import 'package:cloud_firestore/cloud_firestore.dart';

/// ตรงกับ schema ของ Firestore collection: users/{uid}
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoURL;
  final String phone;
  final String authProvider; // "email" | "google"
  final String bio;
  final double rating;
  final int reviewCount;
  final String location;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName = '',
    this.photoURL = '',
    this.phone = '',
    this.authProvider = 'email',
    this.bio = '',
    this.rating = 0.0,
    this.reviewCount = 0,
    this.location = '',
    this.createdAt,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoURL: map['photoURL'] ?? '',
      phone: map['phone'] ?? '',
      authProvider: map['authProvider'] ?? 'email',
      bio: map['bio'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: (map['reviewCount'] ?? 0) as int,
      location: map['location'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phone': phone,
      'authProvider': authProvider,
      'bio': bio,
      'rating': rating,
      'reviewCount': reviewCount,
      'location': location,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
