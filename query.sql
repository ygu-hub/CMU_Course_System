create database if not exists CMU_Course_System;
use CMU_Course_System;

# drop tables with dependencies to other table
drop table if exists student_to_person, students_level, students_major_or_minor,
    class, section_in_class, tuition, waitlist, enrollment, course_name_match, works_for,
    students_attendance, students_gpa_per_quarter, Meeting_or_Review_in_section, prerequisite,
    financial_aid, degree_department_level, degree_category_concentration_requirements,
    courses_in_requirements, thesis_committee;
# drop tables with no dependency to other table
drop table if exists person, student, faculty, degree, department, course, level_of_study, probation;

CREATE TABLE person (
ssn bigint UNIQUE PRIMARY KEY,
first_name varchar(30) NOT NULL,
last_name varchar(30) NOT NULL,
middle_name varchar(30)
);

CREATE TABLE student (
andrew_id varchar(100) PRIMARY KEY,
password varchar(100) NOT NULL,
status int NOT NULL,    # 0: locked 1: unlocked
residency_status int NOT NULL,   # 0: Full time 1：Part time
advisor_name varchar(100)
);

INSERT INTO student (andrew_id, password, status, residency_status, advisor_name)
VALUES
    ('andrew123', 'password123', 1, 0, 'John Doe'),
    ('andrew456', 'password456', 1, 1, 'Jane Smith'),
    ('andrew789', 'password789', 0, 0, 'Mike Johnson');


CREATE TABLE student_to_person (
andrew_id varchar(100) REFERENCES student(andrew_id),
ssn bigint REFERENCES person(ssn),
CONSTRAINT student_to_person_pkey PRIMARY KEY (andrew_id, ssn)
);

CREATE TABLE students_attendance (
andrew_id varchar(100) REFERENCES student(andrew_id),
attend_year int,
attend_semester varchar(30),
end_attend_year int,
end_attend_semester varchar(30),
CONSTRAINT students_attendance_pkey PRIMARY KEY (andrew_id, attend_year, attend_semester, end_attend_year, end_attend_semester)
);

CREATE TABLE students_gpa_per_quarter (
andrew_id varchar(100) REFERENCES student(andrew_id),
gpa_year integer,
gpa_semester varchar(30),
total_gradepoints double precision NOT NULL,
total_units double precision NOT NULL,
CONSTRAINT students_gpa_per_quarter_pkey PRIMARY KEY (andrew_id, gpa_year, gpa_semester)
);

CREATE TABLE financial_aid (
andrew_id varchar(100) REFERENCES student(andrew_id),
aid_quarter varchar(30),
aid_year int,
name_of_grant varchar(255),
amount double precision NOT NULL,
CONSTRAINT financial_aid_pkey PRIMARY KEY (andrew_id, aid_quarter, aid_year, name_of_grant)
);

CREATE TABLE tuition (
andrew_id varchar(100) REFERENCES student(andrew_id),
tuition_quarter varchar(30),
tuition_year int,
amount double precision NOT NULL,
due_date date NOT NULL,
CONSTRAINT tuition_pkey PRIMARY KEY (andrew_id, tuition_quarter, tuition_year)
);

# phd/ms students only
CREATE TABLE thesis_committee (
andrew_id varchar(100) REFERENCES student(andrew_id),
faculty_name varchar(100) REFERENCES faculty(faculty_name),
CONSTRAINT thesis_committee_pkey PRIMARY KEY (andrew_id, faculty_name)
);

CREATE TABLE faculty (
faculty_name varchar(100) PRIMARY KEY,
title varchar(100) NOT NULL
);

# what department the faculty belongs to
CREATE TABLE works_for (
faculty_name varchar(100) REFERENCES faculty(faculty_name),
department_name varchar(100) REFERENCES department(department_name),
CONSTRAINT works_for_pkey PRIMARY KEY (faculty_name, department_name)
);

CREATE TABLE department (
department_name varchar(100) PRIMARY KEY
);

CREATE TABLE students_major_or_minor (
andrew_id varchar(100) REFERENCES student(andrew_id),
department_name varchar(100) REFERENCES department(department_name),
major_or_minor int NOT NULL, # major = 0, minor = 1
CONSTRAINT students_major_or_minor_pkey PRIMARY KEY (andrew_id, department_name)
);

