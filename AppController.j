/*
 This file is part of FrACT10, a vision test battery.
 © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 AppController.j

 Created by mb on 2017-07-12.
 */

@import <Foundation/Foundation.j>
@import <AppKit/CPView.j> //don't need to include the full `AppKit.j`
@import <AppKit/CPWindowController.j>
@import <AppKit/CPAlert.j>
@import <AppKit/CPWebView.j>

@import "Globals.j"
@import "Misc.j"
@import "FractView.j"
@import "FractController.j"
@import "FractControllerAcuityC.j"
@import "FractControllerAcuityL.j"
@import "FractControllerAcuityE.j"
@import "FractControllerAcuityTAO.j"
@import "FractControllerAcuityVernier.j"
@import "FractControllerContrastLett.j"
@import "FractControllerContrastC.j"
@import "FractControllerContrastE.j"
@import "FractControllerContrastG.j"
@import "FractControllerContrastDitherUnittest.j"
@import "FractControllerAcuityLineByLine.j"
@import "FractControllerBalmLight.j"
@import "FractControllerBalmLocation.j"
@import "FractControllerBalmMotion.j"
@import "RewardsController.j"
@import "TAOController.j"
@import "Sound.j"
@import "GammaView.j"
@import "MDBButton_Test.j"
@import "MDBTextField.j"
@import "MDBLabel.j"
@import "MDBAlert.j"
@import "MDBColorWell.j"
@import "Presets.j"
@import "ControlDispatcher.j"
@import "CardController.j"
@import "AboutAndHelpController.j"
@import "PlotController.j"
@import "CheckingContrastController.j"


/**
 AppController

 */

@implementation AppController : CPWindowController {
    CPWindow selfWindow;
    @outlet CPWindow fractControllerWindow;
    @outlet CPPanel settingsPanel, responseinfoPanelAcuityL, responseinfoPanelAcuity4C, responseinfoPanelAcuity8C, responseinfoPanelAcuityE, responseinfoPanelAcuityTAO, responseinfoPanelAcuityVernier, responseinfoPanelContrastLett, responseinfoPanelContrastC, responseinfoPanelContrastE, responseinfoPanelContrastG, responseinfoPanelAcuityLineByLine;
    @outlet MDBButton_Test buttonAcuityTAO;
    @outlet CPButton buttonExportClip, buttonExportPDF, buttonPlot;
    @outlet CPButton radioButtonAcuityBW, radioButtonAcuityColor;
    @outlet GammaView gammaView;
    @outlet CPPopUpButton settingsPanePresetsPopUpButton;  Presets presets;
    @outlet CPPopUpButton settingsPaneSoundsTrialStartPopUp;
    @outlet CPPopUpButton settingsPaneMiscSoundsTrialYesPopUp;
    @outlet CPPopUpButton settingsPaneMiscSoundsTrialNoPopUp;
    @outlet CPPopUpButton settingsPaneMiscSoundsRunEndPopUp;
    CPString versionDateString @accessors; //for the main Xib window top right
    CPString resultString @accessors;
    @outlet MDBLabel resultStringField;
    CPString currentTestResultUnit @accessors;
    CPString currentTestResultExportString @accessors;
    CPString currentTestResultsHistoryExportString @accessors;
    Sound sound;
    CPImageView rewardImageView;
    RewardsController rewardsController;
    TAOController taoController;
    FractController currentFractController;
    BOOL settingsNeededNewDefaults;
    BOOL runAborted @accessors;
    BOOL has4orientations @accessors;
    BOOL has2orientations @accessors;
    BOOL is2alternatives @accessors;
    BOOL is4alternatives @accessors;
    BOOL is8plusAlternatives @accessors;
    id allPanels;
    int settingsPaneTabViewSelectedIndex @accessors;
    CPColor colorOfBestPossibleAcuity @accessors;
    CPNumberFormatter numberFormatter;
    @outlet CPTextField contrastMaxLogCSWeberField;
    @outlet CPTextField gammaValueField;
    int decimalMarkCharIndexPrevious;
    @outlet MDBTextField decimalMarkCharField;
}


