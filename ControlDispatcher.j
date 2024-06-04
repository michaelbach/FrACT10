/*
This file is part of FrACT10, a vision test battery.
Copyright © 2024 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

ControlDispatcher.j

Dispatcher for HTML communication messages to control FrACT

*/


@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>


@implementation ControlDispatcher: CPObject {
    id _eventData;
}


// often used, shortens code
+ (void) post: (CPString) aNotificationName object: (id) anObject {
    [[CPNotificationCenter defaultCenter] postNotificationName: aNotificationName object: anObject];
}


// often used, shortens code
+ (void) logProblem {
    console.log("FrACT10 received unexpected message.data: ", _eventData);
}


/**
 set up listener to dispatch control messages to FrACT10 when embedded as iframe
 */
+ (void) init { //console.info("ControlDispatcher>init")
    window.addEventListener("message", (e) => { //console.info("In addEventListener>message: ", e.data);
        if (e.origin !== window.location.origin) return; // only from embedding window
        if (e.data.length > 100) return; // avoid overruns from malicious senders
        if (Object.keys(e.data).length > 100) return; // also if data is an object
        _eventData = e.data;
        const m1 = e.data.m1, m2 = e.data.m2, m3 = e.data.m3;
        switch (m1) {
            case "Settings":
                switch(m2) {
                    case "Presets":
                        [self post: "applyPresetNamed" object: m3];
                        break;
                    default:
                        [self logProblem];
                }
                break;
            case "Run":
                switch(m2) {
                    case "TestNumber":
                        const allowedNumbers = Array.from({length: 10}, (v, k) => k + 1); //constructs [1,2…]
                        if ((allowedNumbers.includes(m3)))
                            [self post: "notificationRunFractControllerTest" object: m3];
                        else
                            [self logProblem];
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
                                [self logProblem];
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
                                [self logProblem];
                        }
                        break;
                    default:
                        [self logProblem];
                }
                break;
            default:
                [self logProblem];
        }
    });
}


@end
