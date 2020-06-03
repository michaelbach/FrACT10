/*
Settings, FrACT10
Created by mb on July 15, 2015.


History
=======

2020-06-03 fixed recursion with Auckimages
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


#define dateFract "2020-06-03"
#define versionFract "Version 10.0.beta"
#define dateSettingsCurrent "2020-05-19"
#define defaultDistanceInCM 399
#define defaultCalBarLengthInMM 149


@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import <Foundation/CPUserDefaults.j>
@import "Misc.j"


@implementation Settings: CPUserDefaultsController


+ (CPString) versionDate {return dateFract;}
+ (CPString) versionNumber {return versionFract;}


// helpers: check if outside range or nil, if so set default
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
    if (set) [self setDateSettingsVersion: dateSettingsCurrent];

    // for all tests
    [self setNTrials02: [self chckInt: [self nTrials02] def: 32 min: 1 max: 200 set: set]];
    [self setNTrials04: [self chckInt: [self nTrials04] def: 24 min: 1 max: 200 set: set]];
    [self setNTrials08: [self chckInt: [self nTrials08] def: 18 min: 1 max: 200 set: set]];

    [self setDistanceInCM: [self chckFlt: [self distanceInCM] def: defaultDistanceInCM min: 1 max: 2000 set: set]];
    [self setCalBarLengthInMM: [self chckFlt: [self calBarLengthInMM] def: defaultCalBarLengthInMM min: 1 max: 2000 set: set]];
    [self setCalBarLengthInPixel: [self chckFlt: [self calBarLengthInPixel] def: 700 min: 1 max: 2000 set: set]];

    [self setResponseInfoAtStart: [self chckBool: [self responseInfoAtStart] def: YES set: set]];
    [self setEnableTouchControls: [self chckBool: [self enableTouchControls] def: NO set: set]];

    [self setNOfRuns2Recall: [self chckInt: [self nOfRuns2Recall] def: 0 min: 0 max: 100 set: set]];

    [self setEccentXInDeg: [self chckFlt: [self eccentXInDeg] def: 0 min: -99 max: 99 set: set]];
    [self setEccentYInDeg: [self chckFlt: [self eccentYInDeg] def: 0 min: -99 max: 99 set: set]];

    // 0=normal, 1=mirror horizontally, 2=mirror vertically, 3=both=rot180°
    [self setDisplayTransform: [self chckInt: [self displayTransform] def: 0 min: 0 max: 3 set: set]];

    [self setTrialInfoFontSize: [self chckFlt: [self trialInfoFontSize] def: 9 min: 4 max: 48 set: set]];

    [self setTimeoutResponseSeconds: [self chckFlt: [self timeoutResponseSeconds] def: 30 min: 0.1 max: 9999 set: set]];
    [self setTimeoutDisplaySeconds: [self chckFlt: [self timeoutDisplaySeconds] def: 30 min: 0.1 max: 9999 set: set]];
    [self setMaskTimeOnResponseInMS: [self chckFlt: [self timeoutDisplaySeconds] def: 0 min: 0 max: 9999 set: set]];

    // 0:none, 1:always, 2:on correct, 3:w/ info
    [self setAuditoryFeedback: [self chckInt: [self auditoryFeedback] def: 3 min: 0 max: 3 set: set]];
    // 0:none, 1:always, 2:on correct, 3:2/ info, 4:on correct
    [self setVisualFeedback: [self chckInt: [self visualFeedback] def: 0 min: 0 max: 4 set: set]];
    [self setAuditoryFeedbackWhenDone: [self chckBool: [self auditoryFeedbackWhenDone] def: YES set: set]];

    // 0: no, 1: final only, 2: full history
    [self setResults2clipboard: [self chckInt: [self results2clipboard] def: 0 min: 0 max: 2 set: set]];

    [self setRewardPicturesWhenDone: [self chckBool: [self rewardPicturesWhenDone] def: YES set: set]];
    [self setTimeoutRewardPicturesInSeconds: [self chckFlt: [self timeoutRewardPicturesInSeconds] def: 5 min: 0.1 max: 999 set: set]];

    
    // Acuity stuff
    [self setContrastAcuity: [self chckFlt: [self contrastAcuity] def: 1 min: -1 max: 1 set: set]];
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
    [self setGammaValue: [self chckFlt: [self gammaValue] def: 1.8 min: 0.8 max: 4 set: set]];
    [self setContrastEasyTrials: [self chckBool: [self contrastEasyTrials] def: YES set: set]];

    if (set) { //console.info("FrACT10>>Settings>setting all to defaults")
        [[CPUserDefaults standardUserDefaults] setInteger: 2 forKey: "nAlternativesIndex"];//=8 alternatives
        [[CPUserDefaults standardUserDefaults] synchronize];
    }

    [[CPUserDefaults standardUserDefaults] synchronize];
}


+ (void) calculateMaxPossibleDecimalAcuity { //console.info("Settings>calculateMaxPossibleDecimalAcuity");
    var maxPossibleAcuityVal = [Misc visusFromGapPixels: 1.0];
    maxPossibleAcuityVal = [self threshCorrection] ? maxPossibleAcuityVal * 0.891 : maxPossibleAcuityVal;
    // Korrektur für Schwellenunterschätzung aufsteigender Verfahren
    [self setMaxPossibleDecimalAcuity: [Misc stringFromNumber: maxPossibleAcuityVal decimals: 2 localised: NO]];
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


+ (void) setDefaults { //console.info("Prefs>setDefaults");
    [self allNotCheckButSet: YES];
}


+ (BOOL) notCalibrated {
    [self checkDefaults];
    return (([self distanceInCM]==defaultDistanceInCM) || ([self calBarLengthInMM] == defaultCalBarLengthInMM));
}


+ (CPString) dateSettingsVersion { //console.info("Prefs>dateSettingsVersion");
    return [[CPUserDefaults standardUserDefaults] objectForKey: "dateSettingsVersion"];
}
+ (void) setDateSettingsVersion: (CPString) theValue { //console.info("Prefs>setDatesettingsVersion");
    [[CPUserDefaults standardUserDefaults] setObject: theValue forKey: "dateSettingsVersion"];
}


+ (int) nAlternatives { //console.info("Prefs>nAlternatives");
    switch ([[CPUserDefaults standardUserDefaults] integerForKey: "nAlternativesIndex"]) {
        case 0:  return 2;  break;
        case 1:  return 4;  break;
        case 2:  return 8;  break;
    }
}


+ (int) nTrials { //console.info("Prefs>nTrials");
    switch ([self nAlternatives]) {
        case 2:  return [self nTrials02];  break;
        case 4:  return [self nTrials04];  break;
        default:  return [self nTrials08];
    }
}


+ (int) nTrials02 { //console.info("Prefs>nTrials02");
    var t = [[CPUserDefaults standardUserDefaults] integerForKey: "nTrials02"]; //console.info(t);
    return t;
}
+ (void) setNTrials02: (int) theValue { //console.info("Prefs>nTrials02");
    [[CPUserDefaults standardUserDefaults] setInteger: theValue forKey: "nTrials02"];
}


+ (int) nTrials04 { //console.info("Prefs>nTrials04");
    return [[CPUserDefaults standardUserDefaults] integerForKey: "nTrials04"];
}
+ (void) setNTrials04: (int) theValue {
    [[CPUserDefaults standardUserDefaults] setInteger: theValue forKey: "nTrials04"];
}


+ (int) nTrials08 {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "nTrials08"];
}
+ (void) setNTrials08: (int) theValue {
    [[CPUserDefaults standardUserDefaults] setInteger: theValue forKey: "nTrials08"];
}


+ (float) distanceInCM {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "distanceInCM"];
}
+ (void)setDistanceInCM: (float) theValue {
    [[CPUserDefaults standardUserDefaults] setFloat: theValue forKey: "distanceInCM"];
}


+ (float) calBarLengthInMM {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "calBarLengthInMM"];
}
+ (void)setCalBarLengthInMM: (float) theValue {
    [[CPUserDefaults standardUserDefaults] setFloat: theValue forKey: "calBarLengthInMM"];
}


+ (float) calBarLengthInPixel {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "calBarLengthInPixel"];
}
+ (void)setCalBarLengthInPixel: (float) theValue {
    [[CPUserDefaults standardUserDefaults] setFloat: theValue forKey: "calBarLengthInPixel"];
}


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



+ (int) nAlternatives { //console.info("Prefs>nAlternatives");
    switch ([[CPUserDefaults standardUserDefaults] integerForKey: "nAlternativesIndex"]) {
        case 0:  return 2;  break;
        case 1:  return 4;  break;
        case 2:  return 8;  break;
    }
}


+ (BOOL) responseInfoAtStart {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "responseInfoAtStart"];
}
+ (void) setResponseInfoAtStart: (BOOL) theValue {
    [[CPUserDefaults standardUserDefaults] setBool: theValue forKey: "responseInfoAtStart"];
}


+ (BOOL) enableTouchControls {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "enableTouchControls"];
}
+ (void) setEnableTouchControls: (BOOL) theValue {
    [[CPUserDefaults standardUserDefaults] setBool: theValue forKey: "enableTouchControls"];
}


+ (float) eccentXInDeg {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "eccentXInDeg"];
}
+ (void) setEccentXInDeg: (float) theValue {
    [[CPUserDefaults standardUserDefaults] setFloat: theValue forKey: "eccentXInDeg"];
}


+ (float) eccentYInDeg {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "eccentYInDeg"];
}
+ (void) setEccentYInDeg: (float) theValue {
    [[CPUserDefaults standardUserDefaults] setFloat: theValue forKey: "eccentYInDeg"];
}


+ (int) displayTransform {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "displayTransform"];
}
+ (void) setDisplayTransform: (int) displayTransform {
    [[CPUserDefaults standardUserDefaults] setInteger: displayTransform forKey: "displayTransform"];
}


+ (float) maxPossibleDecimalAcuity {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "maxPossibleDecimalAcuity"];
}
+ (void) setMaxPossibleDecimalAcuity: (float) theValue {
    [[CPUserDefaults standardUserDefaults] setFloat: theValue forKey: "maxPossibleDecimalAcuity"];
}


+ (float) gammaValue {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "gammaValue"];
}
+ (void)setGammaValue: (float) theValue {
    [[CPUserDefaults standardUserDefaults] setFloat: theValue forKey: "gammaValue"];
}


+ (BOOL) threshCorrection {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "threshCorrection"];
}
+ (void)setThreshCorrection: (BOOL) theValue {
    [[CPUserDefaults standardUserDefaults] setBool: theValue forKey: "threshCorrection"];
}


+ (int) results2clipboard {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "results2clipboard"];
}
+ (void) setResults2clipboard: (float) theValue {
    [[CPUserDefaults standardUserDefaults] setInteger: theValue forKey: "results2clipboard"];
}


+ (int) nOfRuns2Recall {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "nOfRuns2Recall"];
}
+ (void) setNOfRuns2Recall: (float) theValue {
    [[CPUserDefaults standardUserDefaults] setInteger: theValue forKey: "nOfRuns2Recall"];
}


+ (int) vernierType {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "vernierType"];
}
+ (void) setVernierType: (float) theValue {
    [[CPUserDefaults standardUserDefaults] setInteger: theValue forKey: "vernierType"];
}


+ (float) vernierWidth {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "vernierWidth"];
}
+ (void) setVernierWidth: (float) theValue {
    [[CPUserDefaults standardUserDefaults] setFloat: theValue forKey: "vernierWidth"];
}


+ (float) vernierLength {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "vernierLength"];
}
+ (void) setVernierLength: (float) theValue {
    [[CPUserDefaults standardUserDefaults] setFloat: theValue forKey: "vernierLength"];
}


+ (float) vernierGap {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "vernierGap"];
}
+ (void) setVernierGap: (float) theValue {
    [[CPUserDefaults standardUserDefaults] setFloat: theValue forKey: "vernierGap"];
}


+ (int) trialInfoFontSize {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "trialInfoFontSize"];
}
+ (void) setTrialInfoFontSize: (float) theValue {
    [[CPUserDefaults standardUserDefaults] setInteger: theValue forKey: "trialInfoFontSize"];
}


+ (int) auditoryFeedback {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "auditoryFeedback"];
}
+ (void) setAuditoryFeedback: (float) theValue {
    [[CPUserDefaults standardUserDefaults] setInteger: theValue forKey: "auditoryFeedback"];
}


+ (int) visualFeedback {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "visualFeedback"];
}
+ (void) setVisualFeedback: (float) theValue {
    [[CPUserDefaults standardUserDefaults] setInteger: theValue forKey: "visualFeedback"];
}


+ (BOOL) auditoryFeedbackWhenDone {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "auditoryFeedbackWhenDone"];
}
+ (void)setAuditoryFeedbackWhenDone: (BOOL) theValue {
    [[CPUserDefaults standardUserDefaults] setBool: theValue forKey: "auditoryFeedbackWhenDone"];
}


+ (BOOL) rewardPicturesWhenDone {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "rewardPicturesWhenDone"];
}
+ (void)setRewardPicturesWhenDone: (BOOL) theValue {
    [[CPUserDefaults standardUserDefaults] setBool: theValue forKey: "rewardPicturesWhenDone"];
}
+ (float) timeoutRewardPicturesInSeconds {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "timeoutRewardPicturesInSeconds"];
}
+ (void) setTimeoutRewardPicturesInSeconds: (float) theValue { //console.info("Prefs>setTimeoutRewardPicturesInSeconds");
    [[CPUserDefaults standardUserDefaults] setFloat: theValue forKey: "timeoutRewardPicturesInSeconds"];
}


+ (float) maskTimeOnResponseInMS {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "maskTimeOnResponseInMS"];
}
+ (void)setMaskTimeOnResponseInMS: (float) theValue {
    [[CPUserDefaults standardUserDefaults] setFloat: theValue forKey: "maskTimeOnResponseInMS"];
}


+ (float) maxDisplayedAcuity {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "maxDisplayedAcuity"];
}
+ (void) setMaxDisplayedAcuity: (float) theValue {
    [[CPUserDefaults standardUserDefaults] setFloat: theValue forKey: "maxDisplayedAcuity"];
}


+ (int) crowdingType {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "crowdingType"];
}
+ (void) setCrowdingType: (float) theValue {
    [[CPUserDefaults standardUserDefaults] setInteger: theValue forKey: "crowdingType"];
}


+ (int) crowdingDistanceCalculationType {
    return [[CPUserDefaults standardUserDefaults] integerForKey: "crowdingDistanceCalculationType"];
}
+ (void) setCrowdingDistanceCalculationType: (float) theValue {
    [[CPUserDefaults standardUserDefaults] setInteger: theValue forKey: "crowdingDistanceCalculationType"];
}


+ (BOOL) acuityFormatDecimal {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "acuityFormatDecimal"];
}
+ (void) setAcuityFormatDecimal: (BOOL) theValue {
    [[CPUserDefaults standardUserDefaults] setBool: theValue forKey: "acuityFormatDecimal"];
}


+ (BOOL) acuityFormatLogMAR {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "acuityFormatLogMAR"];
}
+ (void) setAcuityFormatLogMAR: (BOOL) theValue {
    [[CPUserDefaults standardUserDefaults] setBool: theValue forKey: "acuityFormatLogMAR"];
}


+ (BOOL) acuityFormatSnellenFractionFoot {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "acuityFormatSnellenFractionFoot"];
}
+ (void) setAcuityFormatSnellenFractionFoot: (BOOL) theValue {
    [[CPUserDefaults standardUserDefaults] setBool: theValue forKey: "acuityFormatSnellenFractionFoot"];
}
+ (BOOL) forceSnellen20 {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "forceSnellen20"];
}
+ (void) setForceSnellen20: (BOOL) theValue {
    [[CPUserDefaults standardUserDefaults] setBool: theValue forKey: "forceSnellen20"];
}


+ (float) contrastAcuity {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "contrastAcuity"];
}
+ (void) setContrastAcuity: (float) theValue {
    [[CPUserDefaults standardUserDefaults] setFloat: theValue forKey: "contrastAcuity"];
}


+ (CPColor) acuityForeColor {
    var aColor = [CPColor blackColor];
    var theData = [[CPUserDefaults standardUserDefaults] dataForKey: "acuityForeColor"];
    if (theData != nil)
        aColor = (CPColor) [CPUnarchiver unarchiveObjectWithData: theData];
    return aColor;
}
+ (void) setAcuityForeColor: (CPColor) theColor {
    var theData = [CPArchiver archivedDataWithRootObject: theColor];
    [[CPUserDefaults standardUserDefaults] setObject: theData forKey: "acuityForeColor"];
}
//+ (CPColor) acuityBackColor


+ (BOOL) acuityEasyTrials {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "acuityEasyTrials"];
}
+ (void) setAcuityEasyTrials: (BOOL) theValue {
    [[CPUserDefaults standardUserDefaults] setBool: theValue forKey: "acuityEasyTrials"];
}


+ (BOOL) contrastEasyTrials {
    return [[CPUserDefaults standardUserDefaults] boolForKey: "contrastEasyTrials"];
}
+ (void) setContrastEasyTrials: (BOOL) theValue {
    [[CPUserDefaults standardUserDefaults] setBool: theValue forKey: "contrastEasyTrials"];
}


+ (float) timeoutResponseSeconds {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "timeoutResponseSeconds"];
}
+ (void) setTimeoutResponseSeconds: (float) theValue {
    [[CPUserDefaults standardUserDefaults] setFloat: theValue forKey: "timeoutResponseSeconds"];
}


+ (float) timeoutDisplaySeconds {
    return [[CPUserDefaults standardUserDefaults] floatForKey: "timeoutDisplaySeconds"];
}
+ (void) setTimeoutDisplaySeconds: (float) theValue {
    [[CPUserDefaults standardUserDefaults] setFloat: theValue forKey: "timeoutDisplaySeconds"];
}


@end
