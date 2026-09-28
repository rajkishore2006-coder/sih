import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _certCtrl = TextEditingController();
  bool _isChecking = false;
  VerificationResult? _result;

  Future<void> _verify() async {
    final certNo = _certCtrl.text.trim();
    if (certNo.isEmpty) return;

    setState(() {
      _isChecking = true;
      _result = null;
    });

    try {
      final api = context.read<ApiService>();
      final res = await api.verifyCertificate(certNo);
      setState(() => _result = res);
    } catch (_) {
      setState(() {
        _result = VerificationResult(
          isValid: false,
          status: 'error',
          message: 'Unable to reach verification gateway',
        );
      });
    } finally {
      setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Certificate')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _certCtrl,
              decoration: const InputDecoration(
                labelText: 'Certificate ID or Scan Payload',
                hintText: 'e.g. CERT-BATCH-2026-9812',
                prefixIcon: Icon(Icons.qr_code),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isChecking ? null : _verify,
              child: Text(_isChecking ? 'Verifying...' : 'Verify on Ledger'),
            ),
            const SizedBox(height: 24),
            if (_result != null)
              Card(
                color: _result!.isValid ? Colors.green.shade50 : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        _result!.isValid ? Icons.verified : Icons.error_outline,
                        color: _result!.isValid ? Colors.green : Colors.red,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _result!.isValid
                              ? 'Certificate Verified & Authentic'
                              : 'Verification Failed: ${_result!.message ?? _result!.status}',
                          style: TextStyle(
                            color: _result!.isValid ? Colors.green.shade900 : Colors.red.shade900,
                            fontWeight: FontWeight.bold,
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
    );
  }
}
