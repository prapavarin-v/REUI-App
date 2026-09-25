import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../models/product_model.dart';
import '../models/misc_models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------- Categories ----------------
  Stream<List<CategoryModel>> streamCategories() {
    return _db.collection(FirestoreCollections.categories).snapshots().map(
        (s) => s.docs.map((d) => CategoryModel.fromMap(d.id, d.data())).toList());
  }

  /// เรียกครั้งเดียวตอน setup โปรเจกต์เพื่อสร้างหมวดหมู่เริ่มต้น
  Future<void> seedDefaultCategories() async {
    final batch = _db.batch();
    for (final c in DefaultCategories.items) {
      final ref = _db.collection(FirestoreCollections.categories).doc(c['id']);
      batch.set(ref, {'name': c['name'], 'icon': c['icon']});
    }
    await batch.commit();
  }

  // ---------------- Products (CRUD) ----------------
  Future<String> createProduct(ProductModel product) async {
    final ref =
        await _db.collection(FirestoreCollections.products).add(product.toMap());
    return ref.id;
  }

  Future<ProductModel?> getProduct(String productId) async {
    final doc =
        await _db.collection(FirestoreCollections.products).doc(productId).get();
    if (!doc.exists) return null;
    return ProductModel.fromMap(doc.id, doc.data()!);
  }

  Stream<List<ProductModel>> streamProducts({
    String? categoryId,
    String? faculty,
    String? condition,
    String? status,
    String sortBy = 'createdAt', // createdAt | price
    bool descending = true,
  }) {
    Query<Map<String, dynamic>> q = _db.collection(FirestoreCollections.products);
    if (categoryId != null) q = q.where('categoryId', isEqualTo: categoryId);
    if (faculty != null) q = q.where('faculty', isEqualTo: faculty);
    if (condition != null) q = q.where('condition', isEqualTo: condition);
    q = q.where('status', isEqualTo: status ?? ProductStatus.available);
    q = q.orderBy(sortBy, descending: descending);

    return q.snapshots().map(
        (s) => s.docs.map((d) => ProductModel.fromMap(d.id, d.data())).toList());
  }

  /// ดึงสินค้าตามช่วงราคา ทำฝั่ง client เพราะ Firestore จำกัดการ query แบบ range ร่วมกับ orderBy อื่น
  List<ProductModel> filterByPriceRange(
      List<ProductModel> products, int minPrice, int maxPrice) {
    return products
        .where((p) => p.price >= minPrice && p.price <= maxPrice)
        .toList();
  }

  Stream<List<ProductModel>> streamMyProducts(String sellerId) {
    return _db
        .collection(FirestoreCollections.products)
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => ProductModel.fromMap(d.id, d.data())).toList());
  }

  Future<List<ProductModel>> searchProducts(String keyword) async {
    // Firestore ไม่รองรับ full-text search โดยตรง
    // แนวทางจริง: ใช้ Algolia / Typesense sync ผ่าน Cloud Function
    // ที่นี่ทำ prefix search แบบง่ายบนฟิลด์ title (เหมาะกับข้อมูลไม่เยอะ)
    final snap = await _db
        .collection(FirestoreCollections.products)
        .where('title', isGreaterThanOrEqualTo: keyword)
        .where('title', isLessThanOrEqualTo: '$keyword\uf8ff')
        .get();
    return snap.docs.map((d) => ProductModel.fromMap(d.id, d.data())).toList();
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> data) {
    return _db
        .collection(FirestoreCollections.products)
        .doc(productId)
        .update(data);
  }

  Future<void> updateProductStatus(String productId, String status) {
    return updateProduct(productId, {'status': status});
  }

  Future<void> deleteProduct(String productId) {
    return _db.collection(FirestoreCollections.products).doc(productId).delete();
  }

  // ---------------- Favorites (Wishlist) ----------------
  Future<void> toggleFavorite(String userId, String productId) async {
    final favId = '${userId}_$productId';
    final ref = _db.collection(FirestoreCollections.favorites).doc(favId);
    final doc = await ref.get();
    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set(FavoriteModel(
        id: favId,
        userId: userId,
        productId: productId,
        createdAt: DateTime.now(),
      ).toMap());
    }
  }

  Stream<bool> isFavorite(String userId, String productId) {
    final favId = '${userId}_$productId';
    return _db
        .collection(FirestoreCollections.favorites)
        .doc(favId)
        .snapshots()
        .map((d) => d.exists);
  }

  Stream<List<FavoriteModel>> streamFavorites(String userId) {
    return _db
        .collection(FirestoreCollections.favorites)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => FavoriteModel.fromMap(d.id, d.data())).toList());
  }

  // ---------------- Chats & Messages ----------------
  Future<String> getOrCreateChat({
    required String buyerId,
    required String sellerId,
    required ProductModel product,
  }) async {
    final chatId = '${product.id}_$buyerId';
    final ref = _db.collection(FirestoreCollections.chats).doc(chatId);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set(ChatModel(
        id: chatId,
        participants: [buyerId, sellerId],
        productId: product.id,
        productTitle: product.title,
        productImage: product.images.isNotEmpty ? product.images.first : '',
        lastMessage: '',
        lastMessageAt: DateTime.now(),
      ).toMap());
    }
    return chatId;
  }

  Stream<List<ChatModel>> streamChatsForUser(String uid) {
    return _db
        .collection(FirestoreCollections.chats)
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ChatModel.fromMap(d.id, d.data())).toList());
  }

  Stream<List<MessageModel>> streamMessages(String chatId) {
    return _db
        .collection(FirestoreCollections.chats)
        .doc(chatId)
        .collection(FirestoreCollections.messages)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => MessageModel.fromMap(d.id, d.data())).toList());
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    String? imageUrl,
  }) async {
    final msgRef = _db
        .collection(FirestoreCollections.chats)
        .doc(chatId)
        .collection(FirestoreCollections.messages)
        .doc();

    final message = MessageModel(
      id: msgRef.id,
      chatId: chatId,
      senderId: senderId,
      text: text,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );

    final batch = _db.batch();
    batch.set(msgRef, message.toMap());
    batch.update(_db.collection(FirestoreCollections.chats).doc(chatId), {
      'lastMessage': imageUrl != null ? '📷 รูปภาพ' : text,
      'lastMessageAt': Timestamp.fromDate(message.createdAt),
    });
    await batch.commit();
  }

  // ---------------- Reservations ----------------
  Future<String> createReservation(ReservationModel reservation) async {
    final ref = await _db
        .collection(FirestoreCollections.reservations)
        .add(reservation.toMap());
    await updateProductStatus(reservation.productId, ProductStatus.reserved);
    return ref.id;
  }

  Stream<List<ReservationModel>> streamReservationsForUser(String uid,
      {bool asBuyer = true}) {
    final field = asBuyer ? 'buyerId' : 'sellerId';
    return _db
        .collection(FirestoreCollections.reservations)
        .where(field, isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => ReservationModel.fromMap(d.id, d.data()))
            .toList());
  }

  Stream<ReservationModel?> streamReservation(String reservationId) {
    return _db
        .collection(FirestoreCollections.reservations)
        .doc(reservationId)
        .snapshots()
        .map((d) => d.exists ? ReservationModel.fromMap(d.id, d.data()!) : null);
  }

  Future<void> updateReservationStatus(
      String reservationId, String status, {String? productId}) async {
    await _db
        .collection(FirestoreCollections.reservations)
        .doc(reservationId)
        .update({'status': status});

    if (status == ReservationStatus.completed && productId != null) {
      await updateProductStatus(productId, ProductStatus.sold);
    } else if (status == ReservationStatus.cancelled && productId != null) {
      await updateProductStatus(productId, ProductStatus.available);
    }
  }

  Future<void> updateMeetup({
    required String reservationId,
    required String location,
    required DateTime time,
  }) {
    return _db
        .collection(FirestoreCollections.reservations)
        .doc(reservationId)
        .update({
      'meetupLocation': location,
      'meetupTime': Timestamp.fromDate(time),
      'status': ReservationStatus.waiting,
    });
  }
}
