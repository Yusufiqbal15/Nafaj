# Quick Start Guide - Nafaj Backend

## 🚀 Get Started in 5 Minutes

### Prerequisites
- MySQL running on localhost:3306
- Node.js installed
- Terminal/Command Prompt

### Step 1: Navigate to Backend Directory
```bash
cd backend
```

### Step 2: Install Dependencies
```bash
npm install
```

This will install all required packages:
- Express.js (web server)
- MySQL2 (database)
- JWT (authentication)
- bcryptjs (password hashing)

### Step 3: Create MySQL Database
```bash
mysql -u root -p
```

Then in MySQL:
```sql
CREATE DATABASE nafaj;
EXIT;
```

### Step 4: Run Migrations
```bash
npm run migrate
```

This creates all database tables automatically.

### Step 5: Start the Server
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

## ✅ Verify it's Working

### Using curl:
```bash
curl http://localhost:5000/api/health
```

Expected response:
```json
{
  "status": "OK",
  "timestamp": "2024-05-23T...",
  "environment": "development"
}
```

## 📋 API Examples

### Register a New User
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

### Login
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "driver@example.com",
    "password": "SecurePass123"
  }'
```

Save the `token` from the response to use in other requests.

### Get User Profile (Requires Token)
```bash
curl http://localhost:5000/api/auth/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Create a Job
```bash
curl -X POST http://localhost:5000/api/jobs \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "title": "Delivery to Downtown",
    "description": "Quick package delivery needed",
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

### Search Jobs
```bash
curl "http://localhost:5000/api/jobs/search?q=delivery"
```

### Add to Cart
```bash
curl -X POST http://localhost:5000/api/cart/add \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "jobId": 1,
    "quantity": 1
  }'
```

## 🔑 Environment Variables

The `.env` file contains:
```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=Yusuf@15
DB_NAME=nafaj
DB_PORT=3306
SERVER_PORT=5000
NODE_ENV=development
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRE=7d
CORS_ORIGIN=http://localhost:8080,http://localhost:3000
```

Change `JWT_SECRET` for production!

## 📁 Project Structure

```
backend/
├── src/
│   ├── config/database.js          # MySQL connection
│   ├── controllers/                 # Business logic
│   ├── models/                      # Database queries
│   ├── routes/                      # API endpoints
│   ├── middleware/                  # Auth, error handling
│   ├── utils/helpers.js             # Helper functions
│   └── server.js                    # Main app
├── migrations/                      # Database setup
├── package.json
├── .env
└── README.md
```

## 🐛 Troubleshooting

### "connect ECONNREFUSED 127.0.0.1:3306"
- MySQL is not running
- Start MySQL and try again

### "Error: connect ENOTFOUND"
- Check DB_HOST in .env
- Should be `localhost` for local MySQL

### "Port 5000 already in use"
- Change SERVER_PORT in .env to 5001, 5002, etc.
- Or kill the process using port 5000

### "Invalid token" error
- Token may have expired (7 days by default)
- Login again to get a new token
- Token in Authorization header must start with "Bearer "

## 📊 Database Tables

After migrations run, you'll have:

1. **users** - User accounts with auth
2. **categories** - Job categories (Delivery, Rides, etc.)
3. **jobs** - Job listings
4. **cart** - User shopping carts

All tables are created automatically!

## 🚢 Next Steps

1. Run migrations: `npm run migrate`
2. Start server: `npm run dev`
3. Test APIs with curl or Postman
4. Integrate with Flutter app
5. Deploy to production when ready

## 📚 More Help

- Full documentation: See `README.md`
- Flutter integration: See `FLUTTER_INTEGRATION_GUIDE.md`
- Database schema: Check `migrations/` folder

## 💡 Tips

- Use Postman for easier API testing
- Check server logs for errors
- Keep JWT_SECRET secure in production
- Add rate limiting for production
- Enable HTTPS for production

Enjoy! 🎉
