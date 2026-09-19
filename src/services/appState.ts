import { OnionBatch, OnionInspection, QualityGrade } from '../types';
import { AppConfig } from '../config/appConfig';

const BATCHES_STORAGE_KEY = 'onionsure_batches_v1';
const INSPECTIONS_STORAGE_KEY = 'onionsure_inspections_v1';
const AI_SETTINGS_STORAGE_KEY = 'onionsure_ai_settings_v1';

export interface AiSettings {
  useMockAi: boolean;
  aiApiUrl: string;
}

function getInitialBatches(): OnionBatch[] {
  const now = new Date();
  const subDays = (d: number) => new Date(now.getTime() - d * 86400000).toISOString();
  const subHours = (h: number) => new Date(now.getTime() - h * 3600000).toISOString();

  return [
    {
      id: 'batch-001',
      batchNumber: 'BATCH-2026-NSK-104',
      farmerName: 'Ramesh Patil',
      farmerPhone: '+91 98231 44521',
      mandiLocation: 'Lasalgaon APMC, Nashik',
      onionVariety: 'Nashik Red (Garva)',
      harvestDate: subDays(4),
      weightQuintals: 125.0,
      bagCount: 250,
      status: 'certified',
      createdAt: subDays(2),
      latestGrade: 'Grade A',
      qrCodeData: 'ONION-BATCH:BATCH-2026-NSK-104',
    },
    {
      id: 'batch-002',
      batchNumber: 'BATCH-2026-PMP-209',
      farmerName: 'Suresh Gaikwad',
      farmerPhone: '+91 94220 89112',
      mandiLocation: 'Pimpalgaon Baswant APMC',
      onionVariety: 'Rangda Medium',
      harvestDate: subDays(6),
      weightQuintals: 85.5,
      bagCount: 170,
      status: 'inspected',
      createdAt: subDays(1),
      latestGrade: 'Grade B',
      qrCodeData: 'ONION-BATCH:BATCH-2026-PMP-209',
    },
    {
      id: 'batch-003',
      batchNumber: 'BATCH-2026-YVL-043',
      farmerName: 'Kailash Shinde',
      farmerPhone: '+91 99750 31204',
      mandiLocation: 'Yeola Mandi Yard',
      onionVariety: 'White Onion (Kharif)',
      harvestDate: subDays(2),
      weightQuintals: 60.0,
      bagCount: 120,
      status: 'pending',
      createdAt: subHours(5),
      latestGrade: null,
      qrCodeData: 'ONION-BATCH:BATCH-2026-YVL-043',
    },
  ];
}

function getInitialInspections(): OnionInspection[] {
  const now = new Date();
  const subDays = (d: number) => new Date(now.getTime() - d * 86400000).toISOString();

  const detections = [];
  for (let i = 1; i <= 24; i++) {
    const r = Math.floor((i - 1) / 5);
    const c = (i - 1) % 5;
    const cx = 0.12 + c * 0.19;
    const cy = 0.14 + r * 0.21;
    const rx = 0.08;
    const ry = 0.09;

    const defect =
      i === 4
        ? 'Damaged'
        : i === 11
        ? 'Sprouted'
        : i === 18
        ? 'Rotten'
        : i === 22
        ? 'Undersized'
        : 'Healthy';

    const grade: QualityGrade =
      defect === 'Rotten' || defect === 'Sprouted'
        ? 'Reject'
        : defect === 'Damaged' || defect === 'Undersized'
        ? 'Grade B'
        : 'Grade A';

    detections.push({
      id: i,
      bbox: {
        ymin: cy - ry,
        xmin: cx - rx,
        ymax: cy + ry,
        xmax: cx + rx,
      },
      polygon: [
        { x: cx, y: cy - ry },
        { x: cx + rx, y: cy },
        { x: cx, y: cy + ry },
        { x: cx - rx, y: cy },
      ],
      confidence: 0.88 + ((i * 17) % 10) * 0.01,
      defectType: defect as any,
      grade,
      estimatedDiameterMm: 52.0 + ((i * 23) % 15),
      severityScore: defect === 'Healthy' ? 0.0 : 0.45,
    });
  }

  return [
    {
      id: 'INSP-2026-001',
      batchId: 'batch-001',
      batchNumber: 'BATCH-2026-NSK-104',
      inspectorName: 'Dr. V. K. Deshmukh',
      inspectorId: 'INS-MH-704',
      timestamp: subDays(1),
      analysis: {
        analysisId: 'HA-892144',
        timestamp: subDays(1),
        visibleOnionCount: 24,
        grades: {
          gradeAPercent: 75.0,
          gradeBPercent: 16.7,
          rejectPercent: 8.3,
        },
        defects: {
          healthy: 18,
          damaged: 3,
          rotten: 1,
          sprouted: 1,
          undersized: 1,
          unknown: 0,
          total: 24,
        },
        detections,
        overallConfidence: 0.93,
        processingTimeMs: 420,
        isPrototype: true,
        warnings: ['Heap overlap detected: Surface contour estimates only.'],
        disclaimer: AppConfig.estimationDisclaimer,
        annotatedImageBase64: null,
      },
      assignedGrade: 'Grade A',
      sampleWeightKg: 15.0,
      notes: 'Uniform shape, good curing, export grade batch verified.',
      verificationToken: 'VERIF-NSK-8921-A',
    },
  ];
}

