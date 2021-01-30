@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Settings.j"


@implementation Misc: CPObject {
}


+ (int) iRandom: (int) i {
    return Math.floor(Math.random() * i);
}


+ (float) limit01: (float) theValue {
    return [self limit: theValue lo: 0 hi: 1];
}
+ (float) limit: (float) theValue lo: (float) lo hi: (float) hi {
    if (theValue < lo) return lo;
    if (theValue > hi) return hi;
    return theValue;
}


+ (BOOL) isOdd: (int) i {
    return (i & 1);
}


+ (void) fullScreenOn: (BOOL) onOff {
    var element = document.documentElement;
    if (onOff) {
        if(element.requestFullscreen)
            element.requestFullscreen();
        else if(element.mozRequestFullScreen)
            element.mozRequestFullScreen();
        else if(element.webkitRequestFullscreen)
            element.webkitRequestFullscreen();
        else if(element.msRequestFullscreen)
            element.msRequestFullscreen();
    } else {
        if(document.exitFullscreen)
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
+ (void) copyString2Clipboard: (CPString) s { //console.info("AppController>copyString2Clipboard: ", s);
    try {
        navigator.clipboard.writeText(s); // only over https
    }
    catch(e) { // avoid global error catcher
        console.info("Error copying to clipboard: ", e);  // alert(e);
    }
}


+ (CPString) date2YYYY_MM_DD: (CPDate) theDate {
    return [CPString stringWithFormat:@"%04d-%02d-%02d", theDate.getFullYear(), theDate.getMonth() + 1, theDate.getDate()];
}


+ (CPString) date2HH_MM_SS: (CPDate) theDate {
    return [CPString stringWithFormat:@"%02d:%02d:%02d", theDate.getHours(), theDate.getMinutes(), theDate.getSeconds()];
}


//degree2pixel
//return millimeter2pixel(Math.tan(inDegree * Math.PI / 180.0) * Prefs.distanceInCM.n * 10.0);
+ (float) pixelFromDegree: (float) degs { //console.info("pixelFromDegree");
    var mm = Math.tan(degs * Math.PI / 180.0) * 10.0 * [Settings distanceInCM];
    return [self pixelFromMillimeter: mm];
}
+ (float) degreeFromPixel: (float) pixel { //console.info("Misc>pixelFromDegree");
    return 180.0 / Math.PI * Math.atan2([self millimeterFromPixel: pixel], [Settings distanceInCM] * 10.0);
}


+ (float) millimeterFromPixel: (float) pixel {
    return pixel * [Settings calBarLengthInMM] / [Settings calBarLengthInPixel];
}
+ (float) pixelFromMillimeter: (float) inMM { //console.info("pixelFromMillimeter");
    return inMM * [Settings calBarLengthInPixel] / [Settings calBarLengthInMM];
}


+ (float) visusFromGapPixels: (float) pixels {
    return 1.0 / 60.0 / [self degreeFromPixel: pixels];
}
+ (float) gapPixelsFromVisus: (float) decVA {
    return [self pixelFromDegree: (1.0 / 60.0 / decVA)];
}


+ (float) logMARfromDecVA: (float) decVA {
    return -Math.log10(decVA);
}
+ (float) decVAfromLogMAR: (float) logMAR {
    return -Math.pow(10, logMAR);
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


+ (BOOL) areNearlyEqual: (float)a and: (float) b {
    var epsilon = 1e-9, diff = Math.abs(a - b), magnitude = Math.abs(a) + Math.abs(b);
    return (diff / magnitude) < epsilon;
}



+ (void) makeFrameSquareFromWidth: (CPView) view {
    var rect1 = [view frame];
    [view setFrame: CGRectMake(rect1.origin.x, rect1.origin.y - (rect1.size.width - 16) / 2, rect1.size.width, rect1.size.width)];
}


//////////////////////////////////////
// Michelson ←→ Weber contrast.
// both contrasts are defined on a -100…100 scale
// Weber is manipulated so it is also point-symmetric to zero like Michelson

+ (float) contrastMichelsonPercentFromL1: (float) l1 l2: (float) l2 {
    return -(l1 - l2) / (l1 + l2) * 100;
}


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
+ (float) contrastMichelsonFromWeberPercent: (float) inWeberPercent {
    var inWeber = inWeberPercent /= 100;
    var outMichelson = inWeber / (2 - inWeber);
    return outMichelson * 100;
}
    
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
+ (float) contrastWeberPercentFromLogCSWeber: (float) logCS {
    var weberPercent = 100 * Math.pow(10, -logCS);
    return weberPercent;
}

+ (float) getBrightnessViaCSSfromColor: (CPColor) aColor {
    return [[CPColor colorWithCSSString: [aColor cssString]] brightnessComponent];
}


                               
+ (void) testContrastConversion {
    for (var i = -100; i <= 100; i += 10) {
        var w = [Misc contrastWeberFromMichelsonPercent: i];
        console.info("contrastM: ", i, ", W: ", w, ", M: ", [Misc contrastMichelsonFromWeberPercent: w]);
    }
}


//////////////////////////////////////////////////////////////////
////////////////////////////////////// luminance <—> devicegray
// scales
// contrast: -100 … 100 (both for Michelson & Weber
// “devicegray": 0 … 1 AFTER gamma correction
// "luminance": (0…1) as "normalised" luminance as would be measured in cd/m²
//////////////////////////////////////////////////////////////////

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


/*///////////////////////////////////// devicegray <—> RGB
+ (int) devicegray2RGB_UNFERTIG: (float) thedevicegray {
    var g = limit(0, Math.round(255 * thedevicegray), 255);
    return (g | g << 8 | g << 16);
}

+ (float) luminance2RGB: (float) luminance {
    var temp1 = devicegrayFromLuminance(luminance);
    return devicegray2RGB(temp1);
}*/


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

// luminance units
// ===============
//1. luminance (0…1) as "normalised" luminance as would be measured in cd/m2
//2. contrast on a (0…1) scale, corresponding to (0…100%)
//3. "devicegray": luminance in device values, that is gamma-corrected, on a (0…1) scale
//4. RGB: devicegray converted to RGB on a (3 x 0x00…0xFF) scale
////////////////////////////////////// luminance <—> contrast
static public  function lumHiLo2contrast(lumLo:Number, lumHi:Number):Number {
if (lumLo > lumHi) { // sort if necessary
var temp:Number = lumHi;  lumHi = lumLo; lumLo = temp;
}
var c:Number = (lumHi - lumLo) / (lumHi + lumLo);
return limit(0.0, c, 1.0);
}
static public function rgbHiLo2contrast(rgbLo:uint, rgbHi:uint): Number {
var devicegrayLo:Number = RGB2L(rgbLo),  devicegrayHi:Number = RGB2L(rgbHi);
if (devicegrayLo>devicegrayHi) { // sort if necessary
var temp:Number = devicegrayHi;  devicegrayHi = devicegrayLo;  devicegrayLo = temp;
}
var lumLo:Number = luminanceFromDevicegray(devicegrayLo),  lumHi:Number = luminanceFromDevicegray(devicegrayHi);
//console.info(lumLo, " -- ", lumHi);
return lumHiLo2contrast(lumLo, lumHi);
}
////////////////////////////////////// luminance & contrast <—> RGB
static public function contrast2HiRGB(contrast:Number):uint {
var temp1:Number = lumContrast2lumHi(0.5, contrast);
temp1 = devicegrayFromLuminance(temp1);
return devicegray2RGB(temp1);
}
static public function contrast2LoRGB(contrast:Number):uint {
var temp1:Number = lumContrast2lumLo(0.5, contrast);
temp1=devicegrayFromLuminance(temp1);
return devicegray2RGB(temp1);
//			console.info("contrast2LoRGB, contrast: ",contrast,", temp2: ", devicegray2RGB(temp1));
}
//////////////////////////////////////
// average the r, g, and b value to represent the gray number (from 0 to 255)
static public function RGB2L(inRGB:uint):uint {
var r:uint = (inRGB >> 16) & 0xFF,  g:uint = (inRGB >> 8) & 0xFF,  b:uint = inRGB & 0xFF;
return (Math.round((r + g + b)/3.0));
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
    if (theValueAbs < 0.0001) {
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
