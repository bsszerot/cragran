#!/usr/bin/perl

# open source soft - (C) 2023 CrAgrAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

use DBI ;
use Math::Round ;
require "/var/www/crypta/cgi/common_parameter.cragregator" ;
require "$cragran_dir_lib/lib_common_func.pl" ;
require "$cragran_dir_lib/lib_cragran_common.pl" ;
require "$cragran_dir_lib/lib_cragran_trading.pl" ;
require "$cragran_dir_lib/lib_cragran_contracts.pl" ;

# - вытащить из URL запроса значения уточняющих полей
&get_forms_param() ;

# параметры по умолчанию с версии 0.9 расширены, чтобы можно было формировать ссылку в telegram без амперсандов - только в одним параметром

if ( $pv{curr_reference} eq "" ) { $pv{curr_reference} = "USDT" ; }
if (  $pv{curr_reference} eq "USDT") { $curr_ref_coin_gecko = "USD" ; } else { $curr_ref_coin_gecko = $pv{curr_reference} ; }
#-20240223-if ( $curr_ref_coin eq "USDT") { $curr_ref_coin_gecko = "USD" ; }

if ( $pv{time_frame} eq "" ) { $pv{time_frame} = "10M" ; }
if ( $pv{count_prds} eq "" ) { $pv{count_prds} = "960" ; }
if ( $pv{env_prct} eq "" ) { $pv{env_prct} = "2" ; }

$CURR_YEAR = `date +%Y` ; $CURR_YEAR =~ s/[\r\n]+//g ;
$count_rows = 0 ;

print "Content-Type: text/html\n\n" ;

system("cat $COMM_PAR_BASE_WEB_PATH/includes/header1_1_cgi.shtml") ;
print "CNT ZRT КрАгрАн БЕССТ" ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/header1_2_cgi.shtml") ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/main_menu.shtml") ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/header2_1_cgi.shtml") ;

print_js_block_common() ;
print_js_block_trading() ;
print_js_block_contracts() ;

if ( $pv{action} eq "contracts_list" || $pv{action} eq "open_contracts_list" ) { print_main_page_title("Оперативные инструменты: Контракты. Ведение сделок: ", "списки") ; }
else { print_main_page_title("Оперативные инструменты: Контракты. Ведение сделок: ", "$pv{currency}/$pv{curr_reference}") ; }

print_tools_coin_navigation(1) ;

print "<!-- таблица первого уровня вкладок -->
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD><BR>" ;

if ( $pv{action} ne "contracts_list" && $pv{action} ne "open_contracts_list" ) { print_tools_contracts_navigation(2) ; }
if ( $pv{action} eq "contracts_list" ) { print_tools_contracts_navigation(3) ; }
if ( $pv{action} eq "open_contracts_list" ) { print_tools_contracts_navigation(1) ; }

print "<!-- таблица второго уровня вкладок -->
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD COLSPAN=\"3\">&nbsp;<BR>" ;

#print "<P STYLE=\"font-size: 8pt;\">Краткое описание формы:<BR>Форма ведения сделок</P></TD></TR><TR><TD>" ;
print_coin_links_map("tools_coin_contracts.cgi") ;

print "</TD></TR><TR><TD COLSPAN=\"2\" STYLE=\"vertical-align: top;\">" ;

