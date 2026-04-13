/*
This file is part of FrACT10, a vision test battery.
© 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

Settings.j

Provides a getter/setter interface to all settings (preferences)
All values are checked for sensible ranges for robustness.
Also calculates Fore- and BackColors
Created by mb on July 15, 2015.
*/


@import <Foundation/CPUserDefaults.j>
@import <AppKit/CPUserDefaultsController.j>
@import "Globals.j"
@import "Misc.j"
@import "MiscLight.j"
@import "MiscSpace.j"


@implementation Settings: CPUserDefaultsController {
}


+ (void) initialize {
    [super initialize];  [Misc CPLogSetup];
    sharedSettingsInstance = nil; //not really necessary
    //my accessor functions are constructed from the gSettingsNamesAndTypesMap map, depending on type
    for (const [name, meta] of gSettingsNamesAndTypesMap) {
        switch (meta.type) {
            case "str": [self addStringAccessors4Key: name]; break;
            case "int": [self addIntAccessors4Key: name]; break;
            case "bool": [self addBoolAccessors4Key: name]; break;
            case "float": [self addFloatAccessors4Key: name]; break;
            case "color": [self addColorAccessors4Key: name]; break;
            default: alert("Settings>initialize, this must not occur: " + meta.type + ", " + name);
        }
    }
}


/**
 Helpers
 If `set` is true, the default `dflt` is set,
 otherwise check if outside of range or nil, if so set to default.
 A little chatty since no overloading available, also: BOOL/int/float are all of class CPNumber.
 */
+ (BOOL) checkBool: (BOOL) val dflt: (BOOL) def set: (BOOL) set {
    //console.info("chckBool ", val, "set: ", set);
    if (isNaN(val)) return def;
    if (!set && !isNaN(val)) return val;
    return def;
}
+ (int) checkNum: (CPNumber) val dflt: (int) def min: (int) min max: (int) max set: (BOOL) set { //console.info("chckInt ", val);
    if (!set && !isNaN(val) && (val <= max) && (val >= min)) return val;
    return def;
}


//CPColors are stored as hexString because the archiver does not work in Cappuccino. Why not??
//https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/DrawColor/Tasks/StoringNSColorInDefaults.html
+ (CPColor) _colorForKey: (CPString) keyString fallbackInHex: (CPString) fallbackInHex {
    let theData = [[CPUserDefaults standardUserDefaults] stringForKey: keyString];
    if (theData === nil) theData = fallbackInHex; //safety measure and default
    return [CPColor colorWithHexString: theData];
}
+ (void) _setColor: (CPColor) theColor forKey: (CPString) keyString { //console.info("_setColor ", theColor, keyString)
    if (!theColor) {
        // console.warn("Settings>_setColor: theColor==null for: ", keyString)
        return;
    }
    const newHexString = (typeof(theColor) === "string") ? theColor : [theColor hexString];
    const previousValue = [[CPUserDefaults standardUserDefaults] stringForKey: keyString];
    if (newHexString === previousValue) return;
    [[CPUserDefaults standardUserDefaults] setObject: newHexString forKey: keyString];
}


+ (void) enableNotDisableAllTests: (BOOL) enab {
    [self setEnableTestAcuityLetters: enab];
    [self setEnableTestAcuityLandolt: enab];
    [self setEnableTestAcuityE: enab];
    [self setEnableTestAcuityTAO: enab];
    [self setEnableTestAcuityVernier: enab];
    [self setEnableTestContrastLetters: enab];
    [self setEnableTestContrastLandolt: enab];
    [self setEnableTestContrastE: enab];
    [self setEnableTestContrastG: enab];
    [self setEnableTestAcuityLineByLine: enab];
    [self setEnableTestBalmGeneral: enab];
}


/**
 Test all settings for in-range (set===NO) or set the to defaults (set===YES)
 */
