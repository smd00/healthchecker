#!/bin/bash --login

# set -x # print all executed commands

echo "" && echo "############################################" 

datetime=$(date '+%Y%m%d-%H%M%S')
signature="${datetime}-archive"

logs_path=~/logs
archive_path=${logs_path}/archive
archive_destination_path=${archive_path}/${datetime}-logs.tar.gz

# chmod a+rwx ${​​logs_path}

mkdir -p ${archive_path}
touch ${archive_destination_path}
echo "archive_destination_path: ${archive_destination_path}"

compress () {
    # $1 = exclude
    # $2 = destination
    # $3 = source

    tar --exclude=$1 -zcvf $2 $3
}

compress_DefaultLogFolder () {
    compress ${archive_path} ${archive_destination_path} ${logs_path}
} 

emptyFile () {
    # $1 = path

    : > $1
} 

emptyLogFiles () {
    emptyFile ${logs_path}/error.log
    emptyFile ${logs_path}/cron_error.log
    emptyFile ${logs_path}/access.log
}

deleteFiles () {
    # $1 = path
    # $2 = older than (days)
    # $3 = file name

    find $1 -type f -mtime +$2 -name $3 -execdir rm -- '{}' \;
}

deleteOldLogs_Archives () {
    deleteFiles ${archive_path} 7 '*.tar.gz'
}

compress_DefaultLogFolder
emptyLogFiles
deleteOldLogs_Archives