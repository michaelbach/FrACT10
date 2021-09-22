/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, michael.bach@uni-freiburg.de, <https://michaelbach.de>

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
@import "RewardsController.j"
@import "TAOController.j"
@import "Sound.j"
@import "GammaView.j"
@import "MDBButton.j"


/**
 AppController
 
 The main controller. It inherits from HierarchyController
 to make communication with some classes with do not inherit from AppController easier.
 */

/*window.ondeviceorientation = function(event) {
 [setAngleAlpha: Math.round(event.alpha)]; [setAngleAlpha: Math.round(event.beta)]; [setAngleAlpha: Math.round(event.gamma)];
 }*/
/*
 ScreenOrientation.addEventListener('change', function(e) { ... })
 ScreenOrientation.onchange = function(e) { ... }
 */
/*
 window.addEventListener("orientationchange", centerLoginBox);
 …
 if (window.orientation == 90
 */

@typedef TestIDType
kTestAcuityLett = 0; kTestAcuityC = 1; kTestAcuityE = 2; kTestIDTAO = 3; kTestIDVernier = 4; kTestContrastLett = 5; kTestContrastC = 6; kTestContrastE = 7;

CPPushOnPushOffButton = 1;

@implementation AppController : HierarchyController {
    @outlet CPWindow fractControllerWindow;
    @outlet CPColorWell checkContrastWeberField1, checkContrastWeberField2;
    @outlet CPPanel settingsPanel, aboutPanel, helpPanel, responseinfoPanelAcuityL, responseinfoPanelAcuity4C, responseinfoPanelAcuity8C, responseinfoPanelAcuityE, responseinfoPanelAcuityTAO, responseinfoPanelAcuityVernier, responseinfoPanelContrastLett, responseinfoPanelContrastC, responseinfoPanelContrastE, resultDetailsPanel;
    @outlet MDBButton buttonAcuityLett, buttonAcuityC, buttonAcuityE, buttonAcuityTAO, buttonAcuityVernier, buttCntLett, buttCntC, buttCntE;
    @outlet CPButton buttonExport;
    @outlet GammaView gammaView;
    CPImageView rewardImageView;
    RewardsController rewardsController;
    TAOController taoController;
    FractController currentFractController;
    //float angleAlpha @accessors, angleBeta @accessors, angleGamma @accessors;
    TestIDType testID;
    BOOL settingsNeededNewDefaults;
    BOOL runAborted @accessors;
    BOOL is4orientations @accessors;
    Sound sound;
    id allPanels, allTestControllers;
    CPColor checkContrastWeberFieldColor1 @accessors;
    CPColor checkContrastWeberFieldColor2 @accessors;
    float checkContrastActualWeberPercent @accessors
    float checkContrastActualMichelsonPercent @accessors
}


/**
 Accessing the foreground color for acuity optotypes as saved in settings.
 @return the current foreground color
 */
- (CPColor) acuityForeColor { //console.info("AppController>acuityForeColor");
    return [Settings acuityForeColor];
}
/**
 Setting the foreground color for acuity optotypes
 @param theColor: foreground color
 */
- (void) setAcuityForeColor: (CPColor) theColor { //console.info("AppController>
    [Settings setAcuityForeColor: theColor];
}
/**
 Accessing the background color for acuity optotypes as saved in settings.
 @return the current background color
 */
- (CPColor) acuityBackColor { //console.info("AppController>acuityBackColor");
    return [Settings acuityBackColor];
}
/**
 Setting the background color for acuity optotypes
 @param theColor: background color
 */
- (void) setAcuityBackColor: (CPColor) theColor { //console.info("AppController>setAcuityBackColor");
    [Settings setAcuityBackColor: theColor];
}
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
- (void) setWindowBackgroundColor: (CPColor) theColor { //console.info("AppController>setAcuityBackColor");
    [Settings setWindowBackgroundColor: theColor];
    [[self window] setBackgroundColor: theColor];
}


/**
 Our main initialisation begins here
 */
- (id) init { // console.info("AppController>init");
    settingsNeededNewDefaults = [Settings needNewDefaults];
    [Settings checkDefaults]; //important to do this very early, before nib loading, otherwise the updates don't populate the settings panel – DOES NOT HELP, unfortunately
    return self;
}


