/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, michael.bach@uni-freiburg.de, <https://michaelbach.de>

Settings.j

Provides a getter/setter interface to all settings (preferences)
All values are checked for sensible ranges for robustness.
Also calculates Fore- and BackColors
Created by mb on July 15, 2015.
*/

#define kDateOfCurrentSettingsVersion "2021-01-31"


@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import <Foundation/CPUserDefaults.j>
@import "HierarchyController.j"
@import "Misc.j"


@implementation Settings: CPUserDefaultsController


+ (CPString) versionFrACT {return kVersionStringOfFract;}
+ (CPString) versionExportFormat {return kVersionOfExportFormat;}
+ (CPString) versionDateFrACT {return kVersionDateOfFrACT;}
+ (CPString) filenameResultStorage {return kFilename4ResultStorage;}
+ (CPString) filenameResultsHistoryStorage {return kFilename4ResultsHistoryStorage;}


// helpers:
// if "set == true" the default is set,
// otherwise check if outside range or nil, if so set to default
+ (BOOL) chckBool: (BOOL) val def: (BOOL) def set: (BOOL) set { //console.info("chckBool ", val, "set: ", set);
    if (!set && !isNaN(val))  return val;
    return def;
}
+ (int) chckInt: (int) val def: (int) def min: (int) min max: (int) max set: (BOOL) set { // console.info("chckInt ", val);
    if (!set && !isNaN(val) && (val <= max) && (val >= min))  return val;
    return def;
}
+ (int) chckFlt: (float) val def: (float) def min: (float) min max: (float) max set: (BOOL) set { //console.info("chckFlt ", val);
    if (!set && !isNaN(val) && (val <= max) && (val >= min))  return val;
    return def;
}


