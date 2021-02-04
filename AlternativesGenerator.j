/*
 *  AlternativesGenerator.j
 *  FrACT10.02
 *
 *  Created by Bach on 23.07.2017.
 *  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
 */

@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>


/*
 Produces "alternatives" (e.g. Landolt-C directions) from 0 to (nAlternatives-1)
*/


@implementation AlternativesGenerator: CPObject {
    int _currentTrial;
    int currentAlternative @accessors;
    id alternatives2present;
    int i;
}


function randomiseArray(array) {
    for (i = array.length - 1; i > 0; i--) {
        var j = Math.floor(Math.random() * (i + 1));
        var temp = array[i];
        array[i] = array[j];
        array[j] = temp;
    }
    return(array);
}


- (id) initWithNumAlternatives: (int) nAlternatives andNTrials: (int) nTrials { //console.info("AlternativesGenerator>initWithNumAlternatives");
    self = [super init];
    if (self) {
        for (i = 0; i < (([CPDate date].getSeconds()) % 10); ++i) Math.random(); // truly random
        
        //console.info("AlternativesGenerator>initWithNumAlternatives, nAlt:", nAlternatives, ", nT:", nTrials);
        if (nAlternatives < 2) console.info("AlternativesGenerator>initWithNumAlternatives TOO SMALL ", nAlternatives);
        if (nAlternatives > 10) {
            //console.info("AlternativesGenerator>initWithNumAlternatives TOO LARGE ", nAlternatives);
            nAlternatives = 10;
        }
        var possibleAlternatives = [nAlternatives];
        for (i = 0; i < nAlternatives; ++i) possibleAlternatives[i] = i;
        //console.info(nAlternatives);
        switch(nAlternatives) {
            case 2:
                for (i = 0; i < nAlternatives; ++i) possibleAlternatives[i] *= 4;  break;
            case 4: // skip oblique == odd
                for (i = 0; i < nAlternatives; ++i) possibleAlternatives[i] *= 2;  break;
            case 8:  //console.info("8 alternatives, special rare-oblique choice");
                possibleAlternatives = [0, 2, 4, 6, 1, 3, 5, 7]; // oblique never more often then straight
                break;
            case 10: break; // letters, no action needed
            default: console.log("nAlternatives=", nAlternatives, " should never occur!"); // needs to be logged
        }
//        if (nAlternatives == 2) { // to discern between v and h
//            if (currentTestName != "Acuity_Vernier") { // don't do this for Vernier
//                if (Prefs.dir2.n == 2) {
//                    for (i = 0; i < nAlternatives; ++i) possiblenAlternatives[i] += 2;
//                }
//            }
//        }
        alternatives2present = [nTrials];
        for (i=0; i < nTrials; ++i) {
            alternatives2present[i] = possibleAlternatives[i % (nAlternatives)];
        }
        alternatives2present = randomiseArray(alternatives2present);
        _currentTrial = 0;
    }
    return self;
}


- (int) nextAlternative { //console.info("AlternativesGenerator>nextAlternative");
    [self setCurrentAlternative: alternatives2present[_currentTrial]];
    //console.info(_currentTrial, " ", currentAlternative);
    _currentTrial++;
    return currentAlternative;
}


@end
