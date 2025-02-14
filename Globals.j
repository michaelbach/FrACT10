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


//// global Constants
const bundleDict = [[CPBundle bundleWithIdentifier: "de.michaelbach.FrACT10"] infoDictionary];
gVersionDateOfFrACT = [bundleDict objectForKey:@"VersionDate"];
gVersionStringOfFract = [bundleDict objectForKey:@"VersionNumberString"];//CPBundleVersion mangled by jake
gVersionOfExportFormat = "5";

gFilename4ResultStorage = "FRACT10-FINAL-RESULT-STRING";
gFilename4ResultsHistoryStorage = "FRACT10-RESULTS-HISTORY-STRING";

// Correction for threshold underestimation by DIN-ascending method (in VAdecimal)
gThresholdCorrection4Ascending = 0.891;

// parameter for the CI95 dispersion estimation; strongly affects CI95
gSlopeCI95 = 15; //strongly affects CI95, this value approximates test-retest variability
gNSamplesCI95 = 10000; // with 10000 the median differs by LoA=0.003LogMAR from full run

// Clamping the max logCSWeber value to avoid log of zero during conversions. Value way beyond physiologically possible.
gMaxAllowedLogCSWeber = 4.0;
gMaxResultLogCSWeber = 2.0;

gCalBarLengthInPixel = 700;

gMeter2FeetMultiplier = 3.28084;  tab = "\t";  crlf = "\n";


//// global Variables
gDefaultDistanceInCM = 399;
gDefaultCalibrationBarLengthInMM = 149;

// cgc as global makes for easy access in Optotypes and contrast calcs
cgc = [[CPGraphicsContext currentContext] graphicsPort];
gAppController = null;
gColorFore = [CPColor whiteColor];  gColorBack = [CPColor blackColor];
gSpecialBcmDone = NO;
// minimal stroke size (half a pixel). Maximal, depending on screen & margin. Poor naming for Vernier.
gStrokeMinimal = 0.5;  gStrokeMaximal = 100; //Values are later overridden via Setting and screen size

gSoundsTrialYes = ["tink.mp3", "miniPop.mp3"];
gSoundsTrialNo = ["whistle.mp3", "error2.mp3"];
gSoundsRunEnd = ["gong.mp3", "cuteLevelUp.mp3"];
