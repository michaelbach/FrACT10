/*
 This file is part of FrACT10, a vision test battery.
 Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 2025-03-05 created class "FractControllerBalmMotion" inheriting from "FractController"
 */


@import "FractControllerBalm.j"


@implementation FractControllerBalmMotion: FractControllerBalm {
    float motionOffset, radiusInPix, speedInPixPerSec, dotCenterDist, motionJumpBack;
    BOOL isMoving;
    id animationRequestID;
    id animationTimeStamp;
    int dotgridNY, dotgridNX;
    id dotsX, dotsY;
}


- (void) runStart { //console.info("FractControllerBalmMotion>runStart");
    nAlternatives = 4;  nTrials = [Settings nTrials04];
    animationRequestID = 0;
    radiusInPix = 0.5 * [MiscSpace pixelFromDegree: [Settings balmMotionDiameterInDeg]];
    if (radiusInPix > 0.1 * Math.min(viewWidth, viewHeight)) {
        [self alertProblemOfDiameter: [Settings balmMotionDiameterInDeg]];
    }
    speedInPixPerSec = [MiscSpace pixelFromDegree: [Settings balmSpeedInDegPerSec]];
    dotCenterDist = radiusInPix * 4;
    dotgridNX = Math.ceil((3 * viewWidth) / dotCenterDist); //create x/y arrays for the dots
    dotgridNY = Math.ceil((3 * viewHeight) / dotCenterDist);
    dotsX = [dotgridNX]; //allocate the dots position arrays
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


- (void) drawAllDotsDx: (float) dx dy: (float) dy {
    const er = extentInPix + radiusInPix;
    for (let x = 0; x < dotgridNX; x++) {
        for (let y = 0; y < dotgridNY; y++) {
            const dotX = dotsX[x][y] + dx, dotY = dotsY[x][y] + dy;
            const inside = (dotX > -er) && (dotX < er) && (dotY > -er) && (dotY < er);
            if (inside)  [optotypes fillCircleAtX: dotX y: dotY radius: radiusInPix];
        }
    }
}


- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView { //console.info("FractControllerBalmMotion>drawStimulusInRect, state: ", state);
    trialInfoString = [self composeTrialInfoString];
    [self prepareDrawing];
    switch(state) {
        case kStateDrawBack:
            [self drawAllDotsDx: 0 dy: 0];
            break;
        case kStateDrawFore://console.info("kStateDrawFore");
            if (!isMoving) { //detect first time
                [sound playNumber: kSoundTrialStart];
                isMoving = YES;  motionOffset = 0;  animationTimeStamp = -1;
                discardKeyEntries = NO; //now allow responding
            }
            let dx, dy;
            switch ([alternativesGenerator currentAlternative]) {
                case 0: dx = motionOffset; dy = 0;  break;
                case 2: dx = 0; dy = -motionOffset;  break;
                case 4: dx = - motionOffset; dy = 0;  break;
                case 6: dx = 0; dy = motionOffset;  break;
            }
            [self drawAllDotsDx: dx dy: dy];
            animationRequestID = window.requestAnimationFrame(function(timeStamp) {
                //console.info("frameAnimation", timeStamp)
                if (isMoving) {
                    if (animationTimeStamp < 0) animationTimeStamp = timeStamp;
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
    [super drawStimulusInRect: dirtyRect forView: fractView];
}


- (void) trialEnd { //console.info("FractControllerBalmMotion>trialEnd");
    isMoving = NO;
    window.cancelAnimationFrame(animationRequestID);
    [super trialEnd];
}


@end