+ (void) allNotCheckButSet: (BOOL) set {
    [[CPUserDefaults standardUserDefaults] synchronize];
    if (set) {
        [self setDateSettingsVersion: kDateOfCurrentSettingsVersion];
        [[CPUserDefaults standardUserDefaults] setInteger: 2 forKey: "nAlternativesIndex"]; // 8 alternatives
        [self setWindowBackgroundColor: [CPColor colorWithRed: 1 green: 1 blue: 0.9 alpha: 1]];
    }

    // for all tests
    [self setNTrials02: [self chckInt: [self nTrials02] def: 32 min: 1 max: 200 set: set]];
    [self setNTrials04: [self chckInt: [self nTrials04] def: 24 min: 1 max: 200 set: set]];
    [self setNTrials08: [self chckInt: [self nTrials08] def: 18 min: 1 max: 200 set: set]];

    [self setDistanceInCM: [self chckFlt: [self distanceInCM] def: kDefaultDistanceInCM min: 1 max: 2000 set: set]];
    [self setCalBarLengthInMM: [self chckFlt: [self calBarLengthInMM] def: kDefaultCalibrationBarLengthInMM min: 1 max: 2000 set: set]];
    [self setCalBarLengthInPixel: [self chckFlt: [self calBarLengthInPixel] def: 700 min: 1 max: 2000 set: set]];

    [self setResponseInfoAtStart: [self chckBool: [self responseInfoAtStart] def: YES set: set]];
    [self setEnableTouchControls: [self chckBool: [self enableTouchControls] def: YES set: set]];
    
    [self setTestOnFive: [self chckInt: [self testOnFive] def: 1 min: 0 max: 9 set: set]]; // 1: Sloan Letters

    [self setNOfRuns2Recall: [self chckInt: [self nOfRuns2Recall] def: 0 min: 0 max: 100 set: set]];

    [self setEccentXInDeg: [self chckFlt: [self eccentXInDeg] def: 0 min: -99 max: 99 set: set]];
    [self setEccentYInDeg: [self chckFlt: [self eccentYInDeg] def: 0 min: -99 max: 99 set: set]];
    [self setEccentShowCenterFixMark: [self chckBool: [self eccentShowCenterFixMark] def: YES set: set]];

    [self setAutoFullScreen: [self chckBool: [self autoFullScreen] def: NO set: set]];

    [self setMobileOrientation: [self chckBool: [self mobileOrientation] def: YES set: set]];

    // 0=normal, 1=mirror horizontally, 2=mirror vertically, 3=both=rot180°
    [self setDisplayTransform: [self chckInt: [self displayTransform] def: 0 min: 0 max: 3 set: set]];
    
    [self setTrialInfo: [self chckBool: [self trialInfo] def: YES set: set]];
    [self setTrialInfoFontSize: [self chckFlt: [self trialInfoFontSize] def: 9 min: 4 max: 48 set: set]];

    [self setTimeoutResponseSeconds: [self chckFlt: [self timeoutResponseSeconds] def: 30 min: 0.1 max: 9999 set: set]];
    [self setTimeoutDisplaySeconds: [self chckFlt: [self timeoutDisplaySeconds] def: 30 min: 0.1 max: 9999 set: set]];
    [self setMaskTimeOnResponseInMS: [self chckFlt: [self timeoutDisplaySeconds] def: 0 min: 0 max: 9999 set: set]];

    // 0: no, 1: final only, 2: full history
    [self setResults2clipboard: [self chckInt: [self results2clipboard] def: 0 min: 0 max: 2 set: set]];
    [self setResults2clipboardSilent: [self chckBool: [self results2clipboardSilent] def: NO set: set]];

    if (set) {
        [self setDecimalMarkChar: "auto"]; // will select index 0
    }

    // 0: none, 1: always, 2: on correct, 3: w/ info
    [self setAuditoryFeedback: [self chckInt: [self auditoryFeedback] def: 3 min: 0 max: 3 set: set]];
    // 0: none, 1: always, 2: on correct, 3: w/ info
    [self setVisualFeedback: [self chckInt: [self visualFeedback] def: 0 min: 0 max: 3 set: set]]; // NOT IN USE
    [self setAuditoryFeedbackWhenDone: [self chckBool: [self auditoryFeedbackWhenDone] def: YES set: set]];
    [self setSoundVolume: [self chckFlt: [self soundVolume] def: 20 min: 1 max: 100 set: set]];

    [self setRewardPicturesWhenDone: [self chckBool: [self rewardPicturesWhenDone] def: NO set: set]];
    [self setTimeoutRewardPicturesInSeconds: [self chckFlt: [self timeoutRewardPicturesInSeconds] def: 5 min: 0.1 max: 999 set: set]];

    
    // Acuity stuff
    [self setObliqueOnly: [self chckBool: [self obliqueOnly] def: NO set: set]]; // only applies to acuity with 4 Landolt orienations
    [self setContrastAcuityWeber: [self chckFlt: [self contrastAcuityWeber] def: 100 min: -1E6 max: 100 set: set]];
    [self calculateAcuityForeBackColorsFromContrast];
    [self setAcuityEasyTrials: [self chckBool: [self acuityEasyTrials] def: YES set: set]];
    [self setMaxDisplayedAcuity: [self chckFlt: [self maxDisplayedAcuity] def: 2 min: 1 max: 99 set: set]];
    [self setThreshCorrection: [self chckBool: [self threshCorrection] def: YES set: set]];
    [self setAcuityFormatDecimal: [self chckBool: [self acuityFormatDecimal] def: YES set: set]];
    [self setAcuityFormatLogMAR: [self chckBool: [self acuityFormatLogMAR] def: YES set: set]];
    [self setAcuityFormatSnellenFractionFoot: [self chckBool: [self acuityFormatSnellenFractionFoot] def: NO set: set]];
    [self setForceSnellen20: [self chckBool: [self forceSnellen20] def: NO set: set]];
    [self setShowCI95: [self chckBool: [self showCI95] def: NO set: set]];
    [self calculateMaxPossibleDecimalAcuity];

    // Crowding, crowdingType: 0 = none, 1: flanking bars, 2 = flanking rings, 3 = surounding bars, 4: surounding ring, 5 = surounding square, 6 = row of optotypes
    [self setCrowdingType: [self chckInt: [self crowdingType] def: 0 min: 0 max: 6 set: set]];
    // 0 = 2·gap between rings, 1 = fixed 2.6 arcmin between rings, 2 = fixed 30', 3 = like ETDRS
    [self setCrowdingDistanceCalculationType: [self chckInt: [self crowdingDistanceCalculationType] def: 0 min: 0 max: 3 set: set]];

    // Vernier stuff
    [self setVernierType: [self chckInt: [self vernierType] def: 0 min: 0 max: 1 set: set]]; // 2 or 3 bars
    [self setVernierWidth: [self chckFlt: [self vernierWidth] def: 1.0 min: 0.1 max: 120 set: set]]; // in arcminutes
    [self setVernierLength: [self chckFlt: [self vernierLength] def: 15.0 min: 0.1 max: 1200 set: set]];
    [self setVernierGap: [self chckFlt: [self vernierGap] def: 0.2 min: 0.0 max: 120 set: set]];

    
    // Contrast stuff
    [self setGammaValue: [self chckFlt: [self gammaValue] def: 1.7 min: 0.8 max: 4 set: set]];
    [self setContrastEasyTrials: [self chckBool: [self contrastEasyTrials] def: YES set: set]];
    [self setContrastDarkOnLight: [self chckBool: [self contrastDarkOnLight] def: YES set: set]];
    [self setContrastOptotypeDiameter: [self chckFlt: [self contrastOptotypeDiameter] def: 50 min: 1 max: 500 set: set]];
    [self setContrastShowFixMark: [self chckBool: [self contrastShowFixMark] def: YES set: set]];
    [self setContrastTimeoutFixmark: [self chckFlt: [self contrastTimeoutFixmark] def: 500 min: 20 max: 5000 set: set]];
    [self setContrastMaxLogCSWeber: [self chckFlt: [self contrastMaxLogCSWeber] def: 2.4 min: 1.5 max: 3 set: set]];
    
    [[CPUserDefaults standardUserDefaults] synchronize];
}


