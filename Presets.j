/*
 This file is part of FrACT10, a vision test battery.
 © 2022 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 Presets.j

 */

@import <Foundation/CPObject.j>
@import "Globals.j"
@import "Settings.j"
@import "ControlDispatcher.j"

//after applying the preset, respond via GUI or send back to caller?
@typedef feedbackTypeType
kFeedbackTypeNone = 0; kFeedbackTypeGUI = 1; kFeedbackTypeHTMLMessage = 2;


@implementation Presets: CPObject {
    CPString _presetName;
    CPPopUpButton _popUpButton;
}


- (id) initWithPopup: (CPPopUpButton) thePopUpButton {
    self = [super init];
    if (self) {
        const allPresets = ["PRESETS", "Standard Defaults", "AT@LeviLab", "BaLM₁₀", "BCM@Scheie", "CNS@Freiburg", "Color Equiluminance", "EndoArt01", "ESU", "ETCF", "Hyper@TUDo", "HYPERION", "Maculight", "ULV@Gensight", "Testing"];

        _popUpButton = thePopUpButton;
        [_popUpButton removeAllItems];
        for (const aPreset of allPresets) [_popUpButton addItemWithTitle: aPreset];
        [_popUpButton setSelectedIndex: 0];

        [[CPNotificationCenter defaultCenter] addObserver: self selector: @selector(notificationApplyPresetNamed:) name: "notificationApplyPresetNamed" object: nil];
    }
    return self;
}


//called from the GUI Presets popup
- (void) apply: (id) sender {
    const _presetIndex = [sender indexOfSelectedItem];
    if (_presetIndex === 0) return;

    _presetName = [sender itemTitleAtIndex: _presetIndex];
    const messageText = "Really all Settings to “" + _presetName + "” ?";
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
    _presetName = [aNotification object];
    [self apply2withFeedbackType: kFeedbackTypeHTMLMessage];
}


- (void) apply2withFeedbackType: (feedbackTypeType) feedbackType {
    const knownPresets = ["Standard Defaults", "Demo", "Testing", "DemoBaLM", "BaLM₁₀", "Color Equiluminance", "EndoArt01", "ESU", "BCM@Scheie", "CNS@Freiburg", "Maculight", "AT@LeviLab", "Hyper@TUDo", "ULV@Gensight", "ETCF", "HYPERION"];
                          
    if (!knownPresets.includes(_presetName)) {
        console.log("FrACT10>Presets>unknown preset: ", _presetName);
        if (feedbackType === kFeedbackTypeHTMLMessage) {
            [ControlDispatcher post2parentM1: "Settings" m2: "Preset" m3: _presetName success: NO];
        } else if ([Settings isAutoPreset]) {
            [Settings setIsAutoPreset: NO];
            gLatestAlert = [CPAlert alertWithMessageText: "WARNING" defaultButton: "OK" alternateButton: nil otherButton: nil informativeTextWithFormat: "\rTrying to apply unknown preset: “" + _presetName + "”.\r\rI suggest to reselect the desired preset.\r"];
            [gLatestAlert runModal];
        }
        return;
    }

    [self applyPresetLogic: _presetName]
        .then(() => {
            [_popUpButton setSelectedIndex: 0];

            switch (feedbackType) {
                case kFeedbackTypeGUI:
                    gLatestAlert = [CPAlert alertWithMessageText: "Preset  »" + _presetName + "«  was applied." defaultButton: "OK" alternateButton: nil otherButton: nil informativeTextWithFormat: ""];
                    [gLatestAlert runModal];
                    break;
                case kFeedbackTypeHTMLMessage:
                    [ControlDispatcher post2parentM1: "Settings" m2: "Preset" m3: _presetName success: true];
                    break;
            }
        })
        .catch(error => console.error("Preset application failed:", error));
}


- (CPPromise) applyPresetLogic: (CPString) presetName { //console.info("applyPresetLogic")
    const path = [[CPBundle mainBundle] pathForResource: "Presets.json"];
    
    return fetch(path)
        .then(function(response) { return response.json(); })
        .then(function(presets) {
            const config = presets[presetName];
            if (!config) {
                alert("Config for »"+ presetName + "« does not exist");
                return;
            }

            //Reset defaults
            switch (config.action) {
                case "setDefaults": [Settings setDefaults]; break;
                case "setDefaultsKeepingCalBarLength": [Settings setDefaultsKeepingCalBarLength]; break;
                case "applyTestingPresets": [self applyTestingPresets]; break;
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

                for (let key in config.settings) {
                    let value = config.settings[key];
                    //console.info(value)
                    if (typeof value === "string" && ConstantMap[value] !== undefined) {
                        value = ConstantMap[value];
                    }
                    //console.info(value)

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
            [gAppController.sound updateSoundFiles];
        });
}


- (void) applyTestingPresets {
    [Settings setDefaults];
    [Settings setCalBarLengthInMM: 140];
    [Settings setNTrials02: 24];
    [Settings setNTrials04: 18];
    [Settings setNTrials08: 18];
    [Settings setDistanceInCM: 400]; [Settings setCalBarLengthInMM: 150];
    [Settings setShowResponseInfoAtStart: NO];
    [Settings setShowCI95: YES];
    [Settings setSoundTrialYesIndex: 0]; [Settings setSoundTrialNoIndex: 1];
    [Settings setSoundRunEndIndex: 1];
}


@end
