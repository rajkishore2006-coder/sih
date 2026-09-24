import React, { useState, useEffect } from 'react';
import { useOnlineStatus } from '../hooks/useOnlineStatus';
import { offlineSyncService, OfflineSyncStatus } from '../services/offlineSyncService';
import { WifiOff, RefreshCw, CheckCircle2, AlertCircle } from 'lucide-react';
import { useLanguage } from '../i18n/LanguageContext';

export const OfflineSyncBanner: React.FC = () => {
  const isOnline = useOnlineStatus();
  const { t, interpolate } = useLanguage();
  const [syncStatus, setSyncStatus] = useState<OfflineSyncStatus>(() =>
    offlineSyncService.getStatus()
  );
  const [justSynced, setJustSynced] = useState(false);
  const [syncError, setSyncError] = useState(false);

  useEffect(() => {
    return offlineSyncService.subscribe((status) => {
      setSyncStatus(status);
    });
  }, []);

  const handleManualSync = async () => {
    setSyncError(false);
    const res = await offlineSyncService.syncPendingData();
    if (res.success && res.syncedCount > 0) {
      setJustSynced(true);
      setTimeout(() => setJustSynced(false), 3500);
    } else if (!res.success) {
      setSyncError(true);
      setTimeout(() => setSyncError(false), 4000);
    }
  };

  // If online, no pending items, and not just synced, don't take up visual space
  if (isOnline && syncStatus.totalPendingCount === 0 && !justSynced && !syncError) {
    return null;
  }

  return (
    <div className="w-full no-print">
      {/* Offline Mode Banner */}
      {!isOnline && (
        <div className="bg-amber-500 text-white px-4 py-2 text-xs font-medium flex items-center justify-between shadow-xs">
          <div className="flex items-center gap-2 max-w-4xl mx-auto w-full">
            <WifiOff className="w-4 h-4 shrink-0" />
            <div className="flex items-center gap-2 flex-wrap">
              <span className="font-bold">{t.offline.offlineMode}:</span>
              <span>{t.offline.cachedDataNotice}</span>
              {syncStatus.totalPendingCount > 0 && (
                <span className="bg-amber-700/60 px-2 py-0.5 rounded-full text-[11px] font-bold">
                  {interpolate(t.offline.pendingSyncCount, {
                    count: syncStatus.totalPendingCount,
                  })}
                </span>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Online with Pending Sync Items */}
      {isOnline && syncStatus.totalPendingCount > 0 && (
        <div className="bg-sky-700 text-white px-4 py-2 text-xs font-medium flex items-center justify-between shadow-xs">
          <div className="flex items-center justify-between max-w-4xl mx-auto w-full gap-3">
            <div className="flex items-center gap-2 flex-wrap">
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
              <span className="font-bold">{t.offline.onlineMode}:</span>
              <span>
                {interpolate(t.offline.pendingSyncCount, {
                  count: syncStatus.totalPendingCount,
                })}
              </span>
            </div>

            <button
              onClick={handleManualSync}
              disabled={syncStatus.isSyncing}
              className="flex items-center gap-1.5 px-3 py-1 bg-white text-sky-900 font-bold rounded-lg text-xs hover:bg-sky-50 transition-colors shadow-2xs cursor-pointer shrink-0 disabled:opacity-75"
            >
              <RefreshCw
                className={`w-3.5 h-3.5 ${syncStatus.isSyncing ? 'animate-spin' : ''}`}
              />
              <span>{syncStatus.isSyncing ? t.offline.syncing : t.offline.syncNow}</span>
            </button>
          </div>
        </div>
      )}

      {/* Just Synced Toast Banner */}
      {justSynced && (
        <div className="bg-emerald-600 text-white px-4 py-2 text-xs font-medium flex items-center justify-center gap-2 animate-in fade-in duration-200">
          <CheckCircle2 className="w-4 h-4 shrink-0" />
          <span>{t.offline.syncSuccess}</span>
        </div>
      )}

      {/* Sync Error Toast Banner */}
      {syncError && (
        <div className="bg-red-600 text-white px-4 py-2 text-xs font-medium flex items-center justify-center gap-2 animate-in fade-in duration-200">
          <AlertCircle className="w-4 h-4 shrink-0" />
          <span>{t.offline.syncError}</span>
        </div>
      )}
    </div>
  );
};
