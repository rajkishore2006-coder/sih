import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/models.dart';
import '../navigation/app_router.dart';
import '../providers/batch_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/onion_grade_badge.dart';

class BatchDetailsScreen extends StatelessWidget {
  final String batchId;
  const BatchDetailsScreen({super.key, required this.batchId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnionBatchProvider>();
    final batch = provider.batches.cast<OnionBatch?>().firstWhere(
          (b) => b?.id == batchId,
          orElse: () => null,
        );

    if (batch == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Batch Details')),
        body: const Center(child: Text('Requested Mandi batch does not exist.')),
      );
    }

    final inspections = provider.inspections.where((i) => i.batchId == batchId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(batch.batchNumber),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lot QR payload: ${batch.qrCodeData ?? batch.batchNumber}')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header summary card with QR
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    QrImageView(
                      data: batch.qrCodeData ?? batch.batchNumber,
                      version: QrVersions.auto,
                      size: 90.0,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  batch.batchNumber,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                              if (batch.latestGrade != null)
                                OnionGradeBadge(grade: batch.latestGrade!)
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('PENDING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Farmer: ${batch.farmerName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Text('Location: ${batch.mandiLocation}', style: const TextStyle(fontSize: 11, color: OnionSureColors.textMuted)),
                          Text('Variety: ${batch.onionVariety}', style: const TextStyle(fontSize: 11, color: OnionSureColors.textMuted)),
                          Text('Volume: ${batch.weightQuintals} Qtl (${batch.bagCount} bags)', style: const TextStyle(fontSize: 11, color: OnionSureColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Start Inspection CTA
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Inspect & Grade Onion Heap'),
              onPressed: () => context.push('${AppRoutes.heapAnalysis}?batchId=${batch.id}'),
            ),
            const SizedBox(height: 20),

            // Certified Inspections List
            const Text('Audited Inspection History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),

            if (inspections.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.assignment_outlined, size: 36, color: OnionSureColors.textMuted),
                        const SizedBox(height: 6),
                        const Text(
                          'No heap inspections logged yet for this lot.',
                          style: TextStyle(fontSize: 12, color: OnionSureColors.textMuted),
                        ),
                      ],
                    ),
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
                  final insp = inspections[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.verified, color: OnionSureColors.primaryGreen),
                      title: Text(insp.assignedGrade, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Cert: ${insp.verificationToken}\nInspector: ${insp.inspectorName}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => context.push('${AppRoutes.certificate}?certNumber=${insp.verificationToken}'),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
