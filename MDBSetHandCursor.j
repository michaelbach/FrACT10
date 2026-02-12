/*
 MDBButton_HandCursor.j

 This file is part of FrACT10, a vision test battery.
 © 2026 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>
 Created by Bach on 2026-02-10.

*/


/**
A category to give the following controls a "hand" cursor when hovering over:
• Buttons
• Segmented controls
• Color wells

It is possible to restore the former cursor shape, but not used here since reverting to arrow cursor works fine in the FrACT context.
 */

@import <AppKit/CPCursor.j>
@import <AppKit/CPButton.j>
@import <AppKit/CPSegmentedControl.j>
@import <AppKit/CPColorWell.j>


@implementation CPButton (MDBSetHandCursor) {
    CPCursor formerCursor;
}

// Turn into hand when entering the control's tracking area
- (void) mouseEntered: (CPEvent) e {
    //formerCursor = [CPCursor currentCursor];
    [[CPCursor pointingHandCursor] set];
}

// On exit restore former cursor
- (void) mouseExited: (CPEvent) e {
    //[formerCursor set];
    [[CPCursor arrowCursor] set];
}

@end


@implementation CPSegmentedControl (MDBSetHandCursor) {
    CPCursor formerCursor;
}

// Turn into hand when entering the control's tracking area
- (void) mouseEntered: (CPEvent) e {
    //formerCursor = [CPCursor currentCursor];
    [[CPCursor pointingHandCursor] set];
}

// On exit restore former cursor
- (void) mouseExited: (CPEvent) e {
    //[formerCursor set];
    [[CPCursor arrowCursor] set];
}

@end


@implementation CPColorWell (MDBSetHandCursor) {
    CPCursor formerCursor;
}

// Turn into hand when entering the control's tracking area
- (void) mouseEntered: (CPEvent) e {
    //formerCursor = [CPCursor currentCursor];
    [[CPCursor pointingHandCursor] set];
}

// On exit restore former cursor
- (void) mouseExited: (CPEvent) e {
    //[formerCursor set];
    [[CPCursor arrowCursor] set];
}

@end
