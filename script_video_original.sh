#!/bin/bash

## NOT WORKING YET!
if [ $# -ne 1 ]; then
    echo $0: usage: myscript path
    exit 1
fi
path=$1
cd $path

echo $PWD

i=1
toto="toti"
path="$path"
while [ $i -ne 0 ]
#for i in `seq 1 20`;
do	 
	# echo "$i"
	oldtoto=$toto
	#toto=$(find *[^0-9]$i[^0-9]*[.png])
	toto=$(find -maxdepth 1 -name *[^0-9]$i'.png')
	#toto=$(find . -maxdepth 1 -type f -name '*[^0-9]$i[.png]')
	if [ $i -eq 1 ]
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
# done
avconv -i $totaltot -qscale 15 -b:v 1M diff_06.14_porous_chemotaxis.avi