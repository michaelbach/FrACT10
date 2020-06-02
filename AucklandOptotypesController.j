/* 2020-05-23
 This class loads all 10 Auckland Optotype images.
 When all are loaded, the referenced button is enabled
 imageArray returns an id pointing at the image array
*/


@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Settings.j"


@implementation AucklandOptotypesController: CPObject {
    int nImages @accessors;
    id _auckImages;
    CPButton _button;
    int _nAuckImagesLoaded;
}


- (id) initWithButton2Enable: (CPButton) button { //console.info("RewardsController>initWithView");
    self = [super init];
    if (self) {
        _button = button;
        [_button setEnabled: NO];
        [self setNImages: 0];
        var _auckImageNames = ["butterfly", "car", "duck", "flower", "heart", "house", "moon", "rabbit", "rocket", "tree"];
        _auckImages = [];
        _nAuckImagesLoaded = 0;
        for (var i=0; i < _auckImageNames.length; i++) {
            _auckImages[i] = [[CPImage alloc] initWithContentsOfFile: [[CPBundle mainBundle] pathForResource: "AucklandOptotypes/" + _auckImageNames[i] + ".png"]];
            [_auckImages[i] setDelegate: self];
        }
    }
    return self;
}


- (void) imageDidLoad: (CPNotification) aNotification { //console.info("didLoadRepresentation: ", aNotification);
    if ([aNotification loadStatus] == CPImageLoadStatusCompleted) {
        if (++_nAuckImagesLoaded > 9) {
            [self setNImages: _nAuckImagesLoaded];
            [_button setEnabled: YES];
        }
    }
}


- (id) imageArray {
    return _auckImages;
}


@end