+ (void) calculateMaxPossibleDecimalAcuity { //console.info("Settings>calculateMaxPossibleDecimalAcuity");
    var maxPossibleAcuityVal = [Misc decVAFromGapPixels: 1.0];
    // Correction for threshold underestimation of ascending procedures (as opposed to our bracketing one)
    maxPossibleAcuityVal = [self threshCorrection] ? maxPossibleAcuityVal * 0.891 : maxPossibleAcuityVal;
    [self setMaxPossibleDecimalAcuityLocalisedString: [Misc stringFromNumber: maxPossibleAcuityVal decimals: 2 localised: YES]];
    [self setMinPossibleLogMARLocalisedString: [Misc stringFromNumber: [Misc logMARfromDecVA: maxPossibleAcuityVal] decimals: 2 localised: YES]];
}


// contrast in %. 100%: background fully white, foreground fully dark. -100%: inverted
+ (void) calculateAcuityForeBackColorsFromContrast { //console.info("Settings>calculateAcuityForeBackColorsFromContrast");
    var cnt = [Misc contrastMichelsonFromWeberPercent: [self contrastAcuityWeber]];

    var temp = [Misc lowerLuminanceFromContrastMilsn: cnt];  temp = [Misc devicegrayFromLuminance: temp];
    [self setAcuityForeColor: [CPColor colorWithWhite: temp alpha: 1]];

    temp = [Misc upperLuminanceFromContrastMilsn: cnt];  temp = [Misc devicegrayFromLuminance: temp];
    [self setAcuityBackColor: [CPColor colorWithWhite: temp alpha: 1]];
    
    [[CPNotificationCenter defaultCenter] postNotificationName: "copyForeBackColorsFromSettings" object: nil];
}


// when new defaults are added, kDateOfCurrentSettingsVersion is updated. That tells FrACT that all settings need to be defaulted.
+ (BOOL) needNewDefaults {
    return [self dateSettingsVersion] != kDateOfCurrentSettingsVersion;
}
+ (void) checkDefaults { //console.info("Settings>checkDefaults");
    if ([self needNewDefaults]) {
// var alert = [CPAlert alertWithMessageText: "»FrACT«: First run or major version change" defaultButton: "OK" alternateButton: nil otherButton: nil informativeTextWithFormat: "\rAll Settings are reset to their default values, please check them.\r\n\r\n[If all Settings are empty, simply reload, next time they'll be fine.]"]; [alert runModal];
        [self setDefaults];
    } else {
        [self allNotCheckButSet: NO];
    }
    [[CPUserDefaults standardUserDefaults] synchronize];
}


