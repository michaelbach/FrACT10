/*
  MDBButton.j
 _cappDevelop

  Created by Bach on 15.08.21.
 
 2021-09-15 avoid peakthrough of orignal white button, allows other window color
            slight simplification of the rects & colors
*/


/**
 Custom button to make the large square buttons look nicer,
 with rounded corners and 2px border width
 Created on 2021-08-16
 
 Works with many button types.
 The "bordered" property must be off, otherwise the theme drawing will kick in after drawRect and overpaint
 */

@implementation MDBButton: CPButton {
}

- (void) drawRect: (CGRect) dirtyRect { //console.info("MDBButton>drawRect");
    const cgc = [[CPGraphicsContext currentContext] graphicsPort];
    const f1 = CGRectInset([self bounds], 1, 1), radius = 8; // frame a little smaller  to fit into visibleRect
    //console.log(_isHighlighted, [self isHighlighted], [self hasThemeState:CPThemeStateHighlighted]);
    
    const grayFillValue = _isHighlighted ? 0.85 : 0.98; // unselected or selected fill color
    CGContextSetFillColor(cgc, [CPColor colorWithWhite: grayFillValue alpha: 1]);
    CGContextFillRoundedRectangleInRect(cgc, f1, radius, YES, YES, YES, YES);
    
    CGContextSetStrokeColor(cgc, [CPColor colorWithWhite: 0.6 alpha: 1]); // border, darker than any fill
    if ([self isEnabled]) { // so I notice if inadvertantly disabled
        CGContextSetLineWidth(cgc, 3);
        CGContextStrokeRoundedRectangleInRect(cgc, f1, radius, YES, YES, YES, YES);
    }
}


@end
