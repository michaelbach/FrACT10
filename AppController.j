/*
 * AppController.j
 * FrACT10
 *
 * Created by mb on 2017-07-12.
 * Copyright 2015, Your Company All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "HierarchyController.j"
@import "FractView.j"
@import "FractController.j"
@import "FractControllerVAC.j"
@import "FractControllerVAL.j"
@import "FractControllerVAE.j"
@import "FractControllerVAAuck.j"
@import "FractControllerVAVernier.j"
@import "FractControllerContrastC.j"
@import "RewardsController.j"
@import "AucklandOptotypesController.j"
@import "Sound.j"

/*window.ondeviceorientation = function(event) {
    [setAngleAlpha: Math.round(event.alpha)]; [setAngleAlpha: Math.round(event.beta)]; [setAngleAlpha: Math.round(event.gamma)];
}*/


@implementation AppController : HierarchyController {
    @outlet CPWindow fractControllerWindow;
    @outlet CPPanel settingsPanel, aboutPanel, helpPanel, responseinfoPanelVAL, responseinfoPanelVA4C, responseinfoPanelVA8C, responseinfoPanelVAE, responseinfoPanelVAAuck, responseinfoPanelVAVernier;
    @outlet CPButton buttVALett, buttVAC, buttVAE, buttVAAuck, buttVAVernier;
    //@outlet
    CPImageView rewardImageView;
    RewardsController rewardsController;
    AucklandOptotypesController aucklandOptotypesController;
    FractController currentFractController;
    //float angleAlpha @accessors, angleBeta @accessors, angleGamma @accessors;
    int testID, kTestIDLett, kTestIDC, kTestIDE, kTestIDAuck, kTestIDVernier, kTestContrastC;
    BOOL settingsNeedNewDefaults;
    BOOL runAborted @accessors;
    Sound sound;
    id allPanels, allTestControllers;
}


- (void)awakeFromCib { //console.info("AppController>awakeFromCib");
    settingsNeedNewDefaults = [Settings needNewDefaults];
    [Settings checkDefaults]; //important to do this early, otherwise the updates don't populate the settings panel – DOES NOT HELP, unfortunately
    [[self window] setFullPlatformWindow: YES];
    [CPMenu setMenuBarVisible:NO];
}


- (void) applicationDidFinishLaunching: (CPNotification) aNotification { //console.info("AppController>applicationDidFinishLaunching");
    var allButtons = [buttVALett, buttVAC, buttVAE, buttVAAuck, buttVAVernier];
    for (var i = 0; i < allButtons.length; i++)  [self buttonImageAdjust: allButtons[i]];
/*    [self buttonImageAdjust: buttVALett];  [self buttonImageAdjust: buttVAC];
    [self buttonImageAdjust: buttVAE];  [self buttonImageAdjust: buttVAAuck];
    [self buttonImageAdjust: buttVAVernier];
*/
    
    kTestIDLett = 0;  kTestIDC = 1; kTestIDE = 2; kTestIDAuck = 3; kTestIDVernier = 4; kTestContrastC = 5;
    allTestControllers = [FractControllerVAL, FractControllerVAC, FractControllerVAE, FractControllerVAAuck, FractControllerVAVernier, FractControllerContrastC];
//    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsDidChange:) name:CPUserDefaultsDidChangeNotification object:nil];
    
    allPanels = [responseinfoPanelVAL, responseinfoPanelVA4C, responseinfoPanelVA8C, responseinfoPanelVAE, responseinfoPanelVAAuck, responseinfoPanelVAVernier, settingsPanel, helpPanel, aboutPanel];
    for (var i = 0; i < allPanels.length; i++)  [allPanels[i] setFrameOrigin: CGPointMake(0, 0)];
   
    var v = [Settings versionNumber] + "·" + [Settings versionDate]
     [[self window] setTitle: "FrACT10"]; [self setVersionDateString: v];
    [Settings checkDefaults]; // what was the reason to put this here???
    [self setColOptotypeFore: [CPColor blackColor]];  [self setColOptotypeBack: [CPColor whiteColor]];
    var s = @"Current key test settings: " + [Settings distanceInCM] +" cm distance, ";
    s += [Settings nAlternatives] + " Landolt alternatives, " + [Settings nTrials] + " trials";
    [self setKeyTestSettingsString: s];

    rewardImageView = [[CPImageView alloc] initWithFrame: CGRectMake(100, 0, 600, 600)];
    [[[self window] contentView] addSubview: rewardImageView];
    rewardsController = [[RewardsController alloc] initWithView: rewardImageView];
    aucklandOptotypesController = [[AucklandOptotypesController alloc] initWithButton2Enable: buttVAAuck];
    sound = [[Sound alloc] init];
    for (var i = 0; i < (Math.round([[CPDate date] timeIntervalSince1970]) % 33); i++); // ranomising the pseudorandom sequence
}


