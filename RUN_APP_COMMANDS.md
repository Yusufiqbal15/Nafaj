# App Chalane Ke Commands 🚀

## Frontend (Flutter App)

### Option 1: Step by Step
```powershell
# Step 1: Flutter project folder mein jao
cd C:\Users\yusuf\Downloads\stitch_nafaj_driver_dashboard\stitch_nafaj_driver_dashboard\nafaj

# Step 2: Dependencies install karo (pehli baar)
flutter pub get

# Step 3: App run karo Chrome mein
flutter run -d chrome
```

### Option 2: Agar already nafaj folder mein ho
```powershell
cd nafaj
flutter run -d chrome
```

### Option 3: Windows Desktop App
```powershell
cd nafaj
flutter run -d windows
```

### Option 4: Mobile Emulator (agar setup hai)
```powershell
cd nafaj
flutter run
```

## Backend (Node.js Server)

### Terminal 1: Backend Server
```powershell
# Backend folder mein jao
cd C:\Users\yusuf\Downloads\stitch_nafaj_driver_dashboard\backend

# Server start karo
node src/server.js
```

Ya agar package.json mein script hai:
```powershell
cd backend
npm start
```

Expected output:
```
✓ Server running on port 3000
✓ Database connected successfully
```

## Dono Ek Saath Chalane Ke Liye

### Terminal 1 (Backend):
```powershell
cd C:\Users\yusuf\Downloads\stitch_nafaj_driver_dashboard\backend
node src/server.js
```

### Terminal 2 (Frontend):
```powershell
cd C:\Users\yusuf\Downloads\stitch_nafaj_driver_dashboard\stitch_nafaj_driver_dashboard\nafaj
flutter run -d chrome
```

## VS Code Se Run Karo

1. **VS Code open karo**
2. **File → Open Folder**
3. **Select:** `C:\Users\yusuf\Downloads\stitch_nafaj_driver_dashboard\stitch_nafaj_driver_dashboard\nafaj`
4. **F5 press karo** ya **Run → Start Debugging**
5. **Select device:** Chrome

## Agar Error Aaye

### Error: "No pubspec.yaml file found"
**Problem:** Wrong folder mein ho
**Solution:**
```powershell
cd nafaj
# Ya
cd C:\Users\yusuf\Downloads\stitch_nafaj_driver_dashboard\stitch_nafaj_driver_dashboard\nafaj
```

### Error: "flutter command not found"
**Problem:** Flutter path set nahi hai
**Solution:**
```powershell
# Flutter location set karo
$env:PATH += ";C:\flutter\bin"  # Apna flutter path daalo

# Check karo
flutter --version
```

### Error: "Chrome device not available"
**Problem:** Web support enable nahi hai
**Solution:**
```powershell
flutter config --enable-web
flutter devices
flutter run -d chrome
```

### Error: "Port already in use"
**Problem:** Backend already chal raha hai kisi aur terminal mein
**Solution:**
```powershell
# Windows mein port 3000 ko free karo
netstat -ano | findstr :3000
taskkill /PID <PID_NUMBER> /F
```

## Quick Start (Copy Paste)

Ye commands copy karke terminal mein paste karo:

### Backend Start:
```powershell
cd C:\Users\yusuf\Downloads\stitch_nafaj_driver_dashboard\backend & node src/server.js
```

### Frontend Start (New Terminal):
```powershell
cd C:\Users\yusuf\Downloads\stitch_nafaj_driver_dashboard\stitch_nafaj_driver_dashboard\nafaj & flutter run -d chrome
```

## Check Kar Lo Sab Theek Hai

### 1. Flutter Installed?
```powershell
flutter --version
```

### 2. Devices Available?
```powershell
flutter devices
```

Should show:
```
Chrome (web) • chrome • web-javascript • Google Chrome 120.0
Windows (desktop) • windows • windows-x64 • Microsoft Windows
```

### 3. Dependencies OK?
```powershell
cd nafaj
flutter pub get
```

### 4. Backend Dependencies OK?
```powershell
cd backend
npm install
```

## Full Setup (Pehli Baar)

```powershell
# 1. Backend setup
cd C:\Users\yusuf\Downloads\stitch_nafaj_driver_dashboard\backend
npm install
node src/server.js

# 2. Frontend setup (new terminal)
cd C:\Users\yusuf\Downloads\stitch_nafaj_driver_dashboard\stitch_nafaj_driver_dashboard\nafaj
flutter pub get
flutter run -d chrome
```

## URLs

- **Frontend:** http://localhost:RANDOM_PORT (Flutter automatically assigns)
- **Backend:** http://localhost:3000
- **API Base:** http://localhost:3000

## Hot Reload (Development)

Flutter app running ho toh:
- Press **r** - Reload
- Press **R** - Hot Restart  
- Press **q** - Quit
- Press **h** - Help

## Console Logs Dekhne Ke Liye

### Frontend Logs:
- Chrome DevTools: F12 → Console tab
- VS Code: Debug Console panel

### Backend Logs:
- Terminal window jahan backend chal raha hai
- Server requests aur responses dikhenge

## Abhi Run Karo! 🚀

1. **Terminal 1:**
```powershell
cd C:\Users\yusuf\Downloads\stitch_nafaj_driver_dashboard\backend
node src/server.js
```

2. **Terminal 2:**  
```powershell
cd C:\Users\yusuf\Downloads\stitch_nafaj_driver_dashboard\stitch_nafaj_driver_dashboard\nafaj
flutter run -d chrome
```

3. **Browser mein automatically khulega**
4. **Login karo**
5. **Products tab jao**
6. **Console open karo (F12)**
7. **Console logs dekho aur mujhe bhejo!**

---

**Agar koi error aaye toh screenshot ya error message bhejo, main fix kar dunga!** 💪
