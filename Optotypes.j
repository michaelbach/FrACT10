/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, michael.bach@uni-freiburg.de, <https://michaelbach.de>

Optotypes.j

*/


/**
 This class manages all optotypes (letters, E, C, …)
 Begun: 2020-08-17
 */
@implementation Optotypes: CPObject {
    CPColor _colOptotypeFore, _colOptotypeBack;
    CGContext _cgc;
    float kPi, kPi2;
    float currentX, currentY; // for drawing
}


- (id) init { //console.info("Optotypes>init");
    self = [super init];
    if (self) {
        kPi = Math.PI;  kPi2 = kPi / 2;
    }
    return self;
}


/**
 this will be called from all tests and informs us here about the context
 */
- (void) setCgc: (CGContext) cgc colFore: (CPColor) colFore colBack: (CPColor) colBack {//console.info("setCgc");
    _cgc = cgc;
    _colOptotypeFore = colFore;  _colOptotypeBack = colBack;
}


- (float) getCurrentContrastMichelsonPercent {
    return [Misc contrastMichelsonPercentFromColor1: _colOptotypeFore color2: _colOptotypeBack];
}
- (float) getCurrentContrastWeberPercent {
    return [Misc contrastWeberFromMichelsonPercent: [self getCurrentContrastMichelsonPercent]];
}
// problem here: 0 % contrast will end in finite logCSWeber. But since this is now clamped at 4.0,
// after rounding this will still read 0%.
- (float) getCurrentContrastLogCSWeber {
    var michelsonPercent = [self getCurrentContrastMichelsonPercent];
    var weberPercent = [Misc contrastWeberFromMichelsonPercent: michelsonPercent];
    return [Misc contrastLogCSWeberFromWeberPercent: weberPercent];
}


/**
 A number of general drawing helpers
 */
- (void) strokeCircleAtX: (float)x y: (float)y radius: (float) r { //console.info("MBIllus>strokeCircleAtX");
    CGContextStrokeEllipseInRect(_cgc, CGRectMake(x - r, y - r, 2 * r, 2 * r));
}


- (void) fillCircleAtX: (float)x y: (float)y radius: (float) r { //console.info("MBIllus>fillCircleAtX");
    CGContextFillEllipseInRect(_cgc, CGRectMake(x - r, y - r, 2 * r, 2 * r));
}


- (void) strokeLineX0: (float) x0 y0: (float) y0 x1: (float) x1 y1: (float) y1 {//console.info("strokeLineX0");
    CGContextBeginPath(_cgc);
    CGContextMoveToPoint(_cgc, x0, y0);  CGContextAddLineToPoint(_cgc, x1, y1);
    CGContextStrokePath(_cgc);
    currentX = x1;  currentY = y1;
}
- (void) strokeLineToX: (float) xxx y: (float) yyy {//console.info("strokeLineX0");
    CGContextBeginPath(_cgc);
    CGContextMoveToPoint(_cgc, currentX, currentY);  CGContextAddLineToPoint(_cgc, xxx, yyy);
    CGContextStrokePath(_cgc);
    currentX = xxx;  currentY = yyy;
}
- (void) strokeLineDeltaX: (float) xxx deltaY: (float) yyy {//console.info("strokeLineX0");
    CGContextBeginPath(_cgc);
    CGContextMoveToPoint(_cgc, currentX, currentY);
    currentX = currentX + xxx;  currentY = currentY + yyy;
    CGContextAddLineToPoint(_cgc, currentX, currentY);
    CGContextStrokePath(_cgc);
}
- (void) strokeVLineAtX: (float) x y0: (float) y0 y1: (float) y1 {
    [self strokeLineX0: x y0: y0 x1: x y1: y1];
    currentX = x;  currentY = y1;
}
- (void) strokeHLineAtX0: (float) x0 y: (float) y x1: (float) x1 {
    [self strokeLineX0: x0 y0: y x1: x1 y1: y];
    currentX = x1;  currentY = y;
}


