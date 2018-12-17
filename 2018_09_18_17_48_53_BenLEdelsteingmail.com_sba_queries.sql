--Author: Benjamin Edelstein--
--Class: ASM05 2018--
--DQL DATABASE QUERIES--

/*A.	The Curriculum Planning Committee is attempting to fill in gaps in the current course offerings.
        You need to provide them with a query which lists each department and the number of courses offered by that department.  
        The two columns should have headers "Department Name" and "# Courses", and the output should be sorted by "# Courses" in each department (ascending).*/
        
        SELECT d.name "Department Name", COUNT(c.id) "# Courses" --display department name and count of courses by courseId
        FROM course c --get data from course table
        JOIN department d ON (c.deptId=d.id) --join with department table to get a count of courses by department id
        GROUP BY d.id, d.name --aggregate data and group by matching department id and name
        ORDER BY "# Courses" ASC; --sort results by number of courses ascending

/*B.	The recruiting department needs to know which courses are most popular with the students.  
        Please provide them with a query which lists the name of each course and the number of students in that course.  
        The two columns should have headers "Course Name" and "# Students", and the output should be sorted first by 
        # Students descending and then by course name ascending.*/
        
        SELECT c.name "Course Name", COUNT(sc.studentId) "# Students" --display course name, and count of students by studentId
        FROM course c --get data from course table
        JOIN studentCourse sc ON (c.id=sc.courseId) --join with studentCourse table to get studentIds
        GROUP BY c.id, c.name --aggregate data and group by matching course id and name
        ORDER BY "# Students" DESC, "Course Name" ASC; --order first by number of students descending and then by course name ascending

/*C.	Quite a few students have been complaining that the professors are absent from some of their courses.
          1.	Write a query to list the names of all courses where the # of faculty assigned to those courses is zero.  
          The output should be in alphabetical order by course name.
          2.	Using the above, write a query to list the course names and the # of students in those courses for all 
          courses where there are no assigned faculty.  The output should be ordered first by # of students descending 
          and then by course name ascending.*/
    --1--
        SELECT c.name "Course Name"--display course name
        FROM course c --get data from course table
        WHERE 0=(--where the number of faculty assigned to the course (subquery) is equal to 0
        SELECT COUNT(fc.facultyId) --count the number of faculty
        FROM facultyCourse fc --get the data from the faculty course database
        WHERE c.id=fc.courseId)--where the id in course table is matched to courseId in facultyCourse table
        --Note: same results if used a LEFT JOIN and IS NULL in a WHERE clause thanks to the primary key constraint of the facultycourse table--
        ORDER BY "Course Name" ASC; --order by the course name alphabetically
    --2--
        SELECT cfc.name "Course Name", COUNT(sc.studentId) "# of Students" --display course name and # of students
        FROM ( --get data from a subquery
        SELECT * --select entire row
        FROM course c --get data from course table
        WHERE 0=(--where the number of faculty assigned to the course (subquery) is equal to 0
        SELECT COUNT(fc.facultyId) --count the number of faculty
        FROM facultyCourse fc --get the data from the faculty course database
        WHERE c.id=fc.courseId) --where the id in course table is matched to courseId in facultyCourse table
        --Note: same results if used a LEFT JOIN and IS NULL in a WHERE clause thanks to the primary key constraint of the facultycourse table--
        ) cfc --assign alias 'cfc' to subquery results
        JOIN studentCourse sc ON (cfc.id = sc.courseId) --join with studentcourse table to get the studentIds
        GROUP BY cfc.id, cfc.name --aggregate data by course id and course name
        ORDER BY "# of Students" DESC, "Course Name" ASC; --order results by the count of students descending and coursename alphabetically

/*D.	The enrollment team is gathering analytics about student enrollment throughout the years. 
        Write a query that lists the total # of students that were enrolled in classes during each school year.  
        The first column should have the header "Students".  Provide a second "Year" column showing the enrollment year.*/

        SELECT COUNT(DISTINCT studentId) "Students",  Year "Year" --display the total number of students and the year
        FROM ( --get data from subquery
        SELECT 
        TO_CHAR(startDate, 'YYYY') Year, --extract the year from the startdate field
        studentId --select the studentId
        FROM studentCourse --get data from student-course table
        ) 
        GROUP BY Year; --aggregate results by year

