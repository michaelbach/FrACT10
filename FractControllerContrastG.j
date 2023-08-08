/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>
 
 FractControllerContrastG.j: Gratings
 
 Created by Bach on 2020-09-02
 */


@import "FractControllerContrast.j"
@implementation FractControllerContrastG: FractControllerContrast {
    float contrastMichelsonPercent, periodInPixel, spatialFreqCPD;
}


- (float) freqFromThresholderunits: (float) thresholderunit {
    thresholderunit = 1 - thresholderunit; // 0: strong stimulus=low spatFreq
    const logFreqMin = Math.log10([Settings gratingCPDmin]);
    const logFreqMax = Math.log10([Settings gratingCPDmax]);
    const logFreq = logFreqMin + thresholderunit *(logFreqMax - logFreqMin);
    return Math.pow(10, logFreq);
}


- (void) maskWithColor: (CPColor) col {
    const r = 0.5 * [MiscSpace pixelFromDegree: [Settings gratingDiaInDeg]];
    const w = r / 20;
    let radii = [r - 2 * w, r - w, r, r + w, r + 2 * w, r + 400];
    let widths = [w, w, w, w, w, 780];
    let alphas = [0.125, 0.25, 0.5, 0.75, 0.875, 1];
    for (let i=0; i < 6; i++) {
        CGContextSetLineWidth(cgc, widths[i] + 0.1);
        CGContextSetStrokeColor(cgc, [col colorWithAlphaComponent: alphas[i]]);
        const r = radii[i];
        CGContextStrokeEllipseInRect(cgc, CGRectMake(0 - r, 0 - r, 2 * r, 2 * r));
    }
}


- (void) gratingSineWithPeriodInPx: (float) periodInPx direction: (int) theDirection contrast: (float) contrast {
    const s2 = 0.6 * [MiscSpace pixelFromDegree: [Settings gratingDiaInDeg]];
    const trigFactor = 1.0 / periodInPx * 2 * Math.PI; // calculate only once
    CGContextRotateCTM(cgc, -theDirection * 22.5 * Math.PI / 180);
    CGContextSetLineWidth(cgc, 1.3);
    let l, lError = 0, lDiscrete;
    for (let ix = -s2; ix <= s2; ++ix) {
        l = 0.5 + 0.5 * contrast / 100 * Math.sin((ix % periodInPx) * trigFactor);
        l = [MiscLight devicegrayFromLuminance: l]; // apply gamma correction
        lDiscrete = l;
        if ([Settings gratingUseErrorDiffusion]) {
            l = lError + 255 * l; // map to 0…255 and apply previous residual
            lDiscrete = Math.round(l); // discrete integer values 0…255
            lError = l - lDiscrete; // keep residual (what was lost by rounding) for next time
            lDiscrete = lDiscrete / 255; // remap to 0…1
        }
        CGContextSetStrokeColor(cgc, [CPColor colorWithWhite: lDiscrete alpha: 1]);
        [optotypes strokeVLineAtX: ix y0: -s2 y1: s2];
    }
    [self maskWithColor: [CPColor colorWithWhite: [MiscLight devicegrayFromLuminance: 0.5] alpha: 1]];
}


