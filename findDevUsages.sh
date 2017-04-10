#!/bin/bash

for search in "$@"
do
	echo "searching for: ${search}"
	. findDevUsage.sh "${search}"
	sleep 1
done