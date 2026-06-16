const Product = require('../models/Product');

class ProductController {
  // Create new product (Vendor only)
  static async create(req, res, next) {
    try {
      console.log('=== Create Product Request ===');
      console.log('Body:', req.body);
      console.log('Files:', req.files);
      console.log('User:', req.user);

      const {
        name,
        description,
        category,
        price,
        discountPrice,
        stockQuantity,
        unit,
        images // Cloudinary URLs from body
      } = req.body;

      // Validation
      if (!name || !price) {
        return res.status(400).json({ 
          success: false,
          error: 'Product name and price are required' 
        });
      }

      if (!req.user || req.user.role !== 'vendor') {
        return res.status(403).json({ 
          success: false,
          error: 'Only vendors can add products' 
        });
      }

      // Handle images - prioritize uploaded files, then URLs
      let imageArray = [];
      
      // Check if files were uploaded
      if (req.files && req.files.length > 0) {
        imageArray = req.files.map(file => `/uploads/${file.filename}`);
        console.log('Using uploaded files:', imageArray);
      } 
      // Check if Cloudinary URLs provided in body
      else if (images) {
        // Parse images if it's a string
        if (typeof images === 'string') {
          try {
            imageArray = JSON.parse(images);
          } catch (e) {
            imageArray = [images]; // Single URL as string
          }
        } else if (Array.isArray(images)) {
          imageArray = images;
        }
        console.log('Using Cloudinary URLs:', imageArray);
      }

      const result = await Product.create({
        vendorId: req.user.userId,
        name,
        description,
        category,
        price: parseFloat(price),
        discountPrice: discountPrice ? parseFloat(discountPrice) : null,
        stockQuantity: stockQuantity ? parseInt(stockQuantity) : 0,
        unit: unit || 'piece',
        images: imageArray
      });

      console.log('Product created successfully:', result.insertId);

      res.status(201).json({
        success: true,
        message: 'Product created successfully',
        data: {
          productId: result.insertId,
          name,
          price,
          images: imageArray
        }
      });
    } catch (error) {
      console.error('Error creating product:', error);
      next(error);
    }
  }

  // Get all products (with filters)
  static async getAll(req, res, next) {
    try {
      console.log('=== Getting All Products ===');
      const { category, status, search, limit } = req.query;
      console.log('Filters:', { category, status, search, limit });

      const products = await Product.findAll({
        category,
        status,
        search,
        limit
      });

      console.log('Products from DB:', products.length);

      // Parse images and convert to full URLs
      const parsedProducts = products.map(product => {
        let images = [];
        
        console.log('Product:', product.name, 'Images field:', product.images, 'Type:', typeof product.images);
        
        if (product.images) {
          // Check if already an array (MySQL might auto-parse JSON)
          if (Array.isArray(product.images)) {
            images = product.images;
            console.log('Already an array:', images);
          } else if (typeof product.images === 'string') {
            try {
              // Try parsing as JSON array
              images = JSON.parse(product.images);
              console.log('Parsed as JSON:', images);
            } catch (e) {
              // If parsing fails, it's a plain string path
              console.log('JSON parse failed, treating as string');
              if (product.images.trim() !== '') {
                images = [product.images];
                console.log('Created array from string:', images);
              }
            }
          }
        }
        
        // Convert relative paths to full URLs
        const baseUrl = `${req.protocol}://${req.get('host')}`;
        console.log('Base URL:', baseUrl);
        images = images.map(img => {
          if (img.startsWith('http')) {
            return img; // Already full URL
          } else if (img.startsWith('/')) {
            const fullUrl = `${baseUrl}${img}`;
            console.log('Converted to full URL:', fullUrl);
            return fullUrl;
          } else {
            return `${baseUrl}/${img}`;
          }
        });
        
        console.log('Final images:', images);
        
        return {
          ...product,
          images
        };
      });

      console.log('Parsed products:', parsedProducts.length);
      if (parsedProducts.length > 0) {
        console.log('Sample product images:', parsedProducts[0].images);
      }

      const response = {
        success: true,
        count: parsedProducts.length,
        data: parsedProducts
      };

      console.log('Sending response with', response.count, 'products');
      res.json(response);
    } catch (error) {
      console.error('Error in getAll:', error);
      next(error);
    }
  }

