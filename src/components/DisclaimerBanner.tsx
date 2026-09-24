import React from 'react';
import { AlertTriangle } from 'lucide-react';
import { useLanguage } from '../i18n/LanguageContext';

interface DisclaimerBannerProps {
  disclaimerText?: string;
  className?: string;
}

export const DisclaimerBanner: React.FC<DisclaimerBannerProps> = ({
  disclaimerText,
  className = '',
}) => {
  const { t } = useLanguage();

  const text = disclaimerText || t.disclaimer.body;

  return (
    <div
      className={`bg-amber-50/80 border border-amber-300/80 rounded-lg p-3.5 flex gap-3 text-amber-950 ${className}`}
    >
      <AlertTriangle className="w-5 h-5 text-amber-700 shrink-0 mt-0.5" />
      <div className="text-xs leading-relaxed">
        <p className="font-bold text-amber-900 mb-0.5">
          {t.disclaimer.heading}
        </p>
        <p className="text-amber-800">{text}</p>
      </div>
    </div>
  );
};
