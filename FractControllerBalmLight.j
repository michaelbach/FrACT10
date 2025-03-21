/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>
 
 2025-02-26 created class "FractControllerBalmLight" inheriting from "FractController"
 */


@import "FractControllerBalm.j"


@implementation FractControllerBalmLight: FractControllerBalm {
}


- (void) runStart { //console.info("FractControllerBalmLight>runStart");
    nAlternatives = 2;  nTrials = [Settings nTrials02];
    [super runStart];
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerBalmLight>drawStimulusInRect");
    trialInfoString = [self composeTrialInfoString];
    [self prepareDrawing];
    switch(state) {
        case kStateDrawBack: break;
        case kStateDrawFore://console.info("kStateDrawFore");
            [sound playNumber: kSoundTrialYes];
            if ([alternativesGenerator currentAlternative] != 0) {
                CGContextSetFillColor(cgc, gColorFore);
                CGContextFillRect(cgc, CGRectMake(-viewWidth2, -viewHeight2, viewWidth, viewHeight));
            }
            discardKeyEntries = NO; // now allow responding
            break;
        default: break;
    }
    CGContextRestoreGState(cgc);
    CGContextSetFillColor(cgc, gColorBack);
    [super drawStimulusInRect: dirtyRect forView: fractView];
}


@end