/**
 Accessing the foreground/background color for acuity optotypes as saved across restart in Settings.
 Within FrACT use globals gColorFore/gColorBack; need to synchronise [Gratings have their own].
 @return the current foreground color
 Colors cannot be saved as objects in userdefaults, probably because serialiser not implemented
 NSUnarchiveFromData, Error message [CPData encodeWithCoder:] unrecognized selector
 https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/DrawColor/Tasks/StoringNSColorInDefaults.html
 */
- (CPColor) acuityForeColor {
    gColorFore = [Settings acuityForeColor];
    return gColorFore;}
- (void) setAcuityForeColor: (CPColor) col {
    gColorFore = col;
    [Settings setAcuityForeColor: gColorFore];
}
- (CPColor) acuityBackColor {
    gColorBack = [Settings acuityBackColor];
    return gColorBack;
}
- (void) setAcuityBackColor: (CPColor) col {
    gColorBack = col;
    [Settings setAcuityBackColor: gColorBack];
}
- (void) setGratingForeColor: (CPColor) col {[Settings setGratingForeColor: col];}
- (CPColor) gratingForeColor {return [Settings gratingForeColor];}
- (void) setGratingBackColor: (CPColor) col {[Settings setGratingBackColor: col];}
- (CPColor) gratingBackColor {return [Settings gratingBackColor];}
- (CPColor) windowBackgroundColor {return [Settings windowBackgroundColor];}
- (void) setWindowBackgroundColor: (CPColor) col { //console.info("AppController>setAcuityBackColor");
    [Settings setWindowBackgroundColor: col];  [selfWindow setBackgroundColor: col];
}


/**
 Our main initialisation begins here
 */
- (id) init { //console.info("AppController>init");
    gAppController = self; //so others can reference via global variable
    [Misc CPLogSetup];
    settingsNeededNewDefaults = [Settings needNewDefaults];
    [Settings checkDefaults]; //important to do this very early, before nib loading, otherwise the updates don't populate the settings panel
    return self;
}


#pragma mark
/** runs after "init" above */
- (void) applicationDidFinishLaunching: (CPNotification) aNotification { //console.info("AppController>…Launching");
    currentFractController = null; //making sure, is used to check whether inRun
    [Misc randomizeRandomGenerator];
    selfWindow = [self window];
    [selfWindow setFullPlatformWindow: YES];
    [selfWindow setBackgroundColor: [self windowBackgroundColor]];
    [selfWindow setTitle: "FrACT10"];
    [self setVersionDateString: gTestDetails[td_vsFrACT]];
    [CPMenu setMenuBarVisible: NO];
    [self setupEventListeners];

    [Settings checkDefaults]; //what was the reason to put this here???

    allPanels = [responseinfoPanelAcuityL, responseinfoPanelAcuity4C, responseinfoPanelAcuity8C, responseinfoPanelAcuityE, responseinfoPanelAcuityTAO, responseinfoPanelAcuityVernier, responseinfoPanelContrastLett, responseinfoPanelContrastC, responseinfoPanelContrastE, responseinfoPanelContrastG, responseinfoPanelAcuityLineByLine, settingsPanel];
    for (const p of allPanels)  [p setMovable: NO];
    [self setSettingsPaneTabViewSelectedIndex: 0]; //select the "General" tab in Settings

    rewardImageView = [[CPImageView alloc] initWithFrame: CGRectMake(100, 0, 600, 600)];
    [[selfWindow contentView] addSubview: rewardImageView positioned: CPWindowBelow relativeTo: nil];

    [self setupControllers];

    [buttonExportClip setEnabled: NO];  [buttonExportPDF setEnabled: NO];
    [buttonPlot setEnabled: (gTestingPlottingAcuity1Contrast2 !== 0)];
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsDidChange:) name:CPUserDefaultsDidChangeNotification object: nil];

    [self radioButtonsAcuityBwOrColor_action: null];

    [Settings setAutoRunIndex: kAutoRunIndexNone]; //make sure it's not accidentally on
    [Settings setPatID: gPatIDdefault]; //clear ID string

    numberFormatter = [[CPNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: CPNumberFormatterDecimalStyle];
    [numberFormatter setMinimumFractionDigits: 1];
    [contrastMaxLogCSWeberField setFormatter: numberFormatter];
    [gammaValueField setFormatter: numberFormatter];

    [Settings setupSoundPopups: [settingsPaneSoundsTrialStartPopUp, settingsPaneMiscSoundsTrialYesPopUp, settingsPaneMiscSoundsTrialNoPopUp, settingsPaneMiscSoundsRunEndPopUp]];

    //set up control dispatcher (HTML messages to FrACT10 when embedded as iframe)
    [[CPNotificationCenter defaultCenter] addObserver: self selector: @selector(notificationRunFractControllerTest:) name: "notificationRunFractControllerTest" object: nil];
    [ControlDispatcher init];

    [Misc centerWindowOrPanel: [selfWindow contentView]]; //→center
    [selfWindow orderFront: self]; //ensures that it will receive clicks w/o activating
    [resultStringField setVerticalAlignment: CPTopVerticalTextAlignment];
    [self setResultString: "– Result displayed here –"];
    if ([Settings isAutoPreset]) {
        [presets applyPresetNamed: [Settings presetName]];
        [Settings setIsAutoPreset: YES];
    }
}


