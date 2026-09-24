import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// รวม logic การ login/register/signOut ทั้งหมดไว้ที่เดียว
/// เพื่อให้ AuthProvider เรียกใช้ได้ง่าย และแยก concern จาก UI
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// สมัครสมาชิกด้วยอีเมล + สร้าง document ใน users collection ทันที
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _createUserDocument(
      uid: credential.user!.uid,
      email: email,
      displayName: displayName,
      authProvider: 'email',
    );

    return credential;
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// ล็อกอินด้วย Google และสร้าง user document อัตโนมัติถ้ายังไม่มี
  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // ผู้ใช้กดยกเลิก

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user!;

    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      await _createUserDocument(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        photoURL: user.photoURL ?? '',
        authProvider: 'google',
      );
    }

    return userCredential;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> _createUserDocument({
    required String uid,
    required String email,
    String displayName = '',
    String photoURL = '',
    String authProvider = 'email',
  }) {
    return _db.collection('users').doc(uid).set({
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phone': '',
      'authProvider': authProvider,
      'bio': '',
      'rating': 0.0,
      'reviewCount': 0,
      'location': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// แปล error code ของ Firebase ให้เป็นข้อความภาษาไทยที่อ่านง่าย
  String mapErrorToThai(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'รูปแบบอีเมลไม่ถูกต้อง';
        case 'user-not-found':
          return 'ไม่พบบัญชีผู้ใช้นี้';
        case 'wrong-password':
        case 'invalid-credential':
          return 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
        case 'email-already-in-use':
          return 'อีเมลนี้ถูกใช้งานแล้ว';
        case 'weak-password':
          return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
        default:
          return 'เกิดข้อผิดพลาด: ${error.message}';
      }
    }
    return 'เกิดข้อผิดพลาดบางอย่าง กรุณาลองใหม่อีกครั้ง';
  }
}
