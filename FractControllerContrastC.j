/*
 *  FractControllerContrastC.j
 *  cappDevelop
 *
 *  Created by Bach on 23.08.2017.
 *  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
 */

@import <Foundation/CPObject.j>
@import "FractController.j"


@implementation FractControllerContrastC: FractControllerContrast {
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerContrastC>drawStimulusInRect");
    trialInfoString = [self acuityComposeTrialInfoString];
    cgc = [[CPGraphicsContext currentContext] graphicsPort];
    CGContextSetFillColor(cgc, colOptotypeBack);
    CGContextFillRect(cgc, [[self window] frame]);
    CGContextSaveGState(cgc);
    switch(state) {
        case kStateDrawBack: break;
        case kStateDrawFore: //console.info("kStateDrawFore");
            CGContextTranslateCTM(cgc,  viewWidth / 2, viewHeight / 2); // origin to center
            var col = [CPColor colorWithWhite:	0.8 alpha: 1];
            var patternContext = CGContextCreatePatternContext(cgc, CGSizeMake(3, 3));
            CGContextSetStrokeColor(patternContext, col);
            CGContextBeginPath(patternContext);
            CGContextMoveToPoint(patternContext, 0, 0); CGContextAddLineToPoint(patternContext, 1, 0);
            //CGContextMoveToPoint(patternContext, 0, 1); CGContextAddLineToPoint(patternContext, 3, 1);
            //CGContextMoveToPoint(patternContext, 0, 2); CGContextAddLineToPoint(patternContext, 3, 2);
            CGContextStrokePath(patternContext);
            CGContextSetFillPattern(cgc, patternContext);
            [optotypes setCgc: cgc colFore: colOptotypeFore colBack: colOptotypeBack];
            [optotypes drawLandoltWithGapInPx: stimStrengthInDeviceunits landoltDirection: [alternativesGenerator currentAlternative]];
            break;
        default: break;
    }

    CGContextRestoreGState(cgc);
    [super drawStimulusInRect: dirtyRect];
}


- (void) runStart { console.info("FractControllerContrastC>runStart");
    [self setCurrentTestName: "Contrast_LandoltC"];
    [self setCurrentTestResultUnit: "logCS"];
    [super runStart];
}


- (void)runEnd { //console.info("FractControllerContrastC>runEnd");
    if (iTrial < nTrials) { //premature end
        [self setResultString: @"Aborted"];
    } else {
        [self setResultString: [self acuityComposeResultString]];
    }
    [super runEnd];
}


// 0–8: valid; -1: ignore; -2: invalid
- (int) responseNumberFromChar: (CPString) keyChar { //console.info("FractControllerContrastC>responseNumberFromChar: ", keyChar);
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
