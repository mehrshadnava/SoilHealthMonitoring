import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soil_monitoring_app/presentation/providers/soil_provider.dart';
import 'package:soil_monitoring_app/core/models/soil_reading.dart';

class PastDataPage extends StatelessWidget {
  const PastDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Debug: Print current state when building
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final soilProvider = Provider.of<SoilProvider>(context, listen: false);
      print('PastDataPage Build - isLoading: ${soilProvider.isLoading}');
      print('PastDataPage Build - error: ${soilProvider.error}');
      print('PastDataPage Build - records: ${soilProvider.allReadings.length}');
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Past Data Records',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF658C83),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              Provider.of<SoilProvider>(context, listen: false).loadAllData();
            },
          ),
        ],
      ),
      body: Consumer<SoilProvider>(
        builder: (context, soilProvider, child) {
          // Show loading state
          if (soilProvider.isLoading && soilProvider.allReadings.isEmpty) {
            return _buildLoadingState();
          }

          // Show error state
          if (soilProvider.error != null) {
            return _buildErrorState(soilProvider, context);
          }

          // Show no data state
          if (soilProvider.allReadings.isEmpty) {
            return _buildNoDataState(soilProvider, context);
          }

          // Show data
          return _buildDataList(soilProvider.allReadings, context, soilProvider);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading historical data...',
            style: TextStyle(
              color: Color(0xFF658C83),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(SoilProvider soilProvider, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Data',
              style: TextStyle(
                fontSize: 18,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              soilProvider.error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                soilProvider.clearError();
                soilProvider.loadAllData();
              },
              child: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF658C83),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataState(SoilProvider soilProvider, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history_rounded,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Historical Data',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No past sensor readings available',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                soilProvider.loadAllData();
              },
              child: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF658C83),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataList(List<SoilReading> readings, BuildContext context, SoilProvider soilProvider) {
    return Column(
      children: [
        // Header Info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFF5F5F5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Records: ${readings.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF658C83),
                ),
              ),
              const Icon(
                Icons.history,
                color: Color(0xFF658C83),
              ),
            ],
          ),
        ),
        
        // Data List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              soilProvider.loadAllData();
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
              itemCount: readings.length,
              itemBuilder: (context, index) {
                final reading = readings[index];
                return _buildReadingCard(reading, context);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadingCard(SoilReading reading, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E8),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(
            Icons.thermostat,
            color: Color(0xFF658C83),
          ),
        ),
        title: Text(
          '${reading.formattedDate} ${reading.formattedTime}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Sensor: ${reading.sensorId}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildMiniIndicator('${reading.temperature.toStringAsFixed(1)}°C', Icons.thermostat),
                const SizedBox(width: 8),
                _buildMiniIndicator('${reading.humidity.toStringAsFixed(1)}%', Icons.water_drop),
                const SizedBox(width: 8),
                _buildMiniIndicator('${reading.soilMoisturePercent.toStringAsFixed(1)}%', Icons.grass),
              ],
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () {
          _showReadingDetails(context, reading);
        },
      ),
    );
  }

  Widget _buildMiniIndicator(String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  void _showReadingDetails(BuildContext context, SoilReading reading) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Reading Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF658C83),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Date', reading.formattedDate),
              _buildDetailRow('Time', reading.formattedTime),
              _buildDetailRow('Sensor ID', reading.sensorId),
              _buildDetailRow('Timestamp', reading.timestampKey),
              const SizedBox(height: 16),
              const Text(
                'Sensor Readings',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF658C83),
                ),
              ),
              const SizedBox(height: 8),
              _buildReadingRow('Temperature', '${reading.temperature.toStringAsFixed(1)}°C', _getTemperatureColor(reading.temperature)),
              _buildReadingRow('Humidity', '${reading.humidity.toStringAsFixed(1)}%', _getHumidityColor(reading.humidity)),
              _buildReadingRow('Soil Moisture', '${reading.soilMoisturePercent.toStringAsFixed(1)}%', _getMoistureColor(reading.soilMoisturePercent)),
              _buildReadingRow('Raw Value', '${reading.soilMoistureRaw}', Colors.blue),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF658C83)),
            ),
          ),
        ],
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
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingRow(String parameter, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              parameter,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
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