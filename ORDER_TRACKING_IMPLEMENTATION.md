# Order Tracking with Image Upload Implementation

## 🎯 Overview

Complete implementation of detailed order tracking system for drivers with mandatory image upload at key stages:

- **Pickup Request** → heading to restaurant
- **Pickup Done** → 📸 image required (pickup proof)
- **Out for Delivery** → on the way to customer
- **Delivered** → 📸 image required (delivery proof)

---

## 🗂️ Files Created/Modified

### Backend Files

#### New Files:
1. **`backend/migrations/add_order_tracking_images.sql`**
   - Adds `pickup_image_url`, `delivery_image_url` columns
   - Adds `pickup_timestamp`, `delivery_timestamp` columns
   - Creates indexes for better query performance

2. **`backend/run-tracking-migration.js`**
   - Migration script to add tracking image fields to database

#### Modified Files:
1. **`backend/src/models/Order.js`**
   - Added `updateStatusWithImage()` method
   - Handles image URL storage with status updates
   - Supports 'pickup' and 'delivery' image types

2. **`backend/src/controllers/OrderController.js`**
   - Added `updateOrderStatusWithImage()` method
   - Validates image upload requirements
   - Validates driver authorization
   - Stores image URLs in database

3. **`backend/src/routes/orders.js`**
   - Added route: `PATCH /orders/:id/status/driver/with-image`
   - Uses multer middleware for image uploads
   - Requires authentication

### Flutter Files

#### New Files:
1. **`nafaj/lib/screens/driver_order_tracking_detailed.dart`**
   - Complete tracking screen with 4 stages
   - Camera integration for image capture
   - Image preview and validation
   - Progress indicator
   - Stage-by-stage completion flow
   - Auto-navigation back on completion

#### Modified Files:
1. **`nafaj/lib/screens/driver_delivery_history.dart`**
   - Added tap-to-track functionality for in-progress orders
   - Shows "Tap to continue tracking" indicator
   - Refreshes list after tracking completion

2. **`nafaj/lib/routes/app_routes.dart`**
   - Added `/driver_order_tracking_detailed` route
   - Passes order data as arguments

---

## 🚀 Setup Instructions

### Step 1: Run Database Migration

```bash
cd backend
node run-tracking-migration.js
```

Expected output:
```
📦 Connected to database
🔄 Running tracking images migration...
✅ Migration completed successfully!
✅ Added pickup_image_url, delivery_image_url, pickup_timestamp, delivery_timestamp columns to orders table
📦 Database connection closed
```

### Step 2: Restart Backend Server

```bash
# Kill existing process
taskkill /F /IM node.exe

# Or use the restart script
.\restart-backend.bat

# Or manually
npm start
```

### Step 3: Rebuild Flutter App

```bash
cd ../stitch_nafaj_driver_dashboard/nafaj
flutter clean
flutter pub get
flutter run
```

---

## 📱 How to Use (Driver Flow)

### 1. Accept Order
- Driver sees available orders on map
- Clicks "Accept Order"
- Order status → `picked_up`
- Driver redirected to tracking screen

### 2. Navigate from History
- Go to "History" tab (bottom nav)
- Find "In Progress" order
- Tap the order card
- Shows "Tap to continue tracking" button

### 3. Complete Stages

#### Stage 1: Pickup Request
- Heading to restaurant
- No image required
- Click "Complete Stage" to continue

#### Stage 2: Pickup Done ✅
- **IMAGE REQUIRED** 📸
- Tap camera icon to take photo
- Preview image
- Click "Complete Stage"
- Image uploaded to backend
- Status → `picked_up` with pickup_image_url

#### Stage 3: Out for Delivery
- On the way to customer
- No image required
- Click "Complete Stage" to continue

#### Stage 4: Delivered ✅
- **IMAGE REQUIRED** 📸
- Tap camera icon to take delivery proof photo
- Preview image
- Click "Complete Stage"
- Image uploaded to backend
- Status → `delivered` with delivery_image_url
- Order complete! Auto-navigate back to history

---

## 🔌 API Endpoints

### Update Order Status with Image

**Endpoint:** `PATCH /orders/:id/status/driver/with-image`

**Headers:**
```json
{
  "Authorization": "Bearer <driver_token>"
}
```

**Body (FormData):**
```
status: "picked_up" | "delivered"
imageType: "pickup" | "delivery"
image: <file>
```

**Response (Success):**
```json
{
  "success": true,
  "message": "Order status updated successfully with image proof",
  "orderId": 123,
  "newStatus": "picked_up",
  "imageUrl": "/uploads/image-1234567890-123.jpg",
  "imageType": "pickup"
}
```

**Response (Error - No Image):**
```json
{
  "success": false,
  "error": "Image is required for status update"
}
```

