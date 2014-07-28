#! /bin/bash

# this script concatenates and transforms the daily files from pd_listener.sh to an sql acceptible format
# 1st input parameter is the name of the output file (without csv)

rm $1.csv

for file in ./pd_bets_*.dat
do
	act=$(basename $file | cut -d'.' -f1 | cut -d'_' -f3)
	echo Transforming ${file}...
	gawk -v date=${act} -f pd_datamaker.awk $file >> $1.csv
done
