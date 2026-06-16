# 🚀 Quick Start Guide

## Step-by-Step Setup

### 1. Install Dependencies
```bash
npm install
```

### 2. Configure Database

Edit `.env` file:
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=Yusuf@15
DB_NAME=nafaj
DB_PORT=3306
```

### 3. Create Database
```bash
# Open MySQL
mysql -u root -p

# Create database
CREATE DATABASE nafaj;

# Exit MySQL
exit;
```

### 4. Run Migrations
```bash
npm run migrate
```

You should see:
```
✓ Completed: migration_users_table.sql
✓ Completed: migration_drivers_table.sql
✓ Completed: migration_vendors_table.sql
✓ Completed: migration_products_table.sql
✓ Completed: migration_orders_table.sql
✓ All migrations completed successfully
```

### 5. Start Server
```bash
npm run dev
```

You should see:
```
╔════════════════════════════════════════════════╗
║   Nafaj Backend Server Started                 ║
║   Port: 5000                                   ║
║   Environment: development                     ║
║   Database: nafaj                              ║
╚════════════════════════════════════════════════╝
```

### 6. Test API

Open another terminal and test:

```bash
# Health check
curl http://localhost:5000/api/health

# Register vendor
curl -X POST http://localhost:5000/api/auth/vendor/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "vendor@test.com",
    "phone": "+249912345679",
    "password": "password123",
    "businessName": "Test Store",
    "ownerFirstName": "Ahmed",
    "ownerLastName": "Ali",
    "city": "Khartoum"
  }'
```

### 7. Success! ✅

Your backend is now running on `http://localhost:5000`

---

## Common Issues

### MySQL Connection Error
- Make sure MySQL is running
- Check credentials in `.env`
- Verify database `nafaj` exists

### Port Already in Use
- Change `SERVER_PORT` in `.env`
- Or stop the process using port 5000

### Migration Errors
- Drop and recreate database
- Run migrations again

---

## Next Steps

1. ✅ Backend is running
2. 📱 Start Flutter app
3. 🧪 Test authentication
4. 🛍️ Test product management
5. 📦 Test order placement

---

## Available Scripts

```bash
npm run dev      # Start development server
npm run start    # Start production server
npm run migrate  # Run database migrations
```

---

## API Documentation

See **TEST_API.md** for complete API documentation and testing examples.

---

**Backend Status**: ✅ Ready
**Port**: 5000
**Database**: nafaj
**Environment**: development
