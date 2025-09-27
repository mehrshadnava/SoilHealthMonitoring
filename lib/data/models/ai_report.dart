class AIReport {
  final String id;
  final Map<String, dynamic> currentReading;
  final Map<String, dynamic> averageReading;
  final String soilQuality;
  final double fertilityIndex;
  final String cropSuitability;
  final List<String> limitations;
  final List<String> warnings;
  final DateTime generatedAt;

  AIReport({
    required this.id,
    required this.currentReading,
    required this.averageReading,
    required this.soilQuality,
    required this.fertilityIndex,
    required this.cropSuitability,
    required this.limitations,
    required this.warnings,
    required this.generatedAt,
  });

  factory AIReport.fromMap(Map<String, dynamic> map) {
    return AIReport(
      id: map['id'] ?? '',
      currentReading: Map<String, dynamic>.from(map['currentReading'] ?? {}),
      averageReading: Map<String, dynamic>.from(map['averageReading'] ?? {}),
      soilQuality: map['soilQuality'] ?? 'Unknown',
      fertilityIndex: (map['fertilityIndex'] ?? 0.0).toDouble(),
      cropSuitability: map['cropSuitability'] ?? 'Various crops',
      limitations: List<String>.from(map['limitations'] ?? []),
      warnings: List<String>.from(map['warnings'] ?? []),
      generatedAt: DateTime.parse(map['generatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}