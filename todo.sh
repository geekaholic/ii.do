#!/bin/bash

# MyTODO : A simple app which renders a TODO list written using Markdown syntax
# Author : Buddhika Siddhisena <bud@thinkcube.com>
# License : GPL v2

TODO_FILE='todo.markdown'

# Predefined constants
H1='#'
H2='##'

# Get a list of todos for a given heading else show all
function get_todo_list() {
	# Get heading
	heading="$1"


	# Figure out level of heading 
	if  echo $heading | grep -q "$H2"; then
		heading_level='2'
		heading_level_char="$H2"
	else
		heading_level='1'
		heading_level_char="$H1"
	fi 

	# Cleanup heading by removing level character
	heading=$(echo $heading|sed "s/$heading_level_char//")

	if [ "$heading" ]; then
		# Display heading and subheadings
		echo "$heading_level_char $heading"
		sed -n "/^[ ]*$heading_level_char[ ]*$heading/, /^$heading_level_char[ ]/p" $TODO_FILE | grep -v "^$heading_level_char[ ]\+"
	else
		# Display everything!
		cat $TODO_FILE
	fi
}

get_todo_list "$1"
