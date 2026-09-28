import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../navigation/app_router.dart';
import '../providers/batch_provider.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class HeapAnalysisScreen extends StatefulWidget {
  final String? batchId;
  const HeapAnalysisScreen({super.key, this.batchId});

  @override
  State<HeapAnalysisScreen> createState() => _HeapAnalysisScreenState();
}

class _HeapAnalysisScreenState extends State<HeapAnalysisScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _selectedBatchId;
  File? _selectedImage;
  bool _isAnalyzing = false;
  String _analysisStep = '';
  String? _errorMessage;
  HeapAnalysisResult? _result;

  // Sampling & Inspector form
  final _inspectorNameCtrl = TextEditingController();
  final _inspectorIdCtrl = TextEditingController();
  final _weightCtrl = TextEditingController(text: '15.0');
  final _notesCtrl = TextEditingController(text: 'Uniform bulb curing, dry outer tunic scales');

  @override
  void initState() {
    super.initState();
    _selectedBatchId = widget.batchId;
    final storage = context.read<StorageService>();
    _inspectorNameCtrl.text = storage.getSavedInspectorName() ?? 'Dr. V. K. Deshmukh';
    _inspectorIdCtrl.text = storage.getSavedInspectorId() ?? 'INS-MH-704';
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
          _result = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Camera / image capture error: $e');
    }
  }

  Future<void> _runAnalysis() async {
    final batchProvider = context.read<OnionBatchProvider>();
    final activeBatchId = _selectedBatchId ?? (batchProvider.batches.isNotEmpty ? batchProvider.batches.first.id : null);

    if (activeBatchId == null) {
      setState(() => _errorMessage = 'Please select or register a Mandi batch first.');
      return;
    }

    if (_selectedImage == null) {
      setState(() => _errorMessage = 'Please capture or choose an onion heap photo.');
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
      _analysisStep = 'Uploading heap photo to inference pipeline...';
    });

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() => _analysisStep = 'Extracting onion instance boundaries & contours...');

      final sampleWeight = double.tryParse(_weightCtrl.text.trim()) ?? 15.0;

      final res = await batchProvider.runHeapAnalysis(
        imageFile: _selectedImage!,
        batchId: activeBatchId,
        sampleWeightKg: sampleWeight,
      );

      setState(() => _analysisStep = 'Classifying defects: fungal rot, sprouted, damage...');
      await Future.delayed(const Duration(milliseconds: 250));

      setState(() {
        _result = res;
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  String _deriveGrade(HeapAnalysisResult res) {
    if (res.grades.rejectPercent > 12.0) {
      return 'Reject';
    } else if (res.grades.gradeAPercent >= 65.0) {
      return 'Grade A';
    } else {
      return 'Grade B';
    }
  }

  Future<void> _certifyBatch() async {
    if (_result == null) return;
    final batchProvider = context.read<OnionBatchProvider>();
    final activeBatchId = _selectedBatchId ?? (batchProvider.batches.isNotEmpty ? batchProvider.batches.first.id : null);
    if (activeBatchId == null) return;

    final batch = batchProvider.batches.firstWhere((b) => b.id == activeBatchId);
    final assignedGrade = _deriveGrade(_result!);

    await batchProvider.certifyInspection(
      batch: batch,
      analysis: _result!,
      assignedGrade: assignedGrade,
      sampleWeightKg: double.tryParse(_weightCtrl.text.trim()) ?? 15.0,
      notes: _notesCtrl.text.trim(),
      inspectorName: _inspectorNameCtrl.text.trim(),
      inspectorId: _inspectorIdCtrl.text.trim(),
      imageBase64: _selectedImage?.path,
    );

    if (mounted) {
      final latestInsp = batchProvider.inspections.first;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lot certified! Certificate generated.')),
      );
      context.pushReplacement('${AppRoutes.certificate}?certNumber=${latestInsp.verificationToken}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final batchProvider = context.watch<OnionBatchProvider>();
    final batches = batchProvider.batches;

    if (_selectedBatchId == null && batches.isNotEmpty) {
      _selectedBatchId = batches.first.id;
    }

    final selectedBatch = batches.cast<OnionBatch?>().firstWhere(
          (b) => b?.id == _selectedBatchId,
          orElse: () => null,
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Heap Analysis & Grading')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Target Lot Selector Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Target Mandi Lot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    if (batches.isEmpty)
                      const Text('No batches registered. Please register a batch first.', style: TextStyle(color: Colors.red, fontSize: 12))
                    else
                      DropdownButtonFormField<String>(
                        value: _selectedBatchId,
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        items: batches.map((b) {
                          return DropdownMenuItem<String>(
                            value: b.id,
                            child: Text(
                              '${b.batchNumber} — ${b.farmerName} (${b.weightQuintals} Qtl)',
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedBatchId = val),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Camera / Image capture card
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.slate.shade100,
                    child: _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.cover)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_photo_alternate_outlined, size: 48, color: OnionSureColors.textMuted),
                              const SizedBox(height: 8),
                              const Text('Capture Mandi heap surface photo', style: TextStyle(fontSize: 13, color: OnionSureColors.textMuted)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.camera_alt, size: 16),
                                    label: const Text('Camera'),
                                    style: ElevatedButton.styleFrom(minimumSize: const Size(110, 38)),
                                    onPressed: () => _pickImage(ImageSource.camera),
                                  ),
                                  const SizedBox(width: 10),
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.photo_library, size: 16),
                                    label: const Text('Gallery'),
                                    style: OutlinedButton.styleFrom(minimumSize: const Size(110, 38)),
                                    onPressed: () => _pickImage(ImageSource.gallery),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                  if (_selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Heap photo selected', style: TextStyle(fontSize: 12, color: OnionSureColors.textMuted)),
                          TextButton(
                            onPressed: () => _pickImage(ImageSource.camera),
                            child: const Text('Retake Photo'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Inspector Parameters Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sampling & Inspector Parameters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inspectorNameCtrl,
                            decoration: const InputDecoration(labelText: 'Inspector Name', isDense: true),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _inspectorIdCtrl,
                            decoration: const InputDecoration(labelText: 'APMC Badge ID', isDense: true),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _weightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Sample Sub-lot Weight (kg)', isDense: true),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _notesCtrl,
                      decoration: const InputDecoration(labelText: 'Yard Observations / Scale Health', isDense: true),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            if (_isAnalyzing)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: OnionSureColors.primaryGreen),
                      const SizedBox(height: 12),
                      Text(
                        _analysisStep,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Run Computer Vision Heap Analysis'),
                onPressed: _runAnalysis,
              ),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade900, fontSize: 12)),
                ),
              ),

            // Results Section
            if (_result != null) ...[
              const SizedBox(height: 20),
              _GradingResultCard(result: _result!, batch: selectedBatch!),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                icon: const Icon(Icons.verified),
                style: ElevatedButton.styleFrom(backgroundColor: OnionSureColors.primaryDark),
                label: const Text('Certify & Issue AGMARK Digital Certificate'),
                onPressed: _certifyBatch,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GradingResultCard extends StatelessWidget {
  final HeapAnalysisResult result;
  final OnionBatch batch;

  const _GradingResultCard({required this.result, required this.batch});

  @override
  Widget build(BuildContext context) {
    final gradeA = result.grades.gradeAPercent;
    final gradeB = result.grades.gradeBPercent;
    final reject = result.grades.rejectPercent;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AI Heap Estimation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      'Detected ${result.visibleOnionCount} bulbs in ${result.processingTimeMs}ms (${(result.overallConfidence * 100).toInt()}% conf)',
                      style: const TextStyle(fontSize: 11, color: OnionSureColors.textMuted),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: OnionSureColors.primaryGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: OnionSureColors.primaryGreen),
                  ),
                  child: Text(
                    gradeA >= 65 ? 'GRADE A' : reject > 12 ? 'REJECT' : 'GRADE B',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: OnionSureColors.primaryDark, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Grade percentages
            Row(
              children: [
                Expanded(
                  child: _GradeTile(
                    label: 'Grade A (Export)',
                    percent: gradeA,
                    color: OnionSureColors.gradeA,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _GradeTile(
                    label: 'Grade B (Mandi)',
                    percent: gradeB,
                    color: OnionSureColors.gradeB,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _GradeTile(
                    label: 'Reject / Decay',
                    percent: reject,
                    color: OnionSureColors.gradeReject,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Defect Counts
            const Text('Defect Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _DefectBadge(label: 'Healthy', count: result.defects.healthy, color: Colors.green),
                _DefectBadge(label: 'Damaged', count: result.defects.damaged, color: Colors.orange),
                _DefectBadge(label: 'Rotten', count: result.defects.rotten, color: Colors.red),
                _DefectBadge(label: 'Sprouted', count: result.defects.sprouted, color: Colors.amber.shade800),
                _DefectBadge(label: 'Undersized', count: result.defects.undersized, color: Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GradeTile extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;

  const _GradeTile({required this.label, required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text('${percent.toStringAsFixed(1)}%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}

class _DefectBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _DefectBadge({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text('$label: $count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
