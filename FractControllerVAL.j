    /*
 *  FractControllerVALetters.j
 *  cappDevelop
 *
 *  Created by Bach on 08.08.2017.
 *  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
 */

@import <Foundation/CPObject.j>

@implementation FractControllerVAL: FractController {
    float kPi, kPi2;
}


- (void) modifyGenericStimulus {[self modifyGenericStimulusWithBonus];}
- (void) modifyDeviceStimulus {[self acuityModifyDeviceStimulusDIN01_02_04_08];}
- (float) stimDeviceunitsFromGenericunits: (float) tPest {return [self acuitystimDeviceunitsFromGenericunits: tPest];}
- (float) stimGenericunitsFromDeviceunits: (float) d {return [self acuitystimGenericunitsFromDeviceunits: d];}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerVALetters>drawStimulusInRect");
    trialInfoString = [self acuityComposeTrialInfoString];
    cgc = [[CPGraphicsContext currentContext] graphicsPort];
    CGContextSetFillColor(cgc, colOptotypeBack);
    CGContextFillRect(cgc, [[self window] frame]);
    CGContextSaveGState(cgc);
    switch(state) {
        case kStateDrawBack: break;
        case kStateDrawFore:
            CGContextTranslateCTM(cgc,  viewWidth / 2, viewHeight / 2); // origin to center
            CGContextTranslateCTM(cgc,  -xEcc, -yEcc);
            CGContextSetFillColor(cgc, colOptotypeFore);
            [optotypes setCgc: cgc colFore: colOptotypeFore colBack: colOptotypeBack];
            [optotypes drawLetterWithGapInPx: stimStrengthInDeviceunits letterNumber: [alternativesGenerator currentAlternative]];
            CGContextTranslateCTM(cgc,  xEcc, yEcc);
            break;
        default: break;
    }
    
    if ([Settings enableTouchControls] && (!responseButtonsAdded)) {
        var size = viewWidth / ((nAlternatives+1) * 1.4 + 1);
        for (var i = 0; i < nAlternatives+1; i++){
            [self buttonCenteredAtX: (i + 0.9) * 1.4 * size y: viewHeight/2 - size / 2 - 4
                               size: size title: [@"CDHKNORSVZØ" characterAtIndex: i]];
        }
    }

    CGContextRestoreGState(cgc);
    [super drawStimulusInRect: dirtyRect];
}


- (void) runStart { //console.info("FractControllerVALetters>runStart");
    kPi = Math.PI;  kPi2 = kPi / 2;
    nAlternatives = 10;  nTrials = [Settings nTrials08];
    [self setCurrentTestName: "Acuity_Letters"];
    [self setCurrentTestResultUnit: "LogMAR"];
    [super runStart];
}


- (void) runEnd { //console.info("FractControllerVALetters>runEnd");
    if (iTrial < nTrials) { //premature end
        [self setResultString: @"Aborted"];
    } else {
        [self setResultString: [self acuityComposeResultString]];
    }
    [super runEnd];
}


- (int)responseNumberFromChar: (CPString) keyChar { //console.info("FractControllerVALetters>responseNumberFromChar: ", keyChar);
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
