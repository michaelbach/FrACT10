//    History
//    =======
//
//    2020-11-09 created, class "FractControllerAcuity" inheriting from "FractController"


@import "FractController.j"
@implementation FractControllerAcuity: FractController {
}


// this manages crowding, after the optotypes have been drawn
- (void) drawStimulusInRect: (CGRect) dirtyRect { //console.info("FractController>drawStimulusInRect");
    if ([Settings crowdingType] > 0) {
        if (currentTestName != "Acuity_Vernier") { // don't do crowding with Vernier etc.
            CGContextSaveGState(cgc);
            CGContextTranslateCTM(cgc, viewWidth / 2, viewHeight / 2); // origin to center
            CGContextTranslateCTM(cgc, -xEcc, -yEcc);
            var i, crowdingDistance = [self acuityCrowdingDistanceFromGap: stimStrengthInDeviceunits];
            switch ([Settings crowdingType]) {
                case 0:  break; // should not occur here
                case 1: // flanking bars
                    var distance2 = 1.5 * crowdingDistance / 2;
                    var length2 = stimStrengthInDeviceunits * 2.5;
                    CGContextSetLineWidth(cgc, stimStrengthInDeviceunits);
                    [optotypes strokeVLineAtX: -distance2 y0: -length2 y1: length2];
                    [optotypes strokeVLineAtX: distance2 y0: -length2 y1: length2];
                    break;
                case 2:    // flanking rings
                    for (i = -1; i <= 1; i++) { //console.info(i);
                        var tempX = i * crowdingDistance;
                        CGContextTranslateCTM(cgc,  -tempX, 0);
                        if (i != 0)  [optotypes drawLandoltWithGapInPx: stimStrengthInDeviceunits landoltDirection: -1];
                        CGContextTranslateCTM(cgc,  +tempX, 0);
                    }  break;
                case 3:    // surounding bars
                    var distance2 = 1.5 * crowdingDistance / 2;
                    var length2 = stimStrengthInDeviceunits * 4;
                    CGContextSetLineCap(cgc,  kCGLineCapRound);
                    CGContextSetLineWidth(cgc, stimStrengthInDeviceunits);
                    [optotypes strokeVLineAtX: -distance2 y0: -length2 y1: length2];
                    [optotypes strokeVLineAtX: distance2 y0: -length2 y1: length2];
                    [optotypes strokeHLineAtX0: -length2 y: -distance2 x1: length2];
                    [optotypes strokeHLineAtX0: -length2 y: distance2 x1: length2];
                    break;
                case 4:  // surounding ring
                    CGContextSetLineWidth(cgc, stimStrengthInDeviceunits);
                    [optotypes strokeCircleAtX: 0 y: 0 radius: 1.5 * crowdingDistance / 2];
                    break;
                case 5: // surrunding square
                    var frameSize = 1.5 * crowdingDistance, frameSize2 = frameSize / 2;
                    CGContextSetLineWidth(cgc, stimStrengthInDeviceunits);
                    CGContextStrokeRect(cgc, CGRectMake(-frameSize2, -frameSize2, frameSize, frameSize));
                    break;
                case 6:    // row of optotypes
                    for (i = -2; i <= 2; i++) {
                        var directionPresentedX = [Misc iRandom: nAlternatives];
                        var tempX = i * crowdingDistance;
                        CGContextTranslateCTM(cgc,  -tempX, 0);
                        if (i != 0)  [optotypes drawLandoltWithGapInPx: stimStrengthInDeviceunits landoltDirection: directionPresentedX];
                        CGContextTranslateCTM(cgc,  +tempX, 0);
                    }  break;
            }
            CGContextRestoreGState(cgc);
        }
    }
    [super drawStimulusInRect: dirtyRect];
}


- (void)runEnd { //console.info("FractController>runEnd");
    if (currentTestName != "Acuity_Vernier") {
        if (iTrial < nTrials) { //premature end
            [self setResultString: @"Aborted"];
        } else {
            [self setResultString: [self acuityComposeResultString]];
        }
    }
    [super runEnd];
}


- (CPString) format4SnellenInFeet: (float) decVA {
    var distanceInMetres = [Settings distanceInCM] / 100.0;
    var distanceInFeet = distanceInMetres * 3.28084;
    if ([Settings forceSnellen20])  distanceInFeet = 20;
    var s = [Misc stringFromNumber: distanceInFeet decimals: 0 localised: YES] + "/";
    s += [Misc stringFromNumber: (distanceInFeet / decVA) decimals: 0 localised: YES];
    return s;
}
/*private function format4SnellenInMeter(theAcuityResult):String {
 var distanceInMetres=Prefs.distanceInCM.n / 100.0, distanceInFeet=distanceInMetres * 3.28084;
 return Utils.DeleteTrailing_PointZero(Utils.rStrNInt(distanceInMetres, 1, Prefs.decimalPointChar)) + "/" + Utils.DeleteTrailing_PointZero(Utils.rStrNInt(distanceInMetres / theAcuityResult,1,Prefs.decimalPointChar));
 }*/


/*	Transformation formula:   gap = c1 * exp(tPest * c2).
 Constants c1 and c2 are determined by thesse 2 contions: tPest==0 → gap=gapMinimal;  tPest==1 → gap=gapMaximal.
 =>c2 = ln(gapMinimal / gapMaximal)/(0 - 1);  c1 = gapMinimal / exp(0 * c2)  */
