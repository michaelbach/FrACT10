#!/bin/zsh

# 2022-05-26 improve documentation
# 2022-05-25 add automatic addition of all source files, automatic detection of changed source files
# 2022-05-24 add subroutine, name array, and check for ".XcodeSupport"
# 2021-02-04 begun

## Description
#
# Workflow of Cappuccino nib development with Xcode without XcodeCapp

## How to use
#
# Assume a Cappuccino development directory containing the following:
#	- a (possibly empty) NAME.xcodeproj
#	- all *.j files and Resources
#	- Safari with Development menu and "Disable Local File Restrictions" ticked
#     (I prefer to test w/o local server)
# Edit the *.j and *.xib files as desired (e.g. in Xcode, add files manually)
# Run this shellscript. It will
#	- save all unsaved files from Xcode
#	- create and populate or update the ".XcodeSupport" directory
#	- look for "Resources/MainMenu.xib" and create or update the *.cib
#	- empty the Safari cache
#	- open the project index.html file in Safari

## Current limitations
# - new source files (*.j) need to be added manually to Xcode
# - assumes only a single XIB file "MainMenu.xib"
# - very Apple-oriented: uses AppleScript & Safari. Obvious: Xcode
# - not obvious where to obtain the initial NAME.xcodeproj (AppleScript?)
# - the delay times in the AppleScript code are rather arbitrary
# - might be better to use a server


## Global variables
xcodeSupportDirectory='.XcodeSupport'


## Subroutine for processing a single source file
OneObjj2objcskeleton() {
	mFilePath=$xcodeSupportDirectory"/"$1".m"
	modificationTimeMFile=0
	if [ -f $mFilePath ]; then
		modificationTimeMFile=$(stat -f %m $mFilePath)
	fi
	jFilePath=$1".j"
	modificationTimeJFile=$(stat -f %m $jFilePath)
	if [ $modificationTimeJFile -ge $modificationTimeMFile ]; then
		echo "objj2objcskeleton $jFilePath $xcodeSupportDirectory"
		objj2objcskeleton $jFilePath $xcodeSupportDirectory
	else
		echo "$jFilePath is current."
	fi
}


## Here starts the main code
#
echo " "
cd ${0:a:h} # go to the starting directory
workingDirectory=$(pwd)
echo "Our working directory is: $workingDirectory"
echo " "


# Save any changed Xcode files
echo "Saving changed Xcode files."
osascript <<'END'
tell application "Xcode" to activate
delay 0.2
tell application "System Events" to keystroke "s" using {command down, option down}
END
echo " "


# To show feedback what's happening
open -a Terminal


# Create xcodeSupportDirectory if necessary
if [ ! -d "$xcodeSupportDirectory" ]; then
	echo "Creating xcodeSupportDirectory."
	mkdir $xcodeSupportDirectory
	echo " "
fi


# Check all source files; if newer then recreate the pertinent *.h/*.m files
sourceArray=(*.j)
for aFile in ${sourceArray[@]}; do
	temp=${aFile:0:-2};  OneObjj2objcskeleton $temp
done
echo " "


# Create the xib file if necessary (depending on file modification times)
modificationTimeCib=0
if [ -f "Resources/MainMenu.xib" ]; then
	modificationTimeCib=$(stat -f %m Resources/MainMenu.cib)
fi
modificationTimeXib=$(stat -f %m Resources/MainMenu.xib)
if [ $modificationTimeXib -ge $modificationTimeCib ]; then
	echo "nib2cib Resources/MainMenu.xib"
	nib2cib Resources/MainMenu.xib
else
	echo "CIB file is current."
fi
echo " "


# Clear Safari's caches and open the project's index.html
osascript <<'END'
tell application "Safari" to activate
delay 0.2
tell application "System Events" to keystroke "e" using {command down, option down}
END
open -a Safari $workingDirectory"/index.html"


# If all went well, we don't need the terminal window any more
osascript -e 'tell application "Terminal" to close front window'