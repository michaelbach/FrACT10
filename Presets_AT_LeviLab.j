/*
 This file is part of FrACT10, a vision test battery.
 © 2024 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 Presets_AT_LeviLab.j (a helper for Presets)
 Settings for a project by Ângela at LeviLab

 */

@import "Settings.j"

@implementation Presets_AT_LeviLab: CPObject

+ (void) apply {
    [Settings setDefaults];
//    [Presets setStandardDefaultsKeepingCalBarLength];
    //General pane
    [[CPUserDefaults standardUserDefaults] setInteger: kNAlternativesIndex4 forKey: "nAlternativesIndex"]; //4
    [Settings setNTrials04: 24];
    [Settings setShowResponseInfoAtStart: NO];  [Settings setEnableTouchControls: NO];
    [Settings setDecimalMarkCharIndex: kDecimalMarkCharIndexComma];
    [Settings setTimeoutDisplaySeconds: 0.15];
    //[Settings setEccentXInDeg: 8];
    [Settings setEccentYInDeg: 5];
    [Settings setDistanceInCM: 68.5];
    [Settings setCalBarLengthInMM: 191];
    [Settings setResultsToClipboardIndex: kResultsToClipFullHistory];
    [Settings setDisplayTransform: 1]; //1=mirror horizontally
    [Settings setTestOnFive: kTestAcuityLandolt];
    //Acuity pane
    [Settings setMaxDisplayedAcuity: 99];
    //Misc pane
    //[Settings setEccentRandomizeX: YES];
    [Settings setEccentRandomizeY: YES];
}

@end
