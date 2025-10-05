class SoilReport {
  final String id;
  final String title;
  final String content;
  final DateTime generatedAt;
  final Map<String, dynamic> soilData;
  final String reportType;

  SoilReport({
    required this.id,
    required this.title,
    required this.content,
    required this.generatedAt,
    required this.soilData,
    required this.reportType,
  });

  factory SoilReport.fromMap(Map<String, dynamic> map) {
    return SoilReport(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title'] ?? 'Soil Analysis Report',
      content: map['content'] ?? '',
      generatedAt: map['generatedAt'] != null 
          ? DateTime.parse(map['generatedAt'])
          : DateTime.now(),
      soilData: Map<String, dynamic>.from(map['soilData'] ?? {}),
      reportType: map['reportType'] ?? 'basic',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'generatedAt': generatedAt.toIso8601String(),
      'soilData': soilData,
      'reportType': reportType,
    };
  }

  // Helper methods
  bool get hasCriticalAlerts => content.toLowerCase().contains('alert') || 
                               content.toLowerCase().contains('warning') ||
                               content.toLowerCase().contains('critical');

  String get formattedDate {
    return '${generatedAt.day}/${generatedAt.month}/${generatedAt.year} ${generatedAt.hour}:${generatedAt.minute.toString().padLeft(2, '0')}';
  }
}