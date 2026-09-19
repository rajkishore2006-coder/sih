class AppConfig {
  static const String appName = 'OnionSure';
  static const String appSubtitle = 'AI Smart Onion Quality & Digital Grading';
  static const String version = '1.0.0';
  static const String sihProblemCode = 'SIH26031';

  // AI Backend configuration
  static bool useMockAi = true;
  static String aiApiUrl = const String.fromEnvironment(
    'HEAP_ANALYSIS_API_URL',
    defaultValue: 'http://localhost:8000/api/analyze-heap',
  );

  // Disclaimer text required across analyses and reports
  static const String estimationDisclaimer =
      'Estimation is derived solely from visible surface onions in the heap image. '
      'Internal, occluded, and sub-surface onions are not directly measurable. '
      'Calibrate with physical cross-sectional sampling for final trade settlement.';
}
