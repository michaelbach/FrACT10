/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

FractControllerContrast.j

Created by Bach on 2020-09-02
*/


@import "FractControllerContrast.j"
@implementation FractControllerContrast: FractController {
}

- (CPString) composeExportString {return [self contrastComposeExportString];}


- (void) modifyThresholderStimulus {
    if (iTrial == 1) // make the first more visible
        stimStrengthInThresholderUnits = Math.min(stimStrengthInThresholderUnits + 0.3, 1);
    if ([Settings contrastEasyTrials]) // don't forget bonus
        [self modifyThresholderStimulusWithBonus];
}


- (void) calculateForeBackColors {
    let gray1 = [MiscLight lowerLuminanceFromContrastLogCSWeber: stimStrengthInDeviceunits];
    gray1 = [MiscLight devicegrayFromLuminance: gray1];
    let gray2 = [MiscLight upperLuminanceFromContrastLogCSWeber: stimStrengthInDeviceunits];
    gray2 = [MiscLight devicegrayFromLuminance: gray2];
    if (![Settings contrastDarkOnLight]) {
        const gray = gray1; gray1 = gray2; gray2 = gray;
    }
    colOptotypeFore = [CPColor colorWithWhite: gray1 alpha: 1];//console.info(colOptotypeFore);
    colOptotypeBack = [CPColor colorWithWhite: gray2 alpha: 1];//console.info(colOptotypeBack);
}


// Strategy: draw fixmark, delay (onTimeoutFixMark) and draw optotype, erasing fixmark.
// With eccentricity: Need to draw again right after optotype so it seamlessly stays put
// No marked eccentricity: don't draw it again
- (void) drawFixMark3 { // check marked eccentricity is set, otherwise don't draw it
    const eccRadiusInPix = Math.sqrt(xEccInPix * xEccInPix + yEccInPix * yEccInPix);
    if ((optotypeSizeInPix * 4) > eccRadiusInPix) return; // we don't want overlap between fixmark and optotype
    [self drawFixMark2];
}
- (void) drawFixMark2 {
    CGContextSaveGState(cgc);
    CGContextSetStrokeColor(cgc, [CPColor colorWithRed: 0 green: 0 blue: 1 alpha: 0.7]);
    CGContextSetLineWidth(cgc, 0.5);
    //[optotypes setCgc: cgc colFore: [CPColor colorWithRed: 0 green: 0 blue: 1 alpha: 0.3] colBack: colOptotypeBack];
    CGContextTranslateCTM(cgc,  +xEccInPix, +yEccInPix); // counter eccentricity
    [optotypes strokeStarAtX: 0 y: 0 size: optotypeSizeInPix * 3];
    CGContextRestoreGState(cgc);
}
- (void) drawFixMark {
    let t = [Settings contrastTimeoutFixmark] / 1000; // ms → seconds
    if ([Settings contrastShowFixMark]) {
        [self drawFixMark2];
        timerFixMark = [CPTimer scheduledTimerWithTimeInterval: t target:self selector:@selector(onTimeoutFixMark:) userInfo:nil repeats:NO];
    } else {
        t = 0.02;
    }
    timerFixMark = [CPTimer scheduledTimerWithTimeInterval: t target:self selector:@selector(onTimeoutFixMark:) userInfo:nil repeats:NO];
}
- (void) onTimeoutFixMark: (CPTimer) timer { //console.info("FractController>onTimeoutFixCross");
    state = kStateDrawFore2;
    [[[self window] contentView] setNeedsDisplay: YES];
}


- (void) runStart { //console.info("FractControllerContrast>runStart");
    [super runStart];
    [self setCurrentTestResultUnit: "logCSWeber"];
}


// this manages stuff after the optotypes have been drawn
- (void) drawStimulusInRect: (CGRect) dirtyRect { //console.info("FractControllerContrast>drawStimulusInRect");
    [trialHistoryController setValue: stimStrengthInDeviceunits ];
    [super drawStimulusInRect: dirtyRect];
}


- (void) runEnd { //console.info("FractControllerContrast>runEnd");
    if (iTrial < nTrials) { //premature end
        [self setResultString: @"Aborted"];
    } else {
        [self setResultString: [self contrastComposeResultString]];
    }
    [super runEnd];
}


