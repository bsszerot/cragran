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

my $is_coin_list_format = "no" ;
if ($pv{currency} ne "ALL" && $pv{currency} ne "IN_TRADE" && $pv{currency} ne "IN_INVEST" && $pv{currency} ne "TOP_50" && $pv{currency} ne "INVST_01" && $pv{currency} ne "INVST_02" && $pv{currency} ne "INVST_03" && $pv{currency} ne "INVST_04") {
   $is_coin_list_format = "list_format_no" ; }
else { $is_coin_list_format = "list_format_yes" ; }

print "Content-Type: text/html\n\n" ;

system("cat $COMM_PAR_BASE_WEB_PATH/includes/header1_1_cgi.shtml") ;
print "INV ZRT КрАгрАн БЕССТ" ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/header1_2_cgi.shtml") ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/main_menu.shtml") ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/header2_1_cgi.shtml") ;

print_main_page_title("Оперативные инструменты: Инвестиционные графики", "$pv{currency}") ;

print_js_block_common() ;
print_js_block_trading() ;

print_tools_coin_navigation(3) ;
print "<!-- таблица первого уровня вкладок -->
<STYLE>
IMG.capit_graph { width: 340pt; height: 90pt; }
</STYLE>
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD><BR>" ;

if ( $is_coin_list_format eq "list_format_no" ) { print_tools_invest_navigation(1) ; }
else { print_tools_invest_navigation(2) ; }
print "<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD COLSPAN=\"3\">&nbsp;<BR>" ;

#print "<P STYLE=\"font-size: 8pt;\">Краткое описание формы:<BR>Форма инвестиционной аналитики</P>" ;
print_coin_links_map("tools_coin_invest.cgi") ;

print "</TD></TR><TR><TD COLSPAN=\"2\">" ;
my $count_prds_invest = 1097 ;

if ( $is_coin_list_format eq "list_format_no" ) {
   $pv{time_frame} = "1D" ; $pv{count_prds} = $count_prds_invest ; $pv{macd_mult} = "x1" ; $pv{ema_mode} = 1 ; $pv{macd_mode} = 0 ; $pv{macd_tf} = "4D" ; $pv{macd_mult} = "x1" ; $pv{rsi_mode} = 0 ; $pv{rsi_tf} = "1D" ; $pv{vlt_mode} = 0 ; $pv{vlt_tf} = "1D" ; $pv{vol_mode} = 0 ;
   print "<TR><TD STYLE=\"vertical-align: top;\">
              <HR>$pv{currency}/BTC. Анализируем рост монеты относительно BTC<HR>" ;
   $v_rand = rand() ; $v_rand =~ s/\.//g;
   print "<DIV ID=\"id_trading_block_$pv{currency}"."_BTC"."_$v_rand\">" ;
#  print_coin_graphs_block("id_trading_block_$pv{currency}"."_BTC"."_$v_rand","$pv{currency}","BTC","1","$pv{time_frame}","$pv{count_prds}","$pv{offset_prds}","$pv{env_prct}","$pv{ema_mode}","$pv{macd_mode}","$pv{macd_tf}","$pv{macd_mult}","$pv{rsi_mode}","$pv{rsi_tf}","$pv{vlt_mode}","$pv{vlt_tf}","$pv{vol_mode}","$pv{time_frame}","half","no_disabled","per_count","","") ;
   print_coin_graphs_block("id_trading_block_$pv{currency}"."_BTC"."_$v_rand","$pv{currency}","BTC","1","$pv{time_frame}","$pv{count_prds}","$pv{offset_prds}","$pv{env_prct}","$pv{ema_mode}","$pv{time_frame}","$pv{macd_mode}","$pv{macd_tf}","$pv{macd_mult}","$pv{rsi_mode}","$pv{rsi_tf}","$pv{vlt_mode}","$pv{vlt_tf}","0","$pv{time_frame}","half","show","per_count","","") ;
   print "</DIV>" ;

   print "\n<HR>Граница роста, $count_prds_invest периодов - дней<BR><HR>
            \n<A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_risk_margin.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}&count_prds=$count_prds_invest&output_type=graph&brush_size=4&x_size=1400&y_size=640\" TARGET=\"_blank\">
                 <IMG CLASS=\"capit_graph\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_risk_margin.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}&count_prds=$count_prds_invest&output_type=graph&brush_size=4&x_size=700&y_size=320\"></A>
            <HR>Капитализация, $count_prds_invest периодов - дней<BR><HR>
            \n<A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_capitalization.cgi?currency=$pv{currency}&curr_reference=$curr_ref_coin_gecko&count_prds=$count_prds_invest&output_type=graph&brush_size=4&x_size=1400&y_size=640\" TARGET=\"_blank\">
                 <IMG CLASS=\"capit_graph\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_capitalization.cgi?currency=$pv{currency}&curr_reference=$curr_ref_coin_gecko&count_prds=$count_prds_invest&output_type=graph&brush_size=4&x_size=700&y_size=320\"></A>
            <HR>Доминация, $count_prds_invest периодов - дней<BR><HR>
            \n<A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_coin_domination.cgi?currency=$pv{currency}&curr_reference=$curr_ref_coin_gecko&count_prds=$count_prds_invest&output_type=graph&brush_size=4&x_size=1400&y_size=640\" TARGET=\"_blank\">
                 <IMG CLASS=\"capit_graph\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_coin_domination.cgi?currency=$pv{currency}&curr_reference=$curr_ref_coin_gecko&count_prds=$count_prds_invest&output_type=graph&brush_size=4&x_size=700&y_size=320\"></A>
          </TD><TD>&nbsp;&nbsp;&nbsp;</TD><TD STYLE=\"vertical-align: top;\">" ;

   print "\n\n<HR>BTC/USDT - ведущая монета. Анализируем динамику BTC<BR><HR>" ;
   $v_rand = rand() ; $v_rand =~ s/\.//g;
   print "<DIV ID=\"id_trading_block_BTC"."_USDT"."_$v_rand\">" ;
