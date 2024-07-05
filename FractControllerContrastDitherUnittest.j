/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 FractControllerContrastDitherUnittest.j
 
Created by Bach on 2020-08-17
*/


@import "FractControllerContrast.j"
@implementation FractControllerContrastDitherUnittest: FractControllerContrast {
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerContrastDitherUnittest>drawStimulusInRect", state);
    stimStrengthInDeviceunits = 0.5;  stimStrengthInDeviceunitsUnquantised = stimStrengthInDeviceunits;
    [self calculateForeBackColors];
    gColorBack = [Settings windowBackgroundColor];
    [self prepareDrawing];
    switch(state) {
        case kStateDrawBack:  break;
        case kStateDrawFore:
            [self drawFixMark];  break;
        case kStateDrawFore2:
            const xWidth = 3;  let xPos = -400, xPos1 = -300;
            CGContextSetFillColor(cgc, [CPColor whiteColor]);
            //gColorFore = [CPColor colorWithPatternImage: [[CPImage alloc] initWithContentsOfFile: [[CPBundle mainBundle] pathForResource: "allRewards4800x200.png"]]];
            // for some reason, the ditherimage is not a working pattern color when draw… is called for the first time…
            for (let g1 = 127-10; g1 <= 127 + 10; g1++) {
                for (let g2 = 0; g2 < 9; g2++) {
                    const g = (g1 + g2 / 9) / 255;//console.info("g * 255", g * 255)
                    gColorFore = [CPColor colorWithPatternImage: [Dithering image3x3withGray: g]];
                    CGContextSetFillColor(cgc, gColorFore);
                    CGContextFillRect(cgc, CGRectMake(xPos, 20, xWidth, 200));
                    CGContextFillRect(cgc, CGRectMake(xPos1, -220, xWidth, 200));
                    xPos += xWidth + 1;  xPos1 +=xWidth;
                }
                xPos += xWidth
            }
            trialInfoString = "Dither Test";
            break;
    }
    CGContextRestoreGState(cgc);
    [super drawStimulusInRect: dirtyRect];
}


- (void) runStart { //console.info("FractControllerContrastLett>runStart");
    nAlternatives = 2;  nTrials = 9999;
    [super runStart];
}


- (int) responseNumberFromChar: (CPString) keyChar { //console.info("FractControllerAcuityLetters>responseNumberFromChar: ", keyChar);
    return -1;// -1: ignore; -2: invalid
}


@end