- (void) gratingSineColorWithPeriodInPx: (float) periodInPx direction: (int) theDirection contrast: (float) contrast {
    const s2 = 0.6 * [MiscSpace pixelFromDegree: [Settings gratingDiaInDeg]];
    const trigFactor = 1.0 / periodInPx * 2 * Math.PI; // calculate only once
    CGContextRotateCTM(cgc, -theDirection * 22.5 * Math.PI / 180);
    CGContextSetLineWidth(cgc, 1.35); // still an artifact on oblique
    for (let ix = -s2; ix <= s2; ++ix) {
        const a = 0.5 + 0.5 * contrast / 100 * Math.sin((ix % periodInPx) * trigFactor);
        CGContextSetStrokeColor(cgc, [colOptotypeFore colorWithAlphaComponent: a]);
        [optotypes strokeVLineAtX: ix y0: -s2 y1: s2];
    }
    [self maskWithColor: colOptotypeBack];
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView {
    //console.info(stimStrengthInThresholderUnits)
    [self calculateForeBackColors];
    if ([Settings isGratingColor]) {
        colOptotypeFore = [Settings gratingForeColor];
        colOptotypeBack = [Settings gratingBackColor];
    }
    [self prepareDrawing];
    switch(state) {
        case kStateDrawBack: break;
        case kStateDrawFore:
            [self drawFixMark];
            break;
        case kStateDrawFore2:
            if ([self isContrastG]) {
                contrastMichelsonPercent = [MiscLight contrastMichelsonPercentFromLogCSWeber: stimStrengthInDeviceunits];
                spatialFreqCPD = [Settings gratingCPD];
            } else { // acuity_grating
                contrastMichelsonPercent = [Settings gratingContrastMichelsonPercent];
                spatialFreqCPD = [self freqFromThresholderunits: stimStrengthInThresholderUnits];
            }
            periodInPixel = Math.max([MiscSpace periodInPixelFromSpatialFrequency: spatialFreqCPD], 2);
            let dir = [alternativesGenerator currentAlternative];
            //if ([Settings obliqueOnly]) dir += 2;
            if ([Settings isGratingColor]) {
                CGContextSetFillColor(cgc, colOptotypeBack);
                CGContextFillRect(cgc, [[self window] frame]);
                [self gratingSineColorWithPeriodInPx: periodInPixel direction: dir contrast: contrastMichelsonPercent];
            } else {
                [self gratingSineWithPeriodInPx: periodInPixel direction: dir contrast: contrastMichelsonPercent];
            }
            [self drawFixMark3];
            trialInfoString = [self contrastComposeTrialInfoString];// compose here after colors are set
            break;
        default: break;
    }
    
    [self embedInNoise];
    [self drawTouchControls];
    CGContextRestoreGState(cgc);
    [super drawStimulusInRect: dirtyRect];
    if ([self isContrastG]) {
        [trialHistoryController setValue: contrastMichelsonPercent];
    } else { // acuity_grating
        [trialHistoryController setValue: spatialFreqCPD];
    }    
}


- (void) runStart { //console.info("FractControllerContrastLett>runStart");
    nAlternatives = Math.min([Settings nAlternatives], 4);
    nTrials = nAlternatives == 4 ? [Settings nTrials04] : [Settings nTrials02];
    [super runStart];
    [self setCurrentTestResultUnit: "MichelsonPercent"];
}


- (int) responseNumberFromChar: (CPString) keyChar { //console.info("FractControllerContrastE>responseNumberFromChar: ", keyChar);
    switch (keyChar) {
        case CPLeftArrowFunctionKey: return 4; // ⬅️
        case CPRightArrowFunctionKey: return 4; // ➡️
        case CPUpArrowFunctionKey: return 0; // ⬆️
        case CPDownArrowFunctionKey: return 0; // ⬇️
        case "1": return 6; // ↙️
        case "2": return 0; // ⬇️
        case "3": return 2; // ↘️
        case "4": return 4; // ⬅️
        case "5": return -1;
        case "6": return 4; // ➡️
        case "7": return 2; // ↖️
        case "8": return 0; // ⬆️
        case "9": return 6; // ↗️
    }
    return -2;// 0, 2, 4, 6: valid; -1: ignore; -2: invalid
}


- (CPString) contrastComposeTrialInfoString {
    let s = "trial: " + iTrial + "/" + nTrials;
    s +=  ", contrast: " + [Misc stringFromNumber: contrastMichelsonPercent decimals: 1 localised: YES] + "%";
    s += ", frequency: " + [Misc stringFromNumber: spatialFreqCPD decimals: 1 localised: YES];
    s += ", alternative: " + [alternativesGenerator currentAlternative];
    return s;
}


- (CPString) contrastComposeResultString {
    rangeLimitStatus = kRangeLimitOk;
    // taking into account the result of final trial
    stimStrengthInDeviceunits = [self stimDeviceunitsFromThresholderunits: [thresholder nextStim2apply]];
    if ([self isContrastG]) {
        contrastMichelsonPercent = [MiscLight contrastMichelsonPercentFromLogCSWeber: stimStrengthInDeviceunits];
        spatialFreqCPD = [Settings gratingCPD];
    } else { // acuity_grating
        contrastMichelsonPercent = [Settings gratingContrastMichelsonPercent];
    }
/* needs work for frequency sweep
    if (contrastMichelsonPercent < 100 / 512) // 2 × 256
        rangeLimitStatus = kRangeLimitValueAtFloor;
    if (contrastMichelsonPercent >= 100)
        rangeLimitStatus = kRangeLimitValueAtCeiling; */
    let s = "Grating contrast: ";
    s += [self rangeStatusIndicatorStringInverted: YES];
    s += [Misc stringFromNumber: contrastMichelsonPercent decimals: 2 localised: YES];
    s += "%, spatial frequency: ";
    s += [Misc stringFromNumber: spatialFreqCPD decimals: 1 localised: YES];
    s += " cpd";
    return s;
}


- (CPString) contrastComposeExportString {
    if ([[self parentController] runAborted]) return "";
    let s = [self generalComposeExportString];
    s += tab + "value" + tab + [Misc stringFromNumber: contrastMichelsonPercent decimals: 3 localised: YES];
    s += tab + "unit1" + tab + currentTestResultUnit
    s += tab + "distanceInCm" + tab + [Misc stringFromNumber: [Settings distanceInCM] decimals: 2 localised: YES];
    s += tab + "spatFreq" + tab + [Misc stringFromNumber: spatialFreqCPD decimals: 1 localised: YES];
    s += tab + "unit2" + tab + "cpd";
    s += tab + "nTrials" + tab + [Misc stringFromNumber: nTrials decimals: 0 localised: YES];
    s += tab + "rangeLimitStatus" + tab + rangeLimitStatus;
    s += tab + "crowding" + tab + 0; // does not apply, but let's not NaN this
    return s;
}

@end
