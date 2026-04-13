/*
This file is part of FrACT10, a vision test battery.
© 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

Globals.j
*/

/**
 Global constants & variables
 Since we do not have constants in Objective-J, we create global variables
 (and # define does not work for me)
 Created on 2021-01-07
 */


////global Constants
const bundleDict = [[CPBundle bundleWithIdentifier: "de.michaelbach.FrACT10"] infoDictionary];
gVersionDateOfFrACT = [bundleDict objectForKey:@"VersionDate"];
gVersionStringOfFract = [bundleDict objectForKey:@"VersionNumberString"]; //CPBundleVersion mangled by jake
gVersionOfExportFormat = "6"; //incremented 2025-05-13 after adding ID and eyeCondition

gFilename4ResultStorage = "FRACT10-FINAL-RESULT-STRING";
gFilename4ResultsHistoryStorage = "FRACT10-RESULTS-HISTORY-STRING";
kFractWidth = 800;  kFractHeight = 600;
kGuiMarginHorizontal = 18;

kKEY_RESPONSE_RIGHT = "6";  //geographic mapping of keys for numeric keypad
kKEY_RESPONSE_UP_RIGHT = "9";
kKEY_RESPONSE_UP = "8";
kKEY_RESPONSE_UP_LEFT = "7";
kKEY_RESPONSE_LEFT = "4";
kKEY_RESPONSE_DOWN_LEFT = "1";
kKEY_RESPONSE_DOWN = "2";
kKEY_RESPONSE_DOWN_RIGHT = "3";
kKEY_RESPONSE_ABORT = "5";

gAbortMessage = "Run canceled.";
//Correction for threshold underestimation by DIN/ISO-ascending method (in VAdecimal)
kThresholdCorrectionFactor4Ascending = 0.892;//multiplicative for decimal acuity ≙ 0.0496 ≅ 0.05 logMAR addition

//parameter for the CI95 dispersion estimation; strongly affects CI95
gSlopeCI95 = 7; //strongly affects CI95, this value approximates test-retest variability
gNSamplesCI95 = 10000; //with 10000 the median differs by LoA=0.003LogMAR from full run

//Clamping the max logCSWeber value to avoid logarithm of zero during conversions. Value way beyond physiologically possible.
kMaxAllowedLogCSWeber = 4.0; //used as max in Settings value vetting
gMaxResultLogCSWeber = 2.0;

//calibration defaults
gDefaultDistanceInCM = 399;
gDefaultCalibrationBarLengthInMM = 149;
gCalBarLengthInPixel = 700;

kMeter2FeetMultiplier = 3.28084;  tab = "\t";  crlf = "\n";

@typedef TestIDType
kTestNone = 0; kTestAcuityLetters = 1; kTestAcuityLandolt = 2; kTestAcuityE = 3; kTestAcuityTAO = 4;
kTestAcuityVernier = 5; kTestContrastLetters = 6; kTestContrastLandolt = 7; kTestContrastE = 8;
kTestContrastG = 9; kTestAcuityLineByLine = 10;
kTestBalmGeneral = 11;
kTestBalmLight = 12; kTestBalmLocation = 13; kTestBalmMotion = 14;
kTestContrastDitherUnittest = 15;

