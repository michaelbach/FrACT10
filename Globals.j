/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

Globals.j
*/

/**
 Global constants & variables
 Since we do not have constants in Objective-J, we create global variables
 (and # define does not work for me)
 Created on 2021-01-07
 */


//// global Constants
const bundleDict = [[CPBundle bundleWithIdentifier: "de.michaelbach.FrACT10"] infoDictionary];
gVersionDateOfFrACT = [bundleDict objectForKey:@"VersionDate"];
gVersionStringOfFract = [bundleDict objectForKey:@"VersionNumberString"];//CPBundleVersion mangled by jake
gVersionOfExportFormat = "5";

gFilename4ResultStorage = "FRACT10-FINAL-RESULT-STRING";
gFilename4ResultsHistoryStorage = "FRACT10-RESULTS-HISTORY-STRING";

// Correction for threshold underestimation by DIN-ascending method (in VAdecimal)
gThresholdCorrection4Ascending = 0.891;

// slope parameter for the CI95 dispersion estimation; strongly affects CI95
gSlopeCI95 = 15; // this value approximates test-retest variability

// Clamping the max logCSWeber value to avoid log of zero during conversions. Value way beyond physiologically possible.
gMaxAllowedLogCSWeber = 4.0;
gMaxResultLogCSWeber = 2.0;

gCalBarLengthInPixel = 700;

gMeter2FeetMultiplier = 3.28084;  tab = "\t";  crlf = "\n";


//// global Variables
gDefaultDistanceInCM = 399;
gDefaultCalibrationBarLengthInMM = 149;

// cgc as global makes for easy access in Optotypes and contrast calcs
cgc = [[CPGraphicsContext currentContext] graphicsPort];

gColorFore = [CPColor whiteColor];  gColorBack = [CPColor blackColor];
gSpecialBcmDone = NO;
// minimal stroke size (half a pixel). Maximal, depending on screen & margin. Poor naming for Vernier.
gStrokeMinimal = 0.5;  gStrokeMaximal = 100; //Values are later overridden via Setting and screen size

gSoundsTrialYes = ["tink.mp3", "miniPop.mp3"];
gSoundsTrialNo = ["whistle.mp3", "error2.mp3"];
gSoundsRunEnd = ["gong.mp3", "cuteLevelUp.mp3"];


