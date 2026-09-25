import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String studentId;
  final String faculty;
  final String major;
  final String email;
  final String photoUrl;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.studentId,
    required this.faculty,
    required this.major,
    required this.email,
    this.photoUrl = '',
    this.rating = 0,
    this.reviewCount = 0,
    required this.createdAt,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      studentId: map['studentId'] ?? '',
      faculty: map['faculty'] ?? '',
      major: map['major'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: (map['reviewCount'] ?? 0),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'studentId': studentId,
      'faculty': faculty,
      'major': major,
      'email': email,
      'photoUrl': photoUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
