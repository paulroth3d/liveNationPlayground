#!/bin/bash

rm -rdf checkVersionControlResults
mkdir checkVersionControlResults

echo "creating csv"

echo -e "Status,Type,Name of Metadata" > checkVersionControlResults/checkVersionControl.csv

git status -s src |
	perl -pe "s/-meta[.]xml$/†/g" |
	perl -pe "s/\.xml$/†/g" | 
	perl -pe "s/^[^\\n†]+†$//g" |
	
	perl -pe "s/^[ \t]*M[ \t]*/modified,/gi" |
	perl -pe "s/^[ \t]*D[ \t]*/deleted,/gi" |
	perl -pe "s/^[ \t]*\?+[ \t]*/unversioned,/gi" |
	perl -pe "s/\"src\/(\w+)\//\$1,\"/gi" |
	perl -pe "s/src\/(\w+)\//\$1,/gi" |

	perl -pe "s/[.]\w+(\"?)/\$1/gi" >> checkVersionControlResults/checkVersionControl.csv
	perl -pi -0 -w -e "s/\n\n+/\n/gi" checkVersionControlResults/checkVersionControl.csv

echo -e "\n-- done with the csv, now creating the diff"
	
# create a diff of the changes currently held.
# please use folderDiff.sh instead.
#
#git diff src > checkVersionControlResults/checkVersionControl.diff
#echo -e "\n-- created the diff. now html"
#cat checkVersionControlResults/checkVersionControl.diff | python sfdcantproject/diff2html.py > checkVersionControlResults/checkVersionControl.html
	
echo -e "\n-- creating the changed classes file"

git diff --name-status befd383f283bbab848552f8f34a1f041abcb1a74..HEAD |
	perl -pe "s/-meta[.]xml$/†/g" |
	perl -pe "s/\.xml$/†/g" | 
	perl -pe "s/^[^\\n†]+†$//g" |
	grep .cls |
	perl -pe "s/[.]cls//g" |
	perl -pe "s/src\/classes\///g" > checkVersionControlResults/checkVersionControl_changedClasses.csv
awk '	{ p1 = $1; p2 = $2; print p2 "\t" p1; }	' checkVersionControlResults/checkVersionControl_changedClasses.csv > checkVersionControlResults/checkVersionControl_changedClasses2.csv
mv checkVersionControlResults/checkVersionControl_changedClasses2.csv checkVersionControlResults/checkVersionControl_changedClasses.csv

echo -e "\n\n\n\n\n###########\nOutput written to: checkVersionControlResults/"
echo -e ""
echo -e "Copy the first three columns to:"
echo -e "https://docs.google.com/a/salesforce.com/spreadsheets/d/1pBC_7GpQ9N5BSoSm3jaLRlfd-63c2kaOoaTcOTwcDIk/edit?usp=sharing"
echo -e ""
echo -e "Please note the different filter views available"
echo -e "to determine which files to ignore or not"
echo -e ""
echo -e "(When you are done reviewing the changes, you can always reset the src folder through:"
echo -e "rm -rdf src; git checkout src;"
