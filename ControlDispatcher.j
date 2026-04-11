/*
 This file is part of FrACT10, a vision test battery.
 © 2024 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 ControlDispatcher.j

 Dispatcher for HTML communication messages to control FrACT

 */


@import <Foundation/Foundation.j>
@import "Globals.j"


@implementation ControlDispatcher: CPObject {
    CPString m1, m2, m3;
    float m3AsNumber;
    BOOL _sendHTMLMessageOnRunDone;
    CPString _origin;
}


/**
 set up listener to dispatch control messages to FrACT10 when embedded as iframe
 */
+ (void) init { //console.info("ControlDispatcher>init")
    _sendHTMLMessageOnRunDone = NO;
    [[CPNotificationCenter defaultCenter] addObserver: self selector: @selector(dispatchNotification:) name: "dispatchNotification" object: nil];
    window.addEventListener("message", (e) => { //console.info("In addEventListener>message: ", e);
        if (e.origin !== "http://localhost:4000") { //only from local host (for unittesting)
            if (e.source !== window.parent) return; //or from embedding window
            if (e.origin !== window.location.origin) return; //same
        }
        _origin = e.origin;
        if (Object.keys(e.data).length !== 3) return; //avoid overruns from possibly malicious senders
        const userInfo = {m1: e.data.m1, m2: e.data.m2, m3: e.data.m3};
        [[CPNotificationCenter defaultCenter] postNotificationName: "dispatchNotification" object: nil userInfo: userInfo];
    });
}


+ (void) dispatchNotification: (CPNotification) notification {
    //let's vet the message content somewhat
    const message = [notification userInfo];
    if ((message.m1 === undefined) || (message.m2 === undefined) || (message.m3 === undefined)) return;
    if (message.m1.length + message.m2.length + message.m3.length > 100) return;
    m1 = message.m1; m2 = message.m2;  m3 = message.m3;
    m2AsNumber = Number(m2);  m3AsNumber = Number(m3);
    const messageHandlers = {
        "getVersion": () => {
            [self post2parentM1:"getVersion" m2:gVersionStringOfFract m3:gVersionDateOfFrACT success:YES];
            _sendHTMLMessageOnRunDone = NO;
        },
        "getSetting": () => [self manageGetSetting],
        "setSetting": () => [self manageSetSetting],
        "getValue": () => [self manageGetValue],
        "setValue": () => [self manageSetValue],
        "run": () => [self manageRun],
        "getTestDetails": () => {
            [self post2parentM1:"getTestDetails" m2:gTestDetails m3:"" success:YES];
            _sendHTMLMessageOnRunDone = NO;
        },
        "sendChar": () => {
            [self sendChar:m2];  [self post2parentM1:m1 m2:m2 m3:m3 success:YES];
        },
        "respondWithChar": () => {
            const keyEvent = [CPEvent keyEventWithType:CPKeyDown location:CGPointMakeZero() modifierFlags:0 timestamp:0 windowNumber:0 context:nil characters:m2 charactersIgnoringModifiers:m2 isARepeat:NO keyCode:0];
            [gAppController.currentFractController performSelector:@selector(keyDown:) withObject:keyEvent];
            [self post2parentM1:m1 m2:m2 m3:m3 success:YES];
        },
        "unittest": () => [self manageUnittests],
        "reload": () => window.location.reload(NO),
        "setFullScreen": () => {
            [Misc fullScreenOn:m2];  [self post2parentM1:m1 m2:m2 m3:m3 success:YES];
        },
        "settingsPane": () => {
            if (isNaN(m2AsNumber) || (m2AsNumber > 6)) {
                [self _logProblemM123];
                return;
            }
            if (m2AsNumber < 0) {
                [gAppController buttonSettingsClose_action:nil];
                [self post2parentM1:m1 m2:m2 m3:m3 success:YES];
                return;
            }
            [gAppController setSettingsPaneTabViewSelectedIndex:m2AsNumber];
            [gAppController buttonSettings_action:nil];
            [Misc udpateGUI];
            [self post2parentM1:m1 m2:m2 m3:m3 success:YES];
        },
        "redraw": () => {
            [Misc udpateGUI];  [self post2parentM1:m1 m2:m2 m3:m3 success:YES];
        },
        "setHomeState": () => {
            [self sendChar:String.fromCharCode(13)];
            [self sendChar:String.fromCharCode(10)];
            if ([Misc isInRun]) {
                [gAppController.currentFractController runEnd];
            } else {
                if (gLatestAlert) {
                    let alertWindow = [gLatestAlert window];
                    if (alertWindow) {
                        [CPApp stopModal];
                        [alertWindow orderOut:self];
                        gLatestAlert = null;
                    }
                }
            }
            [[gAppController window] makeKeyWindow];
            [self post2parentM1:m1 m2:m2 m3:m3 success:YES];
        }
    };
    /* deprecated names
     messageHandlers["Version"] = messageHandlers["getVersion"];
     messageHandlers["Settings"] = messageHandlers["setSetting"];
     messageHandlers["Run"] = messageHandlers["run"];
     messageHandlers["Unittest"] = messageHandlers["unittest"];
     messageHandlers["setHomeStatus"] = messageHandlers["setHomeState"];*/

    const handler = messageHandlers[m1];
    if (handler) {
        handler();
    } else {
        [self _logProblem: m1 + ", " + m2 + ", " + m3];
    }
}


