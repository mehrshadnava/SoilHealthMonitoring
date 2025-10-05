import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ========== AUTHENTICATION METHODS ==========
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

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // ========== LIVE DATA METHODS ==========
  
  // Get the latest entry from ALL sensors
  Stream<Map<String, dynamic>?> getLatestDataStream() {
    return _database
        .child('sensorData')
        .orderByKey()
        .limitToLast(1)
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      
      print('Latest data stream: $data'); // Debug
      
      if (data == null) {
        return null;
      }

      if (data is Map) {
        final entries = data.entries;
        if (entries.isNotEmpty) {
          final latestEntry = entries.first;
          final timestampKey = latestEntry.key.toString();
          final readingData = latestEntry.value;
          
          if (readingData is Map) {
            final reading = Map<String, dynamic>.from(readingData);
            reading['sensorId'] = 'default'; // Since you don't have multiple sensors
            reading['timestampKey'] = timestampKey;
            print('Latest reading: $reading'); // Debug
            return reading;
          }
        }
      }
      
      return null;
    });
  }

  // Get latest data (for initial load)
  Future<Map<String, dynamic>?> getLatestData() async {
    try {
      final snapshot = await _database
          .child('sensorData')
          .orderByKey()
          .limitToLast(1)
          .once();

      final data = snapshot.snapshot.value;
      
      print('Latest data fetch: $data'); // Debug
      
      if (data is Map) {
        final entries = data.entries;
        if (entries.isNotEmpty) {
          final latestEntry = entries.first;
          final timestampKey = latestEntry.key.toString();
          final readingData = latestEntry.value;
          
          if (readingData is Map) {
            final reading = Map<String, dynamic>.from(readingData);
            reading['sensorId'] = 'default';
            reading['timestampKey'] = timestampKey;
            return reading;
          }
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting latest data: $e');
      return null;
    }
  }

  // Get list of available sensors
  Stream<List<String>> getAvailableSensorsStream() {
    return _database
        .child('sensorData')
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      final List<String> sensorIds = [];
      
      if (data is Map) {
        // Since you have direct timestamps, return a single default sensor
        sensorIds.add('default');
      }
      
      return sensorIds;
    });
  }

  // ========== PAST DATA METHODS ==========

  // Get all sensor data for past data page - FIXED VERSION
  Stream<List<Map<String, dynamic>>> getAllSensorData() {
    return _database
        .child('sensorData')
        .orderByKey()
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      final List<Map<String, dynamic>> allData = [];
      
      print('Raw Firebase data: $data'); // Debug
      
      if (data is Map) {
        data.forEach((timestamp, readingData) {
          print('Processing timestamp: $timestamp, data: $readingData'); // Debug
          if (readingData is Map) {
            try {
              final reading = Map<String, dynamic>.from(readingData);
              reading['sensorId'] = 'default'; // Single sensor
              reading['timestampKey'] = timestamp.toString();
              allData.add(reading);
              print('Added reading: $reading'); // Debug
            } catch (e) {
              print('Error parsing reading $timestamp: $e');
            }
          }
        });
      }
      
      print('Total records found: ${allData.length}'); // Debug
      
      // Sort by timestamp descending (newest first)
      allData.sort((a, b) {
        final timestampA = int.tryParse(a['timestampKey'] ?? '0') ?? 0;
        final timestampB = int.tryParse(b['timestampKey'] ?? '0') ?? 0;
        return timestampB.compareTo(timestampA);
      });
      
      return allData;
    });
  }

  // Get data for a specific timestamp
  Future<Map<String, dynamic>?> getDataByTimestamp(String timestamp) async {
    try {
      final snapshot = await _database
          .child('sensorData')
          .child(timestamp)
          .once();

      final readingData = snapshot.snapshot.value;
      
      if (readingData is Map) {
        final reading = Map<String, dynamic>.from(readingData);
        reading['sensorId'] = 'default';
        reading['timestampKey'] = timestamp;
        return reading;
      }
      
      return null;
    } catch (e) {
      print('Error getting data by timestamp: $e');
      return null;
    }
  }
}