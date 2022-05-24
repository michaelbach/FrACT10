#!/bin/zsh

# 2022-05-24 added subroutine, name array, and check for ".XcodeSupport"
# 2021-02-04 begun

## Description
#
# Workflow for Cappuccino without XcodeCapp

## How to use
#
# Assume a Cappuccino development directory containing the following:
#	- an (possibly empty) NAME.xcodeproj
#	- all *.j files and Resources
# Edit the *.j and *.xib files as desired
# Then run this shellscript. It will
#	- save any open files from Xcode
#	- create and populate the ".XcodeSupport" directory
#	- look for "Resources/MainMenu.xib" and create the *.cib
#	- empty the Safari cache
#	- open the project index.html file in Safari
# In the development loop:
#	- if the XIB file has changed or simple changes in *.j files: run this shellscript
#	- if there are changes involving IBActions or @outlets:
#		- delete the ".XcodeSupport" directory
#		- run this shellscript

## Limitations
#
# - assumes only a single XIB file "MainMenu.xib"
# - …

## Improvements to be done
# - automatically deal with .m/.h creation based on file modification times


## Global variables
XcodeSupport_DIRECTORY='.XcodeSupport'


## Processing a single *.j file
OneObjj2objcskeleton() {
	ECHO "OneObjj2objcskeleton: $1"
	objj2objcskeleton $1 $XcodeSupport_DIRECTORY
}


## Here starts the code
#
cd ${0:a:h} # go to the starting directory
WORKING_DIRECTORY=$(pwd)
ECHO "Our working directory is: $WORKING_DIRECTORY"
ECHO " "


# Save all open Xcode files
osascript <<'END'
tell application "Xcode" to activate
delay 0.1
tell application "System Events" to keystroke "s" using {command down, option down}
END


# Give some feeback what's happening
osascript -e 'tell application "Terminal" to activate'


# Find out if we already have this directory; if not we recreated all *.h/*.m files
if [ ! -d "$XcodeSupport_DIRECTORY" ]; then
	mkdir $XcodeSupport_DIRECTORY
	sourceArray=("AlternativesGenerator.j" "AppController.j"
	"FractController.j" "FractControllerAcuity.j" "FractControllerAcuityC.j" "FractControllerAcuityE.j" "FractControllerAcuityL.j" "FractControllerAcuityLineByLine.j" "FractControllerAcuityTAO.j" "FractControllerAcuityVernier.j"
	"FractControllerContrast.j" "FractControllerContrastC.j" "FractControllerContrastE.j" "FractControllerContrastLett.j"
	"FractView.j" "GammaView.j" "Globals.j" "HierarchyController.j" "MDBButton.j"
	"MDBDispersionEstimation.j" "MDBSimplestatistics.j"
	"Misc.j" "Optotypes.j" "PopulateAboutPanel.j"
	"Presets.j" "RewardsController.j" "Settings.j"
	"Sound.j" "TAOController.j" "Thresholder.j" "ThresholderPest.j" "TrialHistoryController.j")
	for i in ${sourceArray[@]}; do OneObjj2objcskeleton $i; done
	ECHO " "
fi


# Create the xib file if necessary (depending on file modification times)
if [ -f "Resources/MainMenu.xib" ]; then
	modTimeCib=$(stat -f %m Resources/MainMenu.cib)
else
	modTimeCib=0
fi
modTimeXib=$(stat -f %m Resources/MainMenu.xib)
if (( modTimeXib > modTimeCib )); then
	ECHO "nib2cib Resources/MainMenu.xib"
	nib2cib Resources/MainMenu.xib
else
	ECHO "CIB file is current"
fi
ECHO " "


# Clear Safari's caches and open the project's index.html
osascript <<'END'
tell application "Safari" to activate
delay 0.1
tell application "System Events" to keystroke "e" using {command down, option down}
END
open -a Safari $WORKING_DIRECTORY"/index.html"


# If all went well, I don't want the terminal window any more
osascript -e 'tell application "Terminal" to close front window'
