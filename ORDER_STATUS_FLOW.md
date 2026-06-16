# Order Status Flow Implementation

## Complete Order Status Flow

### Status Progression:
```
pending → picked_up → delivering → delivered
          ↓
      (can be cancelled at any stage)
```

### Roles & Actions:

#### 1. **Driver Actions** (After Accepting Order):
- ✅ **Accept Order** → Status: `picked_up`
- 📍 **Arriving at Restaurant** → Status: `picked_up` 
- ✅ **Picked Up from Restaurant** → Status: `delivering`
- 🚚 **Out for Delivery** → Status: `delivering`
- ✅ **Delivered to Customer** → Status: `delivered`

#### 2. **Vendor Actions**:
- 👀 **See Driver Details** when order is accepted
- ✅ **Mark Order Ready** → Notify driver
- 📦 **Confirm Pickup** → When driver collects

#### 3. **User Actions**:
- 👀 **Track Order Status** in real-time
- 📞 **Contact Driver** when order is picked up
- ✅ **Confirm Delivery** → Mark as received

## Implementation Files

### 1. Backend - Add Status Update Endpoint

**File**: `backend/src/controllers/OrderController.js`

Add this method:

```javascript
// Update order status (Driver can update their orders)
static async updateOrderStatusByDriver(req, res, next) {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!req.user || req.user.role !== 'driver') {
      return res.status(403).json({ 
        success: false,
        error: 'Only drivers can update order status' 
      });
    }

    const validStatuses = ['picked_up', 'delivering', 'delivered'];
    
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ 
        success: false,
        error: 'Invalid status. Use: picked_up, delivering, delivered' 
      });
    }

    const order = await Order.findById(id);

    if (!order) {
      return res.status(404).json({ 
        success: false,
        error: 'Order not found' 
      });
    }

    // Verify this order belongs to the authenticated driver
    if (order.driver_id !== req.user.userId) {
      return res.status(403).json({ 
        success: false,
        error: 'You can only update your own orders' 
      });
    }

    await Order.updateStatus(id, status);

    res.json({ 
      success: true,
      message: 'Order status updated successfully',
      orderId: id,
      newStatus: status
    });
  } catch (error) {
    next(error);
  }
}
```

### 2. Backend - Update Routes

**File**: `backend/src/routes/orders.js`

Add route:

```javascript
// Driver updates order status
router.patch('/:id/status/driver', authMiddleware, OrderController.updateOrderStatusByDriver);
```

### 3. Frontend - Add Order Service Method

**File**: `nafaj/lib/services/order_service.dart`

Add method:

```dart
// Update order status (Driver)
static Future<Map<String, dynamic>> updateOrderStatus(
  int orderId,
  String status,
) async {
  try {
    final response = await ApiService.dio.patch(
      '/orders/$orderId/status/driver',
      data: {'status': status},
    );

    if (response.statusCode == 200) {
      return {'success': true, 'data': response.data};
    }
    return {'success': false, 'error': 'Failed to update status'};
  } on DioException catch (e) {
    return {
      'success': false,
      'error': e.response?.data?['error'] ?? 'Network error'
    };
  }
}
```

### 4. Frontend - Update Tracking Page UI

**File**: `nafaj/lib/screens/order_tracking.dart`

Add these variables in state:

```dart
String _currentStatus = 'picked_up'; // Current order status
bool _isUpdatingStatus = false;
```

Add this method:

```dart
Future<void> _updateOrderStatus(String newStatus) async {
  if (_orderData == null) return;
  
  setState(() => _isUpdatingStatus = true);
  
  try {
    final orderId = int.parse(_orderData!['id']);
    final result = await OrderService.updateOrderStatus(orderId, newStatus);
    
    if (result['success'] == true && mounted) {
      setState(() {
        _currentStatus = newStatus;
        _isUpdatingStatus = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Status updated to: ${_getStatusText(newStatus)}',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() => _isUpdatingStatus = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['error'] ?? 'Failed to update status',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } catch (e) {
    setState(() => _isUpdatingStatus = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Error: $e',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

String _getStatusText(String status) {
  switch (status) {
    case 'picked_up':
      return 'Picked Up from Restaurant';
    case 'delivering':
      return 'Out for Delivery';
    case 'delivered':
      return 'Delivered to Customer';
    default:
      return status;
  }
}
```

Add status buttons in UI (add before the closing of SingleChildScrollView):

