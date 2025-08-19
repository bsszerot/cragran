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
if ($pv{currency} eq "") { $pv{currency} = 'BTC' ; }

$CURR_YEAR = `date +%Y` ; $CURR_YEAR =~ s/[\r\n]+//g ;
$count_rows = 0 ;
$window_days = 0 ; $window_days = $pv{window_days} - 1 ;
$request = " " ;

if ( $curr_ref_coin eq "USDT") { $curr_ref_coin_gecko = "USD" ; }
my $half_min_week_volatility = 5 ;

# если параметры не указаны - выставить по умолчанию
$pv{time_frame} = ( $pv{time_frame} ne "" ) ? $pv{time_frame} : "1H" ; $pv{count_prds} = ( $pv{count_prds} ne "" ) ? $pv{count_prds} : 720 ; $pv{env_prct} = ( $pv{env_prct} ne "" ) ? $pv{env_prct} : 5 ;
$pv{ema_mode} = ( $pv{ema_mode} ne "" ) ? $pv{ema_mode} : 1 ; $pv{macd_mode} = ( $pv{macd_mode} ne "" ) ? $pv{macd_mode} : 1 ; $pv{macd_tf} = ( $pv{macd_tf} ne "" ) ? $pv{macd_tf} : "4H" ;
$pv{macd_mult} = ( $pv{macd_mult} ne "" ) ? $pv{macd_mult} : "x1" ; $pv{rsi_mode} = ( $pv{rsi_mode} ne "" ) ? $pv{rsi_mode} : 1 ; $pv{rsi_tf} = ( $pv{rsi_tf} ne "" ) ? $pv{rsi_tf} : "1H" ;
$pv{vlt_mode} = ( $pv{vlt_mode} ne "" ) ? $pv{vlt_mode} : 1 ; $pv{vlt_tf} = ( $pv{vlt_tf} ne "" ) ? $pv{vlt_tf} : "1H" ;

# для аналитики дневного цикла явно выставить переменные
if ($pv{time_frame} eq "SWING_DAY") {
   $pv{curr_time_frame} = "10M" ; $pv{curr_count_prds} = 960 ; $pv{curr_env_prct} = 2 ; $pv{curr_ema_mode} = 1 ; $pv{curr_macd_mode} = 1 ; $pv{curr_macd_tf} = "30M" ; $pv{curr_macd_mult} = "x1" ;
   $pv{curr_rsi_mode} = 1 ; $pv{curr_rsi_tf} = "10M" ; $pv{curr_vlt_mode} = 1 ; $pv{curr_vlt_tf} = "10M" ;
   $pv{prnt_time_frame} = "1H" ; $pv{prnt_count_prds} = 300 ; $pv{prnt_env_prct} = 5 ; $pv{prnt_ema_mode} = 1 ; $pv{prnt_macd_mode} = 1 ; $pv{prnt_macd_tf} = "4H" ; $pv{prnt_macd_mult} = "x1" ;
   $pv{prnt_rsi_mode} = 1 ; $pv{prnt_rsi_tf} = $pv{prnt_time_frame}  ; $pv{prnt_vlt_mode} = 0 ; $pv{prnt_vlt_tf} = $pv{prnt_time_frame}  ;
   $pv{grand_time_frame} = "1D" ; $pv{grand_count_prds} = 180 ; $pv{grand_env_prct} = 30 ; $pv{grand_ema_mode} = 1 ; $pv{grand_macd_mode} = 1 ; $pv{grand_macd_tf} = "4D" ; $pv{grand_macd_mult} = "x1" ;
   $pv{grand_rsi_mode} = 1 ; $pv{grand_rsi_tf} = $pv{grand_time_frame}  ; $pv{grand_vlt_mode} = 0 ; $pv{grand_vlt_tf} = $pv{grand_time_frame}  ;
   $current_cycle_label = "дневной" ; $parent_cycle_label = "недельный" ;
   }

# для аналитики недельного цикла явно выставить переменные
if ($pv{time_frame} eq "SWING_WEEK") {
   $pv{curr_time_frame} = "1H" ; $pv{curr_count_prds} = 720 ; $pv{curr_env_prct} = 5 ; $pv{curr_ema_mode} = 1 ; $pv{curr_macd_mode} = 1 ; $pv{curr_macd_tf} = "4H" ; $pv{curr_macd_mult} = "x1" ;
   $pv{curr_rsi_mode} = 1 ; $pv{curr_rsi_tf} = "1H" ; $pv{curr_vlt_mode} = 1 ; $pv{curr_vlt_tf} = "1H" ;
   $pv{prnt_time_frame} = "1D" ; $pv{prnt_count_prds} = 180 ; $pv{prnt_env_prct} = 30 ; $pv{prnt_ema_mode} = 1 ; $pv{prnt_macd_mode} = 1 ; $pv{prnt_macd_tf} = "4D" ; $pv{prnt_macd_mult} = "x1" ;
   $pv{prnt_rsi_mode} = 1 ; $pv{prnt_rsi_tf} = $pv{prnt_time_frame}  ; $pv{prnt_vlt_mode} = 0 ; $pv{prnt_vlt_tf} = $pv{prnt_time_frame} ;
   $pv{grand_time_frame} = "1W" ; $pv{grand_count_prds} = 100 ; $pv{grand_env_prct} = 30 ; $pv{grand_ema_mode} = 1 ; $pv{grand_macd_mode} = 1 ; $pv{grand_macd_tf} = "4W" ; $pv{grand_macd_mult} = "x1" ;
   $pv{grand_rsi_mode} = 1 ; $pv{grand_rsi_tf} = $pv{grand_time_frame}  ; $pv{grand_vlt_mode} = 0 ; $pv{grand_vlt_tf} = $pv{grand_time_frame}  ;
   $current_cycle_label = "недельный" ; $parent_cycle_label = "месячный" ;
   }

