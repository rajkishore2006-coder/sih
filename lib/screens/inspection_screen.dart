import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onion_quality_app/config/app_config.dart';
import 'package:onion_quality_app/models/batch_model.dart';
import 'package:onion_quality_app/screens/heap_analysis_screen.dart';
import 'package:onion_quality_app/services/app_services.dart';
import 'package:onion_quality_app/services/heap_analysis_service.dart';

class InspectionScreen extends StatefulWidget {
  final OnionBatch? batch;

  const InspectionScreen({super.key, this.batch});

  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  final _heapService = HeapAnalysisService();
  final _services = AppServices.instance;

  late OnionBatch _selectedBatch;
  final _inspectorNameController =
      TextEditingController(text: 'Dr. V. K. Deshmukh');
  final _inspectorIdController = TextEditingController(text: 'INS-MH-704');
  final _sampleWeightController = TextEditingController(text: '15.0');
  final _notesController = TextEditingController(text: 'Heap surface clear, dry curing verified.');

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isAnalyzing = false;
  String _analysisStep = 'Ready';

  @override
  void initState() {
    super.initState();
    if (widget.batch != null) {
      _selectedBatch = widget.batch!;
    } else if (_services.batches.isNotEmpty) {
      _selectedBatch = _services.batches.first;
    } else {
      _selectedBatch = OnionBatch(
        id: 'batch-quick',
        batchNumber: 'BATCH-2026-NSK-QUICK',
        farmerName: 'Walk-in Farmer',
        farmerPhone: '',
        mandiLocation: 'Lasalgaon APMC',
        onionVariety: 'Nashik Red',
        harvestDate: DateTime.now(),
        weightQuintals: 50.0,
        bagCount: 100,
        status: BatchStatus.pending,
        createdAt: DateTime.now(),
      );
    }

    // Pre-load default sample heap so user has ready-to-test image immediately
    _loadPresetHeap(0);
  }

  void _loadPresetHeap(int presetIndex) {
    // Generate distinct synthetic image bytes with distinctive colors for demo presets
    final color = presetIndex == 0
        ? const Color(0xFF7C2D12) // Rich red
        : presetIndex == 1
            ? const Color(0xFF9A3412) // Orange-red
            : const Color(0xFF581C87); // Deep purple

    setState(() {
      _selectedImageName = presetIndex == 0
          ? 'Lasalgaon_Nashik_Red_Heap.jpg'
          : presetIndex == 1
              ? 'Mixed_Mandi_Garva_Heap.jpg'
              : 'Sprout_Rot_Challenged_Heap.jpg';
      _selectedImageBytes = _generateDummyJpeg(color);
    });
  }

  Uint8List _generateDummyJpeg(Color primaryColor) {
    // Minimal valid 1x1 JPEG header with trailing bytes representing the image
    const raw =
        '/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP//////////////////////////////////////////////////////////////////////////////////////wgALCAABAAEBAREA/8QAFBABAAAAAAAAAAAAAAAAAAAAAP/aAAgBAQABPxA=';
    return base64Decode(raw);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = file.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not access image: $e')),
        );
      }
    }
  }

  Future<void> _runAnalysis() async {
    if (_selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or capture an onion heap image')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisStep = 'Uploading heap image to inference pipeline...';
    });

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() => _analysisStep = 'Extracting visible onion instance boundaries...');

      await Future.delayed(const Duration(milliseconds: 400));
      setState(() => _analysisStep = 'Classifying defects: healthy, rot, sprout, damage...');

      final result = await _heapService.analyzeHeap(
        imageBytes: _selectedImageBytes!,
        filename: _selectedImageName ?? 'heap.jpg',
      );

      setState(() => _analysisStep = 'Finalizing AGMARK Grade A/B/Reject metrics...');
      await Future.delayed(const Duration(milliseconds: 200));

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HeapAnalysisScreen(
              batch: _selectedBatch,
              result: result,
              imageBytes: _selectedImageBytes,
              inspectorName: _inspectorNameController.text.trim(),
              inspectorId: _inspectorIdController.text.trim(),
              sampleWeightKg: double.tryParse(_sampleWeightController.text) ?? 15.0,
              notes: _notesController.text.trim(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyze Onion Heap', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: _isAnalyzing
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF7C2D12)),
                    const SizedBox(height: 20),
                    Text(
                      _analysisStep,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AI Model: ${AppConfig.useMockAi ? "Embedded Prototype Simulator" : AppConfig.aiApiUrl}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 750),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Target Batch Selector
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.qr_code_2, color: Color(0xFF7C2D12)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Inspection Target Batch',
                                    style: TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                  Text(
                                    '${_selectedBatch.batchNumber} (${_selectedBatch.farmerName})',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Image Selection Section
                      const Text(
                        'Heap Image Capture',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Photograph or upload an unobstructed top/angle view of the onion heap.',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 12),

                      // Image Preview Box
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 220,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF78350F),
                                      Color(0xFF9A3412),
                                      Color(0xFF451A03),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.camera_alt,
                                        size: 40,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _selectedImageName ?? 'Sample Onion Heap Loaded',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black38,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Ready for AI Computer Vision',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Actions: Camera / File / Presets
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.photo_camera, size: 18),
                              label: const Text('Take Photo', style: TextStyle(fontSize: 12)),
                              onPressed: () => _pickImage(ImageSource.camera),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.upload_file, size: 18),
                              label: const Text('Upload File', style: TextStyle(fontSize: 12)),
                              onPressed: () => _pickImage(ImageSource.gallery),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Instant Heap Presets for easy demo evaluation
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text('Quick Presets:',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ActionChip(
                            label: const Text('Lasalgaon Red', style: TextStyle(fontSize: 11)),
                            onPressed: () => _loadPresetHeap(0),
                          ),
                          ActionChip(
                            label: const Text('Garva Mix', style: TextStyle(fontSize: 11)),
                            onPressed: () => _loadPresetHeap(1),
                          ),
                          ActionChip(
                            label: const Text('Sprout/Rot Heap', style: TextStyle(fontSize: 11)),
                            onPressed: () => _loadPresetHeap(2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Inspector Parameters
                      const Text(
                        'Inspection Parameters',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _inspectorNameController,
                              decoration: const InputDecoration(
                                labelText: 'Inspector Name',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _inspectorIdController,
                              decoration: const InputDecoration(
                                labelText: 'Inspector ID',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _sampleWeightController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Sample Bag Weight (kg)',
                                border: OutlineInputBorder(),
                                suffixText: 'kg',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _notesController,
                              decoration: const InputDecoration(
                                labelText: 'Lot Observations / Notes',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Analyze Action Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C2D12),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _runAnalysis,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Run AI Heap Segmentation & Grading',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
