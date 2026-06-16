const Order = require('../models/Order');
const Product = require('../models/Product');
const Vendor = require('../models/Vendor');
const Driver = require('../models/Driver');

const DELIVERY_FEE = 500; // SDG per delivery to driver

class OrderController {
  // Create new order
  static async create(req, res, next) {
    try {
      const {
        vendorId,
        items,
        deliveryAddress,
        deliveryLatitude,
        deliveryLongitude,
        paymentMethod,
        notes
      } = req.body;

      // Validation
      if (!vendorId || !items || items.length === 0 || !deliveryAddress) {
        return res.status(400).json({ error: 'Vendor, items, and delivery address are required' });
      }

      // Calculate totals
      let totalAmount = 0;
      const orderItems = [];

      for (const item of items) {
        const product = await Product.findById(item.productId);
        
        if (!product) {
          return res.status(404).json({ error: `Product ${item.productId} not found` });
        }

        if (product.stock_quantity < item.quantity) {
          return res.status(400).json({ error: `Insufficient stock for ${product.name}` });
        }

        const itemPrice = product.discount_price || product.price;
        const itemTotal = itemPrice * item.quantity;
        totalAmount += itemTotal;

        orderItems.push({
          productId: item.productId,
          quantity: item.quantity,
          unitPrice: itemPrice,
          totalPrice: itemTotal
        });
      }

      const deliveryFee = DELIVERY_FEE;
      const finalAmount = totalAmount + deliveryFee;

      // Generate order number
      const orderNumber = `ORD-${Date.now()}-${Math.floor(Math.random() * 1000)}`;

      // Create order
      const result = await Order.create({
        userId: req.user.userId,
        vendorId,
        orderNumber,
        totalAmount,
        deliveryFee,
        finalAmount,
        paymentMethod,
        deliveryAddress,
        deliveryLatitude,
        deliveryLongitude,
        notes
      });

      const orderId = result.insertId;

      // Create order items
      for (const item of orderItems) {
        await Order.createOrderItem(orderId, item);
        
        // Update product stock
        await Product.updateStock(item.productId, -item.quantity);
        await Product.incrementSales(item.productId, item.quantity);
      }

      res.status(201).json({
        message: 'Order created successfully',
        orderId,
        orderNumber,
        finalAmount
      });
    } catch (error) {
      next(error);
    }
  }

  // Get ALL orders from database (vendor auth required)
  static async getAllOrders(req, res, next) {
    try {
      if (req.user.role !== 'vendor') {
        return res.status(403).json({
          success: false,
          error: 'Only vendors can access this endpoint'
        });
      }

      const { status } = req.query;
      console.log(`📦 Fetching ALL orders from database (requested by vendor: ${req.user.email})`);

      const orders = await Order.findAll({ status });

      const ordersWithItems = await Promise.all(
        orders.map(async (order) => {
          const items = await Order.getOrderItems(order.id);
          return { ...order, items };
        })
      );

      res.json({
        success: true,
        count: ordersWithItems.length,
        orders: ordersWithItems
      });
    } catch (error) {
      next(error);
    }
  }

  // Get user's orders
  static async getUserOrders(req, res, next) {
    try {
      const { status } = req.query;

      const orders = await Order.findByUser(req.user.userId, { status });

      // Get order items for each order
      const ordersWithItems = await Promise.all(
        orders.map(async (order) => {
          const items = await Order.getOrderItems(order.id);
          return {
            ...order,
            items
          };
        })
      );

      res.json({
        success: true,
        count: ordersWithItems.length,
        orders: ordersWithItems
      });
    } catch (error) {
      next(error);
    }
  }

