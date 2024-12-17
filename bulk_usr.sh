#!/bin/bash
#
#Script name: bulk_usr.sh
#Purpose: This script reads a text file containing user data (username, password, group, and additional info) and creates user accounts accordingly.
#If the group doesn't exist, it creates it before adding the user.
#The script also handles user and group creation errors, and checks if the user already exists before attempting to create them.
#
#Usage:
#	./bulk_usr.sh <input_file>
#		- <input_file>: A text file containing user details in the format:
#		username:password:group:additional_info
#		- Example: John:Password123:Redteam:John_Doe
#
#Requirements:
#		- The script must be run with root priveleges (e.g., using sudo) to create users and groups.
#		- The input file should not contain empty lines or improperly formatted entries.
#
#Author: Dylan A. Miller
#Date: 2024
#
#Exit codes:
#	0 - Script ran successfully.
#	1 - Input file missing or incorrect.
#	2 - Failed to create users or groups.

if [[ $# -ne 1 ]];then
	echo "Usage: $0 ./users.txt"
	exit 1
fi

INPUT_FILE=$1

if [[ ! -f $INPUT_FILE ]];then
	echo "Error: File $INPUT_FILE does not exist."
	exit 1
fi

while IFS=":" read -r username password group additional_info;do		if [[ -z $username || $username == \#* ]];then
		continue
	fi

	echo "Processing user: $username"
	echo "Processing group: '$group'"

	if [[ -z "$group" ]];then
		echo "Error: Group name is missing for user '$username'. Skipping."
		continue
	fi

	if ! getent group "$group" > /dev/null 2>&1;then
		echo "Group '$group' does not exist. Creating it..."
		groupadd "$group"
		if [[ $? -ne 0 ]];then
			echo "Error: Failed to create group '$group'. Skipping user '$username'."
		continue
		fi
	fi

	if ! id "$username" > /dev/null 2>&1;then
		echo "Creating user: $username"
		useradd -m -g "$group" -c "$additional_info" "$username"
		if [[ $? -eq 0 ]];then
			echo "$username:$password" | chpasswd -e
			echo "User $username created successfully."
		else
			echo "Error: Failed to create user $username'."
		fi
	else
		echo "User $username already exists. Skipping."
	fi
done < "$INPUT_FILE"

echo "User creation process completed."
