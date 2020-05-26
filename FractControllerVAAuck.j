/*
 *  FractControllerVAAuck.j
 *  cappDevelop
 *
 *  Created by Bach on 2020-05-21
 *  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
 */

@import <Foundation/CPObject.j>

@implementation FractControllerVAAuck: FractController {
    CGRect imageRect;
    id auckImages @accessors;
}


- (void) modifyGenericStimulus {[self modifyGenericStimulusWithBonus];}
- (void) modifyDeviceStimulus {[self acuityModifyDeviceStimulusDIN01_02_04_08];}
- (float) stimDeviceFromGeneric: (float) tPest {return [self acuityStimDeviceFromGeneric: tPest];}
- (float) stimGenericFromDevice: (float) d {return [self acuityStimGenericFromDevice: d];}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.log("FractControllerVAAuck>drawStimulusInRect");
    trialInfoString = [self acuityComposeTrialInfoString];
    cgc = [[CPGraphicsContext currentContext] graphicsPort];
    CGContextSetFillColor(cgc, colOptotypeBack);
    CGContextFillRect(cgc, [[self window] frame]);
    CGContextSaveGState(cgc);
    switch(state) {
        case kStateDrawBack: break;
        case kStateDrawFore:
            CGContextTranslateCTM(cgc,  viewWidth / 2, viewHeight / 2); // origin to center
            var sizeInPix = stimStrengthInDeviceunits * 5 * 8.172 / 5;// correction for stroke width (Dakin)
            CGContextSetFillColor(cgc, colOptotypeFore);
            imageRect = CGRectMake(-sizeInPix / 2, -sizeInPix / 2, sizeInPix, sizeInPix);
            CGContextDrawImage(cgc, imageRect, auckImages[[alternativesGenerator currentAlternative]]);

            CGContextTranslateCTM(cgc,  -viewWidth / 2, -viewHeight / 2); // origin back
            var size = viewWidth / (nAlternatives * 2 + 1);
            CGContextSetTextDrawingMode(cgc, kCGTextFill);
            CGContextSelectFont(cgc, "36px sans-serif"); // this, surprisingly, must be CSS
            for (var i = 0; i < nAlternatives; i++) {
                imageRect = CGRectMake((i + 0.5) * 2 * size, viewHeight - 1.1 * size, size, size);
                CGContextDrawImage(cgc, imageRect, auckImages[i]);
                CGContextShowTextAtPoint(cgc, (i + 0.5) * 2 * size + size / 2 - 8, viewHeight - 1.5 * size,
                                         [CPString stringWithFormat: @"%d", (i + 1) % 10]);
            }
            break;
        default: break;
    }
    CGContextRestoreGState(cgc);
    CGContextSetTextPosition(cgc, 10, 10);  CGContextSetFillColor(cgc, colOptotypeFore);
    CGContextShowText(cgc, trialInfoString);
    [super drawStimulusInRect: dirtyRect];
}


- (void) runStart { //console.log("FractControllerVAAuck>runStart");
    nAlternatives = 10;  nTrials = [Settings nTrials08];
    [self setCurrentTestName: "Acuity_Auckland"];
    [self setCurrentTestResultUnit: "LogMAR"];
    abortCharacter = "A";
    [super runStart];
}


- (void)runEnd { //console.log("FractControllerVAAuck>runEnd");
    if (iTrial < nTrials) { //premature end
        [self setResultString: @"Aborted"];
    } else {
        [self setResultString: [self acuityComposeResult]];
    }
    [super runEnd];
}


- (int)responseNumberFromChar: (CPString) keyChar { //console.log("FractControllerVAAuck>responseNumberFromChar: ", keyChar);
    switch ([keyChar uppercaseString]) {
        case "0": return 9;
        case "1": return 0;
        case "2": return 1;
        case "3": return 2;
        case "4": return 3;
        case "5": return 4;
        case "6": return 5;
        case "7": return 6;
        case "8": return 7;
        case "9": return 8;
        case abortCharacter: return -1;
    }
    return -2;// -1: ignore; -2: invalid
}


@end
