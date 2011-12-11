#!/bin/bash

# ii.do : A simple script which renders a TODO list written using Markdown syntax
# Author : Buddhika Siddhisena <bud@thinkcube.com>
# License : GPL v2

# Version
VERSION='0.6'

# Predefined constants
TODO_FILE="$HOME/todo.markdown"

if [ ! $EDITOR ]; then
	EDITOR='vi'	# Default editor if unspecified
fi

ACTION='ls'		# Default action is to List tasks
COLOR_ON=1		# By default we show  in color
COUNT_ON=0		# Used to track -n option with other options
TOPIC=''		# Used to filter by topic name

H1='#'
H1_ALT='=='		# Alternatively we could use a series of ====
H2_ALT='\-\-'		# Altenatively we could use a series of ---
COLOR0='\033[0m'	# Reset colors
COLOR_H1='\033[4;35m'	# Purple for H1
COLOR_H2='\033[1;35m'	# Purple for H2
COLOR2='\033[1;35m'	# Light Purple for H2
COLOR_DOT='\033[1;33m'	# Yellow for bullets
COLOR_DONE='\033[9;37m'	# Light gray
COLOR_IMPORTANT='\033[1;31m' # Red for important
COLOR_PRIORITY='\033[1;33m' # Yellow for priority 
COLOR_EM='\033[7m'	# Reverse for emphasis 

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
		echo ''	# Insert a Blank line

		# Figure out the name of next heading with same level
		next_heading=$(get_topics | sed -n -e 's/[^#]\{1,\}//' -e "/$heading/, /^$H1\{1,$heading_level\}[ ]\{1,\}/p"|tail -n 1|sed "s/$H1\{1,$heading_level\}//")

		# Find line number of topic and next topic
		line_num1=$(grep -n "$(echo $heading)" $TODO_FILE| sed -e 's/\:.*//')
		line_num2=$(grep -n "$(echo $next_heading)" $TODO_FILE | sed -e 's/\:.*//')

		if [ $line_num2 -gt $line_num1 ];then
			# Show only between the two lines
			sed -n $line_num1,$(expr $line_num2 - 1)p $TODO_FILE
		else
			# Show from line to EOF
			sed -n $(expr $line_num1),\$p $TODO_FILE
		fi
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

		if  echo "$INP" | grep -q '^[^ \*]\+'; then
			# Show heading
			if echo "$INP" | grep -i -q '[a-z0-9\#]';then
				# Insert blank line before heading if not a --- or ===
				echo 
			fi
			echo "$INP"
		elif echo "$INP" | grep -q "^\* "; then
			# Show completed task
			echo "$INP" | grep "^\*${SP}x${SP}"
		else
			echo 
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

# Filters the list to return important
function get_todo_important() {

	SP='[ ]\{1,\}'	# Match one or more spaces

	while read INP
	do

		# Show NOT completed task
		TASK=$(echo "$INP" | grep "^\*${SP}!${SP}")
		if [ "$TASK" ];then
			if echo "$HEADING" | grep -q "^H1"; then
				echo "$HEADING"
			else
				echo "${HEADING_LEVEL} ${HEADING}"
			fi

			echo
			echo "$TASK"
		fi

		# Capture heading & heading level
		if echo "$INP" | grep -q "^[a-zA-Z$H1]"; then
			HEADING=$(echo "$INP" | grep "^[a-zA-Z$H1]")
		fi

		if echo "$INP" | grep -q "^$H1_ALT"; then
			HEADING_LEVEL="$H1"
		elif echo "$INP" | grep -q "^$H1_ALT"; then 
			HEADING_LEVEL="${H1}${H1}"
		fi

	done
}

# Get list of topics
function get_topics() {

	i=0
	PREV_INP=''	# Keep previous input

	grep -v '^*' $TODO_FILE | while read INP
	do
		if echo $INP | grep -q "$H1"; then
			# Hash Style heading
			i=$(expr $i + 1)
			echo "$i: $INP"
		elif echo $INP | grep -q "$H1_ALT"; then
			# Alt H1 ===  used, normalize to hash style
			i=$(expr $i + 1)
			echo "$i: ${H1} $PREV_INP"
		elif echo $INP | grep -q "$H2_ALT"; then
			# Alt H2 ---  used, normalize to hash style
			i=$(expr $i + 1)
			echo "$i: ${H1}${H1} $PREV_INP"
		fi

		PREV_INP="$INP"
		
	done
}

