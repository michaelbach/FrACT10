/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>
 
 FractControllerContrastG.j: Gratings
 
 Created by Bach on 2020-09-02
 */


@import "FractControllerContrast.j"
@implementation FractControllerContrastG: FractControllerContrast {
    float periodInPixel;
    BOOL isGratingColor, isErrorDiffusion;
    float specialBcmFreq, specialBcmFreqPrevious;
    int specialBcmCountAtStep, specialBcmCountAtStepError;
}


// Method of limits
const specialBcmStepsize = 0.1;
- (void) modifyDeviceStimulus { //console.info("FractControllerContrastG>modifyDeviceStimulus");
    responseWasCorrectCumulative = responseWasCorrectCumulative && responseWasCorrect;
    if (![Settings specialBcmOn]) return;
    if (iTrial == 1) {
        nTrials = 200;
        alternativesGenerator = [[AlternativesGenerator alloc] initWithNumAlternatives: 2 andNTrials: nTrials obliqueOnly: YES];
        trialHistoryController = [[TrialHistoryController alloc] initWithNumTrials: nTrials];
        
        specialBcmFreq = [Settings gratingCPDmin];
        specialBcmFreqPrevious = 0;
        specialBcmCountAtStep = 1;
        specialBcmCountAtStepError = 0;
    } else {
        if (!responseWasCorrect) specialBcmCountAtStepError++;
        if (specialBcmCountAtStepError >= 2) {
            spatialFreqCPD = specialBcmFreqPrevious;
            nTrials = iTrial - 1;  iTrial = 9999;
            [self runEnd];
        } else {
            specialBcmCountAtStep++;
            if (specialBcmCountAtStep > 10) {
                specialBcmFreqPrevious = specialBcmFreq;
                specialBcmFreq *= Math.pow(10, specialBcmStepsize);
                specialBcmCountAtStep = 1;
                specialBcmCountAtStepError = 0;
            }
        }
    }
    [super modifyDeviceStimulus];
}


- (float) freqFromThresholderunits: (float) thresholderunit {
    thresholderunit = 1 - thresholderunit; // 0: strong stimulus=low spatFreq

    // exponential mapping for psychometric function to frequency. Does NOT work well.
    /*const expFreqMin = Math.pow(10, [Settings gratingCPDmin]);
    const expFreqMax = Math.pow(10, [Settings gratingCPDmax]);
    const expFreq = expFreqMin + thresholderunit * (expFreqMax - expFreqMin);
    return Math.log10(expFreq);*/

    // linear mapping for psychometric function to frequency
    const freqMin = [Settings gratingCPDmin], freqMax = [Settings gratingCPDmax];
    const freq = freqMin + thresholderunit * (freqMax - freqMin);
    return freq;
    
    // log mapping for psychometric function to frequency
    /*    const logFreqMin = Math.log10([Settings gratingCPDmin]);
     const logFreqMax = Math.log10([Settings gratingCPDmax]);
     const logFreq = logFreqMin + thresholderunit * (logFreqMax - logFreqMin);
     return Math.pow(10, logFreq);*/
}


