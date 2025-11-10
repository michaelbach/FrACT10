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
    float testHistoryResultValue;
    BOOL isAcuity, isContrast;
}

//This is called by IB
- (id) initWithFrame: (CGRect) theFrame { //CPLog("PlotView>initWithFrame");
    self = [super initWithFrame: theFrame];
    if (gTestingPlottingAcuity1Contrast2 == 1) { //this only needed for testing
        testHistoryResultValue = 0.149;
        testHistory = [
            {value: 1, isCorrect: true},
            {value: 0.7, isCorrect: true},
            {value: 0.4, isCorrect: true},
            {value: 0.1, isCorrect: true},
            {value: -0.033, isCorrect: false},
            {value: 0.139, isCorrect: false},
            {value: 0.284, isCorrect: true},
            {value: 0.203, isCorrect: true},
            {value: 0.136, isCorrect: true},
            {value: 0.078, isCorrect: false},
            {value: 0.160, isCorrect: true},
            {value: 0.615, isCorrect: true},
            {value: 0.101, isCorrect: true},
            {value: 0.060, isCorrect: false},
            {value: 0.121, isCorrect: true},
            {value: 0.085, isCorrect: false},
            {value: 0.138, isCorrect: true},
            {value: 0.609, isCorrect: true}
        ]
    }
    if (gTestingPlottingAcuity1Contrast2 == 2) { //this only needed for testing
        testHistoryResultValue = 1.832;
        testHistory = [
            {value: 0.584, isCorrect: true},
            {value: 1.796, isCorrect: false},
            {value: 1.192, isCorrect: true},
            {value: 1.498, isCorrect: true},
            {value: 1.709, isCorrect: true},
            {value: 1.881, isCorrect: false},
            {value: 1.724, isCorrect: true},
            {value: 1.832, isCorrect: false},
            {value: 1.724, isCorrect: true},
            {value: 1.802, isCorrect: false},
            {value: 1.719, isCorrect: true},
            {value: 1.181, isCorrect: true},
            {value: 1.797, isCorrect: false},
            {value: 1.732, isCorrect: true},
            {value: 1.781, isCorrect: true},
            {value: 1.827, isCorrect: true},
            {value: 1.870, isCorrect: false},
            {value: 1.221, isCorrect: true}
        ]
    }
    return self;
}


- (void) drawRect: (CGRect) dirtyRect { //CPLog("PlotView>drawRect");
    if (firstTime !== "notFirstTime") { //ignore the very first call during launching
        firstTime = "notFirstTime";  return;
    }
    [MDB2plot p2init];
    if (gTestingPlottingAcuity1Contrast2 === 0) {
        testHistory = [TrialHistoryController trialHistoryRecord];
        testHistoryResultValue = gTestDetails[td_resultValue];
        isAcuity = gTestDetails[td_testName].startsWith("Acuity");
        isContrast = gTestDetails[td_testName].startsWith("Contrast");
    } else {
        isAcuity = gTestingPlottingAcuity1Contrast2 == 1;
        isContrast = gTestingPlottingAcuity1Contrast2 == 2;
    }
    const nTrials = testHistory.length;
    let yMin = 3, yMax = -1.05, yHorAxis = yMin; //note inverted axis
    if (isContrast) {
        yMin = 0.0, yMax = 2.5, yHorAxis = yMin; //note normal axis
    }
    const yTick = (yMax - yMin) / 50;
    const xMin = -1, xMax = nTrials + 1;
    const xTick = (xMax - xMin) / 80;
    [MDB2plot p2wndwX0: xMin-0.01 y0: yMin x1: xMax y1: yMax];

    //title
    [MDB2plot p2setFontSize: 24];
    [MDB2plot p2setTextAlignHorizontal: "center" vertical: "hanging"];
    const sHeader = "Presented " + (isAcuity ? "acuity" : "logCS") + " grades along the run";
    [MDB2plot p2showText: sHeader atX: (xMax - xMin - 2) / 2 y: yMax];
    if ([Settings doThreshCorrection] && isAcuity) {
        [MDB2plot p2setFontSize: 14];
        [MDB2plot p2showText: "[All with DIN/ISO threshold correction]" atX: (xMax - xMin - 2) / 2 y: yMax +0.21];
    }
    [MDB2plot p2setTextAlignDefault];

    //axes
        //abscissa
    [MDB2plot p2setFontSize: 18];
    [MDB2plot p2hlineX0: xMin y: yHorAxis x1: nTrials];
    [MDB2plot p2setTextAlignHorizontal: "end" vertical: "bottom"];
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
    const sUnit = isAcuity ? "↓LogMAR" : "↑logCS";
    [MDB2plot p2showText: sUnit atXpx: [MDB2plot p2tx: xMin+0.5] ypx: 40];
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
        let y = testHistory[trial].value;
        if ([Settings doThreshCorrection] && isAcuity) y -= Math.log10(gThresholdCorrection4Ascending);
        if (testHistory[trial].isCorrect) {
            [MDB2plot p2setFillColor: [CPColor colorWithRed: 0 green: 0.6 blue: 0 alpha: 1]];
            [MDB2plot p2fillCircleAtX: trial+0.5 y: y radiusInPx: 10];
        } else {
            [MDB2plot p2setStrokeColor: [CPColor redColor]];
            [MDB2plot p2strokeXAtX: trial+0.5 y: y sizeInPx: 25];
        }
    }

    //line for final value
    [MDB2plot p2setStrokeColor: [CPColor blueColor]];
    [MDB2plot p2setLineWidthInPx: 2];
    [MDB2plot p2hlineX0: xMin+1.5 y: testHistoryResultValue x1: xMax];
    [MDB2plot p2setFillColor: [CPColor blueColor]];
    [MDB2plot p2setTextAlignVertical: "top"];
    let s = [Misc stringFromNumber: testHistoryResultValue decimals: 2];
    [MDB2plot p2showText: s+"↑" atXpx: [MDB2plot p2tx: xMin+1.5] ypx: [MDB2plot p2ty: testHistoryResultValue]+8];
}
@end


