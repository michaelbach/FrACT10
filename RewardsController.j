/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

RewardsController.j

2020-05-23 This class manages the reward images sprite

🤓🤗🐻🐹🍒🐸🐥🐞
👻😻🐭🦎🐇🐿️🐬🦉
🐝🦋🐢🐙🦞🦜🦘🦚
🦭🐠🐳🦕🦖🐜🦔⛄️

To be done:
🦆🦎🏓🛼🥕🍎🌈🪷🐁🫎

*/


@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Misc.j"
@import "Settings.j"


kNImages = 32;
kSize = 200;
kScale = 3;
kSizeScaled = kSize * kScale;
kSpriteFile = "allRewardSprites.png";


@implementation RewardsController: CPObject {
    CPImage _rewardImageStrip;
    CPTimer _timerRewardsController;
    CPImageView _rewardView;
    int _oldImage, _currentImage;
    BOOL _unitTesting;
    float _savedTimeout;
}


- (id) initWithView: (CPImageView) view { //console.info("RewardsController>initWithView", view);
    self = [super init];
    if (self) {
        _rewardImageStrip = [[CPImage alloc] initWithContentsOfFile: [[CPBundle mainBundle] pathForResource: kSpriteFile]];
        _rewardView = view;
        [_rewardView setImageAlignment: CPImageAlignCenter]; // is already the default
        [_rewardView setImageScaling: CPImageScaleNone];
        [_rewardView setAlphaValue: 0.98];
        [_rewardView setHitTests: NO]; // allows "click through"
        [_rewardImageStrip setSize: CGSizeMake(kNImages * kSizeScaled, kSizeScaled)];
        _oldImage = -1;
        _unitTesting = NO;
        _savedTimeout = [Settings timeoutRewardPicturesInSeconds]
    }
    return self;
}


- (void) unittest { //console.info("RewardsController>test");
    _unitTesting = YES;
    _currentImage = 0;
    _savedTimeout = [Settings timeoutRewardPicturesInSeconds]
    [Settings setTimeoutRewardPicturesInSeconds: 0.5];
    [self drawImage];
}


- (id) drawRandom { //console.info("RewardsController>drawRandom");
    _currentImage = [Misc iRandom: kNImages];
    // no immediate repeats
    while (_currentImage == _oldImage)  _currentImage = [Misc iRandom: kNImages];
    _oldImage = _currentImage;
    //_currentImage = 0;
    [self drawImage];
}


// There are 24 reward images, each 200x200 → 4800 x 200
// The image _rewardImageStrip is a strip of sprites, it contains 24 images at 200x200 px
- (id) drawImage { // console.info("RewardsController>drawImageI: ", _currentImage);
    if ([_rewardImageStrip loadStatus] != CPImageLoadStatusCompleted) return;
    [_rewardView setImage: _rewardImageStrip];
    [[_rewardView superview] addSubview: _rewardView]; // so it's ordered front

    // don't really understand why this bounds setting works to select a single sprite
    [_rewardView setBounds: CGRectMake(0, 0, (2 * _currentImage - kNImages + 2) * kSizeScaled, kSizeScaled)];

    _timerRewardsController = [CPTimer scheduledTimerWithTimeInterval: [Settings timeoutRewardPicturesInSeconds] target: self selector: @selector(onTimeoutRewardsController:) userInfo: nil repeats: NO];
}


- (void) onTimeoutRewardsController: (CPTimer) timer { //console.info("RewardsController>onTimeoutRewardsController");
    [_rewardView setImage: nil]; // and now↓ order back so the tooltip areas are not covered
    [[_rewardView superview] addSubview: _rewardView positioned: CPWindowBelow relativeTo: nil];
    if (!_unitTesting) return;

    if (++_currentImage >= kNImages) {
        _unitTesting = NO;
        [Settings setTimeoutRewardPicturesInSeconds: _savedTimeout];
        return;
    }
    [self drawImage];
}


@end
