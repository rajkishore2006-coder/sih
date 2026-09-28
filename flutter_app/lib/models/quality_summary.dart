import 'onion_instance.dart';

class GradeDistributionModel {
  final double gradeAPercent;
  final double gradeBPercent;
  final double rejectPercent;

  GradeDistributionModel({
    required this.gradeAPercent,
    required this.gradeBPercent,
    required this.rejectPercent,
  });

  factory GradeDistributionModel.fromJson(Map<String, dynamic> json) {
    return GradeDistributionModel(
      gradeAPercent: (json['gradeAPercent'] as num?)?.toDouble() ??
          (json['grade_a_percent'] as num?)?.toDouble() ??
          70.0,
      gradeBPercent: (json['gradeBPercent'] as num?)?.toDouble() ??
          (json['grade_b_percent'] as num?)?.toDouble() ??
          25.0,
      rejectPercent: (json['rejectPercent'] as num?)?.toDouble() ??
          (json['reject_percent'] as num?)?.toDouble() ??
          5.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'gradeAPercent': gradeAPercent,
    'gradeBPercent': gradeBPercent,
    'rejectPercent': rejectPercent,
  };
}

class DefectCountsModel {
  final int healthy;
  final int damaged;
  final int rotten;
  final int sprouted;
  final int undersized;
  final int unknown;
  final int total;

  DefectCountsModel({
    required this.healthy,
    required this.damaged,
    required this.rotten,
    required this.sprouted,
    required this.undersized,
    required this.unknown,
    required this.total,
  });

  factory DefectCountsModel.fromJson(Map<String, dynamic> json) {
    return DefectCountsModel(
      healthy: json['healthy'] as int? ?? 0,
      damaged: json['damaged'] as int? ?? 0,
      rotten: json['rotten'] as int? ?? 0,
      sprouted: json['sprouted'] as int? ?? 0,
      undersized: json['undersized'] as int? ?? 0,
      unknown: json['unknown'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'healthy': healthy,
    'damaged': damaged,
    'rotten': rotten,
    'sprouted': sprouted,
    'undersized': undersized,
    'unknown': unknown,
    'total': total,
  };
}

class HeapAnalysisResult {
  final String analysisId;
  final String timestamp;
  final int visibleOnionCount;
  final GradeDistributionModel grades;
  final DefectCountsModel defects;
  final List<OnionDetectionItem> detections;
  final double overallConfidence;
  final int processingTimeMs;
  final bool isPrototype;
  final List<String> warnings;
  final String disclaimer;
  final String? annotatedImageBase64;

  HeapAnalysisResult({
    required this.analysisId,
    required this.timestamp,
    required this.visibleOnionCount,
    required this.grades,
    required this.defects,
    required this.detections,
    required this.overallConfidence,
    required this.processingTimeMs,
    this.isPrototype = false,
    this.warnings = const [],
    this.disclaimer = '',
    this.annotatedImageBase64,
  });

  factory HeapAnalysisResult.fromJson(Map<String, dynamic> json) {
    return HeapAnalysisResult(
      analysisId: json['analysisId'] as String? ?? json['analysis_id'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      visibleOnionCount: json['visibleOnionCount'] as int? ?? json['visible_onion_count'] as int? ?? 0,
      grades: GradeDistributionModel.fromJson(
        json['grades'] as Map<String, dynamic>? ?? {},
      ),
      defects: DefectCountsModel.fromJson(
        json['defects'] as Map<String, dynamic>? ?? {},
      ),
      detections: (json['detections'] as List<dynamic>?)
              ?.map((d) => OnionDetectionItem.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
      overallConfidence: (json['overallConfidence'] as num?)?.toDouble() ??
          (json['overall_confidence'] as num?)?.toDouble() ??
          0.90,
      processingTimeMs: json['processingTimeMs'] as int? ?? json['processing_time_ms'] as int? ?? 350,
      isPrototype: json['isPrototype'] as bool? ?? false,
      warnings: (json['warnings'] as List<dynamic>?)?.map((w) => w.toString()).toList() ?? [],
      disclaimer: json['disclaimer'] as String? ?? '',
      annotatedImageBase64: json['annotatedImageBase64'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'analysisId': analysisId,
    'timestamp': timestamp,
    'visibleOnionCount': visibleOnionCount,
    'grades': grades.toJson(),
    'defects': defects.toJson(),
    'detections': detections.map((d) => d.toJson()).toList(),
    'overallConfidence': overallConfidence,
    'processingTimeMs': processingTimeMs,
    'isPrototype': isPrototype,
    'warnings': warnings,
    'disclaimer': disclaimer,
    'annotatedImageBase64': annotatedImageBase64,
  };
}
