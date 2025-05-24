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
@import "Misc.j"
@import "MiscLight.j"
@import "MiscSpace.j"

@implementation Settings: CPUserDefaultsController


+ (void) initialize {
    [super initialize];  [Misc CPLogSetup];
//    [self addBoolAccessors4Key: ""];
//    [self addIntAccessors4Key: ""];
//    [self addFloatAccessors4Key: ""];
//    [self addStringAccessors4Key: ""];

    //above or for all setting tabs
    [self addIntAccessors4Key: "nAlternativesIndex"];
    [self addStringAccessors4Key: "presetName"];
    [self addIntAccessors4Key: "autoRunIndex"];
    [self addStringAccessors4Key: "dateSettingsVersion"];

    //General
    [self addIntAccessors4Key: "nTrials02"];
    [self addIntAccessors4Key: "nTrials04"];
    [self addIntAccessors4Key: "nTrials08"];
    [self addFloatAccessors4Key: "distanceInCM"];
    [self addStringAccessors4Key: "distanceInInchLocalisedString"];
    [self addFloatAccessors4Key: "calBarLengthInMM"];
    [self addBoolAccessors4Key: "responseInfoAtStart"];
    [self addIntAccessors4Key: "testOnFive"];
    [self addIntAccessors4Key: "nOfRuns2Recall"];
    [self addFloatAccessors4Key: "eccentXInDeg"];
    [self addFloatAccessors4Key: "eccentYInDeg"];
    [self addBoolAccessors4Key: "eccentShowCenterFixMark"];
    [self addBoolAccessors4Key: "eccentRandomizeX"];
    [self addBoolAccessors4Key: "mobileOrientation"];
    [self addBoolAccessors4Key: "autoFullScreen"];
    [self addIntAccessors4Key: "displayTransform"];
    [self addBoolAccessors4Key: "showTrialInfo"];
    [self addIntAccessors4Key: "trialInfoFontSize"];
    [self addFloatAccessors4Key: "timeoutIsiMillisecs"];
    [self addFloatAccessors4Key: "timeoutResponseSeconds"];
    [self addFloatAccessors4Key: "timeoutDisplaySeconds"];
    [self addFloatAccessors4Key: "maskTimeOnResponseInMS"];
    [self addIntAccessors4Key: "decimalMarkCharIndex"];
    [self addIntAccessors4Key: "results2clipboard"];
    [self addBoolAccessors4Key: "results2clipboardSilent"];
    [self addIntAccessors4Key: "auditoryFeedback4trial"];
    [self addIntAccessors4Key: "visualFeedback"];
    [self addBoolAccessors4Key: "auditoryFeedback4run"];
    [self addFloatAccessors4Key: "soundVolume"];
    [self addBoolAccessors4Key: "rewardPicturesWhenDone"];
    [self addFloatAccessors4Key: "timeoutRewardPicturesInSeconds"];
    [self addBoolAccessors4Key: "enableTouchControls"];

    //Acuity
    //these 2 settings keeps optotype colors between restarts. Within FrACT use globals gColorFore/gColorBack
    [self addColorAccessors4Key: "acuityForeColor"];
    [self addColorAccessors4Key: "acuityBackColor"];
    [self addBoolAccessors4Key: "isAcuityColor"];
    [self addFloatAccessors4Key: "floatForKey"];
    [self addStringAccessors4Key: "maxPossibleDecimalAcuityLocalisedString"];
    [self addFloatAccessors4Key: "minPossibleDecimalAcuity"];
    [self addStringAccessors4Key: "minPossibleDecimalAcuityLocalisedString"];
    [self addFloatAccessors4Key: "minPossibleLogMAR"];
    [self addStringAccessors4Key: "minPossibleLogMARLocalisedString"];
    [self addFloatAccessors4Key: "maxPossibleLogMAR"];
    [self addStringAccessors4Key: "maxPossibleLogMARLocalisedString"];
    [self addBoolAccessors4Key: "threshCorrection"];
    [self addFloatAccessors4Key: "maxDisplayedAcuity"];
    [self addFloatAccessors4Key: "minStrokeAcuity"];
    [self addFloatAccessors4Key: "acuityStartingLogMAR"];
    [self addIntAccessors4Key: "margin4maxOptotypeIndex"];
    [self addIntAccessors4Key: "crowdingType"];
    [self addIntAccessors4Key: "crowdingDistanceCalculationType"];
    [self addBoolAccessors4Key: "acuityFormatDecimal"];
    [self addBoolAccessors4Key: "acuityFormatLogMAR"];
    [self addBoolAccessors4Key: "acuityFormatSnellenFractionFoot"];
    [self addBoolAccessors4Key: "forceSnellen20"];
    [self addBoolAccessors4Key: "showCI95"];
    [self addFloatAccessors4Key: "contrastAcuityWeber"];
    [self addBoolAccessors4Key: "acuityEasyTrials"];
    [self addBoolAccessors4Key: "isLandoltObliqueOnly"];

    //Acuity>Line-by-line
    [self addIntAccessors4Key: "testOnLineByLine"];
    [self addIntAccessors4Key: "testOnLineByLineDistanceType"];
    [self addIntAccessors4Key: "lineByLineHeadcountIndex"];
    [self addIntAccessors4Key: "lineByLineLinesIndex"];
    [self addBoolAccessors4Key: "lineByLineChartModeConstantVA"];

    //Acuity>Vernier
    [self addIntAccessors4Key: "vernierType"];
    [self addFloatAccessors4Key: "vernierWidth"];
    [self addFloatAccessors4Key: "vernierLength"];
    [self addFloatAccessors4Key: "vernierGap"];

    //Contrast
    [self addBoolAccessors4Key: "contrastEasyTrials"];
    [self addBoolAccessors4Key: "contrastDarkOnLight"];
    [self addFloatAccessors4Key: "contrastOptotypeDiameter"];
    [self addBoolAccessors4Key: "contrastShowFixMark"];
    [self addFloatAccessors4Key: "contrastTimeoutFixmark"];
    [self addFloatAccessors4Key: "contrastMaxLogCSWeber"];
    [self addFloatAccessors4Key: "gammaValue"];
    [self addBoolAccessors4Key: "contrastBitStealing"];
    [self addBoolAccessors4Key: "contrastDithering"];

    //Gratings
    [self addFloatAccessors4Key: "gratingCPD"];
    [self addBoolAccessors4Key: "isGratingMasked"];
    [self addFloatAccessors4Key: "gratingDiaInDeg"];
    [self addBoolAccessors4Key: "gratingUseErrorDiffusion"];
    [self addBoolAccessors4Key: "isGratingColor"];
    [self addIntAccessors4Key: "what2sweepIndex"];
    [self addFloatAccessors4Key: "gratingCPDmin"];
    [self addFloatAccessors4Key: "gratingCPDmax"];
    [self addFloatAccessors4Key: "gratingContrastMichelsonPercent"];
    [self addBoolAccessors4Key: "isGratingObliqueOnly"];
    [self addIntAccessors4Key: "gratingShapeIndex"];
    [self addColorAccessors4Key: "gratingForeColor"];
    [self addColorAccessors4Key: "gratingBackColor"];

    //BaLM
    [self addIntAccessors4Key: "balmIsiMillisecs"];
    [self addIntAccessors4Key: "balmOnMillisecs"];
    [self addFloatAccessors4Key: "balmSpeedInDegPerSec"];
    [self addFloatAccessors4Key: "balmLocationDiameterInDeg"];
    [self addFloatAccessors4Key: "balmLocationEccentricityInDeg"];
    [self addFloatAccessors4Key: "balmMotionDiameterInDeg"];
    [self addFloatAccessors4Key: "balmSpeedInDegPerSec"];
    [self addFloatAccessors4Key: "balmExtentInDeg"];

    //Misc
    [self addColorAccessors4Key: "windowBackgroundColor"];
    [self addBoolAccessors4Key: "specialBcmOn"];
    [self addBoolAccessors4Key: "hideExitButton"];
    [self addBoolAccessors4Key: "embedInNoise"];
    [self addIntAccessors4Key: "noiseContrast"];
    //Sound
    [self addIntAccessors4Key: "soundTrialStartIndex"];
    [self addIntAccessors4Key: "soundTrialYesIndex"];
    [self addIntAccessors4Key: "soundTrialNoIndex"];
    [self addIntAccessors4Key: "soundRunEndIndex"];

    [self addStringAccessors4Key: "patID"];
    [self addIntAccessors4Key: "eyeIndex"];
}


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
+ (int) checkNum: (CPNumber) val dflt: (int) def min: (int) min max: (int) max set: (BOOL) set { //console.info("chckInt ", val);
    if (!set && !isNaN(val) && (val <= max) && (val >= min)) return val;
    return def;
}


