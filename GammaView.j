/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

GammaView.m
 
*/

@import <AppKit/CPView.j>


/**
 This draws the checkerboard patterns for the psychophysical gamma estimation.
 Created on 31.01.21.
 */
@implementation GammaView: CPView {
    CGContext _cgc; // differs from the global `cgc`
    CPColor grayHalf, grayPlus, grayMinus;
    int checkSize, iLeft, iRight, iBottom, iTop, ix, iy, xm, ym;
    BOOL polarity;
}


- (id) initWithFrame: (CGRect) theFrame { //console.info("GammaView>initWithFrame");
    self = [super initWithFrame: theFrame];
    return self;
}


- (void) drawRect: (CGRect) dirtyRect { //console.info("GammaView>drawRect");
    [super drawRect: dirtyRect];
    _cgc = [[CPGraphicsContext currentContext] graphicsPort];
    xm = CGRectGetWidth([self bounds]) / 2;
    ym = CGRectGetHeight([self bounds]) / 2;
    
    CGContextSetLineWidth(_cgc, 1);
    grayHalf = [CPColor colorWithWhite: [MiscLight devicegrayFromLuminance: 0.5] alpha: 1];
    CGContextSetFillColor(_cgc, grayHalf);    CGContextFillRect(_cgc, [self bounds]);

    CGContextTranslateCTM(_cgc, xm, ym); // origin to center
    grayPlus = [CPColor colorWithWhite: [MiscLight devicegrayFromLuminance: 0.05] alpha: 1];
    grayMinus = [CPColor colorWithWhite: [MiscLight devicegrayFromLuminance: 0.95] alpha: 1];
    iLeft = Math.round(-xm/4.0), iRight = Math.round(xm/4.0), iBottom = Math.round(-ym/4.0), iTop = Math.round(ym/4.0);
    checkSize = 2;
    polarity = YES;
    for (iy = iBottom; iy < iTop; iy += checkSize) {
        polarity = !polarity;
        for (ix = iLeft; ix < iRight; ix += checkSize) {
            polarity = !polarity;
            if (polarity) CGContextSetFillColor(_cgc, grayPlus); else CGContextSetFillColor(_cgc, grayMinus);
            CGContextFillRect(_cgc, CGRectMake(ix, iy, checkSize, checkSize));
        }
    }
}


@end
