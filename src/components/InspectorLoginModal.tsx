import React, { useState } from 'react';
import { UserCheck, X, Shield, Check, Lock } from 'lucide-react';
import { useLanguage } from '../i18n/LanguageContext';

export interface InspectorProfile {
  name: string;
  id: string;
  mandi: string;
  isAuthenticated: boolean;
}

const INSPECTOR_STORAGE_KEY = 'onionsure_inspector_session_v1';

export function loadSavedInspector(): InspectorProfile {
  try {
    const raw = localStorage.getItem(INSPECTOR_STORAGE_KEY);
    if (raw) {
      return JSON.parse(raw);
    }
  } catch (e) {
    console.warn('Could not read saved inspector profile:', e);
  }
  return {
    name: 'Dr. V. K. Deshmukh',
    id: 'INS-MH-704',
    mandi: 'Lasalgaon APMC, Nashik',
    isAuthenticated: true,
  };
}

export function saveInspector(profile: InspectorProfile): void {
  try {
    localStorage.setItem(INSPECTOR_STORAGE_KEY, JSON.stringify(profile));
  } catch (e) {
    console.warn('Could not save inspector profile:', e);
  }
}

interface InspectorLoginModalProps {
  isOpen: boolean;
  onClose: () => void;
  currentProfile: InspectorProfile;
  onSaveProfile: (profile: InspectorProfile) => void;
}

export const InspectorLoginModal: React.FC<InspectorLoginModalProps> = ({
  isOpen,
  onClose,
  currentProfile,
  onSaveProfile,
}) => {
  const { t } = useLanguage();
  const [name, setName] = useState(currentProfile.name);
  const [id, setId] = useState(currentProfile.id);
  const [mandi, setMandi] = useState(currentProfile.mandi);
  const [pin, setPin] = useState('2026');
  const [success, setSuccess] = useState(false);

  if (!isOpen) return null;

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    const updated: InspectorProfile = {
      name: name.trim() || 'Dr. V. K. Deshmukh',
      id: id.trim() || 'INS-MH-704',
      mandi: mandi.trim() || 'Lasalgaon APMC, Nashik',
      isAuthenticated: true,
    };
    saveInspector(updated);
    onSaveProfile(updated);
    setSuccess(true);
    setTimeout(() => {
      setSuccess(false);
      onClose();
    }, 1200);
  };

  const handleLogout = () => {
    const defaultProfile: InspectorProfile = {
      name: 'Guest Grader',
      id: 'INS-TEMP-001',
      mandi: 'Lasalgaon APMC, Nashik',
      isAuthenticated: false,
    };
    setName(defaultProfile.name);
    setId(defaultProfile.id);
    setMandi(defaultProfile.mandi);
    saveInspector(defaultProfile);
    onSaveProfile(defaultProfile);
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/50 backdrop-blur-xs">
      <div className="bg-white rounded-xl shadow-xl border border-slate-200 max-w-md w-full overflow-hidden animate-in fade-in zoom-in-95 duration-150">
        <div className="px-5 py-4 border-b border-slate-200 flex items-center justify-between">
          <div className="flex items-center gap-2 text-slate-900 font-bold text-base">
            <UserCheck className="w-5 h-5 text-[#7C2D12]" />
            <span>{t.login.title}</span>
          </div>
          <button
            onClick={onClose}
            className="text-slate-400 hover:text-slate-600 p-1 rounded-lg hover:bg-slate-100 cursor-pointer"
            title={t.common.close}
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <form onSubmit={handleLogin} className="p-5 space-y-4">
          <div className="flex items-center justify-between p-3 rounded-lg bg-emerald-50 border border-emerald-200">
            <div className="flex items-center gap-2.5">
              <Shield className="w-5 h-5 text-emerald-700" />
              <div>
                <div className="text-xs font-bold text-emerald-900">
                  {currentProfile.isAuthenticated ? t.login.activeSession : t.login.subtitle}
                </div>
                <div className="text-[11px] text-emerald-700 font-mono">
                  {currentProfile.name} ({currentProfile.id})
                </div>
              </div>
            </div>
            <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 border border-emerald-300">
              {t.login.sessionBadge}
            </span>
          </div>

          {success && (
            <div className="p-3 bg-emerald-100 text-emerald-900 text-xs rounded-lg flex items-center gap-2 font-medium">
              <Check className="w-4 h-4 text-emerald-700" />
              <span>{t.login.successMessage}</span>
            </div>
          )}

          <div className="space-y-3">
            <div className="space-y-1">
              <label className="block text-xs font-semibold text-slate-700">
                {t.login.inspectorNameLabel}
              </label>
              <input
                type="text"
                required
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="e.g. Dr. V. K. Deshmukh"
                className="w-full text-xs px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#7C2D12]"
              />
            </div>

            <div className="space-y-1">
              <label className="block text-xs font-semibold text-slate-700">
                {t.login.inspectorIdLabel}
              </label>
              <input
                type="text"
                required
                value={id}
                onChange={(e) => setId(e.target.value)}
                placeholder="e.g. INS-MH-704"
                className="w-full text-xs px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#7C2D12] font-mono"
              />
            </div>

            <div className="space-y-1">
              <label className="block text-xs font-semibold text-slate-700">
                {t.login.mandiLocationLabel}
              </label>
              <input
                type="text"
                value={mandi}
                onChange={(e) => setMandi(e.target.value)}
                placeholder="e.g. Lasalgaon APMC, Nashik"
                className="w-full text-xs px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#7C2D12]"
              />
            </div>

            <div className="space-y-1">
              <label className="block text-xs font-semibold text-slate-700 flex items-center gap-1">
                <Lock className="w-3.5 h-3.5 text-slate-400" />
                <span>{t.login.pinLabel}</span>
              </label>
              <input
                type="password"
                value={pin}
                onChange={(e) => setPin(e.target.value)}
                maxLength={6}
                className="w-full text-xs px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#7C2D12] font-mono tracking-widest"
              />
            </div>
          </div>

          <p className="text-[11px] text-slate-400 italic">
            {t.login.demoCredentialsHint}
          </p>

          <div className="px-5 py-3.5 -mx-5 -mb-5 bg-slate-50 border-t border-slate-200 flex items-center justify-between gap-2">
            {currentProfile.isAuthenticated && (
              <button
                type="button"
                onClick={handleLogout}
                className="text-xs text-red-600 hover:text-red-700 font-semibold cursor-pointer"
              >
                {t.login.logoutBtn}
              </button>
            )}

            <div className="flex items-center gap-2 ml-auto">
              <button
                type="button"
                onClick={onClose}
                className="px-3 py-1.5 rounded-lg text-xs font-semibold text-slate-600 hover:bg-slate-200 transition-colors cursor-pointer"
              >
                {t.common.cancel}
              </button>
              <button
                type="submit"
                className="px-4 py-1.5 rounded-lg text-xs font-semibold bg-[#7C2D12] text-white hover:bg-[#63230e] flex items-center gap-1.5 transition-colors shadow-xs cursor-pointer"
              >
                <Check className="w-3.5 h-3.5" />
                <span>{t.login.loginBtn}</span>
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  );
};