+ (void) allNotCheckButSet: (BOOL) set {
    [[CPUserDefaults standardUserDefaults] synchronize];

    if (set) { //special handling for dependent settings and those with complex defaults
        [self setDateOfSettingsVersion: kDateOfCurrentSettingsVersion];
        [self enableNotDisableAllTests: YES];
    }

    for (const [name, meta] of gSettingsNamesAndTypesMap) {
        const currentVal = [[CPUserDefaults standardUserDefaults] objectForKey: name];
        let newVal = currentVal;
        switch (meta.type) {
            case "bool":
                newVal = [self checkBool: currentVal dflt: meta.dflt set: set];  break;
            case "int": case "float":
                newVal = [self checkNum: currentVal dflt: meta.dflt min: meta.min max: meta.max set: set];  break;
            case "str":
                if (set || currentVal === null) newVal = meta.dflt;
                break;
            case "color":
                if (set || currentVal === null) {
                    if (meta.dflt !== null) {
                        [self _setColor: meta.dflt forKey: name];
                        continue; //_setColor already handles it
                    }
                }
                break;
        }
        //Apply the value if it changed or if we are forcing defaults
        if (newVal !== currentVal || (set && meta.type !== "color")) {
             [[CPUserDefaults standardUserDefaults] setObject: newVal forKey: name];
        }
    }

    [self calculateAcuityForeBackColorsFromContrast];
    [self calculateMinMaxPossibleAcuity];

    [[CPUserDefaults standardUserDefaults] synchronize];
}


+ (void) calculateMinMaxPossibleAcuity { //console.info("Settings>calculateMinMaxPossibleAcuity");
    let maxPossibleAcuityVal = [MiscSpace decVAFromStrokePixels: 1.0];
    const screenSize = Math.min(window.screen.height, window.screen.width);
    const strokeMaximal = screenSize / (5 + [self margin4maxOptotypeIndex]); //leave a margin of ½·index around the largest optotype
    let minPossibleAcuityVal = [MiscSpace decVAFromStrokePixels: strokeMaximal];
    //Correction for threshold underestimation of ascending procedures (as opposed to our bracketing one)
    minPossibleAcuityVal = [self doThreshCorrection] ? minPossibleAcuityVal * kThresholdCorrectionFactor4Ascending : minPossibleAcuityVal;
    [self setMinPossibleDecimalAcuityLocalisedString: [Misc stringFromNumber: minPossibleAcuityVal decimals: 3 localised: YES]];
    [self setMaxPossibleLogMAR: [MiscSpace logMARfromDecVA: minPossibleAcuityVal]]; //needed for color
    [self setMaxPossibleLogMARLocalisedString: [Misc stringFromNumber: [self maxPossibleLogMAR] decimals: 2 localised: YES]];
    
    //Correction for threshold underestimation of ascending procedures (as opposed to our bracketing one)
    maxPossibleAcuityVal = [self doThreshCorrection] ? maxPossibleAcuityVal * kThresholdCorrectionFactor4Ascending : maxPossibleAcuityVal;
    [self setMaxPossibleDecimalAcuityLocalisedString: [Misc stringFromNumber: maxPossibleAcuityVal decimals: 2 localised: YES]];
    [self setMinPossibleLogMAR: [MiscSpace logMARfromDecVA: maxPossibleAcuityVal]]; //needed for color
    [self setMinPossibleLogMARLocalisedString: [Misc stringFromNumber: [self minPossibleLogMAR] decimals: 2 localised: YES]];
    const inch = [Misc stringFromNumber: [self distanceInCM] / 2.54 decimals: 1 localised: YES];
    [self setDistanceInInchLocalisedString: inch];
}


//contrast in %. 100%: background fully white, foreground fully dark. -100%: inverted
+ (void) calculateAcuityForeBackColorsFromContrast { //console.info("Settings>calculateAcuityForeBackColorsFromContrast");
    if ([self isAcuityColor]) return;
    const cnt = [MiscLight contrastMichelsonPercentFromWeberPercent: [self contrastAcuityWeber]];
    let temp = [MiscLight lowerLuminanceFromContrastMilsn: cnt];
    temp = [MiscLight devicegrayFromLuminance: temp];
    [self setAcuityForeColor: [CPColor colorWithWhite: temp alpha: 1]];
    temp = [MiscLight upperLuminanceFromContrastMilsn: cnt];
    temp = [MiscLight devicegrayFromLuminance: temp];
    [self setAcuityBackColor: [CPColor colorWithWhite: temp alpha: 1]];
}


