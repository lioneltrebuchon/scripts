#!/bin/bash
if [ $# -ne 1 ]; then
    echo $0: usage: myscript number
    exit 1
fi
number=$1

i=1
toto="toti"
path="/media/DATA/Documents/0.caltech/test5_genetic_params_reduced/ag"$number
while [ $i -ne 0 ]
#for i in `seq 1 20`;
do	 
	oldtoto=$toto
	toto=$( find $path/pos/gen$i"_"* | sort -Vr | head -n 16 | paste -sd " ")
	if [ "$toto" == "$oldtoto" ]
	then
		i=0
		echo "End of execution with two errors."
	else
		montage $toto -tile 4x4 -geometry 150x150 $path/final/out$i.png #tile = dimension of the array // geometry = pixels of one picture
		i=$(($i + 1))
	fi
done
eog $path/final/out1.png &
# convert -append `counter=0; for x in in-*; do if [[ $(($counter % 2)) == 0 ]]; then echo $x; fi; counter=$((counter + 1)); done` out.jpg