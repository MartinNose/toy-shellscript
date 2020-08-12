#!/bin/bash

manual_enroll () {
    while true; do
        read -p "please input the student id: (q to return) " s_id 
        if [[ "$s_id" == q ]]; then
            return
        fi
        sql "insert into enroll (student_id, class_id) values ('$s_id', '$class_id');" 1>sql.log 2>err.log
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
        sql "insert into enroll (student_id, class_id) values ('$line', '$class_id');" 1>sql.log 2>err.log
        if (($?)); then
            echo "insert failed. please check more information in sql.log and err.log" 
        else
            echo "insert succeeded."
        fi
    done   
}
enroll () {
    read -n1 -p "do you want to manually import?" option
    if [[ "$option" == y ]] || [[ "$option" == y ]]; then
        manual_enroll
        read -n1 -p 'manually enrollment done. press any button to return'
    else
        auto_enroll
        read -n1 -p 'auto enrollment done. press any button to return'
    fi
}

list_course () {
    echo "listing all classes insturcted by you"
    sql "select class_id, teachers.name as teacher_name, t_id,  courses.name as course_name, courses.id as c_id from classes join courses join teachers where classes.c_id = courses.id and t_id = teachers.id and t_id = '$1';"
}

checkclassid () {
    res=$( sql "select * from classes where class_id = '$1';" | tail -n1 )
    if [[ -z "$res" ]]; then
        read -p "Wrong class_id. retry?(y/n)" option
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
    while true; do
        read -p "please input the class id: " class_id
        case $(checkclassid "$class_id") in
        1)
            echo "$class_id" 
            return 0;;
        2)
            return 1;;
        esac 
    done
}

checkstudentid () {
    res=$( sql "select * from students where student_id = '$1';" | tail -n1 )
    if [[ -z "$res" ]]; then
        read -p "Wrong class_id. retry?(y/n)" option
        if [[ "$option" = y ]] || [[ "$option" = Y ]]; then
            echo 0         
        else
            echo 2
        fi
    else
        echo 1
    fi
}

get_student_id () {
    while true; do
        read -p "Please input the id of the student: " s_id
        case $(checkstudentid "$s_id") in
        1)
            echo "$s_id" 
            return 0;;
        2)
            return 1;;
        esac 
    done
}

show_enroll () {
    echo "Current enrollment:"
    sql "select name, student_id from enroll natural join students where class_id = '$1';" 
    if (($?)); then
        echo "no enrollment for this class."
    fi 
}

enroll_list () {
    sql "select student_id from enroll natural join students where class_id = '$1';" | tail -n+2 
}

import_student () {
    echo "importing students to courses..."
    class_id=$( get_class_id )
    if (($?)); then
        return 1
    fi
    show_enroll "$class_id"
    enroll
    return 1
}

alter_student () {
    class_id=$( get_class_id )
    if (($?)); then
        return 1
    fi
    show_enroll "$class_id"
    read -n1 -p "Remove student from your class?" option
    echo
    if [[ ! "$option" = 'y' ]]; then
        return 1;
    fi
    list=($(enroll_list "$class_id"))
    list+=('q')
    select sid in "${list[@]}"; do
        if [[ "$sid" = 'q' ]]; then
           break
        fi 
        echo "Deleteing the student with id: $sid from your class. Are you sure?(y/N)"
        echo
        while true; do
            read -n1 option
            case $option in
            y|Y)
                sql "DELETE FROM enroll WHERE class_id = '$class_id' and student_id = '$sid';" ;;
            n|N)
                break ;; 
            esac
        done
    done
    return 1;
}

manage_course () {
    echo "You can configure your course description here. NOTE: The description will be shared by all the teacher of this course"
    list=($(sql "SELECT c_id FROM classes WHERE t_id = '$1';" | tail -n +2))    
    list+=('exit')
    select c_id in "${list[@]}"; do
        if [[ "$c_id" = exit ]]; then
            return 1;
        fi
        desc=$(sql "SELECT description FROM courses WHERE id = '$c_id';" | tail -n +2)
        if [[ ! -z "$desc" ]]; then
            echo "Current description:"
            echo "$desc"
            echo "Do you want to change?(y/N)"
            while true; do
                read -n1 option
                case $option in
                y|Y)
                    break ;;
                n|N)
                    return 1 ;;
                esac
            done
        fi
        read -p "Please input the course descrition: " desc
        sql "UPDATE courses SET description = '$desc' WHERE id = '$c_id';"
        read -n1 -p "Insert done press any button to go back"
        return 1;
    done
}

