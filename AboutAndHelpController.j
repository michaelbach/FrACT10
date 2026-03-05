/*
 This file is part of FrACT10, a vision test battery.
 © 2025 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 AboutAndHelpController.j

 Created by mb on 2025-02-02.
 */


/**
 AboutAndHelpController

 Dealing with the Help/About panels programmatically rather than Xib-based
 */

@import <AppKit/CPWindowController.j>
@import <AppKit/CPPanel.j>
@import <AppKit/CPWebView.j>
@import <AppKit/CPButton.j>
@import "Globals.j"
@import "Misc.j"


const left = 18;
const buttonsWidth = 130, buttonsHeight = 23;
const buttonsOkWidth = 48;
const buttonsY = (kFractHeight - buttonsHeight - 18);
let SharedAboutAndHelpController = nil;


@implementation AboutAndHelpController: CPWindowController {
    CPPanel aboutPanel;
    CPPanel helpPanel;
    CPWebView aboutWebView1, aboutWebView2;
    CPWebView helpWebView1, helpWebView2, helpWebView3, helpWebView4;
    CPView contentView;
}


//not really necessary, because `AboutAndHelpController` is instantiated in the XIB
+ (AboutAndHelpController) sharedController { console.info("AboutAndHelpController>sharedController")
    if (!SharedAboutAndHelpController) {
        SharedAboutAndHelpController = [[AboutAndHelpController alloc] init];
    }
    return SharedAboutAndHelpController;
}


- (id) init { //console.info("AboutAndHelpController>init")
    self = [super init];
    if (self) {
        [self createAboutPanel];  [self createHelpPanel];
    }
    return self;
}


//all buttons are very similar
- (CPButton) addButtonWithTitle: (CPString) title frame: (CGRect) frame tag: (int) tag tooltip: (CPString) tooltip selector: (SEL) sel {
    const b = [CPButton buttonWithTitle: title];
    [b setFrame: frame];  [b setTarget: self];  [b setAction: sel];
    if (tag >= 0) [b setTag: tag];
    if (tooltip !== "") [b setToolTip: tooltip];
    [contentView addSubview: b];
    return b;
}


- (void) createAboutPanel {
    aboutPanel = [[CPPanel alloc] initWithContentRect: CGRectMake(167, 107, kFractWidth, kFractHeight) styleMask: CPTitledWindowMask | CPClosableWindowMask];
    contentView = [aboutPanel contentView];
    [aboutPanel setTitle: "FrACT₁₀ – About"];

    const viewY = 20, viewWidth = 364, viewHeight = 420;
    aboutWebView1 = [[CPWebView alloc] initWithFrame: CGRectMake(left, viewY, viewWidth, viewHeight)];
    [contentView addSubview: aboutWebView1];
    aboutWebView2 = [[CPWebView alloc] initWithFrame: CGRectMake(414, viewY, viewWidth, viewHeight)];
    [contentView addSubview: aboutWebView2];

    [self addButtonWithTitle: "→FrACT home" frame: CGRectMake(left, buttonsY, buttonsWidth, buttonsHeight) tag: 1 tooltip: "Opens the FrACT home page in your browser." selector: @selector(buttonGotoURLgivenTag_action:)]
    [self addButtonWithTitle: "→Manual" frame: CGRectMake(274, buttonsY, buttonsWidth, buttonsHeight) tag: 3 tooltip: "Opens the manual in your browser." selector: @selector(buttonGotoURLgivenTag_action:)]
    [self addButtonWithTitle: "→FrACT blog" frame: CGRectMake(508, buttonsY, buttonsWidth, buttonsHeight) tag: 2 tooltip: "" selector: @selector(buttonGotoURLgivenTag_action:)]
    const btnOk = [self addButtonWithTitle: "OK" frame: CGRectMake(732, buttonsY, buttonsOkWidth, buttonsHeight) tag: -1 tooltip: "" selector: @selector(buttonAboutClose_action:)]
    [btnOk setKeyEquivalent: crlf];
}


