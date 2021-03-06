#!/bin/bash
course_create () {
    echo "Creating a new course..."
    read -p "Please input the course id: " id
    read -p "Please input the course name: " name
    echo
    mysql hwInfo -u admin -e "INSERT INTO courses (id, name) values ('$id', '$name');"
    if [[ $? -eq 0 ]]; then
        read -n1 -p "Insert successfully. Press any button to return." option
        return 1
    else
        read -n1 -p "Insert failed. Retry?(y/n)" option
        case $option in
        y|Y)
            return 0 ;;
        *)
            return 1 ;;
        esac
    fi
}

course_alter () {
    echo "Altering a course infomation..."
    read -p "Please input id of the course: " id
    name=$(mysql hwInfo -u admin -e "SELECT name FROM courses WHERE id = '$id';" | tail -n1)
    if [[ ! -z "$name" ]]; then
        echo "Current couse name is $name"
        read -n1 -p "Do you want to alter?(y/n)" option
        if [[ "$option" == n ]] || [[ "$option" == N ]]; then
            return 1
        fi
        echo
        read -p "Please input new course name" name ;
        mysql hwInfo -u admin -e "UPDATE courses SET name = '$name' WHERE id = '$id';"
        if [[ $? -eq 0 ]]; then
            read -n1 -p "Alter succeeded. Press any button to return" option
            return 1
        else
            read -n1 -p "Operation failed. Retry?(y/N)" option
        fi
    else
        read -n1 -p "Invalid id. Retry?(y/N)" option
    fi

    case $option in
    y|Y)
        return 0 ;;
    *)
        return 1 ;;
    esac
}

course_bind () {
    echo "Binding a course to a teacher"
    read -p "Please specify the course id: " cid
    cname=$(mysql hwInfo -u admin -e "SELECT name FROM courses WHERE id='$cid';" | tail -n1)
    if [[ -z $cname ]]; then
        read -n1 -p "Invalid course id. Retry?(y/n)" option
        ifRetry "$option"
        return $?
    fi
    read -p "Please specify the teacher id: " tid
    tname=$(mysql hwInfo -u admin -e "SELECT name FROM teachers WHERE id='$tid';" | tail -n1)
    if [[ -z $tname ]]; then
        read -n1 -p "Invalid teacher id. Retry?(y/n)" option
        ifRetry "$option"
        return $?
    fi
    read -p "Please specify the class id: " class_id
    mysql hwInfo -u admin -e "INSERT INTO classes(class_id, t_id, c_id) values ('$class_id','$tid','$cid');"
    if [[ $? -eq 0 ]]; then
        read -n1 -p "Bind succeeded. Press any button to continue..."
        return 1;
    else
        read -n1 -p "Bind failed. Retry?(y/N)" option
        ifRetry "$option"
        return $?
    fi
}

course_list () {
    echo "Listing all the classes..."
    mysql hwInfo -u admin -e "SELECT * FROM courses;"
    read -n1 -p "Press any button to continue..." 
    return 1
}

class_list () {
    echo "Listing all the classes..."
    mysql hwInfo -u admin -e "SELECT * FROM classes;"
    read -n1 -p "Press any button to continue..." 
    return 1
} 

course_unbind () {
    echo "Unbinding a class..."
    read -p "Please specify the class id" id
    res=($(mysql hwInfo -u admin -e "SELECT c_id, t_id FROM classes WHERE class_id = '$id';" | tail -n1))
    if [[ -z "$res" ]]; then
        read -n1 -p "Invalid class id. Retry?(y/N)" option
        ifRetry "$option"
        return $?
    fi
    c_id=${res[0]}
    t_id=${res[1]} 
    echo "Unbinding the class with course_id: $c_id and teacher_id: $t_id..."
    isOK
    case $? in
    0)
        mysql hwInfo -u admin -e "DELETE FROM classes WHERE class_id = '$id';" ;;
    1)
        return 1 ;; 
    esac
    if [[ $? -eq 0 ]]; then
        read -n1 -p "DELETE SUCCESS. Press any button to return..." option
        return 1 
    fi
}

course () {
    title
    echo -e "\tManaging information about teachers"
    echo
    echo -e "\t\t1. Create a new course"
    echo -e "\t\t2. Alter a course"
    echo -e "\t\t3. Bind a course to a teacher"
    echo -e "\t\t4. List all the courses"
    echo -e "\t\t5. Unbind a course from a teacher"
    echo -e "\t\t6. List all the classes"
    echo -e "\t\t7. Go back"
    echo
    read -n1 -p "Your choice: " option
    title
    case $option in
    1)
        rep course_create ;;
    2)
        rep course_alter ;;
    3)
        rep course_bind ;;
    4)
        rep course_list ;;
    5)
        rep course_unbind ;;
    6)
        rep class_list ;;
    7)
        return 1 ;;
    esac
    return 0
}
