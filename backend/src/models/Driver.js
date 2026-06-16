const pool = require('../config/database');

class Driver {
  static async create(driverData) {
    const {
      email,
      phone,
      password,
      firstName,
      lastName,
      licenseNumber,
      vehicleType,
      vehiclePlate
    } = driverData;

    const query = `
      INSERT INTO drivers (email, phone, password, first_name, last_name, license_number, vehicle_type, vehicle_plate, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())
    `;

    const [result] = await pool.execute(query, [
      email,
      phone,
      password,
      firstName,
      lastName,
      licenseNumber,
      vehicleType,
      vehiclePlate
    ]);

    return result;
  }

  static async findByEmail(email) {
    const query = 'SELECT * FROM drivers WHERE email = ? LIMIT 1';
    const [rows] = await pool.execute(query, [email]);
    return rows[0];
  }

  static async findByPhone(phone) {
    const query = 'SELECT * FROM drivers WHERE phone = ? LIMIT 1';
    const [rows] = await pool.execute(query, [phone]);
    return rows[0];
  }

  static async findById(id) {
    const query = 'SELECT * FROM drivers WHERE id = ? LIMIT 1';
    const [rows] = await pool.execute(query, [id]);
    return rows[0];
  }

  static async update(id, driverData) {
    const updates = [];
    const values = [];

    Object.keys(driverData).forEach(key => {
      updates.push(`${key} = ?`);
      values.push(driverData[key]);
    });

    values.push(id);

    const query = `UPDATE drivers SET ${updates.join(', ')}, updated_at = NOW() WHERE id = ?`;
    const [result] = await pool.execute(query, values);
    return result;
  }

  // Credit delivery fee to driver wallet (called when order is delivered)
  static async creditWallet(driverId, orderId, orderNumber, amount, description) {
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();

      // Update wallet_balance (may not exist if migration not run) + total_earnings
      try {
        await conn.execute(
          `UPDATE drivers SET wallet_balance = wallet_balance + ?, total_earnings = total_earnings + ?, updated_at = NOW() WHERE id = ?`,
          [amount, amount, driverId]
        );
      } catch {
        // wallet_balance column missing — only update total_earnings
        await conn.execute(
          `UPDATE drivers SET total_earnings = total_earnings + ?, updated_at = NOW() WHERE id = ?`,
          [amount, driverId]
        );
      }

      // Read balance after
      let balanceAfter = amount;
      try {
        const [rows] = await conn.execute(
          `SELECT COALESCE(wallet_balance, total_earnings, 0) as bal FROM drivers WHERE id = ? LIMIT 1`,
          [driverId]
        );
        balanceAfter = parseFloat(rows[0]?.bal ?? amount);
      } catch { /* ignore */ }

      // Insert transaction record (table may not exist if migration not run)
      try {
        await conn.execute(
          `INSERT INTO driver_wallet_transactions (driver_id, order_id, order_number, transaction_type, amount, description, balance_after)
           VALUES (?, ?, ?, 'delivery_fee', ?, ?, ?)`,
          [driverId, orderId, orderNumber, amount, description || `Delivery fee for order ${orderNumber}`, balanceAfter]
        );
      } catch { /* table not created yet — skip transaction log */ }

      await conn.commit();
      return { success: true, balanceAfter };
    } catch (err) {
      await conn.rollback();
      throw err;
    } finally {
      conn.release();
    }
  }

  // Get wallet data for driver (resilient to missing migration)
  static async getWallet(driverId) {
    // Driver base data
    let walletBalance = 0, totalEarnings = 0, totalRides = 0;
    try {
      const [rows] = await pool.execute(
        `SELECT wallet_balance, total_earnings, total_rides FROM drivers WHERE id = ? LIMIT 1`,
        [driverId]
      );
      const d = rows[0] || {};
      walletBalance = parseFloat(d.wallet_balance ?? 0);
      totalEarnings = parseFloat(d.total_earnings ?? 0);
      totalRides = parseInt(d.total_rides ?? 0);
    } catch {
      // wallet_balance column missing — fallback to total_earnings only
      try {
        const [rows] = await pool.execute(
          `SELECT total_earnings, total_rides FROM drivers WHERE id = ? LIMIT 1`,
          [driverId]
        );
        const d = rows[0] || {};
        totalEarnings = parseFloat(d.total_earnings ?? 0);
        walletBalance = totalEarnings;
        totalRides = parseInt(d.total_rides ?? 0);
      } catch { /* ignore */ }
    }

    // Wallet transactions (table may not exist)
    let txRows = [];
    try {
      const [rows] = await pool.execute(
        `SELECT * FROM driver_wallet_transactions WHERE driver_id = ? ORDER BY created_at DESC LIMIT 50`,
        [driverId]
      );
      txRows = rows;
    } catch { /* table not created yet */ }

    // Week stats
    let weekEarnings = 0, weekDeliveries = 0;
    try {
      const [rows] = await pool.execute(
        `SELECT COALESCE(SUM(amount),0) as week_earnings, COUNT(*) as week_deliveries
         FROM driver_wallet_transactions
         WHERE driver_id = ? AND transaction_type = 'delivery_fee'
         AND created_at >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)`,
        [driverId]
      );
      weekEarnings = parseFloat(rows[0]?.week_earnings ?? 0);
      weekDeliveries = parseInt(rows[0]?.week_deliveries ?? 0);
    } catch { /* table not created yet */ }

    // Total deliveries count
    const [deliveryRows] = await pool.execute(
      `SELECT COUNT(*) as total_deliveries FROM orders WHERE driver_id = ? AND order_status = 'delivered'`,
      [driverId]
    );

    // Delivered orders with actual credited amount from wallet transactions
    const [deliveredOrders] = await pool.execute(
      `SELECT o.id, o.order_number, o.final_amount,
              COALESCE(dwt.amount, 500) AS driver_earnings,
              o.delivery_address, o.created_at, o.updated_at,
              COALESCE(v.business_name, 'Unknown Vendor') AS vendor_name,
              TRIM(CONCAT(COALESCE(u.first_name,''), ' ', COALESCE(u.last_name,''))) AS customer_name
       FROM orders o
       LEFT JOIN vendors v ON o.vendor_id = v.id
       LEFT JOIN users u ON o.user_id = u.id
       LEFT JOIN driver_wallet_transactions dwt
         ON dwt.order_id = o.id AND dwt.driver_id = o.driver_id AND dwt.transaction_type = 'delivery_fee'
       WHERE o.driver_id = ? AND o.order_status = 'delivered'
       ORDER BY o.updated_at DESC
       LIMIT 50`,
      [driverId]
    );

    return {
      walletBalance,
      totalEarnings,
      weekEarnings,
      weekDeliveries,
      totalDeliveries: parseInt(deliveryRows[0]?.total_deliveries ?? 0),
      transactions: txRows,
      deliveredOrders,
    };
  }

  static async findAll(filters = {}) {
    let query = 'SELECT * FROM drivers WHERE 1=1';
    const values = [];

    if (filters.status) {
      query += ' AND status = ?';
      values.push(filters.status);
    }

    if (filters.vehicleType) {
      query += ' AND vehicle_type = ?';
      values.push(filters.vehicleType);
    }

    const [rows] = await pool.execute(query, values);
    return rows;
  }
}

module.exports = Driver;
