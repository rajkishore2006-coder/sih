import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OnionGradeBadge extends StatelessWidget {
  final String grade;

  const OnionGradeBadge({super.key, required this.grade});

  Color _getBadgeColor() {
    switch (grade.toLowerCase()) {
      case 'grade a':
      case 'a':
        return const Color(0xFF16A34A);
      case 'grade b':
      case 'b':
        return const Color(0xFF2563EB);
      case 'grade c':
      case 'c':
        return const Color(0xFFD97706);
      case 'reject':
      default:
        return const Color(0xFFDC2626);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getBadgeColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        grade.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class OnionFormatters {
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  static String formatWeight(double quintals) {
    return '${quintals.toStringAsFixed(1)} Qtl (${(quintals * 100).toStringAsFixed(0)} kg)';
  }
}
