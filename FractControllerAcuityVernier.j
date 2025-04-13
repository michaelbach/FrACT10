/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

FractControllerAcuityVernier.j

Created by Bach on 14.08.2017.
*/


@import "FractControllerAcuity.j"
@implementation FractControllerAcuityVernier: FractControllerAcuity {
    float offsetVernierMinimalArcSec, offsetVernierMaximalArcSec;
}


- (void) modifyThresholderStimulus {[self modifyThresholderStimulusWithBonus];}
- (void) modifyDeviceStimulus {}
- (CPString) composeExportString {return [self acuityComposeExportString];}


- (float) stimDeviceunitsFromThresholderunits: (float) tPest { //console.info("FractControllerAcuityVernier>stimDeviceunitsFromThresholderunits");
    gStrokeMinimal = [MiscSpace pixelFromDegree: offsetVernierMinimalArcSec / 60.0 / 60.0];
    gStrokeMaximal = [MiscSpace pixelFromDegree: offsetVernierMaximalArcSec / 60.0 / 60.0];
    const c1 = gStrokeMinimal;
    const c2 = -Math.log(gStrokeMinimal / gStrokeMaximal);
    const deviceVal = c1 * Math.exp(tPest * c2); //trace("Vernier.pest2native, tPest:", tPest, "native=", nativeVal);
    if ([Misc areNearlyEqual: deviceVal and: gStrokeMaximal]) {
        if (!isBonusTrial) {
            rangeLimitStatus = kRangeLimitValueAtCeiling; //console.info("max shift size!")
        }
    } else {
        if  ([Misc areNearlyEqual: deviceVal and: gStrokeMinimal]) {
            rangeLimitStatus = kRangeLimitValueAtFloor; //console.info("min shift size!");
        } else {
            rangeLimitStatus = kRangeLimitOk;
        }
    }
    return deviceVal;
}
- (float) stimThresholderunitsFromDeviceunits: (float) d {
    gStrokeMinimal = [MiscSpace pixelFromDegree: offsetVernierMinimalArcSec / 60.0 / 60.0];
    gStrokeMaximal = [MiscSpace pixelFromDegree: offsetVernierMaximalArcSec / 60.0 / 60.0];
    const c1 = gStrokeMinimal;
    const c2 = -Math.log(gStrokeMinimal / gStrokeMaximal);
    const retVal = Math.log(d / c1) / c2;
    return retVal;
}


//Draw a vertical line with gaussian profile. x-position (floating point) approximated by center of gravity on discrete raster
- (void) drawLineGaussProfileVerticalAtX: (float) x0 y0: (float) y0 y1: (float) y1 sigma: (float) sigma { //console.info("FractControllerAcuityVernier>>DrawLineGaussianProfileVertical ", x0, y0, y1);
    const ix0 = Math.round(x0);
    const iSigma = Math.round(Math.max(5, Math.min(sigma * 4, 30))); //trace(sigma, iSigma);
    CGContextSetLineWidth(cgc, 1);
    const backGray = [MiscLight upperLuminanceFromContrastMilsn: [MiscLight contrastMichelsonPercentFromWeberPercent: [Settings contrastAcuityWeber]]];
    const cnt = [Settings contrastAcuityWeber] / 100;
    for (let ix = ix0 - iSigma; ix <= ix0 + iSigma; ix++) {
        const gaussValue = Math.exp(-Math.pow(x0 - ix, 2) / sigma);
        const grayValue = [MiscLight devicegrayFromLuminance: backGray - cnt * gaussValue];
        CGContextSetStrokeColor(cgc, [CPColor colorWithWhite: grayValue alpha: 1]);
        CGContextBeginPath(cgc);
        CGContextMoveToPoint(cgc, ix, y0);
        CGContextAddLineToPoint(cgc, ix, y1);
        CGContextStrokePath(cgc);
    }
}


