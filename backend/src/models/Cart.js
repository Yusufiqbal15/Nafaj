const pool = require('../config/database');

class Cart {
  static async addItem(userId, jobId, quantity = 1) {
    const query = `
      INSERT INTO cart (user_id, job_id, quantity, created_at)
      VALUES (?, ?, ?, NOW())
      ON DUPLICATE KEY UPDATE quantity = quantity + ?
    `;

    const [result] = await pool.execute(query, [userId, jobId, quantity, quantity]);
    return result;
  }

  static async removeItem(userId, jobId) {
    const query = 'DELETE FROM cart WHERE user_id = ? AND job_id = ?';
    const [result] = await pool.execute(query, [userId, jobId]);
    return result;
  }

  static async getCart(userId) {
    const query = `
      SELECT c.*, j.title, j.budget, j.location 
      FROM cart c
      JOIN jobs j ON c.job_id = j.id
      WHERE c.user_id = ?
      ORDER BY c.created_at DESC
    `;

    const [rows] = await pool.execute(query, [userId]);
    return rows;
  }

  static async updateQuantity(userId, jobId, quantity) {
    const query = 'UPDATE cart SET quantity = ? WHERE user_id = ? AND job_id = ?';
    const [result] = await pool.execute(query, [quantity, userId, jobId]);
    return result;
  }

  static async clearCart(userId) {
    const query = 'DELETE FROM cart WHERE user_id = ?';
    const [result] = await pool.execute(query, [userId]);
    return result;
  }
}

module.exports = Cart;