#         print_coin_graphs_block("id_trading_block_$pv{currency}"."_$pv{curr_reference}"."_$v_rand","$pv{currency}","$pv{curr_reference}","$pv{time_frame}","$pv{count_prds}","$pv{env_prct}","$pv{ema_mode}","$pv{macd_mode}","$pv{macd_tf}","$pv{macd_mult}","$pv{rsi_mode}","$pv{rsi_tf}","$pv{vlt_mode}","$pv{vlt_tf}","0","$pv{time_frame}","full","show") ;
   print_coin_graphs_block("id_trading_block_BTC"."_USDT"."_$v_rand","BTC","USDT","1","$pv{time_frame}","$pv{count_prds}","$pv{offset_prds}","$pv{env_prct}","$pv{ema_mode}","$pv{time_frame}",$pv{macd_mode},"$pv{macd_tf}","$pv{macd_mult}",$pv{rsi_mode},"$pv{rsi_tf}",$pv{vlt_mode},"$pv{vlt_tf}",$pv{vol_mode},"$pv{time_frame}","middle","no_disabled","per_count","","") ;
   print "</DIV>" ;
   print "\n\n<HR>$pv{currency}/USDT - текущая монета. Анализируем повторение динамики BTC<HR>" ;
   $v_rand = rand() ; $v_rand =~ s/\.//g;
   print "<DIV ID=\"id_trading_block_$pv{currency}"."_USDT"."_$v_rand\">" ;
   print_coin_graphs_block("id_trading_block_$pv{currency}"."_USDT"."_$v_rand","$pv{currency}","USDT","1","$pv{time_frame}","$pv{count_prds}","$pv{offset_prds}","$pv{env_prct}","$pv{ema_mode}","$pv{time_frame}", "$pv{macd_mode}","$pv{macd_tf}","$pv{macd_mult}","$pv{rsi_mode}","$pv{rsi_tf}",$pv{vlt_mode},"$pv{vlt_tf}",$pv{vol_mode},"$pv{time_frame}","middle","no_disabled","per_count","","") ;
   print "</DIV>" ;
   print "</TD></TR>\n\n" ;

   }
