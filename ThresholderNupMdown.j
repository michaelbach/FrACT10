/*
This file is part of FrACT10, a vision test battery.
Copyright © 2024 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

ThresholderNupMdown.j

Implementation of a n-up-m-down staircase

2024-05-26 begun
*/


@import "Thresholder.j";


@implementation ThresholderNupMdown : CPObject {
    float appliedStimStored;
    BOOL wasCorrectStored;
}


- (id)initWithNumAlternatives: (int) numAlternatives { //console.info("ThresholderNupMdown>init");
    self = [super init];
    if (self) {
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


- (float) nextStim2apply { //console.info("ThresholderNupMdown>nextStim2apply");
    return [self nextStimGivenAppliedStim: appliedStimStored wasCorrect: wasCorrectStored];
}


- (void) enterTrialOutcomeWithAppliedStim: (float) appliedStim wasCorrect: (BOOL) wasCorrect {
    //console.info("ThresholderNupMdown>enterTrialOutcomeWithAppliedStim ", wasCorrect);
    appliedStimStored = appliedStim;
    wasCorrectStored = wasCorrect;
}


- (float) nextStimGivenAppliedStim: (float) appliedStim wasCorrect: (BOOL) wasCorrect {
    const intStim = [self externalStim2internalStimGiven: appliedStim];

    const retVal = [self internalStim2externalStimGiven: intStim];
    return retVal;
}


- (int) externalStim2internalStimGiven: (float) extStim {
    return extStim;
}


- (float) internalStim2externalStimGiven: (int) intStim {
    return intStim;
}


@end
