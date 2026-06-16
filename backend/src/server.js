require('dotenv').config();
const express = require('express');
const cors    = require('cors');
require('express-async-errors');

// ─── Global crash guards — must be first ─────────────────────────────────────
process.on('unhandledRejection', (reason) => {
  console.error('UNHANDLED REJECTION:', reason);
});
process.on('uncaughtException', (err) => {
  console.error('UNCAUGHT EXCEPTION:', err.message);
  // Do NOT exit — let Railway healthcheck keep succeeding
});

// ─── Port — Railway injects this, NEVER hardcode ─────────────────────────────
const PORT = parseInt(process.env.PORT, 10) || 8080;

// ─── Express app ─────────────────────────────────────────────────────────────
const app = express();

// ─── CORS ─────────────────────────────────────────────────────────────────────
app.use(cors({
  origin: true,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  maxAge: 86400,
}));
app.options('*', cors());

// ─── Body parsers ─────────────────────────────────────────────────────────────
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// ─── Static files ─────────────────────────────────────────────────────────────
app.use('/uploads', express.static('uploads'));

// ─── Request logger ───────────────────────────────────────────────────────────
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} ${req.method} ${req.path}`);
  next();
});

// ─── Health check — registered before EVERYTHING else ────────────────────────
// Railway hits this during deploy to decide if the service is healthy.
// It must respond even if routes fail to load.
app.get('/api/health', (_req, res) => {
  res.json({ status: 'OK', port: PORT, ts: new Date().toISOString() });
});

// ─── Start listening IMMEDIATELY — before loading routes ─────────────────────
// Reason: if any require('./routes/...') throws synchronously (missing dep,
// syntax error, bad import), app.listen() would never be called and Railway's
// proxy gets TCP_INVALID_SYN on every health check hit.
// By listening first, the process is always reachable.
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log('═══════════════════════════════════════════════════════');
  console.log(`  NAFAJ BACKEND LISTENING`);
  console.log(`  Interface  : 0.0.0.0`);
  console.log(`  PORT (env) : ${process.env.PORT ?? '(Railway did not inject PORT)'}`);
  console.log(`  PORT (used): ${PORT}`);
  console.log(`  NODE_ENV   : ${process.env.NODE_ENV ?? 'not set'}`);
  console.log(`  DB_HOST    : ${process.env.DB_HOST  ?? 'not set'}`);
  console.log(`  DB_PORT    : ${process.env.DB_PORT  ?? 'not set'}`);
  console.log(`  DB_NAME    : ${process.env.DB_NAME  ?? 'not set'}`);
  console.log('═══════════════════════════════════════════════════════');
});

server.on('error', (err) => {
  console.error(`HTTP server error on port ${PORT}:`, err.message);
});

// ─── Load routes AFTER listening so startup is never blocked ─────────────────
try {
  const errorHandler  = require('./middleware/errorHandler');
  const authRoutes    = require('./routes/auth');
  const jobRoutes     = require('./routes/jobs');
  const cartRoutes    = require('./routes/cart');
  const productRoutes = require('./routes/products');
  const orderRoutes   = require('./routes/orders');
  const adminRoutes   = require('./routes/admin');

  app.use('/api/auth',     authRoutes);
  app.use('/api/jobs',     jobRoutes);
  app.use('/api/cart',     cartRoutes);
  app.use('/api/products', productRoutes);
  app.use('/api/orders',   orderRoutes);
  app.use('/api/admin',    adminRoutes);

  app.use((_req, res) => res.status(404).json({ error: 'Route not found' }));
  app.use(errorHandler);

  console.log('✓ All routes loaded successfully');
} catch (err) {
  console.error('✗ Route loading failed — server still running, only health check will work:', err.message);

  // Fallback 404 so the server doesn't hang on unregistered routes
  app.use((_req, res) => res.status(503).json({
    error: 'Server misconfiguration — routes failed to load',
    detail: err.message,
  }));
}

// ─── Graceful shutdown ────────────────────────────────────────────────────────
process.on('SIGTERM', () => {
  console.log('SIGTERM received — shutting down gracefully');
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});

module.exports = app;
