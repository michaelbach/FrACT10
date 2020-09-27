/*
Settings, FrACT10
Created by mb on July 15, 2015.
*/

#define dateFract "2020-09-28"
#define versionFract "Version 10.0.beta"
#define dateSettingsCurrent "2020-05-19"
#define defaultDistanceInCM 399
#define defaultCalBarLengthInMM 149

/* History
   =======

2020-09-28 correct actual contrast levels reported back to Thresholder. Limited logCSWeber to 4.0 when %=0.
            This allowed basing all reported contrast values on stimStrengthInDeviceunits
2020-09-27 renamed Pest → ThresholderPest, added Tooltips for contrast checks
2020-09-02 introduce class FractControllerContrast, add ContrastC & ContrastE, fix Vernier in reduced contrast
2020-08-30 changed the internal contrast scale to logCS, renamed many functions, finished contrast
2020-08-20 Contrast Letters seems to be working, added button and contrast GUI tab, added appropriate Settings
2020-08-17 refactored to separate the "Optotypes"
2020-07-03 add @typedef TestIDType; @typedef StateType
2020-07-03 Export: Vs: 2; add comma/dot; add button → cheat sheet in Help
2020-07-03 rename (nearly) all "Auck…" to TAO…, default no reward images, default testOn5: Sloan Letters
2020-06-24 add "test on 5"
2020-06-22 AucklandOptotypes → TAO(s)
2020-06-18 improve logic to enable➶ the export button; correct minute in date conversion (1 t0o high); new manual location
2020-06-17 add “This is free software. There is no warranty for anything" to About panel.
            moved the "defines" to top, so not to forget upping the date and version
2020-06-16 add volume control to Sound.j, Settings & GUI; moved contrastAcuityWeber plausibility control → Settings
2020-06-12 add logic to make sure not all formats are de-selected
 add "trialInfo" checkbox and logic
2020-06-11 add "localStorage" from the HTML Web Storage API for an alternative export version,
            optotype contrast now in Weber units, renamed contrast conversion formulae to discern Weber/Michelson,
            systematic export string, factored rangeOverflowIndicator, add it to Vernier,
            link to new manual
2020-06-09  recover from nil data in hexString conversion
            finish contrast effect on optotypes. Vernier now ok, TAO not. Some Misc function renamed to fit Objective-J
2020-06-08a add contrast effect on optotypes, Vernier still wrong, TAO not. Tweak Settings GUI
2020-06-08 simplify Settings, set default touch to YES, add eccentricity to all tests, buttonExport disabled→hidden
2020-06-07 fix regression on export alert sequence after adding the button
2020-06-05 add export button
2020-06-03 fixed recursion with Auckimages, Auckland Optotypes now with buttons for touch
2020-06-02 AppController window now centered when in fullScreen,
            renamed console.log → console.info (don't need no log),
            rewardImageView now programmatically added, not in IB (it always got in the way)
            simplified controller allocation etc. by using an array, dito for panels
2020-06-01 added Misc>stringFromInteger, touchResponse 4 Vernier & LandoltC
            truly randomised iRandom
2020-06-01 bug with tooltips: need to change something else in IB too.
            corrected typos. <esc> still doesn't work in the info screens
            touchResponse works for E, factored out infoText
2020-05-31 enableTouchControls no accessible from info screen, improved tab sequence
2020-05-29 Text correction in GUI;  added buttons for touch devices to Sloan Letters;  prepared contrast
2020-05-28 Settings: maxPossAcuity on General tab, and now updates as needed via delegate controlTextDidEndEditing when leaving field
            maxPossAcuity was not set correctly with localisation (float needs dot!)
2020-05-26 Settings: shifted all to chckBool / chckInt / chckFlt
            crowding largely done
2020-05-25 vernier now correct results. maxDisplayedAcuity. Help panel. Feedback sounds. GUI tweaks.
2020-05-23 added Vernier acuity; outfactored RewardsController, added Tooltips
2020-05-22 added Auckland Optotypes
2020-05-21 →clipboard for exporting works in Safari & FireFox,
            reward pictures
2020-05-19 new buttons with images; alerted at less obnoxious stages;
 the empty default window fields still not saved, but with an appropriate alert.
2020-05-13 alert → CPAlert
2020-05-09 modifyDeviceStimulus now acuityModifyDeviceStimulusDIN01_02_04_08]; like FrACT,
            alternatives now initialised appropriately,
            all 10 letters in letters
2020-05-08 Fixed input problems with FireFox
2017-08-05 Acuity working
2017-07-18 serious restart with design help by PM
*/


