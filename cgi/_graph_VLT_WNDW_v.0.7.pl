#!/usr/bin/perl

# open source soft - (C) 2023 CrAgrAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

use DBI ;
use Chart::Lines ;
require "/var/www/crypta/cgi/common_parameter.cragregator" ;
require "$cragran_dir_lib/lib_common_func.pl" ;
require "$cragran_dir_lib/lib_cragran_common.pl" ;
require "$cragran_dir_lib/lib_cragran_trading.pl" ;
require "$cragran_dir_lib/lib_cragran_contracts.pl" ;

$CURR_YEAR = `date +%Y` ; $CURR_YEAR =~ s/[\r\n]+//g ;
my $count_rows = 0 ;
my $count_rows_post = 0 ;

# блок списков для первоначальной обработки данных
my @ds_datetime_list = () ;
my @ds_hours_list = () ;
my @ds_minutes_list = () ;
my @ds_price_open = () ;
my @ds_price_min = () ;
my @ds_price_max = () ;
my @ds_price_close = () ;
my @ds_curr_ema = () ;
my @ds_day_ema = () ;
my @ds_week_ema = () ;
my @ds_env_top = () ;
my @ds_env_dwn = () ;
my @ds_vlt_01 = () ;
my @ds_max_vlt01 = () ;
my @ds_max_vlt02 = () ;
my @ds_max_vlt03 = () ;
# блок списков после вычитания префиксных дней
my @ds_end_datetime_list = () ;
my @ds_hours_list = () ;
my @ds_minutes_list = () ;
my @ds_end_price_open = () ;
my @ds_end_price_min = () ;
my @ds_end_price_max = () ;
my @ds_end_price_close = () ;
my @ds_end_curr_ema = () ;
my @ds_end_day_ema = () ;
my @ds_end_week_ema = () ;
my @ds_end_env_top = () ;
my @ds_end_env_dwn = () ;
my @ds_end_vlt_01 = () ;
my @ds_end_max_vlt_01 = () ;
my @ds_end_max_vlt_02 = () ;
my @ds_end_max_vlt_03 = () ;

# параметры по умолчанию
# для 2х часового графика значения ЕМА - 20 (текущая), 241 (дневная), 1570 - недельная
$pv{env_prct} = 5 ;
$pv{curr_ema_cnt_prds} = 20 ;
$pv{day_ema_cnt_prds} = 241 ;
$pv{week_ema_cnt_prds} = 1570 ;
# -- временно --
#$pv{count_prds} = 12 * 120 ;
#$pv{time_frame} = "2H" ;

# - вытащить из URL запроса значения уточняющих полей
#####
&get_forms_param() ;
#-debug-$pv{currency} = 'LEO' ; $pv{curr_reference} = 'USD' ; $pv{time_frame} = "4H" ; $pv{count_prds} = '120' ; $pv{vlt_wnd_01} = 5; $pv{output_type} = 'graph' ; $pv{brush_size} = '4' ; $pv{x_size} = '1400' ; $pv{y_size} = '640' ;
#-debug-$pv{output_type} = 'table' ;

$request = " " ;
# для отображения именно текущей, дневной и недельной ЕМА в этом модуле используются перерасчитанные параметры по умолчанию
# для 2х часового графика значения ЕМА - 20 (текущая), 241 (дневная), 1570 - недельная
# соответствует месячный цикл, родительский - полугодовой (EMA 1W), дедов - подавлен цветом и приоритетом линий графика
if ( $pv{time_frame} eq "1D" ) { $pv{curr_ema_cnt_prds} = 20 ; $pv{day_ema_cnt_prds} = 140 ; $pv{week_ema_cnt_prds} = 570 ; if ( $pv{vlt_wnd_01} eq "" ) { $pv{vlt_wnd_01} = 45 ; $pv{vlt_wnd_02} = int($pv{vlt_wnd_01} * 70 / 100) ; $pv{vlt_wnd_03} = int($pv{vlt_wnd_01} * 130 / 100) ; } }
# соответствует недельному циклу, родительский месячный (1D), дедов - полугодовой (1W)
if ( $pv{time_frame} eq "4H" ) { $pv{curr_ema_cnt_prds} = 20 ; $pv{day_ema_cnt_prds} = 120 ; $pv{week_ema_cnt_prds} = 785 ; if ( $pv{vlt_wnd_01} eq "" ) { $pv{vlt_wnd_01} = 6 * 7 ; $pv{vlt_wnd_02} = int($pv{vlt_wnd_01} * 70 / 100) ; $pv{vlt_wnd_03} = int($pv{vlt_wnd_01} * 130 / 100) ; } }
if ( $pv{time_frame} eq "3H" ) { $pv{curr_ema_cnt_prds} = 20 ; $pv{day_ema_cnt_prds} = 160 ; $pv{week_ema_cnt_prds} = 1047 ; if ( $pv{vlt_wnd_01} eq "" ) { $pv{vlt_wnd_01} = 8 * 7 ; $pv{vlt_wnd_02} = int($pv{vlt_wnd_01} * 70 / 100) ; $pv{vlt_wnd_03} = int($pv{vlt_wnd_01} * 130 / 100) ; } }
if ( $pv{time_frame} eq "2H" ) { $pv{curr_ema_cnt_prds} = 20 ; $pv{day_ema_cnt_prds} = 241 ; $pv{week_ema_cnt_prds} = 1570 ; if ( $pv{vlt_wnd_01} eq "" ) { $pv{vlt_wnd_01} = 12 * 7 ; $pv{vlt_wnd_02} = int($pv{vlt_wnd_01} * 70 / 100) ; $pv{vlt_wnd_03} = int($pv{vlt_wnd_01} * 130 / 100) ; } }
if ( $pv{time_frame} eq "1H" ) { $pv{curr_ema_cnt_prds} = 20 ; $pv{day_ema_cnt_prds} = 482 ; $pv{week_ema_cnt_prds} = 3140 ; if ( $pv{vlt_wnd_01} eq "" ) { $pv{vlt_wnd_01} = 24 * 7 ; $pv{vlt_wnd_02} = int($pv{vlt_wnd_01} * 70 / 100) ; $pv{vlt_wnd_03} = int($pv{vlt_wnd_01} * 130 / 100) ; } }
# соответствует дневному цикл, родительский недельный (ЕМА 1H), дедов месячный (EMA 1Д)
if ( $pv{time_frame} eq "30M" ) { $pv{curr_ema_cnt_prds} = 20 ; $pv{day_ema_cnt_prds} = 20 * 2 ; $pv{week_ema_cnt_prds} = 20 * 2 * 24 ; if ( $pv{vlt_wnd_01} eq "" ) { $pv{vlt_wnd_01} = int(2 * 24 * 36 / 24) ; $pv{vlt_wnd_02} = int($pv{vlt_wnd_01} * 70 / 100) ; $pv{vlt_wnd_03} = int($pv{vlt_wnd_01} * 130 / 100) ; } }
if ( $pv{time_frame} eq "15M" ) { $pv{curr_ema_cnt_prds} = 20 ; $pv{day_ema_cnt_prds} = 20 * 4 ; $pv{week_ema_cnt_prds} = 20 * 4 * 24 ; if ( $pv{vlt_wnd_01} eq "" ) { $pv{vlt_wnd_01} = int(4 * 24 * 36 / 24) ; $pv{vlt_wnd_02} = int($pv{vlt_wnd_01} * 70 / 100) ; $pv{vlt_wnd_03} = int($pv{vlt_wnd_01} * 130 / 100) ; } }
if ( $pv{time_frame} eq "10M" ) { $pv{curr_ema_cnt_prds} = 20 ; $pv{day_ema_cnt_prds} = 20 * 6 ; $pv{week_ema_cnt_prds} = 20 * 6 * 24 ; if ( $pv{vlt_wnd_01} eq "" ) { $pv{vlt_wnd_01} = int(6 * 24 * 36 / 24) ; $pv{vlt_wnd_02} = int($pv{vlt_wnd_01} * 70 / 100) ; $pv{vlt_wnd_03} = int($pv{vlt_wnd_01} * 130 / 100) ; } }
# соответствует внутридневному циклу, родительский дневной цикл (EMA 15M), дедов недельный (EMA 1H)
if ( $pv{time_frame} eq "5M" ) { $pv{curr_ema_cnt_prds} = 20 ; $pv{day_ema_cnt_prds} = 20 * 3 ; $pv{week_ema_cnt_prds} = 20 * 3 * 4 ; if ( $pv{vlt_wnd_01} eq "" ) { $pv{vlt_wnd_01} = 12 * 7 ; $pv{vlt_wnd_02} = int($pv{vlt_wnd_01} * 70 / 100) ; $pv{vlt_wnd_03} = int($pv{vlt_wnd_01} * 130 / 100) ; } }
if ( $pv{time_frame} eq "3M" ) { $pv{curr_ema_cnt_prds} = 20 ; $pv{day_ema_cnt_prds} = 20 * 5 ; $pv{week_ema_cnt_prds} = 20 * 5 * 4 ; if ( $pv{vlt_wnd_01} eq "" ) { $pv{vlt_wnd_01} = 20 * 7 ; $pv{vlt_wnd_02} = int($pv{vlt_wnd_01} * 70 / 100) ; $pv{vlt_wnd_03} = int($pv{vlt_wnd_01} * 130 / 100) ; } }
if ( $pv{time_frame} eq "1M" ) { $pv{curr_ema_cnt_prds} = 20 ; $pv{day_ema_cnt_prds} = 20 * 15 ; $pv{week_ema_cnt_prds} = 20 * 15 * 4 ; if ( $pv{vlt_wnd_01} eq "" ) { $pv{vlt_wnd_01} = 60 * 7 ; $pv{vlt_wnd_02} = int($pv{vlt_wnd_01} * 70 / 100) ; $pv{vlt_wnd_03} = int($pv{vlt_wnd_01} * 130 / 100) ; } }

