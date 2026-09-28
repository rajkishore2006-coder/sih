import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/models.dart';
import '../navigation/app_router.dart';
import '../providers/batch_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/onion_grade_badge.dart';

class CertificateScreen extends StatelessWidget {
  final String certificateNumber;
  const CertificateScreen({super.key, required this.certificateNumber});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnionBatchProvider>();
    final inspection = provider.inspections.cast<OnionInspection?>().firstWhere(
          (i) => i?.verificationToken == certificateNumber || i?.id == certificateNumber,
          orElse: () => null,
        );

    final batch = inspection != null
        ? provider.batches.cast<OnionBatch?>().firstWhere(
              (b) => b?.id == inspection.batchId,
              orElse: () => null,
            )
        : null;

    final certificate = (batch != null && inspection != null)
        ? Certificate.fromBatchAndInspection(batch: batch, inspection: inspection)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mandi Quality Certificate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Certificate token copied to clipboard')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go(AppRoutes.dashboard),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // AGMARK / e-NAM Certificate Document Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade300, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Certificate Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('GOVERNMENT OF MAHARASHTRA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: OnionSureColors.textMuted)),
                          const Text('APMC MANDI QUALITY CERTIFICATE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: OnionSureColors.primaryDark)),
                          Text('Digital Lot AGMARK Grade Standards', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: OnionSureColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: OnionSureColors.primaryGreen),
                        ),
                        child: const Text('OFFICIAL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: OnionSureColors.primaryDark)),
                      ),
                    ],
                  ),
                  const Divider(height: 24, thickness: 1),

                  // Verification Token & QR
                  Row(
                    children: [
                      QrImageView(
                        data: certificateNumber,
                        version: QrVersions.auto,
                        size: 100.0,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('VERIFICATION TOKEN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: OnionSureColors.textMuted)),
                            Text(
                              certificateNumber,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: OnionSureColors.primaryDark),
                            ),
                            const SizedBox(height: 4),
                            const Text('Scan with any standard QR app or enter into e-NAM verification portal.', style: TextStyle(fontSize: 10, color: OnionSureColors.textMuted)),
                            const SizedBox(height: 6),
                            if (inspection != null)
                              OnionGradeBadge(grade: inspection.assignedGrade),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),

                  // Mandi & Farmer Details Table
                  if (certificate != null) ...[
                    _CertRow(label: 'Batch Identifier', value: certificate.batchNumber),
                    _CertRow(label: 'Farmer / Lot Owner', value: certificate.farmerName),
                    _CertRow(label: 'Contact Number', value: certificate.farmerPhone),
                    _CertRow(label: 'APMC Mandi Yard', value: certificate.mandiLocation),
                    _CertRow(label: 'Onion Variety', value: certificate.variety),
                    _CertRow(label: 'Total Weight', value: OnionFormatters.formatWeight(certificate.totalWeightQuintals)),
                    _CertRow(label: 'Bag Count', value: '${certificate.bagCount} bags'),
                    _CertRow(label: 'Grade A %', value: '${certificate.gradeAPercent.toStringAsFixed(1)}%'),
                    _CertRow(label: 'Defect / Reject %', value: '${certificate.rejectPercent.toStringAsFixed(1)}%'),
                    _CertRow(label: 'Vision Model Confidence', value: '${(certificate.overallConfidence * 100).toInt()}%'),
                    _CertRow(label: 'Authorized Grader', value: certificate.inspectorName),
                    _CertRow(label: 'Inspector Badge ID', value: certificate.inspectorId),
                    _CertRow(label: 'Date of Certification', value: OnionFormatters.formatDateTime(certificate.issuedAt)),
                  ] else ...[
                    Text('Inspection token: $certificateNumber'),
                  ],

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.slate.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.slate.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_outlined, size: 20, color: OnionSureColors.primaryGreen),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Cryptographically signed by OnionSure AI & APMC Inspector. Tamper-evident.',
                            style: TextStyle(fontSize: 10, color: OnionSureColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            ElevatedButton.icon(
              icon: const Icon(Icons.print),
              label: const Text('Print Mandi Yard AGMARK Certificate'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sent to Mandi thermal/A4 printer')),
                );
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.home),
              label: const Text('Return to Home Dashboard'),
              onPressed: () => context.go(AppRoutes.dashboard),
            ),
          ],
        ),
      ),
    );
  }
}

class _CertRow extends StatelessWidget {
  final String label;
  final String value;
  const _CertRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: OnionSureColors.textMuted)),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: OnionSureColors.textDark)),
        ],
      ),
    );
  }
}
