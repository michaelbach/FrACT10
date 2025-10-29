/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

MDBDispersionEstimation.j

*/

@import "MDBSimplestatistics.j"


/**
 Calculate the CI95
 2021-04-22  begun
 */
@implementation MDBDispersionEstimation


let kWorstLogMAR, kBestLogMAR, kGuess, testDF; //there are no class properties in Cappuccino, so use JavaScript


+ (void) initResultStatistics { //console.info("Entering initResultStatistics");
    kWorstLogMAR = [MiscSpace logMARfromDecVA: [MiscSpace decVAFromStrokePixels: gStrokeMaximal]];
    kBestLogMAR =  [MiscSpace logMARfromDecVA: [MiscSpace decVAFromStrokePixels: gStrokeMinimal]];
    //console.info("kWorstLogMAR: ", kWorstLogMAR, ", kBestLogMAR: ", kBestLogMAR);
    kGuess = 0.125; //will be overridden

    if (gTestingCI95) {
        selectTestDF(2);
        //console.info(sampleWithReplacement(testDF, testDF.length))
        console.info("unsampled threshEstimate: ", threshEstimate(testDF));
        console.info([self calculateCI95halfFromDF: testDF guessingProbability: 0.125 nSamples:  10000]);
    }
}

/* nesting of calls:
 calculateCIfromDF
    threshEstimate
        findMaxLlhInRange
            likelihoodFunc
                probCorrectGivenLogMAR
                    logMAR2pest
                    logisticFun
 */
/**
 df is for data frame, inspired by R, here an array of 2-tupels {correct, lMar}
 It represents the full run info of presented acuity (float lMAR) and response (BOOL correct)
 That dataframe is composed in TrialHistoryController
 */
+ (id) calculateCIfromDF: (id) df guessingProbability: (float) guessingProbability nSamples: (int) nSamples {
    kGuess = guessingProbability; //as global parameter to speed up
    nSamples = nSamples || 1000; //default value
    const threshSamples = new Array(nSamples); //array to hold bootstrap results
    for (let i = 0; i < nSamples; i++) threshSamples[i] = threshEstimate(sampleWithReplacement(df, df.length));
    const quantiles = quantile(threshSamples, [0.025, 0.5, 0.975]);
    const [CI0025, med, CI0975] = quantiles;
    //console.info("med: ", med, ", CI0025: ", CI0025, ", CI0975", CI0975, ", Bland-Altman-equiv: ±", (CI0025 - CI0975) / 2);
    /*let s = ""; //outputting all estimates on the clipboard for further workup in R
    for (i =0; i<threshSamples.length; i++) s += threshSamples[i]+ "\n";
    [Misc copyString2ClipboardWithDialog: s];*/
    return {median: med, CI0025: CI0025, CI0975: CI0975};
}


+ (id) calculateCI95halfFromDF: (id) df guessingProbability: (float) guessingProbability nSamples: (int) nSamples {
    const ciResults = [self calculateCIfromDF: df guessingProbability: guessingProbability nSamples: nSamples];
    return (ciResults.CI0975 - ciResults.CI0025) / 2;
}


/**
 A naive maximumfinder. Gradient climbers can fail because of very low likelihood values
 */
function findMaxLlhInRange(df, r1, r2, delta) {
    if (r1 < kBestLogMAR) r1 = kBestLogMAR;
    if (r2 > kWorstLogMAR) r1 = kWorstLogMAR;
    let lMax = Number.NEGATIVE_INFINITY, lMarMax, lMar = r1;
    while (lMar <= r2) {
        const ll = likelihoodFunc(lMar, df); //console.info(lMar, ll);
        if (ll > lMax) {
            lMax = ll;  lMarMax = lMar;
        }
        lMar += delta;
    }
    //console.info(delta, lMarMax, lMax)
    return lMarMax;
}
/**
 The fit to the psychometric function is done in stages, because the fit's slope can be VERY shallow
 */
