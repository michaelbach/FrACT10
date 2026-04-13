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
- (void) exportToClipboardManually { //console.info("ExportManager>exportToClipboardManually");
    [Misc copyString2Clipboard: [self _getExportString]];
}


/**
 Trigger PDF export.
 */
- (void) exportToPDF { //console.info("ExportManager>exportToPDF");
    [Misc export2PDF: resultString withHistory: historyString];
}


////////////////////////////////////////////////
/**
 All Settings export/import
 */
- (void) exportAllSettings { //CPLog("Settings>exportAllSettings")
    //Prepare JSON data
    const EXCLUDED_NAMES = new Set([ //some not necessary
        "presetName", //exclude because it's not reliable info
        "minPossibleDecimalAcuity", //this and ↓ are always calculated, omit
        "minPossibleLogMAR", "minPossibleLogMARLocalisedString",
        "maxPossibleLogMAR", "maxPossibleLogMARLocalisedString",
        "minPossibleDecimalAcuityLocalisedString",
        "maxPossibleDecimalAcuityLocalisedString",
        "distanceInInchLocalisedString"
    ]);
    const settingsToExport = Array.from(gSettingsNamesAndTypesMap)
        .filter(item => !EXCLUDED_NAMES.has(item[0]))
        .map(item => {
            const name = item[0], meta = item[1];
            const value = [[CPUserDefaults standardUserDefaults] objectForKey: name];
            return [name, meta.type, value];
        });
    let jsonString = JSON.stringify(settingsToExport); //all in one long string, I not like
    jsonString = JSON.parse(jsonString); //parse string into JavaScript array
    jsonString = jsonString.map(item => JSON.stringify(item)); //stringify each triplet individually
    jsonString = '[\n' + jsonString.join(',\n') + '\n]' //join triplets with comma and newline, and wrap them. That's what I find more readable than the ", 2" option offered by stringify.
    const jsonBlob = new Blob([jsonString], {type: "application/json;charset=utf-8"});
    const suggestedFilename = "FrACT-settings-01";

    (async () => { //so we can use `await`
        if (window.showSaveFilePicker) { //Use modern API if available
            try {
                const handle = await window.showSaveFilePicker({
                    suggestedName: suggestedFilename,
                    types: [{description: 'JSON Files',
                        accept: {'application/json': ['.json']}}],
                });
                const writable = await handle.createWritable();
                await writable.write(jsonBlob);
                await writable.close(); //console.info('File saved successfully!');
            } catch (err) {
                if (err.name !== 'AbortError') {
                    console.error(err.name, err.message);
                } else {
                    console.info('Save operation cancelled by user.');
                }
            }
            return;
        }
        //Fallback for older browsers (FileSaver.js)
        let s = "Please enter a descriptive filename." + crlf + crlf;
        s += "I will remove illegal characters and add the extension ‘.json’." + crlf + crlf;
        s += "Your browser will ask: “Do you want to allow downloads…”." + crlf;
        s += "Afterwards, you can move that file from your downloads folder to a better place for future Importing."
        let filename = prompt(s, suggestedFilename);
        if (!filename) { //User cancelled the prompt
            console.info('Save operation cancelled by user.');
            return;
        }
        // Sanitize filename
        filename = filename.replace(/[\/\?<>\\:\*\|\""]/g, '_') //Replace illegal characters
            .trim().replace(/^\.+|\.+$/g, '')   //Trim whitespace and dots
            .slice(0, 50);                      //Limit length
        saveAs(jsonBlob, filename + ".json"); //finally save it in the downloads folder
    })();
}


- (void) importAllSettings { //CPLog("Settings>importAllSettings")
    [Settings setDefaults]; //make sure we start with clean slate (in case there are new settings)
    const dummyInput = document.createElement('input');
    dummyInput.type = 'file';  dummyInput.accept = '.json';
    dummyInput.style.display = 'none';
    document.body.appendChild(dummyInput);
    dummyInput.addEventListener('change', (event) => {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = (e) => {
                const fileContent = e.target.result;
                try {
                    const parsedContent = JSON.parse(fileContent);
                    let importOccurred = NO;
                    console.info("*** ExportManager▸︎importAllSettings begin")
                    for (const [name, , value] of parsedContent) { //we don't need `type`
                        if (name === "dateOfSettingsVersion") { //this must not be changed!
                            console.info(`Skipping '${name}'`)
                            continue;
                        }
                        if (value === null) { //so "false" is also passing through
                            console.info(`Skipping '${name}' because of null value`)
                            continue;
                        }
                        importOccurred = YES;
                        const previousVal = [[CPUserDefaults standardUserDefaults] objectForKey: name];
                        if (previousVal !== value) {
                            console.info(`Update '${name}': '${previousVal}' → '${value}'`);
                            [[CPUserDefaults standardUserDefaults] setObject: value forKey: name];
                        }
                    }
                    if (importOccurred) [Settings setPresetName: file.name];
                } catch (jsonError) { //handle potential JSON parsing errors
                    console.error("Error parsing JSON:", jsonError);
                    alert("The selected file is not valid JSON.");
                }
            console.info("*** ExportManager▸︎importAllSettings done.")
            document.body.removeChild(dummyInput); //clean up
                [Settings allNotCheckButSet: NO]; //vet imported settings
            };
            reader.readAsText(file);
        } else {
            document.body.removeChild(dummyInput); //clean up
        }
    });
    dummyInput.click();
}
////////////////////////////////////////////////


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
