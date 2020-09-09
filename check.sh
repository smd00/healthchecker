#!/bin/bash --login

########### vars (see .env file)
echo "" && echo "############################################" 
SMDHC_SOURCE=$1
ignoreAlreadyRunCheck=$2
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

checkAlreadyRun() {
    echoNewLine
    echo "> function checkAlreadyRun" >> ${healthchecks_destination_path}

    earlierThanMins=60
    fileExistsCheck_script="find ${SMDHC_OUTPUT_HEALTHCHECKS_FOLDER_PATH} -name '*.log' -type f -cmin -$earlierThanMins -print"
    fileExistsCheck_Count_script="${fileExistsCheck_script} | wc -l"

    if [ ! -z "${ignoreAlreadyRunCheck}" ]; then
        echo "Ignoring fileExistsCheck_script (${fileExistsCheck_script})"  >> ${healthchecks_destination_path}
        return 0
    fi    

    echo "${fileExistsCheck_script}" >> ${healthchecks_destination_path}
    fileExistsCheck=$(eval ${fileExistsCheck_script}) >> ${healthchecks_destination_path}
    echo $fileExistsCheck >> ${healthchecks_destination_path}

    echo "${fileExistsCheck_Count_script}" >> ${healthchecks_destination_path}
    fileExistsCheck_Count=$(eval ${fileExistsCheck_Count_script}) >> ${healthchecks_destination_path}
    echo $fileExistsCheck_Count >> ${healthchecks_destination_path}

    if [ "${fileExistsCheck_Count}" != "1" ] ; then
        echo "Healthcheck already run in the last ${earlierThanMins} minutes." >> ${healthchecks_destination_path}
        exit 1
    fi
    echo "Ready to run Healthcheck." >> ${healthchecks_destination_path}
}

checkAlreadyRun

compress () {
    # $1 = exclude
    # $2 = destination
    # $3 = source

    echoNewLine
    echo "> function compress $1 $2 $3" >> ${healthchecks_destination_path}
    
    echoNewLine
    echo "  >> tar --exclude=$1 -zcvf $2 $3 >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    tar --exclude=$1 -zcvf $2 $3 >> ${healthchecks_destination_path}
} 

compress_DefaultLogFolder () {
    echoNewLine
    echo "> function compress_DefaultLogFolder" >> ${healthchecks_destination_path}
    
    echoNewLine
    echo "  >> compress ${SMDHC_OUTPUT_FOLDER_PATH} ${archive_destination_path} ${SMDHC_CLIENT_LOG_FOLDER_PATH} >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    compress ${SMDHC_OUTPUT_FOLDER_PATH} ${archive_destination_path} ${SMDHC_CLIENT_LOG_FOLDER_PATH} >> ${healthchecks_destination_path}
} 

compress_DefaultLogFile () {
    echoNewLine
    echo "> function compress_DefaultLogFile" >> ${healthchecks_destination_path}
    
    echoNewLine
    echo "  >> compress ${SMDHC_OUTPUT_FOLDER_PATH} ${archive_destination_path} ${SMDHC_CLIENT_LOG_FILE_PATH} >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    compress ${SMDHC_OUTPUT_FOLDER_PATH} ${archive_destination_path} ${SMDHC_CLIENT_LOG_FILE_PATH} >> ${healthchecks_destination_path}
} 

emptyFile () {
    # $1 = path

    echoNewLine
    echo "> function emptyFile $1" >> ${healthchecks_destination_path}

    echoLsLah $1

    echoNewLine
    echo "  >> : > $1 >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    : > $1 >> ${healthchecks_destination_path}

    echoLsLah $1
} 

emptyFile_DefaultLogFile () {
    echoNewLine
    echo "> function emptyFile_DefaultLogFile" >> ${healthchecks_destination_path}

    echoNewLine
    echo "  >> emptyFile ${SMDHC_CLIENT_LOG_FILE_PATH} >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    emptyFile ${SMDHC_CLIENT_LOG_FILE_PATH} >> ${healthchecks_destination_path}
} 

emptyLogFiles () {
    # $1 = path

    echoNewLine
    echo "> function emptyLogFiles $1" >> ${healthchecks_destination_path}

    echoLsLah $1

    echoNewLine
    echo "  >> find $1/*.log -exec sh -c '>"{}"' \; >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    find $1/*.log -exec sh -c '>"{}"' \; >> ${healthchecks_destination_path}

    echoLsLah $1
}

emptyOutputFiles () {
    # $1 = path

    echoNewLine
    echo "> function emptyOutputFiles $1" >> ${healthchecks_destination_path}

    echoLsLah $1

    echoNewLine
    echo "  >> find $1/*.output -exec sh -c '>"{}"' \; >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    find $1/*.output -exec sh -c '>"{}"' \; >> ${healthchecks_destination_path}

    echoLsLah $1
}

