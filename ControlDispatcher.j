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
    float m3AsNumber;
    BOOL _sendHTMLMessageOnRunDone;
    id _appController;
}


+ (void) setSettingNamed: (CPString) s {
    if (isNaN(m3AsNumber)) {
        [self _logProblemM123];  return;
    }
    const sCapped = s.charAt(0).toUpperCase() + s.slice(1);
    let setter = CPSelectorFromString("set" + sCapped + ":");
    [Settings performSelector: setter withObject: m3AsNumber];
    [Settings allNotCheckButSet: NO]; // check whether we were in range
    const m3Now = [Settings performSelector: CPSelectorFromString(s)]; // read back
    [self post2parentM1: m1 m2: m2 m3: m3Now success: m3AsNumber===m3Now];
}


/**
 set up listener to dispatch control messages to FrACT10 when embedded as iframe
 */
+ (void) initWithAppController: (id) appController { //console.info("ControlDispatcher>initWithAppController")
    _sendHTMLMessageOnRunDone = NO;
    _appController = appController;
    window.addEventListener("message", (e) => { //console.info("In addEventListener>message: ", e);
        if (e.source !== window.parent) return; // only from embedding window
        if (e.origin !== window.location.origin) return; // same
        if (Object.keys(e.data).length !== 3) return; // avoid overruns from possibly malicious senders
        m1 = e.data.m1, m2 = e.data.m2, m3 = e.data.m3;
        if ((m1 === undefined) || (m1.length > 50))  return;
        if ((m2 === undefined) || (m2.length > 50))  return;
        if ((m3 === undefined) || (m3.length > 50))  return;
        m3AsNumber = Number(m3);
        switch (m1) {
            case "Version":
                [self post2parentM1: "Version" m2: gVersionStringOfFract m3: gVersionDateOfFrACT success: YES];
                _sendHTMLMessageOnRunDone = NO;
                break;
            case "setSetting": case "Setting": // 2 versions for compatibility, 2nd is deprecated
                switch(m2) {
                    case "Preset": case "Presets": // 2 versions for compatibility, 2nd is deprecated
                        [self _notify: "applyPresetNamed" object: m3];
                        break;
                    case "nTrials08": case "distanceInCM": case "calBarLengthInMM": case "autoRunIndex":
                        [self setSettingNamed: m2];
                        break;
                    default:
                        [self _logProblemM123];
                }
                break;
            case "Run":
                _sendHTMLMessageOnRunDone = YES;// need to switch again off if parsing below fails
                switch(m2) {
                    case "TestNumber":
                        const allowedNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
                        if ((allowedNumbers.includes(m3AsNumber))) {
                            [self _notify: "notificationRunFractControllerTest" object: m3];
                        } else {
                            [self _logProblemM123];
                        }
                        break;
                    case "Acuity":
                        switch(m3) {
                            case "Letters":
                                [self _notify: "notificationRunFractControllerTest" object: kTestAcuityLett];
                                break;
                            case "LandoltC":
                                [self _notify: "notificationRunFractControllerTest" object: kTestAcuityC];
                                break;
                            case "TumblingE":
                                [self _notify: "notificationRunFractControllerTest" object: kTestAcuityE];
                                break;
                            default:
                                [self _logProblemM123];
                        }
                        break;
                    case "Contrast":
                        switch(m3) {
                            case "Letters":
                                [self _notify: "notificationRunFractControllerTest" object: kTestContrastLett];
                                break;
                            case "LandoltC":
                                [self _notify: "notificationRunFractControllerTest" object: kTestContrastC];
                                break;
                            case "TumblingE":
                                [self _notify: "notificationRunFractControllerTest" object: kTestContrastE];
                                break;
                            default:
                                [self _logProblemM123];
                        }
                        break;
                    default:
                        [self _logProblemM123];
                }
                break;
            default:
                [self _logProblem: e.data];
        }
    });
}


+ (void) post2parentM1: (CPString) m1 m2: (CPString) m2 m3: (CPString) m3 success: (BOOL) success {
    window.parent.postMessage({m1: m1, m2: m2, m3: m3, success: success}, "*");
}


+  (void) runDoneSuccessful: (BOOL) success { //console.info("ControlDispatcher>runDoneSuccessful")
    if (!_sendHTMLMessageOnRunDone) return;
    _sendHTMLMessageOnRunDone = NO;
    [self post2parentM1: m1 m2: m2 m3: m3 success: success];
}


+ (void) _notify: (CPString) aNotificationName object: (id) anObject {
    [[_appController window] orderFront: self]; // otherwise we would crash here
    [[CPNotificationCenter defaultCenter] postNotificationName: aNotificationName object: anObject];
}


+ (void) _logProblemM123 {
    const data = {m1: m1, m2: m2, m3: m3, success: false};
    console.log("FrACT10 received unexpected message.data: ", data);
    window.parent.postMessage(data, "*");
    _sendHTMLMessageOnRunDone = NO;
}


+ (void) _logProblem: (id) data {
    console.log("FrACT10 received unexpected message.data: ", data);
    window.parent.postMessage({data: data, success: NO}, "*");
    _sendHTMLMessageOnRunDone = NO;
}


@end
