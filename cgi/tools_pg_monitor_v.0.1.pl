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
if ( $is_coin_list_format eq "list_format_no" ) { print_tools_pg_main_navigation(1) ; }
else { print_tools_pg_main_navigation(1) ; }
print "<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD COLSPAN=\"2\">&nbsp;<BR>" ;

print_head_ash_graph() ;

print "</TD></TR>
<TR><TD>
<TABLE STYLE=\"width: 100%\">
<TR><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
print_sql_table_activity($pv{period_from},$pv{period_to},'','','','',$pv{ds_type}) ;
print "</TD><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
print_session_table_activity($pv{period_from},$pv{period_to},'','','','',$pv{ds_type}) ;


print "<!-- конец таблицы второго уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы первого уровня вкладок --></TD></TR></TABLE>\n" ;
print_foother1() ;
