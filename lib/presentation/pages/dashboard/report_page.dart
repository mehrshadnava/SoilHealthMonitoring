import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soil_monitoring_app/presentation/providers/soil_provider.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soil Report'),
        backgroundColor: Colors.purple[700],
      ),
      body: Consumer<SoilProvider>(
        builder: (context, soilProvider, child) {
          if (soilProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final report = soilProvider.currentReport;

          if (report == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No report generated yet'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => soilProvider.generateAIReport(),
                    child: const Text('Generate Report'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReportCard('Soil Quality', report['soilQuality'] ?? 'Unknown'),
                _buildReportCard('Fertility Index', '${(report['fertilityIndex'] ?? 0.0).toStringAsFixed(2)}'),
                _buildReportCard('Suitable Crops', report['cropSuitability'] ?? 'Various'),
                _buildListCard('Limitations', report['limitations'] ?? []),
                _buildListCard('Warnings', report['warnings'] ?? []),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(String title, List<dynamic> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...items.map((item) => Text('• $item')).toList(),
          ],
        ),
      ),
    );
  }
}