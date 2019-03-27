#!/bin/bash
set -uo pipefail

# Chybi logika prednosti operaci!
# Neni osetren pripad, kdy vstup ma jen jeden operand a jednu nebo zadnou operaci - vyzadovalo by to pevnou
# delku vsech operandu.

usage() {
	echo "Input"
	echo "	Input is prompted at launch."
	echo "	It can also be piped or loaded from a file."
	echo "	It is a single string of numbers and operators."
	echo "Arithmetic expressions:"
	echo "	Numbers and operators must not be separated via white space."
	echo "	Correct example: 1+2*3-4/5"
	exit 1
}

errCheck() {
	if [ $# -ne 0 ] ; then
		usage
	fi
}	

errCheck
while read -r i ; do
	formCheck=$(echo $i | grep '[^0-9,+,*,/,-]')
	if [ $formCheck ] ; then
		usage
	fi
	divCheck=$(echo $i | grep '/0')
	if [ $divCheck ] ; then
		echo "Cannot divide by zero!"
		exit 1
	fi
	a=$(echo $i | tr /*- +)
	b=$(echo $i | tr -s [0-9] "1")
	op1=$(echo $a | cut -d "+" -f 1)
	n=2
	while true ; do
		op2=$(echo $a | cut -d "+" -f $n)
		sign=$(echo $b | cut -d "1" -f $n)
		test=$(echo $op2 | grep '^[0-9]')
		if [ ! $test ] ; then	
			break
		fi
		if [ "$sign" == "+" ] ; then
		  	op1=$(($op1+$op2))
		fi
		if [ "$sign" == "-" ] ; then
			op1=$(($op1-$op2))
		fi
		if [ "$sign" == "*" ] ; then
			op1=$(($op1*$op2))
		fi
		if [ "$sign" == "/" ] ; then
			op1=$(($op1/$op2))
		fi
		n=$(($n+1))
		#echo $op1
	done
	echo $op1

done
