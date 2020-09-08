# healthchecker

## Run once:
```
chmod +x ./check.sh 
sh ./check.sh .
```

## Install as cron with custom env vars and cron settings
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