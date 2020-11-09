/* 2020-05-23
 This class manages the reward images sprite
*/


@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Misc.j"
@import "Settings.j"


@implementation RewardsController: CPObject {
    CPImage _rewardsImages, croppedImage;
    CPTimer _timerRewardsController;
    CPImageView _rewardView;
    int currentRandom, oldRandom;
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


// 24 reward images, each 200x200 → 4800 x 200
// The image _rewardsImages is a sprite, containing 24 images at 200x200 px
- (id) drawRandom { //console.info("RewardsController>drawRandom");
    if ([_rewardsImages loadStatus] != CPImageLoadStatusCompleted) return;

    currentRandom = [Misc iRandom: 24]; // avoid repeats
    if (currentRandom == oldRandom)  currentRandom = [Misc iRandom: 24];
    oldRandom = currentRandom;

    // verstehe eigentlich nicht, warum das funktioniert:
    [_rewardView setBounds: CGRectMake(0, 0, (-12 + currentRandom) * 1200, 600)];
    [_rewardView setHidden: NO];

    _timerRewardsController = [CPTimer scheduledTimerWithTimeInterval: [Settings timeoutRewardPicturesInSeconds] target: self selector: @selector(onTimeoutRewardsController:) userInfo: nil repeats: NO];
}


-(void) onTimeoutRewardsController: (CPTimer) timer { //console.info("RewardsController>onTimeoutRewardsController");
    [_rewardView setHidden: YES];
}


@end
