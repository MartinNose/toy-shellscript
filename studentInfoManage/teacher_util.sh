#!/bin/bash


manual_enroll () {
    while true; do
        read -p "please input the student id: (q to return) " s_id 
        if [[ "$s_id" == q ]]; then
            return
        fi
        mysql hwinfo -v -u admin -e "insert into enroll (student_id, class_id) values ('$s_id', '$class_id');" 1>sql.log 2>err.log
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
        mysql hwinfo -v -u admin -e "insert into enroll (student_id, class_id) values ('$line', '$class_id');" 1>sql.log 2>err.log
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
    mysql hwinfo -u admin -e "select class_id, teachers.name as teacher_name, t_id,  courses.name as course_name, courses.id as c_id from classes join courses join teachers where classes.c_id = courses.id and t_id = teachers.id and t_id = '$1';"
}

checkclassid () {
    read -p "please input the class id: " class_id
    probe=$( mysql hwinfo -u admin -e "select * from classes where class_id = '$class_id';" | tail -n1 )
    if [[ -z "$probe" ]]; then
        read -p "wrong class_id. retry?(y/n)" option
        if [[ $( yescheck "$option" ) -eq 0 ]]; then
            return 0         
        else
            return 2
        fi
    else
        return 1
    fi
}

get_class_id () {
    class_id=0
    while true; do
        case $(checkclassid) in
            1)
                echo "$class_id"
                break ;; # continue
            2)
                return 1 ;; # go back to last menu      
        esac
    done
}

import_student () {
    teacher_id="$1"
    echo "importing students to courses..."
    list_course "$teacher_id"
    class_id=$( get_class_id )
    res=$( mysql hwinfo -u admin -e "select * from enroll where class_id = '$class_id';" | tail -n +1 )
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
}

assign_hw () {
}

review_hw () {
}
