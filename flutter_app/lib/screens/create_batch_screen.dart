import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/batch_provider.dart';

class CreateBatchScreen extends StatefulWidget {
  const CreateBatchScreen({super.key});

  @override
  State<CreateBatchScreen> createState() => _CreateBatchScreenState();
}

class _CreateBatchScreenState extends State<CreateBatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _batchNumberCtrl = TextEditingController();
  final _farmerCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _mandiCtrl = TextEditingController(text: 'Lasalgaon APMC, Nashik');
  final _varietyCtrl = TextEditingController(text: 'Nashik Red (Rabi)');
  final _weightCtrl = TextEditingController(text: '45.0');
  final _bagsCtrl = TextEditingController(text: '90');
  final _harvestDateCtrl = TextEditingController(text: DateTime.now().toIso8601String().substring(0, 10));

  @override
  void initState() {
    super.initState();
    final rand = 100 + (DateTime.now().millisecondsSinceEpoch % 900);
    _batchNumberCtrl.text = 'LOT-NSK-2026-$rand';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Mandi Batch')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Lot Traceability & Origin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _batchNumberCtrl,
                        decoration: const InputDecoration(labelText: 'Digital Lot Identifier (Batch Number)'),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _farmerCtrl,
                        decoration: const InputDecoration(labelText: 'Farmer / Lot Owner Name', hintText: 'e.g. Ramesh Patil'),
                        validator: (v) => v == null || v.isEmpty ? 'Enter farmer name' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Mobile Number', hintText: '+91 98231 00000'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _mandiCtrl,
                        decoration: const InputDecoration(labelText: 'APMC Mandi Yard Location'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Crop & Lot Quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _varietyCtrl,
                        decoration: const InputDecoration(labelText: 'Onion Variety'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _weightCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Weight (Quintals)'),
                              validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _bagsCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Bag Count'),
                              validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _harvestDateCtrl,
                        decoration: const InputDecoration(labelText: 'Harvest / Curing Date (YYYY-MM-DD)'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_2),
                label: const Text('Register Lot & Generate QR Payload'),
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    await context.read<OnionBatchProvider>().createBatch(
                          batchNumber: _batchNumberCtrl.text.trim(),
                          farmerName: _farmerCtrl.text.trim(),
                          farmerPhone: _phoneCtrl.text.trim(),
                          mandiLocation: _mandiCtrl.text.trim(),
                          onionVariety: _varietyCtrl.text.trim(),
                          weightQuintals: double.parse(_weightCtrl.text.trim()),
                          bagCount: int.parse(_bagsCtrl.text.trim()),
                          harvestDate: _harvestDateCtrl.text.trim(),
                        );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lot registered into Mandi ledger!')),
                      );
                      context.pop();
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
