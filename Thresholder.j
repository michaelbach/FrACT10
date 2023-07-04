/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

Thresholder.j

A wrapper for whatever thresholding algorithm is used (currently only BestPEST)
*/


@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "ThresholderPest.j";


@implementation Thresholder: CPObject {
    Thresholder currentThresholder;
}


- (id)initWithNumAlternatives: (int) numAlternatives { //console.info("Thresholder>init");
    self = [super init];
    if (self) {
        currentThresholder = [[ThresholderPest alloc] initWithNumAlternatives: numAlternatives];
    }
    return self;
}


- (void) unitTest {
    for (let i = 0; i < 10; ++i) {
        const stim = [self nextStim2apply];
        console.info(i + " " + stim);
        [self enterTrialOutcomeWithAppliedStim: stim wasCorrect: NO];
    }
}


- (float) nextStim2apply {
    const retVal = [currentThresholder nextStim2apply];
    //console.info("Thresholder>NextStim2apply: ", retVal);
    return retVal;
}


- (void) enterTrialOutcomeWithAppliedStim: (float) appliedStim wasCorrect: (BOOL) wasCorrect {
    appliedStim = [Misc limit01: appliedStim]; // makes sure that contrast after converting to logCS is in range
    // console.info("Thresholder>enterTrialOutcomeWithAppliedStim", appliedStim, ", wasCorrect: ", wasCorrect);
    [currentThresholder enterTrialOutcomeWithAppliedStim: appliedStim wasCorrect: wasCorrect];
}


- (float) nextStimGivenAppliedStim: (float) appliedStim wasCorrect: (BOOL) wasCorrect {
    return [currentThresholder nextStimGivenAppliedStim: appliedStim wasCorrect: wasCorrect];
}


- (int) externalStim2internalStimGiven: (float) extStim {
    return [currentThresholder externalStim2internalStimGiven: extStim];
}


- (float) internalStim2externalStimGiven: (int) intStim {
    return [currentThresholder internalStim2externalStimGiven: intStim];
}


@end
