col file_name format a50;
col tablespace_name format a15;
select 	file_name,
		tablespace_name,
		bytes/1024,
		AUTOEXTENSIBLE,
		status 
from dba_data_files 
order by tablespace_name;


ALTER DATABASE DATAFILE '/u01/app/oracle/oradata/sistema/PROD01_INDX01.dbf' RESIZE 2G;
ALTER DATABASE DATAFILE '/u01/app/oracle/oradata/sistema/PROD01_INDX02.dbf' RESIZE 8G;
ALTER DATABASE DATAFILE '/u01/app/oracle/oradata/sistema/PROD01_INDX03.dbf' RESIZE 2G;


ALTER DATABASE DATAFILE '/u01/app/oracle/oradata/sistema/PRODIND01.dbf' RESIZE 8G;


alter database datafile '/u01/app/oracle/oradata/sistema/PRODAT02.dbf'  AUTOEXTEND ON next 500M;