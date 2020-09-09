# healthchecker

## Install as cron
```
# apt-get install git -y && apt-get install nano -y
git clone https://github.com/smd00/healthchecker.git && mv -f healthchecker ${HOME}/smdhc && cd ${HOME}/smdhc && chmod +x ./setup.sh
# customise .env.tmp and cron.tmp
sh ./setup.sh
```

## Customise cron job
```
crontab -l && nano /etc/cron.d/cron
crontab /etc/cron.d/cron && crontab -l
```

### (sudo) Customise cron job
```
sudo crontab -l && sudo nano /etc/cron.d/cron
sudo crontab /etc/cron.d/cron && sudo crontab -l
```

### Run once:
```
sh ./check.sh ${HOME}/smdhc ignoreAlreadyRunCheck
```