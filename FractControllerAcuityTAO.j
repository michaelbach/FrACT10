/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 FractControllerAcuityTAO.j
 
Created by Bach on 2020-05-21
*/


@import "FractControllerAcuity.j"
@implementation FractControllerAcuityTAO: FractControllerAcuity {
    CGRect imageRect;
}


- (void) modifyThresholderStimulus {
    if ([Settings acuityEasyTrials]) [self modifyThresholderStimulusWithBonus];
}
- (void) modifyDeviceStimulus {[self acuityModifyDeviceStimulusDIN01_02_04_08];}
- (float) stimDeviceunitsFromThresholderunits: (float) tPest {return [self acuityStimDeviceunitsFromThresholderunits: tPest];}
- (float) stimThresholderunitsFromDeviceunits: (float) d {return [self acuityStimThresholderunitsFromDeviceunits: d];}
- (float) resultValue4Export {return [self acuityResultValue4Export];}
- (CPString) composeExportString {return [self acuityComposeExportString];}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerAcuityTAO>drawStimulusInRect");
    trialInfoString = [self acuityComposeTrialInfoString];
    [self prepareDrawing];
    switch(state) {
        case kStateDrawBack: break;
        case kStateDrawFore:
            [gAppController.taoController drawTaoWithStrokeInPx: stimStrengthInDeviceunits taoNumber: [alternativesGenerator currentAlternative]];
            [self prepareDrawingTransformUndo]; //otherwise the button numbers are subject to "display transform"
            const size = viewWidth / (nAlternatives * 2 + 2)
            if (!responseButtonsAdded) {
                for (let i = 0; i < (nAlternatives); i++) {
                    const button = [self buttonCenteredAtX: (i + 0.75) * 2 * size y: viewHeight2 - 0.5 * size size: size title: "" keyEquivalent: [@"1234567890" characterAtIndex: i]];
                    [button setImage: [gAppController.taoController imageNumber: i]];
                    [button setImageScaling: CPImageScaleProportionallyDown];
                }
                [self buttonCenteredAtX: (10 + 0.75) * 2 * size y: viewHeight2 - 0.5 * size size: size title: "Ø"];
            }
            CGContextSetTextDrawingMode(cgc, kCGTextFill);
            CGContextSelectFont(cgc, "36px sans-serif"); //this, surprisingly, must be CSS
            for (let i = 0; i < (nAlternatives); i++)
                CGContextShowTextAtPoint(cgc, (i + 0.5) * 2 * size + size / 2 - 8, viewHeight - 1.4 * size, [Misc stringFromInteger: (i + 1) % 10]);
            break;
        default: break;
    }
    CGContextRestoreGState(cgc);
    [super drawStimulusInRect: dirtyRect];
}


- (void) runStart { //console.info("FractControllerAcuityTAO>runStart");
    nAlternatives = 10;  nTrials = [Settings nTrials08];
    [gAppController setCurrentTestResultUnit: "LogMAR"];
    abortCharacter = "A";
    [super runStart];
}


- (int)responseNumberFromChar: (CPString) keyChar { //console.info("FractControllerAcuityTAO>responseNumberFromChar: ", keyChar);
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
    return -2; //-1: ignore; -2: invalid
}


@end
