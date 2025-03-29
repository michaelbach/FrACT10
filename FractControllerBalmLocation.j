/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 2020-11-09 created class "FractControllerBalmLocation" inheriting from "FractController"
 */


@import "FractControllerBalm.j"


@implementation FractControllerBalmLocation: FractControllerBalm {
    float radiusInPix;
}


- (void) runStart { //console.info("FractControllerBalmLocation>runStart");
    nAlternatives = 4;  nTrials = [Settings nTrials04];
    radiusInPix = 0.5 * [MiscSpace pixelFromDegree: [Settings balmLocationDiameterInDeg]];
    if (radiusInPix > 0.3 * Math.min(viewWidth, viewHeight)) {
        [self alertProblemOfDiameter: [Settings balmLocationDiameterInDeg]];
    }
    [super runStart];
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerBalmLocation>drawStimulusInRect");
    trialInfoString = [self composeTrialInfoString];
    [self prepareDrawing];
    switch(state) {
        case kStateDrawBack:
            [optotypes fillCircleAtX: 0 y: 0 radius: radiusInPix];
            break;
        case kStateDrawFore://console.info("kStateDrawFore");
            [sound playNumber: kSoundTrialStart];
            CGContextSetFillColor(cgc, gColorFore);
            [optotypes fillCircleAtX: 0 y: 0 radius: radiusInPix];
            const a = -Math.PI / 4 * [alternativesGenerator currentAlternative] + [MiscSpace degrees2radians: -33.33];
            CGContextRotateCTM(cgc, a);
            const r = [MiscSpace pixelFromDegree: [Settings balmLocationEccentricityInDeg]];
            CGContextBeginPath(cgc);
            CGContextMoveToPoint(cgc, 0, 0);
            CGContextAddLineToPoint(cgc, r, 0);
            CGContextAddArc(cgc, 0, 0, r, 0, [MiscSpace degrees2radians: 66.66], 1);
            CGContextFillPath(cgc);
            discardKeyEntries = NO; // now allow responding
            break;
        default: break;
    }
    CGContextRestoreGState(cgc);
    CGContextSetFillColor(cgc, gColorBack);
    [super drawStimulusInRect: dirtyRect forView: fractView];
}


@end
