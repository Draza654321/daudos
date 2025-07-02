import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'database_service.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseService _databaseService = DatabaseService();
  
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _syncTimer;
  bool _isInitialized = false;

  // Initialize Firebase
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await Firebase.initializeApp();
    _isInitialized = true;
    
    // Start connectivity monitoring
    _startConnectivityMonitoring();
    
    // Start periodic sync
    _startPeriodicSync();
  }

  // Authentication
  Future<User?> signInAnonymously() async {
    try {
      final UserCredential result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      print('Anonymous sign-in failed: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;

  // Connectivity monitoring
  void _startConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none && isSignedIn) {
        _syncData();
      }
    });
  }

  // Periodic sync
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(Duration(minutes: 15), (timer) {
      if (isSignedIn) {
        _syncData();
      }
    });
  }

  // Main sync function
  Future<void> _syncData() async {
    if (!isSignedIn) return;
    
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) return;

      // Get pending sync operations
      final pendingOps = await _databaseService.getPendingSyncOperations();
      
      for (final op in pendingOps) {
        await _processSyncOperation(op);
      }

      // Clean up old sync records
      await _databaseService.clearOldSyncRecords();
    } catch (e) {
      print('Sync failed: $e');
    }
  }

  // Process individual sync operation
  Future<void> _processSyncOperation(Map<String, dynamic> operation) async {
    try {
      final String tableName = operation['tableName'];
      final String recordId = operation['recordId'];
      final String operationType = operation['operation'];
      final Map<String, dynamic> data = jsonDecode(operation['data']);

      final DocumentReference docRef = _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection(tableName)
          .doc(recordId);

      switch (operationType) {
        case 'INSERT':
        case 'UPDATE':
          await docRef.set(data, SetOptions(merge: true));
          break;
        case 'DELETE':
          await docRef.delete();
          break;
      }

      // Mark as synced
      await _databaseService.markSyncCompleted(operation['id']);
    } catch (e) {
      print('Failed to process sync operation: $e');
    }
  }

  // Backup all data to Firebase
  Future<void> backupAllData(String userId) async {
    if (!isSignedIn) return;

    try {
      final tables = [
        'users', 'moods', 'tasks', 'habits', 'habit_entries',
        'goals', 'mind_gym_sessions', 'brain_dump_entries',
        'settings', 'daily_analytics'
      ];

      for (final table in tables) {
        final data = await _databaseService.query(table, where: 'userId = ?', whereArgs: [userId]);
        
        final batch = _firestore.batch();
        for (final record in data) {
          final docRef = _firestore
              .collection('users')
              .doc(currentUser!.uid)
              .collection(table)
              .doc(record['id']);
          batch.set(docRef, record);
        }
        await batch.commit();
      }
    } catch (e) {
      print('Backup failed: $e');
      rethrow;
    }
  }

  // Restore data from Firebase
  Future<void> restoreAllData(String userId) async {
    if (!isSignedIn) return;

    try {
      final tables = [
        'users', 'moods', 'tasks', 'habits', 'habit_entries',
        'goals', 'mind_gym_sessions', 'brain_dump_entries',
        'settings', 'daily_analytics'
      ];

      for (final table in tables) {
        final QuerySnapshot snapshot = await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .collection(table)
            .get();

        for (final doc in snapshot.docs) {
          await _databaseService.insert(table, doc.data() as Map<String, dynamic>);
        }
      }
    } catch (e) {
      print('Restore failed: $e');
      rethrow;
    }
  }

  // Sync specific record
  Future<void> syncRecord(String tableName, String recordId, Map<String, dynamic> data, String operation) async {
    await _databaseService.addToSyncQueue(operation, tableName, recordId, data);
    
    // Try immediate sync if online
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none && isSignedIn) {
      await _syncData();
    }
  }

  // Get last sync timestamp
  Future<DateTime?> getLastSyncTime() async {
    if (!isSignedIn) return null;
    
    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('metadata')
          .doc('sync_info')
          .get();
      
      if (doc.exists) {
        final timestamp = doc.data()?['lastSync'];
        return timestamp != null ? (timestamp as Timestamp).toDate() : null;
      }
    } catch (e) {
      print('Failed to get last sync time: $e');
    }
    return null;
  }

  // Update last sync timestamp
  Future<void> updateLastSyncTime() async {
    if (!isSignedIn) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('metadata')
          .doc('sync_info')
          .set({
        'lastSync': FieldValue.serverTimestamp(),
        'userId': currentUser!.uid,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Failed to update last sync time: $e');
    }
  }

  // Manual sync trigger
  Future<void> manualSync() async {
    await _syncData();
    await updateLastSyncTime();
  }

  // Check if sync is needed
  Future<bool> isSyncNeeded() async {
    final pendingOps = await _databaseService.getPendingSyncOperations();
    return pendingOps.isNotEmpty;
  }

  // Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
  }
}