- (void) createHelpPanel {
    helpPanel = [[CPPanel alloc] initWithContentRect: CGRectMake(167, 107, kFractWidth, kFractHeight) styleMask: CPTitledWindowMask | CPClosableWindowMask];
    contentView = [helpPanel contentView];
    [helpPanel setTitle: "FrACT₁₀ – Help"];

    const view13w = 764, view23y = 221, view23h = 96;
    helpWebView1 = [[CPWebView alloc] initWithFrame: CGRectMake(left, 12, view13w, 202)];
    [contentView addSubview: helpWebView1];
    helpWebView2 = [[CPWebView alloc] initWithFrame: CGRectMake(left, view23y, 388, view23h)];
    [contentView addSubview: helpWebView2];
    helpWebView3 = [[CPWebView alloc] initWithFrame: CGRectMake(416, view23y, 366, view23h)];
    [contentView addSubview: helpWebView3];
    helpWebView4 = [[CPWebView alloc] initWithFrame: CGRectMake(left, 324, view13w, 224)];
    [contentView addSubview: helpWebView4];

    [self addButtonWithTitle: "→Manual" frame: CGRectMake(19, buttonsY, buttonsWidth, buttonsHeight) tag: 3 tooltip: "Opens the manual in your browser"  selector: @selector(buttonGotoURLgivenTag_action:)]
    [self addButtonWithTitle: "→Checklist" frame: CGRectMake(204, buttonsY, buttonsWidth, buttonsHeight) tag: 4 tooltip: "Opens the checklist in your browser"  selector: @selector(buttonGotoURLgivenTag_action:)]
    [self addButtonWithTitle: "→Acuity Formats" frame: CGRectMake(383, buttonsY, buttonsWidth, buttonsHeight) tag: 5 tooltip: "Opens the “Acuity Cheat Sheet in your browser"  selector: @selector(buttonGotoURLgivenTag_action:)]
    [self addButtonWithTitle: "→Check Exported" frame: CGRectMake(561, buttonsY, buttonsWidth, buttonsHeight) tag: 6 tooltip: "Opens a website which will read and display the test results exported by default"  selector: @selector(buttonGotoURLgivenTag_action:)]
    const btnOk = [self addButtonWithTitle: "OK" frame: CGRectMake(738, buttonsY, buttonsOkWidth, buttonsHeight) tag: -1 tooltip: ""  selector: @selector(buttonHelpClose_action:)];
    [btnOk setKeyEquivalent: crlf];
}


- (IBAction) buttonAbout_action: (id) sender {
    [aboutPanel setMovable: NO];  [Misc centerWindowOrPanel: aboutPanel];
    [self populateAboutPanelViews];
    [aboutPanel makeKeyAndOrderFront: self];
}


- (IBAction) buttonAboutClose_action: (id) sender {
    [aboutPanel close];
}


- (IBAction) buttonHelp_action: (id) sender {
    [helpPanel setMovable: NO];  [Misc centerWindowOrPanel: helpPanel];
    [self populateHelpPanel];
    [helpPanel makeKeyAndOrderFront: self];
}


- (IBAction) buttonHelpClose_action: (id) sender {
    [helpPanel close];
}


- (IBAction) buttonGotoURLgivenTag_action: (id) sender {
    const tag = [sender tag];
    const tagsURLs = {1: "https://michaelbach.de/fract/",
        2: "https://michaelbach.de/fract/blog.html",
        3: "https://michaelbach.de/fract/manual.html",
        4: "https://michaelbach.de/fract/checklist.html",
        5: "https://michaelbach.de/sci/acuity.html",
        6: "../readResultString.html"};
    const url = tagsURLs[tag];
    if (url === undefined) return;
    if (tag === 6) { //check if this local file exists
        if (![Misc existsUrl: url]) return;
    }
    window.open(url, "_blank");
}


- (void) oneWebView: (CPWebView) theView htmlString: (CPString) htmlString {
    [theView setBackgroundColor: [CPColor colorWithWhite: 0.99 alpha: 1]];
    [theView setScrollMode: CPWebViewScrollNone];
    let s = "<html lang='en'><head><meta charset='UTF-8'> <style>body{ font-family:sans-serif; font-size:13px; line-height:1.2em; padding: 8px; margin:0; border:1px solid black; border-radius:5px;} h4{margin-bottom:4px; padding:0;} ul{margin-top:0;}li{margin-bottom:0.3em;}</style></head><body>";
    s += htmlString + "</body></html>";
    [theView loadHTMLString: s];
}


