#!/bin/bash
# 本脚本负责作业管理系统的交互

source .env.sh
source controller.sh 

title () {
    OLUMNS=$(tput cols) 
    text="Homework Manage System" 
    printf "%*s\n" $(((${#text}+$COLUMNS)/2)) "$text"
}

admin_login () {
    read -p "Enter your username:" username
    read -s -p "Enter your password: " password
    PSWD=$(mysql hwInfo -u admin -e "SELECT password FROM admins WHERE name='$username'" | tail -n1) 
    if [[ "$PSWD" == "$password" ]]; then
        echo -e "\tLogin successfully!"
        admin "$username"
    else
        read -n1 -p "Wrong username or password. Press q to quit" option
        if [[ option = 'q' ]]; then
            exit
        fi
        admin_login
    fi
}
admin () {
    clear
    echo -e "\t\t\tHomework Manage System"
    echo
    echo -e "\tWelcome, $1. Please specify what do you want to do"
    echo
    echo -e "\t\t1. System Admin"
    echo
    echo -e "\t\t2. Teacher"
    echo
    echo -e "\t\t3. Student"
    echo
    read -n1 option
    clear
    echo -n "You chose "
    case $option in
    1)
        # Admin part
        admin
    2)
        # echo "Teacher!";;
        teacher
    3)
        # echo "Student!";;
        student
    *)
        echo "Wrong Option, please choose again!";;
    esac
}
welcome () {
    clear
    echo -e "\t\t\tHomework Manage System"
    echo
    echo -e "\tWelcome to HWM System, please choose your identity"
    echo
    echo -e "\t\t1. System Admin"
    echo
    echo -e "\t\t2. Teacher"
    echo
    echo -e "\t\t3. Student"
    echo
    read -n1 option
    clear
    echo -n "You chose "
    case $option in
    1)
        # Admin part
        admin
    2)
        # echo "Teacher!";;
        teacher
    3)
        # echo "Student!";;
        student
    *)
        echo "Wrong Option, please choose again!";;
    esac
}

welcome
