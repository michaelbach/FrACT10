/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, michael.bach@uni-freiburg.de, <https://michaelbach.de>

PopulateAboutPanel.j

Created by Bach on 2022-01-29.

Populates the About panel with appropriate text using HTML
 
*/

/**
 * PopulateAboutPanel
 *
 * Populates the "About" and "Help" panels
 *
 * */

 
@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>


@implementation PopulateAboutPanel: CPObject {
    CPString s;
}


+ (void) oneWebView: (CPWebView) theView htmlString: (CPString) htmlString {
    [theView setBackgroundColor: [CPColor colorWithWhite: 0.99 alpha: 1]];
    [theView setScrollMode: CPWebViewScrollNone];
    s = "<html lang='en'><head><meta charset='UTF-8'> <style>body{ font-family:sans-serif; font-size:13px; line-height:1.2em; padding: 8px; margin:0; border:1px solid black; border-radius:5px;} h4{margin-bottom:4px; padding:0;} ul{margin-top:0;}li{margin-bottom:0.3em;}</style></head><body>";
    s += htmlString + "</body></html>";
    [theView loadHTMLString: s];
}


+ (void) populateAboutPanelView1: (WebView) aboutWebView1 view2: (WebView) aboutWebView2 { //console.info("PopulateAboutPanel>populateAboutPanel");

    s = "<h2 align='center'>FrACT<sub>10</sub></h2>";
    s += "Freiburg Visual Acuity and Contrast Test 10,<br>Vs " + kVersionStringOfFract + ",&nbsp; release date " + kVersionDateOfFrACT + ". <br><br>";
    s += "Interactive assessment of visual acuities following DIN/ISO; also can assess contrast sensitivity.<br><br>Optotypes: Sloan letters, Landolt C, Tumbling E, and TAO.<br><br>Acuity results in decimal, LogMAR or Snellen notation.<br><br>With ‘Best PEST’ and antialiasing."
    [self oneWebView: aboutWebView1 htmlString: s];

    s = "©1993–" + [kVersionDateOfFrACT substringWithRange: CPMakeRange(0, 4)];
    s += "<br><br>Prof. Michael Bach<br>";
    s += "University of Freiburg, Germany<br>";
    s += "<a href='https://michaelbach.de' target='_blank'>https://michaelbach.de</a><br>";
    s += "<a href='mailto:bach@uni-freiburg.de'>bach@uni-freiburg.de</a><br><br>";
    s += "<a href='https://michaelbach.de/fract/' target='_blank'>FrACT₁₀ homepage</a><br><br>";
    s += "Sources: <a href='https://github.com/michaelbach/FrACT10/#fract' target='_blank'>GitHub repository</a>, <a href='https://github.com/michaelbach/FrACT10/commits' target='_blank'>commit history</a><br><br>"
    s += "Frameworks/Libraries used:<br>";
    s += "<a href='https://michaelbach.de/ot/-misc/cappFrameworks/index.html' target='_blank'>Cappuccino " + gCappucinoVersionString + "</a>,&nbsp; ";
    s += "<a href='https://simplestatistics.org' target='_blank'>Simple Statistics</a>, <a href='https://nodejs.org/' target='_blank'>Node.js,</a><br>";
    s += "<a href='https://www.electronjs.org' target='_blank'>Electron</a>, <a href='https://www.electron.build' target='_blank'>electron-builder</a><br><br><br>";
    s += "This is free software, there is no warranty for anything (<a href='https://github.com/michaelbach/FrACT10/blob/main/LICENSE.md' target='_blank'>GNU GPL licence</a>); it is not certified for medical purposes."
    [self oneWebView: aboutWebView2 htmlString: s];
}


+ (void) populateHelpPanelView1: (WebView) v1 v2: (WebView) v2 v3: (WebView) v3 v4: (WebView) v4 {
    s = "<h4>General</h4> <ul><li><b>Make use of the tool tips!</b> (By hovering with the mouse over the pertinent interface element)</li> <li> Be sure to set the calibration bar width and the observation distance in Preferences correctly. Preferences are automatically saved</li> <li> This is a forced choice test – even when your subjects indicate that they cannot see a thing, encourages them to make their best guess; the software knows about the lucky guesses. Encourage your subjects to react swiftly, lengthy squinting at the optotype is not helpful</li> <li> Quality results requite knowledge in sensory testing. At least observe the Checklist (button below)</li> <li> The Manual (button below) should cover everything. For open questions contact me <a href='mailto:bach@uni-freiburg.de'>bach@uni-freiburg.de</a></li></ul>";
    [self oneWebView: v1 htmlString: s];
    
    s = "<h4>Visual Acuity</h4> <ul><li>Results in logMAR, decimal acuity or Snellen format</li><li>Limited screen resolution (pixel size) may clip high acuity</ul>";
    [self oneWebView: v2 htmlString: s];
    
    s = "<h4>Contrast Sensitivity</h4> <ul><li>Results in logCS(Weber)</li><li>CS: “contrast sensitivity”</ul>";
    [self oneWebView: v3 htmlString: s];

    s = "<h4>References</h4> <ul><li>Bach M, Schäfer K (2016) Visual acuity testing: feedback affects neither outcome nor reproducibility, but leaves participants happier. PLOS ONE 11(1):e0147803</li><li>Bach M (2007) The Freiburg Visual Acuity Test – Variability unchanged by post-hoc re-analysis. Graefe’s Arch Clin Exp Ophthalmol 245:965–971</li><li>Schulze-Bonsel K, Feltgen N, Burau H, Hansen LL, Bach M (2006) Visual acuities “Hand Motion” and “Counting Fingers” can be quantified using the Freiburg Visual Acuity Test. Invest Ophthalmol Vis Sci 47:1236–1240</li><li>Neargarder SA, Stone ER, Cronin-Golomb A, Oross S 3rd (2003) The impact of acuity on performance of four clinical measures of contrast sensitivity in Alzheimer's disease. J Gerontol B Psychol Sci Soc Sci. 58:54–62</li><li>Wesemann W (2002) [Visual acuity measured via the Freiburg visual acuity test (FVT), Bailey Lovie chart and Landolt Ring chart] Klin Monatsbl Augenheilkd 219:660–667</li><li>Loumann KL (2003) Visual acuity testing in diabetic subjects: the decimal progression chart versus the Freiburg visual acuity test. Graefes Arch Clin Exp Ophthalmol</li><li>Bach M, Kommerell G (1998) Sehschärfebestimmung nach Europäischer Norm – wissenschaftliche Grundlagen und Möglichkeiten der automatischen Messung. Klin Mbl Augenheilk 212:190–195 </li><li>Bach M (1997) Anti-aliasing and dithering in the ‘Freiburg Visual Acuity Test’. Spatial Vision 11:85–89 </li><li>Bach M (1996) The “Freiburg Visual Acuity Test” – Automatic measurement of visual acuity. Optometry & Vision Sci 73:49–53 </li><li>Lieberman HR, Pentland AP (1982) Microcomputer-based estimation of psychophysical thresholds: The Best PEST. Behavior Research Methods & Instrumentation 14:21–25</li></ul>";
    [self oneWebView: v4 htmlString: s];
}

@end

