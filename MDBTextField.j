/*
 * CPTextField.j
 _cappDevelop

  Created by Bach on 2024-05-22.
 */


/**
 Custom ad-hoc textfield to work around this problem:
 A bezeled=bordered textfield has a fixed text size (bug in Cappuccino),
 so I draw the border.  Not a good _general_ solution…
 */

@implementation MDBTextField: CPTextField {
}


- (void) drawRect: (CGRect) dirtyRect { //console.info("MDBTextField>drawRect");
    const cgc = [[CPGraphicsContext currentContext] graphicsPort];
    CGContextSaveGState(cgc);
    CGContextSetFillColor(cgc, [CPColor whiteColor]);
    CGContextFillRect(cgc, [self bounds]);
    CGContextSetStrokeColor(cgc, [CPColor grayColor]);
    CGContextSetLineWidth(cgc, 0.5);
    CGContextStrokeRect(cgc, [self bounds]);
    CGContextRestoreGState(cgc);
}

@end
