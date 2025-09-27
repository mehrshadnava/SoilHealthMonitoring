class SoilReading {
  final String id;
  final double pH;
  final double moisture;
  final double temperature;
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double electricalConductivity;
  final DateTime timestamp;
  final String? location;

  SoilReading({
    required this.id,
    required this.pH,
    required this.moisture,
    required this.temperature,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.electricalConductivity,
    required this.timestamp,
    this.location,
  });

  factory SoilReading.fromMap(Map<String, dynamic> map) {
    return SoilReading(
      id: map['id'] ?? '',
      pH: (map['pH'] ?? 0.0).toDouble(),
      moisture: (map['moisture'] ?? 0.0).toDouble(),
      temperature: (map['temperature'] ?? 0.0).toDouble(),
      nitrogen: (map['nitrogen'] ?? 0.0).toDouble(),
      phosphorus: (map['phosphorus'] ?? 0.0).toDouble(),
      potassium: (map['potassium'] ?? 0.0).toDouble(),
      electricalConductivity: (map['electricalConductivity'] ?? 0.0).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      location: map['location'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pH': pH,
      'moisture': moisture,
      'temperature': temperature,
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'electricalConductivity': electricalConductivity,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
    };
  }
}