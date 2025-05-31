/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>
 
 2020-11-09 created, class "FractControllerAcuity" inheriting from "FractController"
 */


@import "FractController.j"
@implementation FractControllerAcuity: FractController {
}


- (void) drawCenterFixMark { //console.info("FractController>drawCenterFixMark");
    if (![Settings eccentShowCenterFixMark]) return;
    const eccRadiusInPix = Math.sqrt(xEccInPix * xEccInPix + yEccInPix * yEccInPix);
    if ((stimStrengthInDeviceunits * 3.5) > eccRadiusInPix) return; //we don't want overlap between fixmark and optotype
    CGContextSaveGState(cgc);
    CGContextTranslateCTM(cgc, viewWidthHalf, viewHeightHalf);
    CGContextSetLineWidth(cgc, 1);
    CGContextSetStrokeColor(cgc, [CPColor colorWithRed: 0 green: 0 blue: 1 alpha: 0.5]);
    [optotypes strokeStarAtX: 0 y: 0 size: Math.max(stimStrengthInDeviceunits * 2.5, [MiscSpace pixelFromDegree: 1 / 6])];
    CGContextRestoreGState(cgc);
}


//this manages stuff after the optotypes have been drawn, e.g. crowding
- (void) drawStimulusInRect: (CGRect) dirtyRect { //console.info("FractControllerAcuity>drawStimulusInRect");
    let _value = [MiscSpace logMARfromDecVA: [MiscSpace decVAFromStrokePixels: stimStrengthInDeviceunits]];
    if (gCurrentTestID === kTestAcuityVernier) { //needs to be in arcsec
        //console.info(_value);
        _value = [self reportFromNative: stimStrengthInDeviceunits];
        //console.info(_value, "\r");
    }
    [TrialHistoryController setValue: _value];
    if (([Settings crowdingType] > 0) && (gCurrentTestID !== kTestAcuityLineByLine) && (gCurrentTestID !== kTestContrastDitherUnittest)) {
        if (gCurrentTestID !== kTestAcuityVernier) { //don't do crowding with Vernier etc.
            CGContextSaveGState(cgc);
            CGContextTranslateCTM(cgc, viewWidthHalf, viewHeightHalf); //origin to center
            CGContextTranslateCTM(cgc, -xEccInPix, -yEccInPix);
            const crowdingGap = [self acuityCrowdingGapFromStrokeWidth: stimStrengthInDeviceunits];
            const distance4bars = crowdingGap + (0.5 + 2.5) * stimStrengthInDeviceunits;
            const distance4optotypes = crowdingGap + 5 * stimStrengthInDeviceunits;
            CGContextSetLineWidth(cgc, stimStrengthInDeviceunits);
            switch ([Settings crowdingType]) {
                case 0:  break; //should not occur here anyway
                case 1: //flanking bars
                    const length2 = stimStrengthInDeviceunits * 2.5;
                    [optotypes strokeVLineAtX: -distance4bars y0: -length2 y1: length2];
                    [optotypes strokeVLineAtX: distance4bars y0: -length2 y1: length2];
                    break;
                case 2: //flanking rings
                    for (let i = -1; i <= 1; i++) { //console.info(i);
                        const tempX = i * distance4optotypes;
                        CGContextTranslateCTM(cgc,  -tempX, 0);
                        if (i !== 0)  [optotypes drawLandoltWithStrokeInPx: stimStrengthInDeviceunits landoltDirection: -1];
                        CGContextTranslateCTM(cgc,  +tempX, 0);
                    }  break;
                case 3:    //surounding bars
                    const length4 = stimStrengthInDeviceunits * 4;
                    CGContextSetLineCap(cgc,  kCGLineCapRound);
                    [optotypes strokeVLineAtX: -distance4bars y0: -length4 y1: length4];
                    [optotypes strokeVLineAtX: distance4bars y0: -length4 y1: length4];
                    [optotypes strokeHLineAtX0: -length4 y: -distance4bars x1: length4];
                    [optotypes strokeHLineAtX0: -length4 y: distance4bars x1: length4];
                    break;
                case 4:  //surounding ring: gap + 2.5 strokes + ½ stroke for stroke width
                    [optotypes strokeCircleAtX: 0 y: 0 radius: distance4bars];
                    break;
                case 5: //surrounding square
                    const frameSizeX2 = 2 * distance4bars, frameSize = distance4bars;
                    CGContextStrokeRect(cgc, CGRectMake(-frameSize, -frameSize, frameSizeX2, frameSizeX2));
                    break;
                case 6:    //row of optotypes
                    let rowAlternatives = [[AlternativesGenerator alloc] initWithNumAlternatives: nAlternatives andNTrials: 5 obliqueOnly: NO];
                    for (let i = -2; i <= 2; i++) {
                        const tempX = i * distance4optotypes;
                        CGContextTranslateCTM(cgc, -tempX, 0);
                        if (i !== 0)  {
                            let directionInRow = [rowAlternatives nextAlternative];
                            if (directionInRow === [alternativesGenerator currentAlternative])
                                directionInRow = [rowAlternatives nextAlternative];
                            switch (gCurrentTestID) {
                                case kTestAcuityLett:
                                    [optotypes drawLetterWithStriokeInPx: stimStrengthInDeviceunits letterNumber: directionInRow];  break;
                                case kTestAcuityE:
                                    [optotypes tumblingEWithStrokeInPx: stimStrengthInDeviceunits direction: directionInRow];  break;
                                case kTestAcuityTAO:
                                    [gAppController.taoController drawTaoWithStrokeInPx: stimStrengthInDeviceunits taoNumber: directionInRow];  break;
                                default:
                                    [optotypes drawLandoltWithStrokeInPx: stimStrengthInDeviceunits landoltDirection: directionInRow];
                            }
                        }
                        CGContextTranslateCTM(cgc, +tempX, 0);
                    }  break;
            }
            CGContextRestoreGState(cgc);
        }
    }
    [self drawCenterFixMark];
    [super drawStimulusInRect: dirtyRect];
    discardKeyEntries = NO; //now allow responding
}