  // Get vendor's orders (email → vendor ID → orders)
  static async getVendorOrders(req, res, next) {
    try {
      if (req.user.role !== 'vendor') {
        return res.status(403).json({
          success: false,
          error: 'Only vendors can access this endpoint'
        });
      }

      // Derive vendor ID from email in JWT
      const vendor = await Vendor.findByEmail(req.user.email);
      if (!vendor) {
        return res.status(404).json({
          success: false,
          error: `No vendor account found for email: ${req.user.email}`
        });
      }

      const vendorId = vendor.id;
      const { status } = req.query;

      console.log(`📦 Fetching orders for vendor email: ${req.user.email} → id: ${vendorId}`);

      // Filter orders that contain at least one of this vendor's products
      const orders = await Order.findByVendorProducts(vendorId, { status });

      // For each order, only return items belonging to this vendor's products
      const ordersWithItems = await Promise.all(
        orders.map(async (order) => {
          const items = await Order.getVendorOrderItems(order.id, vendorId);
          return { ...order, items };
        })
      );

      res.json({
        success: true,
        vendorId,
        vendorEmail: vendor.email,
        count: ordersWithItems.length,
        orders: ordersWithItems
      });
    } catch (error) {
      next(error);
    }
  }

  // Get vendor's sold products with order tracking (email → vendor ID → orders)
  static async getVendorSoldProducts(req, res, next) {
    try {
      if (req.user.role !== 'vendor') {
        return res.status(403).json({
          success: false,
          error: 'Only vendors can access this endpoint'
        });
      }

      const { status, limit } = req.query;

      // Derive vendor ID from email in JWT
      const vendor = await Vendor.findByEmail(req.user.email);
      if (!vendor) {
        return res.status(404).json({
          success: false,
          error: `No vendor account found for email: ${req.user.email}`
        });
      }

      // Only include orders that contain this vendor's products
      const orders = await Order.findByVendorProducts(vendor.id, { status });

      // Get all sold products with order details (only this vendor's items)
      const soldProducts = [];

      for (const order of orders) {
        const items = await Order.getVendorOrderItems(order.id, vendor.id);
        
        for (const item of items) {
          soldProducts.push({
            productId: item.product_id,
            productName: item.product_name,
            productImage: item.product_images ? JSON.parse(item.product_images)[0] : null,
            quantity: item.quantity,
            unitPrice: item.unit_price,
            totalPrice: item.total_price,
            orderId: order.id,
            orderNumber: order.order_number,
            orderStatus: order.order_status,
            customerName: `${order.first_name || ''} ${order.last_name || ''}`.trim(),
            customerPhone: order.phone,
            deliveryAddress: order.delivery_address,
            driverId: order.driver_id,
            driverName: order.driver_first_name ? `${order.driver_first_name} ${order.driver_last_name || ''}`.trim() : null,
            driverPhone: order.driver_phone,
            createdAt: order.created_at,
            updatedAt: order.updated_at
          });
        }
      }

      // Sort by most recent
      soldProducts.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

      // Apply limit if specified
      const limitedProducts = limit ? soldProducts.slice(0, parseInt(limit)) : soldProducts;

      res.json({
        success: true,
        count: limitedProducts.length,
        products: limitedProducts
      });
    } catch (error) {
      next(error);
    }
  }

  // Vendor confirms an order (pending_vendor_confirmation → vendor_confirmed)
  static async vendorConfirmOrder(req, res, next) {
    try {
      if (req.user.role !== 'vendor') {
        return res.status(403).json({ success: false, error: 'Only vendors can confirm orders' });
      }

      const { id } = req.params;
      const vendor = await Vendor.findByEmail(req.user.email);
      if (!vendor) {
        return res.status(404).json({ success: false, error: 'Vendor not found' });
      }

      const order = await Order.findById(id);
      if (!order) {
        return res.status(404).json({ success: false, error: 'Order not found' });
      }

      // Verify this order contains products from this vendor
      const vendorItems = await Order.getVendorOrderItems(id, vendor.id);
      if (vendorItems.length === 0) {
        return res.status(403).json({ success: false, error: 'This order does not contain your products' });
      }

      if (order.order_status !== 'pending_vendor_confirmation') {
        return res.status(400).json({
          success: false,
          error: `Cannot confirm order in status: ${order.order_status}`
        });
      }

      const result = await Order.vendorConfirm(id);
      if (result.affectedRows === 0) {
        return res.status(400).json({ success: false, error: 'Order could not be confirmed' });
      }

      console.log(`✅ Vendor ${vendor.email} confirmed order ${id}`);
      res.json({
        success: true,
        message: 'Order confirmed — now visible to drivers',
        orderId: id,
        newStatus: 'vendor_confirmed'
      });
    } catch (error) {
      next(error);
    }
  }

