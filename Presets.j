/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, michael.bach@uni-freiburg.de, <https://michaelbach.de>

Presets.j

*/

@import "Presets.j"


/**
 Allow presets of settings
 2022-05-20  begun
 */
@implementation Presets {
    SEL gSelector;
}



+ (CPString) capitalizeFirstLetter: (CPString) s {
    if (s.length < 1)  return @"";
    else if (s.length == 1)  return [s capitalizedString];
    var firstChar = [[s substringToIndex: 1] uppercaseString];
    var otherChars = [s substringWithRange: CPMakeRange(1, s.length - 1)];
    return firstChar + otherChars;
}


// this is only the beginning, testing the `performSelector` approach. It works!
+ (void) applyPreset { //console.info("Presets>applyPreset");
    var s = "distanceInCM";
    s = [Presets capitalizeFirstLetter: s];
    s = "set" + s + ":"; //console.info(s);
    gSelector = CPSelectorFromString(s);
    [Settings performSelector: gSelector withObject: [CPNumber numberWithInt: 99]];
}


@end
