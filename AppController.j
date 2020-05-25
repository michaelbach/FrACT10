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

/*window.ondeviceorientation = function(event) {
    [setAngleAlpha: Math.round(event.alpha)]; [setAngleAlpha: Math.round(event.beta)]; [setAngleAlpha: Math.round(event.gamma)];
}*/


@implementation AppController : HierarchyController {
    @outlet CPWindow fractControllerWindow;
    @outlet CPPanel settingsPanel, aboutPanel, helpPanel, responseinfoPanelVAL, responseinfoPanelVA4C, responseinfoPanelVA8C, responseinfoPanelVAE, responseinfoPanelVAAuck, responseinfoPanelVAVernier;
    @outlet CPButton buttVALett, buttVAC, buttVAE, buttVAAuck, buttVAVernier;
    @outlet CPImageView rewardImageView;
    CPImage rewardsController;
    RewardsController rewardsController;
    AucklandOptotypesController aucklandOptotypesController;
    FractController currentFractController;
    //float angleAlpha @accessors, angleBeta @accessors, angleGamma @accessors;
    int testID, kTestIDLett, kTestIDC, kTestIDE, kTestIDAuck, kTestIDVernier;
    BOOL settingsNeedNewDefaults;
    BOOL runAborted @accessors;
//    id auckImages;
//    int nAuckImagesLoaded;
}


- (void)awakeFromCib { //console.log("AppController>awakeFromCib");
    settingsNeedNewDefaults = [Settings needNewDefaults];
    [Settings checkDefaults]; //important to do this early, otherwise the updates don't populate the settings panel – DOES NOT HELP, unfortunately
    [[self window] setFullPlatformWindow: YES];
    [CPMenu setMenuBarVisible:NO];
}


- (void) applicationDidFinishLaunching: (CPNotification)aNotification { //console.log("AppController>applicationDidFinishLaunching");
    [self buttonImageAdjust: buttVALett];  [self buttonImageAdjust: buttVAC];
    [self buttonImageAdjust: buttVAE];  [self buttonImageAdjust: buttVAAuck];
    [self buttonImageAdjust: buttVAVernier];

    var v = [Settings versionNumber] + "·" + [Settings versionDate]
    [[self window] setTitle: "FrACT10"]; [self setVersionDateString: v];
    //[settingsPanel setFrameOrigin: CGPointMake(0, 0)];
    
    kTestIDLett = 0;  kTestIDC = 1; kTestIDE = 2; kTestIDAuck = 3; kTestIDVernier = 4; // constants

    kOptoTypeIndexAcuityC = 0;  kOptoTypeIndexAcuityLetters = 1;// constants
//    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsDidChange:) name:CPUserDefaultsDidChangeNotification object:nil];
    [Settings checkDefaults];
    
    [self setColOptotypeFore: [CPColor blackColor]];  [self setColOptotypeBack: [CPColor whiteColor]];
    var s = @"Current key test settings: " + [Settings distanceInCM] +" cm distance, ";
    s += [Settings nAlternatives] + " Landolt alternatives, " + [Settings nTrials] + " trials";
    [self setKeyTestSettingsString: s];

    rewardsController = [[RewardsController alloc] initWithView: rewardImageView];
    aucklandOptotypesController = [[AucklandOptotypesController alloc] initWithButton2Enable: buttVAAuck];
}


/*[[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"APXMyPropertyIamInterestedInKey" options:NSKeyValueObservingOptionNew
 context:NULL];
 // KVO handler
 -(void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)anObject change:(NSDictionary *)aChange context:(void *)aContext {}*/
- (void) defaultsDidChange: (CPNotification) aNotification {console.log("defaultsDidChange");}


- (void) buttonImageAdjust: (CPButton) b {
    var rect1 = [b frame];
    [b setFrame: CGRectMake(rect1.origin.x, rect1.origin.y - (rect1.size.width - 16) / 2, rect1.size.width, rect1.size.width)];
}


- (void) closeAllPanels {
    [settingsPanel close];  [aboutPanel close];  [helpPanel close]; [responseinfoPanelVAL close];
    [responseinfoPanelVA4C close];  [responseinfoPanelVA8C close]; [responseinfoPanelVAE close];
    [responseinfoPanelVAAuck close];  [responseinfoPanelVAVernier close];
}


- (void) runFractController { //console.log("AppController>runFractController");
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


-(void) runFractController2 { //console.log("AppController>runFractController2  ");
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
        }
    } else {
        [self runFractController2_actionOK: nil];
    }
}