- (void) setupEventListeners { //called from `applicationDidFinishLaunching`
    window.addEventListener('error', function(e) {
        console.error("Error details:", e);
        alert("An error occured, I'm sorry. Error message:\r\r" + e.message + "\r\rIf it recurs, please notify bach@uni-freiburg.de, ideally relating the message, e.g. via a screeshot.\rI will look into it and endeavour to provide a fix ASAP.\r\rOn “Close”, the window will reload and you can retry.");
        window.location.reload(NO);
    });
    window.addEventListener("orientationchange", function(e) {
        if ([Settings respondsToMobileOrientation]) {
            //alert("Orientation change, now "+e.target.screen.orientation.angle+"°.\r\rOn “Close”, the window will reload to fit.");
            window.location.reload(NO);
        }
    });
    window.addEventListener("fullscreenchange", (event) => { //called _after_ the change
        //console.info("isFullScreen: ", [Misc isFullScreen]);
        if (![Misc isFullScreen]) { //so it was full before, possibly we're in a run
            if (currentFractController !== null) { //need to end run when leaving fullscreen
                [currentFractController runEnd]; //because the <esc> was consumed
            }
        }
        if (![Misc isInRun]) { //don't do ⇙this while "inRun"
            selfWindow = [self window]; //this prevents origin shift for fullScreen on/off
        }
    });
    /*if ([Settings autoFullScreen]) { //does not work because it needs user interaction
        [Misc fullScreenOn: YES];
    }*/
    window.addEventListener("resize", (event) => {
        if ([Misc isInRun]) return; //don't do ⇙this while "inRun"
        selfWindow = [self window]; //this prevents origin shift for fullScreen on/off
        [Misc centerWindowOrPanel: [selfWindow contentView]];

/*        //https://ua.hexalys.com
        console.info("scale", window.visualViewport.scale);
        console.info("window.devicePixelRatio", window.devicePixelRatio);
        console.info("window.outerWidth / window.innerWidth", window.outerWidth / window.innerWidth);*/

    });
}


- (void) setupControllers { //called from `applicationDidFinishLaunching`
    rewardsController = [[RewardsController alloc] initWithView: rewardImageView];
    taoController = [[TAOController alloc] initWithButton2Enable: buttonAcuityTAO];
    sound = [[Sound alloc] init];
    presets = [[Presets alloc] initWithPopup: settingsPanePresetsPopUpButton];
}


