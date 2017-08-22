//    History
//    =======
//
//    2015-07-15 started
//


@import "HierarchyController.j"
@import "Settgs.j"
@import "AlternativesGenerator.j"
@import "Thresholder.j";


@implementation FractController: HierarchyController {
    int state, kStateDrawBack, kStateDrawFore, iTrial, nTrials, nAlternatives;
    BOOL isBonus, responseWasCorrect;
    char oldResponseKeyChar, responseKeyChar;
    unsigned short responseKeyCode;
    CGContext cgc;
    BOOL keyWindowValid;
    float stimStrengthGeneric, stimStrengthDevice, viewWidth, viewHeight;
    float gapMinimal, gapMaximal;
    Thresholder thresholder;
    AlternativesGenerator alternativesGenerator;
    CPString trialInfoString @accessors;
    CPTimer timerDisplay, timerResponse;
}


- (id) initWithWindow: (CPWindow) aWindow parent: (HierarchyController) parent {//console.log("FractController>initWithWindow");
    self = [super initWithWindow: aWindow];
    if (self) {
        [self setParentController: parent];
        [aWindow setDelegate: self];
        viewWidth = CGRectGetWidth([aWindow frame]);  viewHeight = CGRectGetHeight([aWindow frame]);
        gapMinimal = 0.5;  gapMaximal = viewHeight / 5 - 2;
        kStateDrawBack = 0; kStateDrawFore = 1;
        state = kStateDrawBack;
        [self setColOptotypeFore: [[self parentController] colOptotypeFore]];
        [self setColOptotypeBack: [[self parentController] colOptotypeBack]];
        [Settgs checkDefaults];
        nTrials = [Settgs nTrials];
        nAlternatives = [Settgs nAlternatives];
        [[self window] setFrameOrigin: CGPointMake(0, 0)];  //[[self window] setFullPlatformWindow: YES];
        [[self window] makeKeyAndOrderFront: self];
        //[self performSelector: @selector(runStart) withObject: nil afterDelay: 0.01];//geht nicht mehr nach DEPLOY???
        [self runStart];
    }
    return self;
}


- (void) runStart {//console.log("FractController>runStart");
    iTrial = 0;
    oldResponseKeyChar = " ";
    state = kStateDrawBack;
    alternativesGenerator = [[AlternativesGenerator alloc] initWithNumAlternatives: nAlternatives];
    thresholder = [[Thresholder alloc] initWithNumAlternatives: nAlternatives];
    [self trialStart];
}


- (void) trialStart {//console.log("FractController>trialStart");
    iTrial += 1;
    stimStrengthGeneric = [thresholder nextStim2apply];//console.log("stimStrengthGeneric ", stimStrengthGeneric);
    [self modifyGenericStimulus];// e.g. for bonus trials
    stimStrengthDevice = [self stimDeviceFromGeneric: stimStrengthGeneric];//console.log("stimStrengthDevice ", stimStrengthDevice);
    if (iTrial > nTrials) {// testing after new stimStrength so we can use final threshold
        [self runEnd];  return;
    }
    [self modifyDeviceStimulus];// e.g. let the first 3 follow DIN
    responseWasCorrect = NO;
    [alternativesGenerator nextAlternative];
    timerDisplay = [CPTimer scheduledTimerWithTimeInterval: [Settgs timeoutDisplaySeconds] target:self selector:@selector(onTimeoutDisplay:) userInfo:nil repeats:NO];
    timerResponse = [CPTimer scheduledTimerWithTimeInterval: [Settgs timeoutResponseSeconds] target:self selector:@selector(onTimeoutResponse:) userInfo:nil repeats:NO];
    state = kStateDrawFore;  [[[self window] contentView] setNeedsDisplay: YES];
}


-(void) onTimeoutDisplay: (CPTimer) timer {//console.log("FractController>onTimeoutDisplay");
    state = kStateDrawBack;  [[[self window] contentView] setNeedsDisplay: YES];
}


-(void) onTimeoutResponse: (CPTimer) timer {//console.log("FractController>onTimeoutResponse");
    responseWasCorrect = NO;  [self trialEnd];
}


- (void) trialEnd {//console.log("Fract>trialEnd");
    [timerDisplay invalidate];  timerDisplay = nil;  [timerResponse invalidate];  timerResponse = nil;
    [thresholder enterTrialOutcomeWithAppliedStim: [self stimGenericFromDevice: stimStrengthDevice] wasCorrect: responseWasCorrect];
    [self trialStart];
}


- (void) runEnd {//console.log("FractController>runEnd");
    [[self window] close];
    if (iTrial < nTrials) {//premature end
    }
    [[self parentController] setResultString: resultString];
    [[self parentController] runEnd];
}


