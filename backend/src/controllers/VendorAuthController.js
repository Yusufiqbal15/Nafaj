const Vendor = require('../models/Vendor');
const { generateToken, hashPassword, comparePasswords, validateEmail, validatePhone } = require('../utils/helpers');

class VendorAuthController {
  static async register(req, res, next) {
    try {
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
      } = req.body;

      // Validation
      if (!email || !phone || !password || !businessName) {
        return res.status(400).json({ 
          success: false,
          error: 'Email, phone, password, and business name are required' 
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

      // Check if vendor already exists
      const existingVendor = await Vendor.findByEmail(email);
      if (existingVendor) {
        return res.status(400).json({ 
          success: false,
          error: 'Email already registered as vendor' 
        });
      }

      const existingPhone = await Vendor.findByPhone(phone);
      if (existingPhone) {
        return res.status(400).json({ 
          success: false,
          error: 'Phone number already registered as vendor' 
        });
      }

      // Hash password
      const hashedPassword = await hashPassword(password);

      // Create vendor
      const result = await Vendor.create({
        email,
        phone,
        password: hashedPassword,
        businessName,
        ownerFirstName,
        ownerLastName,
        businessType,
        shopAddress,
        city,
        ntnNumber
      });

      // Generate token
      const token = generateToken(result.insertId, email, 'vendor');

      res.status(201).json({
        success: true,
        message: 'Vendor registered successfully',
        data: {
          vendorId: result.insertId,
          email,
          businessName,
          ownerFirstName,
          ownerLastName,
          token,
          userType: 'vendor'
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

      const vendor = await Vendor.findByEmail(email);
      if (!vendor) {
        return res.status(401).json({ error: 'Invalid email or password' });
      }

      const isPasswordValid = await comparePasswords(password, vendor.password);
      if (!isPasswordValid) {
        return res.status(401).json({ error: 'Invalid email or password' });
      }

      // Map DB status to approval state
      let approvalStatus = 'approved';
      if (vendor.status === 'pending_approval') approvalStatus = 'pending';
      else if (vendor.status === 'suspended') approvalStatus = 'rejected';

      const token = generateToken(vendor.id, vendor.email, 'vendor');

      res.json({
        message: 'Login successful',
        vendorId: vendor.id,
        email: vendor.email,
        businessName: vendor.business_name,
        ownerFirstName: vendor.owner_first_name,
        ownerLastName: vendor.owner_last_name,
        businessType: vendor.business_type,
        status: vendor.status,
        approvalStatus,
        token,
        userType: 'vendor'
      });
    } catch (error) {
      next(error);
    }
  }

  static async getApprovalStatus(req, res, next) {
    try {
      const vendor = await Vendor.findById(req.user.userId);
      if (!vendor) {
        return res.status(404).json({ success: false, error: 'Vendor not found' });
      }

      let approvalStatus = 'approved';
      if (vendor.status === 'pending_approval') approvalStatus = 'pending';
      else if (vendor.status === 'suspended') approvalStatus = 'rejected';

      res.json({ success: true, approvalStatus, status: vendor.status });
    } catch (error) {
      next(error);
    }
  }

  static async getProfile(req, res, next) {
    try {
      const vendor = await Vendor.findById(req.user.userId);

      if (!vendor) {
        return res.status(404).json({ error: 'Vendor not found' });
      }

      res.json({
        id: vendor.id,
        email: vendor.email,
        phone: vendor.phone,
        businessName: vendor.business_name,
        ownerFirstName: vendor.owner_first_name,
        ownerLastName: vendor.owner_last_name,
        businessType: vendor.business_type,
        shopAddress: vendor.shop_address,
        city: vendor.city,
        ntnNumber: vendor.ntn_number,
        profileImage: vendor.profile_image,
        bannerImage: vendor.banner_image,
        bio: vendor.bio,
        status: vendor.status,
        rating: vendor.rating,
        reviewsCount: vendor.reviews_count,
        totalProducts: vendor.total_products,
        totalOrders: vendor.total_orders,
        totalEarnings: vendor.total_earnings,
        createdAt: vendor.created_at,
        userType: 'vendor'
      });
    } catch (error) {
      next(error);
    }
  }

  static async updateProfile(req, res, next) {
    try {
      const {
        ownerFirstName,
        ownerLastName,
        phone,
        businessType,
        shopAddress,
        city,
        bio
      } = req.body;

      const updateData = {};
      if (ownerFirstName) updateData.owner_first_name = ownerFirstName;
      if (ownerLastName) updateData.owner_last_name = ownerLastName;
      if (phone) {
        if (!validatePhone(phone)) {
          return res.status(400).json({ 
            success: false,
            error: 'Invalid phone number format' 
          });
        }
        updateData.phone = phone;
      }
      if (businessType) updateData.business_type = businessType;
      if (shopAddress) updateData.shop_address = shopAddress;
      if (city) updateData.city = city;
      if (bio) updateData.bio = bio;
      
      // Handle profile image if uploaded
      if (req.files && req.files.length > 0) {
        const imageUrls = req.files.map(file => `/uploads/${file.filename}`);
        
        // If first image, use as profile image
        if (imageUrls[0]) {
          updateData.profile_image = imageUrls[0];
        }
        
        // If second image, use as banner image
        if (imageUrls[1]) {
          updateData.banner_image = imageUrls[1];
        }
      }

      await Vendor.update(req.user.userId, updateData);

      res.json({ 
        success: true,
        message: 'Vendor profile updated successfully',
        data: updateData
      });
    } catch (error) {
      next(error);
    }
  }

  // Get all vendors (for marketplace listing)
  static async getAllVendors(req, res, next) {
    try {
      const { status, businessType, city, limit } = req.query;

      const filters = {};
      if (status) filters.status = status;
      if (businessType) filters.businessType = businessType;
      if (city) filters.city = city;

      let vendors = await Vendor.findAll(filters);

      // Apply limit if specified
      if (limit) {
        vendors = vendors.slice(0, parseInt(limit));
      }

      // Transform data for frontend
      const transformedVendors = vendors.map(vendor => ({
        id: vendor.id,
        businessName: vendor.business_name,
        businessType: vendor.business_type,
        city: vendor.city,
        shopAddress: vendor.shop_address,
        phone: vendor.phone,
        profileImage: vendor.profile_image,
        bannerImage: vendor.banner_image,
        bio: vendor.bio,
        rating: vendor.rating || 0,
        reviewsCount: vendor.reviews_count || 0,
        totalProducts: vendor.total_products || 0,
        status: vendor.status
      }));

      res.json({
        success: true,
        count: transformedVendors.length,
        data: transformedVendors
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = VendorAuthController;