# для аналитики явно указанного ТФ цикла явно выставить переменные
if ($pv{time_frame} ne "SWING_WEEK" && $pv{time_frame} ne "SWING_DAY") {
# выставить параметры текущего цикла
   $pv{curr_time_frame} = $pv{time_frame} ; $pv{curr_count_prds} = $pv{count_prds} ; $pv{curr_env_prct} = $pv{env_prct} ; $pv{curr_ema_mode} = $pv{ema_mode} ; $pv{curr_macd_mode} = $pv{macd_mode} ; $pv{curr_macd_tf} = $pv{macd_tf} ; $pv{curr_macd_mult} = $pv{macd_mult} ;
   $pv{curr_rsi_mode} = $pv{rsi_mode} ; $pv{curr_rsi_tf} = $pv{rsi_tf} ; $pv{curr_vlt_mode} = $pv{vlt_mode} ; $pv{curr_vlt_tf} = $pv{vlt_tf} ;
# выставить параметры старшего цикла
   if ( $pv{time_frame} eq "1M" || $pv{time_frame} eq "3M" || $pv{time_frame} eq "5M" ) {
      $pv{prnt_time_frame} = "10M" ; $pv{prnt_count_prds} = 960 ; $pv{prnt_env_prct} = 2 ; $pv{prnt_ema_mode} = 1 ; $pv{prnt_macd_mode} = 1 ; $pv{prnt_macd_tf} = "30M" ; $pv{prnt_macd_mult} = "x1" ; $pv{prnt_rsi_mode} = 1 ; $pv{prnt_rsi_tf} = $pv{prnt_time_frame}  ; $pv{prnt_vlt_mode} = 0 ; $pv{prnt_vlt_tf} = $pv{prnt_time_frame} ;
      $pv{grand_time_frame} = "10M" ; $pv{grand_count_prds} = 960 ; $pv{grand_env_prct} = 2 ; $pv{grand_ema_mode} = 1 ; $pv{grand_macd_mode} = 1 ; $pv{grand_macd_tf} = "30M" ; $pv{grand_macd_mult} = "x1" ; $pv{grand_rsi_mode} = 1 ; $pv{grand_rsi_tf} = $pv{grand_time_frame}  ; $pv{grand_vlt_mode} = 0 ; $pv{grand_vlt_tf} = $pv{grand_time_frame} ;
      }
   if ( $pv{time_frame} eq "10M" || $pv{time_frame} eq "15M" || $pv{time_frame} eq "30M" ) {
      $pv{prnt_time_frame} = "1H" ; $pv{prnt_count_prds} = 300 ; $pv{prnt_env_prct} = 5 ; $pv{prnt_ema_mode} = 1 ; $pv{prnt_macd_mode} = 1 ; $pv{prnt_macd_tf} = "4H" ; $pv{prnt_macd_mult} = "x1" ; $pv{prnt_rsi_mode} = 1 ; $pv{prnt_rsi_tf} = $pv{prnt_time_frame}  ; $pv{prnt_vlt_mode} = 0 ; $pv{prnt_vlt_tf} = $pv{prnt_time_frame}  ;
      $pv{grand_time_frame} = "1D" ; $pv{grand_count_prds} = 180 ; $pv{grand_env_prct} = 30 ; $pv{grand_ema_mode} = 1 ; $pv{grand_macd_mode} = 1 ; $pv{grand_macd_tf} = "4D" ; $pv{grand_macd_mult} = "x1" ; $pv{grand_rsi_mode} = 1 ; $pv{grand_rsi_tf} = $pv{grand_time_frame}  ; $pv{grand_vlt_mode} = 0 ; $pv{grand_vlt_tf} = $pv{grand_time_frame} ;
      }
   if ( $pv{time_frame} eq "1H" || $pv{time_frame} eq "2H" || $pv{time_frame} eq "3H" || $pv{time_frame} eq "4H" || $pv{time_frame} eq "8H" || $pv{time_frame} eq "12H" ) {
      $pv{prnt_time_frame} = "1D" ; $pv{prnt_count_prds} = 180 ; $pv{prnt_env_prct} = 30 ; $pv{prnt_ema_mode} = 1 ; $pv{prnt_macd_mode} = 1 ; $pv{prnt_macd_tf} = "4D" ; $pv{prnt_macd_mult} = "x1" ; $pv{prnt_rsi_mode} = 1 ; $pv{prnt_rsi_tf} = $pv{prnt_time_frame}  ; $pv{prnt_vlt_mode} = 0 ; $pv{prnt_vlt_tf} = $pv{prnt_time_frame} ;
      $pv{grand_time_frame} = "1W" ; $pv{grand_count_prds} = 25 ; $pv{grand_env_prct} = 30 ; $pv{grand_ema_mode} = 1 ; $pv{grand_macd_mode} = 1 ; $pv{grand_macd_tf} = "4W" ; $pv{grand_macd_mult} = "x1" ; $pv{grand_rsi_mode} = 1 ; $pv{grand_rsi_tf} = $pv{grand_time_frame}  ; $pv{grand_vlt_mode} = 0 ; $pv{grand_vlt_tf} = $pv{grand_time_frame} ;
      }
   if ( $pv{time_frame} eq "1D" || $pv{time_frame} eq "2D" || $pv{time_frame} eq "4D") {
      $pv{prnt_time_frame} = "1W" ; $pv{prnt_count_prds} = 25 ; $pv{prnt_env_prct} = 30 ; $pv{prnt_ema_mode} = 1 ; $pv{prnt_macd_mode} = 1 ; $pv{prnt_macd_tf} = "4W" ; $pv{prnt_macd_mult} = "x1" ; $pv{prnt_rsi_mode} = 1 ; $pv{prnt_rsi_tf} = $pv{prnt_time_frame}  ; $pv{prnt_vlt_mode} = 0 ; $pv{prnt_vlt_tf} = $pv{prnt_time_frame} ;
      $pv{grand_time_frame} = "4W" ; $pv{grand_count_prds} = 25 ; $pv{grand_env_prct} = 30 ; $pv{grand_ema_mode} = 1 ; $pv{grand_macd_mode} = 1 ; $pv{grand_macd_tf} = "4W" ; $pv{grand_macd_mult} = "x1" ; $pv{grand_rsi_mode} = 1 ; $pv{grand_rsi_tf} = $pv{grand_time_frame}  ; $pv{grand_vlt_mode} = 0 ; $pv{grand_vlt_tf} = $pv{grand_time_frame} ;
      }
   if ( $pv{time_frame} eq "1W" || $pv{time_frame} eq "4W" ) {
      $pv{prnt_time_frame} = "4W" ; $pv{prnt_count_prds} = 25 ; $pv{prnt_env_prct} = 30 ; $pv{prnt_ema_mode} = 1 ; $pv{prnt_macd_mode} = 1 ; $pv{prnt_macd_tf} = "4W" ; $pv{prnt_macd_mult} = "x1" ; $pv{prnt_rsi_mode} = 1 ; $pv{prnt_rsi_tf} = $pv{prnt_time_frame}  ; $pv{prnt_vlt_mode} = 0 ; $pv{prnt_vlt_tf} = $pv{prnt_time_frame} ;
      $pv{grand_time_frame} = "4W" ; $pv{grand_count_prds} = 25 ; $pv{grand_env_prct} = 30 ; $pv{grand_ema_mode} = 1 ; $pv{grand_macd_mode} = 1 ; $pv{grand_macd_tf} = "4W" ; $pv{grand_macd_mult} = "x1" ; $pv{grand_rsi_mode} = 1 ; $pv{grand_rsi_tf} = $pv{grand_time_frame}  ; $pv{grand_vlt_mode} = 0 ; $pv{grand_vlt_tf} = $pv{grand_time_frame} ;
      }
   $current_cycle_label = "---" ; $parent_cycle_label = "---" ;
   }

