const express = require('express');
const AdminController = require('../controllers/AdminController');

const router = express.Router();

// Simple admin secret key middleware
const adminAuth = (req, res, next) => {
  const key = req.headers['x-admin-key'];
  if (!key || key !== process.env.ADMIN_SECRET) {
    return res.status(403).json({ success: false, error: 'Unauthorized' });
  }
  next();
};

// GET /api/admin/approvals  — list all pending vendors & drivers
router.get('/approvals', adminAuth, AdminController.getPendingApprovals);

// Vendor approval actions
router.put('/vendors/:id/approve', adminAuth, AdminController.approveVendor);
router.put('/vendors/:id/reject', adminAuth, AdminController.rejectVendor);

// Driver approval actions
router.put('/drivers/:id/approve', adminAuth, AdminController.approveDriver);
router.put('/drivers/:id/reject', adminAuth, AdminController.rejectDriver);

module.exports = router;
