/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 AppController.j

 Created by mb on 2017-07-12.
 */

@import "HierarchyController.j"
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
@import "FractControllerContrastDitherTest.j"
@import "FractControllerAcuityLineByLine.j"
@import "RewardsController.j"
@import "TAOController.j"
@import "Sound.j"
@import "GammaView.j"
@import "MDBButton.j"
@import "MDBTextField.j"
@import "PopulateAboutPanel.j"
@import "Presets.j"
@import "ControlDispatcher.j"


/**
 AppController

 The main controller. It inherits from HierarchyController
 to make communication with some classes which do not inherit from AppController easier.
 */

@implementation AppController : HierarchyController {
    @outlet CPWindow fractControllerWindow;
    @outlet CPPanel settingsPanel, aboutPanel, helpPanel, responseinfoPanelAcuityL, responseinfoPanelAcuity4C, responseinfoPanelAcuity8C, responseinfoPanelAcuityE, responseinfoPanelAcuityTAO, responseinfoPanelAcuityVernier, responseinfoPanelContrastLett, responseinfoPanelContrastC, responseinfoPanelContrastE, responseinfoPanelContrastG, responseinfoPanelAcuityLineByLine, resultDetailsPanel, creditcardPanel;
    @outlet MDBButton buttonAcuityLett, buttonAcuityC, buttonAcuityE, buttonAcuityTAO, buttonAcuityVernier, buttCntLett, buttCntC, buttCntE, buttCntG, buttonAcuityLineByLine;
    @outlet CPButton buttonExport;
    @outlet CPButton radioButtonAcuityBW, radioButtonAcuityColor;
    @outlet GammaView gammaView;
    @outlet CPWebView aboutWebView1, aboutWebView2, helpWebView1, helpWebView2, helpWebView3, helpWebView4;
    @outlet CPImageView creditcardImageView;
    @outlet CPPopUpButton settingsPanePresetsPopUpButton;  Presets presets;
    @outlet CPPopUpButton settingsPaneMiscSoundsTrialYesPopUp;
    @outlet CPPopUpButton settingsPaneMiscSoundsTrialNoPopUp;
    @outlet CPPopUpButton settingsPaneMiscSoundsRunEndPopUp;
    Sound sound;
    CPImageView rewardImageView;
    RewardsController rewardsController;
    TAOController taoController;
    FractController currentFractController;
    BOOL settingsNeededNewDefaults;
    BOOL runAborted @accessors;
    BOOL is4orientations @accessors;
    id allPanels, allTestControllers;
    CPColor checkContrastWeberFieldColor1 @accessors;
    CPColor checkContrastWeberFieldColor2 @accessors;
    float checkContrastActualWeberPercent @accessors;
    float checkContrastActualMichelsonPercent @accessors;
    int settingsPaneTabViewSelectedIndex @accessors;
    float calBarLengthInMMbefore;
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
    settingsNeededNewDefaults = [Settings needNewDefaults];
    [Settings checkDefaults]; //important to do this very early, before nib loading, otherwise the updates don't populate the settings panel
    return self;
}