my $is_coin_list_format = "no" ;
if ($pv{currency} ne "ALL" && $pv{currency} ne "IN_TRADE" && $pv{currency} ne "IN_INVEST" && $pv{currency} ne "TOP_50" && $pv{currency} ne "INVST_01" && $pv{currency} ne "INVST_02" && $pv{currency} ne "INVST_03" && $pv{currency} ne "INVST_04") {
   $is_coin_list_format = "list_format_no" ; }
else { $is_coin_list_format = "list_format_yes" ; }

print "Content-Type: text/html\n\n" ;

system("cat $COMM_PAR_BASE_WEB_PATH/includes/header1_1_cgi.shtml") ;
print "TRD $pv{currency}/$pv{curr_reference} ZRT КрАгрАн БЕССТ" ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/header1_2_cgi.shtml") ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/main_menu.shtml") ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/header2_1_cgi.shtml") ;

print_js_block_common() ;
print_js_block_trading() ;

if ( $is_coin_list_format eq "list_format_no" ) {
   print_main_page_title("Оперативные инструменты: Трэйдинговая аналитика ", "$pv{currency}/$pv{curr_reference}") ;
   }
else {
   print_main_page_title("Оперативные инструменты: Трэйдинговая аналитика ", "$pv{currency}/$pv{curr_reference} [$pv{time_frame_ext}]") ;
   }

print_tools_coin_navigation(2) ;
print "<!-- таблица первого уровня вкладок -->
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD><BR>" ;
if ( $is_coin_list_format eq "list_format_no" ) { print_tools_trading_navigation(1) ; }
else { print_tools_trading_navigation(2) ; }
print "<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD COLSPAN=\"2\">&nbsp;</TD></TR><TR><TD COLSPAN=\"2\">" ;

#print "<P STYLE=\"font-size: 8pt;\">Краткое описание формы:<BR>Форма трэйдинговой аналитики</P>" ;
print_coin_links_map("tools_coin_trading.cgi") ;