- (void) populateAboutPanelViews {
    let s = "<h2 align='center'>FrACT₁₀</h2>";
    s += "Freiburg Visual Acuity and Contrast Test 10, ";
    s += "<a href='https://michaelbach.de/fract/index.html#anchorWhatsNew' target='_blank'>" + "Vs " + gVersionStringOfFract + "</a>, <br>";
    s += "release date " + gVersionDateOfFrACT + ".<br><br>";
    s += "Semi-automatic assessment of visual acuities following ISO, and contrast thresholds.<br><br>Optotypes: Sloan letters, Landolt rings, Tumbling E, TAO, gratings, and hyperacuity targets.<br><br>Acuity results in LogMAR, decimal or Snellen notation; several export options plus 2-way HTML messaging for data management systems.<br><br>With <a href='https://doi.org/10.3758/BF03204398' target='_blank'>‘Best PEST’</a>, <a href='https://dx.doi.org/10.1163/156856897x00087' target='_blank'>anti-aliasing and dithering</a>.<br><br>"
    s += "Includes <a href='https://michaelbach.de/sci/stim/balm/index.html' target='_blank'>BaLM as BaLM₁₀</a>";
    [self oneWebView: aboutWebView1 htmlString: s];


    s = "©1993–" + [gVersionDateOfFrACT substringWithRange: CPMakeRange(0, 4)];
     s += "<br>Prof. Michael Bach, Eye Center, Medical Center<br>"
    s += "Faculty of Medicine, University of Freiburg, Germany<br>";
    s += "<a href='https://michaelbach.de' target='_blank'>https://michaelbach.de</a>,&nbsp; ";
    s += "<a href='mailto:bach@uni-freiburg.de'>bach@uni-freiburg.de</a><br><br>";
    s += "<a href='https://michaelbach.de/fract/' target='_blank'>FrACT₁₀ homepage</a><br><br>";

    s += "Sources: <a href='https://github.com/michaelbach/FrACT10/#fract' target='_blank'>GitHub repository</a>, <a href='https://github.com/michaelbach/FrACT10/commits' target='_blank'>Commit history</a>.<br>"
    s += "Frameworks/Libraries used (thanks!):<br>";
    const cappucinoVersion = [[[CPBundle bundleWithIdentifier: "com.280n.Foundation"] infoDictionary] objectForKey:@"CPBundleVersion"]; //initialised in AppController
    s += "&nbsp; &nbsp; <a href='https://michaelbach.de/ot/-misc/cappFrameworks/index.html' target='_blank'>Cappuccino " + cappucinoVersion + "</a>,&nbsp; ";
    s += "<a href='https://simple-statistics.github.io' target='_blank'>simple-statistics</a>,&nbsp; <a href='https://github.com/parallax/jsPDF' target='_blank'>jsPDF</a>,<br>&nbsp; &nbsp; <a href='https://github.com/simonbengtsson/jsPDF-AutoTable' target='_blank'>jsPDF-AutoTable</a>,&nbsp; <a href='https://github.com/eligrey/FileSaver.js' target='_blank'>FileSaver.js</a>,&nbsp; ";
    s += "<a href='https://github.com/davidshimjs/qrcodejs' target='_blank'>qrcodejs,</a><br>";
    s += "&nbsp; &nbsp; Some sounds from <a href='https://pixabay.com/' target='_blank'>pixabay</a>."
    s += "<br><br>";

    s += "FrACT₁₀ uses cookies on your computer:<ol>";
    s += "<li>To save the settings across sessions</li>";
    s += "<li>To save the progressive web app itself for use w/o internet</li>";
    s += "<li>The last results for access outside FrACT</li>";
    s += "<li>Only when you use the remote response box: <a href='https://console.firebase.google.com' target='_blank'>Google's&nbsp;Firebase</a>.</li></ol>";
    s += "This is free software (<a href='https://github.com/michaelbach/FrACT10/blob/main/LICENSE.md' target='_blank'>GNU GPL licence</a>).";
    s += " There is no warranty for anything, it is not EU-certified for medical purposes."

    [self oneWebView: aboutWebView2 htmlString: s];
}


