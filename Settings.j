/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

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
@import "MiscLight.j"
@import "MiscSpace.j"

@implementation Settings: CPUserDefaultsController


/**
 Helpers
 If `set` is true, the default `dflt` is set,
 otherwise check if outside of range or nil, if so set to default.
 A little chatty since no overloading available, also: BOOL/int/float are all of class CPNumber.
 */
+ (BOOL) checkBool: (BOOL) val dflt: (BOOL) def set: (BOOL) set {
    //console.info("chckBool ", val, "set: ", set);
    if (!set && !isNaN(val)) return val;
    return def;
}
+ (int) checkNum: (CPNumber) val dflt: (int) def min: (int) min max: (int) max set: (BOOL) set { // console.info("chckInt ", val);
    if (!set && !isNaN(val) && (val <= max) && (val >= min)) return val;
    return def;
}


// CPColors are stored as hexString because the archiver does not work in Cappuccino. Why not??
//https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/DrawColor/Tasks/StoringNSColorInDefaults.html
+ (CPColor) colorForKey: (CPString) keyString fallbackInHex: (CPString) fallbackInHex {
    let theData = [[CPUserDefaults standardUserDefaults] stringForKey: keyString];
    if (theData == nil) theData = fallbackInHex; // safety measure and default
    return [CPColor colorWithHexString: theData];
}
+ (void) setColor: (CPColor) theColor forKey: (CPString) keyString {
    [[CPUserDefaults standardUserDefaults] setObject: [theColor hexString] forKey: keyString];
}


/**
 Test all settings for in-range (set==NO) or set the to defaults (set==YES)
 */
