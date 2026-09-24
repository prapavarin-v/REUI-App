import 'package:cloud_firestore/cloud_firestore.dart';

/// ตรงกับ schema ของ Firestore collection: products/{productId}
class ProductModel {
  final String id;
  final String sellerId;
  final String name;
  final String description;
  final num price;
  final String categoryId;
  final String condition;
  final List<String> images;
  final String status; // available | reserved | sold
  final int viewCount;
  final int likeCount;
  final DateTime? createdAt;
  final String location;

  ProductModel({
    required this.id,
    required this.sellerId,
    required this.name,
    this.description = '',
    this.price = 0,
    this.categoryId = '',
    this.condition = '',
    this.images = const [],
    this.status = 'available',
    this.viewCount = 0,
    this.likeCount = 0,
    this.createdAt,
    this.location = '',
  });

  String get thumbnail => images.isNotEmpty ? images.first : '';

  factory ProductModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? {};
    return ProductModel(
      id: doc.id,
      sellerId: map['sellerId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? 0,
      categoryId: map['categoryId'] ?? '',
      condition: map['condition'] ?? '',
      images: List<String>.from(map['images'] ?? const []),
      status: map['status'] ?? 'available',
      viewCount: (map['viewCount'] ?? 0) as int,
      likeCount: (map['likeCount'] ?? 0) as int,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      location: map['location'] ?? '',
    );
  }
}

/// ตรงกับ schema ของ Firestore collection: categories/{categoryId}
class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final int order;
  final int productCount;

  CategoryModel({
    required this.id,
    required this.name,
    this.icon = '',
    this.order = 0,
    this.productCount = 0,
  });

  factory CategoryModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? {};
    return CategoryModel(
      id: doc.id,
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
      order: (map['order'] ?? 0) as int,
      productCount: (map['productCount'] ?? 0) as int,
    );
  }
}