@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import <Foundation/CPUserDefaults.j>
@import "Misc.j"


@implementation Settings: CPUserDefaultsController


+ (CPString) versionDate {return dateFract;}
+ (CPString) versionNumber {return versionFract;}


// helpers:
// if "set == true" the default is set,
// otherwise check if outside range or nil, if so also set default
+ (BOOL) chckBool: (BOOL) val def: (BOOL) def set: (BOOL) set { //console.info("chckBool ", val);
    if (!set && !isNaN(val))  return val;
    return def;
}
+ (int) chckInt: (int) val def: (int) def min: (int) min max: (int) max set: (BOOL) set { //console.info("chckFlt ", val);
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
        [self setDateSettingsVersion: dateSettingsCurrent];
        [[CPUserDefaults standardUserDefaults] setInteger: 2 forKey: "nAlternativesIndex"]; // 8 alternatives
    }

    // for all tests
    [self setNTrials02: [self chckInt: [self nTrials02] def: 32 min: 1 max: 200 set: set]];
    [self setNTrials04: [self chckInt: [self nTrials04] def: 24 min: 1 max: 200 set: set]];
    [self setNTrials08: [self chckInt: [self nTrials08] def: 18 min: 1 max: 200 set: set]];

    [self setDistanceInCM: [self chckFlt: [self distanceInCM] def: defaultDistanceInCM min: 1 max: 2000 set: set]];
    [self setCalBarLengthInMM: [self chckFlt: [self calBarLengthInMM] def: defaultCalBarLengthInMM min: 1 max: 2000 set: set]];
    [self setCalBarLengthInPixel: [self chckFlt: [self calBarLengthInPixel] def: 700 min: 1 max: 2000 set: set]];

    [self setResponseInfoAtStart: [self chckBool: [self responseInfoAtStart] def: YES set: set]];
    [self setEnableTouchControls: [self chckBool: [self enableTouchControls] def: YES set: set]];
    
    [self setTestOnFive: [self chckInt: [self testOnFive] def: 1 min: 0 max: 8 set: set]]; // 1: Sloan Letters

    [self setNOfRuns2Recall: [self chckInt: [self nOfRuns2Recall] def: 0 min: 0 max: 100 set: set]];

    [self setEccentXInDeg: [self chckFlt: [self eccentXInDeg] def: 0 min: -99 max: 99 set: set]];
    [self setEccentYInDeg: [self chckFlt: [self eccentYInDeg] def: 0 min: -99 max: 99 set: set]];

    // 0=normal, 1=mirror horizontally, 2=mirror vertically, 3=both=rot180°
    [self setDisplayTransform: [self chckInt: [self displayTransform] def: 0 min: 0 max: 3 set: set]];
    
    [self setTrialInfo: [self chckBool: [self trialInfo] def: YES set: set]];
    [self setTrialInfoFontSize: [self chckFlt: [self trialInfoFontSize] def: 9 min: 4 max: 48 set: set]];

    [self setTimeoutResponseSeconds: [self chckFlt: [self timeoutResponseSeconds] def: 30 min: 0.1 max: 9999 set: set]];
    [self setTimeoutDisplaySeconds: [self chckFlt: [self timeoutDisplaySeconds] def: 30 min: 0.1 max: 9999 set: set]];
    [self setMaskTimeOnResponseInMS: [self chckFlt: [self timeoutDisplaySeconds] def: 0 min: 0 max: 9999 set: set]];

    // 0: no, 1: final only, 2: full history
    [self setResults2clipboard: [self chckInt: [self results2clipboard] def: 0 min: 0 max: 2 set: set]];

    // 0: none, 1: always, 2: on correct, 3: w/ info
    [self setAuditoryFeedback: [self chckInt: [self auditoryFeedback] def: 3 min: 0 max: 3 set: set]];
    // 0: none, 1: always, 2: on correct, 3: w/ info
    [self setVisualFeedback: [self chckInt: [self visualFeedback] def: 0 min: 0 max: 3 set: set]]; // NOT IN USE
    [self setAuditoryFeedbackWhenDone: [self chckBool: [self auditoryFeedbackWhenDone] def: YES set: set]];
    [self setSoundVolume: [self chckFlt: [self soundVolume] def: 20 min: 1 max: 100 set: set]];

    [self setRewardPicturesWhenDone: [self chckBool: [self rewardPicturesWhenDone] def: NO set: set]];
    [self setTimeoutRewardPicturesInSeconds: [self chckFlt: [self timeoutRewardPicturesInSeconds] def: 5 min: 0.1 max: 999 set: set]];

    
    // Acuity stufflowerLuminanceFromContrast
    [self setContrastAcuityWeber: [self chckFlt: [self contrastAcuityWeber] def: 100 min: -100 max: 100 set: set]];
    [self calculateAcuityForeBackColorsFromContrast];
    [self setAcuityEasyTrials: [self chckBool: [self acuityEasyTrials] def: YES set: set]];
    [self setMaxDisplayedAcuity: [self chckFlt: [self maxDisplayedAcuity] def: 2 min: 1 max: 99 set: set]];
    [self setThreshCorrection: [self chckBool: [self threshCorrection] def: YES set: set]];
    [self setAcuityFormatDecimal: [self chckBool: [self acuityFormatDecimal] def: YES set: set]];
    [self setAcuityFormatLogMAR: [self chckBool: [self acuityFormatLogMAR] def: YES set: set]];
    [self setAcuityFormatSnellenFractionFoot: [self chckBool: [self acuityFormatSnellenFractionFoot] def: NO set: set]];
    [self setForceSnellen20: [self chckBool: [self forceSnellen20] def: NO set: set]];
    [self calculateMaxPossibleDecimalAcuity];

    // Crowding
    // crowdingType: 0 = none, 1 = flanking rings, 2 = row of optotypes, 3 = frame (ring), 4 = frame (square)
    [self setCrowdingType: [self chckInt: [self crowdingType] def: 0 min: 0 max: 4 set: set]];
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
    var maxPossibleAcuityVal = [Misc visusFromGapPixels: 1.0];
    maxPossibleAcuityVal = [self threshCorrection] ? maxPossibleAcuityVal * 0.891 : maxPossibleAcuityVal;
    // Correction for threshold underestimation of ascending procedures (as opposed to our bracketing one)
    [self setMaxPossibleDecimalAcuity: [Misc stringFromNumber: maxPossibleAcuityVal decimals: 2 localised: NO]];
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