if ( $is_coin_list_format eq "list_format_no" ) { }
################################################################
# это блок заголовка и выставления параметров для формы СПИСКА  монет
###############################################################
else {
#################################################################
# таймфрэйм и количество периодов - это отдельная группа, периоды в формах графиков обрабатываются именно таймфрэймовые явно
#################################################################
   if ( $pv{time_frame_ext} eq "1D" ) {
      $time_frame_label = "1D" ; $graph_days = 120 ; $graph_days_label = "120 дней" ; $count_prds = $graph_days ;
      $volatility_period = $graph_days ; $volatility_window = 45 ; $volatility_window_label = "45 дней" ;
# отдельные переменные для построения одиночных графиков
      $pv{time_frame} = $pv{time_frame_ext} ; $pv{count_prds_for_TF} = $graph_days ; }

# периоды - тики в часах (в таблице - ежечасные строки). ТФ1-12H отражают недельный цикл
   if ( $pv{time_frame_ext} eq "1H" || $pv{time_frame_ext} eq "2H" || $pv{time_frame_ext} eq "3H" || $pv{time_frame_ext} eq "4H" || $pv{time_frame_ext} eq "8H" || $pv{time_frame_ext} eq "12H" ) {
      $graph_days = 30 ; $graph_days_label = "30 дней" ; $count_prds = $graph_days * 24 ;
      $volatility_period = $graph_days * 24 ; $volatility_window = 5 * 24 ; $volatility_window_label = "5 дней" ;
# отдельные переменные для построения одиночных графиков
      if ( $pv{time_frame_ext} eq "4H" ) { $time_frame_label = "4H" ; $pv{time_frame} = $pv{time_frame_ext} ; $pv{count_prds_for_TF} = $graph_days * 6 ; }
      if ( $pv{time_frame_ext} eq "3H" ) { $time_frame_label = "3H" ; $pv{time_frame} = $pv{time_frame_ext} ; $pv{count_prds_for_TF} = $graph_days * 8 ; }
      if ( $pv{time_frame_ext} eq "2H" ) { $time_frame_label = "2H" ; $pv{time_frame} = $pv{time_frame_ext} ; $pv{count_prds_for_TF} = $graph_days * 12 ; }
      if ( $pv{time_frame_ext} eq "1H" ) { $time_frame_label = "1H" ; $pv{time_frame} = $pv{time_frame_ext} ; $pv{count_prds_for_TF} = $graph_days * 24 ; }
      }

# периоды - тики в часах (в таблице - ежечасные строки), поэтому их немного. Здесь для убыстрения обработки берём часовые тики, т.к. ТФ30-10М отражают суточный цикл
   if ( $pv{time_frame_ext} eq "30Mh" || $pv{time_frame_ext} eq "15Mh" || $pv{time_frame_ext} eq "10Mh" ) {
      $graph_days = 10 ; $graph_days_label = "10 дней" ; $count_prds = $graph_days * 24 ;
      $volatility_period = $graph_days * 24 ; $volatility_window = 36 - 1 ; $volatility_window_label = "36 часов" ;
# отдельные переменные для построения одиночных графиков
      if ( $pv{time_frame_ext} eq "30Mh" ) { $time_frame_label = "30M" ; $pv{time_frame} = "30M" ; $pv{count_prds_for_TF} = $graph_days * 2 * 24 ; }
      if ( $pv{time_frame_ext} eq "15Mh" ) { $time_frame_label = "15M" ; $pv{time_frame} = "15M" ; $pv{count_prds_for_TF} = $graph_days * 4 * 24 ; }
      if ( $pv{time_frame_ext} eq "10Mh" ) { $time_frame_label = "10M" ; $pv{time_frame} = "10M" ; $pv{count_prds_for_TF} = $graph_days * 6 * 24 ; }
      }

# периоды - тики в минутах (в таблице - ежеминутные строки). Здесь берём минутные тики, но цикл обсчёта общий, т.к. изначально ТФ не выделяется. ТФ30-10М отражают суточный цикл
   if ( $pv{time_frame_ext} eq "30M" || $pv{time_frame_ext} eq "15M" || $pv{time_frame_ext} eq "10M" ) {
      $time_frame_label = "30M" ; $graph_days = 10 ; $graph_days_label = "10 дней" ; $count_prds = $graph_days * 24 * 60 ;
      $volatility_period = $graph_days * 24 * 60 ; $volatility_window = (36 * 60) - 1 ; $volatility_window_label = "36 часов" ;
# отдельные переменные для построения одиночных графиков
      if ( $pv{time_frame_ext} eq "30M" ) { $time_frame_label = "30M" ; $pv{time_frame} = "30М" ; $pv{count_prds_for_TF} = $graph_days * 2 * 24 ; }
      if ( $pv{time_frame_ext} eq "15M" ) { $time_frame_label = "15M" ; $pv{time_frame} = "15М" ; $pv{count_prds_for_TF} = $graph_days * 4 * 24 ; }
      if ( $pv{time_frame_ext} eq "10M" ) { $time_frame_label = "10M" ; $pv{time_frame} = "10М" ; $pv{count_prds_for_TF} = $graph_days * 6 * 24 ; }
      }

# периоды - тики в минутах (в таблице - ежеминутные строки). Здесь берём минутные тики, но цикл обсчёта общий, т.к. изначально ТФ не выделяется. ТФ5-1М отражают 8-часовой цикл
   if ( $pv{time_frame_ext} eq "5M" || $pv{time_frame_ext} eq "3M" || $pv{time_frame_ext} eq "1M" ) {
      $graph_days = 3 ; $graph_days_label = "3 дня" ; $count_prds = $graph_days * 60 * 24 ;
      $volatility_period = $graph_days * 60 * 24 ; $volatility_window = (60 * 5) - 1 ; $volatility_window_label = "5 часов" ;
# отдельные переменные для построения одиночных графиков
      if ( $pv{time_frame_ext} eq "5M" ) { $time_frame_label = "5M" ; $pv{time_frame} = "5M" ; $pv{count_prds_for_TF} = $graph_days * 12 * 24 ; }
      if ( $pv{time_frame_ext} eq "3M" ) { $time_frame_label = "3M" ; $pv{time_frame} = "3M" ; $pv{count_prds_for_TF} = $graph_days * 20 * 24 ; }
      if ( $pv{time_frame_ext} eq "1M" ) { $time_frame_label = "1M" ; $pv{time_frame} = "1M" ; $pv{count_prds_for_TF} = $graph_days * 60 * 24 ; }
      }

   print "ТФ:&nbsp;<A HREF=\"cgi/tools_coin_trading.cgi?window_days=7&period_days=120&sort_column=AVG_VOL&sort_type=DESC&time_frame_ext=1D\">1D</A>
              \n&nbsp;<A HREF=\"cgi/tools_coin_trading.cgi?window_days=7&period_days=25&sort_column=AVG_VOL&sort_type=DESC&time_frame_ext=4H&currency=$pv{currency}&curr_reference=$pv{curr_reference}&macd_mult=$pv{macd_mult}\">4H</A>
          \n&nbsp;<A HREF=\"cgi/tools_coin_trading.cgi?window_days=7&period_days=25&sort_column=AVG_VOL&sort_type=DESC&time_frame_ext=3H&currency=$pv{currency}&curr_reference=$pv{curr_reference}&macd_mult=$pv{macd_mult}\">3H</A>
          \n&nbsp;<A HREF=\"cgi/tools_coin_trading.cgi?window_days=7&period_days=25&sort_column=AVG_VOL&sort_type=DESC&time_frame_ext=2H&currency=$pv{currency}&curr_reference=$pv{curr_reference}&macd_mult=$pv{macd_mult}\">2H</A>
          \n&nbsp;<A HREF=\"cgi/tools_coin_trading.cgi?window_days=7&period_days=25&sort_column=AVG_VOL&sort_type=DESC&time_frame_ext=1H&currency=$pv{currency}&curr_reference=$pv{curr_reference}&macd_mult=$pv{macd_mult}\">1H</A>
          \n&nbsp;<A HREF=\"cgi/tools_coin_trading.cgi?window_days=7&period_days=7&sort_column=AVG_VOL&sort_type=DESC&time_frame_ext=30Mh&currency=$pv{currency}&curr_reference=$pv{curr_reference}&macd_mult=$pv{macd_mult}\">30M(h)</A>
          \n&nbsp;<A HREF=\"cgi/tools_coin_trading.cgi?window_days=7&period_days=7&sort_column=AVG_VOL&sort_type=DESC&time_frame_ext=30M&&currency=$pv{currency}curr_reference=$pv{curr_reference}&macd_mult=$pv{macd_mult}\">30M</A>
          \n&nbsp;<A HREF=\"cgi/tools_coin_trading.cgi?window_days=7&period_days=7&sort_column=AVG_VOL&sort_type=DESC&time_frame_ext=15Mh&currency=$pv{currency}&curr_reference=$pv{curr_reference}&macd_mult=$pv{macd_mult}\">15M(h)</A>
          \n&nbsp;<A HREF=\"cgi/tools_coin_trading.cgi?window_days=7&period_days=7&sort_column=AVG_VOL&sort_type=DESC&time_frame_ext=15M&&currency=$pv{currency}curr_reference=$pv{curr_reference}&macd_mult=$pv{macd_mult}\">15M</A>
          \n&nbsp;<A HREF=\"cgi/tools_coin_trading.cgi?window_days=7&period_days=7&sort_column=AVG_VOL&sort_type=DESC&time_frame_ext=10Mh&currency=$pv{currency}&curr_reference=$pv{curr_reference}&macd_mult=$pv{macd_mult}\">10M(h)</A>
          \n&nbsp;<A HREF=\"cgi/tools_coin_trading.cgi?window_days=7&period_days=7&sort_column=AVG_VOL&sort_type=DESC&time_frame_ext=10M&&currency=$pv{currency}curr_reference=$pv{curr_reference}&macd_mult=$pv{macd_mult}\">10M</A>
          \n&nbsp;<A HREF=\"cgi/tools_coin_trading.cgi?window_days=7&period_days=7&sort_column=AVG_VOL&sort_type=DESC&time_frame_ext=5M&c&currency=$pv{currency}urr_reference=$pv{curr_reference}&macd_mult=$pv{macd_mult}\">5M</A>
          \n&nbsp;<A HREF=\"cgi/tools_coin_trading.cgi?window_days=7&period_days=7&sort_column=AVG_VOL&sort_type=DESC&time_frame_ext=3M&c&currency=$pv{currency}urr_reference=$pv{curr_reference}&macd_mult=$pv{macd_mult}\">3M</A>
          \n&nbsp;<A HREF=\"cgi/tools_coin_trading.cgi?window_days=7&period_days=7&sort_column=AVG_VOL&sort_type=DESC&time_frame_ext=1M&c&currency=$pv{currency}urr_reference=$pv{curr_reference}&macd_mult=$pv{macd_mult}\">1M</A>
          \n&nbsp;&nbsp; MACD:&nbsp;" ;
   if ( $pv{macd_mult} eq "x1" ) { print "<A HREF=\"cgi/tools_coin_trading.cgi?window_days=7&period_days=7&sort_column=AVG_VOL&sort_type=DESC&time_frame_ext=$pv{time_frame_ext}&currency=$pv{currency}&curr_reference=$pv{curr_reference}&macd_mult=x2\">x1</A>&nbsp;&nbsp;&nbsp;" ; }
   else { print "<A HREF=\"cgi/tools_coin_trading.cgi?window_days=7&period_days=7&sort_column=AVG_VOL&sort_type=DESC&time_frame_ext=$pv{time_frame_ext}&currency=$pv{currency}&curr_reference=$pv{curr_reference}&macd_mult=x1\">x2</A>&nbsp;&nbsp;&nbsp;" ; }

   print "Период: $graph_days_label, окно $volatility_window_label, ENV 1/2 VLT</H1><BR>&nbsp;" ;
   }

