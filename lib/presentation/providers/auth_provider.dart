import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soil_monitoring_app/core/services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    // Check if user is already logged in when provider is created
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    _user = _firebaseService.getCurrentUser();
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      _user = await _firebaseService.signInWithEmail(email, password);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String email, String password) async {
    _setLoading(true);
    try {
      _user = await _firebaseService.registerWithEmail(email, password);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _firebaseService.signOut();
    _user = null;
    _error = null;
    notifyListeners();
  }

  bool get isLoggedIn => _firebaseService.isUserLoggedIn();

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}