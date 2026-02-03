//	History
//	=======
//
//	2026-02-03	started
//

@import <AppKit/CPEvent.j>
@import <AppKit/CPColorWell.j>


@implementation MDBColorWell: CPColorWell
- (void) mouseDown: (CPEvent) anEvent {//console.info("MDBColorWell>mouseDown");
    //Force-close shared panel so it gets reassigned to this
    [[CPColorPanel sharedColorPanel] orderOut: nil];
    [super mouseDown: anEvent];
}


@end