emptyLogFiles_DefaultLogFolder () {
    echoNewLine
    echo "> function emptyLogFiles_DefaultLogFolder" >> ${healthchecks_destination_path}

    echoNewLine
    echo "  >> emptyLogFiles ${SMDHC_CLIENT_LOG_FOLDER_PATH} >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    emptyLogFiles ${SMDHC_CLIENT_LOG_FOLDER_PATH} >> ${healthchecks_destination_path}
}

emptyOutputFiles_DefaultLogFolder () {
    echoNewLine
    echo "> function emptyOutputFiles_DefaultLogFolder" >> ${healthchecks_destination_path}

    echoNewLine
    echo "  >> emptyOutputFiles ${SMDHC_CLIENT_LOG_FOLDER_PATH} >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    emptyOutputFiles ${SMDHC_CLIENT_LOG_FOLDER_PATH} >> ${healthchecks_destination_path}
}

deleteOldFiles () {
    # $1 = path
    # $2 = older than (days)
    # $3 = file name

    echoNewLine
    echo "> function deleteOldFiles $1 $2 $3" >> ${healthchecks_destination_path}

    echoLsLah $1

    echoNewLine
    echo "  >> find $1 -type f -mtime +$2 -name $3 -execdir rm -- '{}' \; >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    find $1 -type f -mtime +$2 -name $3 -execdir rm -- '{}' \; >> ${healthchecks_destination_path}
    # find $1 -type f -mtime +30 -exec rm -f {} \;

    echoLsLah $1
}

deleteOldLogs_SmdhcArchive () {
    echoNewLine
    echo "> function deleteOldLogs_SmdhcArchive" >> ${healthchecks_destination_path}

    echoNewLine
    echo "  >> deleteOldFiles ${SMDHC_OUTPUT_ARCHIVE_FOLDER_PATH} 14 '*.gz' >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    deleteOldFiles ${SMDHC_OUTPUT_ARCHIVE_FOLDER_PATH} 14 '*.gz' >> ${healthchecks_destination_path}
}

deleteOldLogs_SmdhcHealthchecks () {
    echoNewLine
    echo "> function deleteOldLogs_SmdhcHealthchecks" >> ${healthchecks_destination_path}

    echoNewLine
    echo "  >> deleteOldFiles ${SMDHC_OUTPUT_HEALTHCHECKS_FOLDER_PATH} 186 '*.log' >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    deleteOldFiles ${SMDHC_OUTPUT_HEALTHCHECKS_FOLDER_PATH} 186 '*.log' >> ${healthchecks_destination_path}
}

tailLogFile () {
    # $1 = path

    echoNewLine
    echo "> function tailLogFile $1" >> ${healthchecks_destination_path}

    echoNewLine
    echo "  >> tail $1 >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    tail $1 >> ${healthchecks_destination_path}
}

tailLogFile_DefaultLogFile () {
    echoNewLine
    echo "> function tailLogFile_DefaultLogFile" >> ${healthchecks_destination_path}

    echoNewLine
    echo "  >> tailLogFile ${SMDHC_CLIENT_LOG_FILE_PATH} >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    tailLogFile ${SMDHC_CLIENT_LOG_FILE_PATH} >> ${healthchecks_destination_path}
}

tailLogFiles () {
    # $1 = path

    echoNewLine
    echo "> function tailLogFiles $1" >> ${healthchecks_destination_path}

    echoNewLine
    echo "  >> tail $1/*.log >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    tail $1/*.log >> ${healthchecks_destination_path}
}

tailOutputFiles () {
    # $1 = path

    echoNewLine
    echo "> function tailOutputFiles $1" >> ${healthchecks_destination_path}

    echoNewLine
    echo "  >> tail $1/*.output >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    tail $1/*.output >> ${healthchecks_destination_path}
}

tailLogFiles_DefaultLogFolder () {
    echoNewLine
    echo "> function tailLogFiles_DefaultLogFolder" >> ${healthchecks_destination_path}

    echoNewLine
    echo "  >> tailLogFiles ${SMDHC_CLIENT_LOG_FOLDER_PATH} >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    tailLogFiles ${SMDHC_CLIENT_LOG_FOLDER_PATH} >> ${healthchecks_destination_path}
}

tailOutputFiles_DefaultLogFolder () {
    echoNewLine
    echo "> function tailOutputFiles_DefaultLogFolder" >> ${healthchecks_destination_path}

    echoNewLine
    echo "  >> tailOutputFiles ${SMDHC_CLIENT_LOG_FOLDER_PATH} >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    tailOutputFiles ${SMDHC_CLIENT_LOG_FOLDER_PATH} >> ${healthchecks_destination_path}
}

tailAllFiles () {
    # $1 = path
    
    echoNewLine
    echo "> function tailAllFiles $1" >> ${healthchecks_destination_path}

    echoNewLine
    echo "  >> tail $1/* >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    tail $1/* >> ${healthchecks_destination_path}

    # cd ${SMDHC_CLIENT_LOG_FOLDER_PATH}
    # ls | while read file; do tail -n 5 $file; done >> ${healthchecks_destination_path}
}

