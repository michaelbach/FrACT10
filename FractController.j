//    History
//    =======
//
//    2015-07-15 started


@import "Globals.j"
@import "Settings.j"
@import "AlternativesGenerator.j"
@import "Thresholder.j";
@import "Optotypes.j";
@import "HierarchyController.j"
@import "TrialHistoryController.j"


@typedef StateType
kStateDrawBack = 0; kStateDrawFore = 1; kStateDrawFore2 = 2;


@implementation FractController: HierarchyController {
    int iTrial, nTrials, nAlternatives;
    StateType state;
    BOOL isBonus, responseWasCorrect, responseWasCorrectCumulative;
    char oldResponseKeyChar, responseKeyChar;
    unsigned short responseKeyCode;
    CGContext cgc;
    float stimStrengthInThresholderUnits, stimStrengthInDeviceunits, viewWidth, viewHeight;
    float gapMinimal, gapMaximal;
    float xEcc, yEcc; // eccentricity
    Thresholder thresholder;
    AlternativesGenerator alternativesGenerator;
    TrialHistoryController trialHistoryController;
    Optotypes optotypes;
    CPString trialInfoString @accessors;
    CPTimer timerDisplay, timerResponse, timerFixMark;
    CPString kRangeLimitDefault, kRangeLimitOk, kRangeLimitValueAtFloor, kRangeLimitValueAtCeiling, rangeLimitStatus, abortCharacter;
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
        viewWidth = CGRectGetWidth([aWindow frame]);  viewHeight = CGRectGetHeight([aWindow frame]);
        gapMinimal = 0.5;  gapMaximal = viewHeight / 5 - 2;
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
        [self setCurrentTestName: "NOT ASSIGNED"];  [self setCurrentTestResultUnit: "NOT ASSIGNED"];
        [self runStart];
        // [self testContrastDeviceThresholdConversion];
    }
    return self;
}


- (void) runStart { //console.info("FractController>runStart");
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
    xEcc = -[Misc pixelFromDegree: [Settings eccentXInDeg]];  yEcc = [Misc pixelFromDegree: [Settings eccentYInDeg]]; //pos y: ↑
    [self trialStart];
}


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
    state = kStateDrawFore;  [[[self window] contentView] setNeedsDisplay: YES];
}


- (void) prepareDrawing { // console.info("FractController>prepareDrawing");
    cgc = [[CPGraphicsContext currentContext] graphicsPort];
    CGContextSetFillColor(cgc, colOptotypeBack);
    if (currentTestName == "Acuity_TAO")
        CGContextSetFillColor(cgc, [CPColor whiteColor]); ;// contrast not respected with TAO
    CGContextFillRect(cgc, [[self window] frame]);
    CGContextSaveGState(cgc);
    CGContextTranslateCTM(cgc,  viewWidth / 2, viewHeight / 2); // origin to center
    CGContextTranslateCTM(cgc,  -xEcc, -yEcc);
    switch ([Settings displayTransform]) {
        case 1: CGContextScaleCTM(cgc, -1, 1);  break;
        case 2: CGContextScaleCTM(cgc, 1, -1);  break;
        case 3: CGContextScaleCTM(cgc, -1, -1);  break;
    }
    CGContextSetFillColor(cgc, colOptotypeFore);
    [optotypes setCgc: cgc colFore: colOptotypeFore colBack: colOptotypeBack];
}

- (void) prepareDrawingTransformUndo {
    CGContextTranslateCTM(cgc,  -viewWidth / 2, -viewHeight / 2); // origin to center
    CGContextTranslateCTM(cgc,  xEcc, yEcc);
    switch ([Settings displayTransform]) {
        case 1: CGContextScaleCTM(cgc, -1, 1);  break;
        case 2: CGContextScaleCTM(cgc, 1, -1);  break;
        case 3: CGContextScaleCTM(cgc, -1, -1);  break;
    }
}


// this draws the trial info after everything else has been drawn
- (void) drawStimulusInRect: (CGRect) dirtyRect { //console.info("FractController>drawStimulusInRect");
    if ([Settings trialInfo]) {
        CGContextSetTextPosition(cgc, 10, 10); // we assume here no transformed CGContext
        CGContextSetFillColor(cgc, colOptotypeFore);
        CGContextSetFillColor(cgc, [CPColor blackColor]);
        CGContextShowText(cgc, trialInfoString);
    }
}