/**
 Observe changes in the settings panel, making sure dependencies are updated
 Caution: endless loops need to be avoided
 */
- (void) settingsDidChange: (CPNotification) aNotification { //console.info("settingsDidChange");
    [self setHas4orientations: ([Settings nAlternatives] === 4)];
    [self setHas2orientations: ([Settings nAlternatives] === 2)];
    if (is2alternatives !== ([Settings nAlternatives] === 2)) {
        [self setIs2alternatives: ([Settings nAlternatives] === 2)];
    } //this complicated way avoids endless loop
    if (is4alternatives !== ([Settings nAlternatives] === 4)) {
        [self setIs4alternatives: ([Settings nAlternatives] === 4)];
    }
    if (is8plusAlternatives !== ([Settings nAlternatives] >= 8)) {
        [self setIs8plusAlternatives: ([Settings nAlternatives] >= 8)];
    }
    if ([Settings minPossibleLogMAR] > 0) { //red: not good enough for normal vision
        [self setColorOfBestPossibleAcuity: [CPColor redColor]];
    } else {
        [self setColorOfBestPossibleAcuity: [CPColor colorWithRed: 0 green: 0.4 blue: 0 alpha: 1]];
    }
    [self radioButtonsAcuityBwOrColor_action: null];
    //↓ complicated to ensure the character is updated (and well visible) in the GUI
    const decimalMarkCharIndexCurrent = [Settings decimalMarkCharIndex]; //check for change
    if (decimalMarkCharIndexCurrent !== decimalMarkCharIndexPrevious) { //startup value is always null
        decimalMarkCharIndexPrevious = decimalMarkCharIndexCurrent; //save for next time
        [Settings setDecimalMarkChar: [Settings decimalMarkChar]]; //this updates in GUI
        [decimalMarkCharField setTextColor: [CPColor blueColor]]; //while we're here…
        [decimalMarkCharField setFont: [CPFont systemFontOfSize: 24]]; //need more visibility
        [decimalMarkCharField sizeToFit]; //can't change font size of CPTextField, so →MDBTextField,
        let r = [decimalMarkCharField bounds]; r.size.height = 30; r.origin.y = 12;
        [decimalMarkCharField setBounds: r];
    }
    let rct = CGRectMake(0, 560, 800, 84); //placeResultStringField
    if ([Settings showIdAndEyeOnMain])  rct = CGRectOffset(rct, 84 / 2, 0);
    [resultStringField setFrame: rct];

    gColorFore = [Settings acuityForeColor];
    gColorBack = [Settings acuityBackColor];
    if (![[self acuityForeColor] isEqual: gColorFore]) { //avoid endless loop
        [self setAcuityForeColor: gColorFore];
        [self setAcuityBackColor: gColorBack];
    }
    if (![[self gratingForeColor] isEqual: [Settings gratingForeColor]]) {
        [self setGratingForeColor: [Settings gratingForeColor]];
        [self setGratingBackColor: [Settings gratingBackColor]];
    }
    if (![[self windowBackgroundColor] isEqual: [Settings windowBackgroundColor]]) {
        [self setWindowBackgroundColor: [Settings windowBackgroundColor]];
    }
    [selfWindow setBackgroundColor: [self windowBackgroundColor]];
}


- (void) closeAllPanels {
    for (const p of allPanels)  [p close];
}
- (void) centerAllPanels {
    for (const p of allPanels)  [Misc centerWindowOrPanel: p];
}


/**
 One of the tests should run, but let's test some prerequisites first
 */
