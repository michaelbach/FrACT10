/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, michael.bach@uni-freiburg.de, <https://michaelbach.de>

HierarchyController.j

Created by Bach on 18.07.2017
Superclass to allow communication between "AppController" and "FractController"
 
*/


@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>
@import "Globals.j"
@import "Settings.j"


@implementation HierarchyController: CPWindowController {
    HierarchyController parentController @accessors;
    CPString resultString @accessors;
    CPString versionDateString @accessors;
    CPString keyTestSettingsString @accessors;
    CPString currentTestName @accessors;
    CPString currentTestResultUnit @accessors;
    CPString currentTestResultExportString @accessors;
    CPString currentTestResultsHistoryExportString @accessors;
}


@end
