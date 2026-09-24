import React, { useState } from 'react';
import { usePWAInstall } from '../hooks/usePWAInstall';
import { Download, Share2, X, Smartphone } from 'lucide-react';
import { useLanguage } from '../i18n/LanguageContext';

export const PWAInstallButton: React.FC<{ compact?: boolean }> = ({ compact = false }) => {
  const { isInstallable, isInstalled, isIOS, install } = usePWAInstall();
  const { t } = useLanguage();
  const [showIOSGuide, setShowIOSGuide] = useState(false);

  // If already running as an installed PWA, hide the button
  if (isInstalled) {
    return null;
  }

  // Chromium / Android / Desktop flow
  if (isInstallable) {
    return (
      <button
        onClick={install}
        title={t.offline.installApp}
        className="flex items-center gap-1.5 px-2.5 sm:px-3 py-1.5 rounded-full text-xs font-semibold bg-[#7C2D12] text-white hover:bg-[#68250e] shadow-2xs transition-all cursor-pointer"
      >
        <Download className="w-3.5 h-3.5" />
        <span className={compact ? 'hidden sm:inline' : ''}>{t.offline.installApp}</span>
      </button>
    );
  }

  // iOS Safari flow
  if (isIOS) {
    return (
      <>
        <button
          onClick={() => setShowIOSGuide(true)}
          title={t.offline.installOnIos}
          className="flex items-center gap-1.5 px-2.5 sm:px-3 py-1.5 rounded-full text-xs font-semibold border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 transition-all cursor-pointer shadow-2xs"
        >
          <Smartphone className="w-3.5 h-3.5 text-[#7C2D12]" />
          <span className={compact ? 'hidden sm:inline' : ''}>{t.offline.installOnIos}</span>
        </button>

        {showIOSGuide && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-xs p-4">
            <div className="w-full max-w-sm rounded-xl bg-white p-5 shadow-xl border border-slate-200 animate-in fade-in zoom-in-95">
              <div className="flex items-center justify-between pb-3 border-b border-slate-100">
                <h3 className="text-sm font-bold text-slate-900 flex items-center gap-2">
                  <Smartphone className="w-4 h-4 text-[#7C2D12]" />
                  <span>{t.offline.iosInstallTitle}</span>
                </h3>
                <button
                  onClick={() => setShowIOSGuide(false)}
                  className="text-slate-400 hover:text-slate-600 p-1 rounded"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>

              <div className="py-4 space-y-3 text-xs text-slate-700">
                <div className="flex items-start gap-2.5 bg-slate-50 p-3 rounded-lg border border-slate-100">
                  <span className="w-5 h-5 rounded-full bg-[#7C2D12] text-white flex items-center justify-center font-bold text-[10px] shrink-0">
                    1
                  </span>
                  <div>
                    <span className="font-semibold block">{t.offline.iosInstallStep1}</span>
                    <span className="text-[11px] text-slate-400 flex items-center gap-1 mt-0.5">
                      <Share2 className="w-3 h-3 text-sky-600 inline" /> (Share icon at the bottom of Safari)
                    </span>
                  </div>
                </div>

                <div className="flex items-start gap-2.5 bg-slate-50 p-3 rounded-lg border border-slate-100">
                  <span className="w-5 h-5 rounded-full bg-[#7C2D12] text-white flex items-center justify-center font-bold text-[10px] shrink-0">
                    2
                  </span>
                  <div>
                    <span className="font-semibold block">{t.offline.iosInstallStep2}</span>
                    <span className="text-[11px] text-slate-400 mt-0.5 block">
                      Enables offline Mandi usage with full icon on your home screen.
                    </span>
                  </div>
                </div>
              </div>

              <button
                onClick={() => setShowIOSGuide(false)}
                className="w-full rounded-lg bg-slate-100 py-2 text-xs font-semibold text-slate-700 hover:bg-slate-200 transition-colors"
              >
                {t.common.close}
              </button>
            </div>
          </div>
        )}
      </>
    );
  }

  return null;
};
