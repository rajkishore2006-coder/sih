import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:onion_quality_app/models/batch_model.dart';
import 'package:onion_quality_app/models/inspection_model.dart';
import 'package:onion_quality_app/screens/inspection_screen.dart';
import 'package:onion_quality_app/screens/report_screen.dart';
import 'package:onion_quality_app/services/app_services.dart';

class BatchDetailScreen extends StatelessWidget {
  final String batchId;

  const BatchDetailScreen({super.key, required this.batchId});

  @override
  Widget build(BuildContext context) {
    final services = AppServices.instance;
    final batch = services.getBatchById(batchId);

    if (batch == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Batch Details')),
        body: const Center(child: Text('Batch not found')),
      );
    }

    final inspections = services.getInspectionsForBatch(batchId);

    return Scaffold(
      appBar: AppBar(
        title: Text(batch.batchNumber, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // QR & Batch Overview Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // QR Code
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: QrImageView(
                            data: batch.qrCodeData ?? batch.batchNumber,
                            version: QrVersions.auto,
                            size: 110,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Metadata
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                batch.batchNumber,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Farmer: ${batch.farmerName} (${batch.farmerPhone})',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              Text(
                                'Mandi: ${batch.mandiLocation}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                'Variety: ${batch.onionVariety}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                'Weight: ${batch.weightQuintals} Qtl • ${batch.bagCount} Bags',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7C2D12).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  batch.latestGrade != null
                                      ? '${batch.status.label} • ${batch.latestGrade}'
                                      : batch.status.label,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7C2D12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Action to Start Inspection
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C2D12),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text(
                    'Analyze Onion Heap for this Batch',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InspectionScreen(batch: batch),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Inspection History
                const Text(
                  'Completed Quality Inspections',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                if (inspections.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Center(
                      child: Text(
                        'No inspection recorded for this batch yet.\nClick "Analyze Onion Heap" to scan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: inspections.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final ins = inspections[index];
                      return _buildInspectionCard(context, batch, ins);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInspectionCard(
    BuildContext context,
    OnionBatch batch,
    OnionInspection ins,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ins.assignedGrade.name.contains('A')
                ? Colors.green.shade50
                : Colors.amber.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.verified,
            color: ins.assignedGrade.name.contains('A')
                ? Colors.green.shade700
                : Colors.amber.shade700,
          ),
        ),
        title: Text(
          'Inspection: ${ins.assignedGrade.label}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          '${ins.timestamp.toString().substring(0, 16)} • ${ins.inspectorName}\nGrade A: ${ins.analysis.grades.gradeAPercent}% | Reject: ${ins.analysis.grades.rejectPercent}%',
          style: const TextStyle(fontSize: 11),
        ),
        trailing: OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReportScreen(
                  batch: batch,
                  inspection: ins,
                ),
              ),
            );
          },
          child: const Text('View PDF', style: TextStyle(fontSize: 11)),
        ),
      ),
    );
  }
}
