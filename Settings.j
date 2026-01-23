/*
This file is part of FrACT10, a vision test battery.
© 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

Settings.j

Provides a getter/setter interface to all settings (preferences)
All values are checked for sensible ranges for robustness.
Also calculates Fore- and BackColors
Created by mb on July 15, 2015.
*/

//#define kDateOfCurrentSettingsVersion "2025-10-05"
#define kDateOfCurrentSettingsVersion "2026-01-15"


@import <Foundation/CPUserDefaults.j>
@import <AppKit/CPUserDefaultsController.j>

@import "Misc.j"
@import "MiscLight.j"
@import "MiscSpace.j"


@implementation Settings: CPUserDefaultsController {
    id settingsNamesAndTypes;
}


+ (void) initialize {
    [super initialize];  [Misc CPLogSetup];
    sharedSettingsInstance = nil; //not really necessary
    //my accessor functions are constructed from this array, depending on type
    settingsNamesAndTypes = [ //array of arrays for all settings and their type
        //[name, type]
        ["presetName", "str"], //above all or for all setting tabs
        ["autoRunIndex", "int"],
        ["dateOfSettingsVersion", "str"],
        ["showIdAndEyeOnMain", "bool"],//↓General tab
        ["nTrials02", "int"], ["nTrials04", "int"], ["nTrials08", "int"],
        ["nAlternativesIndex", "int"],
        ["distanceInCM", "float"],
        ["distanceInInchLocalisedString", "str"],
        ["calBarLengthInMM", "float"],
        ["showResponseInfoAtStart", "bool"],
        ["testOnFive", "int"],
        ["eccentXInDeg", "float"], ["eccentYInDeg", "float"],
        ["eccentShowCenterFixMark", "bool"],
        ["eccentRandomizeX", "bool"], ["eccentRandomizeY", "bool"],
        ["respondsToMobileOrientation", "bool"],
        ["autoFullScreen", "bool"],
        ["displayTransform", "int"],
        ["showTrialInfo", "bool"], ["trialInfoFontSize", "int"],
        ["timeoutIsiMillisecs", "float"],
        ["timeoutResponseSeconds", "float"],
        ["timeoutDisplaySeconds", "float"],
        ["decimalMarkCharIndex", "int"],
        ["resultsToClipboardIndex", "int"], ["putResultsToClipboardSilent", "bool"],
        ["auditoryFeedback4trialIndex", "int"],
        ["visualFeedback", "int"],
        ["giveAuditoryFeedback4run", "bool"],
        ["soundVolume", "float"],
        ["showRewardPicturesWhenDone", "bool"],
        ["timeoutRewardPicturesInSeconds", "float"],
        ["enableTouchControls", "bool"],//↓Acuity tab
        ["acuityForeColor", "col"], ["acuityBackColor", "col"],
        ["isAcuityColor", "bool"],
        ["maxPossibleDecimalAcuityLocalisedString", "str"],
        ["minPossibleDecimalAcuity", "float"],
        ["minPossibleDecimalAcuityLocalisedString", "str"],
        ["minPossibleLogMAR", "float"],
        ["minPossibleLogMARLocalisedString", "str"],
        ["maxPossibleLogMAR", "float"],
        ["maxPossibleLogMARLocalisedString", "str"],
        ["doThreshCorrection", "bool"],
        ["maxDisplayedAcuity", "float"],
        ["minStrokeAcuity", "float"],
        ["acuityStartingLogMAR", "float"],
        ["margin4maxOptotypeIndex", "int"],
        ["crowdingType", "int"], ["crowdingDistanceCalculationType", "int"],
        ["showAcuityFormatDecimal", "bool"],
        ["showAcuityFormatLogMAR", "bool"],
        ["showAcuityFormatSnellenFractionFoot", "bool"],
        ["forceSnellen20", "bool"],
        ["showCI95", "bool"],
        ["contrastAcuityWeber", "float"],
        ["acuityHasEasyTrials", "bool"],
        ["isLandoltObliqueOnly", "bool"], //↓Acuity>Line-by-line
        ["testOnLineByLineIndex", "int"], ["lineByLineDistanceType", "int"],
        ["lineByLineHeadcountIndex", "int"], ["lineByLineLinesIndex", "int"],
        ["isLineByLineChartModeConstantVA", "bool"], //↓Acuity>Vernier
        ["vernierType", "int"], ["vernierWidth", "float"],
        ["vernierLength", "float"], ["vernierGap", "float"], //↓Contrast tab
        ["contrastHasEasyTrials", "bool"],
        ["isContrastDarkOnLight", "bool"],
        ["contrastOptotypeDiameter", "float"],
        ["contrastShowFixMark", "bool"], ["contrastTimeoutFixmark", "float"],
        ["contrastMaxLogCSWeber", "float"],
        ["gammaValue", "float"],
        ["contrastBitStealing", "bool"],
        ["isContrastDithering", "bool"],
        ["contrastCrowdingType", "int"], //↓Gratings tab
        ["gratingCPD", "float"],
        ["isGratingMasked", "bool"], ["gratingMaskDiaInDeg", "float"],
        ["isGratingErrorDiffusion", "bool"],
        ["isGratingColor", "bool"],
        ["what2sweepIndex", "int"],
        ["gratingCPDmin", "float"], ["gratingCPDmax", "float"],
        ["gratingContrastMichelsonPercent", "float"],
        ["isGratingObliqueOnly", "bool"],
        ["gratingShapeIndex", "int"],
        ["gratingForeColor", "col"], ["gratingBackColor", "col"], //↓BaLM tab
        ["balmIsiMillisecs", "int"], ["balmOnMillisecs", "int"],
        ["balmSpeedInDegPerSec", "float"],
        ["balmLocationDiameterInDeg", "float"],
        ["balmLocationEccentricityInDeg", "float"],
        ["balmMotionDiameterInDeg", "float"],
        ["balmSpeedInDegPerSec", "float"],
        ["balmExtentInDeg", "float"], //↓Misc tab
        ["windowBackgroundColor", "col"],
        ["specialBcmOn", "bool"],
        ["hideExitButton", "bool"],
        ["embedInNoise", "bool"], ["noiseContrast", "int"],
        ["soundTrialStartIndex", "int"], ["soundRunEndIndex", "int"],
        ["soundTrialYesIndex", "int"], ["soundTrialNoIndex", "int"],
        ["patID", "str"], ["eyeIndex", "int"],
        ["isAcuityPresentedConstant", "bool"],
        ["acuityPresentedConstantLogMAR", "float"],
        ["isAutoPreset", "bool"],
        ["enableTestAcuityLett", "bool"],
        ["enableTestAcuityLandolt", "bool"],
        ["enableTestAcuityE", "bool"],
        ["enableTestAcuityTAO", "bool"],
        ["enableTestAcuityVernier", "bool"],
        ["enableTestContrastLett", "bool"],
        ["enableTestContrastLandolt", "bool"],
        ["enableTestContrastE", "bool"],
        ["enableTestContrastG", "bool"],
        ["enableTestAcuityLineByLine", "bool"],
        ["enableTestBalmGeneral", "bool"],
        ["isAllSettingsDisabled", "bool"],
    ];

    for (const [name, type] of settingsNamesAndTypes) {
        switch (type) {
            case "str": [self addStringAccessors4Key: name]; break;
            case "int": [self addIntAccessors4Key: name]; break;
            case "bool": [self addBoolAccessors4Key: name]; break;
            case "float": [self addFloatAccessors4Key: name]; break;
            case "col": [self addColorAccessors4Key: name]; break;
            default: alert("Settings>initialize, this must not occur: " + type + ", " + name);
        }
    }
}


