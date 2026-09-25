import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String sellerId;
  final String title;
  final String description;
  final int price;
  final String categoryId;
  final String condition; // เช่น ใหม่มาก / ดี / พอใช้
  final List<String> images;
  final String status; // available | reserved | sold
  final String faculty; // คณะของผู้ขาย (ใช้ filter)
  final String? aiCaption; // แคปชันที่ AI เขียนให้
  final bool aiGenerated;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.condition,
    required this.images,
    required this.status,
    required this.faculty,
    this.aiCaption,
    this.aiGenerated = false,
    required this.createdAt,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      sellerId: map['sellerId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0),
      categoryId: map['categoryId'] ?? '',
      condition: map['condition'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      status: map['status'] ?? 'available',
      faculty: map['faculty'] ?? '',
      aiCaption: map['aiCaption'],
      aiGenerated: map['aiGenerated'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'title': title,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'condition': condition,
      'images': images,
      'status': status,
      'faculty': faculty,
      'aiCaption': aiCaption,
      'aiGenerated': aiGenerated,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ProductModel copyWith({
    String? title,
    String? description,
    int? price,
    String? categoryId,
    String? condition,
    List<String>? images,
    String? status,
  }) {
    return ProductModel(
      id: id,
      sellerId: sellerId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      condition: condition ?? this.condition,
      images: images ?? this.images,
      status: status ?? this.status,
      faculty: faculty,
      aiCaption: aiCaption,
      aiGenerated: aiGenerated,
      createdAt: createdAt,
    );
  }
}
