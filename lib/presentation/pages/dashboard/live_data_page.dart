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

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    SensorGauge(
                      value: reading.pH,
                      title: 'pH Level',
                      unit: '',
                      min: 0,
                      max: 14,
                      optimalRange: [6.0, 7.5],
                    ),
                    SensorGauge(
                      value: reading.moisture,
                      title: 'Moisture',
                      unit: '%',
                      min: 0,
                      max: 100,
                      optimalRange: [40, 80],
                    ),
                    SensorGauge(
                      value: reading.temperature,
                      title: 'Temperature',
                      unit: '°C',
                      min: -10,
                      max: 50,
                      optimalRange: [15, 30],
                    ),
                    SensorGauge(
                      value: reading.nitrogen,
                      title: 'Nitrogen',
                      unit: 'mg/kg',
                      min: 0,
                      max: 100,
                      optimalRange: [20, 50],
                    ),
                    SensorGauge(
                      value: reading.phosphorus,
                      title: 'Phosphorus',
                      unit: 'mg/kg',
                      min: 0,
                      max: 100,
                      optimalRange: [15, 40],
                    ),
                    SensorGauge(
                      value: reading.potassium,
                      title: 'Potassium',
                      unit: 'mg/kg',
                      min: 0,
                      max: 300,
                      optimalRange: [150, 250],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last Updated: ${reading.timestamp.toString()}',
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
}