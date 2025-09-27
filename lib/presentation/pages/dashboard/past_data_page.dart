import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soil_monitoring_app/presentation/providers/soil_provider.dart';
import 'package:intl/intl.dart';

class PastDataPage extends StatefulWidget {
  @override
  _PastDataPageState createState() => _PastDataPageState();
}

class _PastDataPageState extends State<PastDataPage> {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SoilProvider>(context, listen: false).loadHistoricalData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historical Data'),
        backgroundColor: Colors.orange[700],
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () => _exportData(context),
          ),
        ],
      ),
      body: Consumer<SoilProvider>(
        builder: (context, soilProvider, child) {
          if (soilProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final readings = soilProvider.historicalReadings;

          return ListView.builder(
            itemCount: readings.length,
            itemBuilder: (context, index) {
              final reading = readings[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(_dateFormat.format(reading.timestamp)),
                  subtitle: Text(
                    'pH: ${reading.pH.toStringAsFixed(2)} | '
                    'Moisture: ${reading.moisture.toStringAsFixed(1)}% | '
                    'Temp: ${reading.temperature.toStringAsFixed(1)}°C',
                  ),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () => _showReadingDetails(context, reading),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showReadingDetails(BuildContext context, dynamic reading) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reading Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('pH: ${reading.pH.toStringAsFixed(2)}'),
              Text('Moisture: ${reading.moisture.toStringAsFixed(1)}%'),
              Text('Temperature: ${reading.temperature.toStringAsFixed(1)}°C'),
              Text('Nitrogen: ${reading.nitrogen.toStringAsFixed(1)} mg/kg'),
              Text('Phosphorus: ${reading.phosphorus.toStringAsFixed(1)} mg/kg'),
              Text('Potassium: ${reading.potassium.toStringAsFixed(1)} mg/kg'),
              Text('EC: ${reading.electricalConductivity.toStringAsFixed(2)} dS/m'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context) {
    // Implement CSV/PDF export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export functionality coming soon!')),
    );
  }
}