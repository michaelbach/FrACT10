/*
 This file is part of FrACT10, a vision test battery.
 © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 TrialHistoryController.j

 */


@import <Foundation/Foundation.j>


/**
 2021-01-06 This class manages the FrACT10 trial history that collects the full run info
 */
@implementation TrialHistoryController: CPObject {
    id trialHistoryRecord;
    // the fields of above record
    float value;
    int presented;
    int responded;
    BOOL isCorrect;
    // end fields
    CPDate dateStart;
    int currentIndex, nTrialsLocal;
    CPString resultsHistoryString;
}


+ (id) trialHistoryRecord {return trialHistoryRecord;}
+ (void) setTrialHistoryRecord: (id) v {value = v;}

+ (float) value {return value;}
+ (void) setValue: (float) v {value = v;}

+ (int) presented {return presented;}
+ (void) setPresented: (int) v {presented = v;}

+ (int) responded {return responded;}
+ (void) setResponded: (int) v {responded = v;}

+ (BOOL) isCorrect {return isCorrect;}
+ (void) setIsCorrect: (BOOL) v {isCorrect = v;}

+ (CPString) resultsHistoryString {return resultsHistoryString;}
+ (void) setResultsHistoryString: (CPString) v {resultsHistoryString = v;}


+ (void) initialize { //CPLog("TrialHistoryController>initialize");
    [super initialize];
}


+ initWithNumTrials: (int) nTrials { //console.info("TrialHistoryController>initWithNumTrials", nTrials);
    trialHistoryRecord = [];
    gTestDetails = {};
    gTestDetails[td_vsExpFormat] = gVersionOfExportFormat;
    gTestDetails[td_vsFrACT] = "FrACT10·" + gVersionStringOfFract + "·" + gVersionDateOfFrACT;
    gTestDetails[td_nTrials] = 0;
    gTestDetails[td_nCorrect] = 0;
    gTestDetails[td_nIncorrect] = 0;
    currentIndex = 0;
    nTrialsLocal = nTrials;
    [self setResultsHistoryString: ""];
    dateStart = [CPDate date];
}


+ (void) trialEnded { //console.info("TrialHistoryController>trialEnded");
    if (currentIndex > nTrialsLocal) return;  //just for safety, should not occur
    trialHistoryRecord[currentIndex] = {};
    trialHistoryRecord[currentIndex].value = value;
    trialHistoryRecord[currentIndex].presented = presented;
    trialHistoryRecord[currentIndex].responded = responded;
    trialHistoryRecord[currentIndex].isCorrect = isCorrect;
    const tIsi = gBalmTestIDs.includes(gCurrentTestID) ? [Settings balmIsiMillisecs] : [Settings timeoutIsiMillisecs];
    trialHistoryRecord[currentIndex].reactionTimeInMs = Math.round(-[dateStart timeIntervalSinceNow] * 1000.0) - tIsi;
    currentIndex++;
    gTestDetails[td_nTrials] += 1; //calculation for BaLM
    if (isCorrect) gTestDetails[td_nCorrect] += 1;
    else gTestDetails[td_nIncorrect] += 1;
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
        s += th.isCorrect + tab;
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
        trialsDF.push({lMar: thi.value, correct: thi.isCorrect});
    }
    return trialsDF;
}
@end
