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

print_main_page_title("Отчёты и аналитика", "$pv{currency}</SPAN> портрет монеты") ;
print_tools_coin_navigation(6) ;
print "<!-- таблица первого уровня вкладок -->
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD><BR>" ;

print_reports_coin_navigation(2,"tools_coin_common_info.cgi","$pv{currency}</SPAN> портрет монеты") ;
print "<!-- таблица второго уровня вкладок -->
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD>&nbsp;<BR>" ;

print_coin_links_map("tools_coin_common_info.cgi") ;

print "<BR>" ;

system("cat $cragran_dir_desc/desc_$pv{currency}".".shtml") ;

print "<!-- конец таблицы второго уровня вкладок --></TABLE>\n" ;
print "<!-- конец таблицы первого уровня вкладок --></TD></TR></TABLE>\n" ;

print_foother1() ;