  // Vendor rejects an order (pending_vendor_confirmation → cancelled)
  static async vendorRejectOrder(req, res, next) {
    try {
      if (req.user.role !== 'vendor') {
        return res.status(403).json({ success: false, error: 'Only vendors can reject orders' });
      }

      const { id } = req.params;
      const vendor = await Vendor.findByEmail(req.user.email);
      if (!vendor) {
        return res.status(404).json({ success: false, error: 'Vendor not found' });
      }

      const order = await Order.findById(id);
      if (!order) {
        return res.status(404).json({ success: false, error: 'Order not found' });
      }

      const vendorItems = await Order.getVendorOrderItems(id, vendor.id);
      if (vendorItems.length === 0) {
        return res.status(403).json({ success: false, error: 'This order does not contain your products' });
      }

      if (order.order_status !== 'pending_vendor_confirmation') {
        return res.status(400).json({
          success: false,
          error: `Cannot reject order in status: ${order.order_status}`
        });
      }

      const result = await Order.vendorReject(id);
      if (result.affectedRows === 0) {
        return res.status(400).json({ success: false, error: 'Order could not be rejected' });
      }

      console.log(`❌ Vendor ${vendor.email} rejected order ${id}`);
      res.json({
        success: true,
        message: 'Order rejected and cancelled',
        orderId: id,
        newStatus: 'cancelled'
      });
    } catch (error) {
      next(error);
    }
  }

  // Get driver's orders
  static async getDriverOrders(req, res, next) {
    try {
      const { status } = req.query;

      // If status is 'available', get available orders for pickup (no auth needed)
      if (status === 'available') {
        const orders = await Order.findAvailableForDriver({});
        
        const ordersWithItems = await Promise.all(
          orders.map(async (order) => {
            const items = await Order.getOrderItems(order.id);
            return {
              ...order,
              items
            };
          })
        );

        return res.json({
          success: true,
          count: ordersWithItems.length,
          orders: ordersWithItems
        });
      }

      // For driver's own orders, require authentication
      if (!req.user) {
        return res.status(401).json({ 
          success: false,
          error: 'Authentication required. Please login as a driver.' 
        });
      }

      if (req.user.role !== 'driver') {
        return res.status(403).json({ 
          success: false,
          error: 'Only drivers can access this endpoint' 
        });
      }

      // Get orders for authenticated driver only
      const driverId = req.user.userId;
      console.log(`📦 Fetching orders for driver ${driverId} (email: ${req.user.email})`);
      
      const orders = await Order.findByDriver(driverId, { status });

      const ordersWithItems = await Promise.all(
        orders.map(async (order) => {
          const items = await Order.getOrderItems(order.id);
          return {
            ...order,
            items
          };
        })
      );

      res.json({
        success: true,
        count: ordersWithItems.length,
        orders: ordersWithItems,
        driverId: driverId
      });
    } catch (error) {
      next(error);
    }
  }

