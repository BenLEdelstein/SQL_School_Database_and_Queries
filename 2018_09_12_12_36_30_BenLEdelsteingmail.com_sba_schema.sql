--Author: Benjamin Edelstein--
--Class: ASM05 2018--
--DDL DATABASE SCHEMA--

/*Department Table has 2 fields: id and name*/
CREATE TABLE department(
    id NUMBER PRIMARY KEY, --id is unique and not-null (oracle uses 'number' for int)
    name VARCHAR2(30) NOT NULL --full name cannot be null
);

/*Faculty Table has 4 fields: id, firstname, lastname 
and foreign key deptId reference to id field in department table*/
CREATE TABLE faculty(
    id NUMBER PRIMARY KEY, --id is unique and not-null (oracle uses 'number' for int)
    firstname VARCHAR2(30) NOT NULL, --first name cannot be null
    lastname VARCHAR2(50) NOT NULL, --last name cannot be null
    deptId NUMBER NULL, /*can be null if not assigned to department, 
    foreign key constraint is defined on next line and will satisfy uniqueness*/
    CONSTRAINT f_di_fk FOREIGN KEY (deptId) REFERENCES department(id) --foreign key: deptId refers to existing id in department table
);

/*Student Table has 9 fields: id, firstname, lastname,
street, streetDetail, city, state, postalCode 
and foreign key majorId reference to id field in department table*/
CREATE TABLE student(
    id NUMBER PRIMARY KEY, --id is unique and not-null (oracle uses 'number' for int)
    firstname VARCHAR2(30) NOT NULL, --first name cannot be null
    lastname VARCHAR2(50) NOT NULL, --last name cannot be null
    street VARCHAR2(50) NOT NULL, --street cannot be null
    streetDetail VARCHAR2(30) NULL, --street details can be null
    city VARCHAR2(30) NOT NULL, --city cannot be null
    state VARCHAR2(30) NOT NULL, --state cannot be null
    postalCode CHAR(5) NOT NULL, --postal code cannot be null
    majorId NUMBER NULL, /*can be null if major is undeclared, 
    foreign key constraint is defined on next line and will satisfy uniqueness*/
    CONSTRAINT s_mi_fk FOREIGN KEY (majorId) REFERENCES department(id) --foreign key: majorId refers to  existing id in department table
    /*I decided I would rather use a trigger to enforce this constraint so that I can throw an error message explaining
    CONSTRAINT s_pc_nl CHECK(LENGTH(postalCode)=5 AND TRANSLATE(postalCode, '0123456789', ' ') IS NULL) --constraint checks that postal code is 5 digits and that it is a number*/
);

/*Course Table has 3 fields: id, name and foreign key 
deptId reference to id field in department table*/
CREATE TABLE course(
    id NUMBER PRIMARY KEY, --id is unique and not-null (oracle uses 'number' for int)
    name VARCHAR2(50) NOT NULL, --name cannot be null
    deptId NUMBER NOT NULL, --department cannot be null, a course must be set to a department
    CONSTRAINT c_di_fk FOREIGN KEY (deptId) REFERENCES department(id) --foreign key: deptId refers to  existing id in department table
);

/*Student-Course Table is a 'Junction Table' for many-to-many relationship
between student and course tables. There are 4 fields: studentId, courseId, progress, 
startDate. studentId and courseId reference the id field in the student table and
the id field in the course table, respectively. This table has a composite primary
key constructed of the studentId, courseId and startDate (in case the student repeats
courses)*/
CREATE TABLE studentCourse(
    studentId NUMBER, --studentId is foreign key and primary key, will be unique and not null
    courseId NUMBER, --courseId is foreign key and primary key, will be unique and not null
    progress NUMBER DEFAULT 0, --progress will default to 0 value, if none given
    startDate DATE, --startDate is a primary key, will be unique and not null
    CONSTRAINT sc_si_fk FOREIGN KEY (studentId) REFERENCES student(id), --foreign key: studentId refers to  existing id in student table
    CONSTRAINT sc_ci_fk FOREIGN KEY (courseId) REFERENCES course(id), --foreign key: courseId refers to  existing id in course table
    CONSTRAINT sc_pk PRIMARY KEY (studentId, courseId, startDate) --primary key consists of 3 fields: studentId, courseId and startDate
);

/*Faculty-Course Table is a 'Junction Table' for many-to-many relationship
between faculty and course tables. There are 2 fields: facultyId and courseId
which reference the id in the faculty table and the id in the course table, respectively*/
CREATE TABLE facultyCourse(
    facultyId NUMBER, --facultyId is foreign key and primary key, will be unique and not null
    courseId NUMBER, --courseId is foreign key and primary key, will be unique and not null
    CONSTRAINT fc_fi_fk FOREIGN KEY (facultyId) REFERENCES faculty(id), --foreign key: facultyId refers to  existing id in faculty table
    CONSTRAINT fc_ci_fk FOREIGN KEY (courseId) REFERENCES course(id), --foreign key: courseId refers to  existing id in course table
    CONSTRAINT fc_pk PRIMARY KEY (facultyId, courseId) --primary key constraint sets a compound primary key of facultyId and courseId
);

