#!/bin/bash
admin_login () {
    title
    read -p "Enter your username:" username
    read -s -p "Enter your password: " password
    echo
    res=$(mysql hwInfo -u admin -e "SELECT * FROM admins WHERE name='$username' and password='$password';" | tail -n1) 
    if [[ ! -z $res ]]; then
        clear
        rep admin "$username"
    else
        read -n1 -p "Wrong username or password. Press a to abort, enter to try again." option
        if [[ $option = 'a' ]]; then
           return 1 
        fi
    fi
    return 1
}

source ./admin_teacher.sh
source ./admin_course.sh

admin () {
    title
    echo -e "\tWelcome, $1. Please specify what do you want to do"
    echo
    echo -e "\t\t1. Teacher Info"
    echo
    echo -e "\t\t2. Course Info"
    echo
    echo -e "\t\t3. Go back"
    read -n1 option
    clear
    case $option in
    1)
        # Teacher info manage 
        rep teacher ;;
    2)
        # Course info manage
        rep course ;;
    3)
        return 1 ;;   
    *)
        return 0 ;;
    esac
}
