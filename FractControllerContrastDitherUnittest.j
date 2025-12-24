/*
This file is part of FrACT10, a vision test battery.
© 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 FractControllerContrastDitherUnittest.j
 
Created by Bach on 2025-03-11
*/


@import "FractControllerContrast.j"
@implementation FractControllerContrastDitherUnittest: FractControllerContrast {
}


- (void) runStart { //console.info("FractControllerContrastDitherUnittest>runStart");
    nAlternatives = 2;  nTrials = 9999;
    [super runStart];
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //CPLog("FractControllerContrastDitherUnittest>drawStimulusInRect");
    [self calculateForeBackColors];
    [self prepareDrawing];
    const w = 10;
    stimStrengthInDeviceunits = 2.0;//logCSWeber: this will be very low contrast
    for (let x = -viewWidthHalf; x < viewWidth; x += w) {
        let r = CGRectMake(x, -viewHeightHalf, w, viewHeightHalf);
        stimStrengthInDeviceunits -= 0.007;
        if (stimStrengthInDeviceunits > 1) stimStrengthInDeviceunits = 1;
        [self calculateForeBackColors];
        console.info(x, stimStrengthInDeviceunits, [MiscLight contrastWeberPercentFromLogCSWeber: stimStrengthInDeviceunits]);
        CGContextSetFillColor(cgc, gColorFore);
        CGContextFillRect(cgc, r);
    }
    [super drawStimulusInRect: dirtyRect];
}


- (int) responseNumberFromChar: (CPString) keyChar { //console.info("FractControllerContrastDitherUnittest>responseNumberFromChar: ", keyChar);
    return -1; //-1: ignore; -2: invalid
}


@end
