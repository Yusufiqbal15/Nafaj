# Command Reference - Copy & Paste Ready

## 🚀 Phase 1: Backend Setup Commands

### Step 1: Navigate to Backend Directory
```bash
cd backend
```

### Step 2: Install Dependencies
```bash
npm install
```

*This installs:*
- express (web server)
- mysql2 (database driver)
- jsonwebtoken (JWT auth)
- bcryptjs (password hashing)
- cors (cross-origin support)
- dotenv (environment variables)
- And more...

### Step 3: Create MySQL Database
```bash
mysql -u root -p
```

*Then type your password and run:*
```sql
CREATE DATABASE nafaj;
EXIT;
```

**Alternative (one-liner):**
```bash
mysql -u root -pYusuf@15 -e "CREATE DATABASE nafaj;"
```

### Step 4: Run Database Migrations
```bash
npm run migrate
```

*This creates tables:*
- users
- jobs
- cart
- categories

### Step 5: Start Development Server
```bash
npm run dev
```

*Output should show:*
```
╔════════════════════════════════════════════════╗
║   Nafaj Backend Server Started                 ║
║   Port: 5000                                   ║
║   Environment: development                     ║
║   Database: nafaj                              ║
╚════════════════════════════════════════════════╝
```

### Step 6: Test Backend (in another terminal)
```bash
curl http://localhost:5000/api/health
```

*Expected response:*
```json
{"status":"OK","timestamp":"...","environment":"development"}
```

---

## 🧪 Phase 2: API Testing Commands

### Register New User
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "driver@example.com",
    "phone": "03001234567",
    "password": "SecurePass123",
    "firstName": "John",
    "lastName": "Doe",
    "role": "driver"
  }'
```

**Expected Response:**
```json
{
  "message": "User registered successfully",
  "userId": 1,
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

### Login User
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "driver@example.com",
    "password": "SecurePass123"
  }'
```

**Save the token returned in the response!**

### Get User Profile (requires token)
```bash
curl http://localhost:5000/api/auth/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

Replace `YOUR_TOKEN_HERE` with actual token from login.

### Create a Job (requires token)
```bash
curl -X POST http://localhost:5000/api/jobs \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "title": "Quick Delivery to Downtown",
    "description": "Need package delivered ASAP",
    "categoryId": 1,
    "budget": 500,
    "location": "Karachi",
    "deadline": "2024-12-31"
  }'
```

### Get All Jobs
```bash
curl http://localhost:5000/api/jobs
```

### Get Single Job
```bash
curl http://localhost:5000/api/jobs/1
```

### Search Jobs
```bash
curl "http://localhost:5000/api/jobs/search?q=delivery"
```

### Add to Cart (requires token)
```bash
curl -X POST http://localhost:5000/api/cart/add \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "jobId": 1,
    "quantity": 1
  }'
```

### Get Cart Items (requires token)
```bash
curl http://localhost:5000/api/cart \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Update Cart Quantity (requires token)
```bash
curl -X PUT http://localhost:5000/api/cart/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "quantity": 2
  }'
```

### Remove from Cart (requires token)
```bash
curl -X DELETE http://localhost:5000/api/cart/1 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Clear Cart (requires token)
```bash
curl -X DELETE http://localhost:5000/api/cart \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## 📱 Phase 3: Flutter App Preparation

### Navigate to Flutter App
```bash
cd ../stitch_nafaj_driver_dashboard/nafaj
```

### Update Dependencies
```bash
flutter pub get
```

### Check Flutter Setup
```bash
flutter doctor
```

### Run Flutter App (Android Emulator)
```bash
flutter run
```

### Run Flutter App (iOS Simulator)
```bash
flutter run -d iOS
```

### Run Flutter App (Physical Device)
```bash
flutter run -d <device-id>
```

---

## 🗄️ Phase 4: Database Management

### Verify Database Was Created
```bash
mysql -u root -pYusuf@15
USE nafaj;
SHOW TABLES;
```

*Should show:*
- cart
- categories
- jobs
- users

### View Users Table Structure
```bash
DESCRIBE users;
```

### View All Users
```bash
SELECT * FROM users;
```

### View All Jobs
```bash
SELECT * FROM jobs;
```

### View Categories
```bash
SELECT * FROM categories;
```

### Delete All Test Data (WARNING!)
```bash
DELETE FROM cart;
DELETE FROM jobs;
DELETE FROM users;
```

### Backup Database
```bash
mysqldump -u root -pYusuf@15 nafaj > nafaj_backup.sql
```

### Restore Database
```bash
mysql -u root -pYusuf@15 nafaj < nafaj_backup.sql
```

### Check Database Size
```bash
SELECT 
  ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) as 'Database Size (MB)'
