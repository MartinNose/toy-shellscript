#!/bin/bash

teacher_login () {
    title
    read -p "Enter your username:" username
    read -s -p "Enter your password: " password
    echo
    res=$(mysql hwInfo -u admin -e "SELECT * FROM teacherj WHERE name='$username' and password='$password';" | tail -n1) 
    if [[ ! -z $res ]]; then
        clear
        rep teacher "$username"
    else
        read -n1 -p "Wrong username or password. Press a to abort, enter to try again." option
        if [[ $option = 'a' ]]; then
           return 1 
        fi
    fi
    return 1
}



teacher () {
    title
    echo -e "\tWelcome, $1. Please specify what do you want to do"
    echo
    echo -e "\t\t1. Import student to course"
    echo
    echo -e "\t\t2. Manage student info in one course"
    echo
    echo -e "\t\t3. Manage course info"
    echo
    echo -e "\t\t4. Assign homework"
    echo
    echo -e "\t\t5. Review homework"
    echo
    echo -e "\t\t6. Go back"
    read -n1 option
    clear
    case $option in
    1)
        rep import_student ;;
    2)
        rep alter_student ;;
    3)
        rep manage_course ;;
    4)
        rep assign_hw ;;
    5)
        rep review_hw ;;
    6)
        return 1 ;;
    *)
        return 0 ;;
    esac
    return 0 
}
