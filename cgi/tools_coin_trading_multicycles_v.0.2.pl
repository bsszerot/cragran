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

print "Content-Type: text/html\n\n" ;

system("cat $COMM_PAR_BASE_WEB_PATH/includes/header1_1_cgi.shtml") ;
print "TRD $pv{currency}/$pv{curr_reference} ZRT КрАгрАн БЕССТ" ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/header1_2_cgi.shtml") ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/main_menu.shtml") ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/header2_1_cgi.shtml") ;

#print_js_block_common() ;
#print_js_block_trading() ;

print_main_page_title("Оперативные инструменты: Трэйдинговая аналитика. Мультициклы ", "$pv{currency}/$pv{curr_reference}") ;

print_tools_coin_navigation(2) ;
print "<!-- таблица первого уровня вкладок -->
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD><BR>" ;
print_tools_trading_navigation(3) ;
print "<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD COLSPAN=\"2\">&nbsp;</TD></TR><TR><TD COLSPAN=\"2\">" ;

#print "<P STYLE=\"font-size: 8pt;\">Краткое описание формы:<BR>Форма трэйдинговой аналитики</P>" ;
print_coin_links_map("tools_coin_trading.cgi") ;

$pv{curr_count_prds} = recode_tf_periods("1D", "1H",  $pv{period_days}) ;

   my $v_rand = rand() ; $v_rand =~ s/\.//g;
   print "<DIV ID=\"id_trading_block_$pv{currency}"."_$pv{curr_reference}"."_$v_rand\">" ;
   print_coin_multicycles_graphs_block("id_trading_block_$pv{currency}"."_$pv{curr_reference}"."_$v_rand","$pv{currency}","$pv{curr_reference}","$pv{curr_time_frame}","$pv{curr_count_prds}","$pv{curr_env_prct}","$pv{curr_ema_mode}","$pv{curr_macd_mode}","$pv{curr_macd_tf}","$pv{curr_macd_mult}","$pv{curr_rsi_mode}","$pv{curr_rsi_tf}","$pv{curr_vlt_mode}","$pv{curr_vlt_tf}","1","$pv{curr_time_frame}","full","show") ;
   print "</DIV>" ;

   print "</TD></TR>\n\n" ;

# отобразить форму списка всех монет
print "</TABLE>" ;

print "<BR><HR><TABLE><TR><TD STYLE=\"vertical-align: top;\">" ;
system("cat $cragran_dir_desc/desc_$pv{currency}".".shtml") ;

print "<!-- конец таблицы второго уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы первого уровня вкладок --></TD></TR></TABLE>\n" ;
print_foother1() ;
