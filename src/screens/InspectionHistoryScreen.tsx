import React, { useState } from 'react';
import { OnionBatch, OnionInspection, QualityGrade } from '../types';
import {
  History,
  Search,
  Trash2,
  FileCheck2,
  Download,
  Calendar,
  Layers,
  User,
  Check,
  Award,
  ArrowLeft,
} from 'lucide-react';
import { generateNativeVectorPdf } from '../utils/certificateGenerator';

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
                title="Back to Dashboard"
              >
                <ArrowLeft className="w-4 h-4" />
              </button>
            )}
            <div className="w-10 h-10 rounded-xl bg-[#7C2D12]/10 text-[#7C2D12] flex items-center justify-center shrink-0">
              <History className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-base font-bold text-slate-900">
                Inspection & Certification History
              </h2>
              <p className="text-xs text-slate-500">
                Search, review, download, and manage certified mandi lot inspections
              </p>
            </div>
          </div>

          <button
            type="button"
            onClick={onStartNewInspection}
            className="px-4 py-2 rounded-lg bg-[#7C2D12] text-white text-xs font-bold hover:bg-[#68250e] shadow-xs flex items-center justify-center gap-1.5 transition-colors cursor-pointer self-start sm:self-auto"
          >
            <Award className="w-4 h-4" />
            <span>New Heap Inspection</span>
          </button>
        </div>

        {/* Search and Filters */}
        <div className="mt-4 pt-4 border-t border-slate-100 flex flex-col sm:flex-row gap-2.5">
          <div className="relative flex-1">
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search by Certificate ID, Batch, Token, Farmer, Mandi..."
              className="w-full text-xs pl-9 pr-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-[#7C2D12] focus:outline-none"
            />
            <Search className="w-4 h-4 text-slate-400 absolute left-2.5 top-2.5 pointer-events-none" />
          </div>

          {/* Grade filter pills */}
          <div className="flex items-center gap-1.5 overflow-x-auto pb-0.5">
            {(['All', 'Grade A', 'Grade B', 'Reject'] as const).map((g) => (
              <button
                key={g}
                type="button"
                onClick={() => setGradeFilter(g)}
                className={`px-3 py-1.5 rounded-lg text-xs font-semibold whitespace-nowrap transition-colors cursor-pointer ${
                  gradeFilter === g
                    ? 'bg-slate-900 text-white shadow-xs'
                    : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                }`}
              >
                {g}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Inspections List or Empty State */}
      {filteredInspections.length === 0 ? (
        <div className="bg-white rounded-xl border border-slate-200 p-8 text-center space-y-3">
          <div className="w-12 h-12 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center mx-auto">
            <History className="w-6 h-6" />
          </div>
          <div>
            <h3 className="text-sm font-bold text-slate-800">
              {inspections.length === 0 ? 'No inspections recorded yet' : 'No matching inspections found'}
            </h3>
            <p className="text-xs text-slate-500 mt-0.5 max-w-sm mx-auto">
              {inspections.length === 0
                ? 'Run computer vision heap grading on any registered arrival batch to log certificates.'
                : 'Try adjusting your search query or grade filter.'}
            </p>
          </div>
          {inspections.length === 0 && (
            <button
              type="button"
              onClick={onStartNewInspection}
              className="mt-2 px-4 py-2 rounded-lg bg-[#7C2D12] text-white text-xs font-bold hover:bg-[#68250e] transition-colors inline-flex items-center gap-1.5"
            >
              <span>Inspect First Heap Lot</span>
            </button>
          )}
        </div>
      ) : (
        <div className="space-y-3">
          {filteredInspections.map((insp) => {
            const batch = getBatch(insp.batchId, insp.batchNumber);
            const isDeleting = confirmDeleteId === insp.id;

            return (
              <div
                key={insp.id}
                className="bg-white rounded-xl border border-slate-200 p-4 sm:p-5 shadow-xs hover:border-slate-300 transition-all flex flex-col md:flex-row md:items-center justify-between gap-4"
              >
                {/* Info Block */}
                <div className="space-y-2 min-w-0">
                  <div className="flex items-center gap-2 flex-wrap">
                    <span className="font-mono font-bold text-xs sm:text-sm text-slate-900">
                      {insp.id}
                    </span>
                    <span
                      className={`text-[11px] font-extrabold px-2.5 py-0.5 rounded-full border ${
                        insp.assignedGrade === 'Grade A'
                          ? 'bg-emerald-50 text-emerald-800 border-emerald-300'
                          : insp.assignedGrade === 'Grade B'
                          ? 'bg-amber-50 text-amber-800 border-amber-300'
                          : 'bg-red-50 text-red-800 border-red-300'
                      }`}
                    >
                      {insp.assignedGrade}
                    </span>
                    <span className="text-[11px] font-mono text-slate-500 bg-slate-100 px-2 py-0.5 rounded border border-slate-200">
                      Token: {insp.verificationToken}
                    </span>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-x-4 gap-y-1 text-xs text-slate-600">
                    <div className="flex items-center gap-1.5 truncate">
                      <Layers className="w-3.5 h-3.5 text-slate-400 shrink-0" />
                      <span className="font-semibold text-slate-800">{insp.batchNumber}</span>
                      {batch && <span className="text-slate-500 truncate">• {batch.mandiLocation}</span>}
                    </div>

                    <div className="flex items-center gap-1.5 truncate">
                      <User className="w-3.5 h-3.5 text-slate-400 shrink-0" />
                      <span>Farmer: </span>
                      <span className="font-semibold text-slate-800">
                        {batch ? batch.farmerName : 'Owner'}
                      </span>
                    </div>

                    <div className="flex items-center gap-1.5 text-slate-500 text-[11px]">
                      <Calendar className="w-3.5 h-3.5 text-slate-400 shrink-0" />
                      <span>{new Date(insp.timestamp).toLocaleString()}</span>
                    </div>

                    <div className="text-[11px] text-slate-500 truncate">
                      Inspector: {insp.inspectorName} ({insp.inspectorId})
                    </div>
                  </div>

                  {/* Quality summary bar */}
                  <div className="flex items-center gap-3 pt-1 text-[11px]">
                    <span className="text-emerald-700 font-semibold">
                      Grade A: {insp.analysis?.grades?.gradeAPercent ?? 0}%
                    </span>
                    <span className="text-amber-700 font-semibold">
                      Grade B: {insp.analysis?.grades?.gradeBPercent ?? 0}%
                    </span>
                    <span className="text-red-700 font-semibold">
                      Reject: {insp.analysis?.grades?.rejectPercent ?? 0}%
                    </span>
                    <span className="text-slate-400">
                      ({insp.analysis?.visibleOnionCount ?? 0} bulbs scanned)
                    </span>
                  </div>
                </div>

                {/* Actions Toolbar */}
                <div className="flex items-center gap-2 self-start md:self-center shrink-0 pt-2 md:pt-0 border-t md:border-t-0 border-slate-100 w-full md:w-auto justify-end">
                  {isDeleting ? (
                    <div className="flex items-center gap-2 animate-in fade-in">
                      <span className="text-xs text-red-600 font-medium">Delete record?</span>
                      <button
                        type="button"
                        onClick={() => {
                          onDeleteInspection(insp.id);
                          setConfirmDeleteId(null);
                        }}
                        className="px-2.5 py-1.5 rounded bg-red-600 text-white text-xs font-bold hover:bg-red-700 transition-colors"
                      >
                        Yes, Delete
                      </button>
                      <button
                        type="button"
                        onClick={() => setConfirmDeleteId(null)}
                        className="px-2.5 py-1.5 rounded border border-slate-300 text-slate-600 text-xs font-medium hover:bg-slate-50 transition-colors"
                      >
                        Cancel
                      </button>
                    </div>
                  ) : (
                    <>
                      <button
                        type="button"
                        onClick={() => handleQuickDownload(insp)}
                        className="px-3 py-2 rounded-lg bg-[#7C2D12] text-white text-xs font-bold hover:bg-[#68250e] shadow-2xs flex items-center justify-center gap-1.5 transition-colors cursor-pointer"
                        title="Directly download PDF certificate"
                      >
                        {downloadedId === insp.id ? (
                          <>
                            <Check className="w-3.5 h-3.5 text-emerald-300" />
                            <span>Downloaded</span>
                          </>
                        ) : (
                          <>
                            <Download className="w-3.5 h-3.5" />
                            <span>PDF</span>
                          </>
                        )}
                      </button>

                      <button
                        type="button"
                        onClick={() => {
                          const b = getBatch(insp.batchId, insp.batchNumber) || {
                            id: insp.batchId,
                            batchNumber: insp.batchNumber,
                            farmerName: 'Lot Owner',
                            farmerPhone: '',
                            mandiLocation: 'APMC Mandi',
                            onionVariety: 'Red Onion',
                            harvestDate: insp.timestamp,
                            weightQuintals: 100,
                            bagCount: 200,
                            status: 'certified' as const,
                            createdAt: insp.timestamp,
                            latestGrade: insp.assignedGrade,
                            qrCodeData: `ONION-BATCH:${insp.batchNumber}`,
                          };
                          onViewReport(b, insp);
                        }}
                        className="px-3 py-2 rounded-lg border border-slate-300 text-slate-700 text-xs font-bold hover:bg-slate-50 flex items-center justify-center gap-1.5 transition-colors cursor-pointer"
                      >
                        <FileCheck2 className="w-4 h-4 text-[#7C2D12]" />
                        <span>View</span>
                      </button>

                      <button
                        type="button"
                        onClick={() => setConfirmDeleteId(insp.id)}
                        className="p-2 rounded-lg border border-slate-200 text-slate-400 hover:text-red-600 hover:border-red-200 hover:bg-red-50 transition-colors cursor-pointer"
                        title="Delete this inspection record safely"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </>
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
