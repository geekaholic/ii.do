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
COLOR_ON=1		# By default we show  in color

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
while getopts ":f:S:enxXC" opt; do
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

		S )
			# Return PS1
			ACTION='ps1'
			PS="$OPTARG"
			;;

		C )
			# Turn off color
			COLOR_ON=0
			;;

		x )
			# Return Completed
			ACTION='com'
			;;
		X )
			# Return Pending
			ACTION='pen'
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

# Filters the list to return completed
function get_todo_completed() {

	SP='[ ]\{1,\}'	# Match one or more spaces

	while read INP
	do
		if  echo $INP | grep -q "$H1"; then
			# Show heading
			echo
			echo "$INP"
			echo
		else
			# Show completed task
			echo "$INP" | grep "^\*${SP}x${SP}"
		fi
	done
	echo
}

# Filters the list to return pending
function get_todo_pending() {

	SP='[ ]\{1,\}'	# Match one or more spaces

	while read INP
	do
		# Show NOT completed task
		echo "$INP" | grep -v "^\*${SP}x${SP}"
	done
}

# Colorize output
function colorize() {

	SP='[ ]\{1,\}'	# Match one or more spaces

	while read INP
	do
		case "$ACTION" in

		ls | com | pen )
			echo -e "$(echo "$INP" | sed "s/^#\([^\#]\{1,\}\)/\\${COLOR_H1}#\1\\${COLOR0}/" \
			| sed "s/^##\(.*\)/\\${COLOR_H2}##\1\\${COLOR0}/" \
			| sed "s/^\*${SP}x${SP}\(.*\)/*\\${COLOR_DONE} x \1\\${COLOR0}/" \
			| sed "s/^\*${SP}\((.*).*\)/*\\${COLOR_PRIORITY} \1\\${COLOR0}/" \
			| sed "s/\ ! \(.*\)/\\${COLOR_IMPORTANT} ! \1\\${COLOR0}/" \
			| sed "s/\([\`]\{1,\}.*[\`]\{1,\}\)/\\${COLOR_EM}\1\\${COLOR0}/" \
			| sed "s/\*\(.*\)/\\${COLOR_DOT}*\\$COLOR0\1/")"
		;;

		ps1 )
			echo "$(echo "$INP" | sed 's!\[\$\(.*\]\)!\\033[0;31m\[$\1\\033[0;0m!')"
		;;

		esac
	done
}

# Count the number of pending tasks
function count_todo_list() {
	SP='[ ]\{1,\}'	# Match one or more spaces
	N=$(get_todo_list | grep '^[^#]' | grep -v "^\*${SP}x${SP}" | wc -l)
        echo $N
}

# Returns modified PS1 which contains pending tasks
function get_PS1() {
	
	if ! $(echo -n $PS|grep -q "$0");then
		PS1=$(echo -n "$PS"|sed "s!\([\\]\{0,1\}\\$\)! \[\$("$0" -f "$TODO_FILE" -n)\]\1!")
		echo "export PS1='$PS1'"
	else
		echo '$PS1 already modified' 1>&2
		exit 1
	fi
}

# Take action
case "$ACTION" in

	ls )
		#get_todo_list "$1"
		if [ $COLOR_ON -eq 1 ];then
			clear
			get_todo_list | colorize
		else
			get_todo_list
		fi
	;;

	ed )
		$EDITOR $TODO_FILE
	;;

	num )
		# Count tasks
		count_todo_list
	;;

	com )
		# Return completed tasks
		if [ $COLOR_ON -eq 1 ];then
			clear
			get_todo_list | get_todo_completed | colorize
		else
			get_todo_list | get_todo_completed
		fi
	;;

	pen )
		# Return pending tasks
		if [ $COLOR_ON -eq 1 ];then
			clear
			get_todo_list | get_todo_pending | colorize
		else
			get_todo_list | get_todo_pending
		fi
	;;

	ps1 )
		# Help to change $PS1
		if [ $COLOR_ON -eq 1 ];then
			get_PS1 | sed 's!\\!\\\\!g' | colorize
		else
			get_PS1 | sed 's!\\!\\\\!g'
		fi
	;;


esac
