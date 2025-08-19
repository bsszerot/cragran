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
require "$cragran_dir_lib/lib_cragran_monitoring_func.pl" ;
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


my $is_coin_list_format = "no" ;
if ($pv{currency} ne "ALL" && $pv{currency} ne "IN_TRADE" && $pv{currency} ne "IN_INVEST" && $pv{currency} ne "TOP_50" && $pv{currency} ne "INVST_01" && $pv{currency} ne "INVST_02" && $pv{currency} ne "INVST_03" && $pv{currency} ne "INVST_04") {
   $is_coin_list_format = "list_format_no" ; }
else { $is_coin_list_format = "list_format_yes" ; }

print "Content-Type: text/html\n\n" ;

system("cat $COMM_PAR_BASE_WEB_PATH/includes/header1_1_cgi.shtml") ;
print "MON ZRT КрАгрАн БЕССТ" ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/header1_2_cgi.shtml") ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/main_menu.shtml") ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/header2_1_cgi.shtml") ;

print_main_page_title("Оперативные инструменты: Cобытия мониторинга ", "$pv{currency}/$pv{curr_reference}") ;
print_js_block_common() ;
print_js_block_trading() ;
print_tools_coin_navigation(4) ;
print "<!-- таблица первого уровня вкладок -->
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD><BR>" ;

if ( $is_coin_list_format eq "list_format_no" ) { print_tools_monitoring_navigation(1) ; }
else { print_tools_monitoring_navigation(2) ; }
print "<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD COLSPAN=\"2\">&nbsp;<BR>" ;

#print "<P STYLE=\"font-size: 8pt;\">Краткое описание формы:<BR>Форма событий мониторинга</P>" ;
print_coin_links_map("tools_coin_monitoring.cgi") ;

print "</TD></TR><TR><TD COLSPAN=\"2\">" ;

print "<STYLE>
      IMG.invest_graph { width: 320pt; height: 159pt; }
      </STYLE>" ;

print "<TABLE BORDER=\"1\" WIDTH=\"100%\">" ;
#print "<TR><TD COLSPAN=\"3\">" ;
#print_coin_links_map("tools_coin_monitoring.cgi") ;
#print "</TD></TR>" ;

#print "<TR><TD COLSPAN=\"3\"><P>Варианты отображения:
#&nbsp;<A HREF=\"cgi/tools_coin_monitoring.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}&is_macd_cross_only=1\">[MACD_4H_LINES_CROSS]</A>
#&nbsp;<A HREF=\"cgi/tools_coin_monitoring.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}&&is_macd_cross_only=0\">[Все события]</A></P>
#</TD></TR>" ;

my $sz_filter_coin = "" ;
my $current_coin_list = $trade_all_vol_coin_list ;
if ($pv{currency} eq "IN_TRADE") { $current_coin_list = $in_trade_coin_list ; }
if ($pv{currency} eq "IN_INVEST") { $current_coin_list = $in_invest_coin_list ; }
if ($pv{currency} eq "TOP_50") { $current_coin_list = $trade_top_50_coin_list ; }
if ($pv{currency} eq "INVST_01") { $current_coin_list = $invest_01_coin_list ; }
if ($pv{currency} eq "INVST_02") { $current_coin_list = $invest_02_coin_list ; }
if ($pv{currency} eq "INVST_03") { $current_coin_list = $invest_03_coin_list ; }
if ($pv{currency} eq "INVST_04") { $current_coin_list = $invest_04_coin_list ; }

if ($pv{currency} ne "ALL" && $pv{currency} ne "IN_TRADE" && $pv{currency} ne "IN_INVEST" && $pv{currency} ne "TOP_50" && $pv{currency} ne "INVST_01" && $pv{currency} ne "INVST_02" && $pv{currency} ne "INVST_03" && $pv{currency} ne "INVST_04") {
   $sz_filter_coin = " AND currency = '$pv{currency}' and reference_currency = '$pv{curr_reference}' " ; }
else { $sz_filter_coin = " AND currency in ($current_coin_list) " ; }

my $start_event_filter = "" ; if ( $pv{is_macd_cross_only} eq "" ) { $pv{is_macd_cross_only} = "1" ; } if ( $pv{is_macd_cross_only} eq 1 ) { $start_event_filter = " AND event_name = 'MACD_4H_LINE_CROSS'" ; }

