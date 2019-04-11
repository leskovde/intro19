#!/bin/bash
set -euo pipefail

usage() {
	echo "Usage: Two argument are required."
	echo "The first one is one of following options while the second one is a valid URL"
	echo "	-a or --audio for audio files"
	echo "	-p or --picture for images"
	echo "	-doc or --document for formated text files"
	echo "	-ar or --archive for compressed archive files"
	echo "Example: getmedia.sh -p asch.cz/unix/"
	exit 1
}

if [ $# -ne 2 ] || [ $1 = "-h" ] || [ $1 = "--help" ] || [ $2 = "-h" ] || [ $2 = "--help" ] ; then 
	usage
fi

if echo $2 | grep '^-' > /dev/null || echo $2 | grep -v '\.' > /dev/null; then
	usage
fi

regAud="-i -e \.mp3 -e \.wav -e \.ogg"

if [ $1 = "-a" ] || [ $1 = "--audio" ]; then
  curl -L --compressed -s $2 | grep -Po '(?<=src=")[^"]*' | grep $regAud
  curl -L --compressed -s $2 | grep -Po '(?<=href=")[^"]*' | grep $regAud

  else
  regImg="-i -e \.jpg -e \.png -e \.svg -e \.jpeg -e \.gif -e \.apng -e \.bmp -e \.ico -e \.cur"
  if [ $1 = "-p" ] || [ $1 = "--picture" ]; then
    curl -L --compressed -s $2 | grep -Po '(?<=src=")[^"]*' | grep $regImg
    curl -L --compressed -s $2 | grep -Po '(?<=href=")[^"]*' | grep $regImg

    else
    regDoc="-i -e \.doc -e \.xls -e \.docx -e \.pdf -e \.rtf -e \.tex -e \.txt -e \.wpd -e \.odt"
    if [ $1 = "-doc" ] || [ $1 = "--document" ]; then
      curl -L --compressed -s $2 | grep -Po '(?<=src=")[^"]*' | grep $regDoc
      curl -L --compressed -s $2 | grep -Po '(?<=href=")[^"]*' | grep $regDoc

      else
      regArch="-i -e \.zip -e \.rar -e \.arj -e \.tar\.* -e \.gz"
      if [ $1 = "-ar" ] || [ $1 = "--archive" ]; then
        curl -L --compressed -s $2 | grep -Po '(?<=src=")[^"]*' | grep $regArch
        curl -L --compressed -s $2 | grep -Po '(?<=href=")[^"]*' | grep $regArch

	else
	  usage
      fi
    fi
  fi
fi
