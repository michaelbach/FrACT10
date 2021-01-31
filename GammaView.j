//
//  GammaView.m
//  _cappDevelop
//
//  Created by Bach on 31.01.21.
//

@import <AppKit/CPView.j>


@implementation GammaView: CPView {
    CGContext cgc;
    CPColor grayHalf, grayPlus, grayMinus;
    int checkSize, iLeft, iRight, iBottom, iTop, ix, iy, xm, ym;
    BOOL polarity;
}


- (id) initWithFrame: (CGRect) theFrame {//console.info("GammaView>initWithFrame");
    self = [super initWithFrame: theFrame];
    return self;
}


- (void) drawRect: (CGRect) dirtyRect {//console.info("GammaView>drawRect");
    [super drawRect: dirtyRect];
    cgc = [[CPGraphicsContext currentContext] graphicsPort];
    xm = CGRectGetWidth([self bounds]) / 2;
    ym = CGRectGetHeight([self bounds]) / 2;
    
    CGContextSetLineWidth(cgc, 1);
    grayHalf = [CPColor colorWithWhite: [Misc devicegrayFromLuminance: 0.5] alpha: 1];
    CGContextSetFillColor(cgc, grayHalf);    CGContextFillRect(cgc, [self bounds]);

    CGContextTranslateCTM(cgc, xm, ym); // origin to center
    grayPlus = [CPColor colorWithWhite: [Misc devicegrayFromLuminance: 0.05] alpha: 1];
    grayMinus = [CPColor colorWithWhite: [Misc devicegrayFromLuminance: 0.95] alpha: 1];
    iLeft = Math.round(-xm/4.0), iRight = Math.round(xm/4.0), iBottom = Math.round(-ym/4.0), iTop = Math.round(ym/4.0);
    checkSize = 2;
    polarity = YES;
    for (iy = iBottom; iy < iTop; iy += checkSize) {
        polarity = !polarity;
        for (ix = iLeft; ix < iRight; ix += checkSize) {
            polarity = !polarity;
            if (polarity) CGContextSetFillColor(cgc, grayPlus); else CGContextSetFillColor(cgc, grayMinus);
            CGContextFillRect(cgc, CGRectMake(ix, iy, checkSize, checkSize));
        }
    }
}


@end
