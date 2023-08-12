/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>
 
 2020-11-09 created, class "FractControllerAcuity" inheriting from "FractController"
 */


@import "FractController.j"
@implementation FractControllerAcuity: FractController {
}


- (void) drawCenterFixMark { //console.info("FractController>drawCenterFixMarkIfEccentric");
    if (![Settings eccentShowCenterFixMark]) return;
    const eccRadiusInPix = Math.sqrt(xEccInPix * xEccInPix + yEccInPix * yEccInPix);
    if ((stimStrengthInDeviceunits * 3.5) > eccRadiusInPix) return;// we don't want overlap between fixmark and optotype
    CGContextSaveGState(cgc);
    CGContextTranslateCTM(cgc, viewWidth2, viewHeight2);
    CGContextSetLineWidth(cgc, 1);
    CGContextSetStrokeColor(cgc, [CPColor colorWithRed: 0 green: 0 blue: 1 alpha: 0.5]);
    [optotypes strokeStarAtX: 0 y: 0 size: Math.max(stimStrengthInDeviceunits * 2.5, [MiscSpace pixelFromDegree: 1 / 6])];
    CGContextRestoreGState(cgc);
}


// this manages stuff after the optotypes have been drawn, e.g. crowding
- (void) drawStimulusInRect: (CGRect) dirtyRect { //console.info("FractController>drawStimulusInRect");
    [trialHistoryController setValue: [MiscSpace logMARfromDecVA: [MiscSpace decVAFromGapPixels: stimStrengthInDeviceunits]]];
    if ([Settings crowdingType] > 0) {
        if (currentTestID != kTestAcuityVernier) { // don't do crowding with Vernier etc.
            CGContextSaveGState(cgc);
            CGContextTranslateCTM(cgc, viewWidth2, viewHeight / 2); // origin to center
            CGContextTranslateCTM(cgc, -xEccInPix, -yEccInPix);
            const crowdingDistance = [self acuityCrowdingDistanceFromGap: stimStrengthInDeviceunits];
            switch ([Settings crowdingType]) {
                case 0:  break; // should not occur here
                case 1: // flanking bars
                    const distance2 = 1.5 * crowdingDistance / 2;
                    const length2 = stimStrengthInDeviceunits * 2.5;
                    CGContextSetLineWidth(cgc, stimStrengthInDeviceunits);
                    [optotypes strokeVLineAtX: -distance2 y0: -length2 y1: length2];
                    [optotypes strokeVLineAtX: distance2 y0: -length2 y1: length2];
                    break;
                case 2: // flanking rings
                    for (let i = -1; i <= 1; i++) { //console.info(i);
                        const tempX = i * crowdingDistance;
                        CGContextTranslateCTM(cgc,  -tempX, 0);
                        if (i != 0)  [optotypes drawLandoltWithGapInPx: stimStrengthInDeviceunits landoltDirection: -1];
                        CGContextTranslateCTM(cgc,  +tempX, 0);
                    }  break;
                case 3:    // surounding bars
                    const distance4 = 1.5 * crowdingDistance / 2;
                    const length4 = stimStrengthInDeviceunits * 4;
                    CGContextSetLineCap(cgc,  kCGLineCapRound);
                    CGContextSetLineWidth(cgc, stimStrengthInDeviceunits);
                    [optotypes strokeVLineAtX: -distance4 y0: -length4 y1: length4];
                    [optotypes strokeVLineAtX: distance4 y0: -length4 y1: length4];
                    [optotypes strokeHLineAtX0: -length4 y: -distance4 x1: length4];
                    [optotypes strokeHLineAtX0: -length4 y: distance4 x1: length4];
                    break;
                case 4:  // surounding ring
                    CGContextSetLineWidth(cgc, stimStrengthInDeviceunits);
                    [optotypes strokeCircleAtX: 0 y: 0 radius: 1.5 * crowdingDistance / 2];
                    break;
                case 5: // surrunding square
                    const frameSize = 1.5 * crowdingDistance, frameSize2 = frameSize / 2;
                    CGContextSetLineWidth(cgc, stimStrengthInDeviceunits);
                    CGContextStrokeRect(cgc, CGRectMake(-frameSize2, -frameSize2, frameSize, frameSize));
                    break;
                case 6:    // row of optotypes
                    for (i = -2; i <= 2; i++) {
                        const directionPresentedX = [Misc iRandom: nAlternatives];
                        const tempX = i * crowdingDistance;
                        CGContextTranslateCTM(cgc,  -tempX, 0);
                        if (i != 0)  [optotypes drawLandoltWithGapInPx: stimStrengthInDeviceunits landoltDirection: directionPresentedX];
                        CGContextTranslateCTM(cgc,  +tempX, 0);
                    }  break;
            }
            CGContextRestoreGState(cgc);
        }
    }
    [self drawCenterFixMark];
    [super drawStimulusInRect: dirtyRect];
}


