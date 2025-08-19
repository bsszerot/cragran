#!/bin/bash

CURR_DT=`date "+%Y%m%d_%H%M%S"`

. /home/cragr/crypto_agregator/conf/bash_parameter.cragregator

export PGPASSWORD="WWWWWWWW" ; pg_dump -h 127.0.0.1 -U crypta crypta | gzip -c > $CRAGR_DB_BACKUP/db_crypta.$CURR_DT.bak.gz
