// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'OnionSure';

  @override
  String get dashboardTitle => 'मंडी गुणवत्ता निगरानी डैशबोर्ड';

  @override
  String get enamReady => 'e-NAM एकीकरण तैयार';

  @override
  String get dashboardSubtitle =>
      'APMC केंद्रीय यार्ड - लाइव AI गुणवत्ता ग्रेडिंग और ट्रेसबिलिटी';

  @override
  String get totalBatches => 'कुल लॉट';

  @override
  String get inspected => 'जांचा गया';

  @override
  String get avgGradeA => 'औसत ग्रेड A';

  @override
  String get totalVolume => 'कुल मात्रा';

  @override
  String volumeQuintals(String weight) {
    return '$weight क्विंटल';
  }

  @override
  String get bagsUnit => 'बोरियां';

  @override
  String get bags => 'बोरियां';

  @override
  String get newBatch => 'लॉट पंजीकरण';

  @override
  String get inspectHeap => 'ढेर जांचें';

  @override
  String get scanQr => 'QR स्कैन करें';

  @override
  String get verifyCert => 'प्रमाणपत्र जांचें';

  @override
  String get mandiLots => 'पंजीकृत प्याज लॉट';

  @override
  String get searchHint => 'लॉट संख्या, किसान या मंडी खोजें...';

  @override
  String get filterAll => 'सभी';

  @override
  String get filterPending => 'लंबित';

  @override
  String get filterInspected => 'जांचा गया';

  @override
  String get filterCertified => 'प्रमाणित';

  @override
  String get filterRejected => 'अस्वीकृत';

  @override
  String get noBatchesFound => 'कोई लॉट नहीं मिला';

  @override
  String noBatchesFoundFor(String filter) {
    return '\"$filter\" के लिए कोई लॉट नहीं मिला';
  }

  @override
  String get noBatchesSub => 'शुरू करने के लिए नया लॉट बनाएं या फ़िल्टर बदलें।';

  @override
  String get clearFilter => 'फ़िल्टर हटाएं';

  @override
  String get varietyLabel => 'किस्म:';

  @override
  String get volumeLabel => 'मात्रा:';

  @override
  String get qualityScoreLabel => 'गुणवत्ता स्कोर:';

  @override
  String get createdLabel => 'बनाया गया:';

  @override
  String get statusPending => 'लंबित';

  @override
  String get statusInspected => 'जांचा गया';

  @override
  String get statusCertified => 'प्रमाणित';

  @override
  String get statusRejected => 'अस्वीकृत';

  @override
  String get selectLanguage => 'भाषा चुनें';

  @override
  String get english => 'English';

  @override
  String get tamil => 'தமிழ்';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get languageChanged => 'भाषा सफलतापूर्वक बदल दी गई';

  @override
  String get demoAi => 'डेमो AI';

  @override
  String get liveApi => 'लाइव API';

  @override
  String get aiConfigTitle => 'AI अनुमान विन्यास';

  @override
  String get demoModeTitle => 'डेमो प्रस्तुति मोड';

  @override
  String get demoModeSubtitle =>
      'सक्रिय बैकएंड सर्वर के बिना त्वरित सिम्युलेटेड प्याज ढेर ग्रेडिंग';

  @override
  String get fastApiEndpoint => 'FastAPI एंडपॉइंट URL:';

  @override
  String get fastApiHint =>
      'backend/ डायरेक्टरी में \"python3 app/main.py\" चलाएं';

  @override
  String get apply => 'लागू करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get scanOrEnterBatchCode => 'लॉट QR / कोड स्कैन या दर्ज करें';

  @override
  String get scanBatchInstruction =>
      'लॉट नंबर दर्ज करें या बोरी पर QR कोड स्कैन करें:';

  @override
  String get findBatch => 'लॉट खोजें';

  @override
  String get batchSample => 'नमूना';

  @override
  String get analyzeHeapButton => 'प्याज के ढेर का विश्लेषण करें';

  @override
  String get registerNewBatch => 'प्याज लॉट पंजीकृत करें';

  @override
  String get registerBatchSubtitle =>
      'मंडी ट्रैकिंग के लिए डिजिटल लॉट रिकॉर्ड और पता लगाने योग्य QR कोड उत्पन्न होगा।';

  @override
  String get farmerDetails => 'किसान और लॉट विवरण';

  @override
  String get farmerName => 'किसान / व्यापारी का पूरा नाम';

  @override
  String get enterFarmerName => 'किसान का पूरा नाम दर्ज करें';

  @override
  String get pleaseEnterFarmerName => 'किसान का नाम आवश्यक है';

  @override
  String get phoneNumber => 'मोबाइल नंबर';

  @override
  String get enterPhoneNumber => '10 अंकों का मोबाइल नंबर';

  @override
  String get pleaseEnterPhone => 'कृपया संपर्क नंबर दर्ज करें';

  @override
  String get pleaseEnterValidPhone => 'कृपया 10 अंकों का वैध नंबर दर्ज करें';

  @override
  String get mandiYard => 'मंडी APMC यार्ड';

  @override
  String get enterMandiYard => 'उदा. लासलगांव, नासिक APMC';

  @override
  String get pleaseEnterMandi => 'कृपया मंडी स्थान निर्दिष्ट करें';

  @override
  String get lotSpecification => 'मंडी और फसल विनिर्देश';

  @override
  String get onionVariety => 'प्याज की किस्म';

  @override
  String get harvestDate => 'कटाई की तारीख';

  @override
  String get lotVolume => 'लॉट मात्रा';

  @override
  String get weightQuintalsLabel => 'वजन (क्विंटल)';

  @override
  String get bagCountLabel => 'बोरी संख्या';

  @override
  String get estimatedBags => 'अनुमानित बोरियां';

  @override
  String get enterBagCount => 'बोरियों में कुल मात्रा';

  @override
  String get pleaseEnterBags => 'कृपया बोरियों की संख्या दर्ज करें';

  @override
  String get enterValidWeight => 'वैध वजन दर्ज करें';

  @override
  String get approxWeightPerBag => 'प्रति बोरी अनुमानित वजन (किग्रा)';

  @override
  String get storageCondition => 'भंडारण स्थिति';

  @override
  String get notesFieldObservations => 'टिप्पणियां / फील्ड अवलोकन (वैकल्पिक)';

  @override
  String get enterNotes => 'सुखाने, छिलके या अवलोकन पर कोई टिप्पणी जोड़ें...';

  @override
  String get registerLotButton => 'लॉट बनाएं और QR जनरेट करें';

  @override
  String get batchCreatedSuccess => 'लॉट सफलतापूर्वक पंजीकृत हुआ';

  @override
  String get heapInspectionTitle => 'प्याज के ढेर का विश्लेषण करें';

  @override
  String get heapInspectionSubtitle =>
      'ढेर की स्पष्ट ऊपरी/कोणीय तस्वीर लें या चुनें';

  @override
  String get inspectionTargetBatch => 'जांच लक्ष्य लॉट';

  @override
  String get heapImageCapture => 'ढेर छवि कैप्चर';

  @override
  String get heapImageInstructions =>
      'प्याज के ढेर की स्पष्ट ऊपरी/कोणीय तस्वीर लें या अपलोड करें।';

  @override
  String get takePhoto => 'फोटो लें';

  @override
  String get uploadFile => 'फ़ाइल अपलोड करें';

  @override
  String get chooseFromGallery => 'गैलरी से चुनें';

  @override
  String get quickPresets => 'त्वरित नमूने:';

  @override
  String get sampleNashikRed => 'लासलगांव लाल';

  @override
  String get sampleCommercialBulk => 'गरवा मिक्स';

  @override
  String get sampleFieldHarvest => 'अंकुरित/सड़ा ढेर';

  @override
  String get photoReady => 'नमूना प्याज ढेर लोड किया गया';

  @override
  String get readyForAi => 'AI कंप्यूटर विजन के लिए तैयार';

  @override
  String get tapToChange => 'छवि बदलने के लिए ऊपर टैप करें';

  @override
  String get inspectionParameters => 'निरीक्षण पैरामीटर';

  @override
  String get inspectorNameLabel => 'निरीक्षक का नाम';

  @override
  String get inspectorIdLabel => 'निरीक्षक आईडी';

  @override
  String get sampleBagWeightLabel => 'नमूना बोरी वजन (किग्रा)';

  @override
  String get observationsNotesLabel => 'लॉट अवलोकन / टिप्पणियां';

  @override
  String get runAiAnalysis => 'AI ढेर विभाजन और ग्रेडिंग चलाएं';

  @override
  String get stepReady => 'तैयार';

  @override
  String get stepUploading => 'पाइपलाइन में ढेर छवि अपलोड हो रही है...';

  @override
  String get stepExtracting => 'प्याज की सीमाओं को पहचाना जा रहा है...';

  @override
  String get stepClassifying =>
      'दोषों का वर्गीकरण: स्वस्थ, सड़ा हुआ, अंकुरित, क्षतिग्रस्त...';

  @override
  String get stepFinalizing =>
      'AGMARK ग्रेड A/B/अस्वीकृत मेट्रिक्स तैयार हो रहे हैं...';

  @override
  String analysisFailed(String error) {
    return 'विश्लेषण विफल रहा: $error';
  }

  @override
  String get pleaseSelectImage => 'कृपया प्याज के ढेर की छवि चुनें या लें';

  @override
  String get bestPracticesTitle => 'निरीक्षण के सर्वोत्तम तरीके';

  @override
  String get tip1 => 'सटीक नमूने के लिए पूरी ऊपरी परत को फ्रेम में रखें';

  @override
  String get tip2 => 'समान रोशनी सुनिश्चित करें (कठोर छाया से बचें)';

  @override
  String get tip3 => 'ढेर को ढकने वाले मलबे या बोरी को हटा दें';

  @override
  String get heapQualityResults => 'ढेर गुणवत्ता अनुमान परिणाम';

  @override
  String assignedLotGrade(String grade) {
    return 'सौंपा गया लॉट ग्रेड: $grade';
  }

  @override
  String bulbsVisible(int count) {
    return '$count प्याज दिखाई दे रहे हैं';
  }

  @override
  String confidencePercent(String value) {
    return '$value% विश्वास';
  }

  @override
  String latencyMs(int ms) {
    return '$ms मि.से';
  }

  @override
  String get instanceSegmentation => 'प्याज इंस्टेंस सेगमेंटेशन ओवरले';

  @override
  String get tapBulbHint =>
      'व्यास, दोष प्रकार और विश्वास स्कोर देखने के लिए किसी भी प्याज पर टैप करें।';

  @override
  String get prototypeEngine => 'प्रोटोटाइप अनुमान इंजन';

  @override
  String get fineTunedEngine => 'प्रशिक्षित YOLO11-Seg';

  @override
  String visionWarnings(int count) {
    return 'विजन गुणवत्ता चेतावनियां ($count)';
  }

  @override
  String get generatePdfReport => 'डिजिटल PDF रिपोर्ट तैयार करें';

  @override
  String get saveAndCertify => 'लॉट सहेजें और प्रमाणित करें';

  @override
  String inspectionSavedSuccessWithGrade(String grade) {
    return 'निरीक्षण सहेजा गया! लॉट को $grade प्रमाणित किया गया।';
  }

  @override
  String get polygonsLabel => 'बहुभुज';

  @override
  String get boxesLabel => 'बॉक्स';

  @override
  String get labelsLabel => 'लेबल';

  @override
  String get allDefects => 'सभी दोष';

  @override
  String get filterDefectAll => 'दोष फ़िल्टर: सभी';

  @override
  String bulbDetailText(int id, String defect) {
    return 'प्याज #$id: $defect';
  }

  @override
  String bulbMetaInfo(String grade, String diameter, String confidence) {
    return 'ग्रेड: $grade • अनुमानित व्यास: $diameter मिमी • विश्वास: $confidence%';
  }

  @override
  String get digitalGradeDistribution => 'डिजिटल गुणवत्ता ग्रेड वितरण';

  @override
  String get gradeAExport => 'ग्रेड A (निर्यात)';

  @override
  String get gradeBLocal => 'ग्रेड B (स्थानीय)';

  @override
  String get rejectWaste => 'अस्वीकृत / कचरा';

  @override
  String get targetGradeA => 'लक्ष्य >= 70%';

  @override
  String get minorDefects => 'मामूली दोष';

  @override
  String get rotSprout => 'सड़न / अंकुरण';

  @override
  String get defectBreakdown => 'दृश्यमान दोष विवरण';

  @override
  String get disclaimerTitle => 'दृश्यमान सतह अनुमान सीमा';

  @override
  String get disclaimerText =>
      'सतह विजन विश्लेषण दिखाई देने वाली शीर्ष-परत गुणवत्ता का अनुमान लगाता है। गहरे लॉट के लिए भौतिक नमूनाकरण की सिफारिश की जाती है।';

  @override
  String get qualityHealthy => 'स्वस्थ';

  @override
  String get qualityDamaged => 'क्षतिग्रस्त';

  @override
  String get qualityRotten => 'सड़ा हुआ';

  @override
  String get qualitySprouted => 'अंकुरित';

  @override
  String get qualityUndersized => 'छोटा आकार';

  @override
  String get qualityUnknown => 'अज्ञात';

  @override
  String get gradeA => 'ग्रेड A';

  @override
  String get gradeB => 'ग्रेड B';

  @override
  String get gradeC => 'अस्वीकृत';

  @override
  String get batchDetails => 'लॉट विवरण';

  @override
  String get analyzeHeapForBatch => 'इस लॉट के लिए प्याज ढेर का विश्लेषण करें';

  @override
  String get completedInspections => 'पूर्ण गुणवत्ता निरीक्षण';

  @override
  String get noInspectionsYet =>
      'इस लॉट के लिए अभी कोई निरीक्षण दर्ज नहीं है।\nस्कैन करने के लिए \"प्याज के ढेर का विश्लेषण करें\" पर क्लिक करें।';

  @override
  String get viewPdf => 'PDF देखें';

  @override
  String inspectionTitle(String grade) {
    return 'निरीक्षण: $grade';
  }

  @override
  String get verifyCertificateTitle => 'e-NAM गुणवत्ता प्रमाणपत्र सत्यापन';

  @override
  String get publicVerification => 'सार्वजनिक प्रमाणपत्र सत्यापन';

  @override
  String get verifySubtitle =>
      'ग्रेडिंग की प्रामाणिकता और अपरिवर्तनीय रिकॉर्ड की पुष्टि के लिए QR कोड के नीचे छपा सत्यापन टोकन दर्ज करें।';

  @override
  String get verifyButton => 'सत्यापित करें';

  @override
  String get authenticCertificate => 'प्रामाणिक गुणवत्ता प्रमाणपत्र';

  @override
  String get recordNotFound => 'प्रमाणपत्र रिकॉर्ड नहीं मिला';

  @override
  String recordNotFoundMsg(String query) {
    return 'सत्यापन टोकन \"$query\" प्रमाणित मंडी डेटाबेस में नहीं मिला।';
  }

  @override
  String tokenLabel(String token) {
    return 'टोकन: $token';
  }

  @override
  String get batchNumberLabel => 'लॉट नंबर';

  @override
  String get certifiedInspector => 'प्रमाणित निरीक्षक';

  @override
  String get inspectionTimestamp => 'निरीक्षण समय';

  @override
  String get visibleSampleCount => 'स्कैन किए गए नमूने';

  @override
  String get gradeARatio => 'ग्रेड A अनुपात';

  @override
  String get gradeBRatio => 'ग्रेड B अनुपात';

  @override
  String get rejectionRate => 'अस्वीकृति दर';

  @override
  String get modelConfidence => 'मॉडल विश्वास';

  @override
  String bulbsScannedCount(int count) {
    return '$count प्याज स्कैन किए गए';
  }

  @override
  String get digitalCertificate => 'डिजिटल गुणवत्ता प्रमाणपत्र';

  @override
  String get shareCertificate => 'प्रमाणपत्र साझा करें';

  @override
  String verificationRibbon(String token, String inspector) {
    return 'सत्यापन टोकन: $token • हस्ताक्षरकर्ता: $inspector';
  }

  @override
  String get certTitle => 'ONIONSURE डिजिटल गुणवत्ता प्रमाणपत्र';

  @override
  String get certSub => 'SIH26031: AI आधारित स्मार्ट प्याज लॉट ग्रेडिंग';

  @override
  String get certMandiRecord => 'मान्यता प्राप्त मंडी APMC निरीक्षण रिकॉर्ड';

  @override
  String get certBatchRegistration => 'लॉट और पंजीकरण विवरण';

  @override
  String get certInspectionDate => 'निरीक्षण तिथि';

  @override
  String get certFarmerOwner => 'किसान / लॉट मालिक';

  @override
  String get certMandiYard => 'मंडी यार्ड';

  @override
  String get certVariety => 'प्याज की किस्म';

  @override
  String get certTotalWeight => 'कुल वजन';

  @override
  String get certAssignedInspector => 'सौंपा गया निरीक्षक';

  @override
  String get certVerificationToken => 'सत्यापन टोकन';

  @override
  String get certGradingSection => 'ढेर विभाजन और डिजिटल ग्रेडिंग';

  @override
  String get certMetric => 'मेट्रिक';

  @override
  String get certComputedValue => 'गणना किया गया मान';

  @override
  String get certGradingSpec => 'ग्रेडिंग मानक विनिर्देश';

  @override
  String get certVisibleScanned => 'स्कैन किए गए प्याज';

  @override
  String certVisibleBulbs(int count) {
    return '$count प्याज';
  }

  @override
  String get certSurfaceExtraction => 'सतह सीमा निष्कर्षण';

  @override
  String get certGradeARatio => 'ग्रेड A गुणवत्ता अनुपात';

  @override
  String get certGradeASpec => 'मानक: ग्रेड A प्रमाणन के लिए >= 70%';

  @override
  String get certGradeBRatio => 'ग्रेड B उचित अनुपात';

  @override
  String get certGradeBSpec => 'स्वीकार्य मामूली त्वचा दोष / आकार भिन्नता';

  @override
  String get certRejectRatio => 'अस्वीकृति / अपशिष्ट अनुपात';

  @override
  String get certRejectSpec =>
      'सड़न, अंकुरण > 5% व्यापार को प्रतिबंधित करता है';

  @override
  String get certConfidenceScore => 'मॉडल विश्वास स्कोर';

  @override
  String get certMultiContour => 'मल्टी-समोच्च सत्यापन';

  @override
  String get certDefectBreakdown => 'दोष वर्गीकरण विवरण';

  @override
  String get certDisclaimerHeader => 'महत्वपूर्ण अनुमान सीमा और मंडी अस्वीकरण';

  @override
  String get certScanQr => 'e-NAM पोर्टल पर सत्यापित करने के लिए QR स्कैन करें';

  @override
  String get certGraderSignature => 'अधिकृत गुणवत्ता निरीक्षक हस्ताक्षर';

  @override
  String certDate(String date) {
    return 'तिथि: $date';
  }
}
