-- Create the database
CREATE DATABASE student_db;

-- Create a new user
CREATE USER 'student_user'@'%' IDENTIFIED BY 'password';

-- Grant permissions to the user on the database
GRANT ALL PRIVILEGES ON student_db.* TO 'student_user'@'%';

-- Use the database
USE student_db;

-- Create the Student table
CREATE TABLE Student (
    student_id INT AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name  VARCHAR(50),
    PRIMARY KEY (student_id)
);

-- Create the Course table
CREATE TABLE Course (
    course_id   INT AUTO_INCREMENT,
    course_name VARCHAR(100),
    PRIMARY KEY (course_id)
);

-- Create the StudentCourse table to join Student and Course (many-to-many)
CREATE TABLE StudentCourse (
    student_id INT,
    course_id  INT,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (course_id)  REFERENCES Course(course_id)
);

SHOW tables;

/*
This script sets up the `student_db` database, creates a user with permissions,
and defines the `Student`, `Course`, and `StudentCourse` tables with
appropriate primary and foreign keys.
*/
