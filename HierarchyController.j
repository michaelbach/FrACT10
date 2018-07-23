/*
 *  HierarchyController.j
 *  FrACT10.02
 *
 *  Created by Bach on 18.07.2017.
 *  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
 */

@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>


@implementation HierarchyController: CPWindowController {
    HierarchyController parentController @accessors;
    CPColor colOptotypeFore @accessors, colOptotypeBack @accessors;
    int kOptoTypeIndexAcuityC, kOptoTypeIndexAcuityLetters;
    CPString resultString @accessors;
    CPString versionDateString @accessors;
    CPString keyTestSettingsString @accessors;
    CPString currentTestName @accessors;
}


/*- (void) drawStimulusInRect: (CGRect) dirtyRect forView: (FractView) fractView {
    console.log("HierarchyController>drawRect NEEDS OVERRIDE");
}


- (void) runDone {console.log("HierarchyController>runDone");
}


- (void) cancel {
    // exit to parent controller and don't save
}*/


@end
