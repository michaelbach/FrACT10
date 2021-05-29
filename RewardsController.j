/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, michael.bach@uni-freiburg.de, <https://michaelbach.de>

RewardsController.j

2020-05-23 This class manages the reward images sprite
*/


@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Misc.j"
@import "Settings.j"


@implementation RewardsController: CPObject {
    CPImage _rewardsImages, croppedImage;
    CPTimer _timerRewardsController;
    CPImageView _rewardView;
    int _currentRandom, _oldRandom;
}


- (id) initWithView: (CPImageView) view { //console.info("RewardsController>initWithView", view);
    self = [super init];
    if (self) {
        _rewardsImages = [[CPImage alloc] initWithContentsOfFile: [[CPBundle mainBundle] pathForResource: "allRewards4800x200.png"]];
        _rewardView = view;
        [_rewardView setHidden: YES];
        [_rewardView setImageAlignment: CPImageAlignCenter]; // is already the default
        [_rewardView setImageScaling: CPImageScaleNone];
        [_rewardView setAlphaValue: 0.8];
        [_rewardView setHitTests: NO]; // allows "click through"
        [_rewardsImages setSize: CGSizeMake(4800 * 3, 200 * 3)];
        [_rewardView setImage: _rewardsImages];
        
    }
    return self;
}


// There are 24 reward images, each 200x200 → 4800 x 200
// The image _rewardsImages is a sprite, containing 24 images at 200x200 px
- (id) drawRandom { //console.info("RewardsController>drawRandom");
    if ([_rewardsImages loadStatus] != CPImageLoadStatusCompleted) return;

    _currentRandom = [Misc iRandom: 24];
    if (_currentRandom == _oldRandom)  _currentRandom = [Misc iRandom: 24]; // avoid immediate repeats
    _oldRandom = _currentRandom;

    // don't really understand why this works:
    [_rewardView setBounds: CGRectMake(0, 0, (-12 + _currentRandom) * 1200, 600)];
    [_rewardView setHidden: NO];

    _timerRewardsController = [CPTimer scheduledTimerWithTimeInterval: [Settings timeoutRewardPicturesInSeconds] target: self selector: @selector(onTimeoutRewardsController:) userInfo: nil repeats: NO];
}


-(void) onTimeoutRewardsController: (CPTimer) timer { //console.info("RewardsController>onTimeoutRewardsController");
    [_rewardView setHidden: YES];
}


@end
