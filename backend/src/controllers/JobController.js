const Job = require('../models/Job');

class JobController {
  static async createJob(req, res, next) {
    try {
      const { title, description, categoryId, budget, location, deadline, company, phone, jobType, salaryText, sector } = req.body;

      if (!title || !description) {
        return res.status(400).json({ error: 'Title and description are required' });
      }

      const result = await Job.create({
        title,
        description,
        categoryId,
        userId: req.user?.userId || null,
        budget: budget || 0,
        location,
        deadline,
        company,
        phone,
        jobType,
        salaryText,
        sector,
      });

      res.status(201).json({
        success: true,
        message: 'Job created successfully',
        jobId: result.insertId,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getJob(req, res, next) {
    try {
      const job = await Job.findById(req.params.id);

      if (!job) {
        return res.status(404).json({ error: 'Job not found' });
      }

      res.json({ success: true, job });
    } catch (error) {
      next(error);
    }
  }

  static async getJobs(req, res, next) {
    try {
      const filters = {};

      if (req.query.status) filters.status = req.query.status;
      if (req.query.categoryId) filters.categoryId = req.query.categoryId;
      if (req.query.userId) filters.userId = req.query.userId;
      if (req.query.sector) filters.sector = req.query.sector;

      const jobs = await Job.findAll(filters);

      res.json({
        success: true,
        count: jobs.length,
        jobs,
      });
    } catch (error) {
      next(error);
    }
  }

  static async updateJob(req, res, next) {
    try {
      const job = await Job.findById(req.params.id);

      if (!job) {
        return res.status(404).json({ error: 'Job not found' });
      }

      if (job.user_id && job.user_id !== req.user.userId) {
        return res.status(403).json({ error: 'Not authorized to update this job' });
      }

      await Job.update(req.params.id, req.body);

      res.json({ success: true, message: 'Job updated successfully' });
    } catch (error) {
      next(error);
    }
  }

  static async deleteJob(req, res, next) {
    try {
      const job = await Job.findById(req.params.id);

      if (!job) {
        return res.status(404).json({ error: 'Job not found' });
      }

      if (job.user_id && job.user_id !== req.user.userId) {
        return res.status(403).json({ error: 'Not authorized to delete this job' });
      }

      await Job.delete(req.params.id);

      res.json({ success: true, message: 'Job deleted successfully' });
    } catch (error) {
      next(error);
    }
  }

  static async searchJobs(req, res, next) {
    try {
      const { q, status, category, sector } = req.query;

      const filters = {};
      if (status) filters.status = status;
      if (category) filters.categoryId = category;
      if (sector) filters.sector = sector;

      let jobs = await Job.findAll(filters);

      if (q) {
        const lower = q.toLowerCase();
        jobs = jobs.filter(job =>
          job.title.toLowerCase().includes(lower) ||
          job.description.toLowerCase().includes(lower)
        );
      }

      res.json({
        success: true,
        count: jobs.length,
        jobs,
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = JobController;
