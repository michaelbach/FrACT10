/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, michael.bach@uni-freiburg.de, <https://michaelbach.de>

Misc.j

*/


@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Settings.j"


/**
 A collection of "miscellaneous" function.
 All a class variables for easy global access
 */
@implementation Misc: CPObject {
}


/**
 Returns random integer from 0 to i-1 */
+ (int) iRandom: (int) i {
    return Math.floor(Math.random() * i);
}


/**
 limits the input value to lie between 0 and 1
 */
+ (float) limit01: (float) theValue {
    return [self limit: theValue lo: 0 hi: 1];
}
/**
 limits the input value to lie between 2 values
 */
+ (float) limit: (float) theValue lo: (float) lo hi: (float) hi { // limit the input value to lie between lo and hi
    if (theValue < lo) return lo;
    if (theValue > hi) return hi;
    return theValue;
}


+ (BOOL) isOdd: (int) i {
    return (i & 1);
}


/**
 Switching to/from fullscreen. That was quite difficult to figure out
 */
+ (void) fullScreenOn: (BOOL) onOff {
    var element = document.documentElement;
    if (onOff) {
        if (element.requestFullscreen)
            element.requestFullscreen();
        else if(element.mozRequestFullScreen)
            element.mozRequestFullScreen();
        else if(element.webkitRequestFullscreen)
            element.webkitRequestFullscreen();
        else if(element.msRequestFullscreen)
            element.msRequestFullscreen();
    } else {
        if (document.exitFullscreen)
            document.exitFullscreen();
        else if(document.mozCancelFullScreen)
            document.mozCancelFullScreen();
        else if(document.webkitExitFullscreen)
            document.webkitExitFullscreen();
        else if(document.msExitFullscreen)
            document.msExitFullscreen();
    }
}
+ (BOOL) isFullScreen {
    var full_screen_element = document.fullscreenElement || document.webkitFullscreenElement || document.mozFullScreenElement || document.msFullscreenElement || null;
    if(full_screen_element === null)// If no element is in full-screen
        return false;
    else
        return true;
}


+ (void) copyString2ClipboardWithDialog: (CPString) s { //console.info("AppController>copyString2ClipboardWithDialog");
    var alert = [CPAlert alertWithMessageText: "Question:"
    defaultButton: "Yes, put result → clipboard" alternateButton: "No" otherButton: nil
                informativeTextWithFormat: "\rShall we place the result details into the clipboard?\r(So you can paste them into a spreadsheet.)\r"];
    [alert setAlertStyle: CPInformationalAlertStyle];
    [[alert window] setFrameOrigin: CGPointMake(200, 200)];
    [alert runModalWithDidEndBlock: function(alert, returnCode) {
        switch (returnCode) {
            case 1: /*console.info("ok, dann nicht");*/  break;
            case 0:
                [self copyString2Clipboard: s];
                [[CPNotificationCenter defaultCenter] postNotificationName: "buttonExportEnableYESorNO" object: 0];
                break;
        }
    }];
}
/**
 Utility to copy a string to the clipboard which surprisingly now works in all(?) modern browsers
 */
+ (void) copyString2Clipboard: (CPString) s { //console.info("AppController>copyString2Clipboard: ", s);
    try {
        navigator.clipboard.writeText(s); // only over https
    }
    catch(e) { // avoid the global error catcher
        console.info("Error copying result to clipboard: ", e);  // alert(e);
    }
}


+ (CPString) date2YYYY_MM_DD: (CPDate) theDate {
    return [CPString stringWithFormat:@"%04d-%02d-%02d", theDate.getFullYear(), theDate.getMonth() + 1, theDate.getDate()];
}


/**
 ISO date formatter
 */
+ (CPString) date2HH_MM_SS: (CPDate) theDate {
    return [CPString stringWithFormat:@"%02d:%02d:%02d", theDate.getHours(), theDate.getMinutes(), theDate.getSeconds()];
}


/**
 Convert degrees to pixels
 */
+ (float) pixelFromDegree: (float) degs { //console.info("pixelFromDegree");
    var mm = Math.tan(degs * Math.PI / 180.0) * 10.0 * [Settings distanceInCM];
    return [self pixelFromMillimeter: mm];
}
/**
 Convert pixels to degrees
 */
+ (float) degreeFromPixel: (float) pixel { //console.info("Misc>pixelFromDegree");
    return 180.0 / Math.PI * Math.atan2([self millimeterFromPixel: pixel], [Settings distanceInCM] * 10.0);
}


