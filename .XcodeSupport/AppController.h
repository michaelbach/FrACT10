#import <Cocoa/Cocoa.h>
#import "xcc_general_include.h"

@interface AppController : HierarchyController

@property (assign) IBOutlet NSWindow* fractControllerWindow;
@property (assign) IBOutlet NSPanel* settgsPanel;
@property (assign) IBOutlet NSPanel* aboutPanel;
@property (assign) IBOutlet NSPanel* helpPanel;

- (IBAction)buttonFullScreen_action:(id)sender;
- (IBAction)buttonDoAcuityLandolt_action:(id)sender;
- (IBAction)buttonDoAcuityLetters_action:(id)sender;
- (IBAction)buttonDoAcuityE_action:(id)sender;
- (IBAction)buttonSettings_action:(id)sender;
- (IBAction)buttonSettingsClose_action:(id)sender;
- (IBAction)buttonSettingsDefaults_action:(id)sender;
- (IBAction)buttonSettingsUpdate_action:(id)sender;
- (IBAction)buttonAbout_action:(id)sender;
- (IBAction)buttonAboutWebsite_action:(id)sender;
- (IBAction)buttonAboutClose_action:(id)sender;
- (IBAction)buttonExit_action:(id)sender;

@end
