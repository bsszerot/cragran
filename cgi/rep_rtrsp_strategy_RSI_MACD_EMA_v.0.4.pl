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

# - вытащить из URL запроса значения уточняющих полей
&get_forms_param() ;
# параметры по умолчанию с версии 0.9 расширены, чтобы можно было формировать ссылку в telegram без амперсандов - только в одним параметром

if ( $pv{curr_reference} eq "" ) { $pv{curr_reference} = "USDT" ; }
if (  $pv{curr_reference} eq "USDT") { $curr_ref_coin_gecko = "USD" ; }
else { $curr_ref_coin_gecko = $pv{curr_reference} ; }
if ( $curr_ref_coin eq "USDT") { $curr_ref_coin_gecko = "USD" ; }

if ( $pv{time_frame} eq "" ) { $pv{time_frame} = "10M" ; }
if ( $pv{count_prds} eq "" ) { $pv{count_prds} = "960" ; }
if ( $pv{env_prct} eq "" ) { $pv{env_prct} = "2" ; }

if ( $pv{start_date} eq "" ) { $pv{start_date} = "2022-07-01 00:00:00" ; }
if ( $pv{stop_date} eq "" ) { $pv{stop_date} = "2033-07-01 00:00:00" ; }

$CURR_YEAR = `date +%Y` ; $CURR_YEAR =~ s/[\r\n]+//g ;
$count_rows = 0 ;

print "Content-Type: text/html\n\n" ;

system("cat $COMM_PAR_BASE_WEB_PATH/includes/header1_1_cgi.shtml") ;
print "REP ZRT КрАгрАн БЕССТ" ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/header1_2_cgi.shtml") ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/main_menu.shtml") ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/header2_1_cgi.shtml") ;

print_js_block_common() ;
print_js_block_trading() ;

print_main_page_title("Отчёты и аналитика", "Ретроспектива RSI + MACD") ;

print_tools_coin_navigation(7) ;

print "<STYLE>
TD.rtrsp_strat_detais_head { font-size: 9pt; font-family: sans-serif; text-align: center; font-weight: bold; vertical-align: middle; color: navy; }
TD.rtrsp_strat_detais_left { font-size: 9pt; font-family: sans-serif; text-align: left; }
TD.rtrsp_strat_detais_right { font-size: 9pt; font-family: sans-serif; text-align: right; }
TD.rtrsp_strat_detais_center { font-size: 9pt; font-family: sans-serif; text-align: center; }
TD.rtrsp_strat_detais_justify { font-size: 9pt; font-family: sans-serif; text-align: justify; }
TD.small_rtrsp_strat_detais_left { font-size: 8pt; font-family: sans-serif; text-align: left; color: gray; }
TD.small_rtrsp_strat_detais_right { font-size: 8pt; font-family: sans-serif; text-align: right; color: gray; }
TD.small_rtrsp_strat_detais_center { font-size: 8pt; font-family: sans-serif; text-align: center; color: gray; }
TD.small_rtrsp_strat_detais_justify { font-size: 8pt; font-family: sans-serif; text-align: justify; color: gray; }
</STYLE>" ;

print "<!-- таблица первого уровня вкладок -->
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD><BR>" ;
print_reports_coin_navigation(5,"rep_rtrsp_strategy_RSI_MACD_EMA.cgi","Ретроспектива<BR>RSI+MACD") ;
print "<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD COLSPAN=\"2\">&nbsp;<BR>" ;

$is_lncrs_1h1h = "" ; if ( $pv{is_lncrs_1h1h} eq "true" ) { $is_lncrs_1h1h = "CHECKED" ; } $is_lnvct_1h1h = "" ; if ( $pv{is_lnvct_1h1h} eq "true" ) { $is_lnvct_1h1h = "CHECKED" ; } $is_gsvct_1h1h = "" ; if ( $pv{is_gsvct_1h1h} eq "true" ) { $is_gsvct_1h1h = "CHECKED" ; }
$is_lncrs_1h4h = "" ; if ( $pv{is_lncrs_1h4h} eq "true" ) { $is_lncrs_1h4h = "CHECKED" ; } $is_lnvct_1h4h = "" ; if ( $pv{is_lnvct_1h4h} eq "true" ) { $is_lnvct_1h4h = "CHECKED" ; } $is_gsvct_1h4h = "" ; if ( $pv{is_gsvct_1h4h} eq "true" ) { $is_gsvct_1h4h = "CHECKED" ; }

print_coin_links_map("rep_rtrsp_strategy_RSI_MACD_EMA.cgi") ;

#print "<TR><TD COLSPAN=\"2\">&nbsp;</TD></TR>\n\n" ;
print "<TR><TD COLSPAN=\"2\">\n\n" ;

if ($pv{currency} eq "ALL") { $pv{currency} = 'ALL' ; $pv{start_currency} = "ALL" ; } 

if ( $pv{sl_value} eq "") { $pv{sl_value} = "-10" ; }
$pv{reference_currency} = $pv{curr_reference} ;
$aggregate_request = "" ;
$detail_request = "" ;

if ( $pv{sort_field} eq "" ) { $pv{sort_field} = "prtct_profit_per_month" ; }

