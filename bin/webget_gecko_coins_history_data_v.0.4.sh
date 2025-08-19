#!/bin/bash

# open source soft - (C) 2023 CrAgaAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

. /home/cragr/crypto_agregator/conf/bash_parameter.cragregator
# похоже тут нужно запускать частями

#-v0.4-BASE_DIR="/home/cragr/crypto_agregator"
#-v0.4-API_DATA_DIR="$BASE_DIR/src_data_from_api"
LOAD_FILE_PREFIX="$API_DATA_DIR/_cn_gecko_coins_hist_data_""`date +%Y%m%d_%H%M%S`"
RESULT_FILE="$API_DATA_DIR/gecko_coins_hist_data_""`date +%Y%m%d_%H%M%S`"".sql"
# тут надо +1 день, последних даты две
RECORD_LIMIT=30
#RECORD_LIMIT=2000
SLEEP_TIME=5
#SZ_PROXY=" --proxy localhost:8118"
#SZ_PROXY=""

echo ""  > $RESULT_FILE

#LIST_COINS=""
REF_CURRENCY=""
CURR_HOUR=`date "+%H"`
CURR_MINS=`date "+%M"`

#2023-11-23-1inch aave aelf aptos audius avalanche-2 binancecoin bitcoin bitdao bitmon cardano chainlink compound-governance-token dai dash dent dogecoin dydx elrond-erd-2 ethereum filecoin flow icon listenify litecoin marlin matic-network monero okb pancakeswap-token polkadot ripple solana the-open-network tokocrypto tron unicorn-token uniswap wazirx"
#GECKO_GET_LIST_COINS
#LIST_COINS="1inch aave aelf aptos audius avalanche-2 binancecoin bitcoin bitdao bitmon cardano chainlink compound-governance-token cortex covercompared dai dash dent dogecoin dydx elrond-erd-2 ethereum filecoin flow ftx-token icon illuvium listenify litecoin marlin matic-network monero okb optimism pancakeswap-token polkadot ravencoin ripple solana the-open-network thorchain tokocrypto tron twitfi unicorn-token uniswap azirx"

REF_CURRENCY="usd"
for i in $GECKO_GET_COIN_LIST; do
    LOAD_FILE_NAME=""
    LOAD_FILE_NAME="$LOAD_FILE_PREFIX""_""$i""_""$REF_CURRENCY"".out"
#    echo "curl $SZ_PROXY -X 'GET' \"https://api.coingecko.com/api/v3/coins/$i/market_chart?vs_currency=$REF_CURRENCY&days=$RECORD_LIMIT&interval=daily\" -H 'accept: application/json' | sed 's/\[/\n\[/g' | sed 's/\]\]/\]\n\]/g'"
#| $BASE_DIR/bin/read_gecko_coins_history_data.pl - $i $REF_CURRENCY >> $RESULT_FILE
    curl $SZ_PROXY -X 'GET' "https://api.coingecko.com/api/v3/coins/$i/market_chart?vs_currency=$REF_CURRENCY&days=$RECORD_LIMIT&interval=daily" -H 'accept: application/json' | sed 's/\[/\n\[/g' | sed 's/\]\]/\]\n\]/g'| $BASE_DIR/bin/read_gecko_coins_history_data.pl - $i $REF_CURRENCY >> $RESULT_FILE
    sleep $SLEEP_TIME ;
    done

#exit 0 ;

REF_CURRENCY="btc"
for i in $GECKO_GET_COIN_LIST; do
    LOAD_FILE_NAME=""
    LOAD_FILE_NAME="$LOAD_FILE_PREFIX""_""$i""_""$REF_CURRENCY"".out"
    curl $SZ_PROXY -X 'GET' "https://api.coingecko.com/api/v3/coins/$i/market_chart?vs_currency=$REF_CURRENCY&days=$RECORD_LIMIT&interval=daily" -H 'accept: application/json' | sed 's/\[/\n\[/g' | sed 's/\]\]/\]\n\]/g'| $BASE_DIR/bin/read_gecko_coins_history_data.pl - $i $REF_CURRENCY >> $RESULT_FILE
    sleep $SLEEP_TIME ;
    done

export PGPASSWORD="$PG_PASSWORD" ; cat $RESULT_FILE | psql -U $PG_USER -h $PG_HOST -d $PG_DB
gzip $RESULT_FILE
