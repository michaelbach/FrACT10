/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2022 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>
 
 Presets.j
 
 */


/**
 Allow presets of settings
 2022-05-20  begun
 */
@implementation Presets {
    SEL gSelector;
    CPAlert alert1, alert2;
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
+ (void) apply: (id) sender { //console.info("Presets>apply");
    const p = [sender indexOfSelectedItem];
    currentPresetName = [sender itemTitleAtIndex: p];
    const s = "Really apply “" + currentPresetName + "” ?"
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
        case 3:
            [self applyTesting];  break;
        case 4:
            [self applyTestColorEquiluminance];  break;
        case 5:
            [self applyTestBCM_RonB]; break;
        case 6:
            [self applyTestBCM_BonY]; break;
        case 7:
            [self applyTestBCMAtScheie]; break;
        default:
            [Settings setDefaults];
    }
    const s = "Preset “" + currentPresetName + "” was applied."
    alert2 = [CPAlert alertWithMessageText: s
                             defaultButton: "OK" alternateButton: nil otherButton: nil
                 informativeTextWithFormat: ""];
    [alert2 runModal];
}


+ (void) setStandardDefaultsKeepingCalBarLength {
    const calBarLengthInMM_prior = [Settings calBarLengthInMM];
    [Settings setDefaults];
    [Settings setCalBarLengthInMM: calBarLengthInMM_prior];
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
+ (void) applyTesting {
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


/**
 Apply RCM-RonB/BonY
 */
+ (void) applyBCM {
    [self applyTesting];
}
+ (void) applyTestBCM_RonB {
    [self applyBCM];
    [Settings setIsAcuityColor: YES];
    [Settings setAcuityForeColor: [CPColor colorWithRed: 255 green: 0 blue: 0 alpha: 1]];
    [Settings setAcuityBackColor: [CPColor colorWithRed: 0 green: 0 blue: 255 alpha: 1]];
    [[CPNotificationCenter defaultCenter] postNotificationName: "copyForeBackColorsFromSettings" object: nil];
}
+ (void) applyTestBCM_BonY {
    [self applyBCM];
    [Settings setIsAcuityColor: YES];
    [Settings setAcuityForeColor: [CPColor colorWithRed: 0 green: 0 blue: 255 alpha: 1]];
    [Settings setAcuityBackColor: [CPColor colorWithRed: 200 green: 200 blue: 0 alpha: 1]];
    [[CPNotificationCenter defaultCenter] postNotificationName: "copyForeBackColorsFromSettings" object: nil];
}
+ (void) applyTestBCMAtScheie {
    [Settings setDefaults];
    // general pane
    [Settings setNAlternativesIndex: 0];  [Settings setNTrials02: 10];
    [Settings setTimeoutResponseSeconds: 120]; [Settings setTimeoutDisplaySeconds: 120];
    [Settings setResponseInfoAtStart: NO];  [Settings setEnableTouchControls: NO];
    [Settings setMobileOrientation: NO];
    [Settings setResults2clipboard: 2];
    [Settings setAuditoryFeedback: 0];
    [Settings setCalBarLengthInMM: 189];  [Settings setDistanceInCM: 100];
    // acuity pane
    [Settings setContrastAcuityWeber: -1E6];
    [Settings setTestOnLineByLineDistanceType: 1];  [Settings setLineByLineHeadcountIndex: 0];
    [Settings setAcuityEasyTrials: NO];
    // gratings pane
    [Settings setContrastEasyTrials: NO];
    [Settings setGratingObliqueOnly: YES];
    [Settings setIsGratingColor: YES];
    [Settings setGratingForeColor: [CPColor colorWithRed: 255 green: 0 blue: 255 alpha: 1]];
    [Settings setGratingBackColor: [CPColor colorWithRed: 0 green: 0 blue: 255 alpha: 1]];
    [Settings setWhat2SweepIndex: 1];
    [Settings setGratingContrastMichelsonPercent: 99];
    [Settings setGratingCPDmin: 1];
    [Settings setGratingCPDmax: 7];
}


@end
