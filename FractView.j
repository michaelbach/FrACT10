/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

FractView.j
 
*/

@import "HierarchyController.j"


/**
 This class is necessary to allow all subclasses of FractController to draw
 using the delegate as established in the Interface Builder
 Created by Bach on 18.07.2017.
 */
@implementation FractView : CPView {
    @outlet HierarchyController drawingDelegate; // has a connection from view to delegate in IB
    SEL drawStimulusInRect;
}


/**
 This is never called. Why is it here? And how can the drawRect work if never instantated?
 Ah, not it comes: that is done by IB
 */
- (id)initWithFrame:(CGRect)frame { //console.info("FractView>initWithFrame");
    self = [super initWithFrame:frame];
    return self;
}


- (void)drawRect: (CGRect) dirtyRect { //console.info("FractView>drawRect");
    [drawingDelegate drawStimulusInRect: dirtyRect forView: self];
}


@end
