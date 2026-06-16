# Backend Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      FLUTTER APP (Frontend)                     │
│                    - Driver Dashboard                           │
│                    - Job Listings                               │
│                    - Cart Management                            │
└────────────────────────────┬────────────────────────────────────┘
                             │
                    HTTP/REST API Calls
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                  NODE.JS EXPRESS SERVER                         │
│                    (Port 5000)                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              API ROUTES                                  │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  /api/auth       - Register, Login, Profile             │  │
│  │  /api/jobs       - Create, Read, Update, Delete         │  │
│  │  /api/cart       - Add, Remove, Update, Clear           │  │
│  │  /api/health     - Server Health Check                  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                          ↓                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │           MIDDLEWARE LAYER                               │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  - JWT Authentication Verification                       │  │
│  │  - CORS (Cross-Origin Resource Sharing)                 │  │
│  │  - Request Validation                                   │  │
│  │  - Error Handling                                       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                          ↓                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │           CONTROLLERS                                    │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  - AuthController (Login/Register logic)                │  │
│  │  - JobController (Job CRUD operations)                  │  │
│  │  - CartController (Cart management)                     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                          ↓                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │           MODELS (Database Layer)                        │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  - User.js (User operations)                            │  │
│  │  - Job.js (Job operations)                              │  │
│  │  - Cart.js (Cart operations)                            │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                      MySQL Query Execution
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                     MYSQL DATABASE                              │
│                   (localhost:3306)                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌───────────┐│
│  │   USERS    │  │   JOBS     │  │   CART     │  │ CATEGORIES││
│  ├────────────┤  ├────────────┤  ├────────────┤  ├───────────┤│
│  │ • id       │  │ • id       │  │ • id       │  │ • id      ││
│  │ • email    │  │ • title    │  │ • user_id  │  │ • name    ││
│  │ • phone    │  │ • desc     │  │ • job_id   │  │ • desc    ││
│  │ • password │  │ • budget   │  │ • quantity │  │ • icon    ││
│  │ • role     │  │ • location │  │            │  │           ││
│  │ • rating   │  │ • status   │  │            │  │           ││
│  └────────────┘  └────────────┘  └────────────┘  └───────────┘│
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Request Flow Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│  1. CLIENT REQUEST                                               │
│     POST /api/auth/login                                         │
│     { "email": "user@test.com", "password": "pass123" }         │
└────────────────────────┬─────────────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────────────┐
│  2. REQUEST PARSING & VALIDATION                                 │
│     - Parse JSON body                                            │
│     - Validate email format                                      │
│     - Validate password strength                                 │
└────────────────────────┬─────────────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────────────┐
│  3. MIDDLEWARE CHAIN                                             │
│     - CORS check ✓                                               │
│     - JSON parser ✓                                              │
│     - Error handler setup ✓                                      │
└────────────────────────┬─────────────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────────────┐
│  4. CONTROLLER: AuthController.login()                           │
│     - Find user by email                                         │
│     - Compare passwords using bcrypt                             │
│     - Generate JWT token                                         │
└────────────────────────┬─────────────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────────────┐
│  5. MODEL: User.findByEmail(email)                               │
│     - Execute SQL query                                          │
│     - Return user data                                           │
└────────────────────────┬─────────────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────────────┐
│  6. DATABASE: MySQL Query Execution                              │
│     SELECT * FROM users WHERE email = ?                          │
└────────────────────────┬─────────────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────────────┐
│  7. RESPONSE GENERATION                                          │
│     {                                                             │
│       "message": "Login successful",                             │
│       "token": "eyJhbGciOiJIUzI1NiIs...",                       │
│       "userId": 1,                                               │
│       "email": "user@test.com"                                   │
│     }                                                             │
└────────────────────────┬─────────────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────────────┐
│  8. RESPONSE SENT TO CLIENT                                      │
│     Status: 200 OK                                               │
│     Body: Response JSON                                          │
└──────────────────────────────────────────────────────────────────┘
```

## Authentication Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    REGISTRATION                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. User submits registration form                             │
│     ↓                                                           │
│  2. Validate input (email, phone, password)                    │
│     ↓                                                           │
│  3. Check if user already exists                               │
│     ↓                                                           │
│  4. Hash password with bcryptjs (salt: 10)                     │
│     ↓                                                           │
│  5. Store user in database                                      │
│     ↓                                                           │
│  6. Generate JWT token (expires in 7 days)                     │
│     ↓                                                           │
│  7. Return token to client                                      │
│     ↓                                                           │
│  8. Client stores token in SharedPreferences                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    LOGIN                                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. User submits login credentials                             │
│     ↓                                                           │
│  2. Find user by email in database                             │
│     ↓                                                           │
│  3. Compare input password with stored hash                     │
│     ↓                                                           │
│  4. If valid: Generate JWT token                               │
│     ↓                                                           │
│  5. Return token + user info to client                          │
│     ↓                                                           │
│  6. Client stores token locally                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│              AUTHENTICATED REQUEST FLOW                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Client adds token to request header:                       │
│     Authorization: Bearer <token>                              │
│     ↓                                                           │
│  2. Server receives request                                     │
│     ↓                                                           │
│  3. Middleware extracts token from header                       │
│     ↓                                                           │
│  4. Verify token signature with JWT_SECRET                      │
│     ↓                                                           │
│  5. Check token expiration                                      │
│     ↓                                                           │
│  6. If valid: Extract user data (userId, email, role)          │
│     ↓                                                           │
│  7. Attach user info to request object (req.user)              │
│     ↓                                                           │
│  8. Pass to controller with authenticated user                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow Example: Creating a Job

```
┌────────────────────────────────────────────────────┐
│         FLUTTER APP - Job Creation Screen          │
│                                                    │
│  User fills form:                                  │
│  - Title: "Delivery to downtown"                   │
│  - Description: "Quick package delivery"           │
│  - Budget: 500                                     │
│  - Location: "Karachi"                             │
│                                                    │
│  User clicks "Create Job"                          │
└────────────────┬─────────────────────────────────┘
                 │
    ApiService.createJob() with token
                 │
                 ▼
