const pool = require('../config/database');

class User {
  static async create(userData) {
    const { email, phone, password, firstName, lastName } = userData;
    const query = `
      INSERT INTO users (email, phone, password, first_name, last_name, created_at)
      VALUES (?, ?, ?, ?, ?, NOW())
    `;
    const [result] = await pool.execute(query, [
      email,
      phone,
      password,
      firstName,
      lastName
    ]);
    return result;
  }

  static async findByEmail(email) {
    const query = 'SELECT * FROM users WHERE email = ? LIMIT 1';
    const [rows] = await pool.execute(query, [email]);
    return rows[0];
  }

  static async findByPhone(phone) {
    const query = 'SELECT * FROM users WHERE phone = ? LIMIT 1';
    const [rows] = await pool.execute(query, [phone]);
    return rows[0];
  }

  static async findById(id) {
    const query = 'SELECT * FROM users WHERE id = ? LIMIT 1';
    const [rows] = await pool.execute(query, [id]);
    return rows[0];
  }

  static async update(id, userData) {
    const updates = [];
    const values = [];

    Object.keys(userData).forEach(key => {
      updates.push(`${key} = ?`);
      values.push(userData[key]);
    });

    values.push(id);

    const query = `UPDATE users SET ${updates.join(', ')}, updated_at = NOW() WHERE id = ?`;
    const [result] = await pool.execute(query, values);
    return result;
  }

  static async findAll(filters = {}) {
    let query = 'SELECT * FROM users WHERE 1=1';
    const values = [];

    if (filters.status) {
      query += ' AND status = ?';
      values.push(filters.status);
    }

    const [rows] = await pool.execute(query, values);
    return rows;
  }
}

module.exports = User;
