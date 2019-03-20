#!/bin/bash
set -euo pipefail

# Corner case - funguje jen pro jednociferne slozky vektoru

cat "sss.txt" | tr -dc [0-9] | wc -m > sss_01.txt
const=2
count=$(cat sss_01.txt)
count=$((count/const))
a=0
ss=0

while [ $a -lt $count ] ; do
	a=$((a+1))
	o=$(cat sss.txt | head -1 | cut -d \( -f 2 | head -c -2 | cut -d , -f $a)
	p=$(cat sss.txt | tail -1 | cut -d \( -f 2 | head -c -2 | cut -d , -f $a)
	ss=$((ss+$((o*p))))
done
rm sss_01.txt
echo x*y = $ss >> sss.txt
