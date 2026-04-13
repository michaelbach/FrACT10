/*
This file is part of FrACT10, a vision test battery.
© 2026 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

Globals.j

Global variables and constants.
Actually, some are not truly global but attached to `window`.
Coded by mb since July 2015.
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
kVersionOfExportFormat = "6"; //incremented 2025-05-13 after adding ID and eyeCondition
kDateOfCurrentSettingsVersion = "2026-03-18a"

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


//all settings and their types for `Settings` and `ControlDispatcher`
gSettingsNamesAndTypesMap = new Map([
    //[name, {type, dflt, min, max}]
    ["presetName", {type: "str", dflt: "Standard Defaults", min: null, max: null}], //above all or for all setting tabs
    ["autoRunIndex", {type: "int", dflt: kAutoRunIndexNone, min: kAutoRunIndexNone, max: kAutoRunIndexLow}],
    ["dateOfSettingsVersion", {type: "str", dflt: kDateOfCurrentSettingsVersion, min: null, max: null}],
    ["showIdAndEyeOnMain", {type: "bool", dflt: NO, min: null, max: null}],//↓General tab
    ["nTrials02", {type: "int", dflt: 36, min: 1, max: 500}],
    ["nTrials04", {type: "int", dflt: 24, min: 1, max: 500}], ["nTrials08", {type: "int", dflt: 18, min: 1, max: 500}],
    ["nAlternativesIndex", {type: "int", dflt: kNAlternativesIndex8plus, min: kNAlternativesIndex2, max: kNAlternativesIndex8plus}],
    ["distanceInCM", {type: "float", dflt: gDefaultDistanceInCM, min: 1, max: 2500}],
    ["distanceInInchLocalisedString", {type: "str", dflt: "", min: null, max: null}],
    ["calBarLengthInMM", {type: "float", dflt: gDefaultCalibrationBarLengthInMM, min: 1, max: 10000}],
    ["showResponseInfoAtStart", {type: "bool", dflt: YES, min: null, max: null}],
    ["testOnFive", {type: "int", dflt: kTestAcuityLetters, min: kTestNone, max: kTestAcuityLineByLine}],
    ["eccentXInDeg", {type: "float", dflt: 0, min: -99, max: 99}],
    ["eccentYInDeg", {type: "float", dflt: 0, min: -99, max: 99}],
    ["eccentShowCenterFixMark", {type: "bool", dflt: YES, min: null, max: null}],
    ["eccentRandomizeX", {type: "bool", dflt: NO, min: null, max: null}],
    ["eccentRandomizeY", {type: "bool", dflt: NO, min: null, max: null}],
    ["respondsToMobileOrientation", {type: "bool", dflt: YES, min: null, max: null}],
    ["autoFullScreen", {type: "bool", dflt: NO, min: null, max: null}],
    ["displayTransform", {type: "int", dflt: 0, min: 0, max: 3}],
    ["showTrialInfo", {type: "bool", dflt: YES, min: null, max: null}],
    ["trialInfoFontSize", {type: "int", dflt: 10, min: 4, max: 48}],
    ["timeoutIsiMillisecs", {type: "float", dflt: 0, min: 0, max: 3000}],
    ["timeoutResponseSeconds", {type: "float", dflt: 30, min: 0.1, max: 9999}],
    ["timeoutDisplaySeconds", {type: "float", dflt: 30, min: 0.1, max: 9999}],
    ["decimalMarkCharIndex", {type: "int", dflt: kDecimalMarkCharIndexAuto, min: kDecimalMarkCharIndexAuto, max: kDecimalMarkCharIndexComma}],
    ["resultsToClipboardIndex", {type: "int", dflt: kResultsToClipNone, min: kResultsToClipNone, max: kResultsToClipFullHistory2PDF}],
    ["putResultsToClipboardSilent", {type: "bool", dflt: NO, min: null, max: null}],
    ["auditoryFeedback4trialIndex", {type: "int", dflt: kauditoryFeedback4trialIndexWithinfo, min: kauditoryFeedback4trialIndexNone, max: kauditoryFeedback4trialIndexWithinfo}],
    ["visualFeedback", {type: "int", dflt: 0, min: 0, max: 3}],
    ["giveAuditoryFeedback4run", {type: "bool", dflt: YES, min: null, max: null}],
    ["soundVolume", {type: "float", dflt: 20, min: 1, max: 100}],
    ["showRewardPicturesWhenDone", {type: "bool", dflt: NO, min: null, max: null}],
    ["timeoutRewardPicturesInSeconds", {type: "float", dflt: 5, min: 0.1, max: 999}],
    ["enableTouchControls", {type: "bool", dflt: YES, min: null, max: null}],//↓Acuity tab
    ["isAcuityColor", {type: "bool", dflt: NO, min: null, max: null}],//musst come first, so the next↓ 2 color values are not killed by b/w contrast in Importing
    ["acuityForeColor", {type: "color", dflt: null, min: null, max: null}],
    ["acuityBackColor", {type: "color", dflt: null, min: null, max: null}],
    ["maxPossibleDecimalAcuityLocalisedString", {type: "str", dflt: "", min: null, max: null}],
    ["minPossibleDecimalAcuityLocalisedString", {type: "str", dflt: "", min: null, max: null}],
    ["minPossibleLogMAR", {type: "float", dflt: 0, min: null, max: null}],
    ["minPossibleLogMARLocalisedString", {type: "str", dflt: "", min: null, max: null}],
    ["maxPossibleLogMAR", {type: "float", dflt: 0, min: null, max: null}],
    ["maxPossibleLogMARLocalisedString", {type: "str", dflt: "", min: null, max: null}],
    ["doThreshCorrection", {type: "bool", dflt: YES, min: null, max: null}],
    ["maxDisplayedAcuity", {type: "float", dflt: 2, min: 1, max: 99}],
    ["minStrokeAcuity", {type: "float", dflt: 0.5, min: 0.5, max: 5}],
    ["acuityStartingLogMAR", {type: "float", dflt: 1, min: 0.3, max: 2.5}],
    ["margin4maxOptotypeIndex", {type: "int", dflt: 1, min: 0, max: 4}],
    ["crowdingType", {type: "int", dflt: 0, min: 0, max: 6}],
    ["crowdingDistanceCalculationType", {type: "int", dflt: 0, min: 0, max: 3}],
    ["showAcuityFormatDecimal", {type: "bool", dflt: YES, min: null, max: null}],
    ["showAcuityFormatLogMAR", {type: "bool", dflt: YES, min: null, max: null}],
    ["showAcuityFormatLetterScore", {type: "bool", dflt: NO, min: null, max: null}],
    ["showAcuityFormatSnellenFractionFoot", {type: "bool", dflt: NO, min: null, max: null}],
    ["forceSnellen20", {type: "bool", dflt: NO, min: null, max: null}],
    ["showCI95", {type: "bool", dflt: NO, min: null, max: null}],
    ["contrastAcuityWeber", {type: "float", dflt: 100, min: -1E6, max: 100}],
    ["acuityHasEasyTrials", {type: "bool", dflt: YES, min: null, max: null}],
    ["isLandoltObliqueOnly", {type: "bool", dflt: NO, min: null, max: null}], //↓Acuity>Line-by-line
    ["testOnLineByLineIndex", {type: "int", dflt: 1, min: 1, max: 4}],
    ["lineByLineDistanceType", {type: "int", dflt: 1, min: 0, max: 1}],
    ["lineByLineHeadcountIndex", {type: "int", dflt: 2, min: 0, max: 4}],
    ["lineByLineLinesIndex", {type: "int", dflt: 0, min: 0, max: 2}],
    ["isLineByLineChartModeConstantVA", {type: "bool", dflt: NO, min: null, max: null}], //↓Acuity>Vernier
    ["vernierType", {type: "int", dflt: 0, min: 0, max: 1}],
    ["vernierWidth", {type: "float", dflt: 1.0, min: 0.1, max: 120}],
    ["vernierLength", {type: "float", dflt: 15.0, min: 0.1, max: 1200}],
    ["vernierGap", {type: "float", dflt: 0.2, min: 0.0, max: 120}], //↓Contrast tab
    ["contrastHasEasyTrials", {type: "bool", dflt: YES, min: null, max: null}],
    ["isContrastDarkOnLight", {type: "bool", dflt: YES, min: null, max: null}],
    ["contrastOptotypeDiameter", {type: "float", dflt: 50, min: 1, max: 2500}],
    ["contrastShowFixMark", {type: "bool", dflt: YES, min: null, max: null}],
    ["contrastTimeoutFixmark", {type: "float", dflt: 500, min: 20, max: 5000}],
    ["contrastMaxLogCSWeber", {type: "float", dflt: 3.0, min: 1.5, max: kMaxAllowedLogCSWeber}],
    ["gammaValue", {type: "float", dflt: 2.0, min: 0.8, max: 4}],
    ["contrastBitStealing", {type: "bool", dflt: NO, min: null, max: null}],
    ["isContrastDithering", {type: "bool", dflt: YES, min: null, max: null}],
    ["contrastCrowdingType", {type: "int", dflt: 0, min: 0, max: 6}], //↓Gratings tab
    ["gratingCPD", {type: "float", dflt: 2.0, min: 0.01, max: 18}],
    ["isGratingMasked", {type: "bool", dflt: NO, min: null, max: null}],
    ["gratingMaskDiaInDeg", {type: "float", dflt: 10.0, min: 0.5, max: 50}],
    ["isGratingErrorDiffusion", {type: "bool", dflt: YES, min: null, max: null}],
    ["what2sweepIndex", {type: "int", dflt: 0, min: 0, max: 1}],
    ["gratingCPDmin", {type: "float", dflt: 0.5, min: 0.01, max: 60}],
    ["gratingCPDmax", {type: "float", dflt: 30, min: 0.01, max: 60}],
    ["gratingContrastMichelsonPercent", {type: "float", dflt: 95, min: 0.3, max: 99}],
    ["isGratingObliqueOnly", {type: "bool", dflt: NO, min: null, max: null}],
    ["gratingShapeIndex", {type: "int", dflt: 0, min: 0, max: kGratingShapeIndexCheckerboard}],
    ["isGratingColor", {type: "bool", dflt: NO, min: null, max: null}],//this must com before the next 2↓
    ["gratingForeColor", {type: "color", dflt: [CPColor lightGrayColor], min: null, max: null}], ["gratingBackColor", {type: "color", dflt: [CPColor darkGrayColor], min: null, max: null}], //↓BaLM tab
    ["balmIsiMillisecs", {type: "int", dflt: 1500, min: 20, max: 5000}],
    ["balmOnMillisecs", {type: "int", dflt: 200, min: 20, max: 2000}],
    ["balmLocationDiameterInDeg", {type: "float", dflt: 5, min: 0.1, max: 20}],
    ["balmLocationEccentricityInDeg", {type: "float", dflt: 15, min: 1, max: 30}],
    ["balmMotionDiameterInDeg", {type: "float", dflt: 3.3, min: 0.1, max: 10}],
    ["balmSpeedInDegPerSec", {type: "float", dflt: 3.3, min: 0.1, max: 10}],
    ["balmExtentInDeg", {type: "float", dflt: 15, min: 5, max: 30}], //↓Misc tab
    ["windowBackgroundColor", {type: "color", dflt: [CPColor colorWithRed: 1 green: 1 blue: 0.9 alpha: 1], min: null, max: null}],
    ["specialBcmOn", {type: "bool", dflt: NO, min: null, max: null}],
    ["hideExitButton", {type: "bool", dflt: NO, min: null, max: null}],
    ["embedInNoise", {type: "bool", dflt: NO, min: null, max: null}],
    ["noiseContrast", {type: "int", dflt: 50, min: 0, max: 100}],
    ["soundTrialStartIndex", {type: "int", dflt: 1, min: 0, max: 2}],
    ["soundRunEndIndex", {type: "int", dflt: 0, min: 0, max: 1}],
    ["soundTrialYesIndex", {type: "int", dflt: 0, min: 0, max: 1}],
    ["soundTrialNoIndex", {type: "int", dflt: 0, min: 0, max: 1}],
    ["patID", {type: "str", dflt: "-", min: null, max: null}],
    ["eyeIndex", {type: "int", dflt: 0, min: 0, max: 3}],
    ["isAcuityPresentedConstant", {type: "bool", dflt: NO, min: null, max: null}],
    ["acuityPresentedConstantLogMAR", {type: "float", dflt: 0, min: -1.0, max: 3.0}],
    ["isAutoPreset", {type: "bool", dflt: NO, min: null, max: null}],
    ["enableTestAcuityLetters", {type: "bool", dflt: YES, min: null, max: null}],
    ["enableTestAcuityLandolt", {type: "bool", dflt: YES, min: null, max: null}],
    ["enableTestAcuityE", {type: "bool", dflt: YES, min: null, max: null}],
    ["enableTestAcuityTAO", {type: "bool", dflt: YES, min: null, max: null}],
    ["enableTestAcuityVernier", {type: "bool", dflt: YES, min: null, max: null}],
    ["enableTestContrastLetters", {type: "bool", dflt: YES, min: null, max: null}],
    ["enableTestContrastLandolt", {type: "bool", dflt: YES, min: null, max: null}],
    ["enableTestContrastE", {type: "bool", dflt: YES, min: null, max: null}],
    ["enableTestContrastG", {type: "bool", dflt: YES, min: null, max: null}],
    ["enableTestAcuityLineByLine", {type: "bool", dflt: YES, min: null, max: null}],
    ["enableTestBalmGeneral", {type: "bool", dflt: YES, min: null, max: null}],
    ["isAllSettingsDisabled", {type: "bool", dflt: NO, min: null, max: null}],
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
kBalmTestIDs = [kTestBalmLight, kTestBalmLocation, kTestBalmMotion];
gCurrentTestID = kTestNone;

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
gTestDetails[td_vsExpFormat] = kVersionOfExportFormat;
gTestDetails[td_vsFrACT] = "FrACT10·" + gVersionStringOfFract + "·" + gVersionDateOfFrACT;
