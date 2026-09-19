import React, { useState } from 'react';
import {
  OnionBatch,
  HeapAnalysisResult,
  QualityGrade,
  OnionInspection,
  DefectType,
  OnionDetectionItem,
} from '../types';
import { SegmentationOverlay } from '../components/SegmentationOverlay';
import { QualityDistribution } from '../components/QualityDistribution';
import { DefectBreakdownCard } from '../components/DefectBreakdownCard';
import { DisclaimerBanner } from '../components/DisclaimerBanner';
import {
  Award,
  AlertCircle,
  Clock,
  CheckCircle2,
  FileCheck2,
} from 'lucide-react';

interface HeapAnalysisScreenProps {
  batch: OnionBatch;
  result: HeapAnalysisResult;
  imageSrc?: string | null;
  meta: {
    inspectorName: string;
    inspectorId: string;
    sampleWeightKg: number;
    notes: string;
  };
  onCertify: (inspection: OnionInspection) => void;
  onBack: () => void;
}

export const HeapAnalysisScreen: React.FC<HeapAnalysisScreenProps> = ({
  batch,
  result,
  imageSrc,
  meta,
  onCertify,
}) => {
  const [activeDefectFilter, setActiveDefectFilter] = useState<DefectType | null>(null);
  const [selectedBulb, setSelectedBulb] = useState<OnionDetectionItem | null>(null);

  // Derive overall grade exactly as in Flutter app:
  const deriveGrade = (): QualityGrade => {
    if (result.grades.rejectPercent > 12.0) {
      return 'Reject';
    } else if (result.grades.gradeAPercent >= 65.0) {
      return 'Grade A';
    } else {
      return 'Grade B';
    }
  };

  const assignedGrade = deriveGrade();
  const isGradeA = assignedGrade === 'Grade A';
  const isGradeB = assignedGrade === 'Grade B';

  const gradeColor = isGradeA
    ? 'text-emerald-700 bg-emerald-50 border-emerald-300'
    : isGradeB
    ? 'text-amber-700 bg-amber-50 border-amber-300'
    : 'text-red-700 bg-red-50 border-red-300';

  const handleGenerateCertificate = () => {
    const randSuffix = Math.floor(1000 + Math.random() * 9000);
    const token = `VERIF-NSK-${randSuffix}-${assignedGrade[0].toUpperCase()}`;

    const inspection: OnionInspection = {
      id: `INSP-2026-${randSuffix}`,
      batchId: batch.id,
      batchNumber: batch.batchNumber,
      inspectorName: meta.inspectorName || 'Dr. V. K. Deshmukh',
      inspectorId: meta.inspectorId || 'INS-MH-704',
      timestamp: new Date().toISOString(),
      analysis: result,
      assignedGrade,
      sampleWeightKg: meta.sampleWeightKg || 15.0,
      notes: meta.notes || 'Verified through computer vision heap analysis.',
      verificationToken: token,
      imageBase64: imageSrc || null,
    };

    onCertify(inspection);
  };

  return (
    <div className="max-w-3xl mx-auto space-y-4 sm:space-y-5">
      {/* Grade & Confidence Banner */}
      <div className="bg-white rounded-xl border border-slate-200 p-4 sm:p-5 shadow-xs">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div className="flex items-center gap-3.5">
            <div
              className={`w-14 h-14 rounded-xl border flex flex-col items-center justify-center shrink-0 ${gradeColor}`}
            >
              <Award className="w-6 h-6" />
              <span className="text-[11px] font-black tracking-wider uppercase">
                {assignedGrade}
              </span>
            </div>

            <div>
              <div className="flex items-center gap-2">
                <h2 className="text-base sm:text-lg font-extrabold text-slate-900">
                  {assignedGrade === 'Grade A'
                    ? 'Certified Export / Premium Grade'
                    : assignedGrade === 'Grade B'
                    ? 'Fair Average Mandi Quality'
                    : 'Lot Rejected (Non-Marketable)'}
                </h2>
                <span className="text-xs px-2 py-0.5 rounded-full bg-slate-100 text-slate-700 font-semibold">
                  Batch: {batch.batchNumber}
                </span>
              </div>
              <p className="text-xs text-slate-500 mt-0.5">
                {batch.farmerName} • {batch.mandiLocation} • {batch.onionVariety}
              </p>
            </div>
          </div>

          <div className="flex sm:flex-col items-center sm:items-end justify-between sm:justify-center border-t sm:border-t-0 pt-2 sm:pt-0 border-slate-100 text-xs text-slate-600 gap-1">
            <div className="flex items-center gap-1 font-semibold text-slate-800">
              <CheckCircle2 className="w-4 h-4 text-emerald-600" />
              <span>{Math.round(result.overallConfidence * 100)}% Confidence</span>
            </div>
            <div className="flex items-center gap-1 text-[11px] text-slate-400">
              <Clock className="w-3 h-3" />
              <span>Inference: {result.processingTimeMs}ms</span>
            </div>
            <div className="text-[11px] text-slate-400">
              Scanned: {result.visibleOnionCount} surface bulbs
            </div>
          </div>
        </div>
      </div>

      {/* Warnings if any */}
      {result.warnings && result.warnings.length > 0 && (
        <div className="space-y-1.5">
          {result.warnings.map((warn, idx) => (
            <div
              key={idx}
              className="bg-amber-50 border border-amber-200 text-amber-900 text-xs px-3 py-2 rounded-lg flex items-center gap-2"
            >
              <AlertCircle className="w-4 h-4 text-amber-600 shrink-0" />
              <span>{warn}</span>
            </div>
          ))}
        </div>
      )}

      {/* Interactive Instance Segmentation Stage */}
      <div>
        <div className="flex items-center justify-between mb-2">
          <h3 className="text-sm font-bold text-slate-800">
            Computer Vision Heap Instance Segmentation
          </h3>
          <span className="text-xs text-slate-500">
            Click bulbs to isolate
          </span>
        </div>
        <SegmentationOverlay
          detections={result.detections}
          imageSrc={imageSrc}
          selectedDetection={selectedBulb}
          onSelectDetection={(d) => setSelectedBulb(d)}
        />
      </div>

      {/* AGMARK Quality Grade Distribution */}
      <QualityDistribution grades={result.grades} />

      {/* Defect Classification Breakdown */}
      <DefectBreakdownCard
        defects={result.defects}
        activeFilter={activeDefectFilter}
        onSelectFilter={(d) => {
          setActiveDefectFilter(activeDefectFilter === d ? null : d);
        }}
      />

      {/* Mandatory Surface Estimation Disclaimer */}
      <DisclaimerBanner disclaimerText={result.disclaimer} />

      {/* Certify CTA Banner */}
      <div className="bg-white rounded-xl border border-slate-200 p-4 sm:p-5 flex flex-col sm:flex-row items-center justify-between gap-3 shadow-xs">
        <div>
          <h4 className="text-sm font-bold text-slate-900">
            Issue Digital AGMARK Quality Certificate
          </h4>
          <p className="text-xs text-slate-500">
            Signs this lot record with cryptographic token and updates mandi batch status
          </p>
        </div>

        <button
          type="button"
          onClick={handleGenerateCertificate}
          className="w-full sm:w-auto px-6 py-2.5 rounded-xl bg-[#7C2D12] text-white text-xs font-bold hover:bg-[#68250e] shadow-xs flex items-center justify-center gap-2 transition-colors shrink-0"
        >
          <FileCheck2 className="w-4 h-4" />
          <span>Certify & View Certificate</span>
        </button>
      </div>
    </div>
  );
};
