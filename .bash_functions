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
# Remember to use double quotes "" to pass the file if it contains spaces
#
# file=path/to/file with spaces.ext
# get_extension "$file"
function get_extension () {
	ext=""
	if [ $# -eq 1 ]; then
		filename=$(basename -- "$1")
		ext=".${filename##*.}"
	else
		echo "Usage: get_extension <file>"
		return
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
		return
	fi
	echo $fname
}
export -f get_filename

# [all]
# Returns the name of the parent directory (no pending /)
# Usage: get_directory <file/folder>
function get_directory () {

	if [ $# -ne 1 ]; then
		echo "Usage: get_directory <file/folder>"
		return
	fi

	parentdir="$(dirname "$1")"
	echo $parentdir
}
export -f get_directory

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
		return
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
		return
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
		return
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
		return
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
		return
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
		return
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
		return
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
		return
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
		return
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
		return
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
		echo "Usage: count_files_matching_extension <ext> | count_files_matching_extension <ext> <dir>"
		return
	fi
	echo $num_files
}
export -f count_files_matching_extension

# [all]
# Recursively rename the file in argument to only have lowercase letters.
# Usage: lowercase_file <file>
function lowercase_file () {

	if [ $# -ne 1 ]; then
		echo "Usage: uppercase_file <file>"
		return
	fi

	filename=$(basename -- "$1")
	filename="$(echo $filename | tr ' -' '_')"
	filename="$(echo $filename | tr '[:upper:]' '[:lower:]')"

	basename=$(get_directory "$1")
	name=$basename/$filename

	if [ "$1" != "$name" ]; then
		mv "$1" "$name"
	fi
}
export -f lowercase_file

# [all]
# Recursively rename the file in argument to only have uppercase letters.
# Usage: uppercase_file <file>
function uppercase_file () {

	if [ $# -ne 1 ]; then
		echo "Usage: uppercase_file <file>"
		return
	fi

	filename=$(basename -- "$1")
	filename="$(echo $filename | tr ' -' '_')"
	filename="$(echo $filename | tr '[:lower:]' '[:upper:]')"

	basename=$(get_directory "$1")
	name=$basename/$filename

	if [ "$1" != "$name" ]; then
		mv "$1" "$name"
	fi
}
export -f uppercase_file

# [all]
# Recursively rename all the files in current/argument folder
# to only have lowercase letters.
# Credits: https://stackoverflow.com/questions/152514/how-do-i-rename-all-folders-and-files-to-lowercase-on-linux
# Usage: recursively_lowercase | recursively_lowercase <folder>
function recursively_lowercase () {

	if [ $# -eq 0 ]; then
		folder=.
	elif [ $# -eq 1 ]; then
		folder=$1
	else
		echo "Usage: recursively_lowercase | recursively_lowercase <folder>"
		return
	fi

	if [ ! -d $folder ]; then
		echo "Usage: recursively_lowercase | recursively_lowercase <folder>"
		return
	fi

	for f in $folder/*; do

		name="$(echo $f | tr ' -' '_')"
		name="$(echo $name | tr '[:upper:]' '[:lower:]')"

		if [ "$f" != "$name" ]; then
			mv "$f" "$name"
		fi

		if [ -d $name ]; then
			recursively_lowercase $name
		fi

	done
}
export -f recursively_lowercase

# [all]
# Recursively rename all the files in current/argument folder
# to only have uppercase letters.
# Credits: https://stackoverflow.com/questions/152514/how-do-i-rename-all-folders-and-files-to-uppercase-on-linux
# Usage: recursively_uppercase | recursively_uppercase <folder>
function recursively_uppercase () {

	if [ $# -eq 0 ]; then
		folder=.
	elif [ $# -eq 1 ]; then
		folder=$1
	else
		echo "Usage: recursively_uppercase | recursively_uppercase <folder>"
		return
	fi

	if [ ! -d $folder ]; then
		echo "Usage: recursively_uppercase | recursively_uppercase <folder>"
		return
	fi

	for f in $folder/*; do

		name="$(echo $f | tr ' -' '_')"
		name="$(echo $name | tr '[:lower:]' '[:upper:]')"

		if [ "$f" != "$name" ]; then
			mv "$f" "$name"
		fi

		if [ -d $name ]; then
			recursively_uppercase $name
		fi

	done
}
export -f recursively_uppercase

# [all]
# Clear Git master branch history in the Git server
# Source: https://www.systutorials.com/how-to-clear-git-history-in-local-and-remote-branches/
# Usage: clear_git_branch <branch>
function clear_git_branch () {

	if [ $# -ne 1 ]; then
		echo "Usage: clear_git_branch <branch>"
		return
	fi

	tmp_branch_name="tmp-"$1

	# create a temporary branch
	git checkout --orphan $tmp_branch_name

	# Add all files and commit them
	git add -A

	git commit -m 'Cleaned history'

	# Deletes the old branch
	git branch -D $1

	# Rename the current branch like the old one
	git branch -m $1

	# Force push the new branch to Git server
	git push -f origin $1
}
export -f clear_git_branch

# ---------------------------------------------------------------------------- #

[ "$VERBOSE_SCRIPT" = true ] && echo "All functions imported"
