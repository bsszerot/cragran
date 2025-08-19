#!/bin/bash

# open source soft - (C) 2023 CrAgaAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

. /home/cragr/crypto_agregator/conf/bash_parameter.cragregator
# похоже тут нужно запускать частями

#-20240203-BASE_DIR="/home/cragr/crypto_agregator"
#-20240203-API_DATA_DIR="$BASE_DIR/src_data_from_api"
LOAD_FILE_PREFIX="$API_DATA_DIR/_cn_gecko_coins_ohlc_data_""`date +%Y%m%d_%H%M%S`"
RESULT_FILE="$API_DATA_DIR/gecko_coins_ohlc_data_""`date +%Y%m%d_%H%M%S`"".sql"
# тут надо +1 день, последних даты две

# для OHLC данных возможен выбор только нескольких значений 1/7/14/30/90/180/365/max
RECORD_LIMIT=1
SLEEP_TIME=3

echo ""  > $RESULT_FILE

#for i in 1inch aave aelf aptos audius avalanche-2 binancecoin bitcoin bitdao bitmon cardano chainlink compound-governance-token dai dash dent dogecoin dydx elrond-erd-2 ethereum filecoin flow icon listenify litecoin marlin matic-network monero okb pancakeswap-token polkadot ripple solana the-open-network tokocrypto tron unicorn-token uniswap wazirx; do
#LIST_COINS="1inch aave aelf aptos audius avalanche-2 binancecoin bitcoin bitdao bitmon cardano chainlink compound-governance-token dai dash dent dogecoin dydx elrond-erd-2 ethereum filecoin flow icon listenify litecoin marlin matic-network monero okb pancakeswap-token polkadot ripple solana the-open-network tokocrypto tron unicorn-token uniswap wazirx"

LIST_COINS=""
REF_CURRENCY=""
CURR_HOUR=`date "+%H"`
CURR_MINS=`date "+%M"`

#for i in binancecoin bitcoin cardano chainlink dai dogecoin ethereum litecoin matic-network monero polkadot ripple solana tron uniswap ; do
#for i in 1inch aave aelf aptos audius avalanche-2 bitdao bitmon compound-governance-token dash dent dydx elrond-erd-2 filecoin flow; do
#for i in icon listenify marlin okb pancakeswap-token tokocrypto unicorn-token wazirx the-open-network; do
#1inch aave aelf aptos audius avalanche-2 binancecoin bitcoin bitdao bitmon cardano chainlink compound-governance-token dai dash dent dogecoin dydx elrond-erd-2 ethereum filecoin flow icon listenify litecoin marlin matic-network monero okb pancakeswap-token polkadot ripple solana the-open-network tokocrypto tron unicorn-token uniswap wazirx; do
#LIST_COINS="1inch aave aelf aptos audius avalanche-2 binancecoin bitcoin bitdao bitmon cardano chainlink compound-governance-token dai dash dent dogecoin dydx elrond-erd-2 ethereum filecoin flow icon listenify litecoin marlin matic-network monero okb pancakeswap-token polkadot ripple solana the-open-network tokocrypto tron unicorn-token uniswap wazirx"
LIST_COINS=$GECKO_GET_COIN_LIST ;

#LIST_COINS="1inch aave"
REF_CURRENCY="usd"

for i in $LIST_COINS; do
#     echo "--- start $i --- $LOAD_FILE_PREFIX"
    LOAD_FILE_NAME=""
    LOAD_FILE_NAME="$LOAD_FILE_PREFIX""_""$i""_""$REF_CURRENCY"".out"
    curl -X 'GET' "https://api.coingecko.com/api/v3/coins/$i/ohlc?vs_currency=$REF_CURRENCY&days=$RECORD_LIMIT" -H 'accept: application/json' | sed 's/\[/\n\[/g' | sed 's/\]\]/\]\n\]/g' | $BASE_DIR/bin/read_gecko_coins_OHLC_data.pl - $i $REF_CURRENCY >> $RESULT_FILE
#        gzip $LOAD_FILE_NAME
    sleep $SLEEP_TIME ;
    done

#exit 0 ;

REF_CURRENCY="btc"
for i in $LIST_COINS; do
#     echo "--- start $i --- $LOAD_FILE_PREFIX"
    LOAD_FILE_NAME=""
#    LOAD_FILE_NAME="$LOAD_FILE_PREFIX""_""$i"".out"
    LOAD_FILE_NAME="$LOAD_FILE_PREFIX""_""$i""_""$REF_CURRENCY"".out"
    curl -X 'GET' "https://api.coingecko.com/api/v3/coins/$i/ohlc?vs_currency=$REF_CURRENCY&days=$RECORD_LIMIT" -H 'accept: application/json' | sed 's/\[/\n\[/g' | sed 's/\]\]/\]\n\]/g' | $BASE_DIR/bin/read_gecko_coins_OHLC_data.pl - $i $REF_CURRENCY >> $RESULT_FILE
    sleep $SLEEP_TIME ;
    done

export PGPASSWORD="$PG_PASSWORD" ; cat $RESULT_FILE | psql -U $PG_USER -h $PG_HOST -d $PG_DB
gzip $RESULT_FILE