if ( $pv{report_type} eq "coins_groupped" ) {
   $aggregate_request = " " ;
# " UNION ALL select src.*, round((profit / int_period * 30)::numeric,2) profit_per_month, round((protected_profit / int_period * 30)::numeric,2) prtct_profit_per_month from ( select *, CASE WHEN extract(day from stop_period - start_period) > 0 THEN extract(day from stop_period - start_period) ELSE 1 END int_period from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_rsi}', 'LINE', 'CROSS',  'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}') " ; }  else { $detail_request = "select src.*, round((profit / int_period * 30)::numeric,2) profit_per_month, round((protected_profit / int_period * 30)::numeric,2) prtct_profit_per_month  from ( select *, CASE WHEN extract(day from stop_period - start_period) > 0 THEN extract(day from stop_period - start_period) ELSE 1 END int_period from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_rsi}', 'LINE', 'CROSS',  'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}') " ; } }

   if ( $pv{is_lncrs_1h1h} eq "true" ) { if ( $detail_request ne "" ) { $detail_request .= " UNION ALL select src1.*, round((profit / int_period * 30)::numeric,2) profit_per_month, round((protected_profit / int_period * 30)::numeric,2) prtct_profit_per_month from ( select *, CASE WHEN extract(day from stop_period - start_period) > 0 THEN extract(day from stop_period - start_period) ELSE 1 END int_period from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_rsi}',  'LINE', 'CROSS',  'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}')) src1 " ; }  else { $detail_request = "select src1.*, round((profit / int_period * 30)::numeric,2) profit_per_month, round((protected_profit / int_period * 30)::numeric,2) prtct_profit_per_month  from ( select *, CASE WHEN extract(day from stop_period - start_period) > 0 THEN extract(day from stop_period - start_period) ELSE 1 END int_period from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_rsi}',  'LINE', 'CROSS',  'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}')) src1 " ; } }
   if ( $pv{is_lnvct_1h1h} eq "true" ) { if ( $detail_request ne "" ) { $detail_request .= " UNION ALL select src2.*, round((profit / int_period * 30)::numeric,2) profit_per_month, round((protected_profit / int_period * 30)::numeric,2) prtct_profit_per_month from ( select *, CASE WHEN extract(day from stop_period - start_period) > 0 THEN extract(day from stop_period - start_period) ELSE 1 END int_period from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_rsi}',  'LINE', 'VECTOR', 'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}')) src2 " ; }  else { $detail_request = "select src2.*, round((profit / int_period * 30)::numeric,2) profit_per_month, round((protected_profit / int_period * 30)::numeric,2) prtct_profit_per_month  from ( select *, CASE WHEN extract(day from stop_period - start_period) > 0 THEN extract(day from stop_period - start_period) ELSE 1 END int_period from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_rsi}',  'LINE', 'VECTOR', 'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}')) src2 " ; } }
   if ( $pv{is_gsvct_1h1h} eq "true" ) { if ( $detail_request ne "" ) { $detail_request .= " UNION ALL select src3.*, round((profit / int_period * 30)::numeric,2) profit_per_month, round((protected_profit / int_period * 30)::numeric,2) prtct_profit_per_month from ( select *, CASE WHEN extract(day from stop_period - start_period) > 0 THEN extract(day from stop_period - start_period) ELSE 1 END int_period from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_rsi}',  'GIST', 'VECTOR', 'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}')) src3 " ; }  else { $detail_request = "select src3.*, round((profit / int_period * 30)::numeric,2) profit_per_month, round((protected_profit / int_period * 30)::numeric,2) prtct_profit_per_month  from ( select *, CASE WHEN extract(day from stop_period - start_period) > 0 THEN extract(day from stop_period - start_period) ELSE 1 END int_period from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_rsi}',  'GIST', 'VECTOR', 'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}')) src3 " ; } }
   if ( $pv{is_lncrs_1h4h} eq "true" ) { if ( $detail_request ne "" ) { $detail_request .= " UNION ALL select src4.*, round((profit / int_period * 30)::numeric,2) profit_per_month, round((protected_profit / int_period * 30)::numeric,2) prtct_profit_per_month from ( select *, CASE WHEN extract(day from stop_period - start_period) > 0 THEN extract(day from stop_period - start_period) ELSE 1 END int_period from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_macd}', 'LINE', 'CROSS',  'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}')) src4 " ; }  else { $detail_request = "select src4.*, round((profit / int_period * 30)::numeric,2) profit_per_month, round((protected_profit / int_period * 30)::numeric,2) prtct_profit_per_month  from ( select *, CASE WHEN extract(day from stop_period - start_period) > 0 THEN extract(day from stop_period - start_period) ELSE 1 END int_period from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_macd}', 'LINE', 'CROSS',  'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}')) src4 " ; } }
   if ( $pv{is_lnvct_1h4h} eq "true" ) { if ( $detail_request ne "" ) { $detail_request .= " UNION ALL select src5.*, round((profit / int_period * 30)::numeric,2) profit_per_month, round((protected_profit / int_period * 30)::numeric,2) prtct_profit_per_month from ( select *, CASE WHEN extract(day from stop_period - start_period) > 0 THEN extract(day from stop_period - start_period) ELSE 1 END int_period from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_macd}', 'LINE', 'VECTOR', 'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}')) src5 " ; }  else { $detail_request = "select src5.*, round((profit / int_period * 30)::numeric,2) profit_per_month, round((protected_profit / int_period * 30)::numeric,2) prtct_profit_per_month  from ( select *, CASE WHEN extract(day from stop_period - start_period) > 0 THEN extract(day from stop_period - start_period) ELSE 1 END int_period from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_macd}', 'LINE', 'VECTOR', 'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}')) src5 " ; } }
   if ( $pv{is_gsvct_1h4h} eq "true" ) { if ( $detail_request ne "" ) { $detail_request .= " UNION ALL select src6.*, round((profit / int_period * 30)::numeric,2) profit_per_month, round((protected_profit / int_period * 30)::numeric,2) prtct_profit_per_month from ( select *, CASE WHEN extract(day from stop_period - start_period) > 0 THEN extract(day from stop_period - start_period) ELSE 1 END int_period from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_macd}', 'GIST', 'VECTOR', 'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}')) src6 " ; }  else { $detail_request = "select src6.*, round((profit / int_period * 30)::numeric,2) profit_per_month, round((protected_profit / int_period * 30)::numeric,2) prtct_profit_per_month  from ( select *, CASE WHEN extract(day from stop_period - start_period) > 0 THEN extract(day from stop_period - start_period) ELSE 1 END int_period from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_macd}', 'GIST', 'VECTOR', 'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}')) src6 " ; } }

#   if ( $pv{is_lncrs_1h1h} eq "true" ) { if ( $detail_request ne "" ) { $detail_request .= " UNION ALL select *, extract(day from stop_period - start_period) int_period, round((profit / extract(day from stop_period - start_period)*30)::numeric,2) profit_per_month, round((protected_profit / extract(day from stop_period - start_period)*30)::numeric,2) prtct_profit_per_month from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_rsi}', 'LINE', 'CROSS',  'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}') " ; } else { $detail_request = " select *, extract(day from stop_period - start_period) int_period, round((profit / extract(day from stop_period - start_period)*30)::numeric,2) profit_per_month, round((protected_profit / extract(day from stop_period - start_period)*30)::numeric,2) prtct_profit_per_month from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_rsi}', 'LINE', 'CROSS',  'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}') " ; } }
#   if ( $pv{is_lnvct_1h1h} eq "true" ) { if ( $detail_request ne "" ) { $detail_request .= " UNION ALL select *, extract(day from stop_period - start_period) int_period, round((profit / extract(day from stop_period - start_period)*30)::numeric,2) profit_per_month, round((protected_profit / extract(day from stop_period - start_period)*30)::numeric,2) prtct_profit_per_month from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_rsi}', 'LINE', 'VECTOR', 'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}') " ; } else { $detail_request = " select *, extract(day from stop_period - start_period) int_period, round((profit / extract(day from stop_period - start_period)*30)::numeric,2) profit_per_month, round((protected_profit / extract(day from stop_period - start_period)*30)::numeric,2) prtct_profit_per_month from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_rsi}', 'LINE', 'VECTOR', 'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}') " ; } }
#   if ( $pv{is_gsvct_1h1h} eq "true" ) { if ( $detail_request ne "" ) { $detail_request .= " UNION ALL select *, extract(day from stop_period - start_period) int_period, round((profit / extract(day from stop_period - start_period)*30)::numeric,2) profit_per_month, round((protected_profit / extract(day from stop_period - start_period)*30)::numeric,2) prtct_profit_per_month from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_rsi}', 'GIST', 'VECTOR', 'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}') " ; } else { $detail_request = " select *, extract(day from stop_period - start_period) int_period, round((profit / extract(day from stop_period - start_period)*30)::numeric,2) profit_per_month, round((protected_profit / extract(day from stop_period - start_period)*30)::numeric,2) prtct_profit_per_month from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_rsi}', 'GIST', 'VECTOR', 'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}') " ; } }
#   if ( $pv{is_lncrs_1h4h} eq "true" ) { if ( $detail_request ne "" ) { $detail_request .= " UNION ALL select *, extract(day from stop_period - start_period) int_period, round((profit / extract(day from stop_period - start_period)*30)::numeric,2) profit_per_month, round((protected_profit / extract(day from stop_period - start_period)*30)::numeric,2) prtct_profit_per_month from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_macd}','LINE', 'CROSS',  'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}') " ; } else { $detail_request = " select *, extract(day from stop_period - start_period) int_period, round((profit / extract(day from stop_period - start_period)*30)::numeric,2) profit_per_month, round((protected_profit / extract(day from stop_period - start_period)*30)::numeric,2) prtct_profit_per_month from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_macd}','LINE', 'CROSS',  'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}') " ; } }
#   if ( $pv{is_lnvct_1h4h} eq "true" ) { if ( $detail_request ne "" ) { $detail_request .= " UNION ALL select *, extract(day from stop_period - start_period) int_period, round((profit / extract(day from stop_period - start_period)*30)::numeric,2) profit_per_month, round((protected_profit / extract(day from stop_period - start_period)*30)::numeric,2) prtct_profit_per_month from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_macd}','LINE', 'VECTOR', 'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}') " ; } else { $detail_request = " select *, extract(day from stop_period - start_period) int_period, round((profit / extract(day from stop_period - start_period)*30)::numeric,2) profit_per_month, round((protected_profit / extract(day from stop_period - start_period)*30)::numeric,2) prtct_profit_per_month from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_macd}','LINE', 'VECTOR', 'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}') " ; } }
#   if ( $pv{is_gsvct_1h4h} eq "true" ) { if ( $detail_request ne "" ) { $detail_request .= " UNION ALL select *, extract(day from stop_period - start_period) int_period, round((profit / extract(day from stop_period - start_period)*30)::numeric,2) profit_per_month, round((protected_profit / extract(day from stop_period - start_period)*30)::numeric,2) prtct_profit_per_month from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_macd}','GIST', 'VECTOR', 'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}') " ; } else { $detail_request = " select *, extract(day from stop_period - start_period) int_period, round((profit / extract(day from stop_period - start_period)*30)::numeric,2) profit_per_month, round((protected_profit / extract(day from stop_period - start_period)*30)::numeric,2) prtct_profit_per_month from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}','$pv{tf_macd}','GIST', 'VECTOR', 'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}') " ; } }

   $detail_request = $detail_request . " order by $pv{sort_field} desc ;" ;
#-debug-print "=== $detail_request ===\n\n<BR><BR>" ;

   my $dbh_h = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'pg_password_value' ) ;
   my $sth_h = $dbh_h->prepare($detail_request) ; $sth_h->execute(); $count_rows = 0 ;

#strategy_name,strategy_sub_name,currency,reference_currency,vector_type,profit,count_all,prct_count_pos,prct_count_neg,min_min_prct,avg_min_prct,max_max_prct,avg_max_prct,start_period,stop_period,change_ts

   my $strategy_name ; my $strategy_sub_name ; my $currency ; my $reference_currency ; my $vector_type ; my $profit ; my $protected_profit ; my $count_all ; my $prct_count_pos ; my $prct_count_neg ; 
   my $min_min_prct ;  my $avg_min_prct ; my $max_max_prct ; my $avg_max_prct ;
   my $prtct_min_min_prct ;  my $prtct_avg_min_prct ; my $prtct_max_max_prct ; my $prtct_avg_max_prct ;
   my $start_period ; my $stop_period ; my $change_ts ; my $days_period ; my $profit_per_month ;

