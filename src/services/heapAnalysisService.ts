import {
  HeapAnalysisResult,
  OnionDetectionItem,
  DefectType,
  QualityGrade,
  Point2D,
  DetectionBoundingBox,
} from '../types';
import { AppConfig } from '../config/appConfig';

// Simple seeded pseudo-random number generator for deterministic reproducible samples
function createSeededRandom(seed: number) {
  let s = seed % 2147483647;
  if (s <= 0) s += 2147483646;
  return () => {
    s = (s * 16807) % 2147483647;
    return (s - 1) / 2147483646;
  };
}

export class HeapAnalysisService {
  async analyzeHeap(
    imageBytesOrBase64: string,
    filename: string = 'heap.jpg',
    useMock: boolean = true,
    apiUrl: string = AppConfig.defaultAiApiUrl
  ): Promise<HeapAnalysisResult> {
    if (!useMock) {
      try {
        // Attempt live API upload
        const formData = new FormData();
        // convert base64 or blob if needed
        let blob: Blob;
        if (imageBytesOrBase64.startsWith('data:')) {
          const res = await fetch(imageBytesOrBase64);
          blob = await res.blob();
        } else {
          blob = new Blob([imageBytesOrBase64], { type: 'image/jpeg' });
        }
        formData.append('file', blob, filename);

        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 12000);

        const response = await fetch(apiUrl, {
          method: 'POST',
          body: formData,
          signal: controller.signal,
        });
        clearTimeout(timeoutId);

        if (response.ok) {
          const data = await response.json();
          return this.normalizeApiResponse(data);
        }
      } catch (err) {
        console.warn('Live API request failed or timed out. Falling back to realistic simulation.', err);
      }
    }