//works except for <esc> in BaLM switch
+ (void) sendChar: (CPString) s { //console.info("ControlDispatcher>sendChar", s)
    const keyEvent = [CPEvent keyEventWithType:CPKeyDown location:CGPointMakeZero() modifierFlags:0 timestamp:0 windowNumber:0 context:nil characters:s charactersIgnoringModifiers:s isARepeat:NO keyCode:s.charCodeAt(0)];
    const frontWindow = [[CPApp orderedWindows] objectAtIndex:0];
    [frontWindow sendEvent: keyEvent];
}


/**
 called from AppController
 */
+  (void) runDoneSuccessful: (BOOL) success { //console.info("ControlDispatcher>runDoneSuccessful")
    if (!_sendHTMLMessageOnRunDone) return;
    _sendHTMLMessageOnRunDone = NO;
    [self post2parentM1: m1 m2: m2 m3: m3 success: success];
}


+ (void) manageGetSetting {
    if (m2 === "allKeys") {
        const allKeys = [[[CPUserDefaults standardUserDefaults]._domains objectForKey: CPApplicationDomain] allKeys];
        [self post2parentM1: m1 m2: m2 m3: allKeys success: YES];
        return;
    }
    const sttng = [[CPUserDefaults standardUserDefaults] objectForKey: m2];
    [self post2parentM1: m1 m2: m2 m3: sttng success: (sttng !== null)];
}


+ (void) manageSetSetting {
    if ((m2 === "preset") || (m2 === "Preset")) {
        [self _notify:"notificationApplyPresetNamed" object:m3];
        return;
    }
    console.info(gTestMap)
    switch(gSettingsNamesAndTypesMap.get(m2)) {
        case "bool": case "int": case "float":
            [self setNumberSettingNamed:m2]; break;
        case "color":
            [self setColorSettingNamed:m2]; break;
        case "str":
            [self setStringSettingNamed:m2]; break;
        default:
            [self _logProblemM123];
    }
}


+ (void) manageGetValue {
    m3 = null;  const _inRun = [Misc isInRun];
    if (m2 === "isInRun") {
        const s = [Misc testNameGivenTestID: gCurrentTestID];
        [self post2parentM1: m1 m2: _inRun m3: s success: YES];
        return;
    }
    if (!_inRun) { //if no test is running, all options further down are moot
        [self _logProblemM123];  return;
    }
    switch(m2) {
        case "currentAlternative":
            m3 = [gAppController.currentFractController.alternativesGenerator currentAlternative]
            [self post2parentM1: m1 m2: m2 m3: m3 success: (m3 !== null)];
            break;
        case "currentTrial":
            m3 = gAppController.currentFractController.iTrial;
            [self post2parentM1: m1 m2: m2 m3: m3 success: (m3 !== null)];
            break;
        case "currentValue":
            m3 = [TrialHistoryManager value];
            [self post2parentM1: m1 m2: m2 m3: m3 success: (m3 !== null)];
            break;
        default:
            [self _logProblemM123];
    }
}


+ (void) manageSetValue {
    switch(m2) {
        case "resultString":
            [gAppController setResultStringFieldTo: m3];
            [Misc udpateGUI];
            [self post2parentM1:m1 m2:m2 m3:m3 success:YES];
            break;
        default:
            [self _logProblemM123];
    }
}


