const pool = require('../config/database');

class Product {
  static async create(productData) {
    const {
      vendorId,
      name,
      description,
      category,
      price,
      discountPrice,
      stockQuantity,
      unit,
      images
    } = productData;

    const query = `
      INSERT INTO products (vendor_id, name, description, category, price, discount_price, stock_quantity, unit, images, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
    `;

    const [result] = await pool.execute(query, [

      vendorId,
      name,
      description,
      category,
      price,
      discountPrice || null,
      stockQuantity || 0,  
      unit || 'piece',
      JSON.stringify(images || [])
    ]);

    return result;
  }

  static async findById(id) {
    const query = 'SELECT * FROM products WHERE id = ? AND deleted_at IS NULL LIMIT 1';
    const [rows] = await pool.execute(query, [id]);
    return rows[0];
  }

  static async findByVendor(vendorId, filters = {}) {
    let query = 'SELECT * FROM products WHERE vendor_id = ? AND deleted_at IS NULL';
    const values = [vendorId];

    if (filters.category) {
      query += ' AND category = ?';
      values.push(filters.category);
    }

    if (filters.status) {
      query += ' AND status = ?';
      values.push(filters.status);
    }

    query += ' ORDER BY created_at DESC';

    const [rows] = await pool.execute(query, values);
    return rows;
  }

  static async findAll(filters = {}) {
    let query = 'SELECT p.*, v.business_name as vendor_name FROM products p LEFT JOIN vendors v ON p.vendor_id = v.id WHERE p.deleted_at IS NULL';
    const values = [];

    if (filters.category) {
      query += ' AND p.category = ?';
      values.push(filters.category);
    }

    if (filters.status) {
      query += ' AND p.status = ?';
      values.push(filters.status);
    }

    if (filters.search) {
      query += ' AND (p.name LIKE ? OR p.description LIKE ?)';
      values.push(`%${filters.search}%`, `%${filters.search}%`);
    }

    query += ' ORDER BY p.created_at DESC';

    // Add LIMIT directly in query string to avoid prepared statement issues
    if (filters.limit) {
      const limitValue = parseInt(filters.limit);
      if (!isNaN(limitValue) && limitValue > 0) {
        query += ` LIMIT ${limitValue}`;
      }
    }

    const [rows] = await pool.execute(query, values);
    return rows;
  }

  static async update(id, productData) {
    const updates = [];
    const values = [];

    const allowedFields = {
      name: 'name',
      description: 'description',
      category: 'category',
      price: 'price',
      discountPrice: 'discount_price',
      stockQuantity: 'stock_quantity',
      unit: 'unit',
      images: 'images',
      status: 'status',
      isFeatured: 'is_featured'
    };

    Object.keys(productData).forEach(key => {
      if (allowedFields[key]) {
        if (key === 'images') {
          updates.push(`${allowedFields[key]} = ?`);
          values.push(JSON.stringify(productData[key]));
        } else {
          updates.push(`${allowedFields[key]} = ?`);
          values.push(productData[key]);
        }
      }
    });

    if (updates.length === 0) {
      throw new Error('No valid fields to update');
    }

    values.push(id);

    const query = `UPDATE products SET ${updates.join(', ')}, updated_at = NOW() WHERE id = ?`;
    const [result] = await pool.execute(query, values);
    return result;
  }

  static async delete(id) {
    const query = 'UPDATE products SET deleted_at = NOW() WHERE id = ?';
    const [result] = await pool.execute(query, [id]);
    return result;
  }

  static async updateStock(id, quantity) {
    const query = 'UPDATE products SET stock_quantity = stock_quantity + ?, updated_at = NOW() WHERE id = ?';
    const [result] = await pool.execute(query, [quantity, id]);
    return result;
  }

  static async incrementSales(id, quantity) {
    const query = 'UPDATE products SET total_sales = total_sales + ?, updated_at = NOW() WHERE id = ?';
    const [result] = await pool.execute(query, [quantity, id]);
    return result;
  }
}

module.exports = Product;