+ (float) millimeterFromPixel: (float) pixel {
    return pixel * [Settings calBarLengthInMM] / [Settings calBarLengthInPixel];
}
+ (float) pixelFromMillimeter: (float) inMM { //console.info("pixelFromMillimeter");
    return inMM * [Settings calBarLengthInPixel] / [Settings calBarLengthInMM];
}


/**
 Given gap size in pixels, calculates decimla VA
 */
+ (float) decVAFromGapPixels: (float) pixels { // "decVA": visual acuity in decimal format
    return 1.0 / 60.0 / [self degreeFromPixel: pixels];
}
/**
 And the inverse
 */
+ (float) gapPixelsFromDecVA: (float) decVA {
    return [self pixelFromDegree: (1.0 / 60.0 / decVA)];
}


/**
 Given decimal VA, returns equivalent LogMAR
 */
+ (float) logMARfromDecVA: (float) decVA {
    return -Math.log10(decVA);
}
/**
 And the inverse
 */
+ (float) decVAfromLogMAR: (float) logMAR {
    return Math.pow(10, -logMAR);
}


+ (CPString) stringFromInteger: (int) num { //console.info("Misc>stringFromInteger");
    return [CPString stringWithFormat: @"%d", num];
}


+ (CPString) stringFromNumber: (float) num decimals: (int) decs localised: (BOOL) locd { //console.info("Misc>stringFromNumber");
    if (decs < 1)  return [self stringFromInteger: num];
    var fmt = @"%6." + [CPString stringWithFormat:@"%d", decs] + "f";
    var str = [CPString stringWithFormat: fmt, num];
    while ([str hasPrefix:@" "] && [str length] > 1) {
        str = [str substringFromIndex:1];
    }
    while ([str hasSuffix:@"00"]) {
        str = [str substringToIndex:str.length-(str.length>0)];
    }
    if ([str hasSuffix:@"."]) str = str + "0";
    if (locd && ([Settings decimalMarkChar] != ".")) {
        str = [str stringByReplacingOccurrencesOfString:@"." withString:@","];
    }
//    console.info("Misc>stringFromNumber", fmt, str);
    return str;
}


/**
 Given an epsilon, we test for "equality" of 2 floating point numbers
 */
+ (BOOL) areNearlyEqual: (float)a and: (float) b {
    var epsilon = 1e-9, diff = Math.abs(a - b), magnitude = Math.abs(a) + Math.abs(b);
    return (diff / magnitude) < epsilon;
}


+ (void) makeFrameSquareFromWidth: (CPView) view {
    var rect1 = [view frame];
    [view setFrame: CGRectMake(rect1.origin.x, rect1.origin.y - (rect1.size.width - 16) / 2, rect1.size.width, rect1.size.width)];
}


/**
 Michelson ←→ Weber contrast.
 both contrasts are defined on a -100…100 scale
 Weber is modified so it is also point-symmetric to zero like Michelson
 */
+ (float) contrastMichelsonPercentFromL1: (float) l1 l2: (float) l2 {
    return -(l1 - l2) / (l1 + l2) * 100;
}
/**
 Transform Michelson → Weber
 */
+ (float) contrastWeberFromMichelsonPercent: (float) inMichelsonPercent {
    var inMichelson = inMichelsonPercent /= 100,  outWeber;
    if (inMichelson >= 0) {
        outWeber = 2.0 * inMichelson / (1.0 + inMichelson);
    } else {
        inMichelson *= -1;
        outWeber = 2.0 * inMichelson / (1.0 + inMichelson);
        outWeber *= 1;
    }
    // console.info("contrastWeberFromMichelsonPercent: ", inMichelson * 100, outWeber * 100);
    return outWeber * 100;
}
/**
 And the inverse
 */
+ (float) contrastMichelsonFromWeberPercent: (float) inWeberPercent {
    var inWeber = inWeberPercent /= 100;
    var outMichelson = inWeber / (2 - inWeber);
    return outMichelson * 100;
}
    

/**
 Transform Weber → logCSWeber
 */
+ (float) contrastLogCSWeberFromWeberPercent: (float) weberPercent {
    weberPercent /= 100;
    var logCS;
    if (weberPercent > 0.0001) { // avoid log of zero
       logCS = Math.log10(1 / weberPercent);
    } else {
        logCS = 4.0;
    }
    return logCS;
}
/**
 And the inverse
 */
+ (float) contrastWeberPercentFromLogCSWeber: (float) logCS {
    var weberPercent = 100 * Math.pow(10, -logCS);
    return weberPercent;
}


/**
 Returns the brightness component given a CPColor
 */
