/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2022 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>
 
 Presets.j
 
 */


/**
 Allow presets of settings
 2024-05-09 major rewrite to avoid repeated information
 2022-05-20 begun
 */
@implementation Presets: CPObject {
    CPString presetNameInGUI, presetNameInSwitch;
}


/**
 Add all preset names to the Presets popup in Settings
 */
+ (void) populatePresetsGivenPopup: (CPPopUpButton) thePopUpButton {

    const allPresets = ["PRESETS", "Standard Defaults", "Demo", "Testing", "ESU", "ULV", "ColorEquiluminance", "BCM@Scheie", "CNS@Freiburg", "Maculight"];

    [thePopUpButton removeAllItems];
    for (const aPreset of allPresets) [thePopUpButton addItemWithTitle: aPreset];
}


/**
 Called by the action of the preset selection pop-up, shows the "Are you sure" dialog
 */
+ (void) apply: (id) sender { //console.info("Presets>apply");
    const selectedPresetIndex = [sender indexOfSelectedItem];
    if (selectedPresetIndex == 0) {//console.info("selectedPresetIndex == 0");
        return;
    }
    presetNameInGUI = [sender itemTitleAtIndex: selectedPresetIndex];
    const messageText = "Really all Settings to “" + presetNameInGUI + "” ?";
    const alert1 = [CPAlert alertWithMessageText: messageText
                             defaultButton: "NO" alternateButton: "YES" otherButton: nil
                 informativeTextWithFormat: "Many Settings might change. You should know what you are doing here. Luckily, you can always return to defaults."];
    [[alert1 buttons][0] setKeyEquivalent:"y"]; // the "Yes" butten selected by "y"
    [alert1 runModalWithDidEndBlock: function(alert, returnCode) {
        if (returnCode==1) { // alternateButton
            [self apply2: selectedPresetIndex];
        }
    }];
}


/**
 Apply selected preset after "Are you sure" dialog
 */
+ (void) apply2: (int) p { //console.info("Presets>apply2");
    switch(p) { // the case constants refer to the index in `allPresets`
        case 0: return; // should not occur
        case 1: presetNameInSwitch = "Standard Defaults";
            [Settings setDefaults];
            break;
            
        case 2: presetNameInSwitch = "Demo";
            [Settings setDefaults];
            [self applyTesting];
            [Settings setAutoRunIndex: kAutoRunIndexMid];
            break;
            
        case 3: presetNameInSwitch = "Testing";// easier testing
            [self applyTesting];
            break;
            
        case 4: presetNameInSwitch = "ESU"; // (secret project)
            [self setStandardDefaultsKeepingCalBarLength];
            // general pane
            [Settings setResponseInfoAtStart: NO];  [Settings setEnableTouchControls: NO];
            [Settings setDistanceInCM: 150];
            [[CPUserDefaults standardUserDefaults] setInteger: 1 forKey: "nAlternativesIndex"]; // 4 alternatives
            [Settings setNTrials04: 18];
            [Settings setTestOnFive: kTestAcuityC];
            [Settings setTimeoutResponseSeconds: 999]; [Settings setTimeoutDisplaySeconds: 999];
            [Settings setAuditoryFeedback: 0];
            [Settings setRewardPicturesWhenDone: YES];
            [Settings setDecimalMarkChar: ","];
            [Settings setResults2clipboard: kResults2ClipNone];
            // acuity pane
            [Settings setAcuityFormatLogMAR: NO];
            // other
            [Settings setTrialInfoFontSize: 24];
            //displayIncompleteRuns = true; not implemented yet
            break;
            
        case 5: presetNameInSwitch = "ULV"; // Ultra Low Vision settings
            [self setStandardDefaultsKeepingCalBarLength];
            // general pane
            [Settings setResponseInfoAtStart: NO];  [Settings setEnableTouchControls: NO];
            // acuity pane
            [Settings setAcuityStartingLogMAR: 2.5];
            break;
            
        case 6: presetNameInSwitch = "ColorEquiluminance"; // near equiluminant color acuity
            [self applyTesting];
            [Settings setIsAcuityColor: YES];
            [Settings setAcuityForeColor: [CPColor redColor]];
            // the below gives a darker green, near equiluminant to red
            [Settings setAcuityBackColor: [CPColor colorWithRed: 0 green: 0.70 blue: 0 alpha: 1]];
            [[CPNotificationCenter defaultCenter] postNotificationName: "copyColorsFromSettings" object: nil];
            break;
            
        case 7: presetNameInSwitch = "BCM@Scheie";
            [Settings setDefaults];
            // general pane
            [Settings setNAlternativesIndex: 0];  [Settings setNTrials02: 10];
            [Settings setTimeoutResponseSeconds: 120]; [Settings setTimeoutDisplaySeconds: 120];
            [Settings setResponseInfoAtStart: NO];  [Settings setEnableTouchControls: NO];
            [Settings setMobileOrientation: NO];
            [Settings setResults2clipboard: kResults2ClipFullHistory];
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
            break;
            
        case 8: presetNameInSwitch = "CNS@Freiburg";
            [Settings setDefaults];
            // general pane
            [Settings setResponseInfoAtStart: NO];  [Settings setEnableTouchControls: NO];
            [Settings setMobileOrientation: NO];
            [Settings setResults2clipboard: kResults2ClipFinalOnly];
            [Settings setDistanceInCM: 200];
            [Settings setTestOnFive: kTestAcuityLett];
            // acuity pane
            // gratings pane
            break;
            
        case 9:  presetNameInSwitch = "Maculight";
            [self setStandardDefaultsKeepingCalBarLength];
            // general pane
            [Settings setResponseInfoAtStart: NO];  [Settings setEnableTouchControls: NO];
            [Settings setResults2clipboard: kResults2ClipFinalOnly];
            [Settings setDistanceInCM: 400];
            [Settings setTestOnFive: kTestAcuityLett];
            // acuity pane
            // contrast pane
            [Settings setContrastOptotypeDiameter: 170];
            // gratings pane
            break;
    }
    if (presetNameInSwitch != presetNameInGUI) [self runtimeError_action: nil];;

    [[CPNotificationCenter defaultCenter] postNotificationName: "copyColorsFromSettings" object: nil]; // this synchronises the color settings between userdefaults & AppController
    const messageText = "Preset “" + presetNameInGUI + "” was applied."
    const alert2 = [CPAlert alertWithMessageText: messageText
                             defaultButton: "OK" alternateButton: nil otherButton: nil
                 informativeTextWithFormat: ""];
    [alert2 runModal];
    [Settings setPresetName: presetNameInGUI];
}


+ (void) applyTesting { // used several times, so it has its own function
    [self setStandardDefaultsKeepingCalBarLength];
    // general pane
    [Settings setDistanceInCM: 400];
    [Settings setCalBarLengthInMM: 150];
    [Settings setResponseInfoAtStart: NO];
    // acuity pane
    [Settings setShowCI95: YES];
}


+ (void) setStandardDefaultsKeepingCalBarLength {
    const calBarLengthInMM_prior = [Settings calBarLengthInMM];
    [Settings setDefaults];
    [Settings setCalBarLengthInMM: calBarLengthInMM_prior];
}

@end