my $ext_where_tf_query = "" ;
if ( $pv{mon_tf} ne "undefined" ) {
   if ( $pv{mon_areal} eq "equal" ) { $ext_where_tf_query .= " AND event_tf = '$pv{mon_tf}' " ; } 
   if ( $pv{mon_areal} eq "eq_plus" ) { 
      if ( $pv{mon_tf} eq "1H" ) { $ext_where_tf_query .= " AND event_tf IN ('4W','3W','2W','1W','4D','3D','2D','1D','12H','8H','4H','3H','2H','1H') " ; }
      if ( $pv{mon_tf} eq "2H" ) { $ext_where_tf_query .= " AND event_tf IN ('4W','3W','2W','1W','4D','3D','2D','1D','12H','8H','4H','3H','2H') " ; }
      if ( $pv{mon_tf} eq "3H" ) { $ext_where_tf_query .= " AND event_tf IN ('4W','3W','2W','1W','4D','3D','2D','1D','12H','8H','4H','3H') " ; }
      if ( $pv{mon_tf} eq "4H" ) { $ext_where_tf_query .= " AND event_tf IN ('4W','3W','2W','1W','4D','3D','2D','1D','12H','8H','4H') " ; }
      if ( $pv{mon_tf} eq "8H" ) { $ext_where_tf_query .= " AND event_tf IN ('4W','3W','2W','1W','4D','3D','2D','1D','12H','8H') " ; }
      if ( $pv{mon_tf} eq "12H" ) { $ext_where_tf_query .= " AND event_tf IN ('4W','3W','2W','1W','4D','3D','2D','1D','12H') " ; }
      if ( $pv{mon_tf} eq "1D" ) { $ext_where_tf_query .= " AND event_tf IN ('4W','3W','2W','1W','4D','3D','2D','1D') " ; }
      if ( $pv{mon_tf} eq "2D" ) { $ext_where_tf_query .= " AND event_tf IN ('4W','3W','2W','1W','4D','3D','2D') " ; }
      if ( $pv{mon_tf} eq "3D" ) { $ext_where_tf_query .= " AND event_tf IN ('4W','3W','2W','1W','4D','3D') " ; }
      if ( $pv{mon_tf} eq "4D" ) { $ext_where_tf_query .= " AND event_tf IN ('4W','3W','2W','1W','4D') " ; }
      if ( $pv{mon_tf} eq "1W" ) { $ext_where_tf_query .= " AND event_tf IN ('4W','3W','2W','1W') " ; }
      if ( $pv{mon_tf} eq "2W" ) { $ext_where_tf_query .= " AND event_tf IN ('4W','3W','2W') " ; }
      if ( $pv{mon_tf} eq "3W" ) { $ext_where_tf_query .= " AND event_tf IN ('4W','3W') " ; }
      if ( $pv{mon_tf} eq "4W" ) { $ext_where_tf_query .= " AND event_tf IN ('4W') " ; }
      }
   }

my $ext_where_query = "" ;
if ( $pv{mon_events} ne "undefined" ) {
   if ( $pv{mon_events} eq "MACD_ALL" ) { $ext_where_query .= " AND event_indicator = 'MACD' " ; }
   if ( $pv{mon_events} eq "RSI_ALL" ) { $ext_where_query .= " AND event_indicator = 'RSI' " ; }
   }

$request_events = "select event_id, event_rand_id, change_ts, currency, reference_currency, timestamp_point, event_name, event_vector, event_tf, event_indicator, event_sub_indicator
                          from mon_events
                          where event_name IS NOT NULL $sz_filter_coin $ext_where_tf_query $ext_where_query
                          order by timestamp_point DESC" ;

#-debug-print "$request_events<BR>\n" ;

