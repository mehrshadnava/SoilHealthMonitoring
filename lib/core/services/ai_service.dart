import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:soil_monitoring_app/core/constants/api_constants.dart';

class AIService {
  GenerativeModel? _model;

  AIService() {
    _initializeModel();
  }

  void _initializeModel() {
    // Try multiple model names in order
    final modelNames = [
      'gemini-2.5-flash',
    ];

    for (final modelName in modelNames) {
      try {
        _model = GenerativeModel(
          model: modelName,
          apiKey: ApiConstants.geminiApiKey,
        );
        print('✅ Successfully initialized model: $modelName');
        break;
      } catch (e) {
        print('❌ Failed to initialize model $modelName: $e');
        continue;
      }
    }
  }

  // NEW METHOD: Generate content using custom prompt
  Future<String> generateContent(String prompt) async {
    // Check if API key is set
    if (ApiConstants.geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE' || 
        ApiConstants.geminiApiKey.isEmpty) {
      return '''
⚠️ API Key Not Configured

Please set up your Gemini API key to generate AI-powered content:

1. Get your FREE API key from: https://aistudio.google.com/
2. Update lib/core/constants/api_constants.dart
3. Replace "YOUR_GEMINI_API_KEY_HERE" with your actual key
4. Restart the app

Without the API key, only basic analysis is available.
''';
    }

    // Check if model initialized
    if (_model == null) {
      return 'Unable to generate content: AI model not initialized. Please check your API configuration.';
    }

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to generate content at this time.';
    } catch (e) {
      print('Error generating content: $e');
      return 'Error generating content: ${e.toString()}';
    }
  }

  Future<String> generateSoilReport(Map<String, dynamic> soilData) async {
    // Check if API key is set
    if (ApiConstants.geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE' || 
        ApiConstants.geminiApiKey.isEmpty) {
      return _getApiKeyNotSetReport(soilData);
    }

    // Check if model initialized
    if (_model == null) {
      return _getFallbackReport(soilData);
    }

    try {
      final prompt = _buildSoilReportPrompt(soilData);
      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to generate soil report at this time.';
    } catch (e) {
      print('Error generating soil report: $e');
      return _getErrorReport(soilData, e.toString());
    }
  }

  String _getApiKeyNotSetReport(Map<String, dynamic> soilData) {
    return '''
⚠️ API Key Not Configured

Please set up your Gemini API key to generate AI-powered soil reports:

1. Get your FREE API key from: https://aistudio.google.com/
2. Update lib/core/constants/api_constants.dart
3. Replace "YOUR_GEMINI_API_KEY_HERE" with your actual key
4. Restart the app

CURRENT SOIL READINGS:
• Temperature: ${soilData['temperature']}°C
• Humidity: ${soilData['humidity']}%
• Soil Moisture: ${soilData['soilMoisturePercent']}%

BASIC ASSESSMENT:
${_assessTemperature(soilData['temperature'])}
${_assessHumidity(soilData['humidity'])}
${_assessMoisture(soilData['soilMoisturePercent'])}

With AI enabled, you'll get:
✓ Detailed crop recommendations
✓ Seasonal planting advice  
✓ Soil management tips
✓ Pest and disease prevention
''';
  }

  String _getFallbackReport(Map<String, dynamic> soilData) {
    return '''
🌱 SOIL HEALTH REPORT

Based on your sensor readings:

CURRENT READINGS:
• Temperature: ${soilData['temperature']}°C
• Humidity: ${soilData['humidity']}%
• Soil Moisture: ${soilData['soilMoisturePercent']}%

QUICK ASSESSMENT:
${_assessTemperature(soilData['temperature'])}
${_assessHumidity(soilData['humidity'])}
${_assessMoisture(soilData['soilMoisturePercent'])}

SETUP REQUIRED:
To get AI-powered analysis with crop recommendations and detailed insights, please set up your Gemini API key.

Steps:
1. Visit https://aistudio.google.com/
2. Get your free API key
3. Update api_constants.dart with your key
4. Restart the app
''';
  }

  String _getErrorReport(Map<String, dynamic> soilData, String error) {
    return '''
❌ Error Generating AI Report

Error details: $error

This might be due to:
• Invalid or missing API key
• Network connectivity issues  
• API quota exceeded
• Model availability issues

CURRENT SOIL DATA:
• Temperature: ${soilData['temperature']}°C
• Humidity: ${soilData['humidity']}%
• Soil Moisture: ${soilData['soilMoisturePercent']}%

BASIC ASSESSMENT:
${_assessTemperature(soilData['temperature'])}
${_assessHumidity(soilData['humidity'])}
${_assessMoisture(soilData['soilMoisturePercent'])}

Please check your Gemini API configuration and try again.
''';
  }

  String _buildSoilReportPrompt(Map<String, dynamic> soilData) {
    return '''
You are an agricultural expert and soil scientist. Analyze this soil sensor data and provide a comprehensive, practical soil health report for farmers.

SOIL SENSOR READINGS:
- Soil Temperature: ${soilData['temperature']}°C
- Air Humidity: ${soilData['humidity']}%
- Soil Moisture Level: ${soilData['soilMoisturePercent']}%
- Raw Sensor Reading: ${soilData['soilMoistureRaw']}
- Measurement Time: ${soilData['timestampKey']}

Please provide a structured report with these sections:

1. SOIL HEALTH ASSESSMENT
   - Overall condition rating (Excellent/Good/Fair/Poor)
   - Key positive observations
   - Areas needing attention

2. PARAMETER ANALYSIS
   - Temperature Analysis: Optimal range for common crops, current status
   - Humidity Impact: How air humidity affects soil and plants
   - Moisture Level: Sufficiency for different crop types

3. CROP RECOMMENDATIONS
   - Best suited crops for current conditions
   - Planting timing suggestions
   - Crop rotation advice

4. ACTIONABLE RECOMMENDATIONS
   - Immediate actions (if needed)
   - Irrigation suggestions
   - Soil management tips
   - Monitoring frequency

5. ALERTS & WARNINGS
   - Critical conditions requiring immediate action
   - Preventive measures
   - Seasonal considerations

Format the report in clear, bullet-point style that's easy for farmers to understand. Focus on practical, actionable advice.
''';
  }

  // Alternative method for more detailed analysis
  Future<String> generateDetailedSoilAnalysis(Map<String, dynamic> soilData) async {
    // Check if API key is set
    if (ApiConstants.geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE' || 
        ApiConstants.geminiApiKey.isEmpty) {
      return '''
Quick Soil Analysis (API Key Required)

Current readings show:
• Temperature: ${soilData['temperature']}°C - ${_getTemperatureStatus(soilData['temperature'])}
• Humidity: ${soilData['humidity']}% - ${_getHumidityStatus(soilData['humidity'])}
• Soil Moisture: ${soilData['soilMoisturePercent']}% - ${_getMoistureStatus(soilData['soilMoisturePercent'])}

Set up your Gemini API key at https://aistudio.google.com/ for detailed AI analysis with crop-specific recommendations.
''';
    }

    // Check if model initialized
    if (_model == null) {
      return '''
Quick Soil Analysis

${_assessTemperature(soilData['temperature'])}
${_assessHumidity(soilData['humidity'])}
${_assessMoisture(soilData['soilMoisturePercent'])}

Configure your API key for AI-powered insights.
''';
    }

    try {
      final prompt = '''
Provide a quick soil analysis based on these readings:

- Soil Temperature: ${soilData['temperature']}°C
- Air Humidity: ${soilData['humidity']}%
- Soil Moisture: ${soilData['soilMoisturePercent']}%

Give a brief assessment in 3-4 bullet points focusing on:
1. Current soil condition
2. Suitable crops
3. Any immediate concerns
4. One key recommendation

Keep it concise and practical for farmers.
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to generate quick analysis.';
    } catch (e) {
      return '''
Quick Analysis (Fallback)

${_assessTemperature(soilData['temperature'])}
${_assessHumidity(soilData['humidity'])}
${_assessMoisture(soilData['soilMoisturePercent'])}

Error: ${e.toString()}
''';
    }
  }

  String _assessTemperature(double temperature) {
    if (temperature < 10) return '• Temperature: Too cold for most crops (${temperature}°C)';
    if (temperature > 35) return '• Temperature: Too hot, risk of heat stress (${temperature}°C)';
    if (temperature >= 15 && temperature <= 30) return '• Temperature: Optimal for most crops (${temperature}°C)';
    return '• Temperature: Within acceptable range (${temperature}°C)';
  }

  String _assessHumidity(double humidity) {
    if (humidity < 30) return '• Humidity: Low, may need irrigation (${humidity}%)';
    if (humidity > 80) return '• Humidity: High, watch for fungal issues (${humidity}%)';
    return '• Humidity: Normal range (${humidity}%)';
  }

  String _assessMoisture(double moisture) {
    if (moisture < 30) return '• Moisture: Low, plants may be stressed (${moisture}%)';
    if (moisture > 90) return '• Moisture: High, risk of waterlogging (${moisture}%)';
    if (moisture >= 40 && moisture <= 80) return '• Moisture: Ideal for most plants (${moisture}%)';
    return '• Moisture: Within acceptable range (${moisture}%)';
  }

  // Helper methods for status indicators
  String _getTemperatureStatus(double temperature) {
    if (temperature < 10) return 'Too Cold';
    if (temperature > 35) return 'Too Hot';
    if (temperature >= 15 && temperature <= 30) return 'Optimal';
    return 'Acceptable';
  }

  String _getHumidityStatus(double humidity) {
    if (humidity < 30) return 'Low';
    if (humidity > 80) return 'High';
    return 'Normal';
  }

  String _getMoistureStatus(double moisture) {
    if (moisture < 30) return 'Low';
    if (moisture > 90) return 'High';
    if (moisture >= 40 && moisture <= 80) return 'Ideal';
    return 'Acceptable';
  }
}