/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, michael.bach@uni-freiburg.de, <https://michaelbach.de>

TAOController.j
 
2020-05-23
 This class loads the 10 Auckland Optotype (TAO) images.
 When all are loaded, the referenced button is enabled
 imageArray returns an id pointing at the image array
*/


@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>


@implementation TAOController: CPObject {
    int nImages @accessors;
    id _taoImages;
    CPButton _button;
    int _nTAOImagesLoaded;
}


- (id) initWithButton2Enable: (CPButton) button { //console.info("TAOController>initWithButton2Enable");
    self = [super init];
    if (self) {
        _button = button;
        [_button setEnabled: NO];
        [self setNImages: 0];
        const _taoImageNames = ["butterfly", "car", "duck", "flower", "heart", "house", "moon", "rabbit", "rocket", "tree"];
        _taoImages = [];
        _nTAOImagesLoaded = 0;
        for (let i=0; i < _taoImageNames.length; i++) {
            _taoImages[i] = [[CPImage alloc] initWithContentsOfFile: [[CPBundle mainBundle] pathForResource: "TAOs/" + _taoImageNames[i] + ".png"]];
            [_taoImages[i] setDelegate: self];
        }
    }
    return self;
}


- (void) imageDidLoad: (CPNotification) aNotification { //console.info("TAOController>didLoadRepresentation: ", aNotification);
    if ([aNotification loadStatus] == CPImageLoadStatusCompleted) {
        if (++_nTAOImagesLoaded > 9) {
            [self setNImages: _nTAOImagesLoaded];
            [_button setEnabled: YES];
        }
    }
}


- (id) imageArray {
    return _taoImages;
}


@end
