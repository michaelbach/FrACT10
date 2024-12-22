/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

2015-07-15 started
*/


@import "HierarchyController.j"
@import "AlternativesGenerator.j"
@import "Thresholder.j";
@import "Optotypes.j";
@import "TrialHistoryController.j"
@import "MDBDispersionEstimation.j"


@typedef StateType
kStateDrawBack = 0; kStateDrawFore = 1; kStateDrawFore2 = 2;


/**
 FractController
 
 The template controller for all tests. It inherits from HierarchyController
 to make communication with AppController easier.
 */
@implementation FractController: HierarchyController {
    int iTrial, nTrials, nAlternatives;
    StateType state;
    BOOL isBonusTrial, responseWasCorrect, responseWasCorrectCumulative;
    char oldResponseKeyChar, responseKeyChar;
    float stimStrengthInThresholderUnits, stimStrengthInDeviceunits, viewWidth, viewHeight, viewWidth2, viewHeight2;
    float strokeSizeInPix, spatialFreqCPD, contrastMichelsonPercent;
    float xEccInPix, yEccInPix; // eccentricity
    Thresholder thresholder;
    AlternativesGenerator alternativesGenerator, alternativesGeneratorEccentRandomizeX;
    TrialHistoryController trialHistoryController;
    Optotypes optotypes;
    CPString trialInfoString @accessors;
    CPTimer timerDisplay, timerResponse, timerFixMark, timerAutoResponse, timerIsi;
    CPString kRangeLimitDefault, kRangeLimitOk, kRangeLimitValueAtFloor, kRangeLimitValueAtCeiling, rangeLimitStatus, abortCharacter, ci95String;
    id sound @accessors;
    BOOL responseButtonsAdded;
    CPColor colorForeUndithered, colorBackUndithered;
}


- (void) updateViewWidthHeight {
    viewWidth = CGRectGetWidth([selfWindow frame]);  viewWidth2 = viewWidth / 2;
    viewHeight = CGRectGetHeight([selfWindow frame]);  viewHeight2 = viewHeight / 2;
}


- (id) initWithWindow: (CPWindow) aWindow parent: (HierarchyController) parent { //console.info("FractController>initWithWindow");
    self = [super initWithWindow: aWindow];
    if (self) {
        selfWindow = [self window];
        [selfWindow setFullPlatformWindow: YES];
        [self setParentController: parent];
        [aWindow setDelegate: self];
        [self updateViewWidthHeight];
        state = kStateDrawBack;
        kRangeLimitDefault = "";  kRangeLimitOk = "rangeOK";  kRangeLimitValueAtFloor = "atFloor";
        kRangeLimitValueAtCeiling = "atCeiling";  rangeLimitStatus = kRangeLimitDefault;
        gSpecialBcmDone = NO;

        optotypes = [[Optotypes alloc] init];
        [Settings checkDefaults];
        abortCharacter = "5";
        [[self parentController] setRunAborted: YES];
        [selfWindow makeKeyAndOrderFront: self];  [selfWindow makeFirstResponder: self];
        //[self performSelector: @selector(runStart) withObject: nil afterDelay: 0.01];//geht nicht mehr nach DEPLOY???
        [MDBDispersionEstimation initResultStatistics];  ci95String = "";
        //[self runStart];
        // [self unittestContrastDeviceThresholdConversion];
    }
    return self;
}


