/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2021 Michael Bach, michael.bach@uni-freiburg.de, <https://michaelbach.de>
 
 FractControllerContrastG.j: Gratings
 
 Created by Bach on 2020-09-02
 */


@import "FractControllerContrast.j"
@implementation FractControllerContrastG: FractControllerContrast {
    float contrastMichelson;
}


- (float) gratingContrastMichelsonFromDeviceunits: (float) deviceUnits {
    return [MiscLight contrastMichelsonFromWeberPercent: [MiscLight contrastWeberPercentFromLogCSWeber: deviceUnits]] / 100;
}

- (void) annulusWithRadius: (float) r width: (float) w grey: (float) g alpha: (float) a {
    CGContextSetLineWidth(cgc, w + 0.1);
    CGContextSetStrokeColor(cgc, [CPColor colorWithWhite: g alpha: a]);
    CGContextStrokeEllipseInRect(cgc, CGRectMake(0 - r, 0 - r, 2 * r, 2 * r));
}
- (void) gratingSineWithPeriodInPx: (float) periodInPx direction: (int) theDirection {
    //console.info("optotypes>gratingSineWithPeriodInPx: ", periodInPx, theDirection);
    const l2 = 2 * Math.round(0.5 * 1.42 * Math.max(viewWidth2, viewHeight2));
    const trigFactor = 1.0 / periodInPx * 2 * Math.PI; // calculate only once
    CGContextRotateCTM(cgc, -theDirection * 22.5 * Math.PI / 180); // rotato to desired angle
    CGContextSetLineWidth(cgc, 1.3);
    let l, lError = 0;
    for (let ix = -l2; ix <= l2; ++ix) {
        l = 0.5 + 0.5 * contrastMichelson * Math.sin((ix % periodInPx) * trigFactor);
        l = [MiscLight devicegrayFromLuminance: l]; // apply gamma correction
        l = lError + 255 * l; // begin error diffusion
        let lDiscrete = Math.round(l); // discrete values 0…255
        lError = l - lDiscrete; // keep residual (what was lost by rounding) for next time
        lDiscrete = lDiscrete / 255; // remap to 0…1
        //console.info(l, lError)
        CGContextSetStrokeColor(cgc, [CPColor colorWithWhite: lDiscrete alpha: 1]);
        CGContextBeginPath(cgc);
        CGContextMoveToPoint(cgc, ix, -l2);  CGContextAddLineToPoint(cgc, ix, l2);
        CGContextStrokePath(cgc);
    }
    const r = 0.5 * [MiscSpace pixelFromDegree: [Settings gratingDiaInDeg]];
    const w = r / 20;
    l = [MiscLight devicegrayFromLuminance: 0.5];
    [self annulusWithRadius: r - 2 * w width: w grey: l alpha: 0.125];
    [self annulusWithRadius: r - w width: w grey: l alpha: 0.25];
    [self annulusWithRadius: r width: w grey: l alpha: 0.5];
    [self annulusWithRadius: r + w width: w grey: l alpha: 0.75];
    [self annulusWithRadius: r + 2 * w width: w grey: l alpha: 0.875];
    [self annulusWithRadius: r + 400 width: 780 grey: l alpha: 1];
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerContrastG>drawStimulusInRect");
    [self calculateForeBackColors];
    [self prepareDrawing];
    switch(state) {
        case kStateDrawBack: break;
        case kStateDrawFore:
            [self drawFixMark];
            break;
        case kStateDrawFore2:
            contrastMichelson = [self gratingContrastMichelsonFromDeviceunits: stimStrengthInDeviceunits];
            let period = [MiscSpace pixelFromDegree: 1.0 / [Settings gratingCPD]];
            [self gratingSineWithPeriodInPx: period direction: [alternativesGenerator currentAlternative]];
            [self drawFixMark3];
            trialInfoString = [self contrastComposeTrialInfoString];// compose here after colors are set
            break;
        default: break;
    }
    
    if ([Settings enableTouchControls] && (!responseButtonsAdded)) {
        const sze = 50, sze2 = sze / 2, radius = 0.5 * Math.min(viewWidth, viewHeight) - sze2 - 1;
        for (let i = 0; i < 8; i++) {
            if ( ([Settings nAlternatives] > 4)  || (![Misc isOdd: i])) {
                const ang = i / 8 * 2 * Math.PI;
                [self buttonCenteredAtX: viewWidth / 2 + Math.cos(ang) * radius y:  Math.sin(ang) * radius size: sze title: [@"632147899" characterAtIndex: i]];
            }
        }
        [self buttonCenteredAtX: viewWidth - sze2 - 1 y: viewHeight / 2 - sze2 - 1 size: sze title: "Ø"];
    }
    
    CGContextRestoreGState(cgc);
    [super drawStimulusInRect: dirtyRect];
    [trialHistoryController setValue: contrastMichelson * 100];
}


- (void) runStart { //console.info("FractControllerContrastLett>runStart");
    nAlternatives = 4;  nTrials = [Settings nTrials04];
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


- (CPString) contrastComposeResultString {
    
    // taking into account the result of final trial
    stimStrengthInDeviceunits = [self stimDeviceunitsFromThresholderunits: [thresholder nextStim2apply]];
    contrastMichelson = [self gratingContrastMichelsonFromDeviceunits: stimStrengthInDeviceunits];
    
    rangeLimitStatus = kRangeLimitOk;
    if (contrastMichelson < 1 / 512) // 2 × 256
        rangeLimitStatus = kRangeLimitValueAtFloor;
    if (contrastMichelson >= 1.0)
        rangeLimitStatus = kRangeLimitValueAtCeiling;
    let s = "Grating threshold contrast: ";
    s += [self rangeStatusIndicatorStringInverted: YES];
    s += [Misc stringFromNumber: contrastMichelson * 100 decimals: 2 localised: YES];
    s += "% (Michelson)";
    return s;
}


- (CPString) contrastComposeExportString {
    if ([[self parentController] runAborted]) return "";
    let s = [self generalComposeExportString];
    s += tab + "value" + tab + [Misc stringFromNumber: contrastMichelson * 100 decimals: 3 localised: YES];
    s += tab + "unit1" + tab + currentTestResultUnit
    s += tab + "distanceInCm" + tab + [Misc stringFromNumber: [Settings distanceInCM] decimals: 2 localised: YES];
    s += tab + "spatFreq" + tab + [Misc stringFromNumber: [Settings gratingCPD] decimals: 1 localised: YES];
    s += tab + "unit2" + tab + "cpd";
    s += tab + "nTrials" + tab + [Misc stringFromNumber: nTrials decimals: 0 localised: YES];
    s += tab + "rangeLimitStatus" + tab + rangeLimitStatus;
    s += tab + "crowding" + tab + 0; // does not apply, but let's not NaN this
    s += crlf; //console.info("FractController>contrastComposeExportString: ", s);
    return s;
}

@end
