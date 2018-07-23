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
@import "FractControllerAcuityC.j"
@import "FractControllerAcuityLetters.j"
@import "FractControllerAcuityE.j"
@import "FractControllerContrastC.j"


/*document.onload = function(){
    //alert("*");
}
window.ondeviceorientation = function(event) {
    [setAngleAlpha: Math.round(event.alpha)];
    [setAngleAlpha: Math.round(event.beta)];
    [setAngleAlpha: Math.round(event.gamma)];
}*/


@implementation AppController : HierarchyController {
    @outlet CPWindow fractControllerWindow;
    @outlet CPPanel settgsPanel, aboutPanel, helpPanel;
    FractController currentFractController;
    float angleAlpha @accessors, angleBeta @accessors, angleGamma @accessors;
}


- (void)awakeFromCib { //console.log("AppController>awakeFromCib");
    [[self window] setFullPlatformWindow: YES];
}


- (void)applicationDidFinishLaunching:(CPNotification)aNotification {//console.log("AppController>applicationDidFinishLaunching");
    var v = [Settgs versionNumber] + " · " + [Settgs versionDate]
    [[self window] setTitle: "FrACT10"]; [self setVersionDateString: v];
    [settgsPanel setFrameOrigin: CGPointMake(0, 0)];
    [aboutPanel setFrameOrigin: CGPointMake(0, 0)];
    kOptoTypeIndexAcuityC = 0;  kOptoTypeIndexAcuityLetters = 1;// constants
//    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsDidChange:) name:CPUserDefaultsDidChangeNotification object:nil];
    [Settgs checkDefaults];
    if ([Settgs notCalibrated]) alert("»FrACT«\n\nNOTE: Calibration is mandatory for valid results\n(see distance & ruler in 'Settings').");
    [self setColOptotypeFore: [CPColor blackColor]];  [self setColOptotypeBack: [CPColor whiteColor]];
    var s = @"Current key test settings: " + [Settgs distanceInCM] +" cm distance, ";
    s += [Settgs nAlternatives] + " alternatives, " + [Settgs nTrials] + " trials";
    [self setKeyTestSettingsString: s];
}


/*[[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"APXMyPropertyIamInterestedInKey" options:NSKeyValueObservingOptionNew
 context:NULL];
 // KVO handler
 -(void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)anObject change:(NSDictionary *)aChange context:(void *)aContext {}*/
- (void) defaultsDidChange: (CPNotification) aNotification {console.log("defaultsDidChange");}


function requestFullScreen(element) {console.log("requestFullScreen");// Supports most browsers and their versions
    var requestMethod = element.requestFullScreen || element.webkitRequestFullScreen || element.mozRequestFullScreen || element.msRequestFullScreen;
    if (requestMethod) { // Native full screen
        requestMethod.call(element);
    } else if (typeof window.ActiveXObject !== "undefined") { // Older IE
        var wscript = new ActiveXObject("WScript.Shell");
        if (wscript !== null) {wscript.SendKeys("{F11}");}
    }
}


- (void) runFractControllerOfClass: (Class) theClass { //console.log("AppController>runFractControllerOfClass");
    [settgsPanel close];  [aboutPanel close];
    [currentFractController release];
    currentFractController = [[theClass alloc] initWithWindow: fractControllerWindow parent: self];
}


- (void) runEnd {//console.log("AppController>runEnd");
    [currentFractController release];
    currentFractController = nil;
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView {//console.log("AppController>drawStimulusInRect");
    [currentFractController drawStimulusInRect: dirtyRect forView: fractView];
}


- (IBAction) buttonFullScreen_action: (id) sender {console.log("AppController>buttonFullScreen");
    requestFullScreen(document.body);
}


- (IBAction) buttonDoAcuityLandolt_action: (id) sender {//console.log("AppController>buttonDoAcuity_action");
    [self runFractControllerOfClass: [FractControllerAcuityC class]];
}


- (IBAction) buttonDoAcuityLetters_action: (id) sender {//console.log("AppController>buttonDoAcuityLetters_action");
    [self runFractControllerOfClass: [FractControllerAcuityLetters class]];
}

    
- (IBAction) buttonDoAcuityE_action: (id) sender {//console.log("AppController>buttonDoAcuityE_action");
    [self runFractControllerOfClass: [FractControllerAcuityE class]];
}


- (IBAction) buttonDoContrastC_action: (id) sender {//console.log("AppController>buttonDoContrastC_action");
    [self runFractControllerOfClass: [FractControllerContrastC class]];
}


- (IBAction) buttonSettings_action: (id) sender {//console.log("AppController>buttonSettings");
    [Settgs checkDefaults];  [settgsPanel makeKeyAndOrderFront: self];
    [[settgsPanel contentView] setNeedsDisplay: YES];
}
- (IBAction) buttonSettingsClose_action: (id) sender {//console.log("AppController>buttonSettingsClose");
    [Settgs checkDefaults];  [settgsPanel close];
}
- (IBAction) buttonSettingsDefaults_action: (id) sender {//console.log("AppController>buttonSettingsDefaults");
    [self setColOptotypeFore: [CPColor blackColor]];  [self setColOptotypeBack: [CPColor whiteColor]];
    [Settgs setDefaults];  [settgsPanel close];  [Settgs setDefaults];  [settgsPanel makeKeyAndOrderFront: self];
    [[settgsPanel contentView] setNeedsDisplay: YES];
}
- (IBAction) buttonSettingsUpdate_action: (id) sender {//console.log("AppController>buttonSettingsDefaults");
    [settgsPanel close];  [Settgs checkDefaults];  [settgsPanel makeKeyAndOrderFront: self];
    [[settgsPanel contentView] setNeedsDisplay: YES];
}


- (IBAction) buttonAbout_action: (id) sender {//console.log("AppController>buttonAbout_action");
    [aboutPanel makeKeyAndOrderFront: self];
}
- (IBAction) buttonAboutWebsite_action: (id) sender {//console.log("AppController>buttonAboutClose_action");
    window.open("http://michaelbach.de");
}
- (IBAction) buttonAboutClose_action: (id) sender {//console.log("AppController>buttonAboutClose_action");
    [aboutPanel close];
}


- (IBAction) buttonExit_action: (id) sender {//console.log("AppController>buttonExit_action");
    [[self window] close];  [CPApp terminate: nil];
}


@end
