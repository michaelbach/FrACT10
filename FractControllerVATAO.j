/*
 *  FractControllerVATAO.j
 *  cappDevelop
 *
 *  Created by Bach on 2020-05-21
 *  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
 */

@import <Foundation/CPObject.j>

@implementation FractControllerVATAO: FractController {
    CGRect imageRect;
    id taoImages;
}


- (void) modifyGenericStimulus {[self modifyGenericStimulusWithBonus];}
- (void) modifyDeviceStimulus {[self acuityModifyDeviceStimulusDIN01_02_04_08];}
- (float) stimDeviceunitsFromGenericunits: (float) tPest {return [self acuitystimDeviceunitsFromGenericunits: tPest];}
- (float) stimGenericunitsFromDeviceunits: (float) d {return [self acuitystimGenericunitsFromDeviceunits: d];}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerVATAO>drawStimulusInRect");
    trialInfoString = [self acuityComposeTrialInfoString];
    cgc = [[CPGraphicsContext currentContext] graphicsPort];
    CGContextSetFillColor(cgc, [CPColor whiteColor]); // contrast not respected with TAO
    CGContextFillRect(cgc, [[self window] frame]);
    CGContextSaveGState(cgc);
    switch(state) {
        case kStateDrawBack: break;
        case kStateDrawFore:
            CGContextTranslateCTM(cgc,  viewWidth / 2, viewHeight / 2); // origin to center
            var sizeInPix = stimStrengthInDeviceunits * 5 * 8.172 / 5;// correction for stroke width (Dakin)
            CGContextSetFillColor(cgc, colOptotypeFore);
            imageRect = CGRectMake(-sizeInPix / 2, -sizeInPix / 2, sizeInPix, sizeInPix);
            CGContextTranslateCTM(cgc,  -xEcc, -yEcc);
            CGContextDrawImage(cgc, imageRect, taoImages[[alternativesGenerator currentAlternative]]);
            CGContextTranslateCTM(cgc,  xEcc, yEcc);
            
            CGContextTranslateCTM(cgc,  -viewWidth / 2, -viewHeight / 2); // origin back
            var size = viewWidth / (nAlternatives * 2 + 2), button;
            if (!responseButtonsAdded) {
                for (var i = 0; i < (nAlternatives); i++) {
                    button = [self buttonCenteredAtX: (i + 0.75) * 2 * size y: viewHeight/2 - 0.5 * size size: size title: "" keyEquivalent: [@"1234567890" characterAtIndex: i]];
                    [button setImage: taoImages[i]];
                    [button setImageScaling: CPImageScaleProportionallyDown];
                }
                [self buttonCenteredAtX: (10 + 0.75) * 2 * size y: viewHeight/2 - 0.5 * size size: size title: "Ø"];
            }
            CGContextSetTextDrawingMode(cgc, kCGTextFill);
            CGContextSelectFont(cgc, "36px sans-serif"); // this, surprisingly, must be CSS
            for (var i = 0; i < (nAlternatives); i++)
                CGContextShowTextAtPoint(cgc, (i + 0.5) * 2 * size + size / 2 - 8, viewHeight - 1.4 * size, [Misc stringFromInteger: (i + 1) % 10]);
            break;
        default: break;
    }
    CGContextRestoreGState(cgc);
    [super drawStimulusInRect: dirtyRect];
}


- (void) runStart { //console.info("FractControllerVATAO>runStart");
    taoImages = [parentController taoImageArray];
    nAlternatives = 10;  nTrials = [Settings nTrials08];
    [self setCurrentTestName: "Acuity_TAO"];
    [self setCurrentTestResultUnit: "LogMAR"];
    abortCharacter = "A";
    [super runStart];
}


- (void)runEnd { //console.info("FractControllerVATAO>runEnd");
    if (iTrial < nTrials) { //premature end
        [self setResultString: @"Aborted"];
    } else {
        [self setResultString: [self acuityComposeResultString]];
    }
    [super runEnd];
}


- (int)responseNumberFromChar: (CPString) keyChar { //console.info("FractControllerVATAO>responseNumberFromChar: ", keyChar);
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