/**
 Test if we need to set all Settings to defaults
 When new defaults are added, kDateOfCurrentSettingsVersion is updated. That tells FrACT that all settings need to be defaulted.
 */
+ (BOOL) needNewDefaults {
    return [self dateOfSettingsVersion] !== kDateOfCurrentSettingsVersion;
}
+ (void) checkDefaults { //console.info("Settings>checkDefaults");
    if ([self needNewDefaults]) {
        [self setDefaults];
    } else {
        [self allNotCheckButSet: NO];
    }
    [[CPUserDefaults standardUserDefaults] synchronize];
}


/**
 Set all settings to their default values
 */
+ (void) setDefaults { //console.info("Settings>setDefaults");
    [self allNotCheckButSet: YES];
}
+ (void) setDefaultsKeepingCalBarLength {
    const calBarLengthInMM_prior = [Settings calBarLengthInMM];
    [self setDefaults];
    [self setCalBarLengthInMM: calBarLengthInMM_prior];
}


/**
 Calibration is assumed ok if the distance and the calBarLength differ from defaults
 */
+ (BOOL) isNotCalibrated {
    [self checkDefaults];
    return (([self distanceInCM] === kDefaultDistanceInCM) || ([self calBarLengthInMM] === gDefaultCalibrationBarLengthInMM));
}


/**
 Populate the sound selection popups from the selected indices
 */
+ (void) setupSoundPopups: (id) popupsArray {
    const allSounds = [gSoundsTrialStart, gSoundsTrialYes, gSoundsTrialNo, gSoundsRunEnd];
    const allIndexes = [[self soundTrialStartIndex], [self soundTrialYesIndex], [self soundTrialNoIndex], [self soundRunEndIndex]];
    for (let i = 0; i < popupsArray.length; i++) {
        const p = popupsArray[i];
        [p removeAllItems]; //first remove all, then add selected ones
        for (const soundName of allSounds[i]) [p addItemWithTitle: soundName];
        [p setSelectedIndex: allIndexes[i]]; //was lost after remove
    }
}


///////////////////////////////////////////////////////////
/**
 individual getters / setters for all settings not synthesized in `initialize`
 */

+ (int) nTrials { //console.info("Settings>nTrials");
    switch ([self nAlternatives]) {
        case 2:  return [self nTrials02];  break;
        case 4:  return [self nTrials04];  break;
        default:  return [self nTrials08];
    }
}

+ (int) nAlternatives { //console.info("Settings>nAlternatives");
    switch ([self nAlternativesIndex]) {
        case kNAlternativesIndex2:  return 2;  break;
        case kNAlternativesIndex4:  return 4;  break;
        default: return 8; //case kNAlternativesIndex8plus
    }
}

+ (CPString) decimalMarkChar { //console.info("settings>decimalMarkChar");
    const oldMark = [[CPUserDefaults standardUserDefaults] objectForKey: "decimalMarkChar"]; //see below for necessity
    let _mark = ".";
    switch ([self decimalMarkCharIndex]) {
        case 0: //"Automatic"
            try {
                const tArray = Intl.NumberFormat().formatToParts(1.3); //"1.3" has a decimal mark
                _mark = tArray.find(currentValue => currentValue.type === "decimal").value;
            }
            catch(e) { //avoid global error catcher, but log the problem
                console.log("“Intl.NumberFormat().formatToParts” throws error: ", e);
            } //console.info("_decimalMarkChar: ", _decimalMarkChar)
            break;
        case 2: //comma
            _mark = ","; break;
    }
    //necessary, because otherwise, when just asking for the mark for internationalisation, the `settingsDidChange` avalanche starts, possibly resetting colors
    if (oldMark !== _mark) {
        [self setDecimalMarkChar: _mark];
    }
    return _mark;
}
+ (void) setDecimalMarkChar: (CPString) val {
    [[CPUserDefaults standardUserDefaults] setObject: val forKey: "decimalMarkChar"];
}


