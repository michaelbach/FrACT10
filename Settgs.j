/*
Settgs, FrACT10
Created by mb on July 15, 2015.


 History
 =======

 2017-08-05 Acuity working
 2017-07-18 serious restart with design help by PM
*/


#define dateFract @"2017-08-22"
#define versionFract @"Vs10.beta"
#define dateSettingsCurrent @"2017-08-05"
#define defaultDistanceInCM 399
#define defaultCalBarLengthInMM 149


@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import <Foundation/CPUserDefaults.j>
@import "Misc.j"


@implementation Settgs : CPUserDefaultsController


+ (CPString) versionDate {return dateFract;}
+ (CPString) versionNumber {return versionFract;}


+ (int) chckNm: (float) val def: (float) def min: (float) min max: (float) max set: (BOOL) set {//console.log("chckNm ", val);
    if (!set && !isNaN(val) && (val <= max) && (val >= min))  return val;
    return def;
}
+ (void) allNotCheckButSet: (BOOL) set {
    if (set) [self setDatePreferences: dateSettingsCurrent];
    [[CPUserDefaults standardUserDefaults] synchronize];

    [self setNTrials02: [self chckNm: [self nTrials02] def: 32 min: 1 max: 200 set: set]];
    [self setNTrials04: [self chckNm: [self nTrials04] def: 24 min: 1 max: 200 set: set]];
    [self setNTrials08: [self chckNm: [self nTrials08] def: 18 min: 1 max: 200 set: set]];

    [self setDistanceInCM: [self chckNm: [self distanceInCM] def: defaultDistanceInCM min: 1 max: 2000 set: set]];
    [self setCalBarLengthInMM: [self chckNm: [self calBarLengthInMM] def: defaultCalBarLengthInMM min: 1 max: 2000 set: set]];
    [self setCalBarLengthInPixel: [self chckNm: [self calBarLengthInPixel] def: 700 min: 1 max: 2000 set: set]];

    [self setGammaValue: [self chckNm: [self gammaValue] def: 1.8 min: 0.8 max: 4 set: set]];

    [self setTimeoutResponseSeconds: [self chckNm: [self timeoutResponseSeconds] def: 30 min: 0.1 max: 9999 set: set]];
    [self setTimeoutDisplaySeconds: [self chckNm: [self timeoutDisplaySeconds] def: 30 min: 0.1 max: 9999 set: set]];

    if (set) {
        [[CPUserDefaults standardUserDefaults] setInteger: 2 forKey: "nAlternativesIndex"];//=8 alternatives
        [self setAcuityFormatDecimal: YES];
        [self setAcuityFormatLogMAR: YES];
        [self setAcuityFormatSnellenFractionFoot: NO];
        [self setForceSnellen20: NO];
        [self setThreshCorrection: YES];
        [self setAcuityEasyTrials: YES];
        [self setContrastEasyTrials: YES];
        //[self setAcuityForeColor: [CPColor blackColor]];
        [[CPUserDefaults standardUserDefaults] synchronize];
    }

    var maxPossibleAcuity = [Misc visusFromGapPixels: 1.0];
    maxPossibleAcuity = [self threshCorrection] ? maxPossibleAcuity * 0.891 : maxPossibleAcuity;// Korrektur für Schwellenunterschätzung aufsteigender Verfahren
    [self setMaxPossibleDecimalAcuity: [Misc stringFromNumber: maxPossibleAcuity decimals: 2 localised: YES]];
    [[CPUserDefaults standardUserDefaults] synchronize];
}


+ (void) checkDefaults {//console.log("Settgs>checkDefaults");
    if ([self datePreferences] != dateSettingsCurrent) {
        var s = "»FrACT«: First run or major version change:\r\n\r\n";
        s += "All settings are reset to their default values, please check them.\r\n";
        s += "\r\n[If all settings are empty, simply reload, next time they'll be fine.]\r\n";
        alert(s);
        [self setDefaults];
    } else {
        [self allNotCheckButSet: NO];
    }
    [[CPUserDefaults standardUserDefaults] synchronize];
}


+ (void) setDefaults {//console.log("Prefs>setDefaults");
    [self allNotCheckButSet: YES];
}


+ (BOOL) notCalibrated {
    return (([self distanceInCM]==defaultDistanceInCM) || ([self calBarLengthInMM]==defaultCalBarLengthInMM));
}


+ (CPString) datePreferences {   //console.log("Prefs>datePreferences");
    return [[CPUserDefaults standardUserDefaults] objectForKey: "datePreferences"];
}
+ (void) setDatePreferences: (CPString) theValue {   //console.log("Prefs>setDatePreferences");
    [[CPUserDefaults standardUserDefaults] setObject: theValue forKey: "datePreferences"];
}


+ (int) nAlternatives {   //console.log("Prefs>nAlternatives");
    switch ([[CPUserDefaults standardUserDefaults] integerForKey: "nAlternativesIndex"]) {
        case 0:  return 2;  break;
        case 1:  return 4;  break;
        case 2:  return 8;  break;
    }
}


+ (int) nTrials {   //console.log("Prefs>nTrials");
    switch ([self nAlternatives]) {
        case 2:  return [self nTrials02];  break;
        case 4:  return [self nTrials04];  break;
        default:  return [self nTrials08];
    }
}


+ (int) nTrials02 {//console.log("Prefs>nTrials02");
    var t = [[CPUserDefaults standardUserDefaults] integerForKey: "nTrials02"];  //console.log(t);
    return t;
}
+ (void) setNTrials02: (int) theValue {   //console.log("Prefs>setNTrials02", " ", theValue);
    [[CPUserDefaults standardUserDefaults] setInteger: theValue forKey: "nTrials02"];
}


+ (int) nTrials04 {
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
    if ([[CPUserDefaults standardUserDefaults] integerForKey: "decimalMarkCharIndex"]==0) {
        return "."
    } else {
        return ","
    }
}
+ (void) setDecimalMarkChar: (char) mark {
    var idx = (mark == ".") ? 0 : 1;
    [[CPUserDefaults standardUserDefaults] setInteger: idx forKey: "decimalMarkCharIndex"];
}



+ (int) nAlternatives {   //console.log("Prefs>nAlternatives");
    switch ([[CPUserDefaults standardUserDefaults] integerForKey: "nAlternativesIndex"]) {
        case 0:  return 2;  break;
        case 1:  return 4;  break;
        case 2:  return 8;  break;
    }
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


+ (CPColor) acuityForeColor {
    var aColor = [CPColor blackColor];
    var theData = [[CPUserDefaults standardUserDefaults] dataForKey: @"acuityForeColor"];
    if (theData != nil)
        aColor = (CPColor) [CPUnarchiver unarchiveObjectWithData: theData];
    return aColor;
}
+ (void) setAcuityForeColor: (CPColor) theColor {
    var theData = [CPArchiver archivedDataWithRootObject: theColor];
    [[CPUserDefaults standardUserDefaults] setObject: theData forKey: @"acuityForeColor"];
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
