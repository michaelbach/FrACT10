    /*
 *  FractControllerVALetters.j
 *  cappDevelop
 *
 *  Created by Bach on 08.08.2017.
 *  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
 */


@import "FractControllerAcuity.j"
@implementation FractControllerVAL: FractControllerAcuity {
}


- (void) modifyThresholderStimulus {
    if ([Settings acuityEasyTrials]) [self modifyThresholderStimulusWithBonus];
}
- (void) modifyDeviceStimulus {[self acuityModifyDeviceStimulusDIN01_02_04_08];}
- (float) stimDeviceunitsFromThresholderunits: (float) tPest {return [self acuitystimDeviceunitsFromThresholderunits: tPest];}
- (float) stimThresholderunitsFromDeviceunits: (float) d {return [self acuityStimThresholderunitsFromDeviceunits: d];}
- (float) resultValue4Export {return [self acuityResultValue4Export];}
- (CPString) composeExportString {return [self acuityComposeExportString];}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerVALetters>drawStimulusInRect");
    trialInfoString = [self acuityComposeTrialInfoString];
    [self prepareDrawing];
    switch(state) {
        case kStateDrawBack: break;
        case kStateDrawFore:
            [optotypes drawLetterWithGapInPx: stimStrengthInDeviceunits letterNumber: [alternativesGenerator currentAlternative]];
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
    nAlternatives = 10;  nTrials = [Settings nTrials08];
    [self setCurrentTestName: "Acuity_Letters"];
    [self setCurrentTestResultUnit: "LogMAR"];
    [super runStart];
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