- (void) runEnd { //console.info("FractControllerAcuity>runEnd");
    switch (gCurrentTestID) {
        case kTestAcuityLett:
        case kTestAcuityC:
        case kTestAcuityE:
        case kTestAcuityTAO:
            if (iTrial < nTrials) { //premature end
                [gAppController setResultString: gAbortMessage];
            } else {
                if ([Settings isAcuityPresentedConstant]) {
                    stimStrengthInDeviceunits = [MiscSpace strokePixelsFromDecVA: [MiscSpace decVAfromLogMAR: [Settings acuityPresentedConstantLogMAR]]];
                }
                [gAppController setResultString: [self acuityComposeResultString]];
            }
            break;
        case kTestAcuityVernier:
            break;
        case kTestAcuityLineByLine:
            [gAppController setResultString: ""];
            break;
    }
    [super runEnd];
}


- (CPString) format4SnellenInFeet: (float) decVA {
    const distanceInMetres = [Settings distanceInCM] / 100.0;
    let distanceInFeet = distanceInMetres * gMeter2FeetMultiplier;
    if ([Settings forceSnellen20])  distanceInFeet = 20;
    let s = [Misc stringFromNumber: distanceInFeet decimals: 0 localised: YES] + "/";
    s += [Misc stringFromNumber: (distanceInFeet / decVA) decimals: 0 localised: YES];
    return s;
}
/*private function format4SnellenInMeter(theAcuityResult):String {
 let distanceInMetres=Prefs.distanceInCM.n / 100.0, distanceInFeet=distanceInMetres * 3.28084;
 return Utils.DeleteTrailing_PointZero(Utils.rStrNInt(distanceInMetres, 1, Prefs.decimalPointChar)) + "/" + Utils.DeleteTrailing_PointZero(Utils.rStrNInt(distanceInMetres / theAcuityResult,1,Prefs.decimalPointChar));
 }*/


/*    Transformation formula:   stroke = c1 * exp(tPest * c2).
 Constants c1 and c2 are determined by these 2 condions: tPest==0 → stroke=gStrokeMinimal;  tPest==1 → stroke=gStrokeMaximal.
 =>c2 = ln(gStrokeMinimal / gStrokeMaximal)/(0 - 1);  c1 = gStrokeMinimal / exp(0 * c2)  */
- (float) acuityStimDeviceunitsFromThresholderunits: (float) tPest { //console.info("FractControllerAcuityC>stimDeviceunitsFromThresholderunits");
    const c2 = - Math.log(gStrokeMinimal / gStrokeMaximal), c1 = gStrokeMinimal;
    const deviceVal = c1 * Math.exp(tPest * c2); //console.info("DeviceFromPest " + tPest + " " + deviceVal);
    //ROUNDING for realisable stroke values? @@@
    if ([Misc areNearlyEqual: deviceVal and: gStrokeMaximal]) {
        if (!isBonusTrial) {
            rangeLimitStatus = kRangeLimitValueAtCeiling; //console.info("max stroke size!")
        }
    } else {
        if  ([Misc areNearlyEqual: deviceVal and: gStrokeMinimal]) {
            rangeLimitStatus = kRangeLimitValueAtFloor; //console.info("min stroke size!");
        } else {
            rangeLimitStatus = kRangeLimitOk;
        }
    }
    return deviceVal;
}


- (float) acuityStimThresholderunitsFromDeviceunits: (float) d { //console.info("FractControllerAcuityC>stimThresholderunitsFromDeviceunits");
    const c2 = - Math.log(gStrokeMinimal / gStrokeMaximal), c1 = gStrokeMinimal;
    const retVal = Math.log(d / c1) / c2; //console.info("PestFromDevice " + d + " " + retVal);
    return retVal;
}


- (CPString) acuityComposeTrialInfoString {
    let s = iTrial + "/" + nTrials + " ";
    s += [Misc stringFromNumber: [MiscSpace decVAFromStrokePixels: stimStrengthInDeviceunits] decimals: 2 localised: NO];
    return s;
}


