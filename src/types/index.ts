export type BatchStatus = 'pending' | 'inspected' | 'certified' | 'rejected';

export interface OnionBatch {
  id: string;
  batchNumber: string;
  farmerName: string;
  farmerPhone: string;
  mandiLocation: string;
  onionVariety: string;
  harvestDate: string;
  weightQuintals: number;
  bagCount: number;
  status: BatchStatus;
  createdAt: string;
  latestGrade?: string | null;
  qrCodeData?: string | null;
}

export type DefectType =
  | 'Healthy'
  | 'Damaged'
  | 'Rotten'
  | 'Sprouted'
  | 'Undersized'
  | 'Unknown';

export interface DefectMeta {
  label: DefectType;
  description: string;
  color: string;
}

export const DEFECT_DETAILS: Record<DefectType, { description: string; color: string }> = {
  Healthy: {
    description: 'No visual defects detected, intact outer tunic',
    color: '#16A34A', // Green
  },
  Damaged: {
    description: 'Cuts, punctures, mechanical bruises or peeling',
    color: '#EA580C', // Orange
  },
  Rotten: {
    description: 'Fungal decay, soft rot, or dark discoloration',
    color: '#DC2626', // Red
  },
  Sprouted: {
    description: 'Premature green shoot emergence at neck',
    color: '#CA8A04', // Amber/Yellow
  },
  Undersized: {
    description: 'Diameter below 40mm Mandi grade standard',
    color: '#9333EA', // Purple
  },
  Unknown: {
    description: 'Occluded, deep shadow, or unclassified bulb',
    color: '#64748B', // Slate
  },
};

export type QualityGrade = 'Grade A' | 'Grade B' | 'Reject';

export interface GradeMeta {
  label: QualityGrade;
  description: string;
  color: string;
}

export const GRADE_DETAILS: Record<QualityGrade, { description: string; color: string; bg: string }> = {
  'Grade A': {
    description: 'Premium export/mandi grade (>70% healthy, uniform size)',
    color: '#16A34A',
    bg: '#DCFCE7',
  },
  'Grade B': {
    description: 'Fair average quality (light blemishes, secondary market)',
    color: '#CA8A04',
    bg: '#FEF9C3',
  },
  'Reject': {
    description: 'Non-marketable decay, rotting, or severe sprouting',
    color: '#DC2626',
    bg: '#FEE2E2',
  },
};

export interface Point2D {
  x: number;
  y: number;
}

export interface DetectionBoundingBox {
  ymin: number;
  xmin: number;
  ymax: number;
  xmax: number;
}

export interface OnionDetectionItem {
  id: number;
  bbox: DetectionBoundingBox;
  polygon: Point2D[];
  confidence: number;
  defectType: DefectType;
  grade: QualityGrade;
  estimatedDiameterMm: number;
  severityScore: number;
}

export interface GradeDistributionModel {
  gradeAPercent: number;
  gradeBPercent: number;
  rejectPercent: number;
}

export interface DefectCountsModel {
  healthy: number;
  damaged: number;
  rotten: number;
  sprouted: number;
  undersized: number;
  unknown: number;
  total: number;
}

export interface HeapAnalysisResult {
  analysisId: string;
  timestamp: string;
  visibleOnionCount: number;
  grades: GradeDistributionModel;
  defects: DefectCountsModel;
  detections: OnionDetectionItem[];
  overallConfidence: number;
  processingTimeMs: number;
  isPrototype: boolean;
  warnings: string[];
  disclaimer: string;
  annotatedImageBase64?: string | null;
}

export interface OnionInspection {
  id: string;
  batchId: string;
  batchNumber: string;
  inspectorName: string;
  inspectorId: string;
  timestamp: string;
  analysis: HeapAnalysisResult;
  assignedGrade: QualityGrade;
  sampleWeightKg: number;
  notes: string;
  verificationToken: string;
  imageBase64?: string | null;
}
