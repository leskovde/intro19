#!/bin/bash

#set -euo pipefail

# Not to waste your time - options don't work properly, 'next' doesn't work correctly, 'git' is done via github
# Lots of input testing is missing
# 'Help' isn't really helpful, as it doesn't always pop up when needed

url=asch.cz/intro
git=github.com/leskovde/intro19
labNumber=0

echo -n > labInfo.txt
echo -n > dates.txt
echo -n > tempdueDates.txt
echo -n > dueDates.txt
echo -n > taskDesc.txt
echo -n > taskPoints.txt
echo -n > activPoints.txt
echo -n > tpOutput.txt
echo -n > apOutput.txt
curl -L --compressed -s asch.cz/intro | sed 's/<[^>]\+>/ /g' | sed 's/  */ /g' > completePage.txt

help() {
        echo "intro19.sh [option] command"
        echo ""
        echo "  OPTIONS"
        echo "  -h, --help    Prints help."
        echo "  -g, --git     Path to your git repository."
        echo "                Default hardcode path on your filesystem."
        echo "  -u, --url     URL to the labs."
        echo "                Default http://asch.cz/intro"
        echo "  -v, --verbose Print debug outputs. Default off."
        echo "  -s, --short   Use short version of outputs."
        echo ""
        echo "  COMMANDS"
        echo "  ls     Print all scripting tasks."
        echo "  status Prints your score from scripting tasks."
        echo "  next   Prints information about next class."
}

collect() {
        echo "Collecting data..."
        curl -L --compressed -s $url | grep "\[[0-9].*\.sh\]" | sed 's/<[^>]\+>/ /g' |
        sed 's/  */ /g' > allTasks.txt

        while read -r line; do
                labNumber=$(echo "$line" | cut -f 2 -d '[' | head -c 2)
                labNumber=$(echo "$labNumber")
                taskName=$(echo "$line" | cut -f 2 -d '[' | tail -c +4 | head -c -3)
                maxPoints=$(echo "$line" | cut -f 3 -d '[' | cut -f 1 -d ' ')
                echo "$labNumber $taskName $maxPoints" >> labInfo.txt
        done < allTasks.txt

        curl -L --compressed -s $url | grep '[0-9]\.[0-9]\.' | sed -e 's/<br>/ /g' |
        cut -d ' ' -f 2 | tr '.' ' ' > tempDates.txt

        while read -r line; do
                month=$(echo "$line" | cut -f 2 -d ' ')
                day=$(echo "$line" | cut -f 1 -d ' ')
                case $day in
                        1)
                                for n in seq 1 6; do
                                        echo "2019-$month-$day" >> dates.txt
                                        date -d "2019-$month-$day +7 days" >> tempdueDates.txt
                                done;;
                        8)
                                for n in seq 1 6; do
                                        echo "2019-$month-$day" >> dates.txt
                                        date -d "2019-$month-$day +7 days" >> tempdueDates.txt
                                done;;
                        15)
                                for n in seq 1 3; do
                                        echo "2019-$month-$day" >> dates.txt
                                        date -d "2019-$month-$day +14 days" >> tempdueDates.txt
                                done;;
                        22)
                                for n in seq 1 2; do
                                        echo "2019-$month-$day" >> dates.txt
                                        date -d "2019-$month-$day +21 days" >> tempdueDates.txt
                                done;;
                        29)
                                echo "2019-$month-$day" >> dates.txt
                                date -d "2019-$month-$day +28 days" >> tempdueDates.txt;;
                        *)
                                echo "2019-$month-$day" >> dates.txt
                                date -d "2019-$month-$day +7 days" >> tempdueDates.txt

                esac
        done < tempDates.txt

        while read -r line; do
                month=$(echo "$line" | cut -f 2 -d ' ')
                day=$(echo "$line" | cut -f 3 -d ' ')
                echo "2019-$month-$day" >> dueDates.txt
        done < tempdueDates.txt

        while read -r line; do
                tempNumber=$(echo "$line" | cut -f 1 -d ' ' )
                if [ $labNumber -ne $tempNumber ]; then
                        labNumber=$(echo "$line" | cut -f 1 -d ' ' )
                        labName=$(echo "$line" | cut -f 2 -d ' ')
                        id=$(echo "[$labNumber/$labName]")
                        gitS=$(echo "$git/blob/master/$labNumber/_homework_points")
                        gitA=$(echo "$git/blob/master/$labNumber/_activity_points")
                        curl -L --compressed -s $gitS | grep 'id="LC1"' | sed 's/<[^>]\+>/ /g' |
                        sed 's/  */ /g' | tr -d ' ' >> taskPoints.txt
                        curl -L --compressed -s $gitS | grep 'id="LC1"' | sed 's/<[^>]\+>/ /g' |
                        sed 's/  */ /g' | tr -d ' ' >> tpOutput.txt
                        curl -L --compressed -s $gitA | grep 'id="LC1"' | sed 's/<[^>]\+>/ /g' |
                        sed 's/  */ /g' | tr -d ' ' >> activPoints.txt
                        curl -L --compressed -s $gitA | grep 'id="LC1"' | sed 's/<[^>]\+>/ /g' |
                        sed 's/  */ /g' | tr -d ' ' >> apOutput.txt
                else
                        labNumber=$(echo "$line" | cut -f 1 -d ' ' )
                        labName=$(echo "$line" | cut -f 2 -d ' ')
                        id=$(echo "[$labNumber/$labName]")
                        gitS=$(echo "$git/blob/master/$labNumber/_homework_points")
                        gitA=$(echo "$git/blob/master/$labNumber/_activity_points")
                        curl -L --compressed -s $gitS | grep 'id="LC1"' | sed 's/<[^>]\+>/ /g' |
                        sed 's/  */ /g' | tr -d ' ' >> tpOutput.txt
                        curl -L --compressed -s $gitA | grep 'id="LC1"' | sed 's/<[^>]\+>/ /g' |
                        sed 's/  */ /g' | tr -d ' ' >> apOutput.txt

                fi
        done < labInfo.txt
}

