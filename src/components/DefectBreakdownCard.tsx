import React from 'react';
import { DefectCountsModel, DEFECT_DETAILS, DefectType } from '../types';
import { Heart, Scissors, Skull, Leaf, Minimize2, HelpCircle } from 'lucide-react';

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
  const items: {
    type: DefectType;
    count: number;
    icon: React.ComponentType<{ className?: string }>;
  }[] = [
    { type: 'Healthy', count: defects.healthy, icon: Heart },
    { type: 'Damaged', count: defects.damaged, icon: Scissors },
    { type: 'Rotten', count: defects.rotten, icon: Skull },
    { type: 'Sprouted', count: defects.sprouted, icon: Leaf },
    { type: 'Undersized', count: defects.undersized, icon: Minimize2 },
    { type: 'Unknown', count: defects.unknown, icon: HelpCircle },
  ];

  return (
    <div className="bg-white rounded-xl border border-slate-200 p-4 sm:p-5 shadow-xs">
      <div className="flex items-center justify-between mb-3">
        <div>
          <h3 className="text-sm font-bold text-slate-800">
            Defect Classification Breakdown
          </h3>
          <p className="text-xs text-slate-500">
            Detected surface bulb instances categorized by condition
          </p>
        </div>
        <span className="text-xs font-semibold px-2 py-0.5 rounded bg-slate-100 text-slate-700">
          Total: {defects.total} bulbs
        </span>
      </div>

      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-2.5">
        {items.map(({ type, count, icon: Icon }) => {
          const meta = DEFECT_DETAILS[type];
          const isSelected = activeFilter === type;

          return (
            <button
              key={type}
              type="button"
              onClick={() => onSelectFilter?.(type)}
              className={`p-3 rounded-xl border text-left transition-all ${
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
              <div className="text-xs font-bold text-slate-800 truncate">{type}</div>
              <div className="text-[10px] text-slate-500 leading-tight line-clamp-1">
                {meta.description}
              </div>
            </button>
          );
        })}
      </div>
    </div>
  );
};