# отобразить форму одной монеты
if ( $is_coin_list_format eq "list_format_no" ) {
   print "<TR><TD COLSPAN=\"3\" STYLE=\"text-align: right;\">Выбрать цикл:
          &nbsp;<A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_trading.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}&time_frame=SWING_WEEK&macd_mult=$pv{macd_mult}\">SWING_недельный</A>
          &nbsp;<A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_trading.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}&time_frame=SWING_DAY&macd_mult=$pv{macd_mult}\">DAY_дневной</A>
          </TD></TR>" ;

#   print "<TR><TD STYLE=\"vertical-align: top;\">" ;

   print "\n\n<TR><TD COLSPAN=\"2\" STYLE=\"vertical-align: top; width: 66%; text-align: left;\"><HR>Текущий цикл $current_cycle_label [точка входа, SL]<BR>$pv{currency}/$pv{curr_reference}<BR><HR>" ;
   my $v_rand = rand() ; $v_rand =~ s/\.//g;
   print "<DIV ID=\"id_trading_block_$pv{currency}"."_$pv{curr_reference}"."_$v_rand\">" ;
   print_coin_graphs_block("id_trading_block_$pv{currency}"."_$pv{curr_reference}"."_$v_rand","$pv{currency}","$pv{curr_reference}","1","$pv{curr_time_frame}","$pv{curr_count_prds}","$pv{curr_offset_prds}","$pv{curr_env_prct}","$pv{curr_ema_mode}","$pv{curr_time_frame}","$pv{curr_macd_mode}","$pv{curr_macd_tf}","$pv{curr_macd_mult}","$pv{curr_rsi_mode}","$pv{curr_rsi_tf}","$pv{curr_vlt_mode}","$pv{curr_vlt_tf}","1","$pv{curr_time_frame}","full","show","per_count","","") ;
   print "</DIV>" ;

   print "</TD><TD STYLE=\"vertical-align: top; width: 33%; text-align: right;\"><HR>Родительский $parent_cycle_label [вектор трэнда, TP] и дедов циклы<BR>$pv{currency}/$pv{curr_reference} SWING-среднесрок (ТФ1H, 25 дн, конверт 5%)<BR><HR>" ;
   $v_rand = rand() ; $v_rand =~ s/\.//g;
   print "<DIV ID=\"id_trading_block_$pv{currency}"."_$pv{curr_reference}"."_$v_rand\">" ;
   print_coin_graphs_block("id_trading_block_$pv{currency}"."_$pv{curr_reference}"."_$v_rand","$pv{currency}","$pv{curr_reference}","1","$pv{prnt_time_frame}","$pv{prnt_count_prds}","$pv{prnt_offset_prds}","$pv{prnt_env_prct}","$pv{prnt_ema_mode}","$pv{prnt_time_frame}","$pv{prnt_macd_mode}","$pv{prnt_macd_tf}","$pv{prnt_macd_mult}","$pv{prnt_rsi_mode}","$pv{prnt_rsi_tf}","$pv{prnt_vlt_mode}","$pv{prnt_vlt_tf}","0","$pv{prnt_time_frame}","half","show","per_count","","") ;
   print "</DIV>" ;

   $v_rand = rand() ; $v_rand =~ s/\.//g;
   print "<DIV ID=\"id_trading_block_$pv{currency}"."_$pv{curr_reference}"."_$v_rand\">" ;
   print_coin_graphs_block("id_trading_block_$pv{currency}"."_$pv{curr_reference}"."_$v_rand","$pv{currency}","$pv{curr_reference}","1","$pv{grand_time_frame}","$pv{grand_count_prds}","$pv{grand_offset_prds}","$pv{grand_env_prct}","$pv{grand_ema_mode}","$pv{grand_time_frame}","$pv{grand_macd_mode}","$pv{grand_macd_tf}","$pv{grand_macd_mult}","$pv{grand_rsi_mode}","$pv{grand_rsi_tf}","$pv{grand_vlt_mode}","$pv{grand_vlt_tf}","0","$pv{grand_time_frame}","half","show","per_count","","") ;
   print "</DIV>" ;

   print "</TD></TR>\n\n" ;
   }
