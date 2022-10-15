#!/bin/bash

PROXY_URL=socks5h://localhost:9050
DUMP_FOLDER="files"

if [! -d "$DUMP_FOLER" ]; then 
	echo "Creating dump folder ..."
	mkdir $DUMP_FOLDER
fi

function check_if_cmd_exists()
{
	local $CMD=$1
	if ! command -v $CMD &> /dev/null
	then
    		echo "$CMD could not be found. Please install it using apt/brew/etc."
    		exit
	fi
}

