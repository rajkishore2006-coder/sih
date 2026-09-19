import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:onion_quality_app/config/app_config.dart';
import 'package:onion_quality_app/models/analysis_models.dart';

class HeapAnalysisService {
  final http.Client _client = http.Client();

  Future<HeapAnalysisResult> analyzeHeap({
    required Uint8List imageBytes,
    String filename = 'heap.jpg',
    bool forceMock = false,
  }) async {
    if (!forceMock && !AppConfig.useMockAi) {
      try {
        final uri = Uri.parse(AppConfig.aiApiUrl);
        final request = http.MultipartRequest('POST', uri);
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageBytes,
            filename: filename,
          ),
        );

        final streamedResponse = await request.send().timeout(
              const Duration(seconds: 15),
            );

        if (streamedResponse.statusCode == 200) {
          final responseBody = await streamedResponse.stream.bytesToString();
          final jsonMap = jsonDecode(responseBody) as Map<String, dynamic>;
          return HeapAnalysisResult.fromJson(jsonMap);
        }
      } catch (e) {
        // Fall back gracefully to mock analysis if backend is unreachable
      }
    }

    // Simulate realistic inference processing time (600ms)
    await Future.delayed(const Duration(milliseconds: 650));
    return _generateRealisticHeapAnalysis(imageBytes);
  }

  HeapAnalysisResult _generateRealisticHeapAnalysis(Uint8List imageBytes) {
    // Generate deterministic seed based on image bytes length
    final seed = imageBytes.length > 10 ? imageBytes.length : 42;
    final random = Random(seed);

    final detections = <OnionDetectionItem>[];
    const rows = 4;
    const cols = 5;

    int idCounter = 1;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        // 85% presence rate in heap
        if (random.nextDouble() > 0.88) continue;

        final cx = 0.12 + (c * 0.18) + (random.nextDouble() * 0.05 - 0.025);
        final cy = 0.14 + (r * 0.20) + (random.nextDouble() * 0.05 - 0.025);
        final rx = 0.075 * (0.85 + random.nextDouble() * 0.35);
        final ry = 0.085 * (0.85 + random.nextDouble() * 0.35);

        final xmin = (cx - rx).clamp(0.02, 0.98);
        final xmax = (cx + rx).clamp(0.02, 0.98);
        final ymin = (cy - ry).clamp(0.02, 0.98);
        final ymax = (cy + ry).clamp(0.02, 0.98);

        final bbox = DetectionBoundingBox(
          ymin: (ymin * 1000).round() / 1000.0,
          xmin: (xmin * 1000).round() / 1000.0,
          ymax: (ymax * 1000).round() / 1000.0,
          xmax: (xmax * 1000).round() / 1000.0,
        );

        // Generate polygon contour
        final polygon = <Point2D>[];
        const pointCount = 10;
        for (int i = 0; i < pointCount; i++) {
          final angle = (2 * pi / pointCount) * i;
          final jitter = 0.94 + random.nextDouble() * 0.12;
          final px = (cx + rx * cos(angle) * jitter).clamp(0.0, 1.0);
          final py = (cy + ry * sin(angle) * jitter).clamp(0.0, 1.0);
          polygon.add(Point2D(
            x: (px * 1000).round() / 1000.0,
            y: (py * 1000).round() / 1000.0,
          ));
        }

        // Defect distribution
        final roll = random.nextDouble();
        DefectType defect;
        QualityGrade grade;
        double severity;
        double estDia = 40.0 + random.nextDouble() * 32.0;

        if (roll < 0.68) {
          defect = DefectType.healthy;
          grade = QualityGrade.gradeA;
          severity = 0.05;
        } else if (roll < 0.82) {
          defect = DefectType.damaged;
          grade = random.nextBool() ? QualityGrade.gradeB : QualityGrade.reject;
          severity = 0.42;
        } else if (roll < 0.89) {
          defect = DefectType.sprouted;
          grade = QualityGrade.reject;
          severity = 0.85;
        } else if (roll < 0.94) {
          defect = DefectType.rotten;
          grade = QualityGrade.reject;
          severity = 0.92;
        } else {
          defect = DefectType.undersized;
          grade = QualityGrade.gradeB;
          estDia = 34.0 + random.nextDouble() * 5.0;
          severity = 0.38;
        }

        final conf = 0.82 + random.nextDouble() * 0.14;

        detections.add(OnionDetectionItem(
          id: idCounter++,
          bbox: bbox,
          polygon: polygon,
          confidence: (conf * 100).round() / 100.0,
          defectType: defect,
          grade: grade,
          estimatedDiameterMm: (estDia * 10).round() / 10.0,
          severityScore: severity,
        ));
      }
    }

    final total = max(1, detections.length);
    final countA = detections.where((d) => d.grade == QualityGrade.gradeA).length;
    final countB = detections.where((d) => d.grade == QualityGrade.gradeB).length;
    final countR = detections.where((d) => d.grade == QualityGrade.reject).length;

    final gradeDist = GradeDistributionModel(
      gradeAPercent: ((countA / total) * 1000).round() / 10.0,
      gradeBPercent: ((countB / total) * 1000).round() / 10.0,
      rejectPercent: ((countR / total) * 1000).round() / 10.0,
    );

    final defectCounts = DefectCountsModel(
      healthy: detections.where((d) => d.defectType == DefectType.healthy).length,
      damaged: detections.where((d) => d.defectType == DefectType.damaged).length,
      rotten: detections.where((d) => d.defectType == DefectType.rotten).length,
      sprouted: detections.where((d) => d.defectType == DefectType.sprouted).length,
      undersized: detections.where((d) => d.defectType == DefectType.undersized).length,
      unknown: detections.where((d) => d.defectType == DefectType.unknown).length,
    );

    final warnings = <String>[
      'Heap overlap detected: Surface contour estimates only.',
    ];
    if (gradeDist.rejectPercent > 18.0) {
      warnings.add('High rejection rate (>18%). Secondary sampling advised.');
    }

    return HeapAnalysisResult(
      analysisId: 'HA-${Random().nextInt(899999) + 100000}',
      timestamp: DateTime.now().toIso8601String(),
      visibleOnionCount: detections.length,
      grades: gradeDist,
      defects: defectCounts,
      detections: detections,
      overallConfidence: 0.91,
      processingTimeMs: 480,
      isPrototype: true,
      warnings: warnings,
      disclaimer: AppConfig.estimationDisclaimer,
      annotatedImageBase64: null,
    );
  }
}
