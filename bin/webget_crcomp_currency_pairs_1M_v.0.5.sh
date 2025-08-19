#!/bin/bash

# open source soft - (C) 2023 CrAgaAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

. /home/cragr/crypto_agregator/conf/bash_parameter.cragregator

RESULT_FILE="$API_DATA_DIR/merge_crcomp_OHLC_1M_pair_""`date +%Y%m%d_%H%M%S`"".sql"
RECORD_LIMIT=60
#RECORD_LIMIT=180
#RECORD_LIMIT=1000
SLEEP_TIME=1
PARAM_TOTS=""

if [ "_$1" == "_gap" ]; then
   #RECORD_LIMIT=600
   RECORD_LIMIT=2000
   PARAM_TOTS="toTs=`date --date=\"2024-04-25 00:00:00\" +%s`"
   fi

echo ""  > $RESULT_FILE

for i in $CRCOMP_MAIN_COIN_LIST; do
    CURRFROM=$i
    CURRTO=USDT
#-debug-
echo "curl https://min-api.cryptocompare.com/data/v2/histoday?fsym=$CURRFROM\&tsym=$CURRTO\&\&limit=$RECORD_LIMIT | sed 's/{"time"/\n{"time"/g'\n" ;
#-debug-echo https://min-api.cryptocompare.com/data/v2/histominute?fsym=BTC&tsym=USDT&limit=1000
    curl $SZ_PROXY https://min-api.cryptocompare.com/data/v2/histominute?fsym=$CURRFROM\&tsym=$CURRTO\&$PARAM_TOTS\&limit=$RECORD_LIMIT | sed 's/{"time"/\n{"time"/g' | $BASE_DIR/bin/read_crptcomp_OHLC_1M_pair.pl - $CURRFROM $CURRTO >> $RESULT_FILE
    sleep $SLEEP_TIME ;
    done

for i in $CRCOMP_MAIN_COIN_LIST; do
    CURRFROM=$i
    CURRTO=BTC
#-debug-echo "curl https://min-api.cryptocompare.com/data/v2/histoday?fsym=$CURRFROM\&tsym=$CURRTO\&\&limit=$RECORD_LIMIT | sed 's/{"time"/\n{"time"/g' \n" ;
    curl $RSZ_PROXY https://min-api.cryptocompare.com/data/v2/histominute?fsym=$CURRFROM\&tsym=$CURRTO\&$PARAM_TOTS\&limit=$RECORD_LIMIT | sed 's/{"time"/\n{"time"/g' | $BASE_DIR/bin/read_crptcomp_OHLC_1M_pair.pl - $CURRFROM $CURRTO >> $RESULT_FILE
    sleep $SLEEP_TIME ;
    done

export PGPASSWORD="$PG_PASSWORD" ; cat $RESULT_FILE | psql -U $PG_USER -h $PG_HOST -d $PG_DB
gzip $RESULT_FILE

exit 0 ;
