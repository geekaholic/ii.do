#!/bin/bash

# MyTODO : A simple app which renders a TODO list written using Markdown syntax
# Author : Buddhika Siddhisena <bud@thinkcube.com>
# License : GPL v2


# Predefined constants
TODO_FILE="$HOME/todo.markdown"
H1='#'
COLOR0='\033[0m'	# Reset colors
COLOR1='\033[0;35m'	# Purple for H1
COLOR2='\033[1;35m'	# Light Purple for H2
COLOR_DOT='\033[1;33m'	# Yellow for bullets
COLOR_DONE='\033[1;32m'	# Light green
COLOR_IMPORTANT='\033[0;31m' # Red
COLOR_PRIORITY='\033[1;31m' # Light Red

# Get options
while getopts ":f:" opt; do
	case $opt in
		f ) 
			if [ -f "$OPTARG" ];then
				# Replace with -f file 
				TODO_FILE="$OPTARG"
			else
				echo "Unable to find $TODO_FILE. Atleast touch a blank file!"
				exit 1
			fi
			shift 
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
	shift 
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

			sed -n "/^[ ]*$H1\{1,$heading_level\}[ ]*$heading/, /^$H1\{1,$heading_level\}[ ]/p" $TODO_FILE | grep -v "^$H1\{1,$heading_level\}[ ]\+" \
			| colorize
	else
		# Display everything!
		cat $TODO_FILE | colorize
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

	# Set heading color
	heading_color="COLOR$ph_heading_level"
	echo -e "${!heading_color}"

	for i in $(seq $ph_heading_level); do echo -n "$H1"; done
	echo "$ph_heading"

	echo -e "$COLOR0"
}

function colorize() {

	while read INP
	do
		echo -e "$(echo "$INP" | sed "s/#\(.*\)/\\${COLOR1}#\1\\${COLOR0}/" \
		| sed "s/\*\(.*\)/\\${COLOR_DOT}*\\$COLOR0\1/" \
		| sed "s/\ x \(.*\)/\\${COLOR_DONE} x \1\\${COLOR0}/" \
		| sed "s/\ ! \(.*\)/\\${COLOR_IMPORTANT} ! \1\\${COLOR0}/")"

	done
}

get_todo_list "$1"
