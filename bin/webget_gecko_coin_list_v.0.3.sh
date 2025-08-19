#!/bin/bash

# open source soft - (C) 2023 CrAgaAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

. /home/cragr/crypto_agregator/conf/bash_parameter.cragregator

#BASE_DIR="/home/cragr/crypto_agregator"
#API_DATA_DIR="$BASE_DIR/src_data_from_api"
RESULT_FILE="$API_DATA_DIR/gecko_coin_list""`date +%Y%m%d_%H%M%S`"".sql"

echo ""  > $RESULT_FILE

curl -X 'GET' 'https://api.coingecko.com/api/v3/coins/list' -H 'accept: application/json' | sed 's/{"id"/\n{"id"/g' | $BASE_DIR/bin/read_gecko_coin_list.pl > $RESULT_FILE

export PGPASSWORD="$PG_PASSWORD" ; cat $RESULT_FILE | psql -U $PG_USER -h $PG_HOST -d $PG_DB
gzip $RESULT_FILE
