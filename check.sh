#!/bin/bash --login

########### vars (see .env file)
echo ""
echo "############################################" 
SMDHC_SOURCE=$1
echo "> SMDHC_SOURCE: " ${SMDHC_SOURCE}
source ${SMDHC_SOURCE}/.env && source .env
export $(cat ${SMDHC_SOURCE}/.env | xargs) && export $(cat .env | xargs)
# echo "> SMDHC_OUTPUT_FOLDER_PATH: " $SMDHC_OUTPUT_FOLDER_PATH

datetime=$(date '+%Y%m%d-%H%M%S')
signature="${datetime}-SMDHC-healthcheck"

healthchecks_destination_path=${SMDHC_OUTPUT_HEALTHCHECKS_FOLDER_PATH}/${datetime}.log
archive_destination_path=${SMDHC_OUTPUT_ARCHIVE_FOLDER_PATH}/${datetime}-logs.tar.gz

########### create files
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

if [ "${SMDHC_CLIENT_NAME}" = "ETH" ]; then
    echo "" >> ${healthchecks_destination_path}
    echo "Block Number: " >> ${healthchecks_destination_path}
    ETH_URL=127.0.0.1:5011 && echo $((`curl --data '{"method":"eth_blockNumber","params":[],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST $ETH_URL | grep -oh "\w*0x\w*"`)) >> ${healthchecks_destination_path}
    echo "" >> ${healthchecks_destination_path}
elif [ "${SMDHC_CLIENT_NAME}" = "BTC" ]; then
    echo "" >> ${healthchecks_destination_path}
    echo "Block Number: " >> ${healthchecks_destination_path}
    bitcoin-cli getblockcount >> ${healthchecks_destination_path}
    echo "" >> ${healthchecks_destination_path}
fi

echo "" >> ${healthchecks_destination_path}
tail ${SMDHC_CLIENT_LOG_FILE_PATH} >> ${healthchecks_destination_path}
cat ${healthchecks_destination_path}

########### archive log and empty file
tar --exclude=${archive_destination_path} -zcvf ${archive_destination_path} ${SMDHC_CLIENT_LOG_FILE_PATH}
: > ${SMDHC_CLIENT_LOG_FILE_PATH}

########### copy log to S3 (need to configure IAM role first)
# aws s3 ls

########### send health report email
echo "> python" ${SMDHC_SOURCE}/${SMDHC_SOURCE_SEND_EMAIL_SCRIPT} ${healthchecks_destination_path}
python ${SMDHC_SOURCE}/${SMDHC_SOURCE_SEND_EMAIL_SCRIPT} ${healthchecks_destination_path}