my $dbh_h = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'pg_password_value' ) ;
my $sth_h = $dbh_h->prepare($request_events) ; $sth_h->execute(); $count_rows = 0 ;
my $count_output_record = 0 ;
while (my ($ev_event_id, $ev_event_rand_id, $ev_change_ts, $ev_currency, $ev_reference_currency, $ev_timestamp_point, $ev_event_name, $ev_event_vector, $ev_event_tf, $ev_event_indicator, $ev_event_sub_indicator) = $sth_h->fetchrow_array() ) {
      $ev_change_ts =~ s/(.+)\.(.+)/$1/g ;
      $ev_timestamp_point =~ s/(.+)\.(.+)/$1/g ;
      $count_output_record++ ;
      printf ("\n<TR>
                 <TD STYLE=\"vertical-align: top;\" ID=\"id_$ev_event_id\"><SPAN STYLE=\"text-align: right;\">[\#$count_output_record]</SPAN><BR>
                     <A CLASS=\"event_coin\" HREF=\"https://zrt.ourorbits.ru/crypta/cgi/tools_coin_trading.cgi?currency=%s&curr_reference=%s\">%s/%s</A></SPAN>&nbsp;НЕ&nbsp;В&nbsp;СДЕЛКЕ<BR>
                     Событие:&nbsp;<SPAN STYLE=\"font-size: 12pt; color: red;\">%s</SPAN>,&nbsp;<SPAN STYLE=\"font-size: 12pt; color: red;\">%s</SPAN><BR>
                     Индикатор:&nbsp;%s,&nbsp;ТФ:&nbsp;%s,&nbsp;доп.:&nbsp;%s<BR>
                     Время&nbsp;выявления:&nbsp;%s<BR>
                     ID&nbsp;события:&nbsp;%s,&nbsp;#%s<BR><BR>
                     --- аналитика эффективности ---
                     <BR>MACD_4H:&nbsp;<A HREF=\"cgi/rep_mon_analyze_symmetric.cgi?currency=%s&curr_reference=%s&rep_mode=full&event_name=MACD_4H_LINE_CROSS&event_tf=4H\">crss/crss</A>
                     &nbsp;<A HREF=\"cgi/rep_mon_analyze_symmetric.cgi?currency=%s&curr_reference=%s&rep_mode=full&event_name=MACD_4H_LINE_VECTOR&event_tf=4H\">vktr/vktr</A>
                     &nbsp;<A HREF=\"cgi/rep_mon_analyze_symmetric.cgi?currency=%s&curr_reference=%s&rep_mode=full&event_name=MACD_4H_GIST_VECTOR&event_tf=4H\">gist/gist</A>
                     <BR>MACD_1H:&nbsp;<A HREF=\"cgi/rep_mon_analyze_symmetric.cgi?currency=%s&curr_reference=%s&rep_mode=full&event_name=MACD_1H_LINE_CROSS&event_tf=1H\">crss/crss</A>
                     &nbsp;<A HREF=\"cgi/rep_mon_analyze_symmetric.cgi?currency=%s&curr_reference=%s&rep_mode=full&event_name=MACD_1H_LINE_VECTOR&event_tf=1H\">vktr/vktr</A>
                     &nbsp;<A HREF=\"cgi/rep_mon_analyze_symmetric.cgi?currency=%s&curr_reference=%s&rep_mode=full&event_name=MACD_1H_GIST_VECTOR&event_tf=1H\">gist/gist</A>
                     <BR><BR>--- сделки ---
                 </TD>\n", $ev_currency, $ev_reference_currency, $ev_currency, $ev_reference_currency, $ev_event_name, $ev_event_vector, $ev_event_indicator, $ev_event_tf,
                     $ev_event_sub_indicator, $ev_timestamp_point, $ev_event_rand_id, $ev_event_id, $ev_currency, $ev_reference_currency, $ev_currency, $ev_reference_currency,
                     $ev_currency, $ev_reference_currency, $ev_currency, $ev_reference_currency, $ev_currency, $ev_reference_currency, $ev_currency, $ev_reference_currency ) ;

# - вывест ближайшие события
      my $max_prev_event_records = $max_view_prev_records_operative_events ; my $max_fwd_event_records = '10 days' ;
      print "<TD STYLE=\"vertical-align: top; font-size: 8pt;\">прежние и новые (+$max_fwd_event_records) события (limit $max_prev_event_records):<BR><BR><SPAN STYLE=\"font-size: 8pt;\">" ;
      $request_prev_events = "select event_id, event_rand_id, change_ts, currency, reference_currency, timestamp_point, event_name, event_vector, event_tf, event_indicator, event_sub_indicator
                                     from mon_events
                                     where currency = '$ev_currency' AND reference_currency = '$ev_reference_currency'
                                        and timestamp_point < to_timestamp('$ev_timestamp_point','YYYY-MM-DD HH24:MI:SS') + INTERVAL '10 days' $ext_where_tf_query
                                     order by timestamp_point DESC limit $max_prev_event_records " ;
#-debug-print "$request_prev_events<BR>\n" ;
      my $dbh_h_prev = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'pg_password_value' ) ;
      my $sth_h_prev = $dbh_h_prev->prepare($request_prev_events) ; $sth_h_prev->execute(); $count_rows_prev_events = 0 ;
      while (my ($pr_ev_event_id, $pr_ev_event_rand_id, $pr_ev_change_ts, $pr_ev_currency, $pr_ev_reference_currency, $pr_ev_timestamp_point, $pr_ev_event_name, $pr_ev_event_vector, $pr_ev_event_tf, $pr_ev_event_indicator, $pr_ev_event_sub_indicator) = $sth_h_prev->fetchrow_array() ) {
            $pr_ev_change_ts =~ s/(.+)\.(.+)/$1/g ; $pr_ev_change_ts =~ s/\s/&nbsp;/g ;
            $pr_ev_timestamp_point =~ s/(.+)\.(.+)/$1/g ; $pr_ev_timestamp_point =~ s/\s/&nbsp;/g ;
            printf ("\n...&nbsp;<A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_monitoring.cgi?currency=%s&curr_reference=%s&is_macd_cross_only=0&time_frame=%s#id_%s\"><SPAN STYLE=\"font-size: 8pt;\">%s&nbsp;</SPAN><SPAN STYLE=\"font-size: 8pt; color: red;\">%s</SPAN>,&nbsp;<SPAN STYLE=\"font-size: 8pt; color: red;\">%s</SPAN></A>&nbsp;<BR>\n",
                   $pr_ev_currency, $pr_ev_reference_currency, $pr_ev_event_tf, $pr_ev_event_id, $pr_ev_timestamp_point, $pr_ev_event_name, $pr_ev_event_vector ) ;
            }
      $sth_h_prev->finish() ;
      $dbh_h_prev->disconnect() ;
      print "</SPAN></TD><TD STYLE=\"vertical-align: top; text-align: left;\">" ;

      $request_ev_images = "select event_id, event_rand_id, event_img_id, change_ts, file_name, full_file_name, timestamp_point, ev_img_tf, ev_img_indicator, ev_img_sub_indicator
                                   from mon_events_images
                                   where event_rand_id = '$ev_event_rand_id'
                                   order by timestamp_point ASC" ;
