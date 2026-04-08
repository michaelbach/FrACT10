/*
 This file is part of FrACT10, a vision test battery.
 © 2022 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 Presets.j

 */

@import <Foundation/CPObject.j>
@import "Globals.j"
@import "Settings.j"
@import "ControlDispatcher.j"
@import "SoundManager.j"

//after applying the preset, respond via GUI or send back to caller?
@typedef feedbackTypeType
kFeedbackTypeNone = 0; kFeedbackTypeGUI = 1; kFeedbackTypeHTMLMessage = 2;


@implementation Presets: CPObject {
    id allPresets;
    CPString presetName, allPresetNames;
    CPPopUpButton popUpButton;
}


- (id) initWithPopup: (CPPopUpButton) thePopUpButton {
    self = [super init];
    if (self) {
        popUpButton = thePopUpButton;
        [popUpButton removeAllItems];
        [popUpButton addItemWithTitle: "PRESETS"];
        [popUpButton setSelectedIndex: 0];

        const path = [[CPBundle mainBundle] pathForResource: "Presets.json"];
        fetch(path)
            .then(response => response.json())
            .then(presets => {
                allPresets = presets;
                allPresetNames = Object.keys(allPresets);
                allPresetNames.sort();
                for (const name of allPresetNames) {
                    [popUpButton addItemWithTitle: name];
                }
            })
            .catch(error => console.error("Failed to load presets for popup:", error));

        [[CPNotificationCenter defaultCenter] addObserver: self selector: @selector(notificationApplyPresetNamed:) name: "notificationApplyPresetNamed" object: nil];
    }
    return self;
}


- (void) applyPresetNamed: (CPString) aPresetName {
    presetName = aPresetName;
    [self apply2withFeedbackType: kFeedbackTypeNone];
}



//called from the GUI Presets popup
- (void) apply: (id) sender {
    const presetIndex = [sender indexOfSelectedItem];
    if (presetIndex === 0) return;

    presetName = [sender itemTitleAtIndex: presetIndex];
    const messageText = "Really all Settings to “" + presetName + "” ?";
    gLatestAlert = [CPAlert alertWithMessageText: messageText
                                   defaultButton: "NO   (ߵnߴ)" alternateButton: "YES   (ߵyߴ)" otherButton: nil
                       informativeTextWithFormat: "Many Settings will change. You should know what you are doing here. Luckily, you can always return to defaults."];
    [[gLatestAlert buttons][0] setKeyEquivalent: "y"];
    [[gLatestAlert buttons][1] setKeyEquivalent: "n"];
    [gLatestAlert runModalWithDidEndBlock: function(alert, returnCode) {
        if (returnCode === 1) {
            [self apply2withFeedbackType: kFeedbackTypeGUI];
        }
        gLatestAlert = null;
    }];
}


//called from `ControlDispatcher`
- (void) notificationApplyPresetNamed: (CPNotification) aNotification {
    presetName = [aNotification object];
    [self apply2withFeedbackType: kFeedbackTypeHTMLMessage];
}


- (void) apply2withFeedbackType: (feedbackTypeType) feedbackType {
    if (!allPresetNames.includes(presetName)) {
        console.log("FrACT10▸Presets▸unknown preset: ", presetName);
        if (feedbackType === kFeedbackTypeHTMLMessage) {
            [ControlDispatcher post2parentM1: "Settings" m2: "Preset" m3: presetName success: NO];
        } else if ([Settings isAutoPreset]) {
            [Settings setIsAutoPreset: NO];
            gLatestAlert = [CPAlert alertWithMessageText: "WARNING" defaultButton: "OK" alternateButton: nil otherButton: nil informativeTextWithFormat: "\rTrying to apply unknown preset: “" + presetName + "”.\r\rI suggest to reselect the desired preset.\r"];
            [gLatestAlert runModal];
        }
        return;
    }

    [self applyPresetLogic];
    [popUpButton setSelectedIndex: 0];

    switch (feedbackType) {
        case kFeedbackTypeGUI:
            gLatestAlert = [CPAlert alertWithMessageText: "Preset  »" + presetName + "«  was applied." defaultButton: "OK" alternateButton: nil otherButton: nil informativeTextWithFormat: ""];
            [gLatestAlert runModal];
            break;
        case kFeedbackTypeHTMLMessage:
            [ControlDispatcher post2parentM1: "Settings" m2: "Preset" m3: presetName success: true];
            break;
    }
}


