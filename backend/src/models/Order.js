const pool = require('../config/database');

class Order {
  static async create(orderData) {
    const {
      userId,
      vendorId,
      orderNumber,
      totalAmount,
      deliveryFee,
      discountAmount,
      finalAmount,
      paymentMethod,
      deliveryAddress,
      deliveryLatitude,
      deliveryLongitude,
      notes
    } = orderData;

    const query = `
      INSERT INTO orders (user_id, vendor_id, order_number, total_amount, delivery_fee, discount_amount, final_amount, payment_method, order_status, delivery_address, delivery_latitude, delivery_longitude, notes, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'pending_vendor_confirmation', ?, ?, ?, ?, NOW())
    `;

    const [result] = await pool.execute(query, [
      userId,
      vendorId,
      orderNumber,
      totalAmount,
      deliveryFee || 0,
      discountAmount || 0,
      finalAmount,
      paymentMethod || 'cash',
      deliveryAddress,
      deliveryLatitude || null,
      deliveryLongitude || null,
      notes || null
    ]);

    return result;
  }

  static async createOrderItem(orderId, itemData) {
    const { productId, quantity, unitPrice, totalPrice } = itemData;

    const query = `
      INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price, created_at)
      VALUES (?, ?, ?, ?, ?, NOW())
    `;

    const [result] = await pool.execute(query, [
      orderId,
      productId,
      quantity,
      unitPrice,
      totalPrice
    ]);

    return result;
  }

  static async findById(id) {
    const query = `
      SELECT o.*,
        d.first_name as driver_first_name,
        d.last_name as driver_last_name,
        d.phone as driver_phone,
        d.vehicle_type as driver_vehicle_type,
        d.vehicle_plate as driver_vehicle_plate
      FROM orders o
      LEFT JOIN drivers d ON o.driver_id = d.id
      WHERE o.id = ? LIMIT 1
    `;
    const [rows] = await pool.execute(query, [id]);
    return rows[0];
  }

  static async findAll(filters = {}) {
    let query = `
      SELECT o.*,
        u.first_name,
        u.last_name,
        u.phone,
        u.email as user_email,
        v.business_name as vendor_name,
        v.email as vendor_email,
        d.first_name as driver_first_name,
        d.last_name as driver_last_name,
        d.phone as driver_phone,
        d.vehicle_type as driver_vehicle_type,
        d.vehicle_plate as driver_vehicle_plate
      FROM orders o
      LEFT JOIN users u ON o.user_id = u.id
      LEFT JOIN vendors v ON o.vendor_id = v.id
      LEFT JOIN drivers d ON o.driver_id = d.id
      WHERE 1=1
    `;
    const values = [];

    if (filters.status) {
      query += ' AND o.order_status = ?';
      values.push(filters.status);
    }

    query += ' ORDER BY o.created_at DESC';

    const [rows] = await pool.execute(query, values);
    return rows;
  }

  static async findByUser(userId, filters = {}) {
    let query = `
      SELECT o.*,
        v.business_name as vendor_name,
        v.email as vendor_email,
        v.phone as vendor_phone,
        u.email as user_email,
        d.first_name as driver_first_name,
        d.last_name as driver_last_name,
        d.phone as driver_phone,
        d.vehicle_type as driver_vehicle_type,
        d.vehicle_plate as driver_vehicle_plate
      FROM orders o
      LEFT JOIN vendors v ON o.vendor_id = v.id
      LEFT JOIN users u ON o.user_id = u.id
      LEFT JOIN drivers d ON o.driver_id = d.id
      WHERE o.user_id = ?
    `;
    const values = [userId];

    if (filters.status) {
      query += ' AND o.order_status = ?';
      values.push(filters.status);
    }

    query += ' ORDER BY o.created_at DESC';

    const [rows] = await pool.execute(query, values);
    return rows;
  }

