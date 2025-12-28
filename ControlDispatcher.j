/*
 This file is part of FrACT10, a vision test battery.
 © 2024 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 ControlDispatcher.j

 Dispatcher for HTML communication messages to control FrACT

 */


@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>


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
    window.addEventListener("message", (e) => { //console.info("In addEventListener>message: ", e);
        if (e.origin !== "http://localhost:4000") { //only from local host (for unittesting)
            if (e.source !== window.parent) return; //or from embedding window
            if (e.origin !== window.location.origin) return; //same
        }
        _origin = e.origin;
        if (Object.keys(e.data).length !== 3) return; //avoid overruns from possibly malicious senders
        m1 = e.data.m1, m2 = e.data.m2, m3 = e.data.m3;
        if ((m1 === undefined) || (m2 === undefined) || (m3 === undefined)) return;
        if (m1.length + m2.length + m3.length > 100) return;
        m2AsNumber = Number(m2);
        m3AsNumber = Number(m3);
        const messageHandlers = {
            "getVersion": () => {
                [self post2parentM1:"getVersion" m2:gVersionStringOfFract m3:gVersionDateOfFrACT success:YES];
                _sendHTMLMessageOnRunDone = NO;
            },
            "getSetting": () => [self manageGetSetting],
            "setSetting": () => [self manageSetSetting],
            "getValue": () => [self manageGetValue],
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
                [gAppController.selfWindow makeKeyWindow];
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
            [self _logProblem:e.data];
        }
    });
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


