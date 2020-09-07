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

########### print info to healthchecks file
echo "" >> ${healthchecks_destination_path}
echo "############################################" >> ${healthchecks_destination_path}
echo ${signature} >> ${healthchecks_destination_path}
echo "" >> ${healthchecks_destination_path}
echo "> df -h . ${SMDHC_CLIENT_LOG_FOLDER_PATH} >> ${healthchecks_destination_path}"
df -h . ${SMDHC_CLIENT_LOG_FOLDER_PATH} >> ${healthchecks_destination_path}

echo "" >> ${healthchecks_destination_path}
echo "> tail ${SMDHC_CLIENT_LOG_FILE_PATH} >> ${healthchecks_destination_path}"
tail ${SMDHC_CLIENT_LOG_FILE_PATH} >> ${healthchecks_destination_path}

echo "" >> ${healthchecks_destination_path}
echo "> tail /var/log/syslog >> ${healthchecks_destination_path}"
tail /var/log/syslog >> ${healthchecks_destination_path}

TAR_ARGS="--exclude=${archive_destination_path} -zcvf ${archive_destination_path} ${SMDHC_CLIENT_LOG_FILE_PATH}"
EMPTY_LOG=": > ${SMDHC_CLIENT_LOG_FILE_PATH}"

if [ "${SMDHC_CLIENT_NAME}" = "ETH" ]; then
    echo "" >> ${healthchecks_destination_path}
    echo "> ETH Block Number: " >> ${healthchecks_destination_path}
    ETH_URL=127.0.0.1:5011 && echo $((`curl --data '{"method":"eth_blockNumber","params":[],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST $ETH_URL | grep -oh "\w*0x\w*"`)) >> ${healthchecks_destination_path}
    echo "" >> ${healthchecks_destination_path}

    echo "> top -b -n 10 | grep parity >> ${healthchecks_destination_path}"
    top -b -n 10 | grep parity >> ${healthchecks_destination_path}
    echo "" >> ${healthchecks_destination_path}
elif [ "${SMDHC_CLIENT_NAME}" = "BTC" ]; then
    echo "" >> ${healthchecks_destination_path}
    echo "> BTC Block Number: " >> ${healthchecks_destination_path}
    /usr/bin/bitcoin-cli -datadir=/dmdata/ getblockcount >> ${healthchecks_destination_path}
    echo "" >> ${healthchecks_destination_path}

    echo "> tail ${SMDHC_CLIENT_LOG_FILE_PATH_2} >> ${healthchecks_destination_path}"
    tail ${SMDHC_CLIENT_LOG_FILE_PATH_2} >> ${healthchecks_destination_path}
    echo "" >> ${healthchecks_destination_path}

    echo "> top -b -n 10 | grep bitcoind >> ${healthchecks_destination_path}"
    top -b -n 10 | grep bitcoind >> ${healthchecks_destination_path}
    echo "" >> ${healthchecks_destination_path}
elif [ "${SMDHC_CLIENT_NAME}" = "TBOT" ]; then
    echo "" >> ${healthchecks_destination_path}

    # echo "> pm2 prettylist: " >> ${healthchecks_destination_path}
    # pm2 prettylist >> ${healthchecks_destination_path}
    # echo "" >> ${healthchecks_destination_path}

    echo "> tail ${SMDHC_CLIENT_LOG_FILE_PATH_2} >> ${healthchecks_destination_path}"
    tail ${SMDHC_CLIENT_LOG_FILE_PATH_2} >> ${healthchecks_destination_path}
elif [ "${SMDHC_CLIENT_NAME}" = "DAEMONS" ]; then
    echo "" >> ${healthchecks_destination_path}

    # cd ${SMDHC_CLIENT_LOG_FOLDER_PATH}
    # ls | while read file; do tail -n 5 $file; done >> ${healthchecks_destination_path}
    
    TAR_ARGS="--exclude=${SMDHC_OUTPUT_FOLDER_PATH} -zcvf ${archive_destination_path} ${SMDHC_CLIENT_LOG_FOLDER_PATH}"

    EMPTY_LOG=""
    find ${SMDHC_CLIENT_LOG_FOLDER_PATH}/*.output -exec sh -c '>"{}"' \;
    find ${SMDHC_CLIENT_LOG_FOLDER_PATH}/*.log -exec sh -c '>"{}"' \;

    /home/root/.rbenv/shims/rake daemons:status >> ${healthchecks_destination_path}
    echo "" >> ${healthchecks_destination_path}
fi

echo "" >> ${healthchecks_destination_path}
echo "> top -b -n 1" >> ${healthchecks_destination_path}
top -b -n 1 >> ${healthchecks_destination_path}

cat ${healthchecks_destination_path}

########### archive log and empty file
echo "> tar ${TAR_ARGS}"
tar ${TAR_ARGS}
${EMPTY_LOG}

########### copy log to S3 (need to configure IAM role first)
# aws s3 ls

########### send health report email
echo "> python ${SMDHC_SOURCE}/${SMDHC_SOURCE_SEND_EMAIL_SCRIPT} ${healthchecks_destination_path}"
python ${SMDHC_SOURCE}/${SMDHC_SOURCE_SEND_EMAIL_SCRIPT} ${healthchecks_destination_path}