+ (void) allNotCheckButSet: (BOOL) set {
    [[CPUserDefaults standardUserDefaults] synchronize];
    if (set) {
        [self setDateSettingsVersion: kDateOfCurrentSettingsVersion];
        // for `CPColor` I have no `CheckCol` (yet) #tbd, worth it?
        [self setWindowBackgroundColor: [CPColor colorWithRed: 1 green: 1 blue: 0.9 alpha: 1]];
        [self setGratingForeColor: [CPColor lightGrayColor]];
        [self setGratingBackColor: [CPColor darkGrayColor]];
        [self setPresetName: "Standard Defaults"];// synchronise with corresponding item in Presets!
    }

    // need to check before setNAlternativesIndex 'cause oblique might force to index=0
    [self setGratingObliqueOnly: [self checkBool: [self gratingObliqueOnly] dflt: NO set: set]];
    // for all tests
    [self setNAlternativesIndex: [self checkNum: [self nAlternativesIndex] dflt: 2 min: 0 max: 2 set:set]];//dflt:8
    [self setNTrials02: [self checkNum: [self nTrials02] dflt: 32 min: 1 max: 200 set: set]];
    [self setNTrials04: [self checkNum: [self nTrials04] dflt: 24 min: 1 max: 200 set: set]];
    [self setNTrials08: [self checkNum: [self nTrials08] dflt: 18 min: 1 max: 200 set: set]];

    [self setDistanceInCM: [self checkNum: [self distanceInCM] dflt: gDefaultDistanceInCM min: 1 max: 2500 set: set]];
    [self setCalBarLengthInMM: [self checkNum: [self calBarLengthInMM] dflt: gDefaultCalibrationBarLengthInMM min: 1 max: 10000 set: set]];

    [self setResponseInfoAtStart: [self checkBool: [self responseInfoAtStart] dflt: YES set: set]];
    [self setEnableTouchControls: [self checkBool: [self enableTouchControls] dflt: YES set: set]];

    [self setDecimalMarkCharIndex: [self checkNum: [self decimalMarkCharIndex] dflt: kDecimalMarkCharIndexAuto min: kDecimalMarkCharIndexAuto max: kDecimalMarkCharIndexComma set: set]];

    [self setTestOnFive: [self checkNum: [self testOnFive] dflt: kTestAcuityLett min: kTestNone max: kTestAcuityLineByLine set: set]]; // 1: Sloan Letters

    //[self setNOfRuns2Recall: [self checkNum: [self nOfRuns2Recall] dflt: 0 min: 0 max: 100 set: set]];

    [self setEccentXInDeg: [self checkNum: [self eccentXInDeg] dflt: 0 min: -99 max: 99 set: set]];
    [self setEccentYInDeg: [self checkNum: [self eccentYInDeg] dflt: 0 min: -99 max: 99 set: set]];
    [self setEccentShowCenterFixMark: [self checkBool: [self eccentShowCenterFixMark] dflt: YES set: set]];

    [self setAutoFullScreen: [self checkBool: [self autoFullScreen] dflt: NO set: set]];

    [self setMobileOrientation: [self checkBool: [self mobileOrientation] dflt: YES set: set]];

    // 0=normal, 1=mirror horizontally, 2=mirror vertically, 3=both=rot180°
    [self setDisplayTransform: [self checkNum: [self displayTransform] dflt: 0 min: 0 max: 3 set: set]];

    [self setTrialInfo: [self checkBool: [self trialInfo] dflt: YES set: set]];
    [self setTrialInfoFontSize: [self checkNum: [self trialInfoFontSize] dflt: 10 min: 4 max: 48 set: set]];

    [self setTimeoutResponseSeconds: [self checkNum: [self timeoutResponseSeconds] dflt: 30 min: 0.1 max: 9999 set: set]];
    [self setTimeoutDisplaySeconds: [self checkNum: [self timeoutDisplaySeconds] dflt: 30 min: 0.1 max: 9999 set: set]];
    [self setMaskTimeOnResponseInMS: [self checkNum: [self timeoutDisplaySeconds] dflt: 0 min: 0 max: 9999 set: set]];

    [self setResults2clipboard: [self checkNum: [self results2clipboard] dflt: kResults2ClipNone min: kResults2ClipNone max: kResults2ClipFullHistory set: set]];
    [self setResults2clipboardSilent: [self checkBool: [self results2clipboardSilent] dflt: NO set: set]];

    // 0: none, 1: always, 2: on correct, 3: w/ info
    [self setAuditoryFeedback: [self checkNum: [self auditoryFeedback] dflt: 3 min: 0 max: 3 set: set]];
    // 0: none, 1: always, 2: on correct, 3: w/ info
    [self setVisualFeedback: [self checkNum: [self visualFeedback] dflt: 0 min: 0 max: 3 set: set]]; // NOT IN USE
    [self setAuditoryFeedbackWhenDone: [self checkBool: [self auditoryFeedbackWhenDone] dflt: YES set: set]];
    [self setSoundVolume: [self checkNum: [self soundVolume] dflt: 20 min: 1 max: 100 set: set]];

    [self setRewardPicturesWhenDone: [self checkBool: [self rewardPicturesWhenDone] dflt: NO set: set]];
    [self setTimeoutRewardPicturesInSeconds: [self checkNum: [self timeoutRewardPicturesInSeconds] dflt: 5 min: 0.1 max: 999 set: set]];

    [self setEmbedInNoise: [self checkBool: [self embedInNoise] dflt: NO set: set]];
    [self setNoiseContrast: [self checkNum: [self noiseContrast] dflt: 50 min: 0 max: 100 set: set]];

    // Acuity stuff
    [self setIsAcuityColor: [self checkBool: [self isAcuityColor] dflt: NO set: set]];
    [self setObliqueOnly: [self checkBool: [self obliqueOnly] dflt: NO set: set]]; // only applies to acuity with 4 Landolt orienations
    [self setContrastAcuityWeber: [self checkNum: [self contrastAcuityWeber] dflt: 100 min: -1E6 max: 100 set: set]];
    [self calculateAcuityForeBackColorsFromContrast];
    [self setAcuityEasyTrials: [self checkBool: [self acuityEasyTrials] dflt: YES set: set]];
    [self setMaxDisplayedAcuity: [self checkNum: [self maxDisplayedAcuity] dflt: 2 min: 1 max: 99 set: set]];
    [self setMinStrokeAcuity: [self checkNum: [self minStrokeAcuity] dflt: 0.5 min: 0.5 max: 5 set: set]];
    [self setAcuityStartingLogMAR: [self checkNum: [self acuityStartingLogMAR] dflt: 1 min: 0.3 max: 2.5 set: set]];
    [self setMargin4MaxOptotypeIndex: [self checkNum: [self margin4MaxOptotypeIndex] dflt: 1 min: 0 max: 4 set: set]];
    [self setAutoRunIndex: [self checkNum: [self autoRunIndex] dflt: kAutoRunIndexNone min: kAutoRunIndexNone max: kAutoRunIndexLow set: set]];
    [self setThreshCorrection: [self checkBool: [self threshCorrection] dflt: YES set: set]];
    [self setAcuityFormatDecimal: [self checkBool: [self acuityFormatDecimal] dflt: YES set: set]];
    [self setAcuityFormatLogMAR: [self checkBool: [self acuityFormatLogMAR] dflt: YES set: set]];
    [self setAcuityFormatSnellenFractionFoot: [self checkBool: [self acuityFormatSnellenFractionFoot] dflt: NO set: set]];
    [self setForceSnellen20: [self checkBool: [self forceSnellen20] dflt: NO set: set]];
    [self setShowCI95: [self checkBool: [self showCI95] dflt: NO set: set]];
    [self calculateMaxPossibleDecimalAcuity];

    // Crowding, crowdingType: 0 = none, 1: flanking bars, 2 = flanking rings, 3 = surounding bars, 4: surounding ring, 5 = surounding square, 6 = row of optotypes
    [self setCrowdingType: [self checkNum: [self crowdingType] dflt: 0 min: 0 max: 6 set: set]];
    // 0 = 2·stroke between rings, 1 = fixed 2.6 arcmin between rings, 2 = fixed 30', 3 = like ETDRS
    [self setCrowdingDistanceCalculationType: [self checkNum: [self crowdingDistanceCalculationType] dflt: 0 min: 0 max: 3 set: set]];

    [self setCrowdingDistanceCalculationType: [self checkNum: [self crowdingDistanceCalculationType] dflt: 0 min: 0 max: 3 set: set]];

    // Line-by-line stuff
    [self setTestOnLineByLine: [self checkNum: [self testOnLineByLine] dflt: 1 min: 1 max: 4 set: set]]; // 1: Sloan Letters. 0: nicht erlaubt, 2: Landolt, 3…
    [self setTestOnLineByLineDistanceType: [self checkNum: [self testOnLineByLineDistanceType] dflt: 1 min: 0 max: 1 set: set]]; // 0: DIN-EN-ISO, 1: ETDRS
    [self setLineByLineHeadcountIndex: [self checkNum: [self lineByLineHeadcountIndex] dflt: 2 min: 0 max: 4 set: set]]; // 0: "1", 2: "3", 3: "5", 4: "7"
    [self setLineByLineChartMode: [self checkBool: [self lineByLineChartMode] dflt: NO set: set]];
    [self setLineByLineChartModeConstantVA: [self checkBool: [self lineByLineChartModeConstantVA] dflt: NO set: set]];

    // Vernier stuff
    [self setVernierType: [self checkNum: [self vernierType] dflt: 0 min: 0 max: 1 set: set]]; // 2 or 3 bars
    [self setVernierWidth: [self checkNum: [self vernierWidth] dflt: 1.0 min: 0.1 max: 120 set: set]]; // in arcminutes
    [self setVernierLength: [self checkNum: [self vernierLength] dflt: 15.0 min: 0.1 max: 1200 set: set]];
    [self setVernierGap: [self checkNum: [self vernierGap] dflt: 0.2 min: 0.0 max: 120 set: set]];


    // Contrast stuff
    [self setGammaValue: [self checkNum: [self gammaValue] dflt: 2.0 min: 0.8 max: 4 set: set]];
    [self setContrastEasyTrials: [self checkBool: [self contrastEasyTrials] dflt: YES set: set]];
    [self setContrastDarkOnLight: [self checkBool: [self contrastDarkOnLight] dflt: YES set: set]];
    [self setContrastOptotypeDiameter: [self checkNum: [self contrastOptotypeDiameter] dflt: 50 min: 1 max: 2500 set: set]];
    [self setContrastShowFixMark: [self checkBool: [self contrastShowFixMark] dflt: YES set: set]];
    [self setContrastTimeoutFixmark: [self checkNum: [self contrastTimeoutFixmark] dflt: 500 min: 20 max: 5000 set: set]];
    [self setContrastMaxLogCSWeber: [self checkNum: [self contrastMaxLogCSWeber] dflt: 3.0 min: 1.5 max: gMaxAllowedLogCSWeber set: set]];
    [self setContrastBitStealing: [self checkBool: [self contrastBitStealing] dflt: NO set: set]];
    [self setContrastDithering: [self checkBool: [self contrastDithering] dflt: YES set: set]];

    // Grating stuff
    [self setGratingCPD: [self checkNum: [self gratingCPD] dflt: 2.0 min: 0.01 max: 18 set: set]];
    [self setIsGratingMasked: [self checkBool: [self isGratingMasked] dflt: NO set: set]];
    [self setGratingDiaInDeg: [self checkNum: [self gratingDiaInDeg] dflt: 10.0 min: 1.0 max: 50 set: set]];
    [self setGratingUseErrorDiffusion: [self checkBool: [self gratingUseErrorDiffusion] dflt: YES set: set]];
    [self setGratingSineNotSquare: [self checkBool: [self gratingSineNotSquare] dflt: YES set: set]];
    [self setIsGratingColor: [self checkBool: [self isGratingColor] dflt: NO set: set]];
    [self setWhat2SweepIndex: [self checkNum: [self what2SweepIndex] dflt: 0 min: 0 max: 1 set: set]]; // 0: sweep contrast, 1: sweep spatial frequency
    [self setGratingCPDmin: [self checkNum: [self gratingCPDmin] dflt: 0.5 min: 0.01 max: 60 set: set]];
    [self setGratingCPDmax: [self checkNum: [self gratingCPDmax] dflt: 30 min: 0.01 max: 60 set: set]];
    [self setGratingContrastMichelsonPercent: [self checkNum: [self gratingContrastMichelsonPercent] dflt: 95 min: 0.3 max: 99 set: set]];

    // Misc stuff
    [self setSpecialBcmOn: [self checkBool: [self specialBcmOn] dflt: NO set: set]];
    [self setHideExitButton: [self checkBool: [self hideExitButton] dflt: NO set: set]];

    [self setSoundTrialYesIndex: [self checkNum: [self soundTrialYesIndex] dflt: 0 min: 0 max: gSoundsTrialYes.length-1 set: set]];
    [self setSoundTrialNoIndex: [self checkNum: [self soundTrialNoIndex] dflt: 0 min: 0 max: gSoundsTrialNo.length-1 set: set]];
    [self setSoundRunEndIndex: [self checkNum: [self soundRunEndIndex] dflt: 0 min: 0 max: gSoundsRunEnd.length-1 set: set]];

    [[CPUserDefaults standardUserDefaults] synchronize];
}