- (void) runEnd { //console.info("FractControllerAcuity>runEnd");
    switch (currentTestID) {
        case kTestAcuityLett:
        case kTestAcuityC:
        case kTestAcuityE:
        case kTestAcuityTAO:
            if (iTrial < nTrials) { //premature end
                [self setResultString: "Aborted"];
            } else {
                [self setResultString: [self acuityComposeResultString]];
            }
            break;
        case kTestAcuityVernier:
            break;
        case kTestAcuityLineByLine:
            [self setResultString: ""];
            break;
    }
    [super runEnd];
}


- (CPString) format4SnellenInFeet: (float) decVA {
    const distanceInMetres = [Settings distanceInCM] / 100.0;
    let distanceInFeet = distanceInMetres * 3.28084;
    if ([Settings forceSnellen20])  distanceInFeet = 20;
    let s = [Misc stringFromNumber: distanceInFeet decimals: 0 localised: YES] + "/";
    s += [Misc stringFromNumber: (distanceInFeet / decVA) decimals: 0 localised: YES];
    return s;
}
/*private function format4SnellenInMeter(theAcuityResult):String {
 let distanceInMetres=Prefs.distanceInCM.n / 100.0, distanceInFeet=distanceInMetres * 3.28084;
 return Utils.DeleteTrailing_PointZero(Utils.rStrNInt(distanceInMetres, 1, Prefs.decimalPointChar)) + "/" + Utils.DeleteTrailing_PointZero(Utils.rStrNInt(distanceInMetres / theAcuityResult,1,Prefs.decimalPointChar));
 }*/


/*	Transformation formula:   gap = c1 * exp(tPest * c2).
 Constants c1 and c2 are determined by these 2 condions: tPest==0 → gap=gStrokeMinimal;  tPest==1 → gap=gStrokeMaximal.
 =>c2 = ln(gStrokeMinimal / gStrokeMaximal)/(0 - 1);  c1 = gStrokeMinimal / exp(0 * c2)  */
