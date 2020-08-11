#!/bin/bash

teacher_login () {
    title
    read -p "Enter your id:" id
    read -s -p "Enter your password: " password
    echo
    res=$(mysql hwInfo -u admin -e "SELECT * FROM teachers WHERE id='$id' and password='$password';" | tail -n1) 
    if [[ ! -z $res ]]; then
        clear
        rep teacher "$id"
    else
        read -n1 -p "Wrong id or password. Press a to abort, enter to try again." option
        if [[ $option = 'a' ]]; then
           return 1 
        fi
    fi
    return 1
}

source teacher_util.sh

teacher () {
    title
    list_course $1
    echo -e "Please specify what do you want to do"
    echo
    echo -e "\t1. Import students to course"
    echo
    echo -e "\t2. Remove student from course"
    echo
    echo -e "\t3. Change course description"
    echo
    echo -e "\t4. Assign homework"
    echo
    echo -e "\t5. Review homework"
    echo
    echo -e "\t6. Go back"
    read -n1 option
    clear
    title
    list_course $1
    case $option in
    1)
        rep import_student $1 ;;
    2)
        rep alter_student $1 ;;
    3)
        rep manage_course $1 ;;
    4)
        rep assign_hw $1 ;;
    5)
        rep review_hw $1 ;;
    6)
        return 1 ;;
    *)
        return 0 ;;
    esac
    return 0 
}
