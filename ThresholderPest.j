
@import "Thresholder.j";


@implementation ThresholderPest : CPObject {
    int kRange, kRange1, kRange2;
    id probability, plgit, mlgit;
    float appliedStimStored;
    BOOL wasCorrectStored;
}


- (id)initWithNumAlternatives: (int) numAlternatives { //console.info("ThresholderPest>init");
    self = [super init];
    if (self) {
        kRange = 5000;  kRange1 = kRange - 1;  kRange2 = kRange * 2
        probability = new Array(kRange);  plgit = new Array(kRange * 2);  mlgit = new Array(kRange * 2);

        for (var i = 0; i < kRange; i++) {
            probability[i] = 0.0;
        }
        var slope = kRange / 10.0;
        var guessProb = 1.0 / numAlternatives;
        var logistic;
        for (var i = 0; i < kRange2; i++) {
            logistic = guessProb + (1.0 - guessProb) / (1.0 + Math.exp((kRange - i) / slope));
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
    for (var i = 0; i < 10; ++i) {
        var stim = [self nextStim2apply];
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


- (float) nextStimGivenAppliedStim: (float) appliedStim wasCorrect: (BOOL) wasCorrect {
    var intStim = [self externalStim2internalStimGiven: appliedStim];
    var p1 = -10000, p2 = -10000, maxP = -10000;
    for (var i = 0; i < kRange; i++) {
        var p = probability[i], ii = kRange + intStim - i;
        if (ii < 0) ii = 0;
        if (ii >= kRange2)  ii=kRange2 - 1;
        p = p + (wasCorrect ? plgit[ii] : mlgit[ii]);
        if (p > maxP) {
            maxP = p;  p1 = i;
        }
        if (p == maxP) {
            p2 = i;
        }
        probability[i] = p;
    }
    var internalStim = Math.round((p1 + p2) / 2.0);
    var retVal = [self internalStim2externalStimGiven: internalStim];
    return retVal;
}


- (int) externalStim2internalStimGiven: (float) extStim {
    var iTemp = Math.round(extStim * kRange1);
    return Math.min(Math.max(iTemp, 0), kRange - 1);
}


- (float) internalStim2externalStimGiven: (int) intStim {
    return (1.0 * intStim) / (1.0 * kRange1);
}


@end