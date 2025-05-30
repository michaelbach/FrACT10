/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

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

gAbortMessage = "Run canceled.";
//Correction for threshold underestimation by DIN/ISO-ascending method (in VAdecimal)
gThresholdCorrection4Ascending = 0.891;

//parameter for the CI95 dispersion estimation; strongly affects CI95
gSlopeCI95 = 15; //strongly affects CI95, this value approximates test-retest variability
gNSamplesCI95 = 10000; //with 10000 the median differs by LoA=0.003LogMAR from full run

//Clamping the max logCSWeber value to avoid log of zero during conversions. Value way beyond physiologically possible.
gMaxAllowedLogCSWeber = 4.0;
gMaxResultLogCSWeber = 2.0;

gCalBarLengthInPixel = 700;

gMeter2FeetMultiplier = 3.28084;  tab = "\t";  crlf = "\n";

@typedef TestIDType
kTestNone = 0; kTestAcuityLett = 1; kTestAcuityC = 2; kTestAcuityE = 3; kTestAcuityTAO = 4;
kTestAcuityVernier = 5; kTestContrastLett = 6; kTestContrastC = 7; kTestContrastE = 8;
kTestContrastG = 9; kTestAcuityLineByLine = 10; kTestContrastDitherUnittest = 11;
kTestBalmLight = 12; kTestBalmLocation = 13; kTestBalmMotion = 14;
gCurrentTestID = kTestNone;

gBalmTestIDs = [kTestBalmLight, kTestBalmLocation, kTestBalmMotion];

kShortcutKeys4TestsArray = {"L": kTestAcuityLett, "C": kTestAcuityC, "E": kTestAcuityE,
    "A": kTestAcuityTAO, "V": kTestAcuityVernier,
    "1": kTestContrastLett, "2": kTestContrastC, "3": kTestContrastE,
    "G": kTestContrastG, "0": kTestContrastDitherUnittest, "4": kTestAcuityLineByLine};

@typedef NAlternativesIndexType
kNAlternativesIndex2 = 0; kNAlternativesIndex4 = 1; kNAlternativesIndex8plus = 2;

@typedef auditoryFeedback4trialIndexType
kauditoryFeedback4trialIndexNone = 0; kauditoryFeedback4trialIndexAlways = 1; kauditoryFeedback4trialIndexOncorrect = 2; kauditoryFeedback4trialIndexWithinfo = 3;

@typedef ResultsToClipChoiceType
kResultsToClipNone = 0; kResultsToClipFinalOnly = 1; kResultsToClipFullHistory = 2;
kResultsToClipFullHistory2PDF = 3;

@typedef AutoRunIndexType
kAutoRunIndexNone = 0; kAutoRunIndexHi = 1; kAutoRunIndexMid = 2; kAutoRunIndexLow = 3;

@typedef VernierTypeType
kVernierType2bars = 0; kVernierType3bars = 1;

@typedef SoundTypeType
kSoundRunEnd = 0; kSoundTrialYes = 1; kSoundTrialNo = 2; kSoundTrialStart = 3;

@typedef decimalMarkCharIndexType
kDecimalMarkCharIndexAuto = 0; kDecimalMarkCharIndexDot = 1; kDecimalMarkCharIndexComma = 2;

@typedef gratingShapeIndexType
kGratingShapeIndexSinus = 0; kGratingShapeIndexSquare = 1;
kGratingShapeIndexTriangle = 2; kGratingShapeIndexCheckerboard = 3;

gSoundsTrialYes = ["tink.mp3", "miniPop.mp3"];
gSoundsTrialNo = ["whistle.mp3", "error2.mp3"];
gSoundsRunEnd = ["gong.mp3", "cuteLevelUp.mp3"];
gSoundsTrialStart = ["click02.mp3", "notify1.mp3", "notify2.mp3"];

gEyeIndex2string = ["eyeNA", "OU", "OD", "OS"]; //OU = "oculus uterque" = both eyes

////global Variables
gDefaultDistanceInCM = 399;
gDefaultCalibrationBarLengthInMM = 149;

//cgc as global makes for easy access in Optotypes and contrast calcs
cgc = [[CPGraphicsContext currentContext] graphicsPort];
gAppController = null; //allows globally communicating with the AppController
gColorFore = [CPColor whiteColor];  gColorBack = [CPColor blackColor];
//minimal stroke size (half a pixel). Maximal, depending on screen & margin. Poor naming for Vernier. Values are later overridden via Setting and screen size.
gStrokeMinimal = 0.5;  gStrokeMaximal = 100;
