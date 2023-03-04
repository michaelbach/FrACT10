#!/bin/zsh
# 2023-03-04 added jakefile creation to cooperate with the webApp
# 2021-08-01 moved "rm …capp" before "jake…"
# 2021-02-04 begun

cd ${0:a:h} # go to the starting directory
# pwd
rm -R ../capp
cp JakefileCapp Jakefile # create correct jakefile
jake release # compile to release stage
rm -R Build/Release/capp/Frameworks # we don't need this
rm -R Build/Release/capp/CommonJS.environment # nor this
mv Build/Release/capp ../ # move it up, creating the "capp" folder
rm -R Build # and get rid of the rest of the built items

osascript -e 'display notification "Done."'