  static async findByVendor(vendorId, filters = {}) {
    let query = `
      SELECT o.*,
        u.first_name,
        u.last_name,
        u.phone,
        u.email as user_email,
        v.email as vendor_email,
        v.business_name as vendor_name,
        d.first_name as driver_first_name,
        d.last_name as driver_last_name,
        d.phone as driver_phone,
        d.vehicle_type as driver_vehicle_type,
        d.vehicle_plate as driver_vehicle_plate
      FROM orders o
      LEFT JOIN users u ON o.user_id = u.id
      LEFT JOIN vendors v ON o.vendor_id = v.id
      LEFT JOIN drivers d ON o.driver_id = d.id
      WHERE o.vendor_id = ?
    `;
    const values = [vendorId];

    if (filters.status) {
      query += ' AND o.order_status = ?';
      values.push(filters.status);
    }

    query += ' ORDER BY o.created_at DESC';

    const [rows] = await pool.execute(query, values);
    return rows;
  }

  // Find orders that contain at least one item belonging to this vendor's products.
  // Filters by products.vendor_id (not orders.vendor_id) to support multi-vendor carts.
  static async findByVendorProducts(vendorId, filters = {}) {
    let query = `
      SELECT DISTINCT o.*,
        u.first_name, u.last_name, u.phone, u.email as user_email,
        d.first_name as driver_first_name, d.last_name as driver_last_name,
        d.phone as driver_phone, d.vehicle_type as driver_vehicle_type,
        d.vehicle_plate as driver_vehicle_plate
      FROM orders o
      LEFT JOIN users u ON o.user_id = u.id
      LEFT JOIN drivers d ON o.driver_id = d.id
      WHERE EXISTS (
        SELECT 1 FROM order_items oi
        JOIN products p ON oi.product_id = p.id
        WHERE oi.order_id = o.id AND p.vendor_id = ?
      )
    `;
    const values = [vendorId];

    if (filters.status) {
      query += ' AND o.order_status = ?';
      values.push(filters.status);
    }

    query += ' ORDER BY o.created_at DESC';
    const [rows] = await pool.execute(query, values);
    return rows;
  }

  // Get only the order items whose product belongs to the given vendor.
  // Prevents one vendor from seeing another vendor's items in the same order.
  static async getVendorOrderItems(orderId, vendorId) {
    const query = `
      SELECT oi.*,
        p.name as product_name, p.images as product_images,
        p.price as product_price, p.unit as product_unit,
        p.category as product_category
      FROM order_items oi
      JOIN products p ON oi.product_id = p.id
      WHERE oi.order_id = ? AND p.vendor_id = ?
    `;
    const [rows] = await pool.execute(query, [orderId, vendorId]);
    return rows;
  }

  static async findByDriver(driverId, filters = {}) {
    let query = `
      SELECT o.*, 
        v.business_name as vendor_name, 
        v.email as vendor_email,
        v.phone as vendor_phone,
        u.first_name, 
        u.last_name, 
        u.phone as user_phone,
        u.email as user_email
      FROM orders o 
      LEFT JOIN vendors v ON o.vendor_id = v.id 
      LEFT JOIN users u ON o.user_id = u.id 
      WHERE o.driver_id = ?
    `;
    const values = [driverId];

    if (filters.status) {
      query += ' AND o.order_status = ?';
      values.push(filters.status);
    }

    query += ' ORDER BY o.created_at DESC';

    const [rows] = await pool.execute(query, values);
    return rows;
  }

  // Get available orders for drivers (ready for pickup, not assigned yet)
  static async findAvailableForDriver(filters = {}) {
    let query = `
      SELECT o.*, 
        v.business_name as vendor_name, 
        v.shop_address as vendor_address,
        v.email as vendor_email,
        v.phone as vendor_phone,
        u.first_name, 
        u.last_name, 
        u.phone as user_phone,
        u.email as user_email
      FROM orders o 
      LEFT JOIN vendors v ON o.vendor_id = v.id 
      LEFT JOIN users u ON o.user_id = u.id 
      WHERE o.driver_id IS NULL
      AND (o.order_status = 'vendor_confirmed' OR o.order_status = 'ready')
    `;
    const values = [];

    if (filters.status) {
      query += ' AND o.order_status = ?';
      values.push(filters.status);
    }

    query += ' ORDER BY o.created_at DESC';

    const [rows] = await pool.execute(query, values);
    return rows;
  }