#pragma mark
/** runs after "init" above */
- (void) applicationDidFinishLaunching: (CPNotification) aNotification { //console.info("AppController>…Launching");
    'use strict';
    selfWindow = [self window];
    [selfWindow setFullPlatformWindow: YES];  [selfWindow setBackgroundColor: [self windowBackgroundColor]];

    [CPMenu setMenuBarVisible: NO];
    window.addEventListener('error', function(e) {
        alert("An error occured, I'm sorry. Error message:\r\r" + e.message + "\r\rIf it recurs, please notify bach@uni-freiburg.de, ideally relating the message, e.g. via a screeshot.\rI will look into it and endeavour to provide a fix ASAP.\r\rOn “Close”, the window will reload and you can retry.");
        window.location.reload(false);
    });
    window.addEventListener("orientationchange", function(e) {
        if ([Settings mobileOrientation]) {
            //alert("Orientation change, now "+e.target.screen.orientation.angle+"°.\r\rOn “Close”, the window will reload to fit.");
            window.location.reload(false);
        }
    });

    const allButtons = [buttonAcuityLett, buttonAcuityC, buttonAcuityE, buttonAcuityTAO, buttonAcuityVernier, buttCntLett, buttCntC, buttCntE, buttCntG, buttonAcuityLineByLine];
    for (const b of allButtons)  [Misc makeFrameSquareFromWidth: b];

    allTestControllers = [nil, FractControllerAcuityL, FractControllerAcuityC, FractControllerAcuityE, FractControllerAcuityTAO, FractControllerAcuityVernier, FractControllerContrastLett, FractControllerContrastC, FractControllerContrastE, FractControllerContrastG, FractControllerAcuityLineByLine, FractControllerContrastDitherTest]; // sequence like Hierachy kTest#s

    allPanels = [responseinfoPanelAcuityL, responseinfoPanelAcuity4C, responseinfoPanelAcuity8C, responseinfoPanelAcuityE, responseinfoPanelAcuityTAO, responseinfoPanelAcuityVernier, responseinfoPanelContrastLett, responseinfoPanelContrastC, responseinfoPanelContrastE, responseinfoPanelContrastG, responseinfoPanelAcuityLineByLine, settingsPanel, helpPanel, aboutPanel, resultDetailsPanel, creditcardPanel];
    for (const p of allPanels) {
        [p setFrameOrigin: CGPointMake(0, 0)];  [p setMovable: NO];
    }
    [self setSettingsPaneTabViewSelectedIndex: 0]; // select the "General" tab in Settings

    [selfWindow setTitle: "FrACT10"];
    [self setVersionDateString: gVersionStringOfFract + "·" + gVersionDateOfFrACT];

    [Settings checkDefaults]; // what was the reason to put this here???

    rewardImageView = [[CPImageView alloc] initWithFrame: CGRectMake(100, 0, 600, 600)];
    [[selfWindow contentView] addSubview: rewardImageView];
    rewardsController = [[RewardsController alloc] initWithView: rewardImageView];
    taoController = [[TAOController alloc] initWithButton2Enable: buttonAcuityTAO];
    sound = [[Sound alloc] init];
    presets = [[Presets alloc] initWithPopup: settingsPanePresetsPopUpButton];

    for (let i = 0; i < (Math.round([[CPDate date] timeIntervalSince1970]) % 33); i++)
        Math.random(); // randomising the pseudorandom sequence

    [[CPNotificationCenter defaultCenter] addObserver: self selector: @selector(buttonExportEnableYESorNO:) name: "buttonExportEnableYESorNO" object: nil];
    [self postNotificationName: "buttonExportEnableYESorNO" object: 0];
    [[CPNotificationCenter defaultCenter] addObserver: self selector: @selector(copyColorsFromSettings:) name: "copyColorsFromSettings" object: nil];
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsDidChange:) name:CPUserDefaultsDidChangeNotification object: nil];

    [self radioButtonsAcuityBwOrColor_action: null];
    [self buttonCheckContrast_action: null];

    [Settings setAutoRunIndex: kAutoRunIndexNone]; // make sure it's not accidentally on

    numberFormatter = [[CPNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: CPNumberFormatterDecimalStyle];
    [numberFormatter setMinimumFractionDigits: 1];
    [contrastMaxLogCSWeberField setFormatter: numberFormatter];
    [gammaValueField setFormatter: numberFormatter];

    [Settings setupSoundPopups: [settingsPaneMiscSoundsTrialYesPopUp, settingsPaneMiscSoundsTrialNoPopUp, settingsPaneMiscSoundsRunEndPopUp]];

    // set up control dispatcher (HTML messages to FrACT10 when embedded as iframe)
    [[CPNotificationCenter defaultCenter] addObserver: self selector: @selector(notificationRunFractControllerTest:) name: "notificationRunFractControllerTest" object: nil];
    [ControlDispatcher initWithAppController: self];

    [selfWindow orderFront: self]; // ensures that it will receive clicks w/o activating
}