+ (float) getBrightnessViaCSSfromColor: (CPColor) aColor {
    return [[CPColor colorWithCSSString: [aColor cssString]] brightnessComponent];
}

                               
+ (void) testContrastConversion {
    for (var i = -100; i <= 100; i += 10) {
        var w = [Misc contrastWeberFromMichelsonPercent: i];
        console.info("contrastM: ", i, ", W: ", w, ", M: ", [Misc contrastMichelsonFromWeberPercent: w]);
    }
}


/**
 scale transformations luminance ⇄ devicegray
 contrast: -100 … 100 (both for Michelson & Weber)
 “devicegray": 0 … 1 AFTER gamma correction
 "luminance": (0…1) as "normalised" luminance as would be measured in cd/m²
 */
+ (float) devicegrayFromLuminance: (float) luminance {
    return Math.pow(luminance, 1.0 / [Settings gammaValue]);
}
                    
+ (float) luminanceFromDevicegray: (float) g {
    return Math.pow(g, [Settings gammaValue]);
}

+ (float) lowerLuminanceFromContrastMilsn: (float) contrast { //console.info("lowerLuminanceFromContrastMilsn");
    return [self limit01: [self limit01: 0.5 - 0.5 * contrast / 100]];
}
+ (float) upperLuminanceFromContrastMilsn: (float) contrast { //console.info("highLuminanceFromContras");
    return [self limit01: [self limit01: 0.5 + 0.5 * contrast / 100]];
}


+ (float) lowerLuminanceFromContrastLogCSWeber: (float) logCSW {
    var weberPercent = [Misc contrastWeberPercentFromLogCSWeber: logCSW];
    var michelson = [self contrastMichelsonFromWeberPercent: weberPercent];
    return [self lowerLuminanceFromContrastMilsn: michelson];
}
+ (float) upperLuminanceFromContrastLogCSWeber: (float) logCSW {
    var weberPercent = [Misc contrastWeberPercentFromLogCSWeber: logCSW];
    var michelson = [self contrastMichelsonFromWeberPercent: weberPercent];
    return [self upperLuminanceFromContrastMilsn: michelson];
}


+ (float) contrastMichelsonPercentFromDevicegray1: (float) g1 g2: g2 {
    var l1 = [self luminanceFromDevicegray: g1], l2 = [self luminanceFromDevicegray: g2];
    return [self contrastMichelsonPercentFromL1: l1 l2: l2];
}
+ (float) contrastMichelsonPercentFromColor1: (float) c1 color2: c2 {
    var g1 = [self getBrightnessViaCSSfromColor: c1], g2 = [self getBrightnessViaCSSfromColor: c2];
    return [self contrastMichelsonPercentFromDevicegray1: g1 g2: g2];
}


/* ///////////////////////////////////// OLD, not in use (yet) */

/*
static public function spatFreq2periodInPix(spatFreqInCPD:Number):Number {
return 2.0 * PixelFromDegree(1.0 / spatFreqInCPD / 2.0)
}

static public function periodInPix2spatFreq(periodInPix:Number):Number {
return 0.5 / (DegreeFromPixel(periodInPix / 2.0))
}

static public function cpd2logMAR(cpd:Number):Number {
return log10(30.0 / cpd);
}

static public function logMAR2cpd(logMAR:Number):Number {
return 30.0 / (Math.pow(10, logMAR));
}
*/

/*
 // formats a number to given precision
+ (CPString) rStrFromNumber: num precision: (int) precision {
    if (isNaN(precision)) {
        var precision=0;
    }
    if (precision <= 0)	 {	// no decimal points
        return String(Math.round(num));
    }
    //return String(Math.floor(num) + "." + Math.floor(num * Math.pow(10, precision)).toString().substr(-precision));//this is from Macromedia, but wrong all the same… 15.12.2003
    var temp = Math.pow(10, precision);
    temp = Math.round(num * temp) / temp;
    return String(temp);
}


// formats a number to a “sensible” precision
static public  function rStr(theValue:Number):String {
    var precision:int=1,theValueAbs:Number=Math.abs(theValue);
    if (theValueAbs < 0.0001) { // this could be easier using log10…
        precision=7;
    } else {
        if (theValueAbs < 0.001) {
            precision=6;
        } else {
            if (theValueAbs < 0.01) {
                precision=5;
            } else {
                if (theValueAbs < 0.1) {
                    precision=4;
                } else {
                    if (theValueAbs < 1.0) {
                        precision=3;
                    } else {
                        if (theValueAbs < 10.0) {
                            precision=2;
                        }
                    }
                }
            }
        }
    }
    return rStrN(theValue, precision);
}
*/


@end
