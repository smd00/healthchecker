#!/bin/bash --login

# =============================================
# Author: Daniel Montoya
# Website: montoya.com.au

# Usage:
# mkdir $HOME/smdhc && cd $HOME/smdhc && curl -O https://raw.githubusercontent.com/smd00/healthchecker/master/setup.sh && sudo chmod +x ./setup.sh && ./setup.sh

# =============================================
# Update system and install dependencies
apt-get update && apt-get -y install cron && apt-get -y install nano

curl -O https://raw.githubusercontent.com/smd00/healthchecker/master/health-check.sh 
curl -O https://raw.githubusercontent.com/smd00/healthchecker/master/health-cron
curl -O https://raw.githubusercontent.com/smd00/healthchecker/master/send-email.py

# =============================================
# Grant permissions
chmod +x /home/root/app/health/health-check.sh
chmod +x /home/root/app/health/send-email.py

# =============================================
# Apply environment variables
source .env

# =============================================
# Add cron job
cp /home/root/app/health/health-cron /etc/cron.d/health-cron
chmod 0644 /etc/cron.d/health-cron
crontab /etc/cron.d/health-cron
touch /home/root/app/log/health-cron.log

cron
crontab -l

echo "cron pid: $(pgrep cron)" >> /home/root/app/log/health-cron.log
# printenv | grep -v "no_proxy" >> /etc/environment