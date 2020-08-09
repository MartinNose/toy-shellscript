#!/bin/bash

s="$1"
s="${s//[^[:alpha:]]/}" # 将非字母字符替换为空字符

echo "Filtered input string: $s"

r=$(rev <<< "$s")

if [ "$r" = "$s" ]; then
    echo "$s is Palindrome"
    exit 0
else
    echo "$s is not Palindrome"
    exit 1
fi