# отобразить форму списка всех монет
else {
   my $request = " " ;
   my $current_coin_list = $trade_all_vol_coin_list ;
   if ($pv{currency} eq "TOP_100") { $current_coin_list = $trade_top_50_coin_list ; }
   if ($pv{currency} eq "TOP_50") { $current_coin_list = $trade_top_50_coin_list ; }
# здесь ALL с любым префиксом - это все монеты
   if ($pv{currency} eq "ALL") { $current_coin_list = $trade_all_vol_coin_list ; } 
   if ($pv{currency} eq "IN_TRADE") { $current_coin_list = $in_trade_coin_list ; }
   if ($pv{currency} eq "IN_INVEST") { $current_coin_list = $in_invest_coin_list ; }
   if ($pv{currency} eq "INVST_01") { $current_coin_list = $invest_01_coin_list ; }
   if ($pv{currency} eq "INVST_02") { $current_coin_list = $invest_02_coin_list ; }
   if ($pv{currency} eq "INVST_03") { $current_coin_list = $invest_03_coin_list ; }
   if ($pv{currency} eq "INVST_04") { $current_coin_list = $invest_04_coin_list ; }

# если референсная монета не указана - выбираем обе
   if ($pv{curr_reference} eq "") { $pv{curr_reference} = "USDT','BTC" ; }
   $reflist = "'$pv{curr_reference}'" ;

# это SWING среднесрок - т.е. период около полутора месяцев (45 дней). Поэтому для разгрузки можно брать данные дневной таблицы
   if ( $pv{time_frame_ext} eq "1D" ) {
      $request = "select week_vol.currency, week_vol.reference_currency, min(week_vol.WEEK_VOL) MIN_VOL, round(AVG(week_vol.WEEK_VOL),2) AVG_VOL, MAX(week_vol.WEEK_VOL) MAX_VOL
          from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.day_date, round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WEEK_VOL
                       from (select currency, reference_currency, day_date,
                                    min(price_min) OVER (PARTITION BY currency, reference_currency ORDER BY day_date ASC ROWS BETWEEN $volatility_window PRECEDING AND CURRENT ROW) as MIN_PRICE,
                                    max(price_max) OVER (PARTITION BY currency, reference_currency ORDER BY day_date ASC ROWS BETWEEN $volatility_window PRECEDING AND CURRENT ROW) as MAX_PRICE
                                    from curr_pair_history
                                    where day_date > CURRENT_DATE - INTERVAL '$volatility_period day'
                                          AND currency in ($current_coin_list)
                                          AND reference_currency in ($reflist)
                                          AND NOT price_min = 0 AND price_min IS NOT NULL
                                    order by day_date ) ds_win1
                       order by ds_win1.day_date ) as week_vol
          group by week_vol.currency, week_vol.reference_currency
          order by $pv{sort_column} $pv{sort_type}" ;
          }

# это SWING краткосрок и INTRADAT - т.е. период до 5-7 дней или до 2 в среднем. Поэтому для разгрузки можно брать данные часовой таблицы
   if ( $pv{time_frame_ext} eq "4H" || $pv{time_frame_ext} eq "3H" ||$pv{time_frame_ext} eq "2H" || $pv{time_frame_ext} eq "1H" || $pv{time_frame_ext} eq "30Mh" || $pv{time_frame_ext} eq "15Mh" || $pv{time_frame_ext} eq "10Mh" ) {
# окно 140 периодов (24 часа * 5 дней), глубина анализа 60 дней
   $request = "select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
                      MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL
          from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point, round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL
                       from (select currency, reference_currency, timestamp_point,
                                    min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN $volatility_window PRECEDING AND CURRENT ROW) as MIN_PRICE,
                                    max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN $volatility_window PRECEDING AND CURRENT ROW) as MAX_PRICE
                                    from crcomp_pair_OHLC_1H_history
                                    where timestamp_point > CURRENT_DATE - INTERVAL '$volatility_period hours'
                                          AND currency in ($current_coin_list)
                                          AND reference_currency in ($reflist)
                                          AND NOT price_low = 0 AND price_low IS NOT NULL
                                    order by timestamp_point ) ds_win1
                       order by ds_win1.timestamp_point ) as window_vol
          group by window_vol.currency, window_vol.reference_currency
          order by $pv{sort_column} $pv{sort_type}" ;
          }

