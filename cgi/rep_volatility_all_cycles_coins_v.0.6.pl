#!/usr/bin/perl

# open source soft - (C) 2023 CrAgrAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

use DBI ;
require "/var/www/crypta/cgi/common_parameter.cragregator" ;
require "$cragran_dir_lib/lib_common_func.pl" ;
require "$cragran_dir_lib/lib_cragran_common.pl" ;
require "$cragran_dir_lib/lib_cragran_trading.pl" ;
require "$cragran_dir_lib/lib_cragran_contracts.pl" ;

# параметры по умолчанию
$pv{ema_cnt_periods} = 20 ;
$pv{window_days} = 7 ;
$pv{week_ema_cnt_prds} = 135 ;
$pv{rsi_periods} = 14 ;

$pv{isvw_1D_block} = "no" ;
$pv{isvw_2H_block} = "no" ;
$pv{isvw_1H_block} = "no" ;
$pv{isvw_15M_block} = "no" ;
$pv{isvw_5M_block} = "no" ;
$pv{isvw_1M_block} = "no" ;
$pv{isvw_big_price_EMA} = "yes" ;
$pv{isvw_MACD} = "yes" ;
$pv{isvw_RSI} = "yes" ;
$pv{isvw_ext_indicators} = "yes" ;
$pv{isvw_three_month} = "yes" ;
$pv{isvw_full_periods} = "yes" ;

#$pv{isvw_big_price_EMA} = "no" ;
#$pv{isvw_MACD} = "no" ;
#$pv{isvw_RSI} = "yes" ;
#$pv{isvw_ext_indicators} = "no" ;
#$pv{isvw_three_month} = "no" ;
#$pv{isvw_full_periods} = "no" ;

# - вытащить из URL запроса значения уточняющих полей
&get_forms_param() ;
$pv{count_prds} = $pv{period_days} ;

$CURR_YEAR = `date +%Y` ; $CURR_YEAR =~ s/[\r\n]+//g ;
$count_rows = 0 ;
# дополнено в блоке установки переменных для каждого таймфрэйма
$window_days = 0 ; $window_days = $pv{window_days} - 1 ;
$window_days_label = 0 ;

#@reflist = ('USD', 'BTC') ;
#@coinlist1 = ('BTC','ETH','XRP',"BNB",'ADA','DOGE',"TRX","UNI","MATIC","SOL","DOT","LINK","LTC","BCH","ETC","USDC","WBTC","SHIB","AVAX","OKB","XMR") ;
#@coinlist1 = ('BTC','ETH','XRP',"BNB",'ADA','DOGE',"TRX","UNI","MATIC","SOL","DOT","LINK","LTC","BCH","ETC","USDC","WBTC","SHIB","AVAX","OKB","XMR","1INCH","AAVE","APT","ATOM","AUDIO","BIT","CAKE","COMP","DAI","DASH","DENT","EGLD","FIL","FLOW","ICP","ICX","LDO","LEO","TON", "TKO", "DYDX", "POND", "RIF", "WRX", "ELF" ) ;

$coinlist1 = "'BTC','ETH','XRP','BNB','ADA','DOGE','TRX','UNI','MATIC','SOL','DOT','LINK','LTC','BCH','ETC','USDC','WBTC','SHIB','AVAX','OKB','XMR','1INCH','AAVE','APT','ATOM','AUDIO','BIT','CAKE','COMP','DAI','DASH','DENT','EGLD','FIL','FLOW','ICP','ICX','LDO','LEO','TON', 'TKO', 'DYDX', 'POND', 'RIF', 'WRX', 'ELF'" ;
#$coinlist1 = "'1INCH','SHILL','SHIB','CAKE','TRX','UNI','SOL','EGLD','SHIB','LTC','1INCH','SOL'" ;
#$reflist = "'USD', 'BTC'" ;
$reflist = "'USDT'" ;

$current_coin = "" ;
$curr_ref_coin= "" ;

my $current_timeframe_label = "" ;
my $current_graph_days = "" ;
my $current_volatility_period = 0 ;

# таймфрэйм и количество периодов - это отдельная группа, периоды в формах графиков обрабатываются именно таймфрэймовые явно
if ( $pv{isvw_1D_block} eq "yes" ) { $current_timeframe_label = "1D" ; $current_graph_days = 120 ; $current_graph_days_label = "120 дней" ; $current_count_prds = $current_graph_days ;
   $current_volatility_period = $current_graph_days ; $current_volatility_window = 45 ; $current_volatility_window_label = "45 дней" ; }

if ( $pv{isvw_2H_block} eq "yes" ) { $current_timeframe_label = "2H" ; $current_graph_days = 30 ; $current_graph_days_label = "30 дней" ; $current_count_prds = $current_graph_days * 12 ;
   $current_volatility_period = $current_graph_days * 24 ; $current_volatility_window = 5 ; $current_volatility_window_label = "5 дней" ; }

if ( $pv{isvw_1H_block} eq "yes" ) { $current_timeframe_label = "1H" ; $current_graph_days = 30 ; $current_graph_days_label = "30 дней" ; $current_count_prds = $current_graph_days * 24 ;
   $current_volatility_period = $current_graph_days * 24 ; $current_volatility_window = 5 ; $current_volatility_window_label = "5 дней" ; }

if ( $pv{isvw_15M_block} eq "yes" ) { $current_timeframe_label = "15M" ; $current_graph_days = 10 ; $current_graph_days_label = "10 дней" ; $current_count_prds = $current_graph_days * 96 ;
#   $current_volatility_period = $current_graph_days * 1440 ; $current_volatility_window = (60 * 36) - 1 ; $current_volatility_window_label = "36 часов" ; }
   $current_volatility_period = $current_graph_days * 1440 ; $current_volatility_window = (60 * 36) - 1 ; $current_volatility_window_label = "36 часов" ; }

