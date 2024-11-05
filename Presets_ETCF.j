/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2024 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 A helper for Presets

 */

@import "Settings.j"

@implementation Presets_ETCF: CPObject

+ (void) apply {//console.info("Preset_ETCF>preset_ETCF")
    [Settings setDefaults];
    // general pane
    [Settings setTestOnFive: kTestContrastC];
    // acuity pane
    // contrast pane
}

@end
