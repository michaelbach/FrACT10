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
- (float) stimDeviceunitsFromThresholderunits: (float) generic {
    return generic;
}


- (void) runStart { //console.info("FractControllerBalmLight>runStart");
    nAlternatives = 2;  nTrials = [Settings nTrials02];
    [self setCurrentTestResultUnit: "hit rate"];
    [Settings setAcuityForeColor: [CPColor whiteColor]];// will be copied → gColorFore
    [Settings setAcuityBackColor: [CPColor blackColor]];
    [super runStart];
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerBalmLight>drawStimulusInRect");
    trialInfoString = [self acuityComposeTrialInfoString];
    [self prepareDrawing];
    switch(state) {
        case kStateDrawBack: break;
        case kStateDrawFore://console.info("kStateDrawFore");
            [sound playNumber: kSoundTrialYes];
            console.info("currentAlternative", [alternativesGenerator currentAlternative]);
            if ([alternativesGenerator currentAlternative] != 0) {
                CGContextSetFillColor(cgc, gColorFore);
                CGContextFillRect(cgc, [selfWindow frame]);
            }
//            [optotypes drawLandoltWithStrokeInPx: stimStrengthInDeviceunits landoltDirection: [alternativesGenerator currentAlternative]];
            break;
        default: break;
    }
    CGContextRestoreGState(cgc);
    CGContextSetFillColor(cgc, gColorBack);
    [super drawStimulusInRect: dirtyRect];
}


- (void) runEnd { //console.info("FractControllerBalm>runEnd");
    switch (currentTestID) {
        case kTestAcuityLett:
        case kTestAcuityC:
        case kTestAcuityE:
        case kTestAcuityTAO:
            if (iTrial < nTrials) { //premature end
                [self setResultString: "Aborted"];
            } else {
                [self setResultString: [self acuityComposeResultString]];
            }
            break;
        case kTestAcuityVernier:
            break;
        case kTestAcuityLineByLine:
            [self setResultString: ""];
            break;
    }
    [super runEnd];
}


- (CPString) acuityComposeTrialInfoString {
    let s = iTrial + "/" + nTrials + " ";
    s += [Misc stringFromNumber: [MiscSpace decVAFromStrokePixels: stimStrengthInDeviceunits] decimals: 2 localised: NO];
    return s;
}


- (float) acuityResultInDecVA {
    const resultInStrokePx = stimStrengthInDeviceunits;
    let resultInDecVA = [MiscSpace decVAFromStrokePixels: resultInStrokePx];
    if ([Settings threshCorrection]) resultInDecVA *= gThresholdCorrection4Ascending;
    //console.info("FractControllerAcuity>acuityResultInDecVA: ", resultInDecVA);
    return resultInDecVA;
}


- (float) acuityResultInLogMAR {
    return [MiscSpace logMARfromDecVA: [self acuityResultInDecVA]];
}


- (float) acuityResultValue4Export {
    return [self acuityResultInLogMAR];
}


- (CPString) acuityComposeResultString { // 2021-05-02: now all formats are "ceilinged"
    const resultInDecVACeilinged = Math.min([Settings maxDisplayedAcuity], [self acuityResultInDecVA]);
    const resultInLogMARCeilinged = [MiscSpace logMARfromDecVA: resultInDecVACeilinged];
    let s = "";
    if ([Settings acuityFormatLogMAR]) {
        if (s.length > 1) s += ",  ";
        s += "LogMAR:" + [self rangeStatusIndicatorStringInverted: YES];
        s += [Misc stringFromNumber: resultInLogMARCeilinged decimals: 2 localised: YES];
        if (ci95String.length > 1) {
            s += ci95String;
        }
    }
    if ([Settings acuityFormatDecimal]) {
        if (s.length > 1) s += ",  ";
        s += "decVA:" + [self rangeStatusIndicatorStringInverted: NO];
        s += [Misc stringFromNumber: resultInDecVACeilinged decimals: 2 localised: YES];
    }
    if ([Settings acuityFormatSnellenFractionFoot]) {
        if (s.length > 1) s += ",  ";
        s += "Snellen fraction:" +  [self rangeStatusIndicatorStringInverted: NO];
        s += [self format4SnellenInFeet: resultInDecVACeilinged];
    }
    return s;
}


- (CPString) acuityComposeExportString { //console.info("FractController>acuityComposeExportString");
    if (gAppController.runAborted) return "";
    let s = [self generalComposeExportString];
    const nDigits = 3;
    s += tab + "value" + tab + [Misc stringFromNumber: [self resultValue4Export] decimals: nDigits localised: YES];
    s += tab + "unit1" + tab + currentTestResultUnit
    s += tab + "distanceInCm" + tab + [Misc stringFromNumber: [Settings distanceInCM] decimals: 1 localised: YES];
    s += tab + "contrastWeber" + tab + [Misc stringFromNumber: [Settings contrastAcuityWeber] decimals: 1 localised: YES];
    s += tab + "unit2" + tab + "%";
    s += tab + "nTrials" + tab + [Misc stringFromNumber: nTrials decimals: 0 localised: YES];
    s += tab + "rangeLimitStatus" + tab + rangeLimitStatus;
    s += tab + "crowding" + tab + [Settings crowdingType];
    return [self generalComposeExportStringFinalize: s];
}


@end