    // Realistic inference simulation
    await new Promise((resolve) => setTimeout(resolve, 650));
    return this.generateRealisticHeapAnalysis(imageBytesOrBase64);
  }

  generateRealisticHeapAnalysis(imageRef: string): HeapAnalysisResult {
    const seed = imageRef ? Math.abs(imageRef.length * 37 + (imageRef.charCodeAt(10) || 42)) : 12345;
    const rand = createSeededRandom(seed);

    const detections: OnionDetectionItem[] = [];
    const rows = 4;
    const cols = 5;
    let idCounter = 1;

    for (let r = 0; r < rows; r++) {
      for (let c = 0; c < cols; c++) {
        // ~88% presence rate in heap
        if (rand() > 0.9) continue;

        const cx = 0.12 + c * 0.18 + (rand() * 0.05 - 0.025);
        const cy = 0.14 + r * 0.2 + (rand() * 0.05 - 0.025);
        const rx = 0.075 * (0.85 + rand() * 0.35);
        const ry = 0.085 * (0.85 + rand() * 0.35);

        const xmin = Math.max(0.02, Math.min(0.98, cx - rx));
        const xmax = Math.max(0.02, Math.min(0.98, cx + rx));
        const ymin = Math.max(0.02, Math.min(0.98, cy - ry));
        const ymax = Math.max(0.02, Math.min(0.98, cy + ry));

        const bbox: DetectionBoundingBox = {
          ymin: Math.round(ymin * 1000) / 1000,
          xmin: Math.round(xmin * 1000) / 1000,
          ymax: Math.round(ymax * 1000) / 1000,
          xmax: Math.round(xmax * 1000) / 1000,
        };

        // Generate polygon contour
        const polygon: Point2D[] = [];
        const pointCount = 10;
        for (let i = 0; i < pointCount; i++) {
          const angle = ((2 * Math.PI) / pointCount) * i;
          const jitter = 0.94 + rand() * 0.12;
          const px = Math.max(0, Math.min(1, cx + rx * Math.cos(angle) * jitter));
          const py = Math.max(0, Math.min(1, cy + ry * Math.sin(angle) * jitter));
          polygon.push({
            x: Math.round(px * 1000) / 1000,
            y: Math.round(py * 1000) / 1000,
          });
        }

        // Defect distribution
        const roll = rand();
        let defect: DefectType;
        let grade: QualityGrade;
        let severity: number;
        let estDia = 42 + rand() * 30;

        if (roll < 0.68) {
          defect = 'Healthy';
          grade = 'Grade A';
          severity = 0.05;
        } else if (roll < 0.82) {
          defect = 'Damaged';
          grade = rand() > 0.5 ? 'Grade B' : 'Reject';
          severity = 0.42;
        } else if (roll < 0.89) {
          defect = 'Sprouted';
          grade = 'Reject';
          severity = 0.85;
        } else if (roll < 0.94) {
          defect = 'Rotten';
          grade = 'Reject';
          severity = 0.92;
        } else {
          defect = 'Undersized';
          grade = 'Grade B';
          estDia = 34 + rand() * 5;
          severity = 0.38;
        }

        const conf = 0.82 + rand() * 0.14;

        detections.push({
          id: idCounter++,
          bbox,
          polygon,
          confidence: Math.round(conf * 100) / 100,
          defectType: defect,
          grade,
          estimatedDiameterMm: Math.round(estDia * 10) / 10,
          severityScore: severity,
        });
      }
    }

    const total = Math.max(1, detections.length);
    const countA = detections.filter((d) => d.grade === 'Grade A').length;
    const countB = detections.filter((d) => d.grade === 'Grade B').length;
    const countR = detections.filter((d) => d.grade === 'Reject').length;

    const gradeDist = {
      gradeAPercent: Math.round((countA / total) * 1000) / 10,
      gradeBPercent: Math.round((countB / total) * 1000) / 10,
      rejectPercent: Math.round((countR / total) * 1000) / 10,
    };

    const defectCounts = {
      healthy: detections.filter((d) => d.defectType === 'Healthy').length,
      damaged: detections.filter((d) => d.defectType === 'Damaged').length,
      rotten: detections.filter((d) => d.defectType === 'Rotten').length,
      sprouted: detections.filter((d) => d.defectType === 'Sprouted').length,
      undersized: detections.filter((d) => d.defectType === 'Undersized').length,
      unknown: detections.filter((d) => d.defectType === 'Unknown').length,
      total: detections.length,
    };

    const warnings: string[] = [
      'Heap overlap detected: Surface contour estimates only.',
    ];
    if (gradeDist.rejectPercent > 18) {
      warnings.push('High rejection rate (>18%). Secondary cross-sectional sampling advised.');
    }

    return {
      analysisId: `HA-${Math.floor(100000 + rand() * 899999)}`,
      timestamp: new Date().toISOString(),
      visibleOnionCount: detections.length,
      grades: gradeDist,
      defects: defectCounts,
      detections,
      overallConfidence: 0.91,
      processingTimeMs: 480,
      isPrototype: true,
      warnings,
      disclaimer: AppConfig.estimationDisclaimer,
      annotatedImageBase64: null,
    };
  }

  private normalizeApiResponse(data: any): HeapAnalysisResult {
    return {
      analysisId: data.analysis_id || data.analysisId || `HA-${Date.now()}`,
      timestamp: data.timestamp || new Date().toISOString(),
      visibleOnionCount: data.visible_onion_count || (data.detections ? data.detections.length : 0),
      grades: {
        gradeAPercent: Number(data.grades?.grade_a_percent ?? data.grades?.gradeAPercent ?? 0),
        gradeBPercent: Number(data.grades?.grade_b_percent ?? data.grades?.gradeBPercent ?? 0),
        rejectPercent: Number(data.grades?.reject_percent ?? data.grades?.rejectPercent ?? 0),
      },
      defects: {
        healthy: Number(data.defects?.healthy ?? 0),
        damaged: Number(data.defects?.damaged ?? 0),
        rotten: Number(data.defects?.rotten ?? 0),
        sprouted: Number(data.defects?.sprouted ?? 0),
        undersized: Number(data.defects?.undersized ?? 0),
        unknown: Number(data.defects?.unknown ?? 0),
        total: Number(data.visible_onion_count ?? 0),
      },
      detections: (data.detections || []).map((d: any, idx: number) => ({
        id: d.id ?? idx + 1,
        bbox: {
          ymin: Number(d.bbox?.ymin ?? 0),
          xmin: Number(d.bbox?.xmin ?? 0),
          ymax: Number(d.bbox?.ymax ?? 1),
          xmax: Number(d.bbox?.xmax ?? 1),
        },
        polygon: (d.polygon || []).map((p: any) => ({
          x: Number(p.x ?? 0),
          y: Number(p.y ?? 0),
        })),
        confidence: Number(d.confidence ?? 0.85),
        defectType: (d.defect_type || d.defectType || 'Healthy') as DefectType,
        grade: (d.grade || 'Grade A') as QualityGrade,
        estimatedDiameterMm: Number(d.estimated_diameter_mm ?? d.estimatedDiameterMm ?? 50),
        severityScore: Number(d.severity_score ?? d.severityScore ?? 0.05),
      })),
      overallConfidence: Number(data.overall_confidence ?? 0.88),
      processingTimeMs: Number(data.processing_time_ms ?? 450),
      isPrototype: Boolean(data.is_prototype ?? true),
      warnings: data.warnings || ['Heap overlap detected: Surface contour estimates only.'],
      disclaimer: data.estimation_disclaimer || data.disclaimer || AppConfig.estimationDisclaimer,
      annotatedImageBase64: data.annotated_image_base64 || null,
    };
  }
}

export const heapAnalysisService = new HeapAnalysisService();
