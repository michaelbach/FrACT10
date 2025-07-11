/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2023 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>
 
 Misc.j
 
 */


@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Settings.j"


/**
 A collection of "miscellaneous" functions for spatial aspects (degrees, acuity, …).
 All a class variables for easy global access,
 */
@implementation MiscSpace: CPObject {
}


/**
 Convert degrees to pixels
 */
+ (float) pixelFromDegree: (float) degs { //console.info("pixelFromDegree");
    const mm = Math.tan(degs * Math.PI / 180) * 10 * [Settings distanceInCM];
    return [self pixelFromMillimeter: mm];
}
/**
 Convert pixels to degrees
 */
+ (float) degreeFromPixel: (float) pixel { //console.info("Misc>pixelFromDegree");
    return 180 / Math.PI * Math.atan2([self millimeterFromPixel: pixel], [Settings distanceInCM] * 10);
}


/**
 Convert to period from spatial frequency
 */
+ (float) periodInPixelFromSpatialFrequency: (float) f {
    let p = [MiscSpace pixelFromDegree: 1 / f];
    return p;
}
+ (float) spatialFrequencyFromPeriodInPixel: (float) p {
    let f = 1 / [MiscSpace degreeFromPixel: p];
    return f;
}


+ (float) millimeterFromPixel: (float) pixel {
    return pixel * [Settings calBarLengthInMM] / gCalBarLengthInPixel;
}
+ (float) pixelFromMillimeter: (float) inMM { //console.info("pixelFromMillimeter");
    return inMM * gCalBarLengthInPixel / [Settings calBarLengthInMM];
}


/**
 Given stroke size in pixels, calculates decimal VA
 */
+ (float) decVAFromStrokePixels: (float) pixels { //"decVA": visual acuity in decimal format
    return 1 / 60 / [self degreeFromPixel: pixels];
}
/**
 And the inverse
 */
+ (float) strokePixelsFromDecVA: (float) decVA {
    return [self pixelFromDegree: (1 / 60 / decVA)];
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


/**
 Given stroke size in pixels → LogMAR
 */
+ (float) logMARFromStrokePixels: (float) pixels {
    return [self logMARfromDecVA: [self decVAFromStrokePixels: pixels]];
}
/**
 Given LogMAR → stroke size in pixels
 */
+ (float) strokePixelsFromlogMAR: (float) decVA {
    return [self strokePixelsFromDecVA: [self decVAfromLogMAR: decVA]];
}


/**
 Convert degrees to ratians
 */
+ (float) degrees2radians: (float) degrees {
    return degrees * Math.PI / 180;
}

/* /////////////////////////////////////OLD, not in use (yet) */

/*
 static public function spatFreq2periodInPix(spatFreqInCPD:Number):Number {
 return 2 * PixelFromDegree(1.0 / spatFreqInCPD / 2)
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


@end
