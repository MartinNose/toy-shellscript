use hwInfo

create table admins (
    id int not null auto_increment,
    name varchar(10),
    password varchar(20),
    primary key (id));

create table teachers (
    id char(10),
    name varchar(20),
    passward varchar(20),
    primary key (id));

create table courses (
    id char(10),
    name varchar(20),
    description varchar(200),
    primary key (id));

create table classes (
    class_id char(10),
    t_id char(10),
    c_id char(10),
    foreign key (t_id) references teachers(id),
    foreign key (c_id) references courses(id),
    primary key (class_id));

create table students (
    student_id char(10),
    name varchar(20),
    password varchar(20),
    primary key (student_id));

create table homework_require (
    hw_id char(10),
    class_id char(10),
    teacher_id char(10),
    description char(200),
    foreign key (class_id) references classes(class_id),
    foreign key (teacher_id) references teachers(id),
    primary key (hw_id));

create table homework_submit (
    submit_id int not null auto_increment,
    hw_id char(10),
    student_id char(10),
    score int,
    foreign key (hw_id) references homework_require(hw_id),
    foreign key (student_id) references students(student_id),
    primary key (submit_id));
