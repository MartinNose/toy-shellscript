#!/bin/bash

s="$1"
s="${s//[^[:alpha:]]/}"

echo "Filtered input string: $s"

r=$(rev <<< "$s")

if [ "$r" = "$s" ]; then
    echo "Is Palindrome"
    exit 0
else
    echo "Not Palindrome"
    exit 1
fi