if ($pv{action} ne "contracts_list" && $pv{action} ne "open_contracts_list") {
# для полного обновления страницы или чтения конкретной сделки нужно при запуске формы указать дейcтвие select и rand_id как cnt_rand_id сделки
   print "<DIV ID=\"id_one_contract\">" ;
   print_contract_form_main_block("$pv{user_name}",$pv{user_id},"$pv{action}","id_one_contract",0,"$pv{cnt_rand_id}") ;
   print "</DIV>" ;

$profit_graph_start_date = "$v_input_time_point" ; $profit_graph_start_date =~ s/[\s-:]//g ;
$profit_graph_stop_date = "$v_output_time_point" ; $profit_graph_stop_date =~ s/[\s-:]//g ;
if ( $v_status eq "clear_no_contract" || $v_status eq "writed_no_contract" || $v_status eq "open_contract") { $profit_graph_stop_date = "last" ; }
$profit_mult = 1 ; if ($v_vector eq "short") { $profit_mult = -1 ; }

   print "</TD>
          <!-- начало вёрсточного столбца дополняющей информации - состояния индикаторов, графиков и т.п.--><TD STYLE=\"vertical-align: top;\">
          <TABLE>
          <TR><TD CLASS=\"contract_delim\">Динамика прибыли/убытка</TD><TD STYLE=\"width: 200pt;\"><HR CLASS=\"contract_delim\"></TD></TR>
          <TR><TD COLSPAN=\"2\">
              <A HREF=\"cgi/_graph_profit.cgi?currency=$v_currency&curr_reference=$v_reference_currency&start_date=$profit_graph_start_date&stop_date=$profit_graph_stop_date&start_price=$v_input_price&profit_mult=$profit_mult&output_type=graph&brush_size=4&x_size=1120&y_size=480\" TARGET=\"_blank\">
                 <IMG CLASS=\"cnt_pre_result_graph\" SRC=\"cgi/_graph_profit.cgi?currency=$v_currency&curr_reference=$v_reference_currency&start_date=$profit_graph_start_date&stop_date=$profit_graph_stop_date&start_price=$v_input_price&profit_mult=$profit_mult&output_type=graph&brush_size=4&x_size=1120&y_size=480\"><BR>
          </TD></TR>
          <TR><TD CLASS=\"contract_delim\">Текущие цены и цикл</TD><TD><HR CLASS=\"contract_delim\"></TD></TR>
          <TR><TD COLSPAN=\"2\">" ;

   $pv{currency} = $v_currency ;
   $pv{curr_reference} = $v_reference_currency ;
   $pv{time_frame} = $v_ind_curr_price_tf ;
   $pv{count_prds} = 720 ;
   $pv{env_prct} = 2 ;
   $pv{ema_mode} = 1 ;
   $pv{macd_mode} = 1 ;
   $pv{macd_tf} = $v_ind_curr_macd_line_tf ;
   $pv{macd_mult} = "x1" ;
   $pv{rsi_mode} = 1 ;
   $pv{rsi_tf} = $v_ind_curr_price_tf ;
   $pv{vlt_mode} = 1 ;
   $pv{vlt_tf} = $v_ind_curr_price_tf ;
   $v_rand = rand() ; $v_rand =~ s/\.//g;
   print "<DIV ID=\"id_trading_block_$pv{currency}"."_$pv{curr_reference}"."_$v_rand\">" ;
   print_coin_graphs_block("id_trading_block_$pv{currency}"."_$pv{curr_reference}"."_$v_rand","$pv{currency}","$pv{curr_reference}","1","$pv{time_frame}","$pv{count_prds}","$pv{offset_prds}","$pv{env_prct}","$pv{ema_mode}","$pv{time_frame}","$pv{macd_mode}","$pv{macd_tf}","$pv{macd_mult}","$pv{rsi_mode}","$pv{rsi_tf}","$pv{vlt_mode}","$pv{vlt_tf}","0","$pv{time_frame}","half","show","per_count","","") ;
   print "</DIV>\n" ;

   print "</TD></TR>
          <TR><TD CLASS=\"contract_delim\">Графики вручную</TD><TD><HR CLASS=\"contract_delim\"></TD></TR>
          <TR><TD COLSPAN=\"2\">---</TD></TR>
          <!-- конец таблицы 2го столбца - графика прибылей/убытков и текущего состояния цен --></TABLE>
          <!-- конец 2го столбца - графика прибылей/убытков и текущего состояния цен --></TD></TR>
          <TR><TD COLSPAN=\"2\"><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR></TD></TR>
          <!-- конец версточной таблицы всего ведения сделок сделки --></TABLE>" ;
   }
