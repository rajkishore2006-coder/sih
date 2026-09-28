import 'batch.dart';
import 'inspection.dart';

class Certificate {
  final String certificateNumber;
  final String batchNumber;
  final String farmerName;
  final String farmerPhone;
  final String mandiLocation;
  final String variety;
  final double totalWeightQuintals;
  final int bagCount;
  final String assignedGrade;
  final double gradeAPercent;
  final double gradeBPercent;
  final double rejectPercent;
  final double overallConfidence;
  final DateTime issuedAt;
  final String inspectorName;
  final String inspectorId;
  final String verificationUrl;
  final String qrCodePayload;

  Certificate({
    required this.certificateNumber,
    required this.batchNumber,
    required this.farmerName,
    required this.farmerPhone,
    required this.mandiLocation,
    required this.variety,
    required this.totalWeightQuintals,
    required this.bagCount,
    required this.assignedGrade,
    required this.gradeAPercent,
    required this.gradeBPercent,
    required this.rejectPercent,
    required this.overallConfidence,
    required this.issuedAt,
    required this.inspectorName,
    required this.inspectorId,
    required this.verificationUrl,
    required this.qrCodePayload,
  });

  factory Certificate.fromBatchAndInspection({
    required OnionBatch batch,
    required OnionInspection inspection,
    String baseUrl = 'https://onionsure.gov.in',
  }) {
    final certNo = inspection.verificationToken.isNotEmpty
        ? inspection.verificationToken
        : 'VERIF-${batch.batchNumber}-${inspection.timestamp.substring(0, 10)}';

    final verifyUrl = '$baseUrl/verify?token=$certNo&batch=${batch.batchNumber}';

    return Certificate(
      certificateNumber: certNo,
      batchNumber: batch.batchNumber,
      farmerName: batch.farmerName,
      farmerPhone: batch.farmerPhone,
      mandiLocation: batch.mandiLocation,
      variety: batch.onionVariety,
      totalWeightQuintals: batch.weightQuintals,
      bagCount: batch.bagCount,
      assignedGrade: inspection.assignedGrade,
      gradeAPercent: inspection.analysis.grades.gradeAPercent,
      gradeBPercent: inspection.analysis.grades.gradeBPercent,
      rejectPercent: inspection.analysis.grades.rejectPercent,
      overallConfidence: inspection.analysis.overallConfidence,
      issuedAt: DateTime.tryParse(inspection.timestamp) ?? DateTime.now(),
      inspectorName: inspection.inspectorName,
      inspectorId: inspection.inspectorId,
      verificationUrl: verifyUrl,
      qrCodePayload: certNo,
    );
  }

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      certificateNumber: json['certificateNumber'] as String? ?? json['certificate_number'] as String? ?? '',
      batchNumber: json['batchNumber'] as String? ?? json['batch_number'] as String? ?? '',
      farmerName: json['farmerName'] as String? ?? json['farmer_name'] as String? ?? '',
      farmerPhone: json['farmerPhone'] as String? ?? json['farmer_phone'] as String? ?? '',
      mandiLocation: json['mandiLocation'] as String? ?? json['mandi_location'] as String? ?? '',
      variety: json['variety'] as String? ?? json['onionVariety'] as String? ?? 'Nashik Red',
      totalWeightQuintals: (json['totalWeightQuintals'] as num?)?.toDouble() ?? 0.0,
      bagCount: json['bagCount'] as int? ?? 1,
      assignedGrade: json['assignedGrade'] as String? ?? 'Grade A',
      gradeAPercent: (json['gradeAPercent'] as num?)?.toDouble() ?? 70.0,
      gradeBPercent: (json['gradeBPercent'] as num?)?.toDouble() ?? 25.0,
      rejectPercent: (json['rejectPercent'] as num?)?.toDouble() ?? 5.0,
      overallConfidence: (json['overallConfidence'] as num?)?.toDouble() ?? 0.95,
      issuedAt: json['issuedAt'] != null
          ? DateTime.tryParse(json['issuedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      inspectorName: json['inspectorName'] as String? ?? '',
      inspectorId: json['inspectorId'] as String? ?? '',
      verificationUrl: json['verificationUrl'] as String? ?? '',
      qrCodePayload: json['qrCodePayload'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'certificateNumber': certificateNumber,
    'batchNumber': batchNumber,
    'farmerName': farmerName,
    'farmerPhone': farmerPhone,
    'mandiLocation': mandiLocation,
    'variety': variety,
    'totalWeightQuintals': totalWeightQuintals,
    'bagCount': bagCount,
    'assignedGrade': assignedGrade,
    'gradeAPercent': gradeAPercent,
    'gradeBPercent': gradeBPercent,
    'rejectPercent': rejectPercent,
    'overallConfidence': overallConfidence,
    'issuedAt': issuedAt.toIso8601String(),
    'inspectorName': inspectorName,
    'inspectorId': inspectorId,
    'verificationUrl': verificationUrl,
    'qrCodePayload': qrCodePayload,
  };
}

class VerificationResult {
  final bool isValid;
  final String status;
  final Certificate? certificate;
  final String? message;

  VerificationResult({
    required this.isValid,
    required this.status,
    this.certificate,
    this.message,
  });

  factory VerificationResult.fromJson(Map<String, dynamic> json) {
    return VerificationResult(
      isValid: json['is_valid'] as bool? ?? json['isValid'] as bool? ?? false,
      status: json['status'] as String? ?? 'not_found',
      certificate: json['certificate'] != null
          ? Certificate.fromJson(json['certificate'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
    );
  }
}
