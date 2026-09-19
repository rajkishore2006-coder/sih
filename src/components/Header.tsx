import React from 'react';
import { Sprout, Sparkles, Server, ArrowLeft } from 'lucide-react';
import { AppConfig } from '../config/appConfig';
import { AiSettings } from '../services/appState';

interface HeaderProps {
  aiSettings: AiSettings;
  onOpenAiSettings: () => void;
  canGoBack?: boolean;
  onBack?: () => void;
  onGoHome?: () => void;
  title?: string;
  subtitle?: string;
}

export const Header: React.FC<HeaderProps> = ({
  aiSettings,
  onOpenAiSettings,
  canGoBack,
  onBack,
  onGoHome,
  title,
  subtitle,
}) => {
  return (
    <header className="sticky top-0 z-30 bg-white border-b border-slate-200 px-4 py-3 shadow-xs">
      <div className="max-w-6xl mx-auto flex items-center justify-between">
        <div className="flex items-center gap-3">
          {canGoBack && onBack && (
            <button
              onClick={onBack}
              className="p-1.5 rounded-lg text-slate-600 hover:text-slate-900 hover:bg-slate-100 transition-colors cursor-pointer"
              title="Back"
            >
              <ArrowLeft className="w-5 h-5" />
            </button>
          )}

          <div
            onClick={onGoHome}
            className={`flex items-center gap-3 ${onGoHome ? 'cursor-pointer select-none group' : ''}`}
            title={onGoHome ? 'Return to Home Dashboard' : undefined}
          >
            <div className="p-2 rounded-lg bg-amber-950/10 text-amber-900 flex items-center justify-center group-hover:bg-amber-950/15 transition-colors">
              <Sprout className="w-5 h-5 text-[#9A3412]" />
            </div>

            <div>
              <div className="flex items-center gap-2">
                <h1 className="text-lg font-bold text-slate-900 tracking-tight group-hover:text-[#7C2D12] transition-colors">
                  {title || AppConfig.appName}
                </h1>
                <span className="hidden sm:inline-block text-[10px] uppercase font-semibold px-2 py-0.5 rounded-full bg-slate-100 text-slate-600 border border-slate-200">
                  {AppConfig.sihProblemCode}
                </span>
              </div>
              <p className="text-xs text-slate-500">
                {subtitle || 'Digital Onion Grading • Mandi APMC Quality Intelligence'}
              </p>
            </div>
          </div>
        </div>

        {/* AI Mode Selector Pill */}
        <div className="flex items-center gap-2">
          <button
            onClick={onOpenAiSettings}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-semibold border transition-all ${
              aiSettings.useMockAi
                ? 'bg-amber-50 text-amber-900 border-amber-300 hover:bg-amber-100'
                : 'bg-emerald-50 text-emerald-800 border-emerald-300 hover:bg-emerald-100'
            }`}
          >
            {aiSettings.useMockAi ? (
              <>
                <Sparkles className="w-3.5 h-3.5 text-amber-700" />
                <span>Demo AI</span>
              </>
            ) : (
              <>
                <Server className="w-3.5 h-3.5 text-emerald-700" />
                <span>Live API</span>
              </>
            )}
          </button>
        </div>
      </div>
    </header>
  );
};
