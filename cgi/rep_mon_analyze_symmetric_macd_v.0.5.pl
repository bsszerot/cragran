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

# параметры по умолчанию

# - вытащить из URL запроса значения уточняющих полей
&get_forms_param() ;
$pv{count_prds} = $pv{period_days} ;

$CURR_YEAR = `date +%Y` ; $CURR_YEAR =~ s/[\r\n]+//g ;
$count_rows = 0 ;

my $sz_filter_one_coin = "" ;
$sz_filter_one_coin = $sz_filter_one_coin." AND mev.event_name = '$pv{event_name}' and mev.event_tf = '$pv{event_tf}' " ;
if ($pv{currency} ne "ALL") {
   $sz_filter_one_coin = $sz_filter_one_coin." AND mev.currency = '$pv{currency}' and mev.reference_currency = '$pv{curr_reference}' " ;
   }

$request = " " ;
$request = "select src_base.event_id, src_base.currency main_curr, src_base.reference_currency ref_curr, src_base.event_name event, src_base.event_vector vector,
       date_trunc('minute', src_base.timestamp_point) time_point, src_base.price_close,
       date_trunc('minute', lag(src_base.timestamp_point)
                               OVER (PARTITION BY src_base.currency, src_base.reference_currency
                               ORDER BY src_base.timestamp_point DESC)) as next_timestamp,
       lag(src_base.price_close)
          OVER (PARTITION BY src_base.currency, src_base.reference_currency
          ORDER BY src_base.timestamp_point DESC) as next_price_close,
       CASE WHEN (event_vector = 'UP') THEN
            (lag(src_base.price_close)
                OVER (PARTITION BY src_base.currency, src_base.reference_currency
                ORDER BY src_base.timestamp_point DESC) - src_base.price_close)
       ELSE
            (lag(src_base.price_close)
                OVER (PARTITION BY src_base.currency, src_base.reference_currency
                ORDER BY src_base.timestamp_point DESC) - src_base.price_close) * -1
       END as diff_price,
       CASE WHEN (event_vector = 'UP') THEN ROUND(
            (lag(src_base.price_close)
                OVER (PARTITION BY src_base.currency, src_base.reference_currency
                ORDER BY src_base.timestamp_point DESC) - src_base.price_close)/(src_base.price_close/100),2)
       ELSE ROUND(
            (lag(src_base.price_close)
                OVER (PARTITION BY src_base.currency, src_base.reference_currency
                ORDER BY src_base.timestamp_point DESC) - src_base.price_close)/(src_base.price_close/100) * -1,2)
       END as diff_prcnt,
       date_trunc('minute', lag(src_base.tsp_shift)
                               OVER (PARTITION BY src_base.currency, src_base.reference_currency
                               ORDER BY src_base.tsp_shift DESC)) as next_timestamp_shift,
       lag(src_base.price_close_shift)
          OVER (PARTITION BY src_base.currency, src_base.reference_currency
          ORDER BY src_base.tsp_shift DESC) as next_price_close_shift,
       CASE WHEN (event_vector = 'UP') THEN
            (lag(src_base.price_close_shift)
                OVER (PARTITION BY src_base.currency, src_base.reference_currency
                ORDER BY src_base.tsp_shift DESC) - src_base.price_close)
       ELSE
            (lag(src_base.price_close_shift)
                OVER (PARTITION BY src_base.currency, src_base.reference_currency
                ORDER BY src_base.tsp_shift DESC) - src_base.price_close) * -1
       END as diff_price_shift,
       CASE WHEN (event_vector = 'UP') THEN ROUND(
            (lag(src_base.price_close_shift)
                OVER (PARTITION BY src_base.currency, src_base.reference_currency
                ORDER BY src_base.tsp_shift DESC) - src_base.price_close)/(src_base.price_close/100),2)
       ELSE ROUND(
            (lag(src_base.price_close_shift)
                OVER (PARTITION BY src_base.currency, src_base.reference_currency
                ORDER BY src_base.tsp_shift DESC) - src_base.price_close)/(src_base.price_close/100) * -1,2)
       END as diff_prcnt_shift
       from 
