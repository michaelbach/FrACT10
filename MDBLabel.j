/*
 * MDBLabel.j
 _cappDevelop

  Created by Bach on 2024-05-22.
 */


/**
 Custom textfield to be used as label to work around this problem:
 A bezeled textfield = label does not show its disabled state.
 */

@implementation MDBLabel: CPTextField {
}


- (void) drawRect: (CGRect) dirtyRect { //console.info("MDBLabel>drawRect");
    [super drawRect: dirtyRect];
    //[self currentValueForThemeAttribute:@"text-color"] always 0 or gray???
    //of course, because disable has no effect on standard labels!
    [self setTextColor:[self isEnabled] ? [CPColor blackColor] : [CPColor colorWithCalibratedWhite: 79.0 / 255.0 alpha: 0.6]];
    //from: regularDisabledTextColor in Aristo2>ThemeDescriptors.j
}
@end
