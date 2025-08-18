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
    float logMARdelta1line;
    CPPopUpButton acuityNLinesPopup;
    CPPopUpButton acuityNOptosPopup;
}


- (float) resultValue4Export {return [self acuityResultValue4Export];}
- (CPString) composeExportString {return [self acuityComposeExportString];}


- (id) initWithWindow: (CPWindow) aWindow {
    self = [super initWithWindow: aWindow];
    localLogMAR = 0.3;
    let popupRect = CGRectMake(0, window.innerHeight-24, 106, 24); // first one at bottom
    acuityNOptosPopup = [[CPPopUpButton alloc] initWithFrame: popupRect];
    [acuityNOptosPopup setTitle:"1 optotype"];
    [acuityNOptosPopup addItemWithTitle:"3 optotypes"];
    [acuityNOptosPopup addItemWithTitle:"5 optotypes"];
    [acuityNOptosPopup addItemWithTitle:"7 optotypes"];
    [acuityNOptosPopup bind: CPSelectedIndexBinding toObject:self withKeyPath:@"lineByLineHeadcountIndexSelf" options:nil];
    [acuityNOptosPopup setTarget: self];
    [acuityNOptosPopup setAction: @selector(acuityNLinesPopupChanged:)];

    popupRect = CGRectOffset(popupRect, 0, -24); // next one: one up
    acuityNLinesPopup = [[CPPopUpButton alloc] initWithFrame: popupRect];
    [acuityNLinesPopup setTitle:"1 line"];
    [acuityNLinesPopup addItemWithTitle:"3 lines"];
    [acuityNLinesPopup addItemWithTitle:"5 lines"];
    [acuityNLinesPopup bind: CPSelectedIndexBinding toObject:self withKeyPath:@"lineByLineLinesIndexSelf" options:nil];
    [acuityNLinesPopup setTarget: self];
    [acuityNLinesPopup setAction: @selector(acuityNLinesPopupChanged:)];
    return self;
}


- (float) stimThresholderunitsFromDeviceunits: (float) d {return [self acuityStimThresholderunitsFromDeviceunits: d];}


- (void) trialStart { //console.info("FractControllerAcuityLineByLine>trialStart");
    iTrial = 1;
    stimStrengthInDeviceunits = [MiscSpace strokePixelsFromDecVA: [MiscSpace decVAfromLogMAR: localLogMAR]];
    state = kStateDrawFore;
    [[gAppController.selfWindow contentView] setNeedsDisplay: YES];
}