/**
 Observe changes in the settings panel, making sure dependencies are updated
 */
- (void) settingsDidChange: (CPNotification) aNotification { //console.info("settingsDidChange");
    [self setIs4orientations: ([Settings nAlternatives] == 4)];
    [selfWindow setBackgroundColor: [self windowBackgroundColor]];
    if ([Settings minPossibleLogMAR] > 0) { // red: not good enough for normal vision
        [self setColorOfBestPossibleAcuity: [CPColor redColor]];
    } else {
        [self setColorOfBestPossibleAcuity: [CPColor colorWithRed: 0 green: 0.4 blue: 0 alpha: 1]];
    }
    [self radioButtonsAcuityBwOrColor_action: null];
    // ↓ complicated to ensure the character is updated (and well visible) in the GUI
    const decimalMarkCharIndexCurrent = [Settings decimalMarkCharIndex];// check for change
    if (decimalMarkCharIndexCurrent != decimalMarkCharIndexPrevious) {// startup value is always null
        decimalMarkCharIndexPrevious = decimalMarkCharIndexCurrent;//save for next time
        [Settings setDecimalMarkChar: [Settings decimalMarkChar]];// this updates in GUI
        [decimalMarkCharField setTextColor: [CPColor blueColor]];// while we're here…
        [decimalMarkCharField setFont: [CPFont systemFontOfSize: 24]];//need more visibility
        [decimalMarkCharField sizeToFit];// can't change font size of CPTextField, so →MDBTextField,
        let r = [decimalMarkCharField bounds]; r.size.height = 30; r.origin.y = 12;
        [decimalMarkCharField setBounds: r];
    }
}


- (void) buttonExportEnableYESorNO: (CPNotification) aNotification { //console.info("buttonExportEnableYESorNO");
    [buttonExport setEnabled: !([aNotification object] == 0)];
}


/**
 Synchronising userdefaults & Appcontroller
 This mirroring is necessary, because the Settingspanel cannot read the stored colors, because the Archiver does not work
 */
- (void) copyColorsFromSettings: (CPNotification) aNotification { //console.info("mirrorForeBackColors");
    gColorFore = [Settings acuityForeColor];  [self setAcuityForeColor: gColorFore];
    gColorBack = [Settings acuityBackColor];  [self setAcuityBackColor: gColorBack];
    [self setGratingForeColor: [Settings gratingForeColor]];  [self setGratingBackColor: [Settings gratingBackColor]];
    [self setWindowBackgroundColor: [Settings windowBackgroundColor]];
}


- (void) closeAllPanels {
    for (const p of allPanels)  [p close];
}


/**
 We will need this in FractControllerAcuityTAO, it will be accessed via `parent`.
 */
- (id) gTaoController {
    return taoController;
}


/**
 One of the tests should run, but let's test some prerequisites first
 */
- (void) notificationRunFractControllerTest: (CPNotification) aNotification { // called from ControlDispatcher
    [self runFractControllerTest: [aNotification object]];
}
- (void) runFractControllerTest: (int) testNr { //console.info("AppController>runFractController");
    [sound initAfterUserinteraction];
    currentTestID = testNr;
    if ([Settings isNotCalibrated]) {
        const alert = [CPAlert alertWithMessageText: "Calibration is mandatory for valid results!"
                                      defaultButton: "I just want to try…" alternateButton: "OK, go to Settings" otherButton: "Cancel"
                          informativeTextWithFormat: "\rGoto 'Settings' and enter appropriate values for \r«Length of blue ruler» and «Observer distance»;\ror use the credit card sizing method.\r\rThis will also avoid the present obnoxious warning dialog."];
        [alert runModalWithDidEndBlock: function(alert, returnCode) {
            switch (returnCode) {
                case 1: // alternateButton
                    [self setSettingsPaneTabViewSelectedIndex: 0]; // ensure "General" tab
                    [self buttonSettings_action: nil];  break;
                case 0: // defaultButton
                    [self runFractController2];  break;
            }
        }];
    } else {
        [self runFractController2];
    }
}


