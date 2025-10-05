import 'package:flutter/material.dart';
import 'package:soil_monitoring_app/core/models/soil_reading.dart';

class ReadingDetailPage extends StatelessWidget {
  final SoilReading reading;

  const ReadingDetailPage({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Reading Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF658C83),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Text(
                          'Record Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF658C83),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Date', reading.formattedDate),
                    _buildDetailRow('Time', reading.formattedTime),
                    _buildDetailRow('Sensor ID', reading.sensorId),
                    _buildDetailRow('Timestamp Key', reading.timestampKey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Sensor Readings Grid
            const Text(
              'Sensor Readings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildDataCard(
                  'Temperature',
                  Icons.thermostat,
                  '${reading.temperature.toStringAsFixed(1)}°C',
                  _getTemperatureColor(reading.temperature),
                  'Optimal: 15-35°C',
                ),
                _buildDataCard(
                  'Humidity',
                  Icons.water_drop,
                  '${reading.humidity.toStringAsFixed(1)}%',
                  _getHumidityColor(reading.humidity),
                  'Optimal: 30-80%',
                ),
                _buildDataCard(
                  'Soil Moisture',
                  Icons.grass,
                  '${reading.soilMoisturePercent.toStringAsFixed(1)}%',
                  _getMoistureColor(reading.soilMoisturePercent),
                  'Optimal: 30-100%',
                ),
                _buildDataCard(
                  'Raw Moisture',
                  Icons.analytics,
                  '${reading.soilMoistureRaw}',
                  Colors.blue,
                  'Raw sensor value',
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Status Summary
            Card(
              color: Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF658C83),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusIndicator('Temperature', reading.temperature, 15, 35),
                    _buildStatusIndicator('Humidity', reading.humidity, 30, 80),
                    _buildStatusIndicator('Soil Moisture', reading.soilMoisturePercent, 30, 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(String title, IconData icon, String value, Color color, String subtitle) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String parameter, double value, double minOptimal, double maxOptimal) {
    Color color;
    String status;
    
    if (value < minOptimal) {
      color = Colors.orange;
      status = 'Low';
    } else if (value > maxOptimal) {
      color = Colors.red;
      status = 'High';
    } else {
      color = Colors.green;
      status = 'Optimal';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$parameter: $status',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTemperatureColor(double temperature) {
    if (temperature < 15) return Colors.blue;
    if (temperature > 35) return Colors.red;
    return Colors.green;
  }

  Color _getHumidityColor(double humidity) {
    if (humidity < 30) return Colors.orange;
    if (humidity > 80) return Colors.blue;
    return Colors.green;
  }

  Color _getMoistureColor(double moisture) {
    if (moisture < 30) return Colors.red;
    if (moisture < 60) return Colors.orange;
    return Colors.green;
  }
}