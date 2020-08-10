course_create () {
    echo "Creating a new course..."
    read -p "Please input the course id: " id
    read -p "Please input the course name: " name
    mysql hwInfo -u admin -e "INSERT INTO courses (id, name) values ('$id', '$name);"
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
    if [[ ! -z res ]]; then
        echo "Current couse name is ${res[1]}"
        read -n1 -p "Do you want to alter?(y/n)" option
        if [[ "$option" == n ]] or [[ "$option" == N ]]; then
            return 1;
        fi
        read -p "Please input new course name" name ;;
        mysql hwInfo -u admin -e "UPDATE courses SET name = '$name' WHERE id = '$id';"
        if [[ $? -eq 0 ]]; then
            read -n1 -p "Alter succeeded. Press any button to return" option
            return 1;
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

ifQuit () {
    case $1 in
    y|Y)
        return 1 ;;
    *)
        return 0 ;;
    esac
}

course_bind () {
    echo "Binding a course to a teacher"
    read -p "Please specify the course id: " cid
    cname=$(mysql hwInfo -u admin -e "SELECT name FROM courses WHERE id='$cid';" | tail -n1)
    if [[ -z $cname ]]; then
        read -n1 -p "Invalid course id. Retry?(y/n)" option
        ifQuit option
        return $?
    fi
    read -p "Please specify the teacher id: " tid
    tname=$(mysql hwInfo -u admin -e "SELECT name FROM teachers WHERE id='$tid';" | tail -n1)
    if [[ -z $tname ]]; then
        read -n1 -p "Invalid teacher id. Retry?(y/n)" option
        ifQuit option
        return $?
    fi
    mysql hwInfo -u admin -e "INSERT INTO teachei:" # TODO INsert
}

course_list () {

}

course_unbind () {

}

course () {
    title
    echo -e "\t\tManaging information about teachers"
    echo
    echo -e "\t\t\t1. Create a new course"
    echo -e "\t\t\t2. Alter a course"
    echo -e "\t\t\t3. Bind a course to a teacher"
    echo -e "\t\t\t4. List all the course"
    echo -e "\t\t\t5. Unbind a course from a teacher"
    echo -e "\t\t\t6. Go back"
    echo
    read -n1 option
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
        return 1 ;;
    esac
}
