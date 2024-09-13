#!/bin/bash

### Declarando variaveis
PATH_PID=/proc/$(ps aux | grep ora_dbw | head -n 1 | awk '{print $2}')/fd
PATH_PID_REDO=/proc/$(ps aux | grep ora_lgwr | head -n 1 | awk '{print $2}')/fd
TAGFILE=*.dbf\|*.ctl
TAGFILE_REDO=*.log
NC='\033[0m'
YELLOW='\033[1;33m'

echo
echo -e "${YELLOW}Datafiles para que podem ser restaurados${NC}"
echo

### Pegando datafiles que podem ser recuperados
for LISTA in `ls -l "$PATH_PID" | grep -E "$TAGFILE" | grep "(deleted)" | sed "s, ,#,g"`
do
        PID=$(echo $LISTA | sed "s,#, ,g" | awk '{print $9}')
        FILE=$(echo $LISTA | sed "s,#, ,g" | awk '{print $11}')
        echo "cat $PATH_PID/$PID > $FILE"
done

echo "------------------------------------------------------------------------------"
echo "------------------------------------------------------------------------------"

echo
echo -e "${YELLOW}Redologs que podem ser restaurados${NC}"

### Pegando redologs que podem ser recuperados
for LISTA in `ls -l "$PATH_PID_REDO" | grep -E "$TAGFILE_REDO" | grep "(deleted)" | sed "s, ,#,g"`
do
        PID=$(echo $LISTA | sed "s,#, ,g" | awk '{print $9}')
        FILE=$(echo $LISTA | sed "s,#, ,g" | awk '{print $11}')
        echo "cat $PATH_PID_REDO/$PID > $FILE"
done
echo