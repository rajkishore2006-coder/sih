import {
  HeapAnalysisResult,
  OnionDetectionItem,
  DefectType,
  QualityGrade,
  Point2D,
  DetectionBoundingBox,
  DeveloperDiagnostics,
} from '../types';
import { AppConfig } from '../config/appConfig';
import { AppAiModelConfig } from '../config/aiModelConfig';

// Deterministic PRNG
function createSeededRandom(seed: number) {
  let s = seed % 2147483647;
  if (s <= 0) s += 2147483646;
  return () => {
    s = (s * 16807) % 2147483647;
    return (s - 1) / 2147483646;
  };
}

export function computeBoxIou(b1: DetectionBoundingBox, b2: DetectionBoundingBox): number {
  const interXmin = Math.max(b1.xmin, b2.xmin);
  const interYmin = Math.max(b1.ymin, b2.ymin);
  const interXmax = Math.min(b1.xmax, b2.xmax);
  const interYmax = Math.min(b1.ymax, b2.ymax);

  if (interXmax <= interXmin || interYmax <= interYmin) {
    return 0.0;
  }

  const interArea = (interXmax - interXmin) * (interYmax - interYmin);
  const area1 = (b1.xmax - b1.xmin) * (b1.ymax - b1.ymin);
  const area2 = (b2.xmax - b2.xmin) * (b2.ymax - b2.ymin);
  const unionArea = area1 + area2 - interArea;

  return unionArea > 0 ? interArea / unionArea : 0;
}

export function applyNms(
  detections: OnionDetectionItem[],
  iouThreshold: number = 0.45
): { kept: OnionDetectionItem[]; suppressedCount: number } {
  if (detections.length === 0) return { kept: [], suppressedCount: 0 };

  const sorted = [...detections].sort((a, b) => b.confidence - a.confidence);
  const kept: OnionDetectionItem[] = [];
  let suppressedCount = 0;

  for (const candidate of sorted) {
    let shouldSuppress = false;
    for (const preserved of kept) {
      const iou = computeBoxIou(candidate.bbox, preserved.bbox);
      if (iou > iouThreshold) {
        shouldSuppress = true;
        break;
      }
    }

    if (!shouldSuppress) {
      kept.push(candidate);
    } else {
      suppressedCount++;
    }
  }

  // Re-index remaining kept detections
  const reindexed = kept.map((item, idx) => ({ ...item, id: idx + 1 }));
  return { kept: reindexed, suppressedCount };
}

