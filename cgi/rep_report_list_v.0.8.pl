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

print_main_page_title("Отчёты и аналитика", "---") ;

print_tools_coin_navigation(7) ;

print "<!-- таблица первого уровня вкладок -->
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD><BR>" ;
print_reports_coin_navigation(1,"","") ;
print "<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD COLSPAN=\"2\">&nbsp;<BR>" ;

print_coin_links_map("tools_coin_common_info.cgi") ;

print "<TR><TD COLSPAN=\"2\">&nbsp;</TD></TR>\n\n" ;

print "<!-- <TR><TD><A HREF=\"cgi/rep_market_status.cgi\">Общее&nbsp;состояние&nbsp;Рынка</A>
           </TD><TD>Аналитическая форма общего состояния рынка</TD></TR>\n\n" ;

print "<TR><TD><A href=\"cgi/tools_coin_common_info.cgi?currency=BTC&curr_reference=USDT\">Портрет&nbsp;монеты</A>
           </TD><TD>Аналитическая форма с портретом монеты</TD></TR>\n\n-->" ;

print "<TR><TD><A HREF=\"cgi/rep_volatility_all_cycles_coins.cgi?sort_column=AVG_VOL&sort_type=DESC\">Волатильность&nbsp;монет</A>
           </TD><TD>Расчёт волатильности для разных циклов и разных окон рассчета волатильности по основным монетам</TD></TR>\n\n" ;

print "<TR><TD><A HREF=\"cgi/rep_one_coin_TF_compare.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}&rsi_mode=1&macd_mode=1\">Графики ТФ и Циклы</A>
           </TD><TD>Сравнение значимости графиков и индикаторов разных таймфрэймов для разных циклов волатильности</TD></TR>\n\n" ;
print "<TR><TD COLSPAN=\"2\">&nbsp;</TD></TR>\n\n" ;

print "<TR><TD><A HREF=\"cgi/rep_mon_analyze_macd_cross_cross.cgi?currency=BTC&curr_reference=$pv{curr_reference}\">MACD4H cross/cross</A>
           </TD><TD>Аналитика эффективности одноиндикаторной симметричной стратегии cross/cross MACD ТФ4H (пересечение линий графика как сигнал входа и выхода)</TD></TR>\n\n" ;

print "<TR><TD><A HREF=\"cgi/rep_mon_analyze_macd_vect_vect.cgi?currency=BTC&curr_reference=$pv{curr_reference}\">MACD4H vect/vect</A>
           </TD><TD>Аналитика эффективности одноиндикаторной симметричной стратегии vector/vector MACD ТФ4H (пересечение линий графика как сигнал входа и выхода)</TD></TR>\n\n" ;

print "<TR><TD>&nbsp;</TD></TR>\n\n" ;

print "<TR><TD><A HREF=\"cgi/rep_mon_analyze_symmetric.cgi?currency=BTC&curr_reference=$pv{curr_reference}&rep_mode=group&event_name=MACD_4H_LINE_CROSS&event_tf=4H\">REP MACD4H cross/cross</A>
           </TD><TD ROWSPAN=\"6\">Универсальный отчёт - аналитика эффективности одноиндикаторных стратегий с симметричным входом и выходом</TD></TR>\n\n" ;
print "<TR><TD><A HREF=\"cgi/rep_mon_analyze_symmetric.cgi?currency=BTC&curr_reference=$pv{curr_reference}&rep_mode=group&event_name=MACD_4H_LINE_VECTOR&event_tf=4H\">REP MACD4H vect/vect</A></TD></TR>\n\n" ;
print "<TR><TD><A HREF=\"cgi/rep_mon_analyze_symmetric.cgi?currency=BTC&curr_reference=$pv{curr_reference}&rep_mode=group&event_name=MACD_4H_GIST_VECTOR&event_tf=4H\">REP MACD4H gist/gist</A></TD></TR>\n\n" ;
print "<TR><TD><A HREF=\"cgi/rep_mon_analyze_symmetric.cgi?currency=BTC&curr_reference=$pv{curr_reference}&rep_mode=group&event_name=MACD_1H_LINE_CROSS&event_tf=1H\">REP MACD1H cross/cross</A></TD></TR>\n\n" ;
print "<TR><TD><A HREF=\"cgi/rep_mon_analyze_symmetric.cgi?currency=BTC&curr_reference=$pv{curr_reference}&rep_mode=group&event_name=MACD_1H_LINE_VECTOR&event_tf=1H\">REP MACD1H vect/vect</A></TD></TR>\n\n" ;
print "<TR><TD><A HREF=\"cgi/rep_mon_analyze_symmetric.cgi?currency=BTC&curr_reference=$pv{curr_reference}&rep_mode=group&event_name=MACD_1H_GIST_VECTOR&event_tf=1H\">REP MACD1H gist/gist</A></TD></TR>\n\n" ;

print "<TR><TD COLSPAN=\"2\">&nbsp;</TD></TR>\n\n" ;

print "<TR><TD><A HREF=\"cgi/rep_rtrsp_strategy_RSI_MACD.cgi?report_type=coins_groupped&currency=ALL&curr_reference=USDT&tf_rsi=1H&tf_macd=1H&is_lncrs_1h1h=false&is_lnvct_1h1h=false&is_gsvct_1h1h=false&is_lncrs_1h4h=true&is_lnvct_1h4h=false&is_gsvct_1h4h=false&currency=BTC&curr_reference=$pv{curr_reference}&rep_mode=group&event_name=MACD_1H_GIST_VECTOR&event_tf=1H\">RSI + MACD</A></TD><TD>REP Ретроспективный анализ эффективности стратегий RSI + MACD. Данные предрасчитаны
</TD></TR>\n\n" ;

print "<TR><TD COLSPAN=\"2\">&nbsp;</TD></TR>\n\n" ;

print "<!-- конец таблицы второго уровня вкладок --></TABLE>\n" ;
print "<!-- конец таблицы первого уровня вкладок --></TD></TR></TABLE>\n" ;

print_foother1() ;