- (void) notificationRunFractControllerTest: (CPNotification) aNotification { //called from ControlDispatcher
    [self runFractControllerTest: [aNotification object]];
}
- (void) runFractControllerTest: (int) testNr { //console.info("AppController>runFractController");
    [ControlDispatcher sendChar: "\r"]; //commit possible change in patID
    let frontWindow = [[CPApp orderedWindows] objectAtIndex:0];
    if ([frontWindow title] !== "FrACT10") [frontWindow close]; //close overlaying window if any
    if (currentFractController !== null) return; //got here by accident, already inRun?

    [buttonExportClip setEnabled: NO];  [buttonExportPDF setEnabled: NO];  [buttonPlot setEnabled: NO];
    [sound initAfterUserinteraction];
    gCurrentTestID = testNr;
    if ([Settings isNotCalibrated]) {
        gLatestAlert = [CPAlert alertWithMessageText: "Calibration is mandatory for valid results!"
                                      defaultButton: "I just want to try…" alternateButton: "OK, go to  ‘⛭ Settings’" otherButton: "Cancel"
                          informativeTextWithFormat: "\rGoto ‘⛭ Settings’ and enter appropriate values for \r«Observer distance» and «Length of blue ruler».\r\rThis will also get rid of the present obnoxious warning dialog."];
        [gLatestAlert runModalWithDidEndBlock: function(alert, returnCode) {
            switch (returnCode) {
                case 1: //alternateButton: go to Settings
                    [self setSettingsPaneTabViewSelectedIndex: 0]; //ensure "General" tab
                    [self buttonSettings_action: nil];  break;
                case 0: //defaultButton
                    [self runFractController2];  break;
            }
            gLatestAlert = null;
        }];
    } else {
        [self runFractController2];
    }
}


/**
 The above prerequisites were met, so let's run the test specified in the global`gCurrentTestID`
 */
- (void) runFractController2 { //console.info("AppController>runFractController2");
    [self closeAllPanels];  [self centerAllPanels];
    const allInfoPanels = {[kTestAcuityLett]: responseinfoPanelAcuityL,
        [kTestAcuityLandolt]: responseinfoPanelAcuity8C,
        [kTestAcuityE]: responseinfoPanelAcuityE,
        [kTestAcuityTAO]: responseinfoPanelAcuityTAO,
        [kTestAcuityVernier]: responseinfoPanelAcuityVernier,
        [kTestContrastLett]: responseinfoPanelContrastLett,
        [kTestContrastLandolt]: responseinfoPanelContrastC,
        [kTestContrastE]: responseinfoPanelContrastE,
        [kTestContrastG]: responseinfoPanelContrastG,
        [kTestAcuityLineByLine]: responseinfoPanelAcuityLineByLine};
    if ([Settings showResponseInfoAtStart] && (gCurrentTestID in allInfoPanels)) {
        [allInfoPanels[gCurrentTestID] makeKeyAndOrderFront: self];
        if ((gCurrentTestID === kTestAcuityLandolt) && ([Settings nAlternatives] === 4)) {
            [responseinfoPanelAcuity4C makeKeyAndOrderFront: self];
        }
    } else {
        [self runFractController2_actionOK: nil];
    }
}


/**
 Info panels (above) were not needed, or OKed, so lets now REALLY run the test.
 */
- (IBAction) runFractController2_actionOK: (id) sender {
    [self closeAllPanels];
    if (currentFractController) {
        [currentFractController release];  currentFractController = null;
    }
    const allTestControllers = [nil, FractControllerAcuityL, FractControllerAcuityC, FractControllerAcuityE, FractControllerAcuityTAO, FractControllerAcuityVernier, FractControllerContrastLett, FractControllerContrastC, FractControllerContrastE, FractControllerContrastG, FractControllerAcuityLineByLine, FractControllerContrastDitherUnittest,                          FractControllerBalmLight, FractControllerBalmLocation, FractControllerBalmMotion]; //sequence like Hierachy kTest#s
    currentFractController = [[allTestControllers[gCurrentTestID] alloc] initWithWindow: fractControllerWindow];
    [currentFractController setSound: sound];
    currentTestResultExportString = "";
    [currentFractController runStart];
}
/**
 ok, so let's not run this test after all
 */
