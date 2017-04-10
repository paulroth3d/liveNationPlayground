#!/bin/bash

pushd $(dirname "${0}") > /dev/null
basedir=$(pwd -L)
cd "${basedir}"

echo -ne "\033]0;Quickstart Submodule\007";

echo ""
echo ""
echo "This is a shellscript to initialize the sfdcantproject"
echo "assuming that it is used as a submodule."
echo "(Please follow the prompt as follows, and sfdcantproject will be setup)"
echo "-- press enter to continue or close window to cancel--"
read readyToBegin

ant reverseSetup
ant setup -Drun=setup -DsetupOption=1 -DlocalSrcPath=../../src -DlocalResourcePath=../resources

echo ""
echo "-- "
echo "sfdcantproject is now setup."
echo "You can now close this window"
read shouldClose
#return
