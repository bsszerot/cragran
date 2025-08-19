#!/bin/bash

# open source soft - (C) 2023 CrAgaAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

#exit 0 ;

. /home/cragr/crypto_agregator/conf/bash_parameter.cragregator

RESULT_FILE="$API_DATA_DIR/start_check_2H_alerts_""`date +%Y%m%d_%H%M%S`"".flag"

exec 7>&1 ;
exec 8>&2 ;
exec 1>>$RESULT_FILE ;
exec 2>&1 ;
echo ""

for i in $CRCOMP_MAIN_COIN_LIST; do
    CURRFROM=$i ;
    CURRTO=USDT ;

echo "Start check $CURRFROM / $CURRTO" ;

#    $BASE_DIR/bin/_alert_check_RSI_TV_all_TF_crcomp.pl - $CURRFROM $CURRTO $BASE_DIR 10M &
#    $BASE_DIR/bin/_alert_check_RSI_TV_all_TF_crcomp.pl - $CURRFROM $CURRTO $BASE_DIR 30M &
    $BASE_DIR/bin/_alert_check_RSI_TV_all_TF_crcomp.pl - $CURRFROM $CURRTO $BASE_DIR 1H &
#    $BASE_DIR/bin/_alert_check_RSI_TV_all_TF_crcomp.pl - $CURRFROM $CURRTO $BASE_DIR 4H &
#    $BASE_DIR/bin/_alert_check_RSI_TV_all_TF_crcomp.pl - $CURRFROM $CURRTO $BASE_DIR 1D &
#    $BASE_DIR/bin/_alert_check_RSI_TV_all_TF_crcomp.pl - $CURRFROM $CURRTO $BASE_DIR 4H &
#    $BASE_DIR/bin/_alert_check_MACD_TV_all_TF_crcomp.pl - $CURRFROM $CURRTO $BASE_DIR 1W &
#    $BASE_DIR/bin/_alert_check_MACD_TV_all_TF_crcomp.pl - $CURRFROM $CURRTO $BASE_DIR 4D &
    $BASE_DIR/bin/_alert_check_MACD_TV_all_TF_crcomp.pl - $CURRFROM $CURRTO $BASE_DIR 1D &
    $BASE_DIR/bin/_alert_check_MACD_TV_all_TF_crcomp.pl - $CURRFROM $CURRTO $BASE_DIR 4H &
#    $BASE_DIR/bin/_alert_check_MACD_TV_all_TF_crcomp.pl - $CURRFROM $CURRTO $BASE_DIR 1H &
#    $BASE_DIR/bin/_alert_check_MACD_TV_all_TF_crcomp.pl - $CURRFROM $CURRTO $BASE_DIR 10M &
#    $BASE_DIR/bin/_alert_check_MACD_TV_all_TF_crcomp.pl - $CURRFROM $CURRTO $BASE_DIR 30M &
sleep 1
    done

exit 0 ;
