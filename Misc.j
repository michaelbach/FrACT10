/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

Misc.j

*/


@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Globals.j"
@import "Settings.j"


/**
 A collection of "miscellaneous" functions.
 All are class variables for easy global access.
 */
@implementation Misc: CPObject {
}


/**
 Delay for seconds
 */
function _pause(ms) { //console.info("Misc>_pause");
  return new Promise(resolve => setTimeout(resolve, ms));
}
+ (async void) asyncDelaySeconds: (float) secs { //console.info("Misc>delaySeconds");
    await _pause(secs * 1000);
}


/**
 Return random integer from 0 to i-1 */
+ (int) iRandom: (int) i {
    return Math.floor(Math.random() * i);
}


/**
 Limit the input value to lie between 0 and 1
 */
+ (float) limit01: (float) theValue {
    return [self limit: theValue lo: 0 hi: 1];
}
/**
 Limit the input value to lie between 2 values
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
 Handle fullscreen. That was quite difficult to figure out :) (at that time…).
 */
// https://hacks.mozilla.org/2012/01/using-the-fullscreen-api-in-web-browsers/
+ (BOOL) isFullScreenSupported {
    return (
        document.fullscreenEnabled || document.webkitFullscreenEnabled ||
        document.mozFullScreenEnabled || document.msFullscreenEnabled
    );
}
+ (BOOL) isFullScreen {
    if (![self isFullScreenSupported]) return NO;
    return !!(document.fullscreenElement || document.webkitFullscreenElement ||
              document.mozFullScreenElement || document.msFullscreenElement);
}
+ (void) fullScreenOn: (BOOL) onOff {
    if (![self isFullScreenSupported]) return;
    if ([self isFullScreen] == onOff) return;
    const element = document.documentElement;
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


+ (void) centerWindowOrPanel: (CPWindow) p {
    [p setFrameOrigin: CGPointMake((window.innerWidth - 800) / 2, (window.innerHeight - 628) / 2)]; // the header adds 28 pixel, so more than 600
}


+ (void) copyString2ClipboardWithDialog: (CPString) s { //console.info("Misc>copyString2ClipboardWithDialog");
    const alert = [CPAlert alertWithMessageText: "Done."
    defaultButton: "Yes, put result → clipboard  (ߵyߴ)" alternateButton: "Cancel  (ߵcߴ)" otherButton: nil
                informativeTextWithFormat: "\rShall we place the result details into the clipboard?\r\r(So you can paste them into a spreadsheet.)\r"];
    [[alert buttons][0] setKeyEquivalent: "c"]; // the "Cancel" button selected by "c"
    [[alert buttons][1] setKeyEquivalent: "y"]; // the "Yes" button selected by "n"
    [alert setAlertStyle: CPInformationalAlertStyle];
    [[alert window] setFrameOrigin: CGPointMake(200, 200)];
    [alert runModalWithDidEndBlock: function(alert, returnCode) {
        switch (returnCode) {
            case 1: /*console.info("ok, dann nicht");*/  break;
            case 0:
                [self copyString2Clipboard: s];
                [self postDfltNotificationName: "buttonExportEnableYESorNO" object: 0];
                break;
        }
    }];
}
/**
 Utility to copy a string to the clipboard which surprisingly now works in all(?) modern browsers
 */
+ (void) copyString2Clipboard: (CPString) s { //console.info("Misc>copyString2Clipboard: ", s);
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


+ (CPString) stringFromInteger: (int) num { //console.info("Misc>stringFromInteger");
    return [CPString stringWithFormat: @"%d", num];
}


+ (CPString) stringFromNumber: (float) num decimals: (int) decs localised: (BOOL) locd { //console.info("Misc>stringFromNumber");
    if (decs < 1)  return [self stringFromInteger: num];
    const fmt = @"%6." + [CPString stringWithFormat:@"%d", decs] + "f";
    let str = [CPString stringWithFormat: fmt, num];
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
    //console.info("Misc>stringFromNumber ", fmt, ", ", [Settings decimalMarkChar], " ,", str);
    return str;
}


/**
 Given an epsilon, we test for "equality" of 2 floating point numbers
 */
+ (BOOL) areNearlyEqual: (float)a and: (float) b {
    const epsilon = 1e-9, diff = Math.abs(a - b), magnitude = Math.abs(a) + Math.abs(b);
    return (diff / magnitude) < epsilon;
}


+ (void) makeFrameSquareFromWidth: (CPView) view {
    const rect1 = [view frame];
    [view setFrame: CGRectMake(rect1.origin.x, rect1.origin.y - (rect1.size.width - 16) / 2, rect1.size.width, rect1.size.width)];
}


/**
 Helper function: Find out if a URL exists
 */
+ (BOOL) existsUrl: (CPString) url { //console.info("Misc>existsUrl");
    let success = NO;
    try {
        let request;
        if(window.XMLHttpRequest)
            request = new XMLHttpRequest();
        else
            request = new ActiveXObject("Microsoft.XMLHTTP");
        request.open('GET', url, NO);
        request.send(); // there will be a 'pause' here until the response to come.
        // the object request will be modified
        success = (request.status != 404)
    }
    catch (e){
        console.log(e);
    }
    if (!success) {
        alert("The page you are trying to reach is not available (in this context).");
    }
    return success;
}


// Helper to shorten code
+ (void) postDfltNotificationName: (CPString) aNotificationName object: (id) anObject {
    [[CPNotificationCenter defaultCenter] postNotificationName: aNotificationName object: anObject];
}


+ (BOOL) isAcuityGratingMisc { // replication of Helper in FractController
    return (gCurrentTestID == kTestContrastG) && ([Settings what2sweepIndex] == 1);
}
+ (BOOL) isContrastGMisc { // replication of Helper in FractController
    return [kTestContrastG].includes(gCurrentTestID) && (![self isAcuityGratingMisc]);
}
+ (CPString) testNameGivenTestID: (TestIDType) theTestID {
    switch (theTestID) {
        case kTestAcuityLett: return "Acuity_Letters";
        case kTestAcuityC: return "Acuity_LandoltC";
        case kTestAcuityE: return "Acuity_TumblingE";
        case kTestAcuityTAO: return "Acuity_TAO";
        case kTestAcuityVernier: return "Acuity_Vernier";
        case kTestContrastLett: return "Contrast_Letters";
        case kTestContrastC: return "Contrast_LandoltC";
        case kTestContrastE: return "Contrast_TumblingE";
        case kTestContrastG:
            if ([self isContrastGMisc]) return "Contrast_Grating";
            return "Acuity_Grating";
        case kTestAcuityLineByLine: return "Acuity_LineByLine";
        case kTestBalmLight: return "BalmLight";
        case kTestBalmLocation: return "BalmLocation";
        case kTestBalmMotion: return "BalmMotion";
    }
    return "NOT ASSIGNED";
}


/* ///////////////////////////////////// OLD, not in use (yet) */

/*

+ (CPString) capitalizeFirstLetter: (CPString) s {
 if (s.length < 1)  return @"";
 else if (s.length == 1)  return [s capitalizedString];
 const firstChar = [[s substringToIndex: 1] uppercaseString];
 const otherChars = [s substringWithRange: CPMakeRange(1, s.length - 1)];
 return firstChar + otherChars;
}

 
 // formats a number to given precision
+ (CPString) rStrFromNumber: num precision: (int) precision {
    if (isNaN(precision)) {
        let precision=0;
    }
    if (precision <= 0)	 {	// no decimal points
        return String(Math.round(num));
    }
    //return String(Math.floor(num) + "." + Math.floor(num * Math.pow(10, precision)).toString().substr(-precision));//this is from Macromedia, but wrong all the same… 15.12.2003
    let temp = Math.pow(10, precision);
    temp = Math.round(num * temp) / temp;
    return String(temp);
}


// formats a number to a “sensible” precision
static public  function rStr(theValue:Number):String {
    let precision:int=1,theValueAbs:Number=Math.abs(theValue);
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
