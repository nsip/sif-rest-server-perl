#/bin/sh

curl -v -i -H "Content-Type:application/xml" -H "Accept:application/xml" -X POST -d @inputs/post_TeachingGroup.xml http://localhost:3000/TeachingGroups/TeachingGroup
