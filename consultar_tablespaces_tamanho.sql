set linesize 300;
set pagesize 0;
SELECT      d.tablespace_name "Name",
            d.status "Status",
            a.bytes/ 1024 / 1024 "TOTAL(M)",
            F.bytes / 1024 / 1024 "LIVRE(M)",
            ((a.bytes - DECODE(f.bytes, NULL, 0, f.bytes)) / 1024 / 1024) "ALOCADO(M)",
            d.block_size
FROM        sys.dba_tablespaces d, 
            sys.sm$ts_avail a, 
            sys.sm$ts_free f
WHERE       d.tablespace_name = a.tablespace_name 
AND         f.tablespace_name (+) = d.tablespace_name
ORDER BY    3 DESC;