/**
 Bool/Int/Float/String/Color helpers for synthesising class methods to get/set defaults
 */
+ (void) addBoolAccessors4Key: (CPString) key { //CPLog("Settings>addIntAccessors4Key called with key: " + key);
    if (key === "") return;
    const setterName = "set" + key.charAt(0).toUpperCase() + key.substring(1) + ":";
    const getterSel = CPSelectorFromString(key),
        setterSel = CPSelectorFromString(setterName);
    class_addMethod(self.isa, getterSel, function(self, _cmd) {
        const val = [[CPUserDefaults standardUserDefaults] boolForKey:key];
        //CPLog("Getter called for key: %@, returning %d", key, val);
        return val;
    });
    class_addMethod(self.isa, setterSel, function(self, _cmd, val) { //CPLog("Bool setter called for key: " + key + " with value: " + val);
        [[CPUserDefaults standardUserDefaults] setBool:val forKey:key];
    });
}
+ (void) addIntAccessors4Key: (CPString) key { //CPLog("Settings>addIntAccessors4Key called with key: " + key);
    if (key === "") return;
    const setterName = "set" + key.charAt(0).toUpperCase() + key.substring(1) + ":";
    const getterSel = CPSelectorFromString(key),
        setterSel = CPSelectorFromString(setterName);
    class_addMethod(self.isa, getterSel, function(self, _cmd) {
        const val = [[CPUserDefaults standardUserDefaults] integerForKey:key];
        //CPLog("Getter called for key: %@, returning %d", key, val);
        return val;
    });
    class_addMethod(self.isa, setterSel, function(self, _cmd, val) { //CPLog("Int setter called for key: " + key + " with value: " + val);
        [[CPUserDefaults standardUserDefaults] setInteger:val forKey:key];
    });
}
+ (void) addFloatAccessors4Key: (CPString) key { //CPLog("Settings>addFloatAccessors4Key called with key: " + key);
    if (key === "") return;
    const setterName = "set" + key.charAt(0).toUpperCase() + key.substring(1) + ":";
    const getterSel = CPSelectorFromString(key),
        setterSel = CPSelectorFromString(setterName);
    class_addMethod(self.isa, getterSel, function(self, _cmd) {
        const val = [[CPUserDefaults standardUserDefaults] floatForKey:key];
        //CPLog("Getter called for key: %@, returning %f", key, val);
        return val;
    });
    class_addMethod(self.isa, setterSel, function(self, _cmd, val) { //CPLog("Float setter called for key: " + key + " with value: " + val);
        [[CPUserDefaults standardUserDefaults] setFloat:val forKey:key];
    });
    //CPLog("Self responds to getter: " + [self respondsToSelector:getterSel]);
    //CPLog("Settings responds to getter: " + [Settings respondsToSelector:getterSel]);
}
+ (void) addStringAccessors4Key: (CPString) key { //CPLog("Settings>addIntAccessors4Key called with key: " + key);
    if (key === "") return;
    const setterName = "set" + key.charAt(0).toUpperCase() + key.substring(1) + ":";
    const getterSel = CPSelectorFromString(key),
        setterSel = CPSelectorFromString(setterName);
    class_addMethod(self.isa, getterSel, function(self, _cmd) {
        const val = [[CPUserDefaults standardUserDefaults] stringForKey:key];
        //CPLog("Getter called for key: %@, returning %d", key, val);
        return val;
    });
    class_addMethod(self.isa, setterSel, function(self, _cmd, val) { //CPLog("String setter called for key: " + key + " with value: " + val);
        [[CPUserDefaults standardUserDefaults] setObject:val forKey:key];
    });
}
+ (void) addColorAccessors4Key: (CPString) key { //CPLog("Settings>addIntAccessors4Key called with key: " + key);
    if (key === "") return;
    const setterName = "set" + key.charAt(0).toUpperCase() + key.substring(1) + ":";
    const getterSel = CPSelectorFromString(key),
        setterSel = CPSelectorFromString(setterName);
    class_addMethod(self.isa, getterSel, function(self, _cmd) { //CPLog("Color getter called for key: " + key);
        return [self _colorForKey: key fallbackInHex: "777777"];
    });
    class_addMethod(self.isa, setterSel, function(self, _cmd, val) { //CPLog("Color setter called for key: " + key + " with value: " + val);
        [self _setColor: val forKey: key];
    });
}


