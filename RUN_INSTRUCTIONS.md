# Job Portal - Run Instructions

## Fixed Issue ✅
Route conflict resolved - purana `/job_details_contact_info` route remove kar diya. Ab sirf `/job_details` route use hoga.

## Quick Start

### 1. Backend Start Karo (Terminal 1):
```bash
cd backend
node start-server.js
```
✅ Backend should run on `http://localhost:5000`

### 2. Flutter App Run Karo (Terminal 2):
```bash
cd stitch_nafaj_driver_dashboard\nafaj

# Clean build (if needed)
flutter clean
flutter pub get

# Run on Chrome
flutter run -d chrome

# OR Run on your connected device
flutter run
```

## Agar Error Aaye

### "Required named parameter 'job' must be provided" - FIXED ✅
- Purana route remove kar diya
- Ab koi conflict nahi hai
- `flutter clean` aur `flutter pub get` run kar liya

### "Backend not responding"
```bash
# Check if backend is running
netstat -ano | findstr :5000

# If not running, start it
cd backend
node start-server.js
```

### "No jobs showing"
```bash
# Add sample jobs
cd backend
node add-sample-jobs.js
```

### "url_launcher not found"
```bash
cd stitch_nafaj_driver_dashboard\nafaj
flutter pub get
```

## Test Kaise Karein

### 1. Job Creator Test:
1. Open app → Navigate to Jobs
2. Select "I am an Employer"
3. Tap "Post Job" button
4. Fill complete form
5. Submit
6. ✅ Success message dikhega
7. ✅ Job "My Listings" mein dikhega

### 2. Job Seeker Test:
1. Open app → Navigate to Jobs
2. Select "I am a Job Seeker"
3. Select any category (e.g., "Programming")
4. ✅ Jobs list dikhegi
5. Tap "View Details" on any job
6. ✅ Complete details page dikhega with:
   - Job info
   - "Posted Xh ago" badge
   - WhatsApp button
   - Phone button

### 3. Job Details Test:
1. Open any job details page
2. ✅ Check posting time badge (top-left green)
3. ✅ Check job type badge (top-right white)
4. ✅ See complete description
5. ✅ Tap WhatsApp button → should open WhatsApp
6. ✅ Tap Phone button → should open dialer

## Routes Used

### Working Routes:
- `/job_details` - Job details page (NEW)
- `/job_seeker_categories` - Job categories
- `/job_seeker_listings` - Job listings by category
- `/job_creator_post_a_job` - Post new job
- `/job_creator_my_listings` - My posted jobs

### Removed Routes:
- ~~`/job_details_contact_info`~~ - REMOVED (conflicted with new route)

## Project Status

✅ **All Fixed and Ready**:
- Database connected
- APIs working
- Routes fixed
- No conflicts
- Ready to run!

## Commands Summary

```bash
# Backend
cd backend
node start-server.js

# Flutter (New Terminal)
cd stitch_nafaj_driver_dashboard\nafaj
flutter clean
flutter pub get
flutter run -d chrome
```

## Port Check
- Backend: `http://localhost:5000`
- Flutter Web: `http://localhost:xxxx` (auto-assigned)

---

**Fixed**: June 10, 2026
**Status**: ✅ Ready to Run
**Issue**: Route conflict resolved