(select ohlc1m.timestamp_point tsp1, ohlc1m.price_close price_close, ohlc1m2.timestamp_point tsp_shift, ohlc1m2.price_close price_close_shift, mev.*
        from mon_events mev, crcomp_pair_ohlc_1m_history ohlc1m, crcomp_pair_ohlc_1m_history ohlc1m2
       where date_trunc('minute', mev.timestamp_point) = date_trunc('minute', ohlc1m.timestamp_point)
             AND mev.currency = ohlc1m.currency AND mev.reference_currency = ohlc1m.reference_currency
             AND date_trunc('minute', mev.timestamp_point - INTERVAL '1 hours') = date_trunc('minute', ohlc1m2.timestamp_point)
             AND mev.currency = ohlc1m2.currency AND mev.reference_currency = ohlc1m2.reference_currency $sz_filter_one_coin
             ) src_base " ;

print "Content-Type: text/html\n\n" ;

system("cat $COMM_PAR_BASE_WEB_PATH/includes/header1_1_cgi.shtml") ;
print "REP ZRT КрАгрАн БЕССТ" ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/header1_2_cgi.shtml") ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/main_menu.shtml") ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/header2_1_cgi.shtml") ;

print_js_block_common() ;
print_js_block_trading() ;

print_main_page_title("Отчёты и аналитика", "Симметричный [вход выход] отчёт эффективности единичной индикаторной торговли") ;
print_tools_coin_navigation(7) ;

#-debug-print "<PRE>$request</PRE>" ;

print "<!-- таблица первого уровня вкладок -->
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD><BR>" ;

print_reports_coin_navigation(3,"rep_mon_analyze_symmetric_macd.cgi","События мониторинга, оценка прибыли по фильтрам:<BR> EVENT $pv{event_name}, ТФ $pv{event_tf}, COIN $pv{currency}, REF $pv{curr_reference}, MODE $pv{rep_mode}") ;
print "<!-- таблица второго уровня вкладок -->
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD>&nbsp;<BR>" ;

print_coin_links_map("rep_mon_analyze_symmetric_macd.cgi") ;

#print "<BR><P>Варианты отображения:
#&nbsp;<A HREF=\"cgi/rep_mon_analyze_symmetric_macd.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}&rep_mode=full&event_name=$pv{event_name}&event_tf=$pv{event_tf}\">[показывать всё]</A>
#&nbsp;<A HREF=\"cgi/rep_mon_analyze_symmetric_macd.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}&rep_mode=group&event_name=$pv{event_name}&event_tf=$pv{event_tf}\">[только группировка]</A></P>

print "<P STYLE=\"font-size: 8pt;\">Краткое описание отчёта:<BR>
<BR>Основная задача отчёта - показать монеты, по которым есть прилично больше положительных событий, каждое из которых в среднем даёт приличный прирост процентов
<BR>
<BR>Отчёт собирает цены в точках сигнала и показывает потенциальную прибыли и убыток. Так как точное время между широкими свечами
<BR>подобрать затруднительно, делается два расчёта - на точки выявления событий пересечения и на точку окончания на 2 часа раньше
<BR>порядок времени построения отчёта по всем монетам - 10 минут на текущем железе
<BR>&nbsp;</P></TD></TR>
<TR><TD><TABLE BORDER=\"1\" STYLE=\"width: 100%;\">" ;

