import 'package:flutter/material.dart';
import 'package:onion_quality_app/models/analysis_models.dart';

class QualityDistributionWidget extends StatelessWidget {
  final GradeDistributionModel distribution;
  final int visibleCount;

  const QualityDistributionWidget({
    super.key,
    required this.distribution,
    required this.visibleCount,
  });

  @override
  Widget build(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Digital Quality Grade Distribution',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$visibleCount bulbs visible',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stacked visual ratio bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 14,
              child: Row(
                children: [
                  if (distribution.gradeAPercent > 0)
                    Expanded(
                      flex: (distribution.gradeAPercent * 10).toInt(),
                      child: Container(color: const Color(0xFF16A34A)),
                    ),
                  if (distribution.gradeBPercent > 0)
                    Expanded(
                      flex: (distribution.gradeBPercent * 10).toInt(),
                      child: Container(color: const Color(0xFFCA8A04)),
                    ),
                  if (distribution.rejectPercent > 0)
                    Expanded(
                      flex: (distribution.rejectPercent * 10).toInt(),
                      child: Container(color: const Color(0xFFDC2626)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3 Metric Cards: Grade A, Grade B, Reject
          Row(
            children: [
              Expanded(
                child: _GradeTile(
                  label: 'Grade A (Export)',
                  percentage: distribution.gradeAPercent,
                  color: const Color(0xFF16A34A),
                  icon: Icons.check_circle_outline,
                  subtext: 'Target >= 70%',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _GradeTile(
                  label: 'Grade B (Local)',
                  percentage: distribution.gradeBPercent,
                  color: const Color(0xFFCA8A04),
                  icon: Icons.info_outline,
                  subtext: 'Minor defects',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _GradeTile(
                  label: 'Reject / Waste',
                  percentage: distribution.rejectPercent,
                  color: const Color(0xFFDC2626),
                  icon: Icons.warning_amber_rounded,
                  subtext: 'Rot / Sprout',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradeTile extends StatelessWidget {
  final String label;
  final double percentage;
  final Color color;
  final IconData icon;
  final String subtext;

  const _GradeTile({
    required this.label,
    required this.percentage,
    required this.color,
    required this.icon,
    required this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        border: Border.all(color: color.withOpacity(0.25)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 9.5,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
