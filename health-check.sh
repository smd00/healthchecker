#!/bin/bash --login

########### vars (see .env file)
source $SMDHC_SOURCE/.env

datetime=$(date '+%Y%m%d-%H%M%S')
signature="${datetime}-DM-healthcheck"

healthchecks_destination_path=${SMDHC_OUTPUT_HEALTHCHECKS_FOLDER_PATH}/${datetime}.log
archive_destination_path=${SMDHC_OUTPUT_ARCHIVE_FOLDER_PATH}/${datetime}-production-log.tar.gz

########### create folders and files
mkdir -p ${SMDHC_OUTPUT_FOLDER_PATH}
mkdir -p ${SMDHC_OUTPUT_HEALTHCHECKS_FOLDER_PATH}
mkdir -p ${SMDHC_OUTPUT_ARCHIVE_FOLDER_PATH}

touch ${healthchecks_destination_path}
touch ${archive_destination_path}

########### add signature to log files
# find ${SMDHC_CLIENT_LOG_FOLDER_PATH}/*.output -exec sh -c 'echo healthcheck ${(date)} >> ${0}' {} \;
# echo ${signature} >> ${SMDHC_CLIENT_LOG_FILE_PATH}

########### print info to healthchecks file
echo "" >> ${healthchecks_destination_path}
echo "############################################" >> ${healthchecks_destination_path}
echo ${signature} >> ${healthchecks_destination_path}
echo "" >> ${healthchecks_destination_path}
df -h . ${SMDHC_CLIENT_LOG_FOLDER_PATH} >> ${healthchecks_destination_path}
echo "" >> ${healthchecks_destination_path}
tail ${SMDHC_CLIENT_LOG_FILE_PATH} >> ${healthchecks_destination_path}
cat ${healthchecks_destination_path}

########### archive log and empty file
tar --exclude=${archive_destination_path} -zcvf ${archive_destination_path} ${SMDHC_CLIENT_LOG_FILE_PATH}
: > ${SMDHC_CLIENT_LOG_FILE_PATH}

########### copy log to S3 (need to configure IAM role first)
# aws s3 ls

########### send health report email
python ${SMDHC_SOURCE_SEND_EMAIL_SCRIPT} ${healthchecks_destination_path}