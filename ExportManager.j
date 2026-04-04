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
}


- (id) init { //console.info("ExportManager>init");
    self = [super init];
    if (self) {
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
    [gAppController.buttonExportClip setEnabled: haveData];
    [gAppController.buttonExportPDF setEnabled: haveData];

    //Plotting is currently only available for certain test types
    const canPlot = [kTestAcuityLetters, kTestAcuityLandolt, kTestAcuityE, kTestAcuityTAO,
                    kTestContrastLetters, kTestContrastLandolt, kTestContrastE, kTestContrastG].includes(testID);
    [gAppController.buttonPlot setEnabled: (haveData && canPlot)];

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
                [self copyToClipboardWithDialog: [self _getExportString]];
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
- (void) exportToClipboardManually { //console.info("ExportManager>exportToClipboardManually");
    [Misc copyString2Clipboard: [self _getExportString]];
}


/**
 Trigger PDF export.
 */
- (void) exportToPDF { //console.info("ExportManager>exportToPDF");
    [Misc export2PDF: resultString withHistory: historyString];
}


/**
 Perform logic unit tests for ExportManager.
 @return YES if all tests pass
 */
+ (BOOL) unittest {
    let success = YES, report = "\r\nExportManager▸unittest:" + crlf;

    //Setup: Simulate a test result
    const em = [[ExportManager alloc] init];
    const testResult = "value\t0.5";
    const testHistory = "trial\t1\t...\r\n";
    
    //Test 1: Helper string composition
    [Settings setResultsToClipboardIndex: kResultsToClipFinalOnly];
    [em updateResult: testResult history: testHistory forTestID: kTestAcuityLetters];
    if ([em _getExportString] !== testResult) {
        report += "  ERROR: Export string mismatch (FinalOnly)!" + crlf; success = NO;
    }

    [Settings setResultsToClipboardIndex: kResultsToClipFullHistory];
    if ([em _getExportString] !== testResult + testHistory) {
        report += "  ERROR: Export string mismatch (FullHistory)!" + crlf; success = NO;
    }

    //Test 2: LocalStorage formatting
    [em updateResult: "0,5" history: "1,2" forTestID: kTestAcuityLetters];
    [em syncToLocalStorage];
    if (localStorage.getItem(gFilename4ResultStorage) !== "0.5") {
         report += "  ERROR: LocalStorage decimal conversion failed!" + crlf; success = NO;
    }

    if (success) {
        report += "  ExportManager logic tests passed." + crlf;
    }
    console.info(report);
    return success;
}


@end
