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
 * Populates the "About Panel"
 *
 * */

 
@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>


@implementation PopulateAboutPanel: CPObject {
    CPString s;
}


+ (void) oneWebView: (CPWebView) theView htmlString: (CPString) htmlString {
    [theView setBackgroundColor: [CPColor colorWithWhite: 0.95 alpha: 1]];
    [theView setScrollMode:CPWebViewScrollNone];
    s = "<!DOCTYPE html><html lang='en'><head><meta charset='UTF-8'> <style>body{font-family:sans-serif;line-height:1.2em}</style></head><body style='width:97%;'>";
    s += htmlString + "<br>&nbsp;</body></html>"; // need trailing line, otherwise cut (bug)
    [theView loadHTMLString: s];
}


+ (void) populateAboutPanelView1: (WebView) aboutWebView1 view2: (WebView) aboutWebView2 { //console.info("PopulateAboutPanel>populateAboutPanel");

    s = "<h2 align='center'>FrACT<sub>10</sub></h2>";
    s += "Freiburg Visual Acuity and Contrast Test 10, " + kVersionStringOfFract + ". <br><br>";
    s += "Interactive measurement of visual acuities following DIN/ISO; also can assess contrast sensitivity.<br><br>Optotypes: Sloan letters, Landolt C, Tumbling E, and TAO.<br><br>Acuity results in decimal, LogMAR or Snellen notation.<br><br>With ‘Best PEST’ and antialiasing."
    [self oneWebView: aboutWebView1 htmlString: s];

    s = "©1993–2022<br><br>Prof. Michael Bach<br>";
    s += "Eye Center, University Clinical Center<br>";
    s += "Killianstr. 5, 79106 Freiburg, Germany.<br>";
    s += "<a href='https://michaelbach.de' target='_blank'>https://michaelbach.de</a><br>";
    s += "<a href='mailto:bach@uni-freiburg.de'>bach@uni-freiburg.de</a><br><br>";
    s += "Source code: <a href='https://github.com/michaelbach/FrACT10/' target='_blank'>GitHub repository</a><br><br>";
    s += "Frameworks/Libraries used:<br>";
    s += "<a href='https://www.cappuccino.dev' target='_blank'>Cappuccino</a>, <a href='https://simplestatistics.org' target='_blank'>Simple Statistics</a><br><br><br>";
    s += "This is free software. There is no warranty for anything.";
    [self oneWebView: aboutWebView2 htmlString: s];
}


@end
