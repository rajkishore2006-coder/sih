import React from 'react';
import { GradeDistributionModel } from '../types';
import { useLanguage } from '../i18n/LanguageContext';

interface QualityDistributionProps {
  grades: GradeDistributionModel;
}

export const QualityDistribution: React.FC<QualityDistributionProps> = ({ grades }) => {
  const { t } = useLanguage();

  return (
    <div className="bg-white rounded-xl border border-slate-200 p-4 sm:p-5 shadow-xs">
      <div className="flex items-center justify-between mb-3">
        <h3 className="text-sm font-bold text-slate-800">
          {t.grades.title}
        </h3>
        <span className="text-xs text-slate-500 font-medium">{t.grades.standard}</span>
      </div>

      {/* Stacked Visual Bar */}
      <div className="w-full h-4 rounded-full overflow-hidden flex bg-slate-100 mb-4 shadow-inner">
        <div
          style={{ width: `${grades.gradeAPercent}%` }}
          className="bg-emerald-600 transition-all duration-500"
          title={`${t.grades.gradeA}: ${grades.gradeAPercent}%`}
        />
        <div
          style={{ width: `${grades.gradeBPercent}%` }}
          className="bg-amber-500 transition-all duration-500"
          title={`${t.grades.gradeB}: ${grades.gradeBPercent}%`}
        />
        <div
          style={{ width: `${grades.rejectPercent}%` }}
          className="bg-red-600 transition-all duration-500"
          title={`${t.grades.reject}: ${grades.rejectPercent}%`}
        />
      </div>

      {/* Grade Metrics Breakdown */}
      <div className="grid grid-cols-3 gap-2 sm:gap-3 text-center">
        <div className="p-2.5 rounded-lg bg-emerald-50/70 border border-emerald-200/80">
          <span className="inline-block w-2 h-2 rounded-full bg-emerald-600 mb-1" />
          <div className="text-xs font-bold text-emerald-950">{t.grades.gradeA}</div>
          <div className="text-lg sm:text-xl font-extrabold text-emerald-700">
            {grades.gradeAPercent}%
          </div>
          <div className="text-[10px] text-emerald-800/80">{t.grades.gradeASubtitle}</div>
        </div>

        <div className="p-2.5 rounded-lg bg-amber-50/70 border border-amber-200/80">
          <span className="inline-block w-2 h-2 rounded-full bg-amber-500 mb-1" />
          <div className="text-xs font-bold text-amber-950">{t.grades.gradeB}</div>
          <div className="text-lg sm:text-xl font-extrabold text-amber-700">
            {grades.gradeBPercent}%
          </div>
          <div className="text-[10px] text-amber-800/80">{t.grades.gradeBSubtitle}</div>
        </div>

        <div className="p-2.5 rounded-lg bg-red-50/70 border border-red-200/80">
          <span className="inline-block w-2 h-2 rounded-full bg-red-600 mb-1" />
          <div className="text-xs font-bold text-red-950">{t.grades.reject}</div>
          <div className="text-lg sm:text-xl font-extrabold text-red-700">
            {grades.rejectPercent}%
          </div>
          <div className="text-[10px] text-red-800/80">{t.grades.rejectSubtitle}</div>
        </div>
      </div>
    </div>
  );
};
