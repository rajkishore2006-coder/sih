import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:onion_quality_app/models/analysis_models.dart';
import 'package:onion_quality_app/models/batch_model.dart';
import 'package:onion_quality_app/models/inspection_model.dart';
import 'package:onion_quality_app/screens/report_screen.dart';
import 'package:onion_quality_app/services/app_services.dart';
import 'package:onion_quality_app/widgets/defect_breakdown_card.dart';
import 'package:onion_quality_app/widgets/disclaimer_banner.dart';
import 'package:onion_quality_app/widgets/quality_distribution.dart';
import 'package:onion_quality_app/widgets/segmentation_overlay.dart';

class HeapAnalysisScreen extends StatelessWidget {
  final OnionBatch batch;
  final HeapAnalysisResult result;
  final Uint8List? imageBytes;
  final String inspectorName;
  final String inspectorId;
  final double sampleWeightKg;
  final String notes;

  const HeapAnalysisScreen({
    super.key,
    required this.batch,
    required this.result,
    this.imageBytes,
    required this.inspectorName,
    required this.inspectorId,
    required this.sampleWeightKg,
    required this.notes,
  });

  QualityGrade _deriveOverallGrade() {
    if (result.grades.rejectPercent > 12.0) {
      return QualityGrade.reject;
    } else if (result.grades.gradeAPercent >= 65.0) {
      return QualityGrade.gradeA;
    } else {
      return QualityGrade.gradeB;
    }
  }

  OnionInspection _buildInspectionRecord() {
    final overallGrade = _deriveOverallGrade();
    final randVerif = Random().nextInt(9000) + 1000;
    final token = 'VERIF-NSK-$randVerif-${overallGrade.name[0].toUpperCase()}';

    return OnionInspection(
      id: 'INSP-2026-$randVerif',
      batchId: batch.id,
      batchNumber: batch.batchNumber,
      inspectorName: inspectorName.isNotEmpty ? inspectorName : 'Certified Grader',
      inspectorId: inspectorId.isNotEmpty ? inspectorId : 'INS-MH-001',
      timestamp: DateTime.now(),
      analysis: result,
      assignedGrade: overallGrade,
      sampleWeightKg: sampleWeightKg,
      notes: notes,
      verificationToken: token,
    );
  }

  @override
  Widget build(BuildContext context) {
    final overallGrade = _deriveOverallGrade();
    final isGradeA = overallGrade == QualityGrade.gradeA;
    final isGradeB = overallGrade == QualityGrade.gradeB;

    final gradeColor = isGradeA
        ? const Color(0xFF16A34A)
        : isGradeB
            ? const Color(0xFFCA8A04)
            : const Color(0xFFDC2626);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Heap Quality Estimation Results',
            style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Grade & Confidence Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: gradeColor.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: gradeColor.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: gradeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              isGradeA
                                  ? Icons.verified
                                  : isGradeB
                                      ? Icons.thumb_up_outlined
                                      : Icons.cancel_outlined,
                              color: gradeColor,
                              size: 26,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              overallGrade.label.toUpperCase(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: gradeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assigned Lot Grade: ${overallGrade.label}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              overallGrade.description,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _metaPill(
                                  '${result.visibleOnionCount} bulbs visible',
                                  Icons.visibility_outlined,
                                ),
                                const SizedBox(width: 8),
                                _metaPill(
                                  '${(result.overallConfidence * 100).toInt()}% confidence',
                                  Icons.speed_outlined,
                                ),
                                const SizedBox(width: 8),
                                _metaPill(
                                  '${result.processingTimeMs} ms',
                                  Icons.timer_outlined,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Interactive Segmentation Overlay
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Instance Segmentation Overlay',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                result.isPrototype
                                    ? 'Prototype Inference Engine'
                                    : 'Fine-Tuned YOLO11-Seg',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap any onion bulb to view diameter, defect type, and confidence score.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SegmentationOverlayWidget(
                          imageBytes: imageBytes,
                          detections: result.detections,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Quality Grade Distribution
                QualityDistributionWidget(
                  distribution: result.grades,
                  visibleCount: result.visibleOnionCount,
                ),
                const SizedBox(height: 16),

                // Defect Breakdown
                DefectBreakdownCard(defects: result.defects),
                const SizedBox(height: 16),

                // Warnings Card (if any)
                if (result.warnings.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      border: Border.all(color: Colors.orange.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                size: 16, color: Colors.orange.shade900),
                            const SizedBox(width: 6),
                            Text(
                              'Vision Quality Warnings (${result.warnings.length})',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ...result.warnings.map(
                          (w) => Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              '• $w',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Mandatory Visible Surface Disclaimer
                DisclaimerBanner(text: result.disclaimer),
                const SizedBox(height: 24),

                // Bottom Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C2D12),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.picture_as_pdf, size: 18),
                        label: const Text(
                          'Generate Digital PDF Report',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          final inspection = _buildInspectionRecord();
                          AppServices.instance.addInspection(inspection);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReportScreen(
                                batch: batch,
                                inspection: inspection,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Save & Certify Batch'),
                        onPressed: () {
                          final inspection = _buildInspectionRecord();
                          AppServices.instance.addInspection(inspection);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Inspection saved! Batch certified as ${inspection.assignedGrade.label}.'),
                            ),
                          );
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metaPill(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
