import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:soil_monitoring_app/data/models/soil_reading.dart';

class AIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  final String _apiKey;

  AIService(this._apiKey);

  // Simplified version to avoid complex calculations for now
  Future<Map<String, dynamic>> generateSoilReport(List<SoilReading> readings) async {
    if (readings.isEmpty) {
      return _generateFallbackReport();
    }

    final currentReading = readings.first;
    
    try {
      final prompt = '''
      Analyze this soil data and provide a simple report:
      pH: ${currentReading.pH}, Moisture: ${currentReading.moisture}%, 
      Temperature: ${currentReading.temperature}°C, Nitrogen: ${currentReading.nitrogen}mg/kg
      ''';
      
      // For now, return a simple report without API call
      return _generateHeuristicReport(currentReading);
    } catch (e) {
      return _generateFallbackReport();
    }
  }

  Map<String, dynamic> _generateHeuristicReport(SoilReading reading) {
    double fertilityIndex = _calculateFertilityIndex(reading);
    String soilQuality = _assessSoilQuality(fertilityIndex);
    
    return {
      'soilQuality': soilQuality,
      'fertilityIndex': fertilityIndex,
      'cropSuitability': 'Wheat, Corn, Soybean',
      'limitations': ['Moderate nitrogen deficiency'],
      'warnings': ['Maintain optimal moisture levels'],
    };
  }

  Map<String, dynamic> _generateFallbackReport() {
    return {
      'soilQuality': 'Good',
      'fertilityIndex': 0.7,
      'cropSuitability': 'Various crops suitable',
      'limitations': [],
      'warnings': [],
    };
  }

  double _calculateFertilityIndex(SoilReading reading) {
    double index = 0.0;
    if (reading.pH >= 6.0 && reading.pH <= 7.5) index += 0.3;
    if (reading.nitrogen > 20) index += 0.25;
    if (reading.phosphorus > 15) index += 0.25;
    if (reading.potassium > 150) index += 0.2;
    return index;
  }

  String _assessSoilQuality(double index) {
    if (index >= 0.8) return 'Excellent';
    if (index >= 0.6) return 'Good';
    if (index >= 0.4) return 'Fair';
    return 'Poor';
  }
}