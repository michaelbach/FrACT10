/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, michael.bach@uni-freiburg.de, <https://michaelbach.de>

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
    unsigned short responseKeyCode;
    CGContext cgc;
    float stimStrengthInThresholderUnits, stimStrengthInDeviceunits, viewWidth, viewHeight, viewWidth2, viewHeight2;
    float optotypeSizeInPix;
    float xEccInPix, yEccInPix; // eccentricity
    Thresholder thresholder;
    AlternativesGenerator alternativesGenerator;
    TrialHistoryController trialHistoryController;
    Optotypes optotypes;
    CPString trialInfoString @accessors;
    CPTimer timerDisplay, timerResponse, timerFixMark, timerRunEnd2, timerAutoResponse;
    CPString kRangeLimitDefault, kRangeLimitOk, kRangeLimitValueAtFloor, kRangeLimitValueAtCeiling, rangeLimitStatus, abortCharacter, ci95String;
    id sound @accessors;
    BOOL responseButtonsAdded;
    CPColor colOptotypeFore, colOptotypeBack;
}


- (id) initWithWindow: (CPWindow) aWindow parent: (HierarchyController) parent { //console.info("FractController>initWithWindow");
    self = [super initWithWindow: aWindow];
    if (self) {
        [[self window] setFullPlatformWindow: YES];
        if ([Misc isFullScreen]) {
            [[self window] setFrame: CGRectMake(0, 0, window.screen.width, window.screen.height)];
        }
        [self setParentController: parent];
        [aWindow setDelegate: self];
        viewWidth = CGRectGetWidth([aWindow frame]);  viewWidth2 = viewWidth / 2;
        viewHeight = CGRectGetHeight([aWindow frame]);  viewHeight2 = viewHeight / 2;
        state = kStateDrawBack;
        kRangeLimitDefault = "";  kRangeLimitOk = "rangeOK";  kRangeLimitValueAtFloor = "atFloor";
        kRangeLimitValueAtCeiling = "atCeiling";  rangeLimitStatus = kRangeLimitDefault;

        optotypes = [[Optotypes alloc] init];
        [Settings checkDefaults];
        colOptotypeFore = [Settings acuityForeColor];  colOptotypeBack = [Settings acuityBackColor];
        abortCharacter = "5";
        [[self parentController] setRunAborted: YES];
        [[self window] makeKeyAndOrderFront: self];  [[self window] makeFirstResponder: self];
        //[self performSelector: @selector(runStart) withObject: nil afterDelay: 0.01];//geht nicht mehr nach DEPLOY???
        [MDBDispersionEstimation initResultStatistics];  ci95String = "";
        //[self runStart];
        // [self testContrastDeviceThresholdConversion];
    }
    return self;
}


- (void) runStart { //console.info("FractController>runStart");
    gStrokeMinimal = 0.5; // smallest possible gap is ½pixel. Make into a Setting?
    gStrokeMaximal = viewHeight / (5 + [Settings margin4MaxOptotypeIndex]); // this leaves a margin of ½·index around the largest optotype
    if (!([Settings acuityFormatLogMAR] || [Settings acuityFormatDecimal] ||  [Settings acuityFormatSnellenFractionFoot])) {
        [Settings setAcuityFormatLogMAR: YES];  [Settings setAcuityFormatDecimal: YES]; // make sure not all formats are de-selected
    }
    responseButtonsAdded = NO;
    iTrial = 0;
    oldResponseKeyChar = " ";
    state = kStateDrawBack;
    alternativesGenerator = [[AlternativesGenerator alloc] initWithNumAlternatives: nAlternatives andNTrials: nTrials];
    thresholder = [[Thresholder alloc] initWithNumAlternatives: nAlternatives];
    trialHistoryController = [[TrialHistoryController alloc] initWithNumTrials: nTrials];
    responseWasCorrect = YES;  responseWasCorrectCumulative = YES;
    xEccInPix = -[MiscSpace pixelFromDegree: [Settings eccentXInDeg]];  yEccInPix = [MiscSpace pixelFromDegree: [Settings eccentYInDeg]]; //pos y: ↑
    optotypeSizeInPix = [MiscSpace pixelFromDegree: [Settings contrastOptotypeDiameter] / 60] / 5;
    [self trialStart];
}


