/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

Sound.j

2020-05-25 This class manages the FrACT10 feedback sounds
*/


@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>


@implementation Sound: CPObject {
    id audioContext, buffer1, buffer2, buffer3, volumeNode;
    BOOL needsAudioContext;
}


// the below is clumsy (doing it 3 times), but the closure didn't take the provided buffer in my attempts.

// sound1: “tink” for correct response
- (void) loadSound1 { //console.info("Sound>loadSound");
    buffer1 = null;
    const request = new XMLHttpRequest();
    request.open('GET', "Resources/sounds/trialYes.mp3", true);
    request.responseType = 'arraybuffer';
    request.onload = function() {  // Decode asynchronously
            audioContext.decodeAudioData(request.response, function(buff) {buffer1 = buff;});
    }
    request.send();
}


// sound2: “whistle” for incorrect responses
- (void) loadSound2 { //console.info("Sound>loadSound");
    buffer2 = null;
    const request = new XMLHttpRequest();
    request.open('GET', "Resources/sounds/trialNo.mp3", true);
    request.responseType = 'arraybuffer';
    request.onload = function() {  // Decode asynchronously
            audioContext.decodeAudioData(request.response, function(buff) {buffer2 = buff;});
    }
    request.send();
}


// sound3, “gong” for end of run
- (void) loadSound3 { //console.info("Sound>loadSound");
    buffer3 = null;
    const request = new XMLHttpRequest();
    request.open('GET', "Resources/sounds/runEnd.mp3", true);
    request.responseType = 'arraybuffer';
    request.onload = function() {  // Decode asynchronously
        audioContext.decodeAudioData(request.response, function(buff) {buffer3 = buff;});
    }
    request.send();
}


- (void) playSoundFromBuffer: (id) buffer { //console.info("Sound>playSoundFromBuffer");
    if (needsAudioContext)  [self initAfterUserinteraction];
    if (buffer == nil) return;
    const source = audioContext.createBufferSource();
    source.buffer = buffer;
    source.connect(volumeNode);
    volumeNode.gain.value = Math.pow([Settings soundVolume] / 100.0, 2); // a more physiologic transfer function IMHO
    source.start(0);
}


- (void) play1 { //console.info("Sound>playSound1");
    [self playSoundFromBuffer: buffer1];
}
- (void) play2 { //console.info("Sound>playSound2");
    [self playSoundFromBuffer: buffer2];
}
- (void) play3 { //console.info("Sound>playSound3");
    [self playSoundFromBuffer: buffer3];
}


- (void) initAfterUserinteraction {
    if (!needsAudioContext)  return;
    needsAudioContext = NO;
    if ('webkitAudioContext' in window) {
        audioContext = new window.webkitAudioContext();
    } else {
        audioContext = new window.AudioContext();
    }
    volumeNode = audioContext.createGain();
    volumeNode.gain.value = 0;
    volumeNode.connect(audioContext.destination);
    [self loadSound1];  [self loadSound2];  [self loadSound3];
}


- (id) init { //console.info("Sound>init");
    self = [super init];
    if (self) {
        // starting the AudioContext is not allowed unless by user interaction
        needsAudioContext = YES;
    }
    return self;
}


@end
