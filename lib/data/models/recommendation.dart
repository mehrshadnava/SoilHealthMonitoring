class Recommendation {
  final String id;
  final Map<String, dynamic> soilReading;
  final List<Map<String, dynamic>> recommendedFertilizers;
  final String stepByStepGuide;
  final String riskAssessment;
  final DateTime generatedAt;

  Recommendation({
    required this.id,
    required this.soilReading,
    required this.recommendedFertilizers,
    required this.stepByStepGuide,
    required this.riskAssessment,
    required this.generatedAt,
  });
}