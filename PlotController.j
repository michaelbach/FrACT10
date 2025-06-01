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
    float testHistoryFinalValue;
}

//This is called by IB
- (id) initWithFrame: (CGRect) theFrame { //CPLog("PlotView>initWithFrame");
    self = [super initWithFrame: theFrame];
    /*    testHistoryFinalValue = 0.149;
    testHistory = [
        {value: 1, correct: true},
        {value: 0.7, correct: true},
        {value: 0.4, correct: true},
        {value: 0.1, correct: true},
        {value: -0.033, correct: false},
        {value: 0.139, correct: false},
        {value: 0.284, correct: true},
        {value: 0.203, correct: true},
        {value: 0.136, correct: true},
        {value: 0.078, correct: false},
        {value: 0.160, correct: true},
        {value: 0.615, correct: true},
        {value: 0.101, correct: true},
        {value: 0.060, correct: false},
        {value: 0.121, correct: true},
        {value: 0.085, correct: false},
        {value: 0.138, correct: true},
        {value: 0.609, correct: true}
    ]*/
    return self;
}
- (void) drawRect: (CGRect) dirtyRect { //CPLog("PlotView>drawRect");
    if (firstTime !== "notFirstTime") {
        firstTime = "notFirstTime";  return;
    }
    const cgc_ = [[CPGraphicsContext currentContext] graphicsPort]
    [MDB2plot p2initWithCGC: cgc_];

    testHistory = [TrialHistoryController trialHistoryRecord];
    testHistoryFinalValue = [TrialHistoryController finalValue];
    const n = testHistory.length;
//    const yMax = 2.5, yMin = -0.6, yHorAxis = yMin;
    const yMax = -0.6, yMin = 2.5, yHorAxis = yMin;
    const yTick = (yMax - yMin) / 50;
    const xMax = n, xMin = -0.5;
    const xTick = (xMax - xMin) / 50;

    [MDB2plot p2wndwX0: -0.5 y0: yMin - yTick x1: n y1: yMax];

    [MDB2plot p2hlineX0: 0 y: yHorAxis x1: n]; //abscissa
    for (let x = 1; x <= n; x++)  [MDB2plot p2vlineX: x-0.5 y0: yHorAxis - yTick y1: yHorAxis];

    [MDB2plot p2vlineX: 0 y0: yMin y1: yMax]; //ordinate
    [MDB2plot p2hlineX0: -xTick y: 0 x1: 0];
    [MDB2plot p2hlineX0: -xTick y: 1 x1: 0];

    CGContextSetLineWidth(cgc_, 4);
    for (let trial = 0; trial < n; trial++) {
        const y = testHistory[trial].value;
        if (testHistory[trial].correct) {
            CGContextSetFillColor(cgc_, [CPColor colorWithRed: 0 green: 0.6 blue: 0 alpha: 1]);
            [MDB2plot p2fillCircleAtX: trial+0.5 y: y radiusInPx: 10];
        } else {
            CGContextSetStrokeColor(cgc_, [CPColor redColor]);
            [MDB2plot p2strokeXAtX: trial+0.5 y: y sizeInPx: 25];
        }
    }
    CGContextSetStrokeColor(cgc_, [CPColor blackColor]);

    if ([Settings doThreshCorrection]) { //"anticorrect" to let final coincide with history values
        testHistoryFinalValue += Math.log10(gThresholdCorrection4Ascending);
    }
    CGContextSetLineWidth(cgc_, 2);
    [MDB2plot p2hlineX0: xMin y: testHistoryFinalValue x1: xMax];
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
