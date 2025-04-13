/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2025 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 AboutAndHelpController.j

 Created by mb on 2025-02-02.
 */


/**
 AboutAndHelpController

 Dealing with with the Help/About panels
 */

@implementation AboutAndHelpController : CPWindowController {
    @outlet CPPanel aboutPanel, helpPanel;
    @outlet CPWebView aboutWebView1, aboutWebView2, helpWebView1, helpWebView2, helpWebView3, helpWebView4;
    CPString s;
}


- (IBAction) buttonAbout_action: (id) sender {
    [aboutPanel setMovable: NO];
    [Misc centerWindowOrPanel: aboutPanel];
    [self populateAboutPanelView1];
    [aboutPanel makeKeyAndOrderFront: self];
}


- (IBAction) buttonAboutClose_action: (id) sender { //console.info("AboutAndHelpController>buttonAboutClose_action");
    [aboutPanel close];
}


- (IBAction) buttonHelp_action: (id) sender { //console.info("AboutAndHelpController>buttonHelp_action");
    [helpPanel setMovable: NO];
    [Misc centerWindowOrPanel: helpPanel];
    [self populateHelpPanel];
    [helpPanel makeKeyAndOrderFront: self];
}


- (IBAction) buttonHelpClose_action: (id) sender { //console.info("AppController>buttonHelpClose_action");
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
    if (tag == 6) { // check if this local file exists
        if (![Misc existsUrl: url]) return;
    }
    window.open(url, "_blank");
}


- (void) oneWebView: (CPWebView) theView htmlString: (CPString) htmlString {
    [theView setBackgroundColor: [CPColor colorWithWhite: 0.99 alpha: 1]];
    [theView setScrollMode: CPWebViewScrollNone];
    s = "<html lang='en'><head><meta charset='UTF-8'> <style>body{ font-family:sans-serif; font-size:13px; line-height:1.2em; padding: 8px; margin:0; border:1px solid black; border-radius:5px;} h4{margin-bottom:4px; padding:0;} ul{margin-top:0;}li{margin-bottom:0.3em;}</style></head><body>";
    s += htmlString + "</body></html>";
    [theView loadHTMLString: s];
}


- (void) populateAboutPanelView1 {
    s = "<h2 align='center'>FrACT<sub>10</sub></h2>";
    s += "Freiburg Visual Acuity and Contrast Test 10, ";
    s += "<a href='https://michaelbach.de/fract/index.html#anchorWhatsNew' target='_blank'>" + "Vs " + gVersionStringOfFract + "</a>, <br>";
    s += "release date " + gVersionDateOfFrACT + ".<br><br>";
    s += "Semi-automatic assessment of visual acuities following ISO, and contrast thresholds.<br><br>Optotypes: Sloan letters, Landolt C, Tumbling E, TAO, gratings, and hyperacuity targets.<br><br>Acuity results in LogMAR, decimal or Snellen notation; ∃ export options plus 2-way html messaging for data management systems.<br><br>With ‘Best PEST’, antialiasing and dithering."
    [self oneWebView: aboutWebView1 htmlString: s];

    s = "©1993–" + [gVersionDateOfFrACT substringWithRange: CPMakeRange(0, 4)];
    s += "<br>Prof. Michael Bach, Eye Center, Medical Center<br>"
    s += "Faculty of Medicine, University of Freiburg, Germany<br>";
    s += "<a href='https://michaelbach.de' target='_blank'>https://michaelbach.de</a><br>";
    s += "<a href='mailto:bach@uni-freiburg.de'>bach@uni-freiburg.de</a><br><br>";
    s += "<a href='https://michaelbach.de/fract/' target='_blank'>FrACT₁₀ homepage</a><br><br>";
    s += "Sources: <a href='https://github.com/michaelbach/FrACT10/#fract' target='_blank'>GitHub repository</a>, <a href='https://github.com/michaelbach/FrACT10/commits' target='_blank'>Commit history</a><br>"
    s += "Frameworks/Libraries used:<br>";
    const cappucinoVersion = [[[CPBundle bundleWithIdentifier: "com.280n.Foundation"] infoDictionary] objectForKey:@"CPBundleVersion"]; // initialised in AppController
    s += "<a href='https://michaelbach.de/ot/-misc/cappFrameworks/index.html' target='_blank'>Cappuccino " + cappucinoVersion + "</a>,&nbsp; ";
    s += "«simplestatistics.org».<br>";
    //s += "<a href='https://nodejs.org/' target='_blank'>Node.js,</a><br>";
    //s += "<a href='https://www.electronjs.org' target='_blank'>Electron</a>, <a href='https://www.electron.build' target='_blank'>electron-builder</a>";
    s += "Some sounds from <a href='https://pixabay.com/' target='_blank'>pixabay</a>."
    s += "<br><br><br>";
    s += "FrACT₁₀ places “cookies” on your computer:<br>";
    s += "– Two for saving the web app and its settings across sessions<br>";
    s += "– A third contains the last results for exporting.";
    s += "<br><br><br>";
    s += "This is free software, there is no warranty for anything: <a href='https://github.com/michaelbach/FrACT10/blob/main/LICENSE.md' target='_blank'>GNU GPL licence</a>. ";
    s += "It is not formally certified for medical purposes."

    [self oneWebView: aboutWebView2 htmlString: s];
}