/**
 The above prerequisites were met, so let's run the test specified in the class-global`currentTestID`
 */
- (void) runFractController2 { //   console.info("AppController>runFractController2  ");
    [self closeAllPanels];
    if ([Settings responseInfoAtStart]) {
        switch (currentTestID) {
            case kTestAcuityLett: [responseinfoPanelAcuityL makeKeyAndOrderFront: self]; break;
            case kTestAcuityC:
                switch ([Settings nAlternatives]) {
                    case 4: [responseinfoPanelAcuity4C makeKeyAndOrderFront: self];  break;
                    case 8: [responseinfoPanelAcuity8C makeKeyAndOrderFront: self];  break;
                }  break;
            case kTestAcuityE:
                [responseinfoPanelAcuityE makeKeyAndOrderFront: self];  break;
            case kTestAcuityTAO:
                [responseinfoPanelAcuityTAO makeKeyAndOrderFront: self];  break;
            case kTestAcuityVernier:
                [responseinfoPanelAcuityVernier makeKeyAndOrderFront: self];  break;
            case kTestContrastLett:
                [responseinfoPanelContrastLett makeKeyAndOrderFront: self];  break;
            case kTestContrastC:
                [responseinfoPanelContrastC makeKeyAndOrderFront: self];  break;
            case kTestContrastE:
                [responseinfoPanelContrastE makeKeyAndOrderFront: self];  break;
            case kTestContrastG:
                [responseinfoPanelContrastG makeKeyAndOrderFront: self];  break;
            case kTestAcuityLineByLine:
                [responseinfoPanelAcuityLineByLine makeKeyAndOrderFront: self];  break;
            case kTestContrastDitherTest:  break;
        }
    } else {
        [self runFractController2_actionOK: nil];
    }
}


/**
 Info panels (above) were not needed, or OKed, so lets now REALLY run the test.
 */
- (IBAction) runFractController2_actionOK: (id) sender { //console.info("AppController>runFractController2_actionOK");
    [self closeAllPanels];  [currentFractController release];
    currentFractController = [[allTestControllers[currentTestID] alloc] initWithWindow: fractControllerWindow parent: self];
    [currentFractController setSound: sound];
    [currentFractController setCurrentTestID: currentTestID]; // while it has inherited currentTestID, it hasn't inherited its value
    [currentFractController runStart];
    if ([Settings autoFullScreen]) {
        [Misc fullScreenOn: YES];
    }
}
/**
 ok, so let's not run this test after all
 */
- (IBAction) runFractController2_actionCancel: (id) sender { //console.info("AppController>runFractController2_actionCancel");
    [self closeAllPanels];
}


- (void) runEnd { //console.info("AppController>runEnd");
    [currentFractController release];  currentFractController = nil;
    if ([Settings autoFullScreen]) {
        [Misc fullScreenOn: NO];
    }
    if (!runAborted) {
        if ([Settings rewardPicturesWhenDone]) {
            [rewardsController drawRandom];
        }
        [self exportCurrentTestResult];
    }
    [ControlDispatcher runDoneSuccessful: !runAborted];
}


- (void) exportCurrentTestResult { //console.info("AppController>exportCurrentTestResult");
    let temp = currentTestResultExportString.replace(/,/g, "."); // in localStorage we don't want to localise
    localStorage.setItem(gFilename4ResultStorage, temp);
    temp = currentTestResultsHistoryExportString.replace(/,/g, ".");
    localStorage.setItem(gFilename4ResultsHistoryStorage, temp);

    if ([Settings results2clipboard] > kResults2ClipNone) {
        if ([Settings results2clipboard] == kResults2ClipFullHistory) {
            currentTestResultExportString += currentTestResultsHistoryExportString;
        }
        if ([Settings results2clipboardSilent]) {
            [Misc copyString2Clipboard: currentTestResultExportString];
        } else {
            [Misc copyString2ClipboardWithDialog: currentTestResultExportString];
        }
    }
    [self postNotificationName: "buttonExportEnableYESorNO" object: ([currentTestResultExportString length] > 1)];
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("AppController>drawStimulusInRect");
    [currentFractController drawStimulusInRect: dirtyRect forView: fractView];
}


