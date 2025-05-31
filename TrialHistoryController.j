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
    id trialHistoryRecord;
    // the fields of above record
    CPDate dateStart;
    float value;
    int presented;
    int responded;
    int nTotal;
    int nCorrect;
    int nIncorrect;
    BOOL correct;
    // end fields
    int currentIndex, nTrialsLocal;
    CPString resultsHistoryString;
}


+ (id) trialHistoryRecord {return trialHistoryRecord;}
+ (void) setTrialHistoryRecord: (id) v {value = v;}

+ (float) value {return resultsHistoryString;}
+ (void) setValue: (float) v {value = v;}

+ (int) presented {return presented;}
+ (void) setPresented: (int) v {presented = v;}

+ (int) responded {return presented;}
+ (void) setResponded: (int) v {responded = v;}

+ (int) nTotal {return presented;}
+ (void) setNTotal: (int) v {nTotal = v;}

+ (int) nCorrect {return presented;}
+ (void) setNCorrect: (int) v {nCorrect = v;}

+ (int) nIncorrect {return presented;}
+ (void) setNIncorrect: (int) v {nIncorrect = v;}

+ (BOOL) correct {return correct;}
+ (void) setCorrect: (BOOL) v {correct = v;}

+ (CPString) resultsHistoryString {return resultsHistoryString;}
+ (void) setResultsHistoryString: (CPString) v {resultsHistoryString = v;}


+ (void) initialize { //CPLog("TrialHistoryController>initialize");
    [super initialize];
}


+ initWithNumTrials: (int) nTrials { //console.info("TrialHistoryController>initWithNumTrials", nTrials);
    trialHistoryRecord = [];
    currentIndex = 0;
    nTrialsLocal = nTrials;
    dateStart = [CPDate date];
    [self setResultsHistoryString: ""];
    [self setNTotal: 0];  [self setNCorrect: 0];  [self setNIncorrect: 0];
}


+ (void) trialEnded { //console.info("TrialHistoryController>trialEnded");
    if (currentIndex > nTrialsLocal) return;  //just for safety, should not occur
    trialHistoryRecord[currentIndex] = {};
    trialHistoryRecord[currentIndex].value = value;
    trialHistoryRecord[currentIndex].presented = presented;
    trialHistoryRecord[currentIndex].responded = responded;
    trialHistoryRecord[currentIndex].correct = correct;
    const tIsi = gBalmTestIDs.includes(gCurrentTestID) ? [Settings balmIsiMillisecs] : [Settings timeoutIsiMillisecs];
    trialHistoryRecord[currentIndex].reactionTimeInMs = Math.round(-[dateStart timeIntervalSinceNow] * 1000.0) - tIsi;
    currentIndex++;
    [self setNTotal: nTotal + 1]; //calculation for BaLM
    if (correct) [self setNCorrect: nCorrect + 1];
    else [self setNIncorrect: nIncorrect + 1];
    dateStart = [CPDate date];
}


+ (void) runEnded { //console.info("TrialHistoryController>trialEnded");
    //console.info(trialHistoryRecord);
    let s = "trial" + tab + "value" + tab + "choicePresented" + tab + "choiceResponded" + tab + "correct" + tab + "reactionTimeInMs" + crlf;
    for (let i = 0; i < trialHistoryRecord.length; ++i) {
        const th = trialHistoryRecord[i];
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
+ (id) composeInfo4CI {
    const trialsDF = [];
    for (const thi of trialHistoryRecord) {
        trialsDF.push({lMar: thi.value, correct: thi.correct});
    }
    return trialsDF;
}
@end