//all settings and their types for `Settings` and `ControlDispatcher`
gSettingsNamesAndTypesMap = new Map([
    //[name, {type: type}]
    ["presetName", {type: "str"}], //above all or for all setting tabs
    ["autoRunIndex", {type: "int"}],
    ["dateOfSettingsVersion", {type: "str"}],
    ["showIdAndEyeOnMain", {type: "bool"}],//↓General tab
    ["nTrials02", {type: "int"}], ["nTrials04", {type: "int"}], ["nTrials08", {type: "int"}],
    ["nAlternativesIndex", {type: "int"}],
    ["distanceInCM", {type: "float"}],
    ["distanceInInchLocalisedString", {type: "str"}],
    ["calBarLengthInMM", {type: "float"}],
    ["showResponseInfoAtStart", {type: "bool"}],
    ["testOnFive", {type: "int"}],
    ["eccentXInDeg", {type: "float"}], ["eccentYInDeg", {type: "float"}],
    ["eccentShowCenterFixMark", {type: "bool"}],
    ["eccentRandomizeX", {type: "bool"}], ["eccentRandomizeY", {type: "bool"}],
    ["respondsToMobileOrientation", {type: "bool"}],
    ["autoFullScreen", {type: "bool"}],
    ["displayTransform", {type: "int"}],
    ["showTrialInfo", {type: "bool"}], ["trialInfoFontSize", {type: "int"}],
    ["timeoutIsiMillisecs", {type: "float"}],
    ["timeoutResponseSeconds", {type: "float"}],
    ["timeoutDisplaySeconds", {type: "float"}],
    ["decimalMarkCharIndex", {type: "int"}],
    ["resultsToClipboardIndex", {type: "int"}], ["putResultsToClipboardSilent", {type: "bool"}],
    ["auditoryFeedback4trialIndex", {type: "int"}],
    ["visualFeedback", {type: "int"}],
    ["giveAuditoryFeedback4run", {type: "bool"}],
    ["soundVolume", {type: "float"}],
    ["showRewardPicturesWhenDone", {type: "bool"}],
    ["timeoutRewardPicturesInSeconds", {type: "float"}],
    ["enableTouchControls", {type: "bool"}],//↓Acuity tab
    ["isAcuityColor", {type: "bool"}],//musst come first, so the next↓ 2 color values are not killed by b/w contrast in Importing
    ["acuityForeColor", {type: "color"}], ["acuityBackColor", {type: "color"}],
    ["maxPossibleDecimalAcuityLocalisedString", {type: "str"}],
    ["minPossibleDecimalAcuity", {type: "float"}],
    ["minPossibleDecimalAcuityLocalisedString", {type: "str"}],
    ["minPossibleLogMAR", {type: "float"}],
    ["minPossibleLogMARLocalisedString", {type: "str"}],
    ["maxPossibleLogMAR", {type: "float"}],
    ["maxPossibleLogMARLocalisedString", {type: "str"}],
    ["doThreshCorrection", {type: "bool"}],
    ["maxDisplayedAcuity", {type: "float"}],
    ["minStrokeAcuity", {type: "float"}],
    ["acuityStartingLogMAR", {type: "float"}],
    ["margin4maxOptotypeIndex", {type: "int"}],
    ["crowdingType", {type: "int"}], ["crowdingDistanceCalculationType", {type: "int"}],
    ["showAcuityFormatDecimal", {type: "bool"}],
    ["showAcuityFormatLogMAR", {type: "bool"}],
    ["showAcuityFormatLetterScore", {type: "bool"}],
    ["showAcuityFormatSnellenFractionFoot", {type: "bool"}],
    ["forceSnellen20", {type: "bool"}],
    ["showCI95", {type: "bool"}],
    ["contrastAcuityWeber", {type: "float"}],
    ["acuityHasEasyTrials", {type: "bool"}],
    ["isLandoltObliqueOnly", {type: "bool"}], //↓Acuity>Line-by-line
    ["testOnLineByLineIndex", {type: "int"}], ["lineByLineDistanceType", {type: "int"}],
    ["lineByLineHeadcountIndex", {type: "int"}], ["lineByLineLinesIndex", {type: "int"}],
    ["isLineByLineChartModeConstantVA", {type: "bool"}], //↓Acuity>Vernier
    ["vernierType", {type: "int"}], ["vernierWidth", {type: "float"}],
    ["vernierLength", {type: "float"}], ["vernierGap", {type: "float"}], //↓Contrast tab
    ["contrastHasEasyTrials", {type: "bool"}],
    ["isContrastDarkOnLight", {type: "bool"}],
    ["contrastOptotypeDiameter", {type: "float"}],
    ["contrastShowFixMark", {type: "bool"}], ["contrastTimeoutFixmark", {type: "float"}],
    ["contrastMaxLogCSWeber", {type: "float"}],
    ["gammaValue", {type: "float"}],
    ["contrastBitStealing", {type: "bool"}],
    ["isContrastDithering", {type: "bool"}],
    ["contrastCrowdingType", {type: "int"}], //↓Gratings tab
    ["gratingCPD", {type: "float"}],
    ["isGratingMasked", {type: "bool"}], ["gratingMaskDiaInDeg", {type: "float"}],
    ["isGratingErrorDiffusion", {type: "bool"}],
    ["what2sweepIndex", {type: "int"}],
    ["gratingCPDmin", {type: "float"}], ["gratingCPDmax", {type: "float"}],
    ["gratingContrastMichelsonPercent", {type: "float"}],
    ["isGratingObliqueOnly", {type: "bool"}],
    ["gratingShapeIndex", {type: "int"}],
    ["isGratingColor", {type: "bool"}],//this must com before the next 2↓
    ["gratingForeColor", {type: "color"}], ["gratingBackColor", {type: "color"}], //↓BaLM tab
    ["balmIsiMillisecs", {type: "int"}], ["balmOnMillisecs", {type: "int"}],
    ["balmLocationDiameterInDeg", {type: "float"}],
    ["balmLocationEccentricityInDeg", {type: "float"}],
    ["balmMotionDiameterInDeg", {type: "float"}],
    ["balmSpeedInDegPerSec", {type: "float"}],
    ["balmExtentInDeg", {type: "float"}], //↓Misc tab
    ["windowBackgroundColor", {type: "color"}],
    ["specialBcmOn", {type: "bool"}],
    ["hideExitButton", {type: "bool"}],
    ["embedInNoise", {type: "bool"}], ["noiseContrast", {type: "int"}],
    ["soundTrialStartIndex", {type: "int"}], ["soundRunEndIndex", {type: "int"}],
    ["soundTrialYesIndex", {type: "int"}], ["soundTrialNoIndex", {type: "int"}],
    ["patID", {type: "str"}], ["eyeIndex", {type: "int"}],
    ["isAcuityPresentedConstant", {type: "bool"}],
    ["acuityPresentedConstantLogMAR", {type: "float"}],
    ["isAutoPreset", {type: "bool"}],
    ["enableTestAcuityLetters", {type: "bool"}],
    ["enableTestAcuityLandolt", {type: "bool"}],
    ["enableTestAcuityE", {type: "bool"}],
    ["enableTestAcuityTAO", {type: "bool"}],
    ["enableTestAcuityVernier", {type: "bool"}],
    ["enableTestContrastLetters", {type: "bool"}],
    ["enableTestContrastLandolt", {type: "bool"}],
    ["enableTestContrastE", {type: "bool"}],
    ["enableTestContrastG", {type: "bool"}],
    ["enableTestAcuityLineByLine", {type: "bool"}],
    ["enableTestBalmGeneral", {type: "bool"}],
    ["isAllSettingsDisabled", {type: "bool"}],
]);

