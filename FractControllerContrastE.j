/*
 FractControllerContrastE.j

 Created by Bach on 2020-09-02
*/


@import "FractControllerContrast.j"
@implementation FractControllerContrastE: FractControllerContrast {
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerContrastLett>drawStimulusInRect");
    [self calculateForeBackColors];
    [self prepareDrawing];
    switch(state) {
        case kStateDrawBack: break;
        case kStateDrawFore:
            [self drawFixMark];
            break;
        case kStateDrawFore2:
            [optotypes tumblingEWithGapInPx: optotypeSize direction: [alternativesGenerator currentAlternative]];
            stimStrengthInDeviceunits = [optotypes getCurrentContrastLogCSWeber];
            trialInfoString = [self contrastComposeTrialInfoString];// compose here after colors are set
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


- (void) runStart { //console.info("FractControllerContrastLett>runStart");
    nAlternatives = 4;  nTrials = [Settings nTrials04];
    [self setCurrentTestName: "Contrast_TumblingE"];
    [super runStart];
}


- (int) responseNumberFromChar: (CPString) keyChar { //console.info("FractControllerContrastE>responseNumberFromChar: ", keyChar);
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
