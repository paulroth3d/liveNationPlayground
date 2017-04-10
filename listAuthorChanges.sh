#!/bin/bash

#/**
# *  Lists all the changes that a particular author has made to this repository.
# *  
# *  Supports the following flags:
# *   -a (the name or email of the author)
# *   -s (date-optional) - the date to start check fo changes. ex: 2017-02-01
# *   -e (date-optional) - the last date to check for changes. ex: 2017-02-10
# *   -o (file/to/save) - where to store the results. defaults to show to screen
# *   -h - shows this help
#**/

userSearch=""
startParam=""
endParam=""
outParam=""

showHelp(){
	echo "Lists all the changes that a particular author has made to this repository. "
	echo "                                                                            "
	echo "Supports the following flags:                                               "
	echo " -a (the name or email of the author)                                       "
	echo " -s (date-optional) - the date to start check fo changes. ex: 2017-02-01    "
	echo " -e (date-optional) - the last date to check for changes. ex: 2017-02-10    "
	echo " -o (file/to/save) - where to store the results. defaults to show to screen "
	echo " -h - shows this help                                                       "
}

OPTIND=1
while getopts "a:s:e:o:h" opt; do
	#echo "opt[${opt}]"
	case $opt in
		a)
			userSearch="${OPTARG}"
			;;
		s)
			startParam="--since=\"${OPTARG}\""
			;;
		e)
			endParam="--until=\"${OPTARG}\""
			;;
		o)
			outParam="${OPTARG}"
			;;
		h)
			showHelp
			return;
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			showHelp
			return;
			;;
	esac
done

#echo "userSearch[${userSearch}]"
#echo "startParam[${startParam}]"
#echo "endParam[${endParam}]"
#echo "outParam[${outParam}]"

if [ -z "${userSearch}" ]; then
	echo "What is the name of the author I should search for?"
	read userSearch
fi

if [ -z "${outParam}" ]; then
	git log --pretty="%H" --author="${userSearch}" ${startParam} ${endParam}| while read commit_hash; do   git show --oneline --name-only "${commit_hash}" | tail -n+2; done | sort | uniq
else
	git log --pretty="%H" --author="${userSearch}" ${startParam} ${endParam}| while read commit_hash; do   git show --oneline --name-only "${commit_hash}" | tail -n+2; done | sort | uniq > "${outParam}"
fi	