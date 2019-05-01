#!/bin/bash
#set -euo pipefail

# This script creates a bunch of new files. It does not replace the original ones on purpose - write permission
# is not always availible

echo -n > recur_temp.txt

# nepouzivat sed, kdyz argumenty zadava uzivatel - code injection

# driver code
count=1
for file in "$@"; do
        echo "file" | grep '.[ch]' > /dev/null
        if [ $? -eq 0 ]; then
                ls -1 $file/*.{c,h}  >> recur_temp.txt
        fi
        while read -r line; do
                # recursion
                a=$(echo "$line" | sed -n '/^ *#/ p')
                grep "$a" recur_temp.txt > /dev/null
                if [ $? -ne 0 ]; then
                        filePath=$(readlink -f $file)
                        path=$(echo "$line" | sed 's/#include//' | sed 's/[<]/\/usr\/include\//' |
                        sed 's/[>]//' | sed "s_\"_$filePath/_" | sed 's/[\"]//' | sed 's/^ *//')
                        echo "$path" >> recur_temp.txt
                fi
                # declaration
                echo "$line" | sed -n '/^\ *\/\// p' >> $file-temp$count
                echo "$line" | sed -n '/\/\*/ p' >> $file-temp$count
                echo "$line" | sed -n '/\*\// p' >> $file-temp$count
                echo "$line" | sed -n '/^\ *\/\//! p' | sed -n '/\/\*/! p' | sed -n '/\*\//! p' |
                sed 's/(void);/();/' | sed -E '/\);/ s_ [a-z]+([,\)])_\1_g' |
                sed -E '/\{/ s_([,\(]).[a-z]+_\1_g' | sed -E '/\( *[a-z]*[,\)].*\{/ s/\{//' >> $file-temp$count
                # definiton
                temp=$(echo "$line" | sed -nE '/.*,.*\{/ p' | sed -E 's/.*(\(.*\)).*/\1/' |
                tr ',' '\n' | sed 's/^ *//' | sed 's/$/;/' | sed 's/[\(\)]//')
                if [ -n "$temp" ]; then
                        echo "$temp" >> $file-temp$count
                        echo "{" >> $file-temp$count
                fi
        done < $file
        count=$(($count+1))
done
IFS=$'\n'
for file in $(cat recur_temp.txt); do
        while read -r line; do
                # recursion
                a=$(echo "$line" | sed -n '/^ *#/ p');
                grep "$a" recur_temp.txt > /dev/null
                if [ $? -ne 0 ]; then
                        filePath=$(readlink -f $file)
                        path=$(echo "$line" | sed 's/#include//' | sed 's/[<]/\/usr\/include\//' |
                        sed 's/[>]//' | sed "s_\"_$filePath/_" | sed 's/[\"]//' | sed 's/^ *//')
                        echo "$path" >> recur_temp.txt
                fi
                # declaration
                echo "$line" | sed -n '/^\ *\/\// p' >> $file-temp$count
                echo "$line" | sed -n '/\/\*/ p' >> $file-temp$count
                echo "$line" | sed -n '/\*\// p' >> $file-temp$count
                echo "$line" | sed -n '/^\ *\/\//! p' | sed -n '/\/\*/! p' | sed -n '/\*\//! p' |
                sed 's/(void);/();/' | sed -E '/\);/ s_ [a-z]+([,\)])_\1_g' |
                sed -E '/\{/ s_([,\(]).[a-z]+_\1_g' | sed -E '/\( *[a-z]*[,\)].*\{/ s/\{//' >> $file-temp$count
                # definition
                temp=$(echo "$line" | sed -nE '/.*,.*\{/ p' | sed -E 's/.*(\(.*\)).*/\1/' |
                tr ',' '\n' | sed 's/^ *//' | sed 's/$/;/' | sed 's/[\(\)]//')
                if [ -n "$temp" ]; then
                        echo "$temp" >> $file-temp$count
                        echo "{" >> $file-temp$count
                fi
        done < $file
        count=$(($count+1))
done
