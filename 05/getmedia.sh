#!/bin/bash
#set -euo pipefail

usage() {
	echo "Usage: At least two argument are required."
	echo "Options always come first, URL comes last."
	echo "	-a or --audio for audio files"
	echo "	-p or --picture for images"
	echo "	-doc or --document for formated text files"
	echo "	-ar or --archive for compressed archive files"
	echo "	-d N or --depth N, where N is the recursion depth"
	echo "  ! -d or --depth MUST be combined with another option !"
	echo "Example: getmedia.sh -p asch.cz/unix/"
	echo "Example: getmedia.sh -p -d 3 asch.cz/unix/"
	exit 1
}

getMedia() {

regAud="-i -e \.mp3 -e \.wav -e \.ogg"

if [ $1 = "-a" ] || [ $1 = "--audio" ]; then
  curl -L --compressed -s $2 | grep -Po '(?<=src=")[^"]*' | grep $regAud
  curl -L --compressed -s $2 | grep -Po '(?<=href=")[^"]*' | grep $regAud

  else
  regImg="-i -e \.jpg -e \.png -e \.svg -e \.jpeg -e \.gif -e \.bmp -e \.ico -e \.cur"
  if [ $1 = "-p" ] || [ $1 = "--picture" ]; then
    curl -L --compressed -s $2 | grep -Po '(?<=src=")[^"]*' | grep $regImg
    curl -L --compressed -s $2 | grep -Po '(?<=href=")[^"]*' | grep $regImg

    else
    regDoc="-i -e \.doc -e \.xls -e \.docx -e \.pdf -e \.rtf -e \.tex -e \.txt -e \.odt"
    if [ $1 = "-doc" ] || [ $1 = "--document" ]; then
      curl -L --compressed -s $2 | grep -Po '(?<=src=")[^"]*' | grep $regDoc
      curl -L --compressed -s $2 | grep -Po '(?<=href=")[^"]*' | grep $regDoc

      else
      regArch="-i -e '\.zip' -e \.rar -e \.arj -e \.tar\.* -e \.gz"
      if [ $1 = "-ar" ] || [ $1 = "--archive" ]; then
        curl -L --compressed -s $2 | grep -Po '(?<=src=")[^"]*' | grep $regArch
        curl -L --compressed -s $2 | grep -Po '(?<=href=")[^"]*' | grep $regArch

        else
          usage
      fi
    fi
  fi
fi
}

if [ $# -gt 4 ] || [ $1 = "-h" ] || [ $1 = "--help" ]
then 
	usage
fi

if [ $1 = "-d" ] || [ $1 = "--depth" ] || [ $2 = "-d" ] || [ $2 = "--depth" ] ; then
	n=1
	echo "This will take quite some time."
	if echo $4 | grep '^-' > /dev/null || echo $4 | grep -v '\.' > /dev/null; then
            usage
        fi
	curl -L --compressed -s $4 | grep -Po '(?<=href=")[^"]*' | grep http | sort -u > depth1.txt
	if [ $2 = "-d" ] || [ $2 = "--depth" ]; then
	  if echo $3 | grep [^0-9] > /dev/null; then
		 usage
	  fi 
	  count=$(($3+1))
          getMedia $1 $4
          else
          if [ $1 = "-d" ] || [ $1 = "--depth" ]; then
	    if echo $2 | grep [^0-9] > /dev/null; then
                 usage
            fi
	    count=$(($2+1))
            getMedia $3 $4
          fi
        fi

	while [ $n -lt $count ]; do
		while read i ; do
			curl -L --compressed -s $i | grep -Po '(?<=href=")[^"]*' | grep http |
		       	sort -u >> depth$(($n+1)).txt
			if [ $2 = "-d" ]; then
				getMedia $1 $i
			  else
			  if [ $1 = "-d" ]; then
				getMedia $3 $i
			  fi	
			fi
		done < depth$n.txt
		n=$(($n+1))    
	done
	n=$(($n-1))
	while [ $n -gt 0 ]; do
	  rm depth$n.txt	
	  n=$(($n-1))
	done

	else
	  if echo $2 | grep '^-' > /dev/null || echo $2 | grep -v '\.' > /dev/null; then
            usage
          fi
	  getMedia $1 $2	
fi

