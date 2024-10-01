Documentation of the university modeling project
Author: Marton Nagy

The schema contains the following tables:
	01. department
	02. program
	03. program_coordinator
	05. course
	06. student
	07. instructor
	08. progr_coord
	09. course_prog
	10. prerequisite
	11. course_student
	12. instructor_course
Tables 08-12. are junction tables, modeling many-to-many relations. The fields of the tables are self-explanatory, so I will not go into details on them.

Below, I explain some of the practical decisions I made during modeling the database concerning the relations between the tables.

department-program (one-to-many): the department ID FK can be null, as I can imagine programs that are outside the normal department structure of the University.

program-program_coordinator (many-to-many, through progr_coord): the relation is many-to-many as one program can have multiple coordinators at the same time, and one program coordinator may coordinate more than one program (see e.g. Dominika Dash at CEU).

program-student (one-to-many): one student can only attend one program at a time. The program ID FK can be null, as some students may not be part of any program (e.g. exchange students).

course-course (many-to-many, through prerequisite): one course can have many prerequisites, thus the junction table is needed.

instructor-department (many-to-one): an instructor can only be part of one department. Some instructors may not be part of any department (e.g. visiting professors), thus the department ID FK can be null.

instructor-course (many-to-many, through instructor_course): one teacher may teach multiple courses (but at least one), and one course may be taught by multiple teachers (but at least one), so a junction table is needed.

course-program (many-to-many, through course_prog): one course may be part of many programs, and similarly, a program has many courses.

course-student (many-to-many, through course_student): one student can have multiple courses, and a course also has multiple students.

