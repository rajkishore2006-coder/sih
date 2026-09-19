import { useState, useEffect } from 'react';
import {
  OnionBatch,
  OnionInspection,
  HeapAnalysisResult,
} from './types';
import {
  loadSavedBatches,
  saveBatches,
  loadSavedInspections,
  saveInspections,
  loadAiSettings,
  saveAiSettings,
  AiSettings,
} from './services/appState';
import { Header } from './components/Header';
import { HomeScreen } from './screens/HomeScreen';
import { CreateBatchScreen } from './screens/CreateBatchScreen';
import { BatchDetailScreen } from './screens/BatchDetailScreen';
import { InspectionScreen } from './screens/InspectionScreen';
import { HeapAnalysisScreen } from './screens/HeapAnalysisScreen';
import { ReportScreen } from './screens/ReportScreen';
import { VerifyScreen } from './screens/VerifyScreen';
import { InspectionHistoryScreen } from './screens/InspectionHistoryScreen';
import { AiSettingsModal } from './components/AiSettingsModal';
import { ScanBatchModal } from './components/ScanBatchModal';

type AppScreen =
  | 'home'
  | 'create_batch'
  | 'batch_detail'
  | 'inspection'
  | 'heap_analysis'
  | 'report'
  | 'verify'
  | 'history';

