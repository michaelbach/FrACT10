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
    id labels;
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
            var sizeInPix = stimStrengthInDeviceunits * 5 * 8.172 / 5;// correction for stroke widht (Dakin)
            CGContextSetFillColor(cgc, colOptotypeFore);
            imageRect = CGRectMake(-sizeInPix / 2, -sizeInPix / 2, sizeInPix, sizeInPix);
            CGContextDrawImage(cgc, imageRect, auckImages[[alternativesGenerator currentAlternative]]);

            CGContextTranslateCTM(cgc,  -viewWidth / 2, -viewHeight / 2); // origin back
            var size = viewWidth / 21;
            labels = [];
            for (var i = 0; i < 10; i++) {
                imageRect = CGRectMake((i + 0.5) * 2 * size, viewHeight - 1.1 * size, size, size);
                CGContextDrawImage(cgc, imageRect, auckImages[i]);
                labels[i] = [[CPTextField alloc] initWithFrame: CGRectMake((i + 0.5) * 2 * size, viewHeight - 1.9 * size, size, size)];
                [labels[i] setIntegerValue: (i + 1) % 10];  [labels[i] setAlignment: CPCenterTextAlignment];
                [labels[i] setFont: [CPFont fontWithName: [[labels[i] font] familyName] size: 36]];
                [[[self window] contentView] addSubview: labels[i]];
            }
            break;
        default: break;
    }
    CGContextRestoreGState(cgc);
    CGContextSetTextPosition(cgc, 10, 10);  CGContextSetFillColor(cgc, colOptotypeFore);
    CGContextShowText(cgc, trialInfoString);
}


- (void) runStart { //console.log("FractControllerVAAuck>runStart");
    nAlternatives = 10;  nTrials = [Settings nTrials08];
    [self setCurrentTestName: "Acuity_Auckland"];
    [self setCurrentTestResultUnit: "LogMAR"];
    abortCharacter = "A";

    [super runStart];
}


- (void)runEnd { //console.log("FractControllerVAAuck>runEnd");
    for (var i = 0; i < 10; i++) [labels[i] removeFromSuperview];
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
