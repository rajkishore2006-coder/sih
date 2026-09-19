import React from 'react';
import { AlertTriangle } from 'lucide-react';

interface DisclaimerBannerProps {
  disclaimerText?: string;
  className?: string;
}

export const DisclaimerBanner: React.FC<DisclaimerBannerProps> = ({
  disclaimerText,
  className = '',
}) => {
  const text =
    disclaimerText ||
    'Estimation is derived solely from visible surface onions in the heap image. ' +
    'Internal, occluded, and sub-surface onions are not directly measurable. ' +
    'Calibrate with physical cross-sectional sampling for final trade settlement.';

  return (
    <div
      className={`bg-amber-50/80 border border-amber-300/80 rounded-lg p-3.5 flex gap-3 text-amber-950 ${className}`}
    >
      <AlertTriangle className="w-5 h-5 text-amber-700 shrink-0 mt-0.5" />
      <div className="text-xs leading-relaxed">
        <p className="font-bold text-amber-900 mb-0.5">
          IMPORTANT ESTIMATION BOUNDARY & MANDI DISCLAIMER
        </p>
        <p className="text-amber-800">{text}</p>
      </div>
    </div>
  );
};
