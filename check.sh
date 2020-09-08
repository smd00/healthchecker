#!/bin/bash --login

########### vars (see .env file)
echo "" && echo "############################################" 
SMDHC_SOURCE=$1
echo "> SMDHC_SOURCE: " ${SMDHC_SOURCE}

source ${SMDHC_SOURCE}/.env 
source .env

export $(cat ${SMDHC_SOURCE}/.env | xargs) 
export $(cat .env | xargs)

datetime=$(date '+%Y%m%d-%H%M%S')
signature="${datetime}-SMDHC-healthcheck"

healthchecks_destination_path=${SMDHC_OUTPUT_HEALTHCHECKS_FOLDER_PATH}/${datetime}.log
archive_destination_path=${SMDHC_OUTPUT_ARCHIVE_FOLDER_PATH}/${datetime}-logs.tar.gz

########### create files
touch ${healthchecks_destination_path}
touch ${archive_destination_path}

########### functions
echoNewLine() {
    echo "" >> ${healthchecks_destination_path}
}

compress () {
    # $1 = path

    echoNewLine
    echo "> function compress $1" >> ${healthchecks_destination_path}

    echo "  > tar $1 >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    tar $1 >> ${healthchecks_destination_path}
} 

emptyFile () {
    # $1 = path

    echoNewLine
    echo "> function emptyFile $1" >> ${healthchecks_destination_path}

    echoLsLah $1

    echo "  > : > $1 >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    : > $1 >> ${healthchecks_destination_path}

    echoLsLah $1
} 

