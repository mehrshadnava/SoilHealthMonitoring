import 'package:flutter/foundation.dart';
import 'package:soil_monitoring_app/core/services/firebase_service.dart';
import 'package:soil_monitoring_app/core/services/ai_service.dart';

class SoilProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  final AIService _aiService;
  
  List<dynamic> _historicalReadings = [];
  dynamic _latestReading;
  Map<String, dynamic>? _currentReport;
  dynamic _currentRecommendation;
  bool _isLoading = false;
  String? _error;

  SoilProvider() 
      : _firebaseService = FirebaseService(),
        _aiService = AIService() {
    // Initialize data
    _initializeData();
  }

  Future<void> _initializeData() async {
    await refreshData();
    await loadHistoricalData();
  }

  // Getters
  List<dynamic> get historicalReadings => _historicalReadings;
  dynamic get latestReading => _latestReading;
  Map<String, dynamic>? get currentReport => _currentReport;
  dynamic get currentRecommendation => _currentRecommendation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Methods
  Future<void> loadHistoricalData() async {
    _setLoading(true);
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      
      _historicalReadings = await _firebaseService.getHistoricalReadings(
        thirtyDaysAgo,
        now,
      );
      _error = null;
    } catch (e) {
      _error = 'Failed to load historical data: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshData() async {
    _setLoading(true);
    try {
      _latestReading = await _firebaseService.getLatestReading();
      _error = null;
    } catch (e) {
      _error = 'Failed to refresh data: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> generateAIReport() async {
    _setLoading(true);
    try {
      if (_historicalReadings.isNotEmpty) {
        // Fixed: Pass List<dynamic> directly since AI service expects dynamic
        _currentReport = await _aiService.generateSoilReport(_historicalReadings);
        _error = null;
      }
    } catch (e) {
      _error = 'Failed to generate report: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}