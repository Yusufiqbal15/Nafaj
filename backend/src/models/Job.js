const pool = require('../config/database');

class Job {
  static async create(jobData) {
    const {
      title,
      description,
      categoryId,
      userId,
      budget,
      location,
      deadline,
      status,
      company,
      phone,
      jobType,
      salaryText,
      sector,
    } = jobData;

    const query = `
      INSERT INTO jobs (title, description, category_id, user_id, budget, location, deadline, status, company, phone, job_type, salary_text, sector, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
    `;

    const [result] = await pool.execute(query, [
      title,
      description,
      categoryId || null,
      userId || null,
      budget || 0,
      location || null,
      deadline || null,
      status || 'open',
      company || null,
      phone || null,
      jobType || 'Full-time',
      salaryText || 'Negotiable',
      sector || null,
    ]);

    return result;
  }

  static async findById(id) {
    const query = 'SELECT * FROM jobs WHERE id = ? LIMIT 1';
    const [rows] = await pool.execute(query, [id]);
    return rows[0];
  }

  static async findAll(filters = {}) {
    let query = 'SELECT * FROM jobs WHERE 1=1';
    const values = [];

    if (filters.status) {
      query += ' AND status = ?';
      values.push(filters.status);
    }

    if (filters.categoryId) {
      query += ' AND category_id = ?';
      values.push(filters.categoryId);
    }

    if (filters.userId) {
      query += ' AND user_id = ?';
      values.push(filters.userId);
    }

    if (filters.sector) {
      query += ' AND sector = ?';
      values.push(filters.sector);
    }

    query += ' ORDER BY created_at DESC';

    const [rows] = await pool.execute(query, values);
    return rows;
  }

  static async update(id, jobData) {
    const updates = [];
    const values = [];

    Object.keys(jobData).forEach(key => {
      updates.push(`${key} = ?`);
      values.push(jobData[key]);
    });

    values.push(id);

    const query = `UPDATE jobs SET ${updates.join(', ')}, updated_at = NOW() WHERE id = ?`;
    const [result] = await pool.execute(query, values);
    return result;
  }

  static async delete(id) {
    const query = 'DELETE FROM jobs WHERE id = ?';
    const [result] = await pool.execute(query, [id]);
    return result;
  }
}

module.exports = Job;
