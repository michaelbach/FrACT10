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
    int _nAlternatives;
    int _lastAlternative;
    int currentAlternative @accessors;
}

- (id) initWithNumAlternatives: nAlternatives {//console.log("AlternativesGenerator>initWithNumAlternatives");
    self = [super init];
    if (self) {
        if (nAlternatives < 2) console.log("AlternativesGenerator>initWithNumAlternatives TOO SMALL ", nAlternatives);
        _nAlternatives = nAlternatives;
        _lastAlternative = -1;
        // TODO: randomise
        [self nextAlternative];
    }
    return self;
}


// _nAlternatives==8: 0–7
// _nAlternatives==4: 0, 2, 4, 6
// _nAlternatives==2: 0, 4.
- (int) nextAlternative {//console.log("AlternativesGenerator>nextAlternative");
    _lastAlternative = currentAlternative;
    [self setCurrentAlternative: Math.round(Math.random() * (_nAlternatives - 1))];
    if (_nAlternatives == 4) [self setCurrentAlternative: currentAlternative * 2];
    if (_nAlternatives == 2) [self setCurrentAlternative: currentAlternative * 4];
    if (_nAlternatives > 2) {
        //TODO: avoid last (most of the time)
    }
    return currentAlternative;
}


@end
