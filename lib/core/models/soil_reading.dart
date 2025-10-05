class SoilReading {
  final String sensorId;
  final String timestampKey;
  final double humidity;
  final double soilMoisturePercent;
  final int soilMoistureRaw;
  final double temperature;
  final int timestamp;

  SoilReading({
    required this.sensorId,
    required this.timestampKey,
    required this.humidity,
    required this.soilMoisturePercent,
    required this.soilMoistureRaw,
    required this.temperature,
    required this.timestamp,
  });

  factory SoilReading.fromMap(Map<String, dynamic> map) {
    return SoilReading(
      sensorId: map['sensorId'] ?? 'unknown',
      timestampKey: map['timestampKey'] ?? '0',
      humidity: _parseDouble(map['humidity']),
      soilMoisturePercent: _parseDouble(map['soilMoisturePercent']),
      soilMoistureRaw: _parseInt(map['soilMoistureRaw']),
      temperature: _parseDouble(map['temperature']),
      timestamp: _parseInt(map['timestamp']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  DateTime get dateTime {
    // Timestamp is now in seconds (from Arduino NTP)
    if (timestamp > 0) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    } else {
      // Fallback to timestampKey
      final keyTimestamp = int.tryParse(timestampKey) ?? 0;
      return DateTime.fromMillisecondsSinceEpoch(keyTimestamp * 1000);
    }
  }

  String get formattedTime {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String get formattedDateTime {
    return '$formattedDate $formattedTime';
  }

  // Human readable time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else {
      return formattedDate;
    }
  }

  @override
  String toString() {
    return 'SoilReading(sensor: $sensorId, time: $formattedDateTime, temp: $temperature°C, humidity: $humidity%, moisture: $soilMoisturePercent%)';
  }
}