- (void) runStart { //console.info("FractController>runStart");
    [self updateViewWidthHeight];
    [[CPNotificationCenter defaultCenter] postNotificationName: "copyColorsFromSettings" object: nil]; // could have been overwritten
    gStrokeMinimal = [Settings minStrokeAcuity]; // smallest possible stroke is ½pixel. Made into a Setting.
    gStrokeMaximal = Math.min(viewHeight, viewWidth) / (5 + [Settings margin4maxOptotypeIndex]); // leave a margin of ½·index around the largest optotype
    if (!([Settings acuityFormatLogMAR] || [Settings acuityFormatDecimal] ||  [Settings acuityFormatSnellenFractionFoot])) {
        [Settings setAcuityFormatLogMAR: YES];  [Settings setAcuityFormatDecimal: YES]; // make sure not all formats are de-selected
    }
    responseButtonsAdded = NO;
    iTrial = 0;
    oldResponseKeyChar = " ";
    state = kStateDrawBack;
    const obliqueOnlyG = [self isGratingAny] && [Settings gratingObliqueOnly];
    alternativesGenerator = [[AlternativesGenerator alloc] initWithNumAlternatives: nAlternatives andNTrials: nTrials obliqueOnly: obliqueOnlyG];
    alternativesGenerator = [[AlternativesGenerator alloc] initWithNumAlternatives: nAlternatives andNTrials: nTrials obliqueOnly: obliqueOnlyG];
    if ([Settings eccentRandomizeX]) {
        alternativesGeneratorEccentRandomizeX = [[AlternativesGenerator alloc] initWithNumAlternatives: 2 andNTrials: nTrials obliqueOnly: NO];
    }
    thresholder = [[Thresholder alloc] initWithNumAlternatives: nAlternatives];
    trialHistoryController = [[TrialHistoryController alloc] initWithNumTrials: nTrials];
    responseWasCorrect = YES;  responseWasCorrectCumulative = YES;
    strokeSizeInPix = [MiscSpace pixelFromDegree: [Settings contrastOptotypeDiameter] / 60] / 5;
    [self trialStart];
}


/**
 This is a hook, for instance for the initial 4 acuity steps
 */
- (void) modifyDeviceStimulus { //console.info("FractController>modifyDeviceStimulus");
}


- (void) trialStart { //console.info("FractController>trialStart");
    iTrial += 1;
    stimStrengthInThresholderUnits = [thresholder nextStim2apply];//console.info("stimStrengthInThresholderUnits ", stimStrengthInThresholderUnits);
    [self modifyThresholderStimulus];// e.g. for bonus trials
    stimStrengthInDeviceunits = [self stimDeviceunitsFromThresholderunits: stimStrengthInThresholderUnits];//console.info("stimStrengthInDeviceunits ", stimStrengthInDeviceunits);
    if (iTrial > nTrials) { // testing after new stimStrength so we can use final threshold
        [self runEnd];  return;
    }
    [self modifyDeviceStimulus];// e.g. let the first 4 follow DIN
    if (gSpecialBcmDone) return;

    [alternativesGenerator nextAlternative];
    xEccInPix = -[MiscSpace pixelFromDegree: [Settings eccentXInDeg]];
    yEccInPix = [MiscSpace pixelFromDegree: [Settings eccentYInDeg]]; //pos y: ↑
    if ([Settings eccentRandomizeX]) {
        if ([alternativesGeneratorEccentRandomizeX nextAlternative] != 0)  {
            xEccInPix *= -1;
        }
    }
    timerIsi = [CPTimer scheduledTimerWithTimeInterval: [Settings timeoutIsiMillisecs] / 1000 target:self selector:@selector(onTimeoutIsi:) userInfo:nil repeats:NO];
}
- (void) onTimeoutIsi: (CPTimer) timer { // now we can draw the stimulus
    timerDisplay = [CPTimer scheduledTimerWithTimeInterval: [Settings timeoutDisplaySeconds] target:self selector:@selector(onTimeoutDisplay:) userInfo:nil repeats:NO];
    timerResponse = [CPTimer scheduledTimerWithTimeInterval: [Settings timeoutResponseSeconds] target:self selector:@selector(onTimeoutResponse:) userInfo:nil repeats:NO];
    if ([Settings autoRunIndex] != kAutoRunIndexNone) {
        if ([self isAcuityOptotype] || [self isContrastAny] || [self isAcuityGrating]) {
            let autoTime = 0.4 + [Settings timeoutIsiMillisecs] / 1000
            if ([self isContrastAny]) {
                autoTime += [Settings contrastTimeoutFixmark] / 1000;
            }
            timerAutoResponse = [CPTimer scheduledTimerWithTimeInterval: autoTime target:self selector:@selector(onTimeoutAutoResponse:) userInfo:nil repeats:NO];
        }
    }
    state = kStateDrawFore; [[selfWindow contentView] setNeedsDisplay: YES];
}


/**
 Standard things for all tests, includes the display transform
 */
