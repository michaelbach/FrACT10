#import <Cocoa/Cocoa.h>
#import "xcc_general_include.h"

@interface AppController : HierarchyController

@property (assign) IBOutlet NSWindow* fractControllerWindow;
@property (assign) IBOutlet NSColorWell* checkContrastWeberField1;
@property (assign) IBOutlet NSColorWell* checkContrastWeberField2;
@property (assign) IBOutlet NSPanel* settingsPanel;
@property (assign) IBOutlet NSPanel* aboutPanel;
@property (assign) IBOutlet NSPanel* helpPanel;
@property (assign) IBOutlet NSPanel* responseinfoPanelAcuityL;
@property (assign) IBOutlet NSPanel* responseinfoPanelAcuity4C;
@property (assign) IBOutlet NSPanel* responseinfoPanelAcuity8C;
@property (assign) IBOutlet NSPanel* responseinfoPanelAcuityE;
@property (assign) IBOutlet NSPanel* responseinfoPanelAcuityTAO;
@property (assign) IBOutlet NSPanel* responseinfoPanelAcuityVernier;
@property (assign) IBOutlet NSPanel* responseinfoPanelContrastLett;
@property (assign) IBOutlet NSPanel* responseinfoPanelContrastC;
@property (assign) IBOutlet NSPanel* responseinfoPanelContrastE;
@property (assign) IBOutlet NSPanel* responseinfoPanelContrastG;
@property (assign) IBOutlet NSPanel* responseinfoPanelAcuityLineByLine;
@property (assign) IBOutlet NSPanel* resultDetailsPanel;
@property (assign) IBOutlet NSPanel* creditcardPanel;
@property (assign) IBOutlet MDBButton* buttonAcuityLett;
@property (assign) IBOutlet MDBButton* buttonAcuityC;
@property (assign) IBOutlet MDBButton* buttonAcuityE;
@property (assign) IBOutlet MDBButton* buttonAcuityTAO;
@property (assign) IBOutlet MDBButton* buttonAcuityVernier;
@property (assign) IBOutlet MDBButton* buttCntLett;
@property (assign) IBOutlet MDBButton* buttCntC;
@property (assign) IBOutlet MDBButton* buttCntE;
@property (assign) IBOutlet MDBButton* buttCntG;
@property (assign) IBOutlet MDBButton* buttonAcuityLineByLine;
@property (assign) IBOutlet NSButton* buttonExport;
@property (assign) IBOutlet NSButton* buttonExit;
@property (assign) IBOutlet NSButton* radioButtonAcuityBW;
@property (assign) IBOutlet NSButton* radioButtonAcuityColor;
@property (assign) IBOutlet GammaView* gammaView;
@property (assign) IBOutlet WebView* aboutWebView1;
@property (assign) IBOutlet WebView* aboutWebView2;
@property (assign) IBOutlet WebView* helpWebView1;
@property (assign) IBOutlet WebView* helpWebView2;
@property (assign) IBOutlet WebView* helpWebView3;
@property (assign) IBOutlet WebView* helpWebView4;
@property (assign) IBOutlet NSImageView* creditcardImageView;

- (IBAction)runFractController2_actionOK:(id)sender;
- (IBAction)runFractController2_actionCancel:(id)sender;
- (IBAction)resultDetails_action:(id)sender;
- (IBAction)runtimeError_action:(id)sender;
- (IBAction)buttonFullScreen_action:(id)sender;
- (IBAction)buttonDoTest_action:(id)sender;
- (IBAction)buttonSettings_action:(id)sender;
- (IBAction)buttonSettingsClose_action:(id)sender;
- (IBAction)buttonSettingsTestSound_action:(id)sender;
- (IBAction)buttonSettingsContrastAcuityMaxMin_action:(id)sender;
- (IBAction)popupPreset_action:(id)sender;
- (IBAction)buttonHelp_action:(id)sender;
- (IBAction)buttonHelpClose_action:(id)sender;
- (IBAction)buttonAbout_action:(id)sender;
- (IBAction)buttonAboutClose_action:(id)sender;
- (IBAction)buttonGotoFractSite_action:(id)sender;
- (IBAction)buttonGotoFractBlog_action:(id)sender;
- (IBAction)buttonGotoFractManual_action:(id)sender;
- (IBAction)buttonGotoFractChecklist_action:(id)sender;
- (IBAction)buttonGotoAcuityCheats_action:(id)sender;
- (IBAction)buttonExport_action:(id)sender;
- (IBAction)buttonDoExit_action:(id)sender;
- (IBAction)radioButtonsAcuityBwOrColor_action:(id)sender;
- (IBAction)buttonCheckContrast_action:(id)sender;
- (IBAction)buttonGamma_action:(id)sender;
- (IBAction)buttonCreditcardUse_action:(id)sender;
- (IBAction)buttonCreditcardPlusMinus_action:(id)sender;
- (IBAction)buttonCreditcardClosePanel_action:(id)sender;

@end
