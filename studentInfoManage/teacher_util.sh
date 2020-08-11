#!/bin/bash

manual_enroll () {
    while true; do
        read -p "please input the student id: (q to return) " s_id 
        if [[ "$s_id" == q ]]; then
            return
        fi
        mysql hwInfo -v -u admin -e "insert into enroll (student_id, class_id) values ('$s_id', '$class_id');" 1>sql.log 2>err.log
        if (($?)); then
            echo "insert failed. please check more information in sql.log and err.log" 
        else
            echo "insert succeeded."
        fi
    done
}

auto_enroll () {
    read -p "please input the file path" path 
    cat "$path" | while read line; do
        echo "inserting student with id $line"
        mysql hwInfo -v -u admin -e "insert into enroll (student_id, class_id) values ('$line', '$class_id');" 1>sql.log 2>err.log
        if (($?)); then
            echo "insert failed. please check more information in sql.log and err.log" 
        else
            echo "insert succeeded."
        fi
    done   
}
enroll () {
    read -p "do you want to manually import?" option
    if [[ "$option" == y ]] || [[ "$option" == y ]]; then
        manual_enroll
        read -n1 -p 'manually enrollment done. press any button to return'
    else
        auto_enroll
        read -n1 -p 'auto enrollment done. press any button to return'
    fi
}

list_course () {
    echo "listing all classes insturcted by you..."
    mysql hwInfo -u admin -e "select class_id, teachers.name as teacher_name, t_id,  courses.name as course_name, courses.id as c_id from classes join courses join teachers where classes.c_id = courses.id and t_id = teachers.id and t_id = '$1';"
}

checkclassid () {
    mysql hwInfo -u admin -e "select * from classes where class_id = '$1';" 1>/dev/null
    if (($?)); then
        read -p "wrong class_id. retry?(y/n)" option
        if [[ "$option" = y ]] || [[ "$option" = Y ]]; then
            echo 0         
        else
            echo 2
        fi
    else
        echo 1
    fi
}

get_class_id () {
    read -p "please input the class id: " class_id
    while true; do
        case $(checkclassid "$class_id") in
        1)
            echo "$class_id" 
            return 0;;
        2)
            return 1;;
        esac 
    done
}

import_student () {
    teacher_id="$1"
    echo "importing students to courses..."
    list_course "$teacher_id"
    class_id=$( get_class_id )
    if (($?)); then
        return 1
    fi
    echo "Current enrollment:"
    mysql hwInfo -u admin -e "select name, student_id from enroll natural join students where class_id = '$class_id';" 
    if [[ -z "$res" ]]; then
        echo "no enrollment for this class."
    fi 
    enroll
    return 1
}

alter_student () {
    list_course "$1" 
}

manage_course () {
    true
}

assign_hw () {
}

review_hw () {
}