#&get_forms_param() ;

# рассчитать расширение дней от начального периода, чтобы успешно посчитать все ЕМА на начало периода (тут берётся из часовых записей, т.е. *2)
# ___!!!___  здесь берётся заведомо сильно большее количество периодов, и умножается ещё на 2, что с лихвой перекрывает ошибку выборки периодов в SQL запросах ___!!!___
my $ext_period = 0 ;
my $max_ema_periods = 0 ;
$max_ema_periods = $pv{week_ema_cnt_prds} ;
if ( $pv{day_ema_cnt_prds} > $pv{week_ema_cnt_prds} ) { $max_ema_periods = $pv{day_ema_cnt_prds} ; }
if ( $pv{curr_ema_cnt_prds} > $pv{week_ema_cnt_prds} ) { $max_ema_periods = $pv{curr_ema_cnt_prds} ; }
#$ext_period = $pv{count_prds} + $max_ema_periods + 1 ;

#-debug-print "Дополниьельный период == $ext_period == $pv{count_prds} == $count_prds_prefix ;" ;

my $curr_ema_mult = (2 / ($pv{curr_ema_cnt_prds} + 1)) ;
my $day_ema_mult = (2 / ($pv{day_ema_cnt_prds} + 1)) ;
my $week_ema_mult = (2 / ($pv{week_ema_cnt_prds} + 1)) ;

#$pv{vlt_wnd_01} = 5 ;
my $sql_vlt_wnd_01 = $pv{vlt_wnd_01} - 1 ;
my $sql_vlt_wnd_02 = $pv{vlt_wnd_02} - 1 ;
my $sql_vlt_wnd_03 = $pv{vlt_wnd_03} - 1 ;

if ( $pv{time_frame} eq "1D" ) { $ext_period_real_point = ($pv{count_prds} + $max_ema_periods + 1) ;
   $request = "select currency, reference_currency, day_date + INTERVAL '3 HOURS', price_open, price_min, price_max, price_close,
                   extract(hour from (day_date + INTERVAL '3 HOURS')) hours, extract(minute from (day_date + INTERVAL '3 HOURS')) minutes,
                   round(( (PRICE_MAX - LAG(PRICE_MIN,$sql_vlt_wnd_01) OVER vlt_wnd_01)/(LAG(PRICE_MIN,$sql_vlt_wnd_01) OVER vlt_wnd_01/100)),2) as VLT_PRCT_01,
                   round(((max(PRICE_MAX) OVER vlt_wnd_01 - min(PRICE_MIN) OVER vlt_wnd_01)/(min(PRICE_MIN) OVER vlt_wnd_01/100)),2) as MAX_VLT_PRCT_01,
                   round(((max(PRICE_MAX) OVER vlt_wnd_02 - min(PRICE_MIN) OVER vlt_wnd_02)/(min(PRICE_MIN) OVER vlt_wnd_02/100)),2) as MAX_VLT_PRCT_02,
                   round(((max(PRICE_MAX) OVER vlt_wnd_03 - min(PRICE_MIN) OVER vlt_wnd_03)/(min(PRICE_MIN) OVER vlt_wnd_03/100)),2) as MAX_VLT_PRCT_03
                   from curr_pair_history
                   where currency = '$pv{currency}' and reference_currency = '$pv{curr_reference}' and
                         (day_date + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point days'
                   WINDOW vlt_wnd_01 AS (PARTITION BY currency, reference_currency ORDER BY (day_date + INTERVAL '3 HOURS') ASC ROWS BETWEEN $sql_vlt_wnd_01 PRECEDING AND CURRENT ROW),
                          vlt_wnd_02 AS (PARTITION BY currency, reference_currency ORDER BY (day_date + INTERVAL '3 HOURS') ASC ROWS BETWEEN $sql_vlt_wnd_02 PRECEDING AND CURRENT ROW),
                          vlt_wnd_03 AS (PARTITION BY currency, reference_currency ORDER BY (day_date + INTERVAL '3 HOURS') ASC ROWS BETWEEN $sql_vlt_wnd_03 PRECEDING AND CURRENT ROW)
                   order by day_date ASC ";
   }

# здесь мы расчитываем не максимальную или минимальную волатильность, а именно значение "за окно" от начала до конца с детализацией выбранного ТФ
if ( $pv{time_frame} eq "4H" ) { $ext_period_real_point = ($pv{count_prds} + $max_ema_periods + 1) * 4 ;
   $request = "SELECT currency, reference_currency, tst_point, PRICE_OPEN, PRICE_MIN, PRICE_MAX, PRICE_CLOSE, hours, minutes,
                      round(((PRICE_MAX - LAG(PRICE_MIN,$sql_vlt_wnd_01) OVER vlt_wnd_01)/(LAG(PRICE_MIN,$sql_vlt_wnd_01) OVER vlt_wnd_01/100)),2) as VLT_PRCT_01,
                      round(((max(PRICE_MAX) OVER vlt_wnd_01 - min(PRICE_MIN) OVER vlt_wnd_01)/(min(PRICE_MIN) OVER vlt_wnd_01/100)),2) as MAX_VLT_PRCT_01,
                      round(((max(PRICE_MAX) OVER vlt_wnd_02 - min(PRICE_MIN) OVER vlt_wnd_02)/(min(PRICE_MIN) OVER vlt_wnd_02/100)),2) as MAX_VLT_PRCT_02,
                      round(((max(PRICE_MAX) OVER vlt_wnd_03 - min(PRICE_MIN) OVER vlt_wnd_03)/(min(PRICE_MIN) OVER vlt_wnd_03/100)),2) as MAX_VLT_PRCT_03
                      from (SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS') tst_point,
                                   LAG(price_open,3) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS
                                                           BETWEEN 3 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                                   min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS
                                                        BETWEEN 3 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                                   max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS
                                                         BETWEEN 3 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                                   price_close PRICE_CLOSE, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                                   extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes
                                   FROM crcomp_pair_OHLC_1H_history
                                   WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                                         AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point hours' order by timestamp_point ASC) AS ds1
                      WINDOW vlt_wnd_01 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_01 PRECEDING AND CURRENT ROW),
                             vlt_wnd_02 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_02 PRECEDING AND CURRENT ROW),
                             vlt_wnd_03 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_03 PRECEDING AND CURRENT ROW)" ;
   }