  // Get single product by ID
  static async getById(req, res, next) {
    try {
      const { id } = req.params;

      const product = await Product.findById(id);

      if (!product) {
        return res.status(404).json({ 
          success: false,
          error: 'Product not found' 
        });
      }

      // Parse images - handle both formats
      let images = [];
      if (product.images) {
        try {
          images = JSON.parse(product.images);
        } catch (e) {
          if (typeof product.images === 'string') {
            images = [product.images];
          }
        }
      }
      product.images = images;

      res.json({
        success: true,
        data: product
      });
    } catch (error) {
      next(error);
    }
  }

  // Get vendor's products
  static async getVendorProducts(req, res, next) {
    try {
      if (!req.user || req.user.role !== 'vendor') {
        return res.status(403).json({ 
          success: false,
          error: 'Only vendors can access this endpoint' 
        });
      }

      const { category, status } = req.query;

      const products = await Product.findByVendor(req.user.userId, {
        category,
        status
      });

      // Parse images JSON string to array - handle both formats
      const parsedProducts = products.map(product => {
        let images = [];
        
        if (product.images) {
          // Check if already an array (MySQL might auto-parse JSON)
          if (Array.isArray(product.images)) {
            images = product.images;
          } else if (typeof product.images === 'string') {
            try {
              // Try parsing as JSON
              images = JSON.parse(product.images);
            } catch (e) {
              // If not JSON, check if it's a single string path
              if (product.images.trim() !== '') {
                images = [product.images];
              }
            }
          }
        }
        
        // Convert relative paths to full URLs
        const baseUrl = `${req.protocol}://${req.get('host')}`;
        images = images.map(img => {
          if (img.startsWith('http')) {
            return img;
          } else if (img.startsWith('/')) {
            return `${baseUrl}${img}`;
          } else {
            return `${baseUrl}/${img}`;
          }
        });
        
        return {
          ...product,
          images
        };
      });

      res.json({
        success: true,
        count: parsedProducts.length,
        data: parsedProducts
      });
    } catch (error) {
      console.error('Error getting vendor products:', error);
      next(error);
    }
  }

  // Update product (Vendor only - own products)
  static async update(req, res, next) {
    try {
      const { id } = req.params;

      if (!req.user || req.user.role !== 'vendor') {
        return res.status(403).json({ 
          success: false,
          error: 'Only vendors can update products' 
        });
      }

      // Check if product belongs to vendor
      const product = await Product.findById(id);
      if (!product) {
        return res.status(404).json({ 
          success: false,
          error: 'Product not found' 
        });
      }

      if (product.vendor_id !== req.user.userId) {
        return res.status(403).json({ 
          success: false,
          error: 'You can only update your own products' 
        });
      }

      const {
        name,
        description,
        category,
        price,
        discountPrice,
        stockQuantity,
        unit,
        images,
        status,
        isFeatured
      } = req.body;

      await Product.update(id, {
        name,
        description,
        category,
        price,
        discountPrice,
        stockQuantity,
        unit,
        images,
        status,
        isFeatured
      });

      res.json({ 
        success: true,
        message: 'Product updated successfully' 
      });
    } catch (error) {
      next(error);
    }
  }

  // Delete product (Vendor only - own products)
  static async delete(req, res, next) {
    try {
      const { id } = req.params;

      if (!req.user || req.user.role !== 'vendor') {
        return res.status(403).json({ 
          success: false,
          error: 'Only vendors can delete products' 
        });
      }

      // Check if product belongs to vendor
      const product = await Product.findById(id);
      if (!product) {
        return res.status(404).json({ 
          success: false,
          error: 'Product not found' 
        });
      }

      if (product.vendor_id !== req.user.userId) {
        return res.status(403).json({ 
          success: false,
          error: 'You can only delete your own products' 
        });
      }

      await Product.delete(id);

      res.json({ 
        success: true,
        message: 'Product deleted successfully' 
      });
    } catch (error) {
      next(error);
    }
  }

  // Update stock
  static async updateStock(req, res, next) {
    try {
      const { id } = req.params;
      const { quantity } = req.body;

      if (!req.user || req.user.role !== 'vendor') {
        return res.status(403).json({ 
          success: false,
          error: 'Only vendors can update stock' 
        });
      }

      // Check if product belongs to vendor
      const product = await Product.findById(id);
      if (!product) {
        return res.status(404).json({ 
          success: false,
          error: 'Product not found' 
        });
      }

      if (product.vendor_id !== req.user.userId) {
        return res.status(403).json({ 
          success: false,
          error: 'You can only update your own products' 
        });
      }

      await Product.updateStock(id, quantity);

      res.json({ 
        success: true,
        message: 'Stock updated successfully' 
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = ProductController;
