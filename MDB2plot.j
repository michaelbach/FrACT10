/*
This file is part of FrACT10, a vision test battery.
Copyright © 2025 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

Optotypes.j

*/


/**
 This class provides a low-level and a mid-level drawing environment
 Begun: 2025-05-29
 */

@import "Globals.j"


@implementation MDB2plot: CPObject {
    id _cgc;
    float kPi, kPi2;
    float currentX, currentY; //for drawing
    float p2wvxm, p2wvym, p2wvxa, p2wvya;
    float p2wxr, p2wxl, p2wyb, p2wyt;
    int p2vxl, p2vxr, p2vyb, p2vyt;
}


+ initialize { //CPLog("MDB3plot>initialize");
    [super initialize];
    _cgc = cgc;
    kPi = Math.PI;  kPi2 = kPi / 2;
    [self p2initWithCGC: _cgc];
}


/**
 Low-level
 */
/*+ (void) moveToX: (float) x {
    currentX = x;
}
+ (void) moveToY: (float) y {
    currentY = y;
}*/
+ (void) moveToX: (float) x0 y: (float) y0 { //CPLog("MDB2plot>moveToX: %f, y: %f", x0, y0);
    CGContextMoveToPoint(_cgc, x0, y0);
    currentX = x0;  currentY = y0;
}

+ (void) strokeLineX0: (float) x0 y0: (float) y0 x1: (float) x1 y1: (float) y1 { //console.info("strokeLineX0");
    CGContextBeginPath(_cgc);
    CGContextMoveToPoint(_cgc, x0, y0);  CGContextAddLineToPoint(_cgc, x1, y1);
    CGContextStrokePath(_cgc);
    currentX = x1;  currentY = y1;
}

+ (void) strokeLineToX: (float) x y: (float) y { //console.info("strokeLineX0");
    CGContextBeginPath(_cgc);
    CGContextMoveToPoint(_cgc, currentX, currentY);  CGContextAddLineToPoint(_cgc, x, y);
    CGContextStrokePath(_cgc);
    currentX = x;  currentY = y;
}

+ (void) strokeLineDeltaX: (float) x deltaY: (float) y { //console.info("strokeLineX0");
    CGContextBeginPath(_cgc);
    CGContextMoveToPoint(_cgc, currentX, currentY);
    currentX = currentX + x;  currentY = currentY + y;
    CGContextAddLineToPoint(_cgc, currentX, currentY);
    CGContextStrokePath(_cgc);
}

+ (void) strokeVLineAtX: (float) x y0: (float) y0 y1: (float) y1 {
    [self strokeLineX0: x y0: y0 x1: x y1: y1];
    currentX = x;  currentY = y1;
}

+ (void) strokeHLineAtX0: (float) x0 y: (float) y x1: (float) x1 {
    [self strokeLineX0: x0 y0: y x1: x1 y1: y];
    currentX = x1;  currentY = y;
}


+ (void) strokeCircleAtX: (float)x y: (float)y radius: (float) r { //console.info("MBIllus>strokeCircleAtX");
    CGContextStrokeEllipseInRect(_cgc, CGRectMake(x - r, y - r, 2 * r, 2 * r));
}


+ (void) fillCircleAtX: (float)x y: (float)y radius: (float) r { //console.info("MBIllus>fillCircleAtX");
    CGContextFillEllipseInRect(_cgc, CGRectMake(x - r, y - r, 2 * r, 2 * r));
}


+ (void) addCrossAtX: (float) x y: (float) y size: (float) s {
    s /= 2;
    CGContextMoveToPoint(_cgc, x - s, y);  CGContextAddLineToPoint(_cgc, x + s, y);
    CGContextMoveToPoint(_cgc, x, y - s);  CGContextAddLineToPoint(_cgc, x, y + s);
}


+ (void) strokeCrossAtX: (float) x y: (float) y size: (float) s {
    CGContextBeginPath(_cgc);  [self addCrossAtX: x y: y size: s];  CGContextStrokePath(_cgc);
}


+ (void) strokeXAtX: (float) x y: (float) y size: (float) s { //console.info("optotypes>strokeXAtX");
    s *= 0.5 / Math.sqrt(2);
    [self strokeLineX0: x - s y0:y - s x1: x + s y1: y + s];
    [self strokeLineX0: x - s y0:y + s x1: x + s y1: y - s];
}


+ (void) strokeStarAtX: (float) x y: (float) y size: (float) s { //console.info("optotypes>strokeStarAtX");
    [self strokeXAtX: x y: y size: s];  [self strokeCrossAtX: x y: y size: s];
}


/**
 Mid level
 */
