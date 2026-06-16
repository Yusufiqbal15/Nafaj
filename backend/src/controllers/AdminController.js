const pool = require('../config/database');

class AdminController {
  static async getPendingApprovals(req, res, next) {
    try {
      const [vendors] = await pool.execute(
        `SELECT id, email, business_name, owner_first_name, owner_last_name, city, phone, created_at
         FROM vendors WHERE status = 'pending_approval' ORDER BY created_at DESC`
      );
      const [drivers] = await pool.execute(
        `SELECT id, email, first_name, last_name, license_number, vehicle_type, phone, created_at
         FROM drivers WHERE status = 'pending_verification' ORDER BY created_at DESC`
      );

      res.json({
        success: true,
        data: {
          vendors: vendors.map(v => ({
            id: v.id,
            email: v.email,
            businessName: v.business_name,
            ownerFirstName: v.owner_first_name,
            ownerLastName: v.owner_last_name,
            city: v.city,
            phone: v.phone,
            createdAt: v.created_at,
            userType: 'vendor'
          })),
          drivers: drivers.map(d => ({
            id: d.id,
            email: d.email,
            firstName: d.first_name,
            lastName: d.last_name,
            licenseNumber: d.license_number,
            vehicleType: d.vehicle_type,
            phone: d.phone,
            createdAt: d.created_at,
            userType: 'driver'
          }))
        }
      });
    } catch (error) {
      next(error);
    }
  }

  static async approveVendor(req, res, next) {
    try {
      const { id } = req.params;
      const { notes } = req.body;

      const [rows] = await pool.execute('SELECT id FROM vendors WHERE id = ?', [id]);
      if (!rows.length) {
        return res.status(404).json({ success: false, error: 'Vendor not found' });
      }

      await pool.execute(
        "UPDATE vendors SET status = 'active', updated_at = NOW() WHERE id = ?",
        [id]
      );

      await pool.execute(
        'INSERT INTO admin_approvals (user_type, user_id, action, notes) VALUES (?, ?, ?, ?)',
        ['vendor', id, 'approved', notes || null]
      ).catch(() => {});

      res.json({ success: true, message: 'Vendor approved successfully' });
    } catch (error) {
      next(error);
    }
  }

  static async rejectVendor(req, res, next) {
    try {
      const { id } = req.params;
      const { notes } = req.body;

      const [rows] = await pool.execute('SELECT id FROM vendors WHERE id = ?', [id]);
      if (!rows.length) {
        return res.status(404).json({ success: false, error: 'Vendor not found' });
      }

      await pool.execute(
        "UPDATE vendors SET status = 'suspended', updated_at = NOW() WHERE id = ?",
        [id]
      );

      await pool.execute(
        'INSERT INTO admin_approvals (user_type, user_id, action, notes) VALUES (?, ?, ?, ?)',
        ['vendor', id, 'rejected', notes || null]
      ).catch(() => {});

      res.json({ success: true, message: 'Vendor rejected' });
    } catch (error) {
      next(error);
    }
  }

  static async approveDriver(req, res, next) {
    try {
      const { id } = req.params;
      const { notes } = req.body;

      const [rows] = await pool.execute('SELECT id FROM drivers WHERE id = ?', [id]);
      if (!rows.length) {
        return res.status(404).json({ success: false, error: 'Driver not found' });
      }

      await pool.execute(
        "UPDATE drivers SET status = 'active', updated_at = NOW() WHERE id = ?",
        [id]
      );

      await pool.execute(
        'INSERT INTO admin_approvals (user_type, user_id, action, notes) VALUES (?, ?, ?, ?)',
        ['driver', id, 'approved', notes || null]
      ).catch(() => {});

      res.json({ success: true, message: 'Driver approved successfully' });
    } catch (error) {
      next(error);
    }
  }

  static async rejectDriver(req, res, next) {
    try {
      const { id } = req.params;
      const { notes } = req.body;

      const [rows] = await pool.execute('SELECT id FROM drivers WHERE id = ?', [id]);
      if (!rows.length) {
        return res.status(404).json({ success: false, error: 'Driver not found' });
      }

      await pool.execute(
        "UPDATE drivers SET status = 'suspended', updated_at = NOW() WHERE id = ?",
        [id]
      );

      await pool.execute(
        'INSERT INTO admin_approvals (user_type, user_id, action, notes) VALUES (?, ?, ?, ?)',
        ['driver', id, 'rejected', notes || null]
      ).catch(() => {});

      res.json({ success: true, message: 'Driver rejected' });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = AdminController;
