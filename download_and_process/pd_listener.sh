#! /bin/bash

#This script saves bet information from PrimeDice webpage to daily stamped files
#
#Header: username,winnings,roll,bet_id,game,result,multiplier,elapsed,id,bet

echo "This script saves bet information from PrimeDice webpage to daily stamped files"
echo "Start to download..."

apilink="https://primedice.com/api/get_bets.php"

while true
do

t=$(date +%F --utc)

filename=$(echo pd_bets_${t}.dat)

#echo "Actual file: "${filename} 

	wget ${apilink} -O - -q | python pd_transform.py > tray.dat
	grep -v -i -f old.dat tray.dat > new.dat	
	
echo "Time:"$(date +%X --utc)" New lines: "$(wc -l new.dat | cut -d " " -f 1)

	tac new.dat >> ${filename}
	mv tray.dat old.dat

#sleep 1 #to ease network load
done
