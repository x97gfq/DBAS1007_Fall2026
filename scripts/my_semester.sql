-- DBAS 1007 - Week 3 Activity: Your First Database
-- Connect in Workbench: Host 127.0.0.1  Port 13306  User root  Password rootpassword

-- Start fresh: remove the database if it's already there
DROP DATABASE IF EXISTS my_semester;

-- Create a database for your semester
CREATE DATABASE my_semester;

-- Use it, so MySQL knows where to work
USE my_semester;

-- Define a course table
CREATE TABLE course (
    course_id   INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(10)  NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    instructor  VARCHAR(50)
);

-- Insert DBAS 1007
INSERT INTO course
    (course_code, course_name, instructor)
VALUES
    ('DBAS 1007', 'Data Fundamentals', 'Jamie Symonds');

-- now add 2 or more of your own courses

-- Check with SELECT, then refresh Schemas
SELECT * FROM course;