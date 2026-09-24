export type SupportedLanguage = 'en' | 'ta' | 'hi';

export interface LanguageInfo {
  code: SupportedLanguage;
  name: string;
  nativeName: string;
}

export const SUPPORTED_LANGUAGES: LanguageInfo[] = [
  { code: 'en', name: 'English', nativeName: 'English' },
  { code: 'ta', name: 'Tamil', nativeName: 'தமிழ்' },
  { code: 'hi', name: 'Hindi', nativeName: 'हिन्दी' },
];

export interface Translations {
  appName: string;
  appSubtitle: string;
  sihProblemCode: string;
  footerText: string;
  footerDisclaimer: string;

  // Language selector
  languageSelect: string;

  // Common buttons & actions
  common: {
    back: string;
    cancel: string;
    save: string;
    confirm: string;
    delete: string;
    close: string;
    download: string;
    downloadPdf: string;
    downloadPng: string;
    downloadVectorPdf: string;
    downloaded: string;
    view: string;
    search: string;
    filter: string;
    all: string;
    apply: string;
    print: string;
    verified: string;
    pending: string;
    certified: string;
    inspected: string;
    rejected: string;
    loading: string;
    success: string;
    error: string;
    total: string;
    bags: string;
    quintals: string;
    qtl: string;
    kg: string;
    confidence: string;
    timestamp: string;
    inspector: string;
    token: string;
    sample: string;
    active: string;
  };

  // Nav titles and header subtitles
  nav: {
    home: string;
    registerBatch: string;
    registerBatchSubtitle: string;
    batchDetails: string;
    batchDetailsSubtitle: string;
    heapInspection: string;
    heapInspectionSubtitle: string;
    heapAnalysis: string;
    heapAnalysisSubtitle: string;
    certificate: string;
    certificateSubtitle: string;
    verify: string;
    verifySubtitle: string;
    history: string;
    historySubtitle: string;
    aiSettings: string;
    scanBatch: string;
    demoAi: string;
    liveApi: string;
  };

  // Dashboard & KPIs
  dashboard: {
    kpiTitle: string;
    kpiSubtitle: string;
    eNamReady: string;
    totalBatches: string;
    inspectedLots: string;
    avgGradeA: string;
    totalVolume: string;
    registerBatchAction: string;
    registerBatchDesc: string;
    inspectHeapAction: string;
    inspectHeapDesc: string;
    scanQrAction: string;
    scanQrDesc: string;
    verifyCertAction: string;
    verifyCertDesc: string;
    inspectionLogAction: string;
    savedCount: string;
    registeredBatchesTitle: string;
    batchesOfTotal: string;
    filterAll: string;
    filterCertified: string;
    filterInspected: string;
    filterPending: string;
    noBatchesFound: string;
    analyzeHeapCta: string;
  };

  // Create Batch
  createBatch: {
    traceabilityTitle: string;
    traceabilityDesc: string;
    formTitle: string;
    farmerNameLabel: string;
    farmerNamePlaceholder: string;
    farmerPhoneLabel: string;
    farmerPhonePlaceholder: string;
    mandiLocationLabel: string;
    onionVarietyLabel: string;
    weightLabel: string;
    bagCountLabel: string;
    harvestDateLabel: string;
    submitButton: string;
    errorNameRequired: string;
    errorWeightInvalid: string;
    errorBagCountInvalid: string;
  };

  // Batch Details
  batchDetail: {
    harvestedDate: string;
    inspectHeapBtn: string;
    inspectionHistoryTitle: string;
    noInspectionsYet: string;
    confirmDelete: string;
    deleteTooltip: string;
  };

  // Inspection Setup & Execution Screen
  inspectionScreen: {
    title: string;
    lotSelection: string;
    selectBatchPlaceholder: string;
    sourceMode: string;
    modePreset: string;
    modeUpload: string;
    presetSampleLabel: string;
    uploadHeapPhoto: string;
    uploadHeapPrompt: string;
    uploadHeapConstraints: string;
    fileSelected: string;
    inspectorMetaTitle: string;
    inspectorNameLabel: string;
    inspectorIdLabel: string;
    sampleWeightLabel: string;
    observationNotesLabel: string;
    observationNotesPlaceholder: string;
    runAnalysisBtn: string;
    analyzingTitle: string;
    stepUploading: string;
    stepContours: string;
    stepClassifying: string;
    stepFinalizing: string;
    errorNoBatch: string;
    errorInvalidWeight: string;
    errorInvalidImage: string;
    errorImageTooLarge: string;
    errorReadFailed: string;
  };