/*E.	The enrollemnt team is gathering analytics about student enrollment and they now want to know about August admissions specifically. 
        Write a query that lists the Start Date and # of Students who enrolled in classes in August of each year. 
        Output should be ordered by start date ascending.*/
        
        SELECT startDate "Start Date", COUNT(DISTINCT studentId) "# of Students" --display the date and number of students
        FROM studentCourse --get data from studentCourse table
        WHERE TO_CHAR(startDate, 'MON')='AUG' --select rows where the month is august
        GROUP BY startDate --aggregate results by date
        ORDER BY startDate ASC; --sort results by date

/*F.	Students are required to take 4 courses, and at least two of these courses must be from the department of their major.  
        Write a query to list students' First Name, Last Name, and Number of Courses they are taking in their major department.  
        The output should be sorted first in increasing order of the number of courses, then by student last name.*/

        SELECT s.firstName "First Name", s.lastName "Last Name", COUNT(sc.courseId)"Number of Courses" --display student first and last name and the number of their major courses
        FROM student s --get data from student table
        JOIN studentCourse sc ON (s.id=sc.studentId) --join with student-course table to get courseIds
        JOIN course c ON (sc.courseId=c.id) --join with course table to get deptId from the courses
        WHERE s.majorId=c.deptId --select rows where the students' major id matches the courses' department id
        GROUP BY s.id, s.firstName, s.lastName --aggregate data grouping by student id, first name and last name
        ORDER BY "Number of Courses" ASC, "Last Name" ASC; --sort by increasng number of courses and then by student last name
        
/*G.	Students making average progress in their courses of less than 50% need to be offered tutoring assistance.  
        Write a query to list First Name, Last Name and Average Progress of all students achieving average progress of less than 50%.  
        The average progress as displayed should be rounded to one decimal place.  Sort the output by average progress descending.*/

        SELECT s.firstName "First Name", s.lastName "Last Name", TO_CHAR(ROUND(AVG(sc.progress), 1), '999.9') "Average Progress" --display student first and last name and average progress (rounded to 1 decimal)
        FROM student s --get data from student table
        JOIN studentCourse sc ON (s.id=sc.studentId) --join with studentCourse table to get progress field
        GROUP BY s.id, s.firstName, s.lastName --aggregate data grouping by student id, firstname and lastname
        HAVING AVG(sc.progress)<50 --show only groups where average progress is less than 50
        ORDER BY "Average Progress" DESC; --order results by average progress descending

