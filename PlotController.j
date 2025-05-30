/*
This file is part of FrACT10, a vision test battery.
Copyright © 2025 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 PlotController.j

*/

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "AppController.j"
@import "MDB2plot.j"

/**
 For plotting test history
 Created by Bach on 2025-05-29
 */



@implementation PlotView: CPView {
    CPString firstTime;
}

/**
 This is called by IB
 */
- (id) initWithFrame: (CGRect) theFrame { //CPLog("PlotView>initWithFrame");
    self = [super initWithFrame: theFrame];
    //console.info([CPGraphicsContext currentContext]);
    return self;
}


- (void)drawRect: (CGRect) dirtyRect { //CPLog("PlotView>drawRect");
    if (firstTime !== "notFirstTime") {
        firstTime = "notFirstTime";  return;
    }
    const cgc_ = [[CPGraphicsContext currentContext] graphicsPort]
    if (cgc_ === null) return;
    const r = CGRectMake(0, 0, parseInt(cgc_.canvas.style.width), parseInt(cgc_.canvas.style.height));
    //console.info("r: ", r);
    [MDB2plot p2initWithCGC: cgc_];
    [MDB2plot p2vprtFromRect: r];
    [MDB2plot p2wndwX0: 0 y0: 0 x1: 10 y1: 10];
    [MDB2plot p2lineX0: 0 y0: 0 x1: 10 y1: 10];
}


- (void) t1 { CPLog("PlotView>test");
    [self display];
}

@end


@implementation PlotController: CPWindowController {
    @outlet CPPanel plotPanel;
    @outlet PlotView plotView1;
    CPString s;
}


- (IBAction) buttonPlotOpen_action: (id) sender { //CPLog("AboutAndHelpController>buttonPlotOpen_action");
    [plotPanel setMovable: NO];
    [Misc centerWindowOrPanel: plotPanel];
    [plotPanel makeKeyAndOrderFront: self];
//    [plotView1 t1];
}


- (IBAction) buttonPlotClose_action: (id) sender { //CPLog("AboutAndHelpController>buttonPlotClose_action");
    [plotPanel close];
}



@end