gTestRegistry = { //Object to hold all tests, names, their classes, shortcuts etc.
    [kTestAcuityLetters]: {testName: "AcuityLetters", className: "FractControllerAcuityLetters", shortcut: "L", name4xport: "Acuity_Letters"},
    [kTestAcuityLandolt]: {testName: "AcuityLandolt", className: "FractControllerAcuityLandolt", shortcut: "C", name4xport: "Acuity_LandoltC"},
    [kTestAcuityE]: {testName: "AcuityE", className: "FractControllerAcuityE", shortcut: "E", name4xport: "Acuity_TumblingE"},
    [kTestAcuityTAO]: {testName: "AcuityTAO", className: "FractControllerAcuityTAO", shortcut: "A", name4xport: "Acuity_TAO"},
    [kTestAcuityVernier]: {testName: "AcuityVernier", className: "FractControllerAcuityVernier", shortcut: "V", name4xport: "Acuity_Vernier"},
    [kTestContrastLetters]: {testName: "ContrastLetters", className: "FractControllerContrastLetters", shortcut: "1", name4xport: "Contrast_Letters"},
    [kTestContrastLandolt]: {testName: "ContrastLandolt", className: "FractControllerContrastC", shortcut: "2", name4xport: "Contrast_LandoltC"},
    [kTestContrastE]: {testName: "ContrastE", className: "FractControllerContrastE", shortcut: "3", name4xport: "Contrast_TumblingE"},
    [kTestContrastG]: {testName: "ContrastG", className: "FractControllerContrastG", shortcut: "G", name4xport: "Contrast_Grating"},
    [kTestAcuityLineByLine]: {testName: "AcuityLineByLine", className: "FractControllerAcuityLineByLine", shortcut: "4", name4xport: "Acuity_LineByLine"},
    [kTestBalmGeneral]: {name4xport: "BaLM"},
    [kTestBalmLight]: {testName: "BalmLight", className: "FractControllerBalmLight", name4xport: "BalmLight"},
    [kTestBalmLocation]: {testName: "BalmLocation", className: "FractControllerBalmLocation", name4xport: "BalmLocation"},
    [kTestBalmMotion]: {testName: "BalmMotion", className: "FractControllerBalmMotion", name4xport: "BalmMotion"},
    [kTestContrastDitherUnittest]: {testName: "ContrastDitherUnittest", className: "FractControllerContrastDitherUnittest", shortcut: "9"}
};
gBalmTestIDs = [kTestBalmLight, kTestBalmLocation, kTestBalmMotion];
gCurrentTestID = kTestNone;

@typedef NAlternativesIndexType
kNAlternativesIndex2 = 0; kNAlternativesIndex4 = 1; kNAlternativesIndex8plus = 2;

@typedef auditoryFeedback4trialIndexType
kauditoryFeedback4trialIndexNone = 0; kauditoryFeedback4trialIndexAlways = 1; kauditoryFeedback4trialIndexOncorrect = 2; kauditoryFeedback4trialIndexWithinfo = 3;

