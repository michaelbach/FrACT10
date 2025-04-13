/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2025 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 CardController.j

 Created by mb on 2025-02-02.
 */


/**
 CardController

 Dealing with calibration via plastic card's size
 */

@implementation CardController : CPWindowController {
    @outlet CPPanel plasticCardPanel;
    @outlet CPImageView plasticCardImageView;
    float calBarLengthInMMbefore;
}


- (void) plasticCardUpdateSize {
    const wInPx = [MiscSpace pixelFromMillimeter: 92.4]; //magic number, why not 85.6?
    const hOverW = 53.98 / 85.6; // All ID-1 bank cards are 85.6 mm wide and 53.98 mm high
    // https://en.wikipedia.org/wiki/ISO/IEC_7810
    // https://www.iso.org/obp/ui/en/#iso:std:iso-iec:7810:ed-4:v1:en
    // ID-1: nominally 85,60 mm wide by 53,98 mm high by 0,76 mm thick
    const hInPx = wInPx * hOverW, xc = 400, yc = 300 - 24; // position in window, space for buttons
    [plasticCardImageView setFrame: CGRectMake(xc - wInPx / 2, yc - hInPx / 2, wInPx, hInPx)];
}


- (IBAction) buttonPlasticCardUse_action: (id) sender { //console.info("buttonPlasticCardUse_action");
    calBarLengthInMMbefore = [Settings calBarLengthInMM];//for undo=cancel
    [plasticCardPanel makeKeyAndOrderFront: self];
    [Misc centerWindowOrPanel: plasticCardPanel];
    [self plasticCardUpdateSize];
}


- (IBAction) buttonPlasticCardPlusMinus_action: (id) sender {
    let f = 1;
    switch ([sender tag]) {
        case 0: f = 1.0 / 1.01;  break;
        case 1: f = 1.0 / 1.1;  break;
        case 2: f = 1.01;  break;
        case 3: f = 1.1;  break;
    }
    [Settings setCalBarLengthInMM: [Settings calBarLengthInMM] * f];
    [self plasticCardUpdateSize];
}


- (IBAction) buttonPlasticCardClosePanel_action: (id) sender {
    if ([sender tag] == 1) {
        [Settings setCalBarLengthInMM: calBarLengthInMMbefore];//undo
    }
    let t = [Settings calBarLengthInMM];
    if (t >= 100) {
        t = Math.round(t); // don't need that much precision
    }
    [Settings setCalBarLengthInMM: t];
    [Settings calculateMinMaxPossibleAcuity];
    [plasticCardPanel close];
}


@end
