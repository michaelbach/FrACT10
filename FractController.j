//    History
//    =======
//
//    2015-07-15 started


@import "HierarchyController.j"
@import "Settings.j"
@import "AlternativesGenerator.j"
@import "Thresholder.j";
@import "Optotypes.j";


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
    responseWasCorrect = YES;  responseWasCorrectCumulative = YES;
    xEcc = [Misc pixelFromDegree: [Settings eccentXInDeg]];  yEcc = [Misc pixelFromDegree: [Settings eccentYInDeg]]; //pos y: ↓
    [self trialStart];
}


- (void) modifyDeviceStimulus {}


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


- (void) drawStimulusInRect: (CGRect) dirtyRect { //console.info("FractController>drawStimulusInRect");
    if ([Settings trialInfo]) {
        CGContextSetTextPosition(cgc, 10, 10); // we assume here no transformed CGContext
        CGContextSetFillColor(cgc, colOptotypeFore);
        CGContextSetFillColor(cgc, [CPColor blackColor]);
        CGContextShowText(cgc, trialInfoString);
    }

    if (currentTestName == "Acuity_Vernier") return; // don't do crowding with Vernier
    CGContextTranslateCTM(cgc,  viewWidth / 2, viewHeight / 2); // origin to center
    CGContextTranslateCTM(cgc,  -xEcc, -yEcc);
    var i;  //console.info([Settings crowdingType]);
    switch ([Settings crowdingType]) {
        case 0:  break;
        case 1:    // flanking rings
            for (i = -1; i <= 1; i++) { //console.info(i);
                var tempX = i * [self acuityCrowdingDistanceFromGap: stimStrengthInDeviceunits];
                CGContextTranslateCTM(cgc,  -tempX, 0);
                if (i != 0)  [self drawLandoltWithGapInPx: stimStrengthInDeviceunits landoltDirection: -1];
                CGContextTranslateCTM(cgc,  +tempX, 0);
            }  break;
        case 2:    // row of optotypes
            for (i = -2; i <= 2; i++) {
                var directionPresentedX = [Misc iRandom: nAlternatives];
                var tempX = i * [self acuityCrowdingDistanceFromGap: stimStrengthInDeviceunits];
                CGContextTranslateCTM(cgc,  -tempX, 0);
                if (i != 0)  [self drawLandoltWithGapInPx: stimStrengthInDeviceunits landoltDirection: directionPresentedX];
                CGContextTranslateCTM(cgc,  +tempX, 0);
            }  break;
        case 3:
            CGContextSetLineWidth(cgc, stimStrengthInDeviceunits);
            [self strokeCircleAtX: 0 y: 0 radius: 1.5 * [self acuityCrowdingDistanceFromGap: stimStrengthInDeviceunits] / 2];
            break;
        case 4:
            var frameSize = 1.5 * [self acuityCrowdingDistanceFromGap: stimStrengthInDeviceunits], frameSize2 = frameSize / 2;
            CGContextSetLineWidth(cgc, stimStrengthInDeviceunits);
            CGContextStrokeRect(cgc, CGRectMake(-frameSize2, -frameSize2, frameSize, frameSize));
            break;
    }
    CGContextTranslateCTM(cgc,  xEcc, yEcc);
}


- (CPButton) buttonCenteredAtX: (float) x y: (float) y size: (float) size title: (CPString) title { //console.info("FrACTControllerVAE>buttonAtX", x, y, size, title);
    [self buttonCenteredAtX: x y: y size: size title: title keyEquivalent: title];
}
- (CPButton) buttonCenteredAtX: (float) x y: (float) y size: (float) size title: (CPString) title keyEquivalent: (CPString) keyEquivalent { //console.info("FrACTControllerVAE>buttonAtX…", x, y, size, title, keyEquivalent);
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
- (IBAction) responseButton_action: (id) sender { //console.info("FrACTControllerVAE>responseButton_action");
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
    [self trialEnd];
}


- (void) trialEnd { //console.info("Fract>trialEnd");
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
    if ([Settings auditoryFeedbackWhenDone]) [sound play3];
    [[self parentController] runEnd];
}


- (CPString) format4SnellenInFeet: (float) decVA {
    var distanceInMetres = [Settings distanceInCM] / 100.0;
    var distanceInFeet = distanceInMetres * 3.28084;
    if ([Settings forceSnellen20])  distanceInFeet = 20;
    var s = [Misc stringFromNumber: distanceInFeet decimals: 0 localised: YES] + "/";
    s += [Misc stringFromNumber: (distanceInFeet / decVA) decimals: 0 localised: YES];
    return s;
}
/*private function format4SnellenInMeter(theAcuityResult):String {
 var distanceInMetres=Prefs.distanceInCM.n / 100.0, distanceInFeet=distanceInMetres * 3.28084;
 return Utils.DeleteTrailing_PointZero(Utils.rStrNInt(distanceInMetres, 1, Prefs.decimalPointChar)) + "/" + Utils.DeleteTrailing_PointZero(Utils.rStrNInt(distanceInMetres / theAcuityResult,1,Prefs.decimalPointChar));
 }*/


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
    console.info("FractController>stimThresholderunitsFromDeviceunits OVERRIDE!");
    return ntve;
}


