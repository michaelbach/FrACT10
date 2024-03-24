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
            [optotypes drawLetterWithGapInPx: optotypeSizeInPix letterNumber: [alternativesGenerator currentAlternative]];
            [self drawFixMark3];
            stimStrengthInDeviceunits = [self getCurrentContrastLogCSWeber];
            trialInfoString = [self contrastComposeTrialInfoString]; // compose here after colors are set
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


- (int) responseNumberFromChar: (CPString) keyChar { //console.info("FractControllerAcuityLetters>responseNumberFromChar: ", keyChar);
    switch ([keyChar uppercaseString]) { // "CDHKNORSVZ"
        case "C": return 0;
        case "D": return 1;
        case "H": return 2;
        case "K": return 3;
        case "N": return 4;
        case "O": return 5;
        case "R": return 6;
        case "S": return 7;
        case "V": return 8;
        case "Z": return 9;
        case "5": return -1;
    }
    return -2;// -1: ignore; -2: invalid
}


@end
