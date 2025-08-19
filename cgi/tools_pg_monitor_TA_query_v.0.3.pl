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

print_tools_pg_monitor_navigation(1) ;
print "<!-- таблица третьего уровня вкладок - основной блок -->
       <TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\">
       <TR><TD COLSPAN=\"3\">" ;

print_head_ash_graph() ;

print "</TD></TR>
<TR><TD COLSPAN=\"4\"><HR>" ;

$request_text_query = "select distinct query from pg_stat_statements where queryid = $pv{query_id}" ;
#print "<BR>$request_text_query <BR>" ;
my $dbh_text_query = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'pg_password_value' ) ;
my $sth_text_query = $dbh_text_query->prepare($request_text_query) ; $sth_text_query->execute() ;
#-debug-print "<BR>!!! execute sql<BR>" ;
$query_text = "" ;
$query_text_part = "" ;
$count_query_text = 0 ;
while ( ($query_text) = $sth_text_query->fetchrow_array() ) { $count_query_text++ ;
      if ( $query_text ne "" ) { if ( $query_text =~ /([^\n]+\n[^\n]+\n[^\n]+\n)[^\n]+/ ) { $query_text_part = $1."..." ; } else { $query_text_part = $query_text ; } $query_text_part =~ s/\n/<BR>/g ; $query_text_part =~ s/\s/&nbsp;/g ;
         print "<A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_query.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$pv{query_id}&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&tab_detail=2\">Текст запроса</A> [query_id = $pv{query_id}] из pg_stat_statement (нормализованный):<BR><BR>$query_text_part<BR><BR>" ;
         } }
      if ( $query_text eq "" ||  $count_query_text == 0 ) { $sth_text_query->finish() ; $request_text_query = "select distinct query from pg_stat_activity where query_id = $pv{query_id}" ; $sth_text_query = $dbh_text_query->prepare($request_text_query) ; $sth_text_query->execute() ;
          while ( ($query_text) = $sth_text_query->fetchrow_array() ) {
                if ( $query_text ne "" ) { if ( $query_text =~ /([^\n]+\n[^\n]+\n[^\n]+\n)[^\n]+/ ) { $query_text_part = $1."..." ; } else { $query_text_part = $query_text ; }
                   $query_text_part =~ s/\n/<BR>/g ; $query_text_part =~ s/\s/&nbsp;/g ;
                   print "<A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_query.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$pv{query_id}&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&tab_detail=2\">Текст запроса</A> [query_id = $pv{query_id}] из pg_stat_activity (не нормализованный):<BR><BR>$query_text_part<BR><BR>" ;
                   }
                }
          }
$sth_text_query->finish() ;
$dbh_text_query->disconnect() ;

print "<HR>&nbsp;</TD></TR>
<TR><TD COLSPAN=\"4\">" ;

if ( $pv{tab_detail} != 1 && $pv{tab_detail} != 2 && $pv{tab_detail} != 3 && $pv{tab_detail} != 4 && $pv{tab_detail} != 5 && $pv{tab_detail} != 6 ) { $pv{tab_detail} = 1 ; }
print_tools_pg_monitor_query_detail($pv{tab_detail}) ;
print "<!-- таблица третьего - детализации - уровня вкладок -->
       <TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\">
       <TR><TD>" ;

if ($pv{tab_detail} == 1) { print_session_table_activity($pv{period_from},$pv{period_to},$pv{query_id},$pv{plan_id},'','','bestat_sa_history','long',$pg_mon_long_record_limit) ; }
if ($pv{tab_detail} == 2) {
   $request_text_query = "select distinct query from pg_stat_statements where queryid = $pv{query_id}" ;
#-debug-print "<BR>$request_text_query <BR>" ;
   my $dbh_text_query = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'pg_password_value' ) ;
   my $sth_text_query = $dbh_text_query->prepare($request_text_query) ; $sth_text_query->execute() ;
   $query_text = "" ;
   while ( ($query_text) = $sth_text_query->fetchrow_array() ) { if ( $query_text ne "" ) { $query_text =~ s/\n/<BR>/g ; $query_text =~ s/\s/&nbsp;/g ; print "Текст запроса [query_id = $pv{query_id}] из pg_stat_statement:<BR><BR>$query_text<BR><BR>" ; } }
   if ( $query_text eq "" ) { $sth_text_query->finish() ; $request_text_query = "select distinct query from pg_stat_activity where query_id = $pv{query_id}" ; 
      $sth_text_query = $dbh_text_query->prepare($request_text_query) ; $sth_text_query->execute() ;
      while ( ($query_text) = $sth_text_query->fetchrow_array() ) { if ( $query_text ne "" ) { $query_text =~ s/\n/<BR>/g ; $query_text =~ s/\s/&nbsp;/g ; print "Текст запроса [query_id = $pv{query_id}] из pg_stat_activity:<BR><BR>$query_text<BR><BR>" ; } } }
   $sth_text_query->finish() ;
   $dbh_text_query->disconnect() ;
   }

