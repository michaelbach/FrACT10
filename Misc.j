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


+ (BOOL) copyString2ClipboardAlert: (CPString) s { //console.info("AppController>copyString2ClipboardAlert");
    var alert = [CPAlert alertWithMessageText: "Question:"
    defaultButton: "Yes, put result → clipboard" alternateButton: "No" otherButton: nil
                informativeTextWithFormat: "\rShall we place the result details into the clipboard?\r(So you can paste them into a spreadsheet.)\r"];
    [alert setAlertStyle: CPInformationalAlertStyle];
    [[alert window] setFrameOrigin: CGPointMake(200, 200)];
    [alert runModalWithDidEndBlock: function(alert, returnCode) {
        switch (returnCode) {
            case 1: /*console.info("ok, dann nicht");*/  break;
            case 0:
                navigator.clipboard.writeText(s);
                [[CPNotificationCenter defaultCenter] postNotificationName: "buttonExportEnableYESorNO" object: 0];
                break;
        }
    }];
}


+ (CPString) date2YYYY_MM_DD: (CPDate) theDate {
    return [CPString stringWithFormat:@"%04d-%02d-%02d", theDate.getFullYear(), theDate.getMonth() + 1, theDate.getDate()];
}


+ (CPString) date2HH_MM_SS: (CPDate) theDate {
    return [CPString stringWithFormat:@"%02d:%02d:%02d", theDate.getHours(), theDate.getMinutes() + 1, theDate.getSeconds()];
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


//////////////////////////////////////
// Michelson ←→ Weber contrast.
// both contrasts are defined on a 0…100 scale
+ (float) contrastWeberFromMichelson: (float) inMichelson {
    inMichelson /= 100;
    weberValue = 2.0 * inMichelson / (1.0 + inMichelson);
    return weberValue * 100;
}
+ (float) contrastMichelsonFromWeber: (float) inWeber {
    inWeber /= 100;
    michelsonValue = inWeber / (2.0 - inWeber);
    return michelsonValue * 100;
}


//////////////////////////////////////////////////////////////////
////////////////////////////////////// luminance <—> devicegrey
// scales
// contrast: -100 … 100%
// “devicegrey": 0 … 1 AFTER gamma correction
// "luminance": (0…1) as "normalised" luminance as would be measured in cd/m²
//////////////////////////////////////////////////////////////////

+ (float) devicegreyFromLuminance: (float) luminance {
    return Math.pow(luminance, 1.0 / [Settings gammaValue]);
}
                    
+ (float) luminanceFromDevicegrey: (float) g {
    return Math.pow(g, [Settings gammaValue]);
}

+ (float) lowerLuminanceFromContrast: (float) contrast { //console.info("lowerLuminanceFromContrast");
    return [self limit01: [self limit01: 0.5 - 0.5 * contrast]];
}
+ (float) upperLuminanceFromContrast: (float) contrast { //console.info("highLuminanceFromContras");
    return [self limit01: [self limit01: 0.5 + 0.5 * contrast]];
}


/*///////////////////////////////////// devicegrey <—> RGB
+ (int) devicegrey2RGB_UNFERTIG: (float) thedevicegrey {
    var g = limit(0, Math.round(255 * thedevicegrey), 255);
    return (g | g << 8 | g << 16);
}

+ (float) luminance2RGB: (float) luminance {
    var temp1 = devicegreyFromLuminance(luminance);
    return devicegrey2RGB(temp1);
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
//3. "devicegrey": luminance in device values, that is gamma-corrected, on a (0…1) scale
//4. RGB: devicegrey converted to RGB on a (3 x 0x00…0xFF) scale
////////////////////////////////////// luminance <—> contrast
static public  function lumHiLo2contrast(lumLo:Number, lumHi:Number):Number {
if (lumLo > lumHi) { // sort if necessary
var temp:Number = lumHi;  lumHi = lumLo; lumLo = temp;
}
var c:Number = (lumHi - lumLo) / (lumHi + lumLo);
return limit(0.0, c, 1.0);
}
static public function rgbHiLo2contrast(rgbLo:uint, rgbHi:uint): Number {
var devicegreyLo:Number = RGB2L(rgbLo),  devicegreyHi:Number = RGB2L(rgbHi);
if (devicegreyLo>devicegreyHi) { // sort if necessary
var temp:Number = devicegreyHi;  devicegreyHi = devicegreyLo;  devicegreyLo = temp;
}
var lumLo:Number = luminanceFromDevicegrey(devicegreyLo),  lumHi:Number = luminanceFromDevicegrey(devicegreyHi);
//console.info(lumLo, " -- ", lumHi);
return lumHiLo2contrast(lumLo, lumHi);
}
////////////////////////////////////// luminance & contrast <—> RGB
static public function contrast2HiRGB(contrast:Number):uint {
var temp1:Number = lumContrast2lumHi(0.5, contrast);
temp1 = devicegreyFromLuminance(temp1);
return devicegrey2RGB(temp1);
}
static public function contrast2LoRGB(contrast:Number):uint {
var temp1:Number = lumContrast2lumLo(0.5, contrast);
temp1=devicegreyFromLuminance(temp1);
return devicegrey2RGB(temp1);
//			console.info("contrast2LoRGB, contrast: ",contrast,", temp2: ", devicegrey2RGB(temp1));
}
//////////////////////////////////////
// average the r, g, and b value to represent the grey number (from 0 to 255)
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
