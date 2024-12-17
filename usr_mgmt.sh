#!/bin/bash
#this is a menu designed for an administrator
#this menu provides simplified user management capabilities
#it also comes equipped with a function to create a backup of any user's home directory 
#AUTHOR Dylan A. Miller | 2024


chosen=0
while [ $chosen -lt 9 ]
do


echo "Options:"
echo "1. Create a compressed backup of any user's home directory. Stamp: date, time, user."
echo "2. Generate Password."
echo "3. Add user to the system." 
echo "4. Delete user from the system."
echo "5. View all users and hashed passwords."
echo "6. Lock user account."
echo "7. Unlock user account."
echo "8. Reset user password."
echo "9. Identitfy users with sudo privileges."
echo "10. Exit."


echo -n
	echo "Choose an option between 1-10.	"
read chosen

if [ $chosen -eq 1 ];then
	echo "You chose Option 1: Create a compressed backup of any user's home directory."
read -p "Press ENTER to continue..."
	echo "Which user's home directory would you like to create a backup of?"
read username
mkdir /tmp/$username
OF=/tmp/$username/backup-$(date +%Y%m%d%I%M)-$username.tgz
sudo tar -czvf $OF /home/$username
mv $OF ~
rmdir /tmp/$username
	echo "The backup of $username home directory has been created."
echo -n
	echo "It can be found in your home directory."
read -p "Press ENTER to continue..."

elif [ $chosen -eq 2 ];then
        echo "You chose Option 2: Generate Password."
read -p "Press ENTER to continue..."
password=$(< /dev/urandom tr -dc 'A-Za-z0-9_!@#%^&*()' | head -c 12)
        echo "Generated password: $password"
read -p "Press ENTER to continue..."

elif [ $chosen -eq 3 ];then 
        echo "You chose Option 3: Add user to the system."
read -p "Press ENTER to continue..."
echo -n
	echo "Note: You may want to use 'Option 3: Generate Password' to create a secure password before using this option."
read -p "Press ENTER to continue..."
        echo "Enter the username for the new user:"
read username
sudo useradd -m $username
sudo passwd $username
echo -n
        echo "The user $username has been created."
read -p "Press ENTER to continue..."

elif [ $chosen -eq 4 ];then
	echo "You chose Option 4: Delete user from the system."
read -p "Press ENTER to continue..."
echo -n
	echo "Note: This function also deletes the specified user's home directory."
read -p "Press ENTER to continue..."
echo -n 
	echo "Enter the username that you would like to delete:"
read username
sudo userdel -r $username
	echo "If you entered a valid username, it has been successfully deleted. If the user remains, check username carefully and try again."
read -p "Press ENTER to continue..."

elif [ $chosen -eq 5 ];then
	echo "You chose Option 5: View all users and hashed passwords."
read -p "Press ENTER to continue..."
sudo cat /etc/shadow
read -p "Press ENTER to continue..."

elif [ $chosen -eq 6 ];then
	echo "You chose Option 6: Lock user account."
read -p "Press ENTER to continue..."
echo -n
	echo "Enter the user whose account you would like to lock."
read username
sudo usermod -L $username
	echo "The user account $username has been locked."
read -p "Press ENTER to continue..."

elif [ $chosen -eq 7 ];then
	echo "You chose Option 7: Unlock user account."
read -p "Press ENTER to continue..."
echo -n
	echo "Enter the user whose account you would like to unlock."
read username
sudo usermod -U $username
	echo "The user account $username has been unlocked."
read -p "Press ENTER to continue..."


elif [ $chosen -eq 8 ];then
	echo "You chose Option 8: Reset user password."
read -p "Press ENTER to continue..."
echo -n
	echo "Note: Resetting the password will also unlock this user's account."
	echo "Enter the user whose password you would like to reset."
read username
sudo passwd $username
	echo "The password for $username has been reset. If account was previously locked, it is now unlocked."
read -p "Press ENTER to continue..."

elif [ $chosen -eq 9 ];then
	echo "You chose Option 9: Identify users with sudo privileges."
read -p "Press ENTER to continue..."
getent group sudo
read -p "Press ENTER to continue..."
./usr_mgmt.sh

elif [ $chosen -eq 10 ];then
	echo "You chose to exit."
read -p "Press ENTER to continue..."
exit

else
	echo "You did not enter a valid option, you must choose an option number between 1-10. Run the file and try again."

fi

done
