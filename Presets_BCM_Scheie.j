/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2024 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 Presets_BCM_Scheie.j (a helper for Presets)

 */

@import "Settings.j"

@implementation Presets_BCM_Scheie: CPObject

+ (void) presets_BCM_Scheie {
    [Settings setDefaults];
    // general pane
    [Settings setNAlternativesIndex: kNAlternativesIndex2];  [Settings setNTrials02: 10];
    [Settings setTimeoutResponseSeconds: 120]; [Settings setTimeoutDisplaySeconds: 120];
    [Settings setResponseInfoAtStart: NO];  [Settings setEnableTouchControls: NO];
    [Settings setMobileOrientation: NO];
    [Settings setResults2clipboard: kResults2ClipFullHistory];
    [Settings setAuditoryFeedback4trial: kAuditoryFeedback4trialNone];
    [Settings setCalBarLengthInMM: 189];  [Settings setDistanceInCM: 100];
    // acuity pane
    [Settings setContrastAcuityWeber: -1E6];
    [Settings setTestOnLineByLineDistanceType: 1];  [Settings setLineByLineHeadcountIndex: 0];
    [Settings setAcuityEasyTrials: NO];
    // gratings pane
    [Settings setContrastEasyTrials: NO];
    [Settings setGratingObliqueOnly: YES];
    [Settings setIsGratingColor: YES];
    [Settings setGratingForeColor: [CPColor colorWithRed: 255 green: 0 blue: 255 alpha: 1]];
    [Settings setGratingBackColor: [CPColor colorWithRed: 0 green: 0 blue: 255 alpha: 1]];
    [Settings setWhat2sweepIndex: 1];
    [Settings setGratingContrastMichelsonPercent: 99];
    [Settings setGratingCPDmin: 1];
    [Settings setGratingCPDmax: 7];
}

@end
