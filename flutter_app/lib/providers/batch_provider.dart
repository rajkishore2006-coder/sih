import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';
import '../services/offline_sync_service.dart';
import '../services/storage_service.dart';

class OnionBatchProvider extends ChangeNotifier {
  final StorageService _storageService;
  final ApiService _apiService;
  final OfflineSyncService _offlineSyncService;
  final ConnectivityService _connectivityService;

  List<OnionBatch> _batches = [];
  List<OnionInspection> _inspections = [];
  bool _isLoading = false;

  List<OnionBatch> get batches => _batches;
  List<OnionInspection> get inspections => _inspections;
  bool get isLoading => _isLoading;
  int get pendingSyncCount => _offlineSyncService.getPendingItemsCount();

  OnionBatchProvider(
    this._storageService,
    this._apiService,
    this._offlineSyncService,
    this._connectivityService,
  ) {
    loadLocalData();
  }

  void loadLocalData() {
    _batches = _storageService.getAllBatches();
    _inspections = _storageService.getAllInspections();

    // Seed default APMC Mandi batches if empty
    if (_batches.isEmpty) {
      _seedDefaultBatches();
    }

    notifyListeners();
  }

  void _seedDefaultBatches() {
    final now = DateTime.now();
    final seeds = [
      OnionBatch(
        id: 'BATCH-2026-NSK-01',
        batchNumber: 'LOT-NSK-2026-089',
        farmerName: 'Ramesh Balasaheb Patil',
        farmerPhone: '+91 98231 44510',
        mandiLocation: 'Lasalgaon APMC, Nashik',
        onionVariety: 'Nashik Red (Rabi)',
        harvestDate: '2026-03-15',
        weightQuintals: 42.5,
        bagCount: 85,
        status: 'certified',
        createdAt: now.subtract(const Duration(days: 2)),
        latestGrade: 'Grade A',
        qrCodeData: 'ONIONSURE:LOT-NSK-2026-089',
      ),
      OnionBatch(
        id: 'BATCH-2026-PNE-02',
        batchNumber: 'LOT-PNE-2026-104',
        farmerName: 'Suresh Tukaram Shinde',
        farmerPhone: '+91 94220 18923',
        mandiLocation: 'Market Yard, Pune',
        onionVariety: 'Gavran Red',
        harvestDate: '2026-03-18',
        weightQuintals: 31.0,
        bagCount: 62,
        status: 'pending',
        createdAt: now.subtract(const Duration(hours: 18)),
        qrCodeData: 'ONIONSURE:LOT-PNE-2026-104',
      ),
      OnionBatch(
        id: 'BATCH-2026-AHM-03',
        batchNumber: 'LOT-AHM-2026-056',
        farmerName: 'Anil Kisan Gaikwad',
        farmerPhone: '+91 98902 33411',
        mandiLocation: 'Rahata APMC, Ahmednagar',
        onionVariety: 'Bhima Super',
        harvestDate: '2026-03-20',
        weightQuintals: 58.0,
        bagCount: 116,
        status: 'certified',
        createdAt: now.subtract(const Duration(hours: 6)),
        latestGrade: 'Grade B',
        qrCodeData: 'ONIONSURE:LOT-AHM-2026-056',
      ),
    ];

    for (final b in seeds) {
      _storageService.saveBatch(b);
    }
    _batches = seeds;
  }

  Future<void> createBatch({
    required String batchNumber,
    required String farmerName,
    required String farmerPhone,
    required String mandiLocation,
    required String onionVariety,
    required double weightQuintals,
    required int bagCount,
    required String harvestDate,
  }) async {
    final newBatch = OnionBatch(
      id: const Uuid().v4(),
      batchNumber: batchNumber,
      farmerName: farmerName,
      farmerPhone: farmerPhone,
      mandiLocation: mandiLocation,
      onionVariety: onionVariety,
      weightQuintals: weightQuintals,
      bagCount: bagCount,
      harvestDate: harvestDate,
      createdAt: DateTime.now(),
      status: 'pending',
      qrCodeData: 'ONIONSURE:$batchNumber',
    );

    await _storageService.saveBatch(newBatch);
    _batches.insert(0, newBatch);
    notifyListeners();

    if (_connectivityService.isOnline) {
      final ok = await _apiService.syncBatch(newBatch);
      if (!ok) {
        await _storageService.queuePendingSync(
          entityType: 'batch',
          entityId: newBatch.id,
          payload: newBatch.toJson(),
        );
      }
    } else {
      await _storageService.queuePendingSync(
        entityType: 'batch',
        entityId: newBatch.id,
        payload: newBatch.toJson(),
      );
    }
    notifyListeners();
  }

  Future<void> certifyInspection({
    required OnionBatch batch,
    required HeapAnalysisResult analysis,
    required String assignedGrade,
    required double sampleWeightKg,
    required String notes,
    required String inspectorName,
    required String inspectorId,
    String? imageBase64,
  }) async {
    final randSuffix = 1000 + (DateTime.now().millisecondsSinceEpoch % 9000);
    final token = 'VERIF-NSK-$randSuffix-${assignedGrade[0].toUpperCase()}';

    final inspection = OnionInspection(
      id: 'INSP-2026-$randSuffix',
      batchId: batch.id,
      batchNumber: batch.batchNumber,
      inspectorName: inspectorName.isNotEmpty ? inspectorName : 'Dr. V. K. Deshmukh',
      inspectorId: inspectorId.isNotEmpty ? inspectorId : 'INS-MH-704',
      timestamp: DateTime.now().toIso8601String(),
      analysis: analysis,
      assignedGrade: assignedGrade,
      sampleWeightKg: sampleWeightKg,
      notes: notes.isNotEmpty ? notes : 'Verified via computer vision heap analysis.',
      verificationToken: token,
      imageBase64: imageBase64,
      isSynced: false,
    );

    await _storageService.saveInspection(inspection);
    _inspections.insert(0, inspection);

    final updatedBatch = OnionBatch(
      id: batch.id,
      batchNumber: batch.batchNumber,
      farmerName: batch.farmerName,
      farmerPhone: batch.farmerPhone,
      mandiLocation: batch.mandiLocation,
      onionVariety: batch.onionVariety,
      harvestDate: batch.harvestDate,
      weightQuintals: batch.weightQuintals,
      bagCount: batch.bagCount,
      createdAt: batch.createdAt,
      status: assignedGrade == 'Reject' ? 'rejected' : 'certified',
      latestGrade: assignedGrade,
      qrCodeData: batch.qrCodeData,
    );
    await _storageService.saveBatch(updatedBatch);

    final idx = _batches.indexWhere((b) => b.id == batch.id);
    if (idx != -1) {
      _batches[idx] = updatedBatch;
    }

    if (_connectivityService.isOnline) {
      await _apiService.syncInspection(inspection);
    } else {
      await _storageService.queuePendingSync(
        entityType: 'inspection',
        entityId: inspection.id,
        payload: inspection.toJson(),
      );
    }

    notifyListeners();
  }

  Future<HeapAnalysisResult> runHeapAnalysis({
    required File imageFile,
    required String batchId,
    double sampleWeightKg = 15.0,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _apiService.analyzeHeapImage(
        imageFile: imageFile,
        sampleWeightKg: sampleWeightKg,
      );
      return res;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> triggerSync() async {
    _isLoading = true;
    notifyListeners();
    await _offlineSyncService.syncPendingData();
    _isLoading = false;
    notifyListeners();
  }
}
