#!/bin/bash

#/**
# *  Lists all the commits (and files) changed referencing a specific search criteria
# *  
# *  Supports the following flags:
# *   -m (the message text to search for) - supports egrep. ex: US129
# *   -c -flag- if set, will list the names and descriptions for the commits as-well.
# *   -s (date-optional) - the date to start check fo changes. ex: 2017-02-01
# *   -e (date-optional) - the last date to check for changes. ex: 2017-02-10
# *   -o (file/to/save) - where to store the results. defaults to show to screen
# *   -h - shows this help
#**/

messageSearch=""
startParam=""
endParam=""
outParam=""
showCommits=0

showHelp(){
	echo "Lists all the commits (and files) changed referencing a specific search criteria. "
	echo "                                                                            "
	echo "Supports the following flags:                                               "
	echo " -m (the message text to search for) - supports egrep. ex: US129            "
	echo " -c - flag - if set, will list all the commits and messages that match      "
	echo " -s (date-optional) - the date to start check fo changes. ex: 2017-02-01    "
	echo " -e (date-optional) - the last date to check for changes. ex: 2017-02-10    "
	echo " -o (file/to/save) - where to store the results. defaults to show to screen "
	echo " -h - shows this help                                                       "
}

OPTIND=1
while getopts "m:cs:e:o:h" opt; do
	#echo "opt[${opt}]"
	case $opt in
		m)
			messageSearch="${OPTARG}"
			;;
		c)
			showCommits=1
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

#echo "messageSearch[${messageSearch}]"
#echo "showCommits[${showCommits}"
#echo "startParam[${startParam}]"
#echo "endParam[${endParam}]"
#echo "outParam[${outParam}]"

if [ -z "${messageSearch}" ]; then
	echo "What should we search for in the messages?"
	read messageSearch
fi

if [ "${showCommits}" -eq 1 ]; then
	echo "showing commits"
	
	git log --pretty="%H" --grep="${messageSearch}" ${startParam} ${endParam}| while read commit_hash; do git log ${commit_hash}~1..${commit_hash}; done
fi

if [ -z "${outParam}" ]; then
	git log --pretty="%H" --grep="${messageSearch}" ${startParam} ${endParam}| while read commit_hash; do   git show --oneline --name-only "${commit_hash}" | tail -n+2; done | sort | uniq
else
	git log --pretty="%H" --grep="${messageSearch}" ${startParam} ${endParam}| while read commit_hash; do   git show --oneline --name-only "${commit_hash}" | tail -n+2; done | sort | uniq > "${outParam}"
fi	