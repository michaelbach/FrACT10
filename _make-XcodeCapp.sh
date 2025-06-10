#!/bin/zsh

## Description
#
# Workflow of Cappuccino nib development with Xcode without XcodeCapp

## History"
# 2023-09-23 add FileModTime to simplify modification date access
# 2023-08-31 combined `_make-XcodeCappSimile.sh` and `_make-XcodeCappSimileMAIN.sh`into this
# 2022-11-12 no more "open terminal", because empty when script in child of Xcode
# 2022-06-14 corrected the logic for *.cib (re)creation
# 2022-05-27 separated into different sources, MAIN is here.  Ignore "main.*"
# 2022-05-26 improve documentation
# 2022-05-25 add automatic addition of all source files, automatic detection of changed source files
# 2022-05-24 add subroutine, name array, and check for ".XcodeSupport"
# 2021-02-04 begun

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
# - assumes a single XIB file called "MainMenu.xib"
# - very Apple-oriented: uses AppleScript & Safari. Also (obviously): Xcode
# - does not generate the initial NAME.xcodeproj (clone it from another project or generate with Xcode)
# - the delay times in the AppleScript code are rather arbitrary
# - might be better to use a local http server

set -e # ensure stop on error

## Subroutine for file modification time, returns 0 if file does not exist
FileModTime() {
	local modificationTime=0
	if [ -f $1 ]; then
		modificationTime=$(stat -f %m $1)
	fi
	# below "fakes" return value, to be captured with $()
	echo $modificationTime
}

## Subroutine to process a single source file (´.j´)
OneObjj2objcskeleton() {
	local mFilePath=$xcodeSupportDirectory/"$1".m
	local modificationTimeMFile=$(FileModTime $mFilePath)
	jFilePath=$1".j"
	local modificationTimeJFile=$(FileModTime $jFilePath)
	if [ $modificationTimeJFile -ge $modificationTimeMFile ]; then
		echo "objj2objcskeleton $jFilePath $xcodeSupportDirectory"
		objj2objcskeleton $jFilePath $xcodeSupportDirectory
	else
		echo "$jFilePath is current."
	fi
}

set -e # ensure stop on error


## Global variables
xcodeSupportDirectory='.XcodeSupport'


## Here starts main
#
cd ${0:a:h} # go to starting directory
workingDirectory=$(pwd) # save it for later
echo "Our working directory is: $workingDirectory"
echo " "

# Save any changed Xcode files
echo "Saving any changed Xcode files."
osascript <<'END'
tell application "Xcode" to activate
delay 0.2
tell application "System Events" to keystroke "s" using {command down, option down}
tell application "Terminal" to activate
END
echo " "

# Check version date in service worker, update if necessary
node ./updateServiceWorkerDateFromInfoPlist.js

# Create xcodeSupportDirectory if necessary
if [ ! -d "$xcodeSupportDirectory" ]; then
	echo "Creating xcodeSupportDirectory."
	mkdir $xcodeSupportDirectory
	echo " "
fi

# Check all source files; for newer ones recreate the pertinent *.h/*.m files
sourceArray=(*.j)
for aFile in "${sourceArray[@]}"; do
	# drop the trailing `.j`
	temp=${aFile:0:-2}
	# process all files but `main.j`
	if [ ! "$temp" = "main" ]; then
		OneObjj2objcskeleton $temp
	fi
done
echo " "

# (re)create the cib file when necessary (depending on file modification times)
modificationTimeXib=$(FileModTime Resources/MainMenu.xib)
modificationTimeCib=$(FileModTime Resources/MainMenu.cib)
#echo "modificationTimeXib: " $modificationTimeXib ",  modificationTimeCib: " $modificationTimeCib
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
open -a Safari $workingDirectory"/index4testing.html"
