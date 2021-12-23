/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, michael.bach@uni-freiburg.de, <https://michaelbach.de>

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
kTestAcuityLett = 0; kTestAcuityC = 1; kTestAcuityE = 2; kTestIDTAO = 3; kTestIDVernier = 4; kTestContrastLett = 5; kTestContrastC = 6; kTestContrastE = 7, kTestAcuityLineByLine = 8;

@implementation HierarchyController: CPWindowController {
    HierarchyController parentController @accessors;
    TestIDType currentTestID @accessors;
    CPString resultString @accessors;
    CPString versionDateString @accessors;
    CPString keyTestSettingsString @accessors;
    //CPString currentTestName @accessors;
    CPString currentTestResultUnit @accessors;
    CPString currentTestResultExportString @accessors;
    CPString currentTestResultsHistoryExportString @accessors;
    BOOL gIsNodejs;
}


@end
