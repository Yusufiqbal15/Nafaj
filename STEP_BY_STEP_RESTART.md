# Step by Step Backend Restart Guide 📝

## Current Error You're Seeing:
```
DioException: status code of 500
Response: {success: false, error: Internal Server Error, 
details: Incorrect arguments to mysqld_stmt_execute}
```

## Why This Happens:
✅ Code is FIXED in `Product.js`
❌ Backend is running OLD code (before fix)
⚡ Solution: Restart backend to load NEW code

---

## Option 1: Automatic Restart (Easiest!) 🚀

### Windows Command Prompt:
```bash
cd C:\Users\yusuf\Downloads\stitch_nafaj_driver_dashboard\backend
restart-backend.bat
```

### PowerShell:
```powershell
cd C:\Users\yusuf\Downloads\stitch_nafaj_driver_dashboard\backend
.\restart-backend.ps1
```

This will:
1. ⏹️ Stop all Node processes
2. ⏸️ Wait 2 seconds
3. ▶️ Start fresh backend
4. ✅ Load new code

---

## Option 2: Manual Restart (If you see backend terminal) 🔧

### Step 1: Find Backend Terminal
Look for terminal showing:
```
╔════════════════════════════════════════════════╗
║   Nafaj Backend Server Started                 ║
║   Port: 5000                                   ║
╚════════════════════════════════════════════════╝
```

### Step 2: Stop It
```
Press: Ctrl + C
```

### Step 3: Start Again
```bash
node src/server.js
```

### Step 4: Wait for Success Message
```
✓ MySQL Database Connected Successfully
  Host: localhost
  Database: nafaj

╔════════════════════════════════════════════════╗
║   Nafaj Backend Server Started                 ║
║   Port: 5000                                   ║
╚════════════════════════════════════════════════╝
```

---

## Option 3: Force Kill All Node (If terminal lost) 💀

### Command Prompt:
```cmd
taskkill /F /IM node.exe
cd backend
node src/server.js
```

### PowerShell:
```powershell
Stop-Process -Name node -Force
cd backend
node src/server.js
```

---

## After Restart - Verification ✅

### Test 1: Direct API Call
Open NEW terminal:
```bash
curl http://localhost:5000/api/products?status=active
```

**Expected** (✅ Success):
```json
{
  "success": true,
  "count": 3,
  "data": [...]
}
```

**Not Expected** (❌ Still Error):
```json
{
  "success": false,
  "error": "Internal Server Error"
}
```

If still error → Backend not restarted properly!

### Test 2: Run Test Script
```bash
cd backend
node test-after-restart.js
```

**Expected**:
```
✅ Products API Working!
📦 Found: 3 products
✅ Vendors API Working!
🏪 Found: 5 vendors
🎉 ALL TESTS PASSED!
```

---

## Flutter App Restart 📱

After backend restart successful:

### In Flutter Terminal:
```
Press: R (capital R for hot restart)
```

Wait for:
```
Restarted application in XXXms.
```

---

## Visual Flow Chart 📊

```
┌─────────────────────────┐
│   Code Fixed in         │
│   Product.js            │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│   Backend Running       │
│   OLD Code ❌           │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│   Press Ctrl+C or       │
│   Run restart script    │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│   Backend Stopped ⏹️    │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│   node src/server.js    │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│   Backend Running       │
│   NEW Code ✅           │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│   Test API              │
│   curl or script        │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│   ✅ Success!           │
│   Products load         │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│   Flutter Hot Restart   │
│   Press 'R'             │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│   🎉 App Working!       │
│   Products & Vendors    │
│   Show Correctly        │
└─────────────────────────┘
```

---

## Troubleshooting 🔧

### Issue: Port 5000 Already in Use

**Error Message**:
```
Error: listen EADDRINUSE: address already in use :::5000
```

**Solution**:
```bash
# Kill process on port 5000
taskkill /F /PID (netstat -ano | findstr :5000 | awk '{print $5}')

# Or kill all node
taskkill /F /IM node.exe

# Then start
node src/server.js
```

### Issue: Database Connection Error

**Error Message**:
```
✗ MySQL Connection Failed
```

**Solution**:
1. Check MySQL is running
2. Check credentials in `.env`
3. Verify database `nafaj` exists

### Issue: Still Seeing Old Error After Restart

**Possible Reasons**:
1. Backend didn't actually restart
2. Wrong terminal (started in different directory)
3. Old Node process still running

**Solution**:
```bash
# Force stop all
taskkill /F /IM node.exe

# Go to correct directory
cd C:\Users\yusuf\Downloads\stitch_nafaj_driver_dashboard\backend

# Start fresh
node src/server.js
```

---

## Quick Reference Commands 📋

```bash
# Restart backend (Windows)
cd backend
restart-backend.bat

# Test backend
cd backend
node test-after-restart.js

# Test API directly
curl http://localhost:5000/api/products?status=active

# Check Node processes
tasklist | findstr node

# Kill all Node
taskkill /F /IM node.exe

# Flutter hot restart
# Press 'R' in Flutter terminal
```

---

## Success Checklist ✓

After restart, verify:

- [ ] Backend terminal shows "Server Started"
- [ ] No error messages in backend logs
- [ ] Test script passes: `node test-after-restart.js`
- [ ] curl command returns success: true
- [ ] Products count > 0
- [ ] Vendors count > 0
- [ ] Flutter app shows products
- [ ] Flutter app shows vendors
- [ ] No "Internal Server Error" in Flutter

---

## 🎯 DO THIS NOW:

1. Open NEW terminal
2. Run: `cd backend && restart-backend.bat`
3. Wait for success message
4. Run: `node test-after-restart.js`
5. In Flutter terminal: Press 'R'
6. Check app!

**It will work! Just need backend restart! 🚀**