///////////////////////// CONTRAST UTILs
/*
basic flow:
 Thresholder → thresholderunits
 thresholderunits → deviceunits (logCSWeber)
 deviceunits → upper/lower luminance, considering gamma → discrete values for [CPColor colorWithWhite] (0…255)
 present stimulus
 stimStrengthInDeviceunits → thresholderunits (currently ignoring gamma because "locally everything is linear")
 thresholderunits + correctness → Thresholder
 

// contrast: 0.1 … 100, thresholder: 0 … 1
// deviceUnits are in logCSWeber for all contrast tests; for gratings that is converted to Michelson%
// logCSW: 2 … 0, thresholder: 0 … 1 */
- (float) stimDeviceunitsFromThresholderunits: (float) thresholderunit { //console.info("FractControllerAcuityC>stimDeviceunitsFromThresholderunits");
    const logCSWMaximal = [Settings contrastMaxLogCSWeber];
    const deviceVal = logCSWMaximal - logCSWMaximal * thresholderunit; // logCSWMinimal = 0 anyway
    return deviceVal;
}
- (float) stimThresholderunitsFromDeviceunits: (float) d { //console.info("FractControllerAcuityC>stimThresholderunitsFromDeviceunits");
    //console.info("d: ", d, ",  retVal: ", retVal)
    const logCSWMaximal = [Settings contrastMaxLogCSWeber];
    const retVal = (logCSWMaximal - d) / logCSWMaximal
    return retVal;
}
- (void) testContrastDeviceThresholdConversion {
    for (let i = 0; i <= 1.0; i += 0.1) {
        const d = [self contrastStimDeviceunitsFromThresholderunits: i];
        console.info("threshh: ", i, ", devUnits: ", d, ", threshh: ", [self stimThresholderunitsFromDeviceunits: d]);
    }
}

- (CPString) contrastComposeTrialInfoString {
    let s = "trial: " + iTrial + "/" + nTrials;
    s +=  ", contrast: " + [Misc stringFromNumber: [MiscLight contrastWeberPercentFromLogCSWeber: stimStrengthInDeviceunits] decimals: 1 localised: YES] + "%";
    s += ", logCSW: " + [Misc stringFromNumber: stimStrengthInDeviceunits decimals: 2 localised: YES];
    s += ", alternative: " + [alternativesGenerator currentAlternative];
    return s;
}


- (CPString) contrastComposeResultString { //console.info("contrastComposeResultString");
    // console.info("rangeLimitStatus: ", rangeLimitStatus);
    rangeLimitStatus = kRangeLimitOk;
    if (stimStrengthInDeviceunits >= 2.0) { // todo: do this while testing
        rangeLimitStatus = kRangeLimitValueAtCeiling;
    }
    let s = "Contrast threshold: " + crlf;
    s += [self rangeStatusIndicatorStringInverted: YES];
    s += [Misc stringFromNumber: stimStrengthInDeviceunits decimals: 2 localised: YES];
    s += " logCS(Weber) ≙ ";
    s += [self rangeStatusIndicatorStringInverted: NO];
    s += [Misc stringFromNumber: [MiscLight contrastWeberPercentFromLogCSWeber: stimStrengthInDeviceunits] decimals: 2 localised: YES];
    s += "%";
    return s;
}


- (CPString) contrastComposeExportString { //console.info("FractController>contrastComposeExportString");
    if ([[self parentController] runAborted]) return "";
    let s = [self generalComposeExportString];
    const nDigits = 3;
    s += tab + "value" + tab + [Misc stringFromNumber: stimStrengthInDeviceunits decimals: nDigits localised: YES];
    s += tab + "unit1" + tab + currentTestResultUnit
    s += tab + "distanceInCm" + tab + [Misc stringFromNumber: [Settings distanceInCM] decimals: 2 localised: YES];
    s += tab + "diameter" + tab + [Misc stringFromNumber: [Settings contrastOptotypeDiameter] decimals: 2 localised: YES];
    s += tab + "unit2" + tab + "arcmin";
    s += tab + "nTrials" + tab + [Misc stringFromNumber: nTrials decimals: 0 localised: YES];
    s += tab + "rangeLimitStatus" + tab + rangeLimitStatus;
    s += tab + "crowding" + tab + 0; // does not apply, but let's not NaN this
    return s;
}


@end
