import 'package:flutter/foundation.dart';
import 'package:soil_monitoring_app/core/services/firebase_service.dart';
import 'package:soil_monitoring_app/core/services/ai_service.dart';

class SoilProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  final AIService _aiService;
  
  List<dynamic> _historicalReadings = [];
  dynamic _latestReading;
  Map<String, dynamic>? _currentReport;
  Map<String, dynamic>? _currentRecommendation;
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
  Map<String, dynamic>? get currentRecommendation => _currentRecommendation;
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
      if (_latestReading != null) {
        // Fixed method name and parameters to match AIService
        _currentReport = await _aiService.generateFinalReport(
          currentReading: _latestReading.toJson(),
          historicalAverage: await _calculateHistoricalAverage(),
          cropContext: "Chili", // You can make this dynamic later
        );
        _error = null;
      } else {
        _error = 'No latest reading available to generate report';
      }
    } catch (e) {
      _error = 'Failed to generate report: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> generateAIRecommendations() async {
    _setLoading(true);
    try {
      if (_latestReading != null) {
        // Generate recommendations using AI service
        _currentRecommendation = await _aiService.generateRecommendations(
          currentReading: _latestReading.toJson(),
          cropContext: "Chili", // You can make this dynamic later
        );
        _error = null;
      } else {
        _error = 'No latest reading available to generate recommendations';
      }
    } catch (e) {
      _error = 'Failed to generate recommendations: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Helper method to calculate historical average
  Future<Map<String, dynamic>> _calculateHistoricalAverage() async {
    if (_historicalReadings.isEmpty) return {};
    
    try {
      // Calculate average values from historical readings
      // Adjust this logic based on your data structure
      Map<String, dynamic> averages = {};
      
      if (_historicalReadings.isNotEmpty) {
        // Example: Calculate average for numeric fields
        // You'll need to adapt this to your actual data structure
        double sumTemp = 0;
        double sumMoisture = 0;
        double sumPH = 0;
        int count = 0;
        
        for (var reading in _historicalReadings) {
          // Access reading properties based on your data structure
          // This is an example - adjust according to your actual data model
          if (reading.temperature != null) sumTemp += reading.temperature;
          if (reading.moisture != null) sumMoisture += reading.moisture;
          if (reading.ph != null) sumPH += reading.ph;
          count++;
        }
        
        if (count > 0) {
          averages['temperature'] = sumTemp / count;
          averages['moisture'] = sumMoisture / count;
          averages['ph'] = sumPH / count;
        }
      }
      
      return averages;
    } catch (e) {
      return {};
    }
  }

  // Clear current report and recommendations
  void clearAIResults() {
    _currentReport = null;
    _currentRecommendation = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}