#-debug-print "$request_ev_images<BR>" ;
      my $dbh_h_img = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'pg_password_value' ) ;
      my $sth_h_img = $dbh_h_img->prepare($request_ev_images) ; $sth_h_img->execute(); $count_rows_img = 0 ;
      while (my ($img_event_id, $img_event_rand_id, $img_event_img_id, $img_change_ts, $img_file_name, $img_full_file_name, $img_timestamp_point, $img_ev_img_tf, $img_ev_img_indicator, $img_ev_img_sub_indicator) = $sth_h_img->fetchrow_array() ) {
            if ($count_output_record <= $max_view_graph_operative_events) {
               printf("<A HREF=\"$COMM_PAR_BASE_HREF/img/img_event_monitoring/%s\" TARGET=\"_blank\"><IMG STYLE=\"width: 170pt; height: 90pt;\" SRC=\"$COMM_PAR_BASE_HREF/img/img_event_monitoring/%s\"></A>&nbsp;", $img_file_name, $img_file_name) ;
               }
            else {
               printf("<A HREF=\"$COMM_PAR_BASE_HREF/img/img_event_monitoring/%s\" TARGET=\"_blank\">%s</A><BR>", $img_file_name, $img_file_name) ;
               }
            }
      $sth_h_img->finish() ;
      $dbh_h_img->disconnect() ;

      print "</TD></TR>" ;
      }
$sth_h->finish() ;
$dbh_h->disconnect() ;

print "<!-- конец таблицы второго уровня вкладок --></TABLE>\n" ;
print "<!-- конец таблицы первого уровня вкладок --></TD></TR></TABLE>\n" ;
print_foother1() ;