/**
 Helpers
 If `set` is true, the default `dflt` is set,
 otherwise check if outside of range or nil, if so set to default.
 A little chatty since no overloading available, also: BOOL/int/float are all of class CPNumber.
 */
+ (BOOL) checkBool: (BOOL) val dflt: (BOOL) def set: (BOOL) set {
    //console.info("chckBool ", val, "set: ", set);
    if (isNaN(val)) return def;
    if (!set && !isNaN(val)) return val;
    return def;
}
+ (int) checkNum: (CPNumber) val dflt: (int) def min: (int) min max: (int) max set: (BOOL) set { //console.info("chckInt ", val);
    if (!set && !isNaN(val) && (val <= max) && (val >= min)) return val;
    return def;
}


//CPColors are stored as hexString because the archiver does not work in Cappuccino. Why not??
//https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/DrawColor/Tasks/StoringNSColorInDefaults.html
+ (CPColor) _colorForKey: (CPString) keyString fallbackInHex: (CPString) fallbackInHex {
    let theData = [[CPUserDefaults standardUserDefaults] stringForKey: keyString];
    if (theData === nil) theData = fallbackInHex; //safety measure and default
    return [CPColor colorWithHexString: theData];
}
+ (void) _setColor: (CPColor) theColor forKey: (CPString) keyString {
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
        [self setDateOfSettingsVersion: kDateOfCurrentSettingsVersion];
        //for `CPColor` I have no `CheckCol` (yet) #tbd, worth it?
        [self setWindowBackgroundColor: [CPColor colorWithRed: 1 green: 1 blue: 0.9 alpha: 1]];
        [self setGratingForeColor: [CPColor lightGrayColor]];
        [self setGratingBackColor: [CPColor darkGrayColor]];
        [self setPresetName: "Standard Defaults"]; //synchronise with corresponding item in Presets!
        [self setPatID: "-"];
    }
    
    //above or for all setting tabs
    [self setAutoRunIndex: [self checkNum: [self autoRunIndex] dflt: kAutoRunIndexNone min: kAutoRunIndexNone max: kAutoRunIndexLow set: set]];
    [self setShowIdAndEyeOnMain: [self checkBool: [self showIdAndEyeOnMain] dflt: NO set: set]];
    
    //General stuff
    //need to check before setNAlternativesIndex 'cause oblique might force to index=0
    [self setIsGratingObliqueOnly: [self checkBool: [self isGratingObliqueOnly] dflt: NO set: set]];
    //for all tests
    [self setNAlternativesIndex: [self checkNum: [self nAlternativesIndex] dflt: kNAlternativesIndex8plus min: kNAlternativesIndex2 max: kNAlternativesIndex8plus set:set]]; //dflt:8
    [self setNTrials02: [self checkNum: [self nTrials02] dflt: 36 min: 1 max: 500 set: set]];
    [self setNTrials04: [self checkNum: [self nTrials04] dflt: 24 min: 1 max: 500 set: set]];
    [self setNTrials08: [self checkNum: [self nTrials08] dflt: 18 min: 1 max: 500 set: set]];
    
    [self setDistanceInCM: [self checkNum: [self distanceInCM] dflt: gDefaultDistanceInCM min: 1 max: 2500 set: set]];
    [self setCalBarLengthInMM: [self checkNum: [self calBarLengthInMM] dflt: gDefaultCalibrationBarLengthInMM min: 1 max: 10000 set: set]];
    
    [self setShowResponseInfoAtStart: [self checkBool: [self showResponseInfoAtStart] dflt: YES set: set]];
    [self setEnableTouchControls: [self checkBool: [self enableTouchControls] dflt: YES set: set]];
    
    [self setDecimalMarkCharIndex: [self checkNum: [self decimalMarkCharIndex] dflt: kDecimalMarkCharIndexAuto min: kDecimalMarkCharIndexAuto max: kDecimalMarkCharIndexComma set: set]];
    
    [self setTestOnFive: [self checkNum: [self testOnFive] dflt: kTestAcuityLett min: kTestNone max: kTestAcuityLineByLine set: set]]; //1: Sloan Letters
    
    [self setEccentXInDeg: [self checkNum: [self eccentXInDeg] dflt: 0 min: -99 max: 99 set: set]];
    [self setEccentYInDeg: [self checkNum: [self eccentYInDeg] dflt: 0 min: -99 max: 99 set: set]];
    [self setEccentShowCenterFixMark: [self checkBool: [self eccentShowCenterFixMark] dflt: YES set: set]];
    [self setEccentRandomizeX: [self checkBool: [self eccentRandomizeX] dflt: NO set: set]];
    [self setEccentRandomizeY: [self checkBool: [self eccentRandomizeY] dflt: NO set: set]];
    
    [self setAutoFullScreen: [self checkBool: [self autoFullScreen] dflt: NO set: set]];
    
    [self setRespondsToMobileOrientation: [self checkBool: [self respondsToMobileOrientation] dflt: YES set: set]];
    
    //0=normal, 1=mirror horizontally, 2=mirror vertically, 3=both=rot180°
    [self setDisplayTransform: [self checkNum: [self displayTransform] dflt: 0 min: 0 max: 3 set: set]];
    
    [self setShowTrialInfo: [self checkBool: [self showTrialInfo] dflt: YES set: set]];
    [self setTrialInfoFontSize: [self checkNum: [self trialInfoFontSize] dflt: 10 min: 4 max: 48 set: set]];
    
    [self setTimeoutIsiMillisecs: [self checkNum: [self timeoutIsiMillisecs] dflt: 0 min: 0 max: 3000 set: set]];
    [self setTimeoutResponseSeconds: [self checkNum: [self timeoutResponseSeconds] dflt: 30 min: 0.1 max: 9999 set: set]];
    [self setTimeoutDisplaySeconds: [self checkNum: [self timeoutDisplaySeconds] dflt: 30 min: 0.1 max: 9999 set: set]];
    
    [self setResultsToClipboardIndex: [self checkNum: [self resultsToClipboardIndex] dflt: kResultsToClipNone min: kResultsToClipNone max: kResultsToClipFullHistory2PDF set: set]];
    [self setPutResultsToClipboardSilent: [self checkBool: [self putResultsToClipboardSilent] dflt: NO set: set]];
    
    //0: none, 1: always, 2: on correct, 3: w/ info
    [self setAuditoryFeedback4trialIndex: [self checkNum: [self auditoryFeedback4trialIndex] dflt: kauditoryFeedback4trialIndexWithinfo min: kauditoryFeedback4trialIndexNone max: kauditoryFeedback4trialIndexWithinfo set: set]];
    //0: none, 1: always, 2: on correct, 3: w/ info
    [self setVisualFeedback: [self checkNum: [self visualFeedback] dflt: 0 min: 0 max: 3 set: set]]; //NOT IN USE
    [self setGiveAuditoryFeedback4run: [self checkBool: [self giveAuditoryFeedback4run] dflt: YES set: set]];
    [self setSoundVolume: [self checkNum: [self soundVolume] dflt: 20 min: 1 max: 100 set: set]];
    
    [self setShowRewardPicturesWhenDone: [self checkBool: [self showRewardPicturesWhenDone] dflt: NO set: set]];
    [self setTimeoutRewardPicturesInSeconds: [self checkNum: [self timeoutRewardPicturesInSeconds] dflt: 5 min: 0.1 max: 999 set: set]];
    
    [self setEmbedInNoise: [self checkBool: [self embedInNoise] dflt: NO set: set]];
    [self setNoiseContrast: [self checkNum: [self noiseContrast] dflt: 50 min: 0 max: 100 set: set]];
    
    //Acuity stuff
    [self setIsAcuityColor: [self checkBool: [self isAcuityColor] dflt: NO set: set]];
    [self setIsLandoltObliqueOnly: [self checkBool: [self isLandoltObliqueOnly] dflt: NO set: set]]; //only applies to acuity with 4 Landolt orienations
    [self setContrastAcuityWeber: [self checkNum: [self contrastAcuityWeber] dflt: 100 min: -1E6 max: 100 set: set]];
    [self calculateAcuityForeBackColorsFromContrast];
    [self setAcuityHasEasyTrials: [self checkBool: [self acuityHasEasyTrials] dflt: YES set: set]];
    [self setMaxDisplayedAcuity: [self checkNum: [self maxDisplayedAcuity] dflt: 2 min: 1 max: 99 set: set]];
    [self setMinStrokeAcuity: [self checkNum: [self minStrokeAcuity] dflt: 0.5 min: 0.5 max: 5 set: set]];
    [self setAcuityStartingLogMAR: [self checkNum: [self acuityStartingLogMAR] dflt: 1 min: 0.3 max: 2.5 set: set]];
    [self setMargin4maxOptotypeIndex: [self checkNum: [self margin4maxOptotypeIndex] dflt: 1 min: 0 max: 4 set: set]];
    [self setDoThreshCorrection: [self checkBool: [self doThreshCorrection] dflt: YES set: set]];
    [self setShowAcuityFormatDecimal: [self checkBool: [self showAcuityFormatDecimal] dflt: YES set: set]];
    [self setShowAcuityFormatLogMAR: [self checkBool: [self showAcuityFormatLogMAR] dflt: YES set: set]];
    [self setShowAcuityFormatSnellenFractionFoot: [self checkBool: [self showAcuityFormatSnellenFractionFoot] dflt: NO set: set]];
    [self setForceSnellen20: [self checkBool: [self forceSnellen20] dflt: NO set: set]];
    [self setShowCI95: [self checkBool: [self showCI95] dflt: NO set: set]];
    [self calculateMinMaxPossibleAcuity];
    
    //Crowding, crowdingType: 0 = none, 1: flanking bars, 2 = flanking rings, 3 = surounding bars, 4: surounding ring, 5 = surounding square, 6 = row of optotypes
    [self setCrowdingType: [self checkNum: [self crowdingType] dflt: 0 min: 0 max: 6 set: set]];
    //0 = 2·stroke between rings, 1 = fixed 2.6 arcmin between rings, 2 = fixed 30', 3 = like ETDRS
    [self setCrowdingDistanceCalculationType: [self checkNum: [self crowdingDistanceCalculationType] dflt: 0 min: 0 max: 3 set: set]];
    
    //Line-by-line stuff
    [self setTestOnLineByLineIndex: [self checkNum: [self testOnLineByLineIndex] dflt: 1 min: 1 max: 4 set: set]]; //1: Sloan Letters. 0: nicht erlaubt, 2: Landolt, 3…
    [self setLineByLineDistanceType: [self checkNum: [self lineByLineDistanceType] dflt: 1 min: 0 max: 1 set: set]]; //0: DIN-EN-ISO, 1: ETDRS
    [self setLineByLineHeadcountIndex: [self checkNum: [self lineByLineHeadcountIndex] dflt: 2 min: 0 max: 4 set: set]]; //0: "1", 2: "3", 3: "5", 4: "7"
    [self setLineByLineLinesIndex: [self checkNum: [self lineByLineLinesIndex] dflt: 0 min: 0 max: 2 set: set]]; //0: "1", 1: "3", 2: "5"
    [self setIsLineByLineChartModeConstantVA: [self checkBool: [self isLineByLineChartModeConstantVA] dflt: NO set: set]];
    
    //Vernier stuff
    [self setVernierType: [self checkNum: [self vernierType] dflt: 0 min: 0 max: 1 set: set]]; //2 or 3 bars
    [self setVernierWidth: [self checkNum: [self vernierWidth] dflt: 1.0 min: 0.1 max: 120 set: set]]; //in arcminutes
    [self setVernierLength: [self checkNum: [self vernierLength] dflt: 15.0 min: 0.1 max: 1200 set: set]];
    [self setVernierGap: [self checkNum: [self vernierGap] dflt: 0.2 min: 0.0 max: 120 set: set]];
    
    //Contrast stuff
    [self setGammaValue: [self checkNum: [self gammaValue] dflt: 2.0 min: 0.8 max: 4 set: set]];
    [self setContrastHasEasyTrials: [self checkBool: [self contrastHasEasyTrials] dflt: YES set: set]];
    [self setIsContrastDarkOnLight: [self checkBool: [self isContrastDarkOnLight] dflt: YES set: set]];
    [self setContrastOptotypeDiameter: [self checkNum: [self contrastOptotypeDiameter] dflt: 50 min: 1 max: 2500 set: set]];
    [self setContrastShowFixMark: [self checkBool: [self contrastShowFixMark] dflt: YES set: set]];
    [self setContrastTimeoutFixmark: [self checkNum: [self contrastTimeoutFixmark] dflt: 500 min: 20 max: 5000 set: set]];
    [self setContrastMaxLogCSWeber: [self checkNum: [self contrastMaxLogCSWeber] dflt: 3.0 min: 1.5 max: gMaxAllowedLogCSWeber set: set]];
    [self setContrastBitStealing: [self checkBool: [self contrastBitStealing] dflt: NO set: set]];
    [self setIsContrastDithering: [self checkBool: [self isContrastDithering] dflt: YES set: set]];
    [self setContrastCrowdingType: [self checkNum: [self contrastCrowdingType] dflt: 0 min: 0 max: 6 set: set]];
    
    //Grating stuff
    [self setGratingCPD: [self checkNum: [self gratingCPD] dflt: 2.0 min: 0.01 max: 18 set: set]];
    [self setIsGratingMasked: [self checkBool: [self isGratingMasked] dflt: NO set: set]];
    [self setGratingMaskDiaInDeg: [self checkNum: [self gratingMaskDiaInDeg] dflt: 10.0 min: 0.5 max: 50 set: set]];
    [self setIsGratingErrorDiffusion: [self checkBool: [self isGratingErrorDiffusion] dflt: YES set: set]];
    [self setGratingShapeIndex: [self checkNum: [self gratingShapeIndex] dflt: 0 min: 0 max: kGratingShapeIndexCheckerboard set: set]];
    [self setIsGratingColor: [self checkBool: [self isGratingColor] dflt: NO set: set]];
    [self setWhat2sweepIndex: [self checkNum: [self what2sweepIndex] dflt: 0 min: 0 max: 1 set: set]]; //0: sweep contrast, 1: sweep spatial frequency
    [self setGratingCPDmin: [self checkNum: [self gratingCPDmin] dflt: 0.5 min: 0.01 max: 60 set: set]];
    [self setGratingCPDmax: [self checkNum: [self gratingCPDmax] dflt: 30 min: 0.01 max: 60 set: set]];
    [self setGratingContrastMichelsonPercent: [self checkNum: [self gratingContrastMichelsonPercent] dflt: 95 min: 0.3 max: 99 set: set]];
    
    //BaLM stuff
    [self setBalmIsiMillisecs: [self checkNum: [self balmIsiMillisecs] dflt: 1500 min: 20 max: 5000 set: set]];
    [self setBalmOnMillisecs: [self checkNum: [self balmOnMillisecs] dflt: 200 min: 20 max: 2000 set: set]];
    [self setBalmLocationEccentricityInDeg: [self checkNum: [self balmLocationEccentricityInDeg] dflt: 15 min: 1 max: 30 set: set]];
    [self setBalmLocationDiameterInDeg: [self checkNum: [self balmLocationDiameterInDeg] dflt: 5 min: 0.1 max: 20 set: set]];
    [self setBalmMotionDiameterInDeg: [self checkNum: [self balmMotionDiameterInDeg] dflt: 3.3 min: 0.1 max: 10 set: set]];
    [self setBalmSpeedInDegPerSec: [self checkNum: [self balmSpeedInDegPerSec] dflt: 3.3 min: 0.1 max: 10 set: set]];
    [self setBalmExtentInDeg: [self checkNum: [self balmExtentInDeg] dflt: 15 min: 5 max: 30 set: set]];
    
    //Misc stuff
    [self setSpecialBcmOn: [self checkBool: [self specialBcmOn] dflt: NO set: set]];
    [self setHideExitButton: [self checkBool: [self hideExitButton] dflt: NO set: set]];
    
    [self setSoundTrialStartIndex: [self checkNum: [self soundTrialStartIndex] dflt: 1 min: 0 max: gSoundsTrialStart.length-1 set: set]];
    [self setSoundTrialYesIndex: [self checkNum: [self soundTrialYesIndex] dflt: 0 min: 0 max: gSoundsTrialYes.length-1 set: set]];
    [self setSoundTrialNoIndex: [self checkNum: [self soundTrialNoIndex] dflt: 0 min: 0 max: gSoundsTrialNo.length-1 set: set]];
    [self setSoundRunEndIndex: [self checkNum: [self soundRunEndIndex] dflt: 0 min: 0 max: gSoundsRunEnd.length-1 set: set]];
    [self setEyeIndex: [self checkNum: [self eyeIndex] dflt: 0 min: 0 max: 3 set: set]];
    
    [self setIsAcuityPresentedConstant: [self checkBool: [self isAcuityPresentedConstant] dflt: NO set: set]];
    [self setAcuityPresentedConstantLogMAR: [self checkNum: [self acuityPresentedConstantLogMAR] dflt: 0 min: -1.0 max: 3.0 set: set]];

    [self setIsAutoPreset: [self checkBool: [self isAutoPreset] dflt: NO set: set]];

    [self setEnableTestAcuityLett: [self checkBool: [self enableTestAcuityLett] dflt: YES set: set]];
    [self setEnableTestAcuityLandolt: [self checkBool: [self enableTestAcuityLandolt] dflt: YES set: set]];
    [self setEnableTestAcuityE: [self checkBool: [self enableTestAcuityE] dflt: YES set: set]];
    [self setEnableTestAcuityTAO: [self checkBool: [self enableTestAcuityTAO] dflt: YES set: set]];
    [self setEnableTestAcuityVernier: [self checkBool: [self enableTestAcuityVernier] dflt: YES set: set]];
    [self setEnableTestContrastLett: [self checkBool: [self enableTestContrastLett] dflt: YES set: set]];
    [self setEnableTestContrastLandolt: [self checkBool: [self enableTestContrastLandolt] dflt: YES set: set]];
    [self setEnableTestContrastE: [self checkBool: [self enableTestContrastE] dflt: YES set: set]];
    [self setEnableTestContrastG: [self checkBool: [self enableTestContrastG] dflt: YES set: set]];
    [self setEnableTestAcuityLineByLine: [self checkBool: [self enableTestAcuityLineByLine] dflt: YES set: set]];
    [self setEnableTestBalmGeneral: [self checkBool: [self enableTestBalmGeneral] dflt: YES set: set]];
    [self setIsAllSettingsDisabled: [self checkBool: [self isAllSettingsDisabled] dflt: NO set: set]];
    [[CPUserDefaults standardUserDefaults] synchronize];
}


