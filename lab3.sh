#!/bin/bash

# 实现备份功能目标目录, 新文件和新子目录进行升级，源目录将保持不变      
bakcup () {
    echo "Calling backup(): From directory $1 to $2"
 
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
                backup "$file" "$new_file"
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

# 实现同步功能，两个方向上的旧文件都将被最新文件替换，最新文件双向复制。
sync () {	
    if [ ! -e "$1"/last_sync_tag ]; then
        touch "$1"/last_sync_tag
        cp -p "$1"/last_sync_tag "$2"/last_sync_tag 
    fi

    for file in "$2"/*
    do
        twin_file="$1${file/$2/}"
        echo "Checking $twin_file..."
        if [ -e "$twin_file" ]; then
            if [ -d "$file" ] ; then # TODO: check if -R is set
                sync "$twin_file" "$file" 
            elif [ "$file" -nt "$twin_file" ]; then
                cp -p "$file" "$twin_file"
            else
                cp -p "$twin_file" "$file"
            fi
        elif [ "$file" -nt "$2/last_sync_tag" ]; then
            echo -e "\033[0;31mExecuting\033[0m: cp -r $file $twin_file"
            cp -r "$file" "$twin_file" 
        else
            echo "deleting $file"    
            rm -rf "$file"
        fi
    done

    touch "$1/last_sync_tag"
    cp -fp "$1/last_sync_tag" "$2/last_sync_tag"
}

if [ "$1" = "-b" ]; then
    backup "$2" "$3"
elif [ "$2" = "-s" ]; then
    sync "$2" "$3"
else
    backup "$1" "$2"
fi
