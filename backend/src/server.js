require('dotenv').config();
const express = require('express');
const cors = require('cors');
require('express-async-errors');
const errorHandler = require('./middleware/errorHandler');

// ─── Global crash guards ──────────────────────────────────────────────────────
// Node 18 crashes the process on unhandled rejections by default.
// Log and survive instead of dying silently.
process.on('unhandledRejection', (reason) => {
  console.error('═══ UNHANDLED REJECTION (process kept alive) ═══');
  console.error(reason);
});
process.on('uncaughtException', (err) => {
  console.error('═══ UNCAUGHT EXCEPTION (process kept alive) ═══');
  console.error(err);
});

// ─── Port resolution ──────────────────────────────────────────────────────────
// Railway always injects PORT. Never hardcode a port value here.
const PORT = process.env.PORT || 8080;

// ─── Startup env log (visible in Railway deploy logs) ────────────────────────
console.log('══════════════════════════════════════════════════');
console.log('  NAFAJ BACKEND — STARTUP');
console.log('══════════════════════════════════════════════════');
console.log(`  process.env.PORT  : ${process.env.PORT || '(not injected by Railway)'}`);
console.log(`  PORT resolved to  : ${PORT}`);
console.log(`  NODE_ENV          : ${process.env.NODE_ENV  || '(not set)'}`);
console.log(`  DB_HOST           : ${process.env.DB_HOST   || '(not set)'}`);
console.log(`  DB_PORT           : ${process.env.DB_PORT   || '(not set)'}`);
console.log(`  DB_NAME           : ${process.env.DB_NAME   || '(not set)'}`);
console.log(`  DB_PASSWORD       : ${process.env.DB_PASSWORD ? '[SET]' : '[NOT SET]'}`);
console.log('══════════════════════════════════════════════════');

const app = express();

// ─── Health check — registered FIRST, before anything else ───────────────────
// Must respond instantly. Railway health check hits this during deploy.
// If this times out, Railway marks deploy as failed and URL stops working.
app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    port: PORT,
    environment: process.env.NODE_ENV || 'unknown',
  });
});

// ─── CORS ─────────────────────────────────────────────────────────────────────
app.use(cors({
  origin: true,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  exposedHeaders: ['Content-Type', 'Authorization'],
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

// ─── Routes ───────────────────────────────────────────────────────────────────
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

// ─── 404 ──────────────────────────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// ─── Error handler ────────────────────────────────────────────────────────────
app.use(errorHandler);

// ─── Start listening ──────────────────────────────────────────────────────────
// '0.0.0.0' is required on Railway — without it Node binds to 127.0.0.1
// which Railway's reverse proxy cannot reach from outside the container.
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log('╔═══════════════════════════════════════════════════╗');
  console.log('║  Nafaj Backend is LIVE                            ║');
  console.log(`║  Listening on  : 0.0.0.0:${String(PORT).padEnd(24)}║`);
  console.log(`║  NODE_ENV      : ${(process.env.NODE_ENV || 'development').padEnd(32)}║`);
  console.log(`║  Health check  : http://0.0.0.0:${String(PORT).padEnd(5)}/api/health  ║`);
  console.log('╚═══════════════════════════════════════════════════╝');
});

// Graceful shutdown — Railway sends SIGTERM before stopping a container
process.on('SIGTERM', () => {
  console.log('SIGTERM received — closing HTTP server gracefully');
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});

module.exports = app;
