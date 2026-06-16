const express = require('express');
const ProductController = require('../controllers/ProductController');
const authMiddleware = require('../middleware/auth');
const upload = require('../middleware/upload');

const router = express.Router();

// Public routes
router.get('/', ProductController.getAll);
router.get('/:id', ProductController.getById);

// Protected routes (require authentication)
router.post('/', authMiddleware, upload.array('images', 5), ProductController.create);
router.get('/vendor/my-products', authMiddleware, ProductController.getVendorProducts);
router.put('/:id', authMiddleware, upload.array('images', 5), ProductController.update);
router.delete('/:id', authMiddleware, ProductController.delete);
router.patch('/:id/stock', authMiddleware, ProductController.updateStock);

// Image upload endpoint
router.post('/upload-images', authMiddleware, upload.array('images', 5), (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ error: 'No images uploaded' });
    }

    const imageUrls = req.files.map(file => `/uploads/${file.filename}`);

    res.json({
      success: true,
      message: 'Images uploaded successfully',
      images: imageUrls
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
