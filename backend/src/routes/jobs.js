const express = require('express');
const JobController = require('../controllers/JobController');
const authMiddleware = require('../middleware/auth');
const optionalAuth = require('../middleware/optionalAuth');

const router = express.Router();

router.post('/', optionalAuth, JobController.createJob);
router.get('/search', JobController.searchJobs);
router.get('/', JobController.getJobs);
router.get('/:id', JobController.getJob);
router.put('/:id', authMiddleware, JobController.updateJob);
router.delete('/:id', authMiddleware, JobController.deleteJob);

module.exports = router;
