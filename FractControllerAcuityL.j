/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, michael.bach@uni-freiburg.de, <https://michaelbach.de>

FractControllerAcuityLetters.j

Created by Bach on 08.08.2017.
*/


@import "FractControllerAcuity.j"
@implementation FractControllerAcuityL: FractControllerAcuity {
}


- (void) modifyThresholderStimulus {
    if ([Settings acuityEasyTrials]) [self modifyThresholderStimulusWithBonus];
}
- (void) modifyDeviceStimulus {[self acuityModifyDeviceStimulusDIN01_02_04_08];}
- (float) stimDeviceunitsFromThresholderunits: (float) tPest {return [self acuityStimDeviceunitsFromThresholderunits: tPest];}
- (float) stimThresholderunitsFromDeviceunits: (float) d {return [self acuityStimThresholderunitsFromDeviceunits: d];}
- (float) resultValue4Export {return [self acuityResultValue4Export];}
- (CPString) composeExportString {return [self acuityComposeExportString];}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerAcuityLetters>drawStimulusInRect");
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
        const size = viewWidth / ((nAlternatives+1) * 1.4 + 1);
        for (let i = 0; i < nAlternatives+1; i++){
            [self buttonCenteredAtX: (i + 0.9) * 1.4 * size y: viewHeight/2 - size / 2 - 4
                               size: size title: [@"CDHKNORSVZØ" characterAtIndex: i]];
        }
    }

    CGContextRestoreGState(cgc);
    [super drawStimulusInRect: dirtyRect];
}


- (void) runStart { //console.info("FractControllerAcuityLetters>runStart");
    nAlternatives = 10;  nTrials = [Settings nTrials08];
    [self setCurrentTestResultUnit: "LogMAR"];
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