#&is_include_ema=$pv{is_include_ema},is_include_stema=$pv{is_include_stema}

   print "<TABLE BORDER=\"1\" STYLE=\"width: 100%;\">
          <TR><TD ROWSPAN=\"2\" CLASS=\"rtrsp_strat_detais_head\">#</TD>
              <TD ROWSPAN=\"2\" CLASS=\"rtrsp_strat_detais_head\">Cтратегии</TD>
              <TD ROWSPAN=\"2\" CLASS=\"rtrsp_strat_detais_head\">Модификатор</TD>
              <TD ROWSPAN=\"2\" CLASS=\"rtrsp_strat_detais_head\"><A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_rtrsp_strategy_RSI_MACD_EMA.cgi?report_type=coins_groupped&currency=$pv{start_currency}&reference_currency=$pv{reference_currency}&is_include_rsi=$pv{is_include_rsi}&is_include_ema=$pv{is_include_ema},is_include_stema=$pv{is_include_stema}&start_date=$pv{start_date}&stop_date=$pv{stop_date}&tf_rsi=$pv{tf_rsi}&tf_macd=$pv{tf_macd}&macd_ind_type=$pv{macd_ind_type}&macd_ind_sub_type=$pv{macd_ind_sub_type}&is_lncrs_1h1h=$pv{is_lncrs_1h1h}&is_lnvct_1h1h=$pv{is_lnvct_1h1h}&is_gsvct_1h1h=$pv{is_gsvct_1h1h}&is_lncrs_1h4h=$pv{is_lncrs_1h4h}&is_lnvct_1h4h=$pv{is_lnvct_1h4h}&is_gsvct_1h4h=$pv{is_gsvct_1h4h}&sort_field=currency&sl_value=$pv{sl_value}\">Монета</A></TD>
              <TD ROWSPAN=\"2\" CLASS=\"rtrsp_strat_detais_head\">Реф.</TD>
              <TD ROWSPAN=\"2\" CLASS=\"rtrsp_strat_detais_head\">Long / Short</TD>
              <TD STYLE=\"background-color: #FF99CC;\" COLSPAN=\"6\" CLASS=\"rtrsp_strat_detais_head\">Прибыль, без Stop Loss</TD>
              <TD STYLE=\"background-color: #CCFFCC;\" COLSPAN=\"3\" CLASS=\"rtrsp_strat_detais_head\">Прибыль, SL = $pv{sl_value}%</TD>
              <TD COLSPAN=\"4\" CLASS=\"rtrsp_strat_detais_head\">За время сделок</TD>
              <TD COLSPAN=\"3\" CLASS=\"rtrsp_strat_detais_head\">Период анализа</TD></TR>

              <TR>
              <TD STYLE=\"background-color: #FF99CC;\" CLASS=\"rtrsp_strat_detais_head\"><A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_rtrsp_strategy_RSI_MACD_EMA.cgi?report_type=coins_groupped&currency=$pv{start_currency}&reference_currency=$pv{reference_currency}&is_include_rsi=$pv{is_include_rsi}&is_include_ema=$pv{is_include_ema}&is_include_stema=$pv{is_include_stema}&start_date=$pv{start_date}&stop_date=$pv{stop_date}&tf_rsi=$pv{tf_rsi}&tf_macd=$pv{tf_macd}&macd_ind_type=$pv{macd_ind_type}&macd_ind_sub_type=$pv{macd_ind_sub_type}&is_lncrs_1h1h=$pv{is_lncrs_1h1h}&is_lnvct_1h1h=$pv{is_lnvct_1h1h}&is_gsvct_1h1h=$pv{is_gsvct_1h1h}&is_lncrs_1h4h=$pv{is_lncrs_1h4h}&is_lnvct_1h4h=$pv{is_lnvct_1h4h}&is_gsvct_1h4h=$pv{is_gsvct_1h4h}&report_type=$pv{report_type}&sort_field=profit&sl_value=$pv{sl_value}\">за период<BR>%</A></TD>
              <TD STYLE=\"background-color: #FF99CC;\" CLASS=\"rtrsp_strat_detais_head\"><A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_rtrsp_strategy_RSI_MACD_EMA.cgi?report_type=coins_groupped&currency=$pv{start_currency}&reference_currency=$pv{reference_currency}&is_include_rsi=$pv{is_include_rsi}&is_include_ema=$pv{is_include_ema}&is_include_stema=$pv{is_include_stema}&start_date=$pv{start_date}&stop_date=$pv{stop_date}&tf_rsi=$pv{tf_rsi}&tf_macd=$pv{tf_macd}&macd_ind_type=$pv{macd_ind_type}&macd_ind_sub_type=$pv{macd_ind_sub_type}&is_lncrs_1h1h=$pv{is_lncrs_1h1h}&is_lnvct_1h1h=$pv{is_lnvct_1h1h}&is_gsvct_1h1h=$pv{is_gsvct_1h1h}&is_lncrs_1h4h=$pv{is_lncrs_1h4h}&is_lnvct_1h4h=$pv{is_lnvct_1h4h}&is_gsvct_1h4h=$pv{is_gsvct_1h4h}&report_type=$pv{report_type}&sort_field=profit_per_month&sl_value=$pv{sl_value}\">в 30 дней,<BR>%</A></TD>
              <TD STYLE=\"background-color: #FF99CC;\" CLASS=\"rtrsp_strat_detais_head\"><A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_rtrsp_strategy_RSI_MACD_EMA.cgi?report_type=coins_groupped&currency=$pv{start_currency}&reference_currency=$pv{reference_currency}&is_include_rsi=$pv{is_include_rsi}&is_include_ema=$pv{is_include_ema}&is_include_stema=$pv{is_include_stema}&start_date=$pv{start_date}&stop_date=$pv{stop_date}&tf_rsi=$pv{tf_rsi}&tf_macd=$pv{tf_macd}&macd_ind_type=$pv{macd_ind_type}&macd_ind_sub_type=$pv{macd_ind_sub_type}&is_lncrs_1h1h=$pv{is_lncrs_1h1h}&is_lnvct_1h1h=$pv{is_lnvct_1h1h}&is_gsvct_1h1h=$pv{is_gsvct_1h1h}&is_lncrs_1h4h=$pv{is_lncrs_1h4h}&is_lnvct_1h4h=$pv{is_lnvct_1h4h}&is_gsvct_1h4h=$pv{is_gsvct_1h4h}&report_type=$pv{report_type}&sort_field=profit_per_month&sl_value=$pv{sl_value}\">в год,<BR>%</A></TD>
              <TD STYLE=\"background-color: #FF99CC;\" CLASS=\"rtrsp_strat_detais_head\"><A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_rtrsp_strategy_RSI_MACD_EMA.cgi?report_type=coins_groupped&currency=$pv{start_currency}&reference_currency=$pv{reference_currency}&is_include_rsi=$pv{is_include_rsi}&is_include_ema=$pv{is_include_ema}&is_include_stema=$pv{is_include_stema}&start_date=$pv{start_date}&stop_date=$pv{stop_date}&tf_rsi=$pv{tf_rsi}&tf_macd=$pv{tf_macd}&macd_ind_type=$pv{macd_ind_type}&macd_ind_sub_type=$pv{macd_ind_sub_type}&is_lncrs_1h1h=$pv{is_lncrs_1h1h}&is_lnvct_1h1h=$pv{is_lnvct_1h1h}&is_gsvct_1h1h=$pv{is_gsvct_1h1h}&is_lncrs_1h4h=$pv{is_lncrs_1h4h}&is_lnvct_1h4h=$pv{is_lnvct_1h4h}&is_gsvct_1h4h=$pv{is_gsvct_1h4h}&report_type=$pv{report_type}&sort_field=count_all&sl_value=$pv{sl_value}\">Сделок,<BR>всего</TD>
              <TD STYLE=\"background-color: #FF99CC;\" CLASS=\"rtrsp_strat_detais_head\"><A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_rtrsp_strategy_RSI_MACD_EMA.cgi?report_type=coins_groupped&currency=$pv{start_currency}&reference_currency=$pv{reference_currency}&is_include_rsi=$pv{is_include_rsi}&is_include_ema=$pv{is_include_ema}&is_include_stema=$pv{is_include_stema}&start_date=$pv{start_date}&stop_date=$pv{stop_date}&tf_rsi=$pv{tf_rsi}&tf_macd=$pv{tf_macd}&macd_ind_type=$pv{macd_ind_type}&macd_ind_sub_type=$pv{macd_ind_sub_type}&is_lncrs_1h1h=$pv{is_lncrs_1h1h}&is_lnvct_1h1h=$pv{is_lnvct_1h1h}&is_gsvct_1h1h=$pv{is_gsvct_1h1h}&is_lncrs_1h4h=$pv{is_lncrs_1h4h}&is_lnvct_1h4h=$pv{is_lnvct_1h4h}&is_gsvct_1h4h=$pv{is_gsvct_1h4h}&report_type=$pv{report_type}&sort_field=prct_count_pos&sl_value=$pv{sl_value}\">Успех,<BR>%</TD>
              <TD STYLE=\"background-color: #FF99CC;\" CLASS=\"rtrsp_strat_detais_head\"><A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_rtrsp_strategy_RSI_MACD_EMA.cgi?report_type=coins_groupped&currency=$pv{start_currency}&reference_currency=$pv{reference_currency}&is_include_rsi=$pv{is_include_rsi}&is_include_ema=$pv{is_include_ema}&is_include_stema=$pv{is_include_stema}&start_date=$pv{start_date}&stop_date=$pv{stop_date}&tf_rsi=$pv{tf_rsi}&tf_macd=$pv{tf_macd}&macd_ind_type=$pv{macd_ind_type}&macd_ind_sub_type=$pv{macd_ind_sub_type}&is_lncrs_1h1h=$pv{is_lncrs_1h1h}&is_lnvct_1h1h=$pv{is_lnvct_1h1h}&is_gsvct_1h1h=$pv{is_gsvct_1h1h}&is_lncrs_1h4h=$pv{is_lncrs_1h4h}&is_lnvct_1h4h=$pv{is_lnvct_1h4h}&is_gsvct_1h4h=$pv{is_gsvct_1h4h}&report_type=$pv{report_type}&sort_field=prct_count_pos&sl_value=$pv{sl_value}\">НеУсп,<BR>%</TD>

              <TD STYLE=\"background-color: #CCFFCC;\" CLASS=\"rtrsp_strat_detais_head\"><A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_rtrsp_strategy_RSI_MACD_EMA.cgi?report_type=coins_groupped&currency=$pv{start_currency}&reference_currency=$pv{reference_currency}&is_include_rsi=$pv{is_include_rsi}&is_include_ema=$pv{is_include_ema}&is_include_stema=$pv{is_include_stema}&start_date=$pv{start_date}&stop_date=$pv{stop_date}&tf_rsi=$pv{tf_rsi}&tf_macd=$pv{tf_macd}&macd_ind_type=$pv{macd_ind_type}&macd_ind_sub_type=$pv{macd_ind_sub_type}&is_lncrs_1h1h=$pv{is_lncrs_1h1h}&is_lnvct_1h1h=$pv{is_lnvct_1h1h}&is_gsvct_1h1h=$pv{is_gsvct_1h1h}&is_lncrs_1h4h=$pv{is_lncrs_1h4h}&is_lnvct_1h4h=$pv{is_lnvct_1h4h}&is_gsvct_1h4h=$pv{is_gsvct_1h4h}&report_type=$pv{report_type}&sort_field=protected_profit&sl_value=$pv{sl_value}\">за период<BR>%</A></TD>
              <TD STYLE=\"background-color: #CCFFCC;\" CLASS=\"rtrsp_strat_detais_head\"><A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_rtrsp_strategy_RSI_MACD_EMA.cgi?report_type=coins_groupped&currency=$pv{start_currency}&reference_currency=$pv{reference_currency}&is_include_rsi=$pv{is_include_rsi}&is_include_ema=$pv{is_include_ema}&is_include_stema=$pv{is_include_stema}&start_date=$pv{start_date}&stop_date=$pv{stop_date}&tf_rsi=$pv{tf_rsi}&tf_macd=$pv{tf_macd}&macd_ind_type=$pv{macd_ind_type}&macd_ind_sub_type=$pv{macd_ind_sub_type}&is_lncrs_1h1h=$pv{is_lncrs_1h1h}&is_lnvct_1h1h=$pv{is_lnvct_1h1h}&is_gsvct_1h1h=$pv{is_gsvct_1h1h}&is_lncrs_1h4h=$pv{is_lncrs_1h4h}&is_lnvct_1h4h=$pv{is_lnvct_1h4h}&is_gsvct_1h4h=$pv{is_gsvct_1h4h}&report_type=$pv{report_type}&sort_field=prtct_profit_per_month&sl_value=$pv{sl_value}\">в 30 дней,<BR>%</A></TD>
              <TD STYLE=\"background-color: #CCFFCC;\" CLASS=\"rtrsp_strat_detais_head\"><A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_rtrsp_strategy_RSI_MACD_EMA.cgi?report_type=coins_groupped&currency=$pv{start_currency}&reference_currency=$pv{reference_currency}&is_include_rsi=$pv{is_include_rsi}&is_include_ema=$pv{is_include_ema}&is_include_stema=$pv{is_include_stema}&start_date=$pv{start_date}&stop_date=$pv{stop_date}&tf_rsi=$pv{tf_rsi}&tf_macd=$pv{tf_macd}&macd_ind_type=$pv{macd_ind_type}&macd_ind_sub_type=$pv{macd_ind_sub_type}&is_lncrs_1h1h=$pv{is_lncrs_1h1h}&is_lnvct_1h1h=$pv{is_lnvct_1h1h}&is_gsvct_1h1h=$pv{is_gsvct_1h1h}&is_lncrs_1h4h=$pv{is_lncrs_1h4h}&is_lnvct_1h4h=$pv{is_lnvct_1h4h}&is_gsvct_1h4h=$pv{is_gsvct_1h4h}&report_type=$pv{report_type}&sort_field=prtct_profit_per_month&sl_value=$pv{sl_value}\">в год,<BR>%</A></TD>

              <TD CLASS=\"rtrsp_strat_detais_head\">просадка,<BR>MAX</TD>
              <TD CLASS=\"rtrsp_strat_detais_head\">просадка,<BR>AVG</TD>
              <TD CLASS=\"rtrsp_strat_detais_head\">рост,<BR>MAX</TD>
              <TD CLASS=\"rtrsp_strat_detais_head\">рост,<BR>AVG</TD>

              <TD CLASS=\"rtrsp_strat_detais_head\">Дней</TD>
              <TD CLASS=\"rtrsp_strat_detais_head\">Начало</TD>
              <TD CLASS=\"rtrsp_strat_detais_head\">Конец</TD></TR>" ;
   my $count_rows_details = 0 ;
   while (($strategy_name, $strategy_sub_name, $currency, $reference_currency, $vector_type, $profit, $protected_profit, $count_all, $prct_count_pos, $prct_count_neg, $min_min_prct, $avg_min_prct, $max_max_prct, $avg_max_prct, $prtct_min_min_prct, $prtct_avg_min_prct, $start_period, $stop_period, $change_ts, $days_period, $profit_per_month, $prtct_profit_per_month) = $sth_h->fetchrow_array() ) {
         $start_period =~ s/\s/&nbsp;/g ; $stop_period =~ s/\s/&nbsp;/g ; $change_ts =~ s/\s/&nbsp;/g ;
#         $price_close =~ s/(.*[^0])(0+)$/$1/g ;
#         $next_timestamp =~ s/\s/&nbsp;/g ; $next_price_close =~ s/(.*[^0])(0+)$/$1/g ; $diff_price =~ s/(.*[^0])(0+)$/$1/g ;
#         $next_timestamp_shift =~ s/\s/&nbsp;/g ; $next_price_close_shift =~ s/(.*[^0])(0+)$/$1/g ; $diff_price_shift =~ s/(.*[^0])(0+)$/$1/g ;
   
   $count_rows_details++ ;
   $strategy_name =~ /RSI_(\S+)_MACD_(\S+)_(\S+)_(\S+)/ ; my $v_tf_RSI = $1 ; my $v_tf_MACD = $2 ;  my $v_MACD_ind_type = $3 ; my $v_MACD_ind_sub_type = $4 ; 
   my $profit_per_year = $profit_per_month * 12 ; my $prtct_profit_per_year = $prtct_profit_per_month * 12 ;
   print "<TR><TD CLASS=\"rtrsp_strat_detais_right\">$count_rows_details</TD>
              <TD CLASS=\"rtrsp_strat_detais_left\"><A HREF=\"cgi/rep_rtrsp_strategy_RSI_MACD_EMA.cgi?report_type=one_coin&currency=$currency&curr_reference=$reference_currency&is_include_rsi=$pv{is_include_rsi}&is_include_ema=$pv{is_include_ema}&is_include_stema=$pv{is_include_stema}&start_date=$pv{start_date}&stop_date=$pv{stop_date}&tf_rsi=$v_tf_RSI&tf_macd=$v_tf_MACD&macd_ind_type=$v_MACD_ind_type&macd_ind_sub_type=$v_MACD_ind_sub_type&is_lncrs_1h1h=$pv{is_lncrs_1h1h}&is_lnvct_1h1h=$pv{is_lnvct_1h1h}&is_gsvct_1h1h=$pv{is_gsvct_1h1h}&is_lncrs_1h4h=$pv{is_lncrs_1h4h}&is_lnvct_1h4h=$pv{is_lnvct_1h4h}&is_gsvct_1h4h=$pv{is_gsvct_1h4h}&sort_field=currency&sl_value=$pv{sl_value}\">$strategy_name</A></TD>
              <TD CLASS=\"rtrsp_strat_detais_left\">$strategy_sub_name</TD>
              <TD CLASS=\"rtrsp_strat_detais_left\">$currency</A></TD>
              <TD CLASS=\"rtrsp_strat_detais_left\">$reference_currency</TD>
              <TD CLASS=\"rtrsp_strat_detais_center\">$vector_type</TD>
              <TD STYLE=\"background-color: #FF99CC;\" CLASS=\"small_rtrsp_strat_detais_right\">$profit</TD>
              <TD STYLE=\"background-color: #FF99CC;\" CLASS=\"small_rtrsp_strat_detais_right\">$profit_per_month</TD>
              <TD STYLE=\"background-color: #FF99CC;\" CLASS=\"rtrsp_strat_detais_right\">$profit_per_year</TD>
              <TD STYLE=\"background-color: #FF99CC;\" CLASS=\"rtrsp_strat_detais_right\">$count_all</TD>
              <TD STYLE=\"background-color: #FF99CC;\" CLASS=\"rtrsp_strat_detais_right\">$prct_count_pos</TD>
              <TD STYLE=\"background-color: #FF99CC;\" CLASS=\"rtrsp_strat_detais_right\">$prct_count_neg</TD>
              <TD STYLE=\"background-color: #CCFFCC;\" CLASS=\"small_rtrsp_strat_detais_right\">$protected_profit</TD>
              <TD STYLE=\"background-color: #CCFFCC;\" CLASS=\"small_rtrsp_strat_detais_right\">$prtct_profit_per_month</TD>
              <TD STYLE=\"background-color: #CCFFCC;\" CLASS=\"rtrsp_strat_detais_right\">$prtct_profit_per_year</TD>
              <TD CLASS=\"rtrsp_strat_detais_right\">$min_min_prct</TD>
              <TD CLASS=\"rtrsp_strat_detais_right\">$avg_min_prct</TD>
              <TD CLASS=\"rtrsp_strat_detais_right\">$max_max_prct</TD>
              <TD CLASS=\"rtrsp_strat_detais_right\">$avg_max_prct</TD>
              <TD CLASS=\"rtrsp_strat_detais_right\">$days_period</TD>
              <TD CLASS=\"small_rtrsp_strat_detais_left\">$start_period</TD>
              <TD CLASS=\"small_rtrsp_strat_detais_left\">$stop_period</TD></TR>" ;
         }
   $sth_h->finish() ;
   $dbh_h->disconnect() ;
   print "</TABLE>" ;
   }

