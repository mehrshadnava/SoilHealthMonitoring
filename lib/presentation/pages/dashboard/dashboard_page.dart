import 'package:flutter/material.dart';
import 'package:soil_monitoring_app/presentation/pages/dashboard/recommendations_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF628c80), // New background color
      appBar: AppBar(
        title: const Text(
          'Soil Monitoring Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF628c80), // Match app bar with background
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Welcome Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to Soil Monitor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Monitor your soil health and get smart recommendations',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Header
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Text(
                          'Soil Monitoring Features',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Grid Layout - 2x2 with even spacing
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              // First row - Expanded to take equal space
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildFeatureCard(
                                        title: 'Live Data',
                                        subtitle: 'Real-time sensor readings',
                                        imagePath: 'assets/images/live_data.jpg',
                                        onTap: () => Navigator.pushNamed(context, '/live_data'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildFeatureCard(
                                        title: 'Past Data',
                                        subtitle: 'View historical records',
                                        imagePath: 'assets/images/past_data.jpg',
                                        onTap: () => Navigator.pushNamed(context, '/past_data'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Second row - Expanded to take equal space
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildFeatureCard(
                                        title: 'Soil Report',
                                        subtitle: 'Detailed health analysis',
                                        imagePath: 'assets/images/soil_report.jpg',
                                        onTap: () => Navigator.pushNamed(context, '/report'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildFeatureCard(
                                        title: 'Recommendations',
                                        subtitle: 'Smart tips for your crops',
                                        imagePath: 'assets/images/recommendations.jpg',
                                        onTap: () {
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
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Removed fixed height - now expands to fill available space
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF628c80).withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20), // Increased padding for larger cards
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Larger Image Container
              Container(
                width: 70, // Increased size
                height: 70, // Increased size
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16), // Slightly larger radius
                  color: const Color(0xFF628c80).withOpacity(0.1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to icon if image fails to load
                      return Icon(
                        _getIconForTitle(title),
                        color: const Color(0xFF628c80),
                        size: 32, // Larger icon
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16), // Increased spacing
              
              // Title with larger font
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18, // Increased font size
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6), // Increased spacing
              
              // Subtitle with larger font
              Flexible(
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14, // Increased font size
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Live Data':
        return Icons.monitor_heart;
      case 'Past Data':
        return Icons.history;
      case 'Soil Report':
        return Icons.analytics;
      case 'Recommendations':
        return Icons.eco;
      default:
        return Icons.widgets;
    }
  }
}