+ (void) calculateMaxPossibleDecimalAcuity { //console.info("Settings>calculateMaxPossibleDecimalAcuity");
    let maxPossibleAcuityVal = [MiscSpace decVAFromStrokePixels: 1.0];
    // Correction for threshold underestimation of ascending procedures (as opposed to our bracketing one)
    maxPossibleAcuityVal = [self threshCorrection] ? maxPossibleAcuityVal * 0.891 : maxPossibleAcuityVal;
    [self setMaxPossibleDecimalAcuityLocalisedString: [Misc stringFromNumber: maxPossibleAcuityVal decimals: 2 localised: YES]];
    [self setMinPossibleLogMAR: [MiscSpace logMARfromDecVA: maxPossibleAcuityVal]]; // needed for color
    [self setMinPossibleLogMARLocalisedString: [Misc stringFromNumber: [self minPossibleLogMAR] decimals: 2 localised: YES]];
    [self setDistanceInInchFromCM: [self distanceInCM]];
}


// contrast in %. 100%: background fully white, foreground fully dark. -100%: inverted
+ (void) calculateAcuityForeBackColorsFromContrast { //console.info("Settings>calculateAcuityForeBackColorsFromContrast");
    if ([self isAcuityColor]) return;
    const cnt = [MiscLight contrastMichelsonPercentFromWeberPercent: [self contrastAcuityWeber]];
    let temp = [MiscLight lowerLuminanceFromContrastMilsn: cnt];  temp = [MiscLight devicegrayFromLuminance: temp];
    gColorFore = [CPColor colorWithWhite: temp alpha: 1];
    [self setAcuityForeColor: gColorFore];
    temp = [MiscLight upperLuminanceFromContrastMilsn: cnt];  temp = [MiscLight devicegrayFromLuminance: temp];
    gColorBack = [CPColor colorWithWhite: temp alpha: 1];
    [self setAcuityBackColor: gColorBack];
    [[CPNotificationCenter defaultCenter] postNotificationName: "copyColorsFromSettings" object: nil];
}


