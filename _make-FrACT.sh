#!/bin/zsh

# 2024-02-18 add "sleep 1" hoping to give iCloud time to catch up a little
# 2023-06-24 mv rather than rm avoids creation of the *2 files 
# 2023-03-04 added jakefile creation to cooperate with the webApp
# 2021-08-01 moved "rm …capp" before "jake…"
# 2021-02-04 begun


# go to the starting directory
cd "${0:a:h}"
# pwd

# delete old version
#rm -R ../FrACT ← this would give the iCloud services a hiccup, so instead mv to trash
pathFractTrash=$HOME/Library/Mobile\ Documents/.Trash/FrACT
sleep 1
rm -R "$pathFractTrash" # need to delete first, otherwise mv doesn't work in spite of "-f"
sleep 1
mv -fv ../FrACT "$pathFractTrash"
sleep 1

# ensure stop on error
set -e

# "compile"
jake release

# delete unnecessary build products
rm -R Build/Release/FrACT/CommonJS.environment # we don't need this
sleep 1
mv Build/Release/FrACT ../ # move it up, creating the "FrACT" folder
sleep 1
#would preserve date, but jake messes them up… cp -Rp Build/Release/FrACT ../ # move it up, creating the "FrACT" folder
rm -R Build # and get rid of the rest of the built items
sleep 1

# need to copy this too, could be added to jake?
cp webAppServiceWorker.js ../FrACT/

# finally…
osascript -e 'display notification "Done."'