  // Accept order (driver accepts an available order)
  static async acceptOrder(req, res, next) {
    try {
      const { id } = req.params;

      // Check if user is authenticated and is a driver
      if (!req.user) {
        return res.status(401).json({ 
          success: false,
          error: 'Authentication required. Please login as a driver.' 
        });
      }

      if (req.user.role !== 'driver') {
        return res.status(403).json({ 
          success: false,
          error: 'Only drivers can accept orders' 
        });
      }

      // Check if driver already has an active order
      const driverId = req.user.userId;
      const activeOrders = await Order.findByDriver(driverId, {});
      
      // Filter for orders that are not completed (not delivered or cancelled)
      const incompleteOrders = activeOrders.filter(order => 
        order.order_status !== 'delivered' && order.order_status !== 'cancelled'
      );
      
      if (incompleteOrders.length > 0) {
        return res.status(400).json({ 
          success: false,
          error: 'You already have an active delivery. Please complete it first.',
          activeOrderId: incompleteOrders[0].id,
          activeOrderNumber: incompleteOrders[0].order_number
        });
      }

      const order = await Order.findById(id);

      if (!order) {
        return res.status(404).json({ 
          success: false,
          error: 'Order not found' 
        });
      }

      if (order.driver_id) {
        return res.status(400).json({
          success: false,
          error: 'Order already assigned to a driver'
        });
      }

      // Accept both 'vendor_confirmed' and 'ready' status orders
      const validStatuses = ['vendor_confirmed', 'ready'];
      if (!validStatuses.includes(order.order_status)) {
        return res.status(400).json({
          success: false,
          error: `Order is not available for pickup. Status: ${order.order_status}`
        });
      }

      console.log(`📦 Driver ${driverId} accepting order ${id} → status: picked_up`);

      await Order.assignDriver(id, driverId);

      res.json({
        success: true,
        message: 'Order accepted successfully',
        orderId: id,
        orderStatus: 'picked_up',
        driverId: driverId
      });
    } catch (error) {
      next(error);
    }
  }

  // Get order by ID
  static async getById(req, res, next) {
    try {
      const { id } = req.params;

      const order = await Order.findById(id);

      if (!order) {
        return res.status(404).json({ error: 'Order not found' });
      }

      // Check authorization
      if (req.user.role === 'user' && order.user_id !== req.user.userId) {
        return res.status(403).json({ error: 'Unauthorized' });
      }

      if (req.user.role === 'vendor' && order.vendor_id !== req.user.userId) {
        return res.status(403).json({ error: 'Unauthorized' });
      }

      if (req.user.role === 'driver' && order.driver_id !== req.user.userId) {
        return res.status(403).json({ error: 'Unauthorized' });
      }

      // Get order items
      const items = await Order.getOrderItems(id);

      res.json({
        ...order,
        items
      });
    } catch (error) {
      next(error);
    }
  }

  // Update order status
  static async updateStatus(req, res, next) {
    try {
      const { id } = req.params;
      const { status } = req.body;

      const validStatuses = [
        'pending', 'pending_vendor_confirmation', 'vendor_confirmed',
        'confirmed', 'preparing', 'ready', 'picked_up',
        'out_for_delivery', 'delivering', 'delivered', 'cancelled'
      ];

      if (!validStatuses.includes(status)) {
        return res.status(400).json({ error: 'Invalid status' });
      }

      const order = await Order.findById(id);

      if (!order) {
        return res.status(404).json({ error: 'Order not found' });
      }

      // Authorization check for vendor: verify vendor owns at least one item in this order
      if (req.user.role === 'vendor') {
        const vendor = await Vendor.findByEmail(req.user.email);
        if (!vendor) {
          return res.status(404).json({ error: 'Vendor not found' });
        }
        const vendorItems = await Order.getVendorOrderItems(id, vendor.id);
        if (vendorItems.length === 0) {
          return res.status(403).json({ error: 'Unauthorized' });
        }
      }

      if (req.user.role === 'driver' && order.driver_id !== req.user.userId) {
        return res.status(403).json({ error: 'Unauthorized' });
      }

      await Order.updateStatus(id, status);

      res.json({ success: true, message: 'Order status updated successfully' });
    } catch (error) {
      next(error);
    }
  }

  // Assign driver to order
  static async assignDriver(req, res, next) {
    try {
      const { id } = req.params;
      const { driverId } = req.body;

      if (req.user.role !== 'vendor') {
        return res.status(403).json({ error: 'Only vendors can assign drivers' });
      }

      const order = await Order.findById(id);

      if (!order) {
        return res.status(404).json({ error: 'Order not found' });
      }

      if (order.vendor_id !== req.user.userId) {
        return res.status(403).json({ error: 'Unauthorized' });
      }

      await Order.assignDriver(id, driverId);

      res.json({ message: 'Driver assigned successfully' });
    } catch (error) {
      next(error);
    }
  }