--DDL TRIGGERS AND SEQUENCES--

/*Postal-Code-Check Trigger checks that the Postal-Code field value is 5 digits,
and is a number. Raises appropriate error.*/
CREATE OR REPLACE TRIGGER postalCodeCheck
BEFORE INSERT OR UPDATE OF postalCode ON student --invoke the trigger before insert or update of postalCode field in student table
FOR EACH ROW --perform trigger function on each row (batch inserts)
BEGIN
    IF (LENGTH(TRIM(' ' FROM :NEW.postalCode))<>5) --if the length of the postalCode field value is not equal to 5
    THEN RAISE_APPLICATION_ERROR(-20019, 'Postal Code must be a 5-DIGIT number!'); --raise an error message
    END IF;
    IF (LENGTH(TRIM(TRANSLATE(TRANSLATE(:NEW.postalCode, ' ', 'x'), '1234567890', ' '))) IS NOT NULL) --if the postalCode field value contains non-numeric characters
    THEN RAISE_APPLICATION_ERROR(-20020, 'Postal Code can only consist of NUMBERS 0-9! No letters, special characters or spaces.'); --raise an error message
    END IF;
END;
/

/*Student-Course-Progress-Check Trigger checks that the progress field value is between 0 and 100,
and is a number. Raises appropriate error.*/
CREATE OR REPLACE TRIGGER studentCourseProgressCheck
BEFORE INSERT OR UPDATE OF progress ON studentCourse --invoke the trigger before insert or update of progress field in studentCourse table
FOR EACH ROW --perform trigger function on each row (batch inserts)
BEGIN
    IF (:NEW.progress NOT BETWEEN 0 AND 100) --if the value of the progress field value is not between 0 and 100
    THEN RAISE_APPLICATION_ERROR(-20018, 'Progress must be within 0 and 100!'); --raise an error message
    END IF;
END;
/

/*Department-Sequence is a counter for the id field in the 
department table generated by the trigger departmentIdGenerator*/
CREATE SEQUENCE departmentSequence INCREMENT BY 1 START WITH 1; --sequence starts with a value of 1 and increments by 1
/

/*Department-Id-Generator generates the numerical value
for the id field in the department table*/
CREATE OR REPLACE TRIGGER departmentIdGenerator
BEFORE INSERT ON department --invoke trigger before insert into department table
FOR EACH ROW --perform trigger function on each row (batch inserts)
BEGIN
    :NEW.id:=departmentSequence.NEXTVAL; --set id field the current value of the sequence and set sequence to next value
END;
/

/*Faculty-Sequence is a counter for the id field in the 
department table generated by the trigger facultyIdGenerator*/
CREATE SEQUENCE facultySequence INCREMENT BY 1 START WITH 1; --sequence starts with a value of 1 and increments by 1
/

/*Faculty-Id-Generator generates the numerical value
for the id field in the faculty table*/
CREATE OR REPLACE TRIGGER facultyIdGenerator
BEFORE INSERT ON faculty --invoke trigger before insert into faculty table
FOR EACH ROW --perform trigger function on each row (batch inserts)
BEGIN
    :NEW.id:=facultySequence.NEXTVAL; --set id field the current value of the sequence and set sequence to next value
END;
/

/*Student-Sequence is a counter for the id field in the 
department table generated by the trigger studentIdGenerator*/
CREATE SEQUENCE studentSequence INCREMENT BY 1 START WITH 1; --sequence starts with a value of 1 and increments by 1
/

/*Student-Id-Generator generates the numerical value
for the id field in the student table*/
CREATE OR REPLACE TRIGGER studentIdGenerator
BEFORE INSERT ON student --invoke trigger before insert into student table
FOR EACH ROW --perform trigger function on each row (batch inserts)
BEGIN
    :NEW.id:=studentSequence.NEXTVAL; --set id field the current value of the sequence and set sequence to next value
END;
/

/*Course-Sequence is a counter for the id field in the 
department table generated by the trigger courseIdGenerator*/
CREATE SEQUENCE courseSequence INCREMENT BY 1 START WITH 1; --sequence starts with a value of 1 and increments by 1
/

/*Course-Id-Generator generates the numerical value
for the id field in the course table*/
CREATE OR REPLACE TRIGGER courseIdGenerator
BEFORE INSERT ON course --invoke trigger before insert into course table
FOR EACH ROW --perform trigger function on each row (batch inserts)
BEGIN
    :NEW.id:=courseSequence.NEXTVAL; --set id field the current value of the sequence and set sequence to next value
END;
/