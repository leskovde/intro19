#!/bin/bash
set -euo pipefail

cut -d : -f 1,6 /etc/passwd | tr ":" " " | tr -d "," > cut_01
cut -d : -f 3 /etc/passwd | tr ":" " "  > cut_02
paste -d " " cut_01 cut_02 | sort -b -k 2,2 -k 3,3 | grep [02468]$
rm cut_01 cut_02