/**
 Test if we neet to set all Settings to defaults
 When new defaults are added, kDateOfCurrentSettingsVersion is updated. That tells FrACT that all settings need to be defaulted.
 */
+ (BOOL) needNewDefaults {
    return [self dateSettingsVersion] != kDateOfCurrentSettingsVersion;
}
+ (void) checkDefaults { //console.info("Settings>checkDefaults");
    if ([self needNewDefaults]) {
        [self setDefaults];
    } else {
        [self allNotCheckButSet: NO];
    }
    [[CPUserDefaults standardUserDefaults] synchronize];
}


/**
 Set all settings to their default values
 */
+ (void) setDefaults { //console.info("Settings>setDefaults");
    [self allNotCheckButSet: YES];
}


+ (BOOL) isNotCalibrated {
    [self checkDefaults];
    return (([self distanceInCM] == gDefaultDistanceInCM) || ([self calBarLengthInMM] == gDefaultCalibrationBarLengthInMM));
}


+ (CPString) dateSettingsVersion { //console.info("Settings>dateSettingsVersion");
    return [[CPUserDefaults standardUserDefaults] stringForKey: "dateSettingsVersion"];
}
+ (void) setDateSettingsVersion: (CPString) val { //console.info("Settings>setDatesettingsVersion");
    [[CPUserDefaults standardUserDefaults] setObject: val forKey: "dateSettingsVersion"];
}


/**
 individual getters / setters for all settings
 */
///////////////////////////////////////////////////////////
// for all tests

+ (int) nAlternativesIndex { // 0: 2; 1: 4; 2: 8+
    const t = [[CPUserDefaults standardUserDefaults] integerForKey: "nAlternativesIndex"]; //console.info(t);
    return t;
}
+ (void) setNAlternativesIndex: (int) val {
    //[self setDfltIntForKey: "nAlternativesIndex"];
    [[CPUserDefaults standardUserDefaults] setInteger: val forKey: "nAlternativesIndex"];
}


+ (int) nTrials { //console.info("Settings>nTrials");
    switch ([self nAlternatives]) {
        case 2:  return [self nTrials02];  break;
        case 4:  return [self nTrials04];  break;
        default:  return [self nTrials08];
    }
}

+ (int) nTrials02 { //console.info("Settings>nTrials02");
    const t = [[CPUserDefaults standardUserDefaults] integerForKey: "nTrials02"]; //console.info(t);
    return t;
}
+ (void) setNTrials02: (int) val { //console.info("Settings>nTrials02");
    [[CPUserDefaults standardUserDefaults] setInteger: val forKey: "nTrials02"];
}

+ (int) nTrials04 { //console.info("Settings>nTrials04");
    return [[CPUserDefaults standardUserDefaults] integerForKey: "nTrials04"];
}
+ (void) setNTrials04: (int) val {
    [[CPUserDefaults standardUserDefaults] setInteger: val forKey: "nTrials04"];
}

+ (int) nTrials08 {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "nTrials08"];
}
+ (void) setNTrials08: (int) val {
    [[CPUserDefaults standardUserDefaults] setInteger: val forKey: "nTrials08"];
}

+ (int) nAlternatives { //console.info("Settings>nAlternatives");
    switch ([self nAlternativesIndex]) {
        case 0:  return 2;  break;
        case 1:  return 4;  break;
        default:  return 8; // case 2
    }
}

+ (BOOL) obliqueOnly {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "obliqueOnly"];
}
+ (void) setObliqueOnly: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "obliqueOnly"];
}


+ (float) distanceInCM {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "distanceInCM"];
}
+ (void) setDistanceInCM: (float) cm {
    [[CPUserDefaults standardUserDefaults] setFloat: cm forKey: "distanceInCM"];
    [self setDistanceInInchFromCM: cm];
}
+ (void) setDistanceInInchFromCM: (float) cm {
    const inch = [Misc stringFromNumber: cm / 2.54 decimals: 1 localised: YES];
    [self setDistanceInInchLocalisedString: inch];
}
+ (CPString) distanceInInchLocalisedString { //console.info("Settings>distanceInInchLocalisedString");
    return [[CPUserDefaults standardUserDefaults] floatForKey: "distanceInInchLocalisedString"];
}
+ (void) setDistanceInInchLocalisedString: (CPString) val {
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "distanceInInchLocalisedString"];
}

