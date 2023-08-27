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
@import "FractControllerAcuityLineByLine.j"
@import "RewardsController.j"
@import "TAOController.j"
@import "Sound.j"
@import "GammaView.j"
@import "MDBButton.j"
@import "PopulateAboutPanel.j"
@import "Presets.j"


/**
 AppController
 
 The main controller. It inherits from HierarchyController
 to make communication with some classes with do not inherit from AppController easier.
 */

@implementation AppController : HierarchyController {
    @outlet CPWindow fractControllerWindow;
    @outlet CPColorWell checkContrastWeberField1, checkContrastWeberField2;
    @outlet CPPanel settingsPanel, aboutPanel, helpPanel, responseinfoPanelAcuityL, responseinfoPanelAcuity4C, responseinfoPanelAcuity8C, responseinfoPanelAcuityE, responseinfoPanelAcuityTAO, responseinfoPanelAcuityVernier, responseinfoPanelContrastLett, responseinfoPanelContrastC, responseinfoPanelContrastE, responseinfoPanelContrastG, responseinfoPanelAcuityLineByLine, resultDetailsPanel, creditcardPanel;
    @outlet MDBButton buttonAcuityLett, buttonAcuityC, buttonAcuityE, buttonAcuityTAO, buttonAcuityVernier, buttCntLett, buttCntC, buttCntE, buttCntG, buttonAcuityLineByLine;
    @outlet CPButton buttonExport, buttonExit;
    @outlet CPButton radioButtonAcuityBW, radioButtonAcuityColor;
    @outlet GammaView gammaView;
    @outlet CPWebView aboutWebView1, aboutWebView2, helpWebView1, helpWebView2, helpWebView3, helpWebView4;
    @outlet CPImageView creditcardImageView;
    CPImageView rewardImageView;
    RewardsController rewardsController;
    TAOController taoController;
    FractController currentFractController;
    BOOL settingsNeededNewDefaults;
    BOOL runAborted @accessors;
    BOOL is4orientations @accessors;
    Sound sound;
    id allPanels, allTestControllers;
    CPColor checkContrastWeberFieldColor1 @accessors;
    CPColor checkContrastWeberFieldColor2 @accessors;
    float checkContrastActualWeberPercent @accessors;
    float checkContrastActualMichelsonPercent @accessors;
    int settingsTabViewSelectedIndex @accessors;
    float calBarLengthInMMbefore;
    CPColor colorOfBestPossibleAcuity @accessors;
}


/**
 Accessing the foreground/background color for acuity optotypes as saved in settings.
 @return the current foreground color
 Colors not be saved as object in userdefaults, probably serialiser not implemented
 NSUnarchiveFromData, Error message [CPData encodeWithCoder:] unrecognized selector
 https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/DrawColor/Tasks/StoringNSColorInDefaults.html
 */
- (CPColor) acuityForeColor { //console.info("AppController>acuityForeColor");
    return [Settings acuityForeColor];
}
- (void) setAcuityForeColor: (CPColor) col {//console.info("AppController>setAcuityForeColor");
    [Settings setAcuityForeColor: col];
}
- (CPColor) acuityBackColor { //console.info("AppController>acuityBackColor");
    return [Settings acuityBackColor];
}
- (void) setAcuityBackColor: (CPColor) col { //console.info("AppController>setAcuityBackColor");
    [Settings setAcuityBackColor: col];
}

/**
 Accessing the foreground /background color for gratings
 */
- (void) setGratingForeColor: (CPColor) col {[Settings setGratingForeColor: col];}
- (CPColor) gratingForeColor {return [Settings gratingForeColor];}
- (void) setGratingBackColor: (CPColor) col {[Settings setGratingBackColor: col];}
- (CPColor) gratingBackColor {return [Settings gratingBackColor];}

/**
 Accessing the window background color
 @return the current background color
 */
- (CPColor) windowBackgroundColor { //console.info("AppController>acuityBackColor");
    return [Settings windowBackgroundColor];
}
/**
 Setting the window background color
 @param theColor: background color
 */
- (void) setWindowBackgroundColor: (CPColor) col { //console.info("AppController>setAcuityBackColor");
    [Settings setWindowBackgroundColor: col];
    [[self window] setBackgroundColor: col];
}


/**
 Our main initialisation begins here
 */