/*- (void) controlTextDidChange: (CPNotification) notification { //console.info(@"controlTextDidChange: stringValue == %@", [[notification object] stringValue]);[Settings calculateMinMaxPossibleDecimalAcuity];
 }*/
/**
 Called from some text fields in the Settings panel, to update dependencies
 */
- (void) controlTextDidEndEditing: (CPNotification) notification { //console.info(@"controlTextDidChange: stringValue == %@", [[notification object] stringValue]);
    [Settings calculateMinMaxPossibleDecimalAcuity];
    [Settings calculateAcuityForeBackColorsFromContrast];
}


#pragma mark
- (void) keyDown: (CPEvent) theEvent { //console.info("AppController>keyDown");
    const key = [[[theEvent charactersIgnoringModifiers] characterAtIndex: 0] uppercaseString];
    if (gShortcutKeys4Tests[key]) {
        [self runFractControllerTest: gShortcutKeys4Tests[key]];  return;
    }
    switch(key) {
        case "Q": case "X": case "-": // Quit or eXit
            [self buttonDoExit_action: nil];  break;
        case "S": // Settings
            // this complicated version avoids propagation of the "s"
            [[CPRunLoop currentRunLoop] performSelector: @selector(buttonSettings_action:) target: self argument: nil order: 10000 modes: [CPDefaultRunLoopMode]];  break;
        case "F":
            [self buttonFullScreen_action: nil];  break;
        case "5":
            const sto5 = [Settings testOnFive];
            if (sto5 > 0) [self runFractControllerTest: sto5];
            break;
        case "R":
            [Settings toggleAutoRunIndex];  break;
        default:
            [super keyDown: theEvent];  break;
    }
}


- (IBAction) resultDetails_action: (id) sender {
    const path = "../readResultString.html";
    if ([Misc existsUrl: path]) {
        window.open(path, "_blank");
    }
}


- (IBAction) buttonFullScreen_action: (id) sender { //console.info("AppController>buttonFullScreen");
    const full = [Misc isFullScreen];
    if (full) {
        [Misc fullScreenOn: NO];  [[selfWindow contentView] setFrameOrigin: CGPointMake(0, 0)];
    } else {
        [Misc fullScreenOn: YES];
        const point = CGPointMake((window.screen.width - 800) / 2, (window.screen.height - 600) / 2);
        [[selfWindow contentView] setFrameOrigin: point];
    }
}


/**
 All test buttons land here, discriminated by their tag values (→HierarchyController for `TestIDType`)
 */
- (IBAction) buttonDoTest_action: (id) sender {
    [self runFractControllerTest: [sender tag]];
}


/**
 Deal with the Settings panel
 */
- (IBAction) buttonSettings_action: (id) sender { //console.info("AppController>buttonSettings");
    [sound initAfterUserinteraction];
    [Settings checkDefaults];  [settingsPanel makeKeyAndOrderFront: self];
    if (settingsNeededNewDefaults) {
        settingsNeededNewDefaults = NO;
        const alert = [CPAlert alertWithMessageText: "WARNING"
                                      defaultButton: "OK" alternateButton: nil otherButton: nil
                          informativeTextWithFormat: "\r\rAll settings were (re)set to their default values.\r\r"];
        [alert runModalWithDidEndBlock: function(alert, returnCode) {}];
    }
    [self postNotificationName: "copyColorsFromSettings" object: nil];
}

