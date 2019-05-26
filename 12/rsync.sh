#!/bin/bash

sourceDir=$1
destDir=$2
swap=false
token=false

if [ $# -ne 2 ]; then
		echo "Wrong parameters!"
		echo "Usage:            $0 [directory] [directory]"
		exit 1
fi

# copy function from source to dest and vice versa
copy() {
        tFile=$(echo "$1" | sed "s_0/__")
        if [ "$token" == "true" ]; then
                sourceDirLocal=$destDir
                destDirLocal=$sourceDir
        else
                sourceDirLocal=$sourceDir
                destDirLocal=$destDir
        fi

        # if both files exist => replace
        if [ "$2" == "true" ]; then
                echo "Replacing $tFile"
                dateSource=$(date -r "$sourceDirLocal/$tFile" +%s)
                dateDest=$(date -r "$destDirLocal/$tFile" +%s)i
                # compare size and date
                if [ $dateSource -eq $dateDest ]; then
                  sizeSource=$(ls -lah "$sourceDirLocal/$tFile" | cut -f 5 -d ' ')
                  sizeDest=$(ls -lah "$destDirLocal/$tFile" | cut -f 5 -d ' ')
                  if [ $sizeSource -gt $sizeDest ]; then
                    cp -f --preserve=timestamps "$sourceDirLocal/$tFile" "$destDirLocal/$tFile"
                  else
                    cp -f --preserve=timestamps "$destDirLocal/$tFile" "$sourceDirLocal/$tFile"
                  fi
                else
                  if [ $dateSource -gt $dateDest ]; then
                    cp -f --preserve=timestamps "$sourceDirLocal/$tFile" "$destDirLocal/$tFile"
                  else
                    cp -f --preserve=timestamps "$destDirLocal/$tFile" "$sourceDirLocal/$tFile"
                  fi
                fi
        else
        # if only one of them exists => copy
                echo "Copying $tFile"
                cp --preserve=timestamps "$sourceDirLocal/$tFile" "$destDirLocal/$tFile"
        fi
        echo ""
}

# delete function - works in both ways
delete() {
        tFile=$(echo "$1" | sed "s_0/__")
        if [ "$token" == "true" ]; then
                echo "Deleting $tFile"
                rm "$destDir/$tFile"
                if [ "$2" == "true" ]; then
                        rm "$sourceDir/$tFile"
                fi
        else
                echo "Deleting $tFile"
                rm "$sourceDir/$tFile"
                if [ "$2" == "true" ]; then
                        rm "$destDir/$tFile"
                fi

        fi
        echo ""
}

# revoke - reversed copy for both files
revoke() {
        tFile=$(echo "$1" | sed "s_0/__")
        echo "Restoring $tFile"
        if [ "$token" == "true" ]; then
                sourceDirLocal=$destDir
                destDirLocal=$sourceDir
        else
                sourceDirLocal=$sourceDir
                destDirLocal=$destDir
        fi

        dateSource=$(date -r "$sourceDirLocal/$tFile" +%s)
        dateDest=$(date -r "$destDirLocal/$tFile" +%s)
        if [ $dateSource -eq $dateDest ]; then
                sizeSource=$(ls -lah "$sourceDirLocal/$tFile" | cut -f 5 -d ' ')
                sizeDest=$(ls -lah "$destDirLocal/$tFile" | cut -f 5 -d ' ')
                if [ $sizeSource -lt $sizeDest ]; then
                  cp -f --preserve=timestamps "$sourceDirLocal/$tFile" "$destDirLocal/$tFile"
                else
                  cp -f --preserve=timestamps "$destDirLocal/$tFile" "$sourceDirLocal/$tFile"
                fi
        else
                if [ $dateSource -lt $dateDest ]; then
                  cp -f --preserve=timestamps "$sourceDirLocal/$tFile" "$destDirLocal/$tFile"
                else
                  cp -f --preserve=timestamps "$destDirLocal/$tFile" "$sourceDirLocal/$tFile"
                fi
        fi
        echo ""
}

# create function - makes a directory and adds it to the to-do list
create() {
        tFile=$(echo "$1" | sed "s_0/__")
        echo "Creating $tFile"
        if [ "$token" == "true" ]; then
                mkdir "$sourceDir/$tFile"
                echo "$1" >> all_files_source.txt
        else
                mkdir "$destDir/$tFile"
                echo "$1" >> all_files_dest.txt
        fi

        echo ""
}

# tree - creates its own temporary to-do list
tree() {
        tFile=$(echo "$1" | sed "s_0/__")
        # make a list
        if [ "$token" == "true" ]; then
                grep "$1" all_files_dest.txt > tree_files.txt
                sourceDirLocal=$destDir
                destDirLocal=$sourceDir
        else
                grep "$1" all_files_source.txt > tree_files.txt
                sourceDirLocal=$sourceDir
                destDirLocal=$destDir
        fi
        cat current_pattern.txt > tree_pattern.txt
        echo "Copying $tFile"
        # search for all config files in the subtree
        while read -r treeFile; do
                sed -n "\;$treeFile;,\;END;p" config_complete.txt |
                grep '^[-]' | sed 's/^-//' | sed 's_/$_/\*_' >> tree_pattern.txt
        done < tree_files.txt
        # delete unwanted files from the list
        while read -r treePattern; do
                temp=$(grep -v "$treeFile/$pattern" all_files_source.txt)
                echo "$temp" > tree_files.txt
        done < tree_pattern.txt
        # copy all other files
        while read -r treeFile; do
                mkdir -p "$destDirLocal/$treeFile" &&
                cp --preserve=timestamps "$sourceDirLocal/$treeFile" "$destDirLocal/$treeFile"
        done < tree_files.txt
        echo ""
}

echo -n "" > subdirs_source.txt
echo -n "" > all_files_source.txt
echo -n "" > config_temp.txt
echo -n "" > config_source.txt

# traverse makes a complete list of all files, subdirectories and config files
traverseSource() {
        find -L $1 -type d -not -path '*/\.*' -print > subdirs_source.txt
        find -L $1 -not -path '*/\.*' -print > all_files_source.txt
        find -L $1 -name "_default\.baf" -print > config_temp.txt
        while read -r line; do
                echo "$line" >> config_source.txt
                cat "$line" >> config_source.txt
                echo "END" >> config_source.txt
        done < config_temp.txt
}

echo -n "" > subdirs_dest.txt
echo -n "" > all_files_dest.txt
echo -n "" > config_temp.txt
echo -n "" > config_dest.txt

# same deal
traverseDest() {
        find -L $1 -type d -not -path '*/\.*' -print > subdirs_dest.txt
        find -L $1 -not -path '*/\.*' -print > all_files_dest.txt
        find -L $1 -name "_default\.baf" -print > config_temp.txt
        while read -r line; do
                echo "$line" >> config_dest.txt
                cat "$line" >> config_dest.txt
                echo "END" >> config_dest.txt
        done < config_temp.txt
}

# all availible menus
choiceFileShort() {
        while true; do
                        echo "File: $1"
                        echo "Choose: 1)Skip 2)Copy 3)Delete"
                        read choice < /dev/tty
                        case $choice in
                                "1") break;;
                                "2") copy $1 2> /dev/null; break;;
                                "3") delete $1 2> /dev/null; break;;
                        esac
        done
}

