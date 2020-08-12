#!/bin/bash
show_hw () {
    echo "Listing all homework you are assigned..."
    sql "SELECT courses.name as course, courses.id AS course_id, teachers.name AS teacher_name, hw_id FROM students NATURAL JOIN enroll NATURAL JOIN hw_require NATURAL JOIN classes JOIN courses JOIN teachers WHERE teachers.id = classes.t_id AND courses.id = classes.c_id AND student_id = '$1';"
}

check_hw () {
    student_id="$1"
    show_hw "$student_id"
    list=($(sql "SELECT hw_id FROM students NATURAL JOIN enroll NATURAL JOIN hw_require NATURAL JOIN classes JOIN courses JOIN teachers WHERE teachers.id = classes.t_id AND courses.id = classes.c_id AND student_id = '$student_id';" | tail -n +2))
    list+=(exit)
    select hw_id in "${list[@]}"
    do
        if [[ "$hw_id" = exit ]]; then
            return 1
        fi
        echo "Listing the home work information"
        sql "SELECT hw_id, submit_id, score, hw_path FROM hw_submit WHERE hw_id = '$hw_id' AND student_id = '$student_id';"  
    done
}

get_path () {
    echo "$HWPATH/$1.hw"
}

submit_hw () {
    student_id="$1"
    hw_id="$2"
    while true; do
        read path
        if [[ -f "$path" ]]; then
            echo "Submitting..."
            cp "$path" "$(get_path $hw_id)"
            break
        else
            echo "Invalid path. Try again?"        
            read -n1 op
            if [[ ! "$op" = y ]] && [[ ! "$op" = Y ]]; then
                break
            fi
        fi
    done
}
sub_hw () {
    student_id="$1"
    show_hw "$student_id"
    list=($(sql "SELECT hw_id FROM students NATURAL JOIN enroll NATURAL JOIN hw_require NATURAL JOIN classes JOIN courses JOIN teachers WHERE teachers.id = classes.t_id AND courses.id = classes.c_id AND student_id = '$student_id';" | tail -n +2))
    list+=(exit)
    select hw_id in "${list[@]}"
    do
        if [[ "$hw_id" = exit ]]; then
            return 1
        fi
        echo "Listing the home work information"
        sql "SELECT hw_id, submit_id, score, hw_path FROM hw_submit WHERE hw_id = '$hw_id' AND student_id = '$student_id';"  
        hw_path=$(get_path $hw_id)
        if [[ ! -f "$hw_path" ]]; then
            echo "No earlier submission. Please input the path of your homework"
            submit_hw "$student_id" "$hw_id" 
        else
            echo "You have submit this homework before. Printing..."
            echo "Submited at $(date -r "$hw_path" '+%Y-%m-%d %H:%M:%S')" 
            echo "-----------------------------------------------------------------------"
            echo
            cat "$hw_path"
            echo
            echo "-----------------------------------------------------------------------"
            echo "Do you want to resubmit?(y/N)"
            read -n1 op
            if [[ "$op" = y ]] || [[ "$op" = Y ]]; then
                echo "Please input the path of your homework"
                submit_hw "$student_id" "$hw_id" 
            fi
        fi 
    done
}