else {
# здесь отображаем список сделок

   if ( $pv{action} eq "contracts_list" ) {
      $where_extension = "" ; if ($pv{user_name} ne "" || $pv{cntrct_status} ne "" || $pv{cntrct_cycles} ne "") { $where_extension = " WHERE 1=1 " ;}
      if ($pv{user_name} ne "" && $pv{user_name} ne "undefined" ) { $where_extension .= " AND user_name = '$pv{user_name}' " ; }
      if ($pv{cntrct_status} ne "" ) { $where_extension .= " AND contract_status = '$pv{cntrct_status}' " ; }
      if ($pv{cntrct_cycles} ne "" ) {
         if ( $pv{cntrct_cycles} eq "trading" ) { $where_extension .= " AND not cycle = 'invest' " ; }
         if ( $pv{cntrct_cycles} eq "invest" ) { $where_extension .= " AND cycle = 'invest' " ; }
         }
      if ($pv{currency} ne "ALL" ) { $where_extension .= " AND currency = '$pv{currency}' " ; }
      if ($pv{curr_reference} eq "USDT" || $pv{curr_reference} eq "BTC" ) { $where_extension .= " AND reference_currency = '$pv{curr_reference}' " ; }
      $request = "SELECT user_name, user_id, contract_id, contract_rand_id, contract_status, contract_leverage, cycle, currency, reference_currency, contract_vector, rmm_sl_prct, rmm_sl, rmm_tp_prct, rmm_tp, rmm_tgt_prct, rmm_tgt,
 rmm_risk, rmm_revard, input_base, input_event_rand_id, TO_CHAR(input_time_point,'YYYY-MM-DD HH24:MI:SS'), input_price, input_volume, input_summ, ind_curr_ema_tf, ind_curr_ema, ind_own_ema_tf, ind_own_ema,
 ind_curr_price_tf, ind_curr_price, ind_own_price_tf, ind_own_price, ind_curr_macd_line_tf, ind_curr_macd_line, ind_own_macd_line_tf, ind_own_macd_line, ind_curr_macd_gist_tf, ind_curr_macd_gist, ind_own_macd_gist_tf,
 ind_own_macd_gist, ind_curr_rsi_tf, ind_curr_rsi, ind_own_rsi_tf, ind_own_rsi,output_base, output_event_rand_id, TO_CHAR(output_time_point,'YYYY-MM-DD HH24:MI:SS'), output_price, output_volume, output_summ,
 result_price, result_volume, result_summ, result_percent, comments
 from contracts_history $where_extension order by contract_id desc" ;
# from contracts_history $where_extension order by currency asc" ;
#-debug-print "$request<BR>\n" ;
      my $dbh_h = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'pg_password_value') ; my $sth_h = $dbh_h->prepare($request) ; $sth_h->execute();

      print "<STYLE>
TD { font-size: 8pt; margin: 0pt 5pt 0pt 5pt; padding: 0pt 5pt 0pt 5pt; }
</STYLE>
<P>Внимание !!! Текущая реализация не обрабатывает усреднения, считая их отдельными сделками</P>
" ;
      if ($pv{rep_mode} eq "full" || $pv{rep_mode} eq "") {
         print "<TABLE BORDER=\"0\" WIDTH=\"100%\">
                <TR><TD CLASS=\"td_head\">Общие</TD>
                    <TD CLASS=\"td_head\" COLSPAN=\"3\">Вход<BR>Выход</TD>
                    <TD CLASS=\"td_head\" COLSPAN=\"4\">Результат<BR>RMM</TD>
                    <TD CLASS=\"td_head\" COLSPAN=\"4\">Индикаторы текущий<BR>и старший циклы</TD>
                    <TD CLASS=\"td_head\">График прибыли<BR>Примечания</TD>
                <TR><TD COLSPAN=\"13\"><HR></TD></TR>" ; }

      if ($pv{rep_mode} eq "easy") {
         print "<TABLE BORDER=\"1\" WIDTH=\"100%\">
                <TR><TD ROWSPAN=\"2\" CLASS=\"td_head\" STYLE=\"font-size: 8pt;\">Монета</TD><TD ROWSPAN=\"2\" CLASS=\"td_head\" STYLE=\"font-size: 8pt;\">Референсная</TD>
                    <TD ROWSPAN=\"2\" CLASS=\"td_head\" STYLE=\"font-size: 8pt;\">Направление<BR>сделки</TD><TD ROWSPAN=\"2\" CLASS=\"td_head\" STYLE=\"font-size: 8pt;\">Плечо</TD>
                    <TD CLASS=\"td_head\" COLSPAN=\"4\" STYLE=\"font-size: 8pt;\">Вход в сделку</TD><TD CLASS=\"td_head\" COLSPAN=\"4\" STYLE=\"font-size: 8pt;\">Выход из сделки</TD>
                    <TD CLASS=\"td_head\" COLSPAN=\"3\" STYLE=\"font-size: 8pt;\">Результат сделки</TD></TR>
                <TR><TD CLASS=\"td_head\" STYLE=\"font-size: 8pt;\">Дата и время</TD><TD CLASS=\"td_head\" STYLE=\"font-size: 8pt;\">Цена</TD><TD CLASS=\"td_head\" STYLE=\"font-size: 8pt;\">Объём</TD><TD CLASS=\"td_head\" STYLE=\"font-size: 8pt;\">Сумма</TD>
                    <TD CLASS=\"td_head\" STYLE=\"font-size: 8pt;\">Дата и время</TD><TD CLASS=\"td_head\" STYLE=\"font-size: 8pt;\">Цена</TD><TD CLASS=\"td_head\" STYLE=\"font-size: 8pt;\">Объём</TD><TD CLASS=\"td_head\" STYLE=\"font-size: 8pt;\">Сумма</TD>
                    <TD CLASS=\"td_head\" STYLE=\"font-size: 8pt;\" STYLE=\"font-size: 8pt;\">Прибыль/убыток, \%</TD><TD CLASS=\"td_head\" STYLE=\"font-size: 8pt;\">\% с учётом плеча</TD><TD CLASS=\"td_head\" STYLE=\"font-size: 8pt;\">Прибыль/убыток, сумма</TD></TR>" ;
         }

       my $agr_summ_result_percent = 0 ; my $agr_summ_result_percent_leverage = 0 ; my $agr_summ_count = 0 ; my $agr_summ_summ = 0 ;
       while (my($v_user_name, $v_user_id, $v_id, $v_rand_id, $v_status, $v_leverage, $v_cycle, $v_currency, $v_reference_currency, $v_vector, $v_rmm_sl_prct, $v_rmm_sl, $v_rmm_tp_prct, $v_rmm_tp, $v_rmm_tgt_prct, $v_rmm_tgt, $v_rmm_risk,  $v_rmm_revard, $v_input_base, $v_input_event_rand_id, $v_input_time_point, $v_input_price, $v_input_volume, $v_input_summ, $v_ind_curr_ema_tf, $v_ind_curr_ema, $v_ind_own_ema_tf, $v_ind_own_ema,  $v_ind_curr_price_tf, $v_ind_curr_price, $v_ind_own_price_tf, $v_ind_own_price, $v_ind_curr_macd_line_tf, $v_ind_curr_macd_line, $v_ind_own_macd_line_tf, $v_ind_own_macd_line, $v_ind_curr_macd_gist_tf,  $v_ind_curr_macd_gist, $v_ind_own_macd_gist_tf, $v_ind_own_macd_gist, $v_ind_curr_rsi_tf, $v_ind_curr_rsi, $v_ind_own_rsi_tf, $v_ind_own_rsi, $v_output_base, $v_output_event_rand_id, $v_output_time_point,  $v_output_price, $v_output_volume, $v_output_summ, $v_result_price, $v_result_volume, $v_result_summ, $v_result_percent, $v_comments) = $sth_h->fetchrow_array()) {
             $v_rmm_sl =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_rmm_sl =~ s/(\d+)\.$/$1/g ;
             $v_rmm_tp =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_rmm_tp =~ s/(\d+)\.$/$1/g ;
             $v_rmm_tgt =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_rmm_tgt =~ s/(\d+)\.$/$1/g ;
             $v_input_price =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_input_price =~ s/(\d+)\.$/$1/g ;
             $v_input_volume =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_input_volume =~ s/(\d+)\.$/$1/g ;
             $v_input_summ =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_input_summ =~ s/(\d+)\.$/$1/g ;
             $v_output_price =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_output_price =~ s/(\d+)\.$/$1/g ;
             $v_output_volume =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_output_volume =~ s/(\d+)\.$/$1/g ;
             $v_output_summ =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_output_summ =~ s/(\d+)\.$/$1/g ;
             $v_result_price =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_result_price =~ s/(\d+)\.$/$1/g ;
             $v_result_volume =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_result_volume =~ s/(\d+)\.$/$1/g ;
             $v_result_summ =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_result_summ =~ s/(\d+)\.$/$1/g ; $v_result_summ = nearest(0.0001, $v_result_summ) ;

             $profit_graph_start_date = "$v_input_time_point" ; $profit_graph_start_date =~ s/[\s-:]//g ;
             $profit_graph_stop_date = "$v_output_time_point" ; $profit_graph_stop_date =~ s/[\s-:]//g ;
             $v_input_time_point =~ s/\s/&nbsp;/g ;
             $v_output_time_point =~ s/\s/&nbsp;/g ;

             $cnt_color = "navy" ; if ( $v_vector eq "short" ) { $cnt_color = "red" ; } if ( $v_vector eq "long" ) { $cnt_color = "green" ; }
             $profit_mult = 1 ; if ($v_vector eq "short") { $profit_mult = -1 ; }
             $v_result_percent = nearest(0.01, ($v_result_summ * 100 / $v_input_summ )) ;
             my $v_result_color = "navy" ; $v_result_color = ( $v_result_percent > 0 ) ? "green" : "red" ;

             if ($v_status eq "open_contract" ) {
                $request = "SELECT TO_CHAR(timestamp_point + INTERVAL '3 hour', 'YYYY-MM-DD HH24:MI:SS'), price_close from crcomp_pair_ohlc_1m_history where currency = '$v_currency' AND reference_currency = '$v_reference_currency'
                                   AND timestamp_point = (SELECT MAX(timestamp_point) from crcomp_pair_ohlc_1m_history where currency = '$v_currency' AND reference_currency = '$v_reference_currency')" ;
#-debug-print "$request<BR>\n" ;
                my $dbh_h_last_record = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'pg_password_value') ; my $sth_h_last_record = $dbh_h_last_record->prepare($request) ; $sth_h_last_record->execute();
                my $v_last_timestamp_point ; my $v_last_price_close ; my $v_prognoze_sum ;
                ($v_last_timestamp_point, $v_last_price_close) = $sth_h_last_record->fetchrow_array() ;
#-debug-print "=== $v_last_timestamp_point, $v_last_price_close<BR>\n" ;
                $sth_h_last_record->finish() ; $dbh_h_last_record->disconnect() ;
                $v_last_price_close =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_last_price_close =~ s/(\d+)\.$/$1/g ;
                $v_prognoze_summ = $v_last_price_close * $v_input_volume ;
                $v_prognoze_summ_diff = nearest(0.00001, ( $v_prognoze_summ - $v_input_summ ) * $profit_mult) ;
                $v_prognoze_percent = nearest(0.01, ($v_prognoze_summ_diff * 100 / $v_input_summ )) ;
                $v_prognoze_color = "purple" ; $v_prognoze_color = ( $v_prognoze_summ_diff > 0 ) ? "green" : "red" ;
                $cnt_color = "purple" ;

                $v_result_price = $v_last_price_close ;
                $v_result_volume = $v_input_volume ;
                $v_result_summ = $v_prognoze_summ ;
                $v_result_percent = $v_prognoze_percent ;
                $v_result_color = $v_prognoze_color ;
                $profit_graph_stop_date = "last" ;
                }

             $agr_summ_result_percent += $v_result_percent ; $v_result_percent_leverage = $v_result_percent * $v_leverage ; $agr_summ_result_percent_leverage += $v_result_percent_leverage ; $agr_summ_count++ ; $agr_summ_summ += $v_result_summ ;

             if ($pv{rep_mode} eq "easy") {
                print "<TR><TD CLASS=\"td_left\" STYLE=\"font-size: 8pt;\">$v_currency</TD><TD CLASS=\"td_left\" STYLE=\"font-size: 8pt;\">$v_reference_currency</TD>
                           <TD CLASS=\"td_right\" STYLE=\"font-size: 8pt;\">$v_vector</TD><TD CLASS=\"td_center\">x$v_leverage</TD>
                           <TD CLASS=\"td_left\" STYLE=\"font-size: 8pt;\">$v_input_time_point</TD><TD CLASS=\"td_right\" STYLE=\"font-size: 8pt;\">$v_input_price</TD>
                           <TD CLASS=\"td_right\" STYLE=\"font-size: 8pt;\">$v_input_volume</TD><TD CLASS=\"td_right\" STYLE=\"font-size: 8pt;\">$v_input_summ</TD>
                           <TD CLASS=\"td_left\" STYLE=\"font-size: 8pt;\">$v_output_time_point</TD><TD CLASS=\"td_right\" STYLE=\"font-size: 8pt;\">$v_output_price</TD>
                           <TD CLASS=\"td_right\" STYLE=\"font-size: 8pt;\">$v_output_volume</TD><TD CLASS=\"td_right\" STYLE=\"font-size: 8pt;\">$v_output_summ</TD>
                           <TD CLASS=\"td_right\" STYLE=\"font-size: 8pt;\"><SPAN STYLE=\"color: $v_result_color;\">$v_result_percent%</SPAN></TD>
                           <TD CLASS=\"td_right\" STYLE=\"font-size: 8pt;\"><SPAN STYLE=\"color: $v_result_color;\">$v_result_percent_leverage%</SPAN></TD>
                           <TD CLASS=\"td_right\" STYLE=\"font-size: 8pt;\">$v_result_summ</TD></TR>" ;
                }
             else {
                print "<TR><TD ROWSPAN=\"11\"><SPAN STYLE=\"color: $cnt_color; font-size: 12pt;\">$v_currency/$v_reference_currency&nbsp;$v_vector</SPAN>
                                              <BR>статус:&nbsp;$v_status
                                              <BR>цикл:&nbsp;$v_cycle
                                              <BR><A HREF=\"cgi/tools_coin_contracts.cgi?currency=$v_currency&curr_reference=$v_reference_currency&cnt_rand_id=$v_rand_id&action=read\">id:&nbsp;$v_id,&nbsp;rand_id:
                                              <BR>$v_rand_id</A>
                                              <BR>user: $v_user_name</TD>
                           <TD COLSPAN=\"2\">Основание&nbsp;входа:&nbsp;$v_input_event_rand_id<BR>$states_base_inout{$v_input_base}</TD>
                           <TD>&nbsp;</TD><TD ROWSPAN=\"2\">Результат</TD><TD ROWSPAN=\"2\" COLSPAN=\"2\"><SPAN STYLE=\"color: $v_result_color; font-size:12pt;\">$v_result_percent%</SPAN></TD>
                           <TD>&nbsp;</TD><TD>EMA&nbsp;текущая</TD><TD>$v_ind_curr_ema_tf</TD><TD>$v_ind_curr_ema</TD>
                           <TD>&nbsp;</TD></TD><TD ROWSPAN=\"5\">
                               <A HREF=\"cgi/_graph_profit.cgi?currency=$v_currency&curr_reference=$v_reference_currency&start_date=$profit_graph_start_date&stop_date=$profit_graph_stop_date&start_price=$v_input_price&profit_mult=$profit_mult&output_type=graph&brush_size=4&x_size=1120&y_size=480\" TARGET=\"_blank\">
                                  <IMG CLASS=\"cnt_pre_result_graph\" SRC=\"cgi/_graph_profit.cgi?currency=$v_currency&curr_reference=$v_reference_currency&start_date=$profit_graph_start_date&stop_date=$profit_graph_stop_date&start_price=$v_input_price&profit_mult=$profit_mult&output_type=graph&brush_size=4&x_size=1120&y_size=480\"><BR>
                           </TD></TR>
                       <TR><TD>дата:</TD><TD>$v_input_time_point</TD>
                           <TD>&nbsp;</TD><TD>&nbsp;</TD><TD>Price&nbsp;текущая</TD><TD>$v_ind_curr_price_tf</TD><TD>$states_price{$v_ind_curr_price}</TD></TR>
                       <TR><TD>цена:</TD><TD>$v_input_price</TD>
                           <TD>&nbsp;</TD><TD>цена:</TD><TD COLSPAN=\"2\">$v_result_price</TD>
                           <TD>&nbsp;</TD><TD>MACD&nbsp;line</TD><TD>$v_ind_curr_macd_line_tf</TD><TD>$states_macd_line{$v_ind_curr_macd_line}</TD></TR>
                       <TR><TD>объём:</TD><TD>$v_input_volume</TD>
                           <TD>&nbsp;</TD><TD>объём:</TD><TD COLSPAN=\"2\">$v_result_volume</TD>
                           <TD>&nbsp;</TD><TD>MACD&nbsp;gist</TD><TD>$v_ind_curr_macd_gist_tf</TD><TD>$states_macd_gist{$v_ind_curr_macd_gist}</TD></TR>
                       <TR><TD>сумма:</TD><TD>$v_input_summ</TD>
                           <TD>&nbsp;</TD><TD>сумма:</TD><TD COLSPAN=\"2\">$v_result_summ</TD>
                           <TD>&nbsp;</TD><TD>RSI&nbsp;текущая</TD><TD>$v_ind_curr_rsi_tf</TD><TD>$states_rsi{$v_ind_curr_rsi}</TD></TR>
                       <TR><TD COLSPAN=\"11\"><HR></TD><TD COLSPAN=\"2\">&nbsp;</TD></TR>
                       <TR><TD COLSPAN=\"2\">Основание&nbsp;выхода:&nbsp;$v_output_event_rand_id<BR>$states_base_inout{$v_output_base}</TD>
                           <TD>&nbsp;</TD><TD>плечо:</TD><TD COLSPAN=\"2\">$v_leverage</TD>
                           <TD>&nbsp;</TD><TD>EMA&nbsp;старшая</TD><TD>$v_ind_own_ema_tf</TD><TD>$v_ind_own_ema</TD>
                           <TD>&nbsp;</TD><TD ROWSPAN=\"5\">$v_comments</TD></TR>
                       <TR><TD>дата</TD><TD>$v_output_time_point</TD>
                           <TD>&nbsp;</TD><TD>RMM SL:</TD><TD>$v_rmm_sl_prct\%</TD><TD>$v_rmm_sl</TD>
                           <TD>&nbsp;</TD><TD>Price&nbsp;старшая</TD><TD>$v_ind_own_price_tf</TD><TD>$states_price{$v_ind_own_price}</TD></TR>
                       <TR><TD>цена:</TD><TD>$v_output_price</TD>
                           <TD>&nbsp;</TD><TD>RMM TP:</TD><TD>$v_rmm_tp_prct\%</TD><TD>$v_rmm_tp</TD>
                           <TD>&nbsp;</TD><TD>MACD&nbsp;line</TD><TD>$v_ind_own_macd_line_tf</TD><TD>$states_macd_line{$v_ind_own_macd_line}</TD></TR>
                       <TR><TD>объём:</TD><TD>$v_output_volume</TD>
                           <TD>&nbsp;</TD><TD>RMM TGT:</TD><TD>$v_rmm_tgt_prct\%</TD><TD>$v_rmm_tgt</TD>
                           <TD>&nbsp;</TD><TD>MACD&nbsp;gist</TD><TD>$v_ind_own_macd_gist_tf</TD><TD>$states_macd_gist{$v_ind_own_macd_gist}</TD></TR>
                       <TR><TD>сумма:</TD><TD>$v_output_summ</TD>
                           <TD>&nbsp;</TD><TD>RMM R/R:</TD><TD COLSPAN=\"2\">$v_rmm_risk/$v_rmm_revard</TD>
                           <TD>&nbsp;</TD><TD>RSI&nbsp;старшая</TD><TD>$v_ind_own_rsi_tf</TD><TD>$states_rsi{$v_ind_own_rsi}</TD></TR>
                       <TR><TD COLSPAN=\"13\"><HR></TD></TR>" ;
                }
             }

       if ($pv{rep_mode} eq "easy") {
          $agr_summ_summ = nearest(0.01, $agr_summ_summ) ;
          print "<TR><TD CLASS=\"td_left\" STYLE=\"font-size: 8pt;\" COLSPAN=\"2\">Итого</TD>
                     <TD CLASS=\"td_left\" STYLE=\"font-size: 8pt;\" COLSPAN=\"10\">$agr_summ_count сделок</TD>
                     <TD CLASS=\"td_right\" STYLE=\"font-size: 8pt;\">$agr_summ_result_percent%</TD>
                     <TD CLASS=\"td_right\" STYLE=\"font-size: 8pt;\">$agr_summ_result_percent_leverage%</TD>
                     <TD CLASS=\"td_right\" STYLE=\"font-size: 8pt;\">$agr_summ_summ</TD></TR>" ;
                 }
       print "</TABLE>" ;
       $sth_h->finish() ; $dbh_h->disconnect() ;