- (float) acuityResultInDecVA {
    const resultInStrokePx = stimStrengthInDeviceunits;
    let resultInDecVA = [MiscSpace decVAFromStrokePixels: resultInStrokePx];
    if ([Settings doThreshCorrection]) resultInDecVA *= gThresholdCorrection4Ascending;
    //console.info("FractControllerAcuity>acuityResultInDecVA: ", resultInDecVA);
    return resultInDecVA;
}


- (float) acuityResultInLogMAR {
    return [MiscSpace logMARfromDecVA: [self acuityResultInDecVA]];
}


- (float) acuityResultValue4Export {
    return [self acuityResultInLogMAR];
}


- (CPString) acuityComposeResultString { //2021-05-02: now all formats are "ceilinged"
    const resultInDecVACeilinged = Math.min([Settings maxDisplayedAcuity], [self acuityResultInDecVA]);
    const resultInLogMARCeilinged = [MiscSpace logMARfromDecVA: resultInDecVACeilinged];
    let s = "";
    if ([Settings showAcuityFormatLogMAR]) {
        if (s.length > 1) s += ",  ";
        s += "LogMAR:" + [self rangeStatusIndicatorStringInverted: YES];
        s += [Misc stringFromNumber: resultInLogMARCeilinged decimals: 2 localised: YES];
        if (ci95String.length > 1) {
            s += ci95String;
        }
    }
    if ([Settings showAcuityFormatDecimal]) {
        if (s.length > 1) s += ",  ";
        s += "decVA:" + [self rangeStatusIndicatorStringInverted: NO];
        s += [Misc stringFromNumber: resultInDecVACeilinged decimals: 2 localised: YES];
    }
    if ([Settings showAcuityFormatSnellenFractionFoot]) {
        if (s.length > 1) s += ",  ";
        s += "Snellen fraction:" +  [self rangeStatusIndicatorStringInverted: NO];
        s += [self format4SnellenInFeet: resultInDecVACeilinged];
    }
    return s;
}


- (CPString) acuityComposeExportString { //console.info("FractController>acuityComposeExportString");
    if (gAppController.runAborted) return "";
    let s = [self generalComposeExportString];
    const nDigits = 3;
    s += tab + "value" + tab + [Misc stringFromNumber: [self resultValue4Export] decimals: nDigits localised: YES];
    s += tab + "unit1" + tab + gAppController.currentTestResultUnit;
    s += tab + "distanceInCm" + tab + [Misc stringFromNumber: [Settings distanceInCM] decimals: 1 localised: YES];
    s += tab + "contrastWeber" + tab + [Misc stringFromNumber: [Settings contrastAcuityWeber] decimals: 1 localised: YES];
    s += tab + "unit2" + tab + "%";
    s += tab + "nTrials" + tab + [Misc stringFromNumber: nTrials decimals: 0 localised: YES];
    s += tab + "rangeLimitStatus" + tab + rangeLimitStatus;
    s += tab + "crowding" + tab + [Settings crowdingType];
    return [self generalComposeExportStringFinalize: s];
}


- (void) acuityModifyDeviceStimulusDIN01_02_04_08 {
    if ([Settings isAcuityPresentedConstant]) {
        stimStrengthInDeviceunits = [MiscSpace strokePixelsFromDecVA: [MiscSpace decVAfromLogMAR: [Settings acuityPresentedConstantLogMAR]]];
        return;
    }

    responseWasCorrectCumulative = responseWasCorrectCumulative && responseWasCorrect;
    const acuityStartDecimal = [MiscSpace decVAfromLogMAR: [Settings acuityStartingLogMAR]];
    switch (iTrial) {
        case 1:  stimStrengthInDeviceunits = [MiscSpace strokePixelsFromDecVA: acuityStartDecimal];  break;
        case 2:  if (responseWasCorrectCumulative) stimStrengthInDeviceunits = [MiscSpace strokePixelsFromDecVA: acuityStartDecimal * 2];  break;
        case 3:  if (responseWasCorrectCumulative) stimStrengthInDeviceunits = [MiscSpace strokePixelsFromDecVA: acuityStartDecimal * 4];  break;
        case 4:  if (responseWasCorrectCumulative) stimStrengthInDeviceunits = [MiscSpace strokePixelsFromDecVA: acuityStartDecimal * 8];  break;
    }
    if (stimStrengthInDeviceunits > gStrokeMaximal) stimStrengthInDeviceunits = gStrokeMaximal;
    if (stimStrengthInDeviceunits < gStrokeMinimal) stimStrengthInDeviceunits = gStrokeMinimal;
}


//gap between optotype border and border of the crowder
- (float) acuityCrowdingGapFromStrokeWidth: (float) stroke {
    let returnVal = 2 * stroke; //case 0
    switch ([Settings crowdingDistanceCalculationType]) {
        case 1:
            returnVal = [MiscSpace pixelFromDegree: 2.6 / 60.0];  break;
        case 2:
            returnVal = [MiscSpace pixelFromDegree: 30 / 60.0];  break;
        case 3: //1 optotype (like ETDRS)
            returnVal = 5 * stroke;  break;
    }
    return returnVal;
}


@end
