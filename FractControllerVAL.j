    /*
 *  FractControllerVALetters.j
 *  cappDevelop
 *
 *  Created by Bach on 08.08.2017.
 *  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
 */

@import <Foundation/CPObject.j>

@implementation FractControllerVAL: FractController {
    float kPi, kPi2;
}


- (void) modifyGenericStimulus {[self modifyGenericStimulusWithBonus];}
- (void) modifyDeviceStimulus {[self acuityModifyDeviceStimulusDIN01_02_04_08];}
- (float) stimDeviceFromGeneric: (float) tPest {return [self acuityStimDeviceFromGeneric: tPest];}
- (float) stimGenericFromDevice: (float) d {return [self acuityStimGenericFromDevice: d];}


- (void)myPoly: (float) p withD: (float) d {
    CGContextMoveToPoint(cgc, p[0, 0], p[0, 1]);
    for (var i = 1; i < p.length; ++i) {
        CGContextAddLineToPoint(cgc, d * p[i][0], -d * p[i][1]); // minus sign because of CG's coordinate system
    }
}


- (void)drawSloanCWithGapInPx: (float) gap { //console.log("FractControllerVALetters>drawSloanCWithGapInPx");
    [self drawLandoltWithGapInPx: gap landoltDirection: 0];
}
- (void)drawSloanDWithGapInPx: (float) d { //console.log("FractControllerVALetters>drawSloanDWithGapInPx");
    d *= 0.5;
    var gxf = 1.0, gyf = 1.0;
    CGContextBeginPath(cgc);
    CGContextMoveToPoint(cgc, -d * 5 * gxf, -d * 5 * gyf);
    CGContextAddLineToPoint(cgc, d * 1 * gxf, -d * 5 * gyf);
    CGContextAddArc(cgc, d * 1 * gxf, -d * 1 * gyf, 4 * d, -kPi2, 0, YES);
    CGContextAddLineToPoint(cgc, d * 5 * gxf, +d * 1 * gyf);
    CGContextAddArc(cgc, d * 1 * gxf, +d * 1 * gyf, 4 * d, 0, kPi2, YES);
    CGContextAddLineToPoint(cgc, -d * 5 * gxf, d * 5 * gyf);
    CGContextAddLineToPoint(cgc, -d * 5 * gxf, -d * 5 * gyf);
    CGContextFillPath(cgc);
    d *= 3.0 / 5.0;
    CGContextSetFillColor(cgc, colOptotypeBack);
    CGContextBeginPath(cgc);
    CGContextMoveToPoint(cgc, -d * 5 * gxf, -d * 5 * gyf);
    CGContextAddLineToPoint(cgc, d * 1 * gxf, -d * 5 * gyf);
    CGContextAddArc(cgc, d * 1 * gxf, -d * 1 * gyf, 4 * d, -kPi2, 0, YES);
    CGContextAddLineToPoint(cgc, d * 5 * gxf, +d * 1 * gyf);
    CGContextAddArc(cgc, d * 1 * gxf, +d * 1 * gyf, 4 * d, 0, kPi2, YES);
    CGContextAddLineToPoint(cgc, -d * 5 * gxf, d * 5 * gyf);
    CGContextAddLineToPoint(cgc, -d * 5 * gxf, -d * 5 * gyf);
    CGContextFillPath(cgc);
}
- (void)drawSloanHWithGapInPx: (float) d { //console.log("FractControllerVALetters>drawSloanHWithGapInPx");
    var pnts = [[-5,-5], [-3,-5], [-3,-1], [+3,-1], [+3,-5], [+5,-5], [+5,+5], [+3,+5], [+3,+1], [-3,+1], [-3,+5], [-5,+5], [-5, -5]];
    CGContextBeginPath(cgc);  [self myPoly: pnts withD: d * 0.5];  CGContextFillPath(cgc);
}
- (void)drawSloanKWithGapInPx: (float) d {
    var pnts = [[-5,-5], [-3,-5], [-3,-0.82], [-0.98,0.69], [+2.43,-5], [+5,-5], [+0.74,+1.98], [+5,+5], [+1.66,+5], [-3,+1.68], [-3,+5], [-5,+5], [-5,-5]];
    CGContextBeginPath(cgc);  [self myPoly: pnts withD: d * 0.5];  CGContextFillPath(cgc);
}
- (void)drawSloanNWithGapInPx: (float) d {
    var pnts = [[-5,-5], [-3,-5], [-3,1.9], [+3,-5], [+5,-5], [+5,+5], [+3,+5], [+3,-1.9], [-3,+5], [-5,+5], [-5,-5]];
    CGContextBeginPath(cgc);  [self myPoly: pnts withD: d * 0.5];  CGContextFillPath(cgc);
}
- (void)drawSloanOWithGapInPx: (float) d {
    var r = 2.5 * d;
    CGContextFillEllipseInRect(cgc, CGRectMake(-r, -r, 2*r, 2*r));
    r = 1.5 * d;
    CGContextSetFillColor(cgc, colOptotypeBack);  CGContextFillEllipseInRect(cgc, CGRectMake(-r, -r, 2*r, 2*r));
}
- (void)drawSloanRWithGapInPx: (float) d {
    var p1 = [[-5,-5], [-3,-5], [-3,-1], [+2,-1], [+2,+5], [-5,+5], [-5,-5]],
    p2 = [[0.7,0], [2.8,-5], [5,-5], [+2.85,0], [0.7,0]],
    d5 = d * 0.5;
    CGContextBeginPath(cgc);  [self myPoly: p1 withD: d5];  CGContextFillPath(cgc);
    CGContextBeginPath(cgc);  [self myPoly: p2 withD: d5];  CGContextFillPath(cgc);
    [self fillCircleAtX: d y: -d radius: 3 * d5];
    CGContextSetFillColor(cgc, colOptotypeBack);
    [self fillCircleAtX: d y: -d radius: d5];
    CGContextFillRect(cgc, CGRectMake(-3 * d5, -3 * d5, 5 * d5, d));
}
- (void)drawSloanSWithGapInPx: (float) d {
    d = d * 0.5;
    CGContextBeginPath(cgc);
    CGContextMoveToPoint(cgc, -5 * d, 2 * d);
    CGContextAddArc(cgc, -2 * d, 2 * d, 3 * d, kPi, kPi2, NO);// unten links
    CGContextAddLineToPoint(cgc, 2 * d, 5 * d);
    CGContextAddArc(cgc, 2 * d, 2 * d, 3 * d, kPi2, -kPi2, NO);// unten rechts außen
    CGContextAddLineToPoint(cgc, -2 * d, -1 * d);
    CGContextAddArc(cgc, -2 * d, -2 * d, d, kPi2, -kPi2, YES);// oben links innen
    CGContextAddLineToPoint(cgc, 2 * d, -3 * d);
    CGContextAddArc(cgc, 2 * d, -2 * d, d, -kPi2, 0, YES);// oben rechts innen
    CGContextAddLineToPoint(cgc, 5 * d, -2 * d);
    CGContextAddArc(cgc, 2 * d, -2 * d, 3 * d, 0, -kPi2, NO);// oben rechts außen
    CGContextAddLineToPoint(cgc, -2 * d, -5 * d);
    CGContextAddArc(cgc, -2 * d, -2 * d, 3 * d, -kPi2, kPi2, NO);// oben links außen
    CGContextAddLineToPoint(cgc, 2 * d, 1 * d);
    CGContextAddArc(cgc, 2 * d, 2 * d, d, -kPi2, kPi2, YES);// unten rechts innen
    CGContextAddLineToPoint(cgc, -2 * d, 3 * d);
    CGContextAddArc(cgc, -2 * d, 2 * d, d, kPi2, kPi, YES);// unten rechts innen
    CGContextAddLineToPoint(cgc, -5 * d, 2 * d);
    CGContextFillPath(cgc);
    //[self strokeXAtX: 0 y: 0 size: 3];
}
- (void)drawSloanVWithGapInPx: (float) d {
    var pnts = [[-5,+5], [-1,-5], [+1,-5], [+5,+5], [+3,+5], [0,-2.1], [-3,+5], [-5,+5], [-5,+5]];
    CGContextBeginPath(cgc);  [self myPoly: pnts withD: d / 2];  CGContextFillPath(cgc);
}
- (void)drawSloanZWithGapInPx: (float) d {
    var pnts = [[-5,-5], [+5,-5], [+5,-3], [-1.9,-3], [+5,+3], [+5,+5], [-5,+5], [-5,+3], [+1.9,+3], [-5,-3], [-5,-5]];
    CGContextBeginPath(cgc);  [self myPoly: pnts withD: d / 2];  CGContextFillPath(cgc);
}