# это INTRADAY - т.е. период сутки - полтора. Поэтому для разгрузки можно брать данные часовой таблицы
   if ( $pv{time_frame_ext} eq "30M" || $pv{time_frame_ext} eq "15M" || $pv{time_frame_ext} eq "10M" || $pv{time_frame_ext} eq "5M" || $pv{time_frame_ext} eq "3M" || $pv{time_frame_ext} eq "1M" ) {
   $request = "select window_vol.currency, window_vol.reference_currency, min(window_vol.WINDOW_PERCENT_VOL) MIN_VOL, round(AVG(window_vol.WINDOW_PERCENT_VOL),2) AVG_VOL,
                      MAX(window_vol.WINDOW_PERCENT_VOL) MAX_VOL
          from (select ds_win1.currency, ds_win1.reference_currency, ds_win1.timestamp_point, round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WINDOW_PERCENT_VOL
                       from (select currency, reference_currency, timestamp_point,
                                    min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN $volatility_window PRECEDING AND CURRENT ROW) as MIN_PRICE,
                                    max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN $volatility_window PRECEDING AND CURRENT ROW) as MAX_PRICE
                                    from crcomp_pair_OHLC_1M_history
                                    where timestamp_point > CURRENT_DATE - INTERVAL '$volatility_period minutes'
                                          AND currency in ($current_coin_list)
                                          AND reference_currency in ($reflist)
                                          AND NOT price_low = 0 AND price_low IS NOT NULL
                                    order by timestamp_point ) ds_win1
                       order by ds_win1.timestamp_point ) as window_vol
          group by window_vol.currency, window_vol.reference_currency
          order by $pv{sort_column} $pv{sort_type}" ;
       }

   my $dbh_h = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'pg_password_value' ) ;
   my $sth_h = $dbh_h->prepare($request) ; $sth_h->execute(); $count_rows = 0 ;
   while (my ($coin, $curr_ref_coin, $min_week_vol, $avg_week_vol, $max_week_vol) = $sth_h->fetchrow_array() ) {
         if ( $curr_ref_coin eq "USDT") { $curr_ref_coin_gecko = "USD" ; }
         my $half_min_week_volatility = $avg_week_vol / 2 ;

         $pv{currency} = $coin ;
         $pv{curr_reference} = $curr_ref_coin ;
         $pv{env_prct} = $half_min_week_volatility ;

         if ( $pv{time_frame} eq "10M" || $pv{time_frame} eq "10Mh" || $pv{time_frame} eq "15M" || $pv{time_frame} eq "15Mh" || $pv{time_frame} eq "30M" ) {
# для аналитики дневного цикла явно выставить переменные
            $pv{count_prds} = 960 ; $pv{ema_mode} = 1 ; $pv{macd_mode} = 1 ; $pv{macd_tf} = "30M" ; $pv{macd_mult} = "x1" ; $pv{rsi_mode} = 1 ; $pv{rsi_tf} = "10M" ; $pv{vlt_mode} = 1 ; $pv{vlt_tf} = "10M" ;

            $pv{prnts_time_frame} = "1H" ; $pv{prnts_count_prds} = 720 ; $pv{prnts_ema_mode} = 1 ; $pv{prnts_env_prct} = 5 ;
            $pv{prnts_macd_mode} = 1 ; $pv{prnts_macd_tf} = "4H" ; $pv{prnts_macd_prds} = recode_tf_periods("$pv{prnts_time_frame}", "$pv{prnts_macd_tf}", $pv{prnts_count_prds}) ; $pv{prnts_macd_mult} = "x1" ;
            $pv{prnts_rsi_mode} = 1 ; $pv{prnts_rsi_tf} = "1H" ; $pv{prnts_rsi_prds} = recode_tf_periods("$pv{prnts_time_frame}", "$pv{prnts_rsi_tf}", $pv{prnts_count_prds}) ;
            $pv{prnts_vlt_mode} = 1 ; $pv{prnts_vlt_tf} = "1H" ; $pv{prnts_vlt_prds} = recode_tf_periods("$pv{prnts_time_frame}", "$pv{prnts_vlt_tf}", $pv{prnts_count_prds}) ;

            $pv{grand_time_frame} = "1D" ; $pv{grand_count_prds} = 720 ; $pv{grand_ema_mode} = 1 ; $pv{grand_env_prct} = 5 ;
            $pv{grand_macd_mode} = 1 ; $pv{grand_macd_tf} = "4D" ; $pv{grand_macd_prds} = recode_tf_periods("$pv{grand_time_frame}", "$pv{grand_macd_tf}", $pv{grand_count_prds}) ; $pv{grand_macd_mult} = "x1" ;
            $pv{grand_rsi_mode} = 1 ; $pv{grand_rsi_tf} = "1D" ; $pv{grand_rsi_prds} = recode_tf_periods("$pv{grand_time_frame}", "$pv{grand_rsi_tf}", $pv{grand_count_prds}) ;
            $pv{grand_vlt_mode} = 1 ; $pv{grand_vlt_tf} = "1D" ; $pv{grand_vlt_prds} = recode_tf_periods("$pv{grand_time_frame}", "$pv{grand_vlt_tf}", $pv{grand_count_prds}) ;
            }

         if ( $pv{time_frame} eq "1H" || $pv{time_frame} eq "2H" || $pv{time_frame} eq "3H" || $pv{time_frame} eq "4H" ) {
            $pv{count_prds} = 720 ; $pv{macd_mult} = "x1" ; $pv{ema_mode} = 1 ; $pv{macd_mode} = 1 ; $pv{macd_tf} = "4H" ; $pv{macd_mult} = "x1" ; $pv{rsi_mode} = 1 ; $pv{rsi_tf} = "1H" ; $pv{vlt_mode} = 1 ; $pv{vlt_tf} = "1H" ;

            $pv{prnts_time_frame} = "1D" ; $pv{prnts_count_prds} = 360 ; $pv{prnts_ema_mode} = 1 ; $pv{prnts_env_prct} = 30 ;
            $pv{prnts_macd_mode} = 1 ; $pv{prnts_macd_tf} = "4D" ; $pv{prnts_macd_prds} = recode_tf_periods("$pv{prnts_time_frame}", "$pv{prnts_macd_tf}", $pv{prnts_count_prds}) ; $pv{prnts_macd_mult} = "x1" ;
            $pv{prnts_rsi_mode} = 1 ; $pv{prnts_rsi_tf} = "1D" ; $pv{prnts_rsi_prds} = recode_tf_periods("$pv{prnts_time_frame}", "$pv{prnts_rsi_tf}", $pv{prnts_count_prds}) ;
            $pv{prnts_vlt_mode} = 1 ; $pv{prnts_vlt_tf} = "1D" ; $pv{prnts_vlt_prds} = recode_tf_periods("$pv{prnts_time_frame}", "$pv{prnts_vlt_tf}", $pv{prnts_count_prds}) ;

            $pv{grand_time_frame} = "1W" ; $pv{grand_count_prds} = 360 ; $pv{grand_ema_mode} = 1 ; $pv{grand_env_prct} = 30 ;
            $pv{grand_macd_mode} = 1 ; $pv{grand_macd_tf} = "4W" ; $pv{grand_macd_prds} = recode_tf_periods("$pv{grand_time_frame}", "$pv{grand_macd_tf}", $pv{grand_count_prds}) ; $pv{grand_macd_mult} = "x1" ;
            $pv{grand_rsi_mode} = 1 ; $pv{grand_rsi_tf} = "1W" ; $pv{grand_rsi_prds} = recode_tf_periods("$pv{grand_time_frame}", "$pv{grand_rsi_tf}", $pv{grand_count_prds}) ;
            $pv{grand_vlt_mode} = 1 ; $pv{grand_vlt_tf} = "1W" ; $pv{grand_vlt_prds} = recode_tf_periods("$pv{grand_time_frame}", "$pv{grand_vlt_tf}", $pv{grand_count_prds}) ;
            }

         print "<TR><TD COLSPAN=\"3\" STYLE=\"font-size: 10pt; color: white; background-color: navy;\">$coin / $curr_ref_coin [ТФ$pv{time_frame_ext}] [волатильность за $graph_days_label, окно $volatility_window_label]: min = $min_week_vol, avg = $avg_week_vol, max = $max_week_vol, конверт $half_min_week_volatility\%</TD></TR>
                <TR><TD STYLE=\"vertical-align: top; width: 33%;\">" ;

         print "\n\n<HR>Текущий цикл [точка входа, StopLoss.]<BR><HR>" ;
         $v_rand = rand() ; $v_rand =~ s/\.//g;
         print "\n<DIV ID=\"id_trading_block_$pv{currency}"."_$pv{curr_reference}"."_$v_rand\">" ;
         print_coin_graphs_block("id_trading_block_$pv{currency}"."_$pv{curr_reference}"."_$v_rand","$pv{currency}","$pv{curr_reference}","1","$pv{time_frame}","$pv{count_prds}","$pv{offset_prds}","$pv{env_prct}","$pv{ema_mode}","$pv{time_frame}","$pv{macd_mode}","$pv{macd_tf}","$pv{macd_mult}","$pv{rsi_mode}","$pv{rsi_tf}","0","$pv{vlt_tf}","0","$pv{time_frame}","half","no_disabled","per_count","","") ;
         print "</DIV>\n" ;
         print "</TD><TD STYLE=\"vertical-align: top; width: 33%; text-align: right;\"><HR>" ;

         print "Родительский цикл $parent_cycle_label вектор трэнда, TP]<BR><HR>" ;
         $v_rand = rand() ; $v_rand =~ s/\.//g;
         print "\n<DIV ID=\"id_trading_block_$pv{currency}"."_$pv{curr_reference}"."_$v_rand\">" ;
         print_coin_graphs_block("id_trading_block_$pv{currency}"."_$pv{curr_reference}"."_$v_rand","$pv{currency}","$pv{curr_reference}","1","$pv{prnts_time_frame}","$pv{prnts_count_prds}","$pv{prnts_offset_prds}","$pv{prnts_env_prct}","$pv{ema_mode}","$pv{prnts_time_frame}","$pv{macd_mode}","$pv{prnts_macd_tf}","$pv{macd_mult}","$pv{rsi_mode}","$pv{prnts_rsi_tf}","0","$pv{vlt_tf}","0","$pv{prnts_time_frame}","half","no_disabled","per_count","","") ;
         print "</DIV>\n" ;
         print "</TD><TD STYLE=\"vertical-align: top; width: 33%; text-align: right;\"><HR>" ;

         print "Дедов цикл [общая тенденция]<BR><HR>" ;
         $v_rand = rand() ; $v_rand =~ s/\.//g;
         print "\n<DIV ID=\"id_trading_block_BTC"."_$pv{curr_reference}"."_$v_rand\">" ;
         print_coin_graphs_block("id_trading_block_BTC"."_$pv{curr_reference}"."_$v_rand","$pv{currency}","$pv{curr_reference}","1","$pv{grand_time_frame}","$pv{grand_count_prds}","$pv{grand_offset_prds}","$pv{grand_env_prct}","$pv{ema_mode}","$pv{grand_time_frame}","$pv{macd_mode}","$pv{grand_macd_tf}","$pv{macd_mult}","$pv{rsi_mode}","$pv{grand_rsi_tf}","0","$pv{vlt_tf}","0","$pv{grand_time_frame}","half","no_disabled","per_count","","") ;
         print "</DIV>\n" ;

         print "</TD></TR>\n\n" ;
         $count_rows += 1 ; }

         $sth_h->finish() ;
         $dbh_h->disconnect() ;
         }
print "</TABLE>" ;

print "<BR><HR><TABLE><TR><TD STYLE=\"vertical-align: top;\">" ;
system("cat $cragran_dir_desc/desc_$pv{currency}".".shtml") ;

print "<!-- конец таблицы второго уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы первого уровня вкладок --></TD></TR></TABLE>\n" ;
print_foother1() ;