- (void) prepareDrawing { //console.info("FractController>prepareDrawing");
    cgc = [[CPGraphicsContext currentContext] graphicsPort];
    CGContextSetFillColor(cgc, gColorBack);
    if ([self isAcuityTAO])
        CGContextSetFillColor(cgc, [CPColor whiteColor]); // contrast always 100% with TAO
    if ([self isContrastOptotype] && [Settings contrastDithering]) {
        CGContextSetFillColor(cgc, colorBackUndithered); // else black background briefly visible, dithering delay
        CGContextFillRect(cgc, [selfWindow frame]);
        CGContextSetFillColor(cgc, gColorBack);
    }
    CGContextFillRect(cgc, [selfWindow frame]);
    CGContextSaveGState(cgc);
    CGContextTranslateCTM(cgc,  viewWidth2, viewHeight2); // origin to center
    CGContextTranslateCTM(cgc,  -xEccInPix, -yEccInPix); // eccentric if desired
    switch ([Settings displayTransform]) { // mirroring etc.
        case 1: CGContextScaleCTM(cgc, -1, 1);  break;
        case 2: CGContextScaleCTM(cgc, 1, -1);  break;
        case 3: CGContextScaleCTM(cgc, -1, -1);  break;
    }
    CGContextSetFillColor(cgc, gColorFore);
}


/**
 At this time we have to undo the transform, so that the buttons in TAO are ok
 */
- (void) prepareDrawingTransformUndo {
    switch ([Settings displayTransform]) { // opposite sequence than above
        case 1: CGContextScaleCTM(cgc, -1, 1);  break;
        case 2: CGContextScaleCTM(cgc, 1, -1);  break;
        case 3: CGContextScaleCTM(cgc, -1, -1);  break;
    }
    CGContextTranslateCTM(cgc,  xEccInPix, yEccInPix);  CGContextTranslateCTM(cgc,  -viewWidth2, -viewHeight2);
}


/**
 Draw the trial info (top left) after everything else has been drawn
 */
- (void) drawStimulusInRect: (CGRect) dirtyRect { //console.info("FractController>drawStimulusInRect");
    if ([Settings trialInfo]) {
        CGContextSetTextPosition(cgc, 10, 10); // we assume here no transformed CGContext
        //CGContextSetFillColor(cgc, colOptotypeFore); would be unreadable with low contrast
        CGContextSetFillColor(cgc, [CPColor blackColor]);
        CGContextSelectFont(cgc, [Settings trialInfoFontSize] + "px sans-serif");
        CGContextShowText(cgc, trialInfoString);
    }
}


/**
 Embed in noise
 */
- (void) embedInNoise {
    if (![Settings embedInNoise]) return;
    if (!([self isAcuityOptotype] || [self isContrastOptotype])) return;
    let checksize = [self isContrastAny] ? strokeSizeInPix : stimStrengthInDeviceunits;
    checksize = Math.ceil(checksize / 5);
    const aCheck = CGRectMake(0, 0, checksize, checksize);
    const nx = Math.min(Math.ceil(viewWidth2 / checksize), 16 * 5);
    const ny = Math.min(Math.ceil(viewHeight2 / checksize), 16 * 5);
    const _alpha = [Settings noiseContrast] / 100;
    for (let ix = -nx; ix < nx; ix++) {
        for (let iy = -ny; iy < ny; iy++) {
            aCheck.origin.x = checksize * ix;
            aCheck.origin.y = checksize * iy;
            const lum = [MiscLight devicegrayFromLuminance: Math.random()];
            const col = [CPColor colorWithWhite: lum alpha: _alpha];
            CGContextSetFillColor(cgc, col);
            CGContextFillRect(cgc, aCheck);
        }
    }
}


/**
 Draw touch controls
 */
