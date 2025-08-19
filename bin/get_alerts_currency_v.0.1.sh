#!/bin/bash

BASE_DIR="/home/cragr/crypto_agregator"
cd $BASE_DIR/alerts_spool

for i in `ls -1t ./macd_* | head -20`; do
    vTF=`echo $i | cut -d "_" -f 2` ;
    vVECT=`echo $i | cut -d "_" -f 3` ;
    vCURR=`echo $i | cut -d "_" -f 4` ;
    vREF=`echo $i | cut -d "_" -f 5 | cut -d "." -f 1`;
    vPDATE=`tail -1 $i | cut -d " " -f 6,7`;
    vMSG=`tail -1 $i | cut -d " " -f 2,3,4`;

    echo -e "$vPDATE -- $vMSG -- $vVECT -- $vCURR -- $vREF -- $i -- $vTF --" ; 

    vRSI="rsi_*_$vVECT""_$vCURR""_$vREF.alert" ; 
    [[ -f $vRSI ]] && ls -l $vRSI ; 
    done
