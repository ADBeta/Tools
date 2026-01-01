#!/bin/sh
################################################################################
# SMB Share mounting script version 5.0
# ADBeta(c)    29 Jun 2025
################################################################################

#Define SMB Username and password
smb_uname="server"
smb_paswd="password"

#Define System Username, UID and GID
_user="$(id -u -n)"
_uid="$(id -u)"
_gid="$(id -g)"

#Define Mount point locations
mount_root=/home/$_user

SHRD_DIR=$mount_root/Shared
MDIA_DIR=$mount_root/Media
ARCH_DIR=$mount_root/Archive
JORD_DIR=$mount_root/Jordan
DEVL_DIR=$mount_root/Development

##--------------------##

#Define samba share names and mountpoints. Both are indexed together, must match!
smb_shares=("Shared" "Media" "Archive" "Jordan" "Development")
mount_point=($SHRD_DIR $MDIA_DIR $ARCH_DIR $JORD_DIR $DEVL_DIR)

##--------------------##

#Mount function to make configuration easier
Mount () {
	#Arg1 = Samba share name eg. Shared or Media   Arg2 = Mount point
	#If mount point doesn't exist, make it
	if [ ! -d $2 ]; then
		echo "Creating directory $2"
		mkdir $2
		chown "$_uid:$_gid" "$2"
	fi
		
	#Mount the samba share to the mount point now it is safe to do so
	sudo mount -t cifs -o vers=3.0,mfsymlinks,soft,guest,uid=$_uid,gid=$_gid "//192.168.1.250/$1" $2
}

##--------------------##

#Unmount function
Unmount () {
	#Arg1 = Mount point name
	sudo umount -l $1
}

###--- User Input Handling --##
#Default if no specific action is specified 
if [ $# -eq 0 ]; then
	Mount "Shared" $SHRD_DIR
	Mount "Media" $MDIA_DIR
	Mount "Development" $DEVL_DIR
	exit
fi

##--------------------##

#If command given is either -u or -m 
if [ "$1" = "-u" ] || [ "$1" = "-m" ]; then 

	#share_match=false #Matching name flag
	input=$2 #Set input variable to 2nd arg
	
	
	#Special case for 'all' mount or unmount
	if [ "$input" = "all" ]; then
		#Go through all mountpoints and shares
		for index in "${!smb_shares[@]}"; do	
			
			#Set share name from index
			share="${smb_shares[index]}"
			#Set mount from index
			mount="${mount_point[index]}"
				
			#If mount operation is requested
			if [ "$1" = "-m" ]; then
				Mount $share $mount
			fi
			
			#if unmount is requested
			if [ "$1" = "-u" ]; then
				Unmount $mount
			fi
		
		done
		
		#After completing the requested task, exit
		exit
	fi
	
	#Loop through all allowed share names to see if input is valid.
	for index in "${!smb_shares[@]}"; do
		
		#Set share name from index for matching
		share="${smb_shares[index]}"
		
		#If input matches a share name, set the flag and exit
		if [ "$input" = "$share" ]; then
			
			#Set mount variable to the indexed variable in mount_points
			mount="${mount_point[index]}"
			
			#If mount operation is requested
			if [ "$1" = "-m" ]; then
				Mount $input $mount
			fi
			
			#if unmount is requested
			if [ "$1" = "-u" ]; then
				Unmount $mount
			fi
			
			#After completing the requested task, exit
			exit
		fi
		
	done

	#if [ "$share_match" = "false" ]; then
	>&2 echo "error: \"$input\" is not a valid samba share"

#If command is anything but the known ones, must be an error. report and exit
else 
	>&2 echo "error: \"$1\" is not a valid command"
	exit
fi

