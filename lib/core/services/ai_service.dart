// lib/services/ai_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // ‼️ IMPORTANT: Replace this with the URL you got after deploying your function.
  // It will look something like https://api-yourprojectid.cloudfunctions.net/api
  final String _baseUrl = "https://api-ef74hege4q-uc.a.run.app";

  // --- Method for the Final Report Module ---
  Future<Map<String, dynamic>> generateFinalReport({
    required Map<String, dynamic> currentReading,
    required Map<String, dynamic> historicalAverage,
    required String cropContext,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/generateReport');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'current_reading': currentReading,
          'historical_average_30_days': historicalAverage,
          'crop_context': cropContext,
        }),
      );

      if (response.statusCode == 200) {
        // The cloud function returns the 'data' object directly
        return jsonDecode(response.body)['data'];
      } else {
        // Handle server-side errors
        final errorBody = jsonDecode(response.body);
        throw Exception('Failed to generate report: ${errorBody['error']}');
      }
    } catch (e) {
      // Handle network or other unexpected errors
      print('Error in generateFinalReport: $e');
      throw Exception('An error occurred. Please check your network connection.');
    }
  }

  // --- Method for the Recommendations Module ---
  Future<Map<String, dynamic>> generateRecommendations({
    required Map<String, dynamic> currentReading,
    required String cropContext,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/generateRecommendation');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'current_reading': currentReading,
          'crop_context': cropContext,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception('Failed to generate recommendations: ${errorBody['error']}');
      }
    } catch (e) {
      print('Error in generateRecommendations: $e');
      throw Exception('An error occurred. Please check your network connection.');
    }
  }
}