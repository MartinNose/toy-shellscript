#!/bin/bash
# 本脚本负责作业管理系统的交互

rep () {
    while "$@" 
    do
        true
    done
}

source .env.sh
source controller.sh 


title () {
    clear
    echo -e "\t\t\tHomework Manage System"
    echo
}

source admin.sh
source teacher.sh
source student.sh

welcome () {
    while true
    do
        title
        echo -e "\tWelcome to HWM System, please choose your identity"
        echo
        echo -e "\t\t1. System Admin"
        echo
        echo -e "\t\t2. Teacher"
        echo
        echo -e "\t\t3. Student"
        echo
        echo -e "\t\t4. Quit"
        read -n1 option
        clear
        case $option in
        1)
            rep admin_login ;;
        2)
            rep teacher_login ;;
        3)
            rep student_login ;;
        4)
            break ;;
        esac
    done
}

welcome
