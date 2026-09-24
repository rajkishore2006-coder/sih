// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => 'OnionSure';

  @override
  String get dashboardTitle => 'மண்டி தரம் கண்காணிப்பு கட்டுப்பாட்டகம்';

  @override
  String get enamReady => 'e-NAM இணைப்பு தயார்';

  @override
  String get dashboardSubtitle =>
      'APMC மத்திய வளாகம் - நேரடி AI தர நிர்ணயம் & தடமறிதல்';

  @override
  String get totalBatches => 'மொத்த தொகுதிகள்';

  @override
  String get inspected => 'ஆய்வு செய்யப்பட்டது';

  @override
  String get avgGradeA => 'சராசரி தரம் A';

  @override
  String get totalVolume => 'மொத்த அளவு';

  @override
  String volumeQuintals(String weight) {
    return '$weight குவிண்டால்';
  }

  @override
  String get bagsUnit => 'மூட்டைகள்';

  @override
  String get bags => 'மூட்டைகள்';

  @override
  String get newBatch => 'தொகுதி பதிவு';

  @override
  String get inspectHeap => 'குவியல் ஆய்வு';

  @override
  String get scanQr => 'QR ஸ்கேன்';

  @override
  String get verifyCert => 'சான்றிதழ் சரிபார்';

  @override
  String get mandiLots => 'பதிவு செய்யப்பட்ட வெங்காயத் தொகுதிகள்';

  @override
  String get searchHint => 'தொகுதி எண், விவசாயி அல்லது மண்டியைத் தேடுக...';

  @override
  String get filterAll => 'அனைத்தும்';

  @override
  String get filterPending => 'நிலுவையில்';

  @override
  String get filterInspected => 'ஆய்வு செய்யப்பட்டது';

  @override
  String get filterCertified => 'சான்றளிக்கப்பட்டது';

  @override
  String get filterRejected => 'நிராகரிக்கப்பட்டது';

  @override
  String get noBatchesFound => 'தொகுதிகள் எதுவும் கிடைக்கவில்லை';

  @override
  String noBatchesFoundFor(String filter) {
    return '\"$filter\"-க்கு தொகுதிகள் எதுவும் கிடைக்கவில்லை';
  }

  @override
  String get noBatchesSub =>
      'தொடங்குவதற்கு புதிய தொகுதியை உருவாக்கவும் அல்லது வடிகட்டியை மாற்றவும்.';

  @override
  String get clearFilter => 'வடிகட்டியை நீக்கு';

  @override
  String get varietyLabel => 'ரகம்:';

  @override
  String get volumeLabel => 'அளவு:';

  @override
  String get qualityScoreLabel => 'தர மதிப்பெண்:';

  @override
  String get createdLabel => 'உருவாக்கப்பட்டது:';

  @override
  String get statusPending => 'நிலுவையில்';

  @override
  String get statusInspected => 'ஆய்வு செய்யப்பட்டது';

  @override
  String get statusCertified => 'சான்றளிக்கப்பட்டது';

  @override
  String get statusRejected => 'நிராகரிக்கப்பட்டது';

  @override
  String get selectLanguage => 'மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get english => 'English';

  @override
  String get tamil => 'தமிழ்';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get languageChanged => 'மொழி வெற்றிகரமாக மாற்றப்பட்டது';

  @override
  String get demoAi => 'மாதிரி AI';

  @override
  String get liveApi => 'நேரடி API';

  @override
  String get aiConfigTitle => 'AI பகுப்பாய்வு கட்டமைப்பு';

  @override
  String get demoModeTitle => 'விளக்கக் காட்சி முறைமை';

  @override
  String get demoModeSubtitle =>
      'செயலில் உள்ள சேவையகம் இல்லாமல் உடனடி மாதிரி வெங்காயக் குவியல் பகுப்பாய்வு';

  @override
  String get fastApiEndpoint => 'FastAPI இறுதிப்புள்ளி URL:';

  @override
  String get fastApiHint =>
      'backend/ கோப்பகத்தில் \"python3 app/main.py\" இயக்கவும்';

  @override
  String get apply => 'பயன்படுத்து';

  @override
  String get cancel => 'ரத்து செய்';

  @override
  String get scanOrEnterBatchCode =>
      'தொகுதி QR / குறியீட்டை ஸ்கேன் செய்க அல்லது உள்ளிடுக';

  @override
  String get scanBatchInstruction =>
      'தொகுதி எண்ணை உள்ளிடவும் அல்லது சாக்கில் உள்ள QR குறியீட்டை ஸ்கேன் செய்யவும்:';

  @override
  String get findBatch => 'தொகுதியைக் கண்டுபிடி';

  @override
  String get batchSample => 'மாதிரி';

  @override
  String get analyzeHeapButton => 'வெங்காயக் குவியலை ஆய்வு செய்க';

  @override
  String get registerNewBatch => 'வெங்காயத் தொகுதியைப் பதிவு செய்க';

  @override
  String get registerBatchSubtitle =>
      'மண்டி கண்காணிப்புக்காக டிஜிட்டல் தொகுதி பதிவு மற்றும் தடமறியக்கூடிய QR குறியீடு உருவாக்கப்படும்.';

  @override
  String get farmerDetails => 'விவசாயி மற்றும் தொகுதி விவரங்கள்';

  @override
  String get farmerName => 'விவசாயி / வர்த்தகர் முழு பெயர்';

  @override
  String get enterFarmerName => 'விவசாயியின் முழு பெயரை உள்ளிடவும்';

  @override
  String get pleaseEnterFarmerName => 'விவசாயி பெயர் தேவை';

  @override
  String get phoneNumber => 'மொபைல் எண்';

  @override
  String get enterPhoneNumber => '10-இலக்க மொபைல் எண்';

  @override
  String get pleaseEnterPhone => 'தொடர்பு எண்ணை உள்ளிடவும்';

  @override
  String get pleaseEnterValidPhone => 'சரியான 10-இலக்க எண்ணை உள்ளிடவும்';

  @override
  String get mandiYard => 'மண்டி APMC வளாகம்';

  @override
  String get enterMandiYard => 'எ.கா. லாசல்கான், நாசிக் APMC';

  @override
  String get pleaseEnterMandi => 'மண்டி இருப்பிடத்தைக் குறிப்பிடவும்';

  @override
  String get lotSpecification => 'மண்டி மற்றும் பயிர் விவரக்குறிப்பு';

  @override
  String get onionVariety => 'வெங்காய ரகம்';

  @override
  String get harvestDate => 'அறுவடை தேதி';

  @override
  String get lotVolume => 'தொகுதி அளவு';

  @override
  String get weightQuintalsLabel => 'எடை (குவிண்டால்)';

  @override
  String get bagCountLabel => 'மூட்டை எண்ணிக்கை';

  @override
  String get estimatedBags => 'மதிப்பிடப்பட்ட மூட்டைகள்';

  @override
  String get enterBagCount => 'மூட்டைகளில் மொத்த அளவு';

  @override
  String get pleaseEnterBags => 'மூட்டை எண்ணிக்கையை உள்ளிடவும்';

  @override
  String get enterValidWeight => 'சரியான எடையை உள்ளிடவும்';

  @override
  String get approxWeightPerBag => 'ஒரு மூட்டையின் தோராய எடை (கிலோ)';

  @override
  String get storageCondition => 'சேமிப்பு நிலை';

  @override
  String get notesFieldObservations =>
      'குறிப்புகள் / கள அவதானிப்புகள் (விருப்பத்தேர்வு)';

  @override
  String get enterNotes =>
      'பதப்படுத்துதல், தோல் ஒட்டுதல் அல்லது அவதானிப்பு குறிப்புகளைச் சேர்க்கவும்...';

  @override
  String get registerLotButton => 'தொகுதியை உருவாக்கி QR பெறுக';

  @override
  String get batchCreatedSuccess => 'தொகுதி வெற்றிகரமாக பதிவு செய்யப்பட்டது';

  @override
  String get heapInspectionTitle => 'வெங்காயக் குவியலை ஆய்வு செய்க';

  @override
  String get heapInspectionSubtitle =>
      'தெளிவான மேல்நோக்கு குவியல் புகைப்படத்தைப் பிடிக்கவும் அல்லது தேர்ந்தெடுக்கவும்';

  @override
  String get inspectionTargetBatch => 'ஆய்வு இலக்கு தொகுதி';

  @override
  String get heapImageCapture => 'குவியல் படம் எடுத்தல்';

  @override
  String get heapImageInstructions =>
      'வெங்காயக் குவியலின் தடையற்ற மேல்/கோணக் காட்சியைப் படம் பிடிக்கவும் அல்லது பதிவேற்றவும்.';

  @override
  String get takePhoto => 'புகைப்படம் எடு';

  @override
  String get uploadFile => 'கோப்பைப் பதிவேற்று';

  @override
  String get chooseFromGallery => 'கேலரியில் இருந்து தேர்வு செய்';

  @override
  String get quickPresets => 'விரைவு மாதிரிகள்:';

  @override
  String get sampleNashikRed => 'லாசல்கான் சிவப்பு';

  @override
  String get sampleCommercialBulk => 'கர்வா கலவை';

  @override
  String get sampleFieldHarvest => 'முளைத்த/அழுகிய குவியல்';

  @override
  String get photoReady => 'மாதிரி வெங்காயக் குவியல் ஏற்றப்பட்டது';

  @override
  String get readyForAi => 'AI பார்வை பகுப்பாய்விற்கு தயார்';

  @override
  String get tapToChange => 'படத்தை மாற்ற மேலே தட்டவும்';

  @override
  String get inspectionParameters => 'ஆய்வு அளவுருக்கள்';

  @override
  String get inspectorNameLabel => 'ஆய்வாளர் பெயர்';

  @override
  String get inspectorIdLabel => 'ஆய்வாளர் எண்';

  @override
  String get sampleBagWeightLabel => 'மாதிரி மூட்டை எடை (கிலோ)';

  @override
  String get observationsNotesLabel => 'தொகுதி அவதானிப்புகள் / குறிப்புகள்';

  @override
  String get runAiAnalysis => 'AI குவியல் பிரிப்பு & தர நிர்ணயம் செய்க';

  @override
  String get stepReady => 'தயார்';

  @override
  String get stepUploading =>
      'பகுப்பாய்வு பைப்லைனுக்கு குவியல் படத்தை ஏற்றுகிறது...';

  @override
  String get stepExtracting => 'வெங்காய எல்லைகளைப் பிரிக்கிறது...';

  @override
  String get stepClassifying =>
      'குறைபாடுகளை வகைப்படுத்துகிறது: ஆரோக்கியமான, அழுகிய, முளைத்த, சேதமடைந்த...';

  @override
  String get stepFinalizing =>
      'AGMARK தரம் A/B/நிராகரிப்பு அளவீடுகளை இறுதி செய்கிறது...';

  @override
  String analysisFailed(String error) {
    return 'பகுப்பாய்வு தோல்வியடைந்தது: $error';
  }

  @override
  String get pleaseSelectImage =>
      'வெங்காயக் குவியல் படத்தைத் தேர்ந்தெடுக்கவும் அல்லது பிடிக்கவும்';

  @override
  String get bestPracticesTitle => 'ஆய்வு சிறந்த நடைமுறைகள்';

  @override
  String get tip1 =>
      'துல்லியமான மாதிரிக்கு மேல் அடுக்கை முழுமையாக சட்டகத்தில் வைக்கவும்';

  @override
  String get tip2 =>
      'சீரான வெளிச்சத்தை உறுதிப்படுத்தவும் (கடுமையான நிழல்களைத் தவிர்க்கவும்)';

  @override
  String get tip3 => 'குவியலை மூடும் குப்பைகள் அல்லது சாக்குகளை அகற்றவும்';

  @override
  String get heapQualityResults => 'குவியல் தர மதிப்பீட்டு முடிவுகள்';

  @override
  String assignedLotGrade(String grade) {
    return 'ஒதுக்கப்பட்ட தொகுதி தரம்: $grade';
  }

  @override
  String bulbsVisible(int count) {
    return '$count வெங்காயங்கள் தெரிகின்றன';
  }

  @override
  String confidencePercent(String value) {
    return '$value% நம்பிக்கை';
  }

  @override
  String latencyMs(int ms) {
    return '$ms மி.வி';
  }

  @override
  String get instanceSegmentation => 'வெங்காயப் பிரிவு மேலடுக்கு';

  @override
  String get tapBulbHint =>
      'விட்டம், குறைபாடு வகை மற்றும் நம்பிக்கை மதிப்பெண்ணைக் காண ஏதேனும் வெங்காயத்தைத் தட்டவும்.';

  @override
  String get prototypeEngine => 'மாதிரி பகுப்பாய்வு இன்ஜின்';

  @override
  String get fineTunedEngine => 'பயிற்சி பெற்ற YOLO11-Seg';

  @override
  String visionWarnings(int count) {
    return 'பார்வை தர எச்சரிக்கைகள் ($count)';
  }

  @override
  String get generatePdfReport => 'டிஜிட்டல் PDF அறிக்கையை உருவாக்கு';

  @override
  String get saveAndCertify => 'தொகுதியைச் சேமித்து சான்றளி';

  @override
  String inspectionSavedSuccessWithGrade(String grade) {
    return 'ஆய்வு சேமிக்கப்பட்டது! தொகுதி $grade என சான்றளிக்கப்பட்டது.';
  }

  @override
  String get polygonsLabel => 'பலகோணங்கள்';

  @override
  String get boxesLabel => 'பெட்டிகள்';

  @override
  String get labelsLabel => 'லேபிள்கள்';

  @override
  String get allDefects => 'அனைத்து குறைபாடுகளும்';

  @override
  String get filterDefectAll => 'குறைபாடு வடிகட்டி: அனைத்தும்';

  @override
  String bulbDetailText(int id, String defect) {
    return 'வெங்காயம் #$id: $defect';
  }

  @override
  String bulbMetaInfo(String grade, String diameter, String confidence) {
    return 'தரம்: $grade • தோராய விட்டம்: $diameter மிமீ • நம்பிக்கை: $confidence%';
  }

  @override
  String get digitalGradeDistribution => 'டிஜிட்டல் தர விநியோகம்';

  @override
  String get gradeAExport => 'தரம் A (ஏற்றுமதி)';

  @override
  String get gradeBLocal => 'தரம் B (உள்ளூர்)';

  @override
  String get rejectWaste => 'நிராகரிப்பு / கழிவு';

  @override
  String get targetGradeA => 'இலக்கு >= 70%';

  @override
  String get minorDefects => 'சிறிய குறைபாடுகள்';

  @override
  String get rotSprout => 'அழுகல் / முளைப்பு';

  @override
  String get defectBreakdown => 'காணக்கூடிய குறைபாடுகளின் விவரம்';

  @override
  String get disclaimerTitle => 'காணக்கூடிய மேற்பரப்பு மதிப்பீட்டு வரம்பு';

  @override
  String get disclaimerText =>
      'மேற்பரப்பு பார்வை பகுப்பாய்வு காணக்கூடிய மேல் அடுக்கு தரத்தை மதிப்பிடுகிறது. ஆழமான குவியல்களுக்கு உடல் மாதிரி பரிசோதனை பரிந்துரைக்கப்படுகிறது.';

  @override
  String get qualityHealthy => 'ஆரோக்கியமான';

  @override
  String get qualityDamaged => 'சேதமடைந்த';

  @override
  String get qualityRotten => 'அழுகிய';

  @override
  String get qualitySprouted => 'முளைத்த';

  @override
  String get qualityUndersized => 'சிறிய அளவு';

  @override
  String get qualityUnknown => 'தெரியாது';

  @override
  String get gradeA => 'தரம் A';

  @override
  String get gradeB => 'தரம் B';

  @override
  String get gradeC => 'நிராகரிப்பு';

  @override
  String get batchDetails => 'தொகுதி விவரங்கள்';

  @override
  String get analyzeHeapForBatch => 'இந்தத் தொகுதிக்கு குவியல் ஆய்வு செய்க';

  @override
  String get completedInspections => 'நிறைவு செய்யப்பட்ட தர ஆய்வுகள்';

  @override
  String get noInspectionsYet =>
      'இந்தத் தொகுதிக்கு இன்னும் எந்த ஆய்வும் பதிவு செய்யப்படவில்லை.\nஸ்கேன் செய்ய \"வெங்காயக் குவியலை ஆய்வு செய்க\" என்பதைத் தட்டவும்.';

  @override
  String get viewPdf => 'PDF ஐக் காண்க';

  @override
  String inspectionTitle(String grade) {
    return 'ஆய்வு: $grade';
  }

  @override
  String get verifyCertificateTitle => 'e-NAM தரச் சான்றிதழ் சரிபார்ப்பு';

  @override
  String get publicVerification => 'பொது சான்றிதழ் சரிபார்ப்பு';

  @override
  String get verifySubtitle =>
      'தர நிர்ணய நம்பகத்தன்மை மற்றும் மாற்ற முடியாத பதிவுகளை உறுதிப்படுத்த QR குறியீட்டின் கீழ் அச்சிடப்பட்ட சரிபார்ப்பு டோக்கனை உள்ளிடவும்.';

  @override
  String get verifyButton => 'சரிபார்';

  @override
  String get authenticCertificate => 'உண்மையான தரச் சான்றிதழ்';

  @override
  String get recordNotFound => 'சான்றிதழ் பதிவு கிடைக்கவில்லை';

  @override
  String recordNotFoundMsg(String query) {
    return '\"$query\" என்ற சரிபார்ப்பு டோக்கன் அங்கீகரிக்கப்பட்ட மண்டி தரவுத்தளத்தில் கிடைக்கவில்லை.';
  }

  @override
  String tokenLabel(String token) {
    return 'டோக்கன்: $token';
  }

  @override
  String get batchNumberLabel => 'தொகுதி எண்';

  @override
  String get certifiedInspector => 'சான்றளிக்கப்பட்ட ஆய்வாளர்';

  @override
  String get inspectionTimestamp => 'ஆய்வு நேரம்';

  @override
  String get visibleSampleCount => 'ஸ்கேன் செய்யப்பட்ட மாதிரிகள்';

  @override
  String get gradeARatio => 'தரம் A விகிதம்';

  @override
  String get gradeBRatio => 'தரம் B விகிதம்';

  @override
  String get rejectionRate => 'நிராகரிப்பு விகிதம்';

  @override
  String get modelConfidence => 'மாதிரி நம்பிக்கை';

  @override
  String bulbsScannedCount(int count) {
    return '$count வெங்காயங்கள் ஸ்கேன் செய்யப்பட்டன';
  }

  @override
  String get digitalCertificate => 'டிஜிட்டல் தரச் சான்றிதழ்';

  @override
  String get shareCertificate => 'சான்றிதழைப் பகிர்';

  @override
  String verificationRibbon(String token, String inspector) {
    return 'சரிபார்ப்பு டோக்கன்: $token • கையொப்பமிட்டவர்: $inspector';
  }

  @override
  String get certTitle => 'ONIONSURE டிஜிட்டல் தரச் சான்றிதழ்';

  @override
  String get certSub =>
      'SIH26031: AI அடிப்படையிலான ஸ்மார்ட் வெங்காயத் தொகுதி தரம்';

  @override
  String get certMandiRecord => 'அங்கீகரிக்கப்பட்ட மண்டி APMC ஆய்வு பதிவு';

  @override
  String get certBatchRegistration => 'தொகுதி மற்றும் பதிவு விவரங்கள்';

  @override
  String get certInspectionDate => 'ஆய்வு தேதி';

  @override
  String get certFarmerOwner => 'விவசாயி / உரிமையாளர்';

  @override
  String get certMandiYard => 'மண்டி வளாகம்';

  @override
  String get certVariety => 'வெங்காய ரகம்';

  @override
  String get certTotalWeight => 'மொத்த எடை';

  @override
  String get certAssignedInspector => 'நியமிக்கப்பட்ட ஆய்வாளர்';

  @override
  String get certVerificationToken => 'சரிபார்ப்பு டோக்கன்';

  @override
  String get certGradingSection =>
      'குவியல் பிரிவு மற்றும் டிஜிட்டல் தர நிர்ணயம்';

  @override
  String get certMetric => 'அளவீடு';

  @override
  String get certComputedValue => 'கணக்கிடப்பட்ட மதிப்பு';

  @override
  String get certGradingSpec => 'தரநிலை விவரக்குறிப்பு';

  @override
  String get certVisibleScanned => 'ஸ்கேன் செய்யப்பட்ட வெங்காயங்கள்';

  @override
  String certVisibleBulbs(int count) {
    return '$count வெங்காயங்கள்';
  }

  @override
  String get certSurfaceExtraction => 'மேற்பரப்பு எல்லை பிரித்தெடுத்தல்';

  @override
  String get certGradeARatio => 'தரம் A தர விகிதம்';

  @override
  String get certGradeASpec => 'தரநிலை: தரம் A சான்றிதழுக்கு >= 70%';

  @override
  String get certGradeBRatio => 'தரம் B நியாயமான விகிதம்';

  @override
  String get certGradeBSpec => 'அனுமதிக்கப்பட்ட சிறிய தோல் குறைபாடுகள்';

  @override
  String get certRejectRatio => 'நிராகரிப்பு / கழிவு விகிதம்';

  @override
  String get certRejectSpec =>
      'அழுகல், முளைப்பு > 5% வர்த்தகத்தைக் கட்டுப்படுத்துகிறது';

  @override
  String get certConfidenceScore => 'மாதிரி நம்பிக்கை மதிப்பெண்';

  @override
  String get certMultiContour => 'பல விளிம்பு சரிபார்ப்பு';

  @override
  String get certDefectBreakdown => 'குறைபாடு வகைப்பாடு விவரம்';

  @override
  String get certDisclaimerHeader =>
      'முக்கியமான மதிப்பீட்டு வரம்பு மற்றும் மண்டி மறுப்பு';

  @override
  String get certScanQr => 'e-NAM தளத்தில் சரிபார்க்க QR ஐ ஸ்கேன் செய்க';

  @override
  String get certGraderSignature => 'அங்கீகரிக்கப்பட்ட தர ஆய்வாளர் கையொப்பம்';

  @override
  String certDate(String date) {
    return 'தேதி: $date';
  }
}