if ( $pv{isvw_15Mh_block} eq "yes" ) { $current_timeframe_label = "15M" ; $current_graph_days = 10 ; $current_graph_days_label = "10 дней" ; $current_count_prds = $current_graph_days * 96 ;
#   $current_volatility_period = $current_graph_days * 1440 ; $current_volatility_window = (60 * 36) - 1 ; $current_volatility_window_label = "36 часов" ; }
   $current_volatility_period = $current_graph_days * 24 ; $current_volatility_window = 36 - 1 ; $current_volatility_window_label = "36 часов" ; }

if ( $pv{isvw_5M_block} eq "yes" ) { $current_timeframe_label = "5M" ; $current_graph_days = 3 ; $current_graph_days_label = "3 дня" ; $current_count_prds = $current_graph_days * 12 * 24 ;
   $current_volatility_period = $current_graph_days * 1440 ; $current_volatility_window = 300 - 1 ; $current_volatility_window_label = "5 часов" ; }

if ( $pv{isvw_1M_block} eq "yes" ) { $current_timeframe_label = "1M" ; $current_graph_days = 1 ; $current_graph_days_label = "1 день" ; $current_count_prds = $current_graph_days * 1440 ;
   $current_volatility_period = $current_graph_days * 1440 ; $current_volatility_window = 60 - 1 ; $current_volatility_window_label = "60 минут" ; }

$request = " " ;

# это SWING среднесрок - т.е. период около полутора месяцев (45 дней). Поэтому для разгрузки можно брать данные дневной таблицы
# это SWING краткосрок - т.е. период до 5 дней в среднем. Поэтому для разгрузки можно брать данные часовой таблицы
# окно 140 периодов (24 часа * 5 дней), глубина анализа 60 дней
# это INTRADAY - т.е. период сутки - полтора. Поэтому для разгрузки можно брать данные часовой таблицы
# sort_column=AVG_WEEK_VOL&sort_type=DESC"

