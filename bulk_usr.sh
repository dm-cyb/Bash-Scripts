#!/bin/bash
#
#Script name: bulk_usr.sh
#Purpose: This script reads a text file containing user data (username, password, group, and additional info) and creates user accounts accordingly.
#It uses pre-hashed passwords and forces users to change their passwords upon first login.
#
#Usage:
#	./bulk_usr.sh <input_file>
#		- <input_file>: A text file containing user details in the format:
#		username;password;group;additional_info
#		- Example: John_Doe;Password123;Redteam;John_Doe
#
#Requirements:
#		- The script must be run with root priveleges (e.g., using sudo) to create users and groups.
#		- The input file should not contain empty lines or improperly formatted entries.
#		- Passwords must be pre-hashed using 'openssl passwd -6'.
#
#Author: Dylan A. Miller
#Date: 2024
#
#Exit codes:
#	0 - Script ran successfully.
#	1 - Input file missing or incorrect.
#	2 - Script not run as root.
#	3 - Failed to create users or groups.

if [[ $EUID -ne 0 ]];then
	echo "Error: This script must be run as root. Use sudo." >$2
	exit 2
fi

if [[ $# -ne 1 ]];then
	echo "Usage: $0 ./users.txt"
	exit 1
fi

INPUT_FILE=$1

if [[ ! -f $INPUT_FILE ]];then
	echo "Error: File $INPUT_FILE does not exist."
	exit 1
fi

LOG_FILE="user_creation.log"

echo "Starting user creation process...($(date))" > "$LOG_FILE"

while IFS=";" read -r username hashed_password group additional_info;do	

	[[ -z "$username" || $username == \#* ]] && continue
	echo "Parsed Fields:"
	echo "Username: $username"
	echo "Hashed Password: $hashed_password"
	echo "Group $group"
	echo "Additional Info: $additional_info"

	if [[ -z "$username" || -z "$hashed_password" || -z "$group" ]];then
	echo "Error: Malformed line - '$username;$hashed_password;$group:$additional_info'. Skipping." | tee -a "$LOG_FILE"
	continue
fi
	
echo "Processing user: $username"
echo "Group: $group"

if ! getent group "$group" > /dev/null 2>&1;then
		echo "Group '$group' does not exist. Creating it..." | tee -a "$LOG_FILE"
		groupadd "$group"
	if [[ $? -ne 0 ]];then
		echo "Error: Failed to create group '$group'. Skipping user '$username'." | tee -a "$LOG_FILE"
		continue
	fi
fi

if id "$username" > /dev/null 2>&1;then
	echo "User '$username' already exists. Skipping." | tee -a "$LOG_FILE"
	continue
fi

useradd -m -g "$group" -c "$additional_info" "$username"
if [[ $? -eq 0 ]];then
	echo "$username:$hashed_password" | chpasswd -e

	chage -d 0 "$username"

	echo "User '$username' created successfully. Password change enforced at first login." | tee -a "$LOG_FILE"
else
	echo "Error: Failed to create user $username'." | tee -a "$LOG_FILE"
fi
done < "$INPUT_FILE"

echo "User creation process completed. Log saved to $LOG_FILE."
