#!/bin/bash

### Declarando variaveis
export DATA=$(date +%F)
export DIRBKP="/u03/fra/$(echo $ORACLE_SID | tr '[:lower:]' '[:upper:]')/backupset"
BASE_PROD=apollo
BASE_TESTE=TESTE
PASSWORD=passccmoracle

# VERIFICANDO SE DIRETORIO EXISTE
if [ ! -d $DIRBKP ]
then
        mkdir -p $DIRBKP
        chown oracle.oinstall $DIRBKP
fi

### Preparando base de teste
export ORACLE_SID=$BASE_TESTE
$ORACLE_HOME/bin/rman log=$DIRBKP/prepara_teste_rman_$DATA.log <<EOF
connect target
run {
        shutdown immediate;
	startup nomount;
}
exit
EOF

### Duplicando
export ORACLE_SID=$BASE_PROD
$ORACLE_HOME/bin/rman target SYS/$PASSWORD AUXILIARY=SYS/$PASSWORD@$BASE_TESTE log=$DIRBKP/duplicate_rman_$DATA.log <<EOF
run {
	DUPLICATE TARGET DATABASE TO TESTE FROM ACTIVE DATABASE;
}
exit
EOF

### Desativando o Archivelog da base TESTE
export ORACLE_SID=$BASE_TESTE
$ORACLE_HOME/bin/rman log=$DIRBKP/disable_archivelog_man_$DATA.log <<EOF
connect target
run {
        shutdown immediate;
        startup mount;
	alter database noarchivelog;
	alter database open;
}
exit
EOF

### Limpando archivelog usado da duplicacao
rm -rf /u03/fra/TESTE/archivelog/* i