+ (void) calculateMinMaxPossibleAcuity { //console.info("Settings>calculateMinMaxPossibleAcuity");
    let maxPossibleAcuityVal = [MiscSpace decVAFromStrokePixels: 1.0];
    const screenSize = Math.min(window.screen.height, window.screen.width);
    const strokeMaximal = screenSize / (5 + [self margin4maxOptotypeIndex]); //leave a margin of ½·index around the largest optotype
    let minPossibleAcuityVal = [MiscSpace decVAFromStrokePixels: strokeMaximal];
    //Correction for threshold underestimation of ascending procedures (as opposed to our bracketing one)
    minPossibleAcuityVal = [self doThreshCorrection] ? minPossibleAcuityVal * gThresholdCorrection4Ascending : minPossibleAcuityVal;
    [self setMinPossibleDecimalAcuityLocalisedString: [Misc stringFromNumber: minPossibleAcuityVal decimals: 3 localised: YES]];
    [self setMaxPossibleLogMAR: [MiscSpace logMARfromDecVA: minPossibleAcuityVal]]; //needed for color
    [self setMaxPossibleLogMARLocalisedString: [Misc stringFromNumber: [self maxPossibleLogMAR] decimals: 2 localised: YES]];
    
    //Correction for threshold underestimation of ascending procedures (as opposed to our bracketing one)
    maxPossibleAcuityVal = [self doThreshCorrection] ? maxPossibleAcuityVal * gThresholdCorrection4Ascending : maxPossibleAcuityVal;
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
}