export class OnionVisionPipeline {
  static runInference(
    imageRef: string,
    options: {
      enableDiagnostics?: boolean;
      scenarioHint?: 'auto' | 'single' | 'cluster_3' | 'tray_5' | 'multi_20' | 'dense_heap';
      filename?: string;
    } = {}
  ): HeapAnalysisResult {
    const t0 = performance.now();

    // Step 1: Preprocessing & Aspect Ratio Check
    const tPrepStart = performance.now();
    const length = imageRef ? imageRef.length : 1000;
    const seed = Math.abs(length * 37 + (imageRef ? imageRef.charCodeAt(10) || 42 : 12345));
    const rand = createSeededRandom(seed);

    // Mock image dimension parsing
    const rawW = 1920;
    const rawH = 1080;
    const scale = Math.min(640 / rawW, 640 / rawH);
    const scaledW = Math.round(rawW * scale);
    const scaledH = Math.round(rawH * scale);
    const tPrepEnd = performance.now();

    // Step 2: Determine Scenario & Run Detection
    const tInferStart = performance.now();
    let scenario = options.scenarioHint || 'auto';
    if (scenario === 'auto') {
      if (length < 25000) scenario = 'single';
      else if (length < 45000) scenario = 'cluster_3';
      else if (length < 75000) scenario = 'tray_5';
      else if (length > 250000) scenario = 'dense_heap';
      else scenario = 'multi_20';
    }

    const rawDetections: OnionDetectionItem[] = [];

    if (scenario === 'single') {
      // 1 Onion: isolated, centered, high confidence, no false ghosts
      rawDetections.push(
        this.createBulb(1, 0.50, 0.50, 0.22, 0.24, rand, 'Healthy', 58.0)
      );
    } else if (scenario === 'cluster_3') {
      // 3 Onions: sample cluster
      rawDetections.push(this.createBulb(1, 0.32, 0.48, 0.14, 0.15, rand, 'Healthy', 52.0));
      rawDetections.push(this.createBulb(2, 0.68, 0.46, 0.15, 0.16, rand, 'Healthy', 54.5));
      rawDetections.push(this.createBulb(3, 0.50, 0.62, 0.13, 0.14, rand, 'Damaged', 48.0));
    } else if (scenario === 'tray_5') {
      // 5 Onions: sampling tray with 1 edge onion
      rawDetections.push(this.createBulb(1, 0.24, 0.32, 0.12, 0.13, rand, 'Healthy', 55.0));
      rawDetections.push(this.createBulb(2, 0.50, 0.30, 0.13, 0.13, rand, 'Healthy', 56.0));
      rawDetections.push(this.createBulb(3, 0.76, 0.34, 0.12, 0.12, rand, 'Damaged', 46.0));
      rawDetections.push(this.createBulb(4, 0.36, 0.65, 0.13, 0.14, rand, 'Sprouted', 51.0));
      rawDetections.push(this.createBulb(5, 0.64, 0.68, 0.11, 0.11, rand, 'Undersized', 36.5));
    } else if (scenario === 'multi_20') {
      let id = 1;
      for (let r = 0; r < 4; r++) {
        for (let c = 0; c < 6; c++) {
          const cx = 0.12 + c * 0.15 + (rand() * 0.03 - 0.015);
          const cy = 0.15 + r * 0.22 + (rand() * 0.03 - 0.015);
          const rx = 0.065 * (0.90 + rand() * 0.25);
          const ry = 0.070 * (0.90 + rand() * 0.25);
          rawDetections.push(this.createBulb(id++, cx, cy, rx, ry, rand));
        }
      }
      // Add duplicate to test NMS
      if (rawDetections.length > 0) {
        const d = rawDetections[0];
        rawDetections.push({
          ...d,
          id: id++,
          bbox: { ...d.bbox, ymin: d.bbox.ymin + 0.005, xmin: d.bbox.xmin + 0.005 },
          confidence: d.confidence - 0.08,
        });
      }
    } else {
      // Dense heap
      let id = 1;
      for (let r = 0; r < 5; r++) {
        for (let c = 0; c < 6; c++) {
          if (r === 0 && (c < 1 || c > 4)) continue;
          const cx = 0.10 + c * 0.16 + (rand() * 0.04 - 0.02);
          const cy = 0.12 + r * 0.18 + (rand() * 0.04 - 0.02);
          const rx = 0.070 * (0.85 + rand() * 0.30);
          const ry = 0.075 * (0.85 + rand() * 0.30);
          rawDetections.push(this.createBulb(id++, cx, cy, rx, ry, rand));
        }
      }
      // Add duplicate to test NMS
      if (rawDetections.length > 3) {
        const d = rawDetections[3];
        rawDetections.push({
          ...d,
          id: id++,
          bbox: { ...d.bbox, ymin: d.bbox.ymin + 0.006, xmin: d.bbox.xmin + 0.006 },
          confidence: d.confidence - 0.10,
        });
      }
    }

    // Step 3: Non-Maximum Suppression (NMS) Deduplication
    const { kept: finalDetections, suppressedCount } = applyNms(
      rawDetections,
      AppAiModelConfig.iouNmsThreshold
    );
    const tInferEnd = performance.now();

    // Step 4: Quality Grading & Defects Summary
    const tPostStart = performance.now();
    const total = Math.max(1, finalDetections.length);
    const countA = finalDetections.filter((d) => d.grade === 'Grade A').length;
    const countB = finalDetections.filter((d) => d.grade === 'Grade B').length;
    const countR = finalDetections.filter((d) => d.grade === 'Reject').length;

    const grades = {
      gradeAPercent: Math.round((countA / total) * 1000) / 10,
      gradeBPercent: Math.round((countB / total) * 1000) / 10,
      rejectPercent: Math.round((countR / total) * 1000) / 10,
    };

    const defects = {
      healthy: finalDetections.filter((d) => d.defectType === 'Healthy').length,
      damaged: finalDetections.filter((d) => d.defectType === 'Damaged').length,
      rotten: finalDetections.filter((d) => d.defectType === 'Rotten').length,
      sprouted: finalDetections.filter((d) => d.defectType === 'Sprouted').length,
      undersized: finalDetections.filter((d) => d.defectType === 'Undersized').length,
      unknown: finalDetections.filter((d) => d.defectType === 'Unknown').length,
      total: finalDetections.length,
    };

    const warnings: string[] = [
      'Heap overlap detected: Surface contour estimates only.',
    ];
    if (grades.rejectPercent > 18) {
      warnings.push('High rejection rate (>18%). Secondary cross-sectional sampling advised.');
    }
    const edgeCount = finalDetections.filter((d) => d.isEdgeOnion).length;
    if (edgeCount > 0) {
      warnings.push(`${edgeCount} bulb(s) positioned near image frame boundaries.`);
    }

    const tPostEnd = performance.now();
    const totalTimeMs = Math.round((tPostEnd - t0) * 10) / 10;

    const overallConfidence =
      finalDetections.length > 0
        ? Math.round(
            (finalDetections.reduce((sum, d) => sum + d.confidence, 0) /
              finalDetections.length) *
              100
          ) / 100
        : 0.90;

    let diagnostics: DeveloperDiagnostics | undefined = undefined;
    if (options.enableDiagnostics || AppAiModelConfig.enableDiagnostics) {
      diagnostics = {
        modelName: AppAiModelConfig.modelName,
        modelVersion: AppAiModelConfig.modelVersion,
        rawDetections: rawDetections.length,
        finalDetections: finalDetections.length,
        nmsSuppressed: suppressedCount,
        preprocessingTimeMs: Math.round((tPrepEnd - tPrepStart) * 10) / 10,
        inferenceTimeMs: Math.round((tInferEnd - tInferStart) * 10) / 10,
        postprocessingTimeMs: Math.round((tPostEnd - tPostStart) * 10) / 10,
        totalTimeMs,
        imageSize: {
          width: rawW,
          height: rawH,
          sizeBytes: length,
          exifRotationDegrees: 0,
        },
      };
    }

    return {
      analysisId: `HA-${Math.floor(100000 + rand() * 899999)}`,
      timestamp: new Date().toISOString(),
      visibleOnionCount: finalDetections.length,
      grades,
      defects,
      detections: finalDetections,
      overallConfidence,
      processingTimeMs: totalTimeMs,
      isPrototype: true,
      warnings,
      disclaimer: AppConfig.estimationDisclaimer,
      annotatedImageBase64: null,
      diagnostics,
    };
  }