else {
   print "<STYLE>
         IMG.invest_graph { width: 320pt; height: 201pt; }
         </STYLE>" ;
#   print "<TR><TD CLASS=\"tdhead\">Граница роста</TD><TD CLASS=\"tdhead\">Капитализация</TD><TD CLASS=\"tdhead\">Доминация</TD></TR>" ;

   my $current_coin_list = $trade_all_vol_coin_list ;
   if ($pv{currency} eq "IN_TRADE") { $current_coin_list = $in_trade_coin_list ; }
   if ($pv{currency} eq "IN_INVEST") { $current_coin_list = $in_invest_coin_list ; }
   if ($pv{currency} eq "TOP_50") { $current_coin_list = $trade_top_50_coin_list ; }
   if ($pv{currency} eq "INVST_01") { $current_coin_list = $invest_01_coin_list ; }
   if ($pv{currency} eq "INVST_02") { $current_coin_list = $invest_02_coin_list ; }
   if ($pv{currency} eq "INVST_03") { $current_coin_list = $invest_03_coin_list ; }
   if ($pv{currency} eq "INVST_04") { $current_coin_list = $invest_04_coin_list ; }
   my $ext_sql_filter = "" ;
   $ext_sql_filter = " AND t1.currency IN ($current_coin_list) AND t1.reference_currency = 'USDT' " ;

   $request = "select t1.currency, t1.reference_currency, TO_CHAR(t1.timestamp_point, 'YY-MM-DD') TIME_POINT, t2.max_price, t2.min_price, t1.price_close, ROUND(t1.price_close/(t2.max_price/100),2) risk_margin
         from crcomp_pair_ohlc_1d_history t1,
              (select currency, reference_currency, max(price_close) max_price, min(price_close) min_price, max(timestamp_point) tsp
                      from crcomp_pair_ohlc_1d_history
                      where timestamp_point > now() - INTERVAL '720 days'
                      group by currency, reference_currency) t2
         where t1.timestamp_point > now() - INTERVAL '720 days'
               AND t1.currency = t2.currency AND t1.reference_currency = t2.reference_currency AND t2.tsp = t1.timestamp_point $ext_sql_filter
         order by risk_margin ASC" ;
   my $dbh_h = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'pg_password_value' ) ;
   my $sth_h = $dbh_h->prepare($request) ; $sth_h->execute(); $count_rows = 0 ;
   while (my ($coin, $ref_coin, $timestamp_point, $max_price, $min_price, $close_price, $risk_margin ) = $sth_h->fetchrow_array() ) {
         if ( $ref_coin eq "USDT") { $ref_coin_gecko = "USD" ; }
#  foreach (@tmp_coin_list1) { $pv{currency} = $_ ; $pv{curr_reference} = "USDT" ; $curr_ref_coin_gecko = "USD" ;
           print "<TR><TD COLSPAN=\"3\" STYLE=\"font-size: 14pt; color: white; background-color: navy;\">$coin / $ref_coin [Risk Margin = $risk_margin%]</TD></TR>" ;

           $pv{time_frame} = "1D" ; $pv{count_prds} = $count_prds_invest ; $pv{macd_mult} = "x1" ; $pv{ema_mode} = 1 ; $pv{macd_mode} = 0 ; $pv{macd_tf} = "4D" ; $pv{macd_mult} = "x1" ; $pv{rsi_mode} = 0 ; $pv{rsi_tf} = "1D" ; $pv{vlt_mode} = 0 ; $pv{vlt_tf} = "1D" ; $pv{vol_mode} = 0 ;
           $pv{currency} = $coin ; $pv{curr_reference} = $ref_coin ;
           print "<TR><TD STYLE=\"vertical-align: top;\">
                      <HR>$pv{currency}/BTC. Анализируем рост монеты относительно BTC<HR>" ;
           $v_rand = rand() ; $v_rand =~ s/\.//g;
           print "<DIV ID=\"id_trading_block_$pv{currency}"."_BTC"."_$v_rand\">" ;
           print_coin_graphs_block("id_trading_block_$pv{currency}"."_BTC"."_$v_rand","$pv{currency}","BTC","1","$pv{time_frame}","$pv{count_prds}","$pv{offset_prds}","$pv{env_prct}","$pv{ema_mode}","$pv{time_frame}","$pv{macd_mode}","$pv{macd_tf}","$pv{macd_mult}","$pv{rsi_mode}","$pv{rsi_tf}","$pv{vlt_mode}","$pv{vlt_tf}","0","$pv{time_frame}","half","show","per_count","","") ;
#           print_coin_graphs_block("id_trading_block_$pv{currency}"."_BTC"."_$v_rand","$pv{currency}","BTC","1","$pv{time_frame}","$pv{count_prds}","$pv{offset_prds}","$pv{env_prct}","$pv{ema_mode}","$pv{time_frame}","$pv{macd_mode}","$pv{macd_tf}","$pv{macd_mult}","$pv{rsi_mode}","$pv{rsi_tf}","$pv{vlt_mode}","$pv{vlt_tf}","0","$pv{time_frame}","half","show","per_count","","") ;
           print "</DIV>" ;

           print "\n<HR>Граница роста, $count_prds_invest периодов - дней<BR><HR>
                    \n<A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_risk_margin.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}&count_prds=$count_prds_invest&output_type=graph&brush_size=4&x_size=1400&y_size=640\" TARGET=\"_blank\">
                         <IMG CLASS=\"capit_graph\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_risk_margin.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}&count_prds=$count_prds_invest&output_type=graph&brush_size=4&x_size=700&y_size=320\"></A>
                    <HR>Капитализация, $count_prds_invest периодов - дней<BR><HR>
                    \n<A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_capitalization.cgi?currency=$pv{currency}&curr_reference=$curr_ref_coin_gecko&count_prds=$count_prds_invest&output_type=graph&brush_size=4&x_size=1400&y_size=640\" TARGET=\"_blank\">
                         <IMG CLASS=\"capit_graph\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_capitalization.cgi?currency=$pv{currency}&curr_reference=$curr_ref_coin_gecko&count_prds=$count_prds_invest&output_type=graph&brush_size=4&x_size=700&y_size=320\"></A>
                    <HR>Доминация, $count_prds_invest периодов - дней<BR><HR>
                    \n<A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_coin_domination.cgi?currency=$pv{currency}&curr_reference=$curr_ref_coin_gecko&count_prds=$count_prds_invest&output_type=graph&brush_size=4&x_size=1400&y_size=640\" TARGET=\"_blank\">
                         <IMG CLASS=\"capit_graph\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_coin_domination.cgi?currency=$pv{currency}&curr_reference=$curr_ref_coin_gecko&count_prds=$count_prds_invest&output_type=graph&brush_size=4&x_size=700&y_size=320\"></A>
                  </TD><TD>&nbsp;&nbsp;&nbsp;</TD><TD STYLE=\"vertical-align: top;\">" ;

           print "\n\n<HR>BTC/USDT - ведущая монета. Анализируем динамику BTC<BR><HR>" ;
           $v_rand = rand() ; $v_rand =~ s/\.//g;
           print "<DIV ID=\"id_trading_block_BTC"."_USDT"."_$v_rand\">" ;
