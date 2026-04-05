/*
 This file is part of FrACT10, a vision test battery.
 © 2022 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 Presets.j

 */


/**
 Allow presets of settings
 2024-09-11 begin moving presets to categories← no, singletons
 2024-05-09 major rewrite to avoid repeated information
 2022-05-20 begun
 */

@import "PresetManager.j"

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


- (void) notificationApplyPresetNamed: (CPNotification) aNotification {
    _presetName = [aNotification object];
    [self apply2withFeedbackType: kFeedbackTypeHTMLMessage];
}


- (void) applyPresetNamed: (CPString) presetName {
    _presetName = presetName;
    [self apply2withFeedbackType: kFeedbackTypeNone];
}


- (void) apply2withFeedbackType: (feedbackTypeType) feedbackType {
    // Check if preset is valid/known by attempting to apply it.
    // In a future refactor, we could add a validation method to PresetManager.
    // For now, we replicate the unknown check.
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

    [PresetManager applyPresetNamed: _presetName];
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
}


@end
