# upload-conference-from-usb
Upload conference from USB stick ou DVD to remote server

### install requirements on server and laptop
$ apt-get install -y ssh rsync

or

$ yum -y install openssh-server openssh-clients rsync

### run the script on laptop (client machine)
./upload-conf.sh

### bash notes
- script detect's new usb stick inserted
- in dvd case assume the drive is /dev/sr0
- the name of conference and year will be used on target folders

### ansible notes
the playbook 'dir-upload.yml' assume your drive is mounted at /media/new-conf