- (IBAction) runFractController2_actionCancel: (id) sender { //console.info("AppController>runFractController2_actionCancel");
    [self closeAllPanels];
}


- (void) runEnd { //console.info("AppController>runEnd");
    [resultStringField setEnabled: YES];
    [currentFractController release];  currentFractController = nil;
    if (!runAborted) {
        if ([Settings showRewardPicturesWhenDone]) {
            [rewardsController drawRandom];
        }
        [self exportCurrentTestResult];
    }
    [ControlDispatcher runDoneSuccessful: !runAborted];

    //allow 1 eventloop
    const UI_UPDATE_DELAY = 1; //1 millisecond is enough
    setTimeout(() => {[[selfWindow contentView] setNeedsDisplay: YES];}, UI_UPDATE_DELAY);
    //console.info(gTestDetails);
}


- (void) exportCurrentTestResult { //console.info("AppController>exportCurrentTestResult");
    try {//in localStorage we don't want to localise
        let temp = currentTestResultExportString.replace(/,/g, ".");
        localStorage.setItem(gFilename4ResultStorage, temp);
        temp = currentTestResultsHistoryExportString.replace(/,/g, ".");
        localStorage.setItem(gFilename4ResultsHistoryStorage, temp);
    } catch (e) {
        console.warn("localStorage not available:", e);
        // Fallback behavior not really availabe
    }
    let string4clipboard = currentTestResultExportString;
    switch ([Settings resultsToClipboardIndex]) {
        case kResultsToClipNone: break;
        case kResultsToClipFullHistory:
            string4clipboard += currentTestResultsHistoryExportString;
            //purposefully "fall throught" to next:
        case kResultsToClipFinalOnly:
            if ([Settings putResultsToClipboardSilent]) {
                [Misc copyString2Clipboard: string4clipboard];
            } else {
                [Misc copyString2ClipboardWithDialog: string4clipboard];
            }
            break;
        case kResultsToClipFullHistory2PDF: [self exportPDF]; break;
    }
    [buttonExportClip setEnabled: ([currentTestResultExportString length] > 1)];
    [buttonExportPDF setEnabled: ([currentTestResultExportString length] > 1)];
    if ([kTestAcuityLett, kTestAcuityLandolt, kTestAcuityE, kTestAcuityTAO, kTestContrastLett, kTestContrastLandolt, kTestContrastE, kTestContrastG].includes(gCurrentTestID)){
        [buttonPlot setEnabled: ([currentTestResultExportString length] > 1)];
    }
}


- (void) exportPDF { //CPLog("AppController>exportPDF");
    const doc = new window.jspdf.jsPDF(); //https://artskydj.github.io/jsPDF/docs/jsPDF.html
    doc.setProperties({
     title: 'FrACT10 RESULT RECORD',
     author: 'bach@uni-freiburg.de',
     keywords: 'visual acuity',
     creator: "FrACT10_" + gVersionStringOfFract + "·" + gVersionDateOfFrACT
    });

    doc.setFontSize(8);  doc.setFont("Courier", "bold");
    doc.text("FrACT10 RESULT RECORD" + crlf, 15, 10); //https://artskydj.github.io/jsPDF/docs/jsPDF.html#text

    // main output
    const items = currentTestResultExportString.trim().split('\t');
    let tableData = []; //https://github.com/simonbengtsson/jsPDF-AutoTable
    for (let i = 0; i < items.length; i += 2) { //every second item: new row
        tableData.push([items[i], items[i + 1]]);
    }
    const styles = {fontSize: 8, cellWidth: 30, font: "Courier", cellPadding: {top: 1, right: 1, bottom: 1, left: 1}};
    doc.autoTable({body: tableData, theme: 'grid', styles: styles});
    
    // trial-by-trial output
    tableData = currentTestResultsHistoryExportString.trim()
      .split('\n') //split rows by newline
      .map(row => row.split('\t')); //split columns by tab
    doc.autoTable({body: tableData, theme: 'grid', styles: styles});
    const filename = "FrACT_"+ gTestDetails[td_dateOfRunStart] + "_" + [Misc date2HHdashMM: gTestDetails[td_dateTimeOfRunStart]] + ".pdf";
    doc.save(filename); //https://github.com/eligrey/FileSaver.js
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //CPLog("AppController>drawStimulusInRect");
    [currentFractController drawStimulusInRect: dirtyRect forView: fractView];
}


