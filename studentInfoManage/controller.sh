#!/bin/bash
# 本脚本负责用户输入的处理和对数据接口的调用

yesCheck () {
    case $1 in
    y|Y)
        return 0 ;;
    n|N)
        return 1 ;;
    *)
        return 3 ;;
    esac
}

isOK () {
    op=$1
    while true; do
        read -n1 -p "Are you OK about this?(y/N)" op
        res=$( yesCheck "$op" )
        case $res in
        0)
            return 0 ;;
        1)
            return 1 ;;
        esac
    done
     
}

ifQuit () {
    case $1 in
    y|Y)
        return 1 ;;
    *)
        return 0 ;;
    esac
}
ifRetry () {
    case $1 in
    y|Y)
        return 0 ;;
    *)
        return 1 ;;
    esac
}
