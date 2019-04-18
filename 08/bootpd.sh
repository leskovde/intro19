#!/bin/bash

# po obdrzeni zadani je treba si udelat konkretni priklad
# configfile.cfg

echo -n > mac_addr
echo -n > domains
echo -n > pc_name
echo -n > ip_addr
echo -n > /etc/hosts
first_line=$(head -1 /etc/bootpd)
echo $first_line > /etc/bootpd

while read -r line; do
token=0
# line with DOMAIN
        a=$(echo "$line" | grep DOMAIN)
        if [ -n "$a" ]; then
                domain_number=$(echo "$line" | cut -d ' ' -f 2)
                domain_name=$(echo "$line" | cut -d ' ' -f 3)
                grep "^$domain_number " domains > /dev/null
                if [ $? -eq 0 ]; then
                        echo "Domain uplicity found!"
                        exit 1
                fi
                echo "$domain_number $domain_name" >> domains
        fi

# line with NET
        a=$(echo "$line" | grep NET)
        if [ -n "$a" ]; then
                prefix=$(echo "$line" | cut -d ' ' -f 3)
                netname=$(echo "$line" | cut -d ' ' -f 2)
                mask=$(echo "$line" | cut -d ' ' -f 5)
                dns=$(echo "$line" | cut -d ' ' -f 6)
                if [ -n "$dns" ]; then
                        echo "$netname:IP=$prefix:SM=$mask:DS=$dns:" >> /etc/bootpd
                        else echo "$netname:IP=$prefix:SM=$mask:" >> /etc/bootpd
                fi
        fi

        a=$(echo "$line" | grep '^[0-9]')
        if [ -n "$a" ]; then
                dots=$(echo "$line" | cut -f 1 -d ' ' | grep -o '\.' | wc -l)
                if [ $dots -ne 3 ]; then
                        modline="$prefix.$line"
                        else
                                modline="$line"
                fi
                echo "$modline" >> ip_addr
                mac=$(echo "$modline" | cut -f 2 -d ' ' | grep -v '-')
                if [ -n "$mac"  ]; then
                        grep "$mac" mac_addr > /dev/null
                        if [ $? -eq 0 ]; then
                                echo "MAC duplicity found!"
                                exit 1
                        fi
                        echo "$mac" >> mac_addr
                        else
                        token=1
                fi

# this is where the magic happens
                pc_name=$(echo "$modline" | cut -f 3 -d ' ' | grep -v '^-')
                n=$(echo "$pc_name" | grep -oE '[0-9]+$')
                d=$(grep "$n " domains | cut -f 2 -d ' ')
                if [ -n "$pc_name" ]; then
                        if [ -n "$n" ]; then
                                if [ -z "$d" ]; then
                                        echo "Domain not found!"
                                        exit 1
                                fi
                                pc_name=$(echo "$pc_name" | sed "s/$n/$d/")
                                modline=$(echo "$modline" | sed "s/$n/$d/")
                        fi
                        grep "$pc_name" pc_name > /dev/null
                        if [ $? -eq 0 ]; then
                                echo "Name duplicity found!"
                                exit 1
                        fi
                        echo "$pc_name" >> pc_name
                        else
                        token=1
                fi
        fi
        if [ "$token" -eq 0 ]; then
                grep "$modline" hosts > /dev/null
                if [ $? -ne 0 ]; then
                        echo "$modline" >> /etc/hosts
                        pc_name=$(echo "$modline" | cut -d ' ' -f 3)
                        ip_addr=$(echo "$modline" | cut -d ' ' -f 1)
                        mac=$(echo "$modline" | cut -d ' ' -f 2)
                        net=$(grep $ip_addr networks | cut -d ' ' -f 1)
                        if [ -n "$pc_name" ] && [ -n "$ip_addr" ] && [ -n "$mac" ]; then
                                echo "$pc_name:IP=$ip_addr:MC=$mac:NN=$netname" >> /etc/bootpd
                        fi
                fi
        fi

done

args=$(ps axo command,args | grep bootpd | cut -d ' ' -f 2)
pid=$(pidof bootpd)
kill -15 $pid
$args
rm pc_name ip_addr domains mac_addr
