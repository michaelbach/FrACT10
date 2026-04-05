/*
This file is part of FrACT10, a vision test battery.
© 2026 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>
code started by Gemini

PresetManager.j

Encapsulates preset logic. Applies configurations based on preset names.
*/

@import <Foundation/CPObject.j>
@import "Globals.j"
@import "Settings.j"
@import "ControlDispatcher.j"
@import "Presets_AT_LeviLab.j"
@import "Presets_BCM_Scheie.j"
@import "Presets_CNS_Freiburg.j"
@import "Presets_EndoArt01.j"
@import "Presets_ESU.j"
@import "Presets_Hyper_TUDo.j"
@import "Presets_Maculight.j"
@import "Presets_ULV_Gensight.j"
@import "Presets_ETCF.j"
@import "Presets_HYPERION.j"

@implementation PresetManager: CPObject {
}

/**
 Apply selected preset.
 */
+ (void) applyPresetNamed: (CPString) presetName {
    switch (presetName) {
        case "Standard Defaults":
            [Settings setDefaults];
            break;
        case "Demo":
            [Settings setDefaults];
            [self applyTestingPresets];  [Settings setAutoRunIndex: kAutoRunIndexMid];
            break;
        case "Testing": //easier testing
            [self applyTestingPresets];
            break;
        case "DemoBaLM": //easier testing
            [self applyTestingPresets];  [Settings setNTrials02: 4];  [Settings setNTrials04: 4];
            [Settings setDistanceInCM: 29];  [Settings setBalmIsiMillisecs: 500];
            break;
        case "BaLM₁₀":
            [Settings setDefaults];
            [Settings setTimeoutResponseSeconds: 2];
            [Settings setNTrials02: 24];  [Settings setNTrials04: 20];
            [Settings setShowResponseInfoAtStart: NO];
            [Settings setDistanceInCM: 57];  [Settings setBalmIsiMillisecs: 500];
            break;
        case "Color Equiluminance": //near equiluminant color acuity
            [self applyTestingPresets];
            [Settings setIsAcuityColor: YES];
            [Settings setAcuityForeColor: [CPColor redColor]];
            [Settings setAcuityBackColor: [CPColor colorWithRed: 0 green: 0.70 blue: 0 alpha: 1]]; //dark green, near equiluminant to red
            break;
        case "EndoArt01": case "ESU": case "BCM@Scheie": case "CNS@Freiburg": case "Maculight":
        case "AT@LeviLab": case "Hyper@TUDo": case "ULV@Gensight": case "ETCF": case "HYPERION":
            const newPresetName = [presetName stringByReplacingOccurrencesOfString:"@" withString:"_"];
            const classObj = CPClassFromString("Presets_" + newPresetName);
            [classObj performSelector: @selector(apply)];
            break;
    }
    [Settings setPresetName: presetName];
    [Settings calculateMinMaxPossibleAcuity];
    [gAppController.sound updateSoundFiles];
}

+ (void) applyTestingPresets {
    [self setDefaultsKeepingCalBarLength];
    [Settings setNTrials02: 24];
    [Settings setNTrials04: 18];
    [Settings setNTrials08: 18];
    [Settings setDistanceInCM: 400]; [Settings setCalBarLengthInMM: 150];
    [Settings setShowResponseInfoAtStart: NO];
    [Settings setShowCI95: YES];
    [Settings setSoundTrialYesIndex: 0]; [Settings setSoundTrialNoIndex: 1];
    [Settings setSoundRunEndIndex: 1];
}

+ (void) setDefaultsKeepingCalBarLength {
    const calBarLengthInMM_prior = [Settings calBarLengthInMM];
    [Settings setDefaults];
    [Settings setCalBarLengthInMM: calBarLengthInMM_prior];
}

@end
