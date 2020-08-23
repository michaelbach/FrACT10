#import <Cocoa/Cocoa.h>
#import "xcc_general_include.h"

@interface AppController : HierarchyController

@property (assign) IBOutlet NSWindow* fractControllerWindow;
@property (assign) IBOutlet NSPanel* settingsPanel;
@property (assign) IBOutlet NSPanel* aboutPanel;
@property (assign) IBOutlet NSPanel* helpPanel;
@property (assign) IBOutlet NSPanel* responseinfoPanelVAL;
@property (assign) IBOutlet NSPanel* responseinfoPanelVA4C;
@property (assign) IBOutlet NSPanel* responseinfoPanelVA8C;
@property (assign) IBOutlet NSPanel* responseinfoPanelVAE;
@property (assign) IBOutlet NSPanel* responseinfoPanelVATAO;
@property (assign) IBOutlet NSPanel* responseinfoPanelVAVernier;
@property (assign) IBOutlet NSPanel* responseinfoPanelCntLett;
@property (assign) IBOutlet NSPanel* responseinfoPanelCntC;
@property (assign) IBOutlet NSButton* buttVALett;
@property (assign) IBOutlet NSButton* buttVAC;
@property (assign) IBOutlet NSButton* buttVAE;
@property (assign) IBOutlet NSButton* buttVATAO;
@property (assign) IBOutlet NSButton* buttVAVernier;
@property (assign) IBOutlet NSButton* buttCntLett;
@property (assign) IBOutlet NSButton* buttonExport;

- (IBAction)runFractController2_actionOK:(id)sender;
- (IBAction)runFractController2_actionCancel:(id)sender;
- (IBAction)buttonFullScreen_action:(id)sender;
- (IBAction)buttonDoAcuityLetters_action:(id)sender;
- (IBAction)buttonDoAcuityLandolt_action:(id)sender;
- (IBAction)buttonDoAcuityE_action:(id)sender;
- (IBAction)buttonDoAcuityTAO_action:(id)sender;
- (IBAction)buttonDoAcuityVernier_action:(id)sender;
- (IBAction)buttonDoContrastLett_action:(id)sender;
- (IBAction)buttonDoContrastC_action:(id)sender;
- (IBAction)buttonSettings_action:(id)sender;
- (IBAction)buttonSettingsClose_action:(id)sender;
- (IBAction)buttonSettingsDefaults_action:(id)sender;
- (IBAction)buttonHelp_action:(id)sender;
- (IBAction)buttonHelpGetManual_action:(id)sender;
- (IBAction)buttonHelpCheats_action:(id)sender;
- (IBAction)buttonHelpClose_action:(id)sender;
- (IBAction)buttonAbout_action:(id)sender;
- (IBAction)buttonAboutWebsiteMB_action:(id)sender;
- (IBAction)buttonAboutWebsiteFractSite_action:(id)sender;
- (IBAction)buttonAboutWebsiteFractBlog_action:(id)sender;
- (IBAction)buttonAboutClose_action:(id)sender;
- (IBAction)buttonExport_action:(id)sender;
- (IBAction)buttonExit_action:(id)sender;

@end