- (id) init { // console.info("AppController>init");
    settingsNeededNewDefaults = [Settings needNewDefaults];
    [Settings checkDefaults]; //important to do this very early, before nib loading, otherwise the updates don't populate the settings panel – DOES NOT HELP, unfortunately
    return self;
}


/** runs after "init" above */
- (void) applicationDidFinishLaunching: (CPNotification) aNotification { //console.info("AppController>applicationDidFinishLaunching");
    'use strict';
    [[self window] setFullPlatformWindow: YES];
    [[self window] setBackgroundColor: [self windowBackgroundColor]];
    
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
    
    allTestControllers = [FractControllerAcuityL, FractControllerAcuityC, FractControllerAcuityE, FractControllerAcuityTAO, FractControllerAcuityVernier, FractControllerContrastLett, FractControllerContrastC, FractControllerContrastE, FractControllerContrastG, FractControllerAcuityLineByLine];
    
    allPanels = [responseinfoPanelAcuityL, responseinfoPanelAcuity4C, responseinfoPanelAcuity8C, responseinfoPanelAcuityE, responseinfoPanelAcuityTAO, responseinfoPanelAcuityVernier, responseinfoPanelContrastLett, responseinfoPanelContrastC, responseinfoPanelContrastE, responseinfoPanelContrastG, responseinfoPanelAcuityLineByLine, settingsPanel, helpPanel, aboutPanel, resultDetailsPanel, creditcardPanel];
    for (const p of allPanels) {
        [p setFrameOrigin: CGPointMake(0, 0)];  [p setMovable: NO];
    }
    [self setSettingsTabViewSelectedIndex: 0]; // first time select the "General" tab in Settings
    
    [[self window] setTitle: "FrACT10"];
    [self setVersionDateString: [Settings versionFrACT] + "·" + [Settings versionDateFrACT]];
    
    [Settings checkDefaults]; // what was the reason to put this here???
    /*let s = @"Current key test settings: " + [Settings distanceInCM] +" cm distance, ";
     s += [Settings nAlternatives] + " Landolt alternatives, " + [Settings nTrials] + " trials";
     [self setKeyTestSettingsString: s];*/
    
    rewardImageView = [[CPImageView alloc] initWithFrame: CGRectMake(100, 0, 600, 600)];
    [[[self window] contentView] addSubview: rewardImageView];
    rewardsController = [[RewardsController alloc] initWithView: rewardImageView];
    taoController = [[TAOController alloc] initWithButton2Enable: buttonAcuityTAO];
    sound = [[Sound alloc] init];
    for (let i = 0; i < (Math.round([[CPDate date] timeIntervalSince1970]) % 33); i++)
        Math.random(); // randomising the pseudorandom sequence
    
    [[CPNotificationCenter defaultCenter] addObserver: self selector: @selector(buttonExportEnableYESorNO:) name: "buttonExportEnableYESorNO" object: nil];
    [[CPNotificationCenter defaultCenter] postNotificationName: "buttonExportEnableYESorNO" object: 0];
    [[CPNotificationCenter defaultCenter] addObserver: self selector: @selector(copyColorsFromSettings:) name: "copyColorsFromSettings" object: nil];
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsDidChange:) name:CPUserDefaultsDidChangeNotification object:nil];
    
    [self radioButtonsAcuityBwOrColor_action: null];
    [self buttonCheckContrast_action: null];
    
    if ([window.navigator.platform hasPrefix:@"Mac"])  [buttonExit setTitle: "Quit"];// OS: Quit or Exit
    
    [Settings setAutoRunIndex: 0]; // make sure it's not accidentally on
    
    [[self window] orderFront:self]; //← this ensures that it will receive clicks w/o activating
}


/**
 This observes changes in the settings panel, making shure dependencies are updated
 */
- (void) settingsDidChange: (CPNotification) aNotification { //console.info("settingsDidChange");
    [self setIs4orientations: ([Settings nAlternatives] == 4)];
    [[self window] setBackgroundColor: [self windowBackgroundColor]];
    if ([Settings minPossibleLogMAR] > 0) { // red: not good enough for normal vision
        [self setColorOfBestPossibleAcuity: [CPColor redColor]];
    } else {
        [self setColorOfBestPossibleAcuity: [CPColor colorWithRed: 0 green: 0.4 blue: 0 alpha: 1]];
    }
    [self radioButtonsAcuityBwOrColor_action: null];
}


