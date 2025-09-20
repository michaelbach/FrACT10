/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

Optotypes.j

*/


/**
 This class manages all optotypes (letters, E, C, …)
 Begun: 2020-08-17
 */
@implementation Optotypes: CPObject {
    float kPi, kPi2;
    float currentX, currentY; //for drawing
}


- (id) init { //console.info("Optotypes>init");
    self = [super init];
    if (self) {
        kPi = Math.PI;  kPi2 = kPi / 2;
    }
    return self;
}


/**
 A number of general drawing helpers
 */
- (void) strokeCircleAtX: (float)x y: (float)y radius: (float) r { //console.info("MBIllus>strokeCircleAtX");
    CGContextStrokeEllipseInRect(cgc, CGRectMake(x - r, y - r, 2 * r, 2 * r));
}


- (void) fillCircleAtX: (float)x y: (float)y radius: (float) r { //console.info("MBIllus>fillCircleAtX");
    CGContextFillEllipseInRect(cgc, CGRectMake(x - r, y - r, 2 * r, 2 * r));
}


- (void) strokeLineX0: (float) x0 y0: (float) y0 x1: (float) x1 y1: (float) y1 { //console.info("strokeLineX0");
    CGContextBeginPath(cgc);
    CGContextMoveToPoint(cgc, x0, y0);  CGContextAddLineToPoint(cgc, x1, y1);
    CGContextStrokePath(cgc);
    currentX = x1;  currentY = y1;
}
- (void) strokeLineToX: (float) xxx y: (float) yyy { //console.info("strokeLineX0");
    CGContextBeginPath(cgc);
    CGContextMoveToPoint(cgc, currentX, currentY);  CGContextAddLineToPoint(cgc, xxx, yyy);
    CGContextStrokePath(cgc);
    currentX = xxx;  currentY = yyy;
}
- (void) strokeLineDeltaX: (float) xxx deltaY: (float) yyy { //console.info("strokeLineX0");
    CGContextBeginPath(cgc);
    CGContextMoveToPoint(cgc, currentX, currentY);
    currentX = currentX + xxx;  currentY = currentY + yyy;
    CGContextAddLineToPoint(cgc, currentX, currentY);
    CGContextStrokePath(cgc);
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
    s /= 2;
    CGContextMoveToPoint(cgc, x - s, y);  CGContextAddLineToPoint(cgc, x + s, y);
    CGContextMoveToPoint(cgc, x, y - s);  CGContextAddLineToPoint(cgc, x, y + s);
}


- (void) strokeCrossAtX: (float) x y: (float) y size: (float) s {
    CGContextBeginPath(cgc);  [self addCrossAtX: x y: y size: s];  CGContextStrokePath(cgc);
}


- (void) strokeXAtX: (float) x y: (float) y size: (float) s { //console.info("optotypes>strokeXAtX");
    s *= 0.5 / Math.sqrt(2);
    [self strokeLineX0: x - s y0:y - s x1: x + s y1: y + s];
    [self strokeLineX0: x - s y0:y + s x1: x + s y1: y - s];
}


- (void) strokeStarAtX: (float) x y: (float) y size: (float) s { //console.info("optotypes>strokeStarAtX");
    cgc = [[CPGraphicsContext currentContext] graphicsPort]; //probably no longer necessary
    [self strokeXAtX: x y: y size: s];  [self strokeCrossAtX: x y: y size: s];
}


/**
 Draw optotypes (letters and Es) on a -5…+5 coordinate system
*/
- (void) fillPolygon: (float) p withD: (float) d { //console.info("optotypes>fillPolygon");
    CGContextSetFillColor(cgc, gColorFore);
    CGContextBeginPath(cgc);
    CGContextMoveToPoint(cgc, d * p[0][0], -d * p[0][1]);
    for (let i = 1; i < p.length; ++i) {
        CGContextAddLineToPoint(cgc, d * p[i][0], -d * p[i][1]);
    }
    CGContextAddLineToPoint(cgc, d * p[0][0], -d * p[0][1]);
    CGContextFillPath(cgc);
}


- (void) drawLandoltWithStrokeInPx: (float) stroke landoltDirection: (int) direction { //console.info("optotypes>drawLandoltWithStrokeInPx", stroke, direction);
    cgc = [[CPGraphicsContext currentContext] graphicsPort];
    CGContextSetFillColor(cgc, gColorFore);
    [self fillCircleAtX: 0 y: 0 radius: 2.5 * stroke];
    CGContextSetFillColor(cgc, gColorBack);
    [self fillCircleAtX: 0 y: 0 radius: 1.5 * stroke];
    const rct = CGRectMake(stroke * 1.4 - 1, -stroke / 2, 1.3 * stroke + 1, stroke); //console.info(stroke, " ", rct);
    const rot = Math.PI / 180 * (7 - (direction - 1)) / 8 * 360;
    CGContextRotateCTM(cgc, rot);
    if (direction >= 0) CGContextFillRect(cgc, rct);
    CGContextRotateCTM(cgc, -rot);
}


