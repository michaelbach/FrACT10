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
        m3AsNumber = Number(m3);
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
            case "Run":
                [self manageRun];  break;
            case "respondWithChar":
                const e = [CPEvent keyEventWithType:CPKeyDown location:CGPointMakeZero() modifierFlags:0 timestamp:0 windowNumber:0 context:nil characters:m2 charactersIgnoringModifiers:m2 isARepeat:NO keyCode:0];
                [_appController.currentFractController performSelector: @selector(keyDown:) withObject: e];
                [self post2parentM1: m1 m2: m2 m3: m3 success: YES];  break;
            case "Unittest":
                [self manageUnittests];  break;
            default:
                [self _logProblem: e.data];
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
    if (m2 === "Preset") {
        [self _notify: "applyPresetNamed" object: m3];  return;
    }
    allowedBoolSettings = ["gratingObliqueOnly", "responseInfoAtStart", "enableTouchControls", "eccentShowCenterFixMark", "mobileOrientation", "trialInfo", "results2clipboard", "results2clipboardSilent", "rewardPicturesWhenDone", "embedInNoise", "isAcuityColor", "obliqueOnly", "acuityEasyTrials", "acuityFormatDecimal", "acuityFormatLogMAR", "acuityFormatSnellenFractionFoot", "forceSnellen20", "showCI95", "lineByLineChartMode", "lineByLineChartModeConstantVA", "contrastEasyTrials", "contrastDarkOnLight", "contrastShowFixMark", "contrastDithering", "isGratingMasked", "gratingUseErrorDiffusion", "gratingSineNotSquare", "isGratingColor", "specialBcmOn", "hideExitButton", "auditoryFeedback4trial", "auditoryFeedback4run"];
    if (allowedBoolSettings.includes(m2)) {
        [self setSettingNamed: m2];  return;
    }
    allowedNumberSettings = ["nAlternativesIndex", "nTrials02", "nTrials04", "nTrials08", "distanceInCM", "calBarLengthInMM", "testOnFive", "decimalMarkCharIndex", "testOnFive", "eccentXInDeg", "eccentYInDeg", "displayTransform", "trialInfoFontSize", "timeoutResponseSeconds", "timeoutDisplaySeconds", "soundVolume", "timeoutRewardPicturesInSeconds", "noiseContrast", "checkNum", "maxDisplayedAcuity", "minStrokeAcuity", "acuityStartingLogMAR", "margin4maxOptotypeIndex", "autoRunIndex", "crowdingType", "crowdingDistanceCalculationType", "crowdingDistanceCalculationType", "testOnLineByLine", "testOnLineByLineDistanceType", "lineByLineHeadcountIndex", "vernierType", "vernierWidth", "vernierLength", "vernierGap", "gammaValue", "contrastOptotypeDiameter", "contrastTimeoutFixmark", "contrastMaxLogCSWeber", "gratingCPD", "gratingDiaInDeg", "what2sweepIndex", "gratingCPDmin", "gratingCPDmax", "gratingContrastMichelsonPercent", "soundTrialYesIndex", "soundTrialNoIndex", "soundRunEndIndex"];
    if (allowedNumberSettings.includes(m2)) {
        [self setSettingNamed: m2];  return;
    }
    [self _logProblemM123];
}


+ (void) manageGetValue {
    m3 = null;
    if ((_appController.currentFractController === null) ||
         (_appController.currentFractController.alternativesGenerator === null)) {
        [self _logProblemM123];  return;
    }
    switch(m2) {
        case "currentAlternative":
            m3 = [_appController.currentFractController.alternativesGenerator currentAlternative]
            [self post2parentM1: m1 m2: m2 m3: m3 success: (m3 !== null)];
            break;
        case "iTrial":
            m3 = _appController.currentFractController.iTrial;
            [self post2parentM1: m1 m2: m2 m3: m3 success: (m3 !== null)];
            break;
        default:
            [self _logProblemM123];
    }
}


+ (void) manageRun {
    _sendHTMLMessageOnRunDone = YES;// need to switch off again if parsing below fails
    switch(m2) {
        case "TestNumber":
            const allowedNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
            if (allowedNumbers.includes(m3AsNumber)) {
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
                case "Vernier":
                    [self _notify: "notificationRunFractControllerTest" object: kTestAcuityVernier];
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
}


+ (void) manageUnittests {
    switch(m2) {
        case "RewardImages": // ignore m3
            [_appController.rewardsController unittest];
            break;
        case "Error":
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
