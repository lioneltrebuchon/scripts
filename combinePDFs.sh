#!/bin/bash
if [ $# -ne 1 ]; then
    echo $0: usage: /combinePDFs.sh "path/with spaces/path"
    exit 1
fi
path=$1
cd $path

i=1
space=" "
toto="toti"
path="$path"
while [ $i -ne 0 ]
#for i in `seq 1 20`;
do	 
    echo "$i"
    oldtoto=$toto
	toto=$(find *[^1-9]$i[^0-9]*'.pdf' | tac)
	if [ $i -eq 1 ]
		then
		totaltot=$toto
	else
		totaltot=$totaltot$space$toto
	fi

	if [ "$toto" == "$oldtoto" ]
	then
		i=0
		echo "End of execution with two errors."
	else
		i=$(($i + 1))
	fi
done
pdfunite $totaltot out.pdf
# convert -append `counter=0; for x in in-*; do if [[ $(($counter % 2)) == 0 ]]; then echo $x; fi; counter=$((counter + 1)); done` out.jpg