- (void) drawTouchControls {
    if ((![Settings enableTouchControls]) || (responseButtonsAdded)) return;
    let sze = 52, sze2 = sze / 2;
    switch  (currentTestID) {// kTestAcuityTAO, kTestAcuityVernier: done in instance
        case kTestAcuityLett: case kTestContrastLett:
            sze = viewWidth / ((nAlternatives+1) * 1.4 + 1);
            for (let i = 0; i < nAlternatives; i++) {
                [self buttonCenteredAtX: (i + 0.9) * 1.4 * sze y: viewHeight2 - sze2 - 1
                                   size: sze title: [@"CDHKNORSVZØ" characterAtIndex: i]];
            }
            break;
        case kTestAcuityC: case kTestContrastC: case kTestContrastG:
            const radius = 0.5 * Math.min(viewWidth, viewHeight) - sze2 - 1;
            for (let i = 0; i < 8; i++) {
                if ( ([Settings nAlternatives] > 4)  || (![Misc isOdd: i])) {
                    let iConsiderObliqueOnly = i;
                    if ((([Settings nAlternatives] == 4) && [Settings obliqueOnly])
                        || ([self isGratingAny] && [Settings gratingObliqueOnly])) iConsiderObliqueOnly++;
                    const ang = iConsiderObliqueOnly / 8 * 2 * Math.PI;
                    [self buttonCenteredAtX: viewWidth2 + Math.cos(ang) * radius y:  Math.sin(ang) * radius size: sze title: [@"632147899" characterAtIndex: iConsiderObliqueOnly]];
                }
            }
            break;
        case kTestAcuityE: case kTestContrastE:
            [self buttonCenteredAtX: viewWidth-sze2 y: 0 size: sze title: "6"];
            [self buttonCenteredAtX: sze2 y: 0 size: sze title: "4"];
            [self buttonCenteredAtX: viewWidth2 y: -viewHeight2 + sze2 size: sze title: "8"];
            [self buttonCenteredAtX: viewWidth2 y: viewHeight2 - sze2 size: sze title: "2"];
    }
    [self buttonCenteredAtX: viewWidth - sze2 - 1 y: viewHeight2 - sze2 - 1 size: sze title: "Ø"];
}
- (CPButton) buttonCenteredAtX: (float) x y: (float) y size: (float) size title: (CPString) title {
    [self buttonCenteredAtX: x y: y size: size title: title keyEquivalent: title];
}
- (CPButton) buttonCenteredAtX: (float) x y: (float) y size: (float) size title: (CPString) title keyEquivalent: (CPString) keyEquivalent { //console.info("FractControllerAcuityE>buttonAtX…", x, y, size, title, keyEquivalent);
    y = y + viewHeight2 // contentView is not affected by CGContextTranslateCTM, so I'm shifting y here to 0 at center
    const sze2 = size / 2;
    const button = [[CPButton alloc] initWithFrame: CGRectMake(x - sze2, y - sze2, size, size)];
    [button setTitle: title];  [button setKeyEquivalent: keyEquivalent];
    [button setTarget: self];  [button setAction: @selector(responseButton_action:)];
    [button setBezelStyle: CPRoundRectBezelStyle];
    [[selfWindow contentView] addSubview: button];
    responseButtonsAdded = YES;
    return button;
}
- (IBAction) responseButton_action: (id) sender { //console.info("FractController>responseButton_action");
    responseKeyChar = [sender keyEquivalent]; //console.info("<",responseKeyChar,">");
    if (responseKeyChar == "Ø") [self runEnd];
    else [super processKeyDownEvent];
}


- (void) onTimeoutDisplay: (CPTimer) timer { //console.info("FractController>onTimeoutDisplay");
    state = kStateDrawBack;  [[selfWindow contentView] setNeedsDisplay: YES];
}


- (void) onTimeoutResponse: (CPTimer) timer { //console.info("FractController>onTimeoutResponse");
    responseWasCorrect = NO;  [self trialEnd];
}


- (void) onTimeoutAutoResponse: (CPTimer) timer { //console.info("FractController>onTimeoutAutoResponse");
    const arIndex = [Settings autoRunIndex] - 1;
    if ([self isAcuityOptotype]) {
        const logMARcurrent = [MiscSpace logMARfromDecVA: [MiscSpace decVAFromStrokePixels: stimStrengthInDeviceunits]];
        let logMARtarget = [0.3, 0.0, -0.3][arIndex];
        if ([Settings threshCorrection]) logMARtarget += Math.log10(gThresholdCorrection4Ascending);
        responseWasCorrect = logMARcurrent > logMARtarget;
    }
    if ([self isContrastOptotype]) {
        responseWasCorrect = stimStrengthInDeviceunits < [1.0, 1.4, 1.8][arIndex];
    }
    if ([self isContrastG]) {
        //const contrastMichelsonPercentCurrent = [MiscLight contrastMichelsonPercentFromLogCSWeber: stimStrengthInDeviceunits]
        //responseWasCorrect = contrastMichelsonPercentCurrent > [30.0, 3.0, 0.3][arIndex];
        responseWasCorrect = contrastMichelsonPercent > [30.0, 3.0, 0.3][arIndex];
    }
    if ([self isAcuityGrating]) {
        responseWasCorrect = spatialFreqCPD < [0.3, 1, 10][arIndex];
    }

    [self trialEnd];
}


- (void) processKeyDownEvent { //console.info("FractController>processKeyDownEvent");
    const r = [self responseNumberFromChar: responseKeyChar];
    responseWasCorrect = (r == [alternativesGenerator currentAlternative]);
    [trialHistoryController setResponded: r];
    [trialHistoryController setPresented: [alternativesGenerator currentAlternative]];
    [self trialEnd];
}


- (void) invalidateTrialTimers {
    [timerDisplay invalidate];  timerDisplay = nil;
    [timerResponse invalidate];  timerResponse = nil;
    [timerAutoResponse invalidate];  timerAutoResponse = nil;
    [timerIsi invalidate];  timerIsi = nil;
}
- (void) trialEnd { //console.info("FractController>trialEnd");
    [self invalidateTrialTimers];

    CGContextSetFillColor(cgc, gColorBack); // need to clear for ISI to work
    CGContextFillRect(cgc, [selfWindow frame]);

    [trialHistoryController setCorrect: responseWasCorrect]; // placed here so reached by "onTimeoutAutoResponse"
    [thresholder enterTrialOutcomeWithAppliedStim: [self stimThresholderunitsFromDeviceunits: stimStrengthInDeviceunits] wasCorrect: responseWasCorrect];
    switch ([Settings auditoryFeedback4trial]) { // case 0: nothing
        case kAuditoryFeedback4trialAlways:
            [sound playNumber: kSoundTrialYes];  break;
        case kAuditoryFeedback4trialOncorrect:
            if (responseWasCorrect) [sound playNumber: kSoundTrialYes];  break;
        case kAuditoryFeedback4trialWithinfo:
            if (responseWasCorrect) [sound playNumber: kSoundTrialYes];
            else [sound playNumber: kSoundTrialNo];
            break;
    }
    [trialHistoryController trialEnded];
    [self trialStart];
}


- (async void) runEnd { //console.info("FractController>runEnd");
    [self invalidateTrialTimers];
    const sv = [[selfWindow contentView] subviews];
    for (const svi of sv) [svi removeFromSuperview];
    [selfWindow close];
    [[self parentController] setRunAborted: (iTrial < nTrials)]; //premature end
    [[self parentController] setResultString: resultString];
    [[self parentController] setCurrentTestResultExportString: [self composeExportString]];
    // delay to give the screen time to update for immediate response feedback
    await [Misc asyncDelaySeconds: 0.03];
    [trialHistoryController runEnded];
    const _parentController = [self parentController];
    [_parentController setCurrentTestResultsHistoryExportString: [trialHistoryController resultsHistoryString]];
    if ([Settings auditoryFeedback4run]) [sound playNumber: kSoundRunEnd];

    let _currentTestResultExportString = [_parentController currentTestResultExportString];
    if ([Settings showCI95] && (![_parentController runAborted])) {
        if ([self isAcuityOptotype]) {
            // the below causes a delay of < 1 s with 10,000 samples
            const historyResults = [trialHistoryController composeInfo4CI];
            const ciResults = [MDBDispersionEstimation calculateCIfromDF: historyResults guessingProbability: 1.0 / nAlternatives nSamples: 10000][0];
            const halfCI95 = (ciResults.CI0975 - ciResults.CI0025) / 2;
            ci95String = " ± " + [Misc stringFromNumber: halfCI95 decimals: 2 localised: YES];
            [_parentController setResultString: [self acuityComposeResultString]]; // this will add CI95 info
            _currentTestResultExportString += tab + "halfCI95" + tab + [Misc stringFromNumber: halfCI95 decimals: 3 localised: YES];
        }
    }
    if ([Settings isAcuityColor]) {
        if ([self isAcuityOptotype] && (![self isAcuityTAO])) {
            _currentTestResultExportString += tab + "colorForeBack" + tab + [gColorFore hexString] + tab + [gColorBack hexString];
        }
    }
    if ([Settings embedInNoise]) {
        if (([self isAcuityOptotype] || [self isContrastOptotype]) && (![self isAcuityTAO])) {
            _currentTestResultExportString += tab + "noiseContrast" + tab + [Misc stringFromInteger: [Settings noiseContrast]];
        }
    }
    [_parentController setCurrentTestResultExportString: _currentTestResultExportString + crlf];
    [_parentController runEnd];
}


