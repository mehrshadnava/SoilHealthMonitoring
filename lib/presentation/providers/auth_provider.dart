import 'package:flutter/foundation.dart';
import 'package:soil_monitoring_app/core/services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  dynamic _user; // Changed from User? to dynamic
  bool _isLoading = false;
  String? _error;

  dynamic get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      _user = await _firebaseService.signInWithEmail(email, password);
      _error = null;
    } catch (e) {
      _error = e.toString();
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
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}