/**
 This is a hook, for instance for the initial 4 acuity steps following DIN/ISO
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
    [alternativesGenerator nextAlternative];
    timerDisplay = [CPTimer scheduledTimerWithTimeInterval: [Settings timeoutDisplaySeconds] target:self selector:@selector(onTimeoutDisplay:) userInfo:nil repeats:NO];
    timerResponse = [CPTimer scheduledTimerWithTimeInterval: [Settings timeoutResponseSeconds] target:self selector:@selector(onTimeoutResponse:) userInfo:nil repeats:NO];
    if ([Settings autoRunIndex] > 0) {
        if ([kTestAcuityLett, kTestAcuityC, kTestAcuityE, kTestAcuityTAO, kTestContrastLett, kTestContrastC, kTestContrastE, kTestContrastG].includes(currentTestID)) {
            let time = 0.4;
            if ([kTestContrastLett, kTestContrastC, kTestContrastE, kTestContrastG].includes(currentTestID)) {
                time += [Settings contrastTimeoutFixmark] / 1000;
            }
            timerAutoResponse = [CPTimer scheduledTimerWithTimeInterval: 0.8 target:self selector:@selector(onTimeoutAutoResponse:) userInfo:nil repeats:NO];
        }
    }
    state = kStateDrawFore;  [[[self window] contentView] setNeedsDisplay: YES];
}


/**
 Standard things for all tests, including the display transform
 */
