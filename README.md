# healthchecker

## Run once:
```
chmod +x ./health-check.sh && sh ./health-check.sh .
```

## Install as cron:
```
git clone https://github.com/smd00/healthchecker.git && mv -f healthchecker ${HOME}/smdhc && cd ${HOME}/smdhc && chmod +x ./setup.sh && ./setup.sh
```

## Install as cron with custom env vars and cron settings
```
git clone https://github.com/smd00/healthchecker.git && mv -f healthchecker ${HOME}/smdhc && cd ${HOME}/smdhc && chmod +x ./setup.sh
# customise .env.tmp and health-cron.tmp
sh ./setup.sh
```