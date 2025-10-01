import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class AIService {
  final String _baseUrl = "https://api-ef74hege4q-uc.a.run.app";
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to get authentication token
  Future<String?> _getIdToken() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final idToken = await user.getIdToken();
        return idToken;
      }
      return null;
    } catch (e) {
      print('❌ Error getting ID token: $e');
      return null;
    }
  }

  // --- Method for the Final Report Module ---
  Future<Map<String, dynamic>> generateFinalReport({
    required Map<String, dynamic> currentReading,
    required Map<String, dynamic> historicalAverage,
    required String cropContext,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/generateReport');

    try {
      // Get authentication token
      final idToken = await _getIdToken();
      
      if (idToken == null) {
        throw Exception('User not authenticated. Please sign in again.');
      }

      print('🚀 Calling AI API: $url');
      print('🔐 Using ID Token: ${idToken.substring(0, 20)}...');

      final Map<String, dynamic> requestBody = {
        'current_reading': currentReading,
        'historical_average_30_days': historicalAverage,
        'crop_context': cropContext,
      };

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      };

      print('📦 Request Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        if (responseData.containsKey('data')) {
          return responseData['data'];
        } else if (responseData.containsKey('report')) {
          return responseData['report'];
        } else {
          return responseData;
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication failed. Please sign out and sign in again.');
      } else if (response.statusCode == 404) {
        throw Exception('API endpoint not found. Please check the URL.');
      } else if (response.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception('API Error (${response.statusCode}): ${response.body}');
      }
    } on http.ClientException catch (e) {
      print('🌐 Network error: $e');
      throw Exception('Network error: Please check your internet connection.');
    } catch (e) {
      print('❌ Error in generateFinalReport: $e');
      throw Exception('Failed to generate report: $e');
    }
  }

  // --- Method for the Recommendations Module ---
  Future<Map<String, dynamic>> generateRecommendations({
    required Map<String, dynamic> currentReading,
    required String cropContext,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/generateRecommendation');

    try {
      // Get authentication token
      final idToken = await _getIdToken();
      
      if (idToken == null) {
        throw Exception('User not authenticated. Please sign in again.');
      }

      print('🚀 Calling AI Recommendations API: $url');

      final Map<String, dynamic> requestBody = {
        'current_reading': currentReading,
        'crop_context': cropContext,
      };

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      print('📡 Recommendations Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        if (responseData.containsKey('data')) {
          return responseData['data'];
        } else if (responseData.containsKey('recommendations')) {
          return responseData['recommendations'];
        } else {
          return responseData;
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication failed. Please sign out and sign in again.');
      } else {
        throw Exception('API Error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('❌ Error in generateRecommendations: $e');
      throw Exception('Failed to generate recommendations: $e');
    }
  }

  // --- Test API Connection with Auth ---
  Future<bool> testConnection() async {
    try {
      final idToken = await _getIdToken();
      
      if (idToken == null) {
        print('❌ No authentication token available');
        return false;
      }

      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {'Authorization': 'Bearer $idToken'},
      ).timeout(const Duration(seconds: 10));

      print('🔐 Auth test - Status: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 404;
    } catch (e) {
      print('❌ API Connection test failed: $e');
      return false;
    }
  }

  // Mock data generator
  Future<Map<String, dynamic>> generateMockReport({
    required Map<String, dynamic> currentReading,
    required Map<String, dynamic> historicalAverage,
    required String cropContext,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    
    final double moisture = (currentReading['moisture'] ?? currentReading['Moisture'] ?? 50).toDouble();
    final double ph = (currentReading['ph'] ?? currentReading['pH'] ?? currentReading['PH'] ?? 6.5).toDouble();
    final double temperature = (currentReading['temperature'] ?? currentReading['Temperature'] ?? 25).toDouble();

    String qualityStatus = 'Fair';
    int fertilityScore = 65;

    if (moisture >= 60 && ph >= 6.0 && ph <= 7.0 && temperature >= 20 && temperature <= 30) {
      qualityStatus = 'Excellent';
      fertilityScore = 85;
    } else if (moisture >= 50 && ph >= 5.5 && ph <= 7.5) {
      qualityStatus = 'Good';
      fertilityScore = 75;
    }

    String observations = 'Current conditions: Moisture ${moisture.toStringAsFixed(1)}%, '
        'pH ${ph.toStringAsFixed(1)}, Temperature ${temperature.toStringAsFixed(1)}°C. ';

    if (ph < 6.0) {
      observations += 'Soil is slightly acidic. Consider adding lime. ';
    } else if (ph > 7.5) {
      observations += 'Soil is alkaline. Consider adding sulfur. ';
    } else {
      observations += 'pH level is optimal. ';
    }

    return {
      'soil_quality_status': qualityStatus,
      'fertility_index_score': fertilityScore,
      'key_observations': observations.trim(),
      'crop_suitability_analysis': 'Soil conditions are $qualityStatus for $cropContext cultivation.',
      'warnings': moisture < 40 ? 'Low moisture level detected. Consider irrigation.' : 'No critical warnings.',
      'is_mock_data': true,
    };
  }
}