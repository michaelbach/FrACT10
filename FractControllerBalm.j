/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 2025-03-11 created

 This is the superclass for the 3 BaLM modules
 */


@import "FractController.j"


@implementation FractControllerBalm: FractController {
    int savedAuditoryFeedback4trial;
}


- (void) modifyThresholderStimulus {
}
- (float) stimThresholderunitsFromDeviceunits: (float) ntve {
    return ntve;
}
- (float) stimDeviceunitsFromThresholderunits: (float) generic {
    return generic;
}
- (CPString) composeTrialInfoString {
    let s = iTrial + "/" + nTrials + " " + [alternativesGenerator currentAlternative];
    return s;
}


- (void) runStart { //console.info("FractControllerBalm>runStart");
    [self setCurrentTestResultUnit: "hitRateInPercent"];
    [Settings setAcuityForeColor: [CPColor whiteColor]];// will be copied → gColorFore
    [Settings setAcuityBackColor: [CPColor blackColor]];

    savedAuditoryFeedback4trial = [Settings auditoryFeedback4trial];
    [Settings setAuditoryFeedback4trial: kAuditoryFeedback4trialNone];

    [super runStart];
}


- (void) alertProblemOfDiameter: (float) dia {
    let s = "\r\rThe combination of distance (";
    s += [Misc stringFromInteger: [Settings distanceInCM]] + " cm) and diameter (";
    s += [Misc stringFromNumber: dia decimals: 1 localised: YES] + "°)"
    s += " renders the stimulus (nearly) invisible.\r\rTipp: Set distance to, e.g., 60 cm\r\r"
    const alert = [CPAlert alertWithMessageText: "WARNING"
                                  defaultButton: "OK" alternateButton: nil otherButton: nil
                      informativeTextWithFormat: s];
    [alert runModalWithDidEndBlock: function(alert, returnCode) {}];
}


- (int) responseNumberFromChar: (CPString) keyChar { //console.info("FractControllerBalm>responseNumberFromChar")
    switch (nAlternatives) {
        case 2: return [self responseNumber2FromChar: keyChar];
        case 4: return [self responseNumber4FromChar: keyChar];
        default:
            throw new Error("FractControllerBalm>responseNumberFromChar, alternatives not 2 or 4.");
    }
}


- (void) runEnd { //console.info("FractControllerBalm>runEnd");
    [Settings setAuditoryFeedback4trial: savedAuditoryFeedback4trial];
    if (iTrial < nTrials) { //premature end
        [self setResultString: "Aborted"];
    } else {
        [self setResultString: [self composeResultString]];
    }
    [super runEnd];
}


- (float) resultValue4Export { //console.info("FractControllerBalm>resultValue4Export");
    const total = [trialHistoryController nCorrect] + [trialHistoryController nIncorrect];
    if ([trialHistoryController nTotal] != total)
        throw new Error("FractControllerBalm: corret+incorrect ≠ total.");
    const hitRateInPercent = 100 * [trialHistoryController nCorrect] / total;
    return hitRateInPercent;
}


- (CPString) composeResultString { //console.info("FractControllerBalm>composeResultString");
    let s = [Misc stringFromNumber: [self resultValue4Export] decimals: 1 localised: YES];
    s = "Hit rate: " + s + "%";
    return s;
}


- (CPString) composeExportString { //console.info("FractControllerBalm>composeExportString");
    if (gAppController.runAborted) return "";
    let s = [self generalComposeExportString];
    const nDigits = 3;
    s += tab + "value" + tab + [Misc stringFromNumber: [self resultValue4Export] decimals: nDigits localised: YES];
    s += tab + "unit1" + tab + currentTestResultUnit
    s += tab + "distanceInCm" + tab + [Misc stringFromNumber: [Settings distanceInCM] decimals: 1 localised: YES];
    s += tab + "contrastWeber" + tab + 99;
    s += tab + "unit2" + tab + "%";
    s += tab + "nTrials" + tab + [Misc stringFromNumber: nTrials decimals: 0 localised: YES];
    s += tab + "rangeLimitStatus" + tab + rangeLimitStatus;
    s += tab + "crowding" + tab + [Settings crowdingType];
    return [self generalComposeExportStringFinalize: s];
}


@end
