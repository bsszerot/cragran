#!/usr/bin/perl

# open source soft - (C) 2023 CrAgrAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

use DBI ;
require "/var/www/crypta/cgi/common_parameter.cragregator" ;
require "$cragran_dir_lib/lib_common_func.pl" ;
require "$cragran_dir_lib/lib_cragran_common.pl" ;
require "$cragran_dir_lib/lib_cragran_pg_monitor.pl" ;

# - вытащить из URL запроса значения уточняющих полей
&get_forms_param() ;

$CURR_YEAR = `date +%Y` ; $CURR_YEAR =~ s/[\r\n]+//g ;
$count_rows = 0 ;

print "Content-Type: text/html\n\n" ;

system("cat $COMM_PAR_BASE_WEB_PATH/includes/header1_1_cgi.shtml") ;
print "MON ZRT КрАгрАн БЕССТ" ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/header1_2_cgi.shtml") ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/main_menu.shtml") ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/header2_1_cgi.shtml") ;

print_main_page_title("Монитор состояния PostgreSQL БД: ", "$COMM_PAR_PGSQL_DB_NAME") ;
print_js_block_pg_monitor() ;

print_tools_coin_navigation(8) ;

print "<!-- таблица первого уровня вкладок -->
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD><BR>" ;
if ( $is_coin_list_format eq "list_format_no" ) { print_tools_pg_main_navigation(3) ; }
else { print_tools_pg_main_navigation(3) ; }
print "<!-- таблица второго уровня вкладок -->
       <TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\">
       <TR><TD>" ;

print_tools_pg_monitor_navigation(2) ;
print "<!-- таблица третьего уровня вкладок - основной блок -->
       <TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\">
       <TR><TD COLSPAN=\"3\">" ;
print_wait_sampling_head_ash_graph() ;
print "</TD></TR><TR><TD>" ;
print_tools_pg_monitor_top_activity_WS_detail($pv{tab_detail}) ;

print "<!-- таблица четвёртого уровня вкладок - блок детализации -->
       <TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\">
       <TR><TD STYLE=\"width: 50%; vertical-align: top;\">" ;

if ($pv{tab_detail} == 1) {
   print "<TR><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_wait_sampling_sql_table_activity($pv{period_from},$pv{period_to},'','','','',$pv{ds_type},'short',$pg_mon_short_record_limit) ;
   print "</TD><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_wait_sampling_session_table_activity($pv{period_from},$pv{period_to},'','','','',$pv{ds_type},'short',$pg_mon_short_record_limit) ;
   }

if ($pv{tab_detail} == 2) {
   print "<TR><TD STYLE=\"width: 100%; vertical-align: top;\">" ;
   print_wait_sampling_sql_table_activity($pv{period_from},$pv{period_to},'','','','',$pv{ds_type},'long',$pg_mon_long_record_limit) ;
   }

if ($pv{tab_detail} == 3) {
   print "<TR><TD STYLE=\"width: 100%; vertical-align: top;\">" ;
   print_wait_sampling_session_table_activity($pv{period_from},$pv{period_to},'','','','',$pv{ds_type},'long',$pg_mon_long_record_limit) ;
   }

if ($pv{tab_detail} == 4) {
   print "<TR><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_sql_table_activity($pv{period_from},$pv{period_to},'','','','','bestat_sa_history','short',$pg_mon_short_record_limit) ;
   print "</TD><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_wait_sampling_sql_table_activity($pv{period_from},$pv{period_to},'','','','',$pv{ds_type},'short',$pg_mon_short_record_limit) ;
   }

if ($pv{tab_detail} == 5) {
   print "<TR><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_session_table_activity($pv{period_from},$pv{period_to},'','','','','bestat_sa_history','short',$pg_mon_short_record_limit) ;
   print "</TD><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_wait_sampling_session_table_activity($pv{period_from},$pv{period_to},'','','','',$pv{ds_type},'short',$pg_mon_short_record_limit) ;
   }

if ($pv{tab_detail} == 6) {
   print "<TR><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_sah_events($pv{period_from},$pv{period_to},'','','','','bestat_sa_history','short',$pg_mon_short_record_limit) ;
   print "</TD><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_wait_sampling_events($pv{period_from},$pv{period_to},'','','','',$pv{ds_type},'short',$pg_mon_short_record_limit) ;
   }

print "<!-- конец таблицы четвёртого уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы третьего уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы второго уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы первого уровня вкладок --></TD></TR></TABLE>\n" ;
print_foother1() ;
