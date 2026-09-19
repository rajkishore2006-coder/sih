import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:onion_quality_app/models/batch_model.dart';
import 'package:onion_quality_app/models/inspection_model.dart';

class PdfReportService {
  static Future<Uint8List> generateQualityReportPdf({
    required OnionBatch batch,
    required OnionInspection inspection,
  }) async {
    final pdf = pw.Document();

    final analysis = inspection.analysis;
    final grades = analysis.grades;
    final defects = analysis.defects;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'ONIONSURE DIGITAL QUALITY CERTIFICATE',
                        style: pw.TextStyle(
                          fontSize: 15,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.deepPurple900,
                        ),
                      ),
                      pw.Text(
                        'SIH26031: AI-Powered Smart Onion Batch Grading',
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        'Accredited Mandi APMC Inspection Record',
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: pw.BoxDecoration(
                      color: inspection.assignedGrade.name.contains('A')
                          ? PdfColors.green800
                          : inspection.assignedGrade.name.contains('B')
                              ? PdfColors.amber800
                              : PdfColors.red800,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text(
                      inspection.assignedGrade.label.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ],
              ),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 10),

              // Batch and Inspection Details Table
              pw.Text(
                'BATCH & LOT REGISTRATION',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey800,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      _tableCell('Batch Number', isHeader: true),
                      _tableCell(batch.batchNumber),
                      _tableCell('Inspection Date', isHeader: true),
                      _tableCell(inspection.timestamp.toString().substring(0, 16)),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _tableCell('Farmer / Lot Owner', isHeader: true),
                      _tableCell(batch.farmerName),
                      _tableCell('Mandi Yard', isHeader: true),
                      _tableCell(batch.mandiLocation),
                    ],
                  ),
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      _tableCell('Onion Variety', isHeader: true),
                      _tableCell(batch.onionVariety),
                      _tableCell('Total Weight', isHeader: true),
                      _tableCell('${batch.weightQuintals} Qtl (${batch.bagCount} Bags)'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _tableCell('Assigned Inspector', isHeader: true),
                      _tableCell('${inspection.inspectorName} (${inspection.inspectorId})'),
                      _tableCell('Verification Token', isHeader: true),
                      _tableCell(inspection.verificationToken),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // Computer Vision Heap Estimation Breakdown
              pw.Text(
                'HEAP INSTANCE SEGMENTATION & DIGITAL GRADING',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey800,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.blueGrey50),
                    children: [
                      _tableCell('Metric', isHeader: true),
                      _tableCell('Computed Value', isHeader: true),
                      _tableCell('Grading Standard Specification', isHeader: true),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _tableCell('Visible Onions Scanned'),
                      _tableCell('${analysis.visibleOnionCount} bulbs'),
                      _tableCell('Surface polygon boundary extraction'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _tableCell('Grade A Quality Ratio'),
                      _tableCell('${grades.gradeAPercent}%'),
                      _tableCell('Standard: >= 70% for Grade A certification'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _tableCell('Grade B Fair Ratio'),
                      _tableCell('${grades.gradeBPercent}%'),
                      _tableCell('Permissible minor skin cuts / size variance'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _tableCell('Rejection / Waste Ratio'),
                      _tableCell('${grades.rejectPercent}%'),
                      _tableCell('Rot, decay, sprouting > 5% restricts trade'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _tableCell('Model Confidence Score'),
                      _tableCell('${(analysis.overallConfidence * 100).toInt()}%'),
                      _tableCell('Multi-contour overlap verification'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // Defect Breakdown
              pw.Text(
                'DEFECT CLASSIFICATION BREAKDOWN',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey800,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _defectBox('Healthy', defects.healthy, PdfColors.green800),
                  _defectBox('Damaged', defects.damaged, PdfColors.orange800),
                  _defectBox('Rotten', defects.rotten, PdfColors.red800),
                  _defectBox('Sprouted', defects.sprouted, PdfColors.amber800),
                  _defectBox('Undersized', defects.undersized, PdfColors.purple800),
                ],
              ),
              pw.SizedBox(height: 16),

              // Mandatory Surface Estimation Disclaimer
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.amber50,
                  border: pw.Border.all(color: PdfColors.amber300, width: 1),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'IMPORTANT ESTIMATION BOUNDARY & MANDI DISCLAIMER',
                      style: pw.TextStyle(
                        fontSize: 8.5,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.amber900,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      analysis.disclaimer,
                      style: const pw.TextStyle(
                        fontSize: 7.5,
                        color: PdfColors.grey800,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Spacer(),

              // Verification QR Code & Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: 'ONIONSURE-VERIFY:${inspection.verificationToken}',
                        width: 70,
                        height: 70,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Scan QR to verify on e-NAM portal',
                        style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        'Token: ${inspection.verificationToken}',
                        style: pw.TextStyle(
                          fontSize: 7.5,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey900,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        width: 130,
                        height: 35,
                        alignment: pw.Alignment.bottomCenter,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(color: PdfColors.grey800, width: 1),
                          ),
                        ),
                        child: pw.Text(
                          inspection.inspectorName,
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Authorized Quality Grader Signature',
                        style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        'Date: ${inspection.timestamp.toString().substring(0, 10)}',
                        style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.grey800 : PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _defectBox(String label, int count, PdfColor color) {
    return pw.Container(
      width: 80,
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 1),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            '$count',
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  static Future<void> printOrShareReport(
    Uint8List pdfBytes,
    String filename,
  ) async {
    await Printing.sharePdf(bytes: pdfBytes, filename: filename);
  }
}
