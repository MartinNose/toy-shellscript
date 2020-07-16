#!/bin/bash

sync () {
    echo "From directory $1 to $2"

    if [ ! "$(ls -A "$1")" ]; then
        echo "Dir: $1 is empty."
        exit 0
    fi

    for file in "$1"/*
    do
        new_file="$2${file/$1/}"
        echo "Checking $new_file..."
        if [ -d "$file" ]; then
            if [ -e "$new_file" ]; then
                sync "$file" "$new_file"
            else
                echo -e "\033[0;31mExecuting\033[0m: cp -r $file $new_file"
                cp -r "$file" "$new_file"
            fi
        elif [ -f "$new_file" ] && [ "$new_file" -ot "$file" ] || [ ! -e "$new_file" ] ; then
            echo -e "\033[0;31mExecuting\033[0m: cp $file $new_file"
            cp "$file" "$new_file"
        else
            echo "$new_file is already updated."
        fi
    done
}

sync "$1" "$2"
