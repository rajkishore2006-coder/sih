class OnionBatch {
  final String id;
  final String batchNumber;
  final String farmerName;
  final String farmerPhone;
  final String mandiLocation;
  final String onionVariety;
  final String harvestDate;
  final double weightQuintals;
  final int bagCount;
  final String status; // 'pending' | 'inspected' | 'certified' | 'rejected'
  final DateTime createdAt;
  final String? latestGrade;
  final String? qrCodeData;

  OnionBatch({
    required this.id,
    required this.batchNumber,
    required this.farmerName,
    this.farmerPhone = '',
    required this.mandiLocation,
    required this.onionVariety,
    this.harvestDate = '',
    required this.weightQuintals,
    this.bagCount = 1,
    this.status = 'pending',
    required this.createdAt,
    this.latestGrade,
    this.qrCodeData,
  });

  factory OnionBatch.fromJson(Map<String, dynamic> json) {
    return OnionBatch(
      id: json['id'] as String? ?? '',
      batchNumber: json['batchNumber'] as String? ?? json['batch_number'] as String? ?? '',
      farmerName: json['farmerName'] as String? ?? json['farmer_name'] as String? ?? '',
      farmerPhone: json['farmerPhone'] as String? ?? json['farmer_phone'] as String? ?? '',
      mandiLocation: json['mandiLocation'] as String? ?? json['mandi_location'] as String? ?? '',
      onionVariety: json['onionVariety'] as String? ?? json['variety'] as String? ?? 'Nashik Red',
      harvestDate: json['harvestDate'] as String? ?? json['harvest_date'] as String? ?? '',
      weightQuintals: (json['weightQuintals'] as num?)?.toDouble() ??
          (json['total_weight_quintals'] as num?)?.toDouble() ??
          0.0,
      bagCount: json['bagCount'] as int? ?? json['bag_count'] as int? ?? 1,
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : (json['registered_at'] != null
              ? DateTime.tryParse(json['registered_at'] as String) ?? DateTime.now()
              : DateTime.now()),
      latestGrade: json['latestGrade'] as String? ?? json['latest_grade'] as String?,
      qrCodeData: json['qrCodeData'] as String? ?? json['qr_code_data'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'batchNumber': batchNumber,
    'farmerName': farmerName,
    'farmerPhone': farmerPhone,
    'mandiLocation': mandiLocation,
    'onionVariety': onionVariety,
    'harvestDate': harvestDate,
    'weightQuintals': weightQuintals,
    'bagCount': bagCount,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'latestGrade': latestGrade,
    'qrCodeData': qrCodeData,
  };
}
