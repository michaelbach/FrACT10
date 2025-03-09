/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>
 
 2025-03-05 created class "FractControllerBalmMotion" inheriting from "FractController"
 */


@import "FractController.j"
@implementation FractControllerBalmMotion: FractController {
    float motionOffset, radiusInPix, speedInPixPerSec;
    BOOL isMoving;
    id animationRequestID;
    
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
    let s = iTrial + "/" + nTrials + " ";
    s += [alternativesGenerator currentAlternative];
    return s;
}


- (void) runStart { //console.info("FractControllerBalmMotion>runStart");
    nAlternatives = 4;  nTrials = [Settings nTrials04];
    [self setCurrentTestResultUnit: "hitRateInPercent"];
    [Settings setAcuityForeColor: [CPColor whiteColor]];// will be copied → gColorFore
    [Settings setAcuityBackColor: [CPColor blackColor]];
    [Settings setAuditoryFeedback4trial: kAuditoryFeedback4trialNone];
    animationRequestID = 0;
    radiusInPix = 0.5 * [MiscSpace pixelFromDegree: [Settings balmDiameterInDeg]];
    speedInPixPerSec = [MiscSpace pixelFromDegree: [Settings balmSpeedInDegPerSec]];
    [super runStart];
}


/*const rows = 3;
const cols = 4;
const array2 = new Array(rows);
for (let i = 0; i < rows; i++) {
  array2[i] = new Array(cols);
}
// Accessing elements
console.log(array1[0][1]);*/

- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerBalmMotion>drawStimulusInRect, state: ", state);
    trialInfoString = [self composeTrialInfoString];
    [self prepareDrawing];
    switch(state) {
        case kStateDrawBack:
            [optotypes fillCircleAtX: 0 y: 0 radius: radiusInPix];
            break;
        case kStateDrawFore://console.info("kStateDrawFore");
            if (!isMoving) { // detect first time
                isMoving = YES;  motionOffset = 0;
                [sound playNumber: kSoundTrialYes];
                discardKeyEntries = NO; // now allow responding
            }
            motionOffset += 1;
            let x, y;
            switch ([alternativesGenerator currentAlternative]) {
                case 0: x = motionOffset, y = 0;  break;
                case 2: x = 0, y = -motionOffset;  break;
                case 4: x = - motionOffset, y = 0;  break;
                case 6: x = 0, y = motionOffset;  break;
            }
            [optotypes fillCircleAtX: x y: y radius: radiusInPix];
            animationRequestID = window.requestAnimationFrame(function(timeStamp) {
                //console.info("frameAnimation", timeStamp)
                if (isMoving) {
                    if (motionOffset > viewWidth2) motionOffset -= viewWidth2;
                    [fractView display];
                }
            })
            break;
        default: break;
    }
    CGContextRestoreGState(cgc);
    CGContextSetFillColor(cgc, gColorBack);
    [super drawStimulusInRect: dirtyRect];
}


- (int) responseNumberFromChar: (CPString) keyChar {
    return [self responseNumber4FromChar: keyChar];
}


- (void) trialEnd { //console.info("FractControllerBalmMotion>trialEnd");
    isMoving = NO;
    window.cancelAnimationFrame(animationRequestID);
    [super trialEnd];
}


- (void) runEnd { //console.info("FractControllerBalm>runEnd");
    if (iTrial < nTrials) { //premature end
        [self setResultString: "Aborted"];
    } else {
        [self setResultString: [self composeResultString]];
    }
    [super runEnd];
}


- (float) resultValue4Export {
    const total = [trialHistoryController nCorrect] + [trialHistoryController nIncorrect];
    if ([trialHistoryController nTotal] != total) throw new Error("corret+incorrect ≠ total.");
    // ↑ should never occur
    const hitRateInPercent = 100 * [trialHistoryController nCorrect] / total;
    return hitRateInPercent;
}


- (CPString) composeResultString {
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