emptyLogFiles () {
    # $1 = path

    echoNewLine
    echo "> function emptyLogFiles $1" >> ${healthchecks_destination_path}

    echoLsLah $1/*.log

    echo "  > find $1/*.log -exec sh -c '>"{}"' \; >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    find $1/*.log -exec sh -c '>"{}"' \; >> ${healthchecks_destination_path}

    echoLsLah $1/*.log
}

emptyOutputFiles () {
    # $1 = path

    echoNewLine
    echo "> function emptyOutputFiles $1" >> ${healthchecks_destination_path}

    echoLsLah $1/*.output

    echo "  > find $1/*.output -exec sh -c '>"{}"' \; >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    find $1/*.output -exec sh -c '>"{}"' \; >> ${healthchecks_destination_path}

    echoLsLah $1/*.output
}

work in progress
deleteOldFiles () {
    # $1 = path
    # $2 = older than
    # $3 = file name

    echoNewLine
    echo "> function deleteOldFiles $1 $2 $3" >> ${healthchecks_destination_path}

    echoLsLah $1

    echo "  > find $1 -type f -mtime +$2 -name $3 -execdir rm -- '{}' \; >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    find $1 -type f -mtime +$2 -name $3 -execdir rm -- '{}' \; >> ${healthchecks_destination_path}
    # find $1 -type f -mtime +30 -exec rm -f {} \;

    echoLsLah $1
}

deleteOldLogs_SmdhcArchive () {
    # $1 = path

    echoNewLine
    echo "> function deleteOldLogs_SmdhcArchive" >> ${healthchecks_destination_path}

    echoNewLine
    echo "  > deleteOldFiles ${SMDHC_OUTPUT_ARCHIVE_FOLDER_PATH} 14 '*.gz' >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    deleteOldFiles ${SMDHC_OUTPUT_ARCHIVE_FOLDER_PATH} 14 '*.gz' >> ${healthchecks_destination_path}
}

tailLogFile () {
    # $1 = path

    echoNewLine
    echo "> function tailLogFile $1" >> ${healthchecks_destination_path}

    echo "  > tail $1 >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    tail $1 >> ${healthchecks_destination_path}
}

tailLogFiles () {
    # $1 = path

    echoNewLine
    echo "> function tailLogFiles $1" >> ${healthchecks_destination_path}

    echo "  > tail $1/*.log >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    tail $1/*.log >> ${healthchecks_destination_path}
}

tailOutputFiles () {
    # $1 = path

    echoNewLine
    echo "> function tailOutputFiles $1" >> ${healthchecks_destination_path}

    echo "  > tail $1/*.output >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    tail $1/*.output >> ${healthchecks_destination_path}
}

tailAllFiles () {
    # $1 = path
    
    echoNewLine
    echo "> function tailAllFiles $1" >> ${healthchecks_destination_path}

    echo "  > tail $1/* >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    tail $1/* >> ${healthchecks_destination_path}

    # cd ${SMDHC_CLIENT_LOG_FOLDER_PATH}
    # ls | while read file; do tail -n 5 $file; done >> ${healthchecks_destination_path}
}

tailSyslog () {
    echoNewLine
    echo "> function tailSyslog" >> ${healthchecks_destination_path}

    echo "  > tail /var/log/syslog >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    tail /var/log/syslog >> ${healthchecks_destination_path}
}

echoLsLah () {
    # $1 = path

    echoNewLine
    echo "> function echoLsLah $1" >> ${healthchecks_destination_path}

    echo "  > ls -lah $1 >> ${healthchecks_destination_path}"
    ls -lah $1 >> ${healthchecks_destination_path}
}

echoTop () {
    echoNewLine
    echo "> function echoTop" >> ${healthchecks_destination_path}

    echo "  > top -b -n 1 >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    top -b -n 1 >> ${healthchecks_destination_path}
}

echoTopProcessName() {
    # $1 = process name 
    # $2 = n iterations

    echoNewLine
    echo "> function echoTopProcessName $1 $2" >> ${healthchecks_destination_path}

    echo "  > top -b -n $2 | grep $1 >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    top -b -n $2 | grep $1 >> ${healthchecks_destination_path}
}

echoDf () {
    # $1 = path

    echoNewLine
    echo "> function echoDf $1" >> ${healthchecks_destination_path}

    echo "  > df -h . $1 >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    df -h . $1 >> ${healthchecks_destination_path}
}

echoSignature () {
    echoNewLine
    echo "############################################" >> ${healthchecks_destination_path}
    echo ${signature} >> ${healthchecks_destination_path}
}

########### print info to healthchecks file
echoSignature

echoDf ${SMDHC_CLIENT_LOG_FOLDER_PATH}

TAR_ARGS="--exclude=${archive_destination_path} -zcvf ${archive_destination_path} ${SMDHC_CLIENT_LOG_FILE_PATH}"

if [ "${SMDHC_CLIENT_NAME}" = "ETH" ]; then
    echoNewLine
    echo "> ETH Block Number: " >> ${healthchecks_destination_path}
    ETH_URL=127.0.0.1:5011 && echo $((`curl --data '{"method":"eth_blockNumber","params":[],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST $ETH_URL | grep -oh "\w*0x\w*"`)) >> ${healthchecks_destination_path}
    
    tailLogFile ${SMDHC_CLIENT_LOG_FILE_PATH}
    
    tailSyslog

    echoTopProcessName "parity" 10

    compress ${TAR_ARGS}
    emptyFile ${SMDHC_CLIENT_LOG_FILE_PATH}

elif [ "${SMDHC_CLIENT_NAME}" = "BTC" ]; then
    echoNewLine
    echo "> BTC Block Number: " >> ${healthchecks_destination_path}
    /usr/bin/bitcoin-cli -datadir=/dmdata/ getblockcount >> ${healthchecks_destination_path}

    tailLogFile ${SMDHC_CLIENT_LOG_FILE_PATH}
    tailLogFile ${SMDHC_CLIENT_LOG_FILE_PATH_2}    

    tailSyslog

    echoTopProcessName "bitcoind" 10

    compress ${TAR_ARGS}
    emptyFile ${SMDHC_CLIENT_LOG_FILE_PATH}

elif [ "${SMDHC_CLIENT_NAME}" = "TBOT" ]; then
    # echo "> pm2 prettylist: " >> ${healthchecks_destination_path}
    # pm2 prettylist >> ${healthchecks_destination_path}
    # echoNewLine

    tailLogFiles ${SMDHC_CLIENT_LOG_FOLDER_PATH}

    compress ${TAR_ARGS}

elif [ "${SMDHC_CLIENT_NAME}" = "DAEMONS" ]; then
    tailOutputFiles ${SMDHC_CLIENT_LOG_FOLDER_PATH}
    tailLogFiles ${SMDHC_CLIENT_LOG_FOLDER_PATH}
    
    TAR_ARGS="--exclude=${SMDHC_OUTPUT_FOLDER_PATH} -zcvf ${archive_destination_path} ${SMDHC_CLIENT_LOG_FOLDER_PATH}"
    compress ${TAR_ARGS}

    emptyLogFiles ${SMDHC_CLIENT_LOG_FOLDER_PATH}
    emptyOutputFiles ${SMDHC_CLIENT_LOG_FOLDER_PATH}

    echoNewLine
    echo "> cd /home/root/app/ && RAILS_ENV=production && /home/root/.rbenv/shims/rake daemons:status >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    cd /home/root/app/ && RAILS_ENV=production && /home/root/.rbenv/shims/rake daemons:status >> ${healthchecks_destination_path}
elif [ "${SMDHC_CLIENT_NAME}" = "RAILS" ]; then
    tailLogFile ${SMDHC_CLIENT_LOG_FILE_PATH}

    TAR_ARGS="--exclude=${SMDHC_OUTPUT_FOLDER_PATH} -zcvf ${archive_destination_path} ${SMDHC_CLIENT_LOG_FOLDER_PATH}"
    compress ${TAR_ARGS}

    emptyFile ${SMDHC_CLIENT_LOG_FILE_PATH}
fi

deleteOldLogs_SmdhcArchive

echoTop

cat ${healthchecks_destination_path}

########### copy log to S3 (need to configure IAM role first)
# aws s3 ls

########### send health report email
echoNewLine
echo "> python ${SMDHC_SOURCE}/${SMDHC_SOURCE_SEND_EMAIL_SCRIPT} ${healthchecks_destination_path} >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
python ${SMDHC_SOURCE}/${SMDHC_SOURCE_SEND_EMAIL_SCRIPT} ${healthchecks_destination_path} >> ${healthchecks_destination_path}