  static async getOrderItems(orderId) {
    const query = `
      SELECT 
        oi.*,
        p.id as product_id,
        p.name as product_name,
        p.description as product_description,
        p.images as product_images,
        p.price as product_price,
        p.discount_price as product_discount_price,
        p.category as category_name,
        p.stock_quantity,
        p.unit as product_unit
      FROM order_items oi 
      LEFT JOIN products p ON oi.product_id = p.id 
      WHERE oi.order_id = ?
    `;
    const [rows] = await pool.execute(query, [orderId]);
    return rows;
  }

  static async updateStatus(id, status) {
    const query = 'UPDATE orders SET order_status = ?, updated_at = NOW() WHERE id = ?';
    const [result] = await pool.execute(query, [status, id]);
    return result;
  }

  static async updateStatusWithImage(id, status, imageUrl, imageType) {
    let query, values;
    
    if (imageType === 'pickup') {
      query = 'UPDATE orders SET order_status = ?, pickup_image_url = ?, pickup_timestamp = NOW(), updated_at = NOW() WHERE id = ?';
      values = [status, imageUrl, id];
    } else if (imageType === 'delivery') {
      query = 'UPDATE orders SET order_status = ?, delivery_image_url = ?, delivery_timestamp = NOW(), updated_at = NOW() WHERE id = ?';
      values = [status, imageUrl, id];
    } else {
      // Fallback to regular status update
      return this.updateStatus(id, status);
    }
    
    const [result] = await pool.execute(query, values);
    return result;
  }

  static async assignDriver(id, driverId) {
    // Use 'picked_up' — already in the base ENUM, safe without new migrations
    const query = `
      UPDATE orders
      SET driver_id = ?, order_status = 'picked_up', updated_at = NOW()
      WHERE id = ?
    `;
    const [result] = await pool.execute(query, [driverId, id]);
    return result;
  }

  static async vendorConfirm(id) {
    const query = `
      UPDATE orders
      SET order_status = 'vendor_confirmed', vendor_confirmed_at = NOW(), updated_at = NOW()
      WHERE id = ? AND order_status = 'pending_vendor_confirmation'
    `;
    const [result] = await pool.execute(query, [id]);
    return result;
  }

  static async vendorReject(id) {
    const query = `
      UPDATE orders
      SET order_status = 'cancelled', updated_at = NOW()
      WHERE id = ? AND order_status = 'pending_vendor_confirmation'
    `;
    const [result] = await pool.execute(query, [id]);
    return result;
  }

  static async updatePaymentStatus(id, paymentStatus) {
    const query = 'UPDATE orders SET payment_status = ?, updated_at = NOW() WHERE id = ?';
    const [result] = await pool.execute(query, [paymentStatus, id]);
    return result;
  }