# probation
CREATE TABLE probation (
andrew_id varchar(100) REFERENCES student(andrew_id),
start_year int,
end_year int,
start_semester varchar(30), # spr / fall / summer
end_semester varchar(30),   # spr / fall / summer
CONSTRAINT probation_pkey PRIMARY KEY (andrew_id, start_year, end_year, start_semester, end_semester)
);

# level of study
CREATE TABLE level_of_study (
level_name int PRIMARY KEY  # 1: Undergraduate 2: MS 3: PHD candidate 4: PHD pre-candidacy 5: BS-MS
);

CREATE TABLE students_level (
andrew_id varchar(100) REFERENCES student(andrew_id),
level_name int REFERENCES level_of_study(level_name),
CONSTRAINT students_level_pkey PRIMARY KEY (andrew_id, level_name)
);

CREATE TABLE degree (
degree_name varchar(30) PRIMARY KEY
);

# course available
CREATE TABLE course (
course_name varchar(255) UNIQUE PRIMARY KEY,
grade_options char(1) NOT NULL, # grade option = L / PNP
min_units double precision NOT NULL,
max_units double precision NOT NULL,
lab_options boolean NOT NULL
);

# match each course to an official course name
CREATE TABLE course_name_match (
course_name varchar(255) REFERENCES course(course_name),
department_of_major varchar(100) REFERENCES department(department_name),
course_number int NOT NULL,
CONSTRAINT course_name_match_pkey PRIMARY KEY (department_of_major, course_number)
);

CREATE TABLE prerequisite (
course_name varchar(255) REFERENCES course(course_name),
required_course_name varchar(255) REFERENCES course(course_name),
CONSTRAINT prerequisite_pkey PRIMARY KEY (course_name, required_course_name)
);


# class offered in different semester
CREATE TABLE class (
course_name varchar(255) REFERENCES course(course_name),
year int,
semester varchar(30),
title varchar(100) NOT NULL,
discussion_option boolean NOT NULL, # 0: has discussion 1: no discussion
CONSTRAINT class_pkey PRIMARY KEY (course_name, year, semester)
);

CREATE TABLE section_in_class (
section_id bigint PRIMARY KEY AUTO_INCREMENT,
course_name varchar(255),
year int,
semester varchar(30),
section_num int,
faculty_name varchar(100) REFERENCES faculty(faculty_name),
CONSTRAINT `section_course_name_year_semester_fkey` FOREIGN KEY (course_name, year, semester) REFERENCES class(course_name, year, semester),
CONSTRAINT unique_section_num UNIQUE (course_name, year, semester, section_num, faculty_name)
);

CREATE TABLE Meeting_or_Review_in_section(
section_id int REFERENCES section_in_class(section_id),
Type int NOT NULL,  # 0: recitation 1: review session
Day_of_week int,
Date date,
Time time,
Room varchar(30),
PRIMARY KEY(section_id, Type, Day_of_week)
);


# Student's enrollment and waitlist
CREATE TABLE enrollment (
section_id bigint REFERENCES section_in_class(section_id),
andrew_id varchar(100) REFERENCES student(andrew_id)
);

CREATE TABLE waitlist (
section_id integer REFERENCES section_in_class(section_id),
andrew_id varchar(100) REFERENCES student(andrew_id)
);

# degree related
CREATE TABLE degree_department_level (
degree_name varchar(30) REFERENCES degree(degree_name),
department_of_major varchar(100) REFERENCES department(department_name),
level_of_study int REFERENCES level_of_study(level_name),
CONSTRAINT degree_department_level_pkey PRIMARY KEY (degree_name, department_of_major, level_of_study)
);

CREATE TABLE degree_category_concentration_requirements (
degree_name varchar(30) REFERENCES degree(degree_name),
course_category_name varchar(100),
min_gpa double precision NOT NULL,
min_credits double precision NOT NULL,
CONSTRAINT category_concentration_requirements_pkey PRIMARY KEY (degree_name, course_category_name)
);

CREATE TABLE courses_in_requirements (
course_name varchar(255) REFERENCES course(course_name),
course_category_name varchar(100),
degree_name varchar(30),
min_gpa double precision NOT NULL,
min_credits double precision NOT NULL,
CONSTRAINT courses_in_requirements_degree_name_course_category_name_fkey FOREIGN KEY (degree_name, course_category_name) REFERENCES degree_category_concentration_requirements(degree_name, course_category_name),
CONSTRAINT courses_in_requirements_pkey PRIMARY KEY (degree_name, course_category_name, course_name)
);

show tables;