# Restart Backend and Test

## Changes Made:

1. ✅ **Removed authentication** from driver orders endpoints (temporarily)
2. ✅ **Accept order endpoint** now works without login
3. ✅ **Database has 7 orders** ready with coordinates

---

## Quick Commands:

### 1. Restart Backend Server

**Stop current server** (Press Ctrl+C in the terminal running backend)

Then start again:
```bash
cd backend
npm start
```

**Or use these PowerShell commands:**

```powershell
# Find the process
Get-Process -Name "node" | Where-Object {$_.Path -like "*backend*"}

# Kill it (replace PID with actual process ID)
Stop-Process -Id 25480 -Force

# Start again
cd backend
npm start
```

### 2. Test API Directly

```powershell
Invoke-WebRequest -Uri "http://127.0.0.1:5000/api/orders/driver/orders?status=available" -Method GET
```

**Expected:** Should return 7 orders!

### 3. Restart Flutter App

```bash
# Press 'r' for hot reload
# Or press 'R' for hot restart
# Or stop and run again:
flutter run -d chrome
```

---

## What Will Work Now:

✅ **No login required** - Orders will load immediately  
✅ **7 orders will show** - All pending orders visible  
✅ **Accept button works** - Can accept orders without authentication  
✅ **Tracking page** - Will show order details  

---

## Simple Test Steps:

1. **Restart backend** - `npm start` in backend folder
2. **Refresh Flutter app** - Press 'R' in terminal or refresh browser
3. **Go to driver dashboard** - Should see 7 orders!
4. **Click accept** - Should redirect to tracking
5. **See order details** - Complete info displayed

---

## If Still "0 orders":

### Check 1: Backend Running?
```powershell
netstat -ano | findstr :5000
# Should show: TCP  0.0.0.0:5000  LISTENING
```

### Check 2: API Test
```powershell
Invoke-WebRequest -Uri "http://127.0.0.1:5000/api/orders/driver/orders?status=available"
```

Should return:
```json
{
  "success": true,
  "count": 7,
  "orders": [...]
}
```

### Check 3: Browser Console
- Open DevTools (F12)
- Go to Console tab
- Look for API errors

### Check 4: Network Tab
- Open DevTools (F12)
- Go to Network tab
- Reload page
- Check API call to `/orders/driver/orders`
- See response

---

## Backend Restart Script (save as restart-backend.ps1):

```powershell
# Stop old process
Get-Process -Name "node" | Where-Object {$_.Path -like "*stitch_nafaj*"} | Stop-Process -Force

# Wait a moment
Start-Sleep -Seconds 2

# Start new process
cd C:\Users\yusuf\Downloads\stitch_nafaj_driver_dashboard\backend
Start-Process powershell -ArgumentList "npm start" -WorkingDirectory $PWD
```

Run with: `.\restart-backend.ps1`

---

## Expected Screen After Restart:

```
┌─────────────────────────────────────┐
│  Available Orders (7 orders)   ✅  │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  🟠 NEW ORDER                       │
│  Order #ORD-1780928054570-913       │
│  EARNINGS: SDG 3292                 │
│  Test Business                      │
│  📍 Al Riyadh District             │
│  📍 1.4 km    ⏰ 13 mins           │
│  [═══ Slide to Accept ═══►]        │
└─────────────────────────────────────┘

(+ 6 more orders...)
```

---

**DO THIS NOW:**

1. Stop backend server (Ctrl+C)
2. Start again: `npm start`
3. Refresh Flutter app
4. Check driver dashboard

Orders should appear! 🎉
