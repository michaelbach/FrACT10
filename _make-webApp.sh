#!/bin/zsh
# 2023-03-04 created for webApp
# 2021-08-01 moved "rm …capp" before "jake…"
# 2021-02-04 begun

cd ${0:a:h} # go to the starting directory
# pwd
rm -R ../webApp
cp JakefileWebApp Jakefile # create the correct jakefile
jake release # compile to release stage
rm -R Build/Release/webApp/Frameworks # we don't need this
rm -R Build/Release/webApp/CommonJS.environment # nor this
mv Build/Release/webApp ../ # move it up, creating the "webApp" folder
rm -R Build # and get rid of the rest of the built items

cp webApp.webmanifest ../webApp/
cp webAppServiceWorker.js ../webApp/


osascript -e 'display notification "Done."'