- (void) drawSloanCWithStrokeInPx: (float) stroke { //console.info("optotypes>drawSloanCWithStrokeInPx");
    [self drawLandoltWithStrokeInPx: stroke landoltDirection: 0];
}
- (void) drawSloanDWithStrokeInPx: (float) d { //console.info("optotypes>drawSloanDWithStrokeInPx");
    d *= 0.5;
    const gxf = 1, gyf = 1;
    CGContextBeginPath(cgc);
    CGContextMoveToPoint(cgc, -d * 5 * gxf, -d * 5 * gyf);
    CGContextAddLineToPoint(cgc, d * 1 * gxf, -d * 5 * gyf);
    CGContextAddArc(cgc, d * 1 * gxf, -d * 1 * gyf, 4 * d, -kPi2, 0, YES);
    CGContextAddLineToPoint(cgc, d * 5 * gxf, +d * 1 * gyf);
    CGContextAddArc(cgc, d * 1 * gxf, +d * 1 * gyf, 4 * d, 0, kPi2, YES);
    CGContextAddLineToPoint(cgc, -d * 5 * gxf, d * 5 * gyf);
    CGContextAddLineToPoint(cgc, -d * 5 * gxf, -d * 5 * gyf);
    CGContextFillPath(cgc);
    d *= 3 / 5;
    CGContextSetFillColor(cgc, gColorBack);
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
- (void) drawSloanHWithStrokeInPx: (float) d { //console.info("optotypes>drawSloanHWithStrokeInPx");
    const pnts = [[-5,-5], [-3,-5], [-3,-1], [+3,-1], [+3,-5], [+5,-5], [+5,+5], [+3,+5], [+3,+1], [-3,+1], [-3,+5], [-5,+5], [-5, -5]];
    [self fillPolygon: pnts withD: d * 0.5];
}
- (void) drawSloanKWithStrokeInPx: (float) d {
    const pnts = [[-5,-5], [-3,-5], [-3,-0.82], [-0.98,0.69], [+2.43,-5], [+5,-5], [+0.74,+1.98], [+5,+5], [+1.66,+5], [-3,+1.68], [-3,+5], [-5,+5], [-5,-5]];
    [self fillPolygon: pnts withD: d * 0.5];
}
- (void) drawSloanNWithStrokeInPx: (float) d {
    const pnts = [[-5,-5], [-3,-5], [-3,1.9], [+3,-5], [+5,-5], [+5,+5], [+3,+5], [+3,-1.9], [-3,+5], [-5,+5], [-5,-5]];
    [self fillPolygon: pnts withD: d * 0.5];
}
- (void) drawSloanOWithStrokeInPx: (float) d {
    let r = 2.5 * d;
    CGContextFillEllipseInRect(cgc, CGRectMake(-r, -r, 2*r, 2*r));
    r = 1.5 * d;
    CGContextSetFillColor(cgc, gColorBack);  CGContextFillEllipseInRect(cgc, CGRectMake(-r, -r, 2*r, 2*r));
}
- (void) drawSloanRWithStrokeInPx: (float) d {
    const p1 = [[-5,-5], [-3,-5], [-3,-1], [+2,-1], [+2,+5], [-5,+5], [-5,-5]],
    p2 = [[0.7,0], [2.8,-5], [5,-5], [+2.85,0], [0.7,0]],
    d5 = d * 0.5;
    CGContextBeginPath(cgc);  [self fillPolygon: p1 withD: d5];  CGContextFillPath(cgc);
    CGContextBeginPath(cgc);  [self fillPolygon: p2 withD: d5];  CGContextFillPath(cgc);
    [self fillCircleAtX: d y: -d radius: 3 * d5];
    CGContextSetFillColor(cgc, gColorBack);
    [self fillCircleAtX: d y: -d radius: d5];
    CGContextFillRect(cgc, CGRectMake(-3 * d5, -3 * d5, 5 * d5, d));
}
- (void) drawSloanSWithStrokeInPx: (float) d {
    d = d * 0.5;
    CGContextBeginPath(cgc);
    CGContextMoveToPoint(cgc, -5 * d, 2 * d);
    CGContextAddArc(cgc, -2 * d, 2 * d, 3 * d, kPi, kPi2, NO); //unten links
    CGContextAddLineToPoint(cgc, 2 * d, 5 * d);
    CGContextAddArc(cgc, 2 * d, 2 * d, 3 * d, kPi2, -kPi2, NO); //unten rechts außen
    CGContextAddLineToPoint(cgc, -2 * d, -1 * d);
    CGContextAddArc(cgc, -2 * d, -2 * d, d, kPi2, -kPi2, YES); //oben links innen
    CGContextAddLineToPoint(cgc, 2 * d, -3 * d);
    CGContextAddArc(cgc, 2 * d, -2 * d, d, -kPi2, 0, YES); //oben rechts innen
    CGContextAddLineToPoint(cgc, 5 * d, -2 * d);
    CGContextAddArc(cgc, 2 * d, -2 * d, 3 * d, 0, -kPi2, NO); //oben rechts außen
    CGContextAddLineToPoint(cgc, -2 * d, -5 * d);
    CGContextAddArc(cgc, -2 * d, -2 * d, 3 * d, -kPi2, kPi2, NO); //oben links außen
    CGContextAddLineToPoint(cgc, 2 * d, 1 * d);
    CGContextAddArc(cgc, 2 * d, 2 * d, d, -kPi2, kPi2, YES); //unten rechts innen
    CGContextAddLineToPoint(cgc, -2 * d, 3 * d);
    CGContextAddArc(cgc, -2 * d, 2 * d, d, kPi2, kPi, YES); //unten rechts innen
    CGContextAddLineToPoint(cgc, -5 * d, 2 * d);
    CGContextFillPath(cgc);
    //[self strokeXAtX: 0 y: 0 size: 3];
}
- (void) drawSloanVWithStrokeInPx: (float) d {
    const pnts = [[-5,+5], [-1,-5], [+1,-5], [+5,+5], [+3,+5], [0,-2.1], [-3,+5], [-5,+5], [-5,+5]];
    CGContextBeginPath(cgc);  [self fillPolygon: pnts withD: d / 2];  CGContextFillPath(cgc);
}
- (void) drawSloanZWithStrokeInPx: (float) d {
    const pnts = [[-5,-5], [+5,-5], [+5,-3], [-1.9,-3], [+5,+3], [+5,+5], [-5,+5], [-5,+3], [+1.9,+3], [-5,-3], [-5,-5]];
    CGContextBeginPath(cgc);  [self fillPolygon: pnts withD: d / 2];  CGContextFillPath(cgc);
}


- (void) drawLetterNr:(int) letterNumber withStrokeInPx: (float) stroke { //console.info("Optotypes>drawLetterWithStrokeInPx")
    cgc = [[CPGraphicsContext currentContext] graphicsPort];
    CGContextSetFillColor(cgc, gColorFore);
    switch (letterNumber) { //"CDHKNORSVZ"
        case 0:
            [self drawSloanCWithStrokeInPx: stroke];  break;
        case 1:
            [self drawSloanDWithStrokeInPx: stroke];  break;
        case 2:
            [self drawSloanHWithStrokeInPx: stroke];  break;
        case 3:
            [self drawSloanKWithStrokeInPx: stroke];  break;
        case 4:
            [self drawSloanNWithStrokeInPx: stroke];  break;
        case 5:
            [self drawSloanOWithStrokeInPx: stroke];  break;
        case 6:
            [self drawSloanRWithStrokeInPx: stroke];  break;
        case 7:
            [self drawSloanSWithStrokeInPx: stroke];  break;
        case 8:
            [self drawSloanVWithStrokeInPx: stroke];  break;
        case 9:
            [self drawSloanZWithStrokeInPx: stroke];  break;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void) tumblingEWithStrokeInPx: (float) d direction: (int) theDirection { //console.info("Optotypes>tumblingEWithStrokeInPx");
    //theDirection = directionIfMirrored(theDirection);
    cgc = [[CPGraphicsContext currentContext] graphicsPort];
    let p;
    switch (theDirection) {
        case 0: "E"
            p = [[5, -5], [-5, -5], [-5, 5], [5, 5], [5, 3], [-3, 3], [-3, 1], [5, 1], [5, -1], [-3, -1], [-3, -3], [5, -3]];  break;
        case 2:
            p = [[-5, 5], [-5, -5], [5, -5], [5, 5], [3, 5], [3, -3], [1, -3], [1, 5], [-1, 5], [-1, -3], [-3, -3], [-3, 5]];  break;
        case 4:
            p = [[-5, -5], [5, -5], [5, 5], [-5, 5], [-5, 3], [3, 3], [3, 1], [-5, 1], [-5, -1], [3, -1], [3, -3], [-5, -3]];  break;
        case 6:
            p = [[5, -5], [5, 5], [-5, 5], [-5, -5], [-3, -5], [-3, 3], [-1, 3], [-1, -5], [1, -5], [1, 3], [3, 3], [3, -5]];  break;
        default:    //hollow square (for flanker)
            p = [[5, -5], [-5, -5], [-5, 5], [5, 5], [5, -5], [3, -3], [-3, -3], [-3, 3], [3, 3], [3, -3]];
    }
    [self fillPolygon: p withD: d * 0.5];
}


@end
