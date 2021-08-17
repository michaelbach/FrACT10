/*
  MDBButton.j
 _cappDevelop

  Created by Bach on 15.08.21.
*/

@import "CPButton1.j"
@import "HierarchyController.j"

/**
 Custom button to make the large square buttons look nicer
 With rounded corners and 2px border width
 Created on 2021-08-16
 
 Works with many button types.
 The "bordered" property must be off, otherwise the theme drawing will kick in after drawRect and overpaint
 */

@implementation MDBButton: CPButton {
}
    
    - (void) drawRect: (CGRect) dirtyRect { //console.info("MDBButton>drawRect");
        var cgc = [[CPGraphicsContext currentContext] graphicsPort];
        
        var f = [self bounds]; // now make the frame a little smaller  to fit into visibleRect
        var f1 = CGRectMake(f.origin.x + 1, f.origin.y + 1, f.size.width - 2, f.size.height - 2);
        
        //console.log(_isHighlighted, [self isHighlighted], [self hasThemeState:CPThemeStateHighlighted]);
        var grayFillValue = _isHighlighted ? 0.85 : 0.95; // unselected or selected fill color
        var fillColor = [CPColor colorWithWhite: grayFillValue alpha: 1];
        var strokeColor = [CPColor colorWithWhite: 0.5 alpha: 1]; // border, darker than any fill
        CGContextSetFillColor(cgc, fillColor);
        CGContextFillRect(cgc, f1);
        
        CGContextSetStrokeColor(cgc, strokeColor);
        CGContextSetLineWidth(cgc, 2);
        CGContextStrokeRoundedRectangleInRect(cgc, f1, 6, YES, YES, YES, YES);
    }
    
@end
