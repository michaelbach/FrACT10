/*
This file is part of FrACT10, a vision test battery.
© 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

Sound.j

2020-05-25 This class manages the FrACT10 feedback sounds
*/


@import <Foundation/Foundation.j>


@implementation Sound: CPObject {
    id audioContext, bufferTrialStart, bufferTrialYes, bufferTrialNo, bufferRunEnd, volumeNode;
    BOOL needsInitAfterUserinteraction;
    CPTimer _timer;
}


- (void) updateSoundFiles { //console.info("Sound>updateSoundFiles");
    needsInitAfterUserinteraction = YES;
    [self initAfterUserinteraction];
}


//the below is clumsy (doing it 3 times), but the closure didn't take the provided buffer in my attempts.


//for start of trial (BaLM)
- (void) loadSoundTrialStart { //console.info("Sound>loadSoundTrialStart");
    bufferTrialStart = null;
    const request = new XMLHttpRequest();
    request.open('GET', "Resources/sounds/trialStart/" + gSoundsTrialStart[[Settings soundTrialStartIndex]], true);
    request.responseType = 'arraybuffer';
    request.onload = function() {  //Decode asynchronously
        audioContext.decodeAudioData(request.response, function(buff) {bufferTrialStart = buff;});
    }
    request.send();
}




//for correct response
- (void) loadSoundTrialYes { //console.info("Sound>loadSoundTrialYes");
    bufferTrialYes = null;
    const request = new XMLHttpRequest();
    request.open('GET', "Resources/sounds/trialYes/" + gSoundsTrialYes[[Settings soundTrialYesIndex]], true);
    request.responseType = 'arraybuffer';
    request.onload = function() {  //Decode asynchronously
        audioContext.decodeAudioData(request.response, function(buff) {bufferTrialYes = buff;});
    }
    request.send();
}


//for incorrect responses
- (void) loadSoundTrialNo { //console.info("Sound>loadSound");
    bufferTrialNo = null;
    const request = new XMLHttpRequest();
    request.open('GET', "Resources/sounds/trialNo/" + gSoundsTrialNo[[Settings soundTrialNoIndex]], true);
    request.responseType = 'arraybuffer';
    request.onload = function() {  //Decode asynchronously
        audioContext.decodeAudioData(request.response, function(buff) {bufferTrialNo = buff;});
    }
    request.send();
}


//for end of run
- (void) loadSoundRunEnd { //console.info("Sound>loadSound");
    bufferRunEnd = null;
    const request = new XMLHttpRequest();
    request.open('GET', "Resources/sounds/runEnd/" + gSoundsRunEnd[[Settings soundRunEndIndex]], true);
    request.responseType = 'arraybuffer';
    request.onload = function() {  //Decode asynchronously
        audioContext.decodeAudioData(request.response, function(buff) {bufferRunEnd = buff;});
    }
    request.send();
}


- (void) playSoundFromBuffer: (id) buffer { //console.info("Sound>playSoundFromBuffer");
    if (needsInitAfterUserinteraction) [self initAfterUserinteraction];
    if (buffer === nil) return;
    const source = audioContext.createBufferSource();
    source.buffer = buffer;
    source.connect(volumeNode);
    volumeNode.gain.value = Math.pow([Settings soundVolume] / 100.0, 2); //a more physiologic transfer function IMHO
    source.start(0);
}


- (void) playNumber: (int) number {
    switch (number) {
        case kSoundTrialStart: [self playSoundFromBuffer: bufferTrialStart];  break;
        case kSoundTrialYes: [self playSoundFromBuffer: bufferTrialYes];  break;
        case kSoundTrialNo: [self playSoundFromBuffer: bufferTrialNo];  break;
        case kSoundRunEnd: [self playSoundFromBuffer: bufferRunEnd];  break;
        default: alert("xx");
    }
}
- (void) playDelayedNumber: (int) number {
    _timer = [CPTimer scheduledTimerWithTimeInterval: 0.1 target: self selector: @selector(onTimeout:) userInfo:number repeats: NO];
}
- (void) onTimeout: (CPTimer) timer { //console.info("FractController>onTimeoutDisplay");
    [self playNumber: [timer userInfo]];
}


- (void) initAfterUserinteraction { //console.info("Sound>initAfterUserinteraction");
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
    [self loadSoundTrialStart];  [self loadSoundTrialYes];
    [self loadSoundTrialNo];  [self loadSoundRunEnd];
}


- (id) init { //console.info("Sound>init");
    self = [super init];
    if (self) {
        //starting the AudioContext is not allowed unless by user interaction
        needsInitAfterUserinteraction = YES;
    }
    return self;
}


@end
