# 📱 Vendor Screens Implementation Examples

## ✅ Complete Working Examples

### 1. Vendor Products Screen (With Real Database Data)

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';
import '../config/api_config.dart';

class VendorProductsScreen extends StatefulWidget {
  const VendorProductsScreen({super.key});

  @override
  State<VendorProductsScreen> createState() => _VendorProductsScreenState();
}

class _VendorProductsScreenState extends State<VendorProductsScreen> {
  bool _isLoading = true;
  List<Product> _products = [];
  String? _errorMessage;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.getVendorProducts();

      if (result['success']) {
        final List<dynamic> data = result['data'];
        setState(() {
          _products = data.map((json) => Product.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['error'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProduct(int productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await ApiService.deleteProduct(productId);
      
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully')),
        );
        _loadProducts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'])),
        );
      }
    }
  }

  List<Product> get _filteredProducts {
    if (_selectedFilter == 'all') return _products;
    if (_selectedFilter == 'active') {
      return _products.where((p) => p.isActive).toList();
    }
    if (_selectedFilter == 'out_of_stock') {
      return _products.where((p) => !p.isInStock).toList();
    }
    return _products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Products', style: GoogleFonts.plusJakartaSans()),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to Add Product Screen
              // Navigator.push(context, MaterialPageRoute(
              //   builder: (context) => AddProductScreen(),
              // )).then((_) => _loadProducts());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Active', 'active'),
                const SizedBox(width: 8),
                _buildFilterChip('Out of Stock', 'out_of_stock'),
              ],
            ),
          ),
          
          // Products List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_errorMessage!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadProducts,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.inventory_2_outlined, 
                                    size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text('No products yet',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 18, color: Colors.grey)),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    // Navigate to Add Product
                                  },
                                  child: const Text('Add Your First Product'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadProducts,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = _filteredProducts[index];
                                return _buildProductCard(product);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = value);
        }
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product.images.isNotEmpty
                  ? Image.network(
                      '${ApiConfig.imageBaseUrl}${product.images.first}',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.inventory_2),
                    ),
            ),
            const SizedBox(width: 12),
            
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.displayPrice,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: const Color(0xFFFF7A00),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        product.isInStock 
                            ? Icons.check_circle 
                            : Icons.cancel,
                        size: 16,
                        color: product.isInStock 
                            ? Colors.green 
                            : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.isInStock 
                            ? 'Stock: ${product.stockQuantity}' 
                            : 'Out of Stock',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Sales: ${product.totalSales}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  // Navigate to Edit Product Screen
                } else if (value == 'delete') {
                  _deleteProduct(product.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. Vendor Orders Screen (With Real Database Data)

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../models/order_model.dart';

class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> {
  bool _isLoading = true;
  List<Order> _orders = [];
  String? _errorMessage;
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.getVendorOrders(
        status: _selectedStatus == 'all' ? null : _selectedStatus,
      );

      if (result['success']) {
        final List<dynamic> data = result['data'];
        setState(() {
          _orders = data.map((json) => Order.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['error'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    final result = await ApiService.updateOrderStatus(
      orderId: orderId,
      status: newStatus,
    );

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order status updated')),
      );
      _loadOrders();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders', style: GoogleFonts.plusJakartaSans()),
      ),
      body: Column(
        children: [
          // Status Filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildStatusChip('All', 'all'),
                _buildStatusChip('Pending', 'pending'),
                _buildStatusChip('Confirmed', 'confirmed'),
                _buildStatusChip('Preparing', 'preparing'),
                _buildStatusChip('Ready', 'ready'),
                _buildStatusChip('Delivered', 'delivered'),
              ],
            ),
          ),
          
          // Orders List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : _orders.isEmpty
                        ? const Center(child: Text('No orders yet'))
                        : RefreshIndicator(
                            onRefresh: _loadOrders,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _orders.length,
                              itemBuilder: (context, index) {
                                final order = _orders[index];
                                return _buildOrderCard(order);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, String value) {
    final isSelected = _selectedStatus == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedStatus = value);
            _loadOrders();
          }
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.orderStatus),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.statusDisplay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Customer: ${order.customerName}',
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
            ),
            if (order.phone != null)
              Text(
                'Phone: ${order.phone}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Total: ${order.finalAmount.toStringAsFixed(0)} SDG',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFF7A00),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Address: ${order.deliveryAddress}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!order.isDelivered && !order.isCancelled)
              const SizedBox(height: 12),
            if (!order.isDelivered && !order.isCancelled)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showStatusUpdateDialog(order),
                      child: const Text('Update Status'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.green;
      case 'picked_up':
        return Colors.teal;
      case 'delivered':
        return Colors.green[700]!;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showStatusUpdateDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (order.isPending)
              ListTile(
                title: const Text('Confirm Order'),
                onTap: () {
                  Navigator.pop(context);
                  _updateOrderStatus(order.id, 'confirmed');
                },
              ),
            if (order.isConfirmed)
              ListTile(
                title: const Text('Start Preparing'),
                onTap: () {
                  Navigator.pop(context);
                  _updateOrderStatus(order.id, 'preparing');
                },
              ),
            if (order.isPreparing)
              ListTile(
                title: const Text('Mark as Ready'),
                onTap: () {
                  Navigator.pop(context);
                  _updateOrderStatus(order.id, 'ready');
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
```

## 📝 How to Use These Screens

1. **Copy the code** from above
2. **Create new files** in `lib/screens/vendor/` folder
3. **Import dependencies**:
   - `import '../services/api_service.dart';`
   - `import '../models/product_model.dart';`
   - `import '../models/order_model.dart';`
   - `import '../config/api_config.dart';`
   - `import 'package:google_fonts/google_fonts.dart';`

4. **Navigate to these screens** from vendor dashboard:
```dart
// From Vendor Dashboard
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => VendorProductsScreen()),
);
```

## ✅ Features Implemented

### Products Screen:
- ✅ Fetch real products from database
- ✅ Display product images from server
- ✅ Filter by status (all, active, out of stock)
- ✅ Delete product with confirmation
- ✅ Pull to refresh
- ✅ Empty state handling
- ✅ Error handling
- ✅ Loading states

### Orders Screen:
- ✅ Fetch real orders from database
- ✅ Filter by order status
- ✅ Display customer information
- ✅ Update order status
- ✅ Color-coded status badges
- ✅ Pull to refresh
- ✅ Empty state handling

## 🎯 Next Steps

To complete the vendor dashboard, you need to create:

1. **Add Product Screen** - Form with image picker
2. **Edit Product Screen** - Pre-filled form with current data
3. **Order Details Screen** - Show order items and full details
4. **Profile Edit Screen** - Edit vendor profile
5. **Dashboard Stats** - Show real statistics

Backend is 100% ready! Just create these screens and connect with ApiService methods!
