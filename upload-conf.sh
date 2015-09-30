#!/bin/bash 

MY_USER="your-user"
MY_MAIL="your-user@example.com"
MY_SERVER="example.com"
STORAGE_FOLDER="/var/conferences"
MEDIA_NEW_CONF="/media/new-conf"

PARTITION_NUMBER="1"
DVD_DRIVE="sr0"
USB_DEVICE=$(dmesg | grep "Attached SCSI removable disk" | tail -n 1 | cut -d "]" -f 2 | cut -d "[" -f 2)

echo "Enter conf name? "
read -r CONF_NAME

echo "Enter conf year? "
read -r CONF_YEAR

echo "your drive? (dvd / usb)"
read -r YOUR_DRIVE

# Check if dir exist
if [ ! -d "${MEDIA_NEW_CONF}" ]
then
    sudo mkdir ${MEDIA_NEW_CONF}
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
    sudo mount "/dev/${YOUR_DRIVE}${PARTITION_NUMBER}" ${MEDIA_NEW_CONF}
fi

# “stty -echo”, “stty echo” used to disable the display of keyboard input,
# to prevent the sudo password from being displayed.
stty -echo; ssh ${MY_USER}@${MY_SERVER} sudo -S -v; stty echo

# rsync stuff to remote server
ssh ${MY_USER}@${MY_SERVER} "sudo mkdir $STORAGE_FOLDER/${CONF_NAME}/"
rsync -raxv -e "ssh" --rsync-path="sudo -S rsync" ${MEDIA_NEW_CONF}/ ${MY_USER}@${MY_SERVER}:$STORAGE_FOLDER/"${CONF_NAME}"/"${CONF_YEAR}"/
ssh ${MY_USER}@${MY_SERVER} "sudo chown -Rv -- www-data:sample $STORAGE_FOLDER/${CONF_NAME}/${CONF_YEAR}"

# send mail to admin
echo "finish copy :-)" | mail -s "conf: ${CONF_NAME} rsync finish" ${MY_MAIL}
