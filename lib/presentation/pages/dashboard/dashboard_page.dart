import 'package:flutter/material.dart';
import 'package:soil_monitoring_app/presentation/pages/dashboard/recommendations_page.dart';
import 'package:soil_monitoring_app/presentation/widgets/dashboard/dashboard_card.dart';


class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Soil Monitoring Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF648b81),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Welcome Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF648b81),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to Soil Monitor',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Monitor your soil health and get smart recommendations',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Section Header
            const Text(
              'Soil Monitoring Features',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),

            // First row - 2 widgets
            Row(
              children: [
                Expanded(
                  child: DashboardCard(
                    title: 'Live Data',
                    icon: Icons.monitor_heart,
                    color: const Color(0xFF648b81),
                    onTap: () => Navigator.pushNamed(context, '/live_data'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DashboardCard(
                    title: 'Past Data',
                    icon: Icons.history,
                    color: const Color(0xFF648b81),
                    onTap: () => Navigator.pushNamed(context, '/past_data'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Second row - 2 widgets
            Row(
              children: [
                Expanded(
                  child: DashboardCard(
                    title: 'Soil Report',
                    icon: Icons.analytics,
                    color: const Color(0xFF648b81),
                    onTap: () => Navigator.pushNamed(context, '/report'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DashboardCard(
                    title: 'Recommendations',
                    icon: Icons.eco,
                    color: const Color(0xFF648b81),
                    onTap: () {
                      // FIXED: Navigate to RecommendationsPage instead of showing coming soon
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecommendationsPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}