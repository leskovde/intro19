#!/bin/bash

ps aux --sort '-%mem' | grep ^root | head -10 | tr -s " " | cut -d " " -f 2 | tr "\n" "+" | head -c -1 > ps_01;
echo "" >> ps_01
cat ps_01 | bc
rm ps_01
