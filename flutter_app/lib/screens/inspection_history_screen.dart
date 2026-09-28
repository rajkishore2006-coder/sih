import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../navigation/app_router.dart';
import '../providers/batch_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/onion_grade_badge.dart';

class InspectionHistoryScreen extends StatefulWidget {
  const InspectionHistoryScreen({super.key});

  @override
  State<InspectionHistoryScreen> createState() => _InspectionHistoryScreenState();
}

class _InspectionHistoryScreenState extends State<InspectionHistoryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnionBatchProvider>();
    final inspections = provider.inspections.where((i) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return i.batchNumber.toLowerCase().contains(q) ||
          i.verificationToken.toLowerCase().contains(q) ||
          i.inspectorName.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Inspection & Certificate Log')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by Lot #, Token, or Inspector...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
          ),
          Expanded(
            child: inspections.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.assignment_outlined, size: 48, color: OnionSureColors.textMuted),
                        const SizedBox(height: 8),
                        const Text('No inspections logged yet.', style: TextStyle(color: OnionSureColors.textMuted)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => context.push(AppRoutes.heapAnalysis),
                          style: ElevatedButton.styleFrom(minimumSize: const Size(180, 42)),
                          child: const Text('Inspect a Batch Now'),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: inspections.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final insp = inspections[index];
                      return Card(
                        child: ListTile(
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: OnionSureColors.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.verified, color: OnionSureColors.primaryGreen),
                          ),
                          title: Row(
                            children: [
                              Text(insp.batchNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(width: 8),
                              OnionGradeBadge(grade: insp.assignedGrade),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 2),
                              Text('Token: ${insp.verificationToken}', style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                              Text('Inspector: ${insp.inspectorName} (${insp.inspectorId})', style: const TextStyle(fontSize: 11, color: OnionSureColors.textMuted)),
                              Text(
                                '${insp.analysis.visibleOnionCount} bulbs • ${(insp.analysis.overallConfidence * 100).toInt()}% conf • ${insp.sampleWeightKg} kg sample',
                                style: const TextStyle(fontSize: 10, color: OnionSureColors.textMuted),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('${AppRoutes.certificate}?certNumber=${insp.verificationToken}'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
