const express = require('express');
const CartController = require('../controllers/CartController');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

// All cart routes require authentication
router.use(authMiddleware);

router.post('/add', CartController.addToCart);
router.get('/', CartController.getCart);
router.delete('/:jobId', CartController.removeFromCart);
router.put('/:jobId', CartController.updateCartItem);
router.delete('/', CartController.clearCart);

module.exports = router;
