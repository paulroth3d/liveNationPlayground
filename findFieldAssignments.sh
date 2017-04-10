#!/bin/bash

for search in "$@"
do
	echo "searching for: ${search}"
	. findFieldAssignment.sh "${search}"
	sleep 1
done