/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2024 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 Presets_ETCF: A helper for Presets
 Settings for cinical study "ETCF" in Europe

 */

@import "Settings.j"

@implementation Presets_ETCF: CPObject

+ (void) apply {//console.info("Preset_ETCF>apply")
    [Settings setDefaults];
    // general pane
    [Settings setTestOnFive: kTestContrastC];
    [Settings setResponseInfoAtStart: NO];  [Settings setEnableTouchControls: NO];
    [Settings setResults2clipboard: kResults2ClipFinalOnly];
    [Settings setDistanceInCM: 100];
    // acuity pane
    // contrast pane
    [Settings setContrastOptotypeDiameter: 170];
    // gamma pane
    [Settings setGammaValue: 1.0];

    [Settings setPresetName: "ETCF"];
}

@end
