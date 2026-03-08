/*
 CPTextField_Category.j

 This file is part of FrACT10, a vision test battery.
 © 2026 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>
 Created by Bach on 2026-03-08.

*/


/**
A category to ensure the correct CPFont (family and size) is used, regardless of theme state
This fixes this Cappuccino issue: https://github.com/cappuccino/cappuccino/issues/3195
 */

@import <AppKit/CPTextField.j>

@implementation CPTextField (CPTextField_Category)

/*!
    Sets the font of the receiver, making sure it also works in bezeled etc. state.
    @param aFont - A CPFont object.
*/


- (void) setFont: (CPFont) aFont {
    if ([self currentValueForThemeAttribute: "font"] === aFont) return;

    if ([self hasThemeState: CPThemeStateControlSizeRegular])
        [self setFont :aFont inThemeStates: [CPThemeStateControlSizeRegular]];

    if ([self hasThemeState: CPThemeStateBezeled])
        [self setFont: aFont inThemeStates: [CPThemeStateBezeled]];

    if ([self hasThemeState: CPThemeStateBordered])
        [self setFont: aFont inThemeStates: [CPThemeStateBordered]];

    [self layoutSubviews];
}

//helper
- (void) setFont: (CPFont) aFont inThemeStates: (CPArray) themeStates {
    [self setValue: aFont forThemeAttribute: "font" inStates: themeStates];
}


//ThemeStates: [CPThemeStateNormal, CPThemeStateDisabled, CPThemeStateHovered, CPThemeStateHighlighted,  CPThemeStateSelected, CPThemeStateTableDataView, CPThemeStateSelectedDataView, CPThemeStateGroupRow, CPThemeStateBezeled, CPThemeStateBordered, CPThemeStateEditable, CPThemeStateEditing, CPThemeStateVertical, CPThemeStateDefault, CPThemeStateCircular, CPThemeStateAutocompleting, CPThemeStateFirstResponder, CPThemeStateMainWindow, CPThemeStateKeyWindow, CPThemeStateControlSizeRegular, CPThemeStateControlSizeSmall, CPThemeStateControlSizeMini, CPThemeStateAlternateState, CPThemeStateComposedControl]];


@end
