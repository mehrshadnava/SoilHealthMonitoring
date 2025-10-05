import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soil_monitoring_app/data/models/soil_report.dart';
import 'package:soil_monitoring_app/presentation/providers/soil_provider.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  @override
  void initState() {
    super.initState();
    // Ensure we have latest data when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final soilProvider = Provider.of<SoilProvider>(context, listen: false);
      if (soilProvider.latestReading == null) {
        soilProvider.refreshData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Soil Report',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF658C83),
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<SoilProvider>(
        builder: (context, soilProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current Data Card
                _buildCurrentDataCard(soilProvider),
                
                const SizedBox(height: 20),
                
                // Report Generation Section
                _buildReportSection(soilProvider),
                
                const SizedBox(height: 20),
                
                // Generated Report
                if (soilProvider.currentReport != null)
                  _buildGeneratedReport(soilProvider.currentReport!, soilProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentDataCard(SoilProvider soilProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Soil Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF658C83),
              ),
            ),
            const SizedBox(height: 12),
            if (soilProvider.latestReading != null) ...[
              _buildDataRow('Temperature', '${soilProvider.latestReading!.temperature.toStringAsFixed(1)}°C'),
              _buildDataRow('Humidity', '${soilProvider.latestReading!.humidity.toStringAsFixed(1)}%'),
              _buildDataRow('Soil Moisture', '${soilProvider.latestReading!.soilMoisturePercent.toStringAsFixed(1)}%'),
              _buildDataRow('Time', '${soilProvider.latestReading!.formattedTime}'),
              _buildDataRow('Date', soilProvider.latestReading!.formattedDate),
            ] else ...[
              const Text(
                'No current data available',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => soilProvider.refreshData(),
                child: const Text('Load Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF658C83),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportSection(SoilProvider soilProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Generate Soil Report',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF658C83),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Get AI-powered analysis of your soil conditions with recommendations for optimal crop growth.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            
            if (soilProvider.isGeneratingReport) ...[
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Generating soil report...',
                      style: TextStyle(
                        color: Color(0xFF658C83),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: soilProvider.latestReading != null
                          ? () => soilProvider.generateSoilReport()
                          : null,
                      child: const Text('Comprehensive Report'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF658C83),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: soilProvider.latestReading != null
                          ? () => soilProvider.generateQuickAnalysis()
                          : null,
                      child: const Text('Quick Analysis'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF658C83),
                        side: const BorderSide(color: Color(0xFF658C83)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            if (soilProvider.error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        soilProvider.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratedReport(SoilReport report, SoilProvider soilProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF658C83),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    soilProvider.clearReport();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Generated: ${report.formattedDate}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            // Report Content with constrained height and scrolling
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                child: _buildReportContent(report.content),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportContent(String content) {
    return SelectableText(
      content,
      style: const TextStyle(
        fontSize: 14,
        height: 1.5,
      ),
    );
  }
}