if ( $pv{time_frame} eq "3H" ) { $ext_period_real_point = ($pv{count_prds} * 3 + $max_ema_periods + 1) * 3 ;
   $request = "SELECT currency, reference_currency, tst_point, PRICE_OPEN, PRICE_MIN, PRICE_MAX, PRICE_CLOSE, hours, minutes,
                      round(((PRICE_MAX - LAG(PRICE_MIN,$sql_vlt_wnd_01) OVER vlt_wnd_01)/(LAG(PRICE_MIN,$sql_vlt_wnd_01) OVER vlt_wnd_01/100)),2) as VLT_PRCT_01,
                      round(((max(PRICE_MAX) OVER vlt_wnd_01 - min(PRICE_MIN) OVER vlt_wnd_01)/(min(PRICE_MIN) OVER vlt_wnd_01/100)),2) as MAX_VLT_PRCT_01,
                      round(((max(PRICE_MAX) OVER vlt_wnd_02 - min(PRICE_MIN) OVER vlt_wnd_02)/(min(PRICE_MIN) OVER vlt_wnd_02/100)),2) as MAX_VLT_PRCT_02,
                      round(((max(PRICE_MAX) OVER vlt_wnd_03 - min(PRICE_MIN) OVER vlt_wnd_03)/(min(PRICE_MIN) OVER vlt_wnd_03/100)),2) as MAX_VLT_PRCT_03
                      from (SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS') tst_point,
                                   LAG(price_open,2) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS
                                                           BETWEEN 2 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                                   min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS
                                                        BETWEEN 2 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                                   max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS
                                                         BETWEEN 2 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                                   price_close PRICE_CLOSE, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                                   extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes
                                   FROM crcomp_pair_OHLC_1H_history
                                   WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                                         AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point hours' order by timestamp_point ASC) AS ds1
                      WINDOW vlt_wnd_01 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_01 PRECEDING AND CURRENT ROW),
                             vlt_wnd_02 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_02 PRECEDING AND CURRENT ROW),
                             vlt_wnd_03 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_03 PRECEDING AND CURRENT ROW)" ;
   }

if ( $pv{time_frame} eq "2H" ) { $ext_period_real_point = ($pv{count_prds} + $max_ema_periods + 1) * 2 ;
   $request = "SELECT currency, reference_currency, tst_point, PRICE_OPEN, PRICE_MIN, PRICE_MAX, PRICE_CLOSE, hours, minutes,
                      round(((PRICE_MAX - LAG(PRICE_MIN,$sql_vlt_wnd_01) OVER vlt_wnd_01)/(LAG(PRICE_MIN,$sql_vlt_wnd_01) OVER vlt_wnd_01/100)),2) as VLT_PRCT_01,
                      round(((max(PRICE_MAX) OVER vlt_wnd_01 - min(PRICE_MIN) OVER vlt_wnd_01)/(min(PRICE_MIN) OVER vlt_wnd_01/100)),2) as MAX_VLT_PRCT_01,
                      round(((max(PRICE_MAX) OVER vlt_wnd_02 - min(PRICE_MIN) OVER vlt_wnd_02)/(min(PRICE_MIN) OVER vlt_wnd_02/100)),2) as MAX_VLT_PRCT_02,
                      round(((max(PRICE_MAX) OVER vlt_wnd_03 - min(PRICE_MIN) OVER vlt_wnd_03)/(min(PRICE_MIN) OVER vlt_wnd_03/100)),2) as MAX_VLT_PRCT_03
                      from (SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS') tst_point,
                   LAG(price_open,1) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                   min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                   max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                   price_close PRICE_CLOSE, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours, extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes
                   FROM crcomp_pair_OHLC_1H_history
                   WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                         AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point hours' order by timestamp_point ASC) AS ds1
                   WINDOW vlt_wnd_01 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_01 PRECEDING AND CURRENT ROW),
                             vlt_wnd_02 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_02 PRECEDING AND CURRENT ROW),
                             vlt_wnd_03 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_03 PRECEDING AND CURRENT ROW)" ;
   }

if ( $pv{time_frame} eq "1H" ) { $ext_period_real_point = $pv{count_prds} + $max_ema_periods + 1 ;
$request = "SELECT currency, reference_currency, tst_point, PRICE_OPEN, PRICE_MIN, PRICE_MAX, PRICE_CLOSE, hours, minutes,
                      round(((PRICE_MAX - LAG(PRICE_MIN,$sql_vlt_wnd_01) OVER vlt_wnd_01)/(LAG(PRICE_MIN,$sql_vlt_wnd_01) OVER vlt_wnd_01/100)),2) as VLT_PRCT_01,
                      round(((max(PRICE_MAX) OVER vlt_wnd_01 - min(PRICE_MIN) OVER vlt_wnd_01)/(min(PRICE_MIN) OVER vlt_wnd_01/100)),2) as MAX_VLT_PRCT_01,
                      round(((max(PRICE_MAX) OVER vlt_wnd_02 - min(PRICE_MIN) OVER vlt_wnd_02)/(min(PRICE_MIN) OVER vlt_wnd_02/100)),2) as MAX_VLT_PRCT_02,
                      round(((max(PRICE_MAX) OVER vlt_wnd_03 - min(PRICE_MIN) OVER vlt_wnd_03)/(min(PRICE_MIN) OVER vlt_wnd_03/100)),2) as MAX_VLT_PRCT_03
                      from (SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS') tst_point,
                   price_open as PRICE_OPEN, price_low as PRICE_MIN, price_high as PRICE_MAX, price_close PRICE_CLOSE,
                   extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours, extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes
                   FROM crcomp_pair_OHLC_1H_history
                   WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                         AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point hours' order by timestamp_point ASC) AS ds1
                   WINDOW vlt_wnd_01 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_01 PRECEDING AND CURRENT ROW),
                             vlt_wnd_02 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_02 PRECEDING AND CURRENT ROW),
                             vlt_wnd_03 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_03 PRECEDING AND CURRENT ROW)" ;
   }

