import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// State management ของระบบ auth ทั้งแอป
/// หน้าจอ (LoginScreen, HomeScreen ฯลฯ) ฟัง provider ตัวนี้ผ่าน `context.watch`
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider() {
    _authService.authStateChanges.listen((user) {
      _user = user;
      _status = user == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated;
      notifyListeners();
    });
  }

  AuthStatus get status => _status;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> signIn(String email, String password) =>
      _runAuthAction(() => _authService.signInWithEmail(
            email: email.trim(),
            password: password,
          ));

  Future<bool> signUp(String email, String password, String displayName) =>
      _runAuthAction(() => _authService.signUpWithEmail(
            email: email.trim(),
            password: password,
            displayName: displayName.trim(),
          ));

  Future<bool> signInWithGoogle() =>
      _runAuthAction(() => _authService.signInWithGoogle());

  Future<void> signOut() => _authService.signOut();

  /// รวม try/catch + loading state ไว้ที่เดียว ลดโค้ดซ้ำ
  Future<bool> _runAuthAction(Future<Object?> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _authService.mapErrorToThai(e);
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
