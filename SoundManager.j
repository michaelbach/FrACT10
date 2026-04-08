/*
This file is part of FrACT10, a vision test battery.
© 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>
includes code suggestions by Gemini

SoundManager.j

This class manages the FrACT10 feedback sounds.
It is implemented as a singleton to be accessible from anywhere. By using a singleton,
we ensure that there is exactly one AudioContext and one set of sound buffers active at any time.
This prevents issues like overlapping audio contexts or redundant network requests if multiple
controllers were to mistakenly initialize their own sound logic.

*/

@import <Foundation/Foundation.j>
@import "Globals.j"
@import "Settings.j"

let SharedSoundManager = nil;


@implementation SoundManager: CPObject {
    id audioContext, volumeNode;
    Object soundBuffers;
    BOOL needsInitAfterUserinteraction;
}


+ (id) sharedManager {
    if (!SharedSoundManager) {
        SharedSoundManager = [[SoundManager alloc] init];
    }
    return SharedSoundManager;
}


- (id) init {
    self = [super init];
    if (self) {
        soundBuffers = {};
        needsInitAfterUserinteraction = YES;
    }
    return self;
}


/**
 Re-loads all sound files based on current settings.
 Useful when user changes sound selection in settings.
 */
- (void) updateSoundFiles {
    if (needsInitAfterUserinteraction) {
        [self initAfterUserinteraction];
    } else {
        [self _loadAllSounds];
    }
}


/**
 Initializes the AudioContext. Must be called after a user interaction (click/keypress).
 */
- (void) initAfterUserinteraction {
    if (!needsInitAfterUserinteraction) return;
    needsInitAfterUserinteraction = NO;

    if (window.AudioContext) {
        audioContext = new window.AudioContext();
    } else if (window.webkitAudioContext) {
        audioContext = new window.webkitAudioContext();
    }

    if (!audioContext) {
        console.error("SoundManager: Could not create AudioContext");
        return;
    }

    volumeNode = audioContext.createGain();
    volumeNode.connect(audioContext.destination);
    [self _loadAllSounds];
}


- (void) _loadAllSounds {
    [self _loadSound: kSoundTrialStart
                path: "Resources/sounds/trialStart/" + gSoundsTrialStart[[Settings soundTrialStartIndex]]];
    [self _loadSound: kSoundTrialYes
                path: "Resources/sounds/trialYes/" + gSoundsTrialYes[[Settings soundTrialYesIndex]]];
    [self _loadSound: kSoundTrialNo
                path: "Resources/sounds/trialNo/" + gSoundsTrialNo[[Settings soundTrialNoIndex]]];
    [self _loadSound: kSoundRunEnd
                path: "Resources/sounds/runEnd/" + gSoundsRunEnd[[Settings soundRunEndIndex]]];
}


- (void) _loadSound: (int) soundType path: (CPString) path {
    const request = new XMLHttpRequest();
    request.open('GET', path, true);
    request.responseType = 'arraybuffer';
    request.onload = function() {
        audioContext.decodeAudioData(request.response, function(buffer) {
            soundBuffers[soundType] = buffer;
        }, function(error) {
            console.error("SoundManager: Error decoding audio data for " + path, error);
        });
    }
    request.onerror = function() {
        console.error("SoundManager: Network error loading sound " + path);
    }
    request.send();
}


/**
 Plays a sound by its type (e.g., kSoundTrialYes).
 @param soundType One of the kSound* constants in Globals.j
 */
- (void) playSound: (int) soundType {
    if (needsInitAfterUserinteraction) {
        [self initAfterUserinteraction];
    }

    const buffer = soundBuffers[soundType];
    if (!buffer || !audioContext) return;

    if (audioContext.state === 'suspended') {
        audioContext.resume();
    }

    const source = audioContext.createBufferSource();
    source.buffer = buffer;
    source.connect(volumeNode);

    //Approximation to physiological volume curve (square of percentage)
    const volume = [Settings soundVolume] / 100.0;
    volumeNode.gain.value = volume * volume;

    source.start(0);
}


/**
 Plays a sound after a short delay.
 Useful for testing settings where the file might still be loading.
 */
- (void) playSound: (int) soundType delayed: (float) delay {
    [CPTimer scheduledTimerWithTimeInterval: delay
                                     target: self
                                   selector: @selector(_playFromTimer:)
                                   userInfo: soundType
                                    repeats: NO];
}


- (void) _playFromTimer: (CPTimer) aTimer {
    [self playSound: [aTimer userInfo]];
}


@end