//CPColors are stored as hexString because the archiver does not work in Cappuccino. Why not??
//https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/DrawColor/Tasks/StoringNSColorInDefaults.html
+ (CPColor) colorForKey: (CPString) keyString fallbackInHex: (CPString) fallbackInHex {
    let theData = [[CPUserDefaults standardUserDefaults] stringForKey: keyString];
    if (theData === nil) theData = fallbackInHex; //safety measure and default
    return [CPColor colorWithHexString: theData];
}
+ (void) setColor: (CPColor) theColor forKey: (CPString) keyString {
    if (typeof(theColor) !== "string") { //allow both hexstring (from HTML message) & CPColor
        theColor = [theColor hexString];
    }
    [[CPUserDefaults standardUserDefaults] setObject: theColor forKey: keyString];
}


/**
 Test all settings for in-range (set===NO) or set the to defaults (set===YES)
 */
+ (void) allNotCheckButSet: (BOOL) set {
    [[CPUserDefaults standardUserDefaults] synchronize];
    if (set) {
        [self setDateSettingsVersion: kDateOfCurrentSettingsVersion];
        //for `CPColor` I have no `CheckCol` (yet) #tbd, worth it?
        [self setWindowBackgroundColor: [CPColor colorWithRed: 1 green: 1 blue: 0.9 alpha: 1]];
        [self setGratingForeColor: [CPColor lightGrayColor]];
        [self setGratingBackColor: [CPColor darkGrayColor]];
        [self setPresetName: "Standard Defaults"]; //synchronise with corresponding item in Presets!
        [self setPatID: "-"];
    }

    //need to check before setNAlternativesIndex 'cause oblique might force to index=0
    [self setIsGratingObliqueOnly: [self checkBool: [self isGratingObliqueOnly] dflt: NO set: set]];
    //for all tests
    [self setNAlternativesIndex: [self checkNum: [self nAlternativesIndex] dflt: kNAlternativesIndex8plus min: kNAlternativesIndex2 max: kNAlternativesIndex8plus set:set]]; //dflt:8
    [self setNTrials02: [self checkNum: [self nTrials02] dflt: 32 min: 1 max: 200 set: set]];
    [self setNTrials04: [self checkNum: [self nTrials04] dflt: 24 min: 1 max: 200 set: set]];
    [self setNTrials08: [self checkNum: [self nTrials08] dflt: 18 min: 1 max: 200 set: set]];

    [self setDistanceInCM: [self checkNum: [self distanceInCM] dflt: gDefaultDistanceInCM min: 1 max: 2500 set: set]];
    [self setCalBarLengthInMM: [self checkNum: [self calBarLengthInMM] dflt: gDefaultCalibrationBarLengthInMM min: 1 max: 10000 set: set]];

    [self setResponseInfoAtStart: [self checkBool: [self responseInfoAtStart] dflt: YES set: set]];
    [self setEnableTouchControls: [self checkBool: [self enableTouchControls] dflt: YES set: set]];

    [self setDecimalMarkCharIndex: [self checkNum: [self decimalMarkCharIndex] dflt: kDecimalMarkCharIndexAuto min: kDecimalMarkCharIndexAuto max: kDecimalMarkCharIndexComma set: set]];

    [self setTestOnFive: [self checkNum: [self testOnFive] dflt: kTestAcuityLett min: kTestNone max: kTestAcuityLineByLine set: set]]; //1: Sloan Letters

    //[self setNOfRuns2Recall: [self checkNum: [self nOfRuns2Recall] dflt: 0 min: 0 max: 100 set: set]];

    [self setEccentXInDeg: [self checkNum: [self eccentXInDeg] dflt: 0 min: -99 max: 99 set: set]];
    [self setEccentYInDeg: [self checkNum: [self eccentYInDeg] dflt: 0 min: -99 max: 99 set: set]];
    [self setEccentShowCenterFixMark: [self checkBool: [self eccentShowCenterFixMark] dflt: YES set: set]];
    [self setEccentRandomizeX: [self checkBool: [self eccentRandomizeX] dflt: NO set: set]];

    [self setAutoFullScreen: [self checkBool: [self autoFullScreen] dflt: NO set: set]];

    [self setMobileOrientation: [self checkBool: [self mobileOrientation] dflt: YES set: set]];

    //0=normal, 1=mirror horizontally, 2=mirror vertically, 3=both=rot180°
    [self setDisplayTransform: [self checkNum: [self displayTransform] dflt: 0 min: 0 max: 3 set: set]];

    [self setShowTrialInfo: [self checkBool: [self showTrialInfo] dflt: YES set: set]];
    [self setTrialInfoFontSize: [self checkNum: [self trialInfoFontSize] dflt: 10 min: 4 max: 48 set: set]];

    [self setTimeoutIsiMillisecs: [self checkNum: [self timeoutIsiMillisecs] dflt: 0 min: 0 max: 3000 set: set]];
    [self setTimeoutResponseSeconds: [self checkNum: [self timeoutResponseSeconds] dflt: 30 min: 0.1 max: 9999 set: set]];
    [self setTimeoutDisplaySeconds: [self checkNum: [self timeoutDisplaySeconds] dflt: 30 min: 0.1 max: 9999 set: set]];
    [self setMaskTimeOnResponseInMS: [self checkNum: [self timeoutDisplaySeconds] dflt: 0 min: 0 max: 9999 set: set]];

    [self setResults2clipboard: [self checkNum: [self results2clipboard] dflt: kResults2ClipNone min: kResults2ClipNone max: kResults2ClipFullHistory2PDF set: set]];
    [self setResults2clipboardSilent: [self checkBool: [self results2clipboardSilent] dflt: NO set: set]];

    //0: none, 1: always, 2: on correct, 3: w/ info
    [self setAuditoryFeedback4trial: [self checkNum: [self auditoryFeedback4trial] dflt: kAuditoryFeedback4trialWithinfo min: kAuditoryFeedback4trialNone max: kAuditoryFeedback4trialWithinfo set: set]];
    //0: none, 1: always, 2: on correct, 3: w/ info
    [self setVisualFeedback: [self checkNum: [self visualFeedback] dflt: 0 min: 0 max: 3 set: set]]; //NOT IN USE
    [self setAuditoryFeedback4run: [self checkBool: [self auditoryFeedback4run] dflt: YES set: set]];
    [self setSoundVolume: [self checkNum: [self soundVolume] dflt: 20 min: 1 max: 100 set: set]];

    [self setRewardPicturesWhenDone: [self checkBool: [self rewardPicturesWhenDone] dflt: NO set: set]];
    [self setTimeoutRewardPicturesInSeconds: [self checkNum: [self timeoutRewardPicturesInSeconds] dflt: 5 min: 0.1 max: 999 set: set]];

    [self setEmbedInNoise: [self checkBool: [self embedInNoise] dflt: NO set: set]];
    [self setNoiseContrast: [self checkNum: [self noiseContrast] dflt: 50 min: 0 max: 100 set: set]];

    //Acuity stuff
    [self setIsAcuityColor: [self checkBool: [self isAcuityColor] dflt: NO set: set]];
    [self setIsLandoltObliqueOnly: [self checkBool: [self isLandoltObliqueOnly] dflt: NO set: set]]; //only applies to acuity with 4 Landolt orienations
    [self setContrastAcuityWeber: [self checkNum: [self contrastAcuityWeber] dflt: 100 min: -1E6 max: 100 set: set]];
    [self calculateAcuityForeBackColorsFromContrast];
    [self setAcuityEasyTrials: [self checkBool: [self acuityEasyTrials] dflt: YES set: set]];
    [self setMaxDisplayedAcuity: [self checkNum: [self maxDisplayedAcuity] dflt: 2 min: 1 max: 99 set: set]];
    [self setMinStrokeAcuity: [self checkNum: [self minStrokeAcuity] dflt: 0.5 min: 0.5 max: 5 set: set]];
    [self setAcuityStartingLogMAR: [self checkNum: [self acuityStartingLogMAR] dflt: 1 min: 0.3 max: 2.5 set: set]];
    [self setMargin4maxOptotypeIndex: [self checkNum: [self margin4maxOptotypeIndex] dflt: 1 min: 0 max: 4 set: set]];
    [self setAutoRunIndex: [self checkNum: [self autoRunIndex] dflt: kAutoRunIndexNone min: kAutoRunIndexNone max: kAutoRunIndexLow set: set]];
    [self setThreshCorrection: [self checkBool: [self threshCorrection] dflt: YES set: set]];
    [self setAcuityFormatDecimal: [self checkBool: [self acuityFormatDecimal] dflt: YES set: set]];
    [self setAcuityFormatLogMAR: [self checkBool: [self acuityFormatLogMAR] dflt: YES set: set]];
    [self setAcuityFormatSnellenFractionFoot: [self checkBool: [self acuityFormatSnellenFractionFoot] dflt: NO set: set]];
    [self setForceSnellen20: [self checkBool: [self forceSnellen20] dflt: NO set: set]];
    [self setShowCI95: [self checkBool: [self showCI95] dflt: NO set: set]];
    [self calculateMinMaxPossibleAcuity];

    //Crowding, crowdingType: 0 = none, 1: flanking bars, 2 = flanking rings, 3 = surounding bars, 4: surounding ring, 5 = surounding square, 6 = row of optotypes
    [self setCrowdingType: [self checkNum: [self crowdingType] dflt: 0 min: 0 max: 6 set: set]];
    //0 = 2·stroke between rings, 1 = fixed 2.6 arcmin between rings, 2 = fixed 30', 3 = like ETDRS
    [self setCrowdingDistanceCalculationType: [self checkNum: [self crowdingDistanceCalculationType] dflt: 0 min: 0 max: 3 set: set]];

    [self setCrowdingDistanceCalculationType: [self checkNum: [self crowdingDistanceCalculationType] dflt: 0 min: 0 max: 3 set: set]];

    //Line-by-line stuff
    [self setTestOnLineByLine: [self checkNum: [self testOnLineByLine] dflt: 1 min: 1 max: 4 set: set]]; //1: Sloan Letters. 0: nicht erlaubt, 2: Landolt, 3…
    [self setTestOnLineByLineDistanceType: [self checkNum: [self testOnLineByLineDistanceType] dflt: 1 min: 0 max: 1 set: set]]; //0: DIN-EN-ISO, 1: ETDRS
    [self setLineByLineHeadcountIndex: [self checkNum: [self lineByLineHeadcountIndex] dflt: 2 min: 0 max: 4 set: set]]; //0: "1", 2: "3", 3: "5", 4: "7"
    [self setLineByLineLinesIndex: [self checkNum: [self lineByLineLinesIndex] dflt: 0 min: 0 max: 3 set: set]]; //0: "1", 2: "3", 3: "5"
    [self setLineByLineChartModeConstantVA: [self checkBool: [self lineByLineChartModeConstantVA] dflt: NO set: set]];

    //Vernier stuff
    [self setVernierType: [self checkNum: [self vernierType] dflt: 0 min: 0 max: 1 set: set]]; //2 or 3 bars
    [self setVernierWidth: [self checkNum: [self vernierWidth] dflt: 1.0 min: 0.1 max: 120 set: set]]; //in arcminutes
    [self setVernierLength: [self checkNum: [self vernierLength] dflt: 15.0 min: 0.1 max: 1200 set: set]];
    [self setVernierGap: [self checkNum: [self vernierGap] dflt: 0.2 min: 0.0 max: 120 set: set]];


    //Contrast stuff
    [self setGammaValue: [self checkNum: [self gammaValue] dflt: 2.0 min: 0.8 max: 4 set: set]];
    [self setContrastEasyTrials: [self checkBool: [self contrastEasyTrials] dflt: YES set: set]];
    [self setContrastDarkOnLight: [self checkBool: [self contrastDarkOnLight] dflt: YES set: set]];
    [self setContrastOptotypeDiameter: [self checkNum: [self contrastOptotypeDiameter] dflt: 50 min: 1 max: 2500 set: set]];
    [self setContrastShowFixMark: [self checkBool: [self contrastShowFixMark] dflt: YES set: set]];
    [self setContrastTimeoutFixmark: [self checkNum: [self contrastTimeoutFixmark] dflt: 500 min: 20 max: 5000 set: set]];
    [self setContrastMaxLogCSWeber: [self checkNum: [self contrastMaxLogCSWeber] dflt: 3.0 min: 1.5 max: gMaxAllowedLogCSWeber set: set]];
    [self setContrastBitStealing: [self checkBool: [self contrastBitStealing] dflt: NO set: set]];
    [self setContrastDithering: [self checkBool: [self contrastDithering] dflt: YES set: set]];

    //Grating stuff
    [self setGratingCPD: [self checkNum: [self gratingCPD] dflt: 2.0 min: 0.01 max: 18 set: set]];
    [self setIsGratingMasked: [self checkBool: [self isGratingMasked] dflt: NO set: set]];
    [self setGratingDiaInDeg: [self checkNum: [self gratingDiaInDeg] dflt: 10.0 min: 1.0 max: 50 set: set]];
    [self setGratingUseErrorDiffusion: [self checkBool: [self gratingUseErrorDiffusion] dflt: YES set: set]];
    [self setGratingShapeIndex: [self checkNum: [self gratingShapeIndex] dflt: 0 min: 0 max: kGratingShapeIndexCheckerboard set: set]];
    [self setIsGratingColor: [self checkBool: [self isGratingColor] dflt: NO set: set]];
    [self setWhat2sweepIndex: [self checkNum: [self what2sweepIndex] dflt: 0 min: 0 max: 1 set: set]]; //0: sweep contrast, 1: sweep spatial frequency
    [self setGratingCPDmin: [self checkNum: [self gratingCPDmin] dflt: 0.5 min: 0.01 max: 60 set: set]];
    [self setGratingCPDmax: [self checkNum: [self gratingCPDmax] dflt: 30 min: 0.01 max: 60 set: set]];
    [self setGratingContrastMichelsonPercent: [self checkNum: [self gratingContrastMichelsonPercent] dflt: 95 min: 0.3 max: 99 set: set]];

    //Misc stuff
    [self setSpecialBcmOn: [self checkBool: [self specialBcmOn] dflt: NO set: set]];
    [self setHideExitButton: [self checkBool: [self hideExitButton] dflt: NO set: set]];

    [self setSoundTrialStartIndex: [self checkNum: [self soundTrialStartIndex] dflt: 1 min: 0 max: gSoundsTrialStart.length-1 set: set]];
    [self setSoundTrialYesIndex: [self checkNum: [self soundTrialYesIndex] dflt: 0 min: 0 max: gSoundsTrialYes.length-1 set: set]];
    [self setSoundTrialNoIndex: [self checkNum: [self soundTrialNoIndex] dflt: 0 min: 0 max: gSoundsTrialNo.length-1 set: set]];
    [self setSoundRunEndIndex: [self checkNum: [self soundRunEndIndex] dflt: 0 min: 0 max: gSoundsRunEnd.length-1 set: set]];

    [self setEyeIndex: [self checkNum: [self eyeIndex] dflt: 0 min: 0 max: 3 set: set]];


    //BaLM stuff
    [self setBalmIsiMillisecs: [self checkNum: [self balmIsiMillisecs] dflt: 1500 min: 20 max: 5000 set: set]];
    [self setBalmOnMillisecs: [self checkNum: [self balmOnMillisecs] dflt: 200 min: 20 max: 2000 set: set]];
    [self setBalmLocationEccentricityInDeg: [self checkNum: [self balmLocationEccentricityInDeg] dflt: 15 min: 1 max: 30 set: set]];
    [self setBalmLocationDiameterInDeg: [self checkNum: [self balmLocationDiameterInDeg] dflt: 5 min: 0.1 max: 20 set: set]];
    [self setBalmMotionDiameterInDeg: [self checkNum: [self balmMotionDiameterInDeg] dflt: 3.3 min: 0.1 max: 10 set: set]];
    [self setBalmSpeedInDegPerSec: [self checkNum: [self balmSpeedInDegPerSec] dflt: 3.3 min: 0.1 max: 10 set: set]];
    [self setBalmExtentInDeg: [self checkNum: [self balmExtentInDeg] dflt: 15 min: 5 max: 30 set: set]];

    [[CPUserDefaults standardUserDefaults] synchronize];
}