  static async getVendorSalesReport(vendorId, period = 'all_time') {
    let dateFilter = '';

    switch (period) {
      case 'today':
        dateFilter = 'AND DATE(o.created_at) = CURDATE()';
        break;
      case 'week':
        dateFilter = 'AND o.created_at >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)';
        break;
      case 'month':
        dateFilter = 'AND YEAR(o.created_at) = YEAR(CURDATE()) AND MONTH(o.created_at) = MONTH(CURDATE())';
        break;
    }

    const [orders] = await pool.execute(`
      SELECT o.id, o.order_number, o.final_amount, o.order_status, o.payment_method, o.created_at,
        TRIM(CONCAT(COALESCE(u.first_name, ''), ' ', COALESCE(u.last_name, ''))) as customer_name,
        u.email as user_email,
        (
          SELECT GROUP_CONCAT(CONCAT(oi2.quantity, 'x ', p2.name) ORDER BY p2.name SEPARATOR ', ')
          FROM order_items oi2
          JOIN products p2 ON oi2.product_id = p2.id
          WHERE oi2.order_id = o.id AND p2.vendor_id = ?
        ) as items_summary
      FROM orders o
      LEFT JOIN users u ON o.user_id = u.id
      WHERE EXISTS (
        SELECT 1 FROM order_items oi3
        JOIN products p3 ON oi3.product_id = p3.id
        WHERE oi3.order_id = o.id AND p3.vendor_id = ?
      ) ${dateFilter}
      ORDER BY o.created_at DESC
      LIMIT 200
    `, [vendorId, vendorId]);

    const [statsRows] = await pool.execute(`
      SELECT
        COUNT(DISTINCT o.id) as total_orders,
        COALESCE(SUM(CASE WHEN o.order_status = 'delivered' THEN oi.total_price ELSE 0 END), 0) as total_revenue,
        COUNT(DISTINCT CASE WHEN o.order_status = 'delivered' THEN o.id END) as completed_orders,
        COUNT(DISTINCT CASE WHEN o.order_status = 'cancelled' THEN o.id END) as cancelled_orders,
        COUNT(DISTINCT CASE WHEN o.order_status NOT IN ('delivered', 'cancelled') THEN o.id END) as pending_orders
      FROM orders o
      JOIN order_items oi ON oi.order_id = o.id
      JOIN products p ON oi.product_id = p.id
      WHERE p.vendor_id = ? ${dateFilter}
    `, [vendorId]);

    // Previous period revenue for growth comparison
    let prevFilter = '';
    if (period === 'week') {
      prevFilter = 'AND o.created_at >= DATE_SUB(CURDATE(), INTERVAL 13 DAY) AND o.created_at < DATE_SUB(CURDATE(), INTERVAL 6 DAY)';
    } else if (period === 'month') {
      prevFilter = "AND YEAR(o.created_at) = YEAR(DATE_SUB(CURDATE(), INTERVAL 1 MONTH)) AND MONTH(o.created_at) = MONTH(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))";
    }
    let prevRevenue = 0;
    if (prevFilter) {
      const [prevRows] = await pool.execute(
        `SELECT COALESCE(SUM(oi.total_price), 0) as prev_revenue
         FROM orders o
         JOIN order_items oi ON oi.order_id = o.id
         JOIN products p ON oi.product_id = p.id
         WHERE p.vendor_id = ? AND o.order_status = 'delivered' ${prevFilter}`,
        [vendorId]
      );
      prevRevenue = parseFloat(prevRows[0].prev_revenue) || 0;
    }

    const [topProducts] = await pool.execute(`
      SELECT p.name,
        SUM(oi.quantity) as total_sold,
        COALESCE(SUM(oi.total_price), 0) as total_revenue
      FROM order_items oi
      JOIN products p ON oi.product_id = p.id
      JOIN orders o ON oi.order_id = o.id
      WHERE p.vendor_id = ? AND o.order_status != 'cancelled' ${dateFilter}
      GROUP BY p.id, p.name
      ORDER BY total_revenue DESC
      LIMIT 10
    `, [vendorId]);

    const [dailySales] = await pool.execute(`
      SELECT DATE(o.created_at) as sale_date, DAYNAME(o.created_at) as day_name,
        COALESCE(SUM(oi.total_price), 0) as daily_sales, COUNT(DISTINCT o.id) as order_count
      FROM orders o
      JOIN order_items oi ON oi.order_id = o.id
      JOIN products p ON oi.product_id = p.id
      WHERE p.vendor_id = ? AND o.order_status != 'cancelled'
      AND o.created_at >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)
      GROUP BY DATE(o.created_at), DAYNAME(o.created_at)
      ORDER BY sale_date ASC
    `, [vendorId]);

    const s = statsRows[0];
    const totalRevenue = parseFloat(s.total_revenue) || 0;
    const growthPct = prevRevenue > 0 ? Math.round(((totalRevenue - prevRevenue) / prevRevenue) * 100) : 0;

    return {
      orders,
      stats: {
        totalOrders: parseInt(s.total_orders) || 0,
        totalRevenue,
        completedOrders: parseInt(s.completed_orders) || 0,
        cancelledOrders: parseInt(s.cancelled_orders) || 0,
        pendingOrders: parseInt(s.pending_orders) || 0,
        prevRevenue,
        growthPct: prevRevenue > 0 ? growthPct : null,
      },
      topProducts: topProducts.map(p => ({
        name: p.name,
        totalSold: parseInt(p.total_sold) || 0,
        totalRevenue: parseFloat(p.total_revenue) || 0,
      })),
      dailySales,
    };
  }