+ (void) setDefaults { //console.info("Settings>setDefaults");
    [self allNotCheckButSet: YES];
}


+ (BOOL) isNotCalibrated {
    [self checkDefaults];
    return (([self distanceInCM]==kDefaultDistanceInCM) || ([self calBarLengthInMM] == kDefaultCalibrationBarLengthInMM));
}


+ (CPString) dateSettingsVersion { //console.info("Settings>dateSettingsVersion");
    return [[CPUserDefaults standardUserDefaults] objectForKey: "dateSettingsVersion"];
}
+ (void) setDateSettingsVersion: (CPString) value { //console.info("Settings>setDatesettingsVersion");
    [[CPUserDefaults standardUserDefaults] setObject: value forKey: "dateSettingsVersion"];
}


///////////////////////////////////////////////////////////
// for all tests
+ (int) nTrials { //console.info("Settings>nTrials");
    switch ([self nAlternatives]) {
        case 2:  return [self nTrials02];  break;
        case 4:  return [self nTrials04];  break;
        default:  return [self nTrials08];
    }
}

+ (int) nTrials02 { //console.info("Settings>nTrials02");
    var t = [[CPUserDefaults standardUserDefaults] integerForKey: "nTrials02"]; //console.info(t);
    return t;
}
+ (void) setNTrials02: (int) value { //console.info("Settings>nTrials02");
    [[CPUserDefaults standardUserDefaults] setInteger: value forKey: "nTrials02"];
}

+ (int) nTrials04 { //console.info("Settings>nTrials04");
    return [[CPUserDefaults standardUserDefaults] integerForKey: "nTrials04"];
}
+ (void) setNTrials04: (int) value {
    [[CPUserDefaults standardUserDefaults] setInteger: value forKey: "nTrials04"];
}

+ (int) nTrials08 {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "nTrials08"];
}
+ (void) setNTrials08: (int) value {
    [[CPUserDefaults standardUserDefaults] setInteger: value forKey: "nTrials08"];
}

+ (int) nAlternatives { //console.info("Settings>nAlternatives");
    switch ([[CPUserDefaults standardUserDefaults] integerForKey: "nAlternativesIndex"]) {
        case 0:  return 2;  break;
        case 1:  return 4;  break;
        case 2:  return 8;  break;
    }
}

+ (BOOL) obliqueOnly {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "obliqueOnly"];
}
+ (void) setObliqueOnly: (BOOL) value {
    [[CPUserDefaults standardUserDefaults] setBool: value forKey: "obliqueOnly"];
}


+ (float) distanceInCM {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "distanceInCM"];
}
+ (void)setDistanceInCM: (float) value {
    [[CPUserDefaults standardUserDefaults] setFloat: value forKey: "distanceInCM"];
}

+ (float) calBarLengthInMM {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "calBarLengthInMM"];
}
+ (void)setCalBarLengthInMM: (float) value {
    [[CPUserDefaults standardUserDefaults] setFloat: value forKey: "calBarLengthInMM"];
}

+ (float) calBarLengthInPixel {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "calBarLengthInPixel"];
}
+ (void)setCalBarLengthInPixel: (float) value {
    [[CPUserDefaults standardUserDefaults] setFloat: value forKey: "calBarLengthInPixel"];
}


+ (BOOL) responseInfoAtStart {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "responseInfoAtStart"];
}
+ (void) setResponseInfoAtStart: (BOOL) value {
    [[CPUserDefaults standardUserDefaults] setBool: value forKey: "responseInfoAtStart"];
}


+ (int) testOnFive {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "testOnFive"];
}
+ (void) setTestOnFive: (int) value {
    [[CPUserDefaults standardUserDefaults] setInteger: value forKey: "testOnFive"];
}


