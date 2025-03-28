/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2024 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 Presets_Hyper_TUDo.j (a helper for Presets)
 Settings for a hyperacuity project at Universität Dortmung

 */

@import "Settings.j"

@implementation Presets_Hyper_TUDo: CPObject

+ (void) apply {
    [Settings setDefaults];
    // General pane
    [Settings setTimeoutResponseSeconds: 600]; [Settings setTimeoutDisplaySeconds: 90];
    [Settings setDistanceInCM: 147]; [Settings setCalBarLengthInMM: 134];
    [Settings setResponseInfoAtStart: NO];
    [Settings setTestOnFive: kTestNone];
    [Settings setResults2clipboard: kResults2ClipFullHistory];
    [Settings setResults2clipboardSilent: YES];
    // Acuity pane
    [Settings setVernierType: kVernierType3bars];
    [Settings setVernierWidth: 1.5]; [Settings setVernierLength: 40]; [Settings setVernierGap: 0.2];
    [Settings setShowCI95: YES];
    // Gamma pane
    [Settings setGammaValue: 2.2];
    // Misc pane
    [Settings setWindowBackgroundColor: [CPColor whiteColor]];
    [Settings setSoundTrialNoIndex: 1];
}

@end