if ( $pv{report_type} eq "one_coin" ) {
   $aggregate_request = "select *, extract(day from stop_period - start_period) int_period, round((profit / extract(day from stop_period - start_period)*30)::numeric,2) profit_per_month, round((protected_profit / extract(day from stop_period - start_period)*30)::numeric,2) prtct_profit_per_month from fn_rtsp_driver_strategy_RSI_MACD_EMA('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}', '$pv{tf_macd}','$pv{macd_ind_type}','$pv{macd_ind_sub_type}', 'all', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}')" ;
#-debug-print "=== $aggregate_request ===\n\n<BR><BR>" ;

   $detail_request = "select * from (select contract_in_tp, contract_in_price, contract_out_tp, contract_out_price, vector, profit, protected_profit, cn_period, min_prct, prtct_min_prct, max_prct 
                             from check_strategy_RSI_MACD_EMA_long_as_table('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}', '$pv{tf_macd}','$pv{macd_ind_type}','$pv{macd_ind_sub_type}', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}')
                      union all
                      select contract_in_tp, contract_in_price, contract_out_tp, contract_out_price, vector, profit, protected_profit, cn_period, min_prct, prtct_min_prct, max_prct 
                             from check_strategy_RSI_MACD_EMA_short_as_table('$pv{currency}','$pv{reference_currency}','$pv{tf_rsi}', '$pv{tf_macd}','$pv{macd_ind_type}','$pv{macd_ind_sub_type}', $pv{sl_value}, $pv{is_include_rsi}, '$pv{start_date}', '$pv{stop_date}', '$pv{is_include_ema}', '$pv{is_include_stema}')) src1
                      order by contract_in_tp ;" ;