/**
 Perform logic unit tests for Settings (persistence and vetting).
 @return YES if all tests pass
 */
+ (BOOL) unittest {
    let success = YES, report = crlf + "Settings▸unittest:" + crlf;

    //Test 1: Basic Persistence (using a string setting)
    const originalID = [Settings patID];
    const testID = "UnitTest-123";
    [Settings setPatID: testID];
    [[CPUserDefaults standardUserDefaults] synchronize];
    if ([Settings patID] !== testID) {
        report += "  ERROR: String persistence failed!" + crlf; success = NO;
    }
    [Settings setPatID: originalID]; // Restore

    //Test 2: Range Validation (Vetting)
    //distanceInCM has min: 1, max: 2500, dflt: kDefaultDistanceInCM
    const originalDist = [Settings distanceInCM];
    [Settings setDistanceInCM: -50]; //Set invalid value
    [Settings allNotCheckButSet: NO]; //Trigger vetting
    if ([Settings distanceInCM] === -50) {
        report += "  ERROR: Negative distance was not vetted!" + crlf; success = NO;
    }
    if ([Settings distanceInCM] !== kDefaultDistanceInCM) {
        report += "  ERROR: Invalid distance did not revert to default! (is " + [Settings distanceInCM] + ")" + crlf; success = NO;
    }
    [Settings setDistanceInCM: originalDist]; //Restore

    //Test 3: Boolean Vetting
    const originalEasy = [Settings acuityHasEasyTrials];
    // checkBool handles NaN by returning dflt
    [[CPUserDefaults standardUserDefaults] setObject: NaN forKey: "acuityHasEasyTrials"];
    [Settings allNotCheckButSet: NO];
    if (isNaN([Settings acuityHasEasyTrials])) {
        report += "  ERROR: NaN boolean was not vetted!" + crlf; success = NO;
    }
    [Settings setAcuityHasEasyTrials: originalEasy]; //Restore

    //Test 4: Metadata-driven Range Vetting (Systematic)
    report += "  Running systematic metadata range tests…" + crlf;
    for (const [name, meta] of gSettingsNamesAndTypesMap) {
        if (["minPossibleLogMAR", "maxPossibleLogMAR"].includes(name)) continue; //don't test these
        if (meta.type === "int" || meta.type === "float") {
            const originalVal = [[CPUserDefaults standardUserDefaults] objectForKey: name];
            //Test Below Min
            [[CPUserDefaults standardUserDefaults] setObject: meta.min - 1 forKey: name];
            [Settings allNotCheckButSet: NO];
            if ([[CPUserDefaults standardUserDefaults] objectForKey: name] !== meta.dflt) {
                report += "  ERROR: '" + name + "' below min (" + (meta.min - 1) + ") did not revert to default!" + crlf; success = NO;
            }
            //Test Above Max
            if (!["nAlternativesIndex"].includes(name)) { //avoids array overflow when testing
                [[CPUserDefaults standardUserDefaults] setObject: meta.max + 1 forKey: name];
                [Settings allNotCheckButSet: NO];
                if ([[CPUserDefaults standardUserDefaults] objectForKey: name] !== meta.dflt) {
                    report += "  ERROR: '" + name + "' above max (" + (meta.max + 1) + ") did not revert to default!" + crlf; success = NO;
                }
            }
            [[CPUserDefaults standardUserDefaults] setObject: originalVal forKey: name]; //Restore
        }
    }
    if (success) {
        report += "  Settings logic and range vetting tests passed." + crlf;
    }
    console.info(report);
    return success;
}


@end
