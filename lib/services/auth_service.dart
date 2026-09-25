import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// สมัครสมาชิกด้วย University Email + สร้างโปรไฟล์ใน Firestore (users/{uid})
  Future<UserModel> register({
    required String name,
    required String studentId,
    required String faculty,
    required String major,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;

    final userModel = UserModel(
      uid: uid,
      name: name,
      studentId: studentId,
      faculty: faculty,
      major: major,
      email: email,
      createdAt: DateTime.now(),
    );

    await _db
        .collection(FirestoreCollections.users)
        .doc(uid)
        .set(userModel.toMap());

    return userModel;
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Login ด้วย Google Student Mail
  /// หมายเหตุ: ต้องตั้งค่า google_sign_in package + OAuth client ใน Firebase Console
  /// ที่นี่ทำเป็นโครงเรียกใช้งาน ให้เพิ่ม package google_sign_in แล้วเติม logic จริง
  Future<UserCredential> loginWithGoogle(AuthCredential googleCredential) {
    return _auth.signInWithCredential(googleCredential);
  }

  Future<void> resetPassword(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> logout() => _auth.signOut();

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _db.collection(FirestoreCollections.users).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(uid, doc.data()!);
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) {
    return _db.collection(FirestoreCollections.users).doc(uid).update(data);
  }
}
