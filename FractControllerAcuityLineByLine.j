/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, michael.bach@uni-freiburg.de, <https://michaelbach.de>

FractControllerAcuityLineByLine.j

This module draws a 5-optotype line for aid in refraction.
It's task does not really fit the testing via trial/run, but whatever
Created by mb on 2021-12-21.
*/


@import "FractControllerAcuity.j"
@implementation FractControllerAcuityLineByLine: FractControllerAcuity {
    float localLogMAR;
}


- (float) resultValue4Export {return [self acuityResultValue4Export];}
- (CPString) composeExportString {return [self acuityComposeExportString];}


- (id) initWithWindow: (CPWindow) aWindow parent: (HierarchyController) parent {
    localLogMAR = 0.3; // we need this method only for this line, starting acuity
    self = [super initWithWindow: aWindow parent: parent];
    return self;
}


- (float) stimThresholderunitsFromDeviceunits: (float) d {return [self acuityStimThresholderunitsFromDeviceunits: d];}


- (void) trialStart { //console.info("FractControllerAcuityLineByLine>trialStart");
    iTrial = 1;
    stimStrengthInDeviceunits = [Misc gapPixelsFromDecVA: [Misc decVAfromLogMAR: localLogMAR]];
    state = kStateDrawFore;
    [[[self window] contentView] setNeedsDisplay: YES];
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerAcuityLetters>drawStimulusInRect");
    [self prepareDrawing];
    switch(state) {
        case kStateDrawBack: break;
        case kStateDrawFore:
            var usedAlternativesArray = [];
            for (var i = -2; i <= 2; i++) {
                var tempX = i * stimStrengthInDeviceunits * 10;
                CGContextTranslateCTM(cgc,  -tempX, 0);
                var currentAlternative = [Misc iRandom: nAlternatives];
                while (usedAlternativesArray.includes(currentAlternative)) {
                    currentAlternative = [Misc iRandom: nAlternatives];
                }
                usedAlternativesArray.push(currentAlternative);
                [optotypes drawLetterWithGapInPx: stimStrengthInDeviceunits letterNumber: currentAlternative];
                CGContextTranslateCTM(cgc,  +tempX, 0);
            }

            CGContextSetFillColor(cgc, [CPColor blueColor]);
            CGContextSetTextDrawingMode(cgc, kCGTextFill);
            CGContextSelectFont(cgc, "24px sans-serif"); // must be CSS
            var s = [Misc stringFromNumber: localLogMAR decimals: 1 localised: YES] + " LogMAR "
            var stringWidth = 140, lineHeight = 24;
            try {
                var tInfo = cgc.measureText(s);
                stringWidth = tInfo.width;
                //lineHeight = tInfo.emHeightAscent;// + tInfo.emHeightDescent;
            } catch(e) {}
            CGContextShowTextAtPoint(cgc, viewWidth2 - stringWidth, -viewHeight2 + lineHeight, s);
            CGContextShowTextAtPoint(cgc, -viewWidth2, -viewHeight2 + lineHeight, " This is experimental. Use ↑↓, ⇄");
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
    //[super drawStimulusInRect: dirtyRect];
}


- (void) runStart { //console.info("FractControllerAcuityLetters>runStart");
    nAlternatives = 10;  nTrials = 9999;
    [self setCurrentTestName: "Acuity_LineByLine"];
    [self setCurrentTestResultUnit: "LogMAR"];
    [super runStart];
}


- (void) processKeyDownEvent { //console.info("FractControllerAcuityLineByLine>processKeyDownEvent");
    switch (responseKeyChar) {
        case CPLeftArrowFunctionKey:
        case "4":
        case CPRightArrowFunctionKey:
        case "6":
            break; // just reshuffle the optotypes
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
