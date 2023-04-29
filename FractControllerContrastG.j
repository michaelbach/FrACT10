/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2021 Michael Bach, michael.bach@uni-freiburg.de, <https://michaelbach.de>
 
 FractControllerContrastG.j: Gratings
 
 Created by Bach on 2020-09-02
 */


@import "FractControllerContrast.j"
@implementation FractControllerContrastG: FractControllerContrast {
}


- (void) annulusWithRadius: (float) r width: (float) w grey: (float) g alpha: (float) a {
    CGContextSetLineWidth(cgc, w + 0.1);
    CGContextSetStrokeColor(cgc, [CPColor colorWithWhite: g alpha: a]);
    CGContextStrokeEllipseInRect(cgc, CGRectMake(0 - r, 0 - r, 2 * r, 2 * r));
}
- (void) gratingSineWithPeriodInPx:  (float) periodInPx direction: (int) theDirection {
    //console.info("optotypes>gratingSineWithPeriodInPx: ", periodInPx, theDirection);
    let contrastMichelson = 0.3;
    const l2 = 2 * Math.round(0.5 * 1.42 * Math.max(viewWidth2, viewHeight2));
    const trigFactor = 1.0 / periodInPx * 180 / Math.PI;
    CGContextRotateCTM(cgc, -theDirection * 22.5 * Math.PI / 180);
    CGContextSetLineWidth(cgc, 1.3);
    let l;
    for (let ix = -l2; ix <= l2; ++ix) {
        l = 0.5 + 0.5 * contrastMichelson * Math.sin((ix % periodInPx) * trigFactor);
        l = [MiscLight devicegrayFromLuminance: l];
        CGContextSetStrokeColor(cgc, [CPColor colorWithWhite: l alpha: 1]);
        CGContextBeginPath(cgc);
        CGContextMoveToPoint(cgc, ix, -l2);  CGContextAddLineToPoint(cgc, ix, l2);
        CGContextStrokePath(cgc);
    }
    //let r = 0.5 * [MiscSpace pixelFromDegree: [Settings gratingDiaInDeg]];
    let r = 0.5 * 200;
    let w = 4;
    l = [MiscLight devicegrayFromLuminance: 0.5];
    [self annulusWithRadius: r - 2 * w width: w grey: l alpha: 0.125];
    [self annulusWithRadius: r - w width: w grey: l alpha: 0.25];
    [self annulusWithRadius: r width: w grey: l alpha: 0.5];
    [self annulusWithRadius: r + w width: w grey: l alpha: 0.75];
    [self annulusWithRadius: r + 2 * w width: w grey: l alpha: 0.875];
    [self annulusWithRadius: r + 400 width: 780 grey: l alpha: 1];
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerContrastG>drawStimulusInRect");
    [self calculateForeBackColors];
    [self prepareDrawing];
    switch(state) {
        case kStateDrawBack: break;
        case kStateDrawFore:
            [self drawFixMark];
            break;
        case kStateDrawFore2:
            let period = 2 * Math.round(optotypeSizeInPix);
            [self gratingSineWithPeriodInPx: 4*period direction: [alternativesGenerator currentAlternative]];
            [self drawFixMark3];
            stimStrengthInDeviceunits = [optotypes getCurrentContrastLogCSWeber];
            trialInfoString = [self contrastComposeTrialInfoString];// compose here after colors are set
            break;
        default: break;
    }
    
    if ([Settings enableTouchControls] && (!responseButtonsAdded)) {
        const sze = 50, sze2 = sze / 2, radius = 0.5 * Math.min(viewWidth, viewHeight) - sze2 - 1;
        for (let i = 0; i < 8; i++) {
            if ( ([Settings nAlternatives] > 4)  || (![Misc isOdd: i])) {
                const ang = i / 8 * 2 * Math.PI;
                [self buttonCenteredAtX: viewWidth / 2 + Math.cos(ang) * radius y:  Math.sin(ang) * radius size: sze title: [@"632147899" characterAtIndex: i]];
            }
        }
        [self buttonCenteredAtX: viewWidth - sze2 - 1 y: viewHeight / 2 - sze2 - 1 size: sze title: "Ø"];
    }
    
    CGContextRestoreGState(cgc);
    [super drawStimulusInRect: dirtyRect];
}


- (void) runStart { //console.info("FractControllerContrastLett>runStart");
    nAlternatives = 4;  nTrials = [Settings nTrials04];
    [super runStart];
}


- (int) responseNumberFromChar: (CPString) keyChar { //console.info("FractControllerContrastE>responseNumberFromChar: ", keyChar);
    switch (keyChar) {
        case CPLeftArrowFunctionKey: return 0; // ⬅️
        case CPRightArrowFunctionKey: return 0; // ➡️
        case CPUpArrowFunctionKey: return 4; // ⬆️
        case CPDownArrowFunctionKey: return 4; // ⬇️
        case "1": return 2; // ↙️
        case "2": return 4; // ⬇️
        case "3": return 6; // ↘️
        case "4": return 0; // ⬅️
        case "5": return -2;
        case "6": return 0; // ➡️
        case "7": return 6; // ↖️
        case "8": return 4; // ⬆️
        case "9": return 2; // ↗️
    }
    return -2;// 0, 2, 4, 6: valid; -1: ignore; -2: invalid
}


@end
