import 'package:flutter/material.dart';
import 'package:soil_monitoring_app/presentation/widgets/dashboard/dashboard_card.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Soil Monitoring Dashboard'),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            DashboardCard(
              title: 'Live Data',
              icon: Icons.monitor_heart,
              color: Colors.blue,
              onTap: () => Navigator.pushNamed(context, '/live_data'),
            ),
            DashboardCard(
              title: 'Past Data',
              icon: Icons.history,
              color: Colors.orange,
              onTap: () => Navigator.pushNamed(context, '/past_data'),
            ),
            DashboardCard(
              title: 'Soil Report',
              icon: Icons.analytics,
              color: Colors.purple,
              onTap: () => Navigator.pushNamed(context, '/report'),
            ),
            DashboardCard(
              title: 'Recommendations',
              icon: Icons.eco,
              color: Colors.green,
              onTap: () => Navigator.pushNamed(context, '/recommendations'),
            ),
          ],
        ),
      ),
    );
  }
}