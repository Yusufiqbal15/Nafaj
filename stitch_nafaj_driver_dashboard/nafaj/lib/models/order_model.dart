class Order {
  final int id;
  final int userId;
  final int vendorId;
  final String orderNumber;
  final double totalAmount;
  final double deliveryFee;
  final double discountAmount;
  final double finalAmount;
  final String orderStatus;
  final String paymentMethod;
  final String paymentStatus;
  final String deliveryAddress;
  final String? notes;
  final int? driverId;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.vendorId,
    required this.orderNumber,
    required this.totalAmount,
    required this.deliveryFee,
    required this.discountAmount,
    required this.finalAmount,
    required this.orderStatus,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.deliveryAddress,
    this.notes,
    this.driverId,
    this.firstName,
    this.lastName,
    this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      vendorId: json['vendor_id'] as int,
      orderNumber: json['order_number'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (json['final_amount'] as num).toDouble(),
      orderStatus: json['order_status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      deliveryAddress: json['delivery_address'] as String,
      notes: json['notes'] as String?,
      driverId: json['driver_id'] as int?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'vendor_id': vendorId,
      'order_number': orderNumber,
      'total_amount': totalAmount,
      'delivery_fee': deliveryFee,
      'discount_amount': discountAmount,
      'final_amount': finalAmount,
      'order_status': orderStatus,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'delivery_address': deliveryAddress,
      'notes': notes,
      'driver_id': driverId,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get customerName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else {
      return 'Customer';
    }
  }

  String get statusDisplay {
    switch (orderStatus) {
      case 'pending':          return 'Pending';
      case 'confirmed':        return 'Confirmed';
      case 'preparing':        return 'Preparing';
      case 'ready':            return 'Ready';
      case 'picked_up':        return 'Picked Up';
      case 'out_for_delivery': return 'Out for Delivery';
      case 'delivering':       return 'Delivering';
      case 'delivered':        return 'Delivered';
      case 'cancelled':        return 'Cancelled';
      default:                 return orderStatus;
    }
  }

  bool get isPending        => orderStatus == 'pending';
  bool get isConfirmed      => orderStatus == 'confirmed';
  bool get isPreparing      => orderStatus == 'preparing';
  bool get isReady          => orderStatus == 'ready';
  bool get isOutForDelivery => orderStatus == 'out_for_delivery';
  bool get isDelivered      => orderStatus == 'delivered';
  bool get isCancelled      => orderStatus == 'cancelled';
}
