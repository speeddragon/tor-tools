#!/bin/bash

#
# Check missing files from a list of links.
#

if [ ! $# -eq 1 ]; then
  echo "Use ./check_missing.sh <file_name>"
  echo ""
  echo "<file_name> should be a file with one link per line."
	echo "Use ./download_link.sh <URL> to generate that file."

  exit 1
fi

FILE=$1

source config.sh

while read -r line
do 
	if [ ! -f "$DUMP_FOLDER/${line##*/}" ]; then
		echo $line
	fi
done < $FILE