+ (float) calBarLengthInMM {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "calBarLengthInMM"];
}
+ (void)setCalBarLengthInMM: (float) val {
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "calBarLengthInMM"];
}


+ (BOOL) responseInfoAtStart {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "responseInfoAtStart"];
}
+ (void) setResponseInfoAtStart: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "responseInfoAtStart"];
}


+ (int) testOnFive {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "testOnFive"];
}
+ (void) setTestOnFive: (int) val {
    [[CPUserDefaults standardUserDefaults] setInteger: val forKey: "testOnFive"];
}


+ (int) nOfRuns2Recall { // not yet used
    return [[CPUserDefaults standardUserDefaults] integerForKey: "nOfRuns2Recall"];
}
+ (void) setNOfRuns2Recall: (float) val {
    [[CPUserDefaults standardUserDefaults] setInteger: val forKey: "nOfRuns2Recall"];
}


+ (float) eccentXInDeg {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "eccentXInDeg"];
}
+ (void) setEccentXInDeg: (float) val {
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "eccentXInDeg"];
}
+ (float) eccentYInDeg {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "eccentYInDeg"];
}
+ (void) setEccentYInDeg: (float) val {
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "eccentYInDeg"];
}
+ (BOOL) eccentShowCenterFixMark {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "eccentShowCenterFixMark"];
}
+ (void) setEccentShowCenterFixMark: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "eccentShowCenterFixMark"];
}


+ (BOOL) mobileOrientation {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "mobileOrientation"];
}
+ (void) setMobileOrientation: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "mobileOrientation"];
}


+ (BOOL) autoFullScreen {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "autoFullScreen"];
}
+ (void) setAutoFullScreen: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "autoFullScreen"];
}



+ (int) displayTransform {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "displayTransform"];
}
+ (void) setDisplayTransform: (int) val {
    [[CPUserDefaults standardUserDefaults] setInteger: val forKey: "displayTransform"];
}


+ (BOOL) trialInfo {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "trialInfo"];
}
+ (void) setTrialInfo: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "trialInfo"];
}


+ (int) trialInfoFontSize {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "trialInfoFontSize"];
}
+ (void) setTrialInfoFontSize: (float) val {
    [[CPUserDefaults standardUserDefaults] setInteger: val forKey: "trialInfoFontSize"];
}


+ (float) timeoutResponseSeconds {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "timeoutResponseSeconds"];
}
+ (void) setTimeoutResponseSeconds: (float) val {
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "timeoutResponseSeconds"];
}

+ (float) timeoutDisplaySeconds {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "timeoutDisplaySeconds"];
}
+ (void) setTimeoutDisplaySeconds: (float) val {
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "timeoutDisplaySeconds"];
}

+ (float) maskTimeOnResponseInMS {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "maskTimeOnResponseInMS"];
}
+ (void)setMaskTimeOnResponseInMS: (float) val {
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "maskTimeOnResponseInMS"];
}


+ (int) results2clipboard {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "results2clipboard"];
}
+ (void) setResults2clipboard: (int) val {
    [[CPUserDefaults standardUserDefaults] setInteger: val forKey: "results2clipboard"];
}
+ (BOOL) results2clipboardSilent {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "results2clipboardSilent"];
}
+ (void) setResults2clipboardSilent: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "results2clipboardSilent"];
}


+ (int) auditoryFeedback {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "auditoryFeedback"];
}
+ (void) setAuditoryFeedback: (int) val {
    [[CPUserDefaults standardUserDefaults] setInteger: val forKey: "auditoryFeedback"];
}


+ (int) visualFeedback {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "visualFeedback"];
}
+ (void) setVisualFeedback: (int) val {
    [[CPUserDefaults standardUserDefaults] setInteger: val forKey: "visualFeedback"];
}


+ (BOOL) auditoryFeedbackWhenDone {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "auditoryFeedbackWhenDone"];
}
+ (void) setAuditoryFeedbackWhenDone: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "auditoryFeedbackWhenDone"];
}


+ (float) soundVolume { // from 1 to 100%.
    let theValue = [[CPUserDefaults standardUserDefaults] floatForKey: "soundVolume"];
    if (theValue < 1) { // really need this???
        theValue = 20;  // if 0 then it did not go through defaulting; 0 not allowed
        [self setSoundVolume: theValue];
    }
    if (theValue > 100) { // really necessary?
        theValue = 100;  [self setSoundVolume: theValue];
    }
    return theValue;
}
+ (void) setSoundVolume: (float) val {
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "soundVolume"];
}


+ (BOOL) rewardPicturesWhenDone {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "rewardPicturesWhenDone"];
}
+ (void)setRewardPicturesWhenDone: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "rewardPicturesWhenDone"];
}
+ (float) timeoutRewardPicturesInSeconds {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "timeoutRewardPicturesInSeconds"];
}
+ (void) setTimeoutRewardPicturesInSeconds: (float) val { //console.info("Settings>setTimeoutRewardPicturesInSeconds");
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "timeoutRewardPicturesInSeconds"];
}