- (IBAction) buttonSettingsClose_action: (id) sender { //console.info("AppController>buttonSettingsClose");
    [Settings checkDefaults];  [settingsPanel close];
}

- (IBAction) buttonSettingsTestSound_action: (id) sender {
    [self postNotificationName: "updateSoundFiles" object: nil];
    [sound playDelayedNumber: [sender tag]]; // delay because new buffer to be loaded; 0.02 would be enough.
}

- (IBAction) buttonSettingsContrastAcuityMaxMin_action: (id) sender {
    switch ([sender tag]) {
        case 1: [Settings setContrastAcuityWeber: 100];  break;
        case 2: [Settings setContrastAcuityWeber: -10000];  break;
    }
}

- (IBAction) popupPreset_action: (id) sender {//console.info("popupPreset_action: ", sender)
    [presets apply: sender];
}


/**
 Deal with the Help/About panels
 */
- (IBAction) buttonHelp_action: (id) sender { //console.info("AppController>buttonHelp_action");
    [helpPanel makeKeyAndOrderFront: self];
    [PopulateAboutPanel populateHelpPanelView1: helpWebView1 v2: helpWebView2 v3: helpWebView3 v4: helpWebView4];
}
- (IBAction) buttonHelpClose_action: (id) sender { //console.info("AppController>buttonHelpClose_action");
    [helpPanel close];
}
- (IBAction) buttonAbout_action: (id) sender {
    [aboutPanel makeKeyAndOrderFront: self];
    [PopulateAboutPanel populateAboutPanelView1: aboutWebView1 view2: aboutWebView2];
}
- (IBAction) buttonAboutClose_action: (id) sender {
    [aboutPanel close];
}
- (IBAction) buttonGotoFractSite_action: (id) sender {
    window.open("https://michaelbach.de/fract/", "_blank");
}
- (IBAction) buttonGotoFractBlog_action: (id) sender {
    window.open("https://michaelbach.de/fract/blog.html", "_blank");
}
- (IBAction) buttonGotoFractManual_action: (id) sender {
    window.open("https://michaelbach.de/fract/manual.html", "_blank");
}
- (IBAction) buttonGotoFractChecklist_action: (id) sender {
    window.open("https://michaelbach.de/fract/checklist.html", "_blank");
}
- (IBAction) buttonGotoAcuityCheats_action: (id) sender {
    window.open("https://michaelbach.de/sci/acuity.html", "_blank");
}


#pragma mark
/**
 And more buttons…
 */
- (IBAction) buttonExport_action: (id) sender { //console.info("AppController>buttonExport_action");
    [Misc copyString2Clipboard: currentTestResultExportString];
    [self postNotificationName: "buttonExportEnableYESorNO" object: 0];
}


- (IBAction) buttonDoExit_action: (id) sender { //console.info("AppController>buttonExit_action");
    if ([Misc isFullScreen]) {
        [Misc fullScreenOn: NO];
    }
    [selfWindow close];  [CPApp terminate: nil];  window.close();
}


- (IBAction) radioButtonsAcuityBwOrColor_action: (id) sender {
    if (sender != null)
        [Settings setIsAcuityColor: [sender tag] == 1];
    else { // this is to preset the radio buttons
        [radioButtonAcuityBW setState: ([Settings isAcuityColor] ? CPOffState : CPOnState)];
        [radioButtonAcuityColor setState: ([Settings isAcuityColor] ? CPOnState : CPOffState)];
    }
}


