#!/bin/bash

#example start="6ee0a2573fa56ab4b488783301c422a8be70a36d"
#example end="HEAD"

echo "This shellscript finds all files to be deployed"
echo "What is the earliest commit (hash) to check from?"
echo "( NOTE: ~ also works to get the commit prior, ex: HEAD~10 gets 10 commits before HEAD )"
read start

echo "What is the ending commit (hash)?"
read end

git diff --diff-filter=ACMR --name-status "${start}" "${end}" . | awk '!/\.xml/' | awk '/src\//' | sed -e 's/[ACMR]	//g' | sed -e 's/src\///g'


