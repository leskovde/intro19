#!/bin/bash

#set -euo pipefail

rm -r tempKeys 2> /dev/null
echo "" > output_temp.txt
echo "" > blacklist_temp.txt
argCount=0
token=false
sepOpt=false
keyOpt=false
sep=" "
flag1=zero
flag2=zip
flag3=nothing
flag4=natta

# parse arguments
for arg in "$@"; do
	if [ $token == "true" ]; then
		#if [ $option == "-t" ]; then
		sep=$(echo "$arg")
		token=false
		#fi
	fi
	opt=$(echo "$arg" | head -c 2)
	if [ $opt == "-t" ]; then
		#option=$(echo "-t")
		sepOpt=true
		token=true
	elif [ $opt == "-k" ]; then
		#option=$(echo "-k")
		keyOpt=true
		numbers=$(echo "$arg" | tr -c [0-9] " " | sed 's/ */ /')
		N=$(echo "$numbers" | cut -d " " -f 2)
		M=$(echo "$numbers" | cut -d " " -f 3)
		letters=$(echo "$arg" | tr -d [0-9] | cut -d "," -f 2)
		#echo "letters = $letters"
		count=$(echo "$letters" | wc -c)
		count=$((count-1))
		#echo "wc = $count"
		numFlags=$((count+1))
		while [ $count -gt 0 ]; do 
			current=$(echo "$letters" | head -c $count | tail -c 1)
			eval "flag$count=$current"		
			count=$((count-1))	
		done	
	fi
	argCount=$((argCount+1))
done;

count=1
temp='$'$argCount
eval "file=$temp"
directory=tempKeys
mkdir $directory

# extract keys
while read -r line; do
	# can I only have one key in memory at once? can I have multiple?
	# the assignment is somewhat confusing
  if [ $keyOpt == "true" ]; then
	# _ is used instead of space for more convenient file names
	# plus it has decent sort priority => therefore files will be sorted
	# via ls based on keys in proper order, no need for further complications
	temp=$(echo "$line" | cut -d "$sep" -sf $N-$M | sed 's/ /_/g')
	if [ -n $temp ]; then
		line=$(echo "$line" | cut -d "$sep" -f $N-$M | sed 's/ /_/g')
	else
		line="$temp"
	fi
  else
	line=$(echo "$line" | sed 's/ /_/g')
  fi
  touch $directory/$line
done < $file

ls -1 $directory > keys_temp.txt
rm -r $directory/*

# apply flags
if [ $flag1 == "n" ] || [ $flag2 == "n" ] || [ $flag3 == "n" ] || [ $flag4 == "n" ]
then
	while read -r line; do
	  touch $directory/$line
	done < keys_temp.txt
	ls -1v $directory | sed 's/_/ /g' > sorted_temp.txt
	if [ $flag1 == "r" ] || [ $flag2 == "r" ] || [ $flag3 == "r" ] || [ $flag4 == "r" ]
	then
		# numerical sort can be done via -v option (natural sort)
		ls -1v $directory | tac | sed 's/_/ /g' > sorted_temp.txt
	fi
else
	while read -r line; do
	  if [ $flag1 == "b" ] || [ $flag2 == "b" ] || [ $flag3 == "b" ] || [ $flag4 == "b" ]
	  then
		line=$(echo "$line" | sed 's/ //g')
	  fi
	  if [ $flag1 == "f" ] || [ $flag2 == "f" ] || [ $flag3 == "f" ] || [ $flag4 == "f" ]
	  then
		case=true
		line=$(echo "$line" | awk '{ print tolower($0) }')
	  fi
  	touch $directory/$line
	done < keys_temp.txt
	ls -1 $directory | sed 's/_/ /g' > sorted_temp.txt
fi

# create stable sort and print the result
refCounter=1
while read -r line; do
	# stable sort process - grep complete words only from the original file;
	# the grep result is obviously in the same order as the original file;
	# the only thing left to do is to blacklist all the remaining keys with
	# the same value
	grep "$line" blacklist_temp.txt > /dev/null
	if [ $? -eq 0 ]; then
		continue
	fi
	if [ "$case" == "true" ]; then
		num=$(grep -iwc "$line" $file)
		if [ $num -eq 1 ]; then
			grep -iw "$line" $file >> output_temp.txt
		else
			echo "$line" >> blacklist_temp.txt
		fi
	else
		num=$(grep -wc "$line" $file)
		if [ $num -eq 1 ]; then
                	grep -w "$line" $file >> output_temp.txt
		else
			echo "$line" >> blacklist_temp.txt
		fi
	fi
done < sorted_temp.txt

cat output_temp.txt
rm -r $directory
rm blacklist_temp.txt
rm output_temp.txt
rm sorted_temp.txt
rm keys_temp.txt
