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

interface InspectionScreenProps {
  batches: OnionBatch[];
  preselectedBatch?: OnionBatch | null;
  aiSettings: AiSettings;
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

const PRESET_HEAPS = [
  {
    id: 0,
    name: 'Lasalgaon Nashik Red Heap',
    desc: 'Uniform, well-cured premium sample (Expected Grade A)',
    accent: '#7C2D12',
  },
  {
    id: 1,
    name: 'Mixed Mandi Garva Heap',
    desc: 'Variable sizes with minor mechanical cuts (Expected Grade B)',
    accent: '#9A3412',
  },
  {
    id: 2,
    name: 'Sprout & Rot Challenged Heap',
    desc: 'High humidity storage with visible sprouted & decaying bulbs',
    accent: '#581C87',
  },
];

export const InspectionScreen: React.FC<InspectionScreenProps> = ({
  batches,
  preselectedBatch,
  aiSettings,
  onAnalysisComplete,
}) => {
  const [selectedBatchId, setSelectedBatchId] = useState<string>(
    preselectedBatch?.id || (batches[0] ? batches[0].id : '')
  );

  // Synchronize when preselectedBatch changes
  useEffect(() => {
    if (preselectedBatch) {
      setSelectedBatchId(preselectedBatch.id);
    } else if (!selectedBatchId && batches.length > 0) {
      setSelectedBatchId(batches[0].id);
    }
  }, [preselectedBatch, batches]);

  const [inspectorName, setInspectorName] = useState('Dr. V. K. Deshmukh');
  const [inspectorId, setInspectorId] = useState('INS-MH-704');
  const [sampleWeight, setSampleWeight] = useState('15.0');
  const [notes, setNotes] = useState('Heap surface clear, dry curing verified.');

  const [presetIndex, setPresetIndex] = useState(0);
  const [uploadedImageSrc, setUploadedImageSrc] = useState<string | null>(null);
  const [uploadedFileName, setUploadedFileName] = useState<string | null>(null);
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [analysisStep, setAnalysisStep] = useState('Ready');
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const selectedBatch =
    batches.find((b) => b.id === selectedBatchId) || batches[0];

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    setErrorMessage(null);
    const file = e.target.files?.[0];
    if (!file) return;

    // Validate file type
    if (!file.type.startsWith('image/')) {
      setErrorMessage('Please select a valid image file (JPEG, PNG, WebP).');
      return;
    }

    // Validate file size (max 10MB)
    const maxSizeBytes = 10 * 1024 * 1024;
    if (file.size > maxSizeBytes) {
      setErrorMessage('Image size exceeds 10MB. Please choose a smaller photo or compress it.');
      return;
    }

    setUploadedFileName(file.name);
    const reader = new FileReader();
    reader.onload = (event) => {
      setUploadedImageSrc(event.target?.result as string);
    };
    reader.onerror = () => {
      setErrorMessage('Failed to read image file. Please retry.');
    };
    reader.readAsDataURL(file);
  };

  const handleRunAnalysis = async () => {
    setErrorMessage(null);

    if (!selectedBatch) {
      setErrorMessage('No mandi batch available. Please register a batch first.');
      return;
    }

    const weightNum = parseFloat(sampleWeight);
    if (isNaN(weightNum) || weightNum <= 0) {
      setErrorMessage('Please enter a valid positive sample weight in kilograms.');
      return;
    }

    setIsAnalyzing(true);
    setAnalysisStep('Uploading heap image to inference pipeline...');

    try {
      await new Promise((r) => setTimeout(r, 250));
      setAnalysisStep('Extracting visible onion instance boundaries with contour segmentation...');

      await new Promise((r) => setTimeout(r, 300));
      setAnalysisStep('Classifying defects: healthy, fungal rot, premature sprout, skin damage...');

      const imagePayload =
        uploadedImageSrc ||
        `preset-heap-${presetIndex}-${PRESET_HEAPS[presetIndex].name}`;

      const result = await heapAnalysisService.analyzeHeap(
        imagePayload,
        uploadedFileName || (uploadedImageSrc ? 'uploaded_heap.jpg' : `preset_${presetIndex}.jpg`),
        aiSettings.useMockAi,
        aiSettings.aiApiUrl
      );

      setAnalysisStep('Finalizing AGMARK Grade A/B/Reject distribution...');
      await new Promise((r) => setTimeout(r, 200));

      onAnalysisComplete(selectedBatch, result, uploadedImageSrc, {
        inspectorName: inspectorName.trim() || 'Certified Grader',
        inspectorId: inspectorId.trim() || 'INS-MH-001',
        sampleWeightKg: weightNum,
        notes: notes.trim(),
      });
    } catch (err) {
      console.error('Heap analysis failed:', err);
      setIsAnalyzing(false);
      setErrorMessage('Computer vision analysis failed or backend was unreachable. Please verify API settings or try again.');
    }
  };

