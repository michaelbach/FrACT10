/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2024 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 Presets_ESU.j (a helper for Presets)
 Settings for "Einschulungsuntersuchung"
 */

@import "Settings.j"

@implementation Presets_ESU: CPObject

+ (void) apply {
    [Presets setStandardDefaultsKeepingCalBarLength];
    //general pane
    [Settings setShowResponseInfoAtStart: NO];  [Settings setEnableTouchControls: NO];
    [Settings setDistanceInCM: 150];
    [[CPUserDefaults standardUserDefaults] setInteger: kNAlternativesIndex4 forKey: "nAlternativesIndex"]; //4 alternatives
    [Settings setNTrials04: 18];
    [Settings setTestOnFive: kTestAcuityC];
    [Settings setTimeoutResponseSeconds: 999]; [Settings setTimeoutDisplaySeconds: 999];
    [Settings setAuditoryFeedback4trialIndex: kauditoryFeedback4trialIndexNone];
    [Settings setShowRewardPicturesWhenDone: YES];
    [Settings setDecimalMarkCharIndex: kDecimalMarkCharIndexComma];
    [Settings setResultsToClipboardIndex: kResultsToClipNone];
    //acuity pane
    [Settings setShowAcuityFormatLogMAR: NO];
    //other
    [Settings setTrialInfoFontSize: 24];
    //displayIncompleteRuns = true; not implemented yet
}

@end