/*H.	Faculty are awarded bonuses based on the progress made by students in their courses. 
          1.	Write a query to list each Course Name and the Average Progress of students in that course.  
                The output should be sorted descending by average progress.
          2.	Write a query that selects the maximum value of the average progress reported by the previous query.
          3.	Write a query that outputs the faculty First Name, Last Name, and average of the progress 
                ("Avg. Progress") made over all of their courses.
          4.	Write a query just like #3, but where only those faculty where average progress in their courses 
                is 90% or more of the maximum observed in #2.*/

    --1--
        SELECT c.name "Course Name", TO_CHAR(ROUND(AVG(sc.progress),4), '999.9999') "Average Progress" --display course name, and average progress (rounded to 1 decimal place)
        FROM course c --get data from course table
        JOIN studentCourse sc ON (c.id=sc.courseId) --join with studentCourse table to get progress field
        GROUP BY c.id, c.name --aggregate data grouping by course id and name
        ORDER BY "Average Progress" DESC; --sort by average progress descending
    --2--
        SELECT ROUND(MAX(averageProgress),4) "Max Average Progress" --display single max value of average progress
        FROM --get data from subquery
        (SELECT AVG(sc.progress) averageProgress --select course name and average progress
        FROM course c --get data from course table
        JOIN studentCourse sc ON (c.id=sc.courseId) --join with studentcourse table to get progress field
        GROUP BY c.id, c.name); --aggregate data grouping by course id and name
    --3--
        SELECT f.firstName "First Name", f.lastName "Last Name", TO_CHAR(ROUND(AVG(courseAverage),4),'999.9999') "Avg. Progress" --display faculty firstname, lastname and average progress
        FROM ( --select data from subquery
        SELECT c.id id, c.name courseName, AVG(sc.progress) courseAverage --display course name, and average progress (rounded to 1 decimal place)
        FROM course c --get data from course table
        JOIN studentCourse sc ON (c.id=sc.courseId) --join with studentCourse table to get progress field
        GROUP BY c.id, c.name) csc --aggregate data grouping by course id and name and assign alias csc
        JOIN facultyCourse fc ON (csc.id=fc.courseId) --join data to facultyCourse table to get faculty id
        JOIN faculty f ON (f.id = fc.facultyId) --join data to faculty table to get faculty names
        GROUP BY fc.facultyid, f.firstName, f.lastName --aggregate data grouping by faculty id, firstname and lastname
        ORDER BY "Avg. Progress" DESC; --sort results by average progress
    --4--
        SELECT "First Name", "Last Name", TO_CHAR(ROUND(facultyAverageProgress,4), '999.9999') "Avg. Progress" 
        FROM --select data from subquery (from # 3)
        (SELECT f.firstName "First Name", f.lastName "Last Name", AVG(courseAverage) facultyAverageProgress --display faculty firstname, lastname and average progress
        FROM (--select data from subquery
        SELECT c.id id, c.name courseName, AVG(sc.progress) courseAverage --display course name, and average progress (rounded to 1 decimal place)
        FROM course c --get data from course table
        JOIN studentCourse sc ON (c.id=sc.courseId) --join with studentCourse table to get progress field
        GROUP BY c.id, c.name) csc --aggregate data grouping by course id and name and assign alias csc
        JOIN facultyCourse fc ON (csc.id=fc.courseId) --join data to facultyCourse table to get faculty id
        JOIN faculty f ON (f.id = fc.facultyId) --join data to faculty table to get faculty names
        GROUP BY fc.facultyid, f.firstName, f.lastName) --aggregate data grouping by faculty id, firstname and lastname
        WHERE facultyAverageProgress >= 0.9* --return results where average progress is greater than or equal to 90% (0.9) of (*) the max average progress (subquery from #2)
        (SELECT MAX(averageProgress) --display single max value of average progress
        FROM --get data from subquery
        (SELECT AVG(sc.progress) averageProgress --select course name and average progress
        FROM course c --get data from course table
        JOIN studentCourse sc ON (c.id=sc.courseId) --join with studentcourse table to get progress field
        GROUP BY c.id, c.name)) --aggregate data grouping by course id and name)
        ORDER BY "Avg. Progress" DESC; --sort results by average progress

/*I.	Students are awarded two grades based on the minimum and maximum progress they are making in the courses.  The grading scale is as follows:

			Progress < 40:		F
			Progress < 50:		D
			Progress < 60:		C
			Progress < 70:		B
			Progress >= 70:	    A

        Write a query which displays each student's First Name, Last Name, Min Grade based on minimum progress, and Max Grade based on maximum progress.*/
    
        SELECT s.firstName "First Name", s.lastName "Last Name", --display student firstname, lastname, min and max grades (case that follows)
        CASE --case to assign letter grade to minimum numerical grade
        WHEN MIN(sc.progress) < 40 THEN 'F' --when min progress is less than 40 give F
        WHEN MIN(sc.progress) BETWEEN 40 AND 49 THEN 'D' --when min progress is between 40 and 49 (less than 50) give D
        WHEN MIN(sc.progress) BETWEEN 50 AND 59 THEN 'C' --when min progress is between 50 and 59 (less than 60) give C
        WHEN MIN(sc.progress) BETWEEN 60 AND 69 THEN 'B' --when min progress is between 60 and 69 (less than 70) give B
        WHEN MIN(sc.progress) >= 70 THEN 'A' --when min progress is 70 or greater give A
        END "Min Grade",
        CASE --case to assign letter grade to maximum numerical grade
        WHEN MAX(sc.progress) < 40 THEN 'F' --when max progress is less than 40 give F
        WHEN MAX(sc.progress) BETWEEN 40 AND 49 THEN 'D' --when max progress is between 40 and 49 (less than 50) give D
        WHEN MAX(sc.progress) BETWEEN 50 AND 59 THEN 'C' --when max progress is between 50 and 59 (less than 60) give C
        WHEN MAX(sc.progress) BETWEEN 60 AND 69 THEN 'B' --when max progress is between 60 and 69 (less than 70) give B
        WHEN MAX(sc.progress) >= 70 THEN 'A'  --when max progress is 70 or greater give A
        END "Max Grade"
        FROM student s JOIN studentCourse sc ON (s.id=sc.studentId) --get data from student table, join with studentCourse table to get progress field
        GROUP BY s.id, s.firstName, s.lastName --group by student id, firstname, lastname
        ORDER BY s.lastName ASC, s.firstName ASC; --sort results by student lastname and then studentfirstname