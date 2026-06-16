const express = require('express');
const UserAuthController = require('../controllers/AuthController');
const DriverAuthController = require('../controllers/DriverAuthController');
const VendorAuthController = require('../controllers/VendorAuthController');
const authMiddleware = require('../middleware/auth');
const upload = require('../middleware/upload');

const router = express.Router();

// USER ROUTES
router.post('/user/register', UserAuthController.register);
router.post('/user/login', UserAuthController.login);
router.get('/user/profile', authMiddleware, UserAuthController.getProfile);
router.put('/user/profile', authMiddleware, UserAuthController.updateProfile);

// DRIVER ROUTES
router.post('/driver/register', DriverAuthController.register);
router.post('/driver/login', DriverAuthController.login);
router.get('/driver/profile', authMiddleware, DriverAuthController.getProfile);
router.put('/driver/profile', authMiddleware, DriverAuthController.updateProfile);
router.get('/driver/approval-status', authMiddleware, DriverAuthController.getApprovalStatus);

// VENDOR ROUTES
router.post('/vendor/register', VendorAuthController.register);
router.post('/vendor/login', VendorAuthController.login);
router.get('/vendor/profile', authMiddleware, VendorAuthController.getProfile);
router.put('/vendor/profile', authMiddleware, upload.array('images', 2), VendorAuthController.updateProfile);
router.get('/vendor/approval-status', authMiddleware, VendorAuthController.getApprovalStatus);
router.get('/vendors', VendorAuthController.getAllVendors); // Public endpoint for marketplace

module.exports = router;
