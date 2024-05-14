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
    CPString _presetName;
    CPPopUpButton _popUpButton;
}


/**
 Init and add all preset names to the Presets popup in the Settings pane
 */
- (id) initWithPopup: (CPPopUpButton) thePopUpButton { //console.info("Presets>initWithPopup");
    self = [super init];
    if (self) {

        /* first entry: Header, all others need corresponding code in the “if orgy” further down. */
        const allPresets = ["PRESETS", "Standard Defaults", "Demo", "Testing", "ESU", "ULV", "Color Equiluminance", "BCM@Scheie", "CNS@Freiburg", "Maculight", "Hyper@TUDo"];

        _popUpButton = thePopUpButton; // local copy for later
        [_popUpButton removeAllItems];
        for (const aPreset of allPresets) [_popUpButton addItemWithTitle: aPreset];
        [_popUpButton setSelectedIndex: 0]; // always show "PRESETS"
    }
    return self;
}


/**
 Called by the action of the preset selection pop-up, "Are you sure" dialog before applying
 */
- (void) apply: (id) sender { //console.info("Presets>apply");
    const _presetIndex = [sender indexOfSelectedItem];
    if (_presetIndex == 0) {//console.info("_presetIndex == 0");
        return;
    }
    _presetName = [sender itemTitleAtIndex: _presetIndex];
    const messageText = "Really all Settings to “" + _presetName + "” ?";
    const alert1 = [CPAlert alertWithMessageText: messageText
                                   defaultButton: "NO" alternateButton: "YES" otherButton: nil
                       informativeTextWithFormat: "Many Settings will change. You should know what you are doing here. Luckily, you can always return to defaults."];
    [[alert1 buttons][0] setKeyEquivalent: "y"]; // the "Yes" button selected by "y"
    [alert1 runModalWithDidEndBlock: function(alert, returnCode) {
        if (returnCode==1) { // alternateButton
            [self apply2];
        }
    }];
}


/**
 Apply selected preset after "Are you sure" dialog
 */
- (void) apply2 { //console.info("Presets>apply2");
    let presetFound = NO;
    
    // the "needless" if-stacking↓ allows for easy re-arrangment in `allPresets` above
    if (_presetName == "Standard Defaults") {
        [Settings setDefaults];  presetFound = YES;
    }
    
    if (_presetName == "Demo") {
        [Settings setDefaults];
        [self applyTestingPreset];
        [Settings setAutoRunIndex: kAutoRunIndexMid];
        presetFound = YES;
    }
    
    if (_presetName == "Testing") {// easier testing
        [self applyTestingPreset];  presetFound = YES;
    }
    
    if (_presetName == "ESU") { // secret project :)
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
        presetFound = YES;
    }
    
    if (_presetName == "ULV") { // Ultra Low Vision settings
        [self setStandardDefaultsKeepingCalBarLength];
        // general pane
        [Settings setResponseInfoAtStart: NO];  [Settings setEnableTouchControls: NO];
        // acuity pane
        [Settings setAcuityStartingLogMAR: 2.5];
        presetFound = YES;
    }
    
    if (_presetName == "Color Equiluminance") { // near equiluminant color acuity
        [self applyTestingPreset];
        [Settings setIsAcuityColor: YES];
        [Settings setAcuityForeColor: [CPColor redColor]];
        // ↓ dark green, near equiluminant to red
        [Settings setAcuityBackColor: [CPColor colorWithRed: 0 green: 0.70 blue: 0 alpha: 1]];
        [[CPNotificationCenter defaultCenter] postNotificationName: "copyColorsFromSettings" object: nil];
        presetFound = YES;
    }
    
    if (_presetName == "BCM@Scheie") { // a clinical study
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
        presetFound = YES;
    }
    
    if (_presetName == "CNS@Freiburg") { // a clinical study
        [Settings setDefaults];
        // general pane
        [Settings setResponseInfoAtStart: NO];  [Settings setEnableTouchControls: NO];
        [Settings setMobileOrientation: NO];
        [Settings setResults2clipboard: kResults2ClipFinalOnly];
        [Settings setDistanceInCM: 200];
        [Settings setTestOnFive: kTestAcuityLett];
        // acuity pane
        // gratings pane
        presetFound = YES;
    }
    
    if (_presetName == "Maculight") { // a clinical study
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
        presetFound = YES;
    }
    
    if (_presetName == "Hyper@TUDo") {
        [Settings setDefaults];
        // General pane
        [Settings setTimeoutResponseSeconds: 600]; [Settings setTimeoutDisplaySeconds: 90];
        [Settings setDistanceInCM: 147]; [Settings setCalBarLengthInMM: 134];
        [Settings setResponseInfoAtStart: NO];
        [Settings setTestOnFive: kTestNone];
        [Settings setResults2clipboard: kResults2ClipFullHistory];
        [Settings setResults2clipboardSilent: YES];
        // Acuity pane
        [Settings setVernierType: kVernierType3bars];
        [Settings setVernierWidth: 1.5]; [Settings setVernierLength: 40]; [Settings setVernierGap: 0.2];
        [Settings setShowCI95: YES];
        // Gamma pane
        [Settings setGammaValue: 2.2];
        // Misc pane
        [Settings setWindowBackgroundColor: [CPColor whiteColor]];
        presetFound = YES;
    }

    if (_presetName == "Generic Template") { // only as template for new entries
        [Settings setDefaults];
        // General pane
        // Acuity pane
        // Contrast pane
        // Gratings pane
        // Gamma pane
        // Misc pane
        presetFound = YES;
    }

    if (!presetFound) return;  // should never occur
    
    [[CPNotificationCenter defaultCenter] postNotificationName: "copyColorsFromSettings" object: nil]; // this synchronises the color settings between userdefaults & AppController
    const messageText = "Preset  »" + _presetName + "«  was applied."
    const alert2 = [CPAlert alertWithMessageText: messageText
                                   defaultButton: "OK" alternateButton: nil otherButton: nil
                       informativeTextWithFormat: ""];
    [alert2 runModal];
    [Settings setPresetName: _presetName];
    [_popUpButton setSelectedIndex: 0]; // always show "PRESETS"
}


- (void) applyTestingPreset { // used several times, so it has its own function
    [self setStandardDefaultsKeepingCalBarLength];
    // general pane
    [Settings setDistanceInCM: 400];
    [Settings setCalBarLengthInMM: 150];
    [Settings setResponseInfoAtStart: NO];
    // acuity pane
    [Settings setShowCI95: YES];
}


- (void) setStandardDefaultsKeepingCalBarLength {
    const calBarLengthInMM_prior = [Settings calBarLengthInMM];
    [Settings setDefaults];
    [Settings setCalBarLengthInMM: calBarLengthInMM_prior];
}

@end
