#!/bin/bash

# 判断输入是否存在以及是否是目录
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

fcnt=0  # 普通文件数量
xcnt=0  # 可执行文件数量
dcnt=0  # 目录文件数量
ccnt=0  # 普通文件字节数

# 遍历输入目录下所有文件
for file in "$1"/*
do
    if [ -r "$file" ] # 判断是否可读
    then
        if [ -d "$file" ]       # 如果是目录，目录文件计数加一
        then
            dcnt=$((dcnt + 1))
        elif [ -x "$file" ]     # 如果是可执行文件，相关计数加一
        then 
            xcnt=$((xcnt + 1))
        elif [ -f "$file" ]     # 如果是普通文件，则文件计数加一，统计文件字符数并累加入相关变量
        then
            fcnt=$((fcnt + 1))
            tmp=$(wc -c < "$file")
            ccnt=$((ccnt + tmp))
       fi
    else
        echo "$file is not readable."
    fi
done   

# 输出结果
echo "There are $fcnt file(s), $dcnt directory(ies) and $xcnt excutable file(s) in directory '$1'."
echo "$ccnt character(s) in total."

exit 0