+ (int) nOfRuns2Recall {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "nOfRuns2Recall"];
}
+ (void) setNOfRuns2Recall: (float) value {
    [[CPUserDefaults standardUserDefaults] setInteger: value forKey: "nOfRuns2Recall"];
}


+ (float) eccentXInDeg {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "eccentXInDeg"];
}
+ (void) setEccentXInDeg: (float) value {
    [[CPUserDefaults standardUserDefaults] setFloat: value forKey: "eccentXInDeg"];
}
+ (float) eccentYInDeg {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "eccentYInDeg"];
}
+ (void) setEccentYInDeg: (float) value {
    [[CPUserDefaults standardUserDefaults] setFloat: value forKey: "eccentYInDeg"];
}
+ (BOOL) eccentShowCenterFixMark {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "eccentShowCenterFixMark"];
}
+ (void) setEccentShowCenterFixMark: (BOOL) value {
    [[CPUserDefaults standardUserDefaults] setBool: value forKey: "eccentShowCenterFixMark"];
}


+ (BOOL) mobileOrientation {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "mobileOrientation"];
}
+ (void) setMobileOrientation: (BOOL) value {
    [[CPUserDefaults standardUserDefaults] setBool: value forKey: "mobileOrientation"];
}


+ (BOOL) autoFullScreen {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "autoFullScreen"];
}
+ (void) setAutoFullScreen: (BOOL) value {
    [[CPUserDefaults standardUserDefaults] setBool: value forKey: "autoFullScreen"];
}



+ (int) displayTransform {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "displayTransform"];
}
+ (void) setDisplayTransform: (int) value {
    [[CPUserDefaults standardUserDefaults] setInteger: value forKey: "displayTransform"];
}


+ (BOOL) trialInfo {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "trialInfo"];
}
+ (void) setTrialInfo: (BOOL) value {
    [[CPUserDefaults standardUserDefaults] setBool: value forKey: "trialInfo"];
}


+ (int) trialInfoFontSize {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "trialInfoFontSize"];
}
+ (void) setTrialInfoFontSize: (float) value {
    [[CPUserDefaults standardUserDefaults] setInteger: value forKey: "trialInfoFontSize"];
}


+ (float) timeoutResponseSeconds {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "timeoutResponseSeconds"];
}
+ (void) setTimeoutResponseSeconds: (float) value {
    [[CPUserDefaults standardUserDefaults] setFloat: value forKey: "timeoutResponseSeconds"];
}

+ (float) timeoutDisplaySeconds {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "timeoutDisplaySeconds"];
}
+ (void) setTimeoutDisplaySeconds: (float) value {
    [[CPUserDefaults standardUserDefaults] setFloat: value forKey: "timeoutDisplaySeconds"];
}

+ (float) maskTimeOnResponseInMS {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "maskTimeOnResponseInMS"];
}
+ (void)setMaskTimeOnResponseInMS: (float) value {
    [[CPUserDefaults standardUserDefaults] setFloat: value forKey: "maskTimeOnResponseInMS"];
}


+ (int) results2clipboard {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "results2clipboard"];
}
+ (void) setResults2clipboard: (float) value {
    [[CPUserDefaults standardUserDefaults] setInteger: value forKey: "results2clipboard"];
}
+ (BOOL) results2clipboardSilent {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "results2clipboardSilent"];
}
+ (void) setResults2clipboardSilent: (BOOL) value {
    [[CPUserDefaults standardUserDefaults] setBool: value forKey: "results2clipboardSilent"];
}


+ (int) auditoryFeedback {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "auditoryFeedback"];
}
+ (void) setAuditoryFeedback: (float) value {
    [[CPUserDefaults standardUserDefaults] setInteger: value forKey: "auditoryFeedback"];
}


+ (int) visualFeedback {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "visualFeedback"];
}
+ (void) setVisualFeedback: (float) value {
    [[CPUserDefaults standardUserDefaults] setInteger: value forKey: "visualFeedback"];
}


+ (BOOL) auditoryFeedbackWhenDone {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "auditoryFeedbackWhenDone"];
}
+ (void) setAuditoryFeedbackWhenDone: (BOOL) value {
    [[CPUserDefaults standardUserDefaults] setBool: value forKey: "auditoryFeedbackWhenDone"];
}


