/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

FractControllerContrastC.j

Created by Bach on 2020-08-17
*/


@import "FractControllerContrast.j"
@implementation FractControllerContrastC: FractControllerContrast {
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerContrastC>drawStimulusInRect");
    [self calculateForeBackColors];
    [self prepareDrawing];
    switch(state) {
        case kStateDrawBack: break;
        case kStateDrawFore:
            [self drawFixMark];
            break;
        case kStateDrawFore2:
            [optotypes drawLandoltWithStrokeInPx: strokeSizeInPix landoltDirection: [alternativesGenerator currentAlternative]];
            [self drawFixMark3]; //need to draw again
            stimStrengthInDeviceunits = [self getCurrentContrastLogCSWeber];
            trialInfoString = [self contrastComposeTrialInfoString]; //compose here after colors are set
            break;
        default: break;
    }
    
    [self embedInNoise];
    [self drawTouchControls];
    CGContextRestoreGState(cgc);
    [super drawStimulusInRect: dirtyRect];
}


- (void) runStart { //console.info("FractControllerContrastLett>runStart");
    nAlternatives = [Settings nAlternatives];  nTrials = [Settings nTrials];
    [super runStart];
}


- (int) responseNumberFromChar: (CPString) keyChar {
    return [self responseNumber8FromChar: keyChar];
}


@end
