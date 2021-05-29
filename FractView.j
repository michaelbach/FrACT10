/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, michael.bach@uni-freiburg.de, <https://michaelbach.de>

FractView.j

Created by Bach on 18.07.2017.
This class is necessary to allow all subclasses of FractController to draw
 
*/

@import "HierarchyController.j"


@implementation FractView : CPView {
    @outlet HierarchyController drawingDelegate; // has a connection from view to delegate in IB
    SEL drawStimulusInRect;
}


- (id)initWithFrame:(CGRect)frame {console.info("FractView>initWithFrame");
    self = [super initWithFrame:frame];
    return self;
}


- (void)drawRect: (CGRect) dirtyRect { //console.info("FractView>drawRect");
    [drawingDelegate drawStimulusInRect: dirtyRect forView: self];
}


@end