/*- (void) controlTextDidChange: (CPNotification) notification {
 }*/
/**
 Called from some text fields in the Settings panel, to update dependencies
 */
- (void) controlTextDidEndEditing: (CPNotification) notification {
    [Settings calculateMinMaxPossibleAcuity];
    [Settings calculateAcuityForeBackColorsFromContrast];
}


#pragma mark
- (void) keyDown: (CPEvent) theEvent { //console.info("AppController>keyDown");
    const key = [[[theEvent charactersIgnoringModifiers] characterAtIndex: 0] uppercaseString];
    if (kShortcutKeys4TestsArray[key]) {
        [self runFractControllerTest: kShortcutKeys4TestsArray[key]];  return;
    }
    switch(key) { //many keys are dealt with via the "Key Equivalent" in IB
        case "W" : [Misc infoAllWindows]; break;
        case "Q": case "X": case "-": //Quit or eXit
            [self buttonDoExit_action: nil];  break;
        case "5":
            const sto5 = [Settings testOnFive];
            if (sto5 > 0) [self runFractControllerTest: sto5];
            break;
        case "R":
            [Settings setAutoRunIndex: [Settings autoRunIndex] === kAutoRunIndexNone ? kAutoRunIndexMid : kAutoRunIndexNone];
            break;
        case "U":
            [Misc allUnittests];
            break;
        default:
            [super keyDown: theEvent];  break;
    }
}
- (BOOL) alertShowHelp: (id) sender { //DOESN'T WORK
    console.info("alertShowHelp");
    return YES;
}


- (void) balmSwitch {
    gLatestAlert = [MDBAlert alertWithMessageText: "BaLM@FrACT₁₀" defaultButton: "Cancel" alternateButton: "❓Help" otherButton: "Motion (‘3’)" informativeTextWithFormat: "“Basic Assessment of Light, Location & Motion”\rfor ultra low vision.\r\r\r↓ Which BaLM test?"];
    [gLatestAlert addButtonWithTitle: "Location (‘2’)"]; //returnCode === 3
    [gLatestAlert addButtonWithTitle: "Light (‘1’)"]; //returnCode === 2
    [gLatestAlert setDelegate: self];
    //[alert setShowsHelp: YES]; //doesn't work
    [[gLatestAlert buttons][0] setKeyEquivalent: "1"]; //yes, 1/2 inverted…
    [[gLatestAlert buttons][1] setKeyEquivalent: "2"];
    [[gLatestAlert buttons][2] setKeyEquivalent: "3"];
    [[gLatestAlert buttons][3] setKeyEquivalent: "h"]; //help
    [[gLatestAlert buttons][4] setKeyEquivalent: "\x1b"]; //esc
    [gLatestAlert runModalWithDidEndBlock: function(alert, returnCode) {
        switch (returnCode) {
            case 4: //console.info(returnCode); //Light
                [self runFractControllerTest: kTestBalmLight];
                break;
            case 3: //console.info(returnCode); //Location
                [self runFractControllerTest: kTestBalmLocation];
                break;
            case 2: //console.info(returnCode); //Motion
                [self runFractControllerTest: kTestBalmMotion];
                break;
            case 1: //console.info(returnCode); //help
                const url = "https://michaelbach.de/sci/stim/balm/index.html";
                if ([Misc existsUrl: url])  window.open(url, "_blank");
                break;
            default: //console.info(returnCode); //0=cancel
        }
        gLatestAlert = null;
    }];
}

