/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, michael.bach@uni-freiburg.de, <https://michaelbach.de>

Globals.j

*/

/**
 Global variables
 Since we do not have constants in Objective-J, we create global variables
 (and # define does not work for me)
 Created on 2021-01-07
 */
tab = "\t";  crlf = "\n";

kVersionStringOfFract = "1.0.3";
kVersionDateOfFrACT = "2023-07-03";
kVersionOfExportFormat = "5";

kDefaultDistanceInCM = 399;
kDefaultCalibrationBarLengthInMM = 149;

kFilename4ResultStorage = "FRACT10-FINAL-RESULT-STRING";
kFilename4ResultsHistoryStorage = "FRACT10-RESULTS-HISTORY-STRING";

// minimal stroke/gap size (half a pixel). Maximal, depending on screen & margin.
// Formerly named gapMinimal/gapMaximal. Poor naming in case of Vernier.
gStrokeMinimal = 0.5;  gStrokeMaximal = 100; //Values are later overridden

// Correction for threshold underestimation by ascending method (in VAdecimal)
gThresholdCorrection4Ascending = 0.891;

// slope parameter for the CI95 dispersion estimation; strongly affects CI95
gSlopeCI95 = 15; // this value approximates test-retest variability

// version info for the About screen
gCappucinoVersionString = [[[CPBundle bundleWithIdentifier:@"com.280n.Foundation"] infoDictionary] objectForKey:@"CPBundleVersion"]; // initialised in AppController


/* switch to readable history? Given up for now.
 devHistory = [];
devHistory.push(["2022-09-02", 'increase max value of `contrastOptotypeDiameter` from 1500 to 2500']);
devHistory.push(["2022-09-01", 'new compiler allows "let" and "const", begin to use them']);*/