- (void) applicationDidFinishLaunching: (CPNotification) aNotification { //console.info("AppController>applicationDidFinishLaunching");
    'use strict';
    [[self window] setFullPlatformWindow: YES];
    [[self window] setBackgroundColor: [self windowBackgroundColor]];

    [CPMenu setMenuBarVisible: NO];
    addEventListener('error', function(e) {
        alert("An error occured, I'm sorry. Error message:\r\r" + e.message + "\r\rIf it recurs, please notify michael.bach@uni-freiburg.de, ideally relating the message, e.g. via a screeshot.\rI will look into it and endeavour to provide a fix ASAP.\r\rOn “Close”, the window will reload and you can retry.");
        window.location.reload(false);
    });

    window.addEventListener("orientationchange", function(e) {
        if ([Settings mobileOrientation]) {
            //alert("Orientation change, now "+e.target.screen.orientation.angle+"°.\r\rOn “Close”, the window will reload to fit.");
            window.location.reload(false);
        }
    });
    
    var allButtons = [buttonAcuityLett, buttonAcuityC, buttonAcuityE, buttonAcuityTAO, buttonAcuityVernier, buttCntLett, buttCntC, buttCntE];
    for (var i = 0; i < allButtons.length; i++)  [Misc makeFrameSquareFromWidth: allButtons[i]];
    
    allTestControllers = [FractControllerAcuityL, FractControllerAcuityC, FractControllerAcuityE, FractControllerAcuityTAO, FractControllerAcuityVernier, FractControllerContrastLett, FractControllerContrastC, FractControllerContrastE];

    allPanels = [responseinfoPanelAcuityL, responseinfoPanelAcuity4C, responseinfoPanelAcuity8C, responseinfoPanelAcuityE, responseinfoPanelAcuityTAO, responseinfoPanelAcuityVernier, responseinfoPanelContrastLett, responseinfoPanelContrastC, responseinfoPanelContrastE, settingsPanel, helpPanel, aboutPanel, resultDetailsPanel];
    for (var i = 0; i < allPanels.length; i++)  [allPanels[i] setFrameOrigin: CGPointMake(0, 0)];
    
    [[self window] setTitle: "FrACT10"];  [self setVersionDateString: [Settings versionFrACT] + "·" + [Settings versionDateFrACT]];
    [Settings checkDefaults]; // what was the reason to put this here???
    /*var s = @"Current key test settings: " + [Settings distanceInCM] +" cm distance, ";
    s += [Settings nAlternatives] + " Landolt alternatives, " + [Settings nTrials] + " trials";
    [self setKeyTestSettingsString: s];*/
    
    rewardImageView = [[CPImageView alloc] initWithFrame: CGRectMake(100, 0, 600, 600)];
    [[[self window] contentView] addSubview: rewardImageView];
    rewardsController = [[RewardsController alloc] initWithView: rewardImageView];
    taoController = [[TAOController alloc] initWithButton2Enable: buttonAcuityTAO];
    sound = [[Sound alloc] init];
    for (var i = 0; i < (Math.round([[CPDate date] timeIntervalSince1970]) % 33); i++); // ranomising the pseudorandom sequence


    [[CPNotificationCenter defaultCenter] addObserver: self selector: @selector(buttonExportEnableYESorNO:) name: "buttonExportEnableYESorNO" object: nil];
    [[CPNotificationCenter defaultCenter] postNotificationName: "buttonExportEnableYESorNO" object: 0];
    [[CPNotificationCenter defaultCenter] addObserver: self selector: @selector(copyForeBackColorsFromSettings:) name: "copyForeBackColorsFromSettings" object: nil];
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsDidChange:) name:CPUserDefaultsDidChangeNotification object:nil];

    [self buttonCheckContrast_action: null];
}


/**
 This observes changes in the settings panel, making shure some dependencies are updated
 */
- (void) defaultsDidChange: (CPNotification) aNotification { //console.info("defaultsDidChange");
    [self setIs4orientations: ([Settings nAlternatives] == 4)];
    [[self window] setBackgroundColor: [self windowBackgroundColor]];
}



- (void) buttonExportEnableYESorNO: (CPNotification) aNotification { //console.info("buttonExportEnableYESorNO");
    [buttonExport setHidden: [aNotification object] == 0];
}


// mirroring is necessary, because the Settingspanel cannot read the stored colours, because the Archiver does not work
- (void) copyForeBackColorsFromSettings: (CPNotification) aNotification { //console.info("mirrorForeBackColors");
    [self setAcuityForeColor: [Settings acuityForeColor]];  [self setAcuityBackColor: [Settings acuityBackColor]];
}