ls() {
        paste -d ' ' labInfo.txt dates.txt dueDates.txt tpOutput.txt > lsComplete.txt
        while read -r line; do
                major=$(echo "$line" | cut -f 4,5 -d ' ')
                maxPts=$(echo "$line" | cut -f 3 -d ' ')
                pts=$(echo "$line" | cut -f 6 -d ' ')
                if [ -z "$pts" ]; then
                        pts=0
                fi
                if [ $maxPts -lt $pts ]; then
                        pts=$maxPts
                fi
                name=$(echo "$line" | cut -f 2 -d ' ')
                echo "$major $pts/$maxPts $name"
                echo ""
        done < lsComplete.txt
}

status() {
        #if [ "$1" -ne "-s" ] || [ "$1" -ne "--short" ]; then
        paste -d ' ' labInfo.txt tpOutput.txt > statusComplete.txt
        while read -r line; do
                maxPts=$(echo "$line" | cut -f 3 -d ' ')
                pts=$(echo "$line" | cut -f 4 -d ' ')
                if [ -z "$pts" ]; then
                        pts=0
                fi
                if [ $maxPts -lt $pts ]; then
                        pts=$maxPts
                fi
                major=$(echo "$line" | cut -f 1,2 -d ' ')
                echo "$major $pts/$maxPts"
        done < statusComplete.txt

        sumS=$(cat taskPoints.txt | tr '\n' '+' | head -c -1)
        sumS=$(echo "$sumS" | bc)
        maxS=$(cat labInfo.txt | cut -f 3 -d ' ' | tr '\n' '+' | head -c -1)
        maxS=$(echo "$maxS" | bc)
        actA=$(cat activPoints.txt | tr '\n' '+'| head -c -1)
        actA=$(echo "4+$actA" | bc)
        actS=$(echo "$sumS*100/$maxS" | bc)
        diffS=$((actS-75))
        diffPts=$((sumS-maxS))
        diffA=$((actA-10))

        echo ""
        echo "Scripting Summary: Actual $actS%, Needed 75%, Diff $diffS% ($diffPts pts)."
        echo "Activity Summary: Actual $actA pts, Needed 10 pts, Diff $diffA pts."
        #else
        #        sumS=$(cat taskPoints.txt | tr '\n' '+' | head -c -1)
        #        sumS=$(echo "$sumS" | bc)
        #        maxS=$(cat labInfo.txt | cut -f 3 -d ' ' | tr '\n' '+' | head -c -1)
        #        maxS=$(echo "$maxS" | bc)
        #        actA=$(cat activPoints.txt | tr '\n' '+'| head -c -1)
        #        actA=$(echo "4+$actA" | bc)
        #        actS=$(echo "$sumS*100/$maxS" | bc)
        #        diffS=$((actS-75))
        #        diffPts=$((sumS-maxS))
        #        diffA=$((actA-10))
		#
        #        echo ""
        #        echo "Scripting Summary: Actual $actS%, Needed 75%, Diff $diffS% ($diffPts pts)."
        #        echo "Activity Summary: Actual $actA pts, Needed 10 pts, Diff $diffA pts."
        #fi
}

next() {
        now=$(date +%s)
        while read -r line; do
                class=$(date -d "$line" +%s)
                if [ $now -lt $class ]; then
                        hours=$((class-now))
                        hours=$((hours/3600))
                        day=$(echo "$line" | cut -f 3 -d '-')
                        month=$(echo "$line" | cut -f 2 -d '-')
                        date=$(echo "$day.$month.")
                        echo "$date $hours"
                        tac completePage.txt | sed "/$date/q" | tac > classPage.txt
                        sed -i -n '/Before Class/,/On Class/p;/On Class/q' classPage.txt
                        sed -i -n '/Before Class/,/On Class/p;/On Class/q' classPage.txt | wc -l
                        sed -i -n '/On Class/,/Scripting Tasks/p;/Scripting Tasks/q' classPage.txt
                        sed -i -n '/On Class/,/Scripting Tasks/p;/Scripting Tasks/q' classPage.txt |
                        wc -l
                        sed -irn '/Scripting Tasks/,/Before Class|Resources/p;/Before Class|Resources/q' classPage.txt
                        sed -irn '/Scripting Tasks/,/Before Class|Resources/p;/Before Class|Resources/q' classPage.txt |
                        wc -l
                        break
                fi
        done < dates.txt
}

collect
if [ "$1" = "ls" ] || [ "$1" = "status" ] || [ "$1" = "next" ]; then
        { $(echo "$1"); } 2> /dev/null
        else if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        help
        else if [ "$1" = "-g" ] || [ "$1" = "--git" ] || [ "$1" = "-u" ] || [ "$1" = "--url" ]; then
        { $(echo "$3 $1 $2"); } 2> /dev/null
        else if [ "$1" = "-s" ] || [ "$1" = "--short" ]; then
        { $(echo "$2 $1"); } 2> /dev/null
        else if [ "$1" = "-v" ] || [ "$1" = "--verbose" ]; then
        $(echo "$2")
        fi
      fi
    fi
  fi
  else
  help
fi
rm completePage.txt dates.txt labInfo.txt tempdueDates.txt dueDates.txt taskDesc.txt taskPoints.txt activPoints.txt tpOutput.txt apOutput.txt