//calculate the transformation matrix window→viewport
+ (void) p2calcWVMATRIX { //console.info("p2calcWVMATRIX");
    p2wvxm =(p2vxr - p2vxl) / (p2wxr - p2wxl);  p2wvxa =(p2vxl - p2wxl * p2wvxm);
    p2wvym =(p2vyt - p2vyb) / (p2wyt - p2wyb);  p2wvya =(p2vyb - p2wyb * p2wvym);
}


//transform user→screen coordinates
+ (int) p2tx: (float) x {return Math.round(p2wvxm * x + p2wvxa);}
+ (int) p2ty: (float) y {return Math.round(p2wvym * y + p2wvya);}
//static double ity(const short y) {    return(y - p2wvya) / p2wvym;    }
//static double itx(const short x) {    return(x - p2wvxa) / p2wvxm;    }


// initialisation of mid level
+ (void) p2initWithCGC: (id) __cgc { //CPLog("p2initWithCGC");
    if (__cgc === null) return;
    _cgc = __cgc;
    p2wxl = 0.0;  p2wxr = 1.0;  p2wyb = 0.0;  p2wyt = 1.0;
    p2vxl = 0;  p2vxr = 1;  p2vyb = 0;  p2vyt = 1;
    [self p2vprtFromRect: CGRectMake(0, 0, parseInt(_cgc.canvas.style.width), parseInt(_cgc.canvas.style.height))];
    [self p2wndwX0: 0.0 y0: 0.0 x1: 1.0 y1: 1.0];
    CGContextSetLineWidth(_cgc, 1);
    CGContextSetStrokeColor(_cgc, [CPColor blackColor]);
}


//Set ViewPort in screen coordinates (=pixels)
+ (void) p2vprtFromRect: (CGRect) theRect { //CPLog("p2vprtFromRect");
    let x0 = theRect.origin.x, y0 = theRect.origin.y, x1 = x0 + theRect.size.width, y1 = y0 + theRect.size.height;
    if (x0 > x1) [x0, x1] = [x1, x0]; //"modern" swapping of variables
    if (y0 > y1) [y0, y1] = [y1, y0];
    p2vxl = Math.round(x0);  p2vxr = Math.round(x1);  p2vyt = Math.round(y0);  p2vyb = Math.round(y1);
    [self p2calcWVMATRIX];
};


//Set Window in user coordinates
+ (void) p2wndwX0: (float) x0 y0: (float) y0 x1: (float) x1 y1: (float) y1 {
    if (x0 > x1) [x0, x1] = [x1, x0];
    if (y0 > y1) [y0, y1] = [y1, y0];
    p2wxl = x0; p2wxr = x1; p2wyb = y0; p2wyt = y1;
    if (p2wxl == p2wxr) p2wxr = p2wxl + 1.0;
    if (p2wyb == p2wyt) p2wyt = p2wyb + 1.0;
    [self p2calcWVMATRIX];
    //CPLog("p2vxl %d, p2vxr %d, p2vyb %d, p2vyt %d", p2vxl, p2vxr, p2vyb, p2vyt);
    //CPLog("p2wxr %f, p2wxl %f, p2wyb %f, p2wyt %f", p2wxr, p2wxl, p2wyb, p2wyt);
    //CPLog("p2wvxm %f, p2wvym %f, p2wvxa %f, p2wvya %f", p2wvxm, p2wvym, p2wvxa, p2wvya);
}


+ (void) p2moveToX: (float) x y: (float) y { //console.info("p2moveToX");
    [self moveToX: [self p2tx: x]]; [self moveToY: [self p2ty: y]];
}


+ (void) p2lineToX: (float) x y: (float) y { //console.info("p2lineToX");
    [self strokeLineToX: [self p2tx: x]]; [self strokeLineToY: [self p2ty: y]];
}


+ (void) p2lineX0: (float) x0 y0: (float) y0 x1: (float) x1 y1: (float) y1 { //CPLog("p2lineX0");
    [self moveToX: [self p2tx: x0] y: [self p2ty: y0]];
    [self strokeLineToX: [self p2tx: x1] y: [self p2ty: y1]];
}


+ (void) p2hlineX0: (float) x0 y: (float) y x1: (float) x1 { //console.info("p2hlineX0");
    [self moveToX: [self p2tx: x0] y: [self p2ty: y]];
    [self strokeLineToX: [self p2tx: x1] y: [self p2ty: y]];
}


+ (void) p2vlineX: (float) x y0: (float) y0 y1: (float) y1 { //console.info("p2vlineX0");
    [self moveToX: [self p2tx: x] y: [self p2ty: y0]];
    [self strokeLineToX: [self p2tx: x] y: [self p2ty: y1]];
}

@end