- (void) closeAllPanels {
    for (var i = 0; i < allPanels.length; i++)  [allPanels[i] close];
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
- (void) runFractController { //console.info("AppController>runFractController");
    if ([Settings isNotCalibrated]) {
        var alert = [CPAlert alertWithMessageText: "WARNING"
                                    defaultButton: "I just want to try it out" alternateButton: "OK, take me to Settings" otherButton: nil
                        informativeTextWithFormat: "\rCalibration is mandatory for valid results.\r\rGoto 'Settings' and enter appropriate values for \r«Length of blue ruler»\rand \r«Observer distance».\r\rThis will also avoid the present obnoxious warning dialog."];
        [alert runModalWithDidEndBlock: function(alert, returnCode) {
            switch (returnCode) {
                case 1: [self buttonSettings_action: nil];  break;
                case 0: [self runFractController2]; break;
            }
        }];
    } else {
        [self runFractController2];
    }
}


/**
 The above prerequisites were met, so let's run the test specified in the class-global `testID`
 */
- (void) runFractController2 { //console.info("AppController>runFractController2  ");
    [self closeAllPanels];
    if ([Settings responseInfoAtStart]) {
        switch (testID) {
            case kTestAcuityLett: [responseinfoPanelAcuityL makeKeyAndOrderFront: self]; break;
            case kTestAcuityC:
                switch ([Settings nAlternatives]) {
                    case 4: [responseinfoPanelAcuity4C makeKeyAndOrderFront: self];  break;
                    case 8: [responseinfoPanelAcuity8C makeKeyAndOrderFront: self];  break;
                }  break;
            case kTestAcuityE:
                [responseinfoPanelAcuityE makeKeyAndOrderFront: self];  break;
            case kTestIDTAO:
                [responseinfoPanelAcuityTAO makeKeyAndOrderFront: self];  break;
            case kTestIDVernier:
                [responseinfoPanelAcuityVernier makeKeyAndOrderFront: self];  break;
            case kTestContrastLett:
                [responseinfoPanelContrastLett makeKeyAndOrderFront: self];  break;
            case kTestContrastC:
                [responseinfoPanelContrastC makeKeyAndOrderFront: self];  break;
            case kTestContrastE:
                [responseinfoPanelContrastE makeKeyAndOrderFront: self];  break;
                break;
        }
    } else {
        [self runFractController2_actionOK: nil];
    }
}


/**
 Info panels (above) were not present, or oked, so lets now REALLY run the test.
 */
- (IBAction) runFractController2_actionOK: (id) sender { //console.info("AppController>runFractController2_actionOK");
    [self closeAllPanels];  [currentFractController release];
    currentFractController = [[allTestControllers[testID] alloc] initWithWindow: fractControllerWindow parent: self];
    [currentFractController setSound: sound];
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
        var temp = currentTestResultExportString.replace(/,/g, "."); // in localStorage we don't want to localise
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
        case "S":
            [[CPRunLoop currentRunLoop] performSelector: @selector(buttonSettings_action:) target: self argument: nil order: 10000 modes:[CPDefaultRunLoopMode]];  break; // this complicated version avoids propagation of the "s"
        case "F":
            [self  buttonFullScreen_action: nil];  break;
        case "L":
            [self  buttonDoAcuityLetters_action: nil];  break;
        case "C":
            [self  buttonDoAcuityLandolt_action: nil];  break;
        case "E":
            [self  buttonDoAcuityE_action: nil];  break;
        case "A":
            [self  buttonDoAcuityTAO_action: nil];  break;
        case "V":
            [self  buttonDoAcuityVernier_action: nil];  break;
        case "1":
            [self  buttonDoContrastLett_action: nil];  break;
        case "2":
            [self  buttonDoContrastC_action: nil];  break;
        case "3":
            [self  buttonDoContrastE_action: nil];  break;
        case "5" :
            switch([Settings testOnFive]) {
                case 1: [self  buttonDoAcuityLetters_action: nil];  break;
                case 2: [self  buttonDoAcuityLandolt_action: nil];  break;
                case 3: [self  buttonDoAcuityE_action: nil];  break;
                case 4: [self  buttonDoAcuityTAO_action: nil];  break;
                case 5: [self  buttonDoAcuityVernier_action: nil];  break;
                case 6: [self  buttonDoContrastLett_action: nil];  break;
                case 7: [self  buttonDoContrastC_action: nil];  break;
                case 8: [self  buttonDoContrastE_action: nil];  break;
            } break;
        //case "∆": [self runtimeError_action: nil];  break;
        //case "T": [self resultDetails_action: nil];  break;
        default:
            [super keyDown: theEvent];  break;
    }
}