if ( $pv{time_frame} eq "30M" ) { $ext_period_real_point = ($pv{count_prds} + $max_ema_periods + 1) * 30 ;
   $request = "SELECT currency, reference_currency, tst_point, PRICE_OPEN, PRICE_MIN, PRICE_MAX, PRICE_CLOSE, hours, minutes,
                      round(((PRICE_MAX - LAG(PRICE_MIN,$sql_vlt_wnd_01) OVER vlt_wnd_01)/(LAG(PRICE_MIN,$sql_vlt_wnd_01) OVER vlt_wnd_01/100)),2) as VLT_PRCT_01,
                      round(((max(PRICE_MAX) OVER vlt_wnd_01 - min(PRICE_MIN) OVER vlt_wnd_01)/(min(PRICE_MIN) OVER vlt_wnd_01/100)),2) as MAX_VLT_PRCT_01,
                      round(((max(PRICE_MAX) OVER vlt_wnd_02 - min(PRICE_MIN) OVER vlt_wnd_02)/(min(PRICE_MIN) OVER vlt_wnd_02/100)),2) as MAX_VLT_PRCT_02,
                      round(((max(PRICE_MAX) OVER vlt_wnd_03 - min(PRICE_MIN) OVER vlt_wnd_03)/(min(PRICE_MIN) OVER vlt_wnd_03/100)),2) as MAX_VLT_PRCT_03
                      from (SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS') tst_point,
                   LAG(price_open,29) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                   min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                   max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                   price_close PRICE_CLOSE, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours, extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes
                   FROM crcomp_pair_OHLC_1M_history
                   WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                         AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point minutes' order by timestamp_point ASC) AS ds1
                      WINDOW vlt_wnd_01 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_01 PRECEDING AND CURRENT ROW),
                             vlt_wnd_02 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_02 PRECEDING AND CURRENT ROW),
                             vlt_wnd_03 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_03 PRECEDING AND CURRENT ROW)" ;
   }

if ( $pv{time_frame} eq "15M" ) { $ext_period_real_point = ($pv{count_prds} + $max_ema_periods + 1) * 15 ;
   $request = "SELECT currency, reference_currency, tst_point, PRICE_OPEN, PRICE_MIN, PRICE_MAX, PRICE_CLOSE, hours, minutes,
                      round(((PRICE_MAX - LAG(PRICE_MIN,$sql_vlt_wnd_01) OVER vlt_wnd_01)/(LAG(PRICE_MIN,$sql_vlt_wnd_01) OVER vlt_wnd_01/100)),2) as VLT_PRCT_01,
                      round(((max(PRICE_MAX) OVER vlt_wnd_01 - min(PRICE_MIN) OVER vlt_wnd_01)/(min(PRICE_MIN) OVER vlt_wnd_01/100)),2) as MAX_VLT_PRCT_01,
                      round(((max(PRICE_MAX) OVER vlt_wnd_02 - min(PRICE_MIN) OVER vlt_wnd_02)/(min(PRICE_MIN) OVER vlt_wnd_02/100)),2) as MAX_VLT_PRCT_02,
                      round(((max(PRICE_MAX) OVER vlt_wnd_03 - min(PRICE_MIN) OVER vlt_wnd_03)/(min(PRICE_MIN) OVER vlt_wnd_03/100)),2) as MAX_VLT_PRCT_03
                      from (SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS') tst_point,
                   LAG(price_open,14) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 14 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                   min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 14 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                   max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 14 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                   price_close PRICE_CLOSE, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours, extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes
                   FROM crcomp_pair_OHLC_1M_history
                   WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                         AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point minutes' order by timestamp_point ASC) AS ds1
                      WINDOW vlt_wnd_01 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_01 PRECEDING AND CURRENT ROW),
                             vlt_wnd_02 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_02 PRECEDING AND CURRENT ROW),
                             vlt_wnd_03 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_03 PRECEDING AND CURRENT ROW)" ;
   }

if ( $pv{time_frame} eq "10M" ) { $ext_period_real_point = ($pv{count_prds} + $max_ema_periods + 1) * 10 ;
   $request = "SELECT currency, reference_currency, tst_point, PRICE_OPEN, PRICE_MIN, PRICE_MAX, PRICE_CLOSE, hours, minutes,
                      round(((PRICE_MAX - LAG(PRICE_MIN,$sql_vlt_wnd_01) OVER vlt_wnd_01)/(LAG(PRICE_MIN,$sql_vlt_wnd_01) OVER vlt_wnd_01/100)),2) as VLT_PRCT_01,
                      round(((max(PRICE_MAX) OVER vlt_wnd_01 - min(PRICE_MIN) OVER vlt_wnd_01)/(min(PRICE_MIN) OVER vlt_wnd_01/100)),2) as MAX_VLT_PRCT_01,
                      round(((max(PRICE_MAX) OVER vlt_wnd_02 - min(PRICE_MIN) OVER vlt_wnd_02)/(min(PRICE_MIN) OVER vlt_wnd_02/100)),2) as MAX_VLT_PRCT_02,
                      round(((max(PRICE_MAX) OVER vlt_wnd_03 - min(PRICE_MIN) OVER vlt_wnd_03)/(min(PRICE_MIN) OVER vlt_wnd_03/100)),2) as MAX_VLT_PRCT_03
                      from (SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS') tst_point,
                   LAG(price_open,9) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                   min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                   max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                   price_close PRICE_CLOSE, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours, extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes
                   FROM crcomp_pair_OHLC_1M_history
                   WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                         AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point minutes' order by timestamp_point ASC) AS ds1
                      WINDOW vlt_wnd_01 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_01 PRECEDING AND CURRENT ROW),
                             vlt_wnd_02 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_02 PRECEDING AND CURRENT ROW),
                             vlt_wnd_03 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_03 PRECEDING AND CURRENT ROW)" ;
   }

if ( $pv{time_frame} eq "5M" ) { $ext_period_real_point = ($pv{count_prds} + $max_ema_periods + 1) * 5 ;
   $request = "SELECT currency, reference_currency, tst_point, PRICE_OPEN, PRICE_MIN, PRICE_MAX, PRICE_CLOSE, hours, minutes,
                      round(((PRICE_MAX - LAG(PRICE_MIN,$sql_vlt_wnd_01) OVER vlt_wnd_01)/(LAG(PRICE_MIN,$sql_vlt_wnd_01) OVER vlt_wnd_01/100)),2) as VLT_PRCT_01,
                      round(((max(PRICE_MAX) OVER vlt_wnd_01 - min(PRICE_MIN) OVER vlt_wnd_01)/(min(PRICE_MIN) OVER vlt_wnd_01/100)),2) as MAX_VLT_PRCT_01,
                      round(((max(PRICE_MAX) OVER vlt_wnd_02 - min(PRICE_MIN) OVER vlt_wnd_02)/(min(PRICE_MIN) OVER vlt_wnd_02/100)),2) as MAX_VLT_PRCT_02,
                      round(((max(PRICE_MAX) OVER vlt_wnd_03 - min(PRICE_MIN) OVER vlt_wnd_03)/(min(PRICE_MIN) OVER vlt_wnd_03/100)),2) as MAX_VLT_PRCT_03
                      from (SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS') tst_point,
                   LAG(price_open,4) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                   min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                   max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                   price_close PRICE_CLOSE, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours, extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes
                   FROM crcomp_pair_OHLC_1M_history
                   WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                         AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point minutes' order by timestamp_point ASC) AS ds1
                      WINDOW vlt_wnd_01 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_01 PRECEDING AND CURRENT ROW),
                             vlt_wnd_02 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_02 PRECEDING AND CURRENT ROW),
                             vlt_wnd_03 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_03 PRECEDING AND CURRENT ROW)" ;
   }

