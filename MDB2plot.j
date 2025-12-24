/*
 This file is part of FrACT10, a vision test battery.
 © 2025 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 Optotypes.j

 */


/**
 This class provides a low-level and a mid-level drawing environment
 Begun: 2025-05-29
 */

@import "Globals.j"


@implementation MDB2plot: CPObject {
    id cgcLocal;
    float currentX, currentY; //for drawing
    float p2wvxm, p2wvym, p2wvxa, p2wvya;
    float p2wxr, p2wxl, p2wyb, p2wyt;
    int p2vxl, p2vxr, p2vyb, p2vyt;
}


/*+ initialize { //CPLog("MDB3plot>initialize");
    [super initialize];
    cgcLocal = cgc;
    [self p2init];
}*/


/**
 Low-level
 */
+ (void) moveToX: (float) x0 y: (float) y0 { //CPLog("MDB2plot>moveToX: %f, y: %f", x0, y0);
    CGContextMoveToPoint(cgcLocal, x0, y0);
    currentX = x0;  currentY = y0;
}

+ (void) strokeLineX0: (float) x0 y0: (float) y0 x1: (float) x1 y1: (float) y1 { //console.info("strokeLineX0");
    CGContextBeginPath(cgcLocal);
    CGContextMoveToPoint(cgcLocal, x0, y0);  CGContextAddLineToPoint(cgcLocal, x1, y1);
    CGContextStrokePath(cgcLocal);
    currentX = x1;  currentY = y1;
}

+ (void) strokeLineToX: (float) x y: (float) y { //console.info("strokeLineX0");
    CGContextBeginPath(cgcLocal);
    CGContextMoveToPoint(cgcLocal, currentX, currentY);  CGContextAddLineToPoint(cgcLocal, x, y);
    CGContextStrokePath(cgcLocal);
    currentX = x;  currentY = y;
}

+ (void) strokeLineDeltaX: (float) x deltaY: (float) y { //console.info("strokeLineX0");
    CGContextBeginPath(cgcLocal);
    CGContextMoveToPoint(cgcLocal, currentX, currentY);
    currentX = currentX + x;  currentY = currentY + y;
    CGContextAddLineToPoint(cgcLocal, currentX, currentY);
    CGContextStrokePath(cgcLocal);
}

+ (void) strokeVLineAtX: (float) x y0: (float) y0 y1: (float) y1 {
    [self strokeLineX0: x y0: y0 x1: x y1: y1];
    currentX = x;  currentY = y1;
}

+ (void) strokeHLineAtX0: (float) x0 y: (float) y x1: (float) x1 {
    [self strokeLineX0: x0 y0: y x1: x1 y1: y];
    currentX = x1;  currentY = y;
}


+ (void) strokeCircleAtX: (float)x y: (float)y radius: (float) r { CGContextStrokeEllipseInRect(cgcLocal, CGRectMake(x - r, y - r, 2 * r, 2 * r));
}


+ (void) fillCircleAtX: (float)x y: (float)y radius: (float) r { CGContextFillEllipseInRect(cgcLocal, CGRectMake(x - r, y - r, 2 * r, 2 * r));
}


+ (void) addCrossAtX: (float) x y: (float) y size: (float) s {
    s /= 2;
    CGContextMoveToPoint(cgcLocal, x - s, y);  CGContextAddLineToPoint(cgcLocal, x + s, y);
    CGContextMoveToPoint(cgcLocal, x, y - s);  CGContextAddLineToPoint(cgcLocal, x, y + s);
}


