import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';

/// รวม query ทั้งหมดที่หน้า Home (และหน้าอื่นในอนาคต) ต้องใช้
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<UserModel?> userStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.id, doc.data()!);
    });
  }

  /// หมวดหมู่สินค้า เรียงตาม field `order`
  Stream<List<CategoryModel>> categoriesStream() {
    return _db
        .collection('categories')
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map(CategoryModel.fromDoc).toList());
  }

  /// สินค้าใหม่ล่าสุด (เฉพาะที่ status = available) จำกัดจำนวนสำหรับหน้า Home
  Stream<List<ProductModel>> latestProductsStream({int limit = 10}) {
    return _db
        .collection('products')
        .where('status', isEqualTo: 'available')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(ProductModel.fromDoc).toList());
  }
}
