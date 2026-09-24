import React, { useState } from 'react';
import { OnionBatch, OnionInspection } from '../types';
import { KpiBanner } from '../components/KpiBanner';
import {
  PlusCircle,
  Camera,
  QrCode,
  ShieldCheck,
  ChevronRight,
  Package,
  Layers,
  History,
} from 'lucide-react';
import { useLanguage } from '../i18n/LanguageContext';

interface HomeScreenProps {
  batches: OnionBatch[];
  inspections?: OnionInspection[];
  onOpenCreateBatch: () => void;
  onOpenInspection: (batch?: OnionBatch) => void;
  onOpenBatchDetail: (batchId: string) => void;
  onOpenScanBatch: () => void;
  onOpenVerify: () => void;
  onOpenHistory?: () => void;
}

export const HomeScreen: React.FC<HomeScreenProps> = ({
  batches,
  inspections = [],
  onOpenCreateBatch,
  onOpenInspection,
  onOpenBatchDetail,
  onOpenScanBatch,
  onOpenVerify,
  onOpenHistory,
}) => {
  const { t, interpolate } = useLanguage();
  const [filter, setFilter] = useState<'All' | 'Certified' | 'Inspected' | 'Pending'>('All');

  const filteredBatches = batches.filter((b) => {
    if (filter === 'All') return true;
    if (filter === 'Certified') return b.status === 'certified';
    if (filter === 'Inspected') return b.status === 'inspected';
    if (filter === 'Pending') return b.status === 'pending';
    return true;
  });

  const inspectedCount = batches.filter((b) => b.status !== 'pending').length;
  const totalWeight = batches.reduce((acc, b) => acc + b.weightQuintals, 0);

  // Compute actual average Grade A percentage from real inspections
  const averageGradeAPercentage =
    inspections.length > 0
      ? Math.round(
          (inspections.reduce((acc, insp) => {
            return (
              acc +
              (insp.analysis?.grades?.gradeAPercent ??
                (insp.assignedGrade === 'Grade A'
                  ? 85
                  : insp.assignedGrade === 'Grade B'
                  ? 55
                  : 20))
            );
          }, 0) /
            inspections.length) *
            10
        ) / 10
      : 0;

  const getStatusBadge = (batch: OnionBatch) => {
    switch (batch.status) {
      case 'certified':
        return (
          <span className="text-[11px] font-bold px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200">
            {t.common.certified} {batch.latestGrade ? `(${batch.latestGrade})` : ''}
          </span>
        );
      case 'inspected':
        return (
          <span className="text-[11px] font-bold px-2 py-0.5 rounded-full bg-sky-50 text-sky-700 border border-sky-200">
            {t.common.inspected} {batch.latestGrade ? `(${batch.latestGrade})` : ''}
          </span>
        );
      case 'rejected':
        return (
          <span className="text-[11px] font-bold px-2 py-0.5 rounded-full bg-red-50 text-red-700 border border-red-200">
            {t.common.rejected}
          </span>
        );
      default:
        return (
          <span className="text-[11px] font-bold px-2 py-0.5 rounded-full bg-amber-50 text-amber-700 border border-amber-200">
            {t.common.pending}
          </span>
        );
    }
  };

  const filterTabs = [
    { key: 'All' as const, label: t.dashboard.filterAll },
    { key: 'Certified' as const, label: t.dashboard.filterCertified },
    { key: 'Inspected' as const, label: t.dashboard.filterInspected },
    { key: 'Pending' as const, label: t.dashboard.filterPending },
  ];

  const currentTabObj = filterTabs.find((ft) => ft.key === filter);
  const currentTabLabel = currentTabObj ? currentTabObj.label : filter;

  return (
    <div className="space-y-4 sm:space-y-5">
      {/* Top KPI Metrics Banner */}
      <KpiBanner
        totalBatches={batches.length}
        inspectedBatchesCount={inspectedCount}
        averageGradeAPercentage={averageGradeAPercentage}
        totalWeightQuintals={totalWeight}
      />

      {/* Quick Actions Grid */}
      <div className="grid grid-cols-2 sm:grid-cols-5 gap-2.5">
        <button
          type="button"
          onClick={onOpenCreateBatch}
          className="bg-white hover:bg-slate-50 border border-slate-200 rounded-xl p-3.5 flex flex-col items-center text-center transition-all shadow-xs hover:border-slate-300 cursor-pointer"
        >
          <div className="w-10 h-10 rounded-full bg-[#7C2D12]/10 text-[#7C2D12] flex items-center justify-center mb-2">
            <PlusCircle className="w-5 h-5" />
          </div>
          <span className="text-xs font-bold text-slate-800">{t.dashboard.registerBatchAction}</span>
          <span className="text-[10px] text-slate-500">{t.dashboard.registerBatchDesc}</span>
        </button>

        <button
          type="button"
          onClick={() => onOpenInspection()}
          className="bg-white hover:bg-slate-50 border border-slate-200 rounded-xl p-3.5 flex flex-col items-center text-center transition-all shadow-xs hover:border-slate-300 cursor-pointer"
        >
          <div className="w-10 h-10 rounded-full bg-sky-100 text-sky-700 flex items-center justify-center mb-2">
            <Camera className="w-5 h-5" />
          </div>
          <span className="text-xs font-bold text-slate-800">{t.dashboard.inspectHeapAction}</span>
          <span className="text-[10px] text-slate-500">{t.dashboard.inspectHeapDesc}</span>
        </button>

        <button
          type="button"
          onClick={onOpenScanBatch}
          className="bg-white hover:bg-slate-50 border border-slate-200 rounded-xl p-3.5 flex flex-col items-center text-center transition-all shadow-xs hover:border-slate-300 cursor-pointer"
        >
          <div className="w-10 h-10 rounded-full bg-teal-100 text-teal-800 flex items-center justify-center mb-2">
            <QrCode className="w-5 h-5" />
          </div>
          <span className="text-xs font-bold text-slate-800">{t.dashboard.scanQrAction}</span>
          <span className="text-[10px] text-slate-500">{t.dashboard.scanQrDesc}</span>
        </button>

        <button
          type="button"
          onClick={onOpenVerify}
          className="bg-white hover:bg-slate-50 border border-slate-200 rounded-xl p-3.5 flex flex-col items-center text-center transition-all shadow-xs hover:border-slate-300 cursor-pointer"
        >
          <div className="w-10 h-10 rounded-full bg-indigo-100 text-indigo-700 flex items-center justify-center mb-2">
            <ShieldCheck className="w-5 h-5" />
          </div>
          <span className="text-xs font-bold text-slate-800">{t.dashboard.verifyCertAction}</span>
          <span className="text-[10px] text-slate-500">{t.dashboard.verifyCertDesc}</span>
        </button>

        <button
          type="button"
          onClick={onOpenHistory}
          className="col-span-2 sm:col-span-1 bg-white hover:bg-slate-50 border border-slate-200 rounded-xl p-3.5 flex flex-col items-center text-center transition-all shadow-xs hover:border-slate-300 cursor-pointer"
        >
          <div className="w-10 h-10 rounded-full bg-purple-100 text-purple-700 flex items-center justify-center mb-2">
            <History className="w-5 h-5" />
          </div>
          <span className="text-xs font-bold text-slate-800">{t.dashboard.inspectionLogAction}</span>
          <span className="text-[10px] text-slate-500">
            {inspections.length} {t.dashboard.savedCount}
          </span>
        </button>
      </div>

      {/* Batches Section */}
      <div className="space-y-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Layers className="w-4 h-4 text-[#7C2D12]" />
            <h3 className="text-sm sm:text-base font-bold text-slate-900">
              {t.dashboard.registeredBatchesTitle}
            </h3>
          </div>
          <span className="text-xs text-slate-500 font-medium">
            {filteredBatches.length} {interpolate(t.dashboard.batchesOfTotal, { total: batches.length })}
          </span>
        </div>

        {/* Filter Pills */}
        <div className="flex items-center gap-1.5 overflow-x-auto pb-1">
          {filterTabs.map((tab) => {
            const isSelected = filter === tab.key;
            return (
              <button
                key={tab.key}
                type="button"
                onClick={() => setFilter(tab.key)}
                className={`px-3 py-1 rounded-full text-xs font-semibold transition-all cursor-pointer ${
                  isSelected
                    ? 'bg-[#7C2D12] text-white shadow-xs'
                    : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-100'
                }`}
              >
                {tab.label}
              </button>
            );
          })}
        </div>

        {/* Batches List */}
        {filteredBatches.length === 0 ? (
          <div className="bg-white rounded-xl border border-slate-200 p-8 text-center">
            <Package className="w-8 h-8 text-slate-400 mx-auto mb-2" />
            <p className="text-xs text-slate-600 font-medium">
              {interpolate(t.dashboard.noBatchesFound, { filter: currentTabLabel })}
            </p>
          </div>
        ) : (
          <div className="space-y-2">
            {filteredBatches.map((batch) => (
              <div
                key={batch.id}
                onClick={() => onOpenBatchDetail(batch.id)}
                className="bg-white hover:bg-slate-50/80 border border-slate-200 hover:border-slate-300 rounded-xl p-3.5 sm:p-4 flex items-center justify-between gap-3 cursor-pointer transition-all shadow-xs"
              >
                <div className="flex items-center gap-3 min-w-0">
                  <div className="w-10 h-10 rounded-lg bg-amber-950/10 text-amber-900 flex items-center justify-center shrink-0">
                    <Package className="w-5 h-5 text-[#7C2D12]" />
                  </div>
                  <div className="min-w-0">
                    <div className="flex items-center gap-2 flex-wrap">
                      <span className="font-bold text-xs sm:text-sm text-slate-900">
                        {batch.batchNumber}
                      </span>
                      {getStatusBadge(batch)}
                    </div>
                    <div className="text-xs text-slate-600 mt-0.5 truncate">
                      {batch.farmerName} • {batch.mandiLocation}
                    </div>
                    <div className="text-[11px] text-slate-400 mt-0.5">
                      {batch.onionVariety} • {batch.weightQuintals} {t.common.qtl} ({batch.bagCount} {t.common.bags})
                    </div>
                  </div>
                </div>

                <ChevronRight className="w-4 h-4 text-slate-400 shrink-0" />
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Floating Quick Action CTA */}
      <div className="pt-2">
        <button
          type="button"
          onClick={() => onOpenInspection()}
          className="w-full py-3 px-4 rounded-xl bg-[#7C2D12] text-white font-bold text-sm shadow-md hover:bg-[#68250e] flex items-center justify-center gap-2 transition-colors cursor-pointer"
        >
          <Camera className="w-4 h-4" />
          <span>{t.dashboard.analyzeHeapCta}</span>
        </button>
      </div>
    </div>
  );
};