/**
 Helper function: Find out if this URL exists
 */
function existsUrl(url) {
    var request;
    if(window.XMLHttpRequest)
        request = new XMLHttpRequest();
    else
        request = new ActiveXObject("Microsoft.XMLHTTP");
    request.open('GET', url, false);
    request.send(); // there will be a 'pause' here until the response to come.
    // the object request will be modified
    if (request.status === 404) {
        alert("The page you are trying to reach is not available.");
        return false;
    }
    return true;
}
- (IBAction) resultDetails_action: (id) sender {
    var path = "../readResultString.html";
    if (existsUrl(path)) {
        window.open(path, "_blank");
    }
}


/**
 This will, on purpose, cause a run-time error when entering ‘∆’. This tests behaviour on such conditions.
 */
- (IBAction) runtimeError_action: (id) sender { //console.info("AppController>runtimeError_action");
    alert("The (rarely) entered glyph ‘∆’ is my purposeful test for causing a runtime errror. So there will be an error now…")
    [self abc];
}


- (IBAction) buttonFullScreen_action: (id) sender { //console.info("AppController>buttonFullScreen");
    var full = [Misc isFullScreen];
    if (full) {
        [Misc fullScreenOn: NO];  [[[self window] contentView] setFrameOrigin: CGPointMake(0, 0)];
    } else {
        [Misc fullScreenOn: YES];
        var point = CGPointMake((window.screen.width - 800) / 2, (window.screen.height - 600) / 2);
        [[[self window] contentView] setFrameOrigin: point];
    }
}


- (IBAction) buttonDoAcuityLetters_action: (id) sender { //console.info("AppController>buttonDoAcuityLetters_action");
    testID = kTestAcuityLett;    [self runFractController];
}
- (IBAction) buttonDoAcuityLandolt_action: (id) sender { //console.info("AppController>buttonDoAcuity_action");
    testID = kTestAcuityC;    [self runFractController];
}
- (IBAction) buttonDoAcuityE_action: (id) sender { //console.info("AppController>buttonDoAcuityE_action");
    testID = kTestAcuityE;    [self runFractController];
}
- (IBAction) buttonDoAcuityTAO_action: (id) sender { //console.info("AppController>buttonDoAcuityA_action");
    testID = kTestIDTAO;    [self runFractController];
}
- (IBAction) buttonDoAcuityVernier_action: (id) sender { //console.info("AppController>buttonDoAcuityE_action");
    testID = kTestIDVernier;    [self runFractController];
}
- (IBAction) buttonDoContrastLett_action: (id) sender { //console.info("AppController>buttonDoContrastLett_action");
    testID = kTestContrastLett;    [self runFractController];
}
- (IBAction) buttonDoContrastC_action: (id) sender { //console.info("AppController>buttonDoContrastC_action");
    testID = kTestContrastC;    [self runFractController];
}
- (IBAction) buttonDoContrastE_action: (id) sender { //console.info("AppController>buttonDoContrastC_action");
    testID = kTestContrastE;    [self runFractController];
}


- (IBAction) buttonSettings_action: (id) sender { //console.info("AppController>buttonSettings");
    [Settings checkDefaults];  [settingsPanel makeKeyAndOrderFront: self];
    if (settingsNeededNewDefaults) {
        settingsNeededNewDefaults = NO;
        var alert = [CPAlert alertWithMessageText: "WARNING"
                                    defaultButton: "OK" alternateButton: nil otherButton: nil
                        informativeTextWithFormat: "\r\rAll settings were (re)set to their default values.\r\r"];
        [alert runModalWithDidEndBlock: function(alert, returnCode) {}];
    }
    [[CPNotificationCenter defaultCenter] postNotificationName: "copyForeBackColorsFromSettings" object: nil];
}
- (IBAction) buttonSettingsClose_action: (id) sender { //console.info("AppController>buttonSettingsClose");
    [Settings checkDefaults];  [settingsPanel close];
    // below the idea was to keep e.g. red optotypes – but they do not appear. Ah, they cannot appear – only gray values there
    //[Settings setAcuityForeColor: [self acuityForeColor]];  [Settings setAcuityBackColor: [self acuityBackColor]];
}
- (IBAction) buttonSettingsDefaults_action: (id) sender { //console.info("AppController>buttonSettingsDefaults");
    [Settings setDefaults];  [settingsPanel close];  [Settings setDefaults];  [settingsPanel makeKeyAndOrderFront: self];
    [[settingsPanel contentView] setNeedsDisplay: YES];
}
- (IBAction) buttonSettingsTestSound_action: (id) sender { //console.info("AppController>buttonSettingsDefaults");
    [sound play3];
}


