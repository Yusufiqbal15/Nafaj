class Product {
  final int id;
  final int vendorId;
  final String name;
  final String? description;
  final String? category;
  final double price;
  final double? discountPrice;
  final int stockQuantity;
  final String unit;
  final List<String> images;
  final String status;
  final bool isFeatured;
  final int totalSales;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.vendorId,
    required this.name,
    this.description,
    this.category,
    required this.price,
    this.discountPrice,
    required this.stockQuantity,
    required this.unit,
    required this.images,
    required this.status,
    required this.isFeatured,
    required this.totalSales,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      vendorId: json['vendor_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      // Handle both String and num for price
      price: json['price'] is String 
          ? double.parse(json['price']) 
          : (json['price'] as num).toDouble(),
      // Handle both String and num for discount_price
      discountPrice: json['discount_price'] != null
          ? (json['discount_price'] is String
              ? double.parse(json['discount_price'])
              : (json['discount_price'] as num).toDouble())
          : null,
      stockQuantity: json['stock_quantity'] is String
          ? int.parse(json['stock_quantity'])
          : json['stock_quantity'] as int,
      unit: json['unit'] as String? ?? 'piece',
      images: json['images'] is List 
          ? List<String>.from(json['images']) 
          : [],
      status: json['status'] as String? ?? 'active',
      isFeatured: (json['is_featured'] as int?) == 1,
      totalSales: json['total_sales'] is String
          ? int.parse(json['total_sales'])
          : (json['total_sales'] as int? ?? 0),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'discount_price': discountPrice,
      'stock_quantity': stockQuantity,
      'unit': unit,
      'images': images,
      'status': status,
      'is_featured': isFeatured ? 1 : 0,
      'total_sales': totalSales,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Product copyWith({
    int? id,
    int? vendorId,
    String? name,
    String? description,
    String? category,
    double? price,
    double? discountPrice,
    int? stockQuantity,
    String? unit,
    List<String>? images,
    String? status,
    bool? isFeatured,
    int? totalSales,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      unit: unit ?? this.unit,
      images: images ?? this.images,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      totalSales: totalSales ?? this.totalSales,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get effectivePrice => discountPrice ?? price;
  bool get isInStock => stockQuantity > 0;
  bool get isActive => status == 'active';
  String get displayPrice => discountPrice != null 
      ? '${discountPrice!.toStringAsFixed(0)} SDG' 
      : '${price.toStringAsFixed(0)} SDG';
}
