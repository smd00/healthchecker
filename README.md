# healthchecker

## Run once:
```
chmod +x ./health-check.sh && sh ./health-check.sh
```

## Install as cron:
```
SMDHC_SOURCE=$HOME/smdhc && mkdir -p $SMDHC_SOURCE && cd $SMDHC_SOURCE && curl -O https://raw.githubusercontent.com/smd00/healthchecker/master/setup.sh && chmod +x ./setup.sh && ./setup.sh
```