#!/bin/bash

student_login () {
    title
    read -p "Enter your student id:" sid
    read -s -p "Enter your password: " password
    echo
    res=$(mysql hwInfo -u admin -e "SELECT * FROM students WHERE student_id='$sid' and password='$password';" | tail -n1) 
    if [[ ! -z $res ]]; then
        clear
        rep student "$sid"
    else
        read -n1 -p "Wrong student id or password. Press a to abort, enter to try again." option
        if [[ $option = 'a' ]]; then
           return 1 
        fi
    fi
    return 1
}

student () {
    title
    echo -e "\tWelcome, $1. Please specify what do you want to do"
    echo
    echo -e "\t\t1. Check all the home work"
    echo
    echo -e "\t\t2. Submit home work"
    echo
    echo -e "\t\t3. Go back"
    echo
    read -n1 option
    clear
    case $option in
    1)
        rep check_hw ;;
    2)
        rep sub_hw ;;
    3)
        return 1 ;;
    *)
        return 0 ;;
    esac
    return 0 
}