- (void) addCrossAtX: (float) x y: (float) y size: (float) s {
    s /= 2.0;
    CGContextMoveToPoint(_cgc, x - s, y);  CGContextAddLineToPoint(_cgc, x + s, y);
    CGContextMoveToPoint(_cgc, x, y - s);  CGContextAddLineToPoint(_cgc, x, y + s);
}


- (void) strokeCrossAtX: (float) x y: (float) y size: (float) s {
    CGContextBeginPath(_cgc);  [self addCrossAtX: x y: y size: s];  CGContextStrokePath(_cgc);
}


- (void) strokeXAtX: (float) x y: (float) y size: (float) s {//console.info("MBIllus02>strokeXAtX");
    s *= 0.5 / Math.sqrt(2);
    [self strokeLineX0: x - s y0:y - s x1: x + s y1: y + s];
    [self strokeLineX0: x - s y0:y + s x1: x + s y1: y - s];
}


/**
 Draw optotypes (letters and Es) on a -5…+5 coordinate system
*/
- (void) drawPolygon: (float) p withD: (float) d { //console.info("FractControllerAcuityE>drawPolygon");
    CGContextSetFillColor(_cgc, _colOptotypeFore);
    CGContextBeginPath(_cgc);
    CGContextMoveToPoint(_cgc, d * p[0][0], -d * p[0][1]);
    for (var i = 1; i < p.length; ++i) {
        CGContextAddLineToPoint(_cgc, d * p[i][0], -d * p[i][1]);
    }
    CGContextAddLineToPoint(_cgc, d * p[0][0], -d * p[0][1]);
//    console.info(_cgc);
//    console.info(_colOptotypeFore, _colOptotypeBack);
//    console.info([_colOptotypeFore brightnessComponent], [_colOptotypeBack brightnessComponent]);
    CGContextFillPath(_cgc);
}


- (void) drawLandoltWithGapInPx: (float) gap landoltDirection: (int) direction { //console.info("OTLandolts>drawLandoltWithGapInPx", gap, direction);
    CGContextSetFillColor(_cgc, _colOptotypeFore);
    [self fillCircleAtX: 0 y: 0 radius: 2.5 * gap];
    CGContextSetFillColor(_cgc, _colOptotypeBack);
    [self fillCircleAtX: 0 y: 0 radius: 1.5 * gap];
    var rct = CGRectMake(gap * 1.4 - 1, -gap / 2, 1.3 * gap + 1, gap); //console.info(gap, " ", rct);
    var rot = Math.PI / 180.0 * (7 - (direction - 1)) / 8.0 * 360.0;
    CGContextRotateCTM(_cgc, rot);
    if (direction >= 0) CGContextFillRect(_cgc, rct);
    CGContextRotateCTM(_cgc, -rot);
}


