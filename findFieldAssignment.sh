#!/bin/bash

type aha >/dev/null 2>&1 || { echo >&2 "I require aha to highlight matches, but cannot find it. Please run 'brew install aha' before continuing."; return; }

#usage(){
#	echo "findDevUsage [-c <context>] [-s <search>]" 1>&2; exit 1;
#}
#
#
#unset contextSize;
#unset search;
#
#while getopts "c:s:" opt; do
#	case "${opt}" in
#		c)
#			contextSize=${OPTARG}
#			;;
#		s)
#			search=${OPTARG}
#			;;
#		*)
#			usage
#			echo "hello"
#			z			return;
#			;;
#	esac
#done
#shift $((OPTIND-1))
#
#if [ -z "${contextSize}" ]; then
#	echo "contextSize not sent"
#	contextSize=3
#fi
#
#if [ -z "${search}" ]; then
#	echo "What should I search for in custom development?"
#	read search
#fi
#
#echo "contextSize[${contextSize}] search[${search}]"
#
#echo "I have found aha and ready to get going"

contextSize=5

if [ -z "${1}" ]; then
	echo "What should I search for in custom development?"
	read search
else
	search="${1}"
fi

mkdir -p /tmp/fieldAssignments
filePath="/tmp/fieldAssignments/${search}_assignment.html"

grep -r -n -i -C ${contextSize} --color=always --exclude-dir sfdcantproject --exclude \*.layout --exclude \*_Test.cls --exclude \*.profile --exclude gbc_\*_js.js --exclude \*.resource --exclude \*.permissionset "${search}\s*=[^=]" . | aha --title "${search} Assigned" --line-fix --black > "${filePath}"
open "${filePath}"