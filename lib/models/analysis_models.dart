enum DefectType {
  healthy('Healthy', 'No visual defects detected'),
  damaged('Damaged', 'Cuts, bruises, or mechanical punctures'),
  rotten('Rotten', 'Fungal decay, soft rot, or discoloration'),
  sprouted('Sprouted', 'Premature shoot emergence'),
  undersized('Undersized', 'Diameter below 40mm Mandi grade'),
  unknown('Unknown', 'Occluded or unclassified');

  final String label;
  final String description;
  const DefectType(this.label, this.description);

  static DefectType fromString(String val) {
    for (final d in DefectType.values) {
      if (d.label.toLowerCase() == val.toLowerCase()) return d;
    }
    return DefectType.unknown;
  }
}

enum QualityGrade {
  gradeA('Grade A', 'Premium export/mandi grade (>70% healthy, uniform size)'),
  gradeB('Grade B', 'Fair average quality (light blemishes, secondary market)'),
  reject('Reject', 'Non-marketable decay, rotting, or severe sprout');

  final String label;
  final String description;
  const QualityGrade(this.label, this.description);

  static QualityGrade fromString(String val) {
    if (val.contains('A')) return QualityGrade.gradeA;
    if (val.contains('B')) return QualityGrade.gradeB;
    return QualityGrade.reject;
  }
}

class Point2D {
  final double x;
  final double y;

  const Point2D({required this.x, required this.y});

  factory Point2D.fromJson(Map<String, dynamic> json) {
    return Point2D(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'x': x, 'y': y};
}

class DetectionBoundingBox {
  final double ymin;
  final double xmin;
  final double ymax;
  final double xmax;

  const DetectionBoundingBox({
    required this.ymin,
    required this.xmin,
    required this.ymax,
    required this.xmax,
  });