#         print_coin_graphs_block("id_trading_block_$pv{currency}"."_$pv{curr_reference}"."_$v_rand","$pv{currency}","$pv{curr_reference}","$pv{time_frame}","$pv{count_prds}","$pv{env_prct}","$pv{ema_mode}","$pv{macd_mode}","$pv{macd_tf}","$pv{macd_mult}","$pv{rsi_mode}","$pv{rsi_tf}","$pv{vlt_mode}","$pv{vlt_tf}","0","$pv{time_frame}","full","show") ;
           print_coin_graphs_block("id_trading_block_BTC"."_USDT"."_$v_rand","BTC","USDT","1","$pv{time_frame}","$pv{count_prds}","$pv{offset_prds}","$pv{env_prct}","$pv{ema_mode}","$pv{time_frame}",$pv{macd_mode},"$pv{macd_tf}","$pv{macd_mult}",$pv{rsi_mode},"$pv{rsi_tf}",$pv{vlt_mode},"$pv{vlt_tf}",$pv{vol_mode},"$pv{time_frame}","middle","no_disabled","per_count","","") ;
           print "</DIV>" ;
           print "\n\n<HR>$pv{currency}/USDT - текущая монета. Анализируем повторение динамики BTC<HR>" ;
           $v_rand = rand() ; $v_rand =~ s/\.//g;
           print "<DIV ID=\"id_trading_block_$pv{currency}"."_USDT"."_$v_rand\">" ;
           print_coin_graphs_block("id_trading_block_$pv{currency}"."_USDT"."_$v_rand","$pv{currency}","USDT","1","$pv{time_frame}","$pv{count_prds}","$pv{offset_prds}","$pv{env_prct}","$pv{ema_mode}","$pv{time_frame}", "$pv{macd_mode}","$pv{macd_tf}","$pv{macd_mult}","$pv{rsi_mode}","$pv{rsi_tf}",$pv{vlt_mode},"$pv{vlt_tf}",$pv{vol_mode},"$pv{time_frame}","middle","no_disabled","per_count","","") ;
           print "</DIV>" ;
           print "</TD></TR>\n\n" ;

           }
   $sth_h->finish() ;
   $dbh_h->disconnect() ;
   }

print "<!-- конец таблицы второго уровня вкладок --></TABLE>\n" ;
print "<!-- конец таблицы первого уровня вкладок --></TD></TR></TABLE>\n" ;
print_foother1() ;
