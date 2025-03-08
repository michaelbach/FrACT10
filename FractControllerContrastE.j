/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

FractControllerContrastE.j

Created by Bach on 2020-09-02
*/


@import "FractControllerContrast.j"
@implementation FractControllerContrastE: FractControllerContrast {
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerContrastLett>drawStimulusInRect");
    [self calculateForeBackColors];
    [self prepareDrawing];
    switch(state) {
        case kStateDrawBack: break;
        case kStateDrawFore:
            [self drawFixMark];
            break;
        case kStateDrawFore2:
            [optotypes tumblingEWithStrokeInPx: strokeSizeInPix direction: [alternativesGenerator currentAlternative]];
            [self drawFixMark3];
            stimStrengthInDeviceunits = [self getCurrentContrastLogCSWeber];
            trialInfoString = [self contrastComposeTrialInfoString];// compose here after colors are set
            break;
        default: break;
    }
    
    [self embedInNoise];
    [self drawTouchControls];
    CGContextRestoreGState(cgc);
    [super drawStimulusInRect: dirtyRect];
}


- (void) runStart { //console.info("FractControllerContrastLett>runStart");
    nAlternatives = 4;  nTrials = [Settings nTrials04];
    [super runStart];
}


- (int) responseNumberFromChar: (CPString) keyChar {
    return [self responseNumber4FromChar: keyChar];
}


@end
