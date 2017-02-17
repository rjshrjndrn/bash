#################################################
#
# This is a simple script for staging uploading
# Created By Rajesh Rajendran <rajesh@lukup.com>
#
#################################################

#!/bin/bash
set -e

tomcat_path="/usr/share/apache-tomcat-7.0.73/webapps"

#echo -e "\nTHIS SCRIPT IS FOR UPLOADING WAR FILES TO TESTING SERVER !!!\n\n\tIF YOU WANT TO CANCEL PRESS CTRL+C IN\n "

########################
# reading user choice
########################

function user_choice {
#waiting for user break

        echo -e "1\tportal\n2\tcrm\n3\tmpsubscribe\n4\tsms\n"
        read choice
	if [ $choice -gt 4 ];then
		echo -e " \n you are uploading to the server so please THINK before DO \n\tWR0N6 CH0|C3 !!!\n "
		sleep 1
		clear
		user_choice
	fi	
        echo -e "\nenter the file name\n"
        read name
        echo $(pwd)"/"$name

}

#####################
#choice selection
#####################

name=$1

function choice_selection {
# assigning choice
	case $1 in
		'portal.war' )
			choice=1
			;;
		'crmportal.war' )
			choice=2
			;;
		'mpsubscribe.war' )
			choice=3
			;;
		'SMS.war' )
			choice=4
			;;
		*)
			if [ ! -f $1 ];then
				echo -e "\nFILE NOT FOUND\n"
			else
				echo -e "\nENTER THE CORRECT FILE NAME\n"
			fi
			echo -e "\nUSAGE staging_upload <filename> or staging_upload\n\n"
			exit 1
			;;
			esac
}

#######################
#checkig for arguments
#######################

if [ $# -ne 0 ]; then
	choice_selection $1
else 
	user_choice
fi

################
#checking backup
################

echo "choice=$choice"
echo "name=$name"
echo -e "\nchecking for backup\n"
ssh -n staging.lukup.com backup_helper

#################
#uploading files
#################

rsync -avz $name "staging.lukup.com:$tomcat_path/"

##########################
#changing configurations
##########################

echo -e "\nchanging configurations \n"
ssh -n staging.lukup.com conf_changer $choice

#######################################
#waiting for user to intercept restart 
#######################################

echo -e "\n if you dont want to restart the server please press CTRL+C in\n"
for i in  $(seq 5 -1 1);
do
echo -e " $i \c"
sleep 1s
done
echo -e "\n"

##########################
# restarting tomcat
##########################

ssh -n staging.lukup.com /root/restart.sh
sleep 3s
ssh -n staging.lukup.com tail -f $tomcat_path/../logs/catalina.out
