import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('ta'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'OnionSure'**
  String get appName;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Mandi Quality Monitoring Dashboard'**
  String get dashboardTitle;

  /// No description provided for @enamReady.
  ///
  /// In en, this message translates to:
  /// **'e-NAM Integration Ready'**
  String get enamReady;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'APMC Central Yard - Live AI Quality Grading & Traceability'**
  String get dashboardSubtitle;

  /// No description provided for @totalBatches.
  ///
  /// In en, this message translates to:
  /// **'Total Batches'**
  String get totalBatches;

  /// No description provided for @inspected.
  ///
  /// In en, this message translates to:
  /// **'Inspected'**
  String get inspected;

  /// No description provided for @avgGradeA.
  ///
  /// In en, this message translates to:
  /// **'Avg Grade A'**
  String get avgGradeA;

  /// No description provided for @totalVolume.
  ///
  /// In en, this message translates to:
  /// **'Total Volume'**
  String get totalVolume;

  /// No description provided for @volumeQuintals.
  ///
  /// In en, this message translates to:
  /// **'{weight} Qtl'**
  String volumeQuintals(String weight);

  /// No description provided for @bagsUnit.
  ///
  /// In en, this message translates to:
  /// **'Bags'**
  String get bagsUnit;

  /// No description provided for @bags.
  ///
  /// In en, this message translates to:
  /// **'bags'**
  String get bags;

  /// No description provided for @newBatch.
  ///
  /// In en, this message translates to:
  /// **'Register Batch'**
  String get newBatch;

  /// No description provided for @inspectHeap.
  ///
  /// In en, this message translates to:
  /// **'Inspect Heap'**
  String get inspectHeap;

  /// No description provided for @scanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQr;

  /// No description provided for @verifyCert.
  ///
  /// In en, this message translates to:
  /// **'Verify Certificate'**
  String get verifyCert;

  /// No description provided for @mandiLots.
  ///
  /// In en, this message translates to:
  /// **'Registered Onion Batches'**
  String get mandiLots;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search batch #, farmer, or mandi...'**
  String get searchHint;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get filterPending;

  /// No description provided for @filterInspected.
  ///
  /// In en, this message translates to:
  /// **'Inspected'**
  String get filterInspected;

  /// No description provided for @filterCertified.
  ///
  /// In en, this message translates to:
  /// **'Certified'**
  String get filterCertified;

  /// No description provided for @filterRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get filterRejected;

  /// No description provided for @noBatchesFound.
  ///
  /// In en, this message translates to:
  /// **'No batches found'**
  String get noBatchesFound;

  /// No description provided for @noBatchesFoundFor.
  ///
  /// In en, this message translates to:
  /// **'No batches found for \"{filter}\"'**
  String noBatchesFoundFor(String filter);

  /// No description provided for @noBatchesSub.
  ///
  /// In en, this message translates to:
  /// **'Create a new batch or adjust your search filter to get started.'**
  String get noBatchesSub;

  /// No description provided for @clearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear Filter'**
  String get clearFilter;

  /// No description provided for @varietyLabel.
  ///
  /// In en, this message translates to:
  /// **'Variety:'**
  String get varietyLabel;

  /// No description provided for @volumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Volume:'**
  String get volumeLabel;

  /// No description provided for @qualityScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Quality Score:'**
  String get qualityScoreLabel;

  /// No description provided for @createdLabel.
  ///
  /// In en, this message translates to:
  /// **'Created:'**
  String get createdLabel;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusInspected.
  ///
  /// In en, this message translates to:
  /// **'Inspected'**
  String get statusInspected;

  /// No description provided for @statusCertified.
  ///
  /// In en, this message translates to:
  /// **'Certified'**
  String get statusCertified;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'தமிழ்'**
  String get tamil;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get hindi;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChanged;

  /// No description provided for @demoAi.
  ///
  /// In en, this message translates to:
  /// **'Demo AI'**
  String get demoAi;

  /// No description provided for @liveApi.
  ///
  /// In en, this message translates to:
  /// **'Live API'**
  String get liveApi;

  /// No description provided for @aiConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Inference Configuration'**
  String get aiConfigTitle;

  /// No description provided for @demoModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Demo Presentation Mode'**
  String get demoModeTitle;

  /// No description provided for @demoModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Instant simulated onion heap inference without active backend server'**
  String get demoModeSubtitle;

  /// No description provided for @fastApiEndpoint.
  ///
  /// In en, this message translates to:
  /// **'FastAPI Endpoint URL:'**
  String get fastApiEndpoint;

  /// No description provided for @fastApiHint.
  ///
  /// In en, this message translates to:
  /// **'Run \"python3 app/main.py\" in backend/ directory'**
  String get fastApiHint;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @scanOrEnterBatchCode.
  ///
  /// In en, this message translates to:
  /// **'Scan or Enter Batch QR / Code'**
  String get scanOrEnterBatchCode;

  /// No description provided for @scanBatchInstruction.
  ///
  /// In en, this message translates to:
  /// **'Enter a Batch Number or scan QR code on the farmer lot bag:'**
  String get scanBatchInstruction;

  /// No description provided for @findBatch.
  ///
  /// In en, this message translates to:
  /// **'Find Batch'**
  String get findBatch;

  /// No description provided for @batchSample.
  ///
  /// In en, this message translates to:
  /// **'Sample'**
  String get batchSample;

  /// No description provided for @analyzeHeapButton.
  ///
  /// In en, this message translates to:
  /// **'Analyze Onion Heap'**
  String get analyzeHeapButton;

  /// No description provided for @registerNewBatch.
  ///
  /// In en, this message translates to:
  /// **'Register Onion Batch'**
  String get registerNewBatch;

  /// No description provided for @registerBatchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Assign a digital batch record to the onion arrival. A traceable QR code will be generated for mandi tracking.'**
  String get registerBatchSubtitle;

  /// No description provided for @farmerDetails.
  ///
  /// In en, this message translates to:
  /// **'Farmer & Lot Information'**
  String get farmerDetails;

  /// No description provided for @farmerName.
  ///
  /// In en, this message translates to:
  /// **'Farmer / Trader Full Name'**
  String get farmerName;

  /// No description provided for @enterFarmerName.
  ///
  /// In en, this message translates to:
  /// **'Enter farmer full name'**
  String get enterFarmerName;

  /// No description provided for @pleaseEnterFarmerName.
  ///
  /// In en, this message translates to:
  /// **'Farmer name is required'**
  String get pleaseEnterFarmerName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get phoneNumber;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'10-digit mobile number'**
  String get enterPhoneNumber;

  /// No description provided for @pleaseEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter contact number'**
  String get pleaseEnterPhone;

  /// No description provided for @pleaseEnterValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid 10-digit number'**
  String get pleaseEnterValidPhone;

  /// No description provided for @mandiYard.
  ///
  /// In en, this message translates to:
  /// **'Mandi APMC Yard'**
  String get mandiYard;

  /// No description provided for @enterMandiYard.
  ///
  /// In en, this message translates to:
  /// **'e.g. Lasalgaon, Nashik APMC'**
  String get enterMandiYard;

  /// No description provided for @pleaseEnterMandi.
  ///
  /// In en, this message translates to:
  /// **'Please specify mandi location'**
  String get pleaseEnterMandi;

  /// No description provided for @lotSpecification.
  ///
  /// In en, this message translates to:
  /// **'Mandi & Crop Specification'**
  String get lotSpecification;

  /// No description provided for @onionVariety.
  ///
  /// In en, this message translates to:
  /// **'Onion Variety'**
  String get onionVariety;

  /// No description provided for @harvestDate.
  ///
  /// In en, this message translates to:
  /// **'Harvest Date'**
  String get harvestDate;

  /// No description provided for @lotVolume.
  ///
  /// In en, this message translates to:
  /// **'Lot Volume'**
  String get lotVolume;

  /// No description provided for @weightQuintalsLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (Quintals)'**
  String get weightQuintalsLabel;

  /// No description provided for @bagCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Bag Count'**
  String get bagCountLabel;

  /// No description provided for @estimatedBags.
  ///
  /// In en, this message translates to:
  /// **'Estimated Bags / Crates'**
  String get estimatedBags;

  /// No description provided for @enterBagCount.
  ///
  /// In en, this message translates to:
  /// **'Total quantity in bags'**
  String get enterBagCount;

  /// No description provided for @pleaseEnterBags.
  ///
  /// In en, this message translates to:
  /// **'Enter bag count'**
  String get pleaseEnterBags;

  /// No description provided for @enterValidWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter valid weight'**
  String get enterValidWeight;

  /// No description provided for @approxWeightPerBag.
  ///
  /// In en, this message translates to:
  /// **'Approx. Weight per Bag (kg)'**
  String get approxWeightPerBag;

  /// No description provided for @storageCondition.
  ///
  /// In en, this message translates to:
  /// **'Storage Condition'**
  String get storageCondition;

  /// No description provided for @notesFieldObservations.
  ///
  /// In en, this message translates to:
  /// **'Notes / Field Observations (Optional)'**
  String get notesFieldObservations;

  /// No description provided for @enterNotes.
  ///
  /// In en, this message translates to:
  /// **'Add any notes on curing, skin adherence, or field observations...'**
  String get enterNotes;

  /// No description provided for @registerLotButton.
  ///
  /// In en, this message translates to:
  /// **'Create Batch & Generate QR'**
  String get registerLotButton;

  /// No description provided for @batchCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Batch registered successfully'**
  String get batchCreatedSuccess;

  /// No description provided for @heapInspectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyze Onion Heap'**
  String get heapInspectionTitle;

  /// No description provided for @heapInspectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture or select a clear top-down heap photo'**
  String get heapInspectionSubtitle;

  /// No description provided for @inspectionTargetBatch.
  ///
  /// In en, this message translates to:
  /// **'Inspection Target Batch'**
  String get inspectionTargetBatch;

  /// No description provided for @heapImageCapture.
  ///
  /// In en, this message translates to:
  /// **'Heap Image Capture'**
  String get heapImageCapture;

  /// No description provided for @heapImageInstructions.
  ///
  /// In en, this message translates to:
  /// **'Photograph or upload an unobstructed top/angle view of the onion heap.'**
  String get heapImageInstructions;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @uploadFile.
  ///
  /// In en, this message translates to:
  /// **'Upload File'**
  String get uploadFile;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @quickPresets.
  ///
  /// In en, this message translates to:
  /// **'Quick Presets:'**
  String get quickPresets;

  /// No description provided for @sampleNashikRed.
  ///
  /// In en, this message translates to:
  /// **'Lasalgaon Red'**
  String get sampleNashikRed;

  /// No description provided for @sampleCommercialBulk.
  ///
  /// In en, this message translates to:
  /// **'Garva Mix'**
  String get sampleCommercialBulk;

  /// No description provided for @sampleFieldHarvest.
  ///
  /// In en, this message translates to:
  /// **'Sprout/Rot Heap'**
  String get sampleFieldHarvest;

  /// No description provided for @photoReady.
  ///
  /// In en, this message translates to:
  /// **'Sample Onion Heap Loaded'**
  String get photoReady;

  /// No description provided for @readyForAi.
  ///
  /// In en, this message translates to:
  /// **'Ready for AI Computer Vision'**
  String get readyForAi;

  /// No description provided for @tapToChange.
  ///
  /// In en, this message translates to:
  /// **'Tap above to change image'**
  String get tapToChange;

  /// No description provided for @inspectionParameters.
  ///
  /// In en, this message translates to:
  /// **'Inspection Parameters'**
  String get inspectionParameters;

  /// No description provided for @inspectorNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Inspector Name'**
  String get inspectorNameLabel;

  /// No description provided for @inspectorIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Inspector ID'**
  String get inspectorIdLabel;

  /// No description provided for @sampleBagWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Sample Bag Weight (kg)'**
  String get sampleBagWeightLabel;

  /// No description provided for @observationsNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Lot Observations / Notes'**
  String get observationsNotesLabel;

  /// No description provided for @runAiAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Run AI Heap Segmentation & Grading'**
  String get runAiAnalysis;

  /// No description provided for @stepReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get stepReady;

  /// No description provided for @stepUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading heap image to inference pipeline...'**
  String get stepUploading;

  /// No description provided for @stepExtracting.
  ///
  /// In en, this message translates to:
  /// **'Extracting visible onion instance boundaries...'**
  String get stepExtracting;

  /// No description provided for @stepClassifying.
  ///
  /// In en, this message translates to:
  /// **'Classifying defects: healthy, rot, sprout, damage...'**
  String get stepClassifying;

  /// No description provided for @stepFinalizing.
  ///
  /// In en, this message translates to:
  /// **'Finalizing AGMARK Grade A/B/Reject metrics...'**
  String get stepFinalizing;

  /// No description provided for @analysisFailed.
  ///
  /// In en, this message translates to:
  /// **'Analysis failed: {error}'**
  String analysisFailed(String error);

  /// No description provided for @pleaseSelectImage.
  ///
  /// In en, this message translates to:
  /// **'Please select or capture an onion heap image'**
  String get pleaseSelectImage;

  /// No description provided for @bestPracticesTitle.
  ///
  /// In en, this message translates to:
  /// **'Inspection Best Practices'**
  String get bestPracticesTitle;

  /// No description provided for @tip1.
  ///
  /// In en, this message translates to:
  /// **'Keep entire top layer in frame for representative sampling'**
  String get tip1;

  /// No description provided for @tip2.
  ///
  /// In en, this message translates to:
  /// **'Ensure uniform diffused lighting (avoid harsh shadows)'**
  String get tip2;

  /// No description provided for @tip3.
  ///
  /// In en, this message translates to:
  /// **'Remove large debris or sacking covering the pile'**
  String get tip3;

  /// No description provided for @heapQualityResults.
  ///
  /// In en, this message translates to:
  /// **'Heap Quality Estimation Results'**
  String get heapQualityResults;

  /// No description provided for @assignedLotGrade.
  ///
  /// In en, this message translates to:
  /// **'Assigned Lot Grade: {grade}'**
  String assignedLotGrade(String grade);

  /// No description provided for @bulbsVisible.
  ///
  /// In en, this message translates to:
  /// **'{count} bulbs visible'**
  String bulbsVisible(int count);

  /// No description provided for @confidencePercent.
  ///
  /// In en, this message translates to:
  /// **'{value}% confidence'**
  String confidencePercent(String value);

  /// No description provided for @latencyMs.
  ///
  /// In en, this message translates to:
  /// **'{ms} ms'**
  String latencyMs(int ms);

  /// No description provided for @instanceSegmentation.
  ///
  /// In en, this message translates to:
  /// **'Instance Segmentation Overlay'**
  String get instanceSegmentation;

  /// No description provided for @tapBulbHint.
  ///
  /// In en, this message translates to:
  /// **'Tap any onion bulb to view diameter, defect type, and confidence score.'**
  String get tapBulbHint;

  /// No description provided for @prototypeEngine.
  ///
  /// In en, this message translates to:
  /// **'Prototype Inference Engine'**
  String get prototypeEngine;

  /// No description provided for @fineTunedEngine.
  ///
  /// In en, this message translates to:
  /// **'Fine-Tuned YOLO11-Seg'**
  String get fineTunedEngine;

  /// No description provided for @visionWarnings.
  ///
  /// In en, this message translates to:
  /// **'Vision Quality Warnings ({count})'**
  String visionWarnings(int count);

  /// No description provided for @generatePdfReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Digital PDF Report'**
  String get generatePdfReport;

  /// No description provided for @saveAndCertify.
  ///
  /// In en, this message translates to:
  /// **'Save & Certify Batch'**
  String get saveAndCertify;

  /// No description provided for @inspectionSavedSuccessWithGrade.
  ///
  /// In en, this message translates to:
  /// **'Inspection saved! Batch certified as {grade}.'**
  String inspectionSavedSuccessWithGrade(String grade);

  /// No description provided for @polygonsLabel.
  ///
  /// In en, this message translates to:
  /// **'Polygons'**
  String get polygonsLabel;

  /// No description provided for @boxesLabel.
  ///
  /// In en, this message translates to:
  /// **'Boxes'**
  String get boxesLabel;

  /// No description provided for @labelsLabel.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get labelsLabel;

  /// No description provided for @allDefects.
  ///
  /// In en, this message translates to:
  /// **'All Defects'**
  String get allDefects;

  /// No description provided for @filterDefectAll.
  ///
  /// In en, this message translates to:
  /// **'Filter defect: All'**
  String get filterDefectAll;

  /// No description provided for @bulbDetailText.
  ///
  /// In en, this message translates to:
  /// **'Onion #{id}: {defect}'**
  String bulbDetailText(int id, String defect);

  /// No description provided for @bulbMetaInfo.
  ///
  /// In en, this message translates to:
  /// **'Grade: {grade} • Est. Diameter: {diameter} mm • Conf: {confidence}%'**
  String bulbMetaInfo(String grade, String diameter, String confidence);

  /// No description provided for @digitalGradeDistribution.
  ///
  /// In en, this message translates to:
  /// **'Digital Quality Grade Distribution'**
  String get digitalGradeDistribution;

  /// No description provided for @gradeAExport.
  ///
  /// In en, this message translates to:
  /// **'Grade A (Export)'**
  String get gradeAExport;

  /// No description provided for @gradeBLocal.
  ///
  /// In en, this message translates to:
  /// **'Grade B (Local)'**
  String get gradeBLocal;

  /// No description provided for @rejectWaste.
  ///
  /// In en, this message translates to:
  /// **'Reject / Waste'**
  String get rejectWaste;

  /// No description provided for @targetGradeA.
  ///
  /// In en, this message translates to:
  /// **'Target >= 70%'**
  String get targetGradeA;

  /// No description provided for @minorDefects.
  ///
  /// In en, this message translates to:
  /// **'Minor defects'**
  String get minorDefects;

  /// No description provided for @rotSprout.
  ///
  /// In en, this message translates to:
  /// **'Rot / Sprout'**
  String get rotSprout;

  /// No description provided for @defectBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Visible Defect Breakdown'**
  String get defectBreakdown;

  /// No description provided for @disclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'VISIBLE SURFACE ESTIMATION LIMITATION'**
  String get disclaimerTitle;

  /// No description provided for @disclaimerText.
  ///
  /// In en, this message translates to:
  /// **'Surface vision analysis estimates visible top-layer quality. Physical core sampling remains recommended for deep bulk lots.'**
  String get disclaimerText;

  /// No description provided for @qualityHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get qualityHealthy;

  /// No description provided for @qualityDamaged.
  ///
  /// In en, this message translates to:
  /// **'Damaged'**
  String get qualityDamaged;

  /// No description provided for @qualityRotten.
  ///
  /// In en, this message translates to:
  /// **'Rotten'**
  String get qualityRotten;

  /// No description provided for @qualitySprouted.
  ///
  /// In en, this message translates to:
  /// **'Sprouted'**
  String get qualitySprouted;

  /// No description provided for @qualityUndersized.
  ///
  /// In en, this message translates to:
  /// **'Undersized'**
  String get qualityUndersized;

  /// No description provided for @qualityUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get qualityUnknown;

  /// No description provided for @gradeA.
  ///
  /// In en, this message translates to:
  /// **'Grade A'**
  String get gradeA;

  /// No description provided for @gradeB.
  ///
  /// In en, this message translates to:
  /// **'Grade B'**
  String get gradeB;

  /// No description provided for @gradeC.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get gradeC;

  /// No description provided for @batchDetails.
  ///
  /// In en, this message translates to:
  /// **'Batch Details'**
  String get batchDetails;

  /// No description provided for @analyzeHeapForBatch.
  ///
  /// In en, this message translates to:
  /// **'Analyze Onion Heap for this Batch'**
  String get analyzeHeapForBatch;

  /// No description provided for @completedInspections.
  ///
  /// In en, this message translates to:
  /// **'Completed Quality Inspections'**
  String get completedInspections;

  /// No description provided for @noInspectionsYet.
  ///
  /// In en, this message translates to:
  /// **'No inspection recorded for this batch yet.\nClick \"Analyze Onion Heap\" to scan.'**
  String get noInspectionsYet;

  /// No description provided for @viewPdf.
  ///
  /// In en, this message translates to:
  /// **'View PDF'**
  String get viewPdf;

  /// No description provided for @inspectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Inspection: {grade}'**
  String inspectionTitle(String grade);

  /// No description provided for @verifyCertificateTitle.
  ///
  /// In en, this message translates to:
  /// **'e-NAM Quality Certificate Verification'**
  String get verifyCertificateTitle;

  /// No description provided for @publicVerification.
  ///
  /// In en, this message translates to:
  /// **'Public Certificate Verification'**
  String get publicVerification;

  /// No description provided for @verifySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification token printed beneath the report QR code to confirm grading authenticity and tamper-proof records.'**
  String get verifySubtitle;

  /// No description provided for @verifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyButton;

  /// No description provided for @authenticCertificate.
  ///
  /// In en, this message translates to:
  /// **'AUTHENTIC QUALITY CERTIFICATE'**
  String get authenticCertificate;

  /// No description provided for @recordNotFound.
  ///
  /// In en, this message translates to:
  /// **'Certificate Record Not Found'**
  String get recordNotFound;

  /// No description provided for @recordNotFoundMsg.
  ///
  /// In en, this message translates to:
  /// **'The verification token \"{query}\" was not found in the authenticated mandi database.'**
  String recordNotFoundMsg(String query);

  /// No description provided for @tokenLabel.
  ///
  /// In en, this message translates to:
  /// **'Token: {token}'**
  String tokenLabel(String token);

  /// No description provided for @batchNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Batch Number'**
  String get batchNumberLabel;

  /// No description provided for @certifiedInspector.
  ///
  /// In en, this message translates to:
  /// **'Certified Inspector'**
  String get certifiedInspector;

  /// No description provided for @inspectionTimestamp.
  ///
  /// In en, this message translates to:
  /// **'Inspection Timestamp'**
  String get inspectionTimestamp;

  /// No description provided for @visibleSampleCount.
  ///
  /// In en, this message translates to:
  /// **'Visible Sample Count'**
  String get visibleSampleCount;

  /// No description provided for @gradeARatio.
  ///
  /// In en, this message translates to:
  /// **'Grade A Ratio'**
  String get gradeARatio;

  /// No description provided for @gradeBRatio.
  ///
  /// In en, this message translates to:
  /// **'Grade B Ratio'**
  String get gradeBRatio;

  /// No description provided for @rejectionRate.
  ///
  /// In en, this message translates to:
  /// **'Rejection Rate'**
  String get rejectionRate;

  /// No description provided for @modelConfidence.
  ///
  /// In en, this message translates to:
  /// **'Model Confidence'**
  String get modelConfidence;

  /// No description provided for @bulbsScannedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} bulbs scanned'**
  String bulbsScannedCount(int count);

  /// No description provided for @digitalCertificate.
  ///
  /// In en, this message translates to:
  /// **'Digital Quality Certificate'**
  String get digitalCertificate;

  /// No description provided for @shareCertificate.
  ///
  /// In en, this message translates to:
  /// **'Share Certificate'**
  String get shareCertificate;

  /// No description provided for @verificationRibbon.
  ///
  /// In en, this message translates to:
  /// **'Verification Token: {token} • Signed by {inspector}'**
  String verificationRibbon(String token, String inspector);

  /// No description provided for @certTitle.
  ///
  /// In en, this message translates to:
  /// **'ONIONSURE DIGITAL QUALITY CERTIFICATE'**
  String get certTitle;

  /// No description provided for @certSub.
  ///
  /// In en, this message translates to:
  /// **'SIH26031: AI-Powered Smart Onion Batch Grading'**
  String get certSub;

  /// No description provided for @certMandiRecord.
  ///
  /// In en, this message translates to:
  /// **'Accredited Mandi APMC Inspection Record'**
  String get certMandiRecord;

  /// No description provided for @certBatchRegistration.
  ///
  /// In en, this message translates to:
  /// **'BATCH & LOT REGISTRATION'**
  String get certBatchRegistration;

  /// No description provided for @certInspectionDate.
  ///
  /// In en, this message translates to:
  /// **'Inspection Date'**
  String get certInspectionDate;

  /// No description provided for @certFarmerOwner.
  ///
  /// In en, this message translates to:
  /// **'Farmer / Lot Owner'**
  String get certFarmerOwner;

  /// No description provided for @certMandiYard.
  ///
  /// In en, this message translates to:
  /// **'Mandi Yard'**
  String get certMandiYard;

  /// No description provided for @certVariety.
  ///
  /// In en, this message translates to:
  /// **'Onion Variety'**
  String get certVariety;

  /// No description provided for @certTotalWeight.
  ///
  /// In en, this message translates to:
  /// **'Total Weight'**
  String get certTotalWeight;

  /// No description provided for @certAssignedInspector.
  ///
  /// In en, this message translates to:
  /// **'Assigned Inspector'**
  String get certAssignedInspector;

  /// No description provided for @certVerificationToken.
  ///
  /// In en, this message translates to:
  /// **'Verification Token'**
  String get certVerificationToken;

  /// No description provided for @certGradingSection.
  ///
  /// In en, this message translates to:
  /// **'HEAP INSTANCE SEGMENTATION & DIGITAL GRADING'**
  String get certGradingSection;

  /// No description provided for @certMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get certMetric;

  /// No description provided for @certComputedValue.
  ///
  /// In en, this message translates to:
  /// **'Computed Value'**
  String get certComputedValue;

  /// No description provided for @certGradingSpec.
  ///
  /// In en, this message translates to:
  /// **'Grading Standard Specification'**
  String get certGradingSpec;

  /// No description provided for @certVisibleScanned.
  ///
  /// In en, this message translates to:
  /// **'Visible Onions Scanned'**
  String get certVisibleScanned;

  /// No description provided for @certVisibleBulbs.
  ///
  /// In en, this message translates to:
  /// **'{count} bulbs'**
  String certVisibleBulbs(int count);

  /// No description provided for @certSurfaceExtraction.
  ///
  /// In en, this message translates to:
  /// **'Surface polygon boundary extraction'**
  String get certSurfaceExtraction;

  /// No description provided for @certGradeARatio.
  ///
  /// In en, this message translates to:
  /// **'Grade A Quality Ratio'**
  String get certGradeARatio;

  /// No description provided for @certGradeASpec.
  ///
  /// In en, this message translates to:
  /// **'Standard: >= 70% for Grade A certification'**
  String get certGradeASpec;

  /// No description provided for @certGradeBRatio.
  ///
  /// In en, this message translates to:
  /// **'Grade B Fair Ratio'**
  String get certGradeBRatio;

  /// No description provided for @certGradeBSpec.
  ///
  /// In en, this message translates to:
  /// **'Permissible minor skin cuts / size variance'**
  String get certGradeBSpec;

  /// No description provided for @certRejectRatio.
  ///
  /// In en, this message translates to:
  /// **'Rejection / Waste Ratio'**
  String get certRejectRatio;

  /// No description provided for @certRejectSpec.
  ///
  /// In en, this message translates to:
  /// **'Rot, decay, sprouting > 5% restricts trade'**
  String get certRejectSpec;

  /// No description provided for @certConfidenceScore.
  ///
  /// In en, this message translates to:
  /// **'Model Confidence Score'**
  String get certConfidenceScore;

  /// No description provided for @certMultiContour.
  ///
  /// In en, this message translates to:
  /// **'Multi-contour overlap verification'**
  String get certMultiContour;

  /// No description provided for @certDefectBreakdown.
  ///
  /// In en, this message translates to:
  /// **'DEFECT CLASSIFICATION BREAKDOWN'**
  String get certDefectBreakdown;

  /// No description provided for @certDisclaimerHeader.
  ///
  /// In en, this message translates to:
  /// **'IMPORTANT ESTIMATION BOUNDARY & MANDI DISCLAIMER'**
  String get certDisclaimerHeader;

  /// No description provided for @certScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR to verify on e-NAM portal'**
  String get certScanQr;

  /// No description provided for @certGraderSignature.
  ///
  /// In en, this message translates to:
  /// **'Authorized Quality Grader Signature'**
  String get certGraderSignature;

  /// No description provided for @certDate.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String certDate(String date);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