choiceFileLong() {
        while true; do
                        echo "File: $1"
                        echo "Choose: 1)Skip 2)Copy 3)Delete 4)Revoke"
                        read choice < /dev/tty
                        case $choice in
                                "1") break;;
                                "2") copy $1 true 2> /dev/null; break;;
                                "3") delete $1 true 2> /dev/null; break;;
                                "4") revoke $1 2> /dev/null; break;;
                        esac
        done
}

choiceDir() {
        while true; do
                        echo "Directory: $1"
                        echo "Choose: 1)Skip 2)Create 3)Tree 4)Delete"
                        read choice < /dev/tty
                        case $choice in
                                "1") break;;
                                "2") create $1 2> /dev/null; break;;
                                "3") tree $1 2> /dev/null; break;;
                                "4") delete $1 2> /dev/null; break;;
                        esac
        done
}

# preparation - creating all necessary lists
traverseSource $1 2> /dev/null
traverseDest $2 2> /dev/null
cat config_source.txt config_dest.txt > config_complete.txt

# changing the root directory to something common
content=$(cat subdirs_source.txt)
echo "$content" | sed "s_$1_0_" > subdirs_source.txt
content=$(cat subdirs_dest.txt)
echo "$content" | sed "s_$2_0_" > subdirs_dest.txt
content=$(cat all_files_source.txt)
echo "$content" | sed "s_$1_0_" > all_files_source.txt
content=$(cat all_files_dest.txt)
echo "$content" | sed "s_$2_0_" > all_files_dest.txt
content=$(cat config_complete.txt)
echo "$content" | sed "s_$1_0_" | sed "s_$2_0_" > config_complete.txt

