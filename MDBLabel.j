/*
 * MDBLabel.j
 _cappDevelop

  Created by Bach on 2024-05-22.
 */


@import "HierarchyController.j"

/**
 Custom textfield to be used as label to work around this problem:
 A bezeled textfield = label does not show its disabled state.
 */

@implementation MDBLabel: CPTextField {
}


- (void) drawRect: (CGRect) dirtyRect { //console.info("MDBLabel>drawRect");
    [super drawRect: dirtyRect];
    //[self currentValueForThemeAttribute:@"text-color"] always 0 or gray???
    [self setTextColor:[self isEnabled] ? [CPColor blackColor] : [CPColor grayColor]];
}
@end
