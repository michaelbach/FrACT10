/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2024 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 Presets_ULV_Gensight.j (a helper for Presets)

 */

@import "Settings.j"

@implementation Presets_ULV_Gensight: CPObject

+ (void) apply {//console.info("Preset_ULV_Gensight>apply")
    [Settings setDefaults];
    // general pane
    [Settings setResponseInfoAtStart: NO]; [Settings setEnableTouchControls: NO];
    [Settings setDistanceInCM: 100];
    [Settings setNAlternativesIndex: kNAlternativesIndex4];
    [Settings setNTrials04: 32];
    [Settings setNTrials08: 24];
    [Settings setAuditoryFeedback4trial: kAuditoryFeedback4trialAlways];
    [Settings setTimeoutResponseSeconds: 60]; [Settings setTimeoutDisplaySeconds: 60];
    [Settings setTestOnFive: kTestAcuityLett];
    [Settings setResults2clipboard: kResults2ClipFullHistory];
    // acuity pane
    [Settings setMaxDisplayedAcuity: 2.5];
    [Settings setAcuityStartingLogMAR: 1.5];
    [Settings setAcuityFormatLogMAR: YES];
    [Settings setShowCI95: YES];
    [Settings setAcuityFormatDecimal: NO];
    [Settings setCrowdingType: 1]; //flanking bars
    [Settings setCrowdingDistanceCalculationType: 3];//like ETDRS
}

@end