+ (void) calculateMinMaxPossibleAcuity { //console.info("Settings>calculateMinMaxPossibleAcuity");
    let maxPossibleAcuityVal = [MiscSpace decVAFromStrokePixels: 1.0];
    const screenSize = Math.min(window.screen.height, window.screen.width);
    const strokeMaximal = screenSize / (5 + [self margin4maxOptotypeIndex]); //leave a margin of ½·index around the largest optotype
    let minPossibleAcuityVal = [MiscSpace decVAFromStrokePixels: strokeMaximal];
    //Correction for threshold underestimation of ascending procedures (as opposed to our bracketing one)
    minPossibleAcuityVal = [self threshCorrection] ? minPossibleAcuityVal * gThresholdCorrection4Ascending : minPossibleAcuityVal;
    [self setMinPossibleDecimalAcuityLocalisedString: [Misc stringFromNumber: minPossibleAcuityVal decimals: 3 localised: YES]];
    [self setMaxPossibleLogMAR: [MiscSpace logMARfromDecVA: minPossibleAcuityVal]]; //needed for color
    [self setMaxPossibleLogMARLocalisedString: [Misc stringFromNumber: [self maxPossibleLogMAR] decimals: 2 localised: YES]];

    //Correction for threshold underestimation of ascending procedures (as opposed to our bracketing one)
    maxPossibleAcuityVal = [self threshCorrection] ? maxPossibleAcuityVal * gThresholdCorrection4Ascending : maxPossibleAcuityVal;
    [self setMaxPossibleDecimalAcuityLocalisedString: [Misc stringFromNumber: maxPossibleAcuityVal decimals: 2 localised: YES]];
    [self setMinPossibleLogMAR: [MiscSpace logMARfromDecVA: maxPossibleAcuityVal]]; //needed for color
    [self setMinPossibleLogMARLocalisedString: [Misc stringFromNumber: [self minPossibleLogMAR] decimals: 2 localised: YES]];
    const inch = [Misc stringFromNumber: [self distanceInCM] / 2.54 decimals: 1 localised: YES];
    [self setDistanceInInchLocalisedString: inch];

}