# Get the topic name, given id
function get_topic_byid() {

	SP='[ ]\{1,\}'	# Match one or more spaces

	TOPIC_NO="$1"

	if ! [[ "$TOPIC_NO" =~ ^[0-9]+$ ]];then
		echo "Topic must be an integer that represents the topic number. Use -t to findout." >&2
		exit 1
	fi

	# Find out topic name corresponding to number
	TOPIC=$(get_topics | grep "${TOPIC_NO}:" | sed "s/^[0-9]\{1,\}:${SP}//")

	if ! [ "$TOPIC" ];then
		echo "No topic matching your topic number. Use -t to findout." >&2
		exit 1
	fi

	echo "$TOPIC"
}

# Colorize output
function colorize() {

	SP='[ ]\{1,\}'	# Match one or more spaces

	while read INP
	do
		case "$ACTION" in

		ps1 )
			echo "$(echo "$INP" | sed 's!\[\$\(.*\]\)!\\033[0;31m\[$\1\\033[0;0m!')"
		;;

		top )
			echo -e "$(echo "$INP" | sed "s!\(^[0-9]\{1,\}:\)\(.*\)!\\${COLOR_DONE}\1\\${COLOR_H2}\2\\${COLOR0}!")"
		;;

		* )
			echo -e "$(echo "$INP" | sed "s/^${H1}\([^${H1}]\{1,\}\)/\\${COLOR_H1}#\1\\${COLOR0}/" \
			| sed "s/^${H1}${H1}\(.*\)/\\${COLOR_H2}${H1}${H1}\1\\${COLOR0}/" \
			| sed "s/^\([=-].*\)/\\${COLOR_H2}\1\\${COLOR0}/" \
			| sed "s/^\([a-zA-Z0-9].*\)/\\${COLOR_H2}\1\\${COLOR0}/" \
			| sed "s/^\*${SP}x${SP}\(.*\)/*\\${COLOR_DONE} x \1\\${COLOR0}/" \
			| sed "s/^\*${SP}\((.*).*\)/*\\${COLOR_PRIORITY} \1\\${COLOR0}/" \
			| sed "s/\ ! \(.*\)/\\${COLOR_IMPORTANT} ! \1\\${COLOR0}/" \
			| sed "s/\([\`]\{1,\}.*[\`]\{1,\}\)/\\${COLOR_EM}\1\\${COLOR0}/" \
			| sed "s/\*\(.*\)/\\${COLOR_DOT}*\\$COLOR0\1/")"
		;;

		esac
	done
}

# HTMLize output
function htmlize() {

	SP='[ ]\{1,\}'	# Match one or more spaces

# Print html header
cat <<EOT
<!DOCTYPE html>
<html>
	<head>
	<title>$(basename "$TODO_FILE")</title>
	<style type="text/css">

body {
    font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
    font-weight: 300;
    font-size: 12px;
}

h1 {
    font-weight: 100;
    font-size: 62px;
    margin: 20px 0;
}

h2 {
    font-weight: 100;
    font-size: 42px;
    margin: 20px 0;
}

ul {
    margin: 15px;
    padding: 0;
    width: 500px;
}

ul li {
    list-style-type: none;
    font-size: 24px;
    background-color: #efefef;
    margin-bottom: 5px;
    padding: 10px;
    text-align: left;
}

del {
	color: #656565;
}

.important {
	border-left-style: solid;
	border-color: #cc0000;
	border-width: 5px;
}

.priority {
	border-left-style: solid;
	border-color: #f88017;
	border-width: 5px;
}

.completed {
	border-left-style: solid;
	border-color: #8afb17;
	border-width: 5px;
}

	</style>
	</head>

<body>
EOT
	while read INP
	do

		if echo "$PREV_INP" | grep -q "^[${H1}${H1_ALT}${H2_ALT}]"; then
			# Detected a begining of a list
			echo '<ul>'
		elif echo "$INP" | grep -q -v '^\*';then
			# Detected an ending of a list
			if echo "$PREV_INP" | grep -q '^\*';then
				echo '</ul>'
				echo
			fi
		fi

		if echo "$INP" | grep -q "^${H1_ALT}";then
			# Detect an alternate heading 1 =====
			echo "<h1>$PREV_INP</h1>"
		elif echo "$INP" | grep -q "^${H2_ALT}";then
			# Detect an alternate heading 2 -----
			echo "<h2>$PREV_INP</h2>"
		fi

		echo "$INP" | sed "s/^${H1}[ ]*\([^${H1}]\{1,\}\)/<h1>\1<\/h1>/" \
		| sed "s/^${H1}${H1}[ ]*\(.*\)/<h2>\1<\/h2>/" \
		| sed "s/^[a-zA-Z${H1_ALT}${H2_ALT}].*//" \
		| sed "s/^\*${SP}x${SP}\(.*\)/<li class=\"completed\"><del>\1<\/del><\/li>/" \
		| sed "s/^\*${SP}\((.*).*\)/<li class=\"priority\">\1<\/li>/" \
		| sed "s/^\*${SP}!${SP}\(.*\)/<li class=\"important\"><em>\1<\/em><\/li>/" \
		| sed "s/^\*${SP}\(.*\)/<li class=\"pending\">\1<\/li>/"

		PREV_INP="$INP"
	done

# Print html footer
cat <<EOT
	<footer>Generated by <a href="http://github.com/geekaholic/ii.do">ii.do</a></footer>
    </body>
</html>
EOT
}

