/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2025 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 PlotController.j

 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "AppController.j"
@import "MDB2plot.j"

/**
 For plotting test history
 Created by Bach on 2025-05-29
 */




@implementation PlotView: CPView {
    CPString firstTime;
    id testHistory;
}
//This is called by IB
- (id) initWithFrame: (CGRect) theFrame { //CPLog("PlotView>initWithFrame");
    self = [super initWithFrame: theFrame];
    testHistory = [
        {value: 1, correct: true},
        {value: 0.7, correct: true},
        {value: 0.4, correct: true},
        {value: 0.1, correct: true},
        {value: -0.5, correct: true},
        {value: -0.77, correct: true},
        {value: -0.96, correct: false},
        {value: -0.8, correct: true},
        {value: -0.9, correct: false},
        {value: -0.8, correct: true},
        {value: -0.88, correct: false},
        {value: -0.3, correct: true}
    ]
    return self;
}
- (void) drawRect: (CGRect) dirtyRect { //CPLog("PlotView>drawRect");
    if (firstTime !== "notFirstTime") {
        firstTime = "notFirstTime";  return;
    }
    const cgc_ = [[CPGraphicsContext currentContext] graphicsPort]
    [MDB2plot p2initWithCGC: cgc_];
    const n = testHistory.length;
    const yMax = 1.5, yMin = -3, yHorAxis = yMin;
    const yTick = (yMax - yMin) / 50;
    const xMax = n, xMin = -0.5;
    const xTick = (xMax - xMin) / 50;

    [MDB2plot p2wndwX0: -0.5 y0: yMin - yTick x1: n y1: yMax];

    [MDB2plot p2hlineX0: 0 y: yHorAxis x1: n]; // abscissa
    for (let x = 1; x <= n; x++)  [MDB2plot p2vlineX: x y0: yHorAxis - yTick y1: yHorAxis];

    [MDB2plot p2vlineX: 0 y0: yMin y1: yMax]; // ordinate
    [MDB2plot p2hlineX0: -xTick y: 0 x1: 0];
    [MDB2plot p2hlineX0: -xTick y: 1 x1: 0];

    for (let trial = 0; trial < n; trial++) {
        const y = -yMax - testHistory[trial].value;
        if (testHistory[trial].correct) {
            [MDB2plot p2strokeXAtX: trial y: y sizeInPx: 20];
        } else {
            [MDB2plot p2strokeCircleAtX: trial y: y radiusInPx: 10];
        }
    }

}
@end


@implementation PlotController: CPWindowController {
    @outlet CPPanel plotPanel;
    @outlet PlotView plotView1;
    CPString s;
}


- (IBAction) buttonPlotOpen_action: (id) sender { //CPLog("AboutAndHelpController>buttonPlotOpen_action");
    [plotPanel setMovable: NO];
    [Misc centerWindowOrPanel: plotPanel];
    [plotPanel makeKeyAndOrderFront: self];
}


- (IBAction) buttonPlotClose_action: (id) sender { //CPLog("AboutAndHelpController>buttonPlotClose_action");
    [plotPanel close];
}



@end
