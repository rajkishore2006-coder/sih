import 'dart:math';
import 'package:flutter/material.dart';
import 'package:onion_quality_app/models/batch_model.dart';
import 'package:onion_quality_app/screens/batch_detail_screen.dart';
import 'package:onion_quality_app/services/app_services.dart';

class CreateBatchScreen extends StatefulWidget {
  const CreateBatchScreen({super.key});

  @override
  State<CreateBatchScreen> createState() => _CreateBatchScreenState();
}

class _CreateBatchScreenState extends State<CreateBatchScreen> {
  final _formKey = GlobalKey<FormState>();

  final _farmerNameController = TextEditingController(text: 'Dattatray Shinde');
  final _farmerPhoneController = TextEditingController(text: '+91 98901 23456');
  final _weightController = TextEditingController(text: '95.0');
  final _bagCountController = TextEditingController(text: '190');

  String _mandiLocation = 'Lasalgaon APMC, Nashik';
  String _onionVariety = 'Nashik Red (Garva)';
  DateTime _harvestDate = DateTime.now().subtract(const Duration(days: 3));

  final List<String> _mandiLocations = [
    'Lasalgaon APMC, Nashik',
    'Pimpalgaon Baswant APMC',
    'Yeola Mandi Yard',
    'Kalwan APMC Yard',
    'Pune Gultekdi Market Yard',
    'Solapur Onion Market',
  ];

  final List<String> _varieties = [
    'Nashik Red (Garva)',
    'Rangda Medium',
    'Pol Early Red',
    'White Onion (Dehydration)',
    'Yellow Spanish Hybrid',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Onion Batch', style: TextStyle(fontSize: 17)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C2D12).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF7C2D12).withOpacity(0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.inventory, color: Color(0xFF7C2D12), size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Assign a digital batch record to the onion arrival. A traceable QR code will be generated for mandi tracking.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF7C2D12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Farmer Details
                  const Text('Farmer & Lot Information',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _farmerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Farmer / Trader Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Farmer name is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _farmerPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Mobile Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mandi Location & Variety
                  const Text('Mandi & Crop Specification',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _mandiLocation,
                    decoration: const InputDecoration(
                      labelText: 'Mandi APMC Yard',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    items: _mandiLocations
                        .map((loc) => DropdownMenuItem(value: loc, child: Text(loc, style: const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _mandiLocation = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _onionVariety,
                    decoration: const InputDecoration(
                      labelText: 'Onion Variety',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.eco_outlined),
                    ),
                    items: _varieties
                        .map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _onionVariety = v);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Weight and Bags
                  const Text('Lot Volume',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Weight (Quintals)',
                            border: OutlineInputBorder(),
                            suffixText: 'Qtl',
                          ),
                          validator: (v) {
                            if (v == null || double.tryParse(v) == null) {
                              return 'Enter valid weight';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _bagCountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Bag Count',
                            border: OutlineInputBorder(),
                            suffixText: 'Bags',
                          ),
                          validator: (v) {
                            if (v == null || int.tryParse(v) == null) {
                              return 'Enter bag count';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C2D12),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _submitBatch,
                    child: const Text(
                      'Create Batch & Generate QR',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitBatch() {
    if (!_formKey.currentState!.validate()) return;

    final randCode = Random().nextInt(900) + 100;
    final batchNum = 'BATCH-2026-NSK-$randCode';
    final batchId = 'batch-$randCode';

    final batch = OnionBatch(
      id: batchId,
      batchNumber: batchNum,
      farmerName: _farmerNameController.text.trim(),
      farmerPhone: _farmerPhoneController.text.trim(),
      mandiLocation: _mandiLocation,
      onionVariety: _onionVariety,
      harvestDate: _harvestDate,
      weightQuintals: double.parse(_weightController.text),
      bagCount: int.parse(_bagCountController.text),
      status: BatchStatus.pending,
      createdAt: DateTime.now(),
      qrCodeData: 'ONION-BATCH:$batchNum',
    );

    AppServices.instance.addBatch(batch);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BatchDetailScreen(batchId: batch.id),
      ),
    );
  }
}
