@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Settings.j"


@implementation Misc: CPObject {
}


+ (int) iRandom: (int) i {
    return Math.floor(Math.random() * i);
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


+ (void) copyString2ClipboardAlert: (CPString) s { //console.log("AppController>copyString2ClipboardAlert");
    var alert = [CPAlert alertWithMessageText: "Question:"
    defaultButton: "Yes, put result → clipboard" alternateButton: "No" otherButton: nil
                informativeTextWithFormat: "\rShall we place the result details into the clipboard?\r(So you can paste them into a spreadsheet.)\r"];
    [alert setAlertStyle: CPInformationalAlertStyle];
    [alert runModalWithDidEndBlock: function(alert, returnCode) {
        switch (returnCode) {
            case 1: /*console.log("ok, dann nicht");*/  break;
            case 0: navigator.clipboard.writeText(s); break;
        }
    }];
    [[alert window] setFrameOrigin: CGPointMake(200, 200)];
}


+ (CPString) date2YYYY_MM_DD: (CPDate) theDate {
    return [CPString stringWithFormat:@"%04d-%02d-%02d", theDate.getFullYear(), theDate.getMonth() + 1, theDate.getDate()];
}


+ (CPString) date2HH_MM_SS: (CPDate) theDate {
    return [CPString stringWithFormat:@"%02d:%02d:%02d", theDate.getHours(), theDate.getMinutes() + 1, theDate.getSeconds()];
}


//degree2pixel
//return millimeter2pixel(Math.tan(inDegree * Math.PI / 180.0) * Prefs.distanceInCM.n * 10.0);
+ (float) pixelFromDegree: (float) degs { //console.log("pixelFromDegree");
    var mm = Math.tan(degs * Math.PI / 180.0) * 10.0 * [Settings distanceInCM];
    return [self pixelFromMillimeter: mm];
}
+ (float) degreeFromPixel: (float) pixel { //console.log("Misc>pixelFromDegree");
    return 180.0 / Math.PI * Math.atan2([self millimeterFromPixel: pixel], [Settings distanceInCM] * 10.0);
}


+ (float) millimeterFromPixel: (float) pixel {
    return pixel * [Settings calBarLengthInMM] / [Settings calBarLengthInPixel];
}
+ (float) pixelFromMillimeter: (float) inMM { //console.log("pixelFromMillimeter");
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


+ (CPString) stringFromInteger: (int) num { //console.log("Misc>stringFromInteger");
    return [CPString stringWithFormat: @"%d", num];
}


+ (CPString) stringFromNumber: (float) num decimals: (int) decs localised: (BOOL) locd { //console.log("Misc>stringFromNumber");
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
//    console.log("Misc>stringFromNumber", fmt, str);
    return str;
}


+ (BOOL) areNearlyEqual: (float)a and: (float) b {
    var epsilon = 1e-9, diff = Math.abs(a - b), magnitude = Math.abs(a) + Math.abs(b);
    return (diff / magnitude) < epsilon;
}


////////////////////////////////////// luminance <—> deviceGrey
+ (float) luminance2deviceGrey: (float) luminance {
    return Math.pow(luminance, 1.0 / [Settings gammaValue]);
}
                    
+ (float) deviceGrey2luminance: (float) g {
    return Math.pow(g, [Settings gammaValue]);
}
////////////////////////////////////// deviceGrey <—> RGB
+ (int) deviceGrey2RGB_UNFERTIG: (float) theDeviceGrey {
    var g = limit(0, Math.round(255 * theDeviceGrey), 255);
    return (g | g << 8 | g << 16);
}

+ (float) luminance2RGB: (float) luminance {
    var temp1 = luminance2deviceGrey(luminance);
    return deviceGrey2RGB(temp1);
}


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
//3. "deviceGrey": luminance in device values, that is gamma-corrected, on a (0…1) scale
//4. RGB: deviceGrey converted to RGB on a (3 x 0x00…0xFF) scale
////////////////////////////////////// luminance <—> contrast
static public  function lumContrast2lumLo(luminance:Number,contrast:Number):Number {
//trace("lumContrast2lumLo("+luminance+","+contrast+")");
luminance=limit(0.0,luminance,1.0);
var l:Number=luminance * (1.0 - contrast);
//trace("lLo: ",l);
return limit(0.0,l,1.0);
}
static public  function lumContrast2lumHi(luminance:Number, contrast:Number):Number {
luminance=limit(0.0, luminance, 1.0);
var l:Number=luminance * (1.0 + contrast);
//trace("lHi: ",l);
return limit(0.0,l,1.0);
}
static public  function lumHiLo2contrast(lumLo:Number, lumHi:Number):Number {
if (lumLo > lumHi) { // sort if necessary
var temp:Number = lumHi;  lumHi = lumLo; lumLo = temp;
}
var c:Number = (lumHi - lumLo) / (lumHi + lumLo);
return limit(0.0, c, 1.0);
}
static public function rgbHiLo2contrast(rgbLo:uint, rgbHi:uint): Number {
var deviceGreyLo:Number = RGB2L(rgbLo),  deviceGreyHi:Number = RGB2L(rgbHi);
if (deviceGreyLo>deviceGreyHi) { // sort if necessary
var temp:Number = deviceGreyHi;  deviceGreyHi = deviceGreyLo;  deviceGreyLo = temp;
}
var lumLo:Number = deviceGrey2luminance(deviceGreyLo),  lumHi:Number = deviceGrey2luminance(deviceGreyHi);
//trace(lumLo, " -- ", lumHi);
return lumHiLo2contrast(lumLo, lumHi);
}
////////////////////////////////////// luminance & contrast <—> RGB
static public function contrast2HiRGB(contrast:Number):uint {
var temp1:Number = lumContrast2lumHi(0.5, contrast);
temp1 = luminance2deviceGrey(temp1);
return deviceGrey2RGB(temp1);
}
static public function contrast2LoRGB(contrast:Number):uint {
var temp1:Number = lumContrast2lumLo(0.5, contrast);
temp1=luminance2deviceGrey(temp1);
return deviceGrey2RGB(temp1);
//			trace("contrast2LoRGB, contrast: ",contrast,", temp2: ", deviceGrey2RGB(temp1));
}
//////////////////////////////////////
// average the r, g, and b value to represent the grey number (from 0 to 255)
static public function RGB2L(inRGB:uint):uint {
var r:uint = (inRGB >> 16) & 0xFF,  g:uint = (inRGB >> 8) & 0xFF,  b:uint = inRGB & 0xFF;
return (Math.round((r + g + b)/3.0));
}


//////////////////////////////////////
// Michelson ←→ Weber contrast.
// assuming contrast is defined on a 0.0–1.0 scale
static public function contrastMichelson2Weber(inMichelson:Number):Number {
return(2.0 * inMichelson / (1.0 + inMichelson));// vor 2010-09-01: im Nenner (1-cM)
}
static public function contrastWeber2Michelson(inWeber:Number):Number {
return(inWeber / (2.0 - inWeber));
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
