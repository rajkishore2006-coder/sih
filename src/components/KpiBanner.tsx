import React from 'react';
import { Layers, ClipboardCheck, ShieldCheck, Weight } from 'lucide-react';
import { useLanguage } from '../i18n/LanguageContext';

interface KpiBannerProps {
  totalBatches: number;
  inspectedBatchesCount: number;
  averageGradeAPercentage: number;
  totalWeightQuintals: number;
}

export const KpiBanner: React.FC<KpiBannerProps> = ({
  totalBatches,
  inspectedBatchesCount,
  averageGradeAPercentage,
  totalWeightQuintals,
}) => {
  const { t } = useLanguage();

  return (
    <div className="bg-white rounded-xl border border-slate-200 p-4 sm:p-5 shadow-xs">
      <div className="flex items-center justify-between mb-4">
        <div>
          <h2 className="text-sm sm:text-base font-bold text-slate-800">
            {t.dashboard.kpiTitle}
          </h2>
          <p className="text-xs text-slate-500">
            {t.dashboard.kpiSubtitle}
          </p>
        </div>
        <span className="text-[11px] font-semibold px-2.5 py-1 rounded bg-slate-100 text-slate-700 border border-slate-200">
          {t.dashboard.eNamReady}
        </span>
      </div>

      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 sm:divide-x sm:divide-slate-200 sm:gap-0">
        <div className="flex flex-col items-center justify-center p-2 text-center">
          <div className="flex items-center gap-1.5 text-slate-700 font-bold text-lg sm:text-xl">
            <Layers className="w-4 h-4 text-slate-500" />
            <span>{totalBatches}</span>
          </div>
          <span className="text-[11px] text-slate-500 font-medium">{t.dashboard.totalBatches}</span>
        </div>

        <div className="flex flex-col items-center justify-center p-2 text-center">
          <div className="flex items-center gap-1.5 text-sky-700 font-bold text-lg sm:text-xl">
            <ClipboardCheck className="w-4 h-4 text-sky-600" />
            <span>{inspectedBatchesCount}</span>
          </div>
          <span className="text-[11px] text-slate-500 font-medium">{t.dashboard.inspectedLots}</span>
        </div>

        <div className="flex flex-col items-center justify-center p-2 text-center">
          <div className="flex items-center gap-1.5 text-emerald-700 font-bold text-lg sm:text-xl">
            <ShieldCheck className="w-4 h-4 text-emerald-600" />
            <span>{averageGradeAPercentage}%</span>
          </div>
          <span className="text-[11px] text-slate-500 font-medium">{t.dashboard.avgGradeA}</span>
        </div>

        <div className="flex flex-col items-center justify-center p-2 text-center">
          <div className="flex items-center gap-1.5 text-[#7C2D12] font-bold text-lg sm:text-xl">
            <Weight className="w-4 h-4 text-[#7C2D12]" />
            <span>{Math.round(totalWeightQuintals)} {t.common.qtl}</span>
          </div>
          <span className="text-[11px] text-slate-500 font-medium">{t.dashboard.totalVolume}</span>
        </div>
      </div>
    </div>
  );
};
