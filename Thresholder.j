@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Pest.j";


@implementation Thresholder: CPObject {
    Thresholder currentThresholder;
}


- (id)initWithNumAlternatives: (int) numAlternatives { //console.info("Thresholder>init");
    self = [super init];
    if (self) {
        currentThresholder = [[Pest alloc] initWithNumAlternatives: numAçlternatives];
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


- (float) nextStim2apply { //console.info("Thresholder>NextStim2apply");
    return [currentThresholder nextStim2apply];
}


- (void) enterTrialOutcomeWithAppliedStim: (float) appliedStim wasCorrect: (BOOL) wasCorrect {
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
