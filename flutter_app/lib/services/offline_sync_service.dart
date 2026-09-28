import 'dart:io';
import '../models/models.dart';
import 'api_service.dart';
import 'connectivity_service.dart';
import 'storage_service.dart';

class OfflineSyncService {
  final StorageService _storageService;
  final ApiService _apiService;
  final ConnectivityService _connectivityService;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  OfflineSyncService(
    this._storageService,
    this._apiService,
    this._connectivityService,
  ) {
    // Automatically trigger sync when coming back online
    _connectivityService.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        syncPendingData();
      }
    });
  }

  int getPendingItemsCount() {
    return _storageService.getPendingSyncItems().length +
        _storageService.getPendingAiQueue().length;
  }

  /// Process both sync queues:
  /// 1. Upload queued offline heap photos for AI analysis
  /// 2. Push offline created batches and inspections to central APMC database
  Future<void> syncPendingData() async {
    if (_isSyncing || !_connectivityService.isOnline) return;
    _isSyncing = true;

    try {
      // 1. Process Offline AI Queue
      final pendingAi = _storageService.getPendingAiQueue();
      for (final item in pendingAi) {
        final queueId = item['queue_id'] as String;
        final imagePath = item['image_path'] as String;
        final sampleWeight = (item['sample_weight_kg'] as num).toDouble();

        final file = File(imagePath);
        if (await file.exists()) {
          try {
            await _apiService.analyzeHeapImage(
              imageFile: file,
              sampleWeightKg: sampleWeight,
            );
            await _storageService.removePendingAi(queueId);
          } catch (_) {
            // Keep in queue for next retry
          }
        } else {
          // File deleted or missing, remove orphaned queue entry
          await _storageService.removePendingAi(queueId);
        }
      }

      // 2. Process Pending Entity Sync Queue (Batches & Inspections)
      final pendingEntities = _storageService.getPendingSyncItems();
      for (final item in pendingEntities) {
        final syncId = item['sync_id'] as String;
        final entityType = item['entity_type'] as String;
        final payload = item['payload'] as Map<String, dynamic>;

        bool success = false;
        if (entityType == 'batch') {
          final batch = OnionBatch.fromJson(payload);
          success = await _apiService.syncBatch(batch);
        } else if (entityType == 'inspection') {
          final inspection = OnionInspection.fromJson(payload);
          success = await _apiService.syncInspection(inspection);
        }

        if (success) {
          await _storageService.removePendingSync(syncId);
        }
      }
    } finally {
      _isSyncing = false;
    }
  }
}
