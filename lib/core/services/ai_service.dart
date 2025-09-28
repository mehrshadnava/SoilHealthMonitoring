class AIService {
  AIService(); // No parameters needed

  Future<Map<String, dynamic>> generateSoilReport(List<dynamic> readings) async {
    if (readings.isEmpty) {
      return _generateFallbackReport();
    }

    // Use the first reading as current data
    final currentReading = readings.first;
    
    // Return a simple heuristic report
    return _generateHeuristicReport(currentReading);
  }

  Map<String, dynamic> _generateHeuristicReport(dynamic reading) {
    // Extract values safely
    double pH = _getDoubleValue(reading, 'pH');
    double nitrogen = _getDoubleValue(reading, 'nitrogen');
    double phosphorus = _getDoubleValue(reading, 'phosphorus');
    double potassium = _getDoubleValue(reading, 'potassium');
    double moisture = _getDoubleValue(reading, 'moisture');
    double temperature = _getDoubleValue(reading, 'temperature');
    double ec = _getDoubleValue(reading, 'electricalConductivity');
    
    double fertilityIndex = _calculateFertilityIndex(pH, nitrogen, phosphorus, potassium);
    String soilQuality = _assessSoilQuality(fertilityIndex);
    
    return {
      'soilQuality': soilQuality,
      'fertilityIndex': fertilityIndex,
      'cropSuitability': _getCropSuitability(pH, fertilityIndex),
      'limitations': _identifyLimitations(pH, nitrogen, phosphorus, potassium, moisture, ec),
      'warnings': _generateWarnings(reading, temperature, moisture),
      'recommendations': _generateRecommendations(pH, nitrogen, phosphorus, potassium, moisture),
    };
  }

  double _getDoubleValue(dynamic reading, String key) {
    if (reading is Map) {
      return (reading[key] ?? 0.0).toDouble();
    }
    return 0.0;
  }

  double _calculateFertilityIndex(double pH, double nitrogen, double phosphorus, double potassium) {
    double index = 0.0;
    
    // pH score (optimal range 6.0-7.5)
    if (pH >= 6.0 && pH <= 7.5) {
      index += 0.3;
    } else if (pH >= 5.5 && pH <= 8.0) {
      index += 0.15;
    }
    
    // Nutrient scores
    if (nitrogen > 25) index += 0.25;
    else if (nitrogen > 15) index += 0.15;
    
    if (phosphorus > 20) index += 0.25;
    else if (phosphorus > 10) index += 0.15;
    
    if (potassium > 200) index += 0.2;
    else if (potassium > 100) index += 0.1;
    
    return index.clamp(0.0, 1.0);
  }

  String _assessSoilQuality(double index) {
    if (index >= 0.8) return 'Excellent';
    if (index >= 0.6) return 'Good';
    if (index >= 0.4) return 'Fair';
    return 'Poor';
  }

  String _getCropSuitability(double pH, double fertilityIndex) {
    if (fertilityIndex >= 0.7) {
      if (pH >= 6.0 && pH <= 7.0) return 'Wheat, Corn, Soybean, Vegetables';
      if (pH >= 5.5 && pH <= 6.5) return 'Potatoes, Berries, Tea';
      if (pH >= 7.0 && pH <= 8.0) return 'Alfalfa, Sugar Beets, Cabbage';
    }
    return 'Legumes, Rye, Oats (low maintenance crops)';
  }

  List<String> _identifyLimitations(double pH, double nitrogen, double phosphorus, double potassium, double moisture, double ec) {
    List<String> limitations = [];
    
    // pH limitations
    if (pH < 5.5) limitations.add('Highly acidic soil - add lime');
    else if (pH < 6.0) limitations.add('Moderately acidic soil');
    else if (pH > 8.0) limitations.add('Highly alkaline soil - add sulfur');
    else if (pH > 7.5) limitations.add('Moderately alkaline soil');
    
    // Nutrient limitations
    if (nitrogen < 15) limitations.add('Severe nitrogen deficiency');
    else if (nitrogen < 25) limitations.add('Moderate nitrogen deficiency');
    
    if (phosphorus < 10) limitations.add('Severe phosphorus deficiency');
    else if (phosphorus < 20) limitations.add('Moderate phosphorus deficiency');
    
    if (potassium < 100) limitations.add('Severe potassium deficiency');
    else if (potassium < 200) limitations.add('Moderate potassium deficiency');
    
    // Salinity limitations
    if (ec > 4.0) limitations.add('High salinity - consider leaching');
    else if (ec > 2.0) limitations.add('Moderate salinity');
    
    return limitations.isEmpty ? ['No major limitations detected'] : limitations;
  }

  List<String> _generateWarnings(dynamic reading, double temperature, double moisture) {
    List<String> warnings = [];
    
    // Moisture warnings
    if (moisture < 20) warnings.add('Critical moisture level - immediate irrigation needed');
    else if (moisture < 30) warnings.add('Low moisture level - consider irrigation');
    else if (moisture > 90) warnings.add('Waterlogged soil - improve drainage');
    else if (moisture > 80) warnings.add('High moisture level - risk of waterlogging');
    
    // Temperature warnings
    if (temperature < 5) warnings.add('Low temperature - plant growth may be slow');
    if (temperature > 35) warnings.add('High temperature - may stress plants');
    
    return warnings.isEmpty ? ['Soil conditions are stable'] : warnings;
  }

  List<String> _generateRecommendations(double pH, double nitrogen, double phosphorus, double potassium, double moisture) {
    List<String> recommendations = [];
    
    // pH recommendations
    if (pH < 6.0) {
      recommendations.add('Apply agricultural lime: 1-2 tons per hectare');
    } else if (pH > 7.5) {
      recommendations.add('Apply elemental sulfur: 500-1000 kg per hectare');
    }
    
    // Nutrient recommendations
    if (nitrogen < 25) {
      double deficit = 25 - nitrogen;
      recommendations.add('Apply urea: ${(deficit * 2.17).toStringAsFixed(1)} kg per hectare');
    }
    
    if (phosphorus < 20) {
      double deficit = 20 - phosphorus;
      recommendations.add('Apply DAP: ${(deficit * 4.35).toStringAsFixed(1)} kg per hectare');
    }
    
    if (potassium < 200) {
      double deficit = 200 - potassium;
      recommendations.add('Apply potash: ${(deficit * 1.2).toStringAsFixed(1)} kg per hectare');
    }
    
    // Moisture recommendations
    if (moisture < 30) {
      recommendations.add('Irrigate with 20-30 mm water immediately');
    } else if (moisture > 80) {
      recommendations.add('Improve drainage and avoid irrigation for 5-7 days');
    }
    
    // General recommendations
    recommendations.add('Test soil again in 2-3 weeks to monitor improvements');
    recommendations.add('Consider organic compost application for long-term soil health');
    
    return recommendations.isEmpty ? ['Maintain current practices - soil is in good condition'] : recommendations;
  }

  Map<String, dynamic> _generateFallbackReport() {
    return {
      'soilQuality': 'Unknown',
      'fertilityIndex': 0.5,
      'cropSuitability': 'Various crops (data limited)',
      'limitations': ['Insufficient data for detailed analysis'],
      'warnings': ['Collect more soil readings for accurate assessment'],
      'recommendations': [
        'Collect soil samples from multiple locations',
        'Test soil at different depths',
        'Monitor soil conditions regularly'
      ],
    };
  }
}