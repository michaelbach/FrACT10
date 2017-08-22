/*
 *  FractView.j
 *  FrACT10.02
 *
 *  Created by Bach on 18.07.2017.
 *  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
 */

@import "HierarchyController.j"

@implementation FractView : CPView {
    @outlet HierarchyController drawingDelegate; // has a connection from view to delegate in IB
    SEL drawStimulusInRect;
}


- (id)initWithFrame:(CGRect)frame {console.log("FractView>initWithFrame");
    self = [super initWithFrame:frame];
/*    if (self)  {
        // Initialization code here
    }*/
    return self;
}


- (void)drawRect: (CGRect) dirtyRect { //console.log("FractView>drawRect");
    [drawingDelegate drawStimulusInRect: dirtyRect forView: self];
}


@end
