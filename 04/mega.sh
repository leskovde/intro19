#!/bin/bash
set -euo pipefail

if [ $1 = incl.sh ] ; then
	cp -r /usr/include/* ~/my_includes 
       	cd ~/my_includes 
       	rm -r *[0-9]* 
fi
if [ $1 = last-line.sh ] ; then 
	tail -n 3 /usr/include/*.h
fi
if [ $1 = last-mod.sh ] ; then
	ls -t | head -22
fi
if [ $1 = print.sh ] ; then
	ls -t 
fi
if [ $1 = smallest.sh ] ; then
	ls -S /bin | grep a | tail -20
fi
if [ $1 = two-chars.sh ] ; then
	ls -a $HOME | grep '^\.' | grep '[a-zA-Z][a-zA-Z][a-zA-Z]'
fi