+ (BOOL) embedInNoise {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "embedInNoise"];
}
+ (void)setEmbedInNoise: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "embedInNoise"];
}
+ (int) noiseContrast {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "noiseContrast"];
}
+ (void) setNoiseContrast: (int) val {
    [[CPUserDefaults standardUserDefaults] setInteger: val forKey: "noiseContrast"];
}


+ (CPString) presetName {
    return [[CPUserDefaults standardUserDefaults] stringForKey: "presetName"];
}
+ (void) setPresetName: (CPString) val {
    [[CPUserDefaults standardUserDefaults] setObject: val forKey: "presetName"];
}


////////////////////////

+ (int) decimalMarkCharIndex {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "decimalMarkCharIndex"];
}
+ (void) setDecimalMarkCharIndex: (int) val {
    [[CPUserDefaults standardUserDefaults] setInteger: val forKey: "decimalMarkCharIndex"];
}
+ (CPString) decimalMarkChar { //console.info("settings>decimalMarkChar");
    let _mark = ".";
    switch ([self decimalMarkCharIndex]) {
        case 0: // "Automatic"
            try {
                const tArray = Intl.NumberFormat().formatToParts(1.3); // "1.3" has a decimal mark
                _mark = tArray.find(currentValue => currentValue.type === "decimal").value;
            }
            catch(e) { // avoid global error catcher, but log the problem
                console.log("“Intl.NumberFormat().formatToParts” throws error: ", e);
            } //console.info("_decimalMarkChar: ", _decimalMarkChar)
            break;
        case 2: // comma
            _mark = ","; break;
    }
    [self setDecimalMarkChar: _mark];
    return _mark;
}
+ (void) setDecimalMarkChar: (CPString) val {
    [[CPUserDefaults standardUserDefaults] setObject: val forKey: "decimalMarkChar"];
}

+ (BOOL) enableTouchControls {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "enableTouchControls"];
}
+ (void) setEnableTouchControls: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "enableTouchControls"];
}

+ (BOOL) isAcuityColor {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "isAcuityColor"];
}
+ (void) setIsAcuityColor: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "isAcuityColor"];
}

+ (float) maxPossibleDecimalAcuity {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "maxPossibleDecimalAcuity"];
}
+ (void) setMaxPossibleDecimalAcuity: (float) val {
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "maxPossibleDecimalAcuity"];
}
+ (CPString) maxPossibleDecimalAcuityLocalisedString {
    return [[CPUserDefaults standardUserDefaults] stringForKey: "maxPossibleDecimalAcuityLocalisedString"];
}
+ (void) setMaxPossibleDecimalAcuityLocalisedString: (CPString) val {
    [[CPUserDefaults standardUserDefaults] setObject: val forKey: "maxPossibleDecimalAcuityLocalisedString"];
}

+ (float) minPossibleLogMAR {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "minPossibleLogMAR"];
}
+ (void) setMinPossibleLogMAR: (float) val {
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "minPossibleLogMAR"];
}
+ (CPString) minPossibleLogMARLocalisedString {
    return [[CPUserDefaults standardUserDefaults] stringForKey: "minPossibleLogMARLocalisedString"];
}
+ (void) setMinPossibleLogMARLocalisedString: (CPString) val {
    [[CPUserDefaults standardUserDefaults] setObject: val forKey: "minPossibleLogMARLocalisedString"];
}


+ (BOOL) threshCorrection {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "threshCorrection"];
}
+ (void)setThreshCorrection: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "threshCorrection"];
}


+ (float) maxDisplayedAcuity {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "maxDisplayedAcuity"];
}
+ (void) setMaxDisplayedAcuity: (float) val {
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "maxDisplayedAcuity"];
}


+ (float) minStrokeAcuity {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "minStrokeAcuity"];
}
+ (void) setMinStrokeAcuity: (float) val {
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "minStrokeAcuity"];
}


+ (float) acuityStartingLogMAR {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "acuityStartingLogMAR"];
}
+ (void) setAcuityStartingLogMAR: (float) val {
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "acuityStartingLogMAR"];
}


+ (int) margin4MaxOptotypeIndex {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "margin4MaxOptotypeIndex"];
}
+ (void) setMargin4MaxOptotypeIndex: (int) val {
    [[CPUserDefaults standardUserDefaults] setInteger: val forKey: "margin4MaxOptotypeIndex"];
}


+ (int) autoRunIndex {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "autoRunIndex"];
}
+ (void) setAutoRunIndex: (int) val {
    [[CPUserDefaults standardUserDefaults] setInteger: val forKey: "autoRunIndex"];
}


+ (int) crowdingType {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "crowdingType"];
}
+ (void) setCrowdingType: (int) val {
    [[CPUserDefaults standardUserDefaults] setInteger: val forKey: "crowdingType"];
}


+ (int) crowdingDistanceCalculationType {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "crowdingDistanceCalculationType"];
}
+ (void) setCrowdingDistanceCalculationType: (int) val {
    [[CPUserDefaults standardUserDefaults] setInteger: val forKey: "crowdingDistanceCalculationType"];
}


+ (BOOL) acuityFormatDecimal {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "acuityFormatDecimal"];
}
+ (void) setAcuityFormatDecimal: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "acuityFormatDecimal"];
}


+ (BOOL) acuityFormatLogMAR {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "acuityFormatLogMAR"];
}
+ (void) setAcuityFormatLogMAR: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "acuityFormatLogMAR"];
}


