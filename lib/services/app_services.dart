import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:onion_quality_app/models/analysis_models.dart';
import 'package:onion_quality_app/models/batch_model.dart';
import 'package:onion_quality_app/models/inspection_model.dart';

class AppServices extends ChangeNotifier {
  static final AppServices instance = AppServices._internal();
  AppServices._internal() {
    _seedInitialData();
  }

  final List<OnionBatch> _batches = [];
  final List<OnionInspection> _inspections = [];

  List<OnionBatch> get batches => List.unmodifiable(_batches);
  List<OnionInspection> get inspections => List.unmodifiable(_inspections);

  int get totalBatches => _batches.length;
  int get inspectedBatchesCount =>
      _batches.where((b) => b.status != BatchStatus.pending).length;

  double get totalWeightQuintals =>
      _batches.fold(0.0, (acc, b) => acc + b.weightQuintals);

  double get averageGradeAPercentage {
    if (_inspections.isEmpty) return 72.5;
    final sum = _inspections.fold(
      0.0,
      (acc, ins) => acc + ins.analysis.grades.gradeAPercent,
    );
    return (sum / _inspections.length * 10).round() / 10.0;
  }

  OnionBatch? getBatchById(String id) {
    try {
      return _batches.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  List<OnionInspection> getInspectionsForBatch(String batchId) {
    return _inspections.where((i) => i.batchId == batchId).toList();
  }

  void addBatch(OnionBatch batch) {
    _batches.insert(0, batch);
    notifyListeners();
  }

  void updateBatch(OnionBatch updated) {
    final idx = _batches.indexWhere((b) => b.id == updated.id);
    if (idx != -1) {
      _batches[idx] = updated;
      notifyListeners();
    }
  }

  void addInspection(OnionInspection inspection) {
    _inspections.insert(0, inspection);

    // Update batch status
    final batch = getBatchById(inspection.batchId);
    if (batch != null) {
      final newStatus = inspection.assignedGrade == QualityGrade.reject
          ? BatchStatus.rejected
          : BatchStatus.certified;

      updateBatch(batch.copyWith(
        status: newStatus,
        latestGrade: inspection.assignedGrade.label,
      ));
    }
    notifyListeners();
  }

  OnionInspection? verifyInspection(String query) {
    final clean = query.trim().toUpperCase();
    try {
      return _inspections.firstWhere(
        (ins) =>
            ins.id.toUpperCase() == clean ||
            ins.verificationToken.toUpperCase() == clean ||
            ins.batchNumber.toUpperCase() == clean,
      );
    } catch (_) {
      return null;
    }
  }

  void _seedInitialData() {
    final now = DateTime.now();

    final b1 = OnionBatch(
      id: 'batch-001',
      batchNumber: 'BATCH-2026-NSK-104',
      farmerName: 'Ramesh Patil',
      farmerPhone: '+91 98231 44521',
      mandiLocation: 'Lasalgaon APMC, Nashik',
      onionVariety: 'Nashik Red (Garva)',
      harvestDate: now.subtract(const Duration(days: 4)),
      weightQuintals: 125.0,
      bagCount: 250,
      status: BatchStatus.certified,
      createdAt: now.subtract(const Duration(days: 2)),
      latestGrade: 'Grade A',
      qrCodeData: 'ONION-BATCH:BATCH-2026-NSK-104',
    );

    final b2 = OnionBatch(
      id: 'batch-002',
      batchNumber: 'BATCH-2026-PMP-209',
      farmerName: 'Suresh Gaikwad',
      farmerPhone: '+91 94220 89112',
      mandiLocation: 'Pimpalgaon Baswant APMC',
      onionVariety: 'Rangda Medium',
      harvestDate: now.subtract(const Duration(days: 6)),
      weightQuintals: 85.5,
      bagCount: 170,
      status: BatchStatus.inspected,
      createdAt: now.subtract(const Duration(days: 1)),
      latestGrade: 'Grade B',
      qrCodeData: 'ONION-BATCH:BATCH-2026-PMP-209',
    );

    final b3 = OnionBatch(
      id: 'batch-003',
      batchNumber: 'BATCH-2026-YVL-043',
      farmerName: 'Kailash Shinde',
      farmerPhone: '+91 99750 31204',
      mandiLocation: 'Yeola Mandi Yard',
      onionVariety: 'White Onion (Kharif)',
      harvestDate: now.subtract(const Duration(days: 2)),
      weightQuintals: 60.0,
      bagCount: 120,
      status: BatchStatus.pending,
      createdAt: now.subtract(const Duration(hours: 5)),
      latestGrade: null,
      qrCodeData: 'ONION-BATCH:BATCH-2026-YVL-043',
    );

    _batches.addAll([b1, b2, b3]);

    // Seed mock inspection for b1
    final analysis1 = HeapAnalysisResult(
      analysisId: 'HA-892144',
      timestamp: now.subtract(const Duration(days: 1)).toIso8601String(),
      visibleOnionCount: 24,
      grades: const GradeDistributionModel(
        gradeAPercent: 75.0,
        gradeBPercent: 16.7,
        rejectPercent: 8.3,
      ),
      defects: const DefectCountsModel(
        healthy: 18,
        damaged: 3,
        rotten: 1,
        sprouted: 1,
        undersized: 1,
        unknown: 0,
      ),
      detections: _generateSampleDetections(),
      overallConfidence: 0.93,
      processingTimeMs: 420,
      isPrototype: true,
      warnings: const [
        'Heap overlap detected: Surface contour estimates only.',
      ],
      disclaimer:
          'Estimation is derived solely from visible surface onions in the heap image. '
          'Calibrate with physical cross-sectional sampling for final trade settlement.',
    );

    final insp1 = OnionInspection(
      id: 'INSP-2026-001',
      batchId: b1.id,
      batchNumber: b1.batchNumber,
      inspectorName: 'Dr. V. K. Deshmukh',
      inspectorId: 'INS-MH-704',
      timestamp: now.subtract(const Duration(days: 1)),
      analysis: analysis1,
      assignedGrade: QualityGrade.gradeA,
      sampleWeightKg: 15.0,
      notes: 'Uniform shape, good curing, export grade batch verified.',
      verificationToken: 'VERIF-NSK-8921-A',
    );

    _inspections.add(insp1);
  }

  static List<OnionDetectionItem> _generateSampleDetections() {
    final list = <OnionDetectionItem>[];
    final rand = Random(1234);
    for (int i = 1; i <= 24; i++) {
      final r = (i - 1) ~/ 5;
      final c = (i - 1) % 5;
      final cx = 0.12 + c * 0.19;
      final cy = 0.14 + r * 0.21;
      final rx = 0.08;
      final ry = 0.09;

      final defect = i == 4
          ? DefectType.damaged
          : i == 11
              ? DefectType.sprouted
              : i == 18
                  ? DefectType.rotten
                  : i == 22
                      ? DefectType.undersized
                      : DefectType.healthy;

      final grade = (defect == DefectType.rotten || defect == DefectType.sprouted)
          ? QualityGrade.reject
          : (defect == DefectType.damaged || defect == DefectType.undersized)
              ? QualityGrade.gradeB
              : QualityGrade.gradeA;

      list.add(OnionDetectionItem(
        id: i,
        bbox: DetectionBoundingBox(
          ymin: cy - ry,
          xmin: cx - rx,
          ymax: cy + ry,
          xmax: cx + rx,
        ),
        polygon: [
          Point2D(x: cx, y: cy - ry),
          Point2D(x: cx + rx, y: cy),
          Point2D(x: cx, y: cy + ry),
          Point2D(x: cx - rx, y: cy),
        ],
        confidence: 0.88 + (rand.nextDouble() * 0.08),
        defectType: defect,
        grade: grade,
        estimatedDiameterMm: 52.0 + (rand.nextDouble() * 12.0),
        severityScore: defect == DefectType.healthy ? 0.0 : 0.45,
      ));
    }
    return list;
  }
}
