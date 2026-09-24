import React, { useState, useEffect } from 'react';
import { OnionBatch, HeapAnalysisResult } from '../types';
import { heapAnalysisService } from '../services/heapAnalysisService';
import { AiSettings } from '../services/appState';
import {
  Camera,
  Upload,
  UserCheck,
  FileText,
  Weight,
  Sparkles,
  Layers,
  ArrowRight,
  AlertCircle,
} from 'lucide-react';
import { useLanguage } from '../i18n/LanguageContext';
import { offlineSyncService } from '../services/offlineSyncService';

interface InspectionScreenProps {
  batches: OnionBatch[];
  preselectedBatch?: OnionBatch | null;
  aiSettings: AiSettings;
  currentInspector?: { name: string; id: string };
  onAnalysisComplete: (
    batch: OnionBatch,
    result: HeapAnalysisResult,
    imageSrc: string | null,
    meta: {
      inspectorName: string;
      inspectorId: string;
      sampleWeightKg: number;
      notes: string;
    }
  ) => void;
}

export const InspectionScreen: React.FC<InspectionScreenProps> = ({
  batches,
  preselectedBatch,
  aiSettings,
  currentInspector,
  onAnalysisComplete,
}) => {
  const { t } = useLanguage();

  const PRESET_HEAPS = [
    {
      id: 0,
      name: 'Lasalgaon Nashik Red Heap',
      desc: `${t.grades.gradeA} (Expected)`,
      accent: '#7C2D12',
    },
    {
      id: 1,
      name: 'Mixed Mandi Garva Heap',
      desc: `${t.grades.gradeB} (Expected)`,
      accent: '#9A3412',
    },
    {
      id: 2,
      name: 'Sprout & Rot Challenged Heap',
      desc: `${t.grades.reject} (Expected)`,
      accent: '#581C87',
    },
  ];

  const [selectedBatchId, setSelectedBatchId] = useState<string>(
    preselectedBatch?.id || (batches[0] ? batches[0].id : '')
  );

  useEffect(() => {
    if (preselectedBatch) {
      setSelectedBatchId(preselectedBatch.id);
    } else if (!selectedBatchId && batches.length > 0) {
      setSelectedBatchId(batches[0].id);
    }
  }, [preselectedBatch, batches]);

  const [inspectorName, setInspectorName] = useState(currentInspector?.name || 'Dr. V. K. Deshmukh');
  const [inspectorId, setInspectorId] = useState(currentInspector?.id || 'INS-MH-704');

  useEffect(() => {
    if (currentInspector) {
      setInspectorName(currentInspector.name);
      setInspectorId(currentInspector.id);
    }
  }, [currentInspector]);
  const [sampleWeight, setSampleWeight] = useState('15.0');
  const [notes, setNotes] = useState('Heap surface clear, dry curing verified.');

  const [sourceMode, setSourceMode] = useState<'preset' | 'upload'>('preset');
  const [presetIndex, setPresetIndex] = useState(0);
  const [uploadedImageSrc, setUploadedImageSrc] = useState<string | null>(null);
  const [uploadedFileName, setUploadedFileName] = useState<string | null>(null);
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [analysisStep, setAnalysisStep] = useState(t.inspectionScreen.stepUploading);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const selectedBatch =
    batches.find((b) => b.id === selectedBatchId) || batches[0];

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    setErrorMessage(null);
    const file = e.target.files?.[0];
    if (!file) return;

    if (!file.type.startsWith('image/')) {
      setErrorMessage(t.inspectionScreen.errorInvalidImage);
      return;
    }

    const maxSizeBytes = 10 * 1024 * 1024;
    if (file.size > maxSizeBytes) {
      setErrorMessage(t.inspectionScreen.errorImageTooLarge);
      return;
    }

    setUploadedFileName(file.name);
    const reader = new FileReader();
    reader.onload = (event) => {
      setUploadedImageSrc(event.target?.result as string);
    };
    reader.onerror = () => {
      setErrorMessage(t.inspectionScreen.errorReadFailed);
    };
    reader.readAsDataURL(file);
  };

  const handleRunAnalysis = async () => {
    setErrorMessage(null);

    if (!selectedBatch) {
      setErrorMessage(t.inspectionScreen.errorNoBatch);
      return;
    }

    const weightNum = parseFloat(sampleWeight);
    if (isNaN(weightNum) || weightNum <= 0) {
      setErrorMessage(t.inspectionScreen.errorInvalidWeight);
      return;
    }

    setIsAnalyzing(true);
    setAnalysisStep(t.inspectionScreen.stepUploading);

    try {
      await new Promise((r) => setTimeout(r, 250));
      setAnalysisStep(t.inspectionScreen.stepContours);

      await new Promise((r) => setTimeout(r, 300));
      setAnalysisStep(t.inspectionScreen.stepClassifying);

      const imagePayload =
        sourceMode === 'upload' && uploadedImageSrc
          ? uploadedImageSrc
          : `preset-heap-${presetIndex}-${PRESET_HEAPS[presetIndex].name}`;

      const isOffline = typeof navigator !== 'undefined' && !navigator.onLine;

      // If offline in Mandi yard, queue for background sync and use local model
      if (isOffline) {
        offlineSyncService.queueAiAnalysis({
          id: `PENDING-AI-${Date.now()}`,
          batchId: selectedBatch.id,
          batchNumber: selectedBatch.batchNumber,
          imagePayload,
          fileName: uploadedFileName || (uploadedImageSrc ? 'uploaded_heap.jpg' : `preset_${presetIndex}.jpg`),
          timestamp: new Date().toISOString(),
          meta: {
            inspectorName: inspectorName.trim() || 'Certified Grader',
            inspectorId: inspectorId.trim() || 'INS-MH-001',
            sampleWeightKg: weightNum,
            notes: notes.trim(),
          },
        });
      }

      const result = await heapAnalysisService.analyzeHeap(
        imagePayload,
        uploadedFileName || (uploadedImageSrc ? 'uploaded_heap.jpg' : `preset_${presetIndex}.jpg`),
        isOffline ? true : aiSettings.useMockAi,
        aiSettings.aiApiUrl,
        Boolean(aiSettings.enableDiagnostics)
      );

      if (isOffline) {
        result.warnings = [
          ...(result.warnings || []),
          'Offline Mode: Performed locally in Mandi yard. Raw heap image queued for backend sync.',
        ];
      }

      setAnalysisStep(t.inspectionScreen.stepFinalizing);
      await new Promise((r) => setTimeout(r, 200));

      onAnalysisComplete(selectedBatch, result, uploadedImageSrc, {
        inspectorName: inspectorName.trim() || 'Certified Grader',
        inspectorId: inspectorId.trim() || 'INS-MH-001',
        sampleWeightKg: weightNum,
        notes: notes.trim(),
      });
    } catch (err: any) {
      setErrorMessage(err.message || 'Analysis pipeline encountered an error. Please retry.');
    } finally {
      setIsAnalyzing(false);
    }
  };

  return (
    <div className="max-w-3xl mx-auto space-y-4 sm:space-y-5">
      {/* Title Card */}
      <div className="bg-white rounded-xl border border-slate-200 p-4 sm:p-5 shadow-xs">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-sky-100 text-sky-700 flex items-center justify-center shrink-0">
            <Camera className="w-5 h-5" />
          </div>
          <div>
            <h2 className="text-base font-bold text-slate-900">
              {t.inspectionScreen.title}
            </h2>
            <p className="text-xs text-slate-500">
              {t.nav.heapInspectionSubtitle}
            </p>
          </div>
        </div>
      </div>

      {errorMessage && (
        <div className="p-3.5 text-xs text-red-800 bg-red-50 border border-red-200 rounded-xl flex items-center gap-2">
          <AlertCircle className="w-4 h-4 shrink-0 text-red-600" />
          <span>{errorMessage}</span>
        </div>
      )}

      {/* Target Lot Selector */}
      <div className="bg-white rounded-xl border border-slate-200 p-4 sm:p-5 shadow-xs space-y-3">
        <label className="block text-xs font-bold text-slate-800 flex items-center gap-1.5">
          <Layers className="w-4 h-4 text-[#7C2D12]" />
          <span>{t.inspectionScreen.lotSelection}</span>
        </label>

        {batches.length === 0 ? (
          <p className="text-xs text-amber-700 bg-amber-50 p-2.5 rounded-lg border border-amber-200">
            {t.inspectionScreen.errorNoBatch}
          </p>
        ) : (
          <select
            value={selectedBatchId}
            onChange={(e) => setSelectedBatchId(e.target.value)}
            className="w-full text-xs px-3 py-2.5 border border-slate-300 rounded-lg bg-white focus:ring-2 focus:ring-[#7C2D12] focus:outline-none"
          >
            {batches.map((b) => (
              <option key={b.id} value={b.id}>
                {b.batchNumber} — {b.farmerName} ({b.mandiLocation}, {b.weightQuintals} {t.common.qtl})
              </option>
            ))}
          </select>
        )}
      </div>

      {/* Image Source Selection Mode */}
      <div className="bg-white rounded-xl border border-slate-200 p-4 sm:p-5 shadow-xs space-y-4">
        <div className="flex items-center justify-between">
          <span className="text-xs font-bold text-slate-800 flex items-center gap-1.5">
            <Camera className="w-4 h-4 text-[#7C2D12]" />
            <span>{t.inspectionScreen.sourceMode}</span>
          </span>

          <div className="flex items-center gap-1 bg-slate-100 p-1 rounded-lg">
            <button
              type="button"
              onClick={() => setSourceMode('preset')}
              className={`px-3 py-1 rounded-md text-xs font-semibold transition-colors cursor-pointer ${
                sourceMode === 'preset'
                  ? 'bg-white text-slate-900 shadow-2xs'
                  : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              {t.inspectionScreen.modePreset}
            </button>
            <button
              type="button"
              onClick={() => setSourceMode('upload')}
              className={`px-3 py-1 rounded-md text-xs font-semibold transition-colors cursor-pointer ${
                sourceMode === 'upload'
                  ? 'bg-white text-slate-900 shadow-2xs'
                  : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              {t.inspectionScreen.modeUpload}
            </button>
          </div>
        </div>

        {sourceMode === 'preset' ? (
          <div className="space-y-2">
            <span className="text-[11px] font-semibold text-slate-500 block">
              {t.inspectionScreen.presetSampleLabel}
            </span>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-2.5">
              {PRESET_HEAPS.map((heap, idx) => (
                <button
                  key={heap.id}
                  type="button"
                  onClick={() => setPresetIndex(idx)}
                  className={`p-3 rounded-xl border text-left transition-all cursor-pointer ${
                    presetIndex === idx
                      ? 'border-[#7C2D12] bg-[#7C2D12]/5 ring-2 ring-[#7C2D12]/20'
                      : 'border-slate-200 hover:border-slate-300 bg-white'
                  }`}
                >
                  <div className="text-xs font-bold text-slate-900 mb-1">
                    {heap.name}
                  </div>
                  <div className="text-[11px] text-slate-500 leading-tight">
                    {heap.desc}
                  </div>
                </button>
              ))}
            </div>
          </div>
        ) : (
          <div className="space-y-3">
            <div className="border-2 border-dashed border-slate-300 rounded-xl p-6 text-center hover:border-[#7C2D12] transition-colors relative cursor-pointer bg-slate-50/50">
              <input
                type="file"
                accept="image/*"
                onChange={handleFileUpload}
                className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
              />
              <Upload className="w-8 h-8 text-slate-400 mx-auto mb-2" />
              <div className="text-xs font-bold text-slate-800">
                {t.inspectionScreen.uploadHeapPhoto}
              </div>
              <p className="text-[11px] text-slate-500 mt-0.5">
                {t.inspectionScreen.uploadHeapPrompt}
              </p>
              <p className="text-[10px] text-slate-400 mt-1">
                {t.inspectionScreen.uploadHeapConstraints}
              </p>
            </div>

            {uploadedFileName && (
              <div className="text-xs text-slate-700 bg-slate-100 p-2.5 rounded-lg flex items-center justify-between">
                <span className="truncate">
                  {t.inspectionScreen.fileSelected} <strong>{uploadedFileName}</strong>
                </span>
                <span className="text-[10px] text-emerald-700 font-bold px-2 py-0.5 rounded bg-emerald-100">
                  {t.common.verified}
                </span>
              </div>
            )}
          </div>
        )}
      </div>

      {/* Inspector & Sampling Metadata */}
      <div className="bg-white rounded-xl border border-slate-200 p-4 sm:p-5 shadow-xs space-y-4">
        <h3 className="text-xs font-bold text-slate-800 flex items-center gap-1.5 border-b border-slate-100 pb-2">
          <UserCheck className="w-4 h-4 text-[#7C2D12]" />
          <span>{t.inspectionScreen.inspectorMetaTitle}</span>
        </h3>

        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
          <div className="space-y-1">
            <label className="block text-[11px] font-semibold text-slate-600">
              {t.inspectionScreen.inspectorNameLabel}
            </label>
            <input
              type="text"
              value={inspectorName}
              onChange={(e) => setInspectorName(e.target.value)}
              className="w-full text-xs px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#7C2D12]"
            />
          </div>

          <div className="space-y-1">
            <label className="block text-[11px] font-semibold text-slate-600">
              {t.inspectionScreen.inspectorIdLabel}
            </label>
            <input
              type="text"
              value={inspectorId}
              onChange={(e) => setInspectorId(e.target.value)}
              className="w-full text-xs px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#7C2D12]"
            />
          </div>

          <div className="space-y-1">
            <label className="block text-[11px] font-semibold text-slate-600 flex items-center gap-1">
              <Weight className="w-3 h-3 text-slate-400" />
              <span>{t.inspectionScreen.sampleWeightLabel}</span>
            </label>
            <input
              type="number"
              step="0.5"
              value={sampleWeight}
              onChange={(e) => setSampleWeight(e.target.value)}
              className="w-full text-xs px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#7C2D12]"
            />
          </div>
        </div>

        <div className="space-y-1">
          <label className="block text-[11px] font-semibold text-slate-600 flex items-center gap-1">
            <FileText className="w-3 h-3 text-slate-400" />
            <span>{t.inspectionScreen.observationNotesLabel}</span>
          </label>
          <input
            type="text"
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            placeholder={t.inspectionScreen.observationNotesPlaceholder}
            className="w-full text-xs px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#7C2D12]"
          />
        </div>
      </div>

      {/* Execution Call to Action */}
      <div className="pt-2">
        {isAnalyzing ? (
          <div className="bg-white border border-slate-200 rounded-xl p-5 shadow-xs text-center space-y-3">
            <div className="inline-block animate-spin text-[#7C2D12]">
              <Sparkles className="w-6 h-6" />
            </div>
            <div className="text-xs font-bold text-slate-900">
              {t.inspectionScreen.analyzingTitle}
            </div>
            <p className="text-[11px] text-slate-500 font-medium">
              {analysisStep}
            </p>
            <div className="w-48 mx-auto h-1.5 bg-slate-100 rounded-full overflow-hidden">
              <div className="w-full h-full bg-[#7C2D12] animate-pulse" />
            </div>
          </div>
        ) : (
          <button
            type="button"
            onClick={handleRunAnalysis}
            className="w-full py-3 px-4 rounded-xl bg-[#7C2D12] text-white font-bold text-xs sm:text-sm shadow-md hover:bg-[#68250e] flex items-center justify-center gap-2 transition-colors cursor-pointer"
          >
            <Camera className="w-4 h-4" />
            <span>{t.inspectionScreen.runAnalysisBtn}</span>
            <ArrowRight className="w-4 h-4" />
          </button>
        )}
      </div>
    </div>
  );
};
