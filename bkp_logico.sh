#!/bin/bash
#
# FUNÇÃO                                                        #
# Efetua backup logico full do banco de dados utilizando        #
# utilitario DATAPUMP                                           #
#################################################################

### Declarando variaveis
source /home/oracle/.bash_profile
export DIRBKP=/u01/bkp_logico
export DATA=$(date +%F)
DIA=$(date +%d)

#
# Verificando se o diretorio existe
if [ ! -d $DIRBKP ]
then
        mkdir -p $DIRBKP
        chown oracle.oinstall $DIRBKP
fi

#
# Acessando diretorio
cd $DIRBKP

#
# EXPORT 
expdp \'/ as sysdba\' full=Y directory=BKPDIR dumpfile=BKP_"$ORACLE_SID"_"$DATA".dmp logfile=BKP_"$ORACLE_SID"_"$DATA".log reuse_dumpfiles=y

# EXCLUDE=SCHEMA:\"IN \(\'OE\'\)\"

#
# Compactando
tar -cpzvf $DIRBKP/BKP_"$ORACLE_SID"_"$DATA".tgz $DIRBKP/BKP_"$ORACLE_SID"_"$DATA".dmp $DIRBKP/BKP_"$ORACLE_SID"_"$DATA".log
rm -f $DIRBKP/BKP_"$ORACLE_SID"_"$DATA".dmp

#
# Removendo BKPs com + de 2 dias
find $DIRBKP -type f -ctime +6 -exec rm -f {} \;
