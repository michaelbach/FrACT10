/*
 This file is part of FrACT10, a vision test battery.
 © 2025 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 CardController.j
 Dealing with calibration via plastic card's size

 Created by mb on 2025-02-02.
 */

@import <AppKit/CPWindowController.j>
@import <AppKit/CPPanel.j>
@import <AppKit/CPImageView.j>
@import <AppKit/CPTextField.j>
@import <AppKit/CPButton.j>
@import "MDBLabel.j"
@import "Settings.j"
@import "Misc.j"
@import "MiscSpace.j"


const buttonsWidth = 44, buttonsHeight = 23;
const buttonsOkWidth = 68;
const buttonsY = (kFractHeight - buttonsHeight - 18);


@implementation CardController : CPWindowController {
    CPPanel plasticCardPanel;
    CPImageView plasticCardImageView;
    CPTextField resolutionField; 
    float calBarLengthInMMbefore; 
    CPView contentView;
}


//all buttons are very similar, will use `contentView` and set action target to `self`
- (CPButton) addButtonWithTitle: (CPString) title frame: (CGRect) frame tag: (int) tag tooltip: (CPString) tooltip selector: (SEL) sel {
    const b = [CPButton buttonWithTitle: title];
    [b setFrame: frame];  [b setTarget: self];  [b setAction: sel];
    if (tag >= 0) [b setTag: tag];
    if (tooltip !== "") [b setToolTip: tooltip];
    [contentView addSubview: b];
    return b;
}


- (void) createWindow {
    plasticCardPanel = [[CPPanel alloc] initWithContentRect: CGRectMake(0, 0, kFractWidth, kFractHeight) styleMask: CPTitledWindowMask];
    contentView = [plasticCardPanel contentView];
    [plasticCardPanel setTitle: "FrACT₁₀ – Settings ▸ Size Calibration"];
    [plasticCardPanel setFloatingPanel: YES];  [plasticCardPanel setMovable: NO];
    [self setWindow: plasticCardPanel];

    const infoText = [[CPTextField alloc] initWithFrame: CGRectMake(kGuiMarginHorizontal, 16, 762, 68)];
    [infoText setStringValue: "ID-1 cards as used for, e.g., credit cards or personal identification,\nhave a standardized size (ISO/IEC 7810:2019)"];
    [infoText setAlignment: CPCenterTextAlignment];
    [infoText setFont: [CPFont systemFontOfSize: 18]];  [infoText setEditable: NO];
    [contentView addSubview: infoText];

    plasticCardImageView = [[CPImageView alloc] initWithFrame: CGRectMake(284, 223, 233, 151)];
    const imagePath = [[CPBundle mainBundle] pathForResource: @"plasticCard4calibration.png"];
    [plasticCardImageView setImage: [[CPImage alloc] initWithContentsOfFile: imagePath]];
    [plasticCardImageView setImageScaling: CPImageScaleProportionallyDown];
    [contentView addSubview: plasticCardImageView];

    const placeCardText = [[CPTextField alloc] initWithFrame: CGRectMake(246, 264, 310, 38)];
    [placeCardText setStringValue: "Place plastic card here."];
    [placeCardText setAlignment: CPCenterTextAlignment];
    [placeCardText setFont: [CPFont systemFontOfSize: 18]];  [placeCardText setEditable: NO];
    [contentView addSubview: placeCardText];

    [self addButtonWithTitle: "+ +" frame: CGRectMake(kGuiMarginHorizontal, buttonsY, buttonsWidth, buttonsHeight) tag: 1 tooltip: "Click or press to increase the size of the plastic card image by 10%" selector: @selector(buttonPlasticCardPlusMinus_action:)];
    [self addButtonWithTitle: "+" frame: CGRectMake(66, buttonsY, buttonsWidth, buttonsHeight) tag: 0 tooltip: "Click or press to increase the size of the plastic card image by 1%" selector: @selector(buttonPlasticCardPlusMinus_action:)];
    [self addButtonWithTitle: "–" frame: CGRectMake(113, buttonsY, buttonsWidth, buttonsHeight) tag: 2 tooltip: "Click or press to decrease the size of the plastic card image by 1%" selector: @selector(buttonPlasticCardPlusMinus_action:)];
    [self addButtonWithTitle: "– –" frame: CGRectMake(160, buttonsY, buttonsWidth, buttonsHeight) tag: 3 tooltip: "Click or press to decrease the size of the plastic card image by 10%" selector: @selector(buttonPlasticCardPlusMinus_action:)];

    const instructionLabel = [[MDBLabel alloc] initWithFrame: CGRectMake(210, buttonsY, 300, buttonsHeight)];
    [instructionLabel setStringValue: "← Use the ± buttons to fit the card ↑"];
    [instructionLabel setFont: [CPFont systemFontOfSize: 17]];
    [contentView addSubview: instructionLabel];

    const mmPxLabel = [[CPTextField alloc] initWithFrame: CGRectMake(513, buttonsY+4, 61, 16)];
    [mmPxLabel setStringValue: @"→mm/px:"];
    [mmPxLabel setAlignment: CPRightTextAlignment];
    [contentView addSubview: mmPxLabel];

    resolutionField = [[CPTextField alloc] initWithFrame: CGRectMake(573, buttonsY-2, 48, 24)];
    [resolutionField setEditable: NO];  [resolutionField setBezeled: YES];
    [resolutionField setAlignment: CPCenterTextAlignment];
    [resolutionField sizeToFit];
    [contentView addSubview: resolutionField];

    const btnCancel = [self addButtonWithTitle: "Cancel" frame: CGRectMake(629, buttonsY, buttonsOkWidth, buttonsHeight) tag: 1 tooltip: "Cancel calibration and revert to previous value" selector: @selector(buttonPlasticCardClosePanel_action:)];
    [btnCancel setKeyEquivalent: CPEscapeFunctionKey];
    
    const btnOK = [self addButtonWithTitle: "OK" frame: CGRectMake(711, buttonsY, buttonsOkWidth, buttonsHeight) tag: 0 tooltip: "Accept calibration and close panel" selector: @selector(buttonPlasticCardClosePanel_action:)];
    [btnOK setKeyEquivalent: crlf];
}


