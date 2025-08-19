#!/usr/bin/bash

CURR_DT=`date "+%Y%m%d_%H%M%S"`

. /home/cragr/crypto_agregator/conf/bash_parameter.cragregator


export PGPASSWORD="WWWWWWWWWWWWWW" ; 

echo "==== начало выгрузки `date \"+%s\"` `date` ==="

pg_dumpall -v --clean -h 127.0.0.1 -U crypta | gzip -c > $CRAGR_DB_BACKUP/crypta_dumpall.$CURR_DT.bak.gz

echo "==== конец выгрузки `date \"+%s\"` `date` ==="
