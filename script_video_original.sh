#!/bin/bash

## NOT WORKING YET!
if [ $# -ne 1 ]; then
    echo $0: usage: myscript path
    exit 1
fi
path=$1
cd $path

i=1
toto="toti"
path=$path
while [ $i -ne 0 ]
#for i in `seq 1 20`;
do	 
	oldtoto=$toto
	toto=$(find *[^0-9]$i[^0-9]*[.png])
	if [[ "$i" -eq 1 ]]
		then
		totaltot=$toto
	else
		totaltot=$totaltot" "$toto
	fi

	if [ "$toto" == "$oldtoto" ]
	then
		i=0
		echo "End of execution with two errors."
	else
		i=$(($i + 1))
	fi
done
# echo $totaltot
avconv -i $totaltot -qscale 15 -b:v 1M cool_diffusion.avi