# отображаем заголовки таблиц для группового и детального режима
if ($pv{rep_mode} ne "group") {
   printf("<TR><TD CLASS=\"head\">Монета</TD><TD CLASS=\"head\">Референсная</TD><TD CLASS=\"head\">Событие</TD><TD CLASS=\"head\">Вектор</TD><TD CLASS=\"head\">Время</TD><TD CLASS=\"head\">Цена</TD>
        <TD CLASS=\"head\">Следующее время события</TD><TD CLASS=\"head\">Следующая цена</TD><TD CLASS=\"head\">Прибыль или убыток</TD><TD CLASS=\"head\">Процент прибыли или убытка</TD>
        <TD CLASS=\"head\">Следующее время события со сдвижкой</TD><TD CLASS=\"head\">Следующая цена со сдвижкой</TD><TD CLASS=\"head\">Прибыль или убыток со сдвижкой</TD><TD CLASS=\"head\">Процент прибыли или убытка со сдвижкой</TD>
        </TR>") ; }
else {
   printf("<TR><TD CLASS=\"head\" ROWSPAN=\"3\">Монета</TD><TD CLASS=\"head\" ROWSPAN=\"3\">Референсная</TD><TD CLASS=\"head\" ROWSPAN=\"3\">Событие</TD><TD CLASS=\"head\" COLSPAN=\"10\">Вход и выход в момент события</TD><TD CLASS=\"head\" COLSPAN=\"8\">Выход раньше со сдвижкой</TD></TR>
           <TR><TD CLASS=\"head\" COLSPAN=\"2\">Убытки</TD><TD CLASS=\"head\" COLSPAN=\"2\">Прибыли</TD><TD CLASS=\"head\" COLSPAN=\"4\">Разница</TD><TD CLASS=\"head\" COLSPAN=\"2\">Результат</TD><TD CLASS=\"head\" COLSPAN=\"2\">Убытки</TD><TD CLASS=\"head\" COLSPAN=\"2\">Прибыли</TD><TD CLASS=\"head\" COLSPAN=\"2\">Разница</TD><TD CLASS=\"head\" COLSPAN=\"2\">Результат</TD></TR>
           <TR><TD CLASS=\"head\">Событий</TD><TD CLASS=\"head\">\%</TD><TD CLASS=\"head\">Событий</TD><TD CLASS=\"head\">\%</TD><TD CLASS=\"head\">Выирышных<BR>cобытий, шт.</TD><TD CLASS=\"head\">Выирышных<BR>cобытий, \%</TD><TD CLASS=\"head\">Прибыль,<BR> \%/событие</TD><TD CLASS=\"head\">\% прибыли</TD><TD CLASS=\"head\">Событий</TD><TD CLASS=\"head\">\% х</TD>
               <TD CLASS=\"head\">Событий</TD><TD CLASS=\"head\">\%</TD><TD CLASS=\"head\">Событий</TD><TD CLASS=\"head\">\%</TD><TD CLASS=\"head\">Событий</TD><TD CLASS=\"head\">\%</TD><TD CLASS=\"head\">Событий</TD><TD CLASS=\"head\">\%</TD>
           </TR>") ; }

my $prev_currency = "" ; my $prev_ref_currency = "" ;

# счётчики событий - всего, разницы выхода в моменте, разницы выхода со сдвижкой
my $group_count = 0 ; my $group_diff_count = 0 ; my $group_diff_prct = 0 ; my $group_diff_count_shift = 0 ; my $group_diff_prct_shift = 0 ;
# счётчики событий и проценты разницы - плюсовые и минусовые
my $group_plus_count = 0 ; my $group_plus_diff_prct = 0 ; my $group_plus_count_shift = 0 ; my $group_plus_diff_prct_shift = 0 ;
my $group_minus_count = 0 ; my $group_minus_diff_prct = 0 ; my $group_plus_count_shift = 0 ; my $group_minus_diff_prct_shift = 0 ;
# переменные цветовыделения
my $group_diff_count_color = "green" ; my $group_diff_prct_color = "green" ; my $group_diff_count_color_shift = "green" ; my $group_diff_prct_color_shift = "green" ;

my $group_diff_record_prcnt ; my $group_diff_count_event ; my $group_diff_percent_per_event ;


my $dbh_h = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'pg_password_value' ) ;
my $sth_h = $dbh_h->prepare($request) ; $sth_h->execute(); $count_rows = 0 ;

my $event_id ; my $main_curr ; my $ref_curr ; my $event ; my $vector ; my $time_point ; my $price_close ; my $next_timestamp ; my $next_price_close ; my $diff_price ; my $diff_prcnt ; my $next_timestamp_shift ; my $next_price_close_shift ; my $diff_price_shift ; my $diff_prcnt_shift ;
while (($event_id, $main_curr, $ref_curr, $event, $vector, $time_point, $price_close, $next_timestamp, $next_price_close, $diff_price, $diff_prcnt, $next_timestamp_shift, $next_price_close_shift, $diff_price_shift, $diff_prcnt_shift) = $sth_h->fetchrow_array() ) {
      $time_point =~ s/\s/&nbsp;/g ;
      $price_close =~ s/(.*[^0])(0+)$/$1/g ;
      $next_timestamp =~ s/\s/&nbsp;/g ; $next_price_close =~ s/(.*[^0])(0+)$/$1/g ; $diff_price =~ s/(.*[^0])(0+)$/$1/g ;
      $next_timestamp_shift =~ s/\s/&nbsp;/g ; $next_price_close_shift =~ s/(.*[^0])(0+)$/$1/g ; $diff_price_shift =~ s/(.*[^0])(0+)$/$1/g ;

      if ( $prev_currency eq "" or $prev_currency ne $main_curr ) {
         if ( $prev_currency ne "" ) {
# непонятен смыст инкремента здесь, ведь увеличение ниже есть сразу, с первой записи, а одна запись всяко без пары. Получается на 1 событие больше - 
            $group_count++ ;
            $group_diff_count = $group_plus_count - $group_minus_count ; $group_diff_prct = $group_plus_diff_prct + $group_minus_diff_prct ;
            $group_diff_count_color = "green" ; if ( $group_diff_count <= 0 ) { $group_diff_count_color = "red" ; }
            $group_diff_prct_color = "green" ; if ( $group_diff_prct <= 0  ) { $group_diff_prct_color = "red" ; }
            $group_diff_count_shift = $group_plus_count_shift - $group_minus_count_shift ; $group_diff_prct_shift = $group_plus_diff_prct_shift + $group_minus_diff_prct_shift ;
            $group_diff_count_color_shift = "green" ; if ( $group_diff_count_shift <= 0 ) { $group_diff_count_color_shift = "red" ; }
            $group_diff_prct_color_shift = "green" ; if ( $group_diff_prct_shift <= 0 ) { $group_diff_prct_color_shift = "red" ; }

            if ($pv{rep_mode} ne "group") {
               printf("<TR><TD STYLE=\"color: green;\">$prev_currency</TD>
                           <TD STYLE=\"color: green;\">$prev_ref_currency</TD>
                           <TD STYLE=\"color: green;\">$pv{event_name}</TD>
                           <TD STYLE=\"color: green;\" COLSPAN=\"6\">Итого ($group_count)</TD>
                           <TD STYLE=\"color: $group_diff_prct_color;\" CLASS=\"td_right\">%0.2f</TD>
                           <TD STYLE=\"color: $group_diff_prct_color_shift;\" COLSPAN=\"6\" CLASS=\"td_right\">%0.2f</TD>
                       </TR>", $group_diff_prct, $group_diff_prct_shift) ; }
            else {
# процент выигрышных записей от всех
            $local_count_event = $group_plus_count + $group_minus_count ; if ( $local_count_event == 0 ) { $local_count_event = 1 ; } $group_diff_record_prcnt = $group_diff_count * 100 / $local_count_event ;
# для целей расчёта процентов и избежания деления на 0 отдельная переменная
            $group_diff_count_event = $group_diff_count ; if ($group_diff_count_event == 1 ) { $group_diff_count_event = 2 ; } 
            $group_diff_percent_per_event = $group_diff_prct / ($group_diff_count_event - 1) ;
            printf("<TR><TD STYLE=\"font-size: 8pt;\">$prev_currency</TD>
                        <TD STYLE=\"font-size: 8pt;\">$prev_ref_currency</TD>
                        <TD STYLE=\"font-size: 8pt;\">$event</TD>

                        <TD STYLE=\"font-size: 8pt;\" CLASS=\"td_right\">%d</TD><TD STYLE=\"font-size: 8pt;\" CLASS=\"td_right\">%0.2f</TD>
                        <TD STYLE=\"font-size: 8pt;\" CLASS=\"td_right\">%d</TD><TD STYLE=\"font-size: 8pt;\" CLASS=\"td_right\">%0.2f</TD>
                        <TD STYLE=\"color: $group_diff_count_color;\" CLASS=\"td_right\">%d</TD><TD CLASS=\"td_right\">%0.2f</TD>
                            <TD STYLE=\"color: $group_diff_prct_color;\" CLASS=\"td_right\">%0.2f</TD><TD STYLE=\"color: $group_diff_prct_color;\" CLASS=\"td_right\">%0.2f</TD>
                        <TD STYLE=\"color: $group_diff_prct_color; font-size: 8pt;\" CLASS=\"td_right\">%d</TD><TD STYLE=\"color: $group_diff_prct_color; font-size: 8pt;\" CLASS=\"td_right\">%0.2f</TD>

                        <TD STYLE=\"font-size: 8pt;\" CLASS=\"td_right\">%d</TD><TD STYLE=\"font-size: 8pt;\" CLASS=\"td_right\">%0.2f</TD>
                        <TD STYLE=\"font-size: 8pt;\" CLASS=\"td_right\">%d</TD><TD STYLE=\"font-size: 8pt;\" CLASS=\"td_right\">%0.2f</TD>
                        <TD STYLE=\"color: $group_diff_count_color_shift;\" CLASS=\"td_right\">%d</TD><TD STYLE=\"color: $group_diff_prct_color_shift;\" CLASS=\"td_right\">%0.2f</TD><TD STYLE=\"color: $group_diff_prct_color_shift;\" CLASS=\"td_right\">%0.2f</TD>
                        <TD STYLE=\"color: $group_diff_prct_color_shift; font-size: 8pt;\" CLASS=\"td_right\">%d</TD><TD STYLE=\"color: $group_diff_prct_color_shift; font-size: 8pt;\" CLASS=\"td_right\">%0.2f</TD>
                    </TR>", $group_minus_count, $group_minus_diff_prct, $group_plus_count, $group_plus_diff_prct, $group_diff_count, $group_diff_record_prcnt, $group_diff_percent_per_event, $group_diff_prct, $group_count, $group_diff_prct,
                            $group_minus_count_shift, $group_minus_diff_prct_shift, $group_plus_count_shift, $group_plus_diff_prct_shift, $group_diff_count_shift, $group_diff_prct_shift, $group_count, $group_diff_prct_shift) ; }
            }
# сбрасываем значения накопителей для новой группы
         $prev_currency = $main_curr ; $prev_ref_currency = $ref_curr ;
         $group_count = 0 ; $group_diff_prct = 0 ; $group_diff_prct_shift = 0 ;
         $group_plus_count = 0 ; $group_plus_diff_prct = 0 ; $group_plus_count_shift = 0 ; $group_plus_diff_prct_shift = 0 ;
         $group_minus_count = 0 ; $group_minus_diff_prct = 0 ; $group_minus_count_shift = 0 ; $group_minus_diff_prct_shift = 0 ;
         }
      $group_count++ ; $group_diff_prct += $diff_prcnt ; $group_diff_prct_shift += $diff_prcnt_shift ;
      if ( $diff_prcnt > 0 ) { $group_plus_count++ ; $group_plus_diff_prct += $diff_prcnt ; } if ( $diff_prcnt_shift > 0 ) { $group_plus_count_shift++ ; $group_plus_diff_prct_shift += $diff_prcnt_shift ; }
      if ( $diff_prcnt < 0 ) { $group_minus_count++ ; $group_minus_diff_prct += $diff_prcnt ; } if ( $diff_prcnt_shift < 0 ) { $group_minus_count_shift++ ; $group_minus_diff_prct_shift += $diff_prcnt_shift ; }

      if ($pv{rep_mode} ne "group") {
         printf("<TR><TD><A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_trading.cgi?currency=$main_curr&curr_reference=$ref_curr\">$main_curr</A></TD>
                     <TD>$ref_curr</TD>
                     <TD><A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_monitoring.cgi?currency=$main_curr&curr_reference=$ref_curr#id_$event_id\">$event</A></TD>
                     <TD>$vector</TD>
                     <TD CLASS=\"td_right\">$time_point</TD>
                     <TD CLASS=\"td_right\">$price_close</TD>
                     <TD CLASS=\"td_right\">$next_timestamp</TD>
                     <TD CLASS=\"td_right\">$next_price_close</TD>
                     <TD CLASS=\"td_right\">$diff_price</TD>
                     <TD CLASS=\"td_right\">$diff_prcnt</TD>
                     <TD CLASS=\"td_right\">$next_timestamp_shift</TD>
                     <TD CLASS=\"td_right\">$next_price_close_shift</TD>
                     <TD CLASS=\"td_right\">$diff_price_shift</TD>
                     <TD CLASS=\"td_right\">$diff_prcnt_shift</TD>
                 </TR>") ;
         }
      $count_rows += 1 ;
      }
$sth_h->finish() ;
$dbh_h->disconnect() ;

# отображение последней групповой записи
$group_diff_count = $group_plus_count - $group_minus_count ; $group_diff_prct = $group_plus_diff_prct + $group_minus_diff_prct ;
$group_diff_count_shift = $group_plus_count_shift - $group_minus_count_shift ; $group_diff_prct_shift = $group_plus_diff_prct_shift + $group_minus_diff_prct_shift ;
$group_diff_count_color = "green" ; if ( $group_diff_count <= 0 ) { $group_diff_count_color = "red" ; }
$group_diff_prct_color = "green" ; if ( $group_diff_prct <= 0  ) { $group_diff_prct_color = "red" ; }
$group_diff_count_color_shift = "green" ; if ( $group_diff_count_shift <= 0 ) { $group_diff_count_color_shift = "red" ; }
$group_diff_prct_color_shift = "green" ; if ( $group_diff_prct_shift <= 0 ) { $group_diff_prct_color_shift = "red" ; }

if ($pv{rep_mode} ne "group") {
   printf("<TR><TD STYLE=\"color: green;\">$prev_currency</TD>
               <TD STYLE=\"color: green;\">$prev_ref_currency</TD>
               <TD STYLE=\"color: green;\">$pv{event_name}</TD>
               <TD STYLE=\"color: green;\" COLSPAN=\"6\">Итого ($group_count)</TD>
               <TD STYLE=\"color: $group_diff_prct_color;\" CLASS=\"td_right\">%0.2f</TD>
               <TD STYLE=\"color: $group_diff_prct_color_shift;\" COLSPAN=\"6\" CLASS=\"td_right\">%0.2f</TD>
           </TR>", $group_diff_prct, $group_diff_prct_shift) ; }
else {
printf("<TR><TD STYLE=\"font-size: 8pt;\">$prev_currency</TD>
            <TD STYLE=\"font-size: 8pt;\">$prev_ref_currency</TD>
            <TD STYLE=\"font-size: 8pt;\">$event</TD>

            <TD STYLE=\"font-size: 8pt;\" CLASS=\"td_right\">%d</TD><TD STYLE=\"font-size: 8pt;\" CLASS=\"td_right\">%0.2f</TD>
            <TD STYLE=\"font-size: 8pt;\" CLASS=\"td_right\">%d</TD><TD STYLE=\"font-size: 8pt;\" CLASS=\"td_right\">%0.2f</TD>
            <TD STYLE=\"color: $group_diff_prct_color;\" CLASS=\"td_right\">%d</TD><TD STYLE=\"color: $group_diff_prct_color;\" CLASS=\"td_right\">%0.2f</TD>
            <TD STYLE=\"color: $group_diff_prct_color; font-size: 8pt;\" CLASS=\"td_right\">%d</TD><TD STYLE=\"color: $group_diff_prct_color; font-size: 8pt;\" CLASS=\"td_right\">%0.2f</TD>

            <TD STYLE=\"font-size: 8pt;\" CLASS=\"td_right\">%d</TD><TD STYLE=\"font-size: 8pt;\" CLASS=\"td_right\">%0.2f</TD>
            <TD STYLE=\"font-size: 8pt;\" CLASS=\"td_right\">%d</TD><TD STYLE=\"font-size: 8pt;\" CLASS=\"td_right\">%0.2f</TD>
            <TD STYLE=\"color: $group_diff_prct_color_shift;\" CLASS=\"td_right\">%d</TD><TD STYLE=\"color: $group_diff_prct_color_shift;\" CLASS=\"td_right\">%0.2f</TD>
            <TD STYLE=\"color: $group_diff_prct_color_shift; font-size: 8pt;\" CLASS=\"td_right\">%d</TD><TD STYLE=\"color: $group_diff_prct_color_shift; font-size: 8pt;\" CLASS=\"td_right\">%0.2f</TD>
        </TR>", $group_minus_count, $group_minus_diff_prct, $group_plus_count, $group_plus_diff_prct, $group_diff_count, $group_diff_prct, $group_count, $group_diff_prct,
                $group_minus_count_shift, $group_minus_diff_prct_shift, $group_plus_count_shift, $group_plus_diff_prct_shift, $group_diff_count_shift, $group_diff_count_prct,
                $group_count_shift, $group_diff_prct_shift) ; }

print "</TABLE>" ;

print "<!-- конец таблицы второго уровня вкладок --></TABLE>\n" ;
print "<!-- конец таблицы первого уровня вкладок --></TD></TR></TABLE>\n" ;

print_foother1() ;
