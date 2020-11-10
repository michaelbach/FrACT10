/*
 FractControllerContrast.j

 Created by Bach on 2020-09-02
*/


@import "FractControllerContrast.j"
@implementation FractControllerContrast: FractController {
    float optotypeSize;
}


- (void) modifyThresholderStimulus {
    if (iTrial == 1) // make the first more visible
        stimStrengthInThresholderUnits = Math.min(stimStrengthInThresholderUnits + 0.3, 1.0);
    if ([Settings contrastEasyTrials]) // don't forget bonus
        [self modifyThresholderStimulusWithBonus];
}


- (void) calculateForeBackColors {
    var gray1 = [Misc lowerLuminanceFromContrastLogCSWeber: stimStrengthInDeviceunits];
    gray1 = [Misc devicegrayFromLuminance: gray1];
    var gray2 = [Misc upperLuminanceFromContrastLogCSWeber: stimStrengthInDeviceunits];
    gray2 = [Misc devicegrayFromLuminance: gray2];
    if (![Settings contrastDarkOnLight]) {
        var gray = gray1; gray1 = gray2; gray2 = gray;
    }
    colOptotypeFore = [CPColor colorWithWhite: gray1 alpha: 1];//console.info(colOptotypeFore);
    colOptotypeBack = [CPColor colorWithWhite: gray2 alpha: 1];//console.info(colOptotypeBack);
}


- (void) drawFixMark {
    var t = [Settings contrastTimeoutFixmark] / 1000;
    if ([Settings contrastShowFixMark]) {
        CGContextSetStrokeColor(cgc, [CPColor colorWithRed: 0 green: 0 blue: 1 alpha: 0.7]);
        CGContextSetLineWidth(cgc, 0.5);
        [optotypes setCgc: cgc colFore: [CPColor colorWithRed: 0 green: 0 blue: 1 alpha: 0.3] colBack: colOptotypeBack];
        [optotypes strokeCrossAtX: 0 y: 0 size: optotypeSize * 3];
        [optotypes strokeXAtX: 0 y: 0 size: optotypeSize * 3];
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


- (void) runStart { //console.info("FractControllerContrastLett>runStart");
    [super runStart];
    [self setCurrentTestResultUnit: "logCSWeber"];
    optotypeSize = [Misc pixelFromDegree: [Settings contrastOptotypeDiameter] / 60] / 5;
}


- (void) runEnd { //p.info("FractControllerContrastLett>runEnd");
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
// deviceUnits are in logCSWeber
// logCSW: 2 … 0, thresholder: 0 … 1 */
- (float) stimDeviceunitsFromThresholderunits: (float) thresholderunit { //console.info("FractControllerVAC>stimDeviceunitsFromThresholderunits");
    var logCSWMaximal = [Settings contrastMaxLogCSWeber];
    var deviceVal = logCSWMaximal - logCSWMaximal * thresholderunit; // logCSWMinimal = 0 anyway
    return deviceVal;
}
- (float) stimThresholderunitsFromDeviceunits: (float) d { //console.info("FractControllerVAC>stimThresholderunitsFromDeviceunits");
    //console.info("d: ", d, ",  retVal: ", retVal)
    var logCSWMaximal = [Settings contrastMaxLogCSWeber];
    var retVal = (logCSWMaximal - d) / logCSWMaximal
    return retVal;
}
- (void) testContrastDeviceThresholdConversion {
    for (var i = 0; i <= 1.0; i += 0.1) {
        var d = [self contrastStimDeviceunitsFromThresholderunits: i];
        console.info("threshh: ", i, ", devUnits: ", d, ", threshh: ", [self stimThresholderunitsFromDeviceunits: d]);
    }
}

- (CPString) contrastComposeTrialInfoString {
    var s = "trial: " + iTrial + "/" + nTrials;
    s +=  ", contrast: " + [Misc stringFromNumber: [Misc contrastWeberPercentFromLogCSWeber: stimStrengthInDeviceunits] decimals: 1 localised: YES] + "%";
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
    var s = "Contrast threshold: \n";
    s += [self rangeStatusIndicatorStringInverted: YES];
    s += [Misc stringFromNumber: stimStrengthInDeviceunits decimals: 2 localised: YES];
    s += " logCS(Weber) ≘ ";
    s += [self rangeStatusIndicatorStringInverted: NO];
    s += [Misc stringFromNumber: [Misc contrastWeberPercentFromLogCSWeber: stimStrengthInDeviceunits] decimals: 2 localised: YES];
    s += "%";
    return s;
}


- (CPString) composeExportString { //console.info("FractController>contrastComposeExportString");
    var s = "";
    if ([[self parentController] runAborted]) return;
    var tab = "\t", crlf = "\n", nDigits = 3, now = [CPDate date];
    s = "Vs" + tab + "3"; // version
    s += tab + "decimalMark" + tab + [Settings decimalMarkChar];
    s += tab + "date" + tab + [Misc date2YYYY_MM_DD: now] + tab + "time" + tab + [Misc date2HH_MM_SS: now];
    s += tab + "test" + tab + currentTestName;
    s += tab + "value" + tab + [Misc stringFromNumber: stimStrengthInDeviceunits decimals: nDigits localised: YES];
    s += tab + "unit" + tab + currentTestResultUnit
    s += tab + "distanceInCm" + tab + [Misc stringFromNumber: [Settings distanceInCM] decimals: 2 localised: YES];
    s += tab + "diameter" + tab + [Misc stringFromNumber: [Settings contrastOptotypeDiameter] decimals: 2 localised: YES];
    s += tab + "unit" + tab + "arcmin";
    s += tab + "nTrials" + tab + [Misc stringFromNumber: nTrials decimals: 0 localised: YES];
    s += tab + "rangeLimitStatus" + tab + rangeLimitStatus;
    //s += tab + "XX" + tab + YY;
    s += crlf; //console.info("FractController>contrastComposeExportString: ", s);
    return s;
}

@end