- (float) acuityStimDeviceunitsFromThresholderunits: (float) tPest { // console.info("FractControllerAcuityC>stimDeviceunitsFromThresholderunits");
    const c2 = - Math.log(gStrokeMinimal / gStrokeMaximal), c1 = gStrokeMinimal;
    const deviceVal = c1 * Math.exp(tPest * c2); //console.info("DeviceFromPest " + tPest + " " + deviceVal);
    // ROUNDING for realisable gap values? @@@
    if ([Misc areNearlyEqual: deviceVal and: gStrokeMaximal]) {
        if (!isBonusTrial) {
            rangeLimitStatus = kRangeLimitValueAtCeiling; //console.info("max gap size!")
        }
    } else {
        if  ([Misc areNearlyEqual: deviceVal and: gStrokeMinimal]) {
            rangeLimitStatus = kRangeLimitValueAtFloor; //console.info("min gap size!");
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
    s += [Misc stringFromNumber: [MiscSpace decVAFromGapPixels: stimStrengthInDeviceunits] decimals: 2 localised: NO];
    return s;
}


- (float) acuityResultInDecVA {
    const resultInGapPx = stimStrengthInDeviceunits;
    let resultInDecVA = [MiscSpace decVAFromGapPixels: resultInGapPx];
    if ([Settings threshCorrection]) resultInDecVA *= gThresholdCorrection4Ascending;
    //console.info("FractControllerAcuity>acuityResultInDecVA: ", resultInDecVA);
    return resultInDecVA;
}


- (float) acuityResultInLogMAR {
    return [MiscSpace logMARfromDecVA: [self acuityResultInDecVA]];
}


- (float) acuityResultValue4Export {
    return [self acuityResultInLogMAR];
}


- (CPString) acuityComposeResultString { // 2021-05-02: now all formats are "ceilinged"
    const resultInDecVACeilinged = Math.min([Settings maxDisplayedAcuity], [self acuityResultInDecVA]);
    const resultInLogMARCeilinged = [MiscSpace logMARfromDecVA: resultInDecVACeilinged];
    let s = "";
    if ([Settings acuityFormatLogMAR]) {
        if (s.length > 1) s += ",  ";
        s += "LogMAR:" + [self rangeStatusIndicatorStringInverted: YES];
        s += [Misc stringFromNumber: resultInLogMARCeilinged decimals: 2 localised: YES];
        if (ci95String.length > 1) {
            s += ci95String;
        }
    }
    if ([Settings acuityFormatDecimal]) {
        if (s.length > 1) s += ",  ";
        s += "decVA:" + [self rangeStatusIndicatorStringInverted: NO];
        s += [Misc stringFromNumber: resultInDecVACeilinged decimals: 2 localised: YES];
    }
    if ([Settings acuityFormatSnellenFractionFoot]) {
        if (s.length > 1) s += ",  ";
        s += "Snellen fraction:" +  [self rangeStatusIndicatorStringInverted: NO];
        s += [self format4SnellenInFeet: resultInDecVACeilinged];
    }
    return s;
}


- (CPString) acuityComposeExportString { //console.info("FractController>acuityComposeExportString");
    if ([[self parentController] runAborted]) return "";
    let s = [self generalComposeExportString];
    const nDigits = 3;
    s += tab + "value" + tab + [Misc stringFromNumber: [self resultValue4Export] decimals: nDigits localised: YES];
    s += tab + "unit1" + tab + currentTestResultUnit
    s += tab + "distanceInCm" + tab + [Misc stringFromNumber: [Settings distanceInCM] decimals: 1 localised: YES];
    s += tab + "contrastWeber" + tab + [Misc stringFromNumber: [Settings contrastAcuityWeber] decimals: 1 localised: YES];
    s += tab + "unit2" + tab + "%";
    s += tab + "nTrials" + tab + [Misc stringFromNumber: nTrials decimals: 0 localised: YES];
    s += tab + "rangeLimitStatus" + tab + rangeLimitStatus;
    s += tab + "crowding" + tab + [Settings crowdingType];
    return s;
}


- (void) acuityModifyDeviceStimulusDIN01_02_04_08 {
    responseWasCorrectCumulative = responseWasCorrectCumulative && responseWasCorrect;
    const acuityStartDecimal = [MiscSpace decVAfromLogMAR: [Settings acuityStartingLogMAR]];
    switch (iTrial) {
        case 1:  stimStrengthInDeviceunits = [MiscSpace gapPixelsFromDecVA: acuityStartDecimal];  break;
        case 2:  if (responseWasCorrectCumulative) stimStrengthInDeviceunits = [MiscSpace gapPixelsFromDecVA: acuityStartDecimal * 2];  break;
        case 3:  if (responseWasCorrectCumulative) stimStrengthInDeviceunits = [MiscSpace gapPixelsFromDecVA: acuityStartDecimal * 4];  break;
        case 4:  if (responseWasCorrectCumulative) stimStrengthInDeviceunits = [MiscSpace gapPixelsFromDecVA: acuityStartDecimal * 8];  break;
    }
    if (stimStrengthInDeviceunits > gStrokeMaximal) stimStrengthInDeviceunits = gStrokeMaximal;
}


- (float) acuityCrowdingDistanceFromGap: (float) gap {
    let returnVal = 5 * gap + 2 * gap; // case 0
    switch ([Settings crowdingDistanceCalculationType]) {
        case 1:
            returnVal = 5 * gap + [MiscSpace pixelFromDegree: 2.6 / 60.0];  break;
        case 2:
            returnVal = [MiscSpace pixelFromDegree: 30 / 60.0];  break;
        case 3:
            returnVal = 10 * gap;  break;
    }
    if (currentTestID == kTestAcuityVernier) {
        returnVal *= 6 / 5;
    }
    return returnVal;
}


@end