/**
 Test if we need to set all Settings to defaults
 When new defaults are added, kDateOfCurrentSettingsVersion is updated. That tells FrACT that all settings need to be defaulted.
 */
+ (BOOL) needNewDefaults {
    return [self dateOfSettingsVersion] !== kDateOfCurrentSettingsVersion;
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
 individual getters / setters for all settings not synthesized in `initialize`
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


////////////////
+ (void) exportAllSettings { //CPLog("Settings>exportAllSettings")
    //Prepare JSON data
    const EXCLUDED_NAMES = new Set([ //some not necessary
        "presetName", //exclude because it's not reliable info
        "minPossibleDecimalAcuity", //this and ↓ are always calculated, omit
        "minPossibleLogMAR", "minPossibleLogMARLocalisedString",
        "maxPossibleLogMAR", "maxPossibleLogMARLocalisedString",
        "minPossibleDecimalAcuityLocalisedString",
        "maxPossibleDecimalAcuityLocalisedString",
        "distanceInInchLocalisedString"
    ]);
    const settingsToExport = settingsNamesAndTypes
        .filter(([name]) => !EXCLUDED_NAMES.has(name))
        .map(([name, type]) => {
            const value = [[CPUserDefaults standardUserDefaults] objectForKey: name];
            return [name, type, value];
        });
    let jsonString = JSON.stringify(settingsToExport); //all  in one long string, I not like
    jsonString = JSON.parse(jsonString); //parse string into JavaScript array
    jsonString = jsonString.map(item => JSON.stringify(item)); //stringify each triplet individually
    jsonString = '[\n' + jsonString.join(',\n') + '\n]' //join triplets with comma and newline, and wrap them. That's what I find more readable than the ", 2" option.
    const jsonBlob = new Blob([jsonString], {type: "application/json;charset=utf-8"});
    const suggestedFilename = "FrACT-settings-01";

    (async () => { //so we can use `await`
        if (window.showSaveFilePicker) { //Use modern API if available
            try {
                const handle = await window.showSaveFilePicker({
                    suggestedName: suggestedFilename,
                    types: [{description: 'JSON Files',
                        accept: {'application/json': ['.json']}}],
                });
                const writable = await handle.createWritable();
                await writable.write(jsonBlob);
                await writable.close(); //console.info('File saved successfully!');
            } catch (err) {
                if (err.name !== 'AbortError') {
                    console.error(err.name, err.message);
                } else {
                    console.info('Save operation cancelled by user.');
                }
            }
            return;
        }
        //Fallback for older browsers (FileSaver.js)
        let s = "Please enter a descriptive filename." + crlf + crlf;
        s += "I will remove illegal characters and add the extension ‘.json’." + crlf + crlf;
        s += "Your browser will ask: “Do you want to allow downloads…”." + crlf;
        s += "Afterwards, you can move that file from your downloads folder to a better place for future Importing."
        let filename = prompt(s, suggestedFilename);
        if (!filename) { //User cancelled the prompt
            console.info('Save operation cancelled by user.');
            return;
        }
        // Sanitize filename
        filename = filename.replace(/[\/\?<>\\:\*\|\""]/g, '_') //Replace illegal characters
            .trim().replace(/^\.+|\.+$/g, '')   //Trim whitespace and dots
            .slice(0, 50);                      //Limit length
        saveAs(jsonBlob, filename + ".json"); //finally save it in the downloads folder
    })();
}


+ (void) importAllSettings { //CPLog("Settings>importAllSettings")
    const dummyInput = document.createElement('input');
    dummyInput.type = 'file';  dummyInput.accept = '.json';
    dummyInput.style.display = 'none';
    document.body.appendChild(dummyInput);
    dummyInput.addEventListener('change', (event) => {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = (e) => {
                const fileContent = e.target.result;
                try {
                    const parsedContent = JSON.parse(fileContent);
                    let importOccurred = NO;
                    for (const [name, , value] of parsedContent) { //don't need `type`
                        if (value !== NULL) { //so "false" is also passing through
                            importOccurred = YES;
                            const previousVal = [[CPUserDefaults standardUserDefaults] objectForKey: name];
                            if (previousVal !== value) {
                                console.info(`Update '${name}': '${previousVal}' → '${value}'`);
                                [[CPUserDefaults standardUserDefaults] setObject: value forKey: name];
                            }
                        }
                    }
                    if (importOccurred) [self setPresetName: file.name];
                } catch (jsonError) { //handle potential JSON parsing errors
                    console.error("Error parsing JSON:", jsonError);
                    alert("The selected file is not valid JSON.");
                }
                document.body.removeChild(dummyInput); //clean up
                [self allNotCheckButSet: NO]; //vet imported settings
            };
            reader.readAsText(file);
        } else {
            document.body.removeChild(dummyInput); //clean up
        }
    });
    dummyInput.click();
}

/**
 Bool/Int/Float/String/Color helpers for synthesising class methods to get/set defaults
 */
+ (void) addBoolAccessors4Key: (CPString) key { //CPLog("Settings>addIntAccessors4Key called with key: " + key);
    if (key === "") return;
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
    if (key === "") return;
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
    if (key === "") return;
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
    if (key === "") return;
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
    if (key === "") return;
    const setterName = "set" + key.charAt(0).toUpperCase() + key.substring(1) + ":";
    const getterSel = CPSelectorFromString(key),
        setterSel = CPSelectorFromString(setterName);
    class_addMethod(self.isa, getterSel, function(self, _cmd) {
        return [self _colorForKey: key fallbackInHex: "777777"];
    });
    class_addMethod(self.isa, setterSel, function(self, _cmd, val) { //CPLog("Color setter called for key: " + key + " with value: " + val);
        [self _setColor: val forKey: key];
    });
}


@end
