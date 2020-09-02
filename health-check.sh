#!/bin/bash --login

########### vars
datetime=$(date '+%Y%m%d-%H%M%S')
signature="${datetime}-DM-healthcheck"

log_folder_path=/home/root/app/log
log_file_path=${log_folder_path}/production.log

healthchecks_path=${log_folder_path}/healthchecks
healthchecks_file=${healthchecks_path}/${datetime}.log

archive_folder_path=${log_folder_path}/archive
archive_destination_path=${archive_folder_path}/${datetime}-production-log.tar.gz
archive_source_path=${log_folder_path}/production.log

health_folder_path=/home/root/app/health
send_email_script=${health_folder_path}/send-email.py

########### create healthchecks folder and file
mkdir -p ${healthchecks_path}
touch ${healthchecks_file}

########### add signature to log files
# find ${log_folder_path}/*.output -exec sh -c 'echo healthcheck ${(}date) >> ${0}' {} \;
# find ${log_file_path} -exec sh -c 'echo healthcheck ${datetime} >> ${0}' {} \;
# echo ${signature} >> ${log_file_path}

########### print info to healthchecks file
echo "" >> ${healthchecks_file}
echo "############################################" >> ${healthchecks_file}
echo ${signature} >> ${healthchecks_file}
echo "" >> ${healthchecks_file}
df -h . ${log_folder_path} >> ${healthchecks_file}
echo "" >> ${healthchecks_file}
tail ${log_file_path} >> ${healthchecks_file}
cat ${healthchecks_file}

########### create archive folder and file
mkdir -p ${archive_folder_path}
touch ${archive_destination_path}

########### archive log and empty file
tar --exclude=${archive_destination_path} -zcvf ${archive_destination_path} ${archive_source_path}
: > ${archive_source_path}

########### copy log to S3 (need to configure IAM role first)
# aws s3 ls

########### send health report email
python ${send_email_script} ${healthchecks_file}