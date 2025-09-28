import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soil_monitoring_app/presentation/providers/soil_provider.dart';
import 'package:soil_monitoring_app/presentation/widgets/dashboard/sensor_gauge.dart';
import 'package:soil_monitoring_app/presentation/widgets/dashboard/dashboard_card.dart';

class LiveDataPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Live Soil Data',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF658C83),
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<SoilProvider>(
        builder: (context, soilProvider, child) {
          if (soilProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (soilProvider.latestReading == null) {
            return Center(child: Text('No data available'));
          }

          final reading = soilProvider.latestReading!;

          // Extract values from the new data structure
          double humidity = _getDoubleValue(reading, 'humidity');
          double soilMoisturePercent = _getDoubleValue(reading, 'soilMoisturePercent');
          int soilMoistureRaw = _getIntValue(reading, 'soilMoistureRaw');
          double temperature = _getDoubleValue(reading, 'temperature');
          String timestamp = _getTimestamp(reading);

          return SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                // Welcome Container
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Color(0xFF658C83),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Soil Monitoring',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Real-time soil health data and sensor readings',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                // Section Header
                Text(
                  'Sensor Readings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 16),

                // First row - 2 widgets
                Row(
                  children: [
                    Expanded(
                      child: _buildSensorCard(
                        'Soil Moisture',
                        Icons.water_drop,
                        '${soilMoisturePercent.toStringAsFixed(1)}%',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildSensorCard(
                        'Temperature',
                        Icons.thermostat,
                        '${temperature.toStringAsFixed(1)}°C',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Second row - 2 widgets
                Row(
                  children: [
                    Expanded(
                      child: _buildSensorCard(
                        'Humidity',
                        Icons.cloud,
                        '${humidity.toStringAsFixed(1)}%',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildSensorCard(
                        'Raw Moisture',
                        Icons.analytics,
                        '$soilMoistureRaw',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Third row - 2 widgets (Placeholders)
                Row(
                  children: [
                    Expanded(
                      child: _buildPlaceholderCard('pH Sensor', Icons.science),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildPlaceholderCard('Nutrients', Icons.eco),
                    ),
                  ],
                ),

                SizedBox(height: 20),
                Card(
                  color: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last Updated: ${_formatTimestamp(timestamp)}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => soilProvider.refreshData(),
                            child: Text('Refresh Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF658C83),
                              foregroundColor: Colors.white,
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSensorCard(String title, IconData icon, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        height: 110, // Reduced height
        padding: EdgeInsets.all(12), // Reduced padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28, // Smaller icon
              color: Color(0xFF658C83),
            ),
            SizedBox(height: 6), // Reduced spacing
            Text(
              title,
              style: TextStyle(
                fontSize: 12, // Smaller font
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
              maxLines: 1, // Prevent text wrapping
            ),
            SizedBox(height: 2), // Minimal spacing
            Text(
              value,
              style: TextStyle(
                fontSize: 16, // Smaller font
                fontWeight: FontWeight.bold,
                color: Color(0xFF658C83),
              ),
              maxLines: 1, // Prevent text wrapping
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderCard(String title, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        height: 110, // Reduced height
        padding: EdgeInsets.all(12), // Reduced padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28, // Smaller icon
              color: Color(0xFF658C83),
            ),
            SizedBox(height: 6), // Reduced spacing
            Text(
              title,
              style: TextStyle(
                fontSize: 12, // Smaller font
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
              maxLines: 1, // Prevent text wrapping
            ),
            SizedBox(height: 2), // Minimal spacing
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 10, // Smaller font
                color: Colors.grey,
              ),
              maxLines: 1, // Prevent text wrapping
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to safely get double values from the map
  double _getDoubleValue(Map<String, dynamic> reading, String key) {
    final value = reading[key];
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Helper method to safely get int values from the map
  int _getIntValue(Map<String, dynamic> reading, String key) {
    final value = reading[key];
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Helper method to get timestamp from the map
  String _getTimestamp(Map<String, dynamic> reading) {
    final timestamp = reading['timestamp'];
    if (timestamp is String) return timestamp;
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp).toIso8601String();
    }
    if (timestamp is DateTime) return timestamp.toIso8601String();
    return 'Unknown';
  }

  // Helper method to format timestamp for display
  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }
}