if ( $pv{time_frame} eq "3M" ) { $ext_period_real_point = ($pv{count_prds} + $max_ema_periods + 1) * 3 ;
   $request = "SELECT currency, reference_currency, tst_point, PRICE_OPEN, PRICE_MIN, PRICE_MAX, PRICE_CLOSE, hours, minutes,
                      round(((PRICE_MAX - LAG(PRICE_MIN,$sql_vlt_wnd_01) OVER vlt_wnd_01)/(LAG(PRICE_MIN,$sql_vlt_wnd_01) OVER vlt_wnd_01/100)),2) as VLT_PRCT_01,
                      round(((max(PRICE_MAX) OVER vlt_wnd_01 - min(PRICE_MIN) OVER vlt_wnd_01)/(min(PRICE_MIN) OVER vlt_wnd_01/100)),2) as MAX_VLT_PRCT_01,
                      round(((max(PRICE_MAX) OVER vlt_wnd_02 - min(PRICE_MIN) OVER vlt_wnd_02)/(min(PRICE_MIN) OVER vlt_wnd_02/100)),2) as MAX_VLT_PRCT_02,
                      round(((max(PRICE_MAX) OVER vlt_wnd_03 - min(PRICE_MIN) OVER vlt_wnd_03)/(min(PRICE_MIN) OVER vlt_wnd_03/100)),2) as MAX_VLT_PRCT_03
                      from (SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS') tst_point,
                   LAG(price_open,2) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                   min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                   max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                   price_close PRICE_CLOSE, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours, extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes
                   FROM crcomp_pair_OHLC_1M_history
                   WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                         AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point minutes' order by timestamp_point ASC) AS ds1
                      WINDOW vlt_wnd_01 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_01 PRECEDING AND CURRENT ROW),
                             vlt_wnd_02 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_02 PRECEDING AND CURRENT ROW),
                             vlt_wnd_03 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_03 PRECEDING AND CURRENT ROW)" ;
   }

if ( $pv{time_frame} eq "1M" ) { $ext_period_real_point = $pv{count_prds} + $max_ema_periods + 1 ;
   $request = "SELECT currency, reference_currency, tst_point, PRICE_OPEN, PRICE_MIN, PRICE_MAX, PRICE_CLOSE, hours, minutes,
                      round(((PRICE_MAX - LAG(PRICE_MIN,$sql_vlt_wnd_01) OVER vlt_wnd_01)/(LAG(PRICE_MIN,$sql_vlt_wnd_01) OVER vlt_wnd_01/100)),2) as VLT_PRCT_01,
                      round(((max(PRICE_MAX) OVER vlt_wnd_01 - min(PRICE_MIN) OVER vlt_wnd_01)/(min(PRICE_MIN) OVER vlt_wnd_01/100)),2) as MAX_VLT_PRCT_01,
                      round(((max(PRICE_MAX) OVER vlt_wnd_02 - min(PRICE_MIN) OVER vlt_wnd_02)/(min(PRICE_MIN) OVER vlt_wnd_02/100)),2) as MAX_VLT_PRCT_02,
                      round(((max(PRICE_MAX) OVER vlt_wnd_03 - min(PRICE_MIN) OVER vlt_wnd_03)/(min(PRICE_MIN) OVER vlt_wnd_03/100)),2) as MAX_VLT_PRCT_03
                      from (SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS') tst_point,
                   price_open as PRICE_OPEN, price_low as PRICE_MIN, price_high PRICE_MAX, price_close PRICE_CLOSE,
                   extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours, extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes
                   FROM crcomp_pair_OHLC_1M_history
                   WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                         AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point minutes' order by timestamp_point ASC) AS ds1
                      WINDOW vlt_wnd_01 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_01 PRECEDING AND CURRENT ROW),
                             vlt_wnd_02 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_02 PRECEDING AND CURRENT ROW),
                             vlt_wnd_03 AS (PARTITION BY currency, reference_currency ORDER BY (tst_point) ASC ROWS BETWEEN $sql_vlt_wnd_03 PRECEDING AND CURRENT ROW)" ;
   }

if ( $pv{output_type} eq "query" ) { print "Content-Type: text/html\n\n$request\n\n" ; exit ; }

#$dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=$host;port=$port;options=$options", $username, $password, {AutoCommit => 0, RaiseError => 1, PrintError => 0} );
my $dbh_h = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'pg_password_value') ;
my $sth_h = $dbh_h->prepare($request) ; $sth_h->execute(); $count_rows = 0 ;

