#!/bin/bash
# 本脚本负责作业管理系统的交互

source .env.sh
source controller.sh 

title () {
    clear
    echo -e "\t\t\tHomework Manage System"
    echo
}

admin_login () {
    title
    read -p "Enter your username:" username
    read -s -p "Enter your password: " password
    echo
    PSWD=$(mysql hwInfo -u admin -e "SELECT password FROM admins WHERE name='$username'" | tail -n1) 
    if [[ "$PSWD" == "$password" ]]; then
        clear
        admin "$username"
    else
        read -n1 -p "Wrong username or password. Press q to quit" option
        if [[ $option = 'q' ]]; then
            exit
        fi
        admin_login
    fi
}

teacher_insert () {
    echo "Creating a new teacher account..."
    read -p "10 Characters id:" id
    read -p "name: " name
    read -p "password: " password 
    mysql hwInfo -u admin -e "INSERT INTO teachers(id, name, password) values ('$id', '$name', '$password');"
    if [[ $? -eq 0 ]]; then
        read -p "Insert complete, press any button to continue" option 
    else
        echo "Insert failed. Back to last menu..."
        sleep 2
    fi
}

teacher_alter () {
    echo "altering a teacher account ..."
    read -p "teacher's id required" id
    name=$(mysql hwinfo -u admin -e "select name from teachers where id='$id';" | tail -n1)
    if [[ ! -z $name ]]; then
        teacher_alter
    else
        read -n1 -p "Wrong id. Try again?(y/N)" option
        case $option in
        n|N)
            return;;
        y|Y)
            teacher_alter ;;
        esac
    fi
}

teacher_delete () {
    echo -e "\tDeleting a teacher account ..."
    echo
    read -p "teacher's id required" id
    name=$(mysql hwInfo -u admin -e "select name from teachers where id='$id';" | tail -n1)
    if [[ ! -z $name ]]; then
        echo "Deleting $name's account"
        mysql hwInfo -u admin -e "delete from teachers where id='$id';"
        if [[ $? -eq 0 ]]; then
            echo -e "\tDelete success. Going back to last menu..."
            sleep 2
            return
        else
            read -n1 -p "\tDelete failed. Try again?(y/n)" option
            case $option in
            y|Y)
                teacher_delete;;
            n|N)
                echo -e "\tDelete success. Going back to last menu..."
                sleep 2
                return ;;
            esac
        fi
    else
        read -n1 -p "\tWrong id. Try again?(y/n)" option
        case $option in
        y|Y)
            teacher_delete;;
        n|N)
            echo -e "\tDelete success. Going back to last menu..."
            sleep 2
            return ;;
        esac
    fi
}

teacher_list () {
    echo "Listing all teachers information..."
    mysql hwInfo -u admin -e "SELECT * FROM teachers;"
}

teacher () {
    title
    echo -e "\tManaging information about teachers. Please specify your requirement"
    echo
    echo -e "\t\t1. Create a teacher account"
    echo
    echo -e "\t\t2. Alter a teacher account"
    echo
    echo -e "\t\t3. Delete a teacher account" 
    echo
    echo -e "\t\t4. List all teacher account" 
    echo
    echo -e "\t\t5. Go back" 
    echo 
    read -n1 -p "Your Choice:" option
    title
    case $option in
    1)
        teacher_insert ;;
    2)
        teacher_alter  ;;
    3)
        teacher_delete ;;
    4)
        teacher_list ;;
    5)
        admin;;
    esac
        teacher
} 

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
        teacher;;
    2)
        # Course info manage
        course;;
    3)
        welcome ;;   
    *)
        admin ;;
    esac
}

welcome () {
    title
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
    case $option in
    1)
        admin_login ;;
    2)
        teacher_login ;;
    3)
        student_login ;;
    *)
        echo "Wrong Option, please choose again!";;
    esac
}

welcome
