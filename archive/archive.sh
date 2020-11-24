#!/bin/bash --login

set -x # print all executed commands

########### vars (see .env file)
echo "" && echo "############################################" 

datetime=$(date '+%Y%m%d-%H%M%S')
signature="${datetime}-archive"

logs_path=~/logs
archive_path=${logs_path}/archive
healthchecks_destination_path=${archive_path}/${datetime}.log
archive_destination_path=${archive_path}/${datetime}-logs.tar.gz

########### create files
touch ${healthchecks_destination_path}
echo "healthchecks_destination_path: ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
touch ${archive_destination_path}
echo "archive_destination_path: ${archive_destination_path}" >> ${healthchecks_destination_path}

compress () {
    # $1 = exclude
    # $2 = destination
    # $3 = source

    tar --exclude=$1 -zcvf $2 $3 #>> ${healthchecks_destination_path}
}

compress_DefaultLogFolder () {
    compress ${archive_path} ${archive_path} ${logs_path} >> ${healthchecks_destination_path}
} 

emptyFile () {
    # $1 = path

    : > $1 >> ${healthchecks_destination_path}
} 

emptyLogFiles () {
    emptyFile ${logs_path}/error.log
    emptyFile ${logs_path}/cron_error.log
    emptyFile ${logs_path}/access.log
}

deleteOldFiles () {
    # $1 = path
    # $2 = older than (days)
    # $3 = file name

    find $1 -type f -mtime +$2 -name $3 -execdir rm -- '{}' \; >> ${healthchecks_destination_path}
}

deleteOldLogs_Archives () {
    # echoNewLine
    # echo "> function deleteOldLogs_SmdhcHealthchecks" >> ${healthchecks_destination_path}

    deleteOldFiles ${archive_path} 7 '*.log' >> ${healthchecks_destination_path}
    deleteOldFiles ${archive_path} 7 '*.tar.gz' >> ${healthchecks_destination_path}
}

compress_DefaultLogFolder
emptyLogFiles
deleteOldLogs_Archives

cat ${healthchecks_destination_path}