```dart
const SizedBox(height: 24),

// Status Update Buttons
Text(
  'Update Order Status',
  style: GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: darkSlate,
  ),
),
const SizedBox(height: 12),

// Status progression
_buildStatusButton(
  'Picked Up from Restaurant',
  Icons.store_rounded,
  'picked_up',
  _currentStatus == 'picked_up',
  _currentStatus != 'picked_up',
  primaryColor,
),
const SizedBox(height: 12),
_buildStatusButton(
  'Out for Delivery',
  Icons.local_shipping_rounded,
  'delivering',
  _currentStatus == 'delivering',
  _currentStatus == 'delivered',
  const Color(0xFFF59E0B),
),
const SizedBox(height: 12),
_buildStatusButton(
  'Delivered to Customer',
  Icons.check_circle_rounded,
  'delivered',
  _currentStatus == 'delivered',
  _currentStatus == 'delivered',
  greenColor,
),
```

Add status button widget:

```dart
Widget _buildStatusButton(
  String label,
  IconData icon,
  String status,
  bool isActive,
  bool isCompleted,
  Color color,
) {
  return GestureDetector(
    onTap: isCompleted || _isUpdatingStatus
        ? null
        : () => _updateOrderStatus(status),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive
            ? color.withOpacity(0.1)
            : isCompleted
                ? Colors.grey.withOpacity(0.05)
                : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? color
              : isCompleted
                  ? Colors.grey.withOpacity(0.3)
                  : color.withOpacity(0.2),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? color
                  : isCompleted
                      ? Colors.grey
                      : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCompleted ? Icons.check_rounded : icon,
              color: isActive || isCompleted ? Colors.white : color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                color: isCompleted
                    ? Colors.grey
                    : isActive
                        ? color
                        : const Color(0xFF0F172A),
              ),
            ),
          ),
          if (isCompleted)
            Icon(Icons.check_circle_rounded, color: Colors.grey, size: 20)
          else if (isActive)
            Icon(Icons.radio_button_checked, color: color, size: 20)
          else
            Icon(Icons.radio_button_unchecked,
                color: color.withOpacity(0.3), size: 20),
        ],
      ),
    ),
  );
}
```

## Quick Implementation Script

Save this as `backend/add-status-update.js` and run it:

```javascript
const fs = require('fs');
const path = require('path');

// Add to OrderController.js
const controllerPath = path.join(__dirname, 'src/controllers/OrderController.js');
const controllerCode = `

  // Update order status by driver
  static async updateOrderStatusByDriver(req, res, next) {
    try {
      const { id } = req.params;
      const { status } = req.body;

      if (!req.user || req.user.role !== 'driver') {
        return res.status(403).json({ 
          success: false,
          error: 'Only drivers can update order status' 
        });
      }

      const validStatuses = ['picked_up', 'delivering', 'delivered'];
      
      if (!validStatuses.includes(status)) {
        return res.status(400).json({ 
          success: false,
          error: 'Invalid status. Use: picked_up, delivering, delivered' 
        });
      }

      const order = await Order.findById(id);

      if (!order) {
        return res.status(404).json({ 
          success: false,
          error: 'Order not found' 
        });
      }

      if (order.driver_id !== req.user.userId) {
        return res.status(403).json({ 
          success: false,
          error: 'You can only update your own orders' 
        });
      }

      await Order.updateStatus(id, status);

      res.json({ 
        success: true,
        message: 'Order status updated successfully',
        orderId: id,
        newStatus: status
      });
    } catch (error) {
      next(error);
    }
  }
`;

// Read controller file
let controller = fs.readFileSync(controllerPath, 'utf8');

// Add method before the last closing brace
const lastBrace = controller.lastIndexOf('}');
controller = controller.slice(0, lastBrace) + controllerCode + '\n' + controller.slice(lastBrace);

fs.writeFileSync(controllerPath, controller);

console.log('✅ Added updateOrderStatusByDriver to OrderController');

// Add route
const routePath = path.join(__dirname, 'src/routes/orders.js');
let routes = fs.readFileSync(routePath, 'utf8');

const routeLine = "\n// Driver updates order status\nrouter.patch('/:id/status/driver', authMiddleware, OrderController.updateOrderStatusByDriver);\n";

// Add before module.exports
routes = routes.replace('module.exports = router;', routeLine + '\nmodule.exports = router;');

fs.writeFileSync(routePath, routes);

console.log('✅ Added status update route');
console.log('\n🎉 Backend ready! Restart server and update Flutter app.');
```

## Testing

1. **Login as Driver**
2. **Accept an Order** → Redirected to tracking
3. **Click "Picked Up from Restaurant"** → Status updated
4. **Click "Out for Delivery"** → Status updated
5. **Click "Delivered to Customer"** → Status updated, order complete

## Database Check

```sql
SELECT 
  id,
  order_number,
  order_status,
  driver_id,
  updated_at
FROM orders
WHERE driver_id = 4
ORDER BY updated_at DESC;
```

---

**Summary**:
- Driver can update order status from tracking page
- 3 status buttons: Picked Up → Delivering → Delivered
- Each status saved to database
- Vendor/User can see real-time status updates
