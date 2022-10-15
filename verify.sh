#!/bin/bash

#
# Download, resume and verify files. 
#

DOWNLOAD="true"
RESUME="true"
DEBUG="false"

source config.sh

if [ ! $# -eq 1 ]; then
	echo "Use ./verify.sh <file_name>"
	echo ""
	echo "<file_name> should be a file with one link per line."
	echo "Use ./download_link.sh <URL> to generate that file."
	exit 1
fi

FILE=$1
NUMBER_OF_LINK=$(cat $FILE | wc -l | bc)

echo "Verify links ($NUMBER_OF_LINK) inside $FILE\n"

function file_size
{
  local FILE_NAME=$1

  if [ "$(uname)" == "Darwin" ]; then 
    FILE_SIZE=$(stat -f%z $FILE_NAME | tr -d '\n')
  else
    FILE_SIZE=$(stat --printf="%s"h $FILE_NAME | tr -d '\n')
  fi
}

function url_file_size 
{
  local URL=$1

  # The last char is tricky, it will return to the beginning of a line, so I remove it.
  URL_SIZE=$(curl -s -x $PROXY_URL --head $URL | grep "Content-Length" | cut -d ":" -f2 | xargs | sed 's/.$//')
}

function download
{
	local URL=$1
  local FILE_NAME="$DUMP_FOLDER/${URL##*/}"

  if [! -f "$FILE_NAME" ]; then 
  	echo "Download ..."

		curl -x $PROXY_URL -O $URL
	else
		echo "File [$FILE_NAME] already exists, skipping ..."
  fi
}

function resume_download 
{
  local URL=$1
  local FILE_NAME="$DUMP_FOLDER/${URL##*/}"
  # Recalculate again when exits with code 18.
  file_size $FILE_NAME

  echo "Resuming download ..."

  if [  "$DEBUG" == "true" ]; then 
    echo "URL: $URL"
    echo "Filename: $FILE_NAME"
    echo "File size (bytes): $FILE_SIZE"
  fi

  curl -x $PROXY_URL -C $FILE_SIZE -O $URL
}

function check_file_size 
{
  local URL=$1

  if [ "$DEBUG" == "true" ]; then
    echo "Checking ... [$URL]"
  fi

  local FILE_NAME="$DUMP_FOLDER/${URL##*/}"

  if [ -f "$FILE_NAME" ]; then
		url_file_size $URL
		while [ "$URL_SIZE" == "" ]; do 
			if [ "DEBUG" == "true" ]; then 
				echo "Error fetching URL file size, retrying ..."
			fi
			url_file_size $URL
		done
		file_size $FILE_NAME

		if [ "$URL_SIZE" == "$FILE_SIZE" ]; then
			if [ "$DEBUG" == "true" ]; then
				echo "$FILE_NAME file size OK!"
			fi
		else 
			if [ "$FILE_SIZE" -lt "$URL_SIZE"  ]; then 
				echo "$FILE_NAME file size don't match! $FILE_SIZE less than $URL_SIZE."

				if [ "$RESUME" == "true" ]; then
					resume_download $URL
		
					while [ $? -eq 18 ]; do 
						echo "Retry again because there are bytes remaining to be read."
						resume_download $URL
					done
				fi
			else 
				echo "Weird! File $FILE_NAME is larger then original, it might be currupt!"
				echo "Please delete it and download again!"
			fi
		fi
  else
    echo "File [$FILE_NAME] not found!"

    if [ "$DOWNLOAD" == "true" ]; then 
    	download $URL
      while [ $? -eq 18 ]; do 
	  		echo "Retry again because there are bytes remaining to be read."
	  		resume_download $URL
			done
    fi
  fi 
}

while read -r line
do
  check_file_size $line
done < $FILE

