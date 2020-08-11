#!/bin/bash

checkClassID () {
    read -p "Please input the class id you want to import student in: " class_id
    probe=$( mysql hwInfo -u admin -e "SELECT * FROM classes WHERE class_id = '$class_id';" | tail -n1 )
    if [[ -z "$probe" ]]; then
        read -p "Wrong class_id. Retry?(y/N)" option
        if [[ $( yesCheck "$option" ) -eq 0 ]]; then
            return 0         
        else
            return 2
        fi
    else
        return 1
    fi
}

manual_enroll () {
    while true; do
        read -p "Please input the student id: (q to return) " s_id 
        if [[ "$s_id" == q ]]; then
            return
        fi
        mysql hwInfo -v -u admin -e "INSERT INTO enroll (student_id, class_id) values ('$s_id', '$class_id');" 1>sql.log 2>err.log
        if (($?)); then
            echo "Insert failed. Please check more information in sql.log and err.log" 
        else
            echo "Insert succeeded."
        fi
    done
}

auto_enroll () {
    
}
enroll () {
    read -p "Do you want to manually import?" option
    if [[ "$option" == y ]] || [[ "$option" == Y ]]; then
        manual_enroll
        read -p 'Manually enrollment done. Press any button to return'
    else
        auto_enroll
        read -p 'Auto enrollment done. Press any button to return'
    fi
}
import_student () {
    teacher_id="$1"
    echo "Importing students to courses..."
    echo "Listing all classes insturcted by you..."
    mysql hwInfo -u admin -e "SELECT class_id, teachers.name AS teacher_name, t_id,  courses.name AS course_name, courses.id AS c_id FROM classes JOIN courses JOIN teachers WHERE classes.c_id = courses.id AND t_id = teachers.id AND t_id = '$teacher_id';"
    class_id=0
    while true; do
        case $(checkClassID) in
            1)
                break ;; # Continue
            2)
                return 1 ;; # Go back to last menu      
        esac
    done
    read -p "Please input the class id you want to import student in: " class_id
    res=$( mysql hwInfo -u admin -e "SELECT * FROM enroll WHERE class_id = '$class_id';" | tail -n +1 )
    if [[ -z "$res" ]]; then
        echo "No enrollment for this class."
    fi 
    enroll
    return 1
}

alter_student () {
}

manage_course () {
}

assign_hw () {
}

review_hw () {
}
