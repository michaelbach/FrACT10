/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, michael.bach@uni-freiburg.de, <https://michaelbach.de>

MDBdispersionEstimation.j

*/

@import "MDBSimplestatistics.j"
@import "Globals.j"


/**
 Calculate the CI95
 2021-04-22  begun
 */
@implementation MDBDispersionEstimation


let kWorstLogMAR, kBestLogMAR, kGuess, testDF; // there are no class properties in Cappuccino


+ (void) initResultStatistics { //console.info("Entering initResultStatistics");
    kWorstLogMAR = [MiscSpace logMARfromDecVA: [MiscSpace decVAFromGapPixels: gStrokeMaximal]];
    kBestLogMAR =  [MiscSpace logMARfromDecVA: [MiscSpace decVAFromGapPixels: gStrokeMinimal]];
    //console.info("kWorstLogMAR: ", kWorstLogMAR, ", kBestLogMAR: ", kBestLogMAR);
    kGuess = 0.125; // will be overridden
    
    /* selectTestDF(2);
    console.info("threshEstimate: ", threshEstimate(testDF, 10000));
    calculateCI(testDF, 0.125, 10000); */
}


/**
 df is for data frame, inspired by R, here an array of 2-tupels {correct, lMar}
 It represents the full run info of presented acuity (float lMAR) and response (BOOL correct)
 That dataframe is composed in TrialHistoryController
 */
+ (id) calculateCIfromDF: (id) df guessingProbability: (float) guessingProbability nSamples: (int) nSamples {
    kGuess = guessingProbability; // as global parameter to speed up
    nSamples = nSamples || 1000; // default value
    const threshSamples = [nSamples]; // this array will hold all bootstrap results
    for (let i = 0; i < nSamples; i++) threshSamples[i] = threshEstimate(sampleWithReplacement(df, df.length));
    //console.info(threshSamples);
    //console.info("extent: ", extent(threshSamples));
    const med = median(threshSamples), CI0025 = quantile(threshSamples, 0.025), CI0975 = quantile(threshSamples, 0.975);
    //console.info("med: ", med, ", CI0025: ", CI0025, ", CI0975", CI0975, ", Bland-Altman-equiv: ±", (CI0025 - CI0975) / 2);
    /*let s = ""; // outputting all estimates on the clipboard for further workup in R
    for (i =0; i<threshSamples.length; i++) s += threshSamples[i]+ "\n";
    [Misc copyString2ClipboardWithDialog: s];*/
    return [{median: med, CI0025: CI0025, CI0975: CI0975}];
}


/**
 A naive maximumfinder. Gradient climbers can fail because of very low likelihood values
 */
function findMaxLlhInRange(df, r1, r2, delta) {
    let lMax = -1, lMarMax, lMar = r1;
    while (lMar < r2) {
        const ll = likelihoodFunc(lMar, df); //console.info(lMar, ll);
        if (ll > lMax) {lMax = ll;  lMarMax = lMar;}
        lMar += delta;
    }
    return lMarMax;
}
/**
 The fit to the psychometric function is done in stages, because the fit's slope can be VERY shallow
 */
function threshEstimate(df) { // console.info("threshEstimate");
    let delta = 0.5; // initial LogMAR precision for rough homing-in
    let lMarMax = findMaxLlhInRange(df, kBestLogMAR, kWorstLogMAR, delta);
    lMarMax = findMaxLlhInRange(df, lMarMax - delta, lMarMax + delta, delta / 5); // now precise to ±0.1 LogMAR
    delta /= 10;
    lMarMax = findMaxLlhInRange(df, lMarMax - delta, lMarMax + delta, delta / 5); // now precise to ±0.02 LogMAR
    delta /= 10;
    lMarMax = findMaxLlhInRange(df, lMarMax - delta, lMarMax + delta, delta / 5); // now precise to ±0.004 LogMAR. Overkill??
    return lMarMax;
}


/**
 Conversion functions
 The term "pest" refers to a 0…1 scale of the Thresholder. Carried over from old FrACT.
 */
function pest2logMAR(pestVal) {
    return kWorstLogMAR - pestVal * (kWorstLogMAR - kBestLogMAR);
}
function logMAR2pest(lmar) {
    return (kWorstLogMAR - lmar) / (kWorstLogMAR - kBestLogMAR);
}


/**
 likelihood stuff
 */