function threshEstimate(df) { //console.info("threshEstimate");
    let delta = 0.1; //initial LogMAR precision for rough homing-in
    let lMarMax = findMaxLlhInRange(df, kBestLogMAR, kWorstLogMAR, delta);
    delta /= 10;
    lMarMax = findMaxLlhInRange(df, lMarMax - delta, lMarMax + delta, delta); //now precise to ±0.1 LogMAR
    delta /= 10;
    lMarMax = findMaxLlhInRange(df, lMarMax - delta, lMarMax + delta, delta); //now precise to ±0.001 LogMAR
    delta /= 10;
    lMarMax = findMaxLlhInRange(df, lMarMax - delta, lMarMax + delta, delta); //now precise to ±0.0001 LogMAR. Overkill??
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
function likelihoodFunc(thresh, df) { //console.info("MDBDispersionEstimation>likelihoodFunc");
    const len = df.length
    //let llh = probCorrectGivenLogMAR(kGuess, thresh, kWorstLogMAR); //nearly 1. Fix right end.
    //llh = llh * (1 - probCorrectGivenLogMAR(kGuess, thresh, kBestLogMAR)); //guess prob. Fix left end.
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
+ (BOOL) unittestLogisticFun {
    console.log("\nMDBDispersionEstimation>unittestLogisticFun")
    for (let v of [0, 0.5, 1]) {
        const f = parseFloat(logisticFun(0.125, 0.5, v).toFixed(3));
        console.log(v, f);
    }
    return YES;
}
function logisticFun(guessingProbability, inflectionPoint, x) {
    //console.log("guessingProbability: ", guessingProbability, ", inflectionPoint: ", inflectionPoint);
    x = 1 - x;  inflectionPoint = 1 - inflectionPoint;
    //2023-02-07 previously, slope was defined inversely. No change in result, now more readable
    return guessingProbability + (1 - guessingProbability) / (1 + Math.exp(-gSlopeCI95 * (x - inflectionPoint)));
}


/**
 For testing, not used in production
 */
function selectTestDF(selector) {
    selector = selector || 0;
    switch (selector) {
        default:
            testDF = [{lMar: 1.00, correct: YES}, //trial run on 2021-04-22
                      {lMar: 0.699, correct: NO}, //lapse error, good for testing
                      {lMar: 0.886, correct: YES},
                      {lMar: 0.725, correct: YES},
                      {lMar: 0.595, correct: YES},
                      {lMar: 0.481, correct: YES},
                      {lMar: 0.376, correct: YES},
                      {lMar: 0.278, correct: YES},
                      {lMar: 0.187, correct: YES},
                      {lMar: 0.101, correct: YES},
                      {lMar: 0.020, correct: NO},
                      {lMar: 0.581, correct: YES},
                      {lMar: 0.086, correct: YES},
                      {lMar: 0.029, correct: NO},
                      {lMar: 0.090, correct: YES},
                      {lMar: 0.044, correct: YES},
                      {lMar: 0.001, correct: YES},
                      {lMar: 0.439, correct: YES}];
            break;
        case 1:
            testDF = [{lMar: 1.00, correct: YES}, //run 1 (mb)
                      {lMar: 0.699, correct: YES},
                      {lMar: 0.398, correct: YES},
                      {lMar: 0.097, correct: YES},
                      {lMar: -0.433, correct: NO},
                      {lMar: -0.179, correct: YES},
                      {lMar: -0.328, correct: NO},
                      {lMar: -0.188, correct: NO},
                      {lMar: -0.072, correct: NO},
                      {lMar: 0.026, correct: YES},
                      {lMar: -0.045, correct: NO},
                      {lMar: 0.513, correct: YES},
                      {lMar: 0.016, correct: YES},
                      {lMar: -0.033, correct: NO},
                      {lMar: 0.026, correct: NO},
                      {lMar: 0.081, correct: YES},
                      {lMar: 0.041, correct: YES},
                      {lMar: 0.479, correct: YES}];
            break;
        case 2:
                testDF = [{lMar: 1.00, correct: YES}, //"63-He-OS-1"
                          {lMar: 0.699, correct: NO},
                          {lMar: 0.86, correct: YES},
                          {lMar: 0.697, correct: YES},
                          {lMar: 0.562, correct: NO},
                          {lMar: 0.693, correct: NO},
                          {lMar: 0.796, correct: YES},
                          {lMar: 0.726, correct: YES},
                          {lMar: 0.662, correct: YES},
                          {lMar: 0.607, correct: NO},
                          {lMar: 0.668, correct: YES},
                          {lMar: 1.099, correct: YES},
                          {lMar: 0.613, correct: NO},
                          {lMar: 0.662, correct: NO},
                          {lMar: 0.708, correct: YES},
                          {lMar: 0.672, correct: YES},
                          {lMar: 0.642, correct: NO},
                          {lMar: 1.159, correct: YES}];
            break;
    }
}
@end
