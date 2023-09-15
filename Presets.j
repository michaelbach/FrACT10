/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2022 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>
 
 Presets.j
 
 */


/**
 Allow presets of settings
 2022-05-20  begun
 */
@implementation Presets: CPObject {
}


/**
 Called by the action of the preset selection pop-up, shows the "Are you sure" dialog
 */
+ (void) apply: (id) sender { //console.info("Presets>apply");
    const selectedPresetIndex = [sender indexOfSelectedItem];
    if (selectedPresetIndex == 0) {
        console.info("selectedPresetIndex == 0");
        return;
    }
    const selectedPresetName = [sender itemTitleAtIndex: selectedPresetIndex];
    const messageText = "Really all Settings to “" + selectedPresetName + "” ?"
    const alert1 = [CPAlert alertWithMessageText: messageText
                             defaultButton: "NO" alternateButton: "YES" otherButton: nil
                 informativeTextWithFormat: "Many Settings might change. You should know what you are doing here. Luckily, you can always return to defaults in Settings."];
    [[alert1 buttons][0] setKeyEquivalent:"y"]; // the "Yes" butten selected by "y"
    [alert1 runModalWithDidEndBlock: function(alert, returnCode) {
        if (returnCode==1) { // alternateButton
            [self apply2: selectedPresetIndex - 1];
        }
    }]
}
/**
 Apply selected patch after "Are you sure" dialog
 */
+ (void) apply2: (int) p { //console.info("Presets>apply2");
    const allPresets = ["StandardDefaults", "ULV", "ESU", "Testing", "ColorEquiluminance", "BCMatScheie"];
    const selectedPresetName = allPresets[p];
    [self performSelector: CPSelectorFromString("apply" + selectedPresetName)];
    [[CPNotificationCenter defaultCenter] postNotificationName: "copyColorsFromSettings" object: nil]; // this synchronises the color settings between userdefaults & AppController
    const messageText = "Preset “" + selectedPresetName + "” was applied."
    const alert2 = [CPAlert alertWithMessageText: messageText
                             defaultButton: "OK" alternateButton: nil otherButton: nil
                 informativeTextWithFormat: ""];
    [alert2 runModal];
}


+ (void) applyStandardDefaults {
    [Settings setDefaults];
}


+ (void) setStandardDefaultsKeepingCalBarLength {
    const calBarLengthInMM_prior = [Settings calBarLengthInMM];
    [Settings setDefaults];
    [Settings setCalBarLengthInMM: calBarLengthInMM_prior];
}


/**
 Apply ULV = Ultra Low Vision settings
 */
+ (void) applyULV { //console.info("applyULV");
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
+ (void) applyColorEquiluminance {
    [self applyTesting];
    [Settings setIsAcuityColor: YES];
    [Settings setAcuityForeColor: [CPColor redColor]];
    // the below gives a darker green, near equiluminant to red
    [Settings setAcuityBackColor: [CPColor colorWithRed: 0 green: 0.70 blue: 0 alpha: 1]];
    [[CPNotificationCenter defaultCenter] postNotificationName: "copyColorsFromSettings" object: nil];
}


/**
 Apply applyBCMatScheie
 */
+ (void) applyBCMatScheie {
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
