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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Soil Health Report',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF658C83),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<SoilProvider>(
        builder: (context, soilProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current Data Card
                _buildCurrentDataCard(soilProvider),
                
                const SizedBox(height: 24),
                
                // Report Generation Section
                _buildReportSection(soilProvider),
                
                const SizedBox(height: 24),
                
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
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: const Color(0xFF658C83).withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF658C83).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.analytics_outlined,
                    color: Color(0xFF658C83),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Current Soil Data',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF658C83),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (soilProvider.latestReading != null) ...[
              _buildDataRow(
                Icons.thermostat_outlined,
                'Temperature',
                '${soilProvider.latestReading!.temperature.toStringAsFixed(1)}°C',
                _getTemperatureColor(soilProvider.latestReading!.temperature),
              ),
              _buildDataRow(
                Icons.water_drop_outlined,
                'Humidity',
                '${soilProvider.latestReading!.humidity.toStringAsFixed(1)}%',
                _getHumidityColor(soilProvider.latestReading!.humidity),
              ),
              _buildDataRow(
                Icons.grass_outlined,
                'Soil Moisture',
                '${soilProvider.latestReading!.soilMoisturePercent.toStringAsFixed(1)}%',
                _getMoistureColor(soilProvider.latestReading!.soilMoisturePercent),
              ),
              const SizedBox(height: 12),
              Container(
                height: 1,
                color: Colors.grey[200],
              ),
              const SizedBox(height: 12),
              _buildDataRow(
                Icons.access_time_outlined,
                'Measurement Time',
                soilProvider.latestReading!.formattedTime,
                Colors.grey[700]!,
              ),
              _buildDataRow(
                Icons.calendar_today_outlined,
                'Date',
                soilProvider.latestReading!.formattedDate,
                Colors.grey[700]!,
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.sensors_off_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No Sensor Data Available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Connect to soil sensors to get current readings',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => soilProvider.refreshData(),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Refresh Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF658C83),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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

  Widget _buildDataRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: color,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportSection(SoilProvider soilProvider) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: const Color(0xFF658C83).withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF658C83).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.assessment_outlined,
                    color: Color(0xFF658C83),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'AI Soil Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF658C83),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Get comprehensive AI-powered analysis of your soil conditions with detailed insights, crop recommendations, and actionable farming advice.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            
            if (soilProvider.isGeneratingReport) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF658C83).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF658C83)),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Generating Soil Report...',
                      style: TextStyle(
                        color: Color(0xFF658C83),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Analyzing soil data and creating detailed insights',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: soilProvider.latestReading != null
                          ? () => soilProvider.generateSoilReport()
                          : null,
                      icon: const Icon(Icons.assignment_outlined, size: 20),
                      label: const Text(
                        'Generate Comprehensive Report',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF658C83),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: soilProvider.latestReading != null
                          ? () => soilProvider.generateQuickAnalysis()
                          : null,
                      icon: const Icon(Icons.flash_on_outlined, size: 20),
                      label: const Text('Quick Analysis'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF658C83),
                        side: const BorderSide(color: Color(0xFF658C83)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            if (soilProvider.error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[100]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Unable to Generate Report',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            soilProvider.error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ],
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
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: const Color(0xFF658C83).withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF658C83).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF658C83),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF658C83),
                    ),
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18, color: Colors.grey),
                  ),
                  onPressed: () {
                    soilProvider.clearReport();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Generated on ${report.formattedDate}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
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
                maxHeight: MediaQuery.of(context).size.height * 0.5,
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
    // Clean the content by removing any problematic characters
    String cleanedContent = content
        .replaceAll('•', '·')
        .replaceAll('*', '')
        .replaceAll(RegExp(r'#+'), '');
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: SelectableText(
        cleanedContent,
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Helper methods for color coding based on values
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