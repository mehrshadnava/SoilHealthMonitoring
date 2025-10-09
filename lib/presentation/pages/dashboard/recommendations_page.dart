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
                
                // Report Generation Section
                _buildReportSection(soilProvider),
                
                const SizedBox(height: 20),
                
                // Generated Recommendations
                if (soilProvider.currentRecommendations != null)
                  _buildGeneratedReport(soilProvider.currentRecommendations!, soilProvider),
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
              _buildDataRow('Soil Moisture', '${soilProvider.latestReading!.soilMoisturePercent.toStringAsFixed(1)}%'),
              _buildDataRow('Temperature', '${soilProvider.latestReading!.temperature.toStringAsFixed(1)}°C'),
              _buildDataRow('Humidity', '${soilProvider.latestReading!.humidity.toStringAsFixed(1)}%'),
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
              'Generate Soil Recommendations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF658C83),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Get AI-powered recommendations for optimal crop growth based on your current soil conditions.',
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
                      'Generating recommendations...',
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

  Widget _buildGeneratedReport(String recommendations, SoilProvider soilProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Soil Report',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Comprehensive Report',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF658C83),
                        ),
                      ),
                    ],
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
            
            // Divider line
            Container(
              height: 1,
              color: Colors.grey[300],
              margin: const EdgeInsets.symmetric(vertical: 8),
            ),

            // Soil Health Report Header
            const Text(
              'Soil Health Report - 6/10/2025',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Generated: ${DateTime.now().toString().split(' ')[0]} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 16),
            
            // Main content with styled cards
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                child: _buildStyledReportCards(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledReportCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Introduction text
        const Text(
          'Excessive rainfall and poor soil structure can devastate crops quickly. Implementing these preventive measures is crucial for long-term soil health and crop yield.',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Preventive Measures Card
        _buildRecommendationCard(
          icon: Icons.eco,
          title: 'Preventive Measures:',
          content: 'Disease-resistant crop varieties, optimal planting techniques, and regular soil testing are crucial for a healthy harvest.',
        ),
        
        const SizedBox(height: 12),
        
        // Drainage Management Card
        _buildRecommendationCard(
          icon: Icons.water_drop,
          title: 'Drainage Management:',
          content: 'Utilize effective biological fungicides and cultural practices to reduce disease pressure from excess moisture.',
        ),
        
        const SizedBox(height: 12),
        
        // Nutrient Leaching Card
        _buildRecommendationCard(
          icon: Icons.wb_sunny,
          title: 'Nutrient Leaching:',
          content: 'Optimize irrigation, apply organic fertilizers, and incorporate cover crops to prevent nutrient loss from the soil.',
        ),
        
        const SizedBox(height: 12),
        
        // Soil Improvement Card
        _buildRecommendationCard(
          icon: Icons.landscape,
          title: 'Soil Improvement:',
          content: 'During humid seasons, consider adding organic matter and applying tile drainage solutions to improve aeration and nutrient retention.',
        ),
        
        const SizedBox(height: 12),
        
        // Seasonal Considerations Card
        _buildRecommendationCard(
          icon: Icons.calendar_today,
          title: 'Seasonal Considerations:',
          content: 'During warm, humid seasons, pay close attention to soil moisture levels and pest pressure to protect sensitive crops.',
        ),
      ],
    );
  }

  Widget _buildRecommendationCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F4), // Light green background
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF658C83),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF658C83),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}