#-debug-print "<PRE>=== $detail_request ===</PRE>\n\n<BR><BR>" ;

   my $dbh_h = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'pg_password_value' ) ;
   my $sth_h = $dbh_h->prepare($aggregate_request) ; $sth_h->execute(); $count_rows = 0 ;

#strategy_name,strategy_sub_name,currency,reference_currency,vector_type,profit,count_all,prct_count_pos,prct_count_neg,min_min_prct,avg_min_prct,max_max_prct,avg_max_prct,start_period,stop_period,change_ts

   my $strategy_name ; my $strategy_sub_name ; my $currency ; my $reference_currency ; my $vector_type ; my $profit; my $protected_profit ; my $count_all ; my $prct_count_pos ; my $prct_count_neg ; my $min_min_prct ;
   my $avg_min_prct ; my $max_max_prct ; my $avg_max_prct ; my $start_period ; my $stop_period ; my $change_ts ; my $days_period ; my $profit_per_month ;

   print "<P STYLE=\"text-align: right; color: navy; font-weight: bold;\">Агрегация сделок</P>" ;
   print "<TABLE BORDER=\"1\" STYLE=\"width: 100%;\">
          <TR><TD ROWSPAN=\"2\" CLASS=\"rtrsp_strat_detais_head\">Cтратегии</TD>
              <TD ROWSPAN=\"2\" CLASS=\"rtrsp_strat_detais_head\">Модификатор</TD>
              <TD ROWSPAN=\"2\" CLASS=\"rtrsp_strat_detais_head\"><A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_rtrsp_strategy_RSI_MACD_EMA.cgi?report_type=coins_groupped&currency=$pv{start_currency}&reference_currency=$pv{reference_currency}&is_include_rsi=$pv{is_include_rsi}&is_include_ema=$pv{is_include_ema}&is_include_stema=$pv{is_include_stema}&start_date=$pv{start_date}&stop_date=$pv{stop_date}&tf_rsi=$pv{tf_rsi}&tf_macd=$pv{tf_macd}&macd_ind_type=$pv{macd_ind_type}&macd_ind_sub_type=$pv{macd_ind_sub_type}&is_lncrs_1h1h=$pv{is_lncrs_1h1h}&is_lnvct_1h1h=$pv{is_lnvct_1h1h}&is_gsvct_1h1h=$pv{is_gsvct_1h1h}&is_lncrs_1h4h=$pv{is_lncrs_1h4h}&is_lnvct_1h4h=$pv{is_lnvct_1h4h}&is_gsvct_1h4h=$pv{is_gsvct_1h4h}&sort_field=currency&sl_value=$pv{sl_value}\">Монета</A></TD>
              <TD ROWSPAN=\"2\" CLASS=\"rtrsp_strat_detais_head\">Реф.</TD>
              <TD ROWSPAN=\"2\" CLASS=\"rtrsp_strat_detais_head\">Long / Short</TD>
              <TD STYLE=\"background-color: #FF99CC;\" COLSPAN=\"6\" CLASS=\"rtrsp_strat_detais_head\">Прибыль, без Stop Loss</TD>
              <TD STYLE=\"background-color: #CCFFCC;\" COLSPAN=\"3\" CLASS=\"rtrsp_strat_detais_head\">Прибыль, SL = $pv{sl_value}%</TD>
              <TD COLSPAN=\"4\" CLASS=\"rtrsp_strat_detais_head\">За время сделок</TD>
              <TD COLSPAN=\"3\" CLASS=\"rtrsp_strat_detais_head\">Период анализа</TD></TR>

              <TR>
              <TD STYLE=\"background-color: #FF99CC;\" CLASS=\"rtrsp_strat_detais_head\"><A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_rtrsp_strategy_RSI_MACD_EMA.cgi?report_type=coins_groupped&currency=$pv{start_currency}&reference_currency=$pv{reference_currency}&is_include_rsi=$pv{is_include_rsi}&is_include_ema=$pv{is_include_ema}&is_include_stema=$pv{is_include_stema}&start_date=$pv{start_date}&stop_date=$pv{stop_date}&tf_rsi=$pv{tf_rsi}&tf_macd=$pv{tf_macd}&macd_ind_type=$pv{macd_ind_type}&macd_ind_sub_type=$pv{macd_ind_sub_type}&is_lncrs_1h1h=$pv{is_lncrs_1h1h}&is_lnvct_1h1h=$pv{is_lnvct_1h1h}&is_gsvct_1h1h=$pv{is_gsvct_1h1h}&is_lncrs_1h4h=$pv{is_lncrs_1h4h}&is_lnvct_1h4h=$pv{is_lnvct_1h4h}&is_gsvct_1h4h=$pv{is_gsvct_1h4h}&report_type=$pv{report_type}&sort_field=profit&sl_value=$pv{sl_value}\">за период<BR>%</A></TD>
              <TD STYLE=\"background-color: #FF99CC;\" CLASS=\"rtrsp_strat_detais_head\"><A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_rtrsp_strategy_RSI_MACD_EMA.cgi?report_type=coins_groupped&currency=$pv{start_currency}&reference_currency=$pv{reference_currency}&is_include_rsi=$pv{is_include_rsi}&is_include_ema=$pv{is_include_ema}&is_include_stema=$pv{is_include_stema}&start_date=$pv{start_date}&stop_date=$pv{stop_date}&tf_rsi=$pv{tf_rsi}&tf_macd=$pv{tf_macd}&macd_ind_type=$pv{macd_ind_type}&macd_ind_sub_type=$pv{macd_ind_sub_type}&is_lncrs_1h1h=$pv{is_lncrs_1h1h}&is_lnvct_1h1h=$pv{is_lnvct_1h1h}&is_gsvct_1h1h=$pv{is_gsvct_1h1h}&is_lncrs_1h4h=$pv{is_lncrs_1h4h}&is_lnvct_1h4h=$pv{is_lnvct_1h4h}&is_gsvct_1h4h=$pv{is_gsvct_1h4h}&report_type=$pv{report_type}&sort_field=profit_per_month&sl_value=$pv{sl_value}\">в 30 дней,<BR>%</A></TD>
              <TD STYLE=\"background-color: #FF99CC;\" CLASS=\"rtrsp_strat_detais_head\"><A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_rtrsp_strategy_RSI_MACD_EMA.cgi?report_type=coins_groupped&currency=$pv{start_currency}&reference_currency=$pv{reference_currency}&is_include_rsi=$pv{is_include_rsi}&is_include_ema=$pv{is_include_ema}&is_include_stema=$pv{is_include_stema}&start_date=$pv{start_date}&stop_date=$pv{stop_date}&tf_rsi=$pv{tf_rsi}&tf_macd=$pv{tf_macd}&macd_ind_type=$pv{macd_ind_type}&macd_ind_sub_type=$pv{macd_ind_sub_type}&is_lncrs_1h1h=$pv{is_lncrs_1h1h}&is_lnvct_1h1h=$pv{is_lnvct_1h1h}&is_gsvct_1h1h=$pv{is_gsvct_1h1h}&is_lncrs_1h4h=$pv{is_lncrs_1h4h}&is_lnvct_1h4h=$pv{is_lnvct_1h4h}&is_gsvct_1h4h=$pv{is_gsvct_1h4h}&report_type=$pv{report_type}&sort_field=profit_per_month&sl_value=$pv{sl_value}\">в год,<BR>%</A></TD>
              <TD STYLE=\"background-color: #FF99CC;\" CLASS=\"rtrsp_strat_detais_head\"><A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_rtrsp_strategy_RSI_MACD_EMA.cgi?report_type=coins_groupped&currency=$pv{start_currency}&reference_currency=$pv{reference_currency}&is_include_rsi=$pv{is_include_rsi}&is_include_ema=$pv{is_include_ema}&is_include_stema=$pv{is_include_stema}&start_date=$pv{start_date}&stop_date=$pv{stop_date}&tf_rsi=$pv{tf_rsi}&tf_macd=$pv{tf_macd}&macd_ind_type=$pv{macd_ind_type}&macd_ind_sub_type=$pv{macd_ind_sub_type}&is_lncrs_1h1h=$pv{is_lncrs_1h1h}&is_lnvct_1h1h=$pv{is_lnvct_1h1h}&is_gsvct_1h1h=$pv{is_gsvct_1h1h}&is_lncrs_1h4h=$pv{is_lncrs_1h4h}&is_lnvct_1h4h=$pv{is_lnvct_1h4h}&is_gsvct_1h4h=$pv{is_gsvct_1h4h}&report_type=$pv{report_type}&sort_field=count_all&sl_value=$pv{sl_value}\">Сделок,<BR>всего</TD>
              <TD STYLE=\"background-color: #FF99CC;\" CLASS=\"rtrsp_strat_detais_head\"><A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_rtrsp_strategy_RSI_MACD_EMA.cgi?report_type=coins_groupped&currency=$pv{start_currency}&reference_currency=$pv{reference_currency}&is_include_rsi=$pv{is_include_rsi}&is_include_ema=$pv{is_include_ema}&is_include_stema=$pv{is_include_stema}&start_date=$pv{start_date}&stop_date=$pv{stop_date}&tf_rsi=$pv{tf_rsi}&tf_macd=$pv{tf_macd}&macd_ind_type=$pv{macd_ind_type}&macd_ind_sub_type=$pv{macd_ind_sub_type}&is_lncrs_1h1h=$pv{is_lncrs_1h1h}&is_lnvct_1h1h=$pv{is_lnvct_1h1h}&is_gsvct_1h1h=$pv{is_gsvct_1h1h}&is_lncrs_1h4h=$pv{is_lncrs_1h4h}&is_lnvct_1h4h=$pv{is_lnvct_1h4h}&is_gsvct_1h4h=$pv{is_gsvct_1h4h}&report_type=$pv{report_type}&sort_field=prct_count_pos&sl_value=$pv{sl_value}\">Успех,<BR>%</TD>
              <TD STYLE=\"background-color: #FF99CC;\" CLASS=\"rtrsp_strat_detais_head\"><A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_rtrsp_strategy_RSI_MACD_EMA.cgi?report_type=coins_groupped&currency=$pv{start_currency}&reference_currency=$pv{reference_currency}&is_include_rsi=$pv{is_include_rsi}&is_include_ema=$pv{is_include_ema}&is_include_stema=$pv{is_include_stema}&start_date=$pv{start_date}&stop_date=$pv{stop_date}&tf_rsi=$pv{tf_rsi}&tf_macd=$pv{tf_macd}&macd_ind_type=$pv{macd_ind_type}&macd_ind_sub_type=$pv{macd_ind_sub_type}&is_lncrs_1h1h=$pv{is_lncrs_1h1h}&is_lnvct_1h1h=$pv{is_lnvct_1h1h}&is_gsvct_1h1h=$pv{is_gsvct_1h1h}&is_lncrs_1h4h=$pv{is_lncrs_1h4h}&is_lnvct_1h4h=$pv{is_lnvct_1h4h}&is_gsvct_1h4h=$pv{is_gsvct_1h4h}&report_type=$pv{report_type}&sort_field=prct_count_pos&sl_value=$pv{sl_value}\">НеУсп,<BR>%</TD>

              <TD STYLE=\"background-color: #CCFFCC;\" CLASS=\"rtrsp_strat_detais_head\"><A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_rtrsp_strategy_RSI_MACD_EMA.cgi?report_type=coins_groupped&currency=$pv{start_currency}&reference_currency=$pv{reference_currency}&is_include_rsi=$pv{is_include_rsi}&is_include_ema=$pv{is_include_ema}&is_include_stema=$pv{is_include_stema}&start_date=$pv{start_date}&stop_date=$pv{stop_date}&tf_rsi=$pv{tf_rsi}&tf_macd=$pv{tf_macd}&macd_ind_type=$pv{macd_ind_type}&macd_ind_sub_type=$pv{macd_ind_sub_type}&is_lncrs_1h1h=$pv{is_lncrs_1h1h}&is_lnvct_1h1h=$pv{is_lnvct_1h1h}&is_gsvct_1h1h=$pv{is_gsvct_1h1h}&is_lncrs_1h4h=$pv{is_lncrs_1h4h}&is_lnvct_1h4h=$pv{is_lnvct_1h4h}&is_gsvct_1h4h=$pv{is_gsvct_1h4h}&report_type=$pv{report_type}&sort_field=protected_profit&sl_value=$pv{sl_value}\">за период<BR>%</A></TD>
              <TD STYLE=\"background-color: #CCFFCC;\" CLASS=\"rtrsp_strat_detais_head\"><A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_rtrsp_strategy_RSI_MACD_EMA.cgi?report_type=coins_groupped&currency=$pv{start_currency}&reference_currency=$pv{reference_currency}&is_include_rsi=$pv{is_include_rsi}&is_include_ema=$pv{is_include_ema}&is_include_stema=$pv{is_include_stema}&start_date=$pv{start_date}&stop_date=$pv{stop_date}&tf_rsi=$pv{tf_rsi}&tf_macd=$pv{tf_macd}&macd_ind_type=$pv{macd_ind_type}&macd_ind_sub_type=$pv{macd_ind_sub_type}&is_lncrs_1h1h=$pv{is_lncrs_1h1h}&is_lnvct_1h1h=$pv{is_lnvct_1h1h}&is_gsvct_1h1h=$pv{is_gsvct_1h1h}&is_lncrs_1h4h=$pv{is_lncrs_1h4h}&is_lnvct_1h4h=$pv{is_lnvct_1h4h}&is_gsvct_1h4h=$pv{is_gsvct_1h4h}&report_type=$pv{report_type}&sort_field=prtct_profit_per_month&sl_value=$pv{sl_value}\">в 30 дней,<BR>%</A></TD>
              <TD STYLE=\"background-color: #CCFFCC;\" CLASS=\"rtrsp_strat_detais_head\"><A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_rtrsp_strategy_RSI_MACD_EMA.cgi?report_type=coins_groupped&currency=$pv{start_currency}&reference_currency=$pv{reference_currency}&is_include_rsi=$pv{is_include_rsi}&is_include_ema=$pv{is_include_ema}&is_include_stema=$pv{is_include_stema}&start_date=$pv{start_date}&stop_date=$pv{stop_date}&tf_rsi=$pv{tf_rsi}&tf_macd=$pv{tf_macd}&macd_ind_type=$pv{macd_ind_type}&macd_ind_sub_type=$pv{macd_ind_sub_type}&is_lncrs_1h1h=$pv{is_lncrs_1h1h}&is_lnvct_1h1h=$pv{is_lnvct_1h1h}&is_gsvct_1h1h=$pv{is_gsvct_1h1h}&is_lncrs_1h4h=$pv{is_lncrs_1h4h}&is_lnvct_1h4h=$pv{is_lnvct_1h4h}&is_gsvct_1h4h=$pv{is_gsvct_1h4h}&report_type=$pv{report_type}&sort_field=prtct_profit_per_month&sl_value=$pv{sl_value}\">в год,<BR>%</A></TD>

              <TD CLASS=\"rtrsp_strat_detais_head\">просадка,<BR>MAX</TD>
              <TD CLASS=\"rtrsp_strat_detais_head\">просадка,<BR>AVG</TD>
              <TD CLASS=\"rtrsp_strat_detais_head\">рост,<BR>MAX</TD>
              <TD CLASS=\"rtrsp_strat_detais_head\">рост,<BR>AVG</TD>

              <TD CLASS=\"rtrsp_strat_detais_head\">Дней</TD>
              <TD CLASS=\"rtrsp_strat_detais_head\">Начало</TD>
              <TD CLASS=\"rtrsp_strat_detais_head\">Конец</TD></TR>" ;

   while (($strategy_name, $strategy_sub_name, $currency, $reference_currency, $vector_type, $profit, $protected_profit, $count_all, $prct_count_pos, $prct_count_neg, $min_min_prct, $avg_min_prct, $max_max_prct, $avg_max_prct, $prtct_min_min_prct, $prtct_avg_min_prct, $start_period, $stop_period, $change_ts, $days_period, $profit_per_month, $prtct_profit_per_month) = $sth_h->fetchrow_array() ) {
         $start_period =~ s/\s/&nbsp;/g ; $stop_period =~ s/\s/&nbsp;/g ; $change_ts =~ s/\s/&nbsp;/g ;
#         $price_close =~ s/(.*[^0])(0+)$/$1/g ;
#         $next_timestamp =~ s/\s/&nbsp;/g ; $next_price_close =~ s/(.*[^0])(0+)$/$1/g ; $diff_price =~ s/(.*[^0])(0+)$/$1/g ;
#         $next_timestamp_shift =~ s/\s/&nbsp;/g ; $next_price_close_shift =~ s/(.*[^0])(0+)$/$1/g ; $diff_price_shift =~ s/(.*[^0])(0+)$/$1/g ;
   

   $strategy_name =~ /RSI_(\S+)_MACD_(\S+)_(\S+)_(\S+)/ ; my $v_tf_RSI = $1 ; my $v_tf_MACD = $2 ;  my $v_MACD_ind_type = $3 ; my $v_MACD_ind_sub_type = $4 ; 
   my $profit_per_year = $profit_per_month * 12 ; my $prtct_profit_per_year = $prtct_profit_per_month * 12 ;
   print "<TR><TD CLASS=\"rtrsp_strat_detais_left\"><A HREF=\"cgi/rep_rtrsp_strategy_RSI_MACD_EMA.cgi?report_type=one_coin&currency=$currency&curr_reference=$reference_currency&tf_rsi=$v_tf_RSI&tf_macd=$v_tf_MACD&macd_ind_type=$v_MACD_ind_type&macd_ind_sub_type=$v_MACD_ind_sub_type&is_include_rsi=$pv{is_include_rsi}&is_include_ema=$pv{is_include_ema}&is_include_stema=$pv{is_include_stema}&start_date=$pv{start_date}&stop_date=$pv{stop_date}&is_lncrs_1h1h=$pv{is_lncrs_1h1h}&is_lnvct_1h1h=$pv{is_lnvct_1h1h}&is_gsvct_1h1h=$pv{is_gsvct_1h1h}&is_lncrs_1h4h=$pv{is_lncrs_1h4h}&is_lnvct_1h4h=$pv{is_lnvct_1h4h}&is_gsvct_1h4h=$pv{is_gsvct_1h4h}&sort_field=currency&sl_value=$pv{sl_value}\">$strategy_name</A></TD>
              <TD CLASS=\"rtrsp_strat_detais_left\">$strategy_sub_name</TD>
              <TD CLASS=\"rtrsp_strat_detais_left\">$currency</A></TD>
              <TD CLASS=\"rtrsp_strat_detais_left\">$reference_currency</TD>
              <TD CLASS=\"rtrsp_strat_detais_center\">$vector_type</TD>
              <TD STYLE=\"background-color: #FF99CC;\" CLASS=\"small_rtrsp_strat_detais_right\">$profit</TD>
              <TD STYLE=\"background-color: #FF99CC;\" CLASS=\"small_rtrsp_strat_detais_right\">$profit_per_month</TD>
              <TD STYLE=\"background-color: #FF99CC;\" CLASS=\"rtrsp_strat_detais_right\">$profit_per_year</TD>
              <TD STYLE=\"background-color: #FF99CC;\" CLASS=\"rtrsp_strat_detais_right\">$count_all</TD>
              <TD STYLE=\"background-color: #FF99CC;\" CLASS=\"rtrsp_strat_detais_right\">$prct_count_pos</TD>
              <TD STYLE=\"background-color: #FF99CC;\" CLASS=\"rtrsp_strat_detais_right\">$prct_count_neg</TD>
              <TD STYLE=\"background-color: #CCFFCC;\" CLASS=\"small_rtrsp_strat_detais_right\">$protected_profit</TD>
              <TD STYLE=\"background-color: #CCFFCC;\" CLASS=\"small_rtrsp_strat_detais_right\">$prtct_profit_per_month</TD>
              <TD STYLE=\"background-color: #CCFFCC;\" CLASS=\"rtrsp_strat_detais_right\">$prtct_profit_per_year</TD>
              <TD CLASS=\"rtrsp_strat_detais_right\">$min_min_prct</TD>
              <TD CLASS=\"rtrsp_strat_detais_right\">$avg_min_prct</TD>
              <TD CLASS=\"rtrsp_strat_detais_right\">$max_max_prct</TD>
              <TD CLASS=\"rtrsp_strat_detais_right\">$avg_max_prct</TD>
              <TD CLASS=\"rtrsp_strat_detais_right\">$days_period</TD>
              <TD CLASS=\"small_rtrsp_strat_detais_left\">$start_period</TD>
              <TD CLASS=\"small_rtrsp_strat_detais_left\">$stop_period</TD></TR>" ;
         }
   $sth_h->finish() ;
   $dbh_h->disconnect() ;
   print "</TABLE>" ;

   my $dbh_h_detail = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'pg_password_value' ) ;
   my $sth_h_detail = $dbh_h_detail->prepare($detail_request) ; $sth_h_detail->execute(); $count_rows = 0 ;