- (void) populateHelpPanel {
    let s = "<h4>General</h4> <ul><li><b>Make use of the cool tool tips</b> by hovering with the mouse over the pertinent interface element.</li>";
    s += "<li>Be sure to calibrate (→Settings) for correct results. Preferences are automatically saved.</li>";
    s += "<li>This is a forced choice test – even when your observers indicate that they cannot see a thing, encourage them to make their best guess; the software knows about the lucky guesses. Motivate them to react swiftly, lengthy squinting at the optotype is not helpful.</li>";
    s += "<li>Quality results require knowledge in sensory testing. At least observe the <a href='https://michaelbach.de/fract/checklist.html' target='_blank'>Checklist</a>.</li>";
    s += "<li>The <a href='https://michaelbach.de/fract/manual.html' target='_blank'>Manual</a> should cover everything, also don't hesitate to contact me: <a href='mailto:bach@uni-freiburg.de'>bach@uni-freiburg.de</a>.</li>";
    s += "<li>Speed up operation with <a href='https://michaelbach.de/fract/manual.html#anchor_Shortcuts' target='_blank'>Shortcuts</a>.</li></ul>";
    [self oneWebView: helpWebView1 htmlString: s];

    s = "<h4>Visual Acuity</h4> <ul><li>Results in logMAR, decimal acuity or Snellen format</li>";
    s += "<li>Limited screen resolution (pixel size) may clip high acuity</ul>";
    [self oneWebView: helpWebView2 htmlString: s];

    s = "<h4>Contrast Sensitivity</h4> <ul><li>Results in logCS(Weber)</li>";
    s += "<li>CS = contrast sensitivity</ul>";
    [self oneWebView: helpWebView3 htmlString: s];

    s = "<h4>References</h4> <ul><li><a href='https://dx.doi.org/10.1007/s00417-024-06638-z' target='_blank'>Bach M (2024)</a> Freiburg Vision Test (FrACT): Optimal number of trials? Graefes Arch [<a href='https://link.springer.com/content/pdf/10.1007/s00417-024-06638-z.pdf' target='_blank'>PDF</a>]</li>";
    s += "<li><a href='http://dx.doi.org/10.1371/journal.pone.0147803' target='_blank'>Bach M, Schäfer K (2016)</a> Visual Acuity Testing: Feedback affects neither outcome nor reproducibility, but leaves participants happier. PLoS One 11:e0147803</li>";
    s += "<li><a href='http://dx.doi.org/10.1007/s00417-006-0474-4' target='_blank'>Bach M (2007)</a> The Freiburg Visual Acuity Test-variability unchanged by post-hoc re-analysis. Graefes Arch Clin Exp Ophthalmol 245:965–971 [<a href='http://rdcu.be/p2Ju' target='_blank'>→PDF</a>]</li>";
    s += "<li>Schulze-Bonsel K, Feltgen N, Burau H, Hansen LL, Bach M (2006) Visual acuities “Hand Motion” and “Counting Fingers” can be quantified using the Freiburg Visual Acuity Test. Invest Ophthalmol Vis Sci 47:1236–1240</li>";
    s += "<li>Neargarder SA, Stone ER, Cronin-Golomb A, Oross S 3rd (2003) The impact of acuity on performance of four clinical measures of contrast sensitivity in Alzheimer's disease. J Gerontol B Psychol Sci Soc Sci. 58:54–62</li>";
    s += "<li>Wesemann W (2002) [Visual acuity measured via the Freiburg visual acuity test (FVT), Bailey Lovie chart and Landolt Ring chart] Klin Monatsbl Augenheilkd 219:660–667</li>";
    s += "<li>Loumann KL (2003) Visual acuity testing in diabetic subjects: the decimal progression chart versus the Freiburg visual acuity test. Graefes Arch Clin Exp Ophthalmol</li>";
    s += "<li>Bach M, Kommerell G (1998) Sehschärfebestimmung nach Europäischer Norm – wissenschaftliche Grundlagen und Möglichkeiten der automatischen Messung. Klin Mbl Augenheilk 212:190–195</li> <li>Bach M (1997) Anti-aliasing and dithering in the ‘Freiburg Visual Acuity Test’. Spatial Vision 11:85–89</li>";
    s += "<li><a href= 'http://dx.doi.org/10.1097/00006324-199601000-00008 ' target= '_blank'>Bach M (1996)</a> The Freiburg Visual Acuity test – automatic measurement of visual acuity. Optom Vis Sci 73:49–53 [<a href='https://sci-hub.vg/10.1097/00006324-199601000-00008' target='_blank'>PDF</a>]</li>";
    s += "<li>Lieberman HR, Pentland AP (1982) Microcomputer-based estimation of psychophysical thresholds: The Best PEST. Behavior Research Methods & Instrumentation 14:21–25</li></ul>";
    [self oneWebView: helpWebView4 htmlString: s];
}


@end
