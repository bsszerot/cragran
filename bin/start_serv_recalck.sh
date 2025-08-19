#!/usr/bin/bash
#exit 0 ; 

. /home/cragr/crypto_agregator/conf/bash_parameter.cragregator
CURR_DT=`date "+%Y%m%d%H%M%S"`

echo "cragran $CURR_DT $0 - старт разового обсчёта ..." >> $LOG_MAIN_FILE

#echo $0
#ps -ef | grep -v "grep" | grep $0

export PGPASSWORD="$PG_PASSWORD" ;

#psql -U $PG_USER -h $PG_HOST -d $PG_DB
#select pg_terminate_backend(13520) ;
#exit 0 ;

#--select 'стартуем fn_rtsp_driver_fill_events_14h_tables' ;
#--select now() ;
#--CALL fn_rtsp_driver_fill_events_14h_tables('all') ;


psql -U $PG_USER -h $PG_HOST -d $PG_DB <<EEOF
select 'стартуем fn_rtsp_driver_start_from_5M_fill_rsi_tables' ;
select now() ;
CALL fn_rtsp_driver_start_from_5M_fill_rsi_tables(14,'all') ;

select 'стартуем fn_rtsp_driver_fill_events_tables' ;
select now() ;
CALL fn_rtsp_driver_fill_events_tables('all') ;

select now() ;
EEOF
