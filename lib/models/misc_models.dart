import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String icon;

  CategoryModel({required this.id, required this.name, required this.icon});

  factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      icon: map['icon'] ?? '📦',
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'icon': icon};
}

class FavoriteModel {
  final String id;
  final String userId;
  final String productId;
  final DateTime createdAt;

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.createdAt,
  });

  factory FavoriteModel.fromMap(String id, Map<String, dynamic> map) {
    return FavoriteModel(
      id: id,
      userId: map['userId'] ?? '',
      productId: map['productId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'productId': productId,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

/// ห้องแชท 1 ห้องผูกกับ "สินค้า 1 ชิ้น" ระหว่างผู้ซื้อ-ผู้ขาย
class ChatModel {
  final String id;
  final List<String> participants; // [buyerId, sellerId]
  final String productId;
  final String productTitle;
  final String productImage;
  final String lastMessage;
  final DateTime lastMessageAt;
  final Map<String, int> unreadCount; // {uid: count}

  ChatModel({
    required this.id,
    required this.participants,
    required this.productId,
    required this.productTitle,
    required this.productImage,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCount = const {},
  });

  factory ChatModel.fromMap(String id, Map<String, dynamic> map) {
    return ChatModel(
      id: id,
      participants: List<String>.from(map['participants'] ?? []),
      productId: map['productId'] ?? '',
      productTitle: map['productTitle'] ?? '',
      productImage: map['productImage'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageAt:
          (map['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
        'participants': participants,
        'productId': productId,
        'productTitle': productTitle,
        'productImage': productImage,
        'lastMessage': lastMessage,
        'lastMessageAt': Timestamp.fromDate(lastMessageAt),
        'unreadCount': unreadCount,
      };
}

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final String? imageUrl;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    this.imageUrl,
    required this.createdAt,
  });

  factory MessageModel.fromMap(String id, Map<String, dynamic> map) {
    return MessageModel(
      id: id,
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'chatId': chatId,
        'senderId': senderId,
        'text': text,
        'imageUrl': imageUrl,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

/// การจอง/นัดรับสินค้า — Timeline: จอง → รอนัดรับ → นัดรับ → สำเร็จ
class ReservationModel {
  final String id;
  final String productId;
  final String productTitle;
  final String buyerId;
  final String sellerId;
  final String status;
  final String meetupLocation;
  final DateTime? meetupTime;
  final DateTime createdAt;

  ReservationModel({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.buyerId,
    required this.sellerId,
    required this.status,
    this.meetupLocation = '',
    this.meetupTime,
    required this.createdAt,
  });

  factory ReservationModel.fromMap(String id, Map<String, dynamic> map) {
    return ReservationModel(
      id: id,
      productId: map['productId'] ?? '',
      productTitle: map['productTitle'] ?? '',
      buyerId: map['buyerId'] ?? '',
      sellerId: map['sellerId'] ?? '',
      status: map['status'] ?? 'requested',
      meetupLocation: map['meetupLocation'] ?? '',
      meetupTime: (map['meetupTime'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productTitle': productTitle,
        'buyerId': buyerId,
        'sellerId': sellerId,
        'status': status,
        'meetupLocation': meetupLocation,
        'meetupTime':
            meetupTime != null ? Timestamp.fromDate(meetupTime!) : null,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
