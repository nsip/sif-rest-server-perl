#/bin/sh

curl -v -i -H "Content-Type:application/xml" -H "Accept:application/xml" -X POST -d @inputs/post_students_student.xml http://localhost:3000/students/student