- (void) drawOneLineShiftedByLines: (int) tLines {
    //first vertical
    //Ferris et al 1982: the space between lines is equal in height to the letters of the next lower line
    const logMARthisLine = localLogMAR + tLines * logMARdelta1line;
    const d0 = [MiscSpace strokePixelsFromlogMAR: logMARthisLine - tLines * logMARdelta1line];
    const d1 = [MiscSpace strokePixelsFromlogMAR: logMARthisLine + (Math.sign(tLines) - tLines) * logMARdelta1line];
    const d2 = [MiscSpace strokePixelsFromlogMAR: logMARthisLine];
    let vOffset = 0;
    switch (tLines) {
        case 2: // 2 above
            vOffset = 7.5 * d0 + 10 * d1 + 2.5 * d2;  break;
        case 1: // 1 above
            vOffset = 7.5 * d0 + 2.5 * d1;  break;
        case -1: // 1 below
            vOffset = -(7.5 * d1 + 2.5 * d0);  break;
        case -2: // 2 below
            vOffset = -(2.5 * d0 + 10 * d1 + 7.5 * d2);  break;
    }
    CGContextSaveGState(cgc);
    CGContextTranslateCTM(cgc, 0, -vOffset);
    //now horizontal
    let optotypeDistance = 1; //according to ETDRS
    if ([Settings lineByLineDistanceType] === 0) { //according to DIN EN ISO 8596
        optotypeDistance = 0.4;
        const localDecVA = [MiscSpace decVAfromLogMAR: localLogMAR];
        if (localDecVA >= 0.06) optotypeDistance = 1;
        if (localDecVA >= 0.16) optotypeDistance = 1.5;
        if (localDecVA >= 0.4) optotypeDistance = 2;
        if (localDecVA >= 1.0) optotypeDistance = 3;
    }
    const locStimStrenInDeviceunits = [MiscSpace strokePixelsFromlogMAR: logMARthisLine];
    optotypeDistance = (1 + optotypeDistance) * locStimStrenInDeviceunits * 5;
    const iRange = [Settings lineByLineHeadcountIndex];
    let usedAlternativesArray = [];
    for (let i = -iRange; i <= iRange; i++) { //index 0…3 → 1, 3, 5, 7
        const tempX = i * optotypeDistance;
        CGContextTranslateCTM(cgc, -tempX, 0);
        let currentAlternative = [Misc iRandom: nAlternatives];
        while (usedAlternativesArray.includes(currentAlternative)) {
            currentAlternative = [Misc iRandom: nAlternatives];
        }
        usedAlternativesArray.push(currentAlternative);
        switch([Settings testOnLineByLineIndex]) {
            case 1: [optotypes drawLetterWithStriokeInPx: locStimStrenInDeviceunits letterNumber: currentAlternative];  break;
            case 2: [optotypes drawLandoltWithStrokeInPx: locStimStrenInDeviceunits landoltDirection: currentAlternative];  break;
            default: console.log("Line-by-line: unsupported optotype-id: ", [Settings testOnLineByLineIndex]);
        }
        CGContextTranslateCTM(cgc, tempX, 0);
    }
    CGContextRestoreGState(cgc);
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerAcuityLineByLine>drawStimulusInRect");
    logMARdelta1line = [Settings isLineByLineChartModeConstantVA] ? 0 : 0.1;
    [self prepareDrawing];
    switch(state) {
        case kStateDrawBack: break;
        case kStateDrawFore:
            const lines = [1, 3, 5][[Settings lineByLineLinesIndex]];
            CGContextSaveGState(cgc);
            if (![Settings isLineByLineChartModeConstantVA]) { //make the block about centered. No, center the center line: no shift
                //CGContextTranslateCTM(cgc, 0, (lines - 1) * 15);
            }
            [self drawOneLineShiftedByLines: 0];
            for (let i = 1; i <= (lines - 1) / 2; i++) {
                [self drawOneLineShiftedByLines: -i]; [self drawOneLineShiftedByLines: i];
            }
            CGContextRestoreGState(cgc);
            CGContextSetFillColor(cgc, [CPColor blueColor]);
            CGContextSetTextDrawingMode(cgc, kCGTextFill);
            CGContextSelectFont(cgc, "24px sans-serif"); //must be CSS
            let stringWidth = 140, lineHeight = 24;
            CGContextShowTextAtPoint(cgc, -viewWidthHalf, -viewHeightHalf + lineHeight, " Use ↑↓, ⇄");
            let s = (lines > 1) ? "middle line: " : "";
            s += [Misc stringFromNumber: localLogMAR decimals: 1 localised: YES] + " LogMAR ";
            try {
                const tInfo = cgc.measureText(s);
                stringWidth = tInfo.width;
                //lineHeight = tInfo.emHeightAscent; //+ tInfo.emHeightDescent;
            } catch(e) {}
            CGContextShowTextAtPoint(cgc, viewWidthHalf - stringWidth, -viewHeightHalf + lineHeight, s);
            break;
        default: break;
    }
    
    if (!responseButtonsAdded) {
        const sze = 50, sze2 = sze / 2;
        [self buttonCenteredAtX: viewWidth - sze2 y: viewHeightHalf - sze2 size: sze title: "Ø"];
        [fractView addSubview: acuityNLinesPopup]; //to directly change number of lines
        [fractView addSubview: acuityNOptosPopup]; //to directly change number of optotypes
    }

    CGContextRestoreGState(cgc);
    //CGContextTranslateCTM(cgc, 0, -verticalOffset); //so crowding is also offset //CROWDING not work???
    [super drawStimulusInRect: dirtyRect];
}
- (int) lineByLineLinesIndexSelf {return [Settings lineByLineLinesIndex];}
- (void) setLineByLineLinesIndexSelf: (int) value {
    [Settings setLineByLineLinesIndex:value];
}
- (int) lineByLineHeadcountIndexSelf {return [Settings lineByLineHeadcountIndex];}
- (void) setLineByLineHeadcountIndexSelf: (int) value {
    [Settings setLineByLineHeadcountIndex:value];
}
- (void)acuityNLinesPopupChanged:(id)sender { // necessary for immediate update
    [[gAppController.selfWindow contentView] setNeedsDisplay: YES];
}


- (void) runStart { //console.info("FractControllerAcuityLetters>runStart");
    nAlternatives = 10;
    switch([Settings testOnLineByLineIndex]) {
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
    //limit the acuity range to sensible pixel values
    let stroke = [MiscSpace strokePixelsFromlogMAR: localLogMAR];
    //stroke = [Misc limit: stroke lo: gStrokeMinimal hi: gStrokeMaximal / 3 / [Settings lineByLineHeadcountIndex]];
    stroke = [Misc limit: stroke lo: gStrokeMinimal hi: gStrokeMaximal];
    localLogMAR = [MiscSpace logMARFromStrokePixels: stroke];
    [self trialStart];
}


@end