- (void) applyPresetLogic { //console.info("applyPresetLogic")
    const config = allPresets[presetName];
    if (!config) { //this was already tested, can't hurt
        alert("Config for »"+ presetName + "« does not exist");
        return;
    }

    switch (config.action) { //Reset defaults
        case "setDefaults": [Settings setDefaults]; break;
        case "setDefaultsKeepingCalBarLength": [Settings setDefaultsKeepingCalBarLength]; break;
        case "applyTestingPresets": [self applyTestingPresets]; break;
        default: console.warn("`switch (config.action)` finds unknown action: ", config.action);
    }

    if (config.settings) { //Apply settings
        const ConstantMap = { //mapping so we can use symbolic constants in the json file
            "kResultsToClipNone": kResultsToClipNone,
            "kResultsToClipFullHistory": kResultsToClipFullHistory,
            "kResultsToClipFinalOnly": kResultsToClipFinalOnly,
            "kNAlternativesIndex2": kNAlternativesIndex2,
            "kNAlternativesIndex4": kNAlternativesIndex4,
            "kNAlternativesIndex8plus": kNAlternativesIndex8plus,
            "kauditoryFeedback4trialIndexNone": kauditoryFeedback4trialIndexNone,
            "kauditoryFeedback4trialIndexAlways": kauditoryFeedback4trialIndexAlways,
            "kauditoryFeedback4trialIndexOncorrect": kauditoryFeedback4trialIndexOncorrect,
            "kauditoryFeedback4trialIndexWithinfo": kauditoryFeedback4trialIndexWithinfo,
            "kTestNone": kTestNone,
            "kTestAcuityLetters": kTestAcuityLetters,
            "kTestAcuityLandolt": kTestAcuityLandolt,
            "kTestAcuityE": kTestAcuityE,
            "kTestAcuityTAO": kTestAcuityTAO,
            "kTestAcuityVernier": kTestAcuityVernier,
            "kTestContrastLetters": kTestContrastLetters,
            "kTestContrastLandolt": kTestContrastLandolt,
            "kTestContrastE": kTestContrastE,
            "kTestContrastG": kTestContrastG,
            "kDecimalMarkCharIndexAuto": kDecimalMarkCharIndexAuto,
            "kDecimalMarkCharIndexDot": kDecimalMarkCharIndexDot,
            "kDecimalMarkCharIndexComma": kDecimalMarkCharIndexComma,
        };

        for (const key in config.settings) {
            let value = config.settings[key];
            if (typeof value === "string" && ConstantMap[value] !== undefined) {
                value = ConstantMap[value];
            }
            const setterName = "set" + key.charAt(0).toUpperCase() + key.substring(1) + ":";
            const selector = sel_getUid(setterName);
            if ([Settings respondsToSelector: selector]) {
                //console.info("Setter ", setterName, "to be applied.")
                [Settings performSelector: selector withObject: value];
            } else {
                console.warn("Setter ", setterName, "not defined.")
            }
        }
    }

    [Settings setPresetName: presetName];
    [Settings calculateMinMaxPossibleAcuity];
    [[SoundManager sharedManager] updateSoundFiles];
}


- (void) applyTestingPresets {
    [Settings setDefaults];
    [Settings setNTrials02: 24];
    [Settings setNTrials04: 18];
    [Settings setNTrials08: 18];
    [Settings setDistanceInCM: 400];
    [Settings setCalBarLengthInMM: 140];
    [Settings setShowResponseInfoAtStart: NO];
    [Settings setShowCI95: YES];
    [Settings setSoundTrialYesIndex: 0]; [Settings setSoundTrialNoIndex: 1];
    [Settings setSoundRunEndIndex: 1];
}


/**
 Perform logic unit tests for Presets (loading and existence of standard preset).
 @return YES if all tests pass
 */
- (BOOL) unittest {
    let success = YES, report = crlf + "Presets▸unittest:" + crlf;

    if (!allPresets || Object.keys(allPresets).length === 0) {
        report += "  ERROR: allPresets not loaded!" + crlf; success = NO;
    }
    if (!allPresetNames || !allPresetNames.includes("Standard Defaults")) {
        report += "  ERROR: 'Standard Defaults' missing from allPresetNames!" + crlf; success = NO;
    }

    if (success) {
        report += "  Preset loading and validation tests passed." + crlf;
    }
    console.info(report);
    return success;
}


@end
