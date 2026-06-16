# Vendor Profile - Quick Testing Guide

## Prerequisites
1. Backend server running on `http://127.0.0.1:5000`
2. Flutter app compiled and running
3. At least one vendor account in database

## Test Scenarios

### Scenario 1: View Real Profile Data
**Steps:**
1. Open app
2. Login as vendor with:
   - Email: (your test vendor email)
   - Password: (your test vendor password)
3. Navigate to Profile tab (4th icon in bottom nav)

**Expected Result:**
- ✅ Shows real business name (not "Tasty Grill Express")
- ✅ Shows real business type and city
- ✅ Shows real owner name
- ✅ Shows real email and phone
- ✅ Shows rating and review count from database
- ✅ No demo data visible

**If Fails:**
- Check backend API response from `/api/auth/vendor/profile`
- Check console logs for API errors
- Verify token is being sent in Authorization header

---

### Scenario 2: Edit Profile Information
**Steps:**
1. From Profile tab, tap "Edit Store Info"
2. Modify any of these fields:
   - Owner First Name
   - Owner Last Name
   - Phone Number
   - Business Type
   - Shop Address
   - City
3. Tap "Save" button in app bar

**Expected Result:**
- ✅ Loading indicator appears on save button
- ✅ Success message shown: "Profile updated successfully"
- ✅ Returns to profile tab automatically
- ✅ Profile displays updated information
- ✅ Changes persisted in database

**Test Validation:**
- Try leaving required field empty → Should show error
- Try invalid phone format → Should show error
- Try valid data → Should save successfully

**If Fails:**
- Check backend PUT `/api/auth/vendor/profile` endpoint
- Check console for API error messages
- Verify form validation is working

---

### Scenario 3: Session Persistence
**Steps:**
1. Login as vendor
2. Navigate around the app
3. Close app completely
4. Reopen app

**Expected Result:**
- ✅ App remembers you're logged in
- ✅ Opens directly to vendor dashboard
- ✅ Profile data loads automatically
- ✅ No need to login again

**If Fails:**
- Check if token is saved in secure storage
- Check ApiService.isLoggedIn() method
- Verify app startup logic checks for existing session

---

### Scenario 4: Logout
**Steps:**
1. From Profile tab, scroll down
2. Tap "Log Out" (red text)
3. In confirmation dialog, tap "Cancel"
4. Verify still logged in
5. Tap "Log Out" again
6. In confirmation dialog, tap "Logout"