- (void) drawVernierAtX: (float) xCent y: (float) yCent vLength: (float) vLength sigma: (float) sigma gapHeight: (float) gapHeight offsetSize: (float) offsetSize offsetIsTopRight: (BOOL) offsetIsTopRight { //console.info("FractControllerAcuityVernier>drawVernierAtX", offsetSize);
    xCent += (Math.random() < 0.5 ? 1 : -1) + 2 * (2 * Math.random() - 1);
    const theSign = offsetIsTopRight ? +1 : -1;
    const xPos0 = xCent + theSign * offsetSize / 2, xPos1 = xCent - theSign * offsetSize / 2;
    const vLength2 = vLength / 2;
    switch([Settings vernierType]) {
        case 1: // 3 bars
            // lower
            let yTemp = yCent + vLength2 + gapHeight;
            [self drawLineGaussProfileVerticalAtX: xPos0 y0: yTemp y1: yTemp + vLength sigma: sigma];
            // middle
            [self drawLineGaussProfileVerticalAtX: xPos1 y0: yCent - vLength2 y1: yCent + vLength2 sigma: sigma];
            // upper
            yTemp = yCent - vLength2 - gapHeight;
            [self drawLineGaussProfileVerticalAtX: xPos0 y0: yTemp y1: yTemp - vLength sigma: sigma];
            break;
        default: // case 0, 2 bars
            const gapHeight2 = gapHeight / 2;
            // lower
            [self drawLineGaussProfileVerticalAtX: xPos0 y0: yCent + gapHeight2 y1: yCent + gapHeight2 + vLength sigma: sigma];
            // upper
            [self drawLineGaussProfileVerticalAtX: xPos1 y0: yCent - gapHeight2 y1: yCent - gapHeight2 - vLength sigma: sigma];
            break;
    }
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerAcuityVernier>drawStimulusInRect");
    trialInfoString = [self acuityComposeTrialInfoString];
    [self prepareDrawing];
    switch(state) {
        case kStateDrawBack:  break;
        case kStateDrawFore: //console.info("kStateDrawFore");
            [self  drawVernierAtX: 0 y: 0
                          vLength: [MiscSpace pixelFromDegree: [Settings vernierLength] / 60.0]
                            sigma: [MiscSpace pixelFromDegree: [Settings vernierWidth] / 60.0]
                        gapHeight: [MiscSpace pixelFromDegree: [Settings vernierGap] / 60.0]
                       offsetSize: stimStrengthInDeviceunits
                 offsetIsTopRight: [alternativesGenerator currentAlternative] != 0]
            break;
        default: break;
    }
    if ([Settings enableTouchControls] && (!responseButtonsAdded)) {
        const sze = 50, sze2 = sze / 2;
        [self buttonCenteredAtX: viewWidth-sze2 y: 0 size: sze title: "6"];
        [self buttonCenteredAtX: sze2 y: 0 size: sze title: "4"];
        [self buttonCenteredAtX: viewWidth - sze2 y: viewHeight2 - sze2 size: sze title: "Ø"];
    }
    CGContextRestoreGState(cgc);
    [super drawStimulusInRect: dirtyRect];
}


- (void) runStart { //console.info("FractControllerAcuityVernier>runStart");
    [gAppController setCurrentTestResultUnit: "arcsec"];
    nAlternatives = 2;  nTrials = [Settings nTrials02];
    offsetVernierMinimalArcSec = 0.5;  offsetVernierMaximalArcSec = 3000.0;
    [super runStart];
}


- (void) runEnd { //console.info("FractControllerAcuityVernier>runEnd");
    if (iTrial < nTrials) { //premature end
        [gAppController setResultString: @"Aborted"];
    } else {
        [gAppController setResultString: [self composeResultString]];
    }
    [super runEnd];
}


- (int) responseNumberFromChar: (CPString) keyChar { //console.info("FractControllerAcuityVernier>responseNumberFromChar: ", keyChar);
    switch (keyChar) {
        case CPLeftArrowFunctionKey: return 4;
        case CPRightArrowFunctionKey: return 0;
        case "6": return 0;
        case "4": return 4;
    }
    return -2;// 0, 4: valid; -1: ignore; -2: invalid
}


- (float) resultValue4Export {
    return Math.round([self reportFromNative: stimStrengthInDeviceunits] * 10) / 10;
}


- (CPString) composeResultString {
    const rslt = [self resultValue4Export];
    const dcs = rslt > 100 ? 0 : 1;
    let s = "Vernier threshold" + [self rangeStatusIndicatorStringInverted: YES];
    s += [Misc stringFromNumber: rslt decimals: dcs localised: YES] + " arcsec";
    return s;
}


- (float) reportFromNative: (float) t {
    return ([MiscSpace degreeFromPixel: t] * 60.0 * 60.0);
}


@end