export function loadSavedBatches(): OnionBatch[] {
  try {
    const raw = localStorage.getItem(BATCHES_STORAGE_KEY);
    if (raw) return JSON.parse(raw);
  } catch (e) {
    console.error('Failed to read batches from localStorage', e);
  }
  const init = getInitialBatches();
  saveBatches(init);
  return init;
}

export function saveBatches(batches: OnionBatch[]): void {
  try {
    localStorage.setItem(BATCHES_STORAGE_KEY, JSON.stringify(batches));
  } catch (e) {
    console.error('Failed to save batches to localStorage', e);
  }
}

export function loadSavedInspections(): OnionInspection[] {
  try {
    const raw = localStorage.getItem(INSPECTIONS_STORAGE_KEY);
    if (raw) return JSON.parse(raw);
  } catch (e) {
    console.error('Failed to read inspections from localStorage', e);
  }
  const init = getInitialInspections();
  saveInspections(init);
  return init;
}

/**
 * Sanitizes an inspection record before serializing to localStorage.
 * Drops huge Base64 heap image strings and truncates fine-grained
 * polygon point arrays so inspections stay under the 5MB browser quota.
 */
function sanitizeInspectionForStorage(insp: OnionInspection): OnionInspection {
  const sanitizedAnalysis = {
    ...insp.analysis,
    annotatedImageBase64: null, // Never persist massive multi-megabyte base64 strings in localStorage
    detections: insp.analysis.detections.map((d) => ({
      ...d,
      polygon: [], // Keep bbox, grade, confidence, diameter; drop verbose polygon arrays
    })),
  };

  return {
    ...insp,
    imageBase64: null, // Drop raw heap photo base64
    analysis: sanitizedAnalysis,
  };
}

export function saveInspections(inspections: OnionInspection[]): void {
  try {
    // Strip heavy base64 and dense polygons to keep storage lean (<15KB per inspection)
    const lean = inspections.map(sanitizeInspectionForStorage);
    localStorage.setItem(INSPECTIONS_STORAGE_KEY, JSON.stringify(lean));
  } catch (e) {
    console.warn('Quota warning while saving inspections. Applying aggressive compression...', e);
    try {
      // Fallback: Keep only recent 15 inspections and strip detections array completely
      const emergencyLean = inspections.slice(0, 15).map((insp) => ({
        ...sanitizeInspectionForStorage(insp),
        analysis: {
          ...insp.analysis,
          annotatedImageBase64: null,
          detections: [],
        },
      }));
      localStorage.setItem(INSPECTIONS_STORAGE_KEY, JSON.stringify(emergencyLean));
    } catch (criticalErr) {
      console.error('Critical localStorage quota exceeded for inspections:', criticalErr);
    }
  }
}

export function loadAiSettings(): AiSettings {
  try {
    const raw = localStorage.getItem(AI_SETTINGS_STORAGE_KEY);
    if (raw) return JSON.parse(raw);
  } catch (e) {
    console.error('Failed to read AI settings', e);
  }
  return {
    useMockAi: true,
    aiApiUrl: AppConfig.defaultAiApiUrl,
  };
}

export function saveAiSettings(settings: AiSettings): void {
  try {
    localStorage.setItem(AI_SETTINGS_STORAGE_KEY, JSON.stringify(settings));
  } catch (e) {
    console.error('Failed to save AI settings', e);
  }
}