  private static createBulb(
    id: number,
    cx: float,
    cy: float,
    rx: float,
    ry: float,
    rand: () => number,
    defectOverride?: DefectType,
    diaOverride?: number
  ): OnionDetectionItem {
    const ymin = Math.max(0.01, Math.min(0.99, cy - ry));
    const xmin = Math.max(0.01, Math.min(0.99, cx - rx));
    const ymax = Math.max(0.01, Math.min(0.99, cy + ry));
    const xmax = Math.max(0.01, Math.min(0.99, cx + rx));

    const isEdge = xmin <= 0.03 || ymin <= 0.03 || xmax >= 0.97 || ymax >= 0.97;

    const polygon: Point2D[] = [];
    const pointCount = 12;
    for (let i = 0; i < pointCount; i++) {
      const angle = ((2 * Math.PI) / pointCount) * i;
      const jitter = 0.95 + rand() * 0.10;
      const px = Math.max(0, Math.min(1, cx + rx * Math.cos(angle) * jitter));
      const py = Math.max(0, Math.min(1, cy + ry * Math.sin(angle) * jitter));
      polygon.push({
        x: Math.round(px * 1000) / 1000,
        y: Math.round(py * 1000) / 1000,
      });
    }

    let defect: DefectType = defectOverride || 'Healthy';
    let grade: QualityGrade = 'Grade A';
    let severity = 0.05;
    let dia = diaOverride || 42 + rand() * 28;

    if (!defectOverride) {
      const roll = rand();
      if (dia < AppAiModelConfig.minPremiumDiameterMm) {
        defect = 'Undersized';
        grade = 'Grade B';
        severity = 0.35;
      } else if (roll < 0.65) {
        defect = 'Healthy';
        grade = 'Grade A';
        severity = 0.05;
      } else if (roll < 0.78) {
        defect = 'Damaged';
        grade = 'Grade B';
        severity = 0.44;
      } else if (roll < 0.86) {
        defect = 'Sprouted';
        grade = 'Reject';
        severity = 0.85;
      } else if (roll < 0.92) {
        defect = 'Rotten';
        grade = 'Reject';
        severity = 0.92;
      } else {
        defect = 'Undersized';
        grade = 'Grade B';
        dia = 35 + rand() * 4;
        severity = 0.38;
      }
    } else {
      if (defect === 'Healthy') {
        grade = 'Grade A';
        severity = 0.05;
      } else if (defect === 'Damaged') {
        grade = 'Grade B';
        severity = 0.44;
      } else if (defect === 'Undersized') {
        grade = 'Grade B';
        severity = 0.35;
      } else {
        grade = 'Reject';
        severity = 0.88;
      }
    }

    const conf = 0.84 + rand() * 0.14;

    return {
      id,
      bbox: {
        ymin: Math.round(ymin * 1000) / 1000,
        xmin: Math.round(xmin * 1000) / 1000,
        ymax: Math.round(ymax * 1000) / 1000,
        xmax: Math.round(xmax * 1000) / 1000,
      },
      polygon,
      confidence: Math.round(conf * 100) / 100,
      defectType: defect,
      grade,
      estimatedDiameterMm: Math.round(dia * 10) / 10,
      severityScore: Math.round(severity * 100) / 100,
      isEdgeOnion: isEdge,
    };
  }
}
type float = number;
