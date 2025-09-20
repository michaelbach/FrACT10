/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

FractControllerContrastLett.j
 
Created by Bach on 2020-08-17
*/


@import "FractControllerContrast.j"
@implementation FractControllerContrastLett: FractControllerContrast {
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
            [optotypes drawLetterNr: [alternativesGenerator currentAlternative] withStrokeInPx: strokeSizeInPix];
            [self drawFixMark3];
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
    nAlternatives = 10;  nTrials = [Settings nTrials08];
    [super runStart];
}


- (int) responseNumberFromChar: (CPString) keyChar {
    return [self responseNumber10FromChar: keyChar];
}


@end
