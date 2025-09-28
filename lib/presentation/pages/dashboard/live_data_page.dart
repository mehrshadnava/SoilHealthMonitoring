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

          // Safely extract values from the map
          double pH = _getDoubleValue(reading, 'pH');
          double moisture = _getDoubleValue(reading, 'moisture');
          double temperature = _getDoubleValue(reading, 'temperature');
          double nitrogen = _getDoubleValue(reading, 'nitrogen');
          double phosphorus = _getDoubleValue(reading, 'phosphorus');
          double potassium = _getDoubleValue(reading, 'potassium');
          String timestamp = _getTimestamp(reading);

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Fixed: Use ConstrainedBox to limit GridView height
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7, // 70% of screen height
                  ),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    childAspectRatio: 0.9, // Adjust aspect ratio for better fit
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    padding: EdgeInsets.all(8),
                    children: [
                      SensorGauge(
                        value: pH,
                        title: 'pH Level',
                        unit: '',
                        min: 0,
                        max: 14,
                        optimalRange: [6.0, 7.5],
                      ),
                      SensorGauge(
                        value: moisture,
                        title: 'Moisture',
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
                        value: nitrogen,
                        title: 'Nitrogen',
                        unit: 'mg/kg',
                        min: 0,
                        max: 100,
                        optimalRange: [20, 50],
                      ),
                      SensorGauge(
                        value: phosphorus,
                        title: 'Phosphorus',
                        unit: 'mg/kg',
                        min: 0,
                        max: 100,
                        optimalRange: [15, 40],
                      ),
                      SensorGauge(
                        value: potassium,
                        title: 'Potassium',
                        unit: 'mg/kg',
                        min: 0,
                        max: 300,
                        optimalRange: [150, 250],
                      ),
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

  // Helper method to safely get double values from the map
  double _getDoubleValue(Map<String, dynamic> reading, String key) {
    final value = reading[key];
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Helper method to get timestamp from the map
  String _getTimestamp(Map<String, dynamic> reading) {
    final timestamp = reading['timestamp'];
    if (timestamp is String) return timestamp;
    if (timestamp is DateTime) return timestamp.toIso8601String();
    return 'Unknown';
  }

  // Helper method to format timestamp for display
  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }
}