# заполнить промежуточный массив с префиксным расширением периодов - только для граничных записей периода
# и рассчитать ЕМА
my $currency = "" ; my $reference_currency ="" ; my $datetime_point = "" ; my $price_open = 0 ; my $price_min = 0 ; my $price_max = 0 ; my $price_close = 0 ;
my $hours = 0 ; my $minutes = 0 ; my $vlt_01 = 0 ; my $max_vlt_01 = 0 ; my $max_vlt_02 = 0 ; my $max_vlt_03 = 0 ;
my @data_cartrige = () ;
#while (my ($currency, $reference_currency, $datetime_point, $price_open, $price_min, $price_max, $price_close, $hours, $minutes) = $sth_h->fetchrow_array() ) {
while ( @data_cartrige = $sth_h->fetchrow_array() ) {
      $currency = $data_cartrige[0] ; $reference_currency = $data_cartrige[1] ; $datetime_point = $data_cartrige[2] ; $price_open = $data_cartrige[3]; $price_min = $data_cartrige[4] ;
      $price_max = $data_cartrige[5] ; $price_close = $data_cartrige[6] ; $hours = $data_cartrige[7] ; $minutes = $data_cartrige[8] ; $vlt_01 = $data_cartrige[9] ;
      $max_vlt_01 = $data_cartrige[10] ; $max_vlt_02 = $data_cartrige[11] ; $max_vlt_03 = $data_cartrige[12] ;
      if ( ( $pv{time_frame} eq "4H" && ( $hours == 1 || $hours == 5 || $hours == 9 || $hours == 13 || $hours == 17 || $hours == 21 ) && $minutes == 0 ) ||
           ( $pv{time_frame} eq "3H" && ( $hours == 1 || $hours == 4 || $hours == 7 || $hours == 10 || $hours == 13 || $hours == 16 || $hours == 19 || $hours == 22 ) && $minutes == 0 ) ||
           ( $pv{time_frame} eq "2H" && ( (int($hours / 2) - ($hours / 2)) != 0 && $minutes == 0 )) ||
           ( $pv{time_frame} eq "1H" && ( $minutes == 0 )) ||
           ( $pv{time_frame} eq "30M" && ( $minutes == 0 || $minutes == 30 )) ||
           ( $pv{time_frame} eq "15M" && ( $minutes == 0 || $minutes == 15 || $minutes == 30 || $minutes == 45 )) ||
           ( $pv{time_frame} eq "10M" && ( $minutes == 0 || $minutes == 10 || $minutes == 20 || $minutes == 30 || $minutes == 40 || $minutes == 50 )) ||
           ( $pv{time_frame} eq "5M" &&
             ( $minutes == 0 || $minutes == 5 || $minutes == 10 || $minutes == 15 || $minutes == 20 || $minutes == 25 || $minutes == 30 || $minutes == 35 || $minutes == 40 || $minutes == 45 || $minutes == 50 || $minutes == 55)) ||
           ( $pv{time_frame} eq "3M" &&
             ( $minutes == 0 || $minutes == 3 || $minutes == 6 || $minutes == 9 || $minutes == 12 || $minutes == 15 || $minutes == 18 || $minutes == 21 ||
               $minutes == 24 || $minutes == 27 || $minutes == 30 || $minutes == 33 || $minutes == 36 || $minutes == 39 || $minutes == 42 || $minutes == 45 ||
               $minutes == 48 || $minutes == 51 || $minutes == 54 || $minutes == 57)) ||
           ( $pv{time_frame} eq "1M" ) || ( $pv{time_frame} eq "1D" ) ) {
         $datetime_point =~ s/\d\d\d\d-(\d\d)-(\d\d) (\d\d:\d\d):\d\d/$3/g ;
         $ds_datetime_list[$count_rows] = $datetime_point ;
         $ds_hours_list[$count_rows] = $hours ;
         $ds_minutes_list[$count_rows] = $minutes ;
# для начальных записей при использовании оконных функций значения могут быть пустые, а т.к. набор данных может не иметь расширенного диапазона дней, он войдут в конечный массив
# нужно подать правильные значения - пустые графической библиотекой не допускаются
         if ( $price_open eq "" ) { $price_open = $price_close ; }
         $ds_price_open[$count_rows] = $price_open ;
         $ds_price_min[$count_rows] = $price_min ;
         $ds_price_max[$count_rows] = $price_max ;
         $ds_price_close[$count_rows] = $price_close ;
# рассчиталь EMA для текущей строки и заполнить ячейку массива
         if ( $count_rows == 0 ) { $ds_curr_ema[$count_rows] = $price_close ; } else { $ds_curr_ema[$count_rows] = ( $price_close * $curr_ema_mult) + ($ds_curr_ema[$count_rows - 1] * (1 - $curr_ema_mult)) ; }
         if ( $count_rows == 0 ) { $ds_day_ema[$count_rows] = $price_close ; } else { $ds_day_ema[$count_rows] = ( $price_close * $day_ema_mult) + ($ds_day_ema[$count_rows - 1] * (1 - $day_ema_mult)) ; }
         if ( $count_rows == 0 ) { $ds_week_ema[$count_rows] = $price_close ; } else { $ds_week_ema[$count_rows] = ( $price_close * $week_ema_mult) + ($ds_week_ema[$count_rows - 1] * (1 - $week_ema_mult)) ; }
#print "--- $date_list[$count_rows] --- $ds_price_close[$count_rows] --- $ds_curr_ema[$count_rows] --- \n" ;

# заполнить массивы конверта
         $ds_env_top[$count_rows] = $ds_curr_ema[$count_rows] + ($ds_curr_ema[$count_rows] / 100 * $pv{env_prct}) ;
         $ds_env_dwn[$count_rows] = $ds_curr_ema[$count_rows] - ($ds_curr_ema[$count_rows] / 100 * $pv{env_prct}) ;
         $ds_vlt_01[$count_rows] = $vlt_01 ;
         $ds_max_vlt_01[$count_rows] = $max_vlt_01 ;
         $ds_max_vlt_02[$count_rows] = $max_vlt_02 ;
         $ds_max_vlt_03[$count_rows] = $max_vlt_03 ;
         $count_rows += 1 ;
#-debug-system("echo \"faza1 $datetime_point - $hours - $minutes\" >> /tmp/test_xxx.$pv{currency}") ;
         }
      }

$sth_h->finish() ;
$dbh_h->disconnect() ;

# заполнить хвост - последнее значение, не дожидаясь закрытия периода
#-debug-open(DEB_FILE,">>/tmp/test_xxx.$pv{currency}") ;
#-debug-printf DEB_FILE "faza2 - $datetime_point - $hours - $minutes \n" ;
#-debug-close(DEB_FILE) ;
#-debug-#system("echo \"- $hours - $minutes\" > /tmp/test_xxx.$pv{currency}") ;
if ( ( $pv{time_frame} eq "4H" && (( $hours != 1 || $hours != 5 || $hours != 9 || $hours != 13 || $hours != 17 || $hours != 21 ) || $minutes != 0 )) ||
     ( $pv{time_frame} eq "3H" && (( $hours != 1 || $hours != 4 || $hours != 7 || $hours != 10 || $hours != 13 || $hours != 16 || $hours != 19 || $hours != 22 ) || $minutes != 0 )) ||
     ( $pv{time_frame} eq "2H" && ( (int($hours / 2) - ($hours / 2)) == 0 && $minutes != 0 )) ||
     ( $pv{time_frame} eq "1H" && ( $minutes != 0 )) ||
     ( $pv{time_frame} eq "30M" && ( $minutes != 0 || $minutes != 30 )) ||
     ( $pv{time_frame} eq "15M" && ( $minutes != 0 || $minutes != 15 || $minutes != 30 || $minutes != 45 )) ||
     ( $pv{time_frame} eq "10M" && ( $minutes != 0 || $minutes != 10 || $minutes != 20 || $minutes != 30 || $minutes != 40 || $minutes != 50 )) ||
     ( $pv{time_frame} eq "5M" &&
       ( $minutes != 0 || $minutes != 5 || $minutes != 10 || $minutes != 15 || $minutes != 20 || $minutes != 25 || $minutes != 30 || $minutes != 35 || $minutes != 40 || $minutes != 45 || $minutes != 50 || $minutes != 55)) ||
     ( $pv{time_frame} eq "3M" &&
       ( $minutes != 0 || $minutes != 3 || $minutes != 6 || $minutes != 9 || $minutes != 12 || $minutes != 15 || $minutes != 18 || $minutes != 21 ||
         $minutes != 24 || $minutes != 27 || $minutes != 30 || $minutes != 33 || $minutes != 36 || $minutes != 39 || $minutes != 42 || $minutes != 45 ||
         $minutes != 48 || $minutes != 51 || $minutes != 54 || $minutes != 57)) ) {
#-debug-$aa = (int($hours / 2) - ($hours / 2)) ;
   $datetime_point =~ s/\d\d\d\d-(\d\d)-(\d\d) (\d\d:\d\d):\d\d/$3/g ;
   $ds_datetime_list[$count_rows] = $datetime_point ;
   $ds_hours_list[$count_rows] = $hours ;
   $ds_minutes_list[$count_rows] = $minutes ;
# для начальных записей при использовании оконных функций значения могут быть пустые, а т.к. набор данных может не иметь расширенного диапазона дней, он войдут в конечный массив
# нужно подать правильные значения - пустые графической библиотекой не допускаются
   if ( $price_open eq "" ) { $price_open = $price_close ; }
   $ds_price_open[$count_rows] = $price_open ;
   $ds_price_min[$count_rows] = $price_min ;
   $ds_price_max[$count_rows] = $price_max ;
   $ds_price_close[$count_rows] = $price_close ;

# рассчиталь EMA для текущей строки и заполнить ячейку массива
   if ( $count_rows == 0 ) { $ds_curr_ema[$count_rows] = $price_close ; } else { $ds_curr_ema[$count_rows] = ( $price_close * $curr_ema_mult) + ($ds_curr_ema[$count_rows - 1] * (1 - $curr_ema_mult)) ; }
   if ( $count_rows == 0 ) { $ds_day_ema[$count_rows] = $price_close ; } else { $ds_day_ema[$count_rows] = ( $price_close * $day_ema_mult) + ($ds_day_ema[$count_rows - 1] * (1 - $day_ema_mult)) ; }
   if ( $count_rows == 0 ) { $ds_week_ema[$count_rows] = $price_close ; } else { $ds_week_ema[$count_rows] = ( $price_close * $week_ema_mult) + ($ds_week_ema[$count_rows -1 ] * (1 - $week_ema_mult)) ; }
#print "--- $date_list[$count_rows] --- $ds_price_close[$count_rows] --- $ds_curr_ema[$count_rows] --- \n" ;

# заполнить массивы конверта
   $ds_env_top[$count_rows] = $ds_curr_ema[$count_rows] + ($ds_curr_ema[$count_rows] / 100 * $pv{env_prct}) ;
   $ds_env_dwn[$count_rows] = $ds_curr_ema[$count_rows] - ($ds_curr_ema[$count_rows] / 100 * $pv{env_prct}) ;
   $ds_vlt_01[$count_rows] = $vlt_01 ;
   $ds_max_vlt_01[$count_rows] = $max_vlt_01 ;
   $ds_max_vlt_02[$count_rows] = $max_vlt_02 ;
   $ds_max_vlt_03[$count_rows] = $max_vlt_03 ;
#-debug-system("echo \"faza3 include - $aa - $hours - $minutes --- $ds_datetime_list[$count_rows] - $ds_hours_list[$count_rows] - $ds_minutes_list[$count_rows] - $ds_price_open[$count_rows] - $ds_price_min[$count_rows] - $ds_price_max[$count_rows] - $ds_price_close[$count_rows] - ema $ds_curr_ema[$count_rows] - day $ds_day_ema[$count_rows] - week $ds_week_ema[$count_rows]\" >> /tmp/test_xxx.$pv{currency}") ;
   $count_rows += 1 ;
   }

