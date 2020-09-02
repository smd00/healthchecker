#!/bin/bash --login

# =============================================
# Author: Daniel Montoya
# Website: montoya.com.au

# Usage:
# SMDHC_SOURCE=$HOME/smdhc && mkdir -p $SMDHC_SOURCE && cd $SMDHC_SOURCE && curl -O https://raw.githubusercontent.com/smd00/healthchecker/master/setup.sh && chmod +x ./setup.sh && ./setup.sh

# =============================================
# Set vars
#SMDHC_SOURCE=$HOME/smdhc (from .env file)
#SMDHC_OUTPUT_FOLDER_PATH (from .env file)

# =============================================
# Update system and install dependencies
apt-get update && apt-get -y install cron && apt-get -y install nano

curl -O https://raw.githubusercontent.com/smd00/healthchecker/master/health-check.sh 
curl -O https://raw.githubusercontent.com/smd00/healthchecker/master/health-cron
curl -O https://raw.githubusercontent.com/smd00/healthchecker/master/send-email.py

# =============================================
# Apply environment variables
source .env

# =============================================
# Grant permissions
chmod +x $SMDHC_SOURCE/health-check.sh
chmod +x $SMDHC_SOURCE/send-email.py

# =============================================
# Add cron job
cp $SMDHC_SOURCE/health-cron /etc/cron.d/health-cron
chmod 0644 /etc/cron.d/health-cron
crontab /etc/cron.d/health-cron

# =============================================
# Create log folder/file
mkdir -p $SMDHC_OUTPUT_FOLDER_PATH
touch $SMDHC_OUTPUT_FOLDER_PATH/health-cron.log

cron
crontab -l

echo "cron pid: $(pgrep cron)" >> $SMDHC_OUTPUT_FOLDER_PATH/health-cron.log
# printenv | grep -v "no_proxy" >> /etc/environment