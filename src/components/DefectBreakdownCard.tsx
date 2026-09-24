import React from 'react';
import { DefectCountsModel, DEFECT_DETAILS, DefectType } from '../types';
import { Heart, Scissors, Skull, Leaf, Minimize2, HelpCircle } from 'lucide-react';
import { useLanguage } from '../i18n/LanguageContext';

interface DefectBreakdownCardProps {
  defects: DefectCountsModel;
  onSelectFilter?: (defect: DefectType) => void;
  activeFilter?: DefectType | null;
}

export const DefectBreakdownCard: React.FC<DefectBreakdownCardProps> = ({
  defects,
  onSelectFilter,
  activeFilter,
}) => {
  const { t } = useLanguage();

  const items: {
    type: DefectType;
    label: string;
    description: string;
    count: number;
    icon: React.ComponentType<{ className?: string }>;
  }[] = [
    {
      type: 'Healthy',
      label: t.defects.healthy,
      description: t.defects.healthyDesc,
      count: defects.healthy,
      icon: Heart,
    },
    {
      type: 'Damaged',
      label: t.defects.damaged,
      description: t.defects.damagedDesc,
      count: defects.damaged,
      icon: Scissors,
    },
    {
      type: 'Rotten',
      label: t.defects.rotten,
      description: t.defects.rottenDesc,
      count: defects.rotten,
      icon: Skull,
    },
    {
      type: 'Sprouted',
      label: t.defects.sprouted,
      description: t.defects.sproutedDesc,
      count: defects.sprouted,
      icon: Leaf,
    },
    {
      type: 'Undersized',
      label: t.defects.undersized,
      description: t.defects.undersizedDesc,
      count: defects.undersized,
      icon: Minimize2,
    },
    {
      type: 'Unknown',
      label: t.defects.unknown,
      description: t.defects.unknownDesc,
      count: defects.unknown,
      icon: HelpCircle,
    },
  ];

  return (
    <div className="bg-white rounded-xl border border-slate-200 p-4 sm:p-5 shadow-xs">
      <div className="flex items-center justify-between mb-3">
        <div>
          <h3 className="text-sm font-bold text-slate-800">
            {t.defects.title}
          </h3>
          <p className="text-xs text-slate-500">
            {t.defects.subtitle}
          </p>
        </div>
        <span className="text-xs font-semibold px-2 py-0.5 rounded bg-slate-100 text-slate-700">
          {t.common.total}: {defects.total}
        </span>
      </div>

      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-2.5">
        {items.map(({ type, label, description, count, icon: Icon }) => {
          const meta = DEFECT_DETAILS[type];
          const isSelected = activeFilter === type;

          return (
            <button
              key={type}
              type="button"
              onClick={() => onSelectFilter?.(type)}
              className={`p-3 rounded-xl border text-left transition-all cursor-pointer ${
                isSelected
                  ? 'ring-2 ring-slate-800 border-transparent shadow-sm'
                  : 'border-slate-200 hover:border-slate-300 bg-slate-50/50'
              }`}
            >
              <div className="flex items-center justify-between mb-1.5">
                <div
                  className="w-7 h-7 rounded-lg flex items-center justify-center text-white"
                  style={{ backgroundColor: meta.color }}
                >
                  <Icon className="w-4 h-4" />
                </div>
                <span className="text-lg font-black text-slate-800">{count}</span>
              </div>
              <div className="text-xs font-bold text-slate-800 truncate">{label}</div>
              <div className="text-[10px] text-slate-500 leading-tight line-clamp-1">
                {description}
              </div>
            </button>
          );
        })}
      </div>
    </div>
  );
};
