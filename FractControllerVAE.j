/*
 *  FractControllerVAE.j
 *  cappDevelop
 *
 *  Created by Bach on 14.08.2017.
 *  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
 */

@import "FractController.j"


@implementation FractControllerVAE: FractController


- (void) modifyGenericStimulus {[self modifyGenericStimulusWithBonus];}
- (void) modifyDeviceStimulus {[self acuityModifyDeviceStimulusDIN01_02_04_08];}
- (float) stimDeviceFromGeneric: (float) tPest {return [self acuityStimDeviceFromGeneric: tPest];}
- (float) stimGenericFromDevice: (float) d {return [self acuityStimGenericFromDevice: d];}


// optotype on a -5…+5 coordinate system
- (void) myPoly: (float) p d: (float) d { //console.log("FractControllerVAE>myPoly");
    CGContextSetFillColor(cgc, colOptotypeFore);
    CGContextBeginPath(cgc);
    CGContextMoveToPoint(cgc, d * p[0][0], -d * p[0][1]);
    for (var i=1; i<p.length; ++i) {
        CGContextAddLineToPoint(cgc, d * p[i][0], -d * p[i][1]);
    }
    CGContextAddLineToPoint(cgc, d * p[0][0], -d * p[0][1]);
    CGContextFillPath(cgc);
}


- (void) tumblingEWithGapInPx: (float) d direction: (int) theDirection { //console.log("FractControllerVAE>tumblingEWithGapInPx");
    //theDirection = directionIfMirrored(theDirection);
    switch (theDirection) {
        case 0: "E"
            var p = [[5, -5], [-5, -5], [-5, 5], [5, 5], [5, 3], [-3, 3], [-3, 1], [5, 1], [5, -1], [-3, -1], [-3, -3], [5, -3]];  break;
        case 2:
            var p = [[-5, 5], [-5, -5], [5, -5], [5, 5], [3, 5], [3, -3], [1, -3], [1, 5], [-1, 5], [-1, -3], [-3, -3], [-3, 5]];  break;
        case 4:
            var p = [[-5, -5], [5, -5], [5, 5], [-5, 5], [-5, 3], [3, 3], [3, 1], [-5, 1], [-5, -1], [3, -1], [3, -3], [-5, -3]];  break;
        case 6:
            var p = [[5, -5], [5, 5], [-5, 5], [-5, -5], [-3, -5], [-3, 3], [-1, 3], [-1, -5], [1, -5], [1, 3], [3, 3], [3, -5]];  break;
        default:	// hollow square (for flanker)
            var p = [[5, -5], [-5, -5], [-5, 5], [5, 5], [5, -5], [3, -3], [-3, -3], [-3, 3], [3, 3], [3, -3]];
    }
    [self myPoly: p d: d * 0.5];
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.log("FractControllerVAC>drawStimulusInRect");
    trialInfoString = [self acuityComposeTrialInfoString];
    cgc = [[CPGraphicsContext currentContext] graphicsPort];
    CGContextSetFillColor(cgc, colOptotypeBack);
    CGContextFillRect(cgc, [[self window] frame]);
    CGContextSaveGState(cgc);
    switch(state) {
        case kStateDrawBack:  break;
        case kStateDrawFore: //console.log("kStateDrawFore");
            CGContextTranslateCTM(cgc,  viewWidth / 2, viewHeight / 2); // origin to center
            [self tumblingEWithGapInPx: stimStrengthInDeviceunits direction: [alternativesGenerator currentAlternative]];
            break;
        default: break;
    }
    CGContextRestoreGState(cgc);
    CGContextSetTextPosition(cgc, 10, 10);
    CGContextSetFillColor(cgc, colOptotypeFore);
    CGContextShowText(cgc, trialInfoString);
    [super drawStimulusInRect: dirtyRect];
}


- (void) runStart { //console.log("FractControllerVAE>runStart");
    [self setCurrentTestName: "Acuity_TumblingE"];
    [self setCurrentTestResultUnit: "LogMAR"];
    nAlternatives = 4;  nTrials = [Settings nTrials04];
    [super runStart];
}


- (void)runEnd { //console.log("FractControllerVAE>runEnd");
    if (iTrial < nTrials) { //premature end
        [self setResultString: @"Aborted"];
    } else {
        [self setResultString: [self acuityComposeResult]];
    }
    [super runEnd];
}


- (int) responseNumberFromChar: (CPString) keyChar { //console.log("FractControllerVAC>responseNumberFromChar: ", keyChar);
    switch (keyChar) {
        case CPLeftArrowFunctionKey: return 4;
        case CPRightArrowFunctionKey: return 0;
        case CPUpArrowFunctionKey: return 2;
        case CPDownArrowFunctionKey: return 6;
        case "6": return 0;
        case "8": return 2;
        case "4": return 4;
        case "2": return 6;
    }
    return -2;// 0, 2, 4, 6: valid; -1: ignore; -2: invalid
}

    
@end
