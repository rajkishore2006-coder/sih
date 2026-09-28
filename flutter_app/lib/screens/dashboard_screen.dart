import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../navigation/app_router.dart';
import '../providers/batch_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/onion_grade_badge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedFilter = 'all'; // all, certified, pending

  @override
  Widget build(BuildContext context) {
    final batchProvider = context.watch<OnionBatchProvider>();
    final batches = batchProvider.batches;

    final totalLots = batches.length;
    final certifiedLots = batches.where((b) => b.status == 'certified').length;
    final pendingLots = batches.where((b) => b.status == 'pending').length;
    final totalQuintals = batches.fold<double>(0.0, (acc, b) => acc + b.weightQuintals);

    final filteredBatches = batches.where((b) {
      if (_selectedFilter == 'certified') return b.status == 'certified';
      if (_selectedFilter == 'pending') return b.status == 'pending';
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: OnionSureColors.primaryGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.eco, color: OnionSureColors.primaryGreen, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ONIONSURE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, letterSpacing: 0.5)),
                Text('Mandi APMC Quality Intelligence', style: TextStyle(fontSize: 10, color: OnionSureColors.textMuted)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Verify Certificate',
            onPressed: () => context.push(AppRoutes.verification),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sync status banner
            if (batchProvider.pendingSyncCount > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cloud_sync, color: Colors.amber.shade800, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${batchProvider.pendingSyncCount} record(s) queued for APMC cloud sync',
                        style: TextStyle(color: Colors.amber.shade900, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: () => batchProvider.triggerSync(),
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                      child: const Text('Sync Now', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

            // Mandi KPI Stat Cards
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [OnionSureColors.primaryDark, OnionSureColors.primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: OnionSureColors.primaryGreen.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'APMC Mandi Yard Overview',
                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('e-NAM Ready', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatColumn(label: 'Total Lots', value: '$totalLots'),
                      _StatColumn(label: 'Certified', value: '$certifiedLots'),
                      _StatColumn(label: 'Pending', value: '$pendingLots'),
                      _StatColumn(label: 'Total Volume', value: '${totalQuintals.toStringAsFixed(0)} Qtl'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.add_circle_outline,
                    title: 'Register Batch',
                    subtitle: 'Mandi Lot Arrival',
                    color: OnionSureColors.primaryGreen,
                    onTap: () => context.push(AppRoutes.createBatch),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.center_focus_strong,
                    title: 'Inspect Heap',
                    subtitle: 'AI Computer Vision',
                    color: const Color(0xFF0284C7),
                    onTap: () => context.push(AppRoutes.heapAnalysis),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.history_edu,
                    title: 'Inspection Log',
                    subtitle: 'Audited Archive',
                    color: const Color(0xFF7C3AED),
                    onTap: () => context.push(AppRoutes.inspectionHistory),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.verified_outlined,
                    title: 'Verify Token',
                    subtitle: 'e-NAM Public Check',
                    color: const Color(0xFF0D9488),
                    onTap: () => context.push(AppRoutes.verification),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Lot Filter Chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Registered Mandi Lots', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    _FilterChip(
                      label: 'All ($totalLots)',
                      isSelected: _selectedFilter == 'all',
                      onTap: () => setState(() => _selectedFilter = 'all'),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'Certified',
                      isSelected: _selectedFilter == 'certified',
                      onTap: () => setState(() => _selectedFilter = 'certified'),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'Pending',
                      isSelected: _selectedFilter == 'pending',
                      onTap: () => setState(() => _selectedFilter = 'pending'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Batch List
            if (filteredBatches.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 40, color: OnionSureColors.textMuted),
                        const SizedBox(height: 8),
                        Text(
                          'No batches matching "$_selectedFilter"',
                          style: const TextStyle(color: OnionSureColors.textMuted, fontSize: 13),
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
                itemCount: filteredBatches.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final b = filteredBatches[index];
                  return Card(
                    margin: EdgeInsets.zero,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.push('${AppRoutes.batchDetails}?batchId=${b.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: OnionSureColors.surfaceLight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: OnionSureColors.borderLight),
                              ),
                              child: const Icon(Icons.layers, color: OnionSureColors.primaryGreen, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(b.batchNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      const SizedBox(width: 8),
                                      if (b.latestGrade != null)
                                        OnionGradeBadge(grade: b.latestGrade!)
                                      else
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.shade50,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: Colors.amber.shade300),
                                          ),
                                          child: Text('PENDING', style: TextStyle(color: Colors.amber.shade900, fontSize: 9, fontWeight: FontWeight.bold)),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${b.farmerName} • ${b.onionVariety}',
                                    style: const TextStyle(fontSize: 12, color: OnionSureColors.textMuted),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${b.mandiLocation} • ${b.weightQuintals} Qtl (${b.bagCount} bags)',
                                    style: const TextStyle(fontSize: 11, color: OnionSureColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: OnionSureColors.textMuted),
                          ],
                        ),
                      ),
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

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: const TextStyle(fontSize: 10, color: OnionSureColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? OnionSureColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? OnionSureColors.primaryGreen : OnionSureColors.borderLight),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : OnionSureColors.textMuted,
          ),
        ),
      ),
    );
  }
}
