/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

FractControllerAcuityLetters.j

Created by Bach on 08.08.2017.
*/


@import "FractControllerAcuity.j"
@implementation FractControllerAcuityL: FractControllerAcuity {
}


- (void) modifyThresholderStimulus {
    if ([Settings acuityHasEasyTrials]) [self modifyThresholderStimulusWithBonus];
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
            [optotypes drawLetterWithStriokeInPx: stimStrengthInDeviceunits letterNumber: [alternativesGenerator currentAlternative]];
            break;
        default: break;
    }
    
    [self embedInNoise];
    [self drawTouchControls];
    CGContextRestoreGState(cgc);
    [super drawStimulusInRect: dirtyRect];
}


- (void) runStart { //console.info("FractControllerAcuityLetters>runStart");
    nAlternatives = 10;  nTrials = [Settings nTrials08];
    [gAppController setCurrentTestResultUnit: "LogMAR"];
    [super runStart];
}


- (int) responseNumberFromChar: (CPString) keyChar {
    return [self responseNumber10FromChar: keyChar];
}


@end
