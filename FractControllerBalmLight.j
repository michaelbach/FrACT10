/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>
 
 2020-11-09 created class "FractControllerBalmLight" inheriting from "FractController"
 */


@import "FractController.j"
@implementation FractControllerBalmLight: FractController {
    int directionInRow;
}


- (void) modifyThresholderStimulus {
}
- (float) stimThresholderunitsFromDeviceunits: (float) ntve {
    return ntve;
}
- (float) stimDeviceunitsFromThresholderunits: (float) generic {
    return generic;
}


- (void) runStart { //console.info("FractControllerBalmLight>runStart");
    nAlternatives = 2;  nTrials = [Settings nTrials02];
    [self setCurrentTestResultUnit: "hitRateInPercent"];
    [Settings setAcuityForeColor: [CPColor whiteColor]];// will be copied → gColorFore
    [Settings setAcuityBackColor: [CPColor blackColor]];
    [Settings setAuditoryFeedback4trial: kAuditoryFeedback4trialNone];
    [super runStart];
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerBalmLight>drawStimulusInRect");
    [self prepareDrawing];
    switch(state) {
        case kStateDrawBack: break;
        case kStateDrawFore://console.info("kStateDrawFore");
            [sound playNumber: kSoundTrialYes];
            if ([alternativesGenerator currentAlternative] != 0) {
                CGContextSetFillColor(cgc, gColorFore);
                CGContextFillRect(cgc, CGRectMake(-viewWidth2, -viewHeight2, viewWidth, viewHeight));
            }
            discardKeyEntries = NO; // now allow responding
            break;
        default: break;
    }
    CGContextRestoreGState(cgc);
    CGContextSetFillColor(cgc, gColorBack);
    [super drawStimulusInRect: dirtyRect];
}


// 0 & 4=valid; -1=ignore; -2=invalid
- (int) responseNumberFromChar: (CPString) keyChar { //console.info("FractControllerBalmLight>responseNumberFromChar: ", keyChar);
    switch (keyChar) { // 0=no light, 4=light
        case CPLeftArrowFunctionKey: case CPDownArrowFunctionKey:
        case "2": case "4": return 0;
        case CPRightArrowFunctionKey: case CPUpArrowFunctionKey:
        case "6": case "8": return 4;
        case "5": return -1;
    }
    return -2;
}


- (void) runEnd { //console.info("FractControllerBalm>runEnd");
    if (iTrial < nTrials) { //premature end
        [self setResultString: "Aborted"];
    } else {
        [self setResultString: [self balmLightComposeResultString]];
    }
    [super runEnd];
}


- (float) resultValue4Export {
    const total = [trialHistoryController nCorrect] + [trialHistoryController nIncorrect];
    if ([trialHistoryController nTotal] != total) throw new Error("corret+incorrect ≠ total.");
    // ↑ should never occur
    const hitRateInPercent = 100 * [trialHistoryController nCorrect] / total;
    return hitRateInPercent;
}


- (CPString) balmLightComposeResultString {
    let s = [Misc stringFromNumber: [self resultValue4Export] decimals: 1 localised: YES];
    s = "Hit rate: " + s + "%";
    return s;
}


- (CPString) composeExportString { //console.info("FractControllerBalm>composeExportString");
    if (gAppController.runAborted) return "";

    let s = [self generalComposeExportString];
    const nDigits = 3;
    s += tab + "value" + tab + [Misc stringFromNumber: [self resultValue4Export] decimals: nDigits localised: YES];
    s += tab + "unit1" + tab + currentTestResultUnit
    s += tab + "distanceInCm" + tab + [Misc stringFromNumber: [Settings distanceInCM] decimals: 1 localised: YES];
    s += tab + "contrastWeber" + tab + 99;
    s += tab + "unit2" + tab + "%";
    s += tab + "nTrials" + tab + [Misc stringFromNumber: nTrials decimals: 0 localised: YES];
    s += tab + "rangeLimitStatus" + tab + rangeLimitStatus;
    s += tab + "crowding" + tab + [Settings crowdingType];
    return [self generalComposeExportStringFinalize: s];
}


@end
