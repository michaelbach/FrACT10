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

@import "ControlDispatcher.j"


@typedef feedbackTypeType
kFeedbackTypeNone = 0; kFeedbackTypeGUI = 1; kFeedbackTypeHTMLMessage = 2;


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
        /* first entry: Header, all others need corresponding code in the “switch orgy” further down. */
        const allPresets = ["PRESETS", "Standard Defaults", "Demo", "Testing", "ESU", "ULV", "Color Equiluminance", "BCM@Scheie", "CNS@Freiburg", "Maculight", "Hyper@TUDo", "AT@LeviLab"];

        _popUpButton = thePopUpButton; // local copy for later
        [_popUpButton removeAllItems];
        for (const aPreset of allPresets) [_popUpButton addItemWithTitle: aPreset];
        [_popUpButton setSelectedIndex: 0]; // always show "PRESETS"

        [[CPNotificationCenter defaultCenter] addObserver: self selector: @selector(applyPresetNamed:) name: "applyPresetNamed" object: nil];
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
            [self apply2withFeedbackType: kFeedbackTypeGUI];
        }
    }];
}


/**
 Called by by ControlDispatcher after receiving a pertinent HTMLMessage
 */
- (void) applyPresetNamed: (CPNotification) aNotification { //console.info("Presets>applyPresetNamed");
    _presetName = [aNotification object];
    [self apply2withFeedbackType: kFeedbackTypeHTMLMessage];
}


/**
 Apply selected preset after successful "Are you sure" dialog
 */
