#!/bin/bash

greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c() {
    echo -e "\n\n${redColour}[!]${endColour} ${grayColour}Saliendo...${endColour} \n"
    tput cnorm
    exit 1
}

#Ctrl+C
trap ctrl_c SIGINT

echo -e "\n$(cat ascii_art.txt)\n\n"

echo -e "${turquoiseColour}[i]${endColour} ${grayColour}Comenzando con el escaneo de la red $2 ...${endColour}\n\n"

tput civis

function checkHosts () {
    timeout 2 bash -c "ping -c 1 $1" &>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${greenColour}[+]${endColour} ${grayColour}Host $1 - ${endColour}${purpleColour}(${endColour}${yellowColour}ACTIVO${endColour}${purpleColour})${endColour}"
    elif [ $? -eq 124 ]; then
        for port in 21 22 23 25 80 139 443 445 8080; do
            (exec 3<> /dev/tcp/$1/$port) 2>/dev/null
            if [ $? -eq 0 ]; then
                echo -e "${greenColour}[+]${endColour} ${grayColour}Host $1 - ${endColour}${purpleColour}(${endColour}${yellowColour}ACTIVO${endColour}${purpleColour})${endColour}"
            fi
            exec 3<&-
            exec 3>&-
        done
    fi     
}

while [ "$1" != "" ]; do
    case "$1" in
        -i | --ip )     ip="$2";    shift;;
    esac
    shift
done
#Ve que la ip se haya proporcionado
if [[ $ip == "" ]]; then
    echo -e "${redColour}[!]${endColour} ${grayColour}Porfavor dame la ip -i${endColour}"
    echo -e "\n\t${blueColour}[-]${endColour}${grayColour} USO: $0 -i <ip>/<CIDR>${endColour}\n"
    exit
fi
tput civis

network=$(echo $ip | cut -d '/' -f 1)
prefix=$(echo $ip | cut -d '/' -f 2)

IFS='.' read -r i1 i2 i3 i4 <<< "$network"


if [ "$prefix" -gt 24 ]; then
    startip=$(($i4+1))
    endippw=$(echo "2^(32-$prefix)" | bc)
    endip=$(($i4+$endippw-2))
    for i in $(seq $startip $endip); do
        (checkHosts "$i1.$i2.$i3.$i") &
    done
elif [ "$prefix" -gt 16 ]; then
    hosts=$(echo "2^(32-$prefix)" | bc)
    hosts=$(($hosts))
    startip=$(($i4+1))
    iterations=$((($hosts/256)+$i3))
    for ((i=$i3; i<iterations;i++));do
        for ((k=startip; k<256;k++));do
            (checkHosts "$i1.$i2.$(($i3+($i-$i3))).$k") &
        done
        startip=0
    done
    if [ "$i4" -ne 0 ]; then 
        finalip=$i4
        for i in $(seq 0 $finalip); do
            (checkHosts "$i1.$i2.$iterations.$i") &
        done
    fi
elif [ "$prefix" -gt 8 ]; then
    hosts=$(echo "2^(32-$prefix)" | bc)
    hosts=$(($hosts))
    startip=$(($i4+1))
    startip2=$i3
    iterations=$((($hosts/65536)+$i2))
    for ((j=$i2; j<iterations;j++));do
        for ((i=startip2; i<256;i++));do
            for ((k=startip; k<256;k++));do
                (checkHosts "$i1.$(($i2+($j-$i2))).$i.$k") &
            done
            startip=0
        done
        startip2=0
    done
    if [ "$i3" -ne 0 ]; then 
        finalip=$i4
        finalip2=$i3
        for i in $(seq 0 $finalip2);do
            for ((k=0; k<256;k++));do
                (checkHosts "$i1.$iterations.$i.$k") &
            done
            startip=0
        done
        if [ "$i4" -ne 0 ]; then 
            finalip=$i4
            for i in $(seq 0 $finalip); do
                (checkHosts "$i1.$iterations.$finalip2.$i") &
            done
        fi
    elif [ "$i4" -ne 0 ]; then 
        finalip=$i4
        for i in $(seq 0 $finalip); do
            (checkHosts "$i1.$iterations.$i3.$i") &
        done
    fi
elif [ "$prefix" -gt 0 ]; then
    hosts=$(echo "2^(32-$prefix)" | bc)
    startip=$(($i4+1))
    startip2=$i3
    startip3=$i2
    iterations=$(echo "scale=0; ($hosts / 16777216) + $i1" | bc)
    for ((l=$i1; l<iterations;l++));do
        for ((j=startip3; j<256;j++));do
            for ((i=startip2; i<256;i++));do
                for ((k=startip; k<256;k++));do
                    (checkHosts "$(($i1+($l-$i1))).$j.$i.$k") &
                done
                startip=0
            done
            startip2=0
        done
        startip3=0
    done

    if [ "$i2" -ne 0 ]; then
        finalip=$i4
        finalip2=$i3
        finalip3=$i2
        for j in $(seq 0 $finalip3);do
            for ((i=0; i<256;i++));do
                for ((k=0; k<256;k++));do
                    (checkHosts "$iterations.$j.$i.$k") &
                done
                startip=0
            done
        done
        if [ "$i3" -ne 0 ]; then 
            for i in $(seq 0 $finalip2);do
                for ((k=0; k<256;k++));do
                    (checkHosts "$iterations.$finalip3.$i.$k") &
                done
                startip=0
            done
        fi
        if [ "$i4" -ne 0 ]; then
            for i in $(seq 0 $finalip); do
                (checkHosts "$iterations.$finalip3.$finalip2.$i") &
            done
        fi
    elif [ "$i3" -ne 0 ]; then 
        finalip=$i4
        finalip2=$i3
        for i in $(seq 0 $finalip2);do
            for ((k=0; k<256;k++));do
                (checkHosts "$iterations.$i2.$i.$k") &
            done
            startip=0
        done
        if [ "$i4" -ne 0 ]; then 
            finalip=$i4
            for i in $(seq 0 $finalip); do
                (checkHosts "$iterations.$i2.$finalip2.$i") &
            done
        fi
    elif [ "$i4" -ne 0 ]; then 
        finalip=$i4
        for i in $(seq 0 $finalip); do
            (checkHosts "$iterations.$i2.$i3.$i") &
        done
    fi
fi

wait

tput cnorm