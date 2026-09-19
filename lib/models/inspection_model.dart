import 'package:onion_quality_app/models/analysis_models.dart';

class OnionInspection {
  final String id;
  final String batchId;
  final String batchNumber;
  final String inspectorName;
  final String inspectorId;
  final DateTime timestamp;
  final HeapAnalysisResult analysis;
  final QualityGrade assignedGrade;
  final double sampleWeightKg;
  final String notes;
  final String verificationToken;
  final String? imageBase64;

  const OnionInspection({
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
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'batchId': batchId,
        'batchNumber': batchNumber,
        'inspectorName': inspectorName,
        'inspectorId': inspectorId,
        'timestamp': timestamp.toIso8601String(),
        'analysis': analysis.toJson(),
        'assignedGrade': assignedGrade.label,
        'sampleWeightKg': sampleWeightKg,
        'notes': notes,
        'verificationToken': verificationToken,
        'imageBase64': imageBase64,
      };

  factory OnionInspection.fromJson(Map<String, dynamic> json) {
    return OnionInspection(
      id: json['id'] as String,
      batchId: json['batchId'] as String,
      batchNumber: json['batchNumber'] as String,
      inspectorName: json['inspectorName'] as String,
      inspectorId: json['inspectorId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      analysis: HeapAnalysisResult.fromJson(json['analysis'] as Map<String, dynamic>),
      assignedGrade: QualityGrade.fromString(json['assignedGrade'] as String),
      sampleWeightKg: (json['sampleWeightKg'] as num).toDouble(),
      notes: json['notes'] as String? ?? '',
      verificationToken: json['verificationToken'] as String,
      imageBase64: json['imageBase64'] as String?,
    );
  }
}
