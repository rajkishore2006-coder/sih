import React from 'react';
import { Sprout, Sparkles, Server, ArrowLeft, UserCheck } from 'lucide-react';
import { AppConfig } from '../config/appConfig';
import { AiSettings } from '../services/appState';
import { LanguageSelector } from './LanguageSelector';
import { PWAInstallButton } from './PWAInstallButton';
import { useLanguage } from '../i18n/LanguageContext';

interface HeaderProps {
  aiSettings: AiSettings;
  onOpenAiSettings: () => void;
  canGoBack?: boolean;
  onBack?: () => void;
  onGoHome?: () => void;
  title?: string;
  subtitle?: string;
  inspectorName?: string;
  onOpenLogin?: () => void;
}

export const Header: React.FC<HeaderProps> = ({
  aiSettings,
  onOpenAiSettings,
  canGoBack,
  onBack,
  onGoHome,
  title,
  subtitle,
  inspectorName,
  onOpenLogin,
}) => {
  const { t } = useLanguage();

  return (
    <header className="sticky top-0 z-30 bg-white border-b border-slate-200 px-3 sm:px-4 py-2.5 sm:py-3 shadow-xs">
      <div className="max-w-6xl mx-auto flex items-center justify-between gap-2">
        <div className="flex items-center gap-2 sm:gap-3 min-w-0">
          {canGoBack && onBack && (
            <button
              onClick={onBack}
              className="p-1.5 rounded-lg text-slate-600 hover:text-slate-900 hover:bg-slate-100 transition-colors cursor-pointer shrink-0"
              title={t.common.back}
            >
              <ArrowLeft className="w-5 h-5" />
            </button>
          )}

          <div
            onClick={onGoHome}
            className={`flex items-center gap-2.5 sm:gap-3 min-w-0 ${
              onGoHome ? 'cursor-pointer select-none group' : ''
            }`}
            title={onGoHome ? t.nav.home : undefined}
          >
            <div className="p-2 rounded-lg bg-amber-950/10 text-amber-900 flex items-center justify-center group-hover:bg-amber-950/15 transition-colors shrink-0">
              <Sprout className="w-5 h-5 text-[#9A3412]" />
            </div>

            <div className="min-w-0">
              <div className="flex items-center gap-1.5 sm:gap-2">
                <h1 className="text-base sm:text-lg font-bold text-slate-900 tracking-tight group-hover:text-[#7C2D12] transition-colors truncate">
                  {title || t.appName}
                </h1>
                <span className="hidden md:inline-block text-[10px] uppercase font-semibold px-2 py-0.5 rounded-full bg-slate-100 text-slate-600 border border-slate-200 shrink-0">
                  {AppConfig.sihProblemCode}
                </span>
              </div>
              <p className="text-xs text-slate-500 truncate hidden xs:block">
                {subtitle || t.appSubtitle}
              </p>
            </div>
          </div>
        </div>

        {/* Right actions: Inspector Login, Language Selector & AI Mode */}
        <div className="flex items-center gap-1.5 sm:gap-2 shrink-0">
          {onOpenLogin && (
            <button
              onClick={onOpenLogin}
              title={t.login.title}
              className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-full text-xs font-semibold border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 hover:border-slate-300 transition-all cursor-pointer shadow-2xs"
            >
              <UserCheck className="w-3.5 h-3.5 text-[#7C2D12]" />
              <span className="hidden md:inline truncate max-w-[110px]">
                {inspectorName || t.login.title}
              </span>
            </button>
          )}

          <PWAInstallButton compact={true} />

          <LanguageSelector compact={true} />

          <button
            onClick={onOpenAiSettings}
            title={aiSettings.useMockAi ? t.nav.demoAi : t.nav.liveApi}
            className={`flex items-center gap-1.5 px-2.5 sm:px-3 py-1.5 rounded-full text-xs font-semibold border transition-all cursor-pointer ${
              aiSettings.useMockAi
                ? 'bg-amber-50 text-amber-900 border-amber-300 hover:bg-amber-100'
                : 'bg-emerald-50 text-emerald-800 border-emerald-300 hover:bg-emerald-100'
            }`}
          >
            {aiSettings.useMockAi ? (
              <>
                <Sparkles className="w-3.5 h-3.5 text-amber-700" />
                <span className="hidden sm:inline">{t.nav.demoAi}</span>
              </>
            ) : (
              <>
                <Server className="w-3.5 h-3.5 text-emerald-700" />
                <span className="hidden sm:inline">{t.nav.liveApi}</span>
              </>
            )}
          </button>
        </div>
      </div>
    </header>
  );
};