$request = "with
        cycle_inday_hr_2d_wnd3h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_inday_3h as MIN_PRICE, max(price_high) OVER wind_inday_3h as MAX_PRICE, rank() OVER wind_inday_3h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '51 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_inday_3h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 3
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_inday_hr_2d_wnd5h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_inday_5h as MIN_PRICE, max(price_high) OVER wind_inday_5h as MAX_PRICE, rank() OVER wind_inday_5h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '53 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_inday_5h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 5
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_inday_hr_2d_wnd7h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_inday_7h as MIN_PRICE, max(price_high) OVER wind_inday_7h as MAX_PRICE, rank() OVER wind_inday_7h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '55 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_inday_7h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 7
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_inday_hr_3d_wnd3h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_inday_3h as MIN_PRICE, max(price_high) OVER wind_inday_3h as MAX_PRICE, rank() OVER wind_inday_3h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '75 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_inday_3h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 3
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_inday_hr_3d_wnd5h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_inday_5h as MIN_PRICE, max(price_high) OVER wind_inday_5h as MAX_PRICE, rank() OVER wind_inday_5h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '77 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_inday_5h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 5
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_inday_hr_3d_wnd7h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_inday_7h as MIN_PRICE, max(price_high) OVER wind_inday_7h as MAX_PRICE, rank() OVER wind_inday_7h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '79 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_inday_7h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 7
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_inday_hr_4d_wnd3h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_inday_3h as MIN_PRICE, max(price_high) OVER wind_inday_3h as MAX_PRICE, rank() OVER wind_inday_3h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '99 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_inday_3h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 3
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_inday_hr_4d_wnd5h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_inday_5h as MIN_PRICE, max(price_high) OVER wind_inday_5h as MAX_PRICE, rank() OVER wind_inday_5h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '102 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_inday_5h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 5
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_inday_hr_4d_wnd7h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_inday_7h as MIN_PRICE, max(price_high) OVER wind_inday_7h as MAX_PRICE, rank() OVER wind_inday_7h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '103 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_inday_7h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 7
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_day_hr_7d_wnd24h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_24h as MIN_PRICE, max(price_high) OVER wind_day_24h as MAX_PRICE, rank() OVER wind_day_24h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '192 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_24h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 23 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 24
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_day_hr_7d_wnd36h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_36h as MIN_PRICE, max(price_high) OVER wind_day_36h as MAX_PRICE, rank() OVER wind_day_36h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '204 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_36h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 35 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 36
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_day_hr_7d_wnd48h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_48h as MIN_PRICE, max(price_high) OVER wind_day_48h as MAX_PRICE, rank() OVER wind_day_48h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '216 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_48h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 47 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 48
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_day_hr_10d_wnd24h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_24h as MIN_PRICE, max(price_high) OVER wind_day_24h as MAX_PRICE, rank() OVER wind_day_24h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '264 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_24h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 24 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 24
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_day_hr_10d_wnd36h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_36h as MIN_PRICE, max(price_high) OVER wind_day_36h as MAX_PRICE, rank() OVER wind_day_36h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '276 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_36h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 35 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 36
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_day_hr_10d_wnd48h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_48h as MIN_PRICE, max(price_high) OVER wind_day_48h as MAX_PRICE, rank() OVER wind_day_48h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '288 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_48h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 47 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 48
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_day_hr_13d_wnd24h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_24h as MIN_PRICE, max(price_high) OVER wind_day_24h as MAX_PRICE, rank() OVER wind_day_24h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '336 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_24h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 23 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 24
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_day_hr_13d_wnd36h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_36h as MIN_PRICE, max(price_high) OVER wind_day_36h as MAX_PRICE, rank() OVER wind_day_36h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '348 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_36h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 35 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 36
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_day_hr_13d_wnd48h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_48h as MIN_PRICE, max(price_high) OVER wind_day_48h as MAX_PRICE, rank() OVER wind_day_48h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '360 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_48h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 47 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 48
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_week_hr_40d_wnd96h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_96h as MIN_PRICE, max(price_high) OVER wind_day_96h as MAX_PRICE, rank() OVER wind_day_96h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '1036 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_96h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 95 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 96
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_week_hr_40d_wnd168h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_168h as MIN_PRICE, max(price_high) OVER wind_day_168h as MAX_PRICE, rank() OVER wind_day_168h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '1128 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_168h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 167 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 168
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_week_hr_40d_wnd216h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_216h as MIN_PRICE, max(price_high) OVER wind_day_216h as MAX_PRICE, rank() OVER wind_day_216h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '1176 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_216h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 215 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 216
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_week_hr_60d_wnd96h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_96h as MIN_PRICE, max(price_high) OVER wind_day_96h as MAX_PRICE, rank() OVER wind_day_96h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '1536 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_96h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 95 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 96
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_week_hr_60d_wnd168h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_168h as MIN_PRICE, max(price_high) OVER wind_day_168h as MAX_PRICE, rank() OVER wind_day_168h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '1058 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_168h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 167 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 168
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_week_hr_60d_wnd216h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_216h as MIN_PRICE, max(price_high) OVER wind_day_216h as MAX_PRICE, rank() OVER wind_day_216h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '1656 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_216h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 215 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 216
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_week_hr_80d_wnd96h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_96h as MIN_PRICE, max(price_high) OVER wind_day_96h as MAX_PRICE, rank() OVER wind_day_96h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '2016 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_96h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 95 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 96
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_week_hr_80d_wnd168h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_168h as MIN_PRICE, max(price_high) OVER wind_day_168h as MAX_PRICE, rank() OVER wind_day_168h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '2088 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_168h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 167 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 168
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_week_hr_80d_wnd216h as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_216h as MIN_PRICE, max(price_high) OVER wind_day_216h as MAX_PRICE, rank() OVER wind_day_216h as N_RANK
                                       from crcomp_pair_OHLC_1H_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '2136 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_216h AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 215 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 216
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_month_day_90d_wnd25d as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_25d as MIN_PRICE, max(price_high) OVER wind_day_25d as MAX_PRICE, rank() OVER wind_day_25d as N_RANK
                                       from crcomp_pair_OHLC_1D_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '1036 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_25d AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 24 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 25
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_month_day_90d_wnd35d as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_35d as MIN_PRICE, max(price_high) OVER wind_day_35d as MAX_PRICE, rank() OVER wind_day_35d as N_RANK
                                       from crcomp_pair_OHLC_1D_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '1128 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_35d AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 34 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 35
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_month_day_90d_wnd45d as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_45d as MIN_PRICE, max(price_high) OVER wind_day_45d as MAX_PRICE, rank() OVER wind_day_45d as N_RANK
                                       from crcomp_pair_OHLC_1D_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '1176 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_45d AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 44 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 45
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_month_day_120d_wnd25d as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_25d as MIN_PRICE, max(price_high) OVER wind_day_25d as MAX_PRICE, rank() OVER wind_day_25d as N_RANK
                                       from crcomp_pair_OHLC_1D_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '1536 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_25d AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 24 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 25
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_month_day_120d_wnd35d as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_35d as MIN_PRICE, max(price_high) OVER wind_day_35d as MAX_PRICE, rank() OVER wind_day_35d as N_RANK
                                       from crcomp_pair_OHLC_1D_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '1058 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_35d AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 34 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 35
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_month_day_120d_wnd45d as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_45d as MIN_PRICE, max(price_high) OVER wind_day_45d as MAX_PRICE, rank() OVER wind_day_45d as N_RANK
                                       from crcomp_pair_OHLC_1D_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '1656 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_45d AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 44 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 45
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_month_day_150d_wnd25d as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_25d as MIN_PRICE, max(price_high) OVER wind_day_25d as MAX_PRICE, rank() OVER wind_day_25d as N_RANK
                                       from crcomp_pair_OHLC_1D_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '2016 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_25d AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 24 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 25
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_month_day_150d_wnd35d as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_35d as MIN_PRICE, max(price_high) OVER wind_day_35d as MAX_PRICE, rank() OVER wind_day_35d as N_RANK
                                       from crcomp_pair_OHLC_1D_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '2088 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_35d AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 34 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 35
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC),
        cycle_month_day_150d_wnd45d as (select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
             MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL, MIN(window_vol.timestamp_point) tsmin, MAX(window_vol.timestamp_point) tsmax
             from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point,
                          round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL, N_RANK
                          from (select currency, reference_currency, timestamp_point, min(price_low) OVER wind_day_45d as MIN_PRICE, max(price_high) OVER wind_day_45d as MAX_PRICE, rank() OVER wind_day_45d as N_RANK
                                       from crcomp_pair_OHLC_1D_history
                                       where timestamp_point > CURRENT_DATE - INTERVAL '2136 hours'
                                             AND NOT price_low = 0 AND price_low IS NOT NULL
                                       WINDOW wind_day_45d AS (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 44 PRECEDING AND CURRENT ROW)
                                       order by timestamp_point ASC) ds_win1
                          WHERE N_RANK >= 45
                          order by ds_win1.timestamp_point ) as window_vol
             group by window_vol.currency, window_vol.reference_currency
             order by AVG_VOL DESC)
