/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2022 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 Presets.j

 */


/**
 Allow presets of settings
 2024-09-11 begin moving presets to categories← no, singletons
 2024-05-09 major rewrite to avoid repeated information
 2022-05-20 begun
 */

@import "ControlDispatcher.j"
@import "Presets_AT_LeviLab.j";
@import "Presets_BCM_Scheie.j";
@import "Presets_CNS_Freiburg.j";
@import "Presets_ESU.j";
@import "Presets_Hyper_TUDo.j";
@import "Presets_Maculight.j";
@import "Presets_ULV_Gensight.j";
@import "Presets_ETCF.j";
@import "Presets_HYPERION.j";

// after applying the preset, respond via GUI or send back to caller?
@typedef feedbackTypeType
kFeedbackTypeGUI = 1; kFeedbackTypeHTMLMessage = 2;


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
        const allPresets = ["PRESETS", "Standard Defaults", "Demo", "Testing", "TestingBaLM", "ESU", "Color Equiluminance", "BCM@Scheie", "CNS@Freiburg", "Maculight", "Hyper@TUDo", "AT@LeviLab", "ULV@Gensight", "ETCF", "HYPERION"];

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
                                   defaultButton: "NO   (ߵnߴ)" alternateButton: "YES   (ߵyߴ)" otherButton: nil
                       informativeTextWithFormat: "Many Settings will change. You should know what you are doing here. Luckily, you can always return to defaults."];
    [[alert1 buttons][0] setKeyEquivalent: "y"]; // the "YES" button selected by "y"
    [[alert1 buttons][1] setKeyEquivalent: "n"]; // the "NO" button selected by "n"
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
            [Settings setDefaults];
            [Settings setPresetName: _presetName];// setting here to check it worked
            break;
        case "Demo":
            [Settings setDefaults];
            [self applyTestingPresets];  [Settings setAutoRunIndex: kAutoRunIndexMid];
            [Settings setPresetName: _presetName];
            break;
        case "Testing": // easier testing
            [self applyTestingPresets];
            [Settings setPresetName: _presetName];
            break;
        case "TestingBaLM": // easier testing
            [self applyTestingPresets];
            [Settings setPresetName: _presetName];
            [Settings setNTrials02: 4]; [Settings setNTrials04: 4];
            [Settings setDistanceInCM: 60];
            break;
        case "Color Equiluminance": // near equiluminant color acuity
            [self applyTestingPresets];
            [Settings setAcuityColor: YES];
            [Settings setAcuityForeColor: [CPColor redColor]];
            [Settings setAcuityBackColor: [CPColor colorWithRed: 0 green: 0.70 blue: 0 alpha: 1]];// dark green, near equiluminant to red
            [[CPNotificationCenter defaultCenter] postNotificationName: "copyColorsFromSettings" object: nil];
            [Settings setPresetName: _presetName];
            break;
        case "ESU": case "BCM@Scheie": case "CNS@Freiburg": case "Maculight":
        case "AT@LeviLab": case "Hyper@TUDo": case "ULV@Gensight": case "ETCF": case "HYPERION":
            // calculated class name requires strict discipline with filename systematics
            const newPresetName = [_presetName stringByReplacingOccurrencesOfString:"@" withString:"_"]; //in filenames the @ is not allowed
            const classObj = CPClassFromString("Presets_" + newPresetName);
            [classObj performSelector: @selector(apply)];
            break;
        case "Generic Template": // template for new entries
            [Settings setDefaults];
            // General pane
            // Acuity pane
            // Contrast pane
            // Gratings pane
            // Gamma pane
            // Misc pane
            [Settings setPresetName: _presetName];
            break;
        default:
            console.log("FrACT10>Presets>unknown preset: ", _presetName);
            if (feedbackType == kFeedbackTypeHTMLMessage) {
                [ControlDispatcher post2parentM1: "Settings" m2: "Preset" m3: _presetName success: NO];
            }
            return;
    }
    [[CPNotificationCenter defaultCenter] postNotificationName: "updateSoundFiles" object: nil];
    [[CPNotificationCenter defaultCenter] postNotificationName: "copyColorsFromSettings" object: nil]; // this synchronises the color settings between userdefaults & AppController
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
    [Presets setStandardDefaultsKeepingCalBarLength];
    // general pane
    [Settings setNTrials02: 24];//32
    [Settings setNTrials04: 18];//24
    [Settings setNTrials08: 12];//18
    [Settings setDistanceInCM: 400]; [Settings setCalBarLengthInMM: 150];//avoids dialog
    [Settings setResponseInfoAtStart: NO];
    // acuity pane
    [Settings setShowCI95: YES];
    // Misc pane
    [Settings setSoundTrialYesIndex: 0]; [Settings setSoundTrialNoIndex: 1];
    [Settings setSoundRunEndIndex: 1];
    [Settings setbalmIsiMillisecs: 500];
    [Settings setbalmIsiMillisecs: 500];
}


+ (void) setStandardDefaultsKeepingCalBarLength {
    const calBarLengthInMM_prior = [Settings calBarLengthInMM];
    [Settings setDefaults];
    [Settings setCalBarLengthInMM: calBarLengthInMM_prior];
}


@end