+ (void) strokeCrossAtX: (float) x y: (float) y size: (float) s {
    CGContextBeginPath(cgcLocal);  [self addCrossAtX: x y: y size: s];  CGContextStrokePath(cgcLocal);
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
+ (float) ip2tx: (float) x {return(x - p2wvxa) / p2wvxm;}
+ (float) ip2ty: (float) y {return(y - p2wvya) / p2wvym;}

// initialisation of mid level
+ (void) p2init { //CPLog("p2init");
    cgcLocal = [[CPGraphicsContext currentContext] graphicsPort]
    if (cgcLocal === null) return;
    p2wxl = 0.0;  p2wxr = 1.0;  p2wyb = 0.0;  p2wyt = 1.0;
    p2vxl = 0;  p2vxr = 1;  p2vyb = 0;  p2vyt = 1;
    [self p2vprtFromRect: CGRectMake(0, 0, parseInt(cgcLocal.canvas.style.width), parseInt(cgcLocal.canvas.style.height))];//need to drop trailing "px"
    [self p2wndwX0: 0.0 y0: 0.0 x1: 1.0 y1: 1.0];
    [self p2setLineWidthInPx: 1];
    [self p2setFillColor: [CPColor blackColor]];
    [self p2setStrokeColor: [CPColor blackColor]];
    [self p2setTextAlignDefault];
}


//Set ViewPort in screen coordinates (=pixel)
+ (void) p2vprtFromRect: (CGRect) theRect { //CPLog("p2vprtFromRect");
    let x0 = theRect.origin.x, y0 = theRect.origin.y, x1 = x0 + theRect.size.width, y1 = y0 + theRect.size.height;
    if (x0 > x1) [x0, x1] = [x1, x0]; //"modern" swapping of variables
    if (y0 > y1) [y0, y1] = [y1, y0];
    p2vxl = Math.round(x0);  p2vxr = Math.round(x1);  p2vyt = Math.round(y0);  p2vyb = Math.round(y1);
    [self p2calcWVMATRIX];
}


//Set Window in user coordinates
+ (void) p2wndwX0: (float) x0 y0: (float) y0 x1: (float) x1 y1: (float) y1 {
//    if (x0 > x1) [x0, x1] = [x1, x0]; we might intentionally invert coordinate direction
//    if (y0 > y1) [y0, y1] = [y1, y0]; so no swap
    p2wxl = x0; p2wxr = x1; p2wyb = y0; p2wyt = y1;
    if (p2wxl == p2wxr) p2wxr = p2wxl + 1.0;
    if (p2wyb == p2wyt) p2wyt = p2wyb + 1.0;
    [self p2calcWVMATRIX];
    //CPLog("p2vxl %d, p2vxr %d, p2vyb %d, p2vyt %d", p2vxl, p2vxr, p2vyb, p2vyt);
    //CPLog("p2wxr %f, p2wxl %f, p2wyb %f, p2wyt %f", p2wxr, p2wxl, p2wyb, p2wyt);
    //CPLog("p2wvxm %f, p2wvym %f, p2wvxa %f, p2wvya %f", p2wvxm, p2wvym, p2wvxa, p2wvya);
}


//Get the plot's graphics context (needed for printing to PDF)
+ (id) getCGC {
    return cgcLocal;
}


+ (void) p2moveToX: (float) x y: (float) y { //console.info("p2moveToX");
    [self moveToX: [self p2tx: x] y: [self p2ty: y]];
}


+ (void) p2lineToX: (float) x y: (float) y { //console.info("p2lineToX");
    [self strokeLineToX: [self p2tx: x] y: [self p2ty: y]];
}


+ (void) p2lineX0: (float) x0 y0: (float) y0 x1: (float) x1 y1: (float) y1 { //CPLog("p2lineX0");
    [self moveToX: [self p2tx: x0] y: [self p2ty: y0]];
    [self strokeLineToX: [self p2tx: x1] y: [self p2ty: y1]];
}


+ (void) p2hlineX0: (float) x0 y: (float) y x1: (float) x1 { //console.info("p2hlineX0");
    [self p2lineX0: x0 y0: y x1: x1 y1: y];
}


+ (void) p2vlineX: (float) x y0: (float) y0 y1: (float) y1 { //console.info("p2vlineX0");
    [self p2lineX0: x y0: y0 x1: x y1: y1];
}


+ (void) p2strokeXAtX: (float) x y: (float) y sizeInPx: (float) s {
    [self strokeXAtX: [self p2tx: x] y: [self p2ty: y] size: s];
}


+ (void) p2strokeCircleAtX: (float)x y: (float)y radiusInPx: (float) r {
    x = [self p2tx: x]; y = [self p2ty: y];
    CGContextStrokeEllipseInRect(cgcLocal, CGRectMake(x - r, y - r, 2 * r, 2 * r));
}
+ (void) p2fillCircleAtX: (float)x y: (float)y radiusInPx: (float) r {
    x = [self p2tx: x]; y = [self p2ty: y];
    [self fillCircleAtX: x y: y radius: r];
}

+ (void) p2setLineWidthInPx: (float) w {
    CGContextSetLineWidth(cgcLocal, w);
}


+ (void) p2setFillColor: (CPColor) c {
    CGContextSetFillColor(cgcLocal, c);
}

+ (void) p2setStrokeColor: (CPColor) c {
    CGContextSetStrokeColor(cgcLocal, c);
}

+ (void) p2setFontSize: (int) sze {
    CGContextSelectFont(cgcLocal, sze + "px sans-serif");
}

/*+ (void) p2setTextPositionX: (float) x y: (float) y {
    CGContextSetTextPosition(cgcLocal, [self p2tx: x], [self p2ty: y]);
}
+ (void) p2showText: (CPString) s {
    //CGContextShowText(cgcLocal, s);
    cgcLocal.fillText(s, cgcLocal._textPosition.x, cgcLocal._textPosition.y);
}*/

+ (void) p2showText: (CPString) s atX: (float) x y: (float) y {
    //can't use CGContextShowTextAtPoint because that resets alignment values
    cgcLocal.fillText(s, [self p2tx: x], [self p2ty: y]);
}
+ (void) p2showText: (CPString) s atXpx: (float) x ypx: (float) y {
    //can't use CGContextShowTextAtPoint because that resets alignment values
    cgcLocal.fillText(s, x, y);
}

// horizontal: "start", "end", "left", "right", "center" (default: "start")
// vertical: "top", "hanging", "middle", "alphabetic", "ideographic", "bottom" (default: "alphabetic")
+ (void) p2setTextAlignHorizontal: (CPString) hor {
    cgcLocal.textAlign = hor;
}
+ (void) p2setTextAlignVertical: (CPString) vert {
    cgcLocal.textBaseline = vert;
}
+ (void) p2setTextAlignHorizontal: (CPString) hor vertical: (CPString) vert {
    cgcLocal.textBaseline = vert;  cgcLocal.textAlign = hor;
}
+ (void) p2setTextAlignDefault {
    [self p2setTextAlignHorizontal: "left" vertical: "middle"];
}

@end
