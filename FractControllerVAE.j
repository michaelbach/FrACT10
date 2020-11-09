/*
 *  FractControllerVAE.j
 *  cappDevelop
 *
 *  Created by Bach on 14.08.2017.
 *  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
 */


@import "FractControllerAcuity.j"
@implementation FractControllerVAE: FractControllerAcuity {
}


- (void) modifyThresholderStimulus {
    if ([Settings acuityEasyTrials]) [self modifyThresholderStimulusWithBonus];
}
- (void) modifyDeviceStimulus {[self acuityModifyDeviceStimulusDIN01_02_04_08];}
- (float) stimDeviceunitsFromThresholderunits: (float) tPest {return [self acuitystimDeviceunitsFromThresholderunits: tPest];}
- (float) stimThresholderunitsFromDeviceunits: (float) d {return [self acuityStimThresholderunitsFromDeviceunits: d];}
- (float) resultValue4Export {return [self acuityResultValue4Export];}
- (CPString) composeExportString {return [self acuityComposeExportString];}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerVAC>drawStimulusInRect");
    trialInfoString = [self acuityComposeTrialInfoString];
    cgc = [[CPGraphicsContext currentContext] graphicsPort];
    CGContextSetFillColor(cgc, colOptotypeBack);
    CGContextFillRect(cgc, [[self window] frame]);
    CGContextSaveGState(cgc);
    CGContextTranslateCTM(cgc,  viewWidth / 2, viewHeight / 2); // origin to center
    switch(state) {
        case kStateDrawBack:  break;
        case kStateDrawFore: //console.info("kStateDrawFore");
            CGContextTranslateCTM(cgc,  -xEcc, -yEcc);
            [optotypes setCgc: cgc colFore: colOptotypeFore colBack: colOptotypeBack];            
            [optotypes tumblingEWithGapInPx: stimStrengthInDeviceunits direction: [alternativesGenerator currentAlternative]];
            CGContextTranslateCTM(cgc,  xEcc, yEcc);
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


- (void) runStart { //console.info("FractControllerVAE>runStart");
    nAlternatives = 4;  nTrials = [Settings nTrials04];
    [self setCurrentTestName: "Acuity_TumblingE"];
    [self setCurrentTestResultUnit: "LogMAR"];
    [super runStart];
}


- (void)runEnd { //console.info("FractControllerVAE>runEnd");
    if (iTrial < nTrials) { //premature end
        [self setResultString: @"Aborted"];
    } else {
        [self setResultString: [self acuityComposeResultString]];
    }
    [super runEnd];
}


- (int) responseNumberFromChar: (CPString) keyChar { //console.info("FractControllerVAC>responseNumberFromChar: ", keyChar);
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