+
 (void) manageSetSetting {
    const settingTypes = {
        "showIdAndEyeOnMain": "boolean", "isGratingObliqueOnly": "boolean", "showResponseInfoAtStart": "booleaxn", "enableTouchControls": "boolean", "eccentShowCenterFixMark": "boolean", "eccentRandomizeX": "boolean", "eccentRandomizeY": "boolean", "autoFullScreen": "boolean", "respondsToMobileOrientation": "boolean", "showTrialInfo": "boolean", "putResultsToClipboardSilent": "boolean", "showRewardPicturesWhenDone": "boolean", "embedInNoise": "boolean", "isAcuityColor": "boolean", "isLandoltObliqueOnly": "boolean", "acuityHasEasyTrials": "boolean", "doThreshCorrection": "boolean", "showAcuityFormatDecimal": "boolean", "showAcuityFormatLogMAR": "boolean", "showAcuityFormatSnellenFractionFoot": "boolean", "forceSnellen20": "boolean", "showCI95": "boolean", "isLineByLineChartModeConstantVA": "boolean", "contrastHasEasyTrials": "boolean", "isContrastDarkOnLight": "boolean", "contrastShowFixMark": "boolean", "isContrastDithering": "boolean", "isGratingMasked": "boolean", "isGratingErrorDiffusion": "boolean", "isGratingColor": "boolean", "specialBcmOn": "boolean", "hideExitButton": "boolean", "giveAuditoryFeedback4run": "boolean", "isAcuityPresentedConstant": "boolean",
        "nAlternativesIndex": "number", "nTrials02": "number", "nTrials04": "number", "nTrials08": "number", "distanceInCM": "number", "calBarLengthInMM": "number", "testOnFive": "number", "decimalMarkCharIndex": "number", "eccentXInDeg": "number", "eccentYInDeg": "number", "displayTransform": "number", "trialInfoFontSize": "number", "timeoutIsiMillisecs": "number", "timeoutResponseSeconds": "number", "timeoutDisplaySeconds": "number", "soundVolume": "number", "auditoryFeedback4trialIndex": "number", "timeoutRewardPicturesInSeconds": "number", "resultsToClipboardIndex": "number", "noiseContrast": "number", "contrastAcuityWeber": "number", "maxDisplayedAcuity": "number", "minStrokeAcuity": "number", "acuityStartingLogMAR": "number", "margin4maxOptotypeIndex": "number", "autoRunIndex": "number", "crowdingType": "number", "crowdingDistanceCalculationType": "number", "testOnLineByLineIndex": "number", "lineByLineDistanceType": "number", "lineByLineHeadcountIndex": "number", "lineByLineLinesIndex": "number", "vernierType": "number", "vernierWidth": "number", "vernierLength": "number", "vernierGap": "number", "gammaValue": "number", "contrastOptotypeDiameter": "number", "contrastTimeoutFixmark": "number", "contrastMaxLogCSWeber": "number", "contrastCrowdingType": "number", "gratingCPD": "number", "gratingMaskDiaInDeg": "number", "gratingShapeIndex": "number", "what2sweepIndex": "number", "gratingCPDmin": "number", "gratingCPDmax": "number", "gratingContrastMichelsonPercent": "number", "soundTrialYesIndex": "number", "soundTrialNoIndex": "number", "soundRunEndIndex": "number", "acuityPresentedConstantLogMAR": "number",
        "windowBackgroundColor": "color", "gratingForeColor": "color", "gratingBackColor": "color", "acuityForeColor": "color", "acuityBackColor": "color"
    };

    if ((m2 === "preset") || (m2 === "Preset")) {
        [self _notify:"notificationApplyPresetNamed" object:m3];
        return;
    }

    const settingType = settingTypes[m2];
    if (settingType === "boolean" || settingType === "number") {
        [self setSettingNamed:m2];
    } else if (settingType === "color") {
        [self setColorSettingNamed:m2];
    } else {
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
            m3 = [TrialHistoryController value];
            [self post2parentM1: m1 m2: m2 m3: m3 success: (m3 !== null)];
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
            const testKey = {"Letters": kTestAcuityLett, "LandoltC": kTestAcuityC, "TumblingE": kTestAcuityE, "TAO": kTestAcuityTAO, "Vernier": kTestAcuityVernier, "Line": kTestAcuityLineByLine,
                "BalmLight": kTestBalmLight, "BalmLocation": kTestBalmLocation, "BalmMotion": kTestBalmMotion}[m3];
            if (testKey !== undefined) {
                [self _notify: "notificationRunFractControllerTest" object: testKey];  return;
            }}
        case "contrast": case "Contrast": {
            const testKey = {"Letters": kTestContrastLett, "LandoltC": kTestContrastC, "TumblingE": kTestContrastE, "Grating": kTestContrastG}[m3];
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


+ (void) setSettingNamed: (CPString) sName { //console.info("setSettingNamed: ", sName);
    if (isNaN(m3AsNumber)) {
        [self _logProblemM123];  return;
    }
    const sNameCapitalised = sName.charAt(0).toUpperCase() + sName.slice(1);
    const setter = CPSelectorFromString("set" + sNameCapitalised + ":");
    [Settings performSelector: setter withObject: m3AsNumber];
    [Settings allNotCheckButSet: NO]; //check whether we were in range
    let m3Now = [Settings performSelector: CPSelectorFromString(sName)]; //read back
    if (typeof(m3Now) === "boolean") {
        m3Now = Number(m3Now);
    }
    [Misc udpateGUI];
    [self post2parentM1: m1 m2: m2 m3: m3Now success: m3AsNumber === m3Now];
}


+ (void) setColorSettingNamed: (CPString) sName { //console.info("setSettingNamed: ", sName);
    if (["acuityForeColor", "acuityBackColor"].includes(m2)) {
        [Settings setIsAcuityColor: YES];
    }
    if (["gratingForeColor", "gratingBackColor"].includes(m2)) {
        [Settings setIsGratingColor: YES];
    }
    const sNameCapitalised = sName.charAt(0).toUpperCase() + sName.slice(1);
    const setter = CPSelectorFromString("set" + sNameCapitalised + ":");
    [Settings performSelector: setter withObject: m3];
    [gAppController copyColorsFromSettings];
    let m3Now = [Settings performSelector: CPSelectorFromString(sName)]; //read back
    m3Now = [m3Now hexString];
    [Misc udpateGUI];
    [self post2parentM1: m1 m2: m2 m3: m3Now success: m3 === m3Now];
}


+ (void) _notify: (CPString) aNotificationName object: (id) anObject {
    [[gAppController window] orderFront: self]; //otherwise we would crash here
    [[CPNotificationCenter defaultCenter] postNotificationName: aNotificationName object: anObject];
}


+ (void) post2parentM1: (CPString) m1 m2: (CPString) m2 m3: (CPString) m3 success: (BOOL) success {
    window.parent.postMessage({success: success, m1, m2, m3}, _origin);
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
