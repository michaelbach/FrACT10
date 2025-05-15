/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2025 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 CheckingContrastController.j

 Created by mb on 2025-02-09.
 */


/**
 CheckingContrastController

 Dealing with the Checking Contrast stuff: Init, and responding to buttons
 */

@implementation CheckingContrastController : CPWindowController {
    CPColor weberFieldColor1 @accessors;
    CPColor weberFieldColor2 @accessors;
    float actualWeberPercent @accessors;
    float actualMichelsonPercent @accessors;
}


- (id) init { //console.info("CheckingContrastController>Init");
    [self buttonCheckContrast_action: null]; //populate fields
    return self;
}


//all buttons to this action, discriminated by tag value
- (IBAction) buttonCheckContrast_action: (id) sender { //console.info("CheckingContrastController>buttonCheckContrast_action");
    const tag = sender ? [sender tag] : 3; //if sender===null select 10%
    let contrastWeberPercent = 0;
    if ((tag > 0) && (tag <= 5))  contrastWeberPercent = [1, 3, 10, 30, 90][tag - 1];
    const contrastLogCSWeber = [MiscLight contrastLogCSWeberFromWeberPercent: contrastWeberPercent];
    let gray1 = [MiscLight lowerLuminanceFromContrastLogCSWeber: contrastLogCSWeber];
    gray1 = [MiscLight devicegrayFromLuminance: gray1];
    let gray2 = [MiscLight upperLuminanceFromContrastLogCSWeber: contrastLogCSWeber];
    gray2 = [MiscLight devicegrayFromLuminance: gray2];
    if (![Settings contrastDarkOnLight]) {
        [gray1, gray2] = [gray2, gray1]; //"modern" swapping of variables
    }
    //console.log("Wperc ", contrastWeberPercent, ", lgCSW ", contrastLogCSWeber, ", g1 ", gray1, ", g2 ", gray2);
    //const c1 = [CPColor colorWithWhite: gray1 alpha: 1], c2 = [CPColor colorWithWhite: gray2 alpha: 1];
    let c1 = [MiscLight colorFromGreyBitStealed: gray1];
    let c2 = [MiscLight colorFromGreyBitStealed: gray2];
    if ([Settings contrastDithering]) {
        c1 = [CPColor colorWithPatternImage: [Dithering image3x3withGray: gray1]];
        c2 = [CPColor colorWithPatternImage: [Dithering image3x3withGray: gray2]];
    }
    [self setWeberFieldColor1: c1];
    [self setWeberFieldColor2: c2];
    let actualMichelsonPerc = [MiscLight contrastMichelsonPercentFromColor1: c1 color2: c2];
    let actualWeberPerc = [MiscLight contrastWeberPercentFromMichelsonPercent: actualMichelsonPerc];
    if ([Settings contrastDithering]) {
        actualMichelsonPerc = [MiscLight contrastMichelsonPercentFromWeberPercent: contrastWeberPercent];
        actualWeberPerc = contrastWeberPercent;
    }
    [self setActualMichelsonPercent: Math.round(actualMichelsonPerc * 10) / 10];
    [self setActualWeberPercent: Math.round(actualWeberPerc * 10) / 10];
}


@end
