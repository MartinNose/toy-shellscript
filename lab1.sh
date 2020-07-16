#!/bin/bash

if [ -e "$1" ]
then
    if [ -d "$1" ]
    then 
        echo "Processing directory: $1"
    else
        echo "$1 is not a directory"
        exit 1
    fi
else
    echo "$1 doesn't exit."
    exit 1
fi

fcnt=0
xcnt=0
dcnt=0
ccnt=0

for file in "$1"/*
do
    if [ -r "$file" ]
    then
        if [ -d "$file" ]
        then
            dcnt=$((dcnt + 1))
            ccnt=$((ccnt + tmp))
        elif [ -x "$file" ]
        then 
            xcnt=$((xcnt + 1))
        elif [ -f "$file" ]
        then
            fcnt=$((fcnt + 1))
            tmp=$(wc -c < "$file")
       fi
    else
        echo "$file is not readable."
    fi
done   
echo "There are $fcnt file(s), $dcnt directory(ies) and $xcnt excutable file(s) in directory '$1'."
echo "$ccnt character(s) in total."
exit 0
