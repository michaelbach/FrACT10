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


/**
 set up listener to dispatch control messages to FrACT10 when embedded as iframe
 */
+ (void) initWithAppController: (id) appController { //console.info("ControlDispatcher>initWithAppController")
    _sendHTMLMessageOnRunDone = NO;
    _appController = appController;
    window.addEventListener("message", (e) => { //console.info("In addEventListener>message: ", e);
        if (e.origin !== "http://localhost:4000") { // only from local host (for unittesting)
            if (e.source !== window.parent) return; // or from embedding window
            if (e.origin !== window.location.origin) return; // same
        }
        if (Object.keys(e.data).length !== 3) return; // avoid overruns from possibly malicious senders
        m1 = e.data.m1, m2 = e.data.m2, m3 = e.data.m3;
        if ((m1 === undefined) || (m2 === undefined) || (m3 === undefined)) return;
        if (m1.length + m2.length + m3.length > 100) return;
        m2AsNumber = Number(m2);
        m3AsNumber = Number(m3);
        const eData = e.data;//strangly, e no longer in scope after "default:" below; so copy
        switch (m1) {
            case "getVersion": case "Version": // 2 versions for compatibility, 2nd is deprecated
                [self post2parentM1: "getVersion" m2: gVersionStringOfFract m3: gVersionDateOfFrACT success: YES];
                _sendHTMLMessageOnRunDone = NO;
                break;
            case "getSetting":
                [self manageGetSetting];  break;
            case "setSetting": case "Settings": // 2 versions for compatibility, 2nd is deprecated
                [self manageSetSetting];  break;
            case "getValue":
                [self manageGetValue];  break;
            case "run": case "Run":
                [self manageRun];  break;
            case "respondWithChar":
                const e = [CPEvent keyEventWithType:CPKeyDown location:CGPointMakeZero() modifierFlags:0 timestamp:0 windowNumber:0 context:nil characters:m2 charactersIgnoringModifiers:m2 isARepeat:NO keyCode:0];
                [_appController.currentFractController performSelector: @selector(keyDown:) withObject: e];
                [self post2parentM1: m1 m2: m2 m3: m3 success: YES];  break;
            case "unittest": case "Unittest":
                [self manageUnittests];  break;
            case "reload":
                window.location.reload(NO);  break;
            case "setFullScreen":
                [Misc fullScreenOn: m2];
                [self post2parentM1: m1 m2: m2 m3: m3 success: YES];  break;
            case "settingsPanes":
                if (isNaN(m2AsNumber) || (m2AsNumber > 5)) {
                    [self _logProblemM123];  return;
                }
                if (m2AsNumber < 0) {
                    [_appController buttonSettingsClose_action: nil];
                    [self post2parentM1: m1 m2: m2 m3: m3 success: YES];  break;
                }
                [_appController setSettingsPaneTabViewSelectedIndex: m2AsNumber];
                [_appController buttonSettings_action: nil];
                [self post2parentM1: m1 m2: m2 m3: m3 success: YES];  break;
            default:
                [self _logProblem: eData];
        }
    });
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
        [self _notify: "applyPresetNamed" object: m3];  return;
    }
    const allowedBoolSettings = ["gratingObliqueOnly", "responseInfoAtStart", "enableTouchControls", "eccentShowCenterFixMark", "eccentRandomizeX", "autoFullScreen", "mobileOrientation", "trialInfo", "results2clipboard", "results2clipboardSilent", "rewardPicturesWhenDone", "embedInNoise", "isAcuityColor", "obliqueOnly", "acuityEasyTrials", "acuityFormatDecimal", "acuityFormatLogMAR", "acuityFormatSnellenFractionFoot", "forceSnellen20", "showCI95", "lineByLineChartMode", "lineByLineChartModeConstantVA", "contrastEasyTrials", "contrastDarkOnLight", "contrastShowFixMark", "contrastDithering", "isGratingMasked", "gratingUseErrorDiffusion", "isGratingColor", "specialBcmOn", "hideExitButton", "auditoryFeedback4trial", "auditoryFeedback4run"];
    if (allowedBoolSettings.includes(m2)) {
        [self setSettingNamed: m2];  return;
    }
    const allowedNumberSettings = ["nAlternativesIndex", "nTrials02", "nTrials04", "nTrials08", "distanceInCM", "calBarLengthInMM", "testOnFive", "decimalMarkCharIndex", "testOnFive", "eccentXInDeg", "eccentYInDeg", "displayTransform", "trialInfoFontSize", "timeoutIsiMillisecs", "timeoutResponseSeconds", "timeoutDisplaySeconds", "soundVolume", "timeoutRewardPicturesInSeconds", "noiseContrast", "checkNum", "contrastAcuityWeber", "maxDisplayedAcuity", "minStrokeAcuity", "acuityStartingLogMAR", "margin4maxOptotypeIndex", "autoRunIndex", "crowdingType", "crowdingDistanceCalculationType", "crowdingDistanceCalculationType", "testOnLineByLine", "testOnLineByLineDistanceType", "lineByLineHeadcountIndex", "vernierType", "vernierWidth", "vernierLength", "vernierGap", "gammaValue", "contrastOptotypeDiameter", "contrastTimeoutFixmark", "contrastMaxLogCSWeber", "gratingCPD", "gratingDiaInDeg", "gratingShapeIndex", "what2sweepIndex", "gratingCPDmin", "gratingCPDmax", "gratingContrastMichelsonPercent", "soundTrialYesIndex", "soundTrialNoIndex", "soundRunEndIndex"];
    if (allowedNumberSettings.includes(m2)) {
        [self setSettingNamed: m2];  return;
    }
    const allowedColorSettings = ["windowBackgroundColor", "gratingForeColor", "gratingBackColor", "acuityForeColor", "acuityBackColor"];
    if (allowedColorSettings.includes(m2)) {
        [self setColorSettingNamed: m2];  return;
    }
    [self _logProblemM123];
}


