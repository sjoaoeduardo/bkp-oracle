#!/bin/bash
export MINUTES=+10080
export DAYS=7
source /home/oracle/.bash_profile

echo "INFO: adrci purge started at `date`"

adrci exec="show homes"| grep -v : | while read ADR_HOME
do
echo "INFO: adrci purging diagnostic destination " $ADR_HOME
echo "INFO: purging ALERT older than $MINUTES minutes: $DAYS day"
adrci exec="set homepath $ADR_HOME; purge -age $MINUTES -type ALERT"
echo "INFO: purging INCIDENT older than $MINUTES minutes: $DAYS day"
adrci exec="set homepath $ADR_HOME; purge -age $MINUTES -type INCIDENT"
echo "INFO: purging TRACE older than $MINUTES minutes: $DAYS day"
adrci exec="set homepath $ADR_HOME; purge -age $MINUTES -type TRACE"
echo "INFO: purging CDUMP older than $MINUTES minutes: $DAYS day"
adrci exec="set homepath $ADR_HOME; purge -age $MINUTES -type CDUMP"
echo "INFO: purging HM older than $MINUTES minutes: $DAYS day"
adrci exec="set homepath $ADR_HOME; purge -age $MINUTES -type HM"
echo ""
done
echo "INFO: adrci purge finished at `date`"
echo ""
