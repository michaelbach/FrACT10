/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>
 
 2025-03-05 created class "FractControllerBalmMotion" inheriting from "FractController"
 */


@import "FractController.j"
@implementation FractControllerBalmMotion: FractController {
    float motionOffset, radiusInPix, speedInPixPerSec, dotCenterDist, motionJumpBack;
    BOOL isMoving;
    id animationRequestID;
    id animationTimeStamp;
    int dotgridNY, dotgridNX;
    id dotsX, dotsY;
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
    dotCenterDist = radiusInPix * 4;
    dotgridNX = Math.ceil((3 * viewWidth) / dotCenterDist); // create x/y arrays for the dots
    dotgridNY = Math.ceil((3 * viewHeight) / dotCenterDist);
    dotsX = [dotgridNX]; // allocate the dots position arrays
    for (let i = 0; i < dotgridNX; i++) dotsX[i] = [dotgridNY];
    dotsY = [dotgridNX];
    for (let i = 0; i < dotgridNX; i++) dotsY[i] = [dotgridNY];
    [super runStart];
}


- (void) trialStart {
    [super trialStart];
    const xsPerScreen = Math.ceil(dotgridNX / 3), ysPerScreen = Math.ceil(dotgridNY / 3);
    const jitter = dotCenterDist / 2;
    for (let x = 0; x < dotgridNX; x++) {
        for (let y = 0; y < dotgridNY; y++) {
            dotsX[x][y] = (x - xsPerScreen) * dotCenterDist + jitter * (Math.random() - 0.5);
            dotsY[x][y] = (y - ysPerScreen) * dotCenterDist + jitter * (Math.random() - 0.5);
        }
    }
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerBalmMotion>drawStimulusInRect, state: ", state);
    trialInfoString = [self composeTrialInfoString];
    [self prepareDrawing];
    switch(state) {
        case kStateDrawBack:
            for (let x = 0; x < dotgridNX; x++) {
                for (let y = 0; y < dotgridNY; y++) {
                    [optotypes fillCircleAtX: dotsX[x][y] y: dotsY[x][y] radius: radiusInPix];
                }
            }
            break;
        case kStateDrawFore://console.info("kStateDrawFore");
            if (!isMoving) { // detect first time
                isMoving = YES;  motionOffset = 0;  animationTimeStamp = -1;
                [sound playNumber: kSoundTrialYes];
                discardKeyEntries = NO; // now allow responding
            }
            let dx, dy;
            switch ([alternativesGenerator currentAlternative]) {
                case 0: dx = motionOffset; dy = 0;  break;
                case 2: dx = 0; dy = -motionOffset;  break;
                case 4: dx = - motionOffset; dy = 0;  break;
                case 6: dx = 0; dy = motionOffset;  break;
            }
            for (let x = 0; x < dotgridNX; x++) {
                for (let y = 0; y < dotgridNY; y++) {
                    [optotypes fillCircleAtX: dotsX[x][y]+dx y: dotsY[x][y]+dy radius: radiusInPix];
                }
            }
            animationRequestID = window.requestAnimationFrame(function(timeStamp) {
                //console.info("frameAnimation", timeStamp)
                if (isMoving) {
                    if (animationTimeStamp < 0) animationTimeStamp = timeStamp
                    const deltaTSecs = (timeStamp - animationTimeStamp) / 1000;
                    animationTimeStamp = timeStamp;
                    motionOffset += speedInPixPerSec * deltaTSecs;
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
    s += tab + "dotDia" + tab + [Settings balmDiameterInDeg];
    return [self generalComposeExportStringFinalize: s];
}


@end
