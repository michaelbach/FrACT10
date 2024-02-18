/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2023 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>
 
 Misc.j
 
 */


@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Settings.j"


/**
 A collection of "miscellaneous" function for light / contrast / color.
 All a class variables for easy global access,
 */
@implementation MiscLight: CPObject {
}


/**
 Michelson ←→ Weber contrast.
 both contrasts are defined on a -100…100 scale
 Weber is modified so it is also point-symmetric around zero like Michelson
 */
+ (float) contrastMichelsonPercentFromL1: (float) l1 l2: (float) l2 {
    return -(l1 - l2) / (l1 + l2) * 100;
}
/**
 Transform Michelson → Weber, in & out in %
 */
+ (float) contrastWeberPercentFromMichelsonPercent: (float) inMichelsonPercent {
    let inMichelson = inMichelsonPercent /= 100,  outWeber;
    if (inMichelson >= 0) {
        outWeber = 2 * inMichelson / (1 + inMichelson);
    } else {
        inMichelson *= -1;
        outWeber = 2 * inMichelson / (1 + inMichelson);
        outWeber *= 1;
    }
    // console.info("contrastWeberPercentFromMichelsonPercent: ", inMichelson * 100, outWeber * 100);
    return outWeber * 100;
}
/**
 And the inverse
 */
+ (float) contrastMichelsonPercentFromWeberPercent: (float) inWeberPercent {
    const inWeber = inWeberPercent /= 100;
    const outMichelson = inWeber / (2 - inWeber);
    return outMichelson * 100;
}


/**
 Transform Weber% → logCSWeber
 */
+ (float) contrastLogCSWeberFromWeberPercent: (float) weberPercent {
    weberPercent /= 100;
    const logCS = (weberPercent > 0.0001) ? Math.log10(1 / weberPercent) : 4.0
    return logCS;     // avoid log of zero
}
/**
 And the inverse
 */
+ (float) contrastWeberPercentFromLogCSWeber: (float) logCS {
    const weberPercent = 100 * Math.pow(10, -logCS);
    return weberPercent;
}


/**
 Returns the brightness component given a CPColor
 */
+ (float) getBrightnessViaCSSfromColor: (CPColor) aColor {
    return [[CPColor colorWithCSSString: [aColor cssString]] brightnessComponent];
}


+ (void) testContrastConversion {
    for (let i = -100; i <= 100; i += 10) {
        const w = [MiscLight contrastWeberPercentFromMichelsonPercent: i];
        console.info("contrastM: ", i, ", W: ", w, ", M: ", [MiscLight contrastMichelsonPercentFromWeberPercent: w]);
    }
}


/**
 scale transformations luminance ⇄ devicegray
 contrast: -100 … 100 (both for Michelson & Weber)
 “devicegray": 0 … 1 AFTER gamma correction
 "luminance": (0…1) a "normalised" luminance as would be measured in cd/m²
 */
+ (float) devicegrayFromLuminance: (float) luminance {
    return Math.pow(luminance, 1 / [Settings gammaValue]);
}
/**
 And the inverse
 */
+ (float) luminanceFromDevicegray: (float) g {
    return Math.pow(g, [Settings gammaValue]);
}

+ (float) lowerLuminanceFromContrastMilsn: (float) contrast { //console.info("lowerLuminanceFromContrastMilsn");
    return [Misc limit01: [Misc limit01: 0.5 - 0.5 * contrast / 100]];
}
/**
 And the inverse
 */
+ (float) upperLuminanceFromContrastMilsn: (float) contrast { //console.info("highLuminanceFromContras");
    return [Misc limit01: [Misc limit01: 0.5 + 0.5 * contrast / 100]];
}


+ (float) lowerLuminanceFromContrastLogCSWeber: (float) logCSW {
    const weberPercent = [MiscLight contrastWeberPercentFromLogCSWeber: logCSW];
    const michelson = [self contrastMichelsonPercentFromWeberPercent: weberPercent];
    return [self lowerLuminanceFromContrastMilsn: michelson];
}
/**
 And the inverse
 */
+ (float) upperLuminanceFromContrastLogCSWeber: (float) logCSW {
    const weberPercent = [MiscLight contrastWeberPercentFromLogCSWeber: logCSW];
    const michelson = [self contrastMichelsonPercentFromWeberPercent: weberPercent];
    return [self upperLuminanceFromContrastMilsn: michelson];
}


+ (float) contrastMichelsonPercentFromDevicegray1: (float) g1 g2: g2 {
    const l1 = [self luminanceFromDevicegray: g1], l2 = [self luminanceFromDevicegray: g2];
    return [self contrastMichelsonPercentFromL1: l1 l2: l2];
}
/**
 And the inverse
 */
+ (float) contrastMichelsonPercentFromColor1: (float) c1 color2: c2 {
    const g1 = [self getBrightnessViaCSSfromColor: c1], g2 = [self getBrightnessViaCSSfromColor: c2];
    return [self contrastMichelsonPercentFromDevicegray1: g1 g2: g2];
}


+ (float) contrastMichelsonPercentFromLogCSWeber: (float) logCSWeber {
    return [MiscLight contrastMichelsonPercentFromWeberPercent: [MiscLight contrastWeberPercentFromLogCSWeber: logCSWeber]];
}


+ (CPColor) colorFromGreyBitStealed: (float) greyLevel { //console.info("calcColorFromGrey");
    if ([Settings contrastBitStealing]) {
        const gDiscrete = Math.floor(greyLevel * 256);
        const fraction = greyLevel - gDiscrete / 256;
        const fractionIdx = Math.floor(8 * fraction * 256);
        let r = 0, g = 0, b = 0;
        switch(fractionIdx) {
            case 1: b = 1; break;
            case 2: r = 1; break;
            case 3: b = 1; r = 1; break;
            case 4: g = 1; break;
            case 5: b = 1; g = 1; break;
            case 6: r = 1; g = 1; break;
            case 7: b = 1; r = 1; g = 1; break;
        }
        //console.info(fractionIdx);
        r = (gDiscrete + r) / 256; g = (gDiscrete + g) / 256; b = (gDiscrete + b) / 256;
        return [CPColor colorWithRed: r green: g blue: b alpha: 1];
    }
    return [CPColor colorWithWhite: greyLevel alpha: 1]
}

@end
