SET PAGESIZE 1000
SET LINES 210
SELECT DAY, EVENT_NAME, TOTAL_WAIT_SEG
  FROM (SELECT DAY,
               EVENT_NAME,
               SUM(EVENT_TIME_WAITED) TOTAL_WAIT_SEG,
               ROW_NUMBER() OVER(PARTITION BY DAY ORDER BY SUM(EVENT_TIME_WAITED) DESC) RN
          FROM (SELECT TO_DATE(TO_CHAR(BEGIN_INTERVAL_TIME, 'dd/mm/yyyy'),
                               'dd/mm/yyyy') DAY,
                       S.BEGIN_INTERVAL_TIME,
                       M.*
                  FROM (SELECT EE.INSTANCE_NUMBER,
                               EE.SNAP_ID,
                               EE.EVENT_NAME,
                               ROUND(EE.EVENT_TIME_WAITED / 1000000) EVENT_TIME_WAITED,
                               EE.TOTAL_WAITS,
                               ROUND((EE.EVENT_TIME_WAITED * 100) /
                                     ET.TOTAL_TIME_WAITED,
                                     1) PCT,
                               ROUND((EE.EVENT_TIME_WAITED / EE.TOTAL_WAITS) / 1000) AVG_WAIT
                          FROM (SELECT EE1.INSTANCE_NUMBER,
                                       EE1.SNAP_ID,
                                       EE1.EVENT_NAME,
                                       EE1.TIME_WAITED_MICRO -
                                       EE2.TIME_WAITED_MICRO EVENT_TIME_WAITED,
                                       EE1.TOTAL_WAITS - EE2.TOTAL_WAITS TOTAL_WAITS
                                  FROM DBA_HIST_SYSTEM_EVENT EE1
                                  JOIN DBA_HIST_SYSTEM_EVENT EE2
                                    ON EE1.SNAP_ID = EE2.SNAP_ID + 1
                                   AND EE1.INSTANCE_NUMBER =
                                       EE2.INSTANCE_NUMBER
                                   AND EE1.EVENT_ID = EE2.EVENT_ID
                                   AND EE1.WAIT_CLASS_ID <> 2723168908
                                   AND EE1.TIME_WAITED_MICRO -
                                       EE2.TIME_WAITED_MICRO > 0
                                UNION
                                SELECT ST1.INSTANCE_NUMBER,
                                       ST1.SNAP_ID,
                                       ST1.STAT_NAME EVENT_NAME,
                                       ST1.VALUE - ST2.VALUE EVENT_TIME_WAITED,
                                       1 TOTAL_WAITS
                                  FROM DBA_HIST_SYS_TIME_MODEL ST1
                                  JOIN DBA_HIST_SYS_TIME_MODEL ST2
                                    ON ST1.INSTANCE_NUMBER =
                                       ST2.INSTANCE_NUMBER
                                   AND ST1.SNAP_ID = ST2.SNAP_ID + 1
                                   AND ST1.STAT_ID = ST2.STAT_ID
                                   AND ST1.STAT_NAME = 'DB CPU'
                                   AND ST1.VALUE - ST2.VALUE > 0) EE
                          JOIN (SELECT ET1.INSTANCE_NUMBER,
                                      ET1.SNAP_ID,
                                      ET1.VALUE - ET2.VALUE TOTAL_TIME_WAITED
                                 FROM DBA_HIST_SYS_TIME_MODEL ET1
                                 JOIN DBA_HIST_SYS_TIME_MODEL ET2
                                   ON ET1.SNAP_ID = ET2.SNAP_ID + 1
                                  AND ET1.INSTANCE_NUMBER =
                                      ET2.INSTANCE_NUMBER
                                  AND ET1.STAT_ID = ET2.STAT_ID
                                  AND ET1.STAT_NAME = 'DB time'
                                  AND ET1.VALUE - ET2.VALUE > 0) ET
                            ON EE.INSTANCE_NUMBER = ET.INSTANCE_NUMBER
                           AND EE.SNAP_ID = ET.SNAP_ID) M
                  JOIN DBA_HIST_SNAPSHOT S
                    ON M.SNAP_ID = S.SNAP_ID)
         GROUP BY DAY, EVENT_NAME
         ORDER BY DAY DESC, TOTAL_WAIT_SEG DESC)
 WHERE RN < 10;
 