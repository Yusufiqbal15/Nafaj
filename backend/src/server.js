require('dotenv').config();
const express = require('express');
const cors = require('cors');
require('express-async-errors');
const errorHandler = require('./middleware/errorHandler');

// Import routes
const authRoutes = require('./routes/auth');
const jobRoutes = require('./routes/jobs');
const cartRoutes = require('./routes/cart');
const productRoutes = require('./routes/products');
const orderRoutes = require('./routes/orders');
const adminRoutes = require('./routes/admin');

const app = express();

// Railway injects PORT automatically — always prefer it
const PORT = process.env.PORT || process.env.SERVER_PORT || 8080;

// Startup env check (visible in Railway logs)
console.log('══════════════════════════════════════════════');
console.log('  SERVER STARTUP');
console.log(`  PORT (Railway)  : ${process.env.PORT      || '(not set by Railway)'}`);
console.log(`  PORT (resolved) : ${PORT}`);
console.log(`  NODE_ENV        : ${process.env.NODE_ENV  || '(not set)'}`);
console.log(`  DB_HOST         : ${process.env.DB_HOST   || '(not set)'}`);
console.log(`  DB_NAME         : ${process.env.DB_NAME   || '(not set)'}`);
console.log('══════════════════════════════════════════════');

// Middleware - Enable CORS for all origins (development mode)
app.use(cors({
  origin: true, // Allow all origins in development
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  exposedHeaders: ['Content-Type', 'Authorization'],
  maxAge: 86400 // Cache preflight for 24 hours
}));

// Additional CORS headers for preflight requests
app.options('*', cors());

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Serve static files (uploaded images)
app.use('/uploads', express.static('uploads'));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV
  });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/jobs', jobRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/products', productRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/admin', adminRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Error handling middleware
app.use(errorHandler);

// Bind to 0.0.0.0 so Railway's proxy can reach the container
app.listen(PORT, '0.0.0.0', () => {
  console.log('╔════════════════════════════════════════════════╗');
  console.log('║   Nafaj Backend Server Started                 ║');
  console.log(`║   Listening : 0.0.0.0:${PORT}                       ║`);
  console.log(`║   NODE_ENV  : ${(process.env.NODE_ENV || 'development').padEnd(33)}║`);
  console.log(`║   DB_NAME   : ${(process.env.DB_NAME  || '(not set)').padEnd(33)}║`);
  console.log('╚════════════════════════════════════════════════╝');
});

module.exports = app;