- (IBAction) runFractController2_actionOK: (id) sender { //console.log("AppController>buttonFullScreen");
    [self closeAllPanels];  [currentFractController release];
    switch (testID) {
        case kTestIDLett:
            currentFractController = [[FractControllerVAL alloc] initWithWindow: fractControllerWindow parent: self];
            break;
        case kTestIDC:
            currentFractController = [[FractControllerVAC alloc] initWithWindow: fractControllerWindow parent: self];
            break;
        case kTestIDE:
            currentFractController = [[FractControllerVAE alloc] initWithWindow: fractControllerWindow parent: self];
            break;
        case kTestIDAuck:
            currentFractController = [[FractControllerVAAuck alloc] initWithWindow: fractControllerWindow parent: self];
            [currentFractController setAuckImages: [aucklandOptotypesController imageArray]];
            break;
        case kTestIDVernier:
            currentFractController = [[FractControllerVAVernier alloc] initWithWindow: fractControllerWindow parent: self];
            break;
    }
}


- (IBAction) runFractController2_actionCancel: (id) sender { //console.log("AppController>buttonFullScreen");
    [self closeAllPanels];
}


- (void) runEnd { //console.log("AppController>runEnd");
    [currentFractController release];  currentFractController = nil;
    if (([Settings rewardPicturesWhenDone]) && (!runAborted)) [rewardsController drawRandom];
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.log("AppController>drawStimulusInRect");
    [currentFractController drawStimulusInRect: dirtyRect forView: fractView];
}


- (IBAction) buttonFullScreen_action: (id) sender { //console.log("AppController>buttonFullScreen");
    [Misc fullScreenOn: ![Misc isFullScreen]];
}


- (IBAction) buttonDoAcuityLetters_action: (id) sender { //console.log("AppController>buttonDoAcuityLetters_action");
    testID = kTestIDLett;    [self runFractController];
}
- (IBAction) buttonDoAcuityLandolt_action: (id) sender { //console.log("AppController>buttonDoAcuity_action");
    testID = kTestIDC;    [self runFractController];
}
- (IBAction) buttonDoAcuityE_action: (id) sender { //console.log("AppController>buttonDoAcuityE_action");
    testID = kTestIDE;    [self runFractController];
}
- (IBAction) buttonDoAcuityAuck_action: (id) sender { //console.log("AppController>buttonDoAcuityA_action");
    testID = kTestIDAuck;    [self runFractController];
}
- (IBAction) buttonDoAcuityVernier_action: (id) sender { //console.log("AppController>buttonDoAcuityE_action");
    testID = kTestIDVernier;    [self runFractController];
}


- (IBAction) buttonSettings_action: (id) sender { //console.log("AppController>buttonSettings");
    [settingsPanel close];  [settingsPanel release];
    [Settings checkDefaults];  [settingsPanel makeKeyAndOrderFront: self];
    [[settingsPanel contentView] setNeedsDisplay: YES];
    if (settingsNeedNewDefaults) {
        settingsNeedNewDefaults = NO;
        [[CPAlert alertWithMessageText: "WARNING" defaultButton: "OK" alternateButton: nil
            otherButton: nil
             informativeTextWithFormat: "\r\rAll settings were set to their default values.\r\rIf some fields are empty, please reload this browser window once, then all values will be current.\r\r"] runModal];
    }
}
- (IBAction) buttonSettingsClose_action: (id) sender { //console.log("AppController>buttonSettingsClose");
    [Settings checkDefaults];  [settingsPanel close];
}
- (IBAction) buttonSettingsDefaults_action: (id) sender { //console.log("AppController>buttonSettingsDefaults");
    [self setColOptotypeFore: [CPColor blackColor]];  [self setColOptotypeBack: [CPColor whiteColor]];
    [Settings setDefaults];  [settingsPanel close];  [Settings setDefaults];  [settingsPanel makeKeyAndOrderFront: self];
    [[settingsPanel contentView] setNeedsDisplay: YES];
}


- (IBAction) buttonHelp_action: (id) sender { console.log("AppController>buttonHelp_actionsss");
    [helpPanel makeKeyAndOrderFront: self];
}
- (IBAction) buttonHelpGetManual_action: (id) sender {
    window.open("https://michaelbach.de/fract/media/FrACT3_Manual.pdf");
}
- (IBAction) buttonHelpClose_action: (id) sender { //console.log("AppController>buttonHelpClose_action");
    [helpPanel close];
}


- (IBAction) buttonAbout_action: (id) sender { //console.log("AppController>buttonAbout_action");
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
- (IBAction) buttonAboutClose_action: (id) sender { //console.log("AppController>buttonAboutClose_action");
    [aboutPanel close];
}


- (IBAction) buttonExit_action: (id) sender { //console.log("AppController>buttonExit_action");
    if ([Misc isFullScreen]) {
        [Misc fullScreenOn: NO];
    }
    [[self window] close];  [CPApp terminate: nil];
}


@end
