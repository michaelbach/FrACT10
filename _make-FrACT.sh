#!/bin/zsh

# 2023-06-24 mv rather than rm avoids creation of the *2 files 
# 2023-03-04 added jakefile creation to cooperate with the webApp
# 2021-08-01 moved "rm …capp" before "jake…"
# 2021-02-04 begun


cd "${0:a:h}" # go to the starting directory
# pwd

#rm -R ../FrACT ← this would give the iCloud services a hiccup, so mv to trash
pathFractTrash=$HOME/Library/Mobile\ Documents/.Trash/FrACT
rm -R "$pathFractTrash" # need to delete first, otherwise mv doesn't work
mv -fv ../FrACT "$pathFractTrash"

set -e # ensure stop on error

jake release

rm -R Build/Release/FrACT/CommonJS.environment # we don't need this
mv Build/Release/FrACT ../ # move it up, creating the "FrACT" folder
rm -R Build # and get rid of the rest of the built items

cp webAppServiceWorker.js ../FrACT/

osascript -e 'display notification "Done."'
