col owner for a30;
select  owner,  sum(bytes)/1024/1024 MB 
from    dba_segments  
where   tablespace_name = 'SYSAUX'
group by owner
order by 2 desc;


col table_name for a30;
SELECT table_name, BLOCKS*8
from all_tables 
where owner = 'AUDSYS';

col schema for a15;

select
  owner as "schema"
  , segment_name as "object_name"
  , segment_type as "object_type"
  , round(bytes/1024/1024,2) as "object_size_mb"
  , tablespace_name as "Tablespace"
from dba_segments
where tablespace_name = 'SYSAUX'
order by 4;