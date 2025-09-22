/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

ThresholderPest.j
 
Implementation of BestPEST
*/


@import "Thresholder.j";


@implementation ThresholderPest : CPObject {
    int kRange, kRange1, kRange2;
    id probability, plgit, mlgit;
    float appliedStimStored;
    BOOL wasCorrectStored;
}


- (id)initWithNumAlternatives: (int) numAlternatives { //console.info("ThresholderPest>init");
    self = [super init];
    if (self) { //Code below is really really old, but at least long proven
        kRange = 5000;  kRange1 = kRange - 1;  kRange2 = kRange * 2
        probability = new Array(kRange);  plgit = new Array(kRange * 2);  mlgit = new Array(kRange * 2);
        for (let i = 0; i < kRange; i++) {
            probability[i] = 0.0;
        }
        const slope = kRange / 10.0; //this is a major choice, should be parametrized
        const guessProb = 1.0 / numAlternatives;
        for (let i = 0; i < kRange2; i++) {
            const logistic = guessProb + (1.0 - guessProb) / (1.0 + Math.exp((kRange - i) / slope));
            plgit[i] = Math.log10(logistic);
            mlgit[i] = Math.log10(1.0 - logistic);
        }
        [self enterTrialOutcomeWithAppliedStim: 0.0 wasCorrect: NO];
        [self nextStim2apply];
        [self enterTrialOutcomeWithAppliedStim: 1.0 wasCorrect: YES];
    }
    return self;
}


- (void) unitTest {
    console.log("\nThresholderPest>unittest")
    for (let i = 0; i < 10; ++i) {
        const stim = [self nextStim2apply];
        console.info(i + " " + stim);
        [self enterTrialOutcomeWithAppliedStim: stim wasCorrect: NO];
    }
}


- (float) nextStim2apply { //console.info("Pest>nextStim2apply");
    return [self nextStimGivenAppliedStim: appliedStimStored wasCorrect: wasCorrectStored];
}


- (void) enterTrialOutcomeWithAppliedStim: (float) appliedStim wasCorrect: (BOOL) wasCorrect {
    //console.info("Pest>enterTrialOutcomeWithAppliedStim ", wasCorrect);
    appliedStimStored = appliedStim,
    wasCorrectStored = wasCorrect;
}


//this is very old code … don't change a winning team :)
- (float) nextStimGivenAppliedStim: (float) appliedStim wasCorrect: (BOOL) wasCorrect {
    const intStim = [self externalStim2internalStimGiven: appliedStim];
    let p1 = -10000, p2 = -10000, maxP = -10000;
    for (let i = 0; i < kRange; i++) {
        let p = probability[i], ii = kRange + intStim - i;
        if (ii < 0) ii = 0;
        if (ii >= kRange2)  ii=kRange2 - 1;
        p = p + (wasCorrect ? plgit[ii] : mlgit[ii]);
        if (p > maxP) {
            maxP = p;  p1 = i;
        }
        if (p === maxP) {
            p2 = i;
        }
        probability[i] = p;
    }
    const internalStim = Math.round((p1 + p2) / 2);
    const retVal = [self internalStim2externalStimGiven: internalStim];
    return retVal;
}


- (int) externalStim2internalStimGiven: (float) extStim {
    const iTemp = Math.round(extStim * kRange1);
    return Math.min(Math.max(iTemp, 0), kRange - 1);
}


- (float) internalStim2externalStimGiven: (int) intStim {
    return (1.0 * intStim) / (1.0 * kRange1);
}


@end
