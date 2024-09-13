#!/bin/bash
export ORACLE_BASE=/u01/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1/
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH:/usr/local/lib
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=teste
export USER_SYSTEM=system
export PASS_SYSTEM=passccmoracle
export NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1
export DATA=$(date +%F)
export DIRBKP=/u02/bkp_logico
export DIRRESTOR=$DIRBKP/restore
export FILE_NAME=BKP_apollo_$DATA
#export FILE_EXPORT_BKP=BKP_apollo_$DATA.dmp
#export FILE_EXPORT_LOG=BKP_apollo_$DATA.log
#export FILE_IMP_LOG=BKP_apollo_$DATA.imp
export DIRSCRIPTS=/home/oracle/bin/scripts/ccm_restor_base_teste

#
# Verifica se o $DIRRESTOR existe, caso nao sera criado. 
func_dir_restor () {
	if [ ! -d $DIRRESTOR ]
	then
		mkdir -p $DIRRESTOR
		chown oracle:oinstall $DIRRESTOR
	fi
}
#
# Descompactar backup
extrair_bkp_oracle () {
	if [ -f $DIRBKP/$FILE_NAME.tgz ]
	then
		echo "OK - Arquivo $DIRBKP/$FILE_NAME.tgz, existe"

		if tar -xpzf $DIRBKP/$FILE_NAME.tgz -C $DIRRESTOR
		then
			echo "OK - Backup $DIRBKP/$FILE_NAME.tgz, descompactado com sucesso"
			### Movendo arquivos para o diretorio correto
			mv $(find /u02/bkp_logico/restore -iname $FILE_NAME.dmp) $DIRRESTOR > /dev/null
			mv $(find /u02/bkp_logico/restore -iname $FILE_NAME.log) $DIRRESTOR > /dev/null
		else
			"ERROR - Backup $DIRBKP/$FILE_NAME.tgz, nao descompactado com sucesso"
			exit
		fi 

	else
		echo "ERROR - Arquivo $DIRBKP/$FILE_NAME.tgz, nao existe."
		exit
	fi
}

#
# Analise export com sucesso
check_export_bkp () {
	if grep successfully $DIRRESTOR/$FILE_NAME.log > /dev/null
	then
		echo "OK - Instance BRAVOS exportada com sucesso"
	else
		echo "ERROR - Instance BRAVOS encontra-se com algum erro"
		echo "Arquivo:  $DIRRESTOR/$FILE_NAME.log"
		exit
	fi
}

# 
# Dropando usuario CNP@teste
drop_user_cnp_teste () {
	# verifica o processo pmon
	if ! ps -ef | grep pmon_teste > /dev/null
	then
		echo "ERROR - Processo pmon off"
		exit
	fi
		
	
	# checa se esta na instancia certa
	if sqlplus $USER_SYSTEM/$PASS_SYSTEM@$ORACLE_SID @$DIRSCRIPTS/check_instance.sql | grep teste   > /dev/null
	then
		echo "OK - Instance TESTE: UP"
	else
		echo "ERROR - Instance TESTE: DOWN"
		exit
	fi
	
	# Dropando schema teste
	if ! sqlplus $USER_SYSTEM/$PASS_SYSTEM@$ORACLE_SID @$DIRSCRIPTS/drop_user_cnp.sql | grep cannot > /dev/null
	then
		echo "OK - DROP USER CNP CASCADE"
	else
		echo "ERROR - DROP USER CNP CASCADE"
		echo "Existem usuarios logados, segue abaixo uma lista"
		echo ""
		
		sqlplus $USER_SYSTEM/$PASS_SYSTEM@$ORACLE_SID @$DIRSCRIPTS/list_user_current.sql | grep -i CNP 
		exit
	fi
}

#
# Criando schema CNP
create_user_cnp_teste () {
	# cria usuario CNP na instancia TESTE
	if sqlplus $USER_SYSTEM/$PASS_SYSTEM@$ORACLE_SID @$DIRSCRIPTS/create_user_cnp.sql > /dev/null
	then
		echo "OK - CREATED USER CNP" 
	else
		echo "ERROR - CREATE USER CNP"
		echo "ENTRAR EM CONTATO COM A CCM"
		exit 1
	fi
}

#
# Limpando diretorio
clean_directory_restor () {
        cd $DIRRESTOR/
        rm -f *dmp
        rm -f *log

}

#
# Start IMP
start_imp_cnp_teste () {
	# Iniciando o processo de import na base teste
	echo
	echo "Iniciando IMP na instancia: $ORACLE_SID"
		
	impdp $USER_SYSTEM/$PASS_SYSTEM@$ORACLE_SID directory=RESTORDIRTESTE dumpfile=$FILE_NAME.dmp logfile=$FILE_NAME.imp schemas=CNP;

#	impdp $USER_SYSTEM/$PASS_SYSTEM@$ORACLE_SID  file=$DIRRESTOR/$FILE_EXPORT_BKP fromuser=cnp touser=cnp log=$DIRRESTOR/$FILE_IMP_LOG statistics=none > /tmp/imp.log 2>&1
	
	if grep successfully $DIRRESTOR/$FILE_IMP_LOG > /dev/null
	then
		echo "OK - IMP Realizado com sucesso"
		clean_directory_restor
	else
		echo "ERROR - IMP com erro"
		echo ""
		echo "ENTRAR EM CONTATO COM A CCM"
		exit 1
	fi
	

}

func_dir_restor
extrair_bkp_oracle
check_export_bkp
drop_user_cnp_teste
create_user_cnp_teste
start_imp_cnp_teste

echo "....Processo encerrado com sucesso!!!!"