SELECT cy011.currency, cy011.reference_currency,
       cy011.MIN_VOL, cy011.AVG_VOL, cy011.MAX_VOL, cy011.tsmin, cy011.tsmax, cy012.MIN_VOL, cy012.AVG_VOL, cy012.MAX_VOL, cy012.tsmin, cy012.tsmax, cy013.MIN_VOL, cy013.AVG_VOL, cy013.MAX_VOL, cy013.tsmin, cy013.tsmax,
       cy021.MIN_VOL, cy021.AVG_VOL, cy021.MAX_VOL, cy021.tsmin, cy021.tsmax, cy022.MIN_VOL, cy022.AVG_VOL, cy022.MAX_VOL, cy022.tsmin, cy022.tsmax, cy023.MIN_VOL, cy023.AVG_VOL, cy023.MAX_VOL, cy023.tsmin, cy023.tsmax,
       cy031.MIN_VOL, cy031.AVG_VOL, cy031.MAX_VOL, cy031.tsmin, cy031.tsmax, cy032.MIN_VOL, cy032.AVG_VOL, cy032.MAX_VOL, cy032.tsmin, cy032.tsmax, cy033.MIN_VOL, cy033.AVG_VOL, cy033.MAX_VOL, cy033.tsmin, cy033.tsmax,
       cy111.MIN_VOL, cy111.AVG_VOL, cy111.MAX_VOL, cy111.tsmin, cy111.tsmax, cy112.MIN_VOL, cy112.AVG_VOL, cy112.MAX_VOL, cy112.tsmin, cy112.tsmax, cy113.MIN_VOL, cy113.AVG_VOL, cy113.MAX_VOL, cy113.tsmin, cy113.tsmax,
       cy121.MIN_VOL, cy121.AVG_VOL, cy121.MAX_VOL, cy121.tsmin, cy121.tsmax, cy122.MIN_VOL, cy122.AVG_VOL, cy122.MAX_VOL, cy122.tsmin, cy122.tsmax, cy123.MIN_VOL, cy123.AVG_VOL, cy123.MAX_VOL, cy123.tsmin, cy123.tsmax,
       cy131.MIN_VOL, cy131.AVG_VOL, cy131.MAX_VOL, cy131.tsmin, cy131.tsmax, cy132.MIN_VOL, cy132.AVG_VOL, cy132.MAX_VOL, cy132.tsmin, cy132.tsmax, cy133.MIN_VOL, cy133.AVG_VOL, cy133.MAX_VOL, cy133.tsmin, cy133.tsmax,
       cy211.MIN_VOL, cy211.AVG_VOL, cy211.MAX_VOL, cy211.tsmin, cy211.tsmax, cy212.MIN_VOL, cy212.AVG_VOL, cy212.MAX_VOL, cy212.tsmin, cy212.tsmax, cy213.MIN_VOL, cy213.AVG_VOL, cy213.MAX_VOL, cy213.tsmin, cy213.tsmax,
       cy221.MIN_VOL, cy221.AVG_VOL, cy221.MAX_VOL, cy221.tsmin, cy221.tsmax, cy222.MIN_VOL, cy222.AVG_VOL, cy222.MAX_VOL, cy222.tsmin, cy222.tsmax, cy223.MIN_VOL, cy223.AVG_VOL, cy223.MAX_VOL, cy223.tsmin, cy223.tsmax,
       cy231.MIN_VOL, cy231.AVG_VOL, cy231.MAX_VOL, cy231.tsmin, cy231.tsmax, cy232.MIN_VOL, cy232.AVG_VOL, cy232.MAX_VOL, cy232.tsmin, cy232.tsmax, cy233.MIN_VOL, cy233.AVG_VOL, cy233.MAX_VOL, cy233.tsmin, cy233.tsmax,
       cy311.MIN_VOL, cy311.AVG_VOL, cy311.MAX_VOL, cy311.tsmin, cy311.tsmax, cy312.MIN_VOL, cy312.AVG_VOL, cy312.MAX_VOL, cy312.tsmin, cy312.tsmax, cy313.MIN_VOL, cy313.AVG_VOL, cy313.MAX_VOL, cy313.tsmin, cy313.tsmax,
       cy321.MIN_VOL, cy321.AVG_VOL, cy321.MAX_VOL, cy321.tsmin, cy321.tsmax, cy322.MIN_VOL, cy322.AVG_VOL, cy322.MAX_VOL, cy322.tsmin, cy322.tsmax, cy323.MIN_VOL, cy323.AVG_VOL, cy323.MAX_VOL, cy323.tsmin, cy323.tsmax,
       cy331.MIN_VOL, cy331.AVG_VOL, cy331.MAX_VOL, cy331.tsmin, cy331.tsmax, cy332.MIN_VOL, cy332.AVG_VOL, cy332.MAX_VOL, cy332.tsmin, cy332.tsmax, cy333.MIN_VOL, cy333.AVG_VOL, cy333.MAX_VOL, cy333.tsmin, cy333.tsmax
       from cycle_inday_hr_2d_wnd3h cy011
            LEFT OUTER JOIN cycle_inday_hr_2d_wnd5h cy012 ON cy011.currency = cy012.currency AND cy011.reference_currency = cy012.reference_currency
            LEFT OUTER JOIN cycle_inday_hr_2d_wnd7h cy013 ON cy011.currency = cy013.currency AND cy011.reference_currency = cy013.reference_currency
            LEFT OUTER JOIN cycle_inday_hr_3d_wnd3h cy021 ON cy011.currency = cy021.currency AND cy011.reference_currency = cy021.reference_currency
            LEFT OUTER JOIN cycle_inday_hr_3d_wnd5h cy022 ON cy011.currency = cy022.currency AND cy011.reference_currency = cy022.reference_currency
            LEFT OUTER JOIN cycle_inday_hr_3d_wnd7h cy023 ON cy011.currency = cy023.currency AND cy011.reference_currency = cy023.reference_currency
            LEFT OUTER JOIN cycle_inday_hr_4d_wnd3h cy031 ON cy011.currency = cy031.currency AND cy011.reference_currency = cy031.reference_currency
            LEFT OUTER JOIN cycle_inday_hr_4d_wnd5h cy032 ON cy011.currency = cy032.currency AND cy011.reference_currency = cy032.reference_currency
            LEFT OUTER JOIN cycle_inday_hr_4d_wnd7h cy033 ON cy011.currency = cy033.currency AND cy011.reference_currency = cy033.reference_currency
            LEFT OUTER JOIN cycle_day_hr_7d_wnd24h cy111 ON cy011.currency = cy111.currency AND cy011.reference_currency = cy111.reference_currency
            LEFT OUTER JOIN cycle_day_hr_7d_wnd36h cy112 ON cy011.currency = cy112.currency AND cy011.reference_currency = cy112.reference_currency
            LEFT OUTER JOIN cycle_day_hr_7d_wnd48h cy113 ON cy011.currency = cy113.currency AND cy011.reference_currency = cy113.reference_currency
            LEFT OUTER JOIN cycle_day_hr_10d_wnd24h cy121 ON cy011.currency = cy121.currency AND cy011.reference_currency = cy121.reference_currency
            LEFT OUTER JOIN cycle_day_hr_10d_wnd36h cy122 ON cy011.currency = cy122.currency AND cy011.reference_currency = cy122.reference_currency
            LEFT OUTER JOIN cycle_day_hr_10d_wnd48h cy123 ON cy011.currency = cy123.currency AND cy011.reference_currency = cy123.reference_currency
            LEFT OUTER JOIN cycle_day_hr_13d_wnd24h cy131 ON cy011.currency = cy131.currency AND cy011.reference_currency = cy131.reference_currency
            LEFT OUTER JOIN cycle_day_hr_13d_wnd36h cy132 ON cy011.currency = cy132.currency AND cy011.reference_currency = cy132.reference_currency
            LEFT OUTER JOIN cycle_day_hr_13d_wnd48h cy133 ON cy011.currency = cy133.currency AND cy011.reference_currency = cy133.reference_currency
            LEFT OUTER JOIN cycle_week_hr_40d_wnd96h cy211 ON cy011.currency = cy211.currency AND cy011.reference_currency = cy211.reference_currency
            LEFT OUTER JOIN cycle_week_hr_40d_wnd168h cy212 ON cy011.currency = cy212.currency AND cy011.reference_currency = cy212.reference_currency
            LEFT OUTER JOIN cycle_week_hr_40d_wnd216h cy213 ON cy011.currency = cy213.currency AND cy011.reference_currency = cy213.reference_currency
            LEFT OUTER JOIN cycle_week_hr_60d_wnd96h cy221 ON cy011.currency = cy221.currency AND cy011.reference_currency = cy221.reference_currency
            LEFT OUTER JOIN cycle_week_hr_60d_wnd168h cy222 ON cy011.currency = cy222.currency AND cy011.reference_currency = cy222.reference_currency
            LEFT OUTER JOIN cycle_week_hr_60d_wnd216h cy223 ON cy011.currency = cy223.currency AND cy011.reference_currency = cy223.reference_currency
            LEFT OUTER JOIN cycle_week_hr_80d_wnd96h cy231 ON cy011.currency = cy231.currency AND cy011.reference_currency = cy231.reference_currency
            LEFT OUTER JOIN cycle_week_hr_80d_wnd168h cy232 ON cy011.currency = cy232.currency AND cy011.reference_currency = cy232.reference_currency
            LEFT OUTER JOIN cycle_week_hr_80d_wnd216h cy233 ON cy011.currency = cy233.currency AND cy011.reference_currency = cy233.reference_currency
            LEFT OUTER JOIN cycle_month_day_90d_wnd25d cy311 ON cy011.currency = cy311.currency AND cy011.reference_currency = cy311.reference_currency
            LEFT OUTER JOIN cycle_month_day_90d_wnd35d cy312 ON cy011.currency = cy312.currency AND cy011.reference_currency = cy312.reference_currency
            LEFT OUTER JOIN cycle_month_day_90d_wnd45d cy313 ON cy011.currency = cy313.currency AND cy011.reference_currency = cy313.reference_currency
            LEFT OUTER JOIN cycle_month_day_120d_wnd35d cy321 ON cy011.currency = cy321.currency AND cy011.reference_currency = cy321.reference_currency
            LEFT OUTER JOIN cycle_month_day_120d_wnd35d cy322 ON cy011.currency = cy322.currency AND cy011.reference_currency = cy322.reference_currency
            LEFT OUTER JOIN cycle_month_day_120d_wnd45d cy323 ON cy011.currency = cy323.currency AND cy011.reference_currency = cy323.reference_currency
            LEFT OUTER JOIN cycle_month_day_150d_wnd25d cy331 ON cy011.currency = cy331.currency AND cy011.reference_currency = cy331.reference_currency
            LEFT OUTER JOIN cycle_month_day_150d_wnd35d cy332 ON cy011.currency = cy332.currency AND cy011.reference_currency = cy332.reference_currency
            LEFT OUTER JOIN cycle_month_day_150d_wnd45d cy333 ON cy011.currency = cy333.currency AND cy011.reference_currency = cy333.reference_currency
       ORDER BY cy011.reference_currency DESC, cy011.currency ASC" ;

