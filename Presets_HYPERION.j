/*
 This file is part of FrACT10, a vision test battery.
 © 2024 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 Presets_HYPERION.j (a helper for Presets)
 Settings for the cinical study "HYPERION"

 */

@import "Settings.j"

@implementation Presets_HYPERION: CPObject

+ (void) apply { //console.info("Presets_HYPERION>apply")
    [Settings setDefaults];

    //general pane
    [Settings setNTrials08: 24];
    [Settings setShowResponseInfoAtStart: NO]; [Settings setEnableTouchControls: NO];
    [Settings setDecimalMarkCharIndex: kDecimalMarkCharIndexDot];
    [Settings setDistanceInCM: 400];
    [Settings setNAlternativesIndex: kNAlternativesIndex4];
    [Settings setAuditoryFeedback4trialIndex: kauditoryFeedback4trialIndexAlways];
    [Settings setTimeoutIsiMillisecs: 1];
    [Settings setTimeoutResponseSeconds: 60]; [Settings setTimeoutDisplaySeconds: 60];
    [Settings setTestOnFive: kTestAcuityLett];
    [Settings setResultsToClipboardIndex: kResultsToClipFullHistory];

    //acuity pane
    [Settings setMaxDisplayedAcuity: 99];
    [Settings setAcuityStartingLogMAR: 1.0];
    [Settings setShowAcuityFormatLogMAR: YES];
    [Settings setShowCI95: YES];
    [Settings setShowAcuityFormatDecimal: NO];
    [Settings setCrowdingType: 1]; //flanking bars
    [Settings setCrowdingDistanceCalculationType: 3]; //like ETDRS

    [Settings setLineByLineLinesIndex: 2]; //5 lines to aid refraction
}

@end
