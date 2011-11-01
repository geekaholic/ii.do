#!/bin/bash

# ii.do : A simple script which renders a TODO list written using Markdown syntax
# Author : Buddhika Siddhisena <bud@thinkcube.com>
# License : GPL v2


# Predefined constants
TODO_FILE="$HOME/todo.markdown"

if [ ! $EDITOR ]; then
	EDITOR='vi'	# Default editor if unspecified
fi

ACTION='ls'		# Default action is to List tasks

H1='#'
COLOR0='\033[0m'	# Reset colors
COLOR_H1='\033[4;35m'	# Purple for H1
COLOR_H2='\033[1;35m'	# Purple for H2
COLOR2='\033[1;35m'	# Light Purple for H2
COLOR_DOT='\033[1;33m'	# Yellow for bullets
COLOR_DONE='\033[9;37m'	# Light gray
COLOR_IMPORTANT='\033[1;31m' # Red for important
COLOR_PRIORITY='\033[1;33m' # Yellow for priority 
COLOR_EM='\033[7m'	# Reverse for emphasis 

# Get options
while getopts ":f:en" opt; do
	case $opt in
		f ) 
			if [ -f "$OPTARG" ];then
				# Replace with -f file 
				TODO_FILE="$OPTARG"
			else
				echo "Unable to find $TODO_FILE. Atleast touch a blank file!"
				exit 1
			fi
			;;

		e )
			# Edit todo
			ACTION='ed'
			;;

		n )
			# Count tasks 
			ACTION='num'
			;;


		\? )
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;

		: )
			echo "Option -$OPTARG requires an argument">&2
			exit 1
			;;
	esac
done

# Check if todo file exists
if [ ! -f "$TODO_FILE" ];then
	echo "Unable to find $TODO_FILE. Atleast touch a blank file!"
	exit 1
fi

# Get a list of todos for a given heading else show all
function get_todo_list() {
	# Get heading
	heading="$1"


	# Figure out level of heading 
	if  echo $heading | grep -q "$H1$H1"; then
		heading_level='2'
	else
		heading_level='1'
	fi 

	# Cleanup heading by removing level character
	heading=$(echo $heading|sed "s/$H1\{1,$heading_level\}//")

	if [ "$heading" ]; then
		# Display heading and subheadings
		print_heading "$heading" "$heading_level"

			sed -n "/^[ ]*$H1\{1,$heading_level\}[ ]*$heading/, /^$H1\{1,$heading_level\}[ ]/p" $TODO_FILE | grep -v "^$H1\{1,$heading_level\}[ ]\+"
	else
		# Display everything!
		cat $TODO_FILE
	fi
}

# Print heading 
function print_heading() {
	ph_heading="$1"
	ph_heading_level="$2"

	# Assume heading level 1 if none passed
	if [ ! "$ph_heading_level" ]; then
		$ph_heading_level='1'
	fi

	# Print heading level 
	for i in $(seq $ph_heading_level); do echo -n "$H1"; done
	echo "$ph_heading"
}

# Colorize output
function colorize() {

	SP='[ ]\{1,\}'	# Match one or more spaces

	while read INP
	do
		echo -e "$(echo "$INP" | sed "s/^#\([^\#]\{1,\}\)/\\${COLOR_H1}#\1\\${COLOR0}/" \
		| sed "s/^##\(.*\)/\\${COLOR_H2}##\1\\${COLOR0}/" \
		| sed "s/^\*${SP}x${SP}\(.*\)/*\\${COLOR_DONE} x \1\\${COLOR0}/" \
		| sed "s/^\*${SP}\((.*).*\)/*\\${COLOR_PRIORITY} \1\\${COLOR0}/" \
		| sed "s/\ ! \(.*\)/\\${COLOR_IMPORTANT} ! \1\\${COLOR0}/" \
		| sed "s/\([\`]\{1,\}.*[\`]\{1,\}\)/\\${COLOR_EM}\1\\${COLOR0}/" \
		| sed "s/\*\(.*\)/\\${COLOR_DOT}*\\$COLOR0\1/")"


	done
}

# Count the number of pending tasks
function count_todo_list() {
	SP='[ ]\{1,\}'	# Match one or more spaces
	N=$(get_todo_list | grep '^[^#]' | grep -v "^\*${SP}x${SP}" | wc -l)
        echo $N
}

# Take action
case "$ACTION" in

	ls )
		#get_todo_list "$1"
		clear
		get_todo_list | colorize
	;;

	ed )
		$EDITOR $TODO_FILE
	;;

	num )
		# Count tasks
		count_todo_list
	;;


esac