export function App() {
  const [batches, setBatches] = useState<OnionBatch[]>(() => loadSavedBatches());
  const [inspections, setInspections] = useState<OnionInspection[]>(() =>
    loadSavedInspections()
  );
  const [aiSettings, setAiSettings] = useState<AiSettings>(() => loadAiSettings());

  const [currentScreen, setCurrentScreen] = useState<AppScreen>('home');
  const [selectedBatchId, setSelectedBatchId] = useState<string | null>(null);
  const [selectedInspectionId, setSelectedInspectionId] = useState<string | null>(null);

  // Temporary state for active heap analysis in progress
  const [pendingAnalysisData, setPendingAnalysisData] = useState<{
    batch: OnionBatch;
    result: HeapAnalysisResult;
    imageSrc: string | null;
    meta: {
      inspectorName: string;
      inspectorId: string;
      sampleWeightKg: number;
      notes: string;
    };
  } | null>(null);

  // Modals
  const [isAiSettingsOpen, setIsAiSettingsOpen] = useState(false);
  const [isScanModalOpen, setIsScanModalOpen] = useState(false);

  // Persist whenever batches or inspections change
  useEffect(() => {
    saveBatches(batches);
  }, [batches]);

  useEffect(() => {
    saveInspections(inspections);
  }, [inspections]);

  const handleUpdateAiSettings = (newSettings: AiSettings) => {
    setAiSettings(newSettings);
    saveAiSettings(newSettings);
  };

  const activeBatch = batches.find((b) => b.id === selectedBatchId) || null;
  const activeInspection =
    inspections.find((i) => i.id === selectedInspectionId) || null;

  // Handlers
  const handleOpenBatchDetail = (batchId: string) => {
    setSelectedBatchId(batchId);
    setCurrentScreen('batch_detail');
  };

  const handleCreateBatch = (newBatch: OnionBatch) => {
    setBatches((prev) => [newBatch, ...prev]);
    setSelectedBatchId(newBatch.id);
    setCurrentScreen('batch_detail');
  };

  const handleStartInspection = (batch?: OnionBatch) => {
    if (batch) {
      setSelectedBatchId(batch.id);
    }
    setCurrentScreen('inspection');
  };

  const handleAnalysisComplete = (
    batch: OnionBatch,
    result: HeapAnalysisResult,
    imageSrc: string | null,
    meta: {
      inspectorName: string;
      inspectorId: string;
      sampleWeightKg: number;
      notes: string;
    }
  ) => {
    setPendingAnalysisData({ batch, result, imageSrc, meta });
    setCurrentScreen('heap_analysis');
  };

  const handleCertifyInspection = (inspection: OnionInspection) => {
    setInspections((prev) => [inspection, ...prev]);

    // Update batch status and latest grade
    setBatches((prev) =>
      prev.map((b) => {
        if (b.id === inspection.batchId) {
          const newStatus =
            inspection.assignedGrade === 'Reject' ? 'rejected' : 'certified';
          return {
            ...b,
            status: newStatus,
            latestGrade: inspection.assignedGrade,
          };
        }
        return b;
      })
    );

    setSelectedInspectionId(inspection.id);
    setSelectedBatchId(inspection.batchId);
    setCurrentScreen('report');
  };

  const handleViewReport = (batch: OnionBatch, inspection: OnionInspection) => {
    setSelectedBatchId(batch.id);
    setSelectedInspectionId(inspection.id);
    setCurrentScreen('report');
  };

  const handleDeleteInspection = (inspectionId: string) => {
    setInspections((prev) => prev.filter((i) => i.id !== inspectionId));
  };

  const getHeaderMeta = () => {
    switch (currentScreen) {
      case 'create_batch':
        return {
          title: 'Register Mandi Batch',
          subtitle: 'Lot Identification & QR Generation',
          canGoBack: true,
          onBack: () => setCurrentScreen('home'),
        };
      case 'batch_detail':
        return {
          title: activeBatch?.batchNumber || 'Batch Details',
          subtitle: 'Lot Traceability & Inspection Records',
          canGoBack: true,
          onBack: () => setCurrentScreen('home'),
        };
      case 'inspection':
        return {
          title: 'Heap Analysis & Grading',
          subtitle: 'Computer Vision Defect Estimation',
          canGoBack: true,
          onBack: () =>
            selectedBatchId ? setCurrentScreen('batch_detail') : setCurrentScreen('home'),
        };
      case 'heap_analysis':
        return {
          title: 'Analysis & Instance Segmentation',
          subtitle: 'Surface Contour & AGMARK Estimation',
          canGoBack: true,
          onBack: () => setCurrentScreen('inspection'),
        };
      case 'report':
        return {
          title: 'Quality Certificate',
          subtitle: 'Digital AGMARK & e-NAM Verified',
          canGoBack: true,
          onBack: () =>
            selectedBatchId ? setCurrentScreen('batch_detail') : setCurrentScreen('home'),
        };
      case 'verify':
        return {
          title: 'Certificate Verification',
          subtitle: 'Public e-NAM APMC Lot Authentication',
          canGoBack: true,
          onBack: () => setCurrentScreen('home'),
        };
      case 'history':
        return {
          title: 'Inspection & Certificate Log',
          subtitle: 'Audited Mandi Quality Archive',
          canGoBack: true,
          onBack: () => setCurrentScreen('home'),
        };
      default:
        return {
          canGoBack: false,
        };
    }
  };

  const headerMeta = getHeaderMeta();

  return (
    <div className="min-h-screen bg-slate-50 flex flex-col selection:bg-[#7C2D12] selection:text-white">
      {/* Header */}
      <Header
        aiSettings={aiSettings}
        onOpenAiSettings={() => setIsAiSettingsOpen(true)}
        canGoBack={headerMeta.canGoBack}
        onBack={headerMeta.onBack}
        onGoHome={() => setCurrentScreen('home')}
        title={headerMeta.title}
        subtitle={headerMeta.subtitle}
      />

      {/* Main Content Area */}
      <main className="flex-1 max-w-6xl w-full mx-auto p-4 sm:p-6">
        {currentScreen === 'home' && (
          <HomeScreen
            batches={batches}
            inspections={inspections}
            onOpenCreateBatch={() => setCurrentScreen('create_batch')}
            onOpenInspection={handleStartInspection}
            onOpenBatchDetail={handleOpenBatchDetail}
            onOpenScanBatch={() => setIsScanModalOpen(true)}
            onOpenVerify={() => setCurrentScreen('verify')}
            onOpenHistory={() => setCurrentScreen('history')}
          />
        )}

        {currentScreen === 'create_batch' && (
          <CreateBatchScreen
            onSaveBatch={handleCreateBatch}
            onCancel={() => setCurrentScreen('home')}
          />
        )}

        {currentScreen === 'batch_detail' && activeBatch && (
          <BatchDetailScreen
            batch={activeBatch}
            inspections={inspections.filter((i) => i.batchId === activeBatch.id)}
            onStartInspection={(b) => handleStartInspection(b)}
            onViewReport={handleViewReport}
            onDeleteInspection={handleDeleteInspection}
          />
        )}

        {currentScreen === 'inspection' && (
          <InspectionScreen
            batches={batches}
            preselectedBatch={activeBatch}
            aiSettings={aiSettings}
            onAnalysisComplete={handleAnalysisComplete}
          />
        )}

        {currentScreen === 'heap_analysis' && pendingAnalysisData && (
          <HeapAnalysisScreen
            batch={pendingAnalysisData.batch}
            result={pendingAnalysisData.result}
            imageSrc={pendingAnalysisData.imageSrc}
            meta={pendingAnalysisData.meta}
            onCertify={handleCertifyInspection}
            onBack={() => setCurrentScreen('inspection')}
          />
        )}

        {currentScreen === 'report' && activeBatch && activeInspection && (
          <ReportScreen
            batch={activeBatch}
            inspection={activeInspection}
            onBack={() => setCurrentScreen('batch_detail')}
            onGoHome={() => setCurrentScreen('home')}
          />
        )}

        {currentScreen === 'verify' && (
          <VerifyScreen
            batches={batches}
            inspections={inspections}
            onViewReport={handleViewReport}
            onBack={() => setCurrentScreen('home')}
          />
        )}

        {currentScreen === 'history' && (
          <InspectionHistoryScreen
            batches={batches}
            inspections={inspections}
            onViewReport={handleViewReport}
            onDeleteInspection={handleDeleteInspection}
            onStartNewInspection={() => handleStartInspection()}
            onBack={() => setCurrentScreen('home')}
          />
        )}
      </main>

      {/* Footer */}
      <footer className="no-print border-t border-slate-200 bg-white py-4 px-4 text-center text-xs text-slate-500">
        <div className="max-w-6xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-2">
          <div>
            <span className="font-bold text-slate-700">OnionSure</span> • Smart India Hackathon
            SIH26031
          </div>
          <div>
            AI-based smart onion batch quality estimation from heap images • APMC Mandi Ready
          </div>
        </div>
      </footer>

      {/* Modals */}
      <AiSettingsModal
        isOpen={isAiSettingsOpen}
        onClose={() => setIsAiSettingsOpen(false)}
        currentSettings={aiSettings}
        onSave={handleUpdateAiSettings}
      />

      <ScanBatchModal
        isOpen={isScanModalOpen}
        onClose={() => setIsScanModalOpen(false)}
        batches={batches}
        onSelectBatch={handleOpenBatchDetail}
      />
    </div>
  );
}
export default App;
