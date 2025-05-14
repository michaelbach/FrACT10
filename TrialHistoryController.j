/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

TrialHistoryController.j

*/


@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>


/**
 2021-01-06 This class manages the FrACT10 trial history that collects the full run info
*/
@implementation TrialHistoryController: CPObject {
    id _trialHistory;
    int _currentIndex, _nTrials;
    CPDate _dateStart;
    float value @accessors;
    int presented @accessors;
    int responded @accessors;
    int nTotal @accessors;
    int nCorrect @accessors;
    int nIncorrect @accessors;
    BOOL correct @accessors;
    CPString resultsHistoryString @accessors;
}


- (id) initWithNumTrials: (int) nTrials { //console.info("TrialHistoryController>initWithNumTrials", nTrials);
    self = [super init];
    if (self) { //console.info("TrialHistory>initWithNumTrials: success");
        _trialHistory = [];
        _currentIndex = 0;
        _nTrials = nTrials;
        _dateStart = [CPDate date];
        [self setResultsHistoryString: ""];
        [self setNTotal: 0];  [self setNCorrect: 0];  [self setNIncorrect: 0];
    }
    return self;
}


- (void) trialEnded { //console.info("TrialHistoryController>trialEnded");
    if (_currentIndex > _nTrials) return;  //just for safety, should not occur
    _trialHistory[_currentIndex] = {};
    _trialHistory[_currentIndex].value = value;
    _trialHistory[_currentIndex].presented = presented;
    _trialHistory[_currentIndex].responded = responded;
    _trialHistory[_currentIndex].correct = correct;
    const tIsi = gBalmTestIDs.includes(gCurrentTestID) ? [Settings balmIsiMillisecs] : [Settings timeoutIsiMillisecs];
    _trialHistory[_currentIndex].reactionTimeInMs = Math.round(-[_dateStart timeIntervalSinceNow] * 1000.0) - tIsi;
    _currentIndex++;
    [self setNTotal: nTotal + 1]; //calculation for BaLM
    if (correct) [self setNCorrect: nCorrect + 1];
    else [self setNIncorrect: nIncorrect + 1];
    _dateStart = [CPDate date];
}


- (void) runEnded { //console.info("TrialHistoryController>trialEnded");
    let s = "trial" + tab + "value" + tab + "choicePresented" + tab + "choiceResponded" + tab + "correct" + tab + "reactionTimeInMs" + crlf;
    for (let i = 0; i < _trialHistory.length; ++i) {
        const th = _trialHistory[i];
        s += [Misc stringFromInteger: i + 1] + tab;
        s += [Misc stringFromNumber: th.value decimals: 3 localised: YES]  + tab;
        s += th.presented + tab;
        s += th.responded + tab;
        s += th.correct + tab;
        s += th.reactionTimeInMs + crlf;
    }
    [self setResultsHistoryString: s];
}


/**
 Here we collect all info in a dataframe that is needed for the CI95 calculation
 */
- (id) composeInfo4CI {
    const trialsDF = [];
    for (const thi of _trialHistory) {
        trialsDF.push({lMar: thi.value, correct: thi.correct});
    }
    return trialsDF;
}
@end