my $dbh_h = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'pg_password_value' ) ;
my $sth_h = $dbh_h->prepare($request) ; $sth_h->execute(); $count_rows = 0 ;

print "Content-Type: text/html\n\n" ;

system("cat $COMM_PAR_BASE_WEB_PATH/includes/header1_1_cgi.shtml") ;
print "REP ZRT КрАгрАн БЕССТ" ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/header1_2_cgi.shtml") ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/main_menu.shtml") ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/header2_1_cgi.shtml") ;

print_js_block_common() ;
print_js_block_trading() ;

print_main_page_title("Отчёты и аналитика", "Волатильность основных монет в разных циклах") ;

print_tools_coin_navigation(7) ;
print "<!-- таблица первого уровня вкладок -->
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD><BR>" ;

print_reports_coin_navigation(2,"rep_volatility_all_cycles_coins.cgi","Волатильность<BR>Циклы") ;
print "<!-- таблица второго уровня вкладок -->
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD>&nbsp;<BR>" ;

print_coin_links_map("rep_volatility_all_cycles_coins.cgi") ;

#-debug-print "<PRE>$request</PRE>" ;

print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%;\">" ;

printf("<TR><TD CLASS=\"head\" ROWSPAN=\"2\">Монета</TD><TD CLASS=\"head\" ROWSPAN=\"2\">Референсная</TD>
            <TD CLASS=\"head\" COLSPAN=\"3\">Цикл внутридневной</TD><TD CLASS=\"head\" COLSPAN=\"3\">Цикл дневной</TD>
            <TD CLASS=\"head\" COLSPAN=\"3\">Цикл недельный</TD><TD CLASS=\"head\" COLSPAN=\"3\">Цикл месячный</TD></TR>") ;