+ (BOOL) acuityFormatSnellenFractionFoot {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "acuityFormatSnellenFractionFoot"];
}
+ (void) setAcuityFormatSnellenFractionFoot: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "acuityFormatSnellenFractionFoot"];
}
+ (BOOL) forceSnellen20 {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "forceSnellen20"];
}
+ (void) setForceSnellen20: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "forceSnellen20"];
}


+ (BOOL) showCI95 {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "showCI95"];
}
+ (void) setShowCI95: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "showCI95"];
}


+ (float) contrastAcuityWeber { //console.info("Settings>contrastAcuityWeber: ", [[CPUserDefaults standardUserDefaults] floatForKey: "contrastAcuityWeber"]);
    return [[CPUserDefaults standardUserDefaults] floatForKey: "contrastAcuityWeber"];
}
+ (void) setContrastAcuityWeber: (float) val { //console.info("Settings>setContrastAcuityWeber: ", value);
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "contrastAcuityWeber"];
}


// these settings keeps optotype colors between restarts. Within FrACT use globals gColorFore/gColorBack
+ (CPColor) acuityForeColor {
    return [self colorForKey: "acuityForeColor" fallbackInHex: "FFFFFF"];
}
+ (void) setAcuityForeColor: (CPColor) theColor {
    [self setColor: theColor forKey: "acuityForeColor"];
}
+ (CPColor) acuityBackColor {
    return [self colorForKey: "acuityBackColor" fallbackInHex: "000000"];
}
+ (void) setAcuityBackColor: (CPColor) theColor {
    [self setColor: theColor forKey: "acuityBackColor"];
}


+ (BOOL) acuityEasyTrials {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "acuityEasyTrials"];
}
+ (void) setAcuityEasyTrials: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "acuityEasyTrials"];
}


// Line-by-line stuff
+ (int) testOnLineByLine {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "testOnLineByLine"];
}
+ (void) setTestOnLineByLine: (int) val {
    [[CPUserDefaults standardUserDefaults] setInteger: val forKey: "testOnLineByLine"];
}
+ (int) testOnLineByLineDistanceType {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "testOnLineByLineDistanceType"];
}
+ (void) setTestOnLineByLineDistanceType: (int) val {
    [[CPUserDefaults standardUserDefaults] setInteger: val forKey: "testOnLineByLineDistanceType"];
}
+ (int) lineByLineHeadcountIndex {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "lineByLineHeadcountIndex"];
}
+ (void) setLineByLineHeadcountIndex: (int) val {
    [[CPUserDefaults standardUserDefaults] setInteger: val forKey: "lineByLineHeadcountIndex"];
}
+ (BOOL) lineByLineChartMode {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "lineByLineChartMode"];
}
+ (void) setLineByLineChartMode: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "lineByLineChartMode"];
}
+ (BOOL) lineByLineChartModeConstantVA {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "lineByLineChartModeConstantVA"];
}
+ (void) setLineByLineChartModeConstantVA: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "lineByLineChartModeConstantVA"];
}


// Vernier stuff
+ (int) vernierType {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "vernierType"];
}
+ (void) setVernierType: (int) val {
    [[CPUserDefaults standardUserDefaults] setInteger: val forKey: "vernierType"];
}

+ (float) vernierWidth {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "vernierWidth"];
}
+ (void) setVernierWidth: (float) val {
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "vernierWidth"];
}

+ (float) vernierLength {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "vernierLength"];
}
+ (void) setVernierLength: (float) val {
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "vernierLength"];
}

+ (float) vernierGap {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "vernierGap"];
}
+ (void) setVernierGap: (float) val {
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "vernierGap"];
}


// Contrast stuff
+ (BOOL) contrastEasyTrials {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "contrastEasyTrials"];
}
+ (void) setContrastEasyTrials: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "contrastEasyTrials"];
}

+ (BOOL) contrastDarkOnLight {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "contrastDarkOnLight"];
}
+ (void) setContrastDarkOnLight: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "contrastDarkOnLight"];
}

+ (float) contrastOptotypeDiameter {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "contrastOptotypeDiameter"];
}
+ (void) setContrastOptotypeDiameter: (float) val {
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "contrastOptotypeDiameter"];
}

+ (BOOL) contrastShowFixMark {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "contrastShowFixMark"];
}
+ (void) setContrastShowFixMark: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "contrastShowFixMark"];
}

+ (float) contrastTimeoutFixmark {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "contrastTimeoutFixmark"];
}
+ (void) setContrastTimeoutFixmark: (float) val {
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "contrastTimeoutFixmark"];
}

+ (float) contrastMaxLogCSWeber {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "contrastMaxLogCSWeber"];
}
+ (void) setContrastMaxLogCSWeber: (float) val {
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "contrastMaxLogCSWeber"];
}

+ (float) gammaValue {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "gammaValue"];
}
+ (void) setGammaValue: (float) val {
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "gammaValue"];
}

+ (float) contrastBitStealing {//console.info("Settings>contrastBitStealing");
    return [[CPUserDefaults standardUserDefaults] boolForKey: "contrastBitStealing"];
}
+ (void) setContrastBitStealing: (BOOL) val {//console.info("Settings>setContrastBitStealing", val);
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "contrastBitStealing"];
}

