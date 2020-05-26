//    History
//    =======
//
//    2015-07-15 started

@import "HierarchyController.j"
@import "Settings.j"
@import "AlternativesGenerator.j"
@import "Thresholder.j";

@implementation FractController: HierarchyController {
    int state, kStateDrawBack, kStateDrawFore, iTrial, nTrials, nAlternatives;
    BOOL isBonus, responseWasCorrect, responseWasCorrectCumulative;
    char oldResponseKeyChar, responseKeyChar;
    unsigned short responseKeyCode;
    CGContext cgc;
    float stimStrengthGeneric, stimStrengthInDeviceunits, viewWidth, viewHeight;
    float gapMinimal, gapMaximal;
    float currentX, currentY; // for drawing
    Thresholder thresholder;
    AlternativesGenerator alternativesGenerator;
    CPString trialInfoString @accessors;
    CPTimer timerDisplay, timerResponse, timerFirstResponder;
    CPString kRangeLimitDefault, kRangeLimitOk, kRangeLimitValueAtFloor, kRangeLimitValueAtCeiling, rangeLimitStatus, abortCharacter;
    id sound @accessors;
}


- (id) initWithWindow: (CPWindow) aWindow parent: (HierarchyController) parent { //console.log("FractController>initWithWindow");
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
        kStateDrawBack = 0; kStateDrawFore = 1;
        state = kStateDrawBack;
        kRangeLimitDefault = "";  kRangeLimitOk = "rangeOK";  kRangeLimitValueAtFloor = "atFloor";
        kRangeLimitValueAtCeiling = "atCeiling";  rangeLimitStatus = kRangeLimitDefault;

        [self setColOptotypeFore: [[self parentController] colOptotypeFore]];
        [self setColOptotypeBack: [[self parentController] colOptotypeBack]];
        [Settings checkDefaults];
        abortCharacter = "5";
        nTrials = [Settings nTrials];
        nAlternatives = [Settings nAlternatives];
        [[self parentController] setRunAborted: YES];
        [[self window] makeKeyAndOrderFront: self];  [[self window] makeFirstResponder: self];
        //[self performSelector: @selector(runStart) withObject: nil afterDelay: 0.01];//geht nicht mehr nach DEPLOY???
        [self runStart];
    }
    return self;
}


- (void) runStart { //console.log("FractController>runStart");
    timerFirstResponder = [CPTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onTimerFirstResponder:) userInfo:nil repeats:YES];
    iTrial = 0;
    oldResponseKeyChar = " ";
    state = kStateDrawBack;
    alternativesGenerator = [[AlternativesGenerator alloc] initWithNumAlternatives: nAlternatives andNTrials: nTrials];
    thresholder = [[Thresholder alloc] initWithNumAlternatives: nAlternatives];
    responseWasCorrect = YES;  responseWasCorrectCumulative = YES;
    [self trialStart];
}


- (void) trialStart { //console.log("FractController>trialStart");
    iTrial += 1;
    stimStrengthGeneric = [thresholder nextStim2apply];//console.log("stimStrengthGeneric ", stimStrengthGeneric);
    [self modifyGenericStimulus];// e.g. for bonus trials
    stimStrengthInDeviceunits = [self stimDeviceFromGeneric: stimStrengthGeneric];//console.log("stimStrengthInDeviceunits ", stimStrengthInDeviceunits);
    if (iTrial > nTrials) { // testing after new stimStrength so we can use final threshold
        [self runEnd];  return;
    }
    [self modifyDeviceStimulus];// e.g. let the first 4 follow DIN
    [alternativesGenerator nextAlternative];
    timerDisplay = [CPTimer scheduledTimerWithTimeInterval: [Settings timeoutDisplaySeconds] target:self selector:@selector(onTimeoutDisplay:) userInfo:nil repeats:NO];
    timerResponse = [CPTimer scheduledTimerWithTimeInterval: [Settings timeoutResponseSeconds] target:self selector:@selector(onTimeoutResponse:) userInfo:nil repeats:NO];
    
    state = kStateDrawFore;  [[[self window] contentView] setNeedsDisplay: YES];
}