- (void) plasticCardUpdateSize {
    const wInPx = [MiscSpace pixelFromMillimeter: 92.4]; //magic number, why not 85.6?
    const hOverW = 53.98 / 85.6; //All ID-1 bank cards are 85.6 mm wide and 53.98 mm high
    //https://en.wikipedia.org/wiki/ISO/IEC_7810
    //https://www.iso.org/obp/ui/en/#iso:std:iso-iec:7810:ed-4:v1:en
    //ID-1: nominally 85,60 mm wide by 53,98 mm high by 0,76 mm thick
    const hInPx = wInPx * hOverW, xc = 400, yc = 300 - 24; //position in window, space for buttons
    [plasticCardImageView setFrame: CGRectMake(xc - wInPx / 2, yc - hInPx / 2, wInPx, hInPx)];
    [resolutionField setStringValue:
      [Misc stringFromNumber:
        [MiscSpace millimeterFromPixel: 1] decimals: 3 localised: YES]];
}


- (IBAction) buttonPlasticCardUse_action: (id) sender { //console.info("buttonPlasticCardUse_action");
    if (!plasticCardPanel) {
        [self createWindow];
    }
    calBarLengthInMMbefore = [Settings calBarLengthInMM]; //for undo=cancel
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
    if ([sender tag] === 1) {
        [Settings setCalBarLengthInMM: calBarLengthInMMbefore]; //undo
    }
    let t = [Settings calBarLengthInMM];
    if (t >= 100) {
        t = Math.round(t); //don't need that much precision
    }
    [Settings setCalBarLengthInMM: t];
    [Settings calculateMinMaxPossibleAcuity];
    [plasticCardPanel close];
}


@end
