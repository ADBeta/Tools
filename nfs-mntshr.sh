#!/bin/sh
################################################################################
# NFS Share Mounting Script    Version 1.0
# (c)ADBeta    Jan 2026
################################################################################

# Define System Username, UID and GID
_user="$(id -u -n)"
_uid="$(id -u)"
_gid="$(id -g)"

# Define Mountpoint Directories
MNT_ROOT="/home/$_user"

MNT_MED="$MNT_ROOT/Media"
MNT_JDN="$MNT_ROOT/Jordan"
MNT_ARC="$MNT_ROOT/Archive"
MNT_SHR="$MNT_ROOT/Shared"
MNT_DEV="$MNT_ROOT/Development"

##--------------------##


# Define NFS and Mountpoints into arrays. These MUST be 1:1 aligned
# All MUST be at the end
SHARES=("Media" "Jordan" "Archive" "Shared" "Development" "All")
MNTPNT=($MNT_MED $MNT_JDN $MNT_ARC $MNT_SHR $MNT_DEV)

##--------------------##


# Mount the given NFS Share to the given Mountpoit
# @param $1 NFS Share Name
# @param $2 Local Mountpoint
Mount () {
	local NFSSHR="$1"
	local MNTPNT="$2"

	# If the Mountpoint directory doesn't exist, make it
	if [ ! -d "$MNTPNT" ]; then
		echo "Creating Directory $MNTPNT"
		mkdir -p "$MNTPNT"
		chown "$_uid:$_gid" "$MNTPNT"
	fi

	# Exit early if already mounted
	if mountpoint -q "$MNTPNT"; then
		echo "$MNTPNT is already Mounted."
		return 0
	fi
		
	# Mount the NFS Share to the Directory
	if sudo mount -t nfs -o rw,vers=4 "192.168.1.250:$NFSSHR" "$MNTPNT"; then
		echo "Mounted $NFSSHR to $MNTPNT Successfully."
		return 0
	else 
		echo "Failed to mount $NFSSHR to $MNTPNT."
		return 1
	fi
}


# Unmount the given Mountpoint
# @param $1 Mountpoint
Unmount () {
	if sudo umount -l "$1"; then
		echo "Unmounted $1 Successfully."
		return 0
	fi
}


# Prints the INDEX of the given Share in the SHARES Array, "-1" is it is invalid
# @param $1 String to compare
# @return 0 if Found, 1 if Not Found. Echoes its INDEX or -1 if not found
Get_Share_Index () {
	local STRING="$1"
	local INDEX=0

	for SHARE in "${SHARES[@]}"; do
		if [[ "$SHARE" == "$STRING" ]]; then
			echo "$INDEX"
			return 0
		fi
		((INDEX++))
	done

	# Not found
	echo "-1"
	return 1
}





###--- Main ---##
# The only valid number of operands is 0, or 2, for example "-m all"
if [[ $# -ne 0 && $# -ne 2 ]] then
	echo -e "Usage:

mntshr                - Mounts the default group of Shares
mntshr -m all         - Mounts all known Shares
mntshr -u all         - Unmount all known Shares

mntshr -m share_name  - Mounts the given Share to the given Mountpoint
mntshr -u share_name  - Unmounts the given Mountpoint

mntshr -l shares      - lists all known Share Names"

	exit 1
fi

# Get the given NFS and Mountpoint - are blank if not given at calltime
OPERATION="$1"
SHARENAME="$2"


# If no specific Operation has been requested, mount the default Shares
if [ -z "$OPERATION" ]; then
	Mount "Shared"      $MNT_SHR
	Mount "Media"       $MNT_MED
	Mount "Development" $MNT_DEV
	exit 0
fi


# List the Shares    TODO: Add support for other listings if needed later
if [[ "$OPERATION" == "-l" ]]; then
	echo "Availabe Shares: ${SHARES[@]}"
	exit 0
fi


# By this point the Command given is a 2 operand -m or -u. Find the given Share INDEX
INDEX=$(Get_Share_Index "$SHARENAME")

if [[ "$INDEX" == "-1" ]]; then
	echo "Invalid Share. Use -l shares to see the available Shares"
	exit 1
fi
		

# If Mount operation:
if [[ "$OPERATION" == "-m" ]]; then
	
	# Special loop case for if "All" was selected
	if [[ "${SHARES[$INDEX]}" == "All" ]]; then
		for ((i=0; i<${#MNTPNT[@]}; i++)); do
			Mount "${SHARES[$i]}" "${MNTPNT[$i]}"
		done

	# Normal Single Share Mount routine
	else 	
		Mount "${SHARES[$INDEX]}" "${MNTPNT[$INDEX]}"
	fi

	exit 0
fi


# If Unmount operation:
if [[ "$OPERATION" == "-u" ]]; then
	
	# Special loop case for if "All" was selected
	if [[ "${SHARES[$INDEX]}" == "All" ]]; then
		for ((i=0; i<${#MNTPNT[@]}; i++)); do
			Unmount "${MNTPNT[$i]}"
		done

	# Normal Single Share Mount routine
	else 	
		Unmount "${MNTPNT[$INDEX]}"
	fi

	exit 0
fi


# If nothing has triggered an exit yet, the given Operation is invalid.
echo "Invalid Operation. Use -h to get usage info"
exit 1