- (float) stimDeviceunitsFromThresholderunits: (float) generic {
    console.info("FractController>stimDeviceunitsFromThresholderunits OVERRIDE!");
    return generic;
}


///////////////////////// ACUITY UTILs

/*	Transformation formula:   gap = c1 * exp(tPest * c2).
 Constants c1 and c2 are determined by thesse 2 contions: tPest==0 → gap=gapMinimal;  tPest==1 → gap=gapMaximal.
 =>c2 = ln(gapMinimal / gapMaximal)/(0 - 1);  c1 = gapMinimal / exp(0 * c2)  */
- (float) acuitystimDeviceunitsFromThresholderunits: (float) tPest { //console.info("FractControllerVAC>stimDeviceunitsFromThresholderunits");
    var c2 = - Math.log(gapMinimal / gapMaximal), c1 = gapMinimal;
    var deviceVal = c1 * Math.exp(tPest * c2); //console.info("DeviceFromPest " + tPest + " " + deviceVal);
    // ROUNDING for realisable gap values? @@@
    if ([Misc areNearlyEqual: deviceVal and: gapMaximal]) {
        if (!isBonus) {
            rangeLimitStatus = kRangeLimitValueAtCeiling; //console.info("max gap size!")
        }
    } else {
        if  ([Misc areNearlyEqual: deviceVal and: gapMinimal]) {
            rangeLimitStatus = kRangeLimitValueAtFloor; //console.info("min gap size!");
        } else {
            rangeLimitStatus = kRangeLimitOk;
        }
    }
    return deviceVal;
}
        

- (float) acuitystimThresholderunitsFromDeviceunits: (float) d { //console.info("FractControllerVAC>stimThresholderunitsFromDeviceunits");
    var c2 = - Math.log(gapMinimal / gapMaximal), c1 = gapMinimal;
    var retVal = Math.log(d / c1) / c2; //console.info("PestFromDevice " + d + " " + retVal);
    return retVal;
}


- (CPString) acuityComposeTrialInfoString {
    var s = iTrial + "/" + nTrials + " ";
    s += [Misc stringFromNumber: [Misc visusFromGapPixels: stimStrengthInDeviceunits] decimals: 2 localised: YES];
    return s;
}


- (float) acuityResultInDecVA {
    var resultInGapPx = stimStrengthInDeviceunits;
    var resultInDecVA = [Misc visusFromGapPixels: resultInGapPx];
    resultInDecVA *= ([Settings threshCorrection]) ? 0.891 : 1.0;// Korrektur für Schwellenunterschätzung aufsteigender Verfahren
    return resultInDecVA;
}


- (floag) acuityResultInLogMAR {
    return [Misc logMARfromDecVA: [self acuityResultInDecVA]];
}