- (void) drawStimulusInRect: (CGRect) dirtyRect { //console.log("FractController>drawStimulusInRect");
    CGContextTranslateCTM(cgc,  viewWidth / 2, viewHeight / 2); // origin to center
    //[self strokeLineX0: -100 y0: -100 x1: 100 y1: 100];  [self strokeLineX0: 100 y0: -100 x1: -100 y1: 100];
    var i;  //console.log([Settings crowdingType]);
    switch ([Settings crowdingType]) {
        case 0:  break;
        case 1:    // flanking rings
            for (i = -1; i <= 1; i++) { //console.log(i);
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
}


-(void) onTimerFirstResponder: (CPTimer) timer { //console.log("FractController>onTimerFirstResponder");
    //[[self window] makeFirstResponder: self];
}

-(void) onTimeoutDisplay: (CPTimer) timer { //console.log("FractController>onTimeoutDisplay");
    state = kStateDrawBack;  [[[self window] contentView] setNeedsDisplay: YES];
}


-(void) onTimeoutResponse: (CPTimer) timer { //console.log("FractController>onTimeoutResponse");
    responseWasCorrect = NO;  [self trialEnd];
}


- (void) processKeyDownEvent { //console.log("FractController>processKeyDownEvent");
    var r = [self responseNumberFromChar: responseKeyChar];
    responseWasCorrect = (r == [alternativesGenerator currentAlternative]);
    [self trialEnd];
}


- (void) trialEnd { //console.log("Fract>trialEnd");
    [timerDisplay invalidate];  timerDisplay = nil;  [timerResponse invalidate];  timerResponse = nil;//nötig?
    [thresholder enterTrialOutcomeWithAppliedStim: [self stimGenericFromDevice: stimStrengthInDeviceunits] wasCorrect: responseWasCorrect];
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


- (float) resultValue4Export {
    return [self acuityResultInLogMAR];
}


- (CPString) composeExportString { //console.log("FractController>composeExportString");
    var s = "";
    if ([[self parentController] runAborted]) return;
    var tab = "\t", crlf = "\n", nDigits = 5, now = [CPDate date];
    s = [Misc date2YYYY_MM_DD: now] + tab + [Misc date2HH_MM_SS: now];
    s += tab + [Misc stringFromNumber: [self resultValue4Export] decimals: nDigits localised: YES];
    s += tab + currentTestResultUnit;
    s += tab + rangeLimitStatus;
    s += tab + currentTestName;
    s += tab + [Misc stringFromNumber: [Settings distanceInCM] decimals: nDigits localised: YES] + tab + "cm";
    s += tab + [Misc stringFromNumber: nTrials decimals: 0 localised: YES] + tab + "nTrials";
    s += crlf; //console.log("FractController>date: ", s);
    return s;
}


- (void) runEnd { //console.log("FractController>runEnd");
    [timerDisplay invalidate];  timerDisplay = nil;
    [timerResponse invalidate];  timerResponse = nil;
    [timerFirstResponder invalidate];  timerFirstResponder = nil;
    [[self window] close];
    [[self parentController] setRunAborted: (iTrial < nTrials)]; //premature end
    [[self parentController] setResultString: resultString];
    if (([Settings results2clipboard] > 0) && (![[self parentController] runAborted])) {
        [Misc copyString2ClipboardAlert: [self composeExportString]];
    }
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


- (BOOL) acceptsFirstResponder { //console.log("FractController>acceptsFirstResponder");
    return YES;
}

- (void) keyDown: (CPEvent) theEvent { //console.log("FractController>keyDown");
    responseKeyChar = [[[theEvent characters] characterAtIndex: 0] uppercaseString];
    responseKeyCode = [theEvent keyCode];
    if ((responseKeyCode == CPEscapeKeyCode) || ((responseKeyChar == abortCharacter) && (oldResponseKeyChar == abortCharacter))) {
        [self runEnd];
    }
    oldResponseKeyChar = responseKeyChar;
    if (responseKeyChar != abortCharacter) [self processKeyDownEvent];
}

- (float) stimGenericFromDevice: (float) ntve {
    console.log("FractController>stimGenericFromDevice OVERRIDE!");
    return ntve;
}


- (float) stimDeviceFromGeneric: (float) generic {
    console.log("FractController>stimDeviceFromGeneric OVERRIDE!");
    return generic;
}


///////////////////////// ACUITY UTILs

/*	Transformation formula:   gap = c1 * exp(tPest * c2).
 Constants c1 and c2 are determined by thesse 2 contions: tPest==0 → gap=gapMinimal;  tPest==1 → gap=gapMaximal.
 =>c2 = ln(gapMinimal / gapMaximal)/(0 - 1);  c1 = gapMinimal / exp(0 * c2)  */
- (float) acuityStimDeviceFromGeneric: (float) tPest { //console.log("FractControllerVAC>stimDeviceFromGeneric");
    var c2 = - Math.log(gapMinimal / gapMaximal), c1 = gapMinimal;
    var deviceVal = c1 * Math.exp(tPest * c2); //console.log("DeviceFromPest " + tPest + " " + deviceVal);
    if ([Misc areNearlyEqual: deviceVal and: gapMaximal]) {
        if (!isBonus) {
            rangeLimitStatus = kRangeLimitValueAtCeiling; //console.log("max gap size!")
        }
    } else {
        if  ([Misc areNearlyEqual: deviceVal and: gapMinimal]) {
            rangeLimitStatus = kRangeLimitValueAtFloor; //console.log("min gap size!");
        } else {
            rangeLimitStatus = kRangeLimitOk;
        }
    }
    return deviceVal;
}
        
        
- (float) acuityStimGenericFromDevice: (float) d { //console.log("FractControllerVAC>stimGenericFromDevice");
    var c2 = - Math.log(gapMinimal / gapMaximal), c1 = gapMinimal;
    var retVal = Math.log(d / c1) / c2; //console.log("PestFromDevice " + d + " " + retVal);
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


- (CPString) acuityComposeResult {
    var resultInGapPx = stimStrengthInDeviceunits;
    var resultInDecVA = [Misc visusFromGapPixels: resultInGapPx];
    resultInDecVA *= ([Settings threshCorrection]) ? 0.891 : 1.0;// Korrektur für Schwellenunterschätzung aufsteigender Verfahren
    resultInDecVA = Math.min([Settings maxDisplayedAcuity], resultInDecVA);
    var resultInLogMAR = [Misc logMARfromDecVA: resultInDecVA];
    
    // console.log("rangeLimitStatus: ", rangeLimitStatus);
    var s = "";
    if ([Settings acuityFormatDecimal]) {
        s += "decVA";
        if (rangeLimitStatus == kRangeLimitValueAtFloor) {
            s += " ≥ ";
        } else {
            if (rangeLimitStatus == kRangeLimitValueAtCeiling) {
                s += " ≤ ";
            } else {
                s += ": ";
            }
        }
        s += [Misc stringFromNumber: resultInDecVA decimals: 2 localised: YES];

    }
    if ([Settings acuityFormatLogMAR]) {
        if (s.length > 1) s += ",  ";
        s += "logMAR";
        if (rangeLimitStatus == kRangeLimitValueAtFloor) {
            s += " ≤ ";
        } else {
            if (rangeLimitStatus == kRangeLimitValueAtCeiling) {
                s += " ≥ ";
            } else {
                s += ": ";
            }
        }
        s += [Misc stringFromNumber: resultInLogMAR decimals: 2 localised: YES];
    }
    if ([Settings acuityFormatSnellenFractionFoot]) {
        if (s.length > 1) s += ",  ";
        s += "Snellen fraction: " + [self format4SnellenInFeet: resultInDecVA];
    }
    return s;
}


- (void) modifyGenericStimulusWithBonus {
    if (iTrial > nTrials) return; // don't change if done
    isBonus = (iTrial % 6 == 0) && (iTrial != 6);
    if (isBonus) stimStrengthGeneric = Math.min(stimStrengthGeneric + 0.2, 1.0);
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


///////////////////////// DRAWING
- (void) strokeCircleAtX: (float)x y: (float)y radius: (float) r { //console.log("MBIllus>strokeCircleAtX");
    CGContextStrokeEllipseInRect(cgc, CGRectMake(x - r, y - r, 2 * r, 2 * r));
}


- (void) fillCircleAtX: (float)x y: (float)y radius: (float) r { //console.log("MBIllus>fillCircleAtX");
    CGContextFillEllipseInRect(cgc, CGRectMake(x - r, y - r, 2 * r, 2 * r));
}


// no gap for direction -1
- (void) drawLandoltWithGapInPx: (float) gap landoltDirection: (int) direction { //console.log("OTLandolts>drawLandoltWithGapInPx", gap, direction);
    CGContextSetFillColor(cgc, colOptotypeFore);
    [self fillCircleAtX: 0 y: 0 radius: 2.5 * gap];
    CGContextSetFillColor(cgc, colOptotypeBack);
    [self fillCircleAtX: 0 y: 0 radius: 1.5 * gap];
    var rct = CGRectMake(gap * 1.4 - 1, -gap / 2, 1.3 * gap + 1, gap); //console.log(gap, " ", rct);
    var rot = Math.PI / 180.0 * (7 - (direction - 1)) / 8.0 * 360.0;
    CGContextRotateCTM(cgc, rot);
    if (direction >= 0) CGContextFillRect(cgc, rct);
    CGContextRotateCTM(cgc, -rot);
}


- (void) strokeLineX0: (float) x0 y0: (float) y0 x1: (float) x1 y1: (float) y1 {//console.info("strokeLineX0");
    CGContextBeginPath(cgc);
    CGContextMoveToPoint(cgc, x0, y0);  CGContextAddLineToPoint(cgc, x1, y1);
    CGContextStrokePath(cgc);
    currentX = x1;  currentY = y1;
}
- (void) strokeLineToX: (float) xxx y: (float) yyy {//console.info("strokeLineX0");
    CGContextBeginPath(cgc);
    CGContextMoveToPoint(cgc, currentX, currentY);  CGContextAddLineToPoint(cgc, xxx, yyy);
    CGContextStrokePath(cgc);
    currentX = xxx;  currentY = yyy;
}
- (void) strokeLineDeltaX: (float) xxx deltaY: (float) yyy {//console.info("strokeLineX0");
    CGContextBeginPath(cgc);
    CGContextMoveToPoint(cgc, currentX, currentY);
    currentX = currentX+xxx;  currentY = currentY+yyy;
    CGContextAddLineToPoint(cgc, currentX, currentY);
    CGContextStrokePath(cgc);
}
- (void) strokeVLineAtX: (float) x y0: (float) y0 y1: (float) y1 {
    [self strokeLineX0: x y0: y0 x1: x y1: y1];
    currentX = x;  currentY = y1;
}
- (void) strokeHLineAtX0: (float) x0 y: (float) y x1: (float) x1 {
    [self strokeLineX0: x0 y0: y x1: x1 y1: y];
    currentX = x1;  currentY = y;
}


@end
