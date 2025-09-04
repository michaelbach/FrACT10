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
    float finalValue;
    int currentIndex, nTrialsLocal;
    CPString resultsHistoryString;
}


+ (id) trialHistoryRecord {return trialHistoryRecord;}
+ (void) setTrialHistoryRecord: (id) v {value = v;}

+ (CPDate) dateStart {return dateStart;}
+ (void) setDateStart: (CPDate) v {dateStart = v;}

+ (float) value {return value;}
+ (void) setValue: (float) v {value = v;}

+ (float) finalValue {return finalValue;}
+ (void) setFinalValue: (float) v {finalValue = v;}

+ (int) presented {return presented;}
+ (void) setPresented: (int) v {presented = v;}

+ (int) responded {return responded;}
+ (void) setResponded: (int) v {responded = v;}

+ (int) nTotal {return nTotal;}
+ (void) setNTotal: (int) v {nTotal = v;}

+ (int) nCorrect {return nCorrect;}
+ (void) setNCorrect: (int) v {nCorrect = v;}

+ (int) nIncorrect {return nIncorrect;}
+ (void) setNIncorrect: (int) v {nIncorrect = v;}

+ (BOOL) correct {return correct;}
+ (void) setCorrect: (BOOL) v {correct = v;}

+ (CPString) resultsHistoryString {return resultsHistoryString;}
+ (void) setResultsHistoryString: (CPString) v {resultsHistoryString = v;}

// preparation the factor out "composing" the `currentTestResultExportString`
// these ↓ are used in the `currentTestResultExportString` and should be collected
// "vsExportFormat" + tab + gVersionOfExportFormat;
// "vsFrACT" + tab + gVersionDateOfFrACT;
// "decimalMark" + tab + [Settings decimalMarkChar];
// "ID" + tab + [Settings patID];
// "eyeCondition" + tab + gEyeIndex2string[[Settings eyeIndex]];
// "date" + tab + [Misc date2YYYY_MM_DD: now];
// "time" + tab + [Misc date2HH_MM_SS: now];
// "test" + tab + [Misc testNameGivenTestID: gCurrentTestID];
// eccentricityX, eccentricityY
// halfCI95, colorForeBack, noiseContrast, gratingShape
// "Hit rate: " + s + "%";
// "value" + tab + [Misc stringFromNumber: [self resultValue4Export] decimals: nDigits localised: YES]; →finalValue
// "unit1" + tab + gAppController.currentTestResultUnit
// "distanceInCm" + tab + [Misc stringFromNumber: [Settings distanceInCM] decimals: 1 localised: YES];
// "contrastWeber" + tab + 99;
// "unit2" + tab + "%";
// "rangeLimitStatus" + tab + rangeLimitStatus;
// "crowding" + tab + [Settings crowdingType];


+ (void) initialize { //CPLog("TrialHistoryController>initialize");
    [super initialize];
}


+ initWithNumTrials: (int) nTrials { //console.info("TrialHistoryController>initWithNumTrials", nTrials);
    trialHistoryRecord = [];
    currentIndex = 0;
    nTrialsLocal = nTrials;
    [self setDateStart: [CPDate date]];
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
