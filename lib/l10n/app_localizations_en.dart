// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'OnionSure';

  @override
  String get dashboardTitle => 'Mandi Quality Monitoring Dashboard';

  @override
  String get enamReady => 'e-NAM Integration Ready';

  @override
  String get dashboardSubtitle =>
      'APMC Central Yard - Live AI Quality Grading & Traceability';

  @override
  String get totalBatches => 'Total Batches';

  @override
  String get inspected => 'Inspected';

  @override
  String get avgGradeA => 'Avg Grade A';

  @override
  String get totalVolume => 'Total Volume';

  @override
  String volumeQuintals(String weight) {
    return '$weight Qtl';
  }

  @override
  String get bagsUnit => 'Bags';

  @override
  String get bags => 'bags';

  @override
  String get newBatch => 'Register Batch';

  @override
  String get inspectHeap => 'Inspect Heap';

  @override
  String get scanQr => 'Scan QR Code';

  @override
  String get verifyCert => 'Verify Certificate';

  @override
  String get mandiLots => 'Registered Onion Batches';

  @override
  String get searchHint => 'Search batch #, farmer, or mandi...';

  @override
  String get filterAll => 'All';

  @override
  String get filterPending => 'Pending';

  @override
  String get filterInspected => 'Inspected';

  @override
  String get filterCertified => 'Certified';

  @override
  String get filterRejected => 'Rejected';

  @override
  String get noBatchesFound => 'No batches found';

  @override
  String noBatchesFoundFor(String filter) {
    return 'No batches found for \"$filter\"';
  }

  @override
  String get noBatchesSub =>
      'Create a new batch or adjust your search filter to get started.';

  @override
  String get clearFilter => 'Clear Filter';

  @override
  String get varietyLabel => 'Variety:';

  @override
  String get volumeLabel => 'Volume:';

  @override
  String get qualityScoreLabel => 'Quality Score:';

  @override
  String get createdLabel => 'Created:';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusInspected => 'Inspected';

  @override
  String get statusCertified => 'Certified';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get tamil => 'தமிழ்';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get languageChanged => 'Language changed successfully';

  @override
  String get demoAi => 'Demo AI';

  @override
  String get liveApi => 'Live API';

  @override
  String get aiConfigTitle => 'AI Inference Configuration';

  @override
  String get demoModeTitle => 'Demo Presentation Mode';

  @override
  String get demoModeSubtitle =>
      'Instant simulated onion heap inference without active backend server';

  @override
  String get fastApiEndpoint => 'FastAPI Endpoint URL:';

  @override
  String get fastApiHint => 'Run \"python3 app/main.py\" in backend/ directory';

  @override
  String get apply => 'Apply';

  @override
  String get cancel => 'Cancel';

  @override
  String get scanOrEnterBatchCode => 'Scan or Enter Batch QR / Code';

  @override
  String get scanBatchInstruction =>
      'Enter a Batch Number or scan QR code on the farmer lot bag:';

  @override
  String get findBatch => 'Find Batch';

  @override
  String get batchSample => 'Sample';

  @override
  String get analyzeHeapButton => 'Analyze Onion Heap';

  @override
  String get registerNewBatch => 'Register Onion Batch';

  @override
  String get registerBatchSubtitle =>
      'Assign a digital batch record to the onion arrival. A traceable QR code will be generated for mandi tracking.';

  @override
  String get farmerDetails => 'Farmer & Lot Information';

  @override
  String get farmerName => 'Farmer / Trader Full Name';

  @override
  String get enterFarmerName => 'Enter farmer full name';

  @override
  String get pleaseEnterFarmerName => 'Farmer name is required';

  @override
  String get phoneNumber => 'Mobile Number';

  @override
  String get enterPhoneNumber => '10-digit mobile number';

  @override
  String get pleaseEnterPhone => 'Please enter contact number';

  @override
  String get pleaseEnterValidPhone => 'Please enter valid 10-digit number';

  @override
  String get mandiYard => 'Mandi APMC Yard';

  @override
  String get enterMandiYard => 'e.g. Lasalgaon, Nashik APMC';

  @override
  String get pleaseEnterMandi => 'Please specify mandi location';

  @override
  String get lotSpecification => 'Mandi & Crop Specification';

  @override
  String get onionVariety => 'Onion Variety';

  @override
  String get harvestDate => 'Harvest Date';

  @override
  String get lotVolume => 'Lot Volume';

  @override
  String get weightQuintalsLabel => 'Weight (Quintals)';

  @override
  String get bagCountLabel => 'Bag Count';

  @override
  String get estimatedBags => 'Estimated Bags / Crates';

  @override
  String get enterBagCount => 'Total quantity in bags';

  @override
  String get pleaseEnterBags => 'Enter bag count';

  @override
  String get enterValidWeight => 'Enter valid weight';

  @override
  String get approxWeightPerBag => 'Approx. Weight per Bag (kg)';

  @override
  String get storageCondition => 'Storage Condition';

  @override
  String get notesFieldObservations => 'Notes / Field Observations (Optional)';

  @override
  String get enterNotes =>
      'Add any notes on curing, skin adherence, or field observations...';

  @override
  String get registerLotButton => 'Create Batch & Generate QR';

  @override
  String get batchCreatedSuccess => 'Batch registered successfully';

  @override
  String get heapInspectionTitle => 'Analyze Onion Heap';

  @override
  String get heapInspectionSubtitle =>
      'Capture or select a clear top-down heap photo';

  @override
  String get inspectionTargetBatch => 'Inspection Target Batch';

  @override
  String get heapImageCapture => 'Heap Image Capture';

  @override
  String get heapImageInstructions =>
      'Photograph or upload an unobstructed top/angle view of the onion heap.';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get uploadFile => 'Upload File';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get quickPresets => 'Quick Presets:';

  @override
  String get sampleNashikRed => 'Lasalgaon Red';

  @override
  String get sampleCommercialBulk => 'Garva Mix';

  @override
  String get sampleFieldHarvest => 'Sprout/Rot Heap';

  @override
  String get photoReady => 'Sample Onion Heap Loaded';

  @override
  String get readyForAi => 'Ready for AI Computer Vision';

  @override
  String get tapToChange => 'Tap above to change image';

  @override
  String get inspectionParameters => 'Inspection Parameters';

  @override
  String get inspectorNameLabel => 'Inspector Name';

  @override
  String get inspectorIdLabel => 'Inspector ID';

  @override
  String get sampleBagWeightLabel => 'Sample Bag Weight (kg)';

  @override
  String get observationsNotesLabel => 'Lot Observations / Notes';

  @override
  String get runAiAnalysis => 'Run AI Heap Segmentation & Grading';

  @override
  String get stepReady => 'Ready';

  @override
  String get stepUploading => 'Uploading heap image to inference pipeline...';

  @override
  String get stepExtracting =>
      'Extracting visible onion instance boundaries...';

  @override
  String get stepClassifying =>
      'Classifying defects: healthy, rot, sprout, damage...';

  @override
  String get stepFinalizing => 'Finalizing AGMARK Grade A/B/Reject metrics...';

  @override
  String analysisFailed(String error) {
    return 'Analysis failed: $error';
  }

  @override
  String get pleaseSelectImage =>
      'Please select or capture an onion heap image';

  @override
  String get bestPracticesTitle => 'Inspection Best Practices';

  @override
  String get tip1 =>
      'Keep entire top layer in frame for representative sampling';

  @override
  String get tip2 => 'Ensure uniform diffused lighting (avoid harsh shadows)';

  @override
  String get tip3 => 'Remove large debris or sacking covering the pile';

  @override
  String get heapQualityResults => 'Heap Quality Estimation Results';

  @override
  String assignedLotGrade(String grade) {
    return 'Assigned Lot Grade: $grade';
  }

  @override
  String bulbsVisible(int count) {
    return '$count bulbs visible';
  }

  @override
  String confidencePercent(String value) {
    return '$value% confidence';
  }

  @override
  String latencyMs(int ms) {
    return '$ms ms';
  }

  @override
  String get instanceSegmentation => 'Instance Segmentation Overlay';

  @override
  String get tapBulbHint =>
      'Tap any onion bulb to view diameter, defect type, and confidence score.';

  @override
  String get prototypeEngine => 'Prototype Inference Engine';

  @override
  String get fineTunedEngine => 'Fine-Tuned YOLO11-Seg';

  @override
  String visionWarnings(int count) {
    return 'Vision Quality Warnings ($count)';
  }

  @override
  String get generatePdfReport => 'Generate Digital PDF Report';

  @override
  String get saveAndCertify => 'Save & Certify Batch';

  @override
  String inspectionSavedSuccessWithGrade(String grade) {
    return 'Inspection saved! Batch certified as $grade.';
  }

  @override
  String get polygonsLabel => 'Polygons';

  @override
  String get boxesLabel => 'Boxes';

  @override
  String get labelsLabel => 'Labels';

  @override
  String get allDefects => 'All Defects';

  @override
  String get filterDefectAll => 'Filter defect: All';

  @override
  String bulbDetailText(int id, String defect) {
    return 'Onion #$id: $defect';
  }

  @override
  String bulbMetaInfo(String grade, String diameter, String confidence) {
    return 'Grade: $grade • Est. Diameter: $diameter mm • Conf: $confidence%';
  }

  @override
  String get digitalGradeDistribution => 'Digital Quality Grade Distribution';

  @override
  String get gradeAExport => 'Grade A (Export)';

  @override
  String get gradeBLocal => 'Grade B (Local)';

  @override
  String get rejectWaste => 'Reject / Waste';

  @override
  String get targetGradeA => 'Target >= 70%';

  @override
  String get minorDefects => 'Minor defects';

  @override
  String get rotSprout => 'Rot / Sprout';

  @override
  String get defectBreakdown => 'Visible Defect Breakdown';

  @override
  String get disclaimerTitle => 'VISIBLE SURFACE ESTIMATION LIMITATION';

  @override
  String get disclaimerText =>
      'Surface vision analysis estimates visible top-layer quality. Physical core sampling remains recommended for deep bulk lots.';

  @override
  String get qualityHealthy => 'Healthy';

  @override
  String get qualityDamaged => 'Damaged';

  @override
  String get qualityRotten => 'Rotten';

  @override
  String get qualitySprouted => 'Sprouted';

  @override
  String get qualityUndersized => 'Undersized';

  @override
  String get qualityUnknown => 'Unknown';

  @override
  String get gradeA => 'Grade A';

  @override
  String get gradeB => 'Grade B';

  @override
  String get gradeC => 'Reject';

  @override
  String get batchDetails => 'Batch Details';

  @override
  String get analyzeHeapForBatch => 'Analyze Onion Heap for this Batch';

  @override
  String get completedInspections => 'Completed Quality Inspections';

  @override
  String get noInspectionsYet =>
      'No inspection recorded for this batch yet.\nClick \"Analyze Onion Heap\" to scan.';

  @override
  String get viewPdf => 'View PDF';

  @override
  String inspectionTitle(String grade) {
    return 'Inspection: $grade';
  }

  @override
  String get verifyCertificateTitle => 'e-NAM Quality Certificate Verification';

  @override
  String get publicVerification => 'Public Certificate Verification';

  @override
  String get verifySubtitle =>
      'Enter the verification token printed beneath the report QR code to confirm grading authenticity and tamper-proof records.';

  @override
  String get verifyButton => 'Verify';

  @override
  String get authenticCertificate => 'AUTHENTIC QUALITY CERTIFICATE';

  @override
  String get recordNotFound => 'Certificate Record Not Found';

  @override
  String recordNotFoundMsg(String query) {
    return 'The verification token \"$query\" was not found in the authenticated mandi database.';
  }

  @override
  String tokenLabel(String token) {
    return 'Token: $token';
  }

  @override
  String get batchNumberLabel => 'Batch Number';

  @override
  String get certifiedInspector => 'Certified Inspector';

  @override
  String get inspectionTimestamp => 'Inspection Timestamp';

  @override
  String get visibleSampleCount => 'Visible Sample Count';

  @override
  String get gradeARatio => 'Grade A Ratio';

  @override
  String get gradeBRatio => 'Grade B Ratio';

  @override
  String get rejectionRate => 'Rejection Rate';

  @override
  String get modelConfidence => 'Model Confidence';

  @override
  String bulbsScannedCount(int count) {
    return '$count bulbs scanned';
  }

  @override
  String get digitalCertificate => 'Digital Quality Certificate';

  @override
  String get shareCertificate => 'Share Certificate';

  @override
  String verificationRibbon(String token, String inspector) {
    return 'Verification Token: $token • Signed by $inspector';
  }

  @override
  String get certTitle => 'ONIONSURE DIGITAL QUALITY CERTIFICATE';

  @override
  String get certSub => 'SIH26031: AI-Powered Smart Onion Batch Grading';

  @override
  String get certMandiRecord => 'Accredited Mandi APMC Inspection Record';

  @override
  String get certBatchRegistration => 'BATCH & LOT REGISTRATION';

  @override
  String get certInspectionDate => 'Inspection Date';

  @override
  String get certFarmerOwner => 'Farmer / Lot Owner';

  @override
  String get certMandiYard => 'Mandi Yard';

  @override
  String get certVariety => 'Onion Variety';

  @override
  String get certTotalWeight => 'Total Weight';

  @override
  String get certAssignedInspector => 'Assigned Inspector';

  @override
  String get certVerificationToken => 'Verification Token';

  @override
  String get certGradingSection =>
      'HEAP INSTANCE SEGMENTATION & DIGITAL GRADING';

  @override
  String get certMetric => 'Metric';

  @override
  String get certComputedValue => 'Computed Value';

  @override
  String get certGradingSpec => 'Grading Standard Specification';

  @override
  String get certVisibleScanned => 'Visible Onions Scanned';

  @override
  String certVisibleBulbs(int count) {
    return '$count bulbs';
  }

  @override
  String get certSurfaceExtraction => 'Surface polygon boundary extraction';

  @override
  String get certGradeARatio => 'Grade A Quality Ratio';

  @override
  String get certGradeASpec => 'Standard: >= 70% for Grade A certification';

  @override
  String get certGradeBRatio => 'Grade B Fair Ratio';

  @override
  String get certGradeBSpec => 'Permissible minor skin cuts / size variance';

  @override
  String get certRejectRatio => 'Rejection / Waste Ratio';

  @override
  String get certRejectSpec => 'Rot, decay, sprouting > 5% restricts trade';

  @override
  String get certConfidenceScore => 'Model Confidence Score';

  @override
  String get certMultiContour => 'Multi-contour overlap verification';

  @override
  String get certDefectBreakdown => 'DEFECT CLASSIFICATION BREAKDOWN';

  @override
  String get certDisclaimerHeader =>
      'IMPORTANT ESTIMATION BOUNDARY & MANDI DISCLAIMER';

  @override
  String get certScanQr => 'Scan QR to verify on e-NAM portal';

  @override
  String get certGraderSignature => 'Authorized Quality Grader Signature';

  @override
  String certDate(String date) {
    return 'Date: $date';
  }
}