- (IBAction) buttonHelp_action: (id) sender { //console.info("AppController>buttonHelp_action");
    [helpPanel makeKeyAndOrderFront: self];
}
- (IBAction) buttonHelpGetManual_action: (id) sender {
    window.open("https://michaelbach.de/fract/manual.html", "_blank");
}
- (IBAction) buttonHelpGetChecklist_action: (id) sender {
    window.open("https://michaelbach.de/fract/checklist.html", "_blank");
}
- (IBAction) buttonHelpCheats_action: (id) sender {
    window.open("https://michaelbach.de/sci/acuity.html", "_blank");
}
- (IBAction) buttonHelpClose_action: (id) sender { //console.info("AppController>buttonHelpClose_action");
    [helpPanel close];
}


- (IBAction) buttonAbout_action: (id) sender { //console.info("AppController>buttonAbout_action");
    [aboutPanel makeKeyAndOrderFront: self];
}
- (IBAction) buttonAboutWebsiteMB_action: (id) sender {
    window.open("https://michaelbach.de", "_blank");
}
- (IBAction) buttonAboutWebsiteFractSite_action: (id) sender {
    window.open("https://michaelbach.de/fract/", "_blank");
}
- (IBAction) buttonAboutWebsiteFractBlog_action: (id) sender {
    window.open("https://michaelbach.de/fract/blog.html", "_blank");
}
- (IBAction) buttonAboutClose_action: (id) sender { //console.info("AppController>buttonAboutClose_action");
    [aboutPanel close];
}


- (IBAction) buttonExport_action: (id) sender { //console.info("AppController>buttonExport_action");
    [Misc copyString2Clipboard: currentTestResultExportString];
    [[CPNotificationCenter defaultCenter] postNotificationName: "buttonExportEnableYESorNO" object: 0];
}


- (IBAction) buttonExit_action: (id) sender { //console.info("AppController>buttonExit_action");
    if ([Misc isFullScreen]) {
        [Misc fullScreenOn: NO];
    }
    [[self window] close];  [CPApp terminate: nil];
}


- (IBAction) buttonCheckContrast_action: (id) sender { //console.info("AppController>buttonCheckContrast_action");
    var tag = [sender tag], contrastsPercent = [1, 3, 10, 30, 90], contrastPercent = 0;
    if ((tag > 0) && (tag <= 5))  contrastPercent = contrastsPercent[tag - 1];
    var contrastLogCSWeber = [Misc contrastLogCSWeberFromWeberPercent: contrastPercent];
    //    console.log(tag, contrastPercent, contrastLogCSWeber)
    var gray1 = [Misc lowerLuminanceFromContrastLogCSWeber: contrastLogCSWeber];
    gray1 = [Misc devicegrayFromLuminance: gray1];
    var gray2 = [Misc upperLuminanceFromContrastLogCSWeber: contrastLogCSWeber];
    gray2 = [Misc devicegrayFromLuminance: gray2];
    if (![Settings contrastDarkOnLight]) {
        var gray = gray1; gray1 = gray2; gray2 = gray;
    }
    //    console.log("Wperc ", contrastPercent, ", lgCSW ", contrastLogCSWeber, ", g1 ", gray1, ", g2 ", gray2);
    
    var c1 = [CPColor colorWithWhite: gray1 alpha: 1], c2 = [CPColor colorWithWhite: gray2 alpha: 1];
    [self setCheckContrastWeberFieldColor1: c1];   [self setCheckContrastWeberFieldColor2: c2];
    
    var actualMichelsonPerc = [Misc contrastMichelsonPercentFromColor1: c1 color2: c2];
    [self setCheckContrastActualMichelsonPercent: Math.round(actualMichelsonPerc * 10) / 10];
    
    var actualWeberPerc = [Misc contrastWeberFromMichelsonPercent: actualMichelsonPerc];
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
 
@end
