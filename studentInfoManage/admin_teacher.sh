teacher_insert () { option
    echo "Creating a new teacher account..."
    read -p "10 Characters id:" id
    read -p "name: " name
    read -p "password: " password 
    mysql hwInfo -u admin -e "INSERT INTO teachers(id, name, password) values ('$id', '$name', '$password');"
    if [[ $? -eq 0 ]]; then
        read -p "Insert complete, press any button to continue" option 
        return 1
    else
        read -n1 -p "Insert failed. Press any button to go back..." option
        return 1
    fi
}

teacher_alter () {
    echo "altering a teacher account ..."
    read -p "teacher's id required" id
    arr=($(mysql hwInfo -u admin -e "select name,password from teachers where id='$id';" | tail -n1))
    name=${arr[0]}
    pswd=${arr[1]}
    if [[ ! -z $name ]]; then
        read -p "Please input the new name(Enter to skip):" new_name
        if [[ ! -z $new_name ]]; then
            name=$new_name
        fi
        while true 
        do
            read -s -p "Please input the new password(Enter to skip):" new_pswd
            if [[ -z $new_pswd ]]; then
                break
            else
                read -s -p "Please input the password again:" sec_pswd
                if [[ "$new_pswd" -eq "$sec_pswd" ]]; then
                    pswd="$new_pswd"
                    break
                fi
            fi
        done
        mysql hwInfo -u admin -e "UPDATE teachers SET name = '$name', password = '$pswd' WHERE id = '$id';"
        if [[ $? -eq 0 ]]; then
            echo
            read -n1 -p "Alter succeeded! Press any button to continue." option
            return 1 
        else
            echo "Failed"
            return 0
        fi
    else
        read -n1 -p "Wrong id. Try again?(y/N)" option
        case $option in
        n|N)
            return 1 ;;
        y|Y)
            return 0 ;;
        esac
    fi
}

teacher_delete () {
    echo -e "\tDeleting a teacher account ..."
    echo
    read -p "teacher's id required: " id
    name=$(mysql hwInfo -u admin -e "select name from teachers where id='$id';" | tail -n1)
    if [[ ! -z $name ]]; then
        echo "Deleting $name's account"
        mysql hwInfo -u admin -e "delete from teachers where id='$id';"
        if [[ $? -eq 0 ]]; then
            read -n1 -p "Delete success. Press any button to go back..." option
            return 1
        else
            read -n1 -p "Delete failed. Try again?(y/n)" option
        fi
    else
        read -n1 -p "Wrong id. Try again?(y/n)" option
    fi
        case $option in
        y|Y)
            return 0 ;;
        n|N)
            echo
            read -n1 -p "Press any button to go back..." option
            return 1 ;;
        esac
}

teacher_list () {
    echo "Listing all teachers information..."
    mysql hwInfo -u admin -e "SELECT * FROM teachers;"
    read -n1 -p "Press any button to return" option
    return 1
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
        rep teacher_insert ;;
    2)
        rep teacher_alter ;;
    3)
        rep teacher_delete ;;
    4)
        rep teacher_list ;;
    5)
        return 1 ;; 
    esac
    return 0
} 