+ (float) soundVolume { // from 1 to 100%.
    var theValue = [[CPUserDefaults standardUserDefaults] floatForKey: "soundVolume"];
    if (theValue < 1) { // really need this???
        theValue = 20;  // if 0 then it did not go through defaulting; 0 not allowed
        [self setSoundVolume: theValue];
    }
    if (theValue > 100) { // really necessary?
        theValue = 100;  [self setSoundVolume: theValue];
    }
    return theValue;
}
+ (void) setSoundVolume: (float) value {
    [[CPUserDefaults standardUserDefaults] setFloat: value forKey: "soundVolume"];
}


+ (BOOL) rewardPicturesWhenDone {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "rewardPicturesWhenDone"];
}
+ (void)setRewardPicturesWhenDone: (BOOL) value {
    [[CPUserDefaults standardUserDefaults] setBool: value forKey: "rewardPicturesWhenDone"];
}
+ (float) timeoutRewardPicturesInSeconds {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "timeoutRewardPicturesInSeconds"];
}
+ (void) setTimeoutRewardPicturesInSeconds: (float) value { //console.info("Settings>setTimeoutRewardPicturesInSeconds");
    [[CPUserDefaults standardUserDefaults] setFloat: value forKey: "timeoutRewardPicturesInSeconds"];
}


////////////////////////


function _decimalMarkCharFindHelper(currentValue) {
    return (currentValue.type === "decimal"); // arrow syntax not work in Cappuccino, need helper fun
}
+ (char) decimalMarkChar { //console.info("settings>decimalMarkChar");
    var _decimalMarkChar = ".";
    switch ([[CPUserDefaults standardUserDefaults] integerForKey: "decimalMarkCharIndex"]) {
        case 1: _decimalMarkChar = "."; break;
        case 2: _decimalMarkChar = ","; break;
        default:
            try {
                var tArray = Intl.NumberFormat().formatToParts(1.3); // "1.3" surely has a decimal mark
                _decimalMarkChar = tArray.find(_decimalMarkCharFindHelper).value;
            }
            catch(e) { // avoid global error catcher
                console.log("Intl.NumberFormat throws error: ", e);
            }
    }    //console.info("_decimalMarkChar: ", _decimalMarkChar)
    return _decimalMarkChar;
}
+ (void) setDecimalMarkChar: (char) mark {
    var idx = 0; // auto
    if (mark == ".") idx = 1;
    if (mark == ",") idx = 2;
    [[CPUserDefaults standardUserDefaults] setInteger: idx forKey: "decimalMarkCharIndex"];
}



+ (BOOL) enableTouchControls {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "enableTouchControls"];
}
+ (void) setEnableTouchControls: (BOOL) value {
    [[CPUserDefaults standardUserDefaults] setBool: value forKey: "enableTouchControls"];
}


+ (CPColor) windowBackgroundColor { //console.info("Settings>windowBackgroundColor");
    var theData = [[CPUserDefaults standardUserDefaults] stringForKey: "windowBackgroundColor"];
    if (theData == nil) theData = "FFFFEE"; // safety measure and default
    var c = [CPColor colorWithHexString: theData]; //console.info("Settings>windowBackgroundColor:", c);
    //console.info("Settings>windowBackgroundColor", c);
    return c;
}
+ (void) setWindowBackgroundColor: (CPColor) theColor { //console.info("Settings>setWindowBackgroundColor:", theColor);
    [[CPUserDefaults standardUserDefaults] setObject: [theColor hexString] forKey: "windowBackgroundColor"];
}


+ (float) maxPossibleDecimalAcuity {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "maxPossibleDecimalAcuity"];
}
+ (void) setMaxPossibleDecimalAcuity: (float) value {
    [[CPUserDefaults standardUserDefaults] setFloat: value forKey: "maxPossibleDecimalAcuity"];
}
+ (CPString) maxPossibleDecimalAcuityLocalisedString {
    return [[CPUserDefaults standardUserDefaults] objectForKey: "maxPossibleDecimalAcuityLocalisedString"];
}
+ (void) setMaxPossibleDecimalAcuityLocalisedString: (CPString) value {
    [[CPUserDefaults standardUserDefaults] setObject: value forKey: "maxPossibleDecimalAcuityLocalisedString"];
}

