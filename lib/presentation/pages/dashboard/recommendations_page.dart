import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soil_monitoring_app/presentation/providers/soil_provider.dart';

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({super.key});

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
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
          'Soil Recommendations',
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
                
                // Recommendations Section
                _buildRecommendationsSection(soilProvider),
                
                const SizedBox(height: 20),
                
                // Generated Recommendations
                if (soilProvider.currentRecommendations != null)
                  _buildGeneratedRecommendations(soilProvider.currentRecommendations!, soilProvider),
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
              'Current Soil Conditions',
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

  Widget _buildRecommendationsSection(SoilProvider soilProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Get Soil Recommendations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF658C83),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Receive AI-powered recommendations to improve your soil health and optimize growing conditions for your crops.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            
            if (soilProvider.isGeneratingRecommendations) ...[
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Analyzing soil data...',
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
                          ? () => soilProvider.generateSoilRecommendations()
                          : null,
                      child: const Text('Get Recommendations'),
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
                          ? () => soilProvider.generateQuickTips()
                          : null,
                      child: const Text('Quick Tips'),
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

  Widget _buildGeneratedRecommendations(String recommendations, SoilProvider soilProvider) {
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
                const Expanded(
                  child: Text(
                    'Soil Health Recommendations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF658C83),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    soilProvider.clearRecommendations();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Generated: ${DateTime.now().toString().split(' ')[0]}',
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
            // Recommendations Content with constrained height and scrolling
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                child: _buildRecommendationsContent(recommendations),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsContent(String content) {
    return SelectableText(
      content,
      style: const TextStyle(
        fontSize: 14,
        height: 1.5,
      ),
    );
  }
}