function likelihoodFunc(thresh, df) {//console.info("MDBDispersionEstimation>likelihoodFunc");
    const len = df.length
    //let llh = probCorrectGivenLogMAR(kGuess, thresh, kWorstLogMAR); // nearly 1. Fix right end.
    //llh = llh * (1 - probCorrectGivenLogMAR(kGuess, thresh, kBestLogMAR)); // guess prob. Fix left end.
    let llh = 1;
    for (let i = 0; i < len; i++) {
        const l = probCorrectGivenLogMAR(kGuess, thresh, df[i].lMar);
        if (df[i].correct) {llh *= l} else {llh *= (1 - l);}
    }
    return llh;
}


/**
 Logistic function for nAFC tasks, lMar on the kWorstLogMAR…kBestLogMAR scale
 lMar=kWorstLogMAR: ≈1.0, lMar=kBestLogMAR: guessingProb
 */
function probCorrectGivenLogMAR(guessingProbability, inflectionPoint, lMar) {
    lMar = logMAR2pest(lMar);  inflectionPoint = logMAR2pest(inflectionPoint);
    return logisticFun(guessingProbability, inflectionPoint, lMar);
}


/**
Logistic function for nAFC tasks, x on a linear 0…1 scale
x=0: below threshold, =guess; x=1: above threshold, =1
 */
function testLogistic(guessingProbability) {
    for (let i = 0; i < 10; i++)  console.info(i / 10, logisticFun(0.125, 0.5, i / 10));
}
function logisticFun(guessingProbability, inflectionPoint, x) {
    //console.log("guessingProbability: ", guessingProbability, ", inflectionPoint: ", inflectionPoint);
    x = 1 - x;  inflectionPoint = 1 - inflectionPoint;
    // 2023-02-07 previously, slope was defined inversely. No change in result, now more readable
    return guessingProbability + (1 - guessingProbability) / (1 + Math.exp(-gSlopeCI95 * (x - inflectionPoint)));
}


/**
 For testing, not used in production
 */
function selectTestDF(selector) {
    selector = selector || 0;
    switch (selector) {
        default:
            testDF = [{lMar: 1.00, correct: true}, // trial run on 2021-04-22
                      {lMar: 0.699, correct: false}, // inadvertant error, good for testing
                      {lMar: 0.886, correct: true},
                      {lMar: 0.725, correct: true},
                      {lMar: 0.595, correct: true},
                      {lMar: 0.481, correct: true},
                      {lMar: 0.376, correct: true},
                      {lMar: 0.278, correct: true},
                      {lMar: 0.187, correct: true},
                      {lMar: 0.101, correct: true},
                      {lMar: 0.020, correct: false},
                      {lMar: 0.581, correct: true},
                      {lMar: 0.086, correct: true},
                      {lMar: 0.029, correct: false},
                      {lMar: 0.090, correct: true},
                      {lMar: 0.044, correct: true},
                      {lMar: 0.001, correct: true},
                      {lMar: 0.439, correct: true}];
            break;
        case 1:
            testDF = [{lMar: 1.00, correct: true}, // run 1 (mb)
                      {lMar: 0.699, correct: true},
                      {lMar: 0.398, correct: true},
                      {lMar: 0.097, correct: true},
                      {lMar: -0.433, correct: false},
                      {lMar: -0.179, correct: true},
                      {lMar: -0.328, correct: false},
                      {lMar: -0.188, correct: false},
                      {lMar: -0.072, correct: false},
                      {lMar: 0.026, correct: true},
                      {lMar: -0.045, correct: false},
                      {lMar: 0.513, correct: true},
                      {lMar: 0.016, correct: true},
                      {lMar: -0.033, correct: false},
                      {lMar: 0.026, correct: false},
                      {lMar: 0.081, correct: true},
                      {lMar: 0.041, correct: true},
                      {lMar: 0.479, correct: true}];
            break;
        case 2:
            testDF = [{lMar: 1.00, correct: true}, // "63-He-OS-1"
                      {lMar: 0.699, correct: false},
                      {lMar: 0.86, correct: true},
                      {lMar: 0.697, correct: true},
                      {lMar: 0.562, correct: false},
                      {lMar: 0.693, correct: false},
                      {lMar: 0.796, correct: true},
                      {lMar: 0.726, correct: true},
                      {lMar: 0.662, correct: true},
                      {lMar: 0.607, correct: false},
                      {lMar: 0.668, correct: true},
                      {lMar: 1.099, correct: true},
                      {lMar: 0.613, correct: false},
                      {lMar: 0.662, correct: false},
                      {lMar: 0.708, correct: true},
                      {lMar: 0.672, correct: true},
                      {lMar: 0.642, correct: false},
                      {lMar: 1.159, correct: true}];
            break;
    }
}
@end