# берём количество результирующих строк без добавленного префикса дней меньше, чем изначально запрошено - в источнике данных было меньше строк
# если записей в БД не хватило на расширенный период - дельта как раз охватит разницу, если совсем не хватило и вышло отрицательное - дельта = 0, т.ею не применяется
my $delta_if_less = $count_rows - $pv{count_prds} ;
if ( $delta_if_less < 0) { $delta_if_less = 0 ; }

#-debug-print "== delta_if_less == $delta_if_less\n" ;
my $count_rows_post = 0 ;
for ($i=1; $i <= $count_rows ; $i = $i+1) {
# учесть дельту
    if (($i - $delta_if_less) > 0) {
#-debug-$aa = int($ds_hours_list[$i - 1] / 2) ; $bb = $ds_hours_list[$i - 1] / 2) ; print "--- $aa \n\n\n" ;
#       if ( (int($ds_hours_list[$i - 1] / 2) - ($ds_hours_list[$i - 1] / 2)) == 0 && $ds_minutes_list[$i - 1] == 0) {
          $ds_end_datetime_list[$count_rows_post] = $ds_datetime_list[$i - 1] ;
          $ds_end_hours_list[$count_rows_post] = $ds_hours_list[$i - 1] ;
          $ds_end_minutes_list[$count_rows_post] = $ds_minutes_list[$i - 1] ;
          $ds_end_price_open[$count_rows_post] = $ds_price_open[$i - 1] ;
          $ds_end_price_min[$count_rows_post] = $ds_price_min[$i - 1] ;
          $ds_end_price_max[$count_rows_post] = $ds_price_max[$i - 1] ;
          $ds_end_price_close[$count_rows_post] = $ds_price_close[$i - 1] ;
          $ds_end_curr_ema[$count_rows_post] = $ds_curr_ema[$i - 1] ;
          $ds_end_day_ema[$count_rows_post] = $ds_day_ema[$i - 1] ;
          $ds_end_week_ema[$count_rows_post] = $ds_week_ema[$i - 1] ;
          $ds_end_env_top[$count_rows_post] = $ds_env_top[$i - 1] ;
          $ds_end_env_dwn[$count_rows_post] = $ds_env_dwn[$i - 1] ;
          $ds_end_vlt_01[$count_rows_post] = $ds_vlt_01[$i - 1] ; 
          if ( $ds_end_vlt_01[$count_rows_post] < 0 ) { $ds_end_vlt_01[$count_rows_post] = $ds_end_vlt_01[$count_rows_post] * -1 ; }
          if ( $ds_end_vlt_01[$count_rows_post] eq "" ) { $ds_end_vlt_01[$count_rows_post] = 0 ; }
          $ds_end_max_vlt_01[$count_rows_post] = $ds_max_vlt_01[$i - 1] ; if ( $ds_end_max_vlt_01[$count_rows_post] eq "" ) { $ds_end_max_vlt_01[$count_rows_post] = 0 ; }
          $ds_end_max_vlt_02[$count_rows_post] = $ds_max_vlt_02[$i - 1] ; if ( $ds_end_max_vlt_02[$count_rows_post] eq "" ) { $ds_end_max_vlt_02[$count_rows_post] = 0 ; }
          $ds_end_max_vlt_03[$count_rows_post] = $ds_max_vlt_03[$i - 1] ; if ( $ds_end_max_vlt_03[$count_rows_post] eq "" ) { $ds_end_max_vlt_03[$count_rows_post] = 0 ; }

#-debug-#system("echo \"faza4 include - $aa - $hours - $minutes --- $ds_end_datetime_list[$count_rows] - $ds_hours_list[$count_rows] - $ds_minutes_list[$count_rows] - $ds_price_open[$count_rows] - $ds_price_min[$count_rows] - $ds_price_max[$count_rows] - $ds_price_close[$count_rows] - ema $ds_curr_ema[$count_rows] - day $ds_day_ema[$count_rows] - week $ds_week_ema[$count_rows]\" >> /tmp/test_xxx.$pv{currency}") ;
          $count_rows_post += 1 ;
#          }
#-debug-$tmp1 = $i - $delta_if_less - 1 ;
#-debug-$tmp2 = $i - 1 ;
#-debug-print "string - $tmp1 - $tmp2 - $ds_end_date_list[$i - $delta_if_less - 1] - $ds_end_price_open[$i - $delta_if_less - 1] - $ds_end_price_min[$i - $delta_if_less - 1] - $ds_end_price_max[$i - $delta_if_less - 1] - $ds_end_price_close[$i - $delta_if_less - 1] - $ds_end_curr_ema[$i - $delta_if_less - 1] - $ds_end_week_ema[$i - $delta_if_less - 1] - $ds_end_env_top[$i - $delta_if_less - 1] - $ds_end_env_dwn[$i - $delta_if_less - 1]\n" ;
       }
    }