+ (BOOL) contrastDithering {//console.info("Settings>contrastDithering");
    return [[CPUserDefaults standardUserDefaults] boolForKey: "contrastDithering"];
}
+ (void) setContrastDithering: (BOOL) val {//console.info("Settings>setContrastDithering", val);
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "contrastDithering"];
}



// Grating stuff
+ (float) gratingCPD {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "gratingCPD"];
}
+ (void) setGratingCPD: (float) val {
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "gratingCPD"];
}

+ (BOOL) isGratingMasked {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "isGratingMasked"];
}
+ (void) setIsGratingMasked: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "isGratingMasked"];
}
+ (float) gratingDiaInDeg {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "gratingDiaInDeg"];
}
+ (void) setGratingDiaInDeg: (float) val {
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "gratingDiaInDeg"];
}

+ (BOOL) gratingUseErrorDiffusion {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "gratingUseErrorDiffusion"];
}
+ (void) setGratingUseErrorDiffusion: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "gratingUseErrorDiffusion"];
}

+ (BOOL) isGratingColor {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "isGratingColor"];
}
+ (void) setIsGratingColor: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "isGratingColor"];
}
+ (CPColor) gratingForeColor {
    return [self colorForKey: "gratingForeColor" fallbackInHex: "FFFFFF"];
}
+ (void) setGratingForeColor: (CPColor) theColor {
    [self setColor: theColor forKey: "gratingForeColor"];
}
+ (CPColor) gratingBackColor {
    return [self colorForKey: "gratingBackColor" fallbackInHex: "000000"];
}
+ (void) setGratingBackColor: (CPColor) theColor {
    [self setColor: theColor forKey: "gratingBackColor"];
}

+ (int) what2SweepIndex {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "what2SweepIndex"];
}
+ (void) setWhat2SweepIndex: (int) val {
    [[CPUserDefaults standardUserDefaults] setInteger: val forKey: "what2SweepIndex"];
}

+ (float) gratingCPDmin {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "gratingCPDmin"];
}
+ (void) setGratingCPDmin: (float) val {
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "gratingCPDmin"];
}
+ (float) gratingCPDmax {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "gratingCPDmax"];
}
+ (void) setGratingCPDmax: (float) val {
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "gratingCPDmax"];
}
+ (float) gratingContrastMichelsonPercent {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "gratingContrastMichelsonPercent"];
}
+ (void) setGratingContrastMichelsonPercent: (float) val {
    [[CPUserDefaults standardUserDefaults] setFloat: val forKey: "gratingContrastMichelsonPercent"];
}

+ (BOOL) gratingObliqueOnly {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "gratingObliqueOnly"];
}
+ (void) setGratingObliqueOnly: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "gratingObliqueOnly"];
}

+ (BOOL) gratingSineNotSquare {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "gratingSineNotSquare"];
}
+ (void) setGratingSineNotSquare: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "gratingSineNotSquare"];
}


// Misc stuff
+ (CPColor) windowBackgroundColor {
    return [self colorForKey: "windowBackgroundColor" fallbackInHex: "FFFFEE"];
}
+ (void) setWindowBackgroundColor: (CPColor) theColor {
    [self setColor: theColor forKey: "windowBackgroundColor"];
}


+ (BOOL) specialBcmOn {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "specialBcmOn"];
}
+ (void) setSpecialBcmOn: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "specialBcmOn"];
}

+ (BOOL) hideExitButton {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "hideExitButton"];
}
+ (void) setHideExitButton: (BOOL) val {
    [[CPUserDefaults standardUserDefaults] setBool: val forKey: "hideExitButton"];
}

+ (int) soundTrialYesIndex {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "soundTrialYesIndex"];
}
+ (void) setSoundTrialYesIndex: (int) val { //console.info("setSoundTrialYesIndex", val);
    if ((val < 0 ) || (val >= gSoundsTrialYes.length)) val = 0;
    [[CPUserDefaults standardUserDefaults] setInteger: val forKey: "soundTrialYesIndex"];
}
+ (int) soundTrialNoIndex {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "soundTrialNoIndex"];
}
+ (void) setSoundTrialNoIndex: (int) val { //console.info("setSoundTrialNoIndex", val);
    if ((val < 0 ) || (val >= gSoundsTrialNo.length)) val = 0;
    [[CPUserDefaults standardUserDefaults] setInteger: val forKey: "soundTrialNoIndex"];
}
+ (int) soundRunEndIndex {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "soundRunEndIndex"];
}
+ (void) setSoundRunEndIndex: (int) val { //console.info("setSoundRunEndIndex", val);
    if ((val < 0 ) || (val >= gSoundsRunEnd.length)) val = 0;
    [[CPUserDefaults standardUserDefaults] setInteger: val forKey: "soundRunEndIndex"];
}

+ (void) setupSoundPopups: (id) popupsArray {
    const allSounds = [gSoundsTrialYes, gSoundsTrialNo, gSoundsRunEnd];
    const allIndexes = [[self soundTrialYesIndex], [self soundTrialNoIndex], [self soundRunEndIndex]];
    for (let i = 0; i < popupsArray.length; i++) {
        const p = popupsArray[i];
        [p removeAllItems];
        for (const soundName of allSounds[i]) [p addItemWithTitle: soundName];
        [p setSelectedIndex: allIndexes[i]]; // lost after remove
    }
}


@end