# детализация - статистики запроса
if ($pv{tab_detail} == 3) { my $count_rows_stats_per_plan = 0 ;
   print "<TABLE BORDER=\"1\" WIDTH=\"100%\">
                 <TR><TD CLASS=\"td_query_stats_head\" ROWSPAN=\"2\">#</TD><TD CLASS=\"td_query_stats_head\" ROWSPAN=\"2\">userid</TD><TD CLASS=\"td_query_stats_head\" ROWSPAN=\"2\">dbid</TD><TD CLASS=\"td_query_stats_head\" ROWSPAN=\"2\">planid</TD>
                     <TD CLASS=\"td_query_stats_head\" ROWSPAN=\"2\">calls</TD><TD CLASS=\"td_query_stats_head\" COLSPAN=\"5\">total_time</TD><TD CLASS=\"td_query_stats_head\" ROWSPAN=\"2\">rows</TD><TD CLASS=\"td_query_stats_head\" COLSPAN=\"4\">shared_blks</TD>
                     <TD CLASS=\"td_query_stats_head\" COLSPAN=\"4\">local_blks</TD><TD CLASS=\"td_query_stats_head\" COLSPAN=\"2\">temp_blks</TD><TD CLASS=\"td_query_stats_head\" COLSPAN=\"2\">blk_time</TD><TD CLASS=\"td_query_stats_head\" COLSPAN=\"2\">temp_blk_time</TD>
                     <TD CLASS=\"td_query_stats_head\" COLSPAN=\"2\">time_call</TD></TR>\n
                 <TR><TD CLASS=\"td_query_stats_head\">total</TD><TD CLASS=\"td_query_stats_head\">min</TD><TD CLASS=\"td_query_stats_head\">max</TD><TD CLASS=\"td_query_stats_head\">mean</TD><TD CLASS=\"td_query_stats_head\">std_dev</TD>
                     <TD CLASS=\"td_query_stats_head\">hit</TD><TD CLASS=\"td_query_stats_head\">read</TD><TD CLASS=\"td_query_stats_head\">dirtied</TD><TD CLASS=\"td_query_stats_head\">written</TD><TD CLASS=\"td_query_stats_head\">hit</TD>
                     <TD CLASS=\"td_query_stats_head\">read</TD><TD CLASS=\"td_query_stats_head\">dirtied</TD><TD CLASS=\"td_query_stats_head\">written</TD><TD CLASS=\"td_query_stats_head\">read</TD><TD CLASS=\"td_query_stats_head\">written</TD>
                     <TD CLASS=\"td_query_stats_head\">read</TD><TD CLASS=\"td_query_stats_head\">write</TD><TD CLASS=\"td_query_stats_head\">read</TD><TD CLASS=\"td_query_stats_head\">write</TD><TD CLASS=\"td_query_stats_head\">first_call</TD>
                     <TD CLASS=\"td_query_stats_head\">last_call</TD></TR>\n" ;
   $request_stats_per_plan = "select userid, dbid, planid, calls, round(total_time::numeric,2), round(min_time::numeric,2), round(max_time::numeric,2), round(mean_time::numeric,2), round(stddev_time::numeric,2), rows, shared_blks_hit, shared_blks_read, shared_blks_dirtied, shared_blks_written, local_blks_hit,
                                     local_blks_read, local_blks_dirtied, local_blks_written, temp_blks_read, temp_blks_written, blk_read_time, blk_write_time, temp_blk_read_time, temp_blk_write_time, first_call, last_call
                                     from pg_store_plans where queryid = $pv{query_id} order by total_time desc" ;
#-debug-print "<BR>$request_stats_per_plan<BR>" ;
   my $dbh_stats_per_plan = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'pg_password_value' ) ;
   my $sth_stats_per_plan = $dbh_stats_per_plan->prepare($request_stats_per_plan) ; $sth_stats_per_plan->execute() ;
   while ( ($userid, $dbid, $planid, $calls, $total_time, $min_time, $max_time, $mean_time, $stddev_time, $rows, $shared_blks_hit, $shared_blks_read, $shared_blks_dirtied, $shared_blks_written, $local_blks_hit, $local_blks_read, $local_blks_dirtied, $local_blks_written, $temp_blks_read, $temp_blks_written, $blk_read_time, $blk_write_time, $temp_blk_read_time, $temp_blk_write_time, $first_call, $last_call) = $sth_stats_per_plan->fetchrow_array() ) {
         $first_call =~ s/\s/&nbsp;/g ; $last_call =~ s/\s/&nbsp;/g ;
         $count_rows_stats_per_plan++ ;
         print "<TR><TD CLASS=\"td_query_stats_right\">$count_rows_stats_per_plan</TD><TD CLASS=\"td_query_stats_right\">$userid</TD><TD CLASS=\"td_query_stats_right\">$dbid</TD><TD CLASS=\"td_query_stats_right\">$planid</TD><TD CLASS=\"td_query_stats_right\">$calls</TD>
                    <TD CLASS=\"td_query_stats_right\">$total_time</TD><TD CLASS=\"td_query_stats_right\">$min_time</TD><TD CLASS=\"td_query_stats_right\">$max_time</TD><TD CLASS=\"td_query_stats_right\">$mean_time</TD><TD CLASS=\"td_query_stats_right\">$stddev_time</TD>
                    <TD CLASS=\"td_query_stats_right\">$rows</TD><TD CLASS=\"td_query_stats_right\">$shared_blks_hit</TD><TD CLASS=\"td_query_stats_right\">$shared_blks_read</TD><TD CLASS=\"td_query_stats_right\">$shared_blks_dirtied</TD>
                    <TD CLASS=\"td_query_stats_right\">$shared_blks_written</TD><TD CLASS=\"td_query_stats_right\">$local_blks_hit</TD><TD CLASS=\"td_query_stats_right\">$local_blks_read</TD><TD CLASS=\"td_query_stats_right\">$local_blks_dirtied</TD>
                    <TD CLASS=\"td_query_stats_right\">$local_blks_written</TD><TD CLASS=\"td_query_stats_right\">$temp_blks_read</TD><TD CLASS=\"td_query_stats_right\">$temp_blks_written</TD><TD CLASS=\"td_query_stats_right\">$blk_read_time</TD>
                    <TD CLASS=\"td_query_stats_right\">$blk_write_time</TD><TD CLASS=\"td_query_stats_right\">$temp_blk_read_time</TD><TD CLASS=\"td_query_stats_right\">$temp_blk_write_time</TD><TD CLASS=\"td_query_stats_left\">$first_call</TD>
                    <TD CLASS=\"td_query_stats_left\">$last_call</TD></TR>\n" ;
         }
   $sth_stats_per_plan->finish() ;
   $dbh_stats_per_plan->disconnect() ;
   print "</TABLE>" ;
   }

