CREATE USER 'admin'@'localhost' IDENTIFIED BY 'Qwerty12345,';

GRANT ALL PRIVILEGES ON hwInfo.* TO 'admin'@'localhost';


CREATE USER 'teacher'@'localhost' IDENTIFIED BY 'Qwerty12345,';

GRANT ALL PRIVILEGES ON hwInfo.students TO 'teacher'@'localhost';

GRANT ALL PRIVILEGES ON hwInfo.homework_require TO 'teacher'@'localhost';

GRANT SELECT ON hwInfo.homework_submit TO 'teacher'@'localhost';


CREATE USER 'student'@'localhost' IDENTIFIED BY 'Qwerty12345,';

GRANT INSERT ON hwInfo.homework_submit TO 'teacher'@'localhost';
