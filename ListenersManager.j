/*
 This file is part of FrACT10, a vision test battery.
 © 2026 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 ListenersManager.j

 */


@import <Foundation/Foundation.j>


/**
 2026-08-28 This class manages window listeneners for errors etc.
 */

const msg2 = "\r\rIf it recurs, please notify bach@uni-freiburg.de, ideally relating the message above, e.g. via a screenshot.\rI will look into it and endeavour to provide a fix ASAP.\r\rOn “Close”, the window will reload and you can retry.";


@implementation ListenersManager: CPObject {
}


+ (void) initialize {
    [super initialize];
}


+ (void) setup { //console.info("ListenersManager>setup")
    window.addEventListener('error', function(e) {
        //console.error("Error details:", e);
        const stack = (e.error && e.error.stack) ? e.error.stack : "(no stack)";
        const details = e.message
            //+ "\rFile: " + e.filename + "Line: " + e.lineno + ", Column: " + e.colno
            + "\rStack: " + stack.substring(0, 140) + "…"; //140 chars is enough
        alert("An error occured, I'm sorry. Details:\r\r" + details + msg2);
        window.location.reload(NO);
    });
    window.addEventListener('unhandledrejection', function(e) {
        //console.error("Unhandled promise rejection:", e.reason);
        alert("An error occured, I'm sorry: Unhandled promise rejection:" + e.reason + msg2);
        window.location.reload(NO);
    });
    window.addEventListener("orientationchange", function(e) {
        if ([Settings respondsToMobileOrientation]) {
            //alert("Orientation change, now "+e.target.screen.orientation.angle+"°.\r\rOn “Close”, the window will reload to fit.");
            window.location.reload(NO);
        }
    });
    window.addEventListener("fullscreenchange", (event) => { //called _after_ the change
        //console.info("isFullScreen: ", [Misc isFullScreen]);
        if (![Misc isFullScreen]) { //so it was full before, possibly we're in a run
            if (currentFractController !== null) { //need to end run when leaving fullscreen
                [currentFractController runEnd]; //because the <esc> was consumed
            }
        }
    });
    window.addEventListener("resize", (event) => {
        if ([Misc isInRun]) return; //don't do ⇙this while "inRun"
        [Misc centerWindowOrPanel: [[self window] contentView]];

        /*        //https://ua.hexalys.com
         console.info("scale", window.visualViewport.scale);
         console.info("window.devicePixelRatio", window.devicePixelRatio);
         console.info("window.outerWidth / window.innerWidth", window.outerWidth / window.innerWidth);*/

    });
}


@end
