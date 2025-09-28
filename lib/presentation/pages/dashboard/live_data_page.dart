import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soil_monitoring_app/presentation/providers/soil_provider.dart';
import 'package:soil_monitoring_app/presentation/widgets/dashboard/sensor_gauge.dart';

class LiveDataPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Soil Data'),
        backgroundColor: Colors.blue[700],
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
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    padding: EdgeInsets.all(8),
                    children: [
                      SensorGauge(
                        value: soilMoisturePercent,
                        title: 'Soil Moisture',
                        unit: '%',
                        min: 0,
                        max: 100,
                        optimalRange: [40, 80],
                      ),
                      SensorGauge(
                        value: temperature,
                        title: 'Temperature',
                        unit: '°C',
                        min: -10,
                        max: 50,
                        optimalRange: [15, 30],
                      ),
                      SensorGauge(
                        value: humidity,
                        title: 'Humidity',
                        unit: '%',
                        min: 0,
                        max: 100,
                        optimalRange: [40, 70],
                      ),
                      // Raw moisture value display
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Raw Moisture',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '$soilMoistureRaw',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: _getRawMoistureColor(soilMoistureRaw),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'ADC Value',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Placeholder for future sensors
                      _buildPlaceholderCard('pH Sensor', Icons.science),
                      _buildPlaceholderCard('Nutrients', Icons.eco),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last Updated: ${_formatTimestamp(timestamp)}',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () => soilProvider.refreshData(),
                          icon: Icon(Icons.refresh),
                          label: Text('Refresh Data'),
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

  Widget _buildPlaceholderCard(String title, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
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

  // Helper method to get color for raw moisture value
  Color _getRawMoistureColor(int rawValue) {
    if (rawValue > 3000) return Colors.red; // Very wet
    if (rawValue > 2000) return Colors.green; // Optimal
    if (rawValue > 1000) return Colors.orange; // Dry
    return Colors.red; // Very dry
  }
}