tailSyslog () {
    echoNewLine
    echo "> function tailSyslog" >> ${healthchecks_destination_path}

    echoNewLine
    echo "  >> tail /var/log/syslog >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    tail /var/log/syslog >> ${healthchecks_destination_path}
}

echoLsLah () {
    # $1 = path

    echoNewLine
    echo "> function echoLsLah $1" >> ${healthchecks_destination_path}

    echoNewLine
    echo "  >> ls -lah $1 >> ${healthchecks_destination_path}"
    ls -lah $1 >> ${healthchecks_destination_path}
}

echoTop () {
    echoNewLine
    echo "> function echoTop" >> ${healthchecks_destination_path}

    echoNewLine
    echo "  >> top -b -n 1 >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    top -b -n 1 >> ${healthchecks_destination_path}
}

echoTopProcessName() {
    # $1 = process name 
    # $2 = n iterations

    echoNewLine
    echo "> function echoTopProcessName $1 $2" >> ${healthchecks_destination_path}

    echoNewLine
    echo "  >> top -b -n $2 | grep $1 >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    top -b -n $2 | grep $1 >> ${healthchecks_destination_path}
}

echoDf () {
    # $1 = path

    echoNewLine
    echo "> function echoDf $1" >> ${healthchecks_destination_path}

    echoNewLine
    echo "  >> df -h . $1 >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    df -h . $1 >> ${healthchecks_destination_path}
}

echoSignature () {
    echoNewLine
    echo "############################################" >> ${healthchecks_destination_path}
    echo ${signature} >> ${healthchecks_destination_path}
}

pm2_list () {
    echoNewLine
    echo "> function pm2_list" >> ${healthchecks_destination_path}

    echoNewLine
    echo "  >> pm2 list --no-color >> ${healthchecks_destination_path} " >> ${healthchecks_destination_path}
    pm2 list --no-color >> ${healthchecks_destination_path}
}

########### print info to healthchecks file
echoSignature

echoDf ${SMDHC_CLIENT_LOG_FOLDER_PATH}

if [ "${SMDHC_CLIENT_NAME}" = "ETH" ]; then
    echoNewLine
    echo "> ETH Block Number: " >> ${healthchecks_destination_path}
    ETH_URL=127.0.0.1:5011 && echo $((`curl --data '{"method":"eth_blockNumber","params":[],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST $ETH_URL | grep -oh "\w*0x\w*"`)) >> ${healthchecks_destination_path}
    
    tailLogFile_DefaultLogFile
    compress_DefaultLogFile
    emptyFile_DefaultLogFile
    
    tailSyslog
    echoTopProcessName "parity" 10

elif [ "${SMDHC_CLIENT_NAME}" = "BTC" ]; then
    echoNewLine
    echo "> BTC Block Number: " >> ${healthchecks_destination_path}
    /usr/bin/bitcoin-cli -datadir=/dmdata/ getblockcount >> ${healthchecks_destination_path}

    tailLogFile_DefaultLogFile
    compress_DefaultLogFile
    emptyFile_DefaultLogFile
    tailLogFile ${SMDHC_CLIENT_LOG_FILE_PATH_2}    

    tailSyslog
    echoTopProcessName "bitcoind" 10

elif [ "${SMDHC_CLIENT_NAME}" = "TBOT" ]; then
    tailLogFiles_DefaultLogFolder
    compress_DefaultLogFolder
    emptyLogFiles_DefaultLogFolder

    pm2_list

elif [ "${SMDHC_CLIENT_NAME}" = "WALLETD" ]; then
    tailLogFiles_DefaultLogFolder
    compress_DefaultLogFolder
    emptyLogFiles_DefaultLogFolder

    pm2_list

elif [ "${SMDHC_CLIENT_NAME}" = "DAEMONS" ]; then
    tailOutputFiles_DefaultLogFolder
    tailLogFiles_DefaultLogFolder
    
    compress_DefaultLogFolder

    emptyLogFiles_DefaultLogFolder
    emptyOutputFiles_DefaultLogFolder

    echoNewLine
    echo "> cd /home/root/app/ && RAILS_ENV=production && /home/root/.rbenv/shims/rake daemons:status >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
    cd /home/root/app/ && RAILS_ENV=production && /home/root/.rbenv/shims/rake daemons:status >> ${healthchecks_destination_path}
elif [ "${SMDHC_CLIENT_NAME}" = "RAILS" ]; then
    tailLogFile_DefaultLogFile
    compress_DefaultLogFile
    emptyFile_DefaultLogFile
fi

deleteOldLogs_SmdhcArchive
deleteOldLogs_SmdhcHealthchecks

echoTop

cat ${healthchecks_destination_path}

########### copy log to S3 (need to configure IAM role first)
# aws s3 ls

########### send health report email
echoNewLine
echo "> python ${SMDHC_SOURCE}/notify.py ${healthchecks_destination_path} >> ${healthchecks_destination_path}" >> ${healthchecks_destination_path}
python ${SMDHC_SOURCE}/notify.py ${healthchecks_destination_path} >> ${healthchecks_destination_path}