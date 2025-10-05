import 'package:flutter/foundation.dart';
import 'package:soil_monitoring_app/core/services/firebase_service.dart';
import 'package:soil_monitoring_app/core/services/ai_service.dart';
import 'package:soil_monitoring_app/core/models/soil_reading.dart';
import 'package:soil_monitoring_app/data/models/soil_report.dart';

class SoilProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final AIService _aiService = AIService();
  
  SoilReading? _latestReading;
  List<SoilReading> _allReadings = [];
  SoilReport? _currentReport;
  bool _isLoading = false;
  String? _error;
  bool _isGeneratingReport = false;
  bool _isGeneratingRecommendations = false;
  String? _currentRecommendations;

  // Getters
  SoilReading? get latestReading => _latestReading;
  List<SoilReading> get allReadings => _allReadings;
  SoilReport? get currentReport => _currentReport;
  bool get isLoading => _isLoading;
  bool get isGeneratingReport => _isGeneratingReport;
  bool get isGeneratingRecommendations => _isGeneratingRecommendations;
  String? get currentRecommendations => _currentRecommendations;
  String? get error => _error;

  SoilProvider() {
    refreshData();
    loadAllData();
  }

  // Generate soil report using AI
  Future<void> generateSoilReport() async {
    if (_latestReading == null) {
      _error = 'No soil data available to generate report';
      notifyListeners();
      return;
    }

    _isGeneratingReport = true;
    _error = null;
    notifyListeners();

    try {
      // Convert SoilReading to Map for AI service
      final soilData = {
        'temperature': _latestReading!.temperature,
        'humidity': _latestReading!.humidity,
        'soilMoisturePercent': _latestReading!.soilMoisturePercent,
        'soilMoistureRaw': _latestReading!.soilMoistureRaw,
        'timestampKey': _latestReading!.timestampKey,
        'sensorId': _latestReading!.sensorId,
      };

      final reportContent = await _aiService.generateSoilReport(soilData);
      
      _currentReport = SoilReport(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Soil Health Report - ${_latestReading!.formattedDate}',
        content: reportContent,
        generatedAt: DateTime.now(),
        soilData: soilData,
        reportType: 'comprehensive',
      );

      _error = null;
    } catch (e) {
      _error = 'Failed to generate soil report: $e';
      print('Error generating report: $e');
    } finally {
      _isGeneratingReport = false;
      notifyListeners();
    }
  }

  // Generate quick analysis
  Future<void> generateQuickAnalysis() async {
    if (_latestReading == null) {
      _error = 'No soil data available';
      notifyListeners();
      return;
    }

    _isGeneratingReport = true;
    _error = null;
    notifyListeners();

    try {
      final soilData = {
        'temperature': _latestReading!.temperature,
        'humidity': _latestReading!.humidity,
        'soilMoisturePercent': _latestReading!.soilMoisturePercent,
        'soilMoistureRaw': _latestReading!.soilMoistureRaw,
        'timestampKey': _latestReading!.timestampKey,
      };

      final analysis = await _aiService.generateDetailedSoilAnalysis(soilData);
      
      _currentReport = SoilReport(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Quick Soil Analysis - ${_latestReading!.formattedTime}',
        content: analysis,
        generatedAt: DateTime.now(),
        soilData: soilData,
        reportType: 'quick',
      );

      _error = null;
    } catch (e) {
      _error = 'Failed to generate analysis: $e';
    } finally {
      _isGeneratingReport = false;
      notifyListeners();
    }
  }

  // Generate comprehensive soil recommendations
  Future<void> generateSoilRecommendations() async {
    if (_latestReading == null) {
      _error = 'No soil data available to generate recommendations';
      notifyListeners();
      return;
    }

    _isGeneratingRecommendations = true;
    _error = null;
    notifyListeners();

    try {
      final prompt = '''
Based on the following soil sensor readings, provide detailed recommendations to improve soil health:

- Temperature: ${_latestReading!.temperature}°C
- Humidity: ${_latestReading!.humidity}%
- Soil Moisture: ${_latestReading!.soilMoisturePercent}%

Please provide:
1. Analysis of current soil conditions
2. Specific recommendations for improvement
3. Optimal ranges for each parameter
4. Suggested actions for the next 7 days
5. Long-term soil health strategies

Format the response in a clear, actionable way for farmers.
''';

      final response = await _aiService.generateContent(prompt);
      _currentRecommendations = response;
      _error = null;
    } catch (e) {
      _error = 'Failed to generate recommendations: ${e.toString()}';
      print('Error generating recommendations: $e');
    } finally {
      _isGeneratingRecommendations = false;
      notifyListeners();
    }
  }

  // Generate quick tips
  Future<void> generateQuickTips() async {
    if (_latestReading == null) {
      _error = 'No soil data available';
      notifyListeners();
      return;
    }

    _isGeneratingRecommendations = true;
    _error = null;
    notifyListeners();

    try {
      final prompt = '''
Based on these soil readings, provide 5 quick actionable tips:

- Temperature: ${_latestReading!.temperature}°C
- Humidity: ${_latestReading!.humidity}%
- Soil Moisture: ${_latestReading!.soilMoisturePercent}%

Keep each tip brief and practical. Focus on immediate actions.
''';

      final response = await _aiService.generateContent(prompt);
      _currentRecommendations = response;
      _error = null;
    } catch (e) {
      _error = 'Failed to generate tips: ${e.toString()}';
    } finally {
      _isGeneratingRecommendations = false;
      notifyListeners();
    }
  }

  // Clear current report
  void clearReport() {
    _currentReport = null;
    notifyListeners();
  }

  // Clear current recommendations
  void clearRecommendations() {
    _currentRecommendations = null;
    notifyListeners();
  }

  // Existing methods (keep your current implementation)
  void startRealtimeUpdates() {
    _setLoading(true);
    
    _firebaseService.getLatestDataStream().listen(
      (data) {
        if (data != null) {
          try {
            _latestReading = SoilReading.fromMap(data);
            _error = null;
            _setLoading(false);
          } catch (e) {
            _error = 'Error parsing sensor data: $e';
            _setLoading(false);
          }
        }
      },
      onError: (error) {
        _error = 'Real-time update error: $error';
        _setLoading(false);
      },
    );
  }

  void loadAllData() {
    _setLoading(true);
    _allReadings = [];
    
    _firebaseService.getAllSensorData().listen(
      (dataList) {
        try {
          _allReadings = dataList.map((data) => SoilReading.fromMap(data)).toList();
          _error = null;
          _setLoading(false);
          notifyListeners();
        } catch (e) {
          _error = 'Error parsing historical data: $e';
          _setLoading(false);
          notifyListeners();
        }
      },
      onError: (error) {
        _error = 'Error loading historical data: $error';
        _setLoading(false);
        notifyListeners();
      },
    );
  }

  Future<void> refreshData() async {
    _setLoading(true);
    try {
      final data = await _firebaseService.getLatestData();
      if (data != null) {
        _latestReading = SoilReading.fromMap(data);
        _error = null;
      } else {
        _error = 'No data available from any sensor';
      }
    } catch (e) {
      _error = 'Failed to refresh data: $e';
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void refreshHistoricalData() {
    loadAllData();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}