const express = require('express');
const OrderController = require('../controllers/OrderController');
const authMiddleware = require('../middleware/auth');
const upload = require('../middleware/upload');

const router = express.Router();

// Available orders endpoint (no auth required - anyone can see available orders)
router.get('/driver/orders', (req, res, next) => {
  // If status=available, allow without auth
  if (req.query.status === 'available') {
    return OrderController.getDriverOrders(req, res, next);
  }
  // Otherwise require auth
  authMiddleware(req, res, () => {
    OrderController.getDriverOrders(req, res, next);
  });
});

// Accept order requires authentication
router.patch('/:id/accept', authMiddleware, OrderController.acceptOrder);

// All other routes require authentication
router.use(authMiddleware);

// Create order (User only)
router.post('/', OrderController.create);

// Get orders
router.get('/my-orders', OrderController.getUserOrders);
router.get('/all', OrderController.getAllOrders);
router.get('/vendor/orders', OrderController.getVendorOrders);
router.get('/driver/wallet', OrderController.getDriverWallet);
router.get('/vendor/stats', OrderController.getVendorStats);
router.get('/vendor/sales-report', OrderController.getVendorSalesReport);
router.get('/vendor/sold-products', OrderController.getVendorSoldProducts);

// Vendor confirm / reject an order
router.patch('/vendor/orders/:id/confirm', OrderController.vendorConfirmOrder);
router.patch('/vendor/orders/:id/reject', OrderController.vendorRejectOrder);

// Live order tracking (user/vendor/driver)
router.get('/:id/tracking', OrderController.getOrderTracking);

// Get single order
router.get('/:id', OrderController.getById);

// Update order status
router.patch('/:id/status', OrderController.updateStatus);

// Assign driver (Vendor only)
router.patch('/:id/assign-driver', OrderController.assignDriver);

// Driver updates order status
router.patch('/:id/status/driver', OrderController.updateOrderStatusByDriver);

// Driver updates order status WITH image proof
router.patch('/:id/status/driver/with-image', upload.single('image'), OrderController.updateOrderStatusWithImage);

// User confirms delivery
router.patch('/:id/confirm-delivery', OrderController.confirmDelivery);

// TEST ENDPOINT: Create a test order for debugging
router.post('/vendor/test-order', OrderController.createTestOrder);

module.exports = router;
