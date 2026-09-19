import 'package:flutter/material.dart';
import 'package:onion_quality_app/models/analysis_models.dart';

class DefectBreakdownCard extends StatelessWidget {
  final DefectCountsModel defects;

  const DefectBreakdownCard({super.key, required this.defects});

  @override
  Widget build(BuildContext context) {
    final total = defects.total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Visible Defect Breakdown',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip('Healthy', defects.healthy, total, const Color(0xFF16A34A)),
              _chip('Damaged / Bruised', defects.damaged, total, const Color(0xFFEA580C)),
              _chip('Rotten / Fungal', defects.rotten, total, const Color(0xFFDC2626)),
              _chip('Sprouted', defects.sprouted, total, const Color(0xFFCA8A04)),
              _chip('Undersized (<40mm)', defects.undersized, total, const Color(0xFF9333EA)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String name, int count, int total, Color color) {
    final pct = total > 0 ? ((count / total) * 100).toStringAsFixed(1) : '0';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$count ($pct%)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
