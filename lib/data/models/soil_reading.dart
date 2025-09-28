class SoilReading {
  final String id;
  final double humidity;
  final double soilMoisturePercent;
  final int soilMoistureRaw;
  final double temperature;
  final DateTime timestamp;
  final String? location;

  SoilReading({
    required this.id,
    required this.humidity,
    required this.soilMoisturePercent,
    required this.soilMoistureRaw,
    required this.temperature,
    required this.timestamp,
    this.location,
  });

  factory SoilReading.fromMap(Map<String, dynamic> map) {
    return SoilReading(
      id: map['id'] ?? '',
      humidity: (map['humidity'] ?? 0.0).toDouble(),
      soilMoisturePercent: (map['soilMoisturePercent'] ?? 0.0).toDouble(),
      soilMoistureRaw: (map['soilMoistureRaw'] ?? 0).toInt(),
      temperature: (map['temperature'] ?? 0.0).toDouble(),
      timestamp: _parseTimestamp(map),
      location: map['location'],
    );
  }

  static DateTime _parseTimestamp(Map<String, dynamic> map) {
    try {
      if (map['timestamp'] is int) {
        return DateTime.fromMillisecondsSinceEpoch(map['timestamp']);
      } else if (map['timestamp'] is String) {
        return DateTime.parse(map['timestamp']);
      } else if (map['id'] != null) {
        // Use the ID as timestamp (Firebase key)
        return DateTime.fromMillisecondsSinceEpoch(int.parse(map['id']));
      }
    } catch (e) {
      print('Error parsing timestamp: $e');
    }
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'humidity': humidity,
      'soilMoisturePercent': soilMoisturePercent,
      'soilMoistureRaw': soilMoistureRaw,
      'temperature': temperature,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'location': location,
    };
  }
}