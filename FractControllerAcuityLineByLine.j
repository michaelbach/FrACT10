/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

FractControllerAcuityLineByLine.j

This module draws a 5-optotype line to aid in refraction.
It's task does not really fit the testing via trial/run, but whatever
Created by mb on 2021-12-21.
*/


@import "FractControllerAcuity.j"
@implementation FractControllerAcuityLineByLine: FractControllerAcuity {
    float localLogMAR;
}


- (float) resultValue4Export {return [self acuityResultValue4Export];}
- (CPString) composeExportString {return [self acuityComposeExportString];}


- (id) initWithWindow: (CPWindow) aWindow {
    localLogMAR = 0.3; //we need this method only for this line, starting acuity
    self = [super initWithWindow: aWindow];
    return self;
}


- (float) stimThresholderunitsFromDeviceunits: (float) d {return [self acuityStimThresholderunitsFromDeviceunits: d];}


- (void) trialStart { //console.info("FractControllerAcuityLineByLine>trialStart");
    iTrial = 1;
    stimStrengthInDeviceunits = [MiscSpace strokePixelsFromDecVA: [MiscSpace decVAfromLogMAR: localLogMAR]];
    state = kStateDrawFore;
    [[gAppController.selfWindow contentView] setNeedsDisplay: YES];
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerAcuityLetters>drawStimulusInRect");
    const verticalOffset = 150;
    [self prepareDrawing];
    switch(state) {
        case kStateDrawBack: break;
        case kStateDrawFore:
            const chartmodeNotConstVA = ![Settings lineByLineChartModeConstantVA];
            CGContextSaveGState(cgc);
            const lineRange = [Settings lineByLineLinesIndex];
            if (lineRange > 0) {
                if (chartmodeNotConstVA) {
                    stimStrengthInDeviceunits /= Math.pow(2, 1/10);
                }
            }
            for (let iLine = -lineRange; iLine <= lineRange; iLine++) {
                const usedAlternativesArray = [];
                let optotypeDistance = 1; //according to ETDRS
                if ([Settings testOnLineByLineDistanceType] == 0) { //according to DIN EN ISO 8596
                    optotypeDistance = 0.4;
                    const localDecVA = [MiscSpace decVAfromLogMAR: localLogMAR];
                    if (localDecVA >= 0.06) optotypeDistance = 1;
                    if (localDecVA >= 0.16) optotypeDistance = 1.5;
                    if (localDecVA >= 0.4) optotypeDistance = 2;
                    if (localDecVA >= 1.0) optotypeDistance = 3;
                }
                optotypeDistance = (1 + optotypeDistance) * stimStrengthInDeviceunits * 5;
                if (iLine >= -1) CGContextTranslateCTM(cgc, 0, optotypeDistance);
                const iRange = [Settings lineByLineHeadcountIndex];
                for (let i = -iRange; i <= iRange; i++) { //iDex 0…3 → 1, 3, 5, 7
                    const tempX = i * optotypeDistance;
                    CGContextTranslateCTM(cgc, -tempX, -verticalOffset);
                    let currentAlternative = [Misc iRandom: nAlternatives];
                    while (usedAlternativesArray.includes(currentAlternative)) {
                        currentAlternative = [Misc iRandom: nAlternatives];
                    }
                    usedAlternativesArray.push(currentAlternative);
                    switch([Settings testOnLineByLine]) {
                        case 1: [optotypes drawLetterWithStriokeInPx: stimStrengthInDeviceunits letterNumber: currentAlternative];  break;
                        case 2: [optotypes drawLandoltWithStrokeInPx: stimStrengthInDeviceunits landoltDirection: currentAlternative];  break;
                        default: console.log("Line-by-line: unsupported optotype-id: ", [Settings testOnLineByLine]);
                    }
                    CGContextTranslateCTM(cgc, +tempX, verticalOffset);
                }
                if (chartmodeNotConstVA) {
                    stimStrengthInDeviceunits /= Math.pow(2, 1/10);
                }
            }
            CGContextRestoreGState(cgc);
            CGContextSetFillColor(cgc, [CPColor blueColor]);
            CGContextSetTextDrawingMode(cgc, kCGTextFill);
            CGContextSelectFont(cgc, "24px sans-serif"); //must be CSS
            const s = [Misc stringFromNumber: localLogMAR decimals: 1 localised: YES] + " LogMAR  "
            let stringWidth = 140, lineHeight = 24;
            try {
                const tInfo = cgc.measureText(s);
                stringWidth = tInfo.width;
                //lineHeight = tInfo.emHeightAscent; //+ tInfo.emHeightDescent;
            } catch(e) {}
            CGContextShowTextAtPoint(cgc, viewWidthHalf - stringWidth, -viewHeightHalf + lineHeight, s);
            if (lineRange > 0) {
                CGContextShowTextAtPoint(cgc, viewWidthHalf - stringWidth, -viewHeightHalf + 2 * lineHeight, "(middle line)");
            }
            CGContextShowTextAtPoint(cgc, -viewWidthHalf, -viewHeightHalf + lineHeight, " Use ↑↓, ⇄");
            break;
        default: break;
    }
    
    if ([Settings enableTouchControls] && (!responseButtonsAdded)) {
        const sze = 50, sze2 = sze / 2;
        /*[self buttonCenteredAtX: viewWidth-sze2 y: 0 size: sze title: "6"];
        [self buttonCenteredAtX: sze2 y: 0 size: sze title: "4"];
        [self buttonCenteredAtX: viewWidthHalf y: -viewHeightHalf + sze2 size: sze title: "8"];
        [self buttonCenteredAtX: viewWidthHalf y: viewHeightHalf - sze2 size: sze title: "2"];*/
        [self buttonCenteredAtX: viewWidth - sze2 y: viewHeightHalf - sze2 size: sze title: "Ø"];
    }

    CGContextRestoreGState(cgc);
    CGContextTranslateCTM(cgc, 0, -verticalOffset); //so crowding is also offset
    [super drawStimulusInRect: dirtyRect];
}


- (void) runStart { //console.info("FractControllerAcuityLetters>runStart");
    nAlternatives = 10;
    switch([Settings testOnLineByLine]) {
        case 1: nAlternatives = 10;  break;
        case 2: nAlternatives = 8;  break; //4 Landolt orientations not supported
    }
    nTrials = 9999;
    [gAppController setCurrentTestResultUnit: "LogMAR"];
    [super runStart];
}


- (void) processKeyDownEvent { //console.info("FractControllerAcuityLineByLine>processKeyDownEvent");
    switch (responseKeyChar) {
        case CPLeftArrowFunctionKey:
        case "4":
        case CPRightArrowFunctionKey:
        case "6":
            break; //just reshuffle the optotypes
        case CPUpArrowFunctionKey:
        case "8":
            localLogMAR +=0.1; break;
        case CPDownArrowFunctionKey:
        case "2":
            localLogMAR -=0.1; break;
        case "5":
        default:
            [self runEnd];  return;
    }
    localLogMAR = [Misc limit: localLogMAR lo: -1 hi: 3];
    [self trialStart];
}


@end
