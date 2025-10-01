// ignore_for_file: unnecessary_cast

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Real Firebase Authentication methods
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _getAuthErrorMessage(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<User?> registerWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _getAuthErrorMessage(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please contact support.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if user is logged in
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // UPDATED: Soil Reading methods for Realtime Database
  Stream<List<Map<String, dynamic>>> getSoilReadings() {
    return _database
        .child('sensorData')
        .orderByKey()
        .limitToLast(50)
        .onValue
        .map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      final List<Map<String, dynamic>> readings = [];
      
      if (data != null) {
        data.forEach((key, value) {
          try {
            final readingData = Map<String, dynamic>.from(value);
            readingData['id'] = key.toString();
            readings.add(readingData);
          } catch (e) {
            print('Error parsing reading $key: $e');
          }
        });
      }
      
      // Sort by timestamp descending (newest first)
      readings.sort((a, b) {
        final timestampA = _getTimestampFromData(a);
        final timestampB = _getTimestampFromData(b);
        return timestampB.compareTo(timestampA);
      });
      return readings;
    });
  }

  // UPDATED: Get latest reading stream
  Stream<Map<String, dynamic>?> getLatestReadingStream() {
    return _database
        .child('sensorData')
        .orderByKey()
        .limitToLast(1)
        .onValue
        .map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      
      if (data != null && data.isNotEmpty) {
        final entry = data.entries.first;
        try {
          final readingData = Map<String, dynamic>.from(entry.value);
          readingData['id'] = entry.key.toString();
          return readingData;
        } catch (e) {
          print('Error parsing latest reading: $e');
        }
      }
      return null;
    });
  }

  // UPDATED: Get historical readings
  Future<List<Map<String, dynamic>>> getHistoricalReadings(DateTime start, DateTime end) async {
    final startTimestamp = start.millisecondsSinceEpoch.toString();
    final endTimestamp = end.millisecondsSinceEpoch.toString();
    
    final snapshot = await _database
        .child('sensorData')
        .orderByKey()
        .startAt(startTimestamp)
        .endAt(endTimestamp)
        .once();

    final Map<dynamic, dynamic>? data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
    final List<Map<String, dynamic>> readings = [];
    
    if (data != null) {
      data.forEach((key, value) {
        try {
          final readingData = Map<String, dynamic>.from(value);
          readingData['id'] = key.toString();
          readings.add(readingData);
        } catch (e) {
          print('Error parsing historical reading $key: $e');
        }
      });
    }
    
    // Sort by timestamp descending
    readings.sort((a, b) {
      final timestampA = _getTimestampFromData(a);
      final timestampB = _getTimestampFromData(b);
      return timestampB.compareTo(timestampA);
    });
    return readings;
  }

  // UPDATED: Get single latest reading
  Future<Map<String, dynamic>?> getLatestReading() async {
    final snapshot = await _database
        .child('sensorData')
        .orderByKey()
        .limitToLast(1)
        .once();

    final Map<dynamic, dynamic>? data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
    
    if (data != null && data.isNotEmpty) {
      final entry = data.entries.first;
      try {
        final readingData = Map<String, dynamic>.from(entry.value);
        readingData['id'] = entry.key.toString();
        return readingData;
      } catch (e) {
        print('Error parsing latest reading: $e');
      }
    }
    return null;
  }

  // NEW: Get latest soil data (alias for getLatestReading)
  Future<Map<String, dynamic>?> getLatestSoilData() async {
    return await getLatestReading();
  }

  // NEW: Get historical average
  Future<Map<String, dynamic>> getHistoricalAverage(int days) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));
      
      final historicalReadings = await getHistoricalReadings(startDate, endDate);
      
      if (historicalReadings.isEmpty) {
        return {};
      }

      // Calculate averages for numeric fields
      Map<String, dynamic> averages = {};
      Map<String, double> sums = {};
      Map<String, int> counts = {};

      for (var reading in historicalReadings) {
        reading.forEach((key, value) {
          if (value is num) {
            sums[key] = (sums[key] ?? 0.0) + value.toDouble();
            counts[key] = (counts[key] ?? 0) + 1;
          }
        });
      }

      // Calculate averages
      sums.forEach((key, sum) {
        final count = counts[key] ?? 1;
        averages[key] = sum / count;
      });

      // Add metadata
      averages['_totalReadings'] = historicalReadings.length;
      averages['_periodDays'] = days;
      averages['_fromDate'] = startDate.toIso8601String();
      averages['_toDate'] = endDate.toIso8601String();

      return averages;
    } catch (e) {
      print('Error calculating historical average: $e');
      return {};
    }
  }

  // Helper to get timestamp from data
  DateTime _getTimestampFromData(Map<String, dynamic> data) {
    try {
      // Try to get timestamp from the data
      if (data['timestamp'] != null) {
        if (data['timestamp'] is int) {
          return DateTime.fromMillisecondsSinceEpoch(data['timestamp']);
        } else if (data['timestamp'] is String) {
          return DateTime.parse(data['timestamp']);
        }
      }
      // Fallback: use the key as timestamp (assuming key is timestamp)
      if (data['id'] != null) {
        return DateTime.fromMillisecondsSinceEpoch(int.parse(data['id']));
      }
    } catch (e) {
      print('Error parsing timestamp: $e');
    }
    return DateTime.now();
  }

  // Add soil reading (if needed)
  Future<void> addSoilReading(Map<String, dynamic> reading) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    await _database
        .child('sensorData')
        .child(timestamp)
        .set(reading);
  }
}