#-debug-print "<BR>====$v_id, $v_rand_id, $v_status, $v_cycle, $v_currency, $v_reference_currency, $v_vector, $v_leverage, $v_rmm_sl_prct, $v_rmm_sl, $v_rmm_tp_prct, $v_rmm_tp, $v_rmm_tgt_prct, $v_rmm_tgt,
# $v_rmm_risk, $v_rmm_revard, $v_input_base, $v_input_event_rand_id, $v_input_time_point, $v_input_price, $v_input_volume, $v_input_summ, $v_ind_curr_ema_tf, $v_ind_curr_ema, $v_ind_own_ema_tf, $v_ind_own_ema,
# $v_ind_curr_price_tf, $v_ind_curr_price, $v_ind_own_price_tf, $v_ind_own_price, $v_ind_curr_macd_line_tf, $v_ind_curr_macd_line, $v_ind_own_macd_line_tf, $v_ind_own_macd_line, $v_ind_curr_macd_gist_tf, $v_ind_curr_macd_gist,
# $v_ind_own_macd_gist_tf, $v_ind_own_macd_gist, $v_ind_curr_rsi_tf, $v_ind_curr_rsi, $v_ind_own_rsi_tf, $v_ind_own_rsi, $v_output_base, $v_output_event_rand_id, $v_output_time_point, $v_output_price, $v_output_volume,
# $v_output_summ, $v_result_price, $v_result_volume, $v_result_summ, $v_result_percent, $v_comments<BR>" ;
      }

   if ( $pv{action} eq "open_contracts_list" ) {
      $where_extension = "" ;
      if ($pv{user_name} ne "" && $pv{user_name} ne "undefined") { $where_extension .= " AND user_name = '$pv{user_name}' " ; }
      if ($pv{cntrct_status} ne "" ) { $where_extension .= " AND contract_status = '$pv{cntrct_status}' " ; }
      if ($pv{cntrct_cycles} ne "" ) {
         if ( $pv{cntrct_cycles} eq "trading" ) { $where_extension .= " AND not cycle = 'invest' " ; }
         if ( $pv{cntrct_cycles} eq "invest" ) { $where_extension .= " AND cycle = 'invest' " ; }
         }
      if ($pv{currency} ne "ALL" ) { $where_extension .= " AND currency = '$pv{currency}' " ; }
      if ($pv{curr_reference} eq "USDT" || $pv{curr_reference} eq "BTC" ) { $where_extension .= " AND reference_currency = '$pv{curr_reference}' " ; }
      $request = "SELECT user_name, user_id, contract_id, contract_rand_id, contract_status, contract_leverage, cycle, currency, reference_currency, contract_vector, rmm_sl_prct, rmm_sl, rmm_tp_prct, rmm_tp, rmm_tgt_prct, rmm_tgt,
 rmm_risk, rmm_revard, input_base, input_event_rand_id, TO_CHAR(input_time_point,'YYYY-MM-DD HH24:MI:SS'), input_price, input_volume, input_summ, ind_curr_ema_tf, ind_curr_ema, ind_own_ema_tf, ind_own_ema,
 ind_curr_price_tf, ind_curr_price, ind_own_price_tf, ind_own_price, ind_curr_macd_line_tf, ind_curr_macd_line, ind_own_macd_line_tf, ind_own_macd_line, ind_curr_macd_gist_tf, ind_curr_macd_gist, ind_own_macd_gist_tf,
 ind_own_macd_gist, ind_curr_rsi_tf, ind_curr_rsi, ind_own_rsi_tf, ind_own_rsi,output_base, output_event_rand_id, TO_CHAR(output_time_point,'YYYY-MM-DD HH24:MI:SS'), output_price, output_volume, output_summ,
 result_price, result_volume, result_summ, result_percent, comments
 from contracts_history WHERE contract_status = 'open_contract' $where_extension order by currency asc, contract_id asc" ;
# from contracts_history WHERE contract_status = 'open_contract' $where_extension order by contract_id desc" ;
#-debug-print "$request<BR>\n" ;
      my $dbh_h = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'pg_password_value') ; my $sth_h = $dbh_h->prepare($request) ; $sth_h->execute();


      print "<STYLE>
