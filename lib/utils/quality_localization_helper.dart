import 'package:flutter/material.dart';
import 'package:onion_quality_app/l10n/app_localizations.dart';
import 'package:onion_quality_app/models/analysis_models.dart';
import 'package:onion_quality_app/models/batch_model.dart';

class QualityLocalizationHelper {
  static String getLocalizedDefect(BuildContext context, DefectType defect) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return defect.label;
    switch (defect) {
      case DefectType.healthy:
        return l10n.qualityHealthy;
      case DefectType.damaged:
        return l10n.qualityDamaged;
      case DefectType.rotten:
        return l10n.qualityRotten;
      case DefectType.sprouted:
        return l10n.qualitySprouted;
      case DefectType.undersized:
        return l10n.qualityUndersized;
      case DefectType.unknown:
        return l10n.qualityUnknown;
    }
  }

  static String getLocalizedQuality(BuildContext context, String backendValue) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return backendValue;

    switch (backendValue.toLowerCase().trim()) {
      case 'healthy':
        return l10n.qualityHealthy;
      case 'damaged':
        return l10n.qualityDamaged;
      case 'rotten':
        return l10n.qualityRotten;
      case 'sprouted':
        return l10n.qualitySprouted;
      case 'undersized':
        return l10n.qualityUndersized;
      case 'unknown':
        return l10n.qualityUnknown;
      default:
        return backendValue;
    }
  }

  static String getLocalizedBatchStatus(BuildContext context, BatchStatus status) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return status.label;
    switch (status) {
      case BatchStatus.pending:
        return l10n.statusPending;
      case BatchStatus.inspected:
        return l10n.statusInspected;
      case BatchStatus.certified:
        return l10n.statusCertified;
      case BatchStatus.rejected:
        return l10n.statusRejected;
    }
  }

  static String getLocalizedStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return status;

    switch (status.toLowerCase().trim()) {
      case 'pending':
        return l10n.statusPending;
      case 'inspected':
        return l10n.statusInspected;
      case 'certified':
        return l10n.statusCertified;
      case 'rejected':
        return l10n.statusRejected;
      default:
        return status;
    }
  }

  static String getLocalizedQualityGrade(BuildContext context, QualityGrade grade) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return grade.label;
    switch (grade) {
      case QualityGrade.gradeA:
        return l10n.gradeA;
      case QualityGrade.gradeB:
        return l10n.gradeB;
      case QualityGrade.reject:
        return l10n.qualityRotten;
    }
  }

  static String getLocalizedGrade(BuildContext context, String grade) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return 'Grade $grade';

    switch (grade.toUpperCase().trim()) {
      case 'A':
      case 'GRADE A':
        return l10n.gradeA;
      case 'B':
      case 'GRADE B':
        return l10n.gradeB;
      case 'C':
      case 'GRADE C':
      case 'REJECT':
        return l10n.gradeC;
      default:
        return 'Grade $grade';
    }
  }
}
