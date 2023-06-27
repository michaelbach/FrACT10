/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2022 Michael Bach, michael.bach@uni-freiburg.de, <https://michaelbach.de>
 
 Presets.j
 
 */


/**
 Allow presets of settings
 2022-05-20  begun
 */
@implementation Presets {
    SEL gSelector;
    CPAlert alert1, alert2;
    CPArray presetNames;
    CPString currentPresetName;
}



+ (CPString) capitalizeFirstLetter: (CPString) s {
    if (s.length < 1)  return @"";
    else if (s.length == 1)  return [s capitalizedString];
    const firstChar = [[s substringToIndex: 1] uppercaseString];
    const otherChars = [s substringWithRange: CPMakeRange(1, s.length - 1)];
    return firstChar + otherChars;
}


// Testing the `performSelector` approach. It works!
// This is for a planned key-value format
/*let s = "distanceInCM";
 s = [Presets capitalizeFirstLetter: s];
 s = "set" + s + ":"; //console.info(s);
 gSelector = CPSelectorFromString(s);
 [Settings performSelector: gSelector withObject: [CPNumber numberWithInt: 99]];*/


/**
 Called by the action of the preset selection pop-up, shows the "Are you sure" dialog
 */
+ (void) apply: (int) p { //console.info("Presets>apply");
    presetNames = ["default", "ULV", "ESU", "Test", "Test Color Equiluminance"];
    if ((p < 0) | (p > presetNames.length)) return;
    currentPresetName = presetNames[p];
    const s = "Really apply the preset “" + currentPresetName + "” ?"
    alert1 = [CPAlert alertWithMessageText: s
                             defaultButton: "NO" alternateButton: "YES" otherButton: nil
                 informativeTextWithFormat: "Many Settings might change. You should know what you are doing here. Luckily, you can always return to defaults in Settings."];
    [alert1 runModalWithDidEndBlock: function(alert, returnCode) {
        if (returnCode==1) [self apply2: p]; // alternateButton
    }]
}


+ (void) setStandardDefaultsKeepingCalBarLength {
    const calBarLengthInMM_prior = [Settings calBarLengthInMM];
    [Settings setDefaults];
    [Settings setCalBarLengthInMM: calBarLengthInMM_prior];
}


/**
 Apply selected patch after "Are you sure" dialog
 */
+ (void) apply2: (int) p { //console.info("Presets>apply2");
    switch (p) {
        case 1: //console.info("ULV");
            [self applyULV];  break;
        case 2:
            [self applyESU];  break;
        case 3:
            [self applyTest];  break;
        case 4:
            [self applyTestColorEquiluminance];  break;
        default:
            [Settings setDefaults];
    }
    const s = "Preset “" + currentPresetName + "” was applied."
    alert2 = [CPAlert alertWithMessageText: s
                             defaultButton: "OK" alternateButton: nil otherButton: nil
                 informativeTextWithFormat: ""];
    [alert2 runModal];
}


/**
 Apply ULV = Ultra Low Vision settings
 */
+ (void) applyULV { //console.info("ULV");
    [self setStandardDefaultsKeepingCalBarLength];
    [Settings setResponseInfoAtStart: NO];  [Settings setEnableTouchControls: NO];
    [Settings setAcuityStartingLogMAR: 2.5];
}


/**
 Apply ESU settings (secret project)
 */
+ (void) applyESU {
    [self setStandardDefaultsKeepingCalBarLength];
    [Settings setResponseInfoAtStart: NO];  [Settings setEnableTouchControls: NO];

    [Settings setDistanceInCM: 150];
    
    [[CPUserDefaults standardUserDefaults] setInteger: 1 forKey: "nAlternativesIndex"]; // 4 alternatives
    [Settings setNTrials04: 18];
    [Settings setTestOnFive: 2];
    
    [Settings setTimeoutResponseSeconds: 999]; [Settings setTimeoutDisplaySeconds: 999];
    
    [Settings setAuditoryFeedback: 0];
    [Settings setRewardPicturesWhenDone: YES];
    
    [Settings setAcuityFormatLogMAR: NO];
    [Settings setDecimalMarkChar: ","];
    [Settings setResults2clipboard: 0];
    
    //displayIncompleteRuns = true; not implemented yet
    [Settings setTrialInfoFontSize: 24];
}


/**
 Apply Test: easier testing
 */
+ (void) applyTest {
    [self setStandardDefaultsKeepingCalBarLength];
    [Settings setDistanceInCM: 400];
    [Settings setCalBarLengthInMM: 150];
    [Settings setResponseInfoAtStart: NO];
    [Settings setShowCI95: YES];
}


/**
 Apply near equiluminant color acuity
 */
+ (void) applyTestColorEquiluminance {
    [self applyTest];
    [Settings setIsAcuityColor: YES];
    [Settings setAcuityForeColor: [CPColor redColor]];
    // the below gives a darker green, near equiluminant to red
    [Settings setAcuityBackColor: [CPColor colorWithRed: 0 green: 0.70 blue: 0 alpha: 1]];
    [[CPNotificationCenter defaultCenter] postNotificationName: "copyForeBackColorsFromSettings" object: nil];
}

@end
