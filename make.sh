#!/bin/zsh
# 2021-02-04 began

cd ${0:a:h} # go to the starting directory
# pwd
jake release # compile to release stage
rm -R Build/Release/capp/Frameworks # we don't need this
rm -R Build/Release/capp/CommonJS.environment # nor this
mv Build/Release/capp ../ # move it up, creating the "capp" folder
rm -R Build # and get rid of the rest of the built items
