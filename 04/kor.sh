#!/bin/bash
set -euo pipefail

# Pocet disku se predava jako argument

# Je treba pouzit neco, co jsme se neucili -> var=$((var-1))

rekurze() {
    	if [ $1 -gt 0 ] ; then
		rekurze $(($1-1)) $2 $4 $3
      		echo "Disk" $1 z $2 "na" $3"."
     		rekurze $(($1-1)) $4 $3 $2
    	fi
}
rekurze $1 a b c