+ (void) manageRun {
    _sendHTMLMessageOnRunDone = YES; //need to switch off again if parsing below fails
    switch(m2) {
        case "testNumber": case "TestNumber":
            if ((m3AsNumber >= 1) && (m3AsNumber <= 10)) {
                [self _notify: "notificationRunFractControllerTest" object: m3AsNumber];  return;
            }
        case "acuity": case "Acuity": { //need brackets so scope of variables stays local
            const testKey = {"Letters": kTestAcuityLetters, "Landolt": kTestAcuityLandolt, "LandoltRing": kTestAcuityLandolt, "LandoltC": kTestAcuityLandolt, "TumblingE": kTestAcuityE, "TAO": kTestAcuityTAO, "Vernier": kTestAcuityVernier, "Line": kTestAcuityLineByLine,
                "BalmLight": kTestBalmLight, "BalmLocation": kTestBalmLocation, "BalmMotion": kTestBalmMotion}[m3];
            if (testKey !== undefined) {
                [self _notify: "notificationRunFractControllerTest" object: testKey];  return;
            }}
        case "contrast": case "Contrast": {
            const testKey = {"Letters": kTestContrastLetters, "Landolt": kTestContrastLandolt, "LandoltRing": kTestContrastLandolt, "LandoltC": kTestContrastLandolt, "TumblingE": kTestContrastE, "Grating": kTestContrastG}[m3];
            if (testKey !== undefined) {
                [self _notify: "notificationRunFractControllerTest" object: testKey];  return;
            }}
    }
    [self _logProblemM123];
}


+ (void) manageUnittests { //console.log("\nControlDispatcher>unittest")
    switch(m2) {
        case "allAutomatic":
            [self post2parentM1: m1 m2: m2 m3: m3 success: [Misc allUnittests]];
            break;
        case "rewardImages": case "RewardImages": //ignore m3
            [gAppController.rewardsController unittest];
            break;
        case "throwError": case "Error":
            throw new Error("Runtime error on purpose for testing.");
            break;
        default:
            [self _logProblemM123];
    }
}


+ (void) setNumberSettingNamed: (CPString) sName { //console.info("setNumberSettingNamed: ", sName);
    if (isNaN(m3AsNumber)) {
        [self _logProblemM123];  return;
    }
    const sNameCapitalised = sName.charAt(0).toUpperCase() + sName.slice(1);
    const setter = CPSelectorFromString("set" + sNameCapitalised + ":");
    [Settings performSelector: setter withObject: m3AsNumber];
    [Settings allNotCheckButSet: NO]; //check whether we were in range
    let m3Now = [Settings performSelector: CPSelectorFromString(sName)];
    if (typeof(m3Now) === "boolean") {
        m3Now = Number(m3Now);
    }
    [Misc udpateGUI];
    [self post2parentM1: m1 m2: m2 m3: m3Now success: m3AsNumber === m3Now];
}


+ (void) setStringSettingNamed: (CPString) sName {
    const sNameCapitalised = sName.charAt(0).toUpperCase() + sName.slice(1);
    const setter = CPSelectorFromString("set" + sNameCapitalised + ":");
    [Settings performSelector: setter withObject: m3];
    let m3Now = [Settings performSelector: CPSelectorFromString(sName)];
    [Misc udpateGUI];
    [self post2parentM1: m1 m2: m2 m3: m3Now success: m3 === m3Now];
}


+ (void) setColorSettingNamed: (CPString) sName {
    if (["acuityForeColor", "acuityBackColor"].includes(m2)) {
        [Settings setIsAcuityColor: YES];
    }
    if (["gratingForeColor", "gratingBackColor"].includes(m2)) {
        [Settings setIsGratingColor: YES];
    }
    const sNameCapitalised = sName.charAt(0).toUpperCase() + sName.slice(1);
    const setter = CPSelectorFromString("set" + sNameCapitalised + ":");
    [Settings performSelector: setter withObject: m3];

    [[CPNotificationCenter defaultCenter] postNotificationName: "settingsDidChange" object: nil]; //make sure colors are updated

    let m3Now = [Settings performSelector: CPSelectorFromString(sName)]; //read back
    m3Now = [m3Now hexString];
    [Misc udpateGUI];
    [self post2parentM1: m1 m2: m2 m3: m3Now success: m3 === m3Now];
}


+ (void) _notify: (CPString) aNotificationName object: (id) anObject {
    [[gAppController window] orderFront: self]; //otherwise we would crash here
    [[CPNotificationCenter defaultCenter] postNotificationName: aNotificationName object: anObject];
}


+ (void) post2parentM1: (CPString) m1 m2: (CPString) m2 m3: (CPString) m3 success: (BOOL) success { //console.info("post2parentM1");
    try {
        window.parent.postMessage({success: success, m1, m2, m3}, _origin);
    }
    catch(e) { //avoid the global error catcher, `_origin` might be undefined
    }
}


+ (void) _logProblemM123 {
    const data = {success: NO, m1, m2, m3};
    console.log("FrACT10 received unexpected message.data: ", data);
    window.parent.postMessage(data, _origin);
    _sendHTMLMessageOnRunDone = NO;
}


+ (void) _logProblem: (id) data {
    console.log("FrACT10 received unexpected message.data: ", data);
    window.parent.postMessage({success: NO, data: data}, _origin);
    _sendHTMLMessageOnRunDone = NO;
}


@end