#-debug-exit ;

if ( $pv{output_type} eq "table" || $pv{output_type} eq "file" ) {
   print "Content-Type: text/html\n\n" ;
   print "<HTML>
<HEAD>
<BASE HREF=\"$COMM_PAR_BASE_HREF/\">
<LINK REL=STYLESHEET HREF=\"$COMM_PAR_BASE_HREF\/css\/common.css\">
<META HTTP-EQUIV=\"Cache-Control\" content=\"no-cache, no-store, max-age=0, must-revalidate\">
<META HTTP-EQUIV=\"Pragma\" content=\"no-cache\">
<META HTTP-EQUIV=\"Expires\" content=\"Fri, 01 Jan 1990 00:00:00 GMT\">
<META HTTP_EQUIV=\"CONTENT-TYPE\" CONTENT=\"text/html; charset=utf-8\">
</HEAD>
<BODY>
<STYLE>
BODY { font-family: sans-serif; font-size: 10pt; }
TD { font-family: sans-serif; font-size: 10pt; }
TD.coinlines { background-color: navy; color: white; }
H1 { text-align: right; color: navy ; }
H2 { text-align: right; color: navy ; }
</STYLE>

<H1>Данные графика цен и EMA $pv{currency} / $pv{curr_reference}</H1>
<H2>таймфрэйм: $pv{tima_frame}, глубина $pv{count_prds} периодов
<BR>глубина EMA: curr $pv{curr_ema_cnt_prds} / day $pv{day_ema_cnt_prds} / week $pv{week_ema_cnt_prds}
<BR>глубина конверта:
</H2>

<TABLE BORDER=\"1\"><TR><TD STYLE=\"text-align: center;\">№</TD>
       <TD STYLE=\"text-align: center;\">Дата</TD>
       <TD STYLE=\"text-align: center;\">Открытие</TD>
       <TD STYLE=\"text-align: center;\">Минимальная</TD>
       <TD STYLE=\"text-align: center;\">Максимальная</TD>
       <TD STYLE=\"text-align: center;\">Закрытия</TD>
       <TD STYLE=\"text-align: center;\">EMA текущая</TD>
       <TD STYLE=\"text-align: center;\">EMA дневная</TD>
       <TD STYLE=\"text-align: center;\">EMA недельная</TD>
       <TD STYLE=\"text-align: center;\">Часы</TD>
       <TD STYLE=\"text-align: center;\">Минуты</TD>
       <TD STYLE=\"text-align: center;\">Волатильность по границе окна</TD>
       <TD STYLE=\"text-align: center;\">Волатильность внутри окна</TD>
       </TR>" ;
   for ($curr_row = 0; $curr_row <= $#ds_end_datetime_list ; $curr_row += 1) {
       print "<TR><TD>$curr_row</TD>
                  <TD>$ds_end_datetime_list[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_price_open[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_price_min[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_price_max[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_price_close[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_curr_ema[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_day_ema[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_week_ema[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_hours_list[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_minutes_list[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_vlt_01[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_max_vlt_01[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_max_vlt_02[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_max_vlt_03[$curr_row]</TD>
               </TR>\n" ;
       }
   print "</TABLE>" ;
   }

if ( $pv{output_type} eq "graph" || $pv{output_type} eq "file" ) {
   my $graphic ;
   my $min_y ;
   my $max_y ;

   $graphic = Chart::Lines->new( $pv{x_size}, $pv{y_size} ) ;
   $graphic->set( 'brush_size' => $pv{brush_size} ) ;

   $graphic->add_dataset(@ds_end_datetime_list) ;
   $graphic->add_dataset(@ds_end_vlt_01) ;
   $graphic->add_dataset(@ds_end_max_vlt_01) ;
   $graphic->add_dataset(@ds_end_max_vlt_02) ;
   $graphic->add_dataset(@ds_end_max_vlt_03) ;

   $min_y = $ds_end_max_votatility[0] ; foreach (@ds_end_max_votatility) { if ( $_ < $min_y ) { $min_y = $_; } }
   $max_y = $ds_end_max_votatility[0] ; foreach (@ds_end_max_votatility) { if ( $_ > $max_y ) { $max_y = $_; } }

   $graphic->set( 'min_val' => $min_y ) ;
   $graphic->set( 'max_val' => $max_y ) ;

   my $precision = 4 ;
   if ( $max_y < 1 ) { $precision = 5 ; }
   if ( $max_y < 0.1 ) { $precision = 6 ; }
   if ( $max_y < 0.01 ) { $precision = 7 ; }
   if ( $max_y < 0.001 ) { $precision = 8 ; }
   if ( $max_y < 0.0001 ) { $precision = 9 ; }
   if ( $max_y < 0.00001 ) { $precision = 10 ; }
   if ( $max_y < 0.000001 ) { $precision = 11 ; }
   if ( $max_y < 0.0000001 ) { $precision = 12 ; }
   if ( $max_y < 0.00000001 ) { $precision = 13 ; }
   if ( $max_y < 0.000000001 ) { $precision = 14 ; }
   if ( $max_y < 0.0000000001 ) { $precision = 15 ; }
   if ( $max_y < 0.00000000001 ) { $precision = 16 ; }
   if ( $max_y < 0.000000000001 ) { $precision = 17 ; }
   if ( $max_y < 0.0000000000001 ) { $precision = 18 ; }
   if ( $max_y < 0.00000000000001 ) { $precision = 19 ; }
#   $graphic->set( 'precision' => $precision );

   $graphic->set( 'max_y_ticks' => 24 ) ;
   $graphic->set( 'min_y_ticks' => 8 ) ;

# - похоже, влияет только на линии сетки и подписи, на основаниир сверки скриншотов. Без этого параметра плохо читаемо
   my $skip_x_ticks = ($count_rows - $delta_if_less) / 80 ;
#   my $skip_x_ticks = 2 ;

   $graphic->set( 'skip_x_ticks'    => $skip_x_ticks,
                  'x_ticks'         => 'vertical',
                  'grey_background' => 'false',
                  'graph_border'    => 1,
                  'y_grid_lines'    => 'true',
                  'x_grid_lines'    => 'true',
                  'legend'          => 'none',
                  'y_label'         => "Volatility $pv{time_frame}, PRDs $pv{vlt_wnd_02}/$pv{vlt_wnd_01}/$pv{vlt_wnd_03} $pv{currency}/$pv{curr_reference}",
                  'label_font'      => GD::Font->Giant,
                  'y_axes'          => 'both',
                  'precision'       => 4,
                  'transparent'     => 'false',
                  'brush_size'      => $pv{brush_size} ) ;

   $graphic->set( 'colors' => {
                          'y_grid_lines' => [ 127, 127, 0 ],
                          'x_grid_lines' => [ 127, 127, 0 ],
                          'dataset0'     => red,
                          'dataset1'     => navy,
                          'dataset2'     => gray,
                          'dataset3'     => brown
                          } ) ;
   if ( $pv{output_type} eq "graph" ) { $graphic->cgi_png() ; }
   if ( $pv{output_type} eq "file" ) { $graphic->png($pv{file_name}) ; }
   }