- (void)drawSloanCWithGapInPx: (float) gap { //console.info("FractControllerAcuityLetters>drawSloanCWithGapInPx");
    [self drawLandoltWithGapInPx: gap landoltDirection: 0];
}
- (void)drawSloanDWithGapInPx: (float) d { //console.info("FractControllerAcuityLetters>drawSloanDWithGapInPx");
    d *= 0.5;
    var gxf = 1.0, gyf = 1.0;
    CGContextBeginPath(_cgc);
    CGContextMoveToPoint(_cgc, -d * 5 * gxf, -d * 5 * gyf);
    CGContextAddLineToPoint(_cgc, d * 1 * gxf, -d * 5 * gyf);
    CGContextAddArc(_cgc, d * 1 * gxf, -d * 1 * gyf, 4 * d, -kPi2, 0, YES);
    CGContextAddLineToPoint(_cgc, d * 5 * gxf, +d * 1 * gyf);
    CGContextAddArc(_cgc, d * 1 * gxf, +d * 1 * gyf, 4 * d, 0, kPi2, YES);
    CGContextAddLineToPoint(_cgc, -d * 5 * gxf, d * 5 * gyf);
    CGContextAddLineToPoint(_cgc, -d * 5 * gxf, -d * 5 * gyf);
    CGContextFillPath(_cgc);
    d *= 3.0 / 5.0;
    CGContextSetFillColor(_cgc, _colOptotypeBack);
    CGContextBeginPath(_cgc);
    CGContextMoveToPoint(_cgc, -d * 5 * gxf, -d * 5 * gyf);
    CGContextAddLineToPoint(_cgc, d * 1 * gxf, -d * 5 * gyf);
    CGContextAddArc(_cgc, d * 1 * gxf, -d * 1 * gyf, 4 * d, -kPi2, 0, YES);
    CGContextAddLineToPoint(_cgc, d * 5 * gxf, +d * 1 * gyf);
    CGContextAddArc(_cgc, d * 1 * gxf, +d * 1 * gyf, 4 * d, 0, kPi2, YES);
    CGContextAddLineToPoint(_cgc, -d * 5 * gxf, d * 5 * gyf);
    CGContextAddLineToPoint(_cgc, -d * 5 * gxf, -d * 5 * gyf);
    CGContextFillPath(_cgc);
}
- (void)drawSloanHWithGapInPx: (float) d { //console.info("FractControllerAcuityLetters>drawSloanHWithGapInPx");
    var pnts = [[-5,-5], [-3,-5], [-3,-1], [+3,-1], [+3,-5], [+5,-5], [+5,+5], [+3,+5], [+3,+1], [-3,+1], [-3,+5], [-5,+5], [-5, -5]];
    [self drawPolygon: pnts withD: d * 0.5];
}
- (void)drawSloanKWithGapInPx: (float) d {
    var pnts = [[-5,-5], [-3,-5], [-3,-0.82], [-0.98,0.69], [+2.43,-5], [+5,-5], [+0.74,+1.98], [+5,+5], [+1.66,+5], [-3,+1.68], [-3,+5], [-5,+5], [-5,-5]];
    [self drawPolygon: pnts withD: d * 0.5];
}
- (void)drawSloanNWithGapInPx: (float) d {
    var pnts = [[-5,-5], [-3,-5], [-3,1.9], [+3,-5], [+5,-5], [+5,+5], [+3,+5], [+3,-1.9], [-3,+5], [-5,+5], [-5,-5]];
    [self drawPolygon: pnts withD: d * 0.5];
}
- (void)drawSloanOWithGapInPx: (float) d {
    var r = 2.5 * d;
    CGContextFillEllipseInRect(_cgc, CGRectMake(-r, -r, 2*r, 2*r));
    r = 1.5 * d;
    CGContextSetFillColor(_cgc, _colOptotypeBack);  CGContextFillEllipseInRect(_cgc, CGRectMake(-r, -r, 2*r, 2*r));
}
- (void)drawSloanRWithGapInPx: (float) d {
    var p1 = [[-5,-5], [-3,-5], [-3,-1], [+2,-1], [+2,+5], [-5,+5], [-5,-5]],
    p2 = [[0.7,0], [2.8,-5], [5,-5], [+2.85,0], [0.7,0]],
    d5 = d * 0.5;
    CGContextBeginPath(_cgc);  [self drawPolygon: p1 withD: d5];  CGContextFillPath(_cgc);
    CGContextBeginPath(_cgc);  [self drawPolygon: p2 withD: d5];  CGContextFillPath(_cgc);
    [self fillCircleAtX: d y: -d radius: 3 * d5];
    CGContextSetFillColor(_cgc, _colOptotypeBack);
    [self fillCircleAtX: d y: -d radius: d5];
    CGContextFillRect(_cgc, CGRectMake(-3 * d5, -3 * d5, 5 * d5, d));
}
- (void)drawSloanSWithGapInPx: (float) d {
    d = d * 0.5;
    CGContextBeginPath(_cgc);
    CGContextMoveToPoint(_cgc, -5 * d, 2 * d);
    CGContextAddArc(_cgc, -2 * d, 2 * d, 3 * d, kPi, kPi2, NO);// unten links
    CGContextAddLineToPoint(_cgc, 2 * d, 5 * d);
    CGContextAddArc(_cgc, 2 * d, 2 * d, 3 * d, kPi2, -kPi2, NO);// unten rechts außen
    CGContextAddLineToPoint(_cgc, -2 * d, -1 * d);
    CGContextAddArc(_cgc, -2 * d, -2 * d, d, kPi2, -kPi2, YES);// oben links innen
    CGContextAddLineToPoint(_cgc, 2 * d, -3 * d);
    CGContextAddArc(_cgc, 2 * d, -2 * d, d, -kPi2, 0, YES);// oben rechts innen
    CGContextAddLineToPoint(_cgc, 5 * d, -2 * d);
    CGContextAddArc(_cgc, 2 * d, -2 * d, 3 * d, 0, -kPi2, NO);// oben rechts außen
    CGContextAddLineToPoint(_cgc, -2 * d, -5 * d);
    CGContextAddArc(_cgc, -2 * d, -2 * d, 3 * d, -kPi2, kPi2, NO);// oben links außen
    CGContextAddLineToPoint(_cgc, 2 * d, 1 * d);
    CGContextAddArc(_cgc, 2 * d, 2 * d, d, -kPi2, kPi2, YES);// unten rechts innen
    CGContextAddLineToPoint(_cgc, -2 * d, 3 * d);
    CGContextAddArc(_cgc, -2 * d, 2 * d, d, kPi2, kPi, YES);// unten rechts innen
    CGContextAddLineToPoint(_cgc, -5 * d, 2 * d);
    CGContextFillPath(_cgc);
    //[self strokeXAtX: 0 y: 0 size: 3];
}
- (void)drawSloanVWithGapInPx: (float) d {
    var pnts = [[-5,+5], [-1,-5], [+1,-5], [+5,+5], [+3,+5], [0,-2.1], [-3,+5], [-5,+5], [-5,+5]];
    CGContextBeginPath(_cgc);  [self drawPolygon: pnts withD: d / 2];  CGContextFillPath(_cgc);
}
- (void)drawSloanZWithGapInPx: (float) d {
    var pnts = [[-5,-5], [+5,-5], [+5,-3], [-1.9,-3], [+5,+3], [+5,+5], [-5,+5], [-5,+3], [+1.9,+3], [-5,-3], [-5,-5]];
    CGContextBeginPath(_cgc);  [self drawPolygon: pnts withD: d / 2];  CGContextFillPath(_cgc);
}