  return (
    <div className="max-w-2xl mx-auto space-y-4 sm:space-y-5">
      {/* Title & Batch selector */}
      <div className="bg-white rounded-xl border border-slate-200 p-4 sm:p-5 shadow-xs space-y-4">
        <div>
          <h2 className="text-base font-bold text-slate-900">
            Onion Heap Quality & Digital Grading
          </h2>
          <p className="text-xs text-slate-500">
            Capture or select an onion heap lot image for automated computer vision defect estimation
          </p>
        </div>

        {/* Error Notification */}
        {errorMessage && (
          <div className="p-3 bg-red-50 border border-red-200 rounded-lg flex items-center gap-2 text-xs text-red-800">
            <AlertCircle className="w-4 h-4 text-red-600 shrink-0" />
            <span>{errorMessage}</span>
          </div>
        )}

        {/* Batch Picker */}
        <div className="space-y-1">
          <label className="block text-xs font-semibold text-slate-700 flex items-center gap-1.5">
            <Layers className="w-3.5 h-3.5 text-[#7C2D12]" />
            <span>Select Target Arrival Batch</span>
          </label>
          {batches.length === 0 ? (
            <div className="p-3 bg-amber-50 border border-amber-200 rounded-lg text-xs text-amber-800">
              No registered batches found. Please register an onion batch first.
            </div>
          ) : (
            <select
              value={selectedBatchId}
              onChange={(e) => setSelectedBatchId(e.target.value)}
              className="w-full text-xs px-3 py-2.5 border border-slate-300 rounded-lg bg-white focus:ring-2 focus:ring-[#7C2D12] focus:outline-none font-medium"
            >
              {batches.map((b) => (
                <option key={b.id} value={b.id}>
                  {b.batchNumber} — {b.farmerName} ({b.mandiLocation}, {b.onionVariety})
                </option>
              ))}
            </select>
          )}
        </div>

        {/* Inspector Details */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 pt-2 border-t border-slate-100">
          <div className="space-y-1">
            <label className="block text-xs font-semibold text-slate-700 flex items-center gap-1">
              <UserCheck className="w-3.5 h-3.5 text-slate-400" />
              <span>Inspector Name</span>
            </label>
            <input
              type="text"
              value={inspectorName}
              onChange={(e) => setInspectorName(e.target.value)}
              className="w-full text-xs px-2.5 py-2 border border-slate-300 rounded-lg focus:ring-1 focus:ring-[#7C2D12]"
            />
          </div>

          <div className="space-y-1">
            <label className="block text-xs font-semibold text-slate-700">
              Inspector ID
            </label>
            <input
              type="text"
              value={inspectorId}
              onChange={(e) => setInspectorId(e.target.value)}
              className="w-full text-xs px-2.5 py-2 border border-slate-300 rounded-lg focus:ring-1 focus:ring-[#7C2D12]"
            />
          </div>

          <div className="space-y-1">
            <label className="block text-xs font-semibold text-slate-700 flex items-center gap-1">
              <Weight className="w-3.5 h-3.5 text-slate-400" />
              <span>Sample Weight (kg)</span>
            </label>
            <input
              type="number"
              step="0.5"
              min="0.1"
              value={sampleWeight}
              onChange={(e) => setSampleWeight(e.target.value)}
              className="w-full text-xs px-2.5 py-2 border border-slate-300 rounded-lg focus:ring-1 focus:ring-[#7C2D12]"
            />
          </div>
        </div>

        <div className="space-y-1">
          <label className="block text-xs font-semibold text-slate-700 flex items-center gap-1">
            <FileText className="w-3.5 h-3.5 text-slate-400" />
            <span>Inspection Notes</span>
          </label>
          <input
            type="text"
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            placeholder="e.g. Curing condition, ambient humidity, lot notes"
            className="w-full text-xs px-2.5 py-2 border border-slate-300 rounded-lg focus:ring-1 focus:ring-[#7C2D12]"
          />
        </div>
      </div>

      {/* Heap Image Selection */}
      <div className="bg-white rounded-xl border border-slate-200 p-4 sm:p-5 shadow-xs space-y-4">
        <h3 className="text-sm font-bold text-slate-800 flex items-center gap-2">
          <Camera className="w-4 h-4 text-[#7C2D12]" />
          <span>Onion Heap Image Source</span>
        </h3>

        {/* Presets vs Upload Tabs */}
        <div>
          <span className="text-xs font-semibold text-slate-700 block mb-2">
            Choose Standard Benchmark Heap Preset:
          </span>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-2">
            {PRESET_HEAPS.map((preset) => {
              const isSelected = uploadedImageSrc === null && presetIndex === preset.id;
              return (
                <button
                  key={preset.id}
                  type="button"
                  onClick={() => {
                    setPresetIndex(preset.id);
                    setUploadedImageSrc(null);
                    setUploadedFileName(null);
                    setErrorMessage(null);
                  }}
                  className={`p-3 rounded-xl border text-left transition-all ${
                    isSelected
                      ? 'border-[#7C2D12] bg-[#7C2D12]/5 ring-1 ring-[#7C2D12]'
                      : 'border-slate-200 hover:border-slate-300 bg-white'
                  }`}
                >
                  <div className="text-xs font-bold text-slate-900 truncate">
                    {preset.name}
                  </div>
                  <div className="text-[10px] text-slate-500 mt-1 line-clamp-2">
                    {preset.desc}
                  </div>
                </button>
              );
            })}
          </div>
        </div>

        {/* Or Upload Custom Image */}
        <div className="pt-2">
          <div className="flex items-center justify-between mb-1.5">
            <span className="text-xs font-semibold text-slate-700">
              Or Upload/Capture Real Heap Photo:
            </span>
            {uploadedImageSrc && (
              <button
                type="button"
                onClick={() => {
                  setUploadedImageSrc(null);
                  setUploadedFileName(null);
                }}
                className="text-[11px] text-red-600 hover:underline font-semibold"
              >
                Clear uploaded image
              </button>
            )}
          </div>

          <label className="border-2 border-dashed border-slate-300 hover:border-[#7C2D12] rounded-xl p-4 flex flex-col items-center justify-center cursor-pointer transition-colors bg-slate-50/50">
            <input
              type="file"
              accept="image/jpeg,image/png,image/webp"
              capture="environment"
              onChange={handleFileUpload}
              className="hidden"
            />
            {uploadedImageSrc ? (
              <div className="relative w-full aspect-video max-h-48 rounded-lg overflow-hidden">
                <img
                  src={uploadedImageSrc}
                  alt="Custom Heap Preview"
                  className="w-full h-full object-cover"
                />
                <div className="absolute inset-0 bg-black/20 flex items-center justify-center text-white text-xs font-bold">
                  Click to change photo ({uploadedFileName || 'Custom'})
                </div>
              </div>
            ) : (
              <div className="text-center py-2">
                <Upload className="w-6 h-6 text-slate-400 mx-auto mb-1" />
                <span className="text-xs font-bold text-slate-700 block">
                  Click to browse or take heap photo
                </span>
                <span className="text-[11px] text-slate-400">
                  Supports JPEG, PNG, WebP (Max 10MB)
                </span>
              </div>
            )}
          </label>
        </div>
      </div>

      {/* Execute Analysis CTA */}
      <div className="pt-2">
        <button
          type="button"
          disabled={isAnalyzing || batches.length === 0}
          onClick={handleRunAnalysis}
          className={`w-full py-3.5 px-4 rounded-xl font-bold text-sm shadow-md flex items-center justify-center gap-2 transition-all ${
            isAnalyzing || batches.length === 0
              ? 'bg-slate-400 text-white cursor-not-allowed'
              : 'bg-[#7C2D12] text-white hover:bg-[#68250e] cursor-pointer'
          }`}
        >
          {isAnalyzing ? (
            <>
              <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
              <span>{analysisStep}</span>
            </>
          ) : (
            <>
              <Sparkles className="w-4 h-4" />
              <span>Analyze Onion Heap Now</span>
              <ArrowRight className="w-4 h-4" />
            </>
          )}
        </button>

        {isAnalyzing && (
          <p className="text-center text-xs text-slate-500 mt-2 animate-pulse">
            Processing instance contours and AGMARK defect classifications...
          </p>
        )}
      </div>
    </div>
  );
};
