#!/bin/bash

[ "$VERBOSE_SCRIPT" = true ] && echo "Importing bash functions"

# -------------------------- add here your functions ------------------------- #

# [fedora]
# remove package; remove orphaned packages and clean cache
function remove_package () {
	sudo dnf remove $1 -y;
	sudo dnf autoremove -y;
	sudo dnf clean packages;
}
[ "$OS_NAME" = "Fedora Linux" ] && export -f remove_package

# text manipulation

# [all]
# Returns the extension of the file passed as argument
function get_extension () {
	ext=""
	if [ $# -eq 1 ]; then
		filename=$(basename -- "$1")
		ext=".${filename##*.}"
	else
		echo "Usage: get_extension <file>"
	fi
	echo $ext
}
export -f get_extension

# [all]
# Returns the name of the file passed as argument
function get_filename () {
	fname=""
	if [ $# -eq 1 ]; then
		fname=$(basename -- "$1")
		ext="${fname##*.}"
		fname="${fname%.*}"
	else
		echo "Usage: get_filename <file>"
	fi
	echo $fname
}
export -f get_filename

# [all]
# Receives an extension as argument, returns the extension making sure that:
# 1. the extension starts with .
# 2. the extension only has one .
# 3. the extension does not contain whitespaces
# If these conditions are not met, the function tries to fix the extension
function parse_extension () {

	if [ $# -ne 1 ]; then
		echo "You stupid bitch"
		return
	fi

	# remove all the dots and strange stuff
	new_ext=$(echo $1 | sed -e 's/[^a-zA-Z0-9]//g')

	#new_ext=$(echo $1 | sed -e 's/\.//gp') # only removes the dots
	#new_ext=$(echo $1 | sed 's/\(\.\)\1\+/\1/g') # only removes all the dots except for the first

	# add a dot at the beginning
	new_ext=$(echo $new_ext | sed 's/^/\./')

	echo $new_ext
}
export -f parse_extension

# [all]
# Returns true if the argument extension matches the file extension, false otherwise
# Usage: extension_matching <file> <extension>
function extension_matching () {
	result=false
	if [ $# -eq 2 ]; then
		new_ext=$(parse_extension $2)
		file_ext=$(get_extension $1)
		if [ "$file_ext" = "$new_ext" ]; then
			result=true
		fi
	else
		echo "Usage: remove_matching_extension <file> <extension_to_match>"
	fi
	echo $result
}
export -f extension_matching

# [all]
# Add the extension to a single file
# Usage: add_extension <file> <extension>
function add_extension () {
	if [ $# -eq 2 ]; then # argument check
		ext=$(parse_extension $2) # parse extension
		mv $1 $1$ext;
	else
		echo "Usage: add_extension <file> <extension>"
	fi
}
export -f add_extension

# [all]
# Add the extension to all the files (g stands for globally) in the current/argument folder
# Usage: add_extension_g <extension> | add_extension_g <dir> <extension> 
function add_extension_g () {
	if [ $# -eq 1 ]; then # add the extension to the files in the current folder
		for f in * ; do add_extension $f $1; done;
	elif [ $# -eq 2 ]; then # add the extension to the files in the argument folder
		for f in $1/*; do add_extension $f $2; done;
	else
		echo "Usage: add_extension_g <extension> | add_extension_g <dir> <extension>"
	fi
}
export -f add_extension_g

# [all]
# Remove the extension from the input file. If the file has no extension, the mv will
# "silently" fail (it will fail and complain but the script will go on). The extension
# is removed whatever it is, it is not matched first
# Usage: remove_extension <file>
function remove_extension () {
	if [ $# -eq 1 ]; then
		ext=$(get_extension $1)
		basename=$(basename $1 $ext);
		mv $1 $basename;
	else
		echo "Usage: remove_extension <file>"
	fi
}
export -f remove_extension

# [all]
# Remove the extension from all the files in the current/argument folder. If the file has no 
# extension, the mv will "silently" fail (it will fail and complain but the script will go on). 
# The extension is removed whatever it is, it is not matched first
# Usage: remove_extension_g | remove_extension_g <dir>
function remove_extension_g () {
	if [ $# -eq 1 ]; then
		for f in *; do remove_extension $f; done;
	elif [ $# -eq 2 ]; then
		for f in $1/*; do remove_extension $f; done;
	else
		echo "Usage: remove_extension_g | remove_extension_g <dir>"
	fi
}
export -f remove_extension_g

# [all]
# Remove the extension from the input file, if matching. 
# Usage: remove_matching_extension <file> <extension_to_match>
function remove_matching_extension () {
	if [ $# -eq 2 ]; then
		file_ext=$(get_extension $1)
		if [ $(extension_matching $file_ext $2) = "true" ] # if the extension matches
		then
			# remove it
			basename=$(basename $1 $file_ext);
			mv $1 $basename;
		fi
	else
		echo "Usage: remove_matching_extension <file> <extension_to_match>"
	fi
}
export -f remove_matching_extension

# [all]
# Remove the extension from all the files in the current/argument folder. If the file has no 
# extension, the mv will "silently" fail (it will fail and complain but the script will go on). 
# The extension is removed whatever it is, it is not matched first
# Usage: remove_matching_extension_g <ext> | remove_matching_extension_g <dir> <ext>
function remove_matching_extension_g () {
	if [ $# -eq 1 ]; then
		for f in *; do remove_matching_extension $f $1; done;
	elif [ $# -eq 2 ]; then
		for f in $1/*; do remove_matching_extension $f $2; done;
	else
		echo "Usage: remove_matching_extension_g <ext> | remove_matching_extension_g <dir> <ext>"
	fi
}
export -f remove_matching_extension_g

# [all]
# List files in current/argument folder with particular extension
function list_extension () {
	ext=$(get_extension $1) # c -> .c dot is included by get_extension
	if [ $# -eq 1 ]; then
		res=$(ls *$ext)
	elif [ $# -eq 2 ]; then
		res=$(ls $2/*$ext)
	else
		echo "Usage: list_extension <ext> | list_extension <dir> <ext>"
	fi
	echo $res
}
export -f list_extension

# [all]
# Remove files matching the extension in the current/argument folder.
# Usage: remove_files_matching_extension <ext> | remove_files_matching_extension <dir> <ext>
function remove_files_matching_extension () {
	if [ $# -eq 1 ]; then
		rm $(list_extension $1)
	elif [ $# -eq 2 ]; then
		rm $(list_extension $2 $1)
	else
		echo "Usage: remove_files_matching_extension <ext> | remove_files_matching_extension <dir> <ext>"
	fi
}
export -f remove_files_matching_extension

# [all]
# Returns the total number of files in the current/argument folder.
# Usage: count_files | count_files <dir>
function count_files () {
	if [ $# -eq 1 ]; then
		num_files=$(ls | wc -l)
	elif [ $# -eq 2 ]; then
		num_files=$(ls $2 | wc -l)
	else
		echo "Usage: count_files | count_files <dir>"
	fi
	echo $num_files
}
export -f count_files

# [all]
# Returns the total number of files in the current/argument folder
# matching the argument extension.
# Usage: count_files_matching_extension <ext> | count_files_matching_extension <ext> <dir>
function count_files_matching_extension () {
	ext=$(get_extension $1) # c -> .c dot is included by get_extension
	if [ $# -eq 1 ]; then
		num_files=$(ls *$ext | wc -l)
	elif [ $# -eq 2 ]; then
		num_files=$(ls $2/*$ext | wc -l)
	else
		echo "Usage: count_files | count_files <dir>"
	fi
	echo $num_files
}
export -f count_files_matching_extension

# ---------------------------------------------------------------------------- #

[ "$VERBOSE_SCRIPT" = true ] && echo "All functions imported"
