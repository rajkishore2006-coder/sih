import React, { useState } from 'react';
import { OnionBatch, OnionInspection } from '../types';
import { QRCodeSVG } from 'qrcode.react';
import {
  Camera,
  FileCheck2,
  Calendar,
  MapPin,
  Sprout,
  Weight,
  User,
  Phone,
  ShieldCheck,
  Clock,
  Download,
  Check,
  Trash2,
} from 'lucide-react';
import { generateNativeVectorPdf } from '../utils/certificateGenerator';
import { useLanguage } from '../i18n/LanguageContext';

interface BatchDetailScreenProps {
  batch: OnionBatch;
  inspections: OnionInspection[];
  onStartInspection: (batch: OnionBatch) => void;
  onViewReport: (batch: OnionBatch, inspection: OnionInspection) => void;
  onDeleteInspection?: (inspectionId: string) => void;
}

export const BatchDetailScreen: React.FC<BatchDetailScreenProps> = ({
  batch,
  inspections,
  onStartInspection,
  onViewReport,
  onDeleteInspection,
}) => {
  const { t } = useLanguage();
  const [downloadedId, setDownloadedId] = useState<string | null>(null);
  const [confirmDeleteId, setConfirmDeleteId] = useState<string | null>(null);

  const handleQuickDownload = (insp: OnionInspection) => {
    const filename = `OnionSure_Certificate_${insp.id}_${batch.batchNumber}.pdf`;
    generateNativeVectorPdf(batch, insp, filename);
    setDownloadedId(insp.id);
    setTimeout(() => setDownloadedId(null), 3000);
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'certified':
        return 'text-emerald-700 bg-emerald-50 border-emerald-200';
      case 'inspected':
        return 'text-sky-700 bg-sky-50 border-sky-200';
      case 'rejected':
        return 'text-red-700 bg-red-50 border-red-200';
      default:
        return 'text-amber-700 bg-amber-50 border-amber-200';
    }
  };

  const getStatusLabel = (status: string) => {
    switch (status) {
      case 'certified':
        return t.common.certified;
      case 'inspected':
        return t.common.inspected;
      case 'rejected':
        return t.common.rejected;
      default:
        return t.common.pending;
    }
  };

  return (
    <div className="max-w-3xl mx-auto space-y-4 sm:space-y-5">
      {/* Batch Overview & QR Code Card */}
      <div className="bg-white rounded-xl border border-slate-200 p-4 sm:p-6 shadow-xs">
        <div className="flex flex-col sm:flex-row gap-5 items-start sm:items-center justify-between">
          <div className="flex flex-col sm:flex-row gap-4 items-start sm:items-center">
            {/* QR Code */}
            <div className="p-3 bg-white rounded-xl border border-slate-200 shadow-2xs shrink-0 flex flex-col items-center">
              <QRCodeSVG
                value={batch.qrCodeData || `ONION-BATCH:${batch.batchNumber}`}
                size={110}
                level="M"
              />
              <span className="text-[10px] text-slate-400 mt-1 font-mono">
                {batch.batchNumber}
              </span>
            </div>

            {/* Details */}
            <div className="space-y-1.5">
              <div className="flex items-center gap-2 flex-wrap">
                <h2 className="text-lg font-bold text-slate-900 tracking-tight">
                  {batch.batchNumber}
                </h2>
                <span
                  className={`text-xs font-bold px-2.5 py-0.5 rounded-full border ${getStatusColor(
                    batch.status
                  )}`}
                >
                  {getStatusLabel(batch.status)} {batch.latestGrade ? `(${batch.latestGrade})` : ''}
                </span>
              </div>

              <div className="text-xs text-slate-700 flex items-center gap-2">
                <User className="w-3.5 h-3.5 text-slate-400" />
                <span className="font-semibold">{batch.farmerName}</span>
                {batch.farmerPhone && (
                  <>
                    <span className="text-slate-300">•</span>
                    <Phone className="w-3 h-3 text-slate-400" />
                    <span className="text-slate-500">{batch.farmerPhone}</span>
                  </>
                )}
              </div>

              <div className="text-xs text-slate-600 flex items-center gap-2">
                <MapPin className="w-3.5 h-3.5 text-slate-400" />
                <span>{batch.mandiLocation}</span>
              </div>

              <div className="text-xs text-slate-600 flex items-center gap-2">
                <Sprout className="w-3.5 h-3.5 text-slate-400" />
                <span>{batch.onionVariety}</span>
              </div>

              <div className="text-xs text-slate-600 flex items-center gap-2">
                <Weight className="w-3.5 h-3.5 text-slate-400" />
                <span className="font-semibold">{batch.weightQuintals} {t.common.quintals}</span>
                <span className="text-slate-400">({batch.bagCount} {t.common.bags})</span>
              </div>

              <div className="text-[11px] text-slate-400 flex items-center gap-1.5 pt-1">
                <Calendar className="w-3 h-3 text-slate-400" />
                <span>{t.batchDetail.harvestedDate}: {new Date(batch.harvestDate).toLocaleDateString()}</span>
              </div>
            </div>
          </div>

          {/* Quick Inspection Action */}
          <div className="w-full sm:w-auto flex sm:flex-col gap-2 shrink-0">
            <button
              onClick={() => onStartInspection(batch)}
              className="flex-1 sm:flex-initial px-4 py-2.5 rounded-lg bg-[#7C2D12] text-white text-xs font-bold hover:bg-[#68250e] shadow-xs flex items-center justify-center gap-1.5 transition-colors cursor-pointer"
            >
              <Camera className="w-4 h-4" />
              <span>{t.batchDetail.inspectHeapBtn}</span>
            </button>
          </div>
        </div>
      </div>

      {/* Inspection History */}
      <div className="space-y-3">
        <h3 className="text-sm font-bold text-slate-800 flex items-center gap-2">
          <ShieldCheck className="w-4 h-4 text-[#7C2D12]" />
          <span>{t.batchDetail.inspectionHistoryTitle} ({inspections.length})</span>
        </h3>

        {inspections.length === 0 ? (
          <div className="bg-white rounded-xl border border-slate-200 p-6 text-center text-slate-500 text-xs">
            {t.batchDetail.noInspectionsYet}
          </div>
        ) : (
          <div className="space-y-2.5">
            {inspections.map((insp) => (
              <div
                key={insp.id}
                className="bg-white rounded-xl border border-slate-200 p-4 flex flex-col sm:flex-row sm:items-center justify-between gap-3 shadow-xs"
              >
                <div className="space-y-1">
                  <div className="flex items-center gap-2 flex-wrap">
                    <span className="font-bold text-xs sm:text-sm text-slate-900">
                      {insp.id}
                    </span>
                    <span
                      className={`text-[11px] font-extrabold px-2 py-0.5 rounded ${
                        insp.assignedGrade === 'Grade A'
                          ? 'bg-emerald-100 text-emerald-800'
                          : insp.assignedGrade === 'Grade B'
                          ? 'bg-amber-100 text-amber-800'
                          : 'bg-red-100 text-red-800'
                      }`}
                    >
                      {insp.assignedGrade.toUpperCase()}
                    </span>
                    <span className="text-[11px] text-slate-500 font-mono">
                      {t.common.token}: {insp.verificationToken}
                    </span>
                  </div>

                  <div className="text-xs text-slate-600">
                    {t.common.inspector}: <span className="font-semibold">{insp.inspectorName}</span> ({insp.inspectorId})
                  </div>

                  <div className="text-[11px] text-slate-400 flex items-center gap-2">
                    <Clock className="w-3 h-3" />
                    <span>{new Date(insp.timestamp).toLocaleString()}</span>
                    <span>•</span>
                    <span>{t.common.sample}: {insp.sampleWeightKg} {t.common.kg}</span>
                  </div>

                  {insp.notes && (
                    <p className="text-xs text-slate-500 italic mt-1 bg-slate-50 p-2 rounded">
                      "{insp.notes}"
                    </p>
                  )}
                </div>

                <div className="flex items-center gap-2 self-start sm:self-center shrink-0">
                  <button
                    type="button"
                    onClick={() => handleQuickDownload(insp)}
                    className="px-3 py-2 rounded-lg bg-[#7C2D12] text-white text-xs font-bold hover:bg-[#68250e] shadow-2xs flex items-center justify-center gap-1.5 transition-colors cursor-pointer"
                    title={t.common.downloadPdf}
                  >
                    {downloadedId === insp.id ? (
                      <>
                        <Check className="w-3.5 h-3.5 text-emerald-300" />
                        <span>{t.common.downloaded}</span>
                      </>
                    ) : (
                      <>
                        <Download className="w-3.5 h-3.5" />
                        <span>{t.common.downloadPdf}</span>
                      </>
                    )}
                  </button>

                  <button
                    type="button"
                    onClick={() => onViewReport(batch, insp)}
                    className="px-3 py-2 rounded-lg border border-slate-300 text-slate-700 text-xs font-bold hover:bg-slate-50 flex items-center justify-center gap-1.5 transition-colors cursor-pointer"
                  >
                    <FileCheck2 className="w-4 h-4 text-[#7C2D12]" />
                    <span>{t.common.view}</span>
                  </button>

                  {onDeleteInspection && (
                    confirmDeleteId === insp.id ? (
                      <div className="flex items-center gap-1">
                        <button
                          type="button"
                          onClick={() => {
                            onDeleteInspection(insp.id);
                            setConfirmDeleteId(null);
                          }}
                          className="px-2 py-1.5 rounded-lg bg-red-600 text-white text-[11px] font-bold hover:bg-red-700 transition-colors cursor-pointer"
                          title={t.batchDetail.confirmDelete}
                        >
                          {t.common.confirm}
                        </button>
                        <button
                          type="button"
                          onClick={() => setConfirmDeleteId(null)}
                          className="px-2 py-1.5 rounded-lg bg-slate-200 text-slate-700 text-[11px] font-medium hover:bg-slate-300 transition-colors cursor-pointer"
                        >
                          {t.common.cancel}
                        </button>
                      </div>
                    ) : (
                      <button
                        type="button"
                        onClick={() => setConfirmDeleteId(insp.id)}
                        className="p-2 rounded-lg text-slate-400 hover:text-red-600 hover:bg-red-50 transition-colors cursor-pointer"
                        title={t.batchDetail.deleteTooltip}
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    )
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};
