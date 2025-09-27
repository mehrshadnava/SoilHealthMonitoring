import 'package:flutter/material.dart';
import 'package:soil_monitoring_app/presentation/pages/splash_page.dart';
import 'package:soil_monitoring_app/presentation/pages/auth/login_page.dart';
import 'package:soil_monitoring_app/presentation/pages/auth/register_page.dart';
import 'package:soil_monitoring_app/presentation/pages/dashboard/dashboard_page.dart';
import 'package:soil_monitoring_app/presentation/pages/dashboard/live_data_page.dart';
import 'package:soil_monitoring_app/presentation/pages/dashboard/past_data_page.dart';
import 'package:soil_monitoring_app/presentation/pages/dashboard/report_page.dart';
import 'package:soil_monitoring_app/presentation/pages/dashboard/recommendations_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => SplashPage());
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginPage());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegisterPage());
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => DashboardPage());
      case '/live_data':
        return MaterialPageRoute(builder: (_) => LiveDataPage());
      case '/past_data':
        return MaterialPageRoute(builder: (_) => PastDataPage());
      case '/report':
        return MaterialPageRoute(builder: (_) => ReportPage());
      case '/recommendations':
        return MaterialPageRoute(builder: (_) => RecommendationsPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}