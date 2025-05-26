/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2024 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 Presets_ULV_Gensight.j (a helper for Presets)
 Settings for the cinical study "ULV" by Gensight

 */

@import "Settings.j"

@implementation Presets_ULV_Gensight: CPObject

+ (void) apply { //console.info("Preset_ULV_Gensight>apply")
    [Settings setDefaults];
    //general pane
    [Settings setShowResponseInfoAtStart: NO]; [Settings setEnableTouchControls: NO];
    [Settings setDistanceInCM: 100];
    [Settings setNAlternativesIndex: kNAlternativesIndex4];
    [Settings setNTrials04: 32];
    [Settings setNTrials08: 24];
    [Settings setAuditoryFeedback4trialIndex: kauditoryFeedback4trialIndexAlways];
    [Settings setTimeoutResponseSeconds: 60]; [Settings setTimeoutDisplaySeconds: 60];
    [Settings setTestOnFive: kTestAcuityLett];
    [Settings setResultsToClipboardIndex: kResultsToClipFullHistory];
    //acuity pane
    [Settings setMaxDisplayedAcuity: 2.5];
    [Settings setAcuityStartingLogMAR: 1.5];
    [Settings setShowAcuityFormatLogMAR: YES];
    [Settings setShowCI95: YES];
    [Settings setShowAcuityFormatDecimal: NO];
    [Settings setCrowdingType: 1]; //flanking bars
    [Settings setCrowdingDistanceCalculationType: 3]; //like ETDRS
}

@end
