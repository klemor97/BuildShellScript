#!/bin/sh

OUTPUT_FILE_NAME="a.out"

CPP_FILES=`find ./ | grep ".cpp$" | tr '\n' ' '`

FILES_FOUND="false"

for FILE in $CPP_FILES
do
	OBJECT_FILE="`echo "$FILE" | sed "s/.cpp$//"`.o"
	if [ -f "$OBJECT_FILE" ]
	then
		if [ "$FILE" -nt "$OBJECT_FILE" ]
		then
			COMPILATION_RESULT=`g++ $FILE -std=c++11 -c -o "$OBJECT_FILE" 2>&1`
			FILES_FOUND="true"
		fi
	else
		COMPILATION_RESULT=`g++ $FILE -std=c++11 -c -o "$OBJECT_FILE"`
		FILES_FOUND="true"
	fi

	if [ ! -z "`echo "$COMPILATION_RESULT" | tr -d '\n'`" ]
	then
		echo "$COMPILATION_RESULT"
		exit
	fi
	
	OBJECT_FILES="$OBJECT_FILES $OBJECT_FILE"
done

if [ "$FILES_FOUND" = "true" ]
then
	COMPILATION_RESULT=`g++ $OBJECT_FILES -std=c++11 -o "$OUTPUT_FILE_NAME"`
	if [ -z "`echo "$COMPILATION_RESULT" | tr -d '\n'`" ]
	then
		echo "Compilation completed succesfully!"
	else
		echo "$COMPILATION_RESULT"
	fi
else
	echo "No modified files were found!"
fi
