enum BatchStatus {
  pending('Pending Inspection'),
  inspected('Inspected'),
  certified('Certified Grade'),
  rejected('Rejected');

  final String label;
  const BatchStatus(this.label);
}

class OnionBatch {
  final String id;
  final String batchNumber;
  final String farmerName;
  final String farmerPhone;
  final String mandiLocation;
  final String onionVariety;
  final DateTime harvestDate;
  final double weightQuintals;
  final int bagCount;
  final BatchStatus status;
  final DateTime createdAt;
  final String? latestGrade;
  final String? qrCodeData;

  const OnionBatch({
    required this.id,
    required this.batchNumber,
    required this.farmerName,
    required this.farmerPhone,
    required this.mandiLocation,
    required this.onionVariety,
    required this.harvestDate,
    required this.weightQuintals,
    required this.bagCount,
    required this.status,
    required this.createdAt,
    this.latestGrade,
    this.qrCodeData,
  });

  OnionBatch copyWith({
    String? id,
    String? batchNumber,
    String? farmerName,
    String? farmerPhone,
    String? mandiLocation,
    String? onionVariety,
    DateTime? harvestDate,
    double? weightQuintals,
    int? bagCount,
    BatchStatus? status,
    DateTime? createdAt,
    String? latestGrade,
    String? qrCodeData,
  }) {
    return OnionBatch(
      id: id ?? this.id,
      batchNumber: batchNumber ?? this.batchNumber,
      farmerName: farmerName ?? this.farmerName,
      farmerPhone: farmerPhone ?? this.farmerPhone,
      mandiLocation: mandiLocation ?? this.mandiLocation,
      onionVariety: onionVariety ?? this.onionVariety,
      harvestDate: harvestDate ?? this.harvestDate,
      weightQuintals: weightQuintals ?? this.weightQuintals,
      bagCount: bagCount ?? this.bagCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      latestGrade: latestGrade ?? this.latestGrade,
      qrCodeData: qrCodeData ?? this.qrCodeData,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'batchNumber': batchNumber,
        'farmerName': farmerName,
        'farmerPhone': farmerPhone,
        'mandiLocation': mandiLocation,
        'onionVariety': onionVariety,
        'harvestDate': harvestDate.toIso8601String(),
        'weightQuintals': weightQuintals,
        'bagCount': bagCount,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'latestGrade': latestGrade,
        'qrCodeData': qrCodeData,
      };

  factory OnionBatch.fromJson(Map<String, dynamic> json) {
    return OnionBatch(
      id: json['id'] as String,
      batchNumber: json['batchNumber'] as String,
      farmerName: json['farmerName'] as String,
      farmerPhone: json['farmerPhone'] as String? ?? '',
      mandiLocation: json['mandiLocation'] as String,
      onionVariety: json['onionVariety'] as String,
      harvestDate: DateTime.parse(json['harvestDate'] as String),
      weightQuintals: (json['weightQuintals'] as num).toDouble(),
      bagCount: json['bagCount'] as int,
      status: BatchStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BatchStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      latestGrade: json['latestGrade'] as String?,
      qrCodeData: json['qrCodeData'] as String?,
    );
  }
}
