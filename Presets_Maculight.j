/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2024 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 Presets_Maculight: A helper for Presets
 Settings for the cinical study "Maculight" in Europe

 */

@import "Settings.j"

@implementation Presets_Maculight: CPObject

+ (void) apply { //console.info("Presets_Maculight>apply")
    [Presets setStandardDefaultsKeepingCalBarLength];
    //general pane
    [Settings setResponseInfoAtStart: NO];  [Settings setEnableTouchControls: NO];
    [Settings setResults2clipboard: kResults2ClipFinalOnly];
    [Settings setDistanceInCM: 400];
    [Settings setTestOnFive: kTestAcuityLett];
    //contrast pane
    [Settings setContrastOptotypeDiameter: 170];
}

@end