  factory DetectionBoundingBox.fromJson(Map<String, dynamic> json) {
    return DetectionBoundingBox(
      ymin: (json['ymin'] as num).toDouble(),
      xmin: (json['xmin'] as num).toDouble(),
      ymax: (json['ymax'] as num).toDouble(),
      xmax: (json['xmax'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'ymin': ymin,
        'xmin': xmin,
        'ymax': ymax,
        'xmax': xmax,
      };
}

class OnionDetectionItem {
  final int id;
  final DetectionBoundingBox bbox;
  final List<Point2D> polygon;
  final double confidence;
  final DefectType defectType;
  final QualityGrade grade;
  final double estimatedDiameterMm;
  final double severityScore;

  const OnionDetectionItem({
    required this.id,
    required this.bbox,
    required this.polygon,
    required this.confidence,
    required this.defectType,
    required this.grade,
    required this.estimatedDiameterMm,
    required this.severityScore,
  });

  factory OnionDetectionItem.fromJson(Map<String, dynamic> json) {
    final polyList = (json['polygon'] as List<dynamic>?)
            ?.map((p) => Point2D.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];

    return OnionDetectionItem(
      id: json['id'] as int? ?? 0,
      bbox: DetectionBoundingBox.fromJson(json['bbox'] as Map<String, dynamic>),
      polygon: polyList,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.85,
      defectType: DefectType.fromString(json['defect_type'] as String? ?? 'Healthy'),
      grade: QualityGrade.fromString(json['grade'] as String? ?? 'Grade A'),
      estimatedDiameterMm:
          (json['estimated_diameter_mm'] as num?)?.toDouble() ?? 50.0,
      severityScore: (json['severity_score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bbox': bbox.toJson(),
        'polygon': polygon.map((p) => p.toJson()).toList(),
        'confidence': confidence,
        'defect_type': defectType.label,
        'grade': grade.label,
        'estimated_diameter_mm': estimatedDiameterMm,
        'severity_score': severityScore,
      };
}

class GradeDistributionModel {
  final double gradeAPercent;
  final double gradeBPercent;
  final double rejectPercent;

  const GradeDistributionModel({
    required this.gradeAPercent,
    required this.gradeBPercent,
    required this.rejectPercent,
  });

  factory GradeDistributionModel.fromJson(Map<String, dynamic> json) {
    return GradeDistributionModel(
      gradeAPercent: (json['grade_a_percent'] as num?)?.toDouble() ?? 0.0,
      gradeBPercent: (json['grade_b_percent'] as num?)?.toDouble() ?? 0.0,
      rejectPercent: (json['reject_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'grade_a_percent': gradeAPercent,
        'grade_b_percent': gradeBPercent,
        'reject_percent': rejectPercent,
      };
}

class DefectCountsModel {
  final int healthy;
  final int damaged;
  final int rotten;
  final int sprouted;
  final int undersized;
  final int unknown;

  const DefectCountsModel({
    this.healthy = 0,
    this.damaged = 0,
    this.rotten = 0,
    this.sprouted = 0,
    this.undersized = 0,
    this.unknown = 0,
  });

  int get total => healthy + damaged + rotten + sprouted + undersized + unknown;

  factory DefectCountsModel.fromJson(Map<String, dynamic> json) {
    return DefectCountsModel(
      healthy: json['healthy'] as int? ?? 0,
      damaged: json['damaged'] as int? ?? 0,
      rotten: json['rotten'] as int? ?? 0,
      sprouted: json['sprouted'] as int? ?? 0,
      undersized: json['undersized'] as int? ?? 0,
      unknown: json['unknown'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'healthy': healthy,
        'damaged': damaged,
        'rotten': rotten,
        'sprouted': sprouted,
        'undersized': undersized,
        'unknown': unknown,
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

  const HeapAnalysisResult({
    required this.analysisId,
    required this.timestamp,
    required this.visibleOnionCount,
    required this.grades,
    required this.defects,
    required this.detections,
    required this.overallConfidence,
    required this.processingTimeMs,
    required this.isPrototype,
    required this.warnings,
    required this.disclaimer,
    this.annotatedImageBase64,
  });

  factory HeapAnalysisResult.fromJson(Map<String, dynamic> json) {
    final dets = (json['detections'] as List<dynamic>?)
            ?.map((d) => OnionDetectionItem.fromJson(d as Map<String, dynamic>))
            .toList() ??
        [];

    final warns = (json['warnings'] as List<dynamic>?)
            ?.map((w) => w.toString())
            .toList() ??
        [];

    return HeapAnalysisResult(
      analysisId: json['analysis_id'] as String? ?? 'HA-UNKNOWN',
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      visibleOnionCount: json['visible_onion_count'] as int? ?? dets.length,
      grades: GradeDistributionModel.fromJson(
          json['grades'] as Map<String, dynamic>? ?? {}),
      defects: DefectCountsModel.fromJson(
          json['defects'] as Map<String, dynamic>? ?? {}),
      detections: dets,
      overallConfidence:
          (json['overall_confidence'] as num?)?.toDouble() ?? 0.88,
      processingTimeMs: json['processing_time_ms'] as int? ?? 450,
      isPrototype: json['is_prototype'] as bool? ?? true,
      warnings: warns,
      disclaimer: json['estimation_disclaimer'] as String? ??
          'Estimation is derived solely from visible surface onions.',
      annotatedImageBase64: json['annotated_image_base64'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'analysis_id': analysisId,
        'timestamp': timestamp,
        'visible_onion_count': visibleOnionCount,
        'grades': grades.toJson(),
        'defects': defects.toJson(),
        'detections': detections.map((d) => d.toJson()).toList(),
        'overall_confidence': overallConfidence,
        'processing_time_ms': processingTimeMs,
        'is_prototype': isPrototype,
        'warnings': warnings,
        'estimation_disclaimer': disclaimer,
        'annotated_image_base64': annotatedImageBase64,
      };
}