┌────────────────────────────────────────────────────┐
│     POST /api/jobs                                 │
│     Headers: Authorization: Bearer <token>         │
│     Body: {                                        │
│       title: "Delivery to downtown",               │
│       description: "Quick package delivery",       │
│       budget: 500,                                 │
│       location: "Karachi"                          │
│     }                                              │
└────────────────┬─────────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────────┐
│         Express Server Receives Request            │
│                                                    │
│  1. Auth Middleware verifies token                 │
│  2. Extracts userId from token                     │
│  3. Passes to JobController.createJob()            │
└────────────────┬─────────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────────┐
│     JobController.createJob()                      │
│                                                    │
│  1. Validate input data                            │
│  2. Call Job.create() model                        │
│  3. Pass user_id from authenticated session        │
└────────────────┬─────────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────────┐
│     Job.create() Model                             │
│                                                    │
│  Prepare SQL INSERT statement:                     │
│  INSERT INTO jobs (                                │
│    title,                                          │
│    description,                                    │
│    user_id,                                        │
│    budget,                                         │
│    location,                                       │
│    status,                                         │
│    created_at                                      │
│  ) VALUES (?, ?, ?, ?, ?, 'open', NOW())           │
└────────────────┬─────────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────────┐
│     MySQL Database                                 │
│                                                    │
│  INSERT INTO jobs (...)                            │
│                                                    │
│  ✓ Job stored with ID = 5                          │
│  ✓ Status = 'open'                                 │
│  ✓ User = logged-in user                           │
│  ✓ Timestamp recorded                              │
└────────────────┬─────────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────────┐
│     Return Response to Controller                  │
│                                                    │
│  {                                                 │
│    insertId: 5,                                    │
│    affectedRows: 1                                 │
│  }                                                 │
└────────────────┬─────────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────────┐
│     JobController Returns Response                 │
│                                                    │
│  res.status(201).json({                            │
│    message: "Job created successfully",            │
│    jobId: 5                                        │
│  })                                                │
└────────────────┬─────────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────────┐
│     Flutter App Receives Response                  │
│                                                    │
│  Status: 201 Created                               │
│  Body: {                                           │
│    message: "Job created successfully",            │
│    jobId: 5                                        │
│  }                                                 │
│                                                    │
│  Show success message                              │
│  Navigate back to job listings                     │
│  New job appears in list                           │
└────────────────────────────────────────────────────┘
```

## Error Handling Flow

```
┌──────────────────────────────────────────────┐
│           Error Occurs Somewhere             │
│        (Database error, validation, etc)     │
└────────────────┬─────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────┐
│     throw new Error("Message")               │
└────────────────┬─────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────┐
│   Express Catches Error (catch block)        │
│   Passes to next(error)                      │
└────────────────┬─────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────┐
│   Global Error Handler Middleware            │
│   (errorHandler.js)                          │
│                                              │
│   1. Log error details                       │
│   2. Determine error type                    │
│   3. Set appropriate HTTP status             │
│   4. Format error response                   │
│   5. Send to client                          │
└────────────────┬─────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────┐
│   Client Receives Error Response             │
│                                              │
│   {                                          │
│     error: "User-friendly error message"     │
│   }                                          │
│                                              │
│   Display error to user                      │
└──────────────────────────────────────────────┘
```

---

## File Dependencies

```
server.js (Main Entry Point)
├── config/database.js (MySQL Connection)
├── middleware/auth.js (JWT Verification)
├── middleware/errorHandler.js (Error Handling)
├── routes/
│   ├── auth.js
│   │   └── controllers/AuthController.js
│   │       └── models/User.js
│   │           └── utils/helpers.js
│   ├── jobs.js
│   │   └── controllers/JobController.js
│   │       └── models/Job.js
│   └── cart.js
│       └── controllers/CartController.js
│           └── models/Cart.js
└── utils/helpers.js (Utilities)
    ├── generateToken()
    ├── hashPassword()
    └── validateEmail()
```

---

## Summary

✅ **Complete MVC Architecture**
- Models: Database operations
- Views: JSON responses
- Controllers: Business logic

✅ **Secure Authentication**
- Password hashing with bcryptjs
- JWT tokens with expiration
- Protected routes

✅ **Database Relationships**
- Users → Jobs (One-to-Many)
- Users → Cart (One-to-Many)
- Cart → Jobs (Many-to-One)

✅ **Error Handling**
- Centralized error handler
- Input validation
- Meaningful error messages

✅ **Scalable Design**
- Middleware architecture
- Modular controllers
- Separation of concerns
