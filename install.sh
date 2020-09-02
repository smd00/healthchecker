#!/bin/bash --login

########### Add health check cron job
apt-get update && apt-get -y install cron && apt-get -y install nano

chmod +x /home/root/app/health/health-check.sh
chmod +x /home/root/app/health/send-email.py

cp /home/root/app/health/health-cron /etc/cron.d/health-cron
chmod 0644 /etc/cron.d/health-cron
crontab /etc/cron.d/health-cron
touch /home/root/app/log/health-cron.log

cron
crontab -l

echo "cron pid: $(pgrep cron)" >> /home/root/app/log/health-cron.log
# printenv | grep -v "no_proxy" >> /etc/environment