- (void) buttonExportEnableYESorNO: (CPNotification) aNotification { //console.info("buttonExportEnableYESorNO");
    [buttonExport setHidden: [aNotification object] == 0];
}


/**
 Synchronising userdefaults & Appcontroller
 THis mirroring is necessary, because the Settingspanel cannot read the stored colors, because the Archiver does not work
 */
- (void) copyColorsFromSettings: (CPNotification) aNotification { //console.info("mirrorForeBackColors");
    [self setAcuityForeColor: [Settings acuityForeColor]];  [self setAcuityBackColor: [Settings acuityBackColor]];
    [self setGratingForeColor: [Settings gratingForeColor]];  [self setGratingBackColor: [Settings gratingBackColor]];
    [self setWindowBackgroundColor: [Settings windowBackgroundColor]];
}


- (void) closeAllPanels {
    for (const p of allPanels)  [p close];
}


/**
 We will need this in FractControllerAcuityTAO, it's an intermediate calling point accessed via parent.
 */
- (id) taoImageArray {
    return [taoController imageArray];
}


/**
 One of the tests should run, but let's test some prerequisites first
 */
- (void) runFractControllerTest: (int) testNr { //console.info("AppController>runFractController");
    currentTestID = testNr;
    if ([Settings isNotCalibrated]) {
        const alert = [CPAlert alertWithMessageText: "Calibration is mandatory for valid results!"
                                      defaultButton: "I just want to try…" alternateButton: "OK, go to Settings" otherButton: "Cancel"
                          informativeTextWithFormat: "\rGoto 'Settings' and enter appropriate values for \r«Length of blue ruler» and «Observer distance»;\ror use the credit card sizing method.\r\rThis will also avoid the present obnoxious warning dialog."];
        [alert runModalWithDidEndBlock: function(alert, returnCode) {
            switch (returnCode) {
                case 1: // alternateButton
                    [self setSettingsTabViewSelectedIndex: 0]; // ensure "General" tab
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
        }
    } else {
        [self runFractController2_actionOK: nil];
    }
}


/**
 Info panels (above) were not shown, or oked, so lets now REALLY run the test.
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
}


- (void) exportCurrentTestResult { //console.info("AppController>exportCurrentTestResult");
    let temp = currentTestResultExportString.replace(/,/g, "."); // in localStorage we don't want to localise
    localStorage.setItem([Settings filenameResultStorage], temp);
    temp = currentTestResultsHistoryExportString.replace(/,/g, ".");
    localStorage.setItem([Settings filenameResultsHistoryStorage], temp);
    
    if ([Settings results2clipboard] > 0) {
        if ([Settings results2clipboard] == 2) {
            currentTestResultExportString += currentTestResultsHistoryExportString;
        }
        if ([Settings results2clipboardSilent]) {
            [Misc copyString2Clipboard: currentTestResultExportString];
        } else {
            [Misc copyString2ClipboardWithDialog: currentTestResultExportString];
        }
    }
    [[CPNotificationCenter defaultCenter] postNotificationName: "buttonExportEnableYESorNO" object: ([currentTestResultExportString length] > 1)];
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("AppController>drawStimulusInRect");
    [currentFractController drawStimulusInRect: dirtyRect forView: fractView];
}


/*- (void) controlTextDidChange: (CPNotification) notification { //console.info(@"controlTextDidChange: stringValue == %@", [[notification object] stringValue]);[Settings calculateMaxPossibleDecimalAcuity];
 }*/
/**
 Called from some text fields in the Settings panel, to update dependencies
 */
- (void) controlTextDidEndEditing: (CPNotification) notification { //console.info(@"controlTextDidChange: stringValue == %@", [[notification object] stringValue]);
    [Settings calculateMaxPossibleDecimalAcuity];
    [Settings calculateAcuityForeBackColorsFromContrast];
}


- (void) keyDown: (CPEvent) theEvent { //console.info("AppController>keyDown");
    switch([[[theEvent charactersIgnoringModifiers] characterAtIndex: 0] uppercaseString]) {
        case "Q": case "X": // Quit or eXit
            [self buttonDoExit_action: nil];  break;
        case "S":
            [[CPRunLoop currentRunLoop] performSelector: @selector(buttonSettings_action:) target: self argument: nil order: 10000 modes:[CPDefaultRunLoopMode]];  break; // this complicated version avoids propagation of the "s"
        case "F":
            [self buttonFullScreen_action: nil];  break;
        case "L":
            [self runFractControllerTest: kTestAcuityLett];  break;
        case "C":
            [self runFractControllerTest: kTestAcuityC];  break;
        case "E":
            [self runFractControllerTest: kTestAcuityE];  break;
        case "A":
            [self runFractControllerTest: kTestAcuityTAO];  break;
        case "V":
            [self runFractControllerTest: kTestAcuityVernier];  break;
        case "1":
            [self runFractControllerTest: kTestContrastLett];  break;
        case "2":
            [self runFractControllerTest: kTestContrastC];  break;
        case "3":
            [self runFractControllerTest: kTestContrastE];  break;
        case "G":
            [self runFractControllerTest: kTestContrastG];  break;
        case "4":
            [self runFractControllerTest: kTestAcuityLineByLine];  break;
        case "5" :
            switch([Settings testOnFive]) { //0: ignore
                case 1: [self runFractControllerTest: kTestAcuityLett];  break;
                case 2: [self runFractControllerTest: kTestAcuityC];  break;
                case 3: [self runFractControllerTest: kTestAcuityE];  break;
                case 4: [self runFractControllerTest: kTestAcuityTAO];  break;
                case 5: [self runFractControllerTest: kTestAcuityVernier];  break;
                case 6: [self runFractControllerTest: kTestContrastLett];  break;
                case 7: [self runFractControllerTest: kTestContrastC];  break;
                case 8: [self runFractControllerTest: kTestContrastE];  break;
                case 9: [self runFractControllerTest: kTestAcuityLineByLine];  break;
            } break;
            //case "∆": [self runtimeError_action: nil];  break;
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


/**
 This will, on purpose, cause a run-time error when entering ‘∆’. This tests behaviour on such conditions. (but currently disabled, see above)
 */
- (IBAction) runtimeError_action: (id) sender { //console.info("AppController>runtimeError_action");
    alert("The (rarely) entered glyph ‘∆’ is my purposeful test for causing a runtime errror. So there will occur an error now…")
    [self abc];
}


- (IBAction) buttonFullScreen_action: (id) sender { //console.info("AppController>buttonFullScreen");
    const full = [Misc isFullScreen];
    if (full) {
        [Misc fullScreenOn: NO];  [[[self window] contentView] setFrameOrigin: CGPointMake(0, 0)];
    } else {
        [Misc fullScreenOn: YES];
        const point = CGPointMake((window.screen.width - 800) / 2, (window.screen.height - 600) / 2);
        [[[self window] contentView] setFrameOrigin: point];
    }
}


/**
 All test buttons land here, discriminated by the tag values
 kTestAcuityLett = 0; kTestAcuityC = 1; kTestAcuityE = 2; kTestAcuityTAO = 3; kTestAcuityVernier = 4; kTestContrastLett = 5; kTestContrastC = 6; kTestContrastE = 7, kTestContrastG = 8, kTestAcuityLineByLine = 9;← set these tag values
 */
- (IBAction) buttonDoTest_action: (id) sender {
    [self runFractControllerTest: [sender tag]];
}


/**
 Deal with the Settings panel
 */
- (IBAction) buttonSettings_action: (id) sender { //console.info("AppController>buttonSettings");
    [Settings checkDefaults];  [settingsPanel makeKeyAndOrderFront: self];
    if (settingsNeededNewDefaults) {
        settingsNeededNewDefaults = NO;
        const alert = [CPAlert alertWithMessageText: "WARNING"
                                    defaultButton: "OK" alternateButton: nil otherButton: nil
                        informativeTextWithFormat: "\r\rAll settings were (re)set to their default values.\r\r"];
        [alert runModalWithDidEndBlock: function(alert, returnCode) {}];
    }
    [[CPNotificationCenter defaultCenter] postNotificationName: "copyColorsFromSettings" object: nil];
}
- (IBAction) buttonSettingsClose_action: (id) sender { //console.info("AppController>buttonSettingsClose");
    [Settings checkDefaults];  [settingsPanel close];
}
- (IBAction) buttonSettingsDefaults_action: (id) sender { //console.info("AppController>buttonSettingsDefaults");
    [Settings setDefaults];  [settingsPanel close];  [Settings setDefaults];  [settingsPanel makeKeyAndOrderFront: self];
    [[settingsPanel contentView] setNeedsDisplay: YES];
}
- (IBAction) buttonSettingsTestSound_action: (id) sender { //console.info("AppController>buttonSettingsDefaults");
    [sound play3];
}
- (IBAction) buttonSettingsContrastAcuityMaxMin_action: (id) sender {
    switch ([sender tag]) {
        case 1: [Settings setContrastAcuityWeber: 100];  break;
        case 2: [Settings setContrastAcuityWeber: -10000];  break;
    }
}
- (IBAction) popupPreset_action: (id) sender {
    [Presets apply: sender];
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


/**
 And more buttons…
 */
- (IBAction) buttonExport_action: (id) sender { //console.info("AppController>buttonExport_action");
    [Misc copyString2Clipboard: currentTestResultExportString];
    [[CPNotificationCenter defaultCenter] postNotificationName: "buttonExportEnableYESorNO" object: 0];
}


- (IBAction) buttonDoExit_action: (id) sender { //console.info("AppController>buttonExit_action");
    if ([Misc isFullScreen]) {
        [Misc fullScreenOn: NO];
    }
    [[self window] close];  [CPApp terminate: nil];  window.close();
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
    let contrastPercent = 0;
    if ((tag > 0) && (tag <= 5))  contrastPercent = contrastsPercent[tag - 1];
    const contrastLogCSWeber = [MiscLight contrastLogCSWeberFromWeberPercent: contrastPercent];
    //    console.log(tag, contrastPercent, contrastLogCSWeber)
    let gray1 = [MiscLight lowerLuminanceFromContrastLogCSWeber: contrastLogCSWeber];
    gray1 = [MiscLight devicegrayFromLuminance: gray1];
    let gray2 = [MiscLight upperLuminanceFromContrastLogCSWeber: contrastLogCSWeber];
    gray2 = [MiscLight devicegrayFromLuminance: gray2];
    if (![Settings contrastDarkOnLight]) {
        [gray1, gray2] = [gray2, gray1]; // "modern" swapping of variables
    }
    //    console.log("Wperc ", contrastPercent, ", lgCSW ", contrastLogCSWeber, ", g1 ", gray1, ", g2 ", gray2);
    
    const c1 = [CPColor colorWithWhite: gray1 alpha: 1], c2 = [CPColor colorWithWhite: gray2 alpha: 1];
    [self setCheckContrastWeberFieldColor1: c1];   [self setCheckContrastWeberFieldColor2: c2];
    const actualMichelsonPerc = [MiscLight contrastMichelsonPercentFromColor1: c1 color2: c2];
    [self setCheckContrastActualMichelsonPercent: Math.round(actualMichelsonPerc * 10) / 10];
    const actualWeberPerc = [MiscLight contrastWeberFromMichelsonPercent: actualMichelsonPerc];
    [self setCheckContrastActualWeberPercent:  Math.round(actualWeberPerc * 10) / 10];
}


- (IBAction) buttonGamma_action: (id) sender { //console.info("AppController>buttonGamma_action");
    switch ([sender tag]) {
        case 1:
            [Settings setGammaValue: [Settings gammaValue] + 0.1];
        break;
        case 2:
            [Settings setGammaValue: [Settings gammaValue] - 0.1];
        break;
    }
    [gammaView setNeedsDisplay: YES];
}


/**
 Dealing with calibration via creditcard size
 */
- (void) creditCardUpdateSize {
    const widthInPx = 92.4 * [Settings calBarLengthInPixel] / [Settings calBarLengthInMM];//magic number?
    const hOverW = 53.98 / 85.6; // All credit cards are 85.6 mm wide and 53.98 mm high
    const heightInPx = widthInPx * hOverW, xc = 400, yc = 300 - 24; // position in window, space for buttons
    [creditcardImageView setFrame:
      CGRectMake(xc - widthInPx / 2, yc - heightInPx / 2 , widthInPx, heightInPx)];
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
    [Settings setCalBarLengthInMM: [Settings calBarLengthInMM] * f];
    [self creditCardUpdateSize];
}
- (IBAction) buttonCreditcardClosePanel_action: (id) sender {
    if ([sender tag] == 1)  [Settings setCalBarLengthInMM: calBarLengthInMMbefore];//undo
    let t = [Settings calBarLengthInMM];
    if (t >= 100) t = Math.round(t); // don't need that much precision
    [Settings setCalBarLengthInMM: t];
    [creditcardPanel close];
}

@end