# driver code
# the idea - run through all subdirectories, stop on each, do the necessary dir. operations
# then go over each sublevel and do the necessary file operations
# then swap source and destination and go over remaining files
while [ "$swap" == "false" ]; do
  # subdir loop
  while read -r line; do
        echo "$line " | grep "." > /dev/null
        if [ $? -ne 0 ]; then
                continue
        fi
        # check for subdir
        grep "$line" subdirs_dest.txt > /dev/null
        if [ $? -eq 0 ]; then
                # subdir found - file procedure
                # pattern checking
                path=$(echo "$line/_default.baf")
                # if a pattern for current subdir is found, then change it accordingly
                # if not, use the old one (that is stored in a file)
                grep "$path" config_complete.txt > /dev/null
                if [ $? -eq 0 ]; then
                  sed -n "\;$path;,\;END;p" config_complete.txt |
                  grep '^[-]' | sed 's/^-//' | sed 's_/$_/\*_' > current_pattern.txt
                fi
                path=$(echo "$line/")
                # delete all unwanted files and directories
                while read -r pattern; do
                        temp=$(grep -v "$path$pattern" all_files_source.txt)
                        echo "$temp" > all_files_source.txt
                done < current_pattern.txt
                # delete current subdir from to-do list, since it has been processed
                temp=$(grep -xv "$line" all_files_source.txt)
                echo "$temp" > all_files_source.txt
                temp=$(grep -xv "$line" all_files_dest.txt)
                echo "$temp" > all_files_dest.txt
                # make a list of all files on this sublevel
                grep "$path[^/]*$" all_files_source.txt > sublevel_source.txt
                # delete all subdirs from this list - avoid duplicity
                while read -r directory; do
                        temp=$(grep -xv "$directory" sublevel_source.txt)
                        echo "$temp" > sublevel_source.txt
                done < subdirs_source.txt
                # process the files
                while read -r file; do
                        grep $file all_files_dest.txt > /dev/null
                        if [ $? -eq 0 ]; then
                                # file is in both directories
                                choiceFileLong $file
                        else
                                # otherwise
                                choiceFileShort $file
                        fi
                        # delete processed files from to-do list
                        temp=$(grep -xv "$file" all_files_source.txt)
                        echo "$temp" > all_files_source.txt
                        temp=$(grep -xv "$file" all_files_dest.txt)
                        echo "$temp" > all_files_dest.txt
                done < sublevel_source.txt
        else
                # subdir not found - subdir procedure
                # delete subdir from to-do list
                temp=$(grep -xv "$line" all_files_source.txt)
                echo "$temp" > all_files_source.txt
                temp=$(grep -xv "$line" all_files_dest.txt)
                echo "$temp" > all_files_dest.txt
                # process the subdir
                choiceDir $line
        fi
  done < subdirs_source.txt
  # i will have one swapperoni pizza please
  if [ "$token" == "false" ]; then
        content1=$(cat subdirs_source.txt)
        content2=$(cat subdirs_dest.txt)
        echo "$content1" > subdirs_dest.txt
        echo "$content2" > subdirs_source.txt
        content1=$(cat all_files_source.txt)
        content2=$(cat all_files_dest.txt)
        echo "$content1" > all_files_dest.txt
        echo "$content2" > all_files_source.txt
        token=true
  else
        swap=true
  fi
done
