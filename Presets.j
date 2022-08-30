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
    var firstChar = [[s substringToIndex: 1] uppercaseString];
    var otherChars = [s substringWithRange: CPMakeRange(1, s.length - 1)];
    return firstChar + otherChars;
}


// Testing the `performSelector` approach. It works!
// This is for a planned key-value format
/*var s = "distanceInCM";
 s = [Presets capitalizeFirstLetter: s];
 s = "set" + s + ":"; //console.info(s);
 gSelector = CPSelectorFromString(s);
 [Settings performSelector: gSelector withObject: [CPNumber numberWithInt: 99]];*/


/**
 Called by the action of the preset selection pop-up, shows to "Are you sure" dialog
 */
+ (void) apply: (int) p { //console.info("Presets>apply");
    presetNames = ["default", "ULV", "ESU"];
    if ((p < 0) | (p > presetNames.length)) return;
    currentPresetName = presetNames[p];
    var s = "Really apply the preset “" + currentPresetName + "” ?"
    alert1 = [CPAlert alertWithMessageText: s
                             defaultButton: "NO" alternateButton: "YES" otherButton: nil
                 informativeTextWithFormat: "Many Settings might change. You should know what you are doing here. Luckily, you can always return to defaults in Settings."];
    [alert1 runModalWithDidEndBlock: function(alert, returnCode) {
        if (returnCode==1) [self apply2: p]; // alternateButton
    }]
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
        default:
            [Settings setDefaults];
    }
    var s = "Preset “" + currentPresetName + "” was applied."
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
+ (void) applyESU { //console.info("ESU");
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


+ (void) setStandardDefaultsKeepingCalBarLength {
    var calBarLengthInMM_prior = [Settings calBarLengthInMM];
    [Settings setDefaults];
    [Settings setCalBarLengthInMM: calBarLengthInMM_prior];
}
@end