- (void) gratingSineWithPeriodInPx: (float) periodInPx direction: (int) theDirection contrast: (float) contrast {
    let s2 = Math.round(Math.max(viewHeight2, viewWidth2) / 2 * 1.3) * 2;
    const trigFactor = 1 / periodInPx * 2 * Math.PI; // calculate only once
    const notGratingSineNotSquare = ![Settings gratingSineNotSquare]
    CGContextRotateCTM(cgc, -theDirection * 22.5 * Math.PI / 180);
    CGContextSetLineWidth(cgc, 1.3); // still an artifact on oblique
    let lFloat, lDiscrete, lError = 0;
    for (let ix = -s2; ix <= s2; ++ix) {
        lFloat = Math.sin((ix % periodInPx) * trigFactor);
        if (notGratingSineNotSquare) lFloat = lFloat >= 0 ? 1 : -1; // sine → square wave grating
        lFloat = 0.5 + 0.5 * contrast / 100 * lFloat;  // contrast, map [-1, 1] → [0,1]
        if (isGratingColor) {
            CGContextSetStrokeColor(cgc, [colOptotypeFore colorWithAlphaComponent: lFloat]);
        } else {
            lFloat = [MiscLight devicegrayFromLuminance: lFloat]; // gamma correction
            lDiscrete = lFloat;
            if (isErrorDiffusion) {
                lFloat = lFloat * 255 + lError; // map → [0, 255], apply previous residual
                lDiscrete = Math.round(lFloat); // discrete integer values [0, 255]
                lError = lFloat - lDiscrete; // keep residual (what was lost by rounding)
                lDiscrete /= 255; // remap → [0, 1]
            }
            CGContextSetStrokeColor(cgc, [CPColor colorWithWhite: lDiscrete alpha: 1]);
        }
        [optotypes strokeVLineAtX: ix y0: -s2 y1: s2];
    }
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView {
    isGratingColor = [Settings isGratingColor];
    isErrorDiffusion = [Settings gratingUseErrorDiffusion];
    [self calculateForeBackColors];
    if (isGratingColor) {
        colOptotypeFore = [Settings gratingForeColor];
        colOptotypeBack = [Settings gratingBackColor];
    }
    [self prepareDrawing];
    if (!isGratingColor) {
        CGContextSetFillColor(cgc, [CPColor colorWithWhite: [MiscLight devicegrayFromLuminance: 0.5] alpha: 1]);
        CGContextFillRect(cgc, CGRectMake(-viewWidth2, +viewHeight2, viewWidth, -viewHeight));
    }
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
                if ([Settings specialBcmOn]) {
                    spatialFreqCPD = specialBcmFreq;
                }
            }
            periodInPixel = Math.max([MiscSpace periodInPixelFromSpatialFrequency: spatialFreqCPD], 2);
            let dir = [alternativesGenerator currentAlternative];
            if ([Settings isGratingMasked]) {
                CGContextBeginPath(cgc);
                const r = 0.5 * [MiscSpace pixelFromDegree: [Settings gratingDiaInDeg]];
                CGContextAddEllipseInRect(cgc, CGRectMake(0 - r, 0 - r, 2 * r, 2 * r));
                CGContextClosePath(cgc);  CGContextClip(cgc);
            }
            [self gratingSineWithPeriodInPx: periodInPixel direction: dir contrast: contrastMichelsonPercent];
            [self drawFixMark3];
            trialInfoString = [self contrastComposeTrialInfoString];
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
    s += ", frequency: " + [Misc stringFromNumber: spatialFreqCPD decimals: 2 localised: YES];
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
        if (![Settings specialBcmOn]) {
            spatialFreqCPD = [self freqFromThresholderunits: stimStrengthInThresholderUnits];
        }
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
    s += [Misc stringFromNumber: spatialFreqCPD decimals: 2 localised: YES];
    s += " cpd";
    return s;
}


- (CPString) contrastComposeExportString {    if ([[self parentController] runAborted]) return "";
    let _testExportString = [self generalComposeExportString];
    _testExportString += tab + "value" + tab + [Misc stringFromNumber: contrastMichelsonPercent decimals: 3 localised: YES];
    _testExportString += tab + "unit1" + tab + currentTestResultUnit
    _testExportString += tab + "distanceInCm" + tab + [Misc stringFromNumber: [Settings distanceInCM] decimals: 2 localised: YES];
    _testExportString += tab + "spatFreq" + tab + [Misc stringFromNumber: spatialFreqCPD decimals: 2 localised: YES];
    _testExportString += tab + "unit2" + tab + "cpd";
    _testExportString += tab + "nTrials" + tab + [Misc stringFromNumber: nTrials decimals: 0 localised: YES];
    _testExportString += tab + "rangeLimitStatus" + tab + rangeLimitStatus;
    _testExportString += tab + "crowding" + tab + 0; // does not apply, but let's not NaN this
    if (isGratingColor) {
        _testExportString += tab + "colorForeBack" + tab + [colOptotypeFore hexString] + tab + [colOptotypeBack hexString];
        if ([self isAcuityGrating]) {
            _testExportString += tab + "cpdMin" + tab + [Misc stringFromNumber: [Settings gratingCPDmin] decimals: 3 localised: YES];
            _testExportString += tab + "cpdMax" + tab + [Misc stringFromNumber: [Settings gratingCPDmax] decimals: 2 localised: YES];
        }
    }
    return _testExportString;
}

@end