#$contract_in_tp, $vector, $profit, $cn_period, $min_prct, $max_prct 
   my $contract_in_tp ; my $contract_in_price ; my $contract_out_tp ; my $contract_out_price ; my $vector ; my $profit ; my $protected_profit ; my $cn_period ; my $min_prct ; my $prtct_min_prct ; my $max_prct ;

   print "<BR><P STYLE=\"text-align: right; color: navy; font-weight: bold;\">Детализация сделок</P>" ;
   print "<TABLE BORDER=\"1\" STYLE=\"width: 100%;\">
          <TR><TD CLASS=\"rtrsp_strat_detais_head\">#</TD>
              <TD CLASS=\"rtrsp_strat_detais_head\">Старт сделки</TD>
              <TD CLASS=\"rtrsp_strat_detais_head\">Цена входа</TD>
              <TD CLASS=\"rtrsp_strat_detais_head\">Стоп сделки</TD>
              <TD CLASS=\"rtrsp_strat_detais_head\">Цена выхода</TD>
              <TD CLASS=\"rtrsp_strat_detais_head\">Вектор</TD>
              <TD CLASS=\"rtrsp_strat_detais_head\">Прибыль</TD>
              <TD CLASS=\"rtrsp_strat_detais_head\">Прибыль SL</TD>
              <TD CLASS=\"rtrsp_strat_detais_head\">Период сделки</TD>
              <TD CLASS=\"rtrsp_strat_detais_head\">MIN просадка</TD>
              <TD CLASS=\"rtrsp_strat_detais_head\">MIN SL просадка</TD>
              <TD CLASS=\"rtrsp_strat_detais_head\">MAX рост</TD>
              <TD CLASS=\"rtrsp_strat_detais_head\">Динамика&nbsp;прибыли<BR>в&nbsp;период&nbsp;сделки</TD></TR>" ;
   my $count_rows_details = 0 ;
   while (($contract_in_tp, $contract_in_price, $contract_out_tp, $contract_out_price, $vector, $profit, $protected_profit, $cn_period, $min_prct, $prtct_min_prct, $max_prct ) = $sth_h_detail->fetchrow_array() ) {
#         $change_ts =~ s/\s/&nbsp;/g ;
#         $price_close =~ s/(.*[^0])(0+)$/$1/g ;
#         $next_timestamp =~ s/\s/&nbsp;/g ; $next_price_close =~ s/(.*[^0])(0+)$/$1/g ; $diff_price =~ s/(.*[^0])(0+)$/$1/g ;
#         $next_timestamp_shift =~ s/\s/&nbsp;/g ; $next_price_close_shift =~ s/(.*[^0])(0+)$/$1/g ; $diff_price_shift =~ s/(.*[^0])(0+)$/$1/g ;
   $count_rows_details++ ;
   $contract_in_price =~ s/0+$// ; $contract_out_price =~ s/0+$// ;
   $contract_in_tp_flat = $contract_in_tp ; $contract_in_tp_flat =~ s/[\s-_:]+//g ; $contract_out_tp_flat = $contract_out_tp ; $contract_out_tp_flat =~ s/[\s-_:]+//g ;
   my $vector_color = "" ;
   if ( $vector eq "short" ) { $vector_color = "red" ; $profit_mult = -1 ; } if ( $vector eq "long" ) { $vector_color = "green" ; $profit_mult = 1 ; }
   if ( $profit <= 0 ) { $profit_color = "red" ; } else { $profit_color = "green" ; } if ( $protected_profit <= 0 ) { $protected_profit_color = "red" ; } else { $protected_profit_color = "green" ; }
   print "<TR><TD ROWSPAN=\"2\" STYLE=\"color: $vector_color; border-color: $vector_color;\" CLASS=\"rtrsp_strat_detais_right\">$count_rows_details</TD>
              <TD STYLE=\"color: $vector_color; border-color: $vector_color;\" CLASS=\"rtrsp_strat_detais_left\">$contract_in_tp</TD>
              <TD STYLE=\"color: $vector_color; border-color: $vector_color;\" CLASS=\"rtrsp_strat_detais_right\">$contract_in_price</TD>
              <TD STYLE=\"color: $vector_color; border-color: $vector_color;\" CLASS=\"rtrsp_strat_detais_left\">$contract_out_tp</TD>
              <TD STYLE=\"color: $vector_color; border-color: $vector_color;\" CLASS=\"rtrsp_strat_detais_right\">$contract_out_price</TD>
              <TD STYLE=\"color: $vector_color; border-color: $vector_color;\" CLASS=\"rtrsp_strat_detais_center\">$vector</TD>
              <TD STYLE=\"color: $vector_color; border-color: $vector_color;\" CLASS=\"rtrsp_strat_detais_right\"><SPAN STYLE=\"font-size: 12pt; color: $profit_color ;\">$profit</SPAN></TD>
              <TD STYLE=\"color: $vector_color; border-color: $vector_color;\" CLASS=\"rtrsp_strat_detais_right\"><SPAN STYLE=\"font-size: 12pt; color: $protected_profit_color ;\">$protected_profit</SPAN></TD>
              <TD STYLE=\"color: $vector_color; border-color: $vector_color;\" CLASS=\"rtrsp_strat_detais_right\">$cn_period</TD>
              <TD STYLE=\"color: $vector_color; border-color: $vector_color;\" CLASS=\"rtrsp_strat_detais_right\">$min_prct</TD>
              <TD STYLE=\"color: $vector_color; border-color: $vector_color;\" CLASS=\"rtrsp_strat_detais_right\">$prtct_min_prct</TD>
              <TD STYLE=\"color: $vector_color; border-color: $vector_color;\" CLASS=\"rtrsp_strat_detais_right\">$max_prct</TD>
              <TD STYLE=\"color: $vector_color; border-color: $vector_color;\" CLASS=\"rtrsp_strat_detais_center\" ROWSPAN=\"2\">" ;

   $v_rand = rand() ; $v_rand =~ s/\.//g;
   print "\n<DIV ID=\"id_trading_block_$pv{currency}"."_$pv{reference_currency}"."_$v_rand\">" ;
   print_coin_graphs_block("id_trading_block_$pv{currency}"."_$pv{reference_currency}"."_$v_rand","$pv{currency}","$pv{reference_currency}","1","$pv{tf_rsi}","10","0","2","1","$pv{tf_rsi}","1","$pv{tf_macd}","x1","1","$pv{tf_rsi}","0","$pv{vlt_tf}","0","$pv{tf_rsi}","half","no_disabled","per_tsp","$contract_in_tp","$contract_out_tp") ;
   print "</DIV>\n" ;

   print "</TD></TR><TR>
              <TD COLSPAN=\"11\" STYLE=\"color: $vector_color; border-color: $vector_color; vertical-align: top;\" STYLE=\"border-color: $vector_color;\" CLASS=\"rtrsp_strat_detais_right\">
                  Динамика прибыли от точки входа до точки выхода с припусками<BR>
                  по ценам закрытия, максимальной и минимальной<BR>
                  <A HREF=\"cgi/_graph_profit.cgi?currency=$pv{currency}&curr_reference=$pv{reference_currency}&start_date=$contract_in_tp_flat&stop_date=$contract_out_tp_flat&start_price=$contract_in_price&profit_mult=$profit_mult&output_type=graph&brush_size=4&x_size=1120&y_size=480&src=1H\" TARGET=\"_blank\">
                     <IMG CLASS=\"cnt_pre_result_graph\" SRC=\"cgi/_graph_profit.cgi?currency=$pv{currency}&curr_reference=$pv{reference_currency}&start_date=$contract_in_tp_flat&stop_date=$contract_out_tp_flat&start_price=$contract_in_price&profit_mult=$profit_mult&output_type=graph&brush_size=4&x_size=1120&y_size=480&src=1H\"></A>


                 </TD></TR>" ;
         }
   $sth_h_detail->finish() ;
   $dbh_h_detail->disconnect() ;
   print "</TABLE>" ;
#                  <BR>выявленные события в диапазоне сделки с припусками<BR>
   }

print "</TD></TR>\n\n" ;
print "<TR><TD COLSPAN=\"2\">&nbsp;</TD></TR>\n\n" ;

print "<!-- конец таблицы второго уровня вкладок --></TABLE>\n" ;
print "<!-- конец таблицы первого уровня вкладок --></TD></TR></TABLE>\n" ;

print_foother1() ;