  static async getVendorStats(vendorId) {
    const [todayStats] = await pool.execute(`
      SELECT COUNT(DISTINCT o.id) as today_orders,
        COALESCE(SUM(oi.total_price), 0) as today_sales
      FROM orders o
      JOIN order_items oi ON oi.order_id = o.id
      JOIN products p ON oi.product_id = p.id
      WHERE p.vendor_id = ? AND DATE(o.created_at) = CURDATE() AND o.order_status != 'cancelled'
    `, [vendorId]);

    const [weekStats] = await pool.execute(`
      SELECT COALESCE(SUM(oi.total_price), 0) as week_sales
      FROM orders o
      JOIN order_items oi ON oi.order_id = o.id
      JOIN products p ON oi.product_id = p.id
      WHERE p.vendor_id = ? AND o.created_at >= DATE_SUB(CURDATE(), INTERVAL 6 DAY) AND o.order_status != 'cancelled'
    `, [vendorId]);

    const [prevWeekStats] = await pool.execute(`
      SELECT COALESCE(SUM(oi.total_price), 0) as prev_week_sales
      FROM orders o
      JOIN order_items oi ON oi.order_id = o.id
      JOIN products p ON oi.product_id = p.id
      WHERE p.vendor_id = ?
      AND o.created_at >= DATE_SUB(CURDATE(), INTERVAL 13 DAY)
      AND o.created_at < DATE_SUB(CURDATE(), INTERVAL 6 DAY)
      AND o.order_status != 'cancelled'
    `, [vendorId]);

    const [monthStats] = await pool.execute(`
      SELECT COALESCE(SUM(oi.total_price), 0) as month_sales
      FROM orders o
      JOIN order_items oi ON oi.order_id = o.id
      JOIN products p ON oi.product_id = p.id
      WHERE p.vendor_id = ?
      AND YEAR(o.created_at) = YEAR(CURDATE()) AND MONTH(o.created_at) = MONTH(CURDATE())
      AND o.order_status != 'cancelled'
    `, [vendorId]);

    const [totalStats] = await pool.execute(`
      SELECT COALESCE(SUM(oi.total_price), 0) as total_sales
      FROM orders o
      JOIN order_items oi ON oi.order_id = o.id
      JOIN products p ON oi.product_id = p.id
      WHERE p.vendor_id = ? AND o.order_status != 'cancelled'
    `, [vendorId]);

    const [dailySales] = await pool.execute(`
      SELECT DATE(o.created_at) as sale_date, DAYNAME(o.created_at) as day_name,
        COALESCE(SUM(oi.total_price), 0) as daily_sales, COUNT(DISTINCT o.id) as order_count
      FROM orders o
      JOIN order_items oi ON oi.order_id = o.id
      JOIN products p ON oi.product_id = p.id
      WHERE p.vendor_id = ?
      AND o.created_at >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)
      AND o.order_status != 'cancelled'
      GROUP BY DATE(o.created_at), DAYNAME(o.created_at)
      ORDER BY sale_date ASC
    `, [vendorId]);

    const weekSales = parseFloat(weekStats[0].week_sales) || 0;
    const prevWeekSales = parseFloat(prevWeekStats[0].prev_week_sales) || 0;
    const weekGrowth = prevWeekSales > 0 ? Math.round(((weekSales - prevWeekSales) / prevWeekSales) * 100) : 0;

    return {
      todayOrders: parseInt(todayStats[0].today_orders) || 0,
      todaySales: parseFloat(todayStats[0].today_sales) || 0,
      weekSales,
      prevWeekSales,
      weekGrowth,
      monthSales: parseFloat(monthStats[0].month_sales) || 0,
      totalSales: parseFloat(totalStats[0].total_sales) || 0,
      dailySales
    };
  }
}

module.exports = Order;
