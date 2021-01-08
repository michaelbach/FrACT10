/* 2021-01-06
 This class manages the FrACT10 trial history
 */


@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Globals.j"


@implementation TrialHistoryController: CPObject {
    id _trialHistory;
    int _currentIndex, _nTrials;
    CPDate _dateStart;
    int presented @accessors;
    int responded @accessors;
    BOOL correct @accessors;
}


- (id) initWithNumTrials: (int) nTrials { //console.info("TrialHistoryController>initWithNumTrials");
    self = [super init];
    if (self) { // console.info("TrialHistory>initWithNumTrials: success");
        _trialHistory = [nTrials];
        _currentIndex = 0;
        _nTrials = nTrials;
        _dateStart = [CPDate date];
    }
    return self;
}


- (void) trialEnded {  //console.info("TrialHistoryController>trialEnded");
    _trialHistory[_currentIndex] = {};
    _trialHistory[_currentIndex].reactionTimeInMs = Math.round(-[_dateStart timeIntervalSinceNow] * 1000.0);
    _trialHistory[_currentIndex].presented = presented;
    _trialHistory[_currentIndex].responded = responded;
    _trialHistory[_currentIndex].correct = correct;
    _currentIndex++;
    _dateStart = [CPDate date];
}


- (void) runEnded {
    var s = "trial" + tab + "value" + tab + "choicePresented" + tab + "choiceResponded" + tab + "correct" + tab + "reactionTime" + crlf;
    for (var i=0; i < _nTrials; ++i) {
        s += [Misc stringFromInteger: i + 1] + tab;
        //s += _trialHistory[i].responded + tab;
        s += _trialHistory[i].presented + tab;
        s += _trialHistory[i].responded + tab;
        s += _trialHistory[i].correct + tab;
    }
    console.info("_trialHistory: ", s);

}

@end

