#!/bin/bash

MY_USER="your-user"
MY_SERVER="example.com"
STORAGE_FOLDER="/var/conferences"
SSH_OPTIONS="-e 'ssh' --rsync-path='sudo -S rsync'"

PARTITION_NUMBER="1"
DVD_DRIVE="sr0"
USB_DEVICE=$(dmesg | grep "Attached SCSI removable disk" | tail -n 1 | cut -d "]" -f 2 | cut -d "[" -f 2)

echo "Enter conf name? "
read -r CONF_NAME

echo "your drive? (dvd / usb)"
read -r YOUR_DRIVE

# Check if dir exist
if [ ! -d "/media/new-conf" ]
then
    sudo mkdir /media/new-conf
fi

# Set you drive 
if [ "$YOUR_DRIVE" == "usb" ]
then
    YOUR_DRIVE=$USB_DEVICE
elif [ "$YOUR_DRIVE" == "dvd" ]
then
    YOUR_DRIVE=$DVD_DRIVE
    PARTITION_NUMBER=""
fi

# check if drive is mounted
if mount | grep new-conf > /dev/null
then
    echo "/dev/${YOUR_DRIVE}${PARTITION_NUMBER} mounted :-)"
else
    sudo mount "/dev/${YOUR_DRIVE}${PARTITION_NUMBER}" /media/new-conf
fi

# “stty -echo”, “stty echo” used to disable the display of keyboard input,
# to prevent the sudo password from being displayed.
stty -echo; ssh ${MY_USER}@${MY_SERVER} sudo -S -v; stty echo

# rsync stuff to remote server
rsync -rxvH --links /media/new-conf/ ${MY_USER}@${MY_SERVER}:$STORAGE_FOLDER/"${CONF_NAME}"/ "$SSH_OPTIONS"

# send mail to admin
echo "finish copy :-)" | mail -s "conf: ${CONF_NAME} rsync finish" your-user@example.com