@implementation PlotController: CPWindowController {
    @outlet CPPanel plotPanel;
    @outlet PlotView plotView1;
}


- (IBAction) buttonPlotOpen_action: (id) sender { //CPLog("PlotView>buttonPlotOpen_action");
    [plotPanel setMovable: NO];
    [Misc centerWindowOrPanel: plotPanel];
    [plotPanel makeKeyAndOrderFront: self];
}


- (IBAction) buttonPlotClose_action: (id) sender { //CPLog("PlotView>buttonPlotClose_action");
    [plotPanel close];
}


- (IBAction) buttonPlotToPDF_action: (id) sender { //CPLog("PlotView>buttonPlotToPDF_action");
    const canvas = [MDB2plot getCGC].DOMElement;
    const imgData = canvas.toDataURL("image/png", 1.0);

    // Default is 'pt' units and 'a4' size
    const doc = new window.jspdf.jsPDF({
        title: 'FrACT10 RESULT PLOT',
        author: 'bach@uni-freiburg.de',
        keywords: 'visual acuity',
        creator: "FrACT10_" + gVersionStringOfFract + "·" + gVersionDateOfFrACT,
        orientation: 'portrait', unit: 'pt', format: 'a4'
    });

    doc.setFontSize(10);  doc.setFont("Courier", "bold");
    doc.text("FrACT10 RESULT PLOT", 15, 10);

    let tableBody = [ //let's build a table
        ['Date', gTestDetails[td_dateOfRunStart]],
        ['Time', [Misc date2HH_MM: gTestDetails[td_dateTimeOfRunStart]]]
    ];
    if (gTestDetails[td_ID] !== gPatIDdefault) {
        tableBody.push(["ID", gTestDetails[td_ID]]);
    }
    if (gTestDetails[td_eyeCondition] !== gEyeIndex2string[0]) { //optional
        tableBody.push(["Eye", gTestDetails[td_eyeCondition]]);
    }
    tableBody.push(["Test", gTestDetails[td_testName]]);
    const styles = {
        fontSize: 10, font: "Courier", fontStyle: 'normal', halign: 'left',
        cellPadding: {top: 1, right: 1, bottom: 1, left: 1},
    };
    const columnStyles = {0: {cellWidth: 40}, 1: {cellWidth: 'auto'},}
    doc.autoTable({body: tableBody, theme: 'grid', styles: styles, columnStyles: columnStyles});

    // Scale image to fit (keeping aspect ratio)
    const pageWidth = doc.internal.pageSize.getWidth();
    const pageHeight = doc.internal.pageSize.getHeight();
    const canvasWidth = canvas.width, canvasHeight = canvas.height;
    const ratio = 0.8 * Math.min(pageWidth / canvasWidth, pageHeight / canvasHeight);
    const imgWidth = canvasWidth * ratio, imgHeight = canvasHeight * ratio;
    const x = (pageWidth - imgWidth) / 2, y = (pageHeight - imgHeight) / 2; //Center it
    doc.addImage(imgData, "PNG", x, y, imgWidth, imgHeight);

    const filename = "FrACT_"+ gTestDetails[td_dateOfRunStart] + "_" + [Misc date2HHdashMM: gTestDetails[td_dateTimeOfRunStart]] + "_AllTrialsPlot.pdf";
    doc.save(filename);
}


@end
