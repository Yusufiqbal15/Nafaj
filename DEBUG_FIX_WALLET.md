# Wallet Screen Debug Fix

## Error:
```
NoSuchMethodError: 'toDouble'
Dynamic call failed.
Tried to invoke 'null' like a method.
Receiver: "51.00"
```

## Problem:
The `final_amount` field is coming as a **String** from the API, not as a number.

## Quick Fix:

Replace the `_buildOrderItem` method in `nafaj_wallet_transactions.dart`:

```dart
Widget _buildOrderItem({
  required Map<String, dynamic> order,
  required Color primaryColor,
  required Color darkSlate,
}) {
  // Safely extract string values
  final String orderNumber = order['order_number']?.toString() ?? 'N/A';
  final String vendorName = order['vendor_name']?.toString() ?? 'Vendor';
  final String orderStatus = order['order_status']?.toString() ?? 'pending';
  final String createdAt = order['created_at']?.toString() ?? '';
  
  // SAFE conversion to double - handles String, int, double, or null
  double finalAmount = 0.0;
  try {
    final amountValue = order['final_amount'];
    if (amountValue != null) {
      if (amountValue is String) {
        // If it's a String, parse it
        finalAmount = double.tryParse(amountValue) ?? 0.0;
      } else if (amountValue is int) {
        // If it's an int, convert to double
        finalAmount = amountValue.toDouble();
      } else if (amountValue is double) {
        // If it's already a double, use it
        finalAmount = amountValue;
      }
    }
  } catch (e) {
    print('Error parsing final_amount: $e');
    finalAmount = 0.0;
  }

  // Rest of the code stays the same...
  // Parse date
  DateTime? orderDate;
  try {
    if (createdAt.isNotEmpty) {
      orderDate = DateTime.parse(createdAt);
    }
  } catch (e) {
    orderDate = null;
  }

  final String formattedDate = orderDate != null
      ? '${_getMonthName(orderDate.month)} ${orderDate.day}, ${orderDate.year} • ${_formatTime(orderDate)}'
      : 'N/A';

  // Status color
  Color statusColor;
  IconData statusIcon;

  switch (orderStatus.toLowerCase()) {
    case 'pending':
      statusColor = Colors.orange;
      statusIcon = Icons.schedule_rounded;
      break;
    case 'confirmed':
      statusColor = Colors.blue;
      statusIcon = Icons.check_circle_outline;
      break;
    case 'preparing':
      statusColor = Colors.purple;
      statusIcon = Icons.restaurant_rounded;
      break;
    case 'ready':
      statusColor = Colors.teal;
      statusIcon = Icons.shopping_bag_rounded;
      break;
    case 'picked_up':
      statusColor = const Color(0xFF10B981);
      statusIcon = Icons.local_shipping_rounded;
      break;
    case 'delivered':
      statusColor = const Color(0xFF10B981);
      statusIcon = Icons.check_circle_rounded;
      break;
    case 'cancelled':
      statusColor = Colors.red;
      statusIcon = Icons.cancel_rounded;
      break;
    default:
      statusColor = const Color(0xFF64748B);
      statusIcon = Icons.info_outline;
  }

  return GestureDetector(
    onTap: () => Navigator.pushNamed(context, '/user_orders'),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        vendorName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: darkSlate,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        orderStatus.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  orderNumber,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Text(
                  formattedDate,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '- SDG ${finalAmount.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: darkSlate,
            ),
          ),
        ],
      ),
    ),
  );
}

// Add this helper method for time formatting
String _formatTime(DateTime date) {
  final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}
```

## Steps to Fix:

1. Open: `lib/screens/nafaj_wallet_transactions.dart`

2. Find the `_buildOrderItem` method (around line 560)

3. Replace the line:
   ```dart
   final double finalAmount = (order['final_amount'] ?? 0).toDouble();
   ```

   With:
   ```dart
   double finalAmount = 0.0;
   try {
     final amountValue = order['final_amount'];
     if (amountValue != null) {
       if (amountValue is String) {
         finalAmount = double.tryParse(amountValue) ?? 0.0;
       } else if (amountValue is int) {
         finalAmount = amountValue.toDouble();
       } else if (amountValue is double) {
         finalAmount = amountValue;
       }
     }
   } catch (e) {
     print('Error parsing final_amount: $e');
     finalAmount = 0.0;
   }
   ```

4. Also add the `_formatTime` helper method after `_getMonthName`:
   ```dart
   String _formatTime(DateTime date) {
     final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
     final minute = date.minute.toString().padLeft(2, '0');
     final period = date.hour >= 12 ? 'PM' : 'AM';
     return '$hour:$minute $period';
   }
   ```

5. Update the date formatting line to use the new helper:
   ```dart
   final String formattedDate = orderDate != null
       ? '${_getMonthName(orderDate.month)} ${orderDate.day}, ${orderDate.year} • ${_formatTime(orderDate)}'
       : 'N/A';
   ```

6. Save and hot reload (`r` in terminal)

## Why This Works:

The API is returning `final_amount` as a String like `"51.00"` instead of a number like `51.00`.

The safe conversion code checks the type first:
- If String → Use `double.tryParse()`
- If int → Use `.toDouble()`
- If double → Use directly
- If null → Use 0.0

This prevents the `NoSuchMethodError` completely!

## Test:

After fixing:
1. Hot reload the app
2. Navigate to wallet screen
3. Scroll to "Recent Orders"
4. Orders should now appear without errors!
