// lib/screens/report_screen.dart

import 'package:flutter/material.dart';
import 'package:soil_health_monitoring/core/services/ai_service.dart';
import 'package:soil_health_monitoring/core/services/firebase_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AIService _aiService = AIService();
  Map<String, dynamic>? _reportData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAndGenerateReport();
  }

  Future<void> _fetchAndGenerateReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1. Fetch data from Firestore
      final currentReading = await _firebaseService.getLatestSoilData();
      final historicalAverage = await _firebaseService.getHistoricalAverage(30);

      if (currentReading == null) {
        throw Exception("No live sensor data is available to generate a report.");
      }

      // 2. Call the AI Service to generate the report
      final report = await _aiService.generateFinalReport(
        currentReading: currentReading.toJson(),
        historicalAverage: historicalAverage,
        cropContext: "Chili", // This can be made dynamic later
      );

      setState(() {
        _reportData = report;
      });

    } catch (e) {
      setState(() {
        _error = "Failed to generate report:\n${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Soil Health Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAndGenerateReport,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_reportData == null) {
      return const Center(child: Text("No report data could be generated."));
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildReportCard(
          icon: Icons.shield_moon,
          title: "Soil Quality Status",
          content: _reportData!['soil_quality_status'] ?? 'N/A',
          color: Colors.blue.shade100,
        ),
        _buildReportCard(
          icon: Icons.score,
          title: "Fertility Index Score",
          content: "${_reportData!['fertility_index_score'] ?? 'N/A'} / 100",
          color: Colors.green.shade100,
        ),
        _buildReportCard(
          icon: Icons.observation,
          title: "Key Observations",
          content: (_reportData!['key_observations'] ?? 'N/A').replaceAll('\\n', '\n'),
          color: Colors.orange.shade100,
        ),
        _buildReportCard(
          icon: Icons.grass,
          title: "Crop Suitability Analysis",
          content: _reportData!['crop_suitability_analysis'] ?? 'N/A',
          color: Colors.teal.shade100,
        ),
         _buildReportCard(
          icon: Icons.warning_amber,
          title: "Warnings",
          content: _reportData!['warnings'] ?? 'N/A',
          color: Colors.red.shade100,
        ),
      ],
    );
  }

  Widget _buildReportCard({required IconData icon, required String title, required String content, required Color color}) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
         decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color.withOpacity(1), width: 5)),
             borderRadius: BorderRadius.circular(12.0)
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   Icon(icon, color: Theme.of(context).primaryColor),
                   const SizedBox(width: 8),
                   Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 20, thickness: 1),
              Text(content, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}