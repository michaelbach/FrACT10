/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2024 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 Presets_AT_LeviLab.j (a helper for Presets)

 */

@import "Settings.j"

@implementation Presets_AT_LeviLab: CPObject

+ (void) presets_AT_LeviLab {
    [Presets setStandardDefaultsKeepingCalBarLength];
    // General pane
    [[CPUserDefaults standardUserDefaults] setInteger: kNAlternativesIndex4 forKey: "nAlternativesIndex"]; // 4
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
}

@end