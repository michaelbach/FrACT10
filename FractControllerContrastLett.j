/*
 FractControllerContrastLett.j

 Created by Bach on 2020-08-17
*/


@import <Foundation/CPObject.j>

@implementation FractControllerContrastLett: FractController {
}


- (void) modifyThresholderStimulus {if ([Settings contrastEasyTrials]) [self modifyThresholderStimulusWithBonus];}
- (void) modifyDeviceStimulus {}
- (float) stimDeviceunitsFromThresholderunits: (float) thresholderunit {return [self contrastStimDeviceunitsFromThresholderunits: thresholderunit];}
- (float) stimThresholderunitsFromDeviceunits: (float) d {return [self contrastStimThresholderunitsFromDeviceunits: d];}
- (CPString) composeExportString {return [self contrastComposeExportString];}

- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerContrastLett>drawStimulusInRect");
    cgc = [[CPGraphicsContext currentContext] graphicsPort];

    var temp1 = [Misc lowerLuminanceFromContrastLogCSWeber: stimStrengthInDeviceunits];
    temp1 = [Misc devicegreyFromLuminance: temp1];
    colOptotypeFore = [CPColor colorWithWhite: temp1 alpha: 1];
    //console.info(colOptotypeFore);
    var temp2 = [Misc upperLuminanceFromContrastLogCSWeber: stimStrengthInDeviceunits];
    temp2 = [Misc devicegreyFromLuminance: temp2];
    colOptotypeBack = [CPColor colorWithWhite: temp2 alpha: 1];
    //console.info(colOptotypeBack);
    var oSize = [Misc pixelFromDegree: [Settings contrastOptotypeDiameter] / 60] / 5;

    CGContextSetFillColor(cgc, colOptotypeBack);
    CGContextFillRect(cgc, [[self window] frame]);
    CGContextSaveGState(cgc);
    switch(state) {
        case kStateDrawBack: break;
        case kStateDrawFore:
            CGContextTranslateCTM(cgc,  viewWidth / 2, viewHeight / 2); // origin to center
            CGContextTranslateCTM(cgc,  -xEcc, -yEcc);
            CGContextSetStrokeColor(cgc, [CPColor colorWithRed: 0 green: 0 blue: 1 alpha: 0.7]);
            CGContextSetLineWidth(cgc, 0.5);
            [optotypes setCgc: cgc colFore: [CPColor colorWithRed: 0 green: 0 blue: 1 alpha: 0.3] colBack: colOptotypeBack];
            [optotypes strokeCrossAtX: 0 y: 0 size: oSize * 3];
            [optotypes strokeXAtX: 0 y: 0 size: oSize * 3];
            var t = [Settings contrastTimeoutFixmark] / 1000;
            timerFixCross = [CPTimer scheduledTimerWithTimeInterval: t target:self selector:@selector(onTimeoutFixCross:) userInfo:nil repeats:NO];
            break;
        case kStateDrawFore2:
            CGContextTranslateCTM(cgc,  viewWidth / 2, viewHeight / 2); // origin to center
            CGContextTranslateCTM(cgc,  -xEcc, -yEcc);
            //console.info("FractControllerContrastLett>staste: ", state);
            //console.info("FractControllerContrastLett>drawStimulusInRect, temp1: ", temp1, ", temp2: ", temp2);
            [optotypes setCgc: cgc colFore: colOptotypeFore colBack: colOptotypeBack];
            [optotypes drawLetterWithGapInPx: oSize letterNumber: [alternativesGenerator currentAlternative]];
            //console.info(stimStrengthInDeviceunits, [optotypes getCurrentContrastLogCSWeber])
            stimStrengthInDeviceunits = [optotypes getCurrentContrastLogCSWeber];
            trialInfoString = [self contrastComposeTrialInfoString];// compose here after colors are set
            CGContextTranslateCTM(cgc,  xEcc, yEcc);
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


- (void) onTimeoutFixCross: (CPTimer) timer { //console.info("FractController>onTimeoutFixCross");
    state = kStateDrawFore2;  [[[self window] contentView] setNeedsDisplay: YES];
}


- (void) runStart { //console.info("FractControllerContrastLett>runStart");
    nAlternatives = 10;  nTrials = [Settings nTrials08];
    [self setCurrentTestName: "Contrast_Letters"];
    [self setCurrentTestResultUnit: "logCSWeber"];
    [super runStart];
}


- (void) runEnd { //p.info("FractControllerContrastLett>runEnd");
    if (iTrial < nTrials) { //premature end
        [self setResultString: @"Aborted"];
    } else {
        [self setResultString: [self contrastComposeResultString]];
    }
    [super runEnd];
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