/*
 #  History

2024-09-16 add an "ISI" `timeoutIsiMillisecs`; remove superfluous Cappuccino files
2024-09-13 Presets: two more "factored out" into separate files
2024-09-11a Presets: begin moving presets to categories. Does not work, use singletons
2024-09-11 add Preset "ULV@Gensight"; symbolic constants for NAlternativesIndexType and AuditoryFeedback4trialType; ensure best/worst VAs update after plastic card procedure
2024-09-04 rename creditCard → plasticCard throughout
2024-08-30 redesign "Line(s) of optotype mode": no more "chart mode", replaced by n of lines
2024-08-25 simplify actions for Help and About panels by using tag values and URL string collection
+ 2024-08-24 fix regression (line-by-line was disabled in IB), harmonise button shapes & names, recognize "isEnabled" in MDBButton
+ 2024-08-15a add Preset "AT@LeviLab", modify randomization of `eccentXInDeg`, add to export string, button images square
+ 2024-08-14 add randomization of `eccentXInDeg` on request
+ 2024-08-02 reading `Info.plist` in service worker proved not useful: doesn't notice the update. Instead: `updateServiceWorkerDateFromInfoPlist.js` copies versionDate from plist whenever necessary
+ 2024-07-14 refactor `ControlDispatcher`, add "isInRun"
+ 2024-07-09 correct gap calculation for crowding (& simplify)
+ 2024-07-06 rename "test" → "unittest" where applicable (avoid name clash), for testing with Cypress: allow local htmlMessage source; add (nearly) all settings
+ 2024-06-30 refactor `RewardsController`: easier expansion, test mode, more & better images
+ 2024-06-17 add getSettings to HTMLMessaging, refactor `ControlDispatcher`
+ 2024-06-15 rename Settings → setSetting, Presets → Preset, add setSettings>autoRunIndex
+ 2024-06-14 add "worst possible acuity" fields with associated code in Settings
+ 2024-06-12 add "nTrials08" to HTMLMessages, written for general case; rearrange "best poss. acuity" fields
+ 2024-06-11 fix regrssion (initialise `_sendHTMLMessageOnRunDone`), add HTMLMessage "Settings>nTrials08"
+ 2024-06-10 add `Version` to HTMLMessages. This state of HTMLMessages deserves minor version increase.
+ 2024-06-09 add HTMLMessage when Run done
+ 2024-06-04 add feedback (success/nonsuccess) return messages to HTMLMessages for Presets
+ 2024-06-02 begin message communications with FrACT10 when embedded as iframe
+ 2024-05-20 make `decimalMarkChar` responsive & more visible in GUI
+ 2024-05-18 make feedback sounds selectable
+ 2024-05-17 add an alternate "trialNo" sound, selected by @TUdo based on suggestion by Anna B.
+ 2024-05-14 add new Preset
+ 2024-05-14 simplify, rename, refactor Settings for readability, no change in function
+ 2024-05-13 add `hideExitButton` on request
+ 2024-05-10 improve about / help text, tooltips
+ 2024-05-09 complete rewrite of Presets for easier extension
+ 2024-04-30 Contrast values verified with luminance meter. Code no change, just a "freeze"
+ 2024-04-22 rename "gap" → "stroke", Vernier TBD
+ 2024-04-21 clibpoard button invisible/visible → disabled/enabled; improve wording in clipboard dialog;
        improve a tool tip, completely hide "auto fullscreen" – doesn't work well anyway;
        slight GUI shifts in the main window; complete address
+ 2024-04-12 changes in the Maculight preset
+ 2024-04-01 calBarLengthInPixel did not belong in Settings → gCalBarLengthInPixel. Release.
+ 2024-03-31 added number formatter with 1 fractional digit to 2 fields – but only apparent when/after editing???
+ 2024-03-31 Dithering default on. Max logCSWeber for result: gMaxResultLogCSWeber = 2.0 (does not makes sense to display better). Default contrastMaxLogCSWeber 3.0 (now after early error there's a chance to return to sensible value, was 2.4)
+ 2024-03-29 add DitherTest (type zero to run it), fix non-monotony in the gray→ditherpattern transform
+ 2024-03-28 add Dithering
+ 2024-03-15 add close/exit button top right. The webapp doesn't close on iOS though – javascript cannot close windows it didn't open.
+ 2024-03-02 trivial GUI changes
+ 2024-02-16 simplify color/contrast/graphicsport management by going global with gColorFore, gColorBack & cgc
+ 2024-02-15 read version number from info.plist (avoiding CPBundleVersion, which is mangled)
+ 2024-02-14 freeze w/o code changes
+ 2024-02-13a add "lineByLineChartModeConstantVA"
+ 2024-02-13 rearrange presets
+ 2024-02-11 refactor TAO, crowding with TAO
+ 2024-02-10 crowding with curront optotype, not always C (TAO tbd)
+ 2024-02-06 fix regression (oblique only) in specialBcm
    introduce preset "Demo", autoRunIndex symbolic constants
+ 2024-02-03 correct a tooltip, comments a little more systematic
+ 2024-02-02 slight change in logic of specialBcm-done situation
+ 2024-01-31 add info on cookies
+ 2024-01-31 publishing this version now after positiv feedback.
+ 2024-01-30a more "specialBcm" based on first feedback
+ 2024-01-30 move "cappFrameworks" into "Resources", change index.html accordingly. Disentangles OT and FrACT10 framework.
+ 2024-01-30 add  1.5 and 12 cpd on request of Nic Reus
+ 2024-01-30 begin implementation of "specialBcm"
+ 2024-01-28 add preset text name in GUI, fix button relation to started test (via tag)
+ 2024-01-28 results2clipboard with constants rather than numbers
+ 2024-01-28 all back to this morning, with consistent numbering
+ 2024-01-28 test numbering consistent: 0 also in the constant list (hierarchyC.), several changes ensued
+ 2024-01-24 add preset "CNSatFreiburg"
+ 2024-01-20 first go at color bit stealing
+ 2024-01-18 slight rewording in GUI
+ 2024-01-16 fix more incompletely visible tooltips
+ 2023-11-30 FireFox→Firefox. Tried to make more tooltips visible, not fully successful.
+ 2023-11-11 fix tooltips for main buttons: parts missing, added empty line (Cappucino bug?)
+ 2023-10-18 prettify code for sinusoidal grating (for presentation)
+ 2023-10-15 replace ≘ with ≙
+ 2023-10-01 add exit via "-" (for number keyboards). Also "_make-XcodeCapp.sh" more "elegant" :)
+ 2023-09-17 optimize: all images with "ImageOptim"
+ 2023-09-15 Simplify: "Set all to defaults" button deleted, the entry in Presets does it already;
    also deleted pertinent action procedure; simplify text, clean up GUI (overlayed text in contrast)
+ 2023-09-10 gratings: option for sinusoidal / square wave
+ 2023-09-08 alway set Preset index → 0 (avoids possibly confusing Popup title)
+ 2023-09-05 1st entry in Presets is neutral
+ 2023-09-03 ensure sound>AudioContext is only set up after user interaction
+ 2023-09-03 no succes in automically pasting value of `gVersionDateOfFrACT` into the service worker so far.
    Cleared up sequence when service worker is called (before ("AppController>init")
    Prettify syntax in the service worker.
+ 2023-09-01 simplify: use values from Info.plist, some globals replace Setting stuff,
    update LICENSE.md, reference "what's new" in About,
    correct minor minStroke issue.
+ 2023-08-31 make Setting for gStrokeMinimal=minStrokeAcuity on request, up version to 1.0.5
+ 2023-08-30 delete superfluous Autorun popup in Settings>Gratings, slightly correct gui positions on main,
    combine `_make-XcodeCappSimile.sh` and `_make-XcodeCappSimileMAIN.sh` into `_make-XcodeCapp.sh`
    add fields to webmanifest based on: <https://www.w3.org/TR/appmanifest/>
+ 2023-08-28 add "and gratings" to Settings>General># choices…
+ 2023-08-27e add colors & min/maxCPD to color gratings export; add `autoRun` to main screen, shortcut "r"; refactor: lots of `[self window]` → `selfWindow`
+ 2023-08-27d more sensible settings for all panels (no close-"x", not movable etc.)
+ 2023-08-27b colors now fully synchronised between Presets, userdefaults and the GUI representation; remove unnecessary Presets
+ 2023-08-27a correction for "applyBCMatScheie", remove 2 unused presets, in About "Semi-automatic"
+ 2023-08-27 refactor `runFractController` → `runFractControllerTest:…`: 7 action routines less
+ 2023-08-26a ensure gratingColors are initialised
+ 2023-08-26 refactor `Presets`to use `performSelector` (much more elegant :)
+ 2023-08-25 refactor `Presets`to use `sender`, add preset "BCM@Scheie"
+ 2023-08-20b add "headcount" to line-by-line
+ 2023-08-20a crowding also with line-by-line
+ 2023-08-20 linear mapping of psychometric function to grating frequency
+ 2023-08-19 add autorun to gratings, fix wrong result value for gratingAcuity
+ 2023-08-13 rename strokePolygon→fillPolygon, fix *.0 → * (all Numbers are floats)
+ 2023-08-11 fix regression with number of choices, gratings circular mask now via clip [now default off, (bug in current Safari)], "viewWidth/2"→viewWidth2 etc.
+ 2023-08-09 gratings circular mask optional
+ 2023-08-09 increase default range for CPD, increase significant digits in results
+ 2023-08-09 add "cancel" to not-calibrated alert, change wording a little
+ 2023-08-08a fix export string for grating acuity
+ 2023-08-08 extend gratings lowest spat freq, add tooltips
+ 2023-08-03 rename preset "Test" to "Testing"; add Shortcuts link
+ 2023-08-02a fix: oblique logic for all grating types
+ 2023-08-02 fix: grating no longer visible beyond mask, improve Readme, gratings "oblique only"
+ 2023-07-31 add "acuity_grating" to export string
+ 2023-07-30 implement what2Sweep stuff (contrast or spatial frequency): working, improve GUI, needs better export
+ 2023-07-29 refactor gratings (prepare frequency sweep for BCM)
+ 2023-07-28 fix colorgrating background
+ 2023-07-24 improve more in help panel
+ 2023-07-21 improve help panel
+ 2023-07-06 fix regression in acuity GUI
+ 2023-07-05 BCM: colored grating 1st try
+ 2023-07-04 begin additions for the BCM project
+ 2023-07-03 noise also for contrast, simpler decisions on test category with "isContrast/isAcuity"
+ 2023-07-02 correct a tooltip, improve make script
+ 2023-07-01 begin "embed in noise", Version → 1.0.3
+ 2023-06-27 add preset for color
+ 2023-06-26 add export for color, "gray" → "grey"
+ 2023-06-25 begin color for acuity optotypes
+ 2023-06-24 improve the webApp manifest (e.g. added type in header), no more stray Apple icon, re-check on storing CPColor in userdefaults (missing CPData component), improve make script
+ 2023-05-31 History → separate file
+ 2023-05-29 fix regression: GUI had overlap in an optionally hidden element
+ 2023-05-28 need to increase limits for distance and calibration bar (for demo in lecture hall)
renaming of files (capp→FrACT), now only webApp
+ 2023-05-14 remove setting for window background color (not really needed, crowds) and rearrange some GUI elements
+ 2023-05-05 →webApp only, no more mention of Electron and helpers. Also fix regression with lost text in Acuity-E expl.
+ 2023-05-03 ensure that view witdth/height is correct after window resizing
+ 2023-05-03 refactor: centralise draw touch controls to avoid repeating myself
+ 2023-05-02 add autoRun for optotype & grating contrasts
+ 2023-05-02 simplify TrialHistoryController value entries, improve some names concerned with contrast
+ 2023-04-30 error diffusion for contrast grating optional
+ 2023-04-30 contrast grating looking good
## ↑Gratings

+ 2023-04-22 fix crashing bug with crowding "surounding bars" introduced by "modernising" Javascript
+ 2023-03-26 default gamma value now 2.0, formerly 1.8; fix regression from MiscSpace factorisation; fix inverted ">" sign in vernier overflow
+ 2023-03-25 factorisation: separate MiscLight & MiscSpace from Misc; move "existsUrl" to Misc
+ 2023-03-24 add "Test" to presets to make life easier for me
+ 2023-03-18 slight GUI layout adjustments
+ 2023-03-07 automatic copyright end year from versionstring in About
+ 2023-03-05 more WebApp mods, add field for current value of decimalMarkChar
+ 2023-03-04 no change in the cappuccino code, but modifications for WebApp
## ↑WebApp

+ 2023-02-07 add AutoTest for VA;  gThresholdCorrection4Ascending→global
+ 2023-02-07 correct slope "polarity" for the dispersion estimation, gSlopeCI95→global
+ 2022-11-11 fix missing path in build script call, don't show Terminal – now it really works :)
+ 2022-11-10 make path to build script project-relative
+ 2022-11-08 fix a typo in tooltips, add the `XcodeCapp`-emulating shell script to project (runs via ⌘-B), add `*.xcodeproj` to git
+ 2022-10-28 add field with calculated inch value for distance, slight shifts in GUI
+ 2022-10-27 rename `credit card` to `plastic card`, shift related fields in GUI a little
+ 2022-10-12 add license in About
+ 2022-10-03 "Landolt-C" → "Landolt C"
+ 2022-09-29 fix regression: "var" → "const", should be "let" at two places
+ 2022-09-24 fix rewardPictures: first one offset by half a picture width and always same
+ 2022-09-24 all "var" → "const" (where possible) or at least "let" (modernising JavaScript)
+ 2022-09-18 the new "es2022" compiler allows modern JavaScript, so simplify code with an arrow func
more fun with "es2022", implement some "for x of <array>"
+ 2022-09-11 make Quit/Exit button title depend on operating system (Mac: Quit)
+ 2022-09-02 increase max value of `contrastOptotypeDiameter` from 1500 to 2500
+ 2022-09-01 new compiler allows "let" and "const", begin to use them
## ↑modernised JavaScript

+ 2022-08-30 in "applyESU": set "no clipboard" to avoid nagging question
+ 2022-08-29 correct version from 10.0 to 1.0, improve / add several tooltips, add Electron refs
+ 2022-08-17 increase max value of `contrastOptotypeDiameter` from 500 to 1500
+ 2022-08-11 reword calibration warning, trivial button resizing
+ 2022-08-03 allow larger distance (50 m, for presentations in halls), rename Quit/Exit → Exit/Quit
+ 2022-07-18 make Quit/Exit always available (no longer only in Node), also easier because no nw/electron discriminatin necessary
+ 2022-07-03 select Line-by-line distance between optotypes either ISO or ETDRS
+ 2022-07-02 Line-by-line to allow Landolt Cs in addition to Sloan Letters
+ 2022-06-23 improve wording in About
+ 2022-06-17 improve webview in About (border not faked by textfield etc.),
Help panel also with webview, share buttons between Help and About panels,
fix type inconsistencies in Settings (just for code beauty, had no effect),
simplify "decimalMarkChar" in Settings
+ 2022-06-15 unclutter main screen: move Cappuccino version to About panel, kVersionStringOfFract w/o "Vs"; revamp About a little
+ 2022-06-13 add version of Cappuccino Framework (1.2.2 currently) and display,
fix randomising the pseudorandom sequence
+ 2022-05-28 move Presets pop-up to Settings (where it belongs),
IB "builds for" must be set to "10.12 and later" and NOT to anything later.
+ 2022-05-26 improve "make-XcodeCappSimile.sh", improve Presets, worked on Documentation
+ 2022-05-24 add Presets (ESU and ULV so far), some editing in CONTRIBUTING.md.
BIG addition: new "make-XcodeCapp_and_run.sh" to replace XcodeCapp
## ↑XcodeCapp replaced

+ 2022-05-22 cosmetic change: gaMinimal/Maximal → strokeMinmal/Maximal
gStrokeMinimal / gStrokeMaximal now global, so accessible from dispersion estim.
Add "acuityStartingLogMAR" logic + GUI, good for ultra low vision
+ 2022-05-21 preparation for Presets
+ 2022-04-26 gStrokeMaximal = viewHeight / (5 + 1); // this leaves ½stroke margin around optotype
+ 2022-04-26 fix incorrect range check for contrastAcuityWeber, add max+/max- buttons. Change the "OK" button of settings to the correct type.
+ 2022-04-06 Settings>Tabcontainer: adjusted right edge. Not yet changed "OK" to push button (as will be needed for Aristo 3)
+ 2022-03-27 tweaks in Settings texts & positions
+ 2022-03-02 add use of credit card for size calibration
+ 2022-02-24 "Line-by-line ended." → empty string
+ 2022-02-15 ensure "Settings>General" tab is selected when coming from the un-calibrated alert
+ 2022-02-13 shorten Fullscreen → Full to avoid crop
+ 2022-01-29 Factor out to "PopulateAboutPanel", override default font in "About" with sans-serif. Also slight layout change in the "Response info" panes.
+ 2022-01-28 Revamp 'About' pane → WebView, allowing styled text & links, add "Libraries used", move this local history to "Globals.j", move global constants from Settings here
+ 2022-01-27 add "line-by-line" to "which on 5", change version to 1.0. Change version to 1.0 also in "About" panel (in future that text should be generated programmatically)
## ↑Line-by-line added

+ 2022-01-09 fix issue #6: Eccentric targets need better fixation mark presentation. Change neg. Webercontrast for acuity to -∞
+ 2022-01-07 ©→2022, fix regression (setDecimalMarkChar(X)), slightly more yellow default
+ 2022-01-06b some renaming of variables for more consistency. Try unsuccessfully to make tooltips larger by adding cr
+ 2022-01-06a renamed "decimal mark character" to "decimal separator" (term from Wikipedia)
localised the "maxPossibleAcuity + LogMAR" under the ruler
fix »In "oblique only" the buttons must also be at the oblique positions«
+ 2022-01-04 add the "halfCI95" result to the export list; this entailed changes to deal with the computation delay
+ 2021-12-23 global change: drop "currentTestName", replace by testID, thus removing double representation
+ 2021-12-23 refinements of "line-by-line"
+ 2021-12-22 add "line-by-line" mode by request. Fix error in unused logMAR→VAdec conversion
+ 2021-12-07 add field "minPossibleLogMAR" in Settings to complement "maxPossibleDecicmalAcuity"
+ 2021-11-08 add Quit/Exit button and successfully implement process.exit() in Node with the same code as running in the browser
+ 2021-11-04 add Q / X treatment in preparation of Quit/Exit button in an upcoming NWjs version. Doesn't work in a browser.
+ 2021-09-22 try autoFullScreen. Problem: program looses focus to key input until once clicked. `document.body.focus()` etc. no help.
+ 2021-09-17 simplify code to update isetIs4orientations (now in settingssDidChange)
+ 2021-09-15 refined buttons; add option to change background color
+ 2021-08-16 button images needed more space left and right
+ 2021-08-15 add custom button to improve rendering of the large square buttons
+ 2021-08-01 add option to show center fix mark when using eccentric optotypes. So far only with acuity, not contrast
add "CPBundleIdentifier … de.michaelbach.FrACT10" to Info.plist
+ 2021-07-23 eccentricity settings no longer applied twice for Vernier
+ 2021-07-04 solved problem of empty fields in settings. Needs to be done before nib loading, e.g. in init-delegate of main controller
+ 2021-06-18 added more documentation
+ 2021-06-16 better strategy when missing the Settings file to avoid seemingly empty fields in Settings. Found no way so far to re-populate the empty textfields w/o reload.
+ 2021-06-15 begin documenting with "doxygen". No code chanes, only comments and pseudo-comments
+ 2021-06-08 update tooltips after adding "automatic" to decimal mark char, corrected some other tooltips,
changed wording after automatic settings default
+ 2021-06-02 decimalMarkChar now has an "automatic" setting which reads it from the Intl.NumberFormat of the browser,
fix error in CI95 because TrialHistory had localised number,
fix center alignment of the Vernier button image
+ 2021-06-01 add © to index.html, edited README & CONTRIBUTING, improve error catching in AlternativesGenerator
+ 2021-05-29a had to change bezeltype for the buttons to CPRoundRectBezelStyle,
because the former CPRoundedBezelStyle did not draw images.
fixed regression (due to CI95) that displayed the result string for aborted runs
FractController>prepareDrawingTransformUndo: clarified why (had forgotten myelf :)
+ 2021-05-29 code review for more consistency, no new functionality
+ 2021-05-26 switch to the current Cappuccino framwork; needed changes at the ruler. Corrected copyright span.
no need for "awakeFromCib"
+ 2021-05-04 increase sampling n from 3000 → 10000
+ 2021-05-02 rename to "show ±CI95/₂"
+ 2021-04-26 add everything for calculating and displaying a measure of dispersion for acuity
+ 2021-03-01 fix bug that prevented contrast-Cs from following the # trials setting, internal renaming VA→Acuity for more consistency (changed file names too)
+ 2021-02-08 correctly deal with hiding "oblique only", understood more about KVO
+ 2021-02-04 disable "keyTestSettingsString" because it doesn't update; "true" random using current seconds;
more "Auck…" → TAO; tweak gamma GUI; add "make.sh"
+ 2021-02-01 add "obliqueOnly"
+ 2021-01-31 revamp help panel
1st attempt dealing with orientation change on tablets; works, but is reload always necessary?
add mobileOrientation to Settings
improve positioning of Vernier button image
add gamma calibration
+ 2021-01-17 finish export of full history
+ 2020-12-14 (internal changes, Resources structured)
+ 2020-11-20 latest Cappuccino frameworks made some button type changes necessary. Reverted to old framework, but changes still ok
+ 2020-11-15 add button to go to resultDetails URL, corrected export format
+ 2020-11-10 add display transformation. This went along with much refactoring and removing code, either by moving
"up" or finding that it's not used anyway
considered automatic reload when defaulting settings, but seems too intrusive
+ 2020-11-10 added reload when Settings are defaulted (also 1st time)
+ 2020-11-09 refactor: add class "FractControllerAcuity" inheriting from "FractController", forking "FractControllerContrast",
add "silent mode" for clipboard transfer
+ 2020-11-06 add 4 bars for crowding, increase distance for TAO
+ 2020-11-05b unify browswer clipboard access. Works only over https! This error now separately caught.
+ 2020-11-05a add global error handler, add checkbox for operating info on the operating info dialog
+ 2020-11-05 fix crash of contrast: no crowding with contrast, simplify code a little, add crowding to export (vs 4), title in color
+ 2020-11-04 fix crash of TAO with crowding
+ 2020-10-30 changed soundtest unicode glyph
+ 2020-10-29 add sound test button, slight GUI shifts for optical balance
+ 2020-10-27 correct regression with crowing (optotypes now in optotypes), add flanking bars, re-ordered crowding types
direct button to checklist from Help screen, window.open mit "_blank"
+ 2020-10-25 Window background not transparent, …
+ 2020-09-28 correct actual contrast levels reported back to Thresholder. Limited logCSWeber to 4.0 when %=0.
This allowed basing all reported contrast values on stimStrengthInDeviceunits
+ 2020-09-27 renamed Pest → ThresholderPest, added Tooltips for contrast checks
+ 2020-09-02 introduce class FractControllerContrast, add ContrastC & ContrastE, fix Vernier in reduced contrast
+ 2020-08-30 changed the internal contrast scale to logCS, renamed many functions, finished contrast
+ 2020-08-20 Contrast Letters seems to be working, added button and contrast GUI tab, added appropriate Settings
## ↑Contrast Letters

+ 2020-08-17 refactored to separate the "Optotypes"
+ 2020-07-03 add @typedef TestIDType; @typedef StateType
+ 2020-07-03 Export: Vs: 2; add comma/dot; add button → cheat sheet in Help
+ 2020-07-03 rename (nearly) all "Auck…" to TAO…, default no reward images, default testOn5: Sloan Letters
+ 2020-06-24 add "test on 5"
+ 2020-06-22 AucklandOptotypes → TAO(s)
+ 2020-06-18 improve logic to enable➶ the export button; correct minute in date conversion (1 t0o high); new manual location
+ 2020-06-17 add “This is free software. There is no warranty for anything" to About panel.
moved the "defines" to top, so not to forget upping the date and version
+ 2020-06-16 add volume control to Sound.j, Settings & GUI; moved contrastAcuityWeber plausibility control → Settings
+ 2020-06-12 add logic to make sure not all formats are de-selected
add "trialInfo" checkbox and logic
+ 2020-06-11 add "localStorage" from the HTML Web Storage API for an alternative export version,
optotype contrast now in Weber units, renamed contrast conversion formulae to discern Weber/Michelson,
systematic export string, factored rangeOverflowIndicator, add it to Vernier,
link to new manual
+ 2020-06-09  recover from nil data in hexString conversion
finish contrast effect on optotypes. Vernier now ok, TAO not. Some Misc function renamed to fit Objective-J
+ 2020-06-08a add contrast effect on optotypes, Vernier still wrong, TAO not. Tweak Settings GUI
+ 2020-06-08 simplify Settings, set default touch to YES, add eccentricity to all tests, buttonExport disabled→hidden
+ 2020-06-07 fix regression on export alert sequence after adding the button
+ 2020-06-05 add export button
+ 2020-06-03 fixed recursion with Auckimages, Auckland Optotypes now with buttons for touch
+ 2020-06-02 AppController window now centered when in fullScreen,
renamed console.log → console.info (don't need no log),
rewardImageView now programmatically added, not in IB (it always got in the way)
simplified controller allocation etc. by using an array, dito for panels
+ 2020-06-01 added Misc>stringFromInteger, touchResponse 4 Vernier & LandoltC
truly randomised iRandom
+ 2020-06-01 bug with tooltips: need to change something else in IB too.
corrected typos. <esc> still doesn't work in the info screens
touchResponse works for E, factored out infoText
+ 2020-05-31 enableTouchControls no accessible from info screen, improved tab sequence
+ 2020-05-29 Text correction in GUI;  added buttons for touch devices to Sloan Letters;  prepared contrast
+ 2020-05-28 Settings: maxPossAcuity on General tab, and now updates as needed via delegate controlTextDidEndEditing when leaving field
maxPossAcuity was not set correctly with localisation (float needs dot!)
+ 2020-05-26 Settings: shifted all to chckBool / chckInt / chckFlt
crowding largely done
+ 2020-05-25 vernier now correct results. maxDisplayedAcuity. Help panel. Feedback sounds. GUI tweaks.
+ 2020-05-23 added Vernier acuity; outfactored RewardsController, added Tooltips
+ 2020-05-22 added Auckland Optotypes
## ↑TAO added

+ 2020-05-21 →clipboard for exporting works in Safari & Firefox,
reward pictures
+ 2020-05-19 new buttons with images; alerted at less obnoxious stages;
the empty default window fields still not saved, but with an appropriate alert.
+ 2020-05-13 alert → CPAlert
+ 2020-05-09 modifyDeviceStimulus now acuityModifyDeviceStimulusDIN01_02_04_08]; like FrACT,
alternatives now initialised appropriately,
all 10 letters in letters
+ 2020-05-08 Fixed input problems with Firefox
2017-08-05 Acuity working
2017-07-18 serious restart with design help by PM
## ↑Restart

 */

///////////////////////////////////////////////////////////////////////

/* Attempt of readable history. Given up for now.
 devHistory = [];
 devHistory.push(["2022-09-02", 'increase max value of `contrastOptotypeDiameter` from 1500 to 2500']);
 devHistory.push(["2022-09-01", 'new compiler allows "let" and "const", begin to use them']);*/
