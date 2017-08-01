#!/bin/bash

# Input catching
if [ $# -ne 1 ]; then
    echo $0: usage: myscript "path"
    exit 1
fi
path=$1
cd $path

printf "\n"
echo $PWD
printf "\n"

# Initializations
mkdir -p tmp
i=1
space=" "
toto="toti"
path="$path"

#  Transform files into something useable by avconv -i
while [ $i -ne 0 ]
do	 
	oldtoto=$toto
	toto=$(find -maxdepth 1 -name *[^0-9]$i'.png')
	ln -fs ../"$toto" tmp/img"$i".png;

	if [ $i -eq 1 ]
	then
		name=$toto
	fi
	if [ "$toto" == "$oldtoto" ]
	then
		i=0
		echo "End of execution with two errors."
	else
		i=$(($i + 1))
	fi
done
unset i

# Create movie
# NO OUTPUT
avconv -loglevel panic -start_number 1 -i tmp/img%d.png -r 12 -qscale 10 -b:v 1M "${name::-10}".avi
# DEBUG
# avconv -start_number 1 -i tmp/img%d.png -r 12 -qscale 10 -b:v 1M "$name".avi

# Clean up
rm -rf tmp