/**
 * Production AI Model Configuration for OnionSure
 * Supports dynamic model paths, thresholds, and developer diagnostics.
 */

export interface AiModelConfig {
  modelName: string;
  modelPath: string;
  fallbackModelName: string;
  modelVersion: string;
  inputWidth: number;
  inputHeight: number;
  maxImageDimension: number;
  confidenceThreshold: number;
  iouNmsThreshold: number;
  minPremiumDiameterMm: number;
  enableDiagnostics: boolean;
}

export const AppAiModelConfig: AiModelConfig = {
  modelName: 'yoloe-seg-onion',
  modelPath: 'models/yoloe_seg_onion_v1.pt',
  fallbackModelName: 'yoloe-seg-onion-prototype',
  modelVersion: '1.2.0',
  inputWidth: 640,
  inputHeight: 640,
  maxImageDimension: 2048,
  confidenceThreshold: 0.40,
  iouNmsThreshold: 0.45,
  minPremiumDiameterMm: 40.0,
  enableDiagnostics: false,
};
