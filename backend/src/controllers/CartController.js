const Cart = require('../models/Cart');

class CartController {
  static async addToCart(req, res, next) {
    try {
      const { jobId, quantity = 1 } = req.body;

      if (!jobId) {
        return res.status(400).json({ error: 'Job ID is required' });
      }

      await Cart.addItem(req.user.userId, jobId, quantity);

      res.json({ message: 'Item added to cart successfully' });
    } catch (error) {
      next(error);
    }
  }

  static async getCart(req, res, next) {
    try {
      const cartItems = await Cart.getCart(req.user.userId);

      res.json({
        count: cartItems.length,
        items: cartItems
      });
    } catch (error) {
      next(error);
    }
  }

  static async removeFromCart(req, res, next) {
    try {
      const { jobId } = req.params;

      if (!jobId) {
        return res.status(400).json({ error: 'Job ID is required' });
      }

      await Cart.removeItem(req.user.userId, jobId);

      res.json({ message: 'Item removed from cart successfully' });
    } catch (error) {
      next(error);
    }
  }

  static async updateCartItem(req, res, next) {
    try {
      const { jobId } = req.params;
      const { quantity } = req.body;

      if (!jobId) {
        return res.status(400).json({ error: 'Job ID is required' });
      }

      if (quantity <= 0) {
        return res.status(400).json({ error: 'Quantity must be greater than 0' });
      }

      await Cart.updateQuantity(req.user.userId, jobId, quantity);

      res.json({ message: 'Cart item updated successfully' });
    } catch (error) {
      next(error);
    }
  }

  static async clearCart(req, res, next) {
    try {
      await Cart.clearCart(req.user.userId);

      res.json({ message: 'Cart cleared successfully' });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = CartController;
