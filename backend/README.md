# Nafaj Backend - Node.js with MySQL

Complete backend server for the Nafaj Driver Dashboard application, replacing Firebase with MySQL.

## 📋 Prerequisites

- Node.js 16+ 
- MySQL 8.0+
- npm or yarn

## 🚀 Setup Instructions

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Database Configuration

Update the `.env` file with your MySQL credentials:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=Yusuf@15
DB_NAME=nafaj
DB_PORT=3306
SERVER_PORT=5000
JWT_SECRET=your-super-secret-jwt-key
```

### 3. Create Database

Create the MySQL database manually or the migration will create tables:

```bash
mysql -u root -p -e "CREATE DATABASE nafaj;"
```

### 4. Run Migrations

```bash
npm run migrate
```

This will create all necessary tables:
- `users` - User accounts
- `categories` - Job categories
- `jobs` - Job listings
- `cart` - User shopping cart

### 5. Start the Server

**Development (with auto-reload):**
```bash
npm run dev
```

**Production:**
```bash
npm start
```

The server will start on `http://localhost:5000`

## 📡 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/profile` - Get user profile (requires auth)
- `PUT /api/auth/profile` - Update user profile (requires auth)

### Jobs
- `POST /api/jobs` - Create job (requires auth)
- `GET /api/jobs` - Get all jobs
- `GET /api/jobs/search` - Search jobs
- `GET /api/jobs/:id` - Get job details
- `PUT /api/jobs/:id` - Update job (requires auth)
- `DELETE /api/jobs/:id` - Delete job (requires auth)

### Cart
- `POST /api/cart/add` - Add item to cart (requires auth)
- `GET /api/cart` - Get cart items (requires auth)
- `PUT /api/cart/:jobId` - Update cart quantity (requires auth)
- `DELETE /api/cart/:jobId` - Remove from cart (requires auth)
- `DELETE /api/cart` - Clear cart (requires auth)

## 🔒 Authentication

All protected endpoints require a JWT token in the Authorization header:

```
Authorization: Bearer <token>
```

## 📁 Project Structure

```
backend/
├── src/
│   ├── config/
│   │   └── database.js          # MySQL connection pool
│   ├── controllers/
│   │   ├── AuthController.js    # Auth logic
│   │   ├── JobController.js     # Job operations
│   │   └── CartController.js    # Cart operations
│   ├── models/
│   │   ├── User.js              # User database operations
│   │   ├── Job.js               # Job database operations
│   │   └── Cart.js              # Cart database operations
│   ├── middleware/
│   │   ├── auth.js              # JWT verification
│   │   └── errorHandler.js      # Error handling
│   ├── routes/
│   │   ├── auth.js              # Auth routes
│   │   ├── jobs.js              # Job routes
│   │   └── cart.js              # Cart routes
│   ├── utils/
│   │   └── helpers.js           # Password hashing, JWT generation
│   └── server.js                # Express app setup
├── migrations/
│   ├── migration_users_table.sql
│   ├── migration_categories_table.sql
│   ├── migration_jobs_table.sql
│   ├── migration_cart_table.sql
│   └── run.js                   # Migration runner
├── .env                         # Environment variables
├── package.json
└── README.md
```

## 🔧 Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `DB_HOST` | MySQL host | localhost |
| `DB_USER` | MySQL username | root |
| `DB_PASSWORD` | MySQL password | password |
| `DB_NAME` | Database name | nafaj |
| `DB_PORT` | MySQL port | 3306 |
| `SERVER_PORT` | Node server port | 5000 |
| `NODE_ENV` | Environment | development |
| `JWT_SECRET` | JWT signing key | secret-key |
| `JWT_EXPIRE` | Token expiration | 7d |
| `CORS_ORIGIN` | CORS allowed origins | http://localhost:3000 |

## 📝 Sample API Requests

### Register User
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

### Create Job
```bash
curl -X POST http://localhost:5000/api/jobs \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "title": "Delivery to Downtown",
    "description": "Quick delivery needed",
    "categoryId": 1,
    "budget": 500,
    "location": "Karachi",
    "deadline": "2024-12-31"
  }'
```

## 🐛 Troubleshooting

### Database Connection Error
- Ensure MySQL is running
- Check credentials in `.env`
- Verify database exists

### Port Already in Use
```bash
# Change SERVER_PORT in .env or use:
PORT=3001 npm start
```

### JWT Token Errors
- Ensure JWT_SECRET is set
- Token must be included in Authorization header
- Check token hasn't expired

## 📦 Dependencies

- **express** - Web framework
- **mysql2** - MySQL database driver
- **jsonwebtoken** - JWT authentication
- **bcryptjs** - Password hashing
- **cors** - Cross-origin requests
- **dotenv** - Environment variables
- **validator** - Input validation

## 🚀 Next Steps

1. Update Flutter app to use the backend API
2. Implement payment gateway integration
3. Add email/SMS notifications
4. Set up logging and monitoring
5. Deploy to production server

## 📄 License

MIT