  // Update order status by driver (without image)
  static async updateOrderStatusByDriver(req, res, next) {
    try {
      const { id } = req.params;
      const { status } = req.body;

      if (!req.user || req.user.role !== 'driver') {
        return res.status(403).json({ 
          success: false,
          error: 'Only drivers can update order status' 
        });
      }

      const validStatuses = ['picked_up', 'out_for_delivery', 'delivering', 'delivered'];
      
      if (!validStatuses.includes(status)) {
        return res.status(400).json({ 
          success: false,
          error: 'Invalid status. Use: picked_up, out_for_delivery, delivering, delivered' 
        });
      }

      const order = await Order.findById(id);

      if (!order) {
        return res.status(404).json({ 
          success: false,
          error: 'Order not found' 
        });
      }

      // Verify this order belongs to the authenticated driver
      if (order.driver_id !== req.user.userId) {
        return res.status(403).json({ 
          success: false,
          error: 'You can only update your own orders' 
        });
      }

      await Order.updateStatus(id, status);

      // Credit driver wallet when they mark as delivered
      if (status === 'delivered') {
        try {
          await Driver.creditWallet(
            req.user.userId,
            parseInt(id),
            order.order_number,
            DELIVERY_FEE,
            `Delivery fee — order ${order.order_number}`
          );
          console.log(`💰 Credited ${DELIVERY_FEE} SDG to driver ${req.user.userId} for order ${id}`);
        } catch (walletErr) {
          console.error(`⚠️ Wallet credit failed:`, walletErr.message);
        }
      }

      console.log(`📦 Driver ${req.user.userId} updated order ${id} to status: ${status}`);

      res.json({
        success: true,
        message: 'Order status updated successfully',
        orderId: id,
        newStatus: status
      });
    } catch (error) {
      next(error);
    }
  }

  // Update order status by driver with image proof
  static async updateOrderStatusWithImage(req, res, next) {
    try {
      const { id } = req.params;
      const { status, imageType } = req.body;

      if (!req.user || req.user.role !== 'driver') {
        return res.status(403).json({ 
          success: false,
          error: 'Only drivers can update order status' 
        });
      }

      const validStatuses = ['picked_up', 'out_for_delivery', 'pending_confirmation'];
      const validImageTypes = ['pickup', 'delivery'];
      
      if (!validStatuses.includes(status)) {
        return res.status(400).json({ 
          success: false,
          error: 'Invalid status. Use: picked_up, out_for_delivery, pending_confirmation' 
        });
      }

      if (!imageType || !validImageTypes.includes(imageType)) {
        return res.status(400).json({ 
          success: false,
          error: 'Invalid imageType. Use: pickup, delivery' 
        });
      }

      if (!req.file) {
        return res.status(400).json({ 
          success: false,
          error: 'Image is required for status update' 
        });
      }

      const order = await Order.findById(id);

      if (!order) {
        return res.status(404).json({ 
          success: false,
          error: 'Order not found' 
        });
      }

      // Verify this order belongs to the authenticated driver
      if (order.driver_id !== req.user.userId) {
        return res.status(403).json({ 
          success: false,
          error: 'You can only update your own orders' 
        });
      }

      // Generate image URL
      const imageUrl = `/uploads/${req.file.filename}`;

      // Update order with image
      await Order.updateStatusWithImage(id, status, imageUrl, imageType);

      console.log(`📦 Driver ${req.user.userId} updated order ${id} to status: ${status} with ${imageType} image: ${imageUrl}`);

      res.json({ 
        success: true,
        message: status === 'pending_confirmation' 
          ? 'Delivery image uploaded. Waiting for customer confirmation.'
          : 'Order status updated successfully with image proof',
        orderId: id,
        newStatus: status,
        imageUrl: imageUrl,
        imageType: imageType
      });
    } catch (error) {
      next(error);
    }
  }

