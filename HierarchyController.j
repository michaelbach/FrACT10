/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

HierarchyController.j
 
*/


@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>
@import "Globals.j"
@import "Settings.j"


/**
 Superclass to allow communication between "AppController" and "FractController"
 Created on 18.07.2017
 */
@typedef TestIDType
kTestNone = 0; kTestAcuityLett = 1; kTestAcuityC = 2; kTestAcuityE = 3; kTestAcuityTAO = 4;
kTestAcuityVernier = 5; kTestContrastLett = 6; kTestContrastC = 7; kTestContrastE = 8;
kTestContrastG = 9; kTestAcuityLineByLine = 10; kTestContrastDitherUnittest = 11;
kTestBalmLight = 12; kTestBalmLocation = 13; kTestBalmMotion = 14;

kShortcutKeys4TestsArray = {"L": kTestAcuityLett, "C": kTestAcuityC, "E": kTestAcuityE,
    "A": kTestAcuityTAO, "V": kTestAcuityVernier,
    "1": kTestContrastLett, "2": kTestContrastC, "3": kTestContrastE,
    "G": kTestContrastG, "0": kTestContrastDitherUnittest, "4": kTestAcuityLineByLine};

@typedef NAlternativesIndexType
kNAlternativesIndex2 = 0; kNAlternativesIndex4 = 1; kNAlternativesIndex8plus = 2;

@typedef AuditoryFeedback4trialType
kAuditoryFeedback4trialNone = 0; kAuditoryFeedback4trialAlways = 1; kAuditoryFeedback4trialOncorrect = 2; kAuditoryFeedback4trialWithinfo = 3;

@typedef Results2ClipChoiceType
kResults2ClipNone = 0; kResults2ClipFinalOnly = 1; kResults2ClipFullHistory = 2;

@typedef AutoRunIndexType
kAutoRunIndexNone = 0; kAutoRunIndexHi = 1; kAutoRunIndexMid = 2; kAutoRunIndexLow = 3;

@typedef VernierTypeType
kVernierType2bars = 0; kVernierType3bars = 1;

@typedef SoundTypeType
kSoundRunEnd = 0; kSoundTrialYes = 1; kSoundTrialNo = 2; kSoundTrialStart = 3;

@typedef decimalMarkCharIndexType
kDecimalMarkCharIndexAuto = 0; kDecimalMarkCharIndexDot = 1; kDecimalMarkCharIndexComma = 2;

@typedef gratingShapeIndexType
kGratingShapeIndexSinus = 0; kGratingShapeIndexSquare = 1;
kGratingShapeIndexTriangle = 2; kGratingShapeIndexCheckerboard = 3;


@implementation HierarchyController: CPWindowController {
    TestIDType currentTestID @accessors;
    CPString resultString @accessors;
    CPString versionDateString @accessors; // for the main Xib window top right
    CPString currentTestResultUnit @accessors;
    CPString currentTestResultExportString @accessors;
    CPString currentTestResultsHistoryExportString @accessors;
    CPWindow selfWindow;
}


/**
 helpers
 */

// often used, to shorten code
- (void) postNotificationName: (CPString) aNotificationName object: (id) anObject {
    [[CPNotificationCenter defaultCenter] postNotificationName: aNotificationName object: anObject];
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
        case kTestContrastG:
            if ([self isContrastG]) return "Contrast_Grating";
            return "Acuity_Grating";
        case kTestAcuityLineByLine: return "Acuity_LineByLine";
        case kTestBalmLight: return "BalmLight";
        case kTestBalmLocation: return "BalmLocation";
        case kTestBalmMotion: return "BalmMotion";
    }
    return "NOT ASSIGNED";
}


- (BOOL) isAcuityTAO {
    return [kTestAcuityTAO].includes(currentTestID);
}
- (BOOL) isAcuityOptotype {
    return [kTestAcuityLett, kTestAcuityC, kTestAcuityE, kTestAcuityTAO].includes(currentTestID);
}
- (BOOL) isAcuityGrating {
    return (currentTestID == kTestContrastG) && ([Settings what2sweepIndex] == 1);
}
- (BOOL) isAcuityAny {
    return ([self isAcuityOptotype] || (currentTestID == kTestAcuityVernier) || [self isAcuityGrating]);
}
- (BOOL) isContrastG {
    return [kTestContrastG].includes(currentTestID) && (![self isAcuityGrating]);
}
- (BOOL) isContrastOptotype { //console.info("isContrastOptotype ", currentTestID);
    return [kTestContrastLett, kTestContrastC, kTestContrastE].includes(currentTestID);
}
- (BOOL) isContrastAny {
    return [self isContrastOptotype] || (currentTestID == kTestContrastG);
}
- (BOOL) isGratingAny {
    return currentTestID == kTestContrastG;
}


@end