- (void)drawLetterWithGapInPx: (float) gap letterNumber: (int) letterNumber { //console.info("Optotypes>drawLetterWithGapInPx")
    CGContextSetFillColor(_cgc, _colOptotypeFore);
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


///////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void) tumblingEWithGapInPx: (float) d direction: (int) theDirection { //console.info("Optotypes>tumblingEWithGapInPx");
    //theDirection = directionIfMirrored(theDirection);
    switch (theDirection) {
        case 0: "E"
            var p = [[5, -5], [-5, -5], [-5, 5], [5, 5], [5, 3], [-3, 3], [-3, 1], [5, 1], [5, -1], [-3, -1], [-3, -3], [5, -3]];  break;
        case 2:
            var p = [[-5, 5], [-5, -5], [5, -5], [5, 5], [3, 5], [3, -3], [1, -3], [1, 5], [-1, 5], [-1, -3], [-3, -3], [-3, 5]];  break;
        case 4:
            var p = [[-5, -5], [5, -5], [5, 5], [-5, 5], [-5, 3], [3, 3], [3, 1], [-5, 1], [-5, -1], [3, -1], [3, -3], [-5, -3]];  break;
        case 6:
            var p = [[5, -5], [5, 5], [-5, 5], [-5, -5], [-3, -5], [-3, 3], [-1, 3], [-1, -5], [1, -5], [1, 3], [3, 3], [3, -5]];  break;
        default:    // hollow square (for flanker)
            var p = [[5, -5], [-5, -5], [-5, 5], [5, 5], [5, -5], [3, -3], [-3, -3], [-3, 3], [3, 3], [3, -3]];
    }
    [self drawPolygon: p withD: d * 0.5];
}


@end
