import 'package:flutter/material.dart';
import 'package:onion_quality_app/models/inspection_model.dart';
import 'package:onion_quality_app/services/app_services.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final _queryController = TextEditingController(text: 'VERIF-NSK-8921-A');
  OnionInspection? _verifiedInspection;
  bool _searched = false;

  void _verify() {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    final found = AppServices.instance.verifyInspection(query);
    setState(() {
      _verifiedInspection = found;
      _searched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('e-NAM Quality Certificate Verification',
            style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Explanation Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Public Certificate Verification',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Enter the verification token printed beneath the report QR code to confirm grading authenticity and tamper-proof records.',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _queryController,
                              decoration: const InputDecoration(
                                hintText: 'e.g. VERIF-NSK-8921-A',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.verified_outlined),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7C2D12),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                            ),
                            onPressed: _verify,
                            child: const Text('Verify'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Verification Results
                if (_searched) ...[
                  if (_verifiedInspection != null)
                    _buildVerifiedCard(_verifiedInspection!)
                  else
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.gpp_bad, size: 40, color: Colors.red.shade700),
                          const SizedBox(height: 10),
                          Text(
                            'Certificate Record Not Found',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'The verification token "${_queryController.text}" was not found in the authenticated mandi database.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.red.shade800),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerifiedCard(OnionInspection ins) {
    final analysis = ins.analysis;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF16A34A).withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified,
                  color: Color(0xFF16A34A),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AUTHENTIC QUALITY CERTIFICATE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16A34A),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Token: ${ins.verificationToken}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ins.assignedGrade.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          _dataRow('Batch Number', ins.batchNumber),
          _dataRow('Certified Inspector', '${ins.inspectorName} (${ins.inspectorId})'),
          _dataRow('Inspection Timestamp', ins.timestamp.toString().substring(0, 16)),
          _dataRow('Visible Sample Count', '${analysis.visibleOnionCount} bulbs scanned'),
          _dataRow('Grade A Ratio', '${analysis.grades.gradeAPercent}%'),
          _dataRow('Grade B Ratio', '${analysis.grades.gradeBPercent}%'),
          _dataRow('Rejection Rate', '${analysis.grades.rejectPercent}%'),
          _dataRow('Model Confidence', '${(analysis.overallConfidence * 100).toInt()}%'),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Text(
              analysis.disclaimer,
              style: TextStyle(fontSize: 10.5, color: Colors.amber.shade900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          Text(value,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}
