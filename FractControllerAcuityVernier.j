/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, michael.bach@uni-freiburg.de, <https://michaelbach.de>

FractControllerAcuityVernier.j

Created by Bach on 14.08.2017.
*/


@import "FractControllerAcuity.j"
@implementation FractControllerAcuityVernier: FractControllerAcuity {
    float gapVernierMinimalArcSec, gapVernierMaximalArcSec;
}


- (void) modifyThresholderStimulus {[self modifyThresholderStimulusWithBonus];}
- (void) modifyDeviceStimulus {}
- (CPString) composeExportString {return [self acuityComposeExportString];}


- (float) stimDeviceunitsFromThresholderunits: (float) tPest { //console.info("FractControllerAcuityVernier>stimDeviceunitsFromThresholderunits");
    gapMinimal = [Misc pixelFromDegree: gapVernierMinimalArcSec / 60.0 / 60.0];
    gapMaximal = [Misc pixelFromDegree: gapVernierMaximalArcSec / 60.0 / 60.0];
    var c1 = gapMinimal;
    var c2 = -Math.log(gapMinimal / gapMaximal);
    var deviceVal = c1 * Math.exp(tPest * c2); //trace("Vernier.pest2native, tPest:", tPest, "native=", nativeVal);
    if ([Misc areNearlyEqual: deviceVal and: gapMaximal]) {
        if (!isBonusTrial) {
            rangeLimitStatus = kRangeLimitValueAtCeiling; //console.info("max gap size!")
        }
    } else {
        if  ([Misc areNearlyEqual: deviceVal and: gapMinimal]) {
            rangeLimitStatus = kRangeLimitValueAtFloor; //console.info("min gap size!");
        } else {
            rangeLimitStatus = kRangeLimitOk;
        }
    }
    return deviceVal;
}
- (float) stimThresholderunitsFromDeviceunits: (float) d {
    gapMinimal = [Misc pixelFromDegree: gapVernierMinimalArcSec / 60.0 / 60.0];
    gapMaximal = [Misc pixelFromDegree: gapVernierMaximalArcSec / 60.0 / 60.0];
    var c1 = gapMinimal;
    var c2 = -Math.log(gapMinimal / gapMaximal);
    var retVal = Math.log(d / c1) / c2;
    return retVal;
}


//Draw a vertical line with gaussian profile. x-position (floating point) approximated by center of gravity on discrete raster
- (void) drawLineGaussProfileVerticalAtX: (float) x0 y0: (float) y0 y1: (float) y1 sigma: (float) sigma { //console.info("FractControllerAcuityVernier>>DrawLineGaussianProfileVertical ", x0, y0, y1);
    var ix0 = Math.round(x0);
    var iSigma = Math.round(Math.max(5, Math.min(sigma * 4, 30))); //trace(sigma, iSigma);
    CGContextSetLineWidth(cgc, 1);
    var backGray = [Misc upperLuminanceFromContrastMilsn: [Misc contrastMichelsonFromWeberPercent: [Settings contrastAcuityWeber]]];
    var cnt = [Settings contrastAcuityWeber] / 100;
    var grayValue, gaussValue;
    for (var ix = ix0 - iSigma; ix <= ix0 + iSigma; ix++) {
        gaussValue = Math.exp(-Math.pow(x0 - ix, 2) / sigma);
        grayValue = backGray - cnt * gaussValue;
        grayValue = [Misc devicegrayFromLuminance: grayValue];
        CGContextSetStrokeColor(cgc, [CPColor colorWithWhite: grayValue alpha: 1]);
        CGContextBeginPath(cgc);
        CGContextMoveToPoint(cgc, ix, y0);
        CGContextAddLineToPoint(cgc, ix, y1);
        CGContextStrokePath(cgc);
    }
}


- (void) drawVernierAtX: (float) xCent y: (float) yCent vLength: (float) vLength sigma: (float) sigma gapHeight: (float) gapHeight offsetSize: (float) offsetSize offsetIsTopRight: (BOOL) offsetIsTopRight { //console.info("FractControllerAcuityVernier>drawVernierAtX", offsetSize);
    xCent += (Math.random() < 0.5 ? 1 : -1) + 2 * (2 * Math.random() - 1.0);
    var theSign = offsetIsTopRight ? +1 : -1;
    var xPos0 = xCent + theSign * offsetSize / 2.0, xPos1 = xCent - theSign * offsetSize / 2.0;
    var vLength2 = vLength / 2.0;
    switch([Settings vernierType]) {
        case 1: // 3 bars
            // lower
            var yTemp = yCent + vLength2 + gapHeight;
            [self drawLineGaussProfileVerticalAtX: xPos0 y0: yTemp y1: yTemp + vLength sigma: sigma];
            // middle
            [self drawLineGaussProfileVerticalAtX: xPos1 y0: yCent - vLength2 y1: yCent + vLength2 sigma: sigma];
            // upper
            yTemp = yCent - vLength / 2 - gapHeight;
            [self drawLineGaussProfileVerticalAtX: xPos0 y0: yTemp y1: yTemp - vLength sigma: sigma];
            break;
        default: // case 0, 2 bars
            var gapHeight2 = gapHeight / 2.0;
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
                          vLength: [Misc pixelFromDegree: [Settings vernierLength] / 60.0]
                            sigma: [Misc pixelFromDegree: [Settings vernierWidth] / 60.0]
                        gapHeight: [Misc pixelFromDegree: [Settings vernierGap] / 60.0]
                       offsetSize: stimStrengthInDeviceunits
                 offsetIsTopRight: [alternativesGenerator currentAlternative] != 0]
            break;
        default: break;
    }
    if ([Settings enableTouchControls] && (!responseButtonsAdded)) {
        var sze = 50, sze2 = sze / 2;
        [self buttonCenteredAtX: viewWidth-sze2 y: 0 size: sze title: "6"];
        [self buttonCenteredAtX: sze2 y: 0 size: sze title: "4"];
        [self buttonCenteredAtX: viewWidth - sze2 y: viewHeight / 2 - sze2 size: sze title: "Ø"];
    }
    CGContextRestoreGState(cgc);
    [super drawStimulusInRect: dirtyRect];
}


- (void) runStart { //console.info("FractControllerAcuityVernier>runStart");
    [self setCurrentTestResultUnit: "arcsec"];
    nAlternatives = 2;  nTrials = [Settings nTrials02];
    gapVernierMinimalArcSec = 0.5;  gapVernierMaximalArcSec = 3000.0;
    [super runStart];
}


- (void) runEnd { //console.info("FractControllerAcuityVernier>runEnd");
    if (iTrial < nTrials) { //premature end
        [self setResultString: @"Aborted"];
    } else {
        [self setResultString: [self composeResultString]];
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
    var rslt = [self resultValue4Export];
    var dcs = rslt > 100 ? 0 : 1;
    var s = "Vernier threshold" + [self rangeStatusIndicatorStringInverted: NO];
    s += [Misc stringFromNumber: rslt decimals: dcs localised: YES] + " arcsec";
    return s;
}


- (floag) reportFromNative: (float) t {
    return ([Misc degreeFromPixel: t] * 60.0 * 60.0);
}


@end
