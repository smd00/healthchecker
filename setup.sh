#!/bin/bash --login

# =============================================
# Author: Daniel Montoya
# Website: montoya.com.au

# Usage:
# git clone https://github.com/smd00/healthchecker.git && mv -f healthchecker ${HOME}/smdhc && cd ${HOME}/smdhc 
# replace .env.tmp vars
# chmod +x ./setup.sh && ./setup.sh

# =============================================
# Update system and install dependencies
apt-get update && apt-get -y install cron && apt-get -y install nano

echo "============================================="
echo "setup.sh"
echo "============================================="

echo "> pwd: " && pwd 
# =============================================
# Apply environment variables

SMDHC_SOURCE=${HOME}/smdhc
echo "> SMDHC_SOURCE: " ${SMDHC_SOURCE}

cp ${SMDHC_SOURCE}/.env.tmp ${SMDHC_SOURCE}/.env # replace with your .env file
echo "> ls: " && ls -lah

source ${SMDHC_SOURCE}/.env
echo "> SMDHC_OUTPUT_FOLDER_PATH: " ${SMDHC_OUTPUT_FOLDER_PATH}

cat .env >> /etc/environment

# set -o allexport
# source ${SMDHC_SOURCE}/.env
# set +o allexport

# export $(cat ${SMDHC_SOURCE}/.env | xargs)

log_file_path=${SMDHC_OUTPUT_FOLDER_PATH}/health-cron.log

# =============================================
# Grant permissions
chmod +x ${SMDHC_SOURCE}/health-check.sh
chmod +x ${SMDHC_SOURCE}/send-email.py

# =============================================
# Create output folders/files
mkdir -p ${SMDHC_OUTPUT_FOLDER_PATH}
mkdir -p ${SMDHC_OUTPUT_HEALTHCHECKS_FOLDER_PATH}
mkdir -p ${SMDHC_OUTPUT_ARCHIVE_FOLDER_PATH}

touch $log_file_path

# =============================================
# Add cron job
sed -e "s;%SMDHC_SOURCE%;$SMDHC_SOURCE;g" -e "s;%LOG%;$log_file_path;g" ${SMDHC_SOURCE}/health-cron.tmp > ${SMDHC_SOURCE}/health-cron

cp ${SMDHC_SOURCE}/health-cron /etc/cron.d/health-cron
chmod 0644 /etc/cron.d/health-cron
crontab /etc/cron.d/health-cron

cron
crontab -l

echo "cron pid: $(pgrep cron)" >> $log_file_path
# printenv | grep -v "no_proxy" >> /etc/environment