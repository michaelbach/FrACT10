/*
 MDBButton_HandCursor.j

 This file is part of FrACT10, a vision test battery.
 © 2026 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>
 Created by Bach on 2026-02-10.

*/


/**
A category to give the following controls a "hand" cursor when hovering:
• Button
• Segmented control
• Color well
 */

@import <AppKit/CPButton.j>
@import <AppKit/CPSegmentedControl.j>
@import <AppKit/CPColorWell.j>


@implementation CPButton (MDBSetHandCursor)

// Turn into hand when entering the control's tracking area
- (void) mouseEntered: (CPEvent) e {
    [[CPCursor pointingHandCursor] set];
}

// Exiting
// Assuming "arrow" as the right exit shape may be problematic, but looks good so far
- (void) mouseExited: (CPEvent) e {
    [[CPCursor arrowCursor] set];
}

@end


@implementation CPSegmentedControl (MDBSetHandCursor)

// Turn into hand when entering the control's tracking area
- (void) mouseEntered: (CPEvent) e {
    [[CPCursor pointingHandCursor] set];
}

// Exiting
// Assuming "arrow" as the right exit shape may be problematic, but looks good so far
- (void) mouseExited: (CPEvent) e {
    [[CPCursor arrowCursor] set];
}

@end


@implementation CPColorWell (MDBSetHandCursor)

// Turn into hand when entering the control's tracking area
- (void) mouseEntered: (CPEvent) e {
    [[CPCursor pointingHandCursor] set];
}

// Exiting
// Assuming "arrow" as the right exit shape may be problematic, but looks good so far
- (void) mouseExited: (CPEvent) e {
    [[CPCursor arrowCursor] set];
}

@end
