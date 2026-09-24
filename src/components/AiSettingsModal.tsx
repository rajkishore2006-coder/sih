import React, { useState } from 'react';
import { AiSettings } from '../services/appState';
import { X, Sparkles, Server, Check, Activity } from 'lucide-react';
import { useLanguage } from '../i18n/LanguageContext';

interface AiSettingsModalProps {
  isOpen: boolean;
  onClose: () => void;
  currentSettings: AiSettings;
  onSave: (newSettings: AiSettings) => void;
}

export const AiSettingsModal: React.FC<AiSettingsModalProps> = ({
  isOpen,
  onClose,
  currentSettings,
  onSave,
}) => {
  const { t } = useLanguage();
  const [useMock, setUseMock] = useState(currentSettings.useMockAi);
  const [url, setUrl] = useState(currentSettings.aiApiUrl);
  const [enableDiagnostics, setEnableDiagnostics] = useState(
    Boolean(currentSettings.enableDiagnostics)
  );

  if (!isOpen) return null;

  const handleApply = () => {
    onSave({
      useMockAi: useMock,
      aiApiUrl: url.trim(),
      enableDiagnostics,
    });
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/50 backdrop-blur-xs">
      <div className="bg-white rounded-xl shadow-xl border border-slate-200 max-w-md w-full overflow-hidden animate-in fade-in zoom-in-95 duration-150">
        <div className="px-5 py-4 border-b border-slate-200 flex items-center justify-between">
          <div className="flex items-center gap-2 text-slate-900 font-bold text-base">
            <Server className="w-4 h-4 text-[#7C2D12]" />
            <span>{t.aiSettingsModal.title}</span>
          </div>
          <button
            onClick={onClose}
            className="text-slate-400 hover:text-slate-600 p-1 rounded-lg hover:bg-slate-100 cursor-pointer"
            title={t.common.close}
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="p-5 space-y-4">
          <div className="flex items-start justify-between gap-3 p-3.5 rounded-lg border border-slate-200 bg-slate-50/70">
            <div>
              <div className="text-sm font-bold text-slate-800 flex items-center gap-1.5">
                <Sparkles className="w-4 h-4 text-amber-600" />
                <span>{t.aiSettingsModal.demoModeTitle}</span>
              </div>
              <p className="text-xs text-slate-500 mt-1">
                {t.aiSettingsModal.demoModeDesc}
              </p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer shrink-0 mt-1">
              <input
                type="checkbox"
                checked={useMock}
                onChange={(e) => setUseMock(e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-[#7C2D12]"></div>
            </label>
          </div>

          {!useMock && (
            <div className="space-y-1.5 animate-in fade-in">
              <label className="block text-xs font-bold text-slate-700">
                {t.aiSettingsModal.apiUrlLabel}
              </label>
              <input
                type="text"
                value={url}
                onChange={(e) => setUrl(e.target.value)}
                placeholder="http://localhost:8000/api/analyze-heap"
                className="w-full text-xs px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#7C2D12]"
              />
              <p className="text-[11px] text-slate-400">
                {t.aiSettingsModal.apiUrlDesc}
              </p>
            </div>
          )}

          {/* Developer Diagnostics Toggle (Disabled by default) */}
          <div className="flex items-start justify-between gap-3 p-3.5 rounded-lg border border-slate-200 bg-slate-50/70">
            <div>
              <div className="text-sm font-bold text-slate-800 flex items-center gap-1.5">
                <Activity className="w-4 h-4 text-sky-600" />
                <span>{t.aiSettingsModal.diagnosticsTitle}</span>
              </div>
              <p className="text-xs text-slate-500 mt-1">
                {t.aiSettingsModal.diagnosticsDesc}
              </p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer shrink-0 mt-1">
              <input
                type="checkbox"
                checked={enableDiagnostics}
                onChange={(e) => setEnableDiagnostics(e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-sky-600"></div>
            </label>
          </div>
        </div>

        <div className="px-5 py-3.5 bg-slate-50 border-t border-slate-200 flex justify-end gap-2">
          <button
            onClick={onClose}
            className="px-3 py-1.5 rounded-lg text-xs font-semibold text-slate-600 hover:bg-slate-200 transition-colors cursor-pointer"
          >
            {t.common.cancel}
          </button>
          <button
            onClick={handleApply}
            className="px-4 py-1.5 rounded-lg text-xs font-semibold bg-[#7C2D12] text-white hover:bg-[#63230e] flex items-center gap-1.5 transition-colors shadow-xs cursor-pointer"
          >
            <Check className="w-3.5 h-3.5" />
            <span>{t.aiSettingsModal.applyBtn}</span>
          </button>
        </div>
      </div>
    </div>
  );
};
