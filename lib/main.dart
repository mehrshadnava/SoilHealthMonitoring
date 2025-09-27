import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:soil_monitoring_app/presentation/providers/soil_provider.dart';
import 'package:soil_monitoring_app/presentation/providers/auth_provider.dart';
import 'package:soil_monitoring_app/presentation/providers/theme_provider.dart';
import 'package:soil_monitoring_app/core/themes/app_theme.dart';
import 'package:soil_monitoring_app/routes/route_generator.dart';
import 'package:soil_monitoring_app/presentation/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Skip Firebase initialization completely for now
  // This will allow the app to run in demo mode
  print('Running in demo mode without Firebase');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SoilProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Soil Monitoring App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashPage(),
            onGenerateRoute: RouteGenerator.generateRoute,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}