- (BOOL) acceptsFirstResponder { //console.info("FractController>acceptsFirstResponder");
    return YES;
}


/**
 Here's were we read the response keys
 */
- (void) keyDown: (CPEvent) theEvent { //console.info("FractController>keyDown");
    responseKeyChar = [[[theEvent characters] characterAtIndex: 0] uppercaseString];
    const responseKeyCode = [theEvent keyCode];
    if ((responseKeyCode == CPEscapeKeyCode) || ((responseKeyChar == abortCharacter) && (oldResponseKeyChar == abortCharacter))) {
        [self runEnd];  return;
    }
    oldResponseKeyChar = responseKeyChar;
    if (responseKeyChar != abortCharacter) [self processKeyDownEvent];
}


/**
 "stimThresholderunits" are on a linear 0…1 scale
 "Deviceunits" are the corresponding pixels for acuity or logCSWeber for contrast
 */
- (float) stimThresholderunitsFromDeviceunits: (float) ntve {
    console.info("FractController>stimThresholderunitsFromDeviceunits OVERRIDE THIS!");
    return ntve;
}


- (float) stimDeviceunitsFromThresholderunits: (float) generic {
    console.info("FractController>stimDeviceunitsFromThresholderunits OVERRIDE THIS!");
    return generic;
}


- (void) modifyThresholderStimulusWithBonus {
    if (iTrial > nTrials) return; // don't change if done
    isBonusTrial = (iTrial % 6 == 0) && (iTrial != 6);
    if (isBonusTrial) stimStrengthInThresholderUnits = Math.min(stimStrengthInThresholderUnits + 0.2, 1.0);
}


/**
 Calculate ≤ or ≥ as needed. Needs to be inverted for LogMAR
 */
- (CPString) rangeStatusIndicatorStringInverted: (BOOL) invert {
    //console.info("FractController>rangeStatusIndicatorStringInverted");
    let sFloor = kRangeLimitValueAtFloor, sCeil = kRangeLimitValueAtCeiling, s = "";
    if (invert) {
        let sTemp = sCeil;  sCeil = sFloor;  sFloor = sTemp;
    }
    if (rangeLimitStatus == sFloor) {
        s += " ≥ ";
    } else {
        if (rangeLimitStatus == sCeil) {
            s += " ≤ ";
        } else {
            s += " ";
        }
    }
    //console.info(s);
    return s;
}


/**
 Generic part of the export string, used by both acuity & contrast
 */
- (CPString) generalComposeExportString { //console.info("FractController>generalComposeExportString");
    let s = "", now = [CPDate date];
    s += "Vs" + tab + gVersionOfExportFormat;
    s += tab + "vsFrACT" + tab + gVersionDateOfFrACT;
    s += tab + "decimalMark" + tab + [Settings decimalMarkChar];
    s += tab + "date" + tab + [Misc date2YYYY_MM_DD: now];
    s += tab + "time" + tab + [Misc date2HH_MM_SS: now];
    s += tab + "test" + tab + [self testNameGivenTestID: currentTestID];
    return s;
}
// in order to not mangle parameter sequence I'm tucking this addition at the end
- (CPString) generalComposeExportStringFinalize: (CPString) s {
    if ([Settings eccentXInDeg] != 0) {
        s += tab + "eccentricityX" + tab + [Misc stringFromNumber: [Settings eccentXInDeg] decimals: 1 localised: YES];
    }
    return s;
}

@end