**Response (Error - Wrong Driver):**
```json
{
  "success": false,
  "error": "You can only update your own orders"
}
```

---

## 🗃️ Database Schema Changes

```sql
ALTER TABLE orders
ADD COLUMN pickup_image_url VARCHAR(500) DEFAULT NULL,
ADD COLUMN delivery_image_url VARCHAR(500) DEFAULT NULL,
ADD COLUMN pickup_timestamp TIMESTAMP NULL DEFAULT NULL,
ADD COLUMN delivery_timestamp TIMESTAMP NULL DEFAULT NULL;
```

### Sample Order Record:
```json
{
  "id": 123,
  "order_number": "ORD-1780913206637-14",
  "order_status": "delivered",
  "driver_id": 5,
  "pickup_image_url": "/uploads/order_123_pickup.jpg",
  "delivery_image_url": "/uploads/order_123_delivery.jpg",
  "pickup_timestamp": "2026-06-09 10:30:00",
  "delivery_timestamp": "2026-06-09 11:15:00",
  "created_at": "2026-06-09 10:06:00",
  "updated_at": "2026-06-09 11:15:00"
}
```

---

## 🎨 UI Features

### Tracking Screen:
- **Orange theme** matching app design
- **Progress bar** showing completion percentage
- **Stage indicators** with icons
- **Camera integration** with image picker
- **Image preview** before upload
- **Loading states** during upload
- **Success/error toasts**
- **Auto-scroll** to current stage

### Delivery History:
- **Color-coded status badges:**
  - 🟢 Green → Completed
  - 🔴 Red → Cancelled
  - 🟠 Orange → In Progress
  - 🔵 Blue → Pending
- **Tap indicator** for in-progress orders
- **Pull-to-refresh** functionality

---

## 🧪 Testing Checklist

### Backend Testing:

```bash
# Test image upload endpoint
curl -X PATCH http://localhost:5000/orders/123/status/driver/with-image \
  -H "Authorization: Bearer <token>" \
  -F "status=picked_up" \
  -F "imageType=pickup" \
  -F "image=@/path/to/test-image.jpg"
```

### Flutter Testing:

1. ✅ Accept order from map
2. ✅ Navigate to tracking from history
3. ✅ Complete stage without image (1 & 3)
4. ✅ Try to complete image-required stage without photo → shows error
5. ✅ Take photo with camera
6. ✅ Preview photo
7. ✅ Change photo (retake)
8. ✅ Upload and complete stage
9. ✅ Complete all stages
10. ✅ Check order status in history → "Completed"
11. ✅ Verify images stored in backend/uploads/
12. ✅ Check database for pickup_image_url and delivery_image_url

---

## 🔧 Troubleshooting

### Migration Failed
```bash
# Check database connection
mysql -u root -p nafaj_db

# Manually run migration
mysql -u root -p nafaj_db < backend/migrations/add_order_tracking_images.sql
```

### Image Upload Failed
- Check backend/uploads/ folder exists and is writable
- Check file size limit (5MB max)
- Check allowed formats: jpeg, jpg, png, gif, webp
- Check multer configuration in `backend/src/middleware/upload.js`

### Camera Not Working
- Check Android: Add camera permission in AndroidManifest.xml
- Check iOS: Add camera usage description in Info.plist
- Ensure image_picker dependency is installed

### Navigation Issues
- Check route name matches exactly: `/driver_order_tracking_detailed`
- Verify arguments passed correctly from delivery history
- Check import statement in app_routes.dart

---

## 📦 Dependencies

### Backend:
- `multer` - File upload middleware ✅ (already installed)
- `mysql2` - Database driver ✅ (already installed)

### Flutter:
- `image_picker` - Camera/gallery access (add if not present)

```yaml
# Add to pubspec.yaml if missing
dependencies:
  image_picker: ^1.0.7
```

---

## 🎯 Next Steps

### Enhancements:
1. ✨ Add image compression before upload
2. ✨ Add GPS coordinates to images (EXIF data)
3. ✨ Add signature capture for delivery
4. ✨ Add real-time notifications on status change
5. ✨ Add image viewing in admin panel
6. ✨ Add automatic backup to cloud storage (Cloudinary)

### Admin Features:
1. 📊 View pickup/delivery images in order details
2. 📊 Download images for proof/disputes
3. 📊 Track timestamp differences (pickup → delivery time)
4. 📊 Analytics on delivery times with image proof

---

## ✅ Summary

Complete order tracking system implemented with:
- ✅ 4-stage delivery workflow
- ✅ Mandatory image upload at pickup and delivery
- ✅ Image validation and preview
- ✅ Database storage with timestamps
- ✅ Beautiful UI with progress indicators
- ✅ Error handling and user feedback
- ✅ Auto-navigation on completion

**Happy tracking! 🚀📸**
