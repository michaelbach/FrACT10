/*
 * MDBAlert.j
 _cappDevelop

  Created by Bach on 2025-03-10.
 */


//@import "HierarchyController.j"

/**
 Custom CPAlert to be make layout more pleasing when using 3 buttons.
 */


@implementation MDBAlert : CPAlert {
}


- (void) layout { //console.info("MDBAlert>layout");
    [super layout];
    let aestheticShift = 24;
    const buttonsCount = [_buttons count];
    if (buttonsCount > 4) aestheticShift += 100;
    let w = [_window frame].size.width, h = [_window frame].size.height;
    [_window setFrameSize: CGSizeMake(w + aestheticShift, h)]; // window a little wider
    for (let i = 0; i < buttonsCount; i++) {
        let button = _buttons[i]; // ↓ shift all buttons a little to the right
        [button setFrame: CPRectOffset([button frame], aestheticShift, 0)];
    }
    [_window center];
    //console.info(_showHelp, _alertHelpButton)
    // help button not shown???
 }


@end