- (void) apply2withFeedbackType: (feedbackTypeType) feedbackType { //console.info("Presets>apply2", _presetName);
    switch (_presetName) {
        case "Standard Defaults":
            [Settings setDefaults];  break;
        case "Demo":
            [Settings setDefaults];
            [self applyTestingPresets];
            [Settings setAutoRunIndex: kAutoRunIndexMid];
            break;
        case "Testing": // easier testing
            [self applyTestingPresets];  break;
        case "ESU": // secret project :)
            [self setStandardDefaultsKeepingCalBarLength];
            // general pane
            [Settings setResponseInfoAtStart: NO];  [Settings setEnableTouchControls: NO];
            [Settings setDistanceInCM: 150];
            [[CPUserDefaults standardUserDefaults] setInteger: 1 forKey: "nAlternativesIndex"]; // 4 alternatives
            [Settings setNTrials04: 18];
            [Settings setTestOnFive: kTestAcuityC];
            [Settings setTimeoutResponseSeconds: 999]; [Settings setTimeoutDisplaySeconds: 999];
            [Settings setAuditoryFeedback4trial: 0];
            [Settings setRewardPicturesWhenDone: YES];
            [Settings setDecimalMarkCharIndex: kDecimalMarkCharIndexComma];
            [Settings setResults2clipboard: kResults2ClipNone];
            // acuity pane
            [Settings setAcuityFormatLogMAR: NO];
            // other
            [Settings setTrialInfoFontSize: 24];
            //displayIncompleteRuns = true; not implemented yet
            break;
        case "ULV": // Ultra Low Vision settings
            [self setStandardDefaultsKeepingCalBarLength];
            // general pane
            [Settings setResponseInfoAtStart: NO];  [Settings setEnableTouchControls: NO];
            // acuity pane
            [Settings setAcuityStartingLogMAR: 2.5];
            break;
        case "Color Equiluminance": // near equiluminant color acuity
            [self applyTestingPresets];
            [Settings setIsAcuityColor: YES];
            [Settings setAcuityForeColor: [CPColor redColor]];
            // ↓ dark green, near equiluminant to red
            [Settings setAcuityBackColor: [CPColor colorWithRed: 0 green: 0.70 blue: 0 alpha: 1]];
            [[CPNotificationCenter defaultCenter] postNotificationName: "copyColorsFromSettings" object: nil];
            break;
        case "BCM@Scheie": // a clinical study
            [Settings setDefaults];
            // general pane
            [Settings setNAlternativesIndex: 0];  [Settings setNTrials02: 10];
            [Settings setTimeoutResponseSeconds: 120]; [Settings setTimeoutDisplaySeconds: 120];
            [Settings setResponseInfoAtStart: NO];  [Settings setEnableTouchControls: NO];
            [Settings setMobileOrientation: NO];
            [Settings setResults2clipboard: kResults2ClipFullHistory];
            [Settings setAuditoryFeedback4trial: 0];
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
            [Settings setWhat2sweepIndex: 1];
            [Settings setGratingContrastMichelsonPercent: 99];
            [Settings setGratingCPDmin: 1];
            [Settings setGratingCPDmax: 7];
            break;
        case "CNS@Freiburg": // a clinical study
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
        case "Maculight": // a clinical study
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
        case "Hyper@TUDo":
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
            [Settings setSoundTrialNoIndex: 1];
            break;
        case "AT@LeviLab": // for Ângela
            [self setStandardDefaultsKeepingCalBarLength];
            // General pane
            [[CPUserDefaults standardUserDefaults] setInteger: 1 forKey: "nAlternativesIndex"]; // 4
            [Settings setNTrials04: 24];
            [Settings setResponseInfoAtStart: NO];  [Settings setEnableTouchControls: NO];
            [Settings setDecimalMarkCharIndex: kDecimalMarkCharIndexComma];
            [Settings setTimeoutDisplaySeconds: 0.15];
            [Settings setEccentXInDeg: 8];
            [Settings setDistanceInCM: 68.5];
            [Settings setResults2clipboard: kResults2ClipFullHistory];
            [Settings setDisplayTransform: 1]; // 1=mirror horizontally
            [Settings setTestOnFive: kTestAcuityC];
            // Acuity pane
            [Settings setMaxDisplayedAcuity: 99];
            // Misc pane
            [Settings setEccentRandomizeX: YES];
            break;
        case "Generic Template": // only as template for new entries
            [Settings setDefaults];
            // General pane
            // Acuity pane
            // Contrast pane
            // Gratings pane
            // Gamma pane
            // Misc pane
            break;
        default:
            console.log("Frac10>Presets>unknown preset: ", _presetName);
            if (feedbackType == kFeedbackTypeHTMLMessage) {
                [ControlDispatcher post2parentM1: "Settings" m2: "Preset" m3: _presetName success: false];
            }
            return;
    }
    [[CPNotificationCenter defaultCenter] postNotificationName: "updateSoundFiles" object: nil];
    [[CPNotificationCenter defaultCenter] postNotificationName: "copyColorsFromSettings" object: nil]; // this synchronises the color settings between userdefaults & AppController
    [Settings setPresetName: _presetName];
    [_popUpButton setSelectedIndex: 0]; // always show "PRESETS"

    switch (feedbackType) {
        case kFeedbackTypeGUI:
            const messageText = "Preset  »" + _presetName + "«  was applied."
            const alert2 = [CPAlert alertWithMessageText: messageText
                                       defaultButton: "OK" alternateButton: nil otherButton: nil
                           informativeTextWithFormat: ""];
            [alert2 runModal];
            break;
        case kFeedbackTypeHTMLMessage:
            [ControlDispatcher post2parentM1: "Settings" m2: "Preset" m3: _presetName success: true];
            break;
    }
}


- (void) applyTestingPresets { // used several times, so it has its own function
    [self setStandardDefaultsKeepingCalBarLength];
    // general pane
    [Settings setDistanceInCM: 400];
    [Settings setCalBarLengthInMM: 150];
    [Settings setResponseInfoAtStart: NO];
    // acuity pane
    [Settings setShowCI95: YES];
    // Misc pane
    [Settings setSoundTrialYesIndex: 0]; [Settings setSoundTrialNoIndex: 1]; [Settings setSoundRunEndIndex: 1];
}


- (void) setStandardDefaultsKeepingCalBarLength {
    const calBarLengthInMM_prior = [Settings calBarLengthInMM];
    [Settings setDefaults];
    [Settings setCalBarLengthInMM: calBarLengthInMM_prior];
}

@end