- (CPButton) buttonCenteredAtX: (float) x y: (float) y size: (float) size title: (CPString) title { //console.info("FractControllerAcuityE>buttonAtX", x, y, size, title);
    [self buttonCenteredAtX: x y: y size: size title: title keyEquivalent: title];
}
- (CPButton) buttonCenteredAtX: (float) x y: (float) y size: (float) size title: (CPString) title keyEquivalent: (CPString) keyEquivalent { //console.info("FractControllerAcuityE>buttonAtX…", x, y, size, title, keyEquivalent);
    y = y + viewHeight / 2 // contentView is not affected by CGContextTranslateCTM, so I'm shifting y here to 0 at center
    var sze2 = size / 2;
    var button = [[CPButton alloc] initWithFrame: CGRectMake(x - sze2, y - sze2, size, size)];
    [button setTitle: title];  [button setKeyEquivalent: keyEquivalent];
    [button setTarget: self];  [button setAction: @selector(responseButton_action:)];
    [button setBezelStyle: CPRoundedBezelStyle];
    [[[self window] contentView] addSubview: button];
    responseButtonsAdded = YES;
    return button;
}
- (IBAction) responseButton_action: (id) sender { //console.info("FractControllerAcuityE>responseButton_action");
    responseKeyChar = [sender keyEquivalent];
    //console.info("<",responseKeyChar,">");
    if (responseKeyChar == "Ø") {
        [self runEnd];
    } else [super processKeyDownEvent];
}


/*-(void) onTimeoutFirstResponder: (CPTimer) timer { //console.info("FractController>onTimerFirstResponder");
    [[self window] makeFirstResponder: self];
}*/

- (void) onTimeoutDisplay: (CPTimer) timer { //console.info("FractController>onTimeoutDisplay");
    state = kStateDrawBack;  [[[self window] contentView] setNeedsDisplay: YES];
}


- (void) onTimeoutResponse: (CPTimer) timer { //console.info("FractController>onTimeoutResponse");
    responseWasCorrect = NO;  [self trialEnd];
}


- (void) processKeyDownEvent { //console.info("FractController>processKeyDownEvent");
    var r = [self responseNumberFromChar: responseKeyChar];
    responseWasCorrect = (r == [alternativesGenerator currentAlternative]);
    [trialHistoryController setResponded: r];
    [trialHistoryController setPresented: [alternativesGenerator currentAlternative]];
    [trialHistoryController setCorrect: responseWasCorrect];
    [self trialEnd];
}


- (void) trialEnd { //console.info("FractController>trialEnd");
    [timerDisplay invalidate];  timerDisplay = nil;  [timerResponse invalidate];  timerResponse = nil;//nötig?
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
    var sv = [[[self window] contentView] subviews];
    for (var i = 0; i < sv.length; i++) [sv[i] removeFromSuperview];

    [timerDisplay invalidate];  timerDisplay = nil;
    [timerResponse invalidate];  timerResponse = nil;
    [[self window] close];
    [[self parentController] setRunAborted: (iTrial < nTrials)]; //premature end
    [[self parentController] setResultString: resultString];
    [[self parentController] setCurrentTestResultExportString: [self composeExportString]];
    
    [trialHistoryController runEnded];
    [[self parentController] setCurrentTestResultsHistoryExportString: [trialHistoryController resultsHistoryString]];
    if ([Settings auditoryFeedbackWhenDone]) [sound play3];
    [[self parentController] runEnd];
}


- (BOOL) acceptsFirstResponder { //console.info("FractController>acceptsFirstResponder");
    return YES;
}

- (void) keyDown: (CPEvent) theEvent { //console.info("FractController>keyDown");
    responseKeyChar = [[[theEvent characters] characterAtIndex: 0] uppercaseString];
    responseKeyCode = [theEvent keyCode];
    if ((responseKeyCode == CPEscapeKeyCode) || ((responseKeyChar == abortCharacter) && (oldResponseKeyChar == abortCharacter))) {
        [self runEnd];  return;
    }
    oldResponseKeyChar = responseKeyChar;
    if (responseKeyChar != abortCharacter) [self processKeyDownEvent];
}

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
    isBonus = (iTrial % 6 == 0) && (iTrial != 6);
    if (isBonus) stimStrengthInThresholderUnits = Math.min(stimStrengthInThresholderUnits + 0.2, 1.0);
}


// calculates ≤ or ≥ as needed. Needs to be inverted for LogMAR
- (CPString) rangeStatusIndicatorStringInverted: (BOOL) invert {
    var sFloor = kRangeLimitValueAtFloor, sCeil = kRangeLimitValueAtCeiling, s = "";
    if (invert) {
        var sTemp = sCeil;  sCeil = sFloor;  sFloor = sTemp;
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
    return s;
}


- (CPString) generalComposeExportString { // used by acuity & contrast
    var s = "", now = [CPDate date];
    s += "Vs" + tab + [Settings versionExportFormat];
    s += tab + "vsFrACT" + tab + [Settings versionDateFrACT];
    s += tab + "decimalMark" + tab + [Settings decimalMarkChar];
    s += tab + "date" + tab + [Misc date2YYYY_MM_DD: now];
    s += tab + "time" + tab + [Misc date2HH_MM_SS: now];
    s += tab + "test" + tab + currentTestName;
    return s;
}


@end
