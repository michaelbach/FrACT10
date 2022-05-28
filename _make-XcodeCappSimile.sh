#!/bin/zsh

## Description
#
# 2022-05-28 copy → FrACT project so it's found in git
# 2022-05-27 split into this local file and MAIN
# Workflow of Cappuccino nib development with Xcode without XcodeCapp
# main work done by the included shell script, see `source` for its location

# go to the starting directory
cd ${0:a:h}
# save it for later
workingDirectory=$(pwd)
echo "Our working directory is: $workingDirectory"

# now hand off to MAIN
#source $HOME/Library/Mobile\ Documents/com\~apple\~CloudDocs/Bach/Projekte/Websites/WWW-michaelbach-de/ot/-misc/cappFrameworks/_make-XcodeCappSimileMAIN.sh
source _make-XcodeCappSimileMAIN.sh
