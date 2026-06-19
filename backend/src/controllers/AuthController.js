const User = require('../models/User');
const { generateToken, hashPassword, comparePasswords, validateEmail, validatePhone } = require('../utils/helpers');

class UserAuthController {
  static async register(req, res, next) {
    try {
      const { email, phone, password, firstName, lastName } = req.body;

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

      // Check if user already exists
      const existingUser = await User.findByEmail(email);
      if (existingUser) {
        return res.status(400).json({ 
          success: false,
          error: 'Email already registered' 
        });
      }

      const existingPhone = await User.findByPhone(phone);
      if (existingPhone) {
        return res.status(400).json({ 
          success: false,
          error: 'Phone number already registered' 
        });
      }

      // Hash password
      const hashedPassword = await hashPassword(password);

      // Create user
      const result = await User.create({
        email,
        phone,
        password: hashedPassword,
        firstName,
        lastName
      });

      // Generate token
      const token = generateToken(result.insertId, email, 'user');

      res.status(201).json({
        success: true,
        message: 'User registered successfully',
        data: {
          userId: result.insertId,
          email,
          firstName,
          lastName,
          token,
          userType: 'user'
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

      const user = await User.findByEmail(email);
      if (!user) {
        return res.status(401).json({ error: 'Invalid email or password' });
      }

      const isPasswordValid = await comparePasswords(password, user.password);
      if (!isPasswordValid) {
        return res.status(401).json({ error: 'Invalid email or password' });
      }

      const token = generateToken(user.id, user.email, 'user');

      res.json({
        message: 'Login successful',
        userId: user.id,
        email: user.email,
        firstName: user.first_name,
        lastName: user.last_name,
        status: user.status,
        token,
        userType: 'user'
      });
    } catch (error) {
      next(error);
    }
  }

  static async getProfile(req, res, next) {
    try {
      const user = await User.findById(req.user.userId);

      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }

      res.json({
        id: user.id,
        email: user.email,
        phone: user.phone,
        firstName: user.first_name,
        lastName: user.last_name,
        status: user.status,
        rating: user.rating,
        reviewsCount: user.reviews_count,
        createdAt: user.created_at,
        userType: 'user'
      });
    } catch (error) {
      next(error);
    }
  }

  static async updateProfile(req, res, next) {
    try {
      const { firstName, lastName, phone } = req.body;

      const updateData = {};
      if (firstName) updateData.first_name = firstName;
      if (lastName) updateData.last_name = lastName;
      if (phone) {
        if (!validatePhone(phone)) {
          return res.status(400).json({ error: 'Invalid phone number format' });
        }
        updateData.phone = phone;
      }

      await User.update(req.user.userId, updateData);

      res.json({ message: 'User profile updated successfully' });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = UserAuthController;
