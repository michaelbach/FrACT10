/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, michael.bach@uni-freiburg.de, <https://michaelbach.de>

TrialHistoryController.j

2021-01-06 This class manages the FrACT10 trial history that contains the full run info
*/


@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Globals.j"


@implementation TrialHistoryController: CPObject {
    id _trialHistory;
    int _currentIndex, _nTrials;
    CPDate _dateStart;
    float value @accessors;
    int presented @accessors;
    int responded @accessors;
    BOOL correct @accessors;
    CPString resultsHistoryString @accessors;
}


- (id) initWithNumTrials: (int) nTrials { //console.info("TrialHistoryController>initWithNumTrials");
    self = [super init];
    if (self) { // console.info("TrialHistory>initWithNumTrials: success");
        _trialHistory = [];
        _currentIndex = 0;
        _nTrials = nTrials;
        _dateStart = [CPDate date];
        [self setResultsHistoryString: ""];
    }
    return self;
}


- (void) trialEnded {  //console.info("TrialHistoryController>trialEnded");
    _trialHistory[_currentIndex] = {};
    _trialHistory[_currentIndex].value = value;
    _trialHistory[_currentIndex].presented = presented;
    _trialHistory[_currentIndex].responded = responded;
    _trialHistory[_currentIndex].correct = correct;
    _trialHistory[_currentIndex].reactionTimeInMs = Math.round(-[_dateStart timeIntervalSinceNow] * 1000.0);
    _currentIndex++;
    _dateStart = [CPDate date];
}


- (void) runEnded {  //console.info("TrialHistoryController>trialEnded");
    var s = "trial" + tab + "value" + tab + "choicePresented" + tab + "choiceResponded" + tab + "correct" + tab + "reactionTimeInMs" + crlf;
    for (var i=0; i < _trialHistory.length; ++i) {
        s += [Misc stringFromInteger: i + 1] + tab;
        s += _trialHistory[i].value + tab;
        s += _trialHistory[i].presented + tab;
        s += _trialHistory[i].responded + tab;
        s += _trialHistory[i].correct + tab;
        s += _trialHistory[i].reactionTimeInMs + crlf;
    }
    [self setResultsHistoryString: s];
}


- (id) composeInfo4CI {
    var trialsDF = [];
    for (var i=0; i < _trialHistory.length; ++i) {
        trialsDF.push({lMar: _trialHistory[i].value, correct: _trialHistory[i].correct});
    }
    return trialsDF;
}
@end
