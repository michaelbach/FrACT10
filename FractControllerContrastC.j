/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, michael.bach@uni-freiburg.de, <https://michaelbach.de>

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
            [optotypes drawLandoltWithGapInPx: optotypeSizeInPix landoltDirection: [alternativesGenerator currentAlternative]];
            [self drawFixMark3];// need to draw again
            stimStrengthInDeviceunits = [optotypes getCurrentContrastLogCSWeber];
            trialInfoString = [self contrastComposeTrialInfoString];// compose here after colors are set
            break;
        default: break;
    }
    
    if ([Settings enableTouchControls] && (!responseButtonsAdded)) {
        var sze = 50, sze2 = sze / 2, radius = 0.5 * Math.min(viewWidth, viewHeight) - sze2 - 1;
        for (var i = 0; i < 8; i++) {
            if ( ([Settings nAlternatives] > 4)  || (![Misc isOdd: i])) {
                var ang = i / 8 * 2 * Math.PI;
                [self buttonCenteredAtX: viewWidth / 2 + Math.cos(ang) * radius y:  Math.sin(ang) * radius size: sze title: [@"632147899" characterAtIndex: i]];
            }
        }
        [self buttonCenteredAtX: viewWidth - sze2 - 1 y: viewHeight / 2 - sze2 - 1 size: sze title: "Ø"];
    }
    
    CGContextRestoreGState(cgc);
    [super drawStimulusInRect: dirtyRect];
}


- (void) runStart { //console.info("FractControllerContrastLett>runStart");
    nAlternatives = [Settings nAlternatives];  nTrials = [Settings nTrials];
    [super runStart];
}


// 0–8: valid; -1: ignore; -2: invalid
- (int) responseNumberFromChar: (CPString) keyChar { //console.info("FractControllerAcuityC>responseNumberFromChar: ", keyChar);
    switch (keyChar) {
        case CPLeftArrowFunctionKey: return 4;
        case CPRightArrowFunctionKey: return 0;
        case CPUpArrowFunctionKey: return 2;
        case CPDownArrowFunctionKey: return 6;
        case "6": return 0;
        case "9": return 1;
        case "8": return 2;
        case "7": return 3;
        case "4": return 4;
        case "1": return 5;
        case "2": return 6;
        case "3": return 7;
        case "5": return -1;
    }
    return -2;
}


@end
