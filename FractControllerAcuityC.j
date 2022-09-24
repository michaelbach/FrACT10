/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, michael.bach@uni-freiburg.de, <https://michaelbach.de>

FractControllerAcuityC.j

Created by Bach on 18.07.2017.
*/


@import "FractControllerAcuity.j"
@implementation FractControllerAcuityC: FractControllerAcuity {
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
        case kStateDrawBack: break;
        case kStateDrawFore: //console.info("kStateDrawFore");
            [optotypes setCgc: cgc colFore: colOptotypeFore colBack: colOptotypeBack];
            if (([Settings nAlternatives] == 4) && ([Settings obliqueOnly])) {
                [alternativesGenerator setCurrentAlternative: [alternativesGenerator currentAlternative] + 1];
            }
            [optotypes drawLandoltWithGapInPx: stimStrengthInDeviceunits landoltDirection: [alternativesGenerator currentAlternative]];
            break;
        default: break;
    }
    if ([Settings enableTouchControls] && (!responseButtonsAdded)) {
        const sze = 50, sze2 = sze / 2, radius = 0.5 * Math.min(viewWidth, viewHeight) - sze2 - 1;
        for (let i = 0; i < 8; i++) {
            if ( ([Settings nAlternatives] > 4)  || (![Misc isOdd: i])) {
                let iConsiderObliqueOnly = i;
                if (([Settings nAlternatives] == 4) && [Settings obliqueOnly])  iConsiderObliqueOnly++;
                const ang = iConsiderObliqueOnly / 8 * 2 * Math.PI;
                [self buttonCenteredAtX: viewWidth / 2 + Math.cos(ang) * radius y:  Math.sin(ang) * radius size: sze title: [@"632147899" characterAtIndex: iConsiderObliqueOnly]];
            }
        }
        [self buttonCenteredAtX: viewWidth - sze2 - 1 y: viewHeight / 2 - sze2 - 1 size: sze title: "Ø"];
    }
    CGContextRestoreGState(cgc);
    [super drawStimulusInRect: dirtyRect];
}


- (void) runStart { //console.info("FractControllerAcuityLetters>runStart");
    nAlternatives = [Settings nAlternatives];  nTrials = [Settings nTrials];
    [self setCurrentTestResultUnit: "LogMAR"];
    [super runStart];
}


// 0–8: valid; -1: ignore; -2: invalid
- (int) responseNumberFromChar: (CPString) keyChar { //console.info("FractControllerAcuityC>responseNumberFromChar: ", keyChar);
    switch (keyChar) {
        case CPLeftArrowFunctionKey: return 4;
        case CPRightArrowFunctionKey: return 0;
        case CPUpArrowFunctionKey: return 2;
        case CPDownArrowFunctionKey: return 6;
        case "6": return 0;
        case "9": return 1;
        case "8": return 2;
        case "7": return 3;
        case "4": return 4;
        case "1": return 5;
        case "2": return 6;
        case "3": return 7;
        case "5": return -1;
    }
    return -2;
}


@end