**Expected Result:**
- ✅ Dialog appears with "Are you sure?" message
- ✅ Cancel keeps you logged in
- ✅ Logout redirects to login screen
- ✅ Cannot go back to dashboard (back button doesn't work)
- ✅ Session data cleared from storage

**If Fails:**
- Check ApiService.clearAuthData() is being called
- Check navigation uses pushNamedAndRemoveUntil
- Verify secure storage is cleared

---

### Scenario 5: Token Expiration
**Steps:**
1. Login as vendor
2. Wait for token to expire (or manually expire in backend)
3. Try to fetch profile or perform any API action

**Expected Result:**
- ✅ Receives 401 error from backend
- ✅ Dio interceptor catches error
- ✅ Auth data cleared automatically
- ✅ User shown appropriate error message
- ✅ May be redirected to login

**If Fails:**
- Check Dio interceptor in ApiService.initialize()
- Check backend returns 401 for expired tokens
- Verify clearAuthData() is called on 401

---

### Scenario 6: Edit Profile Validation
**Steps:**
1. Tap "Edit Store Info"
2. Clear first name field
3. Tap Save

**Expected Result:**
- ✅ Inline error shown: "Please enter first name"
- ✅ Form not submitted
- ✅ No API call made

**Repeat for all required fields**

**If Fails:**
- Check form validators in vendor_edit_profile.dart
- Check _formKey.currentState!.validate() is being called

---

### Scenario 7: Network Error Handling
**Steps:**
1. Stop backend server
2. Try to edit and save profile
3. Try to load profile

**Expected Result:**
- ✅ Error message shown: "Network error" or similar
- ✅ App doesn't crash
- ✅ User can retry action
- ✅ Loading state ends properly

**If Fails:**
- Check try-catch blocks in API methods
- Check DioException handling
- Verify error messages are user-friendly

---

### Scenario 8: Dashboard Header Updates
**Steps:**
1. Login as vendor
2. Check top of dashboard home tab

**Expected Result:**
- ✅ Shows real business name in header
- ✅ Shows store status indicator
- ✅ Not showing hardcoded "Tasty Grill Express"

**If Fails:**
- Check _vendorProfile is populated
- Check dashboard header widget uses _vendorProfile data
- Verify _loadProfile() is called in initState

---

## Backend Verification

### Check Vendor Profile Endpoint
```bash
# Get vendor profile
curl -X GET http://127.0.0.1:5000/api/auth/vendor/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Expected Response:**
```json
{
  "id": 1,
  "email": "vendor@example.com",
  "businessName": "My Shop",
  "ownerFirstName": "Ahmed",
  "ownerLastName": "Ali",
  ...
}
```

### Check Profile Update Endpoint
```bash
# Update vendor profile
curl -X PUT http://127.0.0.1:5000/api/auth/vendor/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "ownerFirstName": "New Name",
    "phone": "03001234567"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Vendor profile updated successfully"
}
```

---

## Common Issues & Solutions

### Issue: Profile shows "Loading..." forever
**Solution:**
- Check network connectivity
- Verify backend is running
- Check console for API errors
- Verify token is valid

### Issue: Edit saves but profile doesn't refresh
**Solution:**
- Check if Navigator.pop(context, true) is called
- Verify _loadProfile() is called after edit
- Check setState() is updating _vendorProfile

### Issue: Can't logout - stays on dashboard
**Solution:**
- Check Navigator.pushNamedAndRemoveUntil is used
- Verify route name is correct: '/vendor_login'
- Check clearAuthData() completes before navigation

### Issue: Session doesn't persist after app restart
**Solution:**
- Check flutter_secure_storage is properly configured
- Verify saveAuthData() is called on login
- Check app startup checks for existing token

### Issue: Form validation not working
**Solution:**
- Verify Form widget wraps all TextFormFields
- Check _formKey is attached to Form
- Ensure validator functions return String? (not void)

---

## Debugging Tips

### Enable Detailed Logging
1. Check console for these log messages:
   - "=== Loading Vendor Products ==="
   - "Request URI: ..."
   - "Response status: ..."
   - API error messages

2. Add print statements to track flow:
```dart
print('Profile loaded: $_vendorProfile');
print('Loading state: $_isLoadingProfile');
```

### Use Flutter DevTools
1. Open Flutter DevTools
2. Check Network tab for API calls
3. Check Flutter Inspector for widget tree
4. Check Console for errors

### Check Secure Storage
```dart
// Temporarily add this to debug
final token = await ApiService.getToken();
print('Current token: $token');

final userType = await ApiService.getUserType();
print('User type: $userType');
```

---

## Success Criteria

All features are working if:
- ✅ No demo data visible anywhere
- ✅ Real vendor data displays correctly
- ✅ Profile edit saves and updates
- ✅ Validation prevents invalid data
- ✅ Session persists across restarts
- ✅ Logout clears session completely
- ✅ No crashes or unhandled errors
- ✅ Loading states work properly
- ✅ Error messages are helpful

---

## Report Issues

If any test fails, collect:
1. Screenshot of issue
2. Console logs
3. API response (if applicable)
4. Steps to reproduce
5. Expected vs actual behavior

---

**Testing Date**: ___________
**Tester Name**: ___________
**Status**: [ ] Pass [ ] Fail [ ] Partial
**Notes**: ___________________________________________
