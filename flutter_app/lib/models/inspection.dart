import 'quality_summary.dart';

class OnionInspection {
  final String id;
  final String batchId;
  final String batchNumber;
  final String inspectorName;
  final String inspectorId;
  final String timestamp;
  final HeapAnalysisResult analysis;
  final String assignedGrade; // 'Grade A' | 'Grade B' | 'Reject'
  final double sampleWeightKg;
  final String notes;
  final String verificationToken;
  final String? imageBase64;
  final bool isSynced;

  OnionInspection({
    required this.id,
    required this.batchId,
    required this.batchNumber,
    required this.inspectorName,
    required this.inspectorId,
    required this.timestamp,
    required this.analysis,
    required this.assignedGrade,
    required this.sampleWeightKg,
    required this.notes,
    required this.verificationToken,
    this.imageBase64,
    this.isSynced = false,
  });

  factory OnionInspection.fromJson(Map<String, dynamic> json) {
    return OnionInspection(
      id: json['id'] as String? ?? '',
      batchId: json['batchId'] as String? ?? json['batch_id'] as String? ?? '',
      batchNumber: json['batchNumber'] as String? ?? json['batch_number'] as String? ?? '',
      inspectorName: json['inspectorName'] as String? ?? json['inspector_name'] as String? ?? '',
      inspectorId: json['inspectorId'] as String? ?? json['inspector_id'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      analysis: HeapAnalysisResult.fromJson(
        json['analysis'] as Map<String, dynamic>? ?? {},
      ),
      assignedGrade: json['assignedGrade'] as String? ?? json['assigned_grade'] as String? ?? 'Grade A',
      sampleWeightKg: (json['sampleWeightKg'] as num?)?.toDouble() ??
          (json['sample_weight_kg'] as num?)?.toDouble() ??
          15.0,
      notes: json['notes'] as String? ?? '',
      verificationToken: json['verificationToken'] as String? ??
          json['verification_token'] as String? ??
          json['certificateNumber'] as String? ??
          '',
      imageBase64: json['imageBase64'] as String? ?? json['heap_image_url'] as String?,
      isSynced: json['isSynced'] as bool? ?? json['is_synced'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'batchId': batchId,
    'batchNumber': batchNumber,
    'inspectorName': inspectorName,
    'inspectorId': inspectorId,
    'timestamp': timestamp,
    'analysis': analysis.toJson(),
    'assignedGrade': assignedGrade,
    'sampleWeightKg': sampleWeightKg,
    'notes': notes,
    'verificationToken': verificationToken,
    'imageBase64': imageBase64,
    'isSynced': isSynced,
  };
}