/*[[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"APXMyPropertyIamInterestedInKey" options:NSKeyValueObservingOptionNew
 context:NULL];
 // KVO handler
 -(void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)anObject change:(NSDictionary *)aChange context:(void *)aContext {}*/
- (void) defaultsDidChange: (CPNotification) aNotification {console.info("defaultsDidChange");}


- (void) buttonImageAdjust: (CPButton) b {
    var rect1 = [b frame];
    [b setFrame: CGRectMake(rect1.origin.x, rect1.origin.y - (rect1.size.width - 16) / 2, rect1.size.width, rect1.size.width)];
}


- (void) closeAllPanels {
    for (var i = 0; i < allPanels.length; i++)  [allPanels[i] close];
}


- (id) auckImageArray {
    return [aucklandOptotypesController imageArray];
}


- (void) runFractController { //console.info("AppController>runFractController");
    if ([Settings notCalibrated]) {
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


- (void) runFractController2 { //console.info("AppController>runFractController2  ");
    [self closeAllPanels];
    if ([Settings responseInfoAtStart]) {
        switch (testID) {
            case kTestIDLett: [responseinfoPanelVAL makeKeyAndOrderFront: self]; break;
            case kTestIDC:
                switch ([Settings nAlternatives]) {
                   case 4: [responseinfoPanelVA4C makeKeyAndOrderFront: self];  break;
                   case 8: [responseinfoPanelVA8C makeKeyAndOrderFront: self];  break;
                }  break;
            case kTestIDE:
                [responseinfoPanelVAE makeKeyAndOrderFront: self];  break;
            case kTestIDAuck:
                [responseinfoPanelVAAuck makeKeyAndOrderFront: self];  break;
            case kTestIDVernier:
                [responseinfoPanelVAVernier makeKeyAndOrderFront: self];  break;
            case kTestContrastC:
                [responseinfoPanelVAVernier makeKeyAndOrderFront: self];  break;
        }
    } else {
        [self runFractController2_actionOK: nil];
    }
}


- (IBAction) runFractController2_actionOK: (id) sender { //console.info("AppController>runFractController2_actionOK");
    [self closeAllPanels];  [currentFractController release];
    currentFractController = [[allTestControllers[testID] alloc] initWithWindow: fractControllerWindow parent: self];
    [currentFractController setSound: sound];
}
- (IBAction) runFractController2_actionCancel: (id) sender { //console.info("AppController>runFractController2_actionCancel");
    [self closeAllPanels];
}


- (void) runEnd { //console.info("AppController>runEnd");
    [currentFractController release];  currentFractController = nil;
    if (([Settings rewardPicturesWhenDone]) && (!runAborted)) [rewardsController drawRandom];
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("AppController>drawStimulusInRect");
    [currentFractController drawStimulusInRect: dirtyRect forView: fractView];
}


/*- (void) controlTextDidChange: (CPNotification) notification { //console.info(@"controlTextDidChange: stringValue == %@", [[notification object] stringValue]);[Settings calculateMaxPossibleDecimalAcuity];
}*/
- (void) controlTextDidEndEditing: (CPNotification) notification { //console.info(@"controlTextDidChange: stringValue == %@", [[notification object] stringValue]);
    [Settings calculateMaxPossibleDecimalAcuity];
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
            [self  buttonDoAcuityAuck_action: nil];  break;
        case "V":
            [self  buttonDoAcuityVernier_action: nil];  break;
        case "KK":
            [self  buttonDoContrastC_action: nil];  break;
        default:
            [super keyDown: theEvent];  break;
    }
}


- (IBAction) buttonFullScreen_action: (id) sender { //console.info("AppController>buttonFullScreen");
    var full = [Misc isFullScreen];
    if (full) {
        [Misc fullScreenOn: NO];
        [[[self window] contentView] setFrameOrigin: CGPointMake(0, 0)];
    } else {
        [Misc fullScreenOn: YES];
        var point = CGPointMake((window.screen.width - 800) / 2, (window.screen.height - 600) / 2);
        [[[self window] contentView] setFrameOrigin: point];
    }
}


- (IBAction) buttonDoAcuityLetters_action: (id) sender { //console.info("AppController>buttonDoAcuityLetters_action");
    testID = kTestIDLett;    [self runFractController];
}
- (IBAction) buttonDoAcuityLandolt_action: (id) sender { //console.info("AppController>buttonDoAcuity_action");
    testID = kTestIDC;    [self runFractController];
}
- (IBAction) buttonDoAcuityE_action: (id) sender { //console.info("AppController>buttonDoAcuityE_action");
    testID = kTestIDE;    [self runFractController];
}
- (IBAction) buttonDoAcuityAuck_action: (id) sender { //console.info("AppController>buttonDoAcuityA_action");
    testID = kTestIDAuck;    [self runFractController];
}
- (IBAction) buttonDoAcuityVernier_action: (id) sender { //console.info("AppController>buttonDoAcuityE_action");
    testID = kTestIDVernier;    [self runFractController];
}
- (IBAction) buttonDoContrastC_action: (id) sender { //console.info("AppController>buttonDoContrastC_action");
    testID = kTestContrastC;    [self runFractController];
}


- (IBAction) buttonSettings_action: (id) sender { //console.info("AppController>buttonSettings");
    [Settings checkDefaults];  [settingsPanel makeKeyAndOrderFront: self];
    if (settingsNeedNewDefaults) {
        settingsNeedNewDefaults = NO;
        [[CPAlert alertWithMessageText: "WARNING" defaultButton: "OK" alternateButton: nil otherButton: nil
             informativeTextWithFormat: "\r\rAll settings were set to their default values.\r\rIf some fields are empty, please reload this browser window once, then all values will be current.\r\r"] runModal];
    }
}
- (IBAction) buttonSettingsClose_action: (id) sender { //console.info("AppController>buttonSettingsClose");
    [Settings checkDefaults];  [settingsPanel close];
}
- (IBAction) buttonSettingsDefaults_action: (id) sender { //console.info("AppController>buttonSettingsDefaults");
    [self setColOptotypeFore: [CPColor blackColor]];  [self setColOptotypeBack: [CPColor whiteColor]];
    [Settings setDefaults];  [settingsPanel close];  [Settings setDefaults];  [settingsPanel makeKeyAndOrderFront: self];
    [[settingsPanel contentView] setNeedsDisplay: YES];
}


- (IBAction) buttonHelp_action: (id) sender { //console.info("AppController>buttonHelp_action");
    [helpPanel makeKeyAndOrderFront: self];
}
- (IBAction) buttonHelpGetManual_action: (id) sender {
    window.open("https://michaelbach.de/fract/media/FrACT3_Manual.pdf");
}
- (IBAction) buttonHelpClose_action: (id) sender { //console.info("AppController>buttonHelpClose_action");
    [helpPanel close];
}


- (IBAction) buttonAbout_action: (id) sender { //console.info("AppController>buttonAbout_action");
    [aboutPanel makeKeyAndOrderFront: self];
}
- (IBAction) buttonAboutWebsiteMB_action: (id) sender {
    window.open("https://michaelbach.de");
}
- (IBAction) buttonAboutWebsiteFractSite_action: (id) sender {
    window.open("https://michaelbach.de/fract/");
}
- (IBAction) buttonAboutWebsiteFractBlog_action: (id) sender {
    window.open("https://michaelbach.de/fract/blog.html");
}
- (IBAction) buttonAboutClose_action: (id) sender { //console.info("AppController>buttonAboutClose_action");
    [aboutPanel close];
}


- (IBAction) buttonExit_action: (id) sender { //console.info("AppController>buttonExit_action");
    if ([Misc isFullScreen]) {
        [Misc fullScreenOn: NO];
    }
    [[self window] close];  [CPApp terminate: nil];
}


@end
