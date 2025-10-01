import 'package:flutter/material.dart';
import 'package:soil_monitoring_app/core/services/ai_service.dart';
import 'package:soil_monitoring_app/core/services/firebase_service.dart';

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
  bool _usingMockData = false;

  @override
  void initState() {
    super.initState();
    _fetchAndGenerateReport();
  }

  Future<void> _fetchAndGenerateReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _usingMockData = false;
    });

    try {
      print('🔍 Step 1: Testing API connection...');
      final isConnected = await _aiService.testConnection();
      if (!isConnected) {
        print('⚠️ API not reachable, using mock data...');
        await _useMockData();
        return;
      }

      print('🔍 Step 2: Fetching current soil data...');
      final currentReading = await _firebaseService.getLatestSoilData();
      print('📊 Current reading: $currentReading');

      if (currentReading == null || currentReading.isEmpty) {
        throw Exception("No live sensor data is available to generate a report.");
      }

      print('🔍 Step 3: Fetching historical average...');
      final historicalAverage = await _firebaseService.getHistoricalAverage(30);
      print('📈 Historical average: $historicalAverage');

      print('🔍 Step 4: Calling AI service...');
      final report = await _aiService.generateFinalReport(
        currentReading: currentReading,
        historicalAverage: historicalAverage,
        cropContext: "Chili",
      );

      print('✅ Report generated successfully');
      setState(() {
        _reportData = report;
        _usingMockData = report['is_mock_data'] == true;
      });

    } catch (e) {
      print('❌ Error in main flow: $e');
      // Try fallback to mock data
      await _useMockData();
    }
  }

  Future<void> _useMockData() async {
    try {
      print('🔄 Attempting to use mock data...');
      final currentReading = await _firebaseService.getLatestSoilData();
      final historicalAverage = await _firebaseService.getHistoricalAverage(30);

      if (currentReading == null || currentReading.isEmpty) {
        // Use default mock data if no Firebase data
        final mockReport = await _aiService.generateMockReport(
          currentReading: {'moisture': 65.0, 'ph': 6.8, 'temperature': 25.0},
          historicalAverage: {},
          cropContext: "Chili",
        );
        setState(() {
          _reportData = mockReport;
          _usingMockData = true;
        });
      } else {
        // Generate mock data based on actual Firebase data
        final mockReport = await _aiService.generateMockReport(
          currentReading: currentReading,
          historicalAverage: historicalAverage,
          cropContext: "Chili",
        );
        setState(() {
          _reportData = mockReport;
          _usingMockData = true;
        });
      }
    } catch (e) {
      print('❌ Mock data also failed: $e');
      setState(() {
        _error = "Failed to generate report:\n$e\n\nUsing demo data instead.";
        _useDemoData();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _useDemoData() {
    _reportData = {
      'soil_quality_status': 'Good',
      'fertility_index_score': 72,
      'key_observations': 'Soil analysis shows adequate nutrient levels. pH is balanced. Moisture content is optimal for plant growth.',
      'crop_suitability_analysis': 'Highly suitable for Chili cultivation. Maintain current soil conditions for best yield.',
      'warnings': 'Monitor soil moisture during dry spells. Consider organic compost for long-term fertility.',
      'is_demo_data': true,
    };
    _usingMockData = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Soil Health Report'),
        actions: [
          if (_usingMockData)
            const Tooltip(
              message: 'Using demo data - API unavailable',
              child: Icon(Icons.wifi_off, color: Colors.orange),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAndGenerateReport,
            tooltip: 'Refresh report',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating AI Soil Report...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchAndGenerateReport,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_reportData == null) {
      return const Center(
        child: Text("No report data could be generated."),
      );
    }

    return Column(
      children: [
        if (_usingMockData)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.orange.shade100,
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Using ${_reportData?['is_demo_data'] == true ? 'demo' : 'mock'} data - AI service unavailable',
                    style: const TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildReportCard(
                icon: Icons.assessment,
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
                icon: Icons.visibility,
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
          ),
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
          border: Border(
            left: BorderSide(color: color, width: 5),
          ),
          borderRadius: BorderRadius.circular(12.0),
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
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 1),
              Text(
                content,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}