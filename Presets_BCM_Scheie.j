/*
 This file is part of FrACT10, a vision test battery.
 © 2024 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 Presets_BCM_Scheie.j (a helper for Presets)
 Settings for project "BCM" at Scheie

 */

@import "Settings.j"

@implementation Presets_BCM_Scheie: CPObject

+ (void) apply {
    [Settings setDefaults];
    //general pane
    [Settings setNAlternativesIndex: kNAlternativesIndex2];  [Settings setNTrials02: 10];
    [Settings setTimeoutResponseSeconds: 120]; [Settings setTimeoutDisplaySeconds: 120];
    [Settings setShowResponseInfoAtStart: NO];  [Settings setEnableTouchControls: NO];
    [Settings setRespondsToMobileOrientation: NO];
    [Settings setResultsToClipboardIndex: kResultsToClipFullHistory];
    [Settings setAuditoryFeedback4trialIndex: kauditoryFeedback4trialIndexNone];
    [Settings setCalBarLengthInMM: 189];  [Settings setDistanceInCM: 100];
    //acuity pane
    [Settings setContrastAcuityWeber: -1E6];
    [Settings setLineByLineDistanceType: 1];  [Settings setLineByLineHeadcountIndex: 0];
    [Settings setAcuityHasEasyTrials: NO];
    //gratings pane
    [Settings setContrastHasEasyTrials: NO];
    [Settings setIsGratingObliqueOnly: YES];
    [Settings setIsGratingColor: YES];
    [Settings setGratingForeColor: [CPColor colorWithRed: 255 green: 0 blue: 255 alpha: 1]];
    [Settings setGratingBackColor: [CPColor colorWithRed: 0 green: 0 blue: 255 alpha: 1]];
    [Settings setWhat2sweepIndex: 1];
    [Settings setGratingContrastMichelsonPercent: 99];
    [Settings setGratingCPDmin: 1];
    [Settings setGratingCPDmax: 7];
}

@end
