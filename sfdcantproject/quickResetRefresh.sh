#!/bin/bash

pushd $(dirname "${0}") > /dev/null
basedir=$(pwd -L)
cd "${basedir}"

echo "This command is to help pull down the latest of all items from salesforce."
echo "Into your local git folder."
echo "You will still need to commit them in git to have them deploy to QA"
echo ""

echo -ne "\033]0;Quick Reset Refresh\007";
echo "Here is where you can get started to refresh everything"
echo "Run the following command to pull the latest:"
echo "ant resetRefresh"
echo ""

ant resetRefresh
echo "if you have any issues, ping Pauly"
echo "-- press return to close or close this window --"
read shouldContinue;
#return