+ (float) minPossibleLogMAR {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "minPossibleLogMAR"];
}
+ (void) setMinPossibleLogMAR: (float) value {
    [[CPUserDefaults standardUserDefaults] setFloat: value forKey: "minPossibleLogMAR"];
}
+ (float) minPossibleLogMARLocalisedString {
    return [[CPUserDefaults standardUserDefaults] objectForKey: "minPossibleLogMARLocalisedString"];
}
+ (void) setMinPossibleLogMARLocalisedString: (CPString) value {
    [[CPUserDefaults standardUserDefaults] setObject: value forKey: "minPossibleLogMARLocalisedString"];
}


+ (BOOL) threshCorrection {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "threshCorrection"];
}
+ (void)setThreshCorrection: (BOOL) value {
    [[CPUserDefaults standardUserDefaults] setBool: value forKey: "threshCorrection"];
}


+ (float) maxDisplayedAcuity {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "maxDisplayedAcuity"];
}
+ (void) setMaxDisplayedAcuity: (float) value {
    [[CPUserDefaults standardUserDefaults] setFloat: value forKey: "maxDisplayedAcuity"];
}


+ (int) crowdingType {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "crowdingType"];
}
+ (void) setCrowdingType: (int) value {
    [[CPUserDefaults standardUserDefaults] setInteger: value forKey: "crowdingType"];
}


+ (int) crowdingDistanceCalculationType {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "crowdingDistanceCalculationType"];
}
+ (void) setCrowdingDistanceCalculationType: (float) value {
    [[CPUserDefaults standardUserDefaults] setInteger: value forKey: "crowdingDistanceCalculationType"];
}


+ (BOOL) acuityFormatDecimal {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "acuityFormatDecimal"];
}
+ (void) setAcuityFormatDecimal: (BOOL) value {
    [[CPUserDefaults standardUserDefaults] setBool: value forKey: "acuityFormatDecimal"];
}


+ (BOOL) acuityFormatLogMAR {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "acuityFormatLogMAR"];
}
+ (void) setAcuityFormatLogMAR: (BOOL) value {
    [[CPUserDefaults standardUserDefaults] setBool: value forKey: "acuityFormatLogMAR"];
}


+ (BOOL) acuityFormatSnellenFractionFoot {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "acuityFormatSnellenFractionFoot"];
}
+ (void) setAcuityFormatSnellenFractionFoot: (BOOL) value {
    [[CPUserDefaults standardUserDefaults] setBool: value forKey: "acuityFormatSnellenFractionFoot"];
}
+ (BOOL) forceSnellen20 {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "forceSnellen20"];
}
+ (void) setForceSnellen20: (BOOL) value {
    [[CPUserDefaults standardUserDefaults] setBool: value forKey: "forceSnellen20"];
}


+ (BOOL) showCI95 {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "showCI95"];
}
+ (void) setShowCI95: (BOOL) value {
    [[CPUserDefaults standardUserDefaults] setBool: value forKey: "showCI95"];
}


+ (float) contrastAcuityWeber { //console.info("Settings>contrastAcuityWeber: ", [[CPUserDefaults standardUserDefaults] floatForKey: "contrastAcuityWeber"]);
    return [[CPUserDefaults standardUserDefaults] floatForKey: "contrastAcuityWeber"];
}
+ (void) setContrastAcuityWeber: (float) value { //console.info("Settings>setContrastAcuityWeber: ", value);
    [[CPUserDefaults standardUserDefaults] setFloat: value forKey: "contrastAcuityWeber"];
}


