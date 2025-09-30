// lib/screens/recommendation_screen.dart

import 'package:flutter/material.dart';
import 'package:soil_health_monitoring/lib/core/services/ai_service.dart';
import 'package:soil_health_monitoring/lib/core/services/firebase_service.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({Key? key}) : super(key: key);

  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AIService _aiService = AIService();
  Map<String, dynamic>? _recommendationData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAndGenerateRecommendations();
  }

  Future<void> _fetchAndGenerateRecommendations() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final currentReading = await _firebaseService.getLatestSoilData();
      if (currentReading == null) {
        throw Exception("No live sensor data is available.");
      }
      final recommendations = await _aiService.generateRecommendations(
        currentReading: currentReading.toJson(),
        cropContext: "Chili",
      );
      setState(() { _recommendationData = recommendations; });
    } catch (e) {
      setState(() { _error = "Failed to get recommendations:\n${e.toString()}"; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Improvement Plan'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchAndGenerateRecommendations)],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center)));
    if (_recommendationData == null) return const Center(child: Text("No recommendations could be generated."));

    final deficiencies = List<String>.from(_recommendationData!['identified_deficiencies'] ?? []);
    final fertilizers = List<Map<String, dynamic>>.from(_recommendationData!['fertilizer_recommendations'] ?? []);
    final guide = List<String>.from(_recommendationData!['step_by_step_guide'] ?? []);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionCard(
          title: "Identified Deficiencies",
          icon: Icons.error_outline,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: deficiencies.map((item) => Text('• $item', style: Theme.of(context).textTheme.bodyLarge)).toList(),
          ),
        ),
        _buildSectionCard(
          title: "Fertilizer Recommendations",
          icon: Icons.science,
          child: Column(
            children: fertilizers.map((fert) => ListTile(
              title: Text(fert['name'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(fert['purpose'] ?? 'N/A'),
              trailing: Text("${fert['application_rate_kg_per_hectare'] ?? 'N/A'} kg/ha"),
            )).toList(),
          )
        ),
        _buildSectionCard(
          title: "Step-by-Step Guide",
          icon: Icons.checklist,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: guide.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text("${entry.key + 1}. ${entry.value}", style: Theme.of(context).textTheme.bodyLarge),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
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
            child,
          ],
        ),
      ),
    );
  }
}