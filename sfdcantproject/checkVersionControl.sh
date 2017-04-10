#!/bin/bash

# The purpose of this script is to check what files are in version control
# As opposed to what is inside of salesforce
# 
# It does this by making certain that all files have a consistent file permission
# And then checking out all files from salesforce over the files with and version control
# (venture and that those file permissions again are the same)


echo "this will reset any local modified files under src."
echo "press enter to continue"
echo "or Ctrl-C to cancel"

read shouldContinue

rm -rdf src
git checkout src

. fixFilePermissions.sh

echo "checking for files with inconsistent file permissions"
echo "listed below:"

git status src -s -uno src

echo "Verify no files are changed."
echo "if they are, commit them to keep the file mode consistent"
echo "then press enter to continue"

read fileModeConsistent

read -p "Should we include all files? (y|n) " includeAllFiles 

cd sfdcantproject
if [ "$includeAllFiles" == "y" ]
then
	ant addPackageMember -Dmetadata.type="ApexClass" -Dmetadata.members="*"
	ant addPackageMember -Dmetadata.type="ApexComponent" -Dmetadata.members="*"
	ant addPackageMember -Dmetadata.type="ApexPage" -Dmetadata.members="*"
	ant addPackageMember -Dmetadata.type="ApexTrigger" -Dmetadata.members="*"
	ant addPackageMember -Dmetadata.type="CustomApplication" -Dmetadata.members="*"
	ant addPackageMember -Dmetadata.type="CustomLabels" -Dmetadata.members="*"
	ant addPackageMember -Dmetadata.type="CustomObject" -Dmetadata.members="*"
	ant addPackageMember -Dmetadata.type="CustomTab" -Dmetadata.members="*"
	ant addPackageMember -Dmetadata.type="Layout" -Dmetadata.members="*"
	ant addPackageMember -Dmetadata.type="ListView" -Dmetadata.members="*"
	ant addPackageMember -Dmetadata.type="PermissionSet" -Dmetadata.members="*"
	ant addPackageMember -Dmetadata.type="Profile" -Dmetadata.members="*"
	ant addPackageMember -Dmetadata.type="RecordType" -Dmetadata.members="*"
	ant addPackageMember -Dmetadata.type="StaticResource" -Dmetadata.members="*"
else
	echo "leaving alone"
fi

ant resetRefresh


cd ../
#. fixFilePermissions.sh
chmod -R 755 ./src

echo -e "Status,Type,Name of Metadata" > checkVersionControl.csv

git status -s src |
	perl -pe "s/-meta[.]xml$/†/g" |
	perl -pe "s/\.xml$/†/g" | 
	perl -pe "s/^[^\\n†]+†$//g" |
	
	perl -pe "s/^[ \t]*M[ \t]*/modified,/gi" |
	perl -pe "s/^[ \t]*D[ \t]*/deleted,/gi" |
	perl -pe "s/^[ \t]*\?+[ \t]*/unversioned,/gi" |
	perl -pe "s/\"src\/(\w+)\//\$1,\"/gi" |
	perl -pe "s/src\/(\w+)\//\$1,/gi" |

	perl -pe "s/[.]\w+(\"?)/\$1/gi" >> checkVersionControl.csv
	perl -pi -0 -w -e "s/\n\n+/\n/gi" checkVersionControl.csv
	
echo -e "\n\n\n\n\n###########\nOutput written to: checkVersionControl.csv"
echo -e ""
echo -e "Copy the first three columns to:"
echo -e "https://docs.google.com/a/salesforce.com/spreadsheets/d/1wqyC5NCCVyd8hYNJ27P66KQBYyYNyYtyCe0UReErHkI/edit?usp=sharing"
echo -e ""
echo -e "Please note the different filter views available"
echo -e "to determine which files to ignore or not"
echo -e ""
echo -e "(When you are done reviewing the changes, you can always reset the src folder through:"
echo -e "rm -rdf src; git checkout src;"