// CPColors are stored as hexString because the archiver does not work in Cappuccino. Why not??
+ (CPColor) acuityForeColor { //console.info("Settings>acuityForeColor");
    var theData = [[CPUserDefaults standardUserDefaults] stringForKey: "acuityForeColor"];
//    console.info("Settings>acuityForeColor>theData: ", theData)
    if (theData == nil) theData = "FFFFFF"; // safety measure
    var c = [CPColor colorWithHexString: theData]; //console.info("Settings>acuityForeColor:", c);
    return c;
}
+ (void) setAcuityForeColor: (CPColor) theColor { //console.info("Settings>setAcuityBackColor:", theColor);
    [[CPUserDefaults standardUserDefaults] setObject: [theColor hexString] forKey: "acuityForeColor"];
}
+ (CPColor) acuityBackColor { //console.info("Settings>acuityBackColor");
    var theData = [[CPUserDefaults standardUserDefaults] stringForKey: "acuityBackColor"];
    //console.info("Settings>acuityBackColor>theData: ", theData)
    if (theData == nil) theData = "000000"; // safety measure
    var c = [CPColor colorWithHexString: theData]; //console.info("Settings>acuityBackColor:", c);
    return c;
}
+ (void) setAcuityBackColor: (CPColor) theColor { //console.info("Settings>setAcuityBackColor:", theColor);
    [[CPUserDefaults standardUserDefaults] setObject: [theColor hexString] forKey: "acuityBackColor"];
}


+ (BOOL) acuityEasyTrials {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "acuityEasyTrials"];
}
+ (void) setAcuityEasyTrials: (BOOL) value {
    [[CPUserDefaults standardUserDefaults] setBool: value forKey: "acuityEasyTrials"];
}


// Vernier stuff
+ (int) vernierType {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "vernierType"];
}
+ (void) setVernierType: (float) value {
    [[CPUserDefaults standardUserDefaults] setInteger: value forKey: "vernierType"];
}

+ (float) vernierWidth {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "vernierWidth"];
}
+ (void) setVernierWidth: (float) value {
    [[CPUserDefaults standardUserDefaults] setFloat: value forKey: "vernierWidth"];
}

+ (float) vernierLength {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "vernierLength"];
}
+ (void) setVernierLength: (float) value {
    [[CPUserDefaults standardUserDefaults] setFloat: value forKey: "vernierLength"];
}

+ (float) vernierGap {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "vernierGap"];
}
+ (void) setVernierGap: (float) value {
    [[CPUserDefaults standardUserDefaults] setFloat: value forKey: "vernierGap"];
}


// Contrast stuff
+ (BOOL) contrastEasyTrials {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "contrastEasyTrials"];
}
+ (void) setContrastEasyTrials: (BOOL) value {
    [[CPUserDefaults standardUserDefaults] setBool: value forKey: "contrastEasyTrials"];
}

+ (BOOL) contrastDarkOnLight {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "contrastDarkOnLight"];
}
+ (void) setContrastDarkOnLight: (BOOL) value {
    [[CPUserDefaults standardUserDefaults] setBool: value forKey: "contrastDarkOnLight"];
}

+ (float) contrastOptotypeDiameter {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "contrastOptotypeDiameter"];
}
+ (void) setContrastOptotypeDiameter: (float) value {
    [[CPUserDefaults standardUserDefaults] setFloat: value forKey: "contrastOptotypeDiameter"];
}

+ (BOOL) contrastShowFixMark {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "contrastShowFixMark"];
}
+ (void) setContrastShowFixMark: (BOOL) value {
    [[CPUserDefaults standardUserDefaults] setBool: value forKey: "contrastShowFixMark"];
}

+ (float) contrastTimeoutFixmark {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "contrastTimeoutFixmark"];
}
+ (void) setContrastTimeoutFixmark: (float) value {
    [[CPUserDefaults standardUserDefaults] setFloat: value forKey: "contrastTimeoutFixmark"];
}

+ (float) contrastMaxLogCSWeber {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "contrastMaxLogCSWeber"];
}
+ (void) setContrastMaxLogCSWeber: (float) value {
    [[CPUserDefaults standardUserDefaults] setFloat: value forKey: "contrastMaxLogCSWeber"];
}

+ (float) gammaValue {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "gammaValue"];
}
+ (void) setGammaValue: (float) value {
    [[CPUserDefaults standardUserDefaults] setFloat: value forKey: "gammaValue"];
}


@end
