#!/bin/bash

# 
# Download all link from a page to a file.
#

source config.sh

check_if_cmd_exists htmlq
check_if_cmd_exists curl

URL=$1

while read line
do
	# Ignore hidden and root files
	if [[ ! "$line" =~ ^\?.*|^\/.* ]]; then	
		echo "$URL$line"
	fi
done < <(curl -s -x $PROXY_URL $URL | htmlq --attribute href a)

