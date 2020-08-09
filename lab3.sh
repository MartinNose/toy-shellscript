#!/bin/bash

# 实现备份功能目标目录, 新文件和新子目录进行升级，源目录将保持不变      
bakcup () {
    echo "Calling backup(): From directory $1 to $2"
 
    if [ ! -e "$1"/last_sync_tag ]; then # 检查时间戳文件是否存在，若无则新建，并更新目标目录中的时间戳
        touch "$1"/last_sync_tag
        cp -p "$1"/last_sync_tag "$2"/last_sync_tag 
    fi

    if [ ! "$(ls -A "$1")" ]; then
        echo "Dir: $1 is empty."
        exit 0
    fi 

    for file in "$1"/*
    do
        new_file="$2/$(basename file)}"
        echo "Checking $new_file..."
        if [ -d "$file" ]; then # 如果是目录，则进行递归调用
            if [ -e "$new_file" ]; then
                backup "$file" "$new_file"
            else
                echo -e "\033[0;31mExecuting\033[0m: cp -r $file $new_file" # 当目录二中不存在该目录时先进行创建
                cp -r "$file" "$new_file"
            fi
        elif [ -f "$new_file" ] && [ "$new_file" -ot "$file" ] || [ ! -e "$new_file" ] ; then # 若不是目录文件且目录二中文件较老或目录二中不存在某文件，则对其进行复制
            echo -e "\033[0;31mExecuting\033[0m: cp $file $new_file"
            cp "$file" "$new_file"
        else
            echo "$new_file is already updated."
        fi
    done

    touch "$1/last_sync_tag" # 更新时间戳
    cp -fp "$1/last_sync_tag" "$2/last_sync_tag"
}

# 实现同步功能，两个方向上的旧文件都将被最新文件替换，最新文件双向复制。
# 同时接受两个参数，第一个是源目录，第二是目标目录
sync () {	
    if [ ! -e "$1"/last_sync_tag ]; then # 检查时间戳文件是否存在，若无则新建，并更新目标目录中的时间戳
        touch "$1"/last_sync_tag
        cp -p "$1"/last_sync_tag "$2"/last_sync_tag 
    fi

    for file in "$2"/*
    do
        twin_file="$1/$(basename file)}" # 得到目录一中的文件路径
        echo "Checking $twin_file..."
        if [ -e "$twin_file" ]; then # 若目录一中文件存在，若是目录则进行递归调用
            if [ -d "$file" ] ; then
                sync "$twin_file" "$file" 
            elif [ "$file" -nt "$twin_file" ]; then # 若目录二中文件更新，则替换目标一中文件，反之亦然
                cp -p "$file" "$twin_file"
            else
                cp -p "$twin_file" "$file"
            fi
        elif [ "$file" -nt "$2/last_sync_tag" ]; then # 若目录一中文件不存在，且目录二中文件晚于同步时间戳，说明是新文件，拷贝至目录一
            echo -e "\033[0;31mExecuting\033[0m: cp -r $file $twin_file"
            cp -r "$file" "$twin_file" 
        else # 该文件早于同步时间戳，说明该文件已经在目录一中被删除
            echo "deleting $file"    
            rm -rf "$file"
        fi
    done

    for file in "$1"/* # 检查文件夹一中创建时间晚于时间戳且在文件夹二中不存在的文件
    do
        probe="$1/$(basename file)"
        if [ "$file" -nt "$1/last_sync_tag" ] && [ ! -e "$probe" ]; then
            cp -p "$file" "$probe"
        fi
    done

    touch "$1/last_sync_tag" # 更新时间戳
    cp -fp "$1/last_sync_tag" "$2/last_sync_tag"
}

if [ "$1" = "-b" ]; then
    backup "$2" "$3"
elif [ "$2" = "-s" ]; then
    sync "$2" "$3"
else
    backup "$1" "$2"
fi
