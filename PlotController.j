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
 For plotting test results history
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
    if (gTestingPlotting) { //this only needed for testing
        testHistoryFinalValue = 0.149;
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
        ]
    }
    return self;
}


- (void) drawRect: (CGRect) dirtyRect { //CPLog("PlotView>drawRect");
    if (firstTime !== "notFirstTime") { //ignore the very first call during launching
        firstTime = "notFirstTime";  return;
    }
    [MDB2plot p2init];
    if (!gTestingPlotting) {
        testHistory = [TrialHistoryController trialHistoryRecord];
        testHistoryFinalValue = gTestDetails[td_resultValue];
    }
    const nTrials = testHistory.length;
    const yMin = 3, yMax = -1.05, yHorAxis = yMin; //note inverted axis
    const yTick = (yMax - yMin) / 50;
    const xMin = -1, xMax = nTrials + 1;
    const xTick = (xMax - xMin) / 80;
    [MDB2plot p2wndwX0: xMin-0.01 y0: yMin x1: xMax y1: yMax];

    //title
    [MDB2plot p2setFontSize: 24];
    [MDB2plot p2setTextAlignHorizontal: "center" vertical: "hanging"];
    [MDB2plot p2showText: "Presented acuity grades along the run" atX: (xMax - xMin - 2) / 2 y: yMax];
    if ([Settings doThreshCorrection]) {
        [MDB2plot p2setFontSize: 14];
        [MDB2plot p2showText: "[Without threshold correction, so 0.05 LogMAR smaller]" atX: (xMax - xMin - 2) / 2 y: yMax +0.21];
    }
    [MDB2plot p2setTextAlignDefault];

    //axes
        //abscissa
    [MDB2plot p2setFontSize: 18];
    [MDB2plot p2hlineX0: xMin y: yHorAxis x1: nTrials];
    [MDB2plot p2setTextAlignHorizontal: "end" vertical: "bottom"];
//    [MDB2plot p2showText: "Trials→" atXpx: [yHorAxis p2tx: xMax-1] ypx: 490];
    [MDB2plot p2showText: "Trials→" atX: xMax - 1 y: yHorAxis + 4 * yTick];
    [MDB2plot p2setTextAlignHorizontal: "center"];
    for (let trial = 1; trial <= nTrials; trial++) {
        [MDB2plot p2vlineX: trial-0.5 y0: yHorAxis + yTick y1: yHorAxis];
        if ([Misc isOdd: trial]) {
            [MDB2plot p2showText: trial atX: trial-0.5 y: yHorAxis + yTick ];
        }
    }
    [MDB2plot p2setTextAlignDefault];

        //ordinate
    [MDB2plot p2vlineX: xMin y0: yMin y1: yMax];
    [MDB2plot p2showText: "↓LogMAR" atXpx: [MDB2plot p2tx: xMin+0.5] ypx: 40];
    for (let y = -1; y < 3; y++) {
        [MDB2plot p2hlineX0: xMin y: y x1: xMin + xTick];
        [MDB2plot p2showText: y atX: xMin + xTick +0.1 y: y];
    }
    for (let y = -1; y < 3; y+=0.1) {
        [MDB2plot p2hlineX0: xMin y: y x1: xMin + xTick/2];
    }

    //test points
    [MDB2plot p2setLineWidthInPx: 4];
    for (let trial = 0; trial < nTrials; trial++) {
        const y = testHistory[trial].value;
        if (testHistory[trial].isCorrect) {
            [MDB2plot p2setFillColor: [CPColor colorWithRed: 0 green: 0.6 blue: 0 alpha: 1]];
            [MDB2plot p2fillCircleAtX: trial+0.5 y: y radiusInPx: 10];
        } else {
            [MDB2plot p2setStrokeColor: [CPColor redColor]];
            [MDB2plot p2strokeXAtX: trial+0.5 y: y sizeInPx: 25];
        }
    }

    //line for final value
    let testHistoryFinalValueCorr = testHistoryFinalValue;
    if ([Settings doThreshCorrection]) { //"anticorrect" to let final coincide with history values
        testHistoryFinalValueCorr += Math.log10(gThresholdCorrection4Ascending);
    }
    [MDB2plot p2setStrokeColor: [CPColor blueColor]];
    [MDB2plot p2setLineWidthInPx: 2];
    [MDB2plot p2hlineX0: xMin+1.5 y: testHistoryFinalValueCorr x1: xMax];
    [MDB2plot p2setFillColor: [CPColor blueColor]];
    [MDB2plot p2setTextAlignVertical: "top"];
    let s = [Misc stringFromNumber: testHistoryFinalValueCorr decimals: 2];
    [MDB2plot p2showText: s+"↑" atXpx: [MDB2plot p2tx: xMin+1.5] ypx: [MDB2plot p2ty: testHistoryFinalValueCorr]+8];
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