+ (BOOL) needNewDefaults {
    return [self dateSettingsVersion] != dateSettingsCurrent;
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


+ (BOOL) notCalibrated {
    [self checkDefaults];
    return (([self distanceInCM]==defaultDistanceInCM) || ([self calBarLengthInMM] == defaultCalBarLengthInMM));
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
+ (void)setAuditoryFeedbackWhenDone: (BOOL) value {
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





+ (char) decimalMarkChar {
    if ([[CPUserDefaults standardUserDefaults] integerForKey: "decimalMarkCharIndex"] == 0) {
        return "."
    } else {
        return ","
    }
}
+ (void) setDecimalMarkChar: (char) mark {
    var idx = (mark == ".") ? 0 : 1;
    [[CPUserDefaults standardUserDefaults] setInteger: idx forKey: "decimalMarkCharIndex"];
}



+ (BOOL) enableTouchControls {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "enableTouchControls"];
}
+ (void) setEnableTouchControls: (BOOL) value {
    [[CPUserDefaults standardUserDefaults] setBool: value forKey: "enableTouchControls"];
}


+ (float) maxPossibleDecimalAcuity {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "maxPossibleDecimalAcuity"];
}
+ (void) setMaxPossibleDecimalAcuity: (float) value {
    [[CPUserDefaults standardUserDefaults] setFloat: value forKey: "maxPossibleDecimalAcuity"];
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