//contrast in %. 100%: background fully white, foreground fully dark. -100%: inverted
+ (void) calculateAcuityForeBackColorsFromContrast { //console.info("Settings>calculateAcuityForeBackColorsFromContrast");
    if ([self isAcuityColor]) return;
    const cnt = [MiscLight contrastMichelsonPercentFromWeberPercent: [self contrastAcuityWeber]];
    let temp = [MiscLight lowerLuminanceFromContrastMilsn: cnt];  temp = [MiscLight devicegrayFromLuminance: temp];
    gColorFore = [CPColor colorWithWhite: temp alpha: 1];
    [self setAcuityForeColor: gColorFore];
    temp = [MiscLight upperLuminanceFromContrastMilsn: cnt];  temp = [MiscLight devicegrayFromLuminance: temp];
    gColorBack = [CPColor colorWithWhite: temp alpha: 1];
    [self setAcuityBackColor: gColorBack];
    [gAppController copyColorsFromSettings];
}


/**
 Test if we neet to set all Settings to defaults
 When new defaults are added, kDateOfCurrentSettingsVersion is updated. That tells FrACT that all settings need to be defaulted.
 */
+ (BOOL) needNewDefaults {
    return [self dateSettingsVersion] !== kDateOfCurrentSettingsVersion;
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


/**
 Calibration is assumed ok if the distance and the calBarLength differ from defaults
 */
+ (BOOL) isNotCalibrated {
    [self checkDefaults];
    return (([self distanceInCM] === gDefaultDistanceInCM) || ([self calBarLengthInMM] === gDefaultCalibrationBarLengthInMM));
}


/**
 Populate the sound selection popups from the selected indices
 */
+ (void) setupSoundPopups: (id) popupsArray {
    const allSounds = [gSoundsTrialStart, gSoundsTrialYes, gSoundsTrialNo, gSoundsRunEnd];
    const allIndexes = [[self soundTrialStartIndex], [self soundTrialYesIndex], [self soundTrialNoIndex], [self soundRunEndIndex]];
    for (let i = 0; i < popupsArray.length; i++) {
        const p = popupsArray[i];
        [p removeAllItems]; //first remove all, then add selected ones
        for (const soundName of allSounds[i]) [p addItemWithTitle: soundName];
        [p setSelectedIndex: allIndexes[i]]; //was lost after remove
    }
}


///////////////////////////////////////////////////////////
/**
 individual getters / setters for all settings not synthesized
 */

+ (int) nTrials { //console.info("Settings>nTrials");
    switch ([self nAlternatives]) {
        case 2:  return [self nTrials02];  break;
        case 4:  return [self nTrials04];  break;
        default:  return [self nTrials08];
    }
}

+ (int) nAlternatives { //console.info("Settings>nAlternatives");
    switch ([self nAlternativesIndex]) {
        case kNAlternativesIndex2:  return 2;  break;
        case kNAlternativesIndex4:  return 4;  break;
        default: return 8; //case kNAlternativesIndex8plus
    }
}

+ (CPString) decimalMarkChar { //console.info("settings>decimalMarkChar");
    let _mark = ".";
    switch ([self decimalMarkCharIndex]) {
        case 0: //"Automatic"
            try {
                const tArray = Intl.NumberFormat().formatToParts(1.3); //"1.3" has a decimal mark
                _mark = tArray.find(currentValue => currentValue.type === "decimal").value;
            }
            catch(e) { //avoid global error catcher, but log the problem
                console.log("“Intl.NumberFormat().formatToParts” throws error: ", e);
            } //console.info("_decimalMarkChar: ", _decimalMarkChar)
            break;
        case 2: //comma
            _mark = ","; break;
    }
    [self setDecimalMarkChar: _mark];
    return _mark;
}
+ (void) setDecimalMarkChar: (CPString) val {
    [[CPUserDefaults standardUserDefaults] setObject: val forKey: "decimalMarkChar"];
}
///////////////////////////////////////////////////////////


/**
 Helpers for synthesising class methods to get/set defaults
 */
+ (void) addBoolAccessors4Key: (CPString) key { //CPLog("Settings>addIntAccessors4Key called with key: " + key);
    if (key == "") return;
    const setterName = "set" + key.charAt(0).toUpperCase() + key.substring(1) + ":";
    const getterSel = CPSelectorFromString(key),
        setterSel = CPSelectorFromString(setterName);
    class_addMethod(self.isa, getterSel, function(self, _cmd) {
        const val = [[CPUserDefaults standardUserDefaults] boolForKey:key];
        //CPLog("Getter called for key: %@, returning %d", key, val);
        return val;
    });
    class_addMethod(self.isa, setterSel, function(self, _cmd, val) { //CPLog("Bool setter called for key: " + key + " with value: " + val);
        [[CPUserDefaults standardUserDefaults] setBool:val forKey:key];
    });
}
+ (void) addIntAccessors4Key: (CPString) key { //CPLog("Settings>addIntAccessors4Key called with key: " + key);
    if (key == "") return;
    const setterName = "set" + key.charAt(0).toUpperCase() + key.substring(1) + ":";
    const getterSel = CPSelectorFromString(key),
        setterSel = CPSelectorFromString(setterName);
    class_addMethod(self.isa, getterSel, function(self, _cmd) {
        const val = [[CPUserDefaults standardUserDefaults] integerForKey:key];
        //CPLog("Getter called for key: %@, returning %d", key, val);
        return val;
    });
    class_addMethod(self.isa, setterSel, function(self, _cmd, val) { //CPLog("Int setter called for key: " + key + " with value: " + val);
        [[CPUserDefaults standardUserDefaults] setInteger:val forKey:key];
    });
}
+ (void) addFloatAccessors4Key: (CPString) key { //CPLog("Settings>addFloatAccessors4Key called with key: " + key);
    if (key == "") return;
    const setterName = "set" + key.charAt(0).toUpperCase() + key.substring(1) + ":";
    const getterSel = CPSelectorFromString(key),
        setterSel = CPSelectorFromString(setterName);
    class_addMethod(self.isa, getterSel, function(self, _cmd) {
        const val = [[CPUserDefaults standardUserDefaults] floatForKey:key];
        //CPLog("Getter called for key: %@, returning %f", key, val);
        return val;
    });
    class_addMethod(self.isa, setterSel, function(self, _cmd, val) { //CPLog("Float setter called for key: " + key + " with value: " + val);
        [[CPUserDefaults standardUserDefaults] setFloat:val forKey:key];
    });
    //CPLog("Self responds to getter: " + [self respondsToSelector:getterSel]);
    //CPLog("Settings responds to getter: " + [Settings respondsToSelector:getterSel]);
}
+ (void) addStringAccessors4Key: (CPString) key { //CPLog("Settings>addIntAccessors4Key called with key: " + key);
    if (key == "") return;
    const setterName = "set" + key.charAt(0).toUpperCase() + key.substring(1) + ":";
    const getterSel = CPSelectorFromString(key),
        setterSel = CPSelectorFromString(setterName);
    class_addMethod(self.isa, getterSel, function(self, _cmd) {
        const val = [[CPUserDefaults standardUserDefaults] stringForKey:key];
        //CPLog("Getter called for key: %@, returning %d", key, val);
        return val;
    });
    class_addMethod(self.isa, setterSel, function(self, _cmd, val) { //CPLog("String setter called for key: " + key + " with value: " + val);
        [[CPUserDefaults standardUserDefaults] setObject:val forKey:key];
    });
}
+ (void) addColorAccessors4Key: (CPString) key { //CPLog("Settings>addIntAccessors4Key called with key: " + key);
    if (key == "") return;
    const setterName = "set" + key.charAt(0).toUpperCase() + key.substring(1) + ":";
    const getterSel = CPSelectorFromString(key),
        setterSel = CPSelectorFromString(setterName);
    class_addMethod(self.isa, getterSel, function(self, _cmd) {
        return [self colorForKey: key fallbackInHex: "777777"];
    });
    class_addMethod(self.isa, setterSel, function(self, _cmd, val) { //CPLog("Color setter called for key: " + key + " with value: " + val);
        [self setColor: val forKey: key];
    });
}


@end
