#!/bin/bash

# MyTODO : A simple app which renders a TODO list written using Markdown syntax
# Author : Buddhika Siddhisena <bud@thinkcube.com>
# License : GPL v2

TODO_FILE='todo.markdown'

# Predefined constants
H1='#'
COLOR0='\033[0m'	# Reset colors
COLOR1='\033[0;35m'	# Purple for H1
COLOR2='\033[1;35m'	# Light Purple for H2
COLOR_DOT='\033[1;33m'	# Yellow for bullets
COLOR_DONE='\033[1;32m'	# Light green

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

		echo -e "$(
			sed -n "/^[ ]*$H1\{1,$heading_level\}[ ]*$heading/, /^$H1\{1,$heading_level\}[ ]/p" $TODO_FILE | grep -v "^$H1\{1,$heading_level\}[ ]\+" \
			| sed "s/#\(.*\)/\\${COLOR1}#\1\\${COLOR0}/" \
			| sed "s/\*\(.*\)/\\${COLOR_DOT}*\\$COLOR0\1/"  \
			| sed "s/\ x \(.*\)/\\${COLOR_DONE} x \1\\${COLOR0}/"

		)"
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

	# Set heading color
	heading_color="COLOR$ph_heading_level"
	echo -e "${!heading_color}"

	for i in $(seq $ph_heading_level); do echo -n "$H1"; done
	echo "$ph_heading"

	echo -e "$COLOR0"
}

get_todo_list "$1"