- (void)drawLetterWithGapInPx: (float) gap letterNumber: (int) letterNumber { //console.log("FractControllerVALetters>drawLetterWithGapInPx")
    CGContextSetFillColor(cgc, colOptotypeFore);
    switch (letterNumber) { //"CDHKNORSVZ"
        case 0:
            [self drawSloanCWithGapInPx: gap];  break;
        case 1:
            [self drawSloanDWithGapInPx: gap];  break;
        case 2:
            [self drawSloanHWithGapInPx: gap];  break;
        case 3:
            [self drawSloanKWithGapInPx: gap];  break;
        case 4:
            [self drawSloanNWithGapInPx: gap];  break;
        case 5:
            [self drawSloanOWithGapInPx: gap];  break;
        case 6:
            [self drawSloanRWithGapInPx: gap];  break;
        case 7:
            [self drawSloanSWithGapInPx: gap];  break;
        case 8:
            [self drawSloanVWithGapInPx: gap];  break;
        case 9:
            [self drawSloanZWithGapInPx: gap];  break;
    }
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.log("FractControllerVALetters>drawStimulusInRect");
    trialInfoString = [self acuityComposeTrialInfoString];
    cgc = [[CPGraphicsContext currentContext] graphicsPort];
    CGContextSetFillColor(cgc, colOptotypeBack);
    CGContextFillRect(cgc, [[self window] frame]);
    CGContextSaveGState(cgc);
    switch(state) {
        case kStateDrawBack: break;
        case kStateDrawFore:
            CGContextTranslateCTM(cgc,  viewWidth / 2, viewHeight / 2); // origin to center
            [self drawLetterWithGapInPx: stimStrengthInDeviceunits letterNumber: [alternativesGenerator currentAlternative]];
            break;
        default: break;
    }
    CGContextRestoreGState(cgc);
    CGContextSetTextPosition(cgc, 10, 10);  CGContextSetFillColor(cgc, colOptotypeFore);
    CGContextShowText(cgc, trialInfoString);
    [super drawStimulusInRect: dirtyRect];
}


- (void) runStart { //console.log("FractControllerVALetters>runStart");
    kPi = Math.PI;  kPi2 = kPi / 2;
    nAlternatives = 10;  nTrials = [Settings nTrials08];
    [self setCurrentTestName: "Acuity_Letters"];
    [self setCurrentTestResultUnit: "LogMAR"];
    [super runStart];
}


- (void)runEnd { //console.log("FractControllerVALetters>runEnd");
    if (iTrial < nTrials) { //premature end
        [self setResultString: @"Aborted"];
    } else {
        [self setResultString: [self acuityComposeResult]];
    }
    [super runEnd];
}


- (int)responseNumberFromChar: (CPString) keyChar { //console.log("FractControllerVALetters>responseNumberFromChar: ", keyChar);
    switch ([keyChar uppercaseString]) { // "CDHKNORSVZ"
        case "C": return 0;
        case "D": return 1;
        case "H": return 2;
        case "K": return 3;
        case "N": return 4;
        case "O": return 5;
        case "R": return 6;
        case "S": return 7;
        case "V": return 8;
        case "Z": return 9;
        case "5": return -1;
    }
    return -2;// -1: ignore; -2: invalid
}


@end