TD { font-size: 8pt; margin: 0pt 5pt 0pt 5pt; padding: 0pt 5pt 0pt 5pt; }
</STYLE>
<TABLE BORDER=\"0\" WIDTH=\"100%\">
<TR><TD CLASS=\"td_head\">Общие</TD>
    <TD CLASS=\"td_head\" COLSPAN=\"3\">Риск мани<BR>менеджмент</TD>
    <TD CLASS=\"td_head\" COLSPAN=\"2\">Вход в<BR>сделку</TD>
    <TD CLASS=\"td_head\" COLSPAN=\"2\">Промежуточный<BR>результат сделки</TD>
    <TD CLASS=\"td_head\">График прибылей и убытков</TD>
    <TD CLASS=\"td_head\">Коментарии</TD></TR>
    <TR><TD COLSPAN=\"17\"><HR></TD></TR>" ;
       while (my($v_user_name, $v_user_id, $v_id, $v_rand_id, $v_status, $v_leverage, $v_cycle, $v_currency, $v_reference_currency, $v_vector, $v_rmm_sl_prct, $v_rmm_sl, $v_rmm_tp_prct, $v_rmm_tp, $v_rmm_tgt_prct, $v_rmm_tgt, $v_rmm_risk,  $v_rmm_revard, $v_input_base, $v_input_event_rand_id, $v_input_time_point, $v_input_price, $v_input_volume, $v_input_summ, $v_ind_curr_ema_tf, $v_ind_curr_ema, $v_ind_own_ema_tf, $v_ind_own_ema,  $v_ind_curr_price_tf, $v_ind_curr_price, $v_ind_own_price_tf, $v_ind_own_price, $v_ind_curr_macd_line_tf, $v_ind_curr_macd_line, $v_ind_own_macd_line_tf, $v_ind_own_macd_line, $v_ind_curr_macd_gist_tf,  $v_ind_curr_macd_gist, $v_ind_own_macd_gist_tf, $v_ind_own_macd_gist, $v_ind_curr_rsi_tf, $v_ind_curr_rsi, $v_ind_own_rsi_tf, $v_ind_own_rsi, $v_output_base, $v_output_event_rand_id, $v_output_time_point,  $v_output_price, $v_output_volume, $v_output_summ, $v_result_price, $v_result_volume, $v_result_summ, $v_result_percent, $v_comments) = $sth_h->fetchrow_array()) {
             $v_rmm_sl =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_rmm_sl =~ s/(\d+)\.$/$1/g ;
             $v_rmm_tp =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_rmm_tp =~ s/(\d+)\.$/$1/g ;
             $v_rmm_tgt =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_rmm_tgt =~ s/(\d+)\.$/$1/g ;
             $v_input_price =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_input_price =~ s/(\d+)\.$/$1/g ;
             $v_input_volume =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_input_volume =~ s/(\d+)\.$/$1/g ;
             $v_input_summ =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_input_summ =~ s/(\d+)\.$/$1/g ;
             $v_output_price =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_output_price =~ s/(\d+)\.$/$1/g ;
             $v_output_volume =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_output_volume =~ s/(\d+)\.$/$1/g ;
             $v_output_summ =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_output_summ =~ s/(\d+)\.$/$1/g ;
             $v_result_price =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_result_price =~ s/(\d+)\.$/$1/g ;
             $v_result_volume =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_result_volume =~ s/(\d+)\.$/$1/g ;
             $v_result_summ =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_result_summ =~ s/(\d+)\.$/$1/g ;
             $cnt_color = "navy" ; if ( $v_vector eq "short" ) { $cnt_color = "red" ; } if ( $v_vector eq "long" ) { $cnt_color = "green" ; }
             $profit_graph_start_date = "$v_input_time_point" ; $profit_graph_start_date =~ s/[\s-:]//g ;
             $profit_graph_stop_date = "$v_output_time_point" ; $profit_graph_stop_date =~ s/[\s-:]//g ;
             $profit_mult = 1 ; if ($v_vector eq "short") { $profit_mult = -1 ; }

             $request = "SELECT TO_CHAR(timestamp_point + INTERVAL '3 hour', 'YYYY-MM-DD HH24:MI:SS'), price_close from crcomp_pair_ohlc_1m_history where currency = '$v_currency' AND reference_currency = '$v_reference_currency'
                                AND timestamp_point = (SELECT MAX(timestamp_point) from crcomp_pair_ohlc_1m_history where currency = '$v_currency' AND reference_currency = '$v_reference_currency')" ;
#-debug-print "$request<BR>\n" ;
             my $dbh_h_last_record = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'pg_password_value') ; my $sth_h_last_record = $dbh_h_last_record->prepare($request) ; $sth_h_last_record->execute();
             my $v_last_timestamp_point ; my $v_last_price_close ; my $v_prognoze_sum ;
             ($v_last_timestamp_point, $v_last_price_close) = $sth_h_last_record->fetchrow_array() ;