# Count the number of pending tasks
function count_todo_list() {
	SP='[ ]\{1,\}'	# Match one or more spaces

	# Adapt count based on other actions or default to pending tasks
	case "$ACTION" in

	com )
		# Completed task count
		N=$(get_todo_list "$TOPIC" | get_todo_completed | grep "^\*${SP}x${SP}" | wc -l)
	;;


	* )
		# Pending task count
		N=$(get_todo_list "$TOPIC" | grep '^\*' | grep -v "^\*${SP}x${SP}" | wc -l)
	;;

	esac

        echo $N
}

# Returns modified PS1 which contains pending tasks
function get_PS1() {
	
	if ! $(echo -n $PS|grep -q "$0");then
		PS1=$(echo -n "$PS"|sed "s!\([\\]\{0,1\}\\$\)! \[\$("$0" -f "$TODO_FILE" -n)\]\1!")
		echo "export PS1='$PS1'"
	else
		echo '$PS1 already modified' >&2
		exit 1
	fi
}

#############################################################
# Begin:  Get options
while getopts ":f:S:T:enixXChtH" opt; do
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
			COUNT_ON=1
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

		i )
			# Return Important Tasks
			ACTION='imp'
			;;

		H )
			# Return HTMLized Tasks
			ACTION='htm'
			;;

		h )
			# Return Usage help
			ACTION='hlp'
			;;
		t )
			# Return Topic
			ACTION='top'
			;;

		T )
			# Filter by Topic number
			TOPIC=$(get_topic_byid "$OPTARG")
			;;

		\? )
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;

		: )
			echo "Option -$OPTARG requires an argument" >&2
			exit 1
			;;
	esac
done

# Check if todo file exists
if [ ! -f "$TODO_FILE" ];then
	echo "Unable to find $TODO_FILE. Atleast touch a blank file!"
	exit 1
fi

# Handle counting of tasks
if [ $COUNT_ON -eq 1 ];then
	count_todo_list
	exit 0
fi

# Take action
case "$ACTION" in

	ls )
		if [ $COLOR_ON -eq 1 ];then
			clear
			get_todo_list "$TOPIC" | colorize
		else
			get_todo_list "$TOPIC"
		fi
	;;

	ed )
		$EDITOR $TODO_FILE
	;;

	com )
		# Return completed tasks
		if [ $COLOR_ON -eq 1 ];then
			clear
			get_todo_list "$TOPIC" | get_todo_completed | colorize
		else
			get_todo_list "$TOPIC" | get_todo_completed
		fi
	;;

	pen )
		# Return pending tasks
		if [ $COLOR_ON -eq 1 ];then
			clear
			get_todo_list "$TOPIC" | get_todo_pending | colorize
		else
			get_todo_list "$TOPIC" | get_todo_pending
		fi
	;;

	imp )
		# Return important tasks
		if [ $COLOR_ON -eq 1 ];then
			clear
			get_todo_list "$TOPIC" | get_todo_important | colorize
		else
			get_todo_list "$TOPIC" | get_todo_important
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

	top )
		# Return topics, aka Headings
		if [ $COLOR_ON -eq 1 ];then
			clear
			get_topics | colorize
		else
			get_topics
		fi
	;;

	htm )
		# Return HTMLized topic list
		get_todo_list | htmlize
	;;

	hlp )
		# Usage
		echo "Version: $VERSION"
		echo -e "\nUsage: $(basename $0) [-f todo_file.markdown] [-T topic_number] [options]"
		echo -e "\nOptions :"
		echo -e " -e \t\t Open TODO file using \$EDITOR"
		echo -e " -n \t\t Count number of pending tasks. Can be filtered using -x, -X etc."
		echo -e " -X \t\t Filter to show only pending tasks"
		echo -e " -x \t\t Filter to show only completed tasks"
		echo -e " -i \t\t Filter to show only important tasks"
		echo -e " -t \t\t Filter to show only topics with topic_number"
		echo -e " -C \t\t Don't colorize output (useful for piping)"
		echo -e " -H \t\t HTMLize the output"
		echo -e " -S \"\$PS1\" \t Will return modified PS1 prompt to contain pending task count"
		echo -e " -h \t\t Show this help screen"
		echo -e "\nBy default, we expect a ~/todo.markdown to be in your \$HOME if not overridden \nby the -f option. Refer to http://github.com/geekaholic/ii.do for examples of \ncreating this file.\n"

	;;


esac

exit 0