- (void) populateHelpPanel {
    s = "<h4>General</h4> <ul><li><b>Make use of the cool tool tips</b> by hovering with the mouse over the pertinent interface element.</li> <li>Be sure to calibrate (→Settings) for correct results. Preferences are automatically saved.</li> <li>This is a forced choice test – even when your observers indicate that they cannot see a thing, encourage them to make their best guess; the software knows about the lucky guesses. Motivate them to react swiftly, lengthy squinting at the optotype is not helpful.</li> <li>Quality results require knowledge in sensory testing. At least observe the <a href='https://michaelbach.de/fract/checklist.html' target='_blank'>Checklist</a>.</li> <li>The <a href='https://michaelbach.de/fract/manual.html' target='_blank'>Manual</a> should cover everything, also don't hesitate to contact me: <a href='mailto:bach@uni-freiburg.de'>bach@uni-freiburg.de</a>.</li> <li>Speed up operation with <a href='https://michaelbach.de/fract/manual.html#anchor_Shortcuts' target='_blank'>Shortcuts</a>.</li></ul>";
    [self oneWebView: helpWebView1 htmlString: s];
    
    s = "<h4>Visual Acuity</h4> <ul><li>Results in logMAR, decimal acuity or Snellen format</li><li>Limited screen resolution (pixel size) may clip high acuity</ul>";
    [self oneWebView: helpWebView2 htmlString: s];

    s = "<h4>Contrast Sensitivity</h4> <ul><li>Results in logCS(Weber)</li><li>CS = contrast sensitivity</ul>";
    [self oneWebView: helpWebView3 htmlString: s];

    s = "<h4>References</h4> <ul><li><a href='https://dx.doi.org/10.1007/s00417-024-06638-z' target='_blank'>Bach M (2024)</a> Freiburg Vision Test (FrACT): Optimal number of trials? Graefes Arch [<a href='https://link.springer.com/content/pdf/10.1007/s00417-024-06638-z.pdf' target='_blank'>PDF</a>]</li><li><a href='http://dx.doi.org/10.1371/journal.pone.0147803' target='_blank'>Bach M, Schäfer K (2016)</a> Visual Acuity Testing: Feedback affects neither outcome nor reproducibility, but leaves participants happier. PLoS One 11:e0147803</li><li><a href='http://dx.doi.org/10.1007/s00417-006-0474-4' target='_blank'>Bach M (2007)</a> The Freiburg Visual Acuity Test-variability unchanged by post-hoc re-analysis. Graefes Arch Clin Exp Ophthalmol 245:965–971 [<a href='http://rdcu.be/p2Ju' target='_blank'>→PDF</a>]</li><li>Schulze-Bonsel K, Feltgen N, Burau H, Hansen LL, Bach M (2006) Visual acuities “Hand Motion” and “Counting Fingers” can be quantified using the Freiburg Visual Acuity Test. Invest Ophthalmol Vis Sci 47:1236–1240</li><li>Neargarder SA, Stone ER, Cronin-Golomb A, Oross S 3rd (2003) The impact of acuity on performance of four clinical measures of contrast sensitivity in Alzheimer's disease. J Gerontol B Psychol Sci Soc Sci. 58:54–62</li><li>Wesemann W (2002) [Visual acuity measured via the Freiburg visual acuity test (FVT), Bailey Lovie chart and Landolt Ring chart] Klin Monatsbl Augenheilkd 219:660–667</li><li>Loumann KL (2003) Visual acuity testing in diabetic subjects: the decimal progression chart versus the Freiburg visual acuity test. Graefes Arch Clin Exp Ophthalmol</li><li>Bach M, Kommerell G (1998) Sehschärfebestimmung nach Europäischer Norm – wissenschaftliche Grundlagen und Möglichkeiten der automatischen Messung. Klin Mbl Augenheilk 212:190–195 </li><li>Bach M (1997) Anti-aliasing and dithering in the ‘Freiburg Visual Acuity Test’. Spatial Vision 11:85–89 </li><li><a href= 'http://dx.doi.org/10.1097/00006324-199601000-00008 ' target= '_blank ' >Bach M (1996)</a> The Freiburg Visual Acuity test – automatic measurement of visual acuity. Optom Vis Sci 73:49–53  [<a href= 'http://www.ipexhealth.com/wp-content/uploads/2018/01/FrACT-Landolt-Vision.pdf ' target= '_blank ' >→PDF</a>]</li> <li>Lieberman HR, Pentland AP (1982) Microcomputer-based estimation of psychophysical thresholds: The Best PEST. Behavior Research Methods & Instrumentation 14:21–25</li></ul>";
    [self oneWebView: helpWebView4 htmlString: s];
}


@end