  // Heap Analysis Results Screen
  heapAnalysis: {
    gradeExport: string;
    gradeFair: string;
    gradeReject: string;
    inferenceTime: string;
    scannedBulbs: string;
    segmentationTitle: string;
    clickBulbHint: string;
    polygonsToggle: string;
    boxesToggle: string;
    labelsToggle: string;
    filterAllDefects: string;
    bulbDetailHeader: string;
    diameterLabel: string;
    clickPrompt: string;
    certifyBannerTitle: string;
    certifyBannerSubtitle: string;
    certifyBtn: string;
  };

  // Defect Classification
  defects: {
    title: string;
    subtitle: string;
    totalCount: string;
    healthy: string;
    healthyDesc: string;
    damaged: string;
    damagedDesc: string;
    rotten: string;
    rottenDesc: string;
    sprouted: string;
    sproutedDesc: string;
    undersized: string;
    undersizedDesc: string;
    unknown: string;
    unknownDesc: string;
  };

  // Quality Grades
  grades: {
    title: string;
    standard: string;
    gradeA: string;
    gradeADesc: string;
    gradeASubtitle: string;
    gradeB: string;
    gradeBDesc: string;
    gradeBSubtitle: string;
    reject: string;
    rejectDesc: string;
    rejectSubtitle: string;
  };

  // Disclaimer
  disclaimer: {
    heading: string;
    body: string;
  };

  // Inspection History Screen
  historyScreen: {
    title: string;
    subtitle: string;
    newInspectionBtn: string;
    searchPlaceholder: string;
    emptySearch: string;
    emptyLog: string;
    noResultsFound: string;
    clearFilter: string;
  };

  // Verification Screen
  verifyScreen: {
    title: string;
    subtitle: string;
    tokenInputLabel: string;
    tokenInputPlaceholder: string;
    verifyBtn: string;
    activeTokensLabel: string;
    validTitle: string;
    invalidTitle: string;
    invalidMessage: string;
    verifiedSummary: string;
    viewCertBtn: string;
    batchNumberLabel: string;
    farmerLabel: string;
    mandiLabel: string;
    gradeAssignedLabel: string;
    timestampLabel: string;
  };

  // Certificate / Report Screen
  reportScreen: {
    backToDetail: string;
    dashboard: string;
    print: string;
    downloadPdf: string;
    downloadPng: string;
    downloadVector: string;
    successPdf: string;
    successVectorPdf: string;
    successPng: string;
    errorPdf: string;
    errorPng: string;
    errorVectorPdf: string;
    officialTitle: string;
    officialSubtitle: string;
    govtSubtitle: string;
    certificateNumber: string;
    issueDate: string;
    verifiedBadge: string;
    lotDetailsHeader: string;
    batchNumber: string;
    farmerName: string;
    mandiYard: string;
    onionVariety: string;
    lotWeight: string;
    bagQuantity: string;
    inspectionHeader: string;
    leadInspector: string;
    inspectorId: string;
    sampleWeight: string;
    verificationToken: string;
    gradingResultsHeader: string;
    assignedGrade: string;
    gradeRationale: string;
    defectBreakdownHeader: string;
    notesHeader: string;
    digitalSignTitle: string;
    digitalSignSubtitle: string;
    qrVerifyPrompt: string;
  };

  // Modals
  scanModal: {
    title: string;
    desc: string;
    placeholder: string;
    testSamples: string;
    findBatch: string;
    errorEmpty: string;
    errorNotFound: string;
  };

  aiSettingsModal: {
    title: string;
    demoModeTitle: string;
    demoModeDesc: string;
    apiUrlLabel: string;
    apiUrlDesc: string;
    diagnosticsTitle: string;
    diagnosticsDesc: string;
    applyBtn: string;
  };

  // Inspector Login / Mandi Session
  login: {
    title: string;
    subtitle: string;
    inspectorNameLabel: string;
    inspectorIdLabel: string;
    mandiLocationLabel: string;
    pinLabel: string;
    loginBtn: string;
    logoutBtn: string;
    activeSession: string;
    sessionBadge: string;
    successMessage: string;
    welcomeBack: string;
    demoCredentialsHint: string;
  };

  // Offline & Sync
  offline: {
    offlineMode: string;
    onlineMode: string;
    cachedDataNotice: string;
    pendingSyncCount: string;
    syncNow: string;
    syncing: string;
    syncSuccess: string;
    syncError: string;
    queuedOffline: string;
    installApp: string;
    installOnIos: string;
    iosInstallTitle: string;
    iosInstallStep1: string;
    iosInstallStep2: string;
    offlineSavedNotice: string;
    pendingQueueTitle: string;
  };
}
