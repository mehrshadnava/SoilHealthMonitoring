class FirebaseService {
  FirebaseService(); // Simple constructor

  // Auth methods - demo mode
  Future<dynamic> signInWithEmail(String email, String password) async {
    // Demo mode - simulate successful login after delay
    await Future.delayed(const Duration(seconds: 2));
    return _createDemoUser();
  }

  Future<dynamic> registerWithEmail(String email, String password) async {
    // Demo mode
    await Future.delayed(const Duration(seconds: 2));
    return _createDemoUser();
  }

  Map<String, dynamic> _createDemoUser() {
    return {
      'uid': 'demo-user-123',
      'email': 'demo@example.com',
      'displayName': 'Demo User',
    };
  }

  // Soil Reading methods - demo data
  Stream<List<dynamic>> getSoilReadings() {
    // Return demo data stream that updates every 3 seconds
    return Stream.periodic(const Duration(seconds: 3), (count) {
      return _generateDemoReadings();
    });
  }

  List<Map<String, dynamic>> _generateDemoReadings() {
    final now = DateTime.now();
    return [
      {
        'id': 'demo-${now.millisecondsSinceEpoch}',
        'pH': 6.5 + (now.second % 10) * 0.1,
        'moisture': 40.0 + (now.second % 30),
        'temperature': 22.0 + (now.second % 15),
        'nitrogen': 25.0 + (now.second % 20),
        'phosphorus': 20.0 + (now.second % 15),
        'potassium': 180.0 + (now.second % 50),
        'electricalConductivity': 1.2 + (now.second % 10) * 0.1,
        'timestamp': now.toIso8601String(),
        'location': 'Demo Field A'
      }
    ];
  }

  Future<List<dynamic>> getHistoricalReadings(DateTime start, DateTime end) async {
    // Generate 30 days of demo historical data
    return _generateHistoricalDemoData();
  }

  List<Map<String, dynamic>> _generateHistoricalDemoData() {
    List<Map<String, dynamic>> data = [];
    DateTime now = DateTime.now();
    
    for (int i = 0; i < 30; i++) {
      DateTime date = now.subtract(Duration(days: i));
      data.add({
        'id': 'historical-demo-$i',
        'pH': 6.3 + (i % 8) * 0.2,
        'moisture': 35.0 + (i % 40),
        'temperature': 18.0 + (i % 20),
        'nitrogen': 20.0 + (i % 25),
        'phosphorus': 15.0 + (i % 20),
        'potassium': 150.0 + (i % 60),
        'electricalConductivity': 1.0 + (i % 8) * 0.2,
        'timestamp': date.toIso8601String(),
        'location': 'Demo Field A'
      });
    }
    
    return data;
  }

  Future<dynamic> getLatestReading() async {
    // Return latest demo reading
    return _generateDemoReadings().first;
  }

  Future<void> addSoilReading(Map<String, dynamic> reading) async {
    // In demo mode, just simulate success
    await Future.delayed(const Duration(milliseconds: 500));
    print('Demo: Soil reading added successfully');
  }
}