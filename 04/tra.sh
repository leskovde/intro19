#!/bin/bash
set -euo pipefail

# Soubor .telDb ma 6 poli, ktere jsou oddelene strednikem
# Format - jmeno;prijmeni;provolane_minuty;sms;smlouva_od;smlouva_do

name=.telDb
calc=0
result=0

if [ $1 = -existing ] ; then
	echo "Jmeno | Prijmeni | Zakaznik Do"
        cut -d ";" -f 1-2,6 .telDb | tail -n +2 | tr ";" "\t" | sort
fi
if [ $1 = -show ] ; then
	echo "Jmeno | Prijmeni | Minuty | Zpravy | Zakaznik Od | Zakaznik Do"
       	cat .telDb | tail -n +2 | tr ";" "\t" | grep $2
fi
if [ $1 = -cost ] ; then
	calc=$(grep Name1 .telDb  | cut -d ";" -f 3,4 |  tr ";" "+")
	calc="$calc*2.5"
	result=$(echo $calc | bc)
	echo "Cena tarifu: $calc = $result"
fi
if [ $1 = -help ] ; then
	echo "-existing -> vypise vsechny smlouvy"
	echo "-show 'jmeno prijmeni' -> vypise informace o danem klientovi"
	echo "-cost 'jmeno prijmeni' -> vypise cenu tarifu dle aktualniho ceniku"
	echo "-help -> vypise tuto napovedu"
fi


       
