#!/bin/bash
if [ $# -ne 1 ]; then
    echo $0: usage: myscript number
    exit 1
fi
number=$1

i=1
space=" "
toto="toti"
# number="6"
path="/media/DATA/Documents/0.caltech/test5_genetic_params_reduced/ag"$number
while [ $i -ne 0 ]
#for i in `seq 1 20`;
do	 
	oldtoto=$toto
	toto=$( find $path/final/out$i.png )
	echo $toto
	toto2=$( find $path/final/fig$i.png )
	echo $toto2
	totaltot=$toto$space$toto2
	if [ "$toto" == "$oldtoto" ]
	then
		i=0
		echo "End of execution with two errors."
	else
		convert $totaltot +append $path/final/final$i.png #tile = dimension of the array // geometry = pixels of one picture
		i=$(($i + 1))
	fi
done

avconv -r 2.5 -i $path/final/final%d.png -qscale 1 movie_AGparams_$number.avi