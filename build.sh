#!/bin/bash

OUTPUT_FILE_NAME="a.out"

COMPILER="g++"
STANDARD="-std=c++11"
INCLUDES=""
LINKER_FLAGS="-lglfw -lGLEW -lGL"

CPP_FILES=`find ./ | grep "\.cpp$"`

FILES_FOUND="false"

WARNINGS_FOUND="false"

COLOR_RED="\033[38;5;160m"
COLOR_YELLOW="\033[38;5;220m"
COLOR_GREEN="\033[38;5;46m"

COLOR_RESET="\033[39m"

if [ "$1" = "clean" ]
then
	for FILE in $CPP_FILES
	do
		OBJECT_FILE="`echo "$FILE" | sed "s/.cpp$//"`.o"
		OBJECT_FILES="$OBJECT_FILES $OBJECT_FILE"
	done

	rm $OBJECT_FILES $OUTPUT_FILE_NAME > /dev/null 2>&1

	exit
fi

for FILE in $CPP_FILES
do
	OBJECT_FILE="`echo "$FILE" | sed "s/.cpp$//"`.o"
	if [ ! -f "$OBJECT_FILE" ] || ( [ -f "$OBJECT_FILE" ] && [ "$FILE" -nt "$OBJECT_FILE" ] )
	then
		echo "Compiling: $FILE"
		COMPILATION_RESULT=`$COMPILER $STANDARD $FILE -c -o "$OBJECT_FILE" $INCLUDES 2>&1`
		FILES_FOUND="true"
	fi

	if [ ! -z "`echo "$COMPILATION_RESULT" | tr -d '\n'`" ]
	then
		if [ ! -z "`echo "$COMPILATION_RESULT" | grep "error" | tr -d '\n'`" ]
		then
			echo "$COMPILATION_RESULT"
			echo -e "${COLOR_RED}Compilation failed!${COLOR_RESET}"
			exit
		fi

		if [ ! -z "`echo "$COMPILATION_RESULT" | grep "warning" | tr -d '\n'`" ]
		then
			echo "$COMPILATION_RESULT"
			WARNINGS_FOUND="true"
		fi
	fi
	
	OBJECT_FILES="$OBJECT_FILES $OBJECT_FILE"
done

if [ "$FILES_FOUND" = "true" ]
then
	echo "Linking"
	COMPILATION_RESULT=`$COMPILER $STANDARD $OBJECT_FILES -o "$OUTPUT_FILE_NAME" $LINKER_FLAGS 2>&1`
	
	if [ "$WARNINGS_FOUND" = "false" ] && [ -z "`echo "$COMPILATION_RESULT" | tr -d '\n'`" ]
	then
		echo -e "${COLOR_GREEN}Compilation completed succesfully!${COLOR_RESET}"
	elif [ "$WARNINGS_FOUND" = "true" ] && [ -z "`echo "$COMPILATION_RESULT" | tr -d '\n'`" ]
	then
		echo -e "${COLOR_YELLOW}Compilation completed with warnings!${COLOR_RESET}"
	else
		echo "$COMPILATION_RESULT"
		echo -e "${COLOR_RED}Linking failed!${COLOR_RESET}"
		exit
	fi

	if [ "$1" = "run" ]
	then
		./a.out
	fi
else
	echo "No modified files were found!"
fi
