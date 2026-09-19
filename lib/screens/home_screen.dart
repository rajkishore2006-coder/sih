import 'package:flutter/material.dart';
import 'package:onion_quality_app/config/app_config.dart';
import 'package:onion_quality_app/models/batch_model.dart';
import 'package:onion_quality_app/screens/create_batch_screen.dart';
import 'package:onion_quality_app/screens/batch_detail_screen.dart';
import 'package:onion_quality_app/screens/inspection_screen.dart';
import 'package:onion_quality_app/screens/verify_screen.dart';
import 'package:onion_quality_app/services/app_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _services = AppServices.instance;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _services.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _services.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final batches = _services.batches;
    final filteredBatches = _filter == 'All'
        ? batches
        : _filter == 'Certified'
            ? batches.where((b) => b.status == BatchStatus.certified).toList()
            : _filter == 'Inspected'
                ? batches.where((b) => b.status == BatchStatus.inspected).toList()
                : batches.where((b) => b.status == BatchStatus.pending).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF7C2D12).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.energy_savings_leaf_outlined,
                color: Color(0xFF9A3412),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppConfig.appName,
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'SIH26031 • Digital Onion Grading',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // AI Mode Toggle
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ActionChip(
              avatar: Icon(
                AppConfig.useMockAi ? Icons.science_outlined : Icons.cloud_done_outlined,
                size: 14,
                color: AppConfig.useMockAi ? Colors.amber.shade900 : Colors.green.shade800,
              ),
              label: Text(
                AppConfig.useMockAi ? 'Demo AI' : 'Live API',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppConfig.useMockAi ? Colors.amber.shade900 : Colors.green.shade800,
                ),
              ),
              backgroundColor: AppConfig.useMockAi
                  ? Colors.amber.shade50
                  : Colors.green.shade50,
              side: BorderSide(
                color: AppConfig.useMockAi
                    ? Colors.amber.shade300
                    : Colors.green.shade300,
              ),
              onPressed: () {
                _showAiSettingsDialog(context);
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top KPI Metrics
                _buildKpiBanner(),
                const SizedBox(height: 16),

                // Quick Action Buttons
                _buildQuickActionsRow(context),
                const SizedBox(height: 20),

                // Batches List Header & Filter Chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Registered Onion Batches',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '${filteredBatches.length} of ${batches.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  children: [
                    _filterChip('All'),
                    _filterChip('Certified'),
                    _filterChip('Inspected'),
                    _filterChip('Pending'),
                  ],
                ),
                const SizedBox(height: 12),

                // Batches List
                if (filteredBatches.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 40, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            'No batches found for "$_filter"',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
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
                      final batch = filteredBatches[index];
                      return _buildBatchCard(context, batch);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF7C2D12),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Analyze Onion Heap'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const InspectionScreen(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKpiBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
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
                'Mandi Quality Monitoring Dashboard',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'e-NAM Integration Ready',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _kpiItem(
                  '${_services.totalBatches}',
                  'Total Batches',
                  Icons.grid_view_rounded,
                  const Color(0xFF475569),
                ),
              ),
              Container(width: 1, height: 36, color: Colors.grey.shade200),
              Expanded(
                child: _kpiItem(
                  '${_services.inspectedBatchesCount}',
                  'Inspected',
                  Icons.fact_check_outlined,
                  const Color(0xFF0284C7),
                ),
              ),
              Container(width: 1, height: 36, color: Colors.grey.shade200),
              Expanded(
                child: _kpiItem(
                  '${_services.averageGradeAPercentage}%',
                  'Avg Grade A',
                  Icons.verified_outlined,
                  const Color(0xFF16A34A),
                ),
              ),
              Container(width: 1, height: 36, color: Colors.grey.shade200),
              Expanded(
                child: _kpiItem(
                  '${_services.totalWeightQuintals.toInt()} Qtl',
                  'Total Volume',
                  Icons.scale_outlined,
                  const Color(0xFF7C2D12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kpiItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildQuickActionsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            context,
            icon: Icons.add_circle_outline,
            label: 'Register Batch',
            color: const Color(0xFF7C2D12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateBatchScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _actionButton(
            context,
            icon: Icons.camera_alt_outlined,
            label: 'Inspect Heap',
            color: const Color(0xFF0284C7),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InspectionScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _actionButton(
            context,
            icon: Icons.qr_code_scanner,
            label: 'Scan QR Code',
            color: const Color(0xFF0F766E),
            onTap: () {
              _showScanDialog(context);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _actionButton(
            context,
            icon: Icons.verified_user_outlined,
            label: 'Verify Certificate',
            color: const Color(0xFF4338CA),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VerifyScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String title) {
    final isSelected = _filter == title;
    return ChoiceChip(
      label: Text(title, style: const TextStyle(fontSize: 12)),
      selected: isSelected,
      selectedColor: const Color(0xFF7C2D12),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey.shade800,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) setState(() => _filter = title);
      },
    );
  }

  Widget _buildBatchCard(BuildContext context, OnionBatch batch) {
    final statusColor = batch.status == BatchStatus.certified
        ? const Color(0xFF16A34A)
        : batch.status == BatchStatus.inspected
            ? const Color(0xFF0284C7)
            : batch.status == BatchStatus.rejected
                ? const Color(0xFFDC2626)
                : const Color(0xFFCA8A04);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BatchDetailScreen(batchId: batch.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C2D12).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFF7C2D12),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          batch.batchNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            batch.latestGrade != null
                                ? '${batch.status.label} (${batch.latestGrade})'
                                : batch.status.label,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${batch.farmerName} • ${batch.mandiLocation}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${batch.onionVariety} • ${batch.weightQuintals} Quintals (${batch.bagCount} bags)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showScanDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Scan or Enter Batch QR / Code', style: TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter a Batch Number or scan QR code on the farmer lot bag:',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: 'e.g. BATCH-2026-NSK-104',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                ActionChip(
                  label: const Text('Sample: NSK-104', style: TextStyle(fontSize: 10)),
                  onPressed: () => textController.text = 'BATCH-2026-NSK-104',
                ),
                ActionChip(
                  label: const Text('Sample: PMP-209', style: TextStyle(fontSize: 10)),
                  onPressed: () => textController.text = 'BATCH-2026-PMP-209',
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C2D12),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final query = textController.text.trim();
              Navigator.pop(ctx);
              final found = _services.batches.firstWhere(
                (b) => b.batchNumber.toLowerCase() == query.toLowerCase() ||
                    b.id.toLowerCase() == query.toLowerCase(),
                orElse: () => _services.batches.first,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BatchDetailScreen(batchId: found.id),
                ),
              );
            },
            child: const Text('Find Batch'),
          ),
        ],
      ),
    );
  }

  void _showAiSettingsDialog(BuildContext context) {
    bool mock = AppConfig.useMockAi;
    final urlController = TextEditingController(text: AppConfig.aiApiUrl);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('AI Inference Configuration', style: TextStyle(fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: const Text('Demo Presentation Mode', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: const Text('Instant simulated onion heap inference without active backend server', style: TextStyle(fontSize: 11)),
                value: mock,
                onChanged: (val) {
                  setDialogState(() => mock = val);
                },
              ),
              const SizedBox(height: 8),
              if (!mock) ...[
                const Text('FastAPI Endpoint URL:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    hintText: 'http://localhost:8000/api/analyze-heap',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Run "python3 app/main.py" in backend/ directory',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                AppConfig.useMockAi = mock;
                AppConfig.aiApiUrl = urlController.text.trim();
                setState(() {});
                Navigator.pop(ctx);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
