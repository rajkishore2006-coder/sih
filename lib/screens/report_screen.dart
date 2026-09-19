import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:onion_quality_app/models/batch_model.dart';
import 'package:onion_quality_app/models/inspection_model.dart';
import 'package:onion_quality_app/services/pdf_report_service.dart';

class ReportScreen extends StatefulWidget {
  final OnionBatch batch;
  final OnionInspection inspection;

  const ReportScreen({
    super.key,
    required this.batch,
    required this.inspection,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  Uint8List? _pdfBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    final bytes = await PdfReportService.generateQualityReportPdf(
      batch: widget.batch,
      inspection: widget.inspection,
    );
    if (mounted) {
      setState(() {
        _pdfBytes = bytes;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Quality Certificate', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          if (_pdfBytes != null)
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Share Certificate',
              onPressed: () {
                PdfReportService.printOrShareReport(
                  _pdfBytes!,
                  '${widget.batch.batchNumber}_Certificate.pdf',
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C2D12)),
            )
          : Column(
              children: [
                // Top Verification Ribbon
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: Colors.deepPurple.shade50,
                  child: Row(
                    children: [
                      const Icon(Icons.verified, size: 18, color: Colors.deepPurple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Verification Token: ${widget.inspection.verificationToken} • Signed by ${widget.inspection.inspectorName}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // PDF Interactive Preview
                Expanded(
                  child: PdfPreview(
                    build: (format) => _pdfBytes!,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    canDebug: false,
                    actions: const [],
                  ),
                ),
              ],
            ),
    );
  }
}