- (IBAction) buttonFullScreen_action: (id) sender { //console.info("AppController>buttonFullScreen");
    [Misc fullScreenOn: ![Misc isFullScreen]]; //toggle
}


/**
 All test buttons land here, discriminated by their tag values (→Globals for `TestIDType`)
 */
- (IBAction) buttonDoTest_action: (id) sender { //console.info("buttonDoTest_action ", [sender tag])
    if ([sender tag] === kTestBalmGeneral) {
        [self balmSwitch];  return;
    }
    [self runFractControllerTest: [sender tag]];
}


/**
 Deal with the Settings panel
 */
- (IBAction) buttonSettings_action: (id) sender { //console.info("AppController>buttonSettings");
    [sound initAfterUserinteraction];
    [Settings checkDefaults];  [settingsPanel makeKeyAndOrderFront: self];
    [Misc centerWindowOrPanel: settingsPanel];
    if (settingsNeededNewDefaults) {
        settingsNeededNewDefaults = NO;
        gLatestAlert = [CPAlert alertWithMessageText: "WARNING"
                                      defaultButton: "OK" alternateButton: nil otherButton: nil
                          informativeTextWithFormat: "\r\rAll settings were (re)set to their default values.\r\r"];
        [gLatestAlert runModalWithDidEndBlock: function(alert, returnCode) {
            gLatestAlert = null;
        }];
    }
}

- (IBAction) buttonSettingsClose_action: (id) sender {
    [Settings checkDefaults];  [settingsPanel close];
}

- (IBAction) buttonSettingsTestSound_action: (id) sender { //console.info("buttonSettingsTestSound_action", [sender tag]);
    [sound updateSoundFiles];
    [sound playDelayedNumber: [sender tag]]; //delay because new buffer to be loaded; 0.02 would be enough.
}

- (IBAction) buttonSettingsContrastAcuityMaxMin_action: (id) sender {
    switch ([sender tag]) {
        case 1: [Settings setContrastAcuityWeber: 100];  break;
        case 2: [Settings setContrastAcuityWeber: -10000];  break;
    }
}

- (IBAction) popupPreset_action: (id) sender { //console.info("popupPreset_action: ", sender)
    [presets apply: sender];
}

- (IBAction) buttonSettingsExportImport_action: (id) sender {
    switch ([sender tag]) {
        case 1: [Settings exportAllSettings];  break;
        case 2: [Settings importAllSettings];  break;
    }
}


#pragma mark
/**
 And more buttons…
 */
- (IBAction) buttonExportClip_action: (id) sender { //CPLog("AppController>buttonExportClip_action");
    [Misc copyString2Clipboard: currentTestResultExportString];
    [buttonExportClip setEnabled: NO];
}
- (IBAction) buttonExportPDF_action: (id) sender { //CPLog("AppController>buttonExportPDF_action");
    [self exportPDF];
}


- (IBAction) buttonDoExit_action: (id) sender { //console.info("AppController>buttonExit_action");
    [Misc fullScreenOn: NO];
    [Settings setPatID: gPatIDdefault]; //clear ID string
    [selfWindow close];  [CPApp terminate: nil];  window.close();
}


- (IBAction) radioButtonsAcuityBwOrColor_action: (id) sender {
    if (sender !== null)
        [Settings setIsAcuityColor: [sender tag] === 1];
    else { //this is to preset the radio buttons
        [radioButtonAcuityBW setState: ([Settings isAcuityColor] ? CPOffState : CPOnState)];
        [radioButtonAcuityColor setState: ([Settings isAcuityColor] ? CPOnState : CPOffState)];
    }
}


- (IBAction) buttonGamma_action: (id) sender {
    [Settings setGammaValue: [Settings gammaValue] + ([sender tag] === 1 ? 0.1 : -0.1)];
    [gammaView setNeedsDisplay: YES];
}


@end
