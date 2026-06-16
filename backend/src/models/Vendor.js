const pool = require('../config/database');

class Vendor {
  static async create(vendorData) {
    const {
      email,
      phone,
      password,
      businessName,
      ownerFirstName,
      ownerLastName,
      businessType,
      shopAddress,
      city,
      ntnNumber
    } = vendorData;

    const query = `
      INSERT INTO vendors (email, phone, password, business_name, owner_first_name, owner_last_name, business_type, shop_address, city, ntn_number, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
    `;

    const [result] = await pool.execute(query, [
      email,
      phone,
      password,
      businessName,
      ownerFirstName,
      ownerLastName,
      businessType,
      shopAddress,
      city,
      ntnNumber
    ]);

    return result;
  }

  static async findByEmail(email) {
    const query = 'SELECT * FROM vendors WHERE email = ? LIMIT 1';
    const [rows] = await pool.execute(query, [email]);
    return rows[0];
  }

  static async findByPhone(phone) {
    const query = 'SELECT * FROM vendors WHERE phone = ? LIMIT 1';
    const [rows] = await pool.execute(query, [phone]);
    return rows[0];
  }

  static async findById(id) {
    const query = 'SELECT * FROM vendors WHERE id = ? LIMIT 1';
    const [rows] = await pool.execute(query, [id]);
    return rows[0];
  }

  static async update(id, vendorData) {
    const updates = [];
    const values = [];

    Object.keys(vendorData).forEach(key => {
      updates.push(`${key} = ?`);
      values.push(vendorData[key]);
    });

    values.push(id);

    const query = `UPDATE vendors SET ${updates.join(', ')}, updated_at = NOW() WHERE id = ?`;
    const [result] = await pool.execute(query, values);
    return result;
  }

  static async findAll(filters = {}) {
    let query = 'SELECT * FROM vendors WHERE 1=1';
    const values = [];

    if (filters.status) {
      query += ' AND status = ?';
      values.push(filters.status);
    }

    if (filters.businessType) {
      query += ' AND business_type = ?';
      values.push(filters.businessType);
    }

    if (filters.city) {
      query += ' AND city = ?';
      values.push(filters.city);
    }

    const [rows] = await pool.execute(query, values);
    return rows;
  }
}

module.exports = Vendor;