- (CPString) format4SnellenInFeet: (float) decVA {
    var distanceInMetres = [Settgs distanceInCM] / 100.0;
    var distanceInFeet = distanceInMetres * 3.28084;
    if ([Settgs forceSnellen20])  distanceInFeet = 20;
    var s = [Misc stringFromNumber: distanceInFeet decimals: 0 localised: YES] + "/";
    s += [Misc stringFromNumber: (distanceInFeet / decVA) decimals: 0 localised: YES];
    return s;
}
/*private function format4SnellenInMeter(theAcuityResult:Number):String {
 var distanceInMetres:Number=Prefs.distanceInCM.n / 100.0, distanceInFeet:Number=distanceInMetres * 3.28084;
 return Utils.DeleteTrailing_PointZero(Utils.rStrNInt(distanceInMetres, 1, Prefs.decimalPointChar)) + "/" + Utils.DeleteTrailing_PointZero(Utils.rStrNInt(distanceInMetres / theAcuityResult,1,Prefs.decimalPointChar));
 }*/


- (void) keyDown: (CPEvent) theEvent {//console.log("FractController>keyDown");
    responseKeyChar = [[[theEvent characters] characterAtIndex: 0] uppercaseString];
    responseKeyCode = [theEvent keyCode];
    if ((responseKeyCode == CPEscapeKeyCode) || ((responseKeyChar == "5") && (oldResponseKeyChar == "5"))) {
        [self runEnd];
    }
    oldResponseKeyChar = responseKeyChar;
    if (responseKeyChar != "5") [self processKeyDownEvent];
}


- (void) processKeyDownEvent {//console.log("FractController>processKeyDownEvent");
    var r = [self responseNumberFromChar: responseKeyChar];
    responseWasCorrect = (r == [alternativesGenerator currentAlternative]);
    [self trialEnd];
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
- (float) acuityStimDeviceFromGeneric: (float) tPest {//console.log("FractControllerAcuityC>stimDeviceFromGeneric");
    var c2 = - Math.log(gapMinimal / gapMaximal), c1 = gapMinimal;
    var deviceVal = c1 * Math.exp(tPest * c2);  //console.log("DeviceFromPest " + tPest + " " + deviceVal);
    return deviceVal;
}
- (float) acuityStimGenericFromDevice: (float) d {//console.log("FractControllerAcuityC>stimGenericFromDevice");
    var c2 = - Math.log(gapMinimal / gapMaximal), c1 = gapMinimal;
    var retVal = Math.log(d / c1) / c2;  //console.log("PestFromDevice " + d + " " + retVal);
    return retVal;
}


- (CPString) acuityComposeTrialInfoString {
    var s = iTrial + "/" + nTrials + " ";
    s += [Misc stringFromNumber: [Misc visusFromGapPixels: stimStrengthDevice] decimals: 2 localised: YES];
    return s;
}


- (CPString) acuityComposeResult {
    var resultInGapPx = stimStrengthDevice;
    var resultInDecVA = [Misc visusFromGapPixels: resultInGapPx];
    resultInDecVA *= ([Settgs threshCorrection]) ? 0.891 : 1.0;// Korrektur für Schwellenunterschätzung aufsteigender Verfahren
    var resultInLogMAR = [Misc logMARfromDecVA: resultInDecVA];
    var s = "";
    if ([Settgs acuityFormatDecimal]) {
        s += "decVA: " + [Misc stringFromNumber: resultInDecVA decimals: 2 localised: YES]
    }
    if ([Settgs acuityFormatLogMAR]) {
        if (s.length > 1) s += ",  ";
        s += "logMAR: " + [Misc stringFromNumber: resultInLogMAR decimals: 2 localised: YES]
    }
    if ([Settgs acuityFormatSnellenFractionFoot]) {
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


- (void) acuityModifyDeviceStimulusDIN01_02_04 {
    switch (iTrial) {
        case 1:  stimStrengthDevice = [Misc gapPixelsFromVisus: 0.1];  break;
        case 2:  if (responseWasCorrect) stimStrengthDevice = [Misc gapPixelsFromVisus: 0.2];  break;
        case 3:  if (responseWasCorrect) stimStrengthDevice = [Misc gapPixelsFromVisus: 0.4];  break;
    }
}


///////////////////////// DRAWING
- (void) fillCircleAtX: (float)x y: (float)y radius: (float)r {//console.log("MBIllus>fillCircleAtX");
    CGContextFillEllipseInRect(cgc, CGRectMake(x-r, y-r, 2*r, 2*r));
}


- (void) drawLandoltWithGapInPx: (float) gap landoltDirection: (int) direction {//console.log("OTLandolts>drawLandoltWithGapInPx");
    CGContextSetFillColor(cgc, colOptotypeFore);
    [self fillCircleAtX: 0 y: 0 radius: 2.5 * gap];
    CGContextSetFillColor(cgc, colOptotypeBack);
    [self fillCircleAtX: 0 y: 0 radius: 1.5 * gap];
    var rct = CGRectMake(gap * 1.4 - 1, -gap / 2, 1.3 * gap + 1, gap); //console.log(gap, " ", rct);
    var rot = Math.PI / 180.0 * (7 - (direction - 1)) / 8.0 * 360.0;
    CGContextRotateCTM(cgc, rot);  CGContextFillRect(cgc, rct);  CGContextRotateCTM(cgc, -rot);
}



@end
