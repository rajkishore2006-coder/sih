import React, { useState } from 'react';
import { QrCode, X, Search } from 'lucide-react';
import { OnionBatch } from '../types';
import { useLanguage } from '../i18n/LanguageContext';

interface ScanBatchModalProps {
  isOpen: boolean;
  onClose: () => void;
  batches: OnionBatch[];
  onSelectBatch: (batchId: string) => void;
}

export const ScanBatchModal: React.FC<ScanBatchModalProps> = ({
  isOpen,
  onClose,
  batches,
  onSelectBatch,
}) => {
  const { t, interpolate } = useLanguage();
  const [query, setQuery] = useState('');
  const [error, setError] = useState('');

  if (!isOpen) return null;

  const handleSearch = () => {
    const clean = query.trim().toLowerCase();
    if (!clean) {
      setError(t.scanModal.errorEmpty);
      return;
    }

    const found = batches.find(
      (b) =>
        b.batchNumber.toLowerCase().includes(clean) ||
        b.id.toLowerCase().includes(clean) ||
        (b.qrCodeData && b.qrCodeData.toLowerCase().includes(clean))
    );

    if (found) {
      onSelectBatch(found.id);
      onClose();
    } else {
      setError(interpolate(t.scanModal.errorNotFound, { query }));
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/50 backdrop-blur-xs">
      <div className="bg-white rounded-xl shadow-xl border border-slate-200 max-w-md w-full overflow-hidden animate-in fade-in zoom-in-95 duration-150">
        <div className="px-5 py-4 border-b border-slate-200 flex items-center justify-between">
          <div className="flex items-center gap-2 text-slate-900 font-bold text-base">
            <QrCode className="w-5 h-5 text-[#7C2D12]" />
            <span>{t.scanModal.title}</span>
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
          <p className="text-xs text-slate-600">
            {t.scanModal.desc}
          </p>

          <div className="relative">
            <input
              type="text"
              value={query}
              onChange={(e) => {
                setQuery(e.target.value);
                setError('');
              }}
              onKeyDown={(e) => e.key === 'Enter' && handleSearch()}
              placeholder={t.scanModal.placeholder}
              className="w-full text-xs pl-9 pr-3 py-2.5 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#7C2D12] font-mono"
            />
            <QrCode className="w-4 h-4 text-slate-400 absolute left-3 top-3 pointer-events-none" />
          </div>

          {error && <p className="text-xs text-red-600 font-medium">{error}</p>}

          <div>
            <span className="text-[11px] font-semibold text-slate-500 block mb-1.5">
              {t.scanModal.testSamples}
            </span>
            <div className="flex flex-wrap gap-1.5">
              {batches.slice(0, 3).map((b) => (
                <button
                  key={b.id}
                  type="button"
                  onClick={() => {
                    setQuery(b.batchNumber);
                    setError('');
                  }}
                  className="text-[11px] font-mono px-2.5 py-1 rounded-full bg-slate-100 text-slate-700 hover:bg-slate-200 border border-slate-200 transition-colors cursor-pointer"
                >
                  {b.batchNumber}
                </button>
              ))}
            </div>
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
            onClick={handleSearch}
            className="px-4 py-1.5 rounded-lg text-xs font-semibold bg-[#7C2D12] text-white hover:bg-[#63230e] flex items-center gap-1.5 transition-colors shadow-xs cursor-pointer"
          >
            <Search className="w-3.5 h-3.5" />
            <span>{t.scanModal.findBatch}</span>
          </button>
        </div>
      </div>
    </div>
  );
};