FROM information_schema.TABLES
WHERE table_schema = 'nafaj';
```

### Exit MySQL
```bash
EXIT;
```

---

## 🔧 Troubleshooting Commands

### Check if Backend is Running
```bash
curl http://localhost:5000/api/health
```

### Check if MySQL is Running
```bash
mysql -u root -pYusuf@15 -e "SELECT 1;"
```

### Kill Process on Port 5000 (Windows)
```bash
netstat -ano | findstr :5000
taskkill /PID <PID> /F
```

### Kill Process on Port 5000 (Mac/Linux)
```bash
lsof -ti:5000 | xargs kill -9
```

### View Backend Logs
```bash
# Terminal should show logs (no special command needed)
# Look for errors in the output
```

### Check npm Install Status
```bash
npm list
```

### Clear npm Cache
```bash
npm cache clean --force
```

### Reinstall Dependencies
```bash
rm -rf node_modules package-lock.json
npm install
```

---

## 📊 Monitor Backend

### Using curl to Monitor
```bash
# Run in loop every 5 seconds
while true; do curl -s http://localhost:5000/api/health | jq . && sleep 5; done
```

*Requires `jq` (JSON pretty printer) - install if needed*

---

## 🚀 Production Deployment (Future)

### Environment Variables for Production
```bash
DB_HOST=prod-db-server.com
DB_USER=prod_user
DB_PASSWORD=StrongPassword123!
DB_NAME=nafaj_prod
DB_PORT=3306
SERVER_PORT=5000
NODE_ENV=production
JWT_SECRET=YourVeryLongSecretKey32CharactersMinimum!
JWT_EXPIRE=7d
CORS_ORIGIN=https://yourdomain.com
```

### Start Production Server
```bash
npm start
```

### Enable PM2 for Auto-Restart (Optional)
```bash
npm install -g pm2
pm2 start src/server.js --name "nafaj-backend"
pm2 save
pm2 startup
```

---

## 📝 Quick Reference Summary

| Task | Command |
|------|---------|
| Install Dependencies | `npm install` |
| Create Database | `mysql -u root -pYusuf@15 -e "CREATE DATABASE nafaj;"` |
| Run Migrations | `npm run migrate` |
| Start Dev Server | `npm run dev` |
| Start Prod Server | `npm start` |
| Test Health | `curl http://localhost:5000/api/health` |
| View Backend Logs | Check terminal output |
| Reset Database | `mysql -u root -pYusuf@15 nafaj -e "DROP TABLE users, jobs, cart;"` |
| Backup DB | `mysqldump -u root -pYusuf@15 nafaj > backup.sql` |
| Restore DB | `mysql -u root -pYusuf@15 nafaj < backup.sql` |

---

## ⚡ One-Command Setup (Linux/Mac)

For experienced users (run from project root):

```bash
cd backend && npm install && \
mysql -u root -pYusuf@15 -e "CREATE DATABASE nafaj;" && \
npm run migrate && \
npm run dev
```

---

## 🎯 Common Command Patterns

### Creating a Complex Job with All Fields
```bash
curl -X POST http://localhost:5000/api/jobs \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{
    "title": "Premium Delivery Service",
    "description": "Fast and reliable delivery with insurance",
    "categoryId": 1,
    "budget": 2500,
    "location": "Karachi, Pakistan",
    "deadline": "2024-12-31"
  }'
```

### Filtering Jobs by Category
```bash
curl "http://localhost:5000/api/jobs?categoryId=1"
curl "http://localhost:5000/api/jobs?categoryId=2"
curl "http://localhost:5000/api/jobs?categoryId=3"
```

### Filtering Jobs by Status
```bash
curl "http://localhost:5000/api/jobs?status=open"
curl "http://localhost:5000/api/jobs?status=in_progress"
curl "http://localhost:5000/api/jobs?status=completed"
```

---

## 💾 Data Persistence

All data is stored in MySQL database at:
- **Host:** localhost
- **Port:** 3306
- **Database:** nafaj
- **User:** root

Data persists between server restarts as long as:
- MySQL server is running
- Database hasn't been deleted
- Files haven't been corrupted

---

**Ready to go! Follow GETTING_STARTED.md for the complete step-by-step guide.** 🚀
