class Point2D {
  final double x;
  final double y;

  Point2D({required this.x, required this.y});

  factory Point2D.fromJson(Map<String, dynamic> json) {
    return Point2D(
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {'x': x, 'y': y};
}

class DetectionBoundingBox {
  final double ymin;
  final double xmin;
  final double ymax;
  final double xmax;

  DetectionBoundingBox({
    required this.ymin,
    required this.xmin,
    required this.ymax,
    required this.xmax,
  });

  factory DetectionBoundingBox.fromJson(Map<String, dynamic> json) {
    return DetectionBoundingBox(
      ymin: (json['ymin'] as num?)?.toDouble() ?? 0.0,
      xmin: (json['xmin'] as num?)?.toDouble() ?? 0.0,
      ymax: (json['ymax'] as num?)?.toDouble() ?? 1.0,
      xmax: (json['xmax'] as num?)?.toDouble() ?? 1.0,
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
  final String defectType; // Healthy, Damaged, Rotten, Sprouted, Undersized, Unknown
  final String grade; // Grade A, Grade B, Reject
  final double estimatedDiameterMm;
  final double severityScore;
  final bool isEdgeOnion;

  OnionDetectionItem({
    required this.id,
    required this.bbox,
    this.polygon = const [],
    required this.confidence,
    required this.defectType,
    required this.grade,
    required this.estimatedDiameterMm,
    required this.severityScore,
    this.isEdgeOnion = false,
  });

  factory OnionDetectionItem.fromJson(Map<String, dynamic> json) {
    return OnionDetectionItem(
      id: json['id'] as int? ?? 0,
      bbox: DetectionBoundingBox.fromJson(json['bbox'] as Map<String, dynamic>? ?? {}),
      polygon: (json['polygon'] as List<dynamic>?)
              ?.map((p) => Point2D.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.85,
      defectType: json['defectType'] as String? ?? json['defect_type'] as String? ?? 'Healthy',
      grade: json['grade'] as String? ?? 'Grade A',
      estimatedDiameterMm: (json['estimatedDiameterMm'] as num?)?.toDouble() ??
          (json['estimated_diameter_mm'] as num?)?.toDouble() ??
          52.0,
      severityScore: (json['severityScore'] as num?)?.toDouble() ??
          (json['severity_score'] as num?)?.toDouble() ??
          0.0,
      isEdgeOnion: json['isEdgeOnion'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'bbox': bbox.toJson(),
    'polygon': polygon.map((p) => p.toJson()).toList(),
    'confidence': confidence,
    'defectType': defectType,
    'grade': grade,
    'estimatedDiameterMm': estimatedDiameterMm,
    'severityScore': severityScore,
    'isEdgeOnion': isEdgeOnion,
  };
}