@typedef ResultsToClipChoiceType
kResultsToClipNone = 0; kResultsToClipFinalOnly = 1; kResultsToClipFullHistory = 2;
kResultsToClipFullHistory2PDF = 3;

@typedef AutoRunIndexType //hi ≙ high acuity
kAutoRunIndexNone = 0; kAutoRunIndexHi = 1; kAutoRunIndexMid = 2; kAutoRunIndexLow = 3;

@typedef VernierTypeType
kVernierType2bars = 0; kVernierType3bars = 1;

@typedef decimalMarkCharIndexType
kDecimalMarkCharIndexAuto = 0; kDecimalMarkCharIndexDot = 1; kDecimalMarkCharIndexComma = 2;

@typedef gratingShapeIndexType
kGratingShapeIndexSinus = 0; kGratingShapeIndexSquare = 1;
kGratingShapeIndexTriangle = 2; kGratingShapeIndexCheckerboard = 3;

@typedef SoundTypeType
kSoundRunEnd = 0; kSoundTrialYes = 1; kSoundTrialNo = 2; kSoundTrialStart = 3;
gSoundsTrialYes = ["tink.mp3", "miniPop.mp3"];
gSoundsTrialNo = ["whistle.mp3", "error2.mp3"];
gSoundsRunEnd = ["gong.mp3", "cuteLevelUp.mp3"];
gSoundsTrialStart = ["click02.mp3", "notify1.mp3", "notify2.mp3"];

gPatIDdefault = "-";
gEyeIndex2string = ["eyeNA", "OU", "OD", "OS"]; //OU = "oculus uterque" = both eyes


////global Variables

//cgc as global makes for easy access in Optotypes and contrast calcs
cgc = [[CPGraphicsContext currentContext] graphicsPort];
gAppController = null; //allows globally communicating with the AppController
gCurrentUUID = "";
gColorFore = [CPColor whiteColor];  gColorBack = [CPColor blackColor];
//minimal stroke size (half a pixel). Maximal, depending on screen & margin. Poor naming for Vernier. Values are later overridden via Setting and screen size.
gStrokeMinimal = 0.5;  gStrokeMaximal = 100;

gLatestAlert = null; //save the most recent alert (if not closed yet) so it can be automatically dismissed

//for testing; 0 for production
gTestingPlottingAcuity1Contrast2 = 0; //for easier testing of the AllTrialsPlot
gTestingCI95 = NO;

//general exporting
td_vsExpFormat = "vsExpFormat";
td_vsFrACT = "vsFrACT";
td_decimalMark = "decimalMark";
td_ID = "ID";
td_eyeCondition = "eyeCondition";
td_dateTimeOfRunStart = "dateTimeOfRunStart"
td_dateOfRunStart = "dateOfRunStart"
td_timeOfRunStart = "timeOfRunStart";
td_testName = "testName"
td_resultValue = "resultValue";
td_resultUnit = "resultUnit";
td_distanceInCm = "distanceInCm";
td_contrastWeber = "contrastWeber";
td_resultUnit2 = "resultUnit2";
td_nTrials = "nTrials";
td_nCorrect = "nCorrect";
td_nIncorrect = "nIncorrect";
// optionals
td_halfCI95 = "halfCI95";
td_colorFore = "colorFore";
td_colorBack = "colorBack";
td_rangeLimitStatus = "rangeLimitStatus";
td_noiseContrast = "noiseContrast";
td_gratingShape = "gratingShape";
td_crowdingType = "crowdingType";
td_eccentricityX = "eccentricityX";
td_eccentricityY = "eccentricityY";
td_spatFreq = "spatFreq";
td_cpdMin = "cpdMin";
td_cpdMax = "cpdMax";
td_hitRate = "hitRate";
gTestDetails = {};
/*gTestDetailsKeys = [
    td_vsExpFormat, td_vsFrACT, td_decimalMark, td_ID, td_eyeCondition,
    td_dateTimeOfRunStart, td_timeOfRunStart, td_timeOfRunStart, td_testName, td_resultValue, td_resultUnit,
    td_distanceInCm, td_contrastWeber, td_resultUnit2,
    td_nTrials, td_nCorrect, td_nIncorrect,
    // optionals
    td_halfCI95, td_colorFore, td_colorBack, td_rangeLimitStatus,
    td_noiseContrast, td_gratingShape,
    td_crowdingType, td_eccentricityX, td_eccentricityY,
    td_spatFreq, td_cpdMin, td_cpdMax,
    td_hitRate];*/
gTestDetails[td_vsExpFormat] = gVersionOfExportFormat;
gTestDetails[td_vsFrACT] = "FrACT10·" + gVersionStringOfFract + "·" + gVersionDateOfFrACT;