printf("<TR><TD CLASS=\"head\">2 дня, MIN/AVG/MAX</TD><TD CLASS=\"head\">3 дня, MIN/AVG/MAX</TD><TD CLASS=\"head\">4 дня, MIN/AVG/MAX</TD>
<TD CLASS=\"head\">7 дней, MIN/AVG/MAX</TD><TD CLASS=\"head\">10 дней, MIN/AVG/MAX</TD><TD CLASS=\"head\">13 дней, MIN/AVG/MAX</TD>
<TD CLASS=\"head\">40 дней, MIN/AVG/MAX</TD><TD CLASS=\"head\">60 дней, MIN/AVG/MAX</TD><TD CLASS=\"head\">80 дней, MIN/AVG/MAX</TD>
<TD CLASS=\"head\">90 дней, MIN/AVG/MAX</TD><TD CLASS=\"head\">120 дней, MIN/AVG/MAX</TD><TD CLASS=\"head\">150 дней, MIN/AVG/MAX</TD>
</TR>") ;

while (my ($current_coin, $curr_ref_coin,
 $cy011_min_vol, $cy011_avg_vol, $cy011_max_vol, $cy011_tsmin, $cy011_tsmax, $cy012_min_vol, $cy012_avg_vol, $cy012_max_vol, $cy012_tsmin, $cy012_tsmax, $cy013_min_vol, $cy013_avg_vol, $cy013_max_vol, $cy013_tsmin, $cy013_tsmax,
 $cy021_min_vol, $cy021_avg_vol, $cy021_max_vol, $cy021_tsmin, $cy021_tsmax, $cy022_min_vol, $cy022_avg_vol, $cy022_max_vol, $cy022_tsmin, $cy022_tsmax, $cy023_min_vol, $cy023_avg_vol, $cy023_max_vol, $cy023_tsmin, $cy023_tsmax,
 $cy031_min_vol, $cy031_avg_vol, $cy031_max_vol, $cy031_tsmin, $cy031_tsmax, $cy032_min_vol, $cy032_avg_vol, $cy032_max_vol, $cy032_tsmin, $cy032_tsmax, $cy033_min_vol, $cy033_avg_vol, $cy033_max_vol, $cy033_tsmin, $cy033_tsmax,
 $cy111_min_vol, $cy111_avg_vol, $cy111_max_vol, $cy111_tsmin, $cy111_tsmax, $cy112_min_vol, $cy112_avg_vol, $cy112_max_vol, $cy112_tsmin, $cy112_tsmax, $cy113_min_vol, $cy113_avg_vol, $cy113_max_vol, $cy113_tsmin, $cy113_tsmax,
 $cy121_min_vol, $cy121_avg_vol, $cy121_max_vol, $cy121_tsmin, $cy121_tsmax, $cy122_min_vol, $cy122_avg_vol, $cy122_max_vol, $cy122_tsmin, $cy122_tsmax, $cy123_min_vol, $cy123_avg_vol, $cy123_max_vol, $cy123_tsmin, $cy123_tsmax,
 $cy131_min_vol, $cy131_avg_vol, $cy131_max_vol, $cy131_tsmin, $cy131_tsmax, $cy132_min_vol, $cy132_avg_vol, $cy132_max_vol, $cy132_tsmin, $cy132_tsmax, $cy133_min_vol, $cy133_avg_vol, $cy133_max_vol, $cy133_tsmin, $cy133_tsmax,
 $cy211_min_vol, $cy211_avg_vol, $cy211_max_vol, $cy211_tsmin, $cy211_tsmax, $cy212_min_vol, $cy212_avg_vol, $cy212_max_vol, $cy212_tsmin, $cy212_tsmax, $cy213_min_vol, $cy213_avg_vol, $cy213_max_vol, $cy213_tsmin, $cy213_tsmax,
 $cy221_min_vol, $cy221_avg_vol, $cy221_max_vol, $cy221_tsmin, $cy221_tsmax, $cy222_min_vol, $cy222_avg_vol, $cy222_max_vol, $cy222_tsmin, $cy222_tsmax, $cy223_min_vol, $cy223_avg_vol, $cy223_max_vol, $cy223_tsmin, $cy223_tsmax,
 $cy231_min_vol, $cy231_avg_vol, $cy231_max_vol, $cy231_tsmin, $cy231_tsmax, $cy232_min_vol, $cy232_avg_vol, $cy232_max_vol, $cy232_tsmin, $cy232_tsmax, $cy233_min_vol, $cy233_avg_vol, $cy233_max_vol, $cy233_tsmin, $cy233_tsmax,
 $cy311_min_vol, $cy311_avg_vol, $cy311_max_vol, $cy311_tsmin, $cy311_tsmax, $cy312_min_vol, $cy312_avg_vol, $cy312_max_vol, $cy312_tsmin, $cy312_tsmax, $cy313_min_vol, $cy313_avg_vol, $cy313_max_vol, $cy313_tsmin, $cy313_tsmax,
 $cy321_min_vol, $cy321_avg_vol, $cy321_max_vol, $cy321_tsmin, $cy321_tsmax, $cy322_min_vol, $cy322_avg_vol, $cy322_max_vol, $cy322_tsmin, $cy322_tsmax, $cy323_min_vol, $cy323_avg_vol, $cy323_max_vol, $cy323_tsmin, $cy323_tsmax,
 $cy331_min_vol, $cy331_avg_vol, $cy331_max_vol, $cy331_tsmin, $cy331_tsmax, $cy332_min_vol, $cy332_avg_vol, $cy332_max_vol, $cy332_tsmin, $cy332_tsmax, $cy333_min_vol, $cy333_avg_vol, $cy333_max_vol, $cy333_tsmin, $cy333_tsmax

 ) = $sth_h->fetchrow_array() ) {
      if ( $curr_ref_coin eq "USDT") { $curr_ref_coin_gecko = "USD" ; }
      my $half_min_week_volatility = $avg_week_vol / 2 ;
#      print "$day_date, $volat\n" ;

      printf("<TR><TD>$current_coin</TD>
                  <TD>$curr_ref_coin</TD>
                  <TD>
                  <SPAN STYLE=\"font-size: 8pt; color: gray;\" TITLE=\"$cy011_tsmin/$cy011_tsmax\"><NOBR>w3h:&nbsp;$cy011_min_vol/$cy011_avg_vol/$cy011_max_vol</NOBR></SPAN>
                  <BR><SPAN STYLE=\"font-size: 10pt; color: navy;\" TITLE=\"$cy012_tsmin/$cy012_tsmax\"><NOBR>w5h:&nbsp;$cy012_min_vol/$cy012_avg_vol/$cy012_max_vol</NOBR></SPAN>
                  <BR><SPAN STYLE=\"font-size: 8pt; color: gray;\" TITLE=\"$cy013_tsmin/$cy013_tsmax\"><NOBR>w7h:&nbsp;$cy013_min_vol/$cy013_avg_vol/$cy013_max_vol</NOBR></SPAN>
                  </TD><TD>
                  <SPAN STYLE=\"font-size: 8pt; color: gray;\" TITLE=\"$cy021_tsmin/$cy021_tsmax\"><NOBR>w3h:&nbsp;$cy021_min_vol/$cy021_avg_vol/$cy021_max_vol</NOBR></SPAN>
                  <BR><SPAN STYLE=\"font-size: 10pt; color: navy;\" TITLE=\"$cy022_tsmin/$cy022_tsmax\"><NOBR>w5h:&nbsp;$cy022_min_vol/$cy022_avg_vol/$cy022_max_vol</NOBR></SPAN>
                  <BR><SPAN STYLE=\"font-size: 8pt; color: gray;\" TITLE=\"$cy023_tsmin/$cy023_tsmax\"><NOBR>w7h:&nbsp;$cy023_min_vol/$cy023_avg_vol/$cy023_max_vol</NOBR></SPAN>
                  </TD><TD>
                  <SPAN STYLE=\"font-size: 8pt; color: gray;\" TITLE=\"$cy031_tsmin/$cy031_tsmax\"><NOBR>w3h:&nbsp;$cy031_min_vol/$cy031_avg_vol/$cy031_max_vol</NOBR></SPAN>
                  <BR><SPAN STYLE=\"font-size: 10pt; color: navy;\" TITLE=\"$cy032_tsmin/$cy032_tsmax\"><NOBR>w5h:&nbsp;$cy032_min_vol/$cy032_avg_vol/$cy032_max_vol</NOBR></SPAN>
                  <BR><SPAN STYLE=\"font-size: 8pt; color: gray;\" TITLE=\"$cy033_tsmin/$cy033_tsmax\"><NOBR>w7h:&nbsp;$cy033_min_vol/$cy033_avg_vol/$cy033_max_vol</NOBR></SPAN>
                  </TD>

                  <TD>
                  <SPAN STYLE=\"font-size: 8pt; color: gray;\" TITLE=\"$cy111_tsmin/$cy111_tsmax\"><NOBR>w24h:&nbsp;$cy111_min_vol/$cy111_avg_vol/$cy111_max_vol</NOBR></SPAN>
                  <BR><SPAN STYLE=\"font-size: 10pt; color: navy;\" TITLE=\"$cy112_tsmin/$cy112_tsmax\"><NOBR>w36h:&nbsp;$cy112_min_vol/$cy112_avg_vol/$cy112_max_vol</NOBR></SPAN>
                  <BR><SPAN STYLE=\"font-size: 8pt; color: gray;\" TITLE=\"$cy113_tsmin/$cy113_tsmax\"><NOBR>w48h:&nbsp;$cy113_min_vol/$cy113_avg_vol/$cy113_max_vol</NOBR></SPAN>
                  </TD><TD>
                  <SPAN STYLE=\"font-size: 8pt; color: gray;\" TITLE=\"$cy121_tsmin/$cy121_tsmax\"><NOBR>w24h:&nbsp;$cy121_min_vol/$cy121_avg_vol/$cy121_max_vol</NOBR></SPAN>
                  <BR><SPAN STYLE=\"font-size: 10pt; color: navy;\" TITLE=\"$cy122_tsmin/$cy122_tsmax\"><NOBR>w36h:&nbsp;$cy122_min_vol/$cy122_avg_vol/$cy122_max_vol</NOBR></SPAN>
                  <BR><SPAN STYLE=\"font-size: 8pt; color: gray;\" TITLE=\"$cy123_tsmin/$cy123_tsmax\"><NOBR>w48h:&nbsp;$cy123_min_vol/$cy123_avg_vol/$cy123_max_vol</NOBR></SPAN>
                  </TD><TD>
                  <SPAN STYLE=\"font-size: 8pt; color: gray;\" TITLE=\"$cy131_tsmin/$cy131_tsmax\"><NOBR>w24h:&nbsp;$cy131_min_vol/$cy131_avg_vol/$cy131_max_vol</NOBR></SPAN>
                  <BR><SPAN STYLE=\"font-size: 10pt; color: navy;\" TITLE=\"$cy132_tsmin/$cy132_tsmax\"><NOBR>w36h:&nbsp;$cy132_min_vol/$cy132_avg_vol/$cy132_max_vol</NOBR></SPAN>
                  <BR><SPAN STYLE=\"font-size: 8pt; color: gray;\" TITLE=\"$cy133_tsmin/$cy133_tsmax\"><NOBR>w48h:&nbsp;$cy133_min_vol/$cy133_avg_vol/$cy133_max_vol</NOBR></SPAN>
                  </TD>

                  <TD>
                  <SPAN STYLE=\"font-size: 8pt; color: gray;\" TITLE=\"$cy211_tsmin/$cy211_tsmax\"><NOBR>w4d:&nbsp;$cy211_min_vol/$cy211_avg_vol/$cy211_max_vol</NOBR></SPAN>
                  <BR><SPAN STYLE=\"font-size: 10pt; color: navy;\" TITLE=\"$cy212_tsmin/$cy212_tsmax\"><NOBR>w7d:&nbsp;$cy212_min_vol/$cy212_avg_vol/$cy212_max_vol</NOBR></SPAN>
                  <BR><SPAN STYLE=\"font-size: 8pt; color: gray;\" TITLE=\"$cy213_tsmin/$cy213_tsmax\"><NOBR>w9d:&nbsp;$cy213_min_vol/$cy213_avg_vol/$cy213_max_vol</NOBR></SPAN>
                  </TD><TD>
                  <SPAN STYLE=\"font-size: 8pt; color: gray;\" TITLE=\"$cy221_tsmin/$cy221_tsmax\"><NOBR>w4d:&nbsp;$cy221_min_vol/$cy221_avg_vol/$cy221_max_vol</NOBR></SPAN>
                  <BR><SPAN STYLE=\"font-size: 10pt; color: navy;\" TITLE=\"$cy222_tsmin/$cy222_tsmax\"><NOBR>w7d:&nbsp;$cy222_min_vol/$cy222_avg_vol/$cy222_max_vol</NOBR></SPAN>
                  <BR><SPAN STYLE=\"font-size: 8pt; color: gray;\" TITLE=\"$cy223_tsmin/$cy223_tsmax\"><NOBR>w9d:&nbsp;$cy223_min_vol/$cy223_avg_vol/$cy223_max_vol</NOBR></SPAN>
                  </TD><TD>
                  <SPAN STYLE=\"font-size: 8pt; color: gray;\" TITLE=\"$cy231_tsmin/$cy231_tsmax\"><NOBR>w4d:&nbsp;$cy231_min_vol/$cy231_avg_vol/$cy231_max_vol</NOBR></SPAN>
                  <BR><SPAN STYLE=\"font-size: 10pt; color: navy;\" TITLE=\"$cy232_tsmin/$cy232_tsmax\"><NOBR>w7d:&nbsp;$cy232_min_vol/$cy232_avg_vol/$cy232_max_vol</NOBR></SPAN>
                  <BR><SPAN STYLE=\"font-size: 8pt; color: gray;\" TITLE=\"$cy233_tsmin/$cy233_tsmax\"><NOBR>w9d:&nbsp;$cy233_min_vol/$cy233_avg_vol/$cy233_max_vol</NOBR></SPAN>
                  </TD>

                  <TD>
                  <SPAN STYLE=\"font-size: 8pt; color: gray;\" TITLE=\"$cy311_tsmin/$cy311_tsmax\"><NOBR>w25d:&nbsp;$cy311_min_vol/$cy311_avg_vol/$cy311_max_vol</NOBR></SPAN>
                  <BR><SPAN STYLE=\"font-size: 10pt; color: navy;\" TITLE=\"$cy312_tsmin/$cy312_tsmax\"><NOBR>w35d:&nbsp;$cy312_min_vol/$cy312_avg_vol/$cy312_max_vol</NOBR></SPAN>
                  <BR><SPAN STYLE=\"font-size: 8pt; color: gray;\" TITLE=\"$cy313_tsmin/$cy313_tsmax\"><NOBR>w45d:&nbsp;$cy313_min_vol/$cy313_avg_vol/$cy313_max_vol</NOBR></SPAN>
                  </TD><TD>
                  <SPAN STYLE=\"font-size: 8pt; color: gray;\" TITLE=\"$cy321_tsmin/$cy321_tsmax\"><NOBR>w25d:&nbsp;$cy321_min_vol/$cy321_avg_vol/$cy321_max_vol</NOBR></SPAN>
                  <BR><SPAN STYLE=\"font-size: 10pt; color: navy;\" TITLE=\"$cy322_tsmin/$cy322_tsmax\"><NOBR>w35d:&nbsp;$cy322_min_vol/$cy322_avg_vol/$cy322_max_vol</NOBR></SPAN>
                  <BR><SPAN STYLE=\"font-size: 8pt; color: gray;\" TITLE=\"$cy323_tsmin/$cy323_tsmax\"><NOBR>w45d:&nbsp;$cy323_min_vol/$cy323_avg_vol/$cy323_max_vol</NOBR></SPAN>
                  </TD><TD>
                  <SPAN STYLE=\"font-size: 8pt; color: gray;\" TITLE=\"$cy331_tsmin/$cy331_tsmax\"><NOBR>w25d:&nbsp;$cy331_min_vol/$cy331_avg_vol/$cy331_max_vol</NOBR></SPAN>
                  <BR><SPAN STYLE=\"font-size: 10pt; color: navy;\" TITLE=\"$cy332_tsmin/$cy332_tsmax\"><NOBR>w35d:&nbsp;$cy332_min_vol/$cy332_avg_vol/$cy332_max_vol</NOBR></SPAN>
                  <BR><SPAN STYLE=\"font-size: 8pt; color: gray;\" TITLE=\"$cy333_tsmin/$cy333_tsmax\"><NOBR>45d:&nbsp;$cy333_min_vol/$cy333_avg_vol/$cy333_max_vol</NOBR></SPAN>
                  </TD>
               </TR>") ;
      $count_rows += 1 ; }

$sth_h->finish() ;
$dbh_h->disconnect() ;

print "</TABLE>" ;
print "<!-- конец таблицы второго уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы первого уровня вкладок --></TD></TR></TABLE>\n" ;
print_foother1() ;
