/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, michael.bach@uni-freiburg.de, <https://michaelbach.de>

FractControllerAcuityE.j

Created by Bach on 14.08.2017.

*/


@import "FractControllerAcuity.j"
@implementation FractControllerAcuityE: FractControllerAcuity {
}


- (void) modifyThresholderStimulus {
    if ([Settings acuityEasyTrials]) [self modifyThresholderStimulusWithBonus];
}
- (void) modifyDeviceStimulus {[self acuityModifyDeviceStimulusDIN01_02_04_08];}

- (float) stimDeviceunitsFromThresholderunits: (float) tPest {return [self acuityStimDeviceunitsFromThresholderunits: tPest];}
- (float) stimThresholderunitsFromDeviceunits: (float) d {return [self acuityStimThresholderunitsFromDeviceunits: d];}

- (float) resultValue4Export {return [self acuityResultValue4Export];}

- (CPString) composeExportString {return [self acuityComposeExportString];}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerAcuityC>drawStimulusInRect");
    trialInfoString = [self acuityComposeTrialInfoString];
    [self prepareDrawing];
    switch(state) {
        case kStateDrawBack:  break;
        case kStateDrawFore: //console.info("kStateDrawFore");
            [optotypes setCgc: cgc colFore: colOptotypeFore colBack: colOptotypeBack];
            [optotypes tumblingEWithGapInPx: stimStrengthInDeviceunits direction: [alternativesGenerator currentAlternative]];
            break;
        default: break;
    }
    if ([Settings enableTouchControls] && (!responseButtonsAdded)) {
        var sze = 50, sze2 = sze / 2;
        [self buttonCenteredAtX: viewWidth-sze2 y: 0 size: sze title: "6"];
        [self buttonCenteredAtX: sze2 y: 0 size: sze title: "4"];
        [self buttonCenteredAtX: viewWidth / 2 y: -viewHeight / 2 + sze2 size: sze title: "8"];
        [self buttonCenteredAtX: viewWidth / 2 y: viewHeight / 2 - sze2 size: sze title: "2"];
        [self buttonCenteredAtX: viewWidth - sze2 y: viewHeight / 2 - sze2 size: sze title: "Ø"];
    }
    CGContextRestoreGState(cgc);
    [super drawStimulusInRect: dirtyRect];
}


- (void) runStart { //console.info("FractControllerAcuityE>runStart");
    nAlternatives = 4;  nTrials = [Settings nTrials04];
    [self setCurrentTestResultUnit: "LogMAR"];
    [super runStart];
}


- (int) responseNumberFromChar: (CPString) keyChar { //console.info("FractControllerAcuityC>responseNumberFromChar: ", keyChar);
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
