/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2024 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 A helper for Presets

 */

@import "Settings.j"

@implementation Presets_CNS_Freiburg: CPObject

+ (void) apply {//console.info("Presets_CNS_Freiburg>apply")
    [Settings setDefaults];
    // general pane
    [Settings setResponseInfoAtStart: NO];  [Settings setEnableTouchControls: NO];
    [Settings setMobileOrientation: NO];
    [Settings setResults2clipboard: kResults2ClipFinalOnly];
    [Settings setDistanceInCM: 200];
    [Settings setTestOnFive: kTestAcuityLett];
}

@end