#-debug-print "=== $v_last_timestamp_point, $v_last_price_close<BR>\n" ;
             $sth_h_last_record->finish() ; $dbh_h_last_record->disconnect() ;
             $v_last_price_close =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_last_price_close =~ s/(\d+)\.$/$1/g ;
             $v_prognoze_summ = $v_last_price_close * $v_input_volume ;
             $v_prognoze_summ_diff = nearest(0.00001, ( $v_prognoze_summ - $v_input_summ ) * $profit_mult) ;
#             $v_prognoze_percent = nearest(0.01, ($v_prognoze_summ_diff * 100 / ($v_input_summ + $v_prognoze_summ_diff/1000) )) ;
             if ( $v_input_summ == 0 ) { $v_input_summ = 1000000 ; }
             $v_prognoze_percent = nearest(0.01, ($v_prognoze_summ_diff * 100 / $v_input_summ )) ;
             $v_prognoze_color = "purple" ; $v_prognoze_color = ( $v_prognoze_summ_diff > 0 ) ? "green" : "red" ;

             print "<TR><TD ROWSPAN=\"5\"><SPAN STYLE=\"color: $cnt_color; font-size: 12pt;\">$v_currency/$v_reference_currency&nbsp;$v_vector</SPAN><BR>статус:&nbsp;$v_status<BR>цикл:&nbsp;$v_cycle<BR><A HREF=\"cgi/tools_coin_contracts.cgi?currency=$v_currency&curr_reference=$v_reference_currency&cnt_rand_id=$v_rand_id&action=read\">id:&nbsp;$v_id,&nbsp;rand_id:<BR>$v_rand_id</A><BR>user: $v_user_name</TD>
                        <TD>плечо:</TD><TD COLSPAN=\"2\" STYLE=\"text-align: center; font-size:12pt;\">x$v_leverage</TD><TD COLSPAN=\"2\">Основание входа:&nbsp;$v_input_event_rand_id<BR>$states_base_inout{$v_input_base}</TD>
                        <TD STYLE=\"color: $v_prognoze_color; font-size:12pt;\">$v_prognoze_percent\%</TD><TD STYLE=\"color: $v_prognoze_color ; font-size:12pt;\">$v_prognoze_summ_diff</TD>
                        <TD ROWSPAN=\"5\">
                            <A HREF=\"cgi/_graph_profit.cgi?currency=$v_currency&curr_reference=$v_reference_currency&start_date=$profit_graph_start_date&stop_date=last&start_price=$v_input_price&profit_mult=$profit_mult&output_type=graph&brush_size=4&x_size=1120&y_size=480\" TARGET=\"_blank\">
                               <IMG CLASS=\"cnt_pre_result_graph\" SRC=\"cgi/_graph_profit.cgi?currency=$v_currency&curr_reference=$v_reference_currency&start_date=$profit_graph_start_date&stop_date=last&start_price=$v_input_price&profit_mult=$profit_mult&output_type=graph&brush_size=4&x_size=1120&y_size=480\"><BR>
                        </TD>
                        <TD ROWSPAN=\"5\" STYLE=\"font-size: 7pt;\">$v_comments</TD></TR>
                    <TR><TD>SL:</TD><TD>$v_rmm_sl_prct\%</TD><TD>$v_rmm_sl</TD><TD>дата:</TD><TD>$v_input_time_point</TD><TD>дата</TD><TD>$v_last_timestamp_point$v_result_percent</TD></TR>
                    <TR><TD>TP:</TD><TD>$v_rmm_tp_prct\%</TD><TD>$v_rmm_tp</TD><TD>цена:</TD><TD>$v_input_price</TD><TD>цена:</TD><TD>$v_last_price_close</TD></TR>
                    <TR><TD>TGT:</TD><TD>$v_rmm_tgt_prct\%</TD><TD>$v_rmm_tgt</TD><TD>объём:</TD><TD>$v_input_volume</TD><TD>объём:</TD><TD>$v_input_volume</TD></TR>
                    <TR><TD>R/R:</TD><TD COLSPAN=\"2\">$v_rmm_risk/$v_rmm_revard</TD><TD>сумма:</TD><TD>$v_input_summ</TD><TD>сумма:</TD><TD>$v_prognoze_summ</TD></TR>
                    <TR><TD COLSPAN=\"17\"><HR></TD></TR>" ;
             }
       print "</TABLE>" ;
       $sth_h->finish() ; $dbh_h->disconnect() ;
      }

   }

print "<!-- конец таблицы второго уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы первого уровня вкладок --></TD></TR></TABLE>\n" ;
print_foother1() ;
