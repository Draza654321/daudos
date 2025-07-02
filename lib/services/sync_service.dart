import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'database_service.dart';
import 'firebase_service.dart';
import 'user_repository.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final DatabaseService _databaseService = DatabaseService();
  final FirebaseService _firebaseService = FirebaseService();
  final UserRepository _userRepository = UserRepository();
  
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _periodicSyncTimer;
  bool _isSyncing = false;
  
  final StreamController<SyncStatus> _syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  // Initialize sync service
  Future<void> initialize() async {
    await _firebaseService.initialize();
    _startConnectivityMonitoring();
    _startPeriodicSync();
  }

  // Start monitoring connectivity changes
  void _startConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none && _firebaseService.isSignedIn) {
        _triggerSync();
      }
    });
  }

  // Start periodic sync (every 15 minutes)
  void _startPeriodicSync() {
    _periodicSyncTimer = Timer.periodic(Duration(minutes: 15), (timer) {
      if (_firebaseService.isSignedIn) {
        _triggerSync();
      }
    });
  }

  // Trigger sync if not already syncing
  void _triggerSync() {
    if (!_isSyncing) {
      syncData();
    }
  }

  // Main sync function
  Future<void> syncData() async {
    if (_isSyncing || !_firebaseService.isSignedIn) return;

    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);

    try {
      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        _syncStatusController.add(SyncStatus.offline);
        return;
      }

      // Get current user
      final user = await _userRepository.getCurrentUser();
      if (user == null) {
        _syncStatusController.add(SyncStatus.error);
        return;
      }

      // Sync pending operations
      await _syncPendingOperations();

      // Update last sync time
      await _firebaseService.updateLastSyncTime();

      _syncStatusController.add(SyncStatus.completed);
    } catch (e) {
      print('Sync failed: $e');
      _syncStatusController.add(SyncStatus.error);
    } finally {
      _isSyncing = false;
    }
  }

  // Sync pending operations from local queue
  Future<void> _syncPendingOperations() async {
    final pendingOps = await _databaseService.getPendingSyncOperations();
    
    for (final op in pendingOps) {
      try {
        await _firebaseService.manualSync();
        await _databaseService.markSyncCompleted(op['id']);
      } catch (e) {
        print('Failed to sync operation ${op['id']}: $e');
        // Continue with other operations
      }
    }
  }

  // Force full backup to Firebase
  Future<void> forceBackup() async {
    if (!_firebaseService.isSignedIn) {
      throw Exception('Not signed in to Firebase');
    }

    _syncStatusController.add(SyncStatus.backing_up);

    try {
      final user = await _userRepository.getCurrentUser();
      if (user == null) {
        throw Exception('No user found');
      }

      await _firebaseService.backupAllData(user.id);
      _syncStatusController.add(SyncStatus.backup_completed);
    } catch (e) {
      _syncStatusController.add(SyncStatus.error);
      rethrow;
    }
  }

  // Force full restore from Firebase
  Future<void> forceRestore() async {
    if (!_firebaseService.isSignedIn) {
      throw Exception('Not signed in to Firebase');
    }

    _syncStatusController.add(SyncStatus.restoring);

    try {
      final user = await _userRepository.getCurrentUser();
      if (user == null) {
        throw Exception('No user found');
      }

      await _firebaseService.restoreAllData(user.id);
      _syncStatusController.add(SyncStatus.restore_completed);
    } catch (e) {
      _syncStatusController.add(SyncStatus.error);
      rethrow;
    }
  }

  // Check if sync is needed
  Future<bool> isSyncNeeded() async {
    return await _firebaseService.isSyncNeeded();
  }

  // Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    return await _firebaseService.getLastSyncTime();
  }

  // Manual sync trigger
  Future<void> manualSync() async {
    await syncData();
  }

  // Enable/disable automatic sync
  void setAutoSyncEnabled(bool enabled) {
    if (enabled) {
      _startPeriodicSync();
    } else {
      _periodicSyncTimer?.cancel();
    }
  }

  // Get sync status
  SyncStatus get currentStatus {
    if (_isSyncing) return SyncStatus.syncing;
    if (!_firebaseService.isSignedIn) return SyncStatus.offline;
    return SyncStatus.idle;
  }

  // Add this to satisfy build references
  Future<void> performFullSync() async {
    await manualSync(); // or: await syncData();
  }

  // Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _periodicSyncTimer?.cancel();
    _syncStatusController.close();
    _firebaseService.dispose();
  }
}

enum SyncStatus {
  idle,
  syncing,
  completed,
  error,
  offline,
  backing_up,
  backup_completed,
  restoring,
  restore_completed,
}