  // Get order for live tracking (user/vendor/driver can call)
  static async getOrderTracking(req, res, next) {
    try {
      const { id } = req.params;
      const order = await Order.findById(id);

      if (!order) {
        return res.status(404).json({ success: false, error: 'Order not found' });
      }

      // Authorization: user can only track their own orders
      if (req.user.role === 'user' && order.user_id !== req.user.userId) {
        return res.status(403).json({ success: false, error: 'Unauthorized' });
      }
      if (req.user.role === 'vendor' && order.vendor_id !== req.user.userId) {
        return res.status(403).json({ success: false, error: 'Unauthorized' });
      }
      if (req.user.role === 'driver' && order.driver_id !== req.user.userId) {
        return res.status(403).json({ success: false, error: 'Unauthorized' });
      }

      const items = await Order.getOrderItems(id);

      const driverName = order.driver_first_name
        ? `${order.driver_first_name} ${order.driver_last_name || ''}`.trim()
        : null;

      res.json({
        success: true,
        data: {
          id: order.id,
          orderNumber: order.order_number,
          orderStatus: order.order_status,
          deliveryAddress: order.delivery_address,
          deliveryLatitude: order.delivery_latitude,
          deliveryLongitude: order.delivery_longitude,
          finalAmount: order.final_amount,
          deliveryFee: order.delivery_fee,
          paymentMethod: order.payment_method,
          driverAssigned: order.driver_id !== null,
          driverName,
          driverPhone: order.driver_phone || null,
          driverVehicleType: order.driver_vehicle_type || null,
          driverVehiclePlate: order.driver_vehicle_plate || null,
          vendorName: order.vendor_name || null,
          pickupImageUrl: order.pickup_image_url || null,
          deliveryImageUrl: order.delivery_image_url || null,
          pickupTimestamp: order.pickup_timestamp || null,
          deliveryTimestamp: order.delivery_timestamp || null,
          items,
          createdAt: order.created_at,
          updatedAt: order.updated_at,
        }
      });
    } catch (error) {
      next(error);
    }
  }

  // User confirms delivery (completes the order)
  static async confirmDelivery(req, res, next) {
    try {
      const { id } = req.params;

      if (!req.user || req.user.role !== 'user') {
        return res.status(403).json({ 
          success: false,
          error: 'Only customers can confirm delivery' 
        });
      }

      const order = await Order.findById(id);

      if (!order) {
        return res.status(404).json({ 
          success: false,
          error: 'Order not found' 
        });
      }

      // Verify this order belongs to the authenticated user
      if (order.user_id !== req.user.userId) {
        return res.status(403).json({ 
          success: false,
          error: 'You can only confirm your own orders' 
        });
      }

      // Check if order is in pending_confirmation status
      if (order.order_status !== 'pending_confirmation') {
        return res.status(400).json({ 
          success: false,
          error: 'Order is not ready for confirmation. Current status: ' + order.order_status
        });
      }

      // Update status to delivered
      await Order.updateStatus(id, 'delivered');

      // Credit driver wallet with delivery fee
      if (order.driver_id) {
        try {
          await Driver.creditWallet(
            order.driver_id,
            parseInt(id),
            order.order_number,
            DELIVERY_FEE,
            `Delivery fee — order ${order.order_number}`
          );
          console.log(`💰 Credited ${DELIVERY_FEE} SDG to driver ${order.driver_id} for order ${id}`);
        } catch (walletErr) {
          console.error(`⚠️ Wallet credit failed for driver ${order.driver_id}:`, walletErr.message);
        }
      }

      console.log(`✅ User ${req.user.userId} confirmed delivery for order ${id}`);

      res.json({
        success: true,
        message: 'Delivery confirmed successfully',
        orderId: id,
        newStatus: 'delivered'
      });
    } catch (error) {
      next(error);
    }
  }

