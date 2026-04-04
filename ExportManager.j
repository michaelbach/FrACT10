/*
This file is part of FrACT10, a vision test battery.
© 2026 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

ExportManager.j

Centralizes export logic for result strings, trial history, and formatting.
Coded by Gemini, many corrections by MB
*/

@import <Foundation/CPObject.j>
@import "Globals.j"
@import "Settings.j"
@import "Misc.j"


@implementation ExportManager: CPObject {
    CPString resultString, historyString;
    CPButton buttonExportClip, buttonExportPDF, buttonPlot;
}


- (id) initWithButtonClip: (CPButton) aButtonClip buttonPDF: (CPButton) aButtonPDF buttonPlot: (CPButton) aButtonPlot { //console.info("ExportManager>initWithButtonClip");
    self = [super init];
    if (self) {
        buttonExportClip = aButtonClip;
        buttonExportPDF = aButtonPDF;
        buttonPlot = aButtonPlot;
        resultString = "";  historyString = "";
    }
    return self;
}


/**
 Update the data to be exported and update UI buttons accordingly.
 */
- (void) updateResult: (CPString) aResult history: (CPString) aHistory forTestID: (int) testID {
    resultString = aResult;  historyString = aHistory;

    const haveData = [resultString length] > 1;
    [buttonExportClip setEnabled: haveData];
    [buttonExportPDF setEnabled: haveData];

    //Plotting is currently only available for certain test types
    const canPlot = [kTestAcuityLetters, kTestAcuityLandolt, kTestAcuityE, kTestAcuityTAO,
                    kTestContrastLetters, kTestContrastLandolt, kTestContrastE, kTestContrastG].includes(testID);
    [buttonPlot setEnabled: (haveData && canPlot)];

    [self syncToLocalStorage];
}


/**
 Synchronize current results to local storage for persistence across reloads.
 Note: We convert decimal commas to dots for machine-readability in local storage.
 */
- (void) syncToLocalStorage { //console.info("ExportManager>syncToLocalStorage");
    const resultDot = resultString.replace(/,/g, ".");
    const historyDot = historyString.replace(/,/g, ".");
    try {
        localStorage.setItem(gFilename4ResultStorage, resultDot);
        localStorage.setItem(gFilename4ResultsHistoryStorage, historyDot);
    } catch (e) {
        console.warn("ExportManager>syncToLocalStorage: localStorage not available:", e);
    }
}


/**
 Private helper to get the correct export string.
 */
- (CPString) _getExportString {
    if ([Settings resultsToClipboardIndex] === kResultsToClipFullHistory) {
        return resultString + historyString;
    } else {
        return resultString;
    }
}


/**
 Handle the export logic based on user settings (clipboard, PDF, etc.)
 */
- (void) exportToClipboardAuto { //console.info("ExportManager>exportToClipboardAuto");
    switch ([Settings resultsToClipboardIndex]) {
        case kResultsToClipNone: 
            break;
        case kResultsToClipFullHistory:
        case kResultsToClipFinalOnly:
            if ([Settings putResultsToClipboardSilent]) {
                [Misc copyString2Clipboard: [self _getExportString]];
            } else {
                [Misc copyString2ClipboardWithDialog: [self _getExportString]];
            }
            break;
        case kResultsToClipFullHistory2PDF: 
            [self exportToPDF]; 
            break;
    }
}


/**
 Copy current result (and optionally history) to clipboard.
 */
- (void) exportToClipboard { //console.info("ExportManager>exportToClipboard");
    if ([Settings putResultsToClipboardSilent]) {
        [Misc copyString2Clipboard: [self _getExportString]];
    } else {
        [self copyToClipboardWithDialog: [self _getExportString]];
    }
}


/**
 Trigger PDF export.
 */
- (void) exportToPDF { //console.info("ExportManager>exportToPDF");
    [Misc export2PDF: resultString withHistory: historyString];
}


@end