// calculates ≤ or ≥ as needed. Needs to be inverted for LogMAR
- (CPString) rangeStatusIndicatorStringInverted: (BOOL) invert {
    var sFloor = kRangeLimitValueAtFloor, sCeil = kRangeLimitValueAtCeiling, s = "";
    if (invert) {
        var sTemp = sCeil; sCeil = sFloor; sFloor = sTemp;
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


- (CPString) acuityComposeResultString {
    var resultInGapPx = stimStrengthInDeviceunits;
    var resultInDecVA = [Misc visusFromGapPixels: resultInGapPx];
    resultInDecVA *= ([Settings threshCorrection]) ? 0.891 : 1.0;// Korrektur für Schwellenunterschätzung aufsteigender Verfahren
    resultInDecVA = Math.min([Settings maxDisplayedAcuity], resultInDecVA);
    var resultInLogMAR = [Misc logMARfromDecVA: resultInDecVA];
    
    // console.info("rangeLimitStatus: ", rangeLimitStatus);
    var s = "";
    if ([Settings acuityFormatLogMAR]) {
        if (s.length > 1) s += ",  ";
        s += "LogMAR:" + [self rangeStatusIndicatorStringInverted: YES];
        s += [Misc stringFromNumber: resultInLogMAR decimals: 2 localised: YES];
    }
    if ([Settings acuityFormatDecimal]) {
        if (s.length > 1) s += ",  ";
        s += "decVA:" + [self rangeStatusIndicatorStringInverted: NO];
        s += [Misc stringFromNumber: resultInDecVA decimals: 2 localised: YES];
    }
    if ([Settings acuityFormatSnellenFractionFoot]) {
        if (s.length > 1) s += ",  ";
        s += "Snellen fraction:" +  [self rangeStatusIndicatorStringInverted: NO];
        s += [self format4SnellenInFeet: resultInDecVA];
    }
    return s;
}


- (float) acuityResultValue4Export {
    return [self acuityResultInLogMAR];
}


- (CPString) acuityComposeExportString { //console.info("FractController>composeExportString");
    var s = "";
    if ([[self parentController] runAborted]) return;
    var tab = "\t", crlf = "\n", nDigits = 4, now = [CPDate date];
    s = "Vs" + tab + "3"; // version
    s += tab + "decimalMark" + tab + [Settings decimalMarkChar];
    s += tab + "date" + tab + [Misc date2YYYY_MM_DD: now] + tab + "time" + tab + [Misc date2HH_MM_SS: now];
    s += tab + "test" + tab + currentTestName;
    s += tab + "value" + tab + [Misc stringFromNumber: [self resultValue4Export] decimals: nDigits localised: YES];
    s += tab + "unit" + tab + currentTestResultUnit
    s += tab + "distanceInCm" + tab + [Misc stringFromNumber: [Settings distanceInCM] decimals: 1 localised: YES];
    s += tab + "contrastWeber" + tab + [Misc stringFromNumber: [Settings contrastAcuityWeber] decimals: 1 localised: YES];
    s += tab + "unit" + tab + "%";
    s += tab + "nTrials" + tab + [Misc stringFromNumber: nTrials decimals: 0 localised: YES];
    s += tab + "rangeLimitStatus" + tab + rangeLimitStatus;
    //s += tab + "XX" + tab + YY;
    s += crlf; //console.info("FractController>date: ", s);
    return s;
}


- (void) modifyThresholderStimulusWithBonus {
    if (iTrial > nTrials) return; // don't change if done
    isBonus = (iTrial % 6 == 0) && (iTrial != 6);
    if (isBonus) stimStrengthInThresholderUnits = Math.min(stimStrengthInThresholderUnits + 0.2, 1.0);
}


- (void) acuityModifyDeviceStimulusDIN01_02_04_08 {
    responseWasCorrectCumulative = responseWasCorrectCumulative && responseWasCorrect;
     switch (iTrial) {
        case 1:  stimStrengthInDeviceunits = [Misc gapPixelsFromVisus: 0.1];  break;
        case 2:  if (responseWasCorrectCumulative) stimStrengthInDeviceunits = [Misc gapPixelsFromVisus: 0.2];  break;
        case 3:  if (responseWasCorrectCumulative) stimStrengthInDeviceunits = [Misc gapPixelsFromVisus: 0.4];  break;
        case 4:  if (responseWasCorrectCumulative) stimStrengthInDeviceunits = [Misc gapPixelsFromVisus: 0.8];  break;
    }
}


- (float) acuityCrowdingDistanceFromGap: (float) gap {
    var returnVal = 5 * gap + 2 * gap; // case 0
    switch ([Settings crowdingDistanceCalculationType]) {
        case 1:
            returnVal = 5 * gap + [Misc pixelFromDegree: 2.6 / 60.0];  break;
        case 2:
            returnVal = [Misc pixelFromDegree: 30 / 60.0];  break;
        case 3:
            returnVal = 10 * gap;  break;
    }
    return returnVal;
}


@end
