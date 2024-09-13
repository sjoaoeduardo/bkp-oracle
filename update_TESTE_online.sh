#!/bin/bash
export ORACLE_BASE=/u01/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1/
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH:/usr/local/lib
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=teste
export USER_SYSTEM=system
export PASS_SYSTEM=passccmoracle
export DIRRESTOR=/u03/oracle
export FILE_IMP_LOG=imp.log
export NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1
export DATA=$(date +%F)
export DIRSCRIPTS=/home/oracle/bin/scripts/ccm_restor_base_teste

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
# Start IMP
start_imp_cnp_teste () {
	# Iniciando o processo de import na base teste
	echo
	echo "Iniciando IMP na instancia: $ORACLE_SID"
	
	impdp $USER_SYSTEM/$PASS_SYSTEM@$ORACLE_SID network_link=PROD logfile=RESTORDIR:$FILE_IMP_LOG schemas=CNP flashback_time=systimestamp;
	
	if grep successfully $DIRRESTOR/$FILE_IMP_LOG > /dev/null
	then
		echo "OK - IMP Realizado com sucesso"
	else
		echo "ERROR - IMP com erro"
		echo ""
		echo "ENTRAR EM CONTATO COM A CCM"
		exit 1
	fi
}

drop_user_cnp_teste
create_user_cnp_teste
start_imp_cnp_teste

echo "....Processo encerrado com sucesso!!!!"
