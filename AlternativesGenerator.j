/*
This file is part of FrACT10, a vision test battery.
© 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

AlternativesGenerator.j

Created by Bach on 23.07.2017.

Generates "alternatives" (e.g. Landolt ring directions) from 0 to (nAlternatives-1)

*/

/**
 * AlternativesGenerator
 *
 * Generates "alternatives" (e.g. Landolt ring directions) from 0 to (nAlternatives-1)
 *
 * */


@import <Foundation/CPObject.j>


@implementation AlternativesGenerator: CPObject {
    int _currentTrial;
    int currentAlternative @accessors;
    id alternatives2present;
    int i;
    BOOL _obliqueOnly; //only gratings for now
}


/**
 * randomiseArray (local function)
 *
 * Randomises the sequence of the input array in an unbiased way
 *  https://blog.codinghorror.com/the-danger-of-naivete/
 *
 * Method: exchange every item with a random other one.
 * If you want to pre-randomize, simply do this before calling here.
 */
function randomiseArray(array) {
    for (let i = array.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [array[j], array[i]] = [array[i], array[j]]; //ES6 allows to assign 2 variables at once: flip
    }
    return(array);
}

/**
 Initialiser

 @param nAlternatives: (int) 2, 4, 8, 10
 @param nTrials: (int) number of trials
 @return class instance

 */
- (id) initWithNumAlternatives: (int) nAlternatives andNTrials: (int) nTrials obliqueOnly: (BOOL) obliqueOnly { //console.info("AlternativesGenerator>initWithNumAlternatives");
    self = [super init];
    if (self) {
        for (i = 0; i < (([CPDate date].getSeconds()) % 10); ++i) Math.random(); //truly random

        //console.info("AlternativesGenerator>initWithNumAlternatives, nAlt:", nAlternatives, ", nT:", nTrials);
        if (nAlternatives < 2) {
            console.log("AlternativesGenerator>initWithNumAlternatives TOO SMALL: ", nAlternatives);
            nAlternatives = 2;
        }
        if (nAlternatives > 10) {
            console.log("AlternativesGenerator>initWithNumAlternatives TOO LARGE: ", nAlternatives);
            nAlternatives = 10;
        }
        let possibleAlternatives = [nAlternatives];
        for (i = 0; i < nAlternatives; ++i) possibleAlternatives[i] = i;
        //console.info(nAlternatives);
        switch(nAlternatives) {
            case 2:
                for (i = 0; i < nAlternatives; ++i) possibleAlternatives[i] *= 4;  break;
            case 4: //skip oblique === odd
                for (i = 0; i < nAlternatives; ++i) possibleAlternatives[i] *= 2;  break;
            case 8:  //console.info("8 alternatives, special rare-oblique choice");
                possibleAlternatives = [0, 2, 4, 6, 1, 3, 5, 7]; //oblique never more often then straight
                break;
            case 10: break; //letters, no action needed
            default: console.log("nAlternatives=", nAlternatives, " should never occur!"); //needs to be logged
        }
/*        if (nAlternatives === 2) { //to discern between v and h
            if (current_TestName !== "Acuity_Vernier") { //don't do this for Vernier
                if (Prefs.dir2.n === 2) {
                    for (i = 0; i < nAlternatives; ++i) possiblenAlternatives[i] += 2;
                }
            }
        } */
        possibleAlternatives = randomiseArray(possibleAlternatives); //in case nTrials<nAlternatives

        alternatives2present = [nTrials];
        for (i=0; i < nTrials; ++i) {
            alternatives2present[i] = possibleAlternatives[i % (nAlternatives)];
        }
        alternatives2present = randomiseArray(alternatives2present);
        _currentTrial = 0;
        _obliqueOnly = obliqueOnly;
    }
    return self;
}


/**
 Retrieve next alternative to present as optotype

 @return (int) number within the range given when instantiating
 */
- (int) nextAlternative { //console.info("AlternativesGenerator>nextAlternative");
    const _trial = _currentTrial % alternatives2present.length; //to catch 5 Es with crowding
    [self setCurrentAlternative: alternatives2present[_trial]];
    if (_obliqueOnly)
        [self setCurrentAlternative: currentAlternative + 2];
    _currentTrial++;
    return currentAlternative;
}


/**
 Perform logic unit tests for AlternativesGenerator.
 @return YES if all tests pass
 */
+ (BOOL) unittest {
    let success = YES, report = crlf + "AlternativesGenerator▸unittest:" + crlf;

    // Test 1: Basic 4-alternative generation (cardinal directions)
    const gen4 = [[AlternativesGenerator alloc] initWithNumAlternatives: 4 andNTrials: 20 obliqueOnly: NO];
    const results4 = [];
    for (let i = 0; i < 20; i++) results4.push([gen4 nextAlternative]);
    // Expecting 0, 2, 4, 6 (cardinal)
    if (results4.some(v => ![0, 2, 4, 6].includes(v))) {
        report += "  ERROR: 4-alternative generator produced non-cardinal values: " + results4 + crlf; success = NO;
    }

    // Test 2: 2-alternative generation
    const gen2 = [[AlternativesGenerator alloc] initWithNumAlternatives: 2 andNTrials: 10 obliqueOnly: NO];
    const results2 = [];
    for (let i = 0; i < 10; i++) results2.push([gen2 nextAlternative]);
    // Expecting 0, 4
    if (results2.some(v => ![0, 4].includes(v))) {
        report += "  ERROR: 2-alternative generator produced unexpected values: " + results2 + crlf; success = NO;
    }

    // Test 3: ObliqueOnly logic (for 4 alternatives)
    // If nAlternatives=4, nextAlternative adds 2. 
    // cardinal 0,2,4,6 -> 2,4,6,8. 8 is effectively 0 in many contexts but let's see what happens.
    const gen4O = [[AlternativesGenerator alloc] initWithNumAlternatives: 4 andNTrials: 10 obliqueOnly: YES];
    const results4O = [];
    for (let i = 0; i < 10; i++) results4O.push([gen4O nextAlternative]);
    if (results4O.some(v => ![2, 4, 6, 8].includes(v))) {
         report += "  ERROR: 4-alternative oblique generator produced unexpected values: " + results4O + crlf; success = NO;
    }

    // Test 4: 10 alternatives (Letters)
    const gen10 = [[AlternativesGenerator alloc] initWithNumAlternatives: 10 andNTrials: 30 obliqueOnly: NO];
    const results10 = [];
    for (let i = 0; i < 30; i++) results10.push([gen10 nextAlternative]);
    if (results10.some(v => v < 0 || v > 9)) {
         report += "  ERROR: 10-alternative generator out of range: " + results10 + crlf; success = NO;
    }

    if (success) {
        report += "  Sequence generation and range tests passed." + crlf;
    }
    console.info(report);
    return success;
}


@end