- (float) acuitystimDeviceunitsFromThresholderunits: (float) tPest { //console.info("FractControllerVAC>stimDeviceunitsFromThresholderunits");
    var c2 = - Math.log(gapMinimal / gapMaximal), c1 = gapMinimal;
    var deviceVal = c1 * Math.exp(tPest * c2); //console.info("DeviceFromPest " + tPest + " " + deviceVal);
    // ROUNDING for realisable gap values? @@@
    if ([Misc areNearlyEqual: deviceVal and: gapMaximal]) {
        if (!isBonus) {
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


- (float) acuityStimThresholderunitsFromDeviceunits: (float) d { //console.info("FractControllerVAC>stimThresholderunitsFromDeviceunits");
    var c2 = - Math.log(gapMinimal / gapMaximal), c1 = gapMinimal;
    var retVal = Math.log(d / c1) / c2; //console.info("PestFromDevice " + d + " " + retVal);
    return retVal;
}


- (CPString) acuityComposeTrialInfoString {
    var s = iTrial + "/" + nTrials + " ";
    s += [Misc stringFromNumber: [Misc visusFromGapPixels: stimStrengthInDeviceunits] decimals: 2 localised: YES];
    return s;
}


- (float) acuityResultInDecVA {
    var resultInGapPx = stimStrengthInDeviceunits;
    var resultInDecVA = [Misc visusFromGapPixels: resultInGapPx];
    resultInDecVA *= ([Settings threshCorrection]) ? 0.891 : 1.0;// Korrektur für Schwellenunterschätzung aufsteigender Verfahren
    return resultInDecVA;
}


- (float) acuityResultInLogMAR {
    return [Misc logMARfromDecVA: [self acuityResultInDecVA]];
}


- (CPString) acuityComposeResultString {
    var resultInGapPx = stimStrengthInDeviceunits;
    var resultInDecVA = [Misc visusFromGapPixels: resultInGapPx];
    resultInDecVA *= ([Settings threshCorrection]) ? 0.891 : 1.0;// Korrektur für Schwellenunterschätzung aufsteigender Verfahren
    resultInDecVA = Math.min([Settings maxDisplayedAcuity], resultInDecVA);
    var resultInLogMAR = [Misc logMARfromDecVA: resultInDecVA];
    
    // console.info("rangeLimitStatus: ", rangeLimitStatus);
    var s = "";
    if ([Settings acuityFormatLogMAR]) {
        if (s.length > 1) s += ",  ";
        s += "LogMAR:" + [self rangeStatusIndicatorStringInverted: YES];
        s += [Misc stringFromNumber: resultInLogMAR decimals: 2 localised: YES];
    }
    if ([Settings acuityFormatDecimal]) {
        if (s.length > 1) s += ",  ";
        s += "decVA:" + [self rangeStatusIndicatorStringInverted: NO];
        s += [Misc stringFromNumber: resultInDecVA decimals: 2 localised: YES];
    }
    if ([Settings acuityFormatSnellenFractionFoot]) {
        if (s.length > 1) s += ",  ";
        s += "Snellen fraction:" +  [self rangeStatusIndicatorStringInverted: NO];
        s += [self format4SnellenInFeet: resultInDecVA];
    }
    return s;
}


- (float) acuityResultValue4Export {
    return [self acuityResultInLogMAR];
}


- (CPString) acuityComposeExportString { //console.info("FractController>composeExportString");
    var s = "";
    if ([[self parentController] runAborted]) return;
    var tab = "\t", crlf = "\n", nDigits = 4, now = [CPDate date];
    s = "Vs" + tab + "4"; // version
    s += tab + "decimalMark" + tab + [Settings decimalMarkChar];
    s += tab + "date" + tab + [Misc date2YYYY_MM_DD: now] + tab + "time" + tab + [Misc date2HH_MM_SS: now];
    s += tab + "test" + tab + currentTestName;
    s += tab + "value" + tab + [Misc stringFromNumber: [self resultValue4Export] decimals: nDigits localised: YES];
    s += tab + "unit" + tab + currentTestResultUnit
    s += tab + "distanceInCm" + tab + [Misc stringFromNumber: [Settings distanceInCM] decimals: 1 localised: YES];
    s += tab + "contrastWeber" + tab + [Misc stringFromNumber: [Settings contrastAcuityWeber] decimals: 1 localised: YES];
    s += tab + "unit" + tab + "%";
    s += tab + "nTrials" + tab + [Misc stringFromNumber: nTrials decimals: 0 localised: YES];
    s += tab + "rangeLimitStatus" + tab + rangeLimitStatus;
    s += tab + "crowding" + tab + [Settings crowdingType];
    //s += tab + "XX" + tab + YY;
    s += crlf; //console.info("FractController>date: ", s);
    return s;
}


- (void) acuityModifyDeviceStimulusDIN01_02_04_08 {
    responseWasCorrectCumulative = responseWasCorrectCumulative && responseWasCorrect;
    switch (iTrial) {
        case 1:  stimStrengthInDeviceunits = [Misc gapPixelsFromVisus: 0.1];  break;
        case 2:  if (responseWasCorrectCumulative) stimStrengthInDeviceunits = [Misc gapPixelsFromVisus: 0.2];  break;
        case 3:  if (responseWasCorrectCumulative) stimStrengthInDeviceunits = [Misc gapPixelsFromVisus: 0.4];  break;
        case 4:  if (responseWasCorrectCumulative) stimStrengthInDeviceunits = [Misc gapPixelsFromVisus: 0.8];  break;
    }
}


- (float) acuityCrowdingDistanceFromGap: (float) gap {
    var returnVal = 5 * gap + 2 * gap; // case 0
    switch ([Settings crowdingDistanceCalculationType]) {
        case 1:
            returnVal = 5 * gap + [Misc pixelFromDegree: 2.6 / 60.0];  break;
        case 2:
            returnVal = [Misc pixelFromDegree: 30 / 60.0];  break;
        case 3:
            returnVal = 10 * gap;  break;
    }
    if (currentTestName == "Acuity_TAO") {
        returnVal *= 6 / 5;
    }
    return returnVal;
}


@end
