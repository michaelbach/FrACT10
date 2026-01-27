/*
 This file is part of FrACT10, a vision test battery.
 © 2025 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 Presets_EndoArt01.j (a helper for Presets)
 Settings for the cinical study "EndoArt" by Eye-Yon

 */

@import "Settings.j"

@implementation Presets_EndoArt01: CPObject

+ (void) apply { //CPLog("Presets_EndoArt01>apply")
    [Settings setDefaults];

    //general tab
    [Settings setNAlternativesIndex: kNAlternativesIndex4];
    [Settings setNTrials04: 30];
    [Settings setShowResponseInfoAtStart: NO];
    [Settings setEnableTouchControls: NO];
    [Settings setDecimalMarkCharIndex: kDecimalMarkCharIndexDot];
    [Settings setDistanceInCM: 50];
    [Settings setTimeoutIsiMillisecs: 0];
    [Settings setTimeoutResponseSeconds: 20];
    [Settings setTimeoutDisplaySeconds: 30];
    [Settings setTestOnFive: kTestAcuityLandolt];
    [Settings setResultsToClipboardIndex: kResultsToClipFullHistory];
    [Settings setAuditoryFeedback4trialIndex: kauditoryFeedback4trialIndexNone];

    //acuity tab
    [Settings setAcuityStartingLogMAR: 2.5];
    [Settings setShowCI95: NO];
    [Settings setShowAcuityFormatLogMAR: YES];
    [Settings setShowAcuityFormatDecimal: NO];

    //contrast tab
    [Settings setContrastOptotypeDiameter: 500];

    //gamma tab
    [Settings setGammaValue: 2.0];
}

@end
