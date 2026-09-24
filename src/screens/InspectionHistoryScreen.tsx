import React, { useState } from 'react';
import { OnionBatch, OnionInspection, QualityGrade } from '../types';
import {
  History,
  Search,
  Trash2,
  FileCheck2,
  Download,
  Check,
  Award,
  ArrowLeft,
  Clock,
} from 'lucide-react';
import { generateNativeVectorPdf } from '../utils/certificateGenerator';
import { useLanguage } from '../i18n/LanguageContext';

interface InspectionHistoryScreenProps {
  batches: OnionBatch[];
  inspections: OnionInspection[];
  onViewReport: (batch: OnionBatch, inspection: OnionInspection) => void;
  onDeleteInspection: (inspectionId: string) => void;
  onStartNewInspection: () => void;
  onBack?: () => void;
}

export const InspectionHistoryScreen: React.FC<InspectionHistoryScreenProps> = ({
  batches,
  inspections,
  onViewReport,
  onDeleteInspection,
  onStartNewInspection,
  onBack,
}) => {
  const { t } = useLanguage();
  const [searchQuery, setSearchQuery] = useState('');
  const [gradeFilter, setGradeFilter] = useState<'All' | QualityGrade>('All');
  const [downloadedId, setDownloadedId] = useState<string | null>(null);
  const [confirmDeleteId, setConfirmDeleteId] = useState<string | null>(null);

  const getBatch = (batchId: string, batchNumber: string): OnionBatch | undefined => {
    return batches.find((b) => b.id === batchId || b.batchNumber === batchNumber);
  };

  const filteredInspections = inspections.filter((insp) => {
    const batch = getBatch(insp.batchId, insp.batchNumber);
    const query = searchQuery.trim().toLowerCase();

    // Grade filter
    if (gradeFilter !== 'All' && insp.assignedGrade !== gradeFilter) {
      return false;
    }

    if (!query) return true;

    const matchesCert = insp.id.toLowerCase().includes(query);
    const matchesToken = insp.verificationToken.toLowerCase().includes(query);
    const matchesBatch = insp.batchNumber.toLowerCase().includes(query);
    const matchesInspector = insp.inspectorName.toLowerCase().includes(query);
    const matchesFarmer = batch ? batch.farmerName.toLowerCase().includes(query) : false;
    const matchesMandi = batch ? batch.mandiLocation.toLowerCase().includes(query) : false;

    return matchesCert || matchesToken || matchesBatch || matchesInspector || matchesFarmer || matchesMandi;
  });

  const handleQuickDownload = (insp: OnionInspection) => {
    const batch = getBatch(insp.batchId, insp.batchNumber) || {
      id: insp.batchId,
      batchNumber: insp.batchNumber,
      farmerName: 'Registered Lot Owner',
      farmerPhone: '',
      mandiLocation: 'APMC Mandi Yard',
      onionVariety: 'Standard Red Onion',
      harvestDate: insp.timestamp,
      weightQuintals: 100,
      bagCount: 200,
      status: 'certified' as const,
      createdAt: insp.timestamp,
      latestGrade: insp.assignedGrade,
      qrCodeData: `ONION-BATCH:${insp.batchNumber}`,
    };

    const filename = `OnionSure_Certificate_${insp.id}_${insp.batchNumber}.pdf`;
    generateNativeVectorPdf(batch, insp, filename);
    setDownloadedId(insp.id);
    setTimeout(() => setDownloadedId(null), 3000);
  };

  const filterButtons = [
    { key: 'All' as const, label: t.common.all },
    { key: 'Grade A' as const, label: 'Grade A' },
    { key: 'Grade B' as const, label: 'Grade B' },
    { key: 'Reject' as const, label: 'Reject' },
  ];

  return (
    <div className="max-w-4xl mx-auto space-y-4 sm:space-y-5">
      {/* Page Header */}
      <div className="bg-white rounded-xl border border-slate-200 p-4 sm:p-5 shadow-xs">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
          <div className="flex items-center gap-3">
            {onBack && (
              <button
                type="button"
                onClick={onBack}
                className="p-2 rounded-lg border border-slate-200 text-slate-600 hover:text-slate-900 hover:bg-slate-50 transition-colors cursor-pointer"
                title={t.common.back}
              >
                <ArrowLeft className="w-4 h-4" />
              </button>
            )}
            <div className="w-10 h-10 rounded-xl bg-[#7C2D12]/10 text-[#7C2D12] flex items-center justify-center shrink-0">
              <History className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-base font-bold text-slate-900">
                {t.historyScreen.title}
              </h2>
              <p className="text-xs text-slate-500">
                {t.historyScreen.subtitle}
              </p>
            </div>
          </div>

          <button
            type="button"
            onClick={onStartNewInspection}
            className="px-4 py-2 rounded-lg bg-[#7C2D12] text-white text-xs font-bold hover:bg-[#68250e] shadow-xs flex items-center justify-center gap-1.5 transition-colors cursor-pointer self-start sm:self-auto"
          >
            <Award className="w-4 h-4" />
            <span>{t.historyScreen.newInspectionBtn}</span>
          </button>
        </div>

        {/* Search and Filters */}
        <div className="mt-4 pt-4 border-t border-slate-100 flex flex-col sm:flex-row gap-2.5">
          <div className="relative flex-1">
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder={t.historyScreen.searchPlaceholder}
              className="w-full text-xs pl-9 pr-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-[#7C2D12] focus:outline-none"
            />
            <Search className="w-4 h-4 text-slate-400 absolute left-2.5 top-2.5 pointer-events-none" />
          </div>

          {/* Grade filter pills */}
          <div className="flex items-center gap-1.5 overflow-x-auto pb-0.5">
            {filterButtons.map((g) => (
              <button
                key={g.key}
                type="button"
                onClick={() => setGradeFilter(g.key)}
                className={`px-3 py-1.5 rounded-lg text-xs font-semibold whitespace-nowrap transition-colors cursor-pointer ${
                  gradeFilter === g.key
                    ? 'bg-slate-900 text-white shadow-xs'
                    : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                }`}
              >
                {g.label}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Inspections List or Empty State */}
      {filteredInspections.length === 0 ? (
        <div className="bg-white rounded-xl border border-slate-200 p-10 text-center space-y-3">
          <History className="w-10 h-10 text-slate-300 mx-auto" />
          <h3 className="text-sm font-bold text-slate-800">
            {searchQuery ? t.historyScreen.noResultsFound : t.historyScreen.emptyLog}
          </h3>
          <p className="text-xs text-slate-500 max-w-sm mx-auto">
            {searchQuery ? t.historyScreen.emptySearch : t.batchDetail.noInspectionsYet}
          </p>
          {searchQuery && (
            <button
              type="button"
              onClick={() => {
                setSearchQuery('');
                setGradeFilter('All');
              }}
              className="px-3 py-1.5 rounded-lg bg-slate-100 text-xs font-semibold text-slate-700 hover:bg-slate-200 cursor-pointer"
            >
              {t.historyScreen.clearFilter}
            </button>
          )}
        </div>
      ) : (
        <div className="space-y-2.5">
          {filteredInspections.map((insp) => {
            const batch = getBatch(insp.batchId, insp.batchNumber);

            return (
              <div
                key={insp.id}
                className="bg-white rounded-xl border border-slate-200 p-4 sm:p-5 flex flex-col sm:flex-row sm:items-center justify-between gap-3 shadow-xs hover:border-slate-300 transition-all"
              >
                <div className="space-y-1.5 min-w-0">
                  <div className="flex items-center gap-2 flex-wrap">
                    <span className="font-bold text-xs sm:text-sm text-slate-900">
                      {insp.id}
                    </span>
                    <span
                      className={`text-[11px] font-extrabold px-2.5 py-0.5 rounded-full ${
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

                  <div className="flex items-center gap-2 text-xs text-slate-600 flex-wrap">
                    <span className="font-semibold text-slate-800">
                      {insp.batchNumber}
                    </span>
                    {batch && (
                      <>
                        <span>•</span>
                        <span>{batch.farmerName}</span>
                        <span>•</span>
                        <span>{batch.mandiLocation}</span>
                      </>
                    )}
                  </div>

                  <div className="text-[11px] text-slate-400 flex items-center gap-2 flex-wrap">
                    <span className="flex items-center gap-1">
                      <Clock className="w-3 h-3" />
                      {new Date(insp.timestamp).toLocaleString()}
                    </span>
                    <span>•</span>
                    <span>{t.common.inspector}: {insp.inspectorName} ({insp.inspectorId})</span>
                    <span>•</span>
                    <span>{t.common.sample}: {insp.sampleWeightKg} {t.common.kg}</span>
                  </div>
                </div>

                <div className="flex items-center gap-2 self-start sm:self-center shrink-0 pt-2 sm:pt-0 border-t sm:border-t-0 border-slate-100 w-full sm:w-auto justify-end">
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
                    onClick={() => {
                      if (batch) {
                        onViewReport(batch, insp);
                      }
                    }}
                    className="px-3 py-2 rounded-lg border border-slate-300 text-slate-700 text-xs font-bold hover:bg-slate-50 flex items-center justify-center gap-1.5 transition-colors cursor-pointer"
                  >
                    <FileCheck2 className="w-4 h-4 text-[#7C2D12]" />
                    <span>{t.common.view}</span>
                  </button>

                  {confirmDeleteId === insp.id ? (
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
                  )}
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};