# детализация - планы выполнения
if ($pv{tab_detail} == 4) {
   print "<TABLE BORDER=\"1\" WIDTH=\"100%\">
                 <TR><TD CLASS=\"td_plans_head\">#</TD><TD CLASS=\"td_plans_head\">Plan ID</TD><TD CLASS=\"td_plans_head\">Plan</TD></TR>\n" ;
   $request_plans = "select planid, plan from pg_store_plans where queryid = $pv{query_id} order by total_time desc" ;
#-debug-print "<BR>$request_plans<BR>" ;
   my $dbh_plans = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'pg_password_value' ) ;
   my $sth_plans = $dbh_plans->prepare($request_plans) ; $sth_plans->execute() ;
   while ( ($planid,$plan) = $sth_plans->fetchrow_array() ) {
         $count_rows_plans++ ;
         print "<TR><TD CLASS=\"td_plans_right\">$count_rows_plans</TD><TD CLASS=\"td_plans_right\">$planid</TD><TD CLASS=\"td_plans_right\"><PRE>$plan</PRE></TD></TR>\n" ;
         }
   $sth_plans->finish() ;
   $dbh_plans->disconnect() ;
   print "</TABLE>" ;
   }

# детализация - события ожидания из pg_stat_activity
if ($pv{tab_detail} == 5) {
   print "<TABLE BORDER=\"0\" WIDTH=\"100%\"><TR><TD STYLE=\"width: 50%; vertical-align: top;\">" ;
   print_sah_events($pv{period_from},$pv{period_to},$pv{query_id},$pv{plan_id},$pv{pid},$pv{pid_start},"bestat_sa_history") ;
   print "</TD>\n<TD STYLE=\"width: 50%; vertical-align: top;\">
          <!-- вторая таблица отражает данные распределения событий ожидания из pg_wait_sampling -->" ;
   print_wait_sampling_events($pv{period_from},$pv{period_to},$pv{query_id},$pv{plan_id},$pv{pid},$pv{pid_start},"bestat_ws_history") ;
   print "</TD></TR></TABLE>" ;

   }

# детализация - события ожидания из pg_wait_stats
if ($pv{tab_detail} == 6) { 
   print "<A TARGET=\"_blank\" HREF=\"$base_url/cgi/_graph_pg_WS_top_activity.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$pv{query_id}&plan_hash=$pv{plan_hash}&pid=$pv{pid}&serial=$pv{serial}&ds_type=DB&width=1450&height=500\">
           <IMG style=\"width:100%; height: 240pt;\" SRC=\"$base_url/cgi/_graph_pg_WS_top_activity.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$pv{query_id}&plan_hash=$pv{plan_hash}&pid=$pv{pid}&serial=$pv{serial}&ds_type=DB&width=2800&height=600\"></A>" ;
   }

print "<!-- конец таблицы четвёртого уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы третьего уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы второго уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы первого уровня вкладок --></TD></TR></TABLE>\n" ;
print_foother1() ;
