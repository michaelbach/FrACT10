/*
 *  FractControllerVAVernier.j
 *  cappDevelop
 *
 *  Created by Bach on 14.08.2017.
 *  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
 */

@import "FractController.j"


@implementation FractControllerVAVernier: FractController {
    float gapVernierMinimalArcSec, gapVernierMaximalArcSec;
}


- (void) modifyGenericStimulus {[self modifyGenericStimulusWithBonus];}
- (void) modifyDeviceStimulus {}


- (float) stimDeviceFromGeneric: (float) tPest {
    gapMinimal = [Misc pixelFromDegree: gapVernierMinimalArcSec / 60.0 / 60.0];
    gapMaximal = [Misc pixelFromDegree: gapVernierMaximalArcSec / 60.0 / 60.0];
    var c1 = gapMinimal;
    var c2 = -Math.log(gapMinimal / gapMaximal);
    var nativeVal = c1 * Math.exp(tPest * c2); //trace("Vernier.pest2native, tPest:", tPest, "native=", nativeVal);
    return nativeVal;
}
- (float) stimGenericFromDevice: (float) d {
    gapMinimal = [Misc pixelFromDegree: gapVernierMinimalArcSec / 60.0 / 60.0];
    gapMaximal = [Misc pixelFromDegree: gapVernierMaximalArcSec / 60.0 / 60.0];
    var c1 = gapMinimal;
    var c2 = -Math.log(gapMinimal / gapMaximal);
    var retVal =Math.log(d / c1) / c2;//retVal /= Prefs.vernierScale.n;
    return retVal;
}


//Draw vertical line with gaussian profile. x-position (floating point) approximated by center of gravity on discrete raster
- (void) drawLineGaussProfileVerticalAtX: (float) x0 y0: (float) y0 y1: (float) y1 sigma: (float) sigma { //console.log("FractControllerVAVernier>>DrawLineGaussianProfileVertical ", x0, y0, y1);
    var ix0 = Math.round(x0);
    var iSigma = Math.round(Math.max(5, Math.min(sigma * 4, 30))); //trace(sigma, iSigma);
    CGContextSetLineWidth(cgc, 1);
    for (var ix = ix0 - iSigma; ix <= ix0 + iSigma; ix++) {
        var gaussValue = Math.exp(-Math.pow(x0 - ix, 2) / sigma);
        var gValue = 0.5 + [Settings contrastAcuity] * (0.5 - gaussValue);
        gValue = [Misc luminance2deviceGrey: gValue];
        CGContextSetStrokeColor(cgc, [CPColor colorWithWhite: gValue alpha: 1]);
        [self strokeVLineAtX: ix y0: y0 y1: y1];
    }
}


- (void) drawVernierAtX: (float) xCenter y: (float) yCenter vLength: (float) vLength sigma: (float) sigma gapHeight: (float) gapHeight offsetSize: (float) offsetSize offsetIsTopRight: (BOOL) offsetIsTopRight { //console.log("FractControllerVAVernier>drawVernierAtX", offsetSize);
    xCenter += (Math.random() < 0.5 ? 1 : -1) + 2 * (2 * Math.random() - 1.0);
    var theSign = offsetIsTopRight ? +1 : -1;
    var xPos0 = xCenter + theSign * offsetSize / 2.0;
    var xPos1 = xCenter - theSign * offsetSize / 2.0;
    var vLength2 = vLength / 2.0;
    switch([Settings vernierType]) {
        case 1: // 3 bars
            // untere
            var yTemp = yCenter + vLength2 + gapHeight;
            [self drawLineGaussProfileVerticalAtX: xPos0 y0: yTemp y1: yTemp + vLength sigma: sigma];
            // mittlere
            [self drawLineGaussProfileVerticalAtX: xPos1 y0: yCenter - vLength2 y1: yCenter + vLength2 sigma: sigma];
            // ganz oben
            yTemp = yCenter - vLength / 2 - gapHeight;
            [self drawLineGaussProfileVerticalAtX: xPos0 y0: yTemp y1: yTemp - vLength sigma: sigma];
            break;
        default: // case 0, 2 bars
            var gapHeight2 = gapHeight / 2.0;
            // untere
            [self drawLineGaussProfileVerticalAtX: xPos0 y0: yCenter + gapHeight2 y1: yCenter + gapHeight2 + vLength sigma: sigma];
            // obere
            [self drawLineGaussProfileVerticalAtX: xPos1 y0: yCenter - gapHeight2 y1: yCenter - gapHeight2 - vLength sigma: sigma];
            break;
    }
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.log("FractControllerVAVernier>drawStimulusInRect");
    trialInfoString = [self acuityComposeTrialInfoString];
    cgc = [[CPGraphicsContext currentContext] graphicsPort];
    CGContextSetFillColor(cgc, colOptotypeBack);
    CGContextFillRect(cgc, [[self window] frame]);
    CGContextSaveGState(cgc);
    switch(state) {
        case kStateDrawBack:  break;
        case kStateDrawFore: //console.log("kStateDrawFore");
            CGContextTranslateCTM(cgc,  viewWidth / 2, viewHeight / 2); // origin to center
            [self  drawVernierAtX: [Misc pixelFromDegree: [Settings eccentXInDeg]]
                                y: [Misc pixelFromDegree: [Settings eccentYInDeg]]
                          vLength: [Misc pixelFromDegree: [Settings vernierLength] / 60.0]
                            sigma: [Misc pixelFromDegree: [Settings vernierWidth] / 60.0]
                        gapHeight: [Misc pixelFromDegree: [Settings vernierGap] / 60.0]
                       offsetSize: stimStrengthInDeviceunits
                 offsetIsTopRight: [alternativesGenerator currentAlternative] != 0]
            break;
        default: break;
    }
    CGContextRestoreGState(cgc);
    CGContextSetTextPosition(cgc, 10, 10);
    CGContextSetFillColor(cgc, colOptotypeFore);
    CGContextShowText(cgc, trialInfoString);
}


- (void) runStart { //console.log("FractControllerVAVernier>runStart");
    [self setCurrentTestName: "Acuity_Vernier"];
    [self setCurrentTestResultUnit: "arcsec"];
    nAlternatives = 2;  nTrials = [Settings nTrials04];
    gapVernierMinimalArcSec = 0.5;  gapVernierMaximalArcSec = 3000.0;
    [super runStart];
}


- (void) runEnd { //console.log("FractControllerVAVernier>runEnd");
    if (iTrial < nTrials) { //premature end
        [self setResultString: @"Aborted"];
    } else {
        [self setResultString: [self composeResults]];
    }
    [super runEnd];
}


- (int) responseNumberFromChar: (CPString) keyChar { //console.log("FractControllerVAVernier>responseNumberFromChar: ", keyChar);
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

- (CPString) composeResults {
    var rslt = [self resultValue4Export];
    var dcs = rslt > 100 ? 0 : 1;
    return "Vernier threshold: " +  [Misc stringFromNumber: rslt decimals: dcs localised: YES] + " arcsec";
}


- (floag) reportFromNative: (float) t {
    return ([Misc degreeFromPixel: t] * 60.0 * 60.0);
}

@end
