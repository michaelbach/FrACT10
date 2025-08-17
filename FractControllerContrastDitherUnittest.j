/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

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
    // does not do anything but prevents crash
}


- (int) responseNumberFromChar: (CPString) keyChar { //console.info("FractControllerContrastDitherUnittest>responseNumberFromChar: ", keyChar);
    return -1; //-1: ignore; -2: invalid
}


@end