+ (void) manageGetValue {
    m3 = null;  const _inRun = [self _isInRun];
    if (m2 == "isInRun") {
        const currTestID = _appController.currentTestID;
        const s = [_appController performSelector: @selector(testNameGivenTestID:) withObject: currTestID];
        [self post2parentM1: m1 m2: _inRun m3: s success: YES];
        return;
    }
    if (!_inRun) { // if no test is running, all options further down are moot
        [self _logProblemM123];  return;
    }
    switch(m2) {
        case "currentAlternative":
            m3 = [_appController.currentFractController.alternativesGenerator currentAlternative]
            [self post2parentM1: m1 m2: m2 m3: m3 success: (m3 !== null)];
            break;
        case "currentTrial":
            m3 = _appController.currentFractController.iTrial;
            [self post2parentM1: m1 m2: m2 m3: m3 success: (m3 !== null)];
            break;
        case "currentValue":
            m3 = [_appController.currentFractController.trialHistoryController value];
            [self post2parentM1: m1 m2: m2 m3: m3 success: (m3 !== null)];
            break;
        default:
            [self _logProblemM123];
    }
}


+ (void) manageRun {
    _sendHTMLMessageOnRunDone = YES;// need to switch off again if parsing below fails
    switch(m2) {
        case "testNumber": case "TestNumber":
            if ((m3AsNumber >= 1) && (m3AsNumber <= 10)) {
                [self _notify: "notificationRunFractControllerTest" object: m3AsNumber];  return;
            }
        case "acuity": case "Acuity": { // need brackets so scope of variables stays local
            const testKey = {"Letters": kTestAcuityLett, "LandoltC": kTestAcuityC, "TumblingE": kTestAcuityE, "TAO": kTestAcuityTAO, "Vernier": kTestAcuityVernier}[m3];
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


+ (void) manageUnittests {
    switch(m2) {
        case "rewardImages": case "RewardImages": // ignore m3
            [_appController.rewardsController unittest];
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
    const sNameCapped = sName.charAt(0).toUpperCase() + sName.slice(1);
    let setter = CPSelectorFromString("set" + sNameCapped + ":");
    [Settings performSelector: setter withObject: m3AsNumber];
    [Settings allNotCheckButSet: NO]; // check whether we were in range
    let m3Now = [Settings performSelector: CPSelectorFromString(sName)]; // read back
    if (typeof(m3Now) === "boolean") {
        m3Now = Number(m3Now);
    }
    [self post2parentM1: m1 m2: m2 m3: m3Now success: m3AsNumber === m3Now];
}


+ (void) setColorSettingNamed: (CPString) sName { //console.info("setSettingNamed: ", sName);
    if (["acuityForeColor", "acuityBackColor"].includes(m2)) {
        [Settings setIsAcuityColor: YES];
    }
    if (["gratingForeColor", "gratingBackColor"].includes(m2)) {
        [Settings setIsGratingColor: YES];
    }
    const sNameCapped = sName.charAt(0).toUpperCase() + sName.slice(1);
    let setter = CPSelectorFromString("set" + sNameCapped + ":");
    [Settings performSelector: setter withObject: m3];
    [[CPNotificationCenter defaultCenter] postNotificationName: "copyColorsFromSettings" object: nil];
    let m3Now = [Settings performSelector: CPSelectorFromString(sName)]; // read back
    m3Now = [m3Now hexString];
    [self post2parentM1: m1 m2: m2 m3: m3Now success: m3 === m3Now];
}


+ (BOOL) _isInRun {
    if (_appController.currentFractController === null) return NO;
    return _appController.currentFractController.alternativesGenerator !== null;
}


+ (void) _notify: (CPString) aNotificationName object: (id) anObject {
    [[_appController window] orderFront: self]; // otherwise we would crash here
    [[CPNotificationCenter defaultCenter] postNotificationName: aNotificationName object: anObject];
}


+ (void) post2parentM1: (CPString) m1 m2: (CPString) m2 m3: (CPString) m3 success: (BOOL) success {
    window.parent.postMessage({success: success, m1, m2, m3}, "*");
}


+ (void) _logProblemM123 {
    const data = {success: NO, m1, m2, m3};
    console.log("FrACT10 received unexpected message.data: ", data);
    window.parent.postMessage(data, "*");
    _sendHTMLMessageOnRunDone = NO;
}


+ (void) _logProblem: (id) data {
    console.log("FrACT10 received unexpected message.data: ", data);
    window.parent.postMessage({success: NO, data: data}, "*");
    _sendHTMLMessageOnRunDone = NO;
}


@end
