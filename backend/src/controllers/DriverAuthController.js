const Driver = require('../models/Driver');
const { generateToken, hashPassword, comparePasswords, validateEmail, validatePhone } = require('../utils/helpers');

class DriverAuthController {
  static async register(req, res, next) {
    try {
      const { email, phone, password, firstName, lastName, licenseNumber, vehicleType, vehiclePlate } = req.body;

      // Validation
      if (!email || !phone || !password) {
        return res.status(400).json({ 
          success: false,
          error: 'Email, phone, and password are required' 
        });
      }

      if (!validateEmail(email)) {
        return res.status(400).json({ 
          success: false,
          error: 'Invalid email format' 
        });
      }

      if (!validatePhone(phone)) {
        return res.status(400).json({ 
          success: false,
          error: 'Invalid phone number. Must be at least 10 digits.'
        });
      }

      // Check if driver already exists
      const existingDriver = await Driver.findByEmail(email);
      if (existingDriver) {
        return res.status(400).json({ 
          success: false,
          error: 'Email already registered as driver' 
        });
      }

      const existingPhone = await Driver.findByPhone(phone);
      if (existingPhone) {
        return res.status(400).json({ 
          success: false,
          error: 'Phone number already registered as driver' 
        });
      }

      // Hash password
      const hashedPassword = await hashPassword(password);

      // Create driver
      const result = await Driver.create({
        email,
        phone,
        password: hashedPassword,
        firstName,
        lastName,
        licenseNumber,
        vehicleType,
        vehiclePlate
      });

      // Generate token
      const token = generateToken(result.insertId, email, 'driver');

      res.status(201).json({
        success: true,
        message: 'Driver registered successfully',
        data: {
          driverId: result.insertId,
          email,
          firstName,
          lastName,
          token,
          userType: 'driver'
        }
      });
    } catch (error) {
      next(error);
    }
  }

  static async login(req, res, next) {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        return res.status(400).json({ error: 'Email and password are required' });
      }

      const driver = await Driver.findByEmail(email);
      if (!driver) {
        return res.status(401).json({ error: 'Invalid email or password' });
      }

      const isPasswordValid = await comparePasswords(password, driver.password);
      if (!isPasswordValid) {
        return res.status(401).json({ error: 'Invalid email or password' });
      }

      // Map DB status to approval state
      let approvalStatus = 'approved';
      if (driver.status === 'pending_verification') approvalStatus = 'pending';
      else if (driver.status === 'suspended') approvalStatus = 'rejected';

      const token = generateToken(driver.id, driver.email, 'driver');

      res.json({
        message: 'Login successful',
        driverId: driver.id,
        email: driver.email,
        firstName: driver.first_name,
        lastName: driver.last_name,
        licenseNumber: driver.license_number,
        vehicleType: driver.vehicle_type,
        status: driver.status,
        approvalStatus,
        token,
        userType: 'driver'
      });
    } catch (error) {
      next(error);
    }
  }

  static async getApprovalStatus(req, res, next) {
    try {
      const driver = await Driver.findById(req.user.userId);
      if (!driver) {
        return res.status(404).json({ success: false, error: 'Driver not found' });
      }

      let approvalStatus = 'approved';
      if (driver.status === 'pending_verification') approvalStatus = 'pending';
      else if (driver.status === 'suspended') approvalStatus = 'rejected';

      res.json({ success: true, approvalStatus, status: driver.status });
    } catch (error) {
      next(error);
    }
  }

  static async getProfile(req, res, next) {
    try {
      const driver = await Driver.findById(req.user.userId);

      if (!driver) {
        return res.status(404).json({ error: 'Driver not found' });
      }

      res.json({
        id: driver.id,
        email: driver.email,
        phone: driver.phone,
        firstName: driver.first_name,
        lastName: driver.last_name,
        licenseNumber: driver.license_number,
        vehicleType: driver.vehicle_type,
        vehiclePlate: driver.vehicle_plate,
        status: driver.status,
        rating: driver.rating,
        reviewsCount: driver.reviews_count,
        totalRides: driver.total_rides,
        totalEarnings: driver.total_earnings,
        createdAt: driver.created_at,
        userType: 'driver'
      });
    } catch (error) {
      next(error);
    }
  }

  static async updateProfile(req, res, next) {
    try {
      const { firstName, lastName, phone, vehicleType, vehiclePlate } = req.body;

      const updateData = {};
      if (firstName) updateData.first_name = firstName;
      if (lastName) updateData.last_name = lastName;
      if (phone) {
        if (!validatePhone(phone)) {
          return res.status(400).json({ error: 'Invalid phone number format' });
        }
        updateData.phone = phone;
      }
      if (vehicleType) updateData.vehicle_type = vehicleType;
      if (vehiclePlate) updateData.vehicle_plate = vehiclePlate;

      await Driver.update(req.user.userId, updateData);

      res.json({ message: 'Driver profile updated successfully' });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = DriverAuthController;
