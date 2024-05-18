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
    BOOL needsInitAfterUserinteraction;
}


- (void) updateSoundFiles: (CPNotification) aNotification { //console.info("Sound>updateSoundFiles");
    needsInitAfterUserinteraction = YES;
    [self initAfterUserinteraction];
}


// the below is clumsy (doing it 3 times), but the closure didn't take the provided buffer in my attempts.

// SoundTrialYES for correct response
- (void) loadSoundTrialYES { //console.info("Sound>loadSound");
    buffer1 = null;
    const request = new XMLHttpRequest();
    request.open('GET', "Resources/sounds/trialYES/" + gSoundsTrialYES[[Settings soundTrialYesIndex]], true);
    request.responseType = 'arraybuffer';
    request.onload = function() {  // Decode asynchronously
        audioContext.decodeAudioData(request.response, function(buff) {buffer1 = buff;});
    }
    request.send();
}


// SoundTrialNO for incorrect responses
- (void) loadSoundTrialNO { //console.info("Sound>loadSound");
    buffer2 = null;
    const request = new XMLHttpRequest();
    request.open('GET', "Resources/sounds/trialNO/" + gSoundsTrialNO[[Settings soundTrialNoIndex]], true);
    request.responseType = 'arraybuffer';
    request.onload = function() {  // Decode asynchronously
        audioContext.decodeAudioData(request.response, function(buff) {buffer2 = buff;});
    }
    request.send();
}


// SoundRunEnd for end of run
- (void) loadSoundRunEnd { //console.info("Sound>loadSound");
    buffer3 = null;
    const request = new XMLHttpRequest();
    request.open('GET', "Resources/sounds/runEnd/" + gSoundsRunEnd[[Settings soundRunEndIndex]], true);
    request.responseType = 'arraybuffer';
    request.onload = function() {  // Decode asynchronously
        audioContext.decodeAudioData(request.response, function(buff) {buffer3 = buff;});
    }
    request.send();
}


- (void) playSoundFromBuffer: (id) buffer { //console.info("Sound>playSoundFromBuffer");
    if (needsInitAfterUserinteraction)  [self initAfterUserinteraction];
    if (buffer == nil) return;
    const source = audioContext.createBufferSource();
    source.buffer = buffer;
    source.connect(volumeNode);
    volumeNode.gain.value = Math.pow([Settings soundVolume] / 100.0, 2); // a more physiologic transfer function IMHO
    source.start(0);
}


- (void) play1 { //console.info("Sound>playSoundTrialYES");
    [self playSoundFromBuffer: buffer1];
}
- (void) play2 { //console.info("Sound>playSoundTrialNO");
    [self playSoundFromBuffer: buffer2];
}
- (void) play3 { //console.info("Sound>playSoundRunEnd");
    [self playSoundFromBuffer: buffer3];
}


- (void) initAfterUserinteraction {
    if (!needsInitAfterUserinteraction)  return;
    needsInitAfterUserinteraction = NO;
    if ('webkitAudioContext' in window) {
        audioContext = new window.webkitAudioContext();
    } else {
        audioContext = new window.AudioContext();
    }
    volumeNode = audioContext.createGain();
    volumeNode.gain.value = 0;
    volumeNode.connect(audioContext.destination);
    [self loadSoundTrialYES];  [self loadSoundTrialNO];  [self loadSoundRunEnd];
}


- (id) init { //console.info("Sound>init");
    self = [super init];
    if (self) {
        // starting the AudioContext is not allowed unless by user interaction
        needsInitAfterUserinteraction = YES;
        [[CPNotificationCenter defaultCenter] addObserver: self selector: @selector(updateSoundFiles:) name: "updateSoundFiles" object: nil]; // needed when changing sounds in Presets
    }
    return self;
}


@end