add_hw_description () {
    desc=$(sql "SELECT description FROM hw_require WHERE hw_id = '$1';" | tail -n +2)
    if [[ ! -z "$desc" ]]; then
        echo "Current description:"
        echo "$desc"
        echo "Do you want to change?(y/N)"
        while true; do
            read -n1 option
            case $option in
            y|Y)
                break ;;
            n|N)
                return 1 ;;
            esac
        done
    fi
    read -p "Please input the homework descrition: " desc
    sql "UPDATE hw_require SET description = '$desc' WHERE hw_id = '$1';"
    read -n1 -p "Insert done press any button to go back"
    return 1;
}

create_hw () {
    read -p "Please input the homework id: " id
    read -p "Please input the homework description: " desc
    sql "INSERT INTO hw_require (hw_id, class_id, teacher_id, description) values ('$id', '$2', '$1', '$desc');"
}
assign_hw () {
   list=($(sql "SELECT class_id FROM classes WHERE t_id = '$1';" | tail -n +2))    
    list+=('exit')
    select cl_id in "${list[@]}"; do
        if [[ "$cl_id" = exit ]]; then 
            return 1 
        fi
        echo "Listing all the homework of current class." 
        ql "SELECT * FROM hw_require WHERE class_id = '$1';"
        hw_list=($(sql "SELECT hw_id FROM hw_require WHERE class_id = '$cl_id';" | tail -n+2))
        hw_list+=('Assign new homework')
        hw_list+=('exit')
        select hw_id in "${hw_list[@]}"; do
            case $hw_id in
            exit)
                return 1 ;;
            'Assign new homework')
                create_hw "$1" "$cl_id" ;;
            *) 
                add_hw_description $hw_id ;;
            esac
        done
    done
}

process_hw () {
    echo "Listing current homework situation"
    sql "SELECT * FROM hw_submit WHERE submit_id = '$sub_id';"
    list=(print score exit)    
    select option in "${list[@]}"; do
        case $option in
        print)
            cat "$HWPATH$(sql "SELECT hw_path FROM hw_submit WHERE submit_id = '$1';" | tail -n 1)" ;; 
        score)
            read -p "Please input a score: " score
            if [[ "$score" -ge 0 ]] && [[ "$score" -le 100 ]]; then
                sql "UPDATE hw_submit SET score = '$score' WHERE submit_id = '$1';"
            else
                echo "Invalid number."
            fi ;;
        exit)
            break ;;
        esac
    done
}
review_hw_id () {
    echo "Listing all submit of homeword $1"
    sql "SELECT hw_submit.*, name FROM hw_submit natural join students WHERE hw_id = '$1';"
    list=($( sql "SELECT submit_id FROM hw_submit WHERE hw_id = '$1';" | tail -n +2)) 
    list+=('exit')
    select sub_id in "${list[@]}"; do
        if [[ "$sub_id" = exit ]]; then
            return ;
        fi
        process_hw "$sub_id" 
        echo "Listing all submit of homeword $1"
        sql "SELECT hw_submit.*, name FROM hw_submit natural join students WHERE hw_id = '$1';"
    done 
}
review_hw () {
    echo "Listing all the homework you assigned."
    sql "SELECT * FROM hw_require WHERE teacher_id = '$1';"
    list=($(sql "SELECT hw_id FROM hw_require WHERE teacher_id = '$1';" | tail -n+2))
    list+=('exit')
    select hw_id in "${list[@]}"; do
        if [[ "$hw_id" = exit ]]; then
            return 1;
        fi
        review_hw_id "$hw_id"
        title
        echo "Listing all the homework you assigned."
        sql "SELECT * FROM hw_require WHERE teacher_id = '$1';"
    done
}
