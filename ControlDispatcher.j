/*
This file is part of FrACT10, a vision test battery.
Copyright © 2024 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

ControlDispatcher.j

Dispatcher for HTML communication messages to control FrACT

*/


@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Globals.j"


@implementation ControlDispatcher: CPObject {
    CPString m1, m2, m3;
}


// often used, shortens code
+ (void) post: (CPString) aNotificationName object: (id) anObject {
    [[gAppController window] orderFront: self]; // otherwise we would crash here
    [[CPNotificationCenter defaultCenter] postNotificationName: aNotificationName object: anObject];
    gHTMLMessage1 = m1;  gHTMLMessage2 = m2;  gHTMLMessage3 = m3;
}


// often used, shortens code
+ (void) logProblem: (id) data {
    console.log("FrACT10 received unexpected message.data: ", data);
    window.parent.postMessage({data: data, success: false}, "*");
    gSendHTMLMessageOnRunDone = NO;
}


/**
 set up listener to dispatch control messages to FrACT10 when embedded as iframe
 */
+ (void) init { //console.info("ControlDispatcher>init")
    window.addEventListener("message", (e) => { //console.info("In addEventListener>message: ", e);
        if (e.source !== window.parent) return; // only from embedding window
        if (e.origin !== window.location.origin) return; // same
        if (Object.keys(e.data).length !== 3) return; // avoid overruns from possibly malicious senders
        m1 = e.data.m1, m2 = e.data.m2, m3 = e.data.m3;
        if ((m1 === undefined) || (m1.length > 50))  return;
        if ((m2 === undefined) || (m2.length > 50))  return;
        if ((m3 === undefined) || (m3.length > 50))  return;
        switch (m1) {
            case "Settings":
                switch(m2) {
                    case "Presets":
                        [self post: "applyPresetNamed" object: m3];
                        break;
                    default:
                        [self logProblem: e.data];
                }
                break;
            case "Run":
                gSendHTMLMessageOnRunDone = YES;// need to switch off if parsing below fails
                switch(m2) {
                    case "TestNumber":
                        const allowedNumbers = Array.from({length: 10}, (v, k) => k + 1); //constructs [1,2…]
                        if ((allowedNumbers.includes(m3))) {
                            [self post: "notificationRunFractControllerTest" object: m3];
                        } else {
                            [self logProblem: e.data];
                        }
                        break;
                    case "Acuity":
                        switch(m3) {
                            case "Letters":
                                [self post: "notificationRunFractControllerTest" object: kTestAcuityLett];
                                break;
                            case "LandoltC":
                                [self post: "notificationRunFractControllerTest" object: kTestAcuityC];
                                break;
                            case "TumblingE":
                                [self post: "notificationRunFractControllerTest" object: kTestAcuityE];
                                break;
                            default:
                                [self logProblem: e.data];
                        }
                        break;
                    case "Contrast":
                        switch(m3) {
                            case "Letters":
                                [self post: "notificationRunFractControllerTest" object: kTestContrastLett];
                                break;
                            case "LandoltC":
                                [self post: "notificationRunFractControllerTest" object: kTestContrastC];
                                break;
                            case "TumblingE":
                                [self post: "notificationRunFractControllerTest" object: kTestContrastE];
                                break;
                            default:
                                [self logProblem: e.data];
                        }
                        break;
                    default:
                        [self logProblem: e.data];
                }
                break;
            default:
                [self logProblem: e.data];
        }
    });
}


@end