  // TEST ENDPOINT: Create a test order for debugging (vendor only)
  static async createTestOrder(req, res, next) {
    try {
      if (!req.user || req.user.role !== 'vendor') {
        return res.status(403).json({
          success: false,
          error: 'Only vendors can create test orders'
        });
      }

      // Derive vendor ID from email in JWT
      const vendor = await Vendor.findByEmail(req.user.email);
      if (!vendor) {
        return res.status(404).json({
          success: false,
          error: `No vendor account found for email: ${req.user.email}`
        });
      }

      const vendorId = vendor.id;
      console.log(`📦 Vendor email: ${req.user.email} → id: ${vendorId} creating test order...`);

      // Get first product from vendor
      const vendorProducts = await Product.findByVendor(vendorId);
      
      if (!vendorProducts || vendorProducts.length === 0) {
        return res.status(400).json({ 
          success: false,
          error: 'No products found. Please create a product first.' 
        });
      }

      const product = vendorProducts[0];
      const itemPrice = product.discount_price || product.price;
      const quantity = 1;
      const totalAmount = itemPrice * quantity;
      const deliveryFee = DELIVERY_FEE;
      const finalAmount = totalAmount + deliveryFee;

      // Generate order number
      const orderNumber = `TEST-${Date.now()}-${Math.floor(Math.random() * 1000)}`;

      // Create test order
      const result = await Order.create({
        userId: 1, // Test user ID
        vendorId: vendorId,
        orderNumber,
        totalAmount,
        deliveryFee,
        finalAmount,
        paymentMethod: 'cash',
        deliveryAddress: 'Test Address, Test City',
        notes: 'Test order for debugging'
      });

      const orderId = result.insertId;

      // Create order item
      await Order.createOrderItem(orderId, {
        productId: product.id,
        quantity,
        unitPrice: itemPrice,
        totalPrice: itemPrice * quantity
      });

      console.log(`✅ Test order created: ${orderNumber} (ID: ${orderId})`);

      res.json({
        success: true,
        message: 'Test order created successfully',
        data: {
          orderId,
          orderNumber,
          totalAmount,
          deliveryFee,
          finalAmount,
          productName: product.name
        }
      });
    } catch (error) {
      console.error(`❌ Error creating test order:`, error);
      next(error);
    }
  }

  // Get driver wallet (balance + transactions + weekly stats)
  static async getDriverWallet(req, res, next) {
    try {
      if (!req.user || req.user.role !== 'driver') {
        return res.status(403).json({ success: false, error: 'Only drivers can access wallet' });
      }
      const wallet = await Driver.getWallet(req.user.userId);
      res.json({ success: true, data: wallet });
    } catch (error) {
      next(error);
    }
  }

  // Get vendor sales report with period filter
  static async getVendorSalesReport(req, res, next) {
    try {
      if (req.user.role !== 'vendor') {
        return res.status(403).json({ success: false, error: 'Only vendors can access this endpoint' });
      }

      const vendor = await Vendor.findByEmail(req.user.email);
      if (!vendor) {
        return res.status(404).json({ success: false, error: `No vendor account found for email: ${req.user.email}` });
      }

      const period = req.query.period || 'all_time';
      const validPeriods = ['today', 'week', 'month', 'all_time'];
      if (!validPeriods.includes(period)) {
        return res.status(400).json({ success: false, error: 'Invalid period. Use: today, week, month, all_time' });
      }

      const report = await Order.getVendorSalesReport(vendor.id, period);

      res.json({ success: true, data: report });
    } catch (error) {
      next(error);
    }
  }

  // Get vendor dashboard stats (email → vendor ID → stats)
  static async getVendorStats(req, res, next) {
    try {
      if (req.user.role !== 'vendor') {
        return res.status(403).json({ success: false, error: 'Only vendors can access this endpoint' });
      }

      // Derive vendor ID from email in JWT
      const vendor = await Vendor.findByEmail(req.user.email);
      if (!vendor) {
        return res.status(404).json({
          success: false,
          error: `No vendor account found for email: ${req.user.email}`
        });
      }

      const vendorId = vendor.id;
      console.log(`📊 Fetching stats for vendor email: ${req.user.email} → id: ${vendorId}`);

      const stats = await Order.getVendorStats(vendorId);

      res.json({
        success: true,
        data: {
          ...stats,
          vendorId,
          vendorEmail: vendor.email,
          rating: parseFloat(vendor?.rating) || 0,
          reviewsCount: parseInt(vendor?.reviews_count) || 0,
        }
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = OrderController;
