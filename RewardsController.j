/* 2020-05-23
 This class manages the reward images sprite
*/


@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Settings.j"


@implementation RewardsController: CPObject {
    CPImage _rewardsImages;
    CPTimer _timerRewardsController;
    CPImageView _rewardView;
}


- (id) initWithView: (CPImageView) view { //console.log("RewardsController>initWithView");
    self = [super init];
    if (self) {
        _rewardView = view;
        [_rewardView setHidden: YES];
        _rewardsImages = [[CPImage alloc] initWithContentsOfFile: [[CPBundle mainBundle] pathForResource: "allRewards4800x200.png"]];
    }
    return self;
}


// The image _rewardsImages is a sprite, containing 24 images at 200x200 px
- (id) drawRandom { //console.log("RewardsController>drawRandom");
    if ([_rewardsImages loadStatus] != CPImageLoadStatusCompleted) return;
    [_rewardsImages setSize: CGSizeMake(4800 * 3, 200 * 3)];
    // verstehe eigentlich nicht, warum das funktioniert:
    [_rewardView setBounds: CGRectMake(0, 0, (-12 + [Misc iRandom: 24]) * 1200, 600)];
    //console.log([_rewardView bounds]);  console.log([_rewardView frame]);
    [_rewardView setImage: _rewardsImages];
    [_rewardView setAlphaValue: 0.8];
    [_rewardView setHidden: NO];
    _timerRewardsController = [CPTimer scheduledTimerWithTimeInterval: [Settings timeoutRewardPicturesInSeconds] target:self selector:@selector(onTimeoutRewardsController:) userInfo:nil repeats:NO];
}


-(void) onTimeoutRewardsController: (CPTimer) timer { //console.log("RewardsController>initWithView");
    [_rewardView setHidden: YES];
}


@end