- (void) prepareDrawing { // console.info("FractController>prepareDrawing");
    cgc = [[CPGraphicsContext currentContext] graphicsPort];
    CGContextSetFillColor(cgc, colOptotypeBack);
    if (currentTestID == kTestAcuityTAO)
        CGContextSetFillColor(cgc, [CPColor whiteColor]); ;// contrast always 100% with TAO
    CGContextFillRect(cgc, [[self window] frame]);
    CGContextSaveGState(cgc);
    CGContextTranslateCTM(cgc,  viewWidth2, viewHeight2); // origin to center
    CGContextTranslateCTM(cgc,  -xEccInPix, -yEccInPix); // eccentric if desired
    switch ([Settings displayTransform]) { // mirroring etc.
        case 1: CGContextScaleCTM(cgc, -1, 1);  break;
        case 2: CGContextScaleCTM(cgc, 1, -1);  break;
        case 3: CGContextScaleCTM(cgc, -1, -1);  break;
    }
    CGContextSetFillColor(cgc, colOptotypeFore);
    [optotypes setCgc: cgc colFore: colOptotypeFore colBack: colOptotypeBack];
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
 Draw the trial info after everything else has been drawn
 */
- (void) drawStimulusInRect: (CGRect) dirtyRect { //console.info("FractController>drawStimulusInRect");
    if ([Settings trialInfo]) {
        CGContextSetTextPosition(cgc, 10, 10); // we assume here no transformed CGContext
        CGContextSetFillColor(cgc, colOptotypeFore);
        CGContextSetFillColor(cgc, [CPColor blackColor]);
        CGContextSelectFont(cgc, [Settings trialInfoFontSize] + "px sans-serif");
        CGContextShowText(cgc, trialInfoString);
    }
}


/**
 Draw touch controls
 */
- (void) drawTouchControls { // kTestAcuityTAO, kTestAcuityVernier: done in instance
    if ((![Settings enableTouchControls]) || (responseButtonsAdded)) return;
    let sze = 52, sze2 = sze / 2;
    switch  (currentTestID) {
        case kTestAcuityLett: case kTestContrastLett:
            sze = viewWidth / ((nAlternatives+1) * 1.4 + 1);
            for (let i = 0; i < nAlternatives; i++){
                [self buttonCenteredAtX: (i + 0.9) * 1.4 * sze y: viewHeight/2 - sze / 2 - 1
                                   size: sze title: [@"CDHKNORSVZØ" characterAtIndex: i]];
            }
            break;
        case kTestAcuityC: case kTestContrastC: case kTestContrastG:
            const radius = 0.5 * Math.min(viewWidth, viewHeight) - sze2 - 1;
            for (let i = 0; i < 8; i++) {
                if ( ([Settings nAlternatives] > 4)  || (![Misc isOdd: i])) {
                    let iConsiderObliqueOnly = i;
                    if (([Settings nAlternatives] == 4) && [Settings obliqueOnly])  iConsiderObliqueOnly++;
                    const ang = iConsiderObliqueOnly / 8 * 2 * Math.PI;
                    [self buttonCenteredAtX: viewWidth / 2 + Math.cos(ang) * radius y:  Math.sin(ang) * radius size: sze title: [@"632147899" characterAtIndex: iConsiderObliqueOnly]];
                }
            }
            break;
        case kTestAcuityE: case kTestContrastE:
            [self buttonCenteredAtX: viewWidth-sze2 y: 0 size: sze title: "6"];
            [self buttonCenteredAtX: sze2 y: 0 size: sze title: "4"];
            [self buttonCenteredAtX: viewWidth / 2 y: -viewHeight / 2 + sze2 size: sze title: "8"];
            [self buttonCenteredAtX: viewWidth / 2 y: viewHeight / 2 - sze2 size: sze title: "2"];
    }
    [self buttonCenteredAtX: viewWidth - sze2 - 1 y: viewHeight / 2 - sze2 - 1 size: sze title: "Ø"];
}
- (CPButton) buttonCenteredAtX: (float) x y: (float) y size: (float) size title: (CPString) title {
    [self buttonCenteredAtX: x y: y size: size title: title keyEquivalent: title];
}
- (CPButton) buttonCenteredAtX: (float) x y: (float) y size: (float) size title: (CPString) title keyEquivalent: (CPString) keyEquivalent { //console.info("FractControllerAcuityE>buttonAtX…", x, y, size, title, keyEquivalent);
    y = y + viewHeight / 2 // contentView is not affected by CGContextTranslateCTM, so I'm shifting y here to 0 at center
    const sze2 = size / 2;
    const button = [[CPButton alloc] initWithFrame: CGRectMake(x - sze2, y - sze2, size, size)];
    [button setTitle: title];  [button setKeyEquivalent: keyEquivalent];
    [button setTarget: self];  [button setAction: @selector(responseButton_action:)];
    [button setBezelStyle: CPRoundRectBezelStyle];
    [[[self window] contentView] addSubview: button];
    responseButtonsAdded = YES;
    return button;
}
- (IBAction) responseButton_action: (id) sender { //console.info("FractController>responseButton_action");
    responseKeyChar = [sender keyEquivalent]; //console.info("<",responseKeyChar,">");
    if (responseKeyChar == "Ø") [self runEnd];
    else [super processKeyDownEvent];
}


- (void) onTimeoutDisplay: (CPTimer) timer { //console.info("FractController>onTimeoutDisplay");
    state = kStateDrawBack;  [[[self window] contentView] setNeedsDisplay: YES];
}


- (void) onTimeoutResponse: (CPTimer) timer { //console.info("FractController>onTimeoutResponse");
    responseWasCorrect = NO;  [self trialEnd];
}


- (void) onTimeoutAutoResponse: (CPTimer) timer { //console.info("FractController>onTimeoutAutoResponse");
    const arIndex = [Settings autoRunIndex] - 1;
    if ([kTestAcuityLett, kTestAcuityC, kTestAcuityE, kTestAcuityTAO].includes(currentTestID)) {
        const logMARcurrent = [MiscSpace logMARfromDecVA: [MiscSpace decVAFromGapPixels: stimStrengthInDeviceunits]];
        let logMARtarget = [0.3, 0.0, -0.3][arIndex];
        if ([Settings threshCorrection]) logMARtarget += Math.log10(gThresholdCorrection4Ascending);
        responseWasCorrect = logMARcurrent > logMARtarget;
    }
    if ([kTestContrastLett, kTestContrastC, kTestContrastE].includes(currentTestID)) {
        responseWasCorrect = stimStrengthInDeviceunits < [1.0, 1.3, 1.6][arIndex];
    }
    if ([kTestContrastG].includes(currentTestID)) {
        const contrastMichelsonPercentCurrent = [self gratingContrastMichelsonPercentFromDeviceunits: stimStrengthInDeviceunits];
        responseWasCorrect = contrastMichelsonPercentCurrent > [10.0, 1.0, 0.3][arIndex];
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
}
- (void) trialEnd { //console.info("FractController>trialEnd");
    [self invalidateTrialTimers];
    [trialHistoryController setCorrect: responseWasCorrect]; // placed here so reached by "onTimeoutAutoResponse"
    [thresholder enterTrialOutcomeWithAppliedStim: [self stimThresholderunitsFromDeviceunits: stimStrengthInDeviceunits] wasCorrect: responseWasCorrect];
    switch ([Settings auditoryFeedback]) { // case 0: nothing
        case 1:
            [sound play1];  break;
        case 2:
            if (responseWasCorrect) [sound play1];  break;
        case 3:
            if (responseWasCorrect) [sound play1];
            else [sound play2];
            break;
    }
    [trialHistoryController trialEnded];
    [self trialStart];
}


- (void) runEnd { //console.info("FractController>runEnd");
    [self invalidateTrialTimers];
    const sv = [[[self window] contentView] subviews];
    for (const svi of sv) [svi removeFromSuperview];
    [[self window] close];
    [[self parentController] setRunAborted: (iTrial < nTrials)]; //premature end
    [[self parentController] setResultString: resultString];
    [[self parentController] setCurrentTestResultExportString: [self composeExportString]];
    // timer delay to give the screen time to update, thus giving immediate response feedback
    timerRunEnd2 = [CPTimer scheduledTimerWithTimeInterval: 0.02 target:self selector:@selector(onRunEnd2:) userInfo:nil repeats:NO];
}


- (void) onRunEnd2: (CPTimer) timer { //console.info("FractController>onRunEnd2");
    [trialHistoryController runEnded];
    [[self parentController] setCurrentTestResultsHistoryExportString: [trialHistoryController resultsHistoryString]];
    if ([Settings auditoryFeedbackWhenDone]) [sound play3];
    
    if ([Settings showCI95] && (![[self parentController] runAborted])) {
        if ([kTestAcuityLett, kTestAcuityC, kTestAcuityE, kTestAcuityTAO].includes(currentTestID)) {
            // the below causes a delay of < 1 s with 10,000 samples
            const historyResults = [trialHistoryController composeInfo4CI];
            const ciResults = [MDBDispersionEstimation calculateCIfromDF: historyResults guessingProbability: 1.0 / nAlternatives nSamples: 10000][0];
            const halfCI95 = (ciResults.CI0975 - ciResults.CI0025) / 2;
            ci95String = " ± " + [Misc stringFromNumber: halfCI95 decimals: 2 localised: YES];
            [[self parentController] setResultString: [self acuityComposeResultString]]; // this will add CI95 info
            
            [[self parentController] setCurrentTestResultExportString: [[self parentController] currentTestResultExportString] + tab + "halfCI95" + tab + [Misc stringFromNumber: halfCI95 decimals: 3 localised: YES]];
        }
    }
    [[self parentController] setCurrentTestResultExportString: [[self parentController] currentTestResultExportString] + crlf];
    [[self parentController] runEnd];
}


- (BOOL) acceptsFirstResponder { //console.info("FractController>acceptsFirstResponder");
    return YES;
}


/**
 Here's were we read the response keys
 */
- (void) keyDown: (CPEvent) theEvent { //console.info("FractController>keyDown");
    responseKeyChar = [[[theEvent characters] characterAtIndex: 0] uppercaseString];
    responseKeyCode = [theEvent keyCode];
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


- (CPString) testNameGivenTestID: (TestIDType) theTestID {
    switch (theTestID) {
        case kTestAcuityLett: return "Acuity_Letters";
        case kTestAcuityC: return "Acuity_LandoltC";
        case kTestAcuityE: return "Acuity_TumblingE";
        case kTestAcuityTAO: return "Acuity_TAO";
        case kTestAcuityVernier: return "Acuity_Vernier";
        case kTestContrastLett: return "Contrast_Letters";
        case kTestContrastC: return "Contrast_LandoltC";
        case kTestContrastE: return "Contrast_TumblingE";
        case kTestContrastG: return "Contrast_Grating";
        case kTestAcuityLineByLine: return "Acuity_LineByLine";
    }
    return "NOT ASSIGNED";
}


/**
 Generic part of the export string, used by both acuity & contrast
 */
- (CPString) generalComposeExportString { //console.info("FractController>generalComposeExportString");
    let s = "", now = [CPDate date];
    s += "Vs" + tab + [Settings versionExportFormat];
    s += tab + "vsFrACT" + tab + [Settings versionDateFrACT];
    s += tab + "decimalMark" + tab + [Settings decimalMarkChar];
    s += tab + "date" + tab + [Misc date2YYYY_MM_DD: now];
    s += tab + "time" + tab + [Misc date2HH_MM_SS: now];
    s += tab + "test" + tab + [self testNameGivenTestID: currentTestID];
    return s;
}


@end