- (IBAction) buttonCheckContrast_action: (id) sender { //console.info("AppController>buttonCheckContrast_action");
    const tag = [sender tag], contrastsPercent = [1, 3, 10, 30, 90];
    let contrastWeberPercent = 0;
    if ((tag > 0) && (tag <= 5))  contrastWeberPercent = contrastsPercent[tag - 1];
    const contrastLogCSWeber = [MiscLight contrastLogCSWeberFromWeberPercent: contrastWeberPercent];
    //    console.log(tag, contrastWeberPercent, contrastLogCSWeber)
    let gray1 = [MiscLight lowerLuminanceFromContrastLogCSWeber: contrastLogCSWeber];
    gray1 = [MiscLight devicegrayFromLuminance: gray1];
    let gray2 = [MiscLight upperLuminanceFromContrastLogCSWeber: contrastLogCSWeber];
    gray2 = [MiscLight devicegrayFromLuminance: gray2];
    if (![Settings contrastDarkOnLight]) {
        [gray1, gray2] = [gray2, gray1]; // "modern" swapping of variables
    }
    //console.log("Wperc ", contrastWeberPercent, ", lgCSW ", contrastLogCSWeber, ", g1 ", gray1, ", g2 ", gray2);

    //const c1 = [CPColor colorWithWhite: gray1 alpha: 1], c2 = [CPColor colorWithWhite: gray2 alpha: 1];
    let c1 = [MiscLight colorFromGreyBitStealed: gray1];
    let c2 = [MiscLight colorFromGreyBitStealed: gray2];
    if ([Settings contrastDithering]) {
        c1 = [CPColor colorWithPatternImage: [Dithering image3x3withGray: gray1]];
        c2 = [CPColor colorWithPatternImage: [Dithering image3x3withGray: gray2]];
    }
    [self setCheckContrastWeberFieldColor1: c1];
    [self setCheckContrastWeberFieldColor2: c2];
    let actualMichelsonPerc = [MiscLight contrastMichelsonPercentFromColor1: c1 color2: c2];
    let actualWeberPerc = [MiscLight contrastWeberPercentFromMichelsonPercent: actualMichelsonPerc];
    if ([Settings contrastDithering]) {
        actualMichelsonPerc = [MiscLight contrastMichelsonPercentFromWeberPercent: contrastWeberPercent];
        actualWeberPerc = contrastWeberPercent;
    }
    [self setCheckContrastActualMichelsonPercent: Math.round(actualMichelsonPerc * 10) / 10];
    [self setCheckContrastActualWeberPercent: Math.round(actualWeberPerc * 10) / 10];
}


- (IBAction) buttonGamma_action: (id) sender {
    [Settings setGammaValue: [Settings gammaValue] + ([sender tag] == 1 ? 0.1 : -0.1)];
    [gammaView setNeedsDisplay: YES];
}


/**
 Dealing with calibration via creditcard size
 */
- (void) creditCardUpdateSize {
    const wInPx = [MiscSpace pixelFromMillimeter: 92.4]; //magic number, why not 85.6?
    const hOverW = 53.98 / 85.6; // All bank cards are 85.6 mm wide and 53.98 mm high
    const hInPx = wInPx * hOverW, xc = 400, yc = 300 - 24; // position in window, space for buttons
    [creditcardImageView setFrame: CGRectMake(xc - wInPx / 2, yc - hInPx / 2, wInPx, hInPx)];
}
- (IBAction) buttonCreditcardUse_action: (id) sender {
    calBarLengthInMMbefore = [Settings calBarLengthInMM];//for possible undo
    [creditcardPanel makeKeyAndOrderFront: self];  [self creditCardUpdateSize];
}
- (IBAction) buttonCreditcardPlusMinus_action: (id) sender {
    let f = 1;
    switch ([sender tag]) {
        case 0: f = 1.0 / 1.01;  break;
        case 1: f = 1.0 / 1.1;  break;
        case 2: f = 1.01;  break;
        case 3: f = 1.1;  break;
    }
    [Settings setCalBarLengthInMM: [Settings calBarLengthInMM] * f];  [self creditCardUpdateSize];
}
- (IBAction) buttonCreditcardClosePanel_action: (id) sender {
    if ([sender tag] == 1)  [Settings setCalBarLengthInMM: calBarLengthInMMbefore];//undo
    let t = [Settings calBarLengthInMM];
    if (t >= 100) t = Math.round(t); // don't need that much precision
    [Settings setCalBarLengthInMM: t];
    [creditcardPanel close];
}

@end
