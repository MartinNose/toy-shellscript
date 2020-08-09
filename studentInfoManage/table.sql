create table teachers (
    id char(10),
    name varchar(20),
    passward varchar(20),
    primary key (id));

create table courses (
    id char(10),
    name varchar(20));

create table teaches (
    class_id char(10),
    t_id char(10),
    c_id char(10),
    foreign key (t_id) references teachers(id),
    foreign key (c_id) references courses(id)
    primary key (class_id));


