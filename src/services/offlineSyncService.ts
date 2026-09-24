import { OnionBatch, OnionInspection } from '../types';

const PENDING_BATCHES_KEY = 'onionsure_pending_batches_v1';
const PENDING_INSPECTIONS_KEY = 'onionsure_pending_inspections_v1';
const PENDING_AI_QUEUE_KEY = 'onionsure_pending_ai_queue_v1';

export interface PendingAiItem {
  id: string;
  batchId: string;
  batchNumber: string;
  imagePayload: string;
  fileName: string;
  timestamp: string;
  meta: {
    inspectorName: string;
    inspectorId: string;
    sampleWeightKg: number;
    notes: string;
  };
}

export interface OfflineSyncStatus {
  pendingBatchesCount: number;
  pendingInspectionsCount: number;
  pendingAiCount: number;
  totalPendingCount: number;
  isSyncing: boolean;
  lastSyncTime: string | null;
}

type SyncListener = (status: OfflineSyncStatus) => void;

class OfflineSyncService {
  private listeners: Set<SyncListener> = new Set();
  private isSyncing = false;
  private lastSyncTime: string | null = null;

  constructor() {
    // Listen for online events to auto-trigger synchronization
    if (typeof window !== 'undefined') {
      window.addEventListener('online', () => {
        if (this.getTotalPendingCount() > 0) {
          this.syncPendingData();
        }
      });
    }
  }

  // --- Read Queues ---

  public getPendingBatches(): OnionBatch[] {
    try {
      const raw = localStorage.getItem(PENDING_BATCHES_KEY);
      return raw ? JSON.parse(raw) : [];
    } catch {
      return [];
    }
  }

  public getPendingInspections(): OnionInspection[] {
    try {
      const raw = localStorage.getItem(PENDING_INSPECTIONS_KEY);
      return raw ? JSON.parse(raw) : [];
    } catch {
      return [];
    }
  }

  public getPendingAiItems(): PendingAiItem[] {
    try {
      const raw = localStorage.getItem(PENDING_AI_QUEUE_KEY);
      return raw ? JSON.parse(raw) : [];
    } catch {
      return [];
    }
  }

  public getTotalPendingCount(): number {
    return (
      this.getPendingBatches().length +
      this.getPendingInspections().length +
      this.getPendingAiItems().length
    );
  }

  public getStatus(): OfflineSyncStatus {
    const batches = this.getPendingBatches().length;
    const inspections = this.getPendingInspections().length;
    const aiItems = this.getPendingAiItems().length;
    return {
      pendingBatchesCount: batches,
      pendingInspectionsCount: inspections,
      pendingAiCount: aiItems,
      totalPendingCount: batches + inspections + aiItems,
      isSyncing: this.isSyncing,
      lastSyncTime: this.lastSyncTime,
    };
  }

  // --- Add to Queue (When offline or creating locally) ---

  public queueBatch(batch: OnionBatch): void {
    const list = this.getPendingBatches();
    if (!list.some((b) => b.id === batch.id)) {
      list.push(batch);
      localStorage.setItem(PENDING_BATCHES_KEY, JSON.stringify(list));
      this.notifyListeners();
    }
  }

  public queueInspection(inspection: OnionInspection): void {
    const list = this.getPendingInspections();
    if (!list.some((i) => i.id === inspection.id)) {
      list.push(inspection);
      localStorage.setItem(PENDING_INSPECTIONS_KEY, JSON.stringify(list));
      this.notifyListeners();
    }
  }

  public queueAiAnalysis(item: PendingAiItem): void {
    const list = this.getPendingAiItems();
    if (!list.some((i) => i.id === item.id)) {
      list.push(item);
      localStorage.setItem(PENDING_AI_QUEUE_KEY, JSON.stringify(list));
      this.notifyListeners();
    }
  }

  // --- Synchronization Process ---

  public async syncPendingData(): Promise<{ success: boolean; syncedCount: number }> {
    if (typeof navigator !== 'undefined' && !navigator.onLine) {
      return { success: false, syncedCount: 0 };
    }

    const totalBefore = this.getTotalPendingCount();
    if (totalBefore === 0) {
      return { success: true, syncedCount: 0 };
    }

    this.isSyncing = true;
    this.notifyListeners();

    try {
      // Simulate real APMC cloud / e-NAM gateway sync with 800ms pipeline
      await new Promise((r) => setTimeout(r, 800));

      // Successfully synchronized: clear the pending queues
      localStorage.removeItem(PENDING_BATCHES_KEY);
      localStorage.removeItem(PENDING_INSPECTIONS_KEY);
      localStorage.removeItem(PENDING_AI_QUEUE_KEY);

      this.lastSyncTime = new Date().toISOString();
      this.isSyncing = false;
      this.notifyListeners();

      return { success: true, syncedCount: totalBefore };
    } catch (err) {
      this.isSyncing = false;
      this.notifyListeners();
      return { success: false, syncedCount: 0 };
    }
  }

  // --- Subscriptions ---

  public subscribe(listener: SyncListener): () => void {
    this.listeners.add(listener);
    listener(this.getStatus());
    return () => this.listeners.delete(listener);
  }

  private notifyListeners(): void {
    const status = this.getStatus();
    this.listeners.forEach((fn) => fn(status));
  }
}

export const offlineSyncService = new OfflineSyncService();
