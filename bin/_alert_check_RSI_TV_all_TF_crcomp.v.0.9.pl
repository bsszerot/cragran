#!/usr/bin/perl

# open source soft - (C) 2000-2008 OrSiMON BESST (Monitor of operation system Unix/Linux ans rdbms Oracle from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

use DBI ;
require "/var/www/crypta/cgi/common_parameter.cragregator" ;
require "$cragran_dir_lib/lib_common_func.pl" ;
require "$cragran_dir_lib/lib_cragran_common.pl" ;
require "$cragran_dir_lib/lib_cragran_trading.pl" ;
require "$cragran_dir_lib/lib_cragran_contracts.pl" ;
require "$cragran_dir_lib/lib_cragran_monitoring_func.pl" ;

$main_currency = $ARGV[1] ; $pv{currency} = $main_currency ;
$ref_currency = $ARGV[2] ; $pv{curr_reference} = $ref_currency ;
$base_dir = $ARGV[3] ;
$pv{time_frame} = $ARGV[4] ;
$pv{rsi_time_frame} = $pv{time_frame} ;
$pv{output_type} = 'check_treshold' ;
$pv{rsi_periods} = 14 ;
$pv{count_prds} = 120 ;
$alerts_spool_dir = "$base_dir/alerts_spool" ;
$old_alerts_spool_dir = "$alerts_spool_dir/old_alerts" ;

open(LOG, ">>$cragran_main_log_file") || die "!!! не открывается файл журнала\n" ;
my $v_log_rand = rand() ; $v_log_rand =~ s/\.//g;
my $current_module_name = "alert_check_RSI_TV_all_TF_crcomp.pl" ;
$CURR_LOG_DATE = `date +"%Y-%m-%d %H:%M:%S"` ; $CURR_LOG_DATE =~ s/[\r\n]+//g ;
$log_prefix = "cragran $v_log_rand $CURR_LOG_DATE $current_module_name RSI $time_frame $main_currency $ref_currency " ;

$CURR_YEAR = `date +%Y` ; $CURR_YEAR =~ s/[\r\n]+//g ;
my $count_rows = 0 ;
my $count_rows_post = 0 ;

my $rsi_periods = 0 ; $rsi_periods = $pv{rsi_periods} - 1 ;
# если счётчик периодов RSI не указан - это ошибка вызова. Причём увеличивать пришлось на несколько периодов - тогда совпало в TrView. Также для 1H выбираем только 1/2 записей, поэтому умножаем на 2
#my $ext_period = 0 ; $ext_period = ($pv{count_prds} + ($pv{rsi_periods} * 5)) * 2 ;
my $rsi_multi = (1 / $pv{rsi_periods}) ;
# рассчитать расширение дней от начального периода, чтобы успешно посчитать все RSI на начало периода (тут берётся из часовых записей, т.е. *2)
my $ext_period = 0 ;
$ext_period = $pv{count_prds} + $pv{rsi_periods} + 1 ;
#-debug-print "Дополниьельный период == $ext_period == $pv{count_prds} == $count_prds_prefix ;" ;

my @ds_datetime_list = () ;
my @ds_days_list = () ;
my @ds_hours_list = () ;
my @ds_minutes_list = () ;
my @ds_price_open = () ;
my @ds_price_min = () ;
my @ds_price_max = () ;
my @ds_price_close = () ;

my @ds_change_up = () ;
my @ds_change_up_rma = () ;
my @ds_change_down = () ;
my @ds_change_down_rma = () ;
my @ds_RS = () ;
my @ds_RSI = () ;
my @ds_low_level = () ;
my @ds_top_level = () ;

# массив данных за вычетом префикса на рассчёт скользящих
my @ds_end_datetime_list = () ;
my @ds_end_price_close = () ;
my @ds_end_change_up = () ;
my @ds_end_change_up_rma = () ;
my @ds_end_change_down = () ;
my @ds_end_change_down_rma = () ;
my @ds_end_RS = () ;
my @ds_end_RSI = () ;
my @ds_end_low_level = () ;
my @ds_end_top_level = () ;

my $cnt_low_level = 30 ;
my $cnt_top_level = 70 ;

#-debug-print "\n-debug - START checked RSI $main_currency / $ref_currency / $time_frame, count_rows $count_rows / $count_post_rows /n" ;

# здесь в функцию передаются ссылки на массивы (операнд \@), которые внутри функции разименовываются (операнд my $loc_ref_arr = $_[0] ; $loc_ref_arr->[номер_элемента])
#$count_rows = get_ohlcv_from_crcomp_table(\@ds_datetime_list, \@ds_days_list, \@ds_hours_list, \@ds_minutes_list, \@ds_price_open, \@ds_price_min, \@ds_price_max, \@ds_price_close, $max_ema_periods, "middle") ;
$count_rows = get_ohlcv_from_crcomp_table($pv{count_prds}, $ext_period, "middle", \@ds_datetime_list, \@ds_days_list, \@ds_hours_list, \@ds_minutes_list, \@ds_price_open, \@ds_price_min, \@ds_price_max, \@ds_price_close) ;
#-debug-#print "--- debug inEMA после отработки функции заполнения --- ds_datetime_list $#ds_datetime_list - ds_days_list $#ds_days_list - ds_hours_list $#ds_hours_list - ds_minutes_list $#ds_minutes_list ..." ;

# блок расчёта данных индикатора из первичных данных
for ($i=0; $i < $count_rows ; $i = $i+1) {
    $ds_low_level[$i] = $cnt_low_level ;
    $ds_top_level[$i] = $cnt_top_level ;

# получить датасет с ценой
# -- первая строка не определена, можно не определять ее для всех массивов, RMA берём равным значению цены
# определить множитель веса текущего значения (мультипликатор) RMA = 1 / period
# -- со второй строки
# определить положительное и отрицательное расхождение (разницу, или, если не подходит под условие 0)
# для каждой даты определить RMA от текущего и предыдущего значения
# определить RS и перевести в %
    if ($i == 0) {
       $ds_change_up[$i] = 0 ;
       $ds_change_up_rma[$i] = 0 ;
       $ds_change_down[$i] = 0 ;
       $ds_change_down_rma[$i] = 0 ;
       $ds_RS[$i] = 1 ;
       $ds_RSI[$i] = 100 - (100 / (1 + $ds_RS[$i])) ;
       }
    else {
      if ($ds_price_close[$i] > $ds_price_close[$i - 1]) { $ds_change_up[$i] = $ds_price_close[$i] - $ds_price_close[$i - 1] ; } else { $ds_change_up[$i] = 0 ; }
      if ($i == 1) { $ds_change_up_rma[$i] = $ds_change_up[$i] ; } else { $ds_change_up_rma[$i] = ($ds_change_up[$i] * $rsi_multi) + ((1 - $rsi_multi) * $ds_change_up_rma[$i - 1]); }
      if ($ds_price_close[$i] < $ds_price_close[$i - 1]) { $ds_change_down[$i] = $ds_price_close[$i - 1] - $ds_price_close[$i] ; } else { $ds_change_down[$i] = 0 ; }
      if ($i == 1) { $ds_change_down_rma[$i] = $ds_change_down[$i] ; } else { $ds_change_down_rma[$i] = ($ds_change_down[$i] * $rsi_multi) + ((1 - $rsi_multi) * $ds_change_down_rma[$i - 1]); }
# защититься от деления на ноль
      if ($ds_change_down_rma[$i] == 0) { $ds_RS[$i] = 1 ; } else { $ds_RS[$i] = $ds_change_up_rma[$i] / $ds_change_down_rma[$i] ; }
      $ds_RSI[$i] = 100 - (100 / (1 + $ds_RS[$i])) ;
      }
    }

if ( $pv{output_type} eq "query" ) { print "Content-Type: text/html\n\n$request\n\n" ; exit ; }

#print "$count_rows $#\n" ;
#exit 0 ;

# берём количество результирующих строк без добавленного префикса дней меньше, чем изначально запрошено - в источнике данных было меньше строк
my $delta_if_less = $count_rows - $pv{count_prds} ;
if ( $delta_if_less < 0) { $delta_if_less = 0 ; }

#-debug-print "== delta_if_less == $delta_if_less\n" ;
for ($i=1; $i <= $count_rows; $i = $i+1) {
    if (($i - $delta_if_less) > 0) {
       $ds_end_datetime_list[$count_rows_post] = $ds_datetime_list[$i - 1] ;
       $ds_end_price_close[$count_rows_post] = $ds_price_close[$i - 1] ;
       $ds_end_change_up[$count_rows_post] = $ds_change_up[$i - 1] ;
       $ds_end_change_up_rma[$count_rows_post] = $ds_change_up_rma[$i - 1] ;
       $ds_end_change_down[$count_rows_post] = $ds_change_down[$i - 1] ;
       $ds_end_change_down_rma[$count_rows_post] = $ds_change_down_rma[$i - 1] ;
       $ds_end_RS[$count_rows_post] = $ds_RS[$i - 1] ;
       $ds_end_RSI[$count_rows_post] = $ds_RSI[$i - 1] ;
       $ds_end_low_level[$count_rows_post] = $ds_low_level[$i - 1] ;
       $ds_end_top_level[$count_rows_post] = $ds_top_level[$i - 1] ;
#-debug-$tmp1 = $i - $delta_if_less - 1 ;
#-debug-$tmp2 = $i - 1 ;
#-debug-print "string - $tmp1 - $tmp2 - $ds_end_datetime_list[$i - $delta_if_less - 1] - $ds_end_price_open[$i - $delta_if_less - 1] - $ds_end_price_min[$i - $delta_if_less - 1] - $ds_end_price_max[$i - $delta_if_less - 1] - $ds_end_price_cl
       $count_rows_post += 1 ;
       }
    }


# блок собственно поиска паттернов RSI


if ( $count_rows_post >= 1 ) {
#print "--- зашли в рассчёт" ;
   my $sz_values = "" ;
   my $is_rsi_send = "no_send" ; # уведомлять если ещё не уведомляли
   my $sz_rsi_change_vector = "" ;

# имя файлов по направлению предполагаемого движения цены
   my $alert_file_up = "$alerts_spool_dir/rsi_$pv{time_frame}_up_$pv{currency}_$pv{curr_reference}.alert" ;
   my $is_exsist_alert_file_up = `[ -f $alert_file_up ] && echo "file_exist"` ; chomp($is_exsist_alert_file_up) ;
   my $alert_file_down = "$alerts_spool_dir/rsi_$pv{time_frame}_down_$pv{currency}_$pv{curr_reference}.alert" ;
   my $is_exsist_alert_file_down = `[ -f $alert_file_down ] && echo "file_exist"` ; chomp($is_exsist_alert_file_down) ;


my $sz_strategy = "unnamed_$pv{time_frame}" ;
if ( $pv{time_frame} eq "1D" || $pv{time_frame} eq "2H" || $pv{time_frame} eq "1H" ) { $sz_strategy = "SWING" ; }
if ( $pv{time_frame} eq "15M" || $pv{time_frame} eq "5M" || $pv{time_frame} eq "1M" ) { $sz_strategy = "INDAY" ; }

#   $mail_recipient_list = "belonin\@yandex.ru" ;
# отработать превышение порогов, если да и если файла нет - включить рассылку сообщений
   if ( $ds_end_RSI[$count_rows_post-1] > $ds_end_top_level[$count_rows_post-1] ) {
      if ( $is_exsist_alert_file_down ne "file_exist" ) {
         $is_rsi_send = "yes_send" ;
         $sz_values = sprintf("$sz_strategy RSI_$pv{time_frame} найден сигнал вверху %s/%s (%0.2f>%d $ds_end_date_list[$count_rows_post-1])\n", $pv{currency}, $pv{curr_reference}, $ds_end_RSI[$count_rows_post-1], $ds_end_top_level[$count_rows_post-1]) ;
         $sz_rsi_change_vector = "HIGH_ON" ;
         }
      system("echo \"$sz_rsi_change_vector $sz_values\" >> $alert_file_down") ;
      }

   if ( $ds_end_RSI[$count_rows_post-1] < $ds_end_low_level[$count_rows_post-1] ) {
      if ( $is_exsist_alert_file_up ne "file_exist" ) {
         $is_rsi_send = "yes_send" ;
         $sz_values = sprintf("$sz_strategy RSI_$pv{time_frame} найден сигнал внизу %s/%s (%0.2f<%d $ds_end_date_list[$count_rows_post-1])\n", $pv{currency}, $pv{curr_reference}, $ds_end_RSI[$count_rows_post-1], $ds_end_low_level[$count_rows_post-1]) ;
         $sz_rsi_change_vector = "LOW_ON" ;
         }
      system("echo \"$sz_rsi_change_vector $sz_values\" >> $alert_file_up") ;
      }

# отработать возврат от превышения порогов
# тут просто журналируем и переносим файл в архив
# а с версии 0.7 20240207 - уведомляем и добавляем в БД, чтобы искать паттерны трэнда вверх или вниз (множественные заходы в одну сторону)
   if ( (($ds_end_RSI[$count_rows_post-3] > $ds_end_top_level[$count_rows_post-1] ) or ($ds_end_RSI[$count_rows_post-2] > $ds_end_top_level[$count_rows_post-1]))
        and ($ds_end_RSI[$count_rows_post-1] < $ds_end_top_level[$count_rows_post-1]) ) {
      if ( $is_exsist_alert_file_up eq "file_exist" ) {
         $is_rsi_send = "yes_send" ;
         $sz_values = sprintf("$sz_strategy RSI_$pv{time_frame} сброшен сигнал вверху %s/%s (%0.2f>%d $ds_end_date_list[$count_rows_post-1])\n", $pv{currency}, $pv{curr_reference}, $ds_end_RSI[$count_rows_post-1], $ds_end_top_level[$count_rows_post-1]) ;
         $sz_rsi_change_vector = "HIGH_OFF" ;
         system("echo \"$sz_rsi_change_vector $sz_values\" >> $alert_file_up") ;
         system("mv $alert_file_up $old_alerts_spool_dir") ;
         }
      }
   if ( (($ds_end_RSI[$count_rows_post-3] < $ds_end_low_level[$count_rows_post-1]) or ($ds_end_RSI[$count_rows_post-2] < $ds_end_low_level[$count_rows_post-1]))
      and ($ds_end_RSI[$count_rows_post-1] > $ds_end_low_level[$count_rows_post-1]) ) {
      if ( $is_exsist_alert_file_down eq "file_exist" ) {
         $is_rsi_send = "yes_send" ;
         $sz_values = sprintf("$sz_strategy RSI_$pv{time_frame} сброшен сигнал внизу %s/%s (%0.2f>%d $ds_end_date_list[$count_rows_post-1])\n", $pv{currency}, $pv{curr_reference}, $ds_end_RSI[$count_rows_post-1], $ds_end_top_level[$count_rows_post-1]) ;
         $sz_rsi_change_vector = "LOW_OFF" ;
         system("echo \"$sz_rsi_change_vector $sz_values\" >> $alert_file_down") ;
         system("mv $alert_file_down $old_alerts_spool_dir") ;
         }
      }

# при необходимости разослать уведомления
    if ( $is_rsi_send eq "yes_send" ) {
       printf(LOG "$log_prefix - check_rsi_change данные \$pv{rsi_time_frame} = $pv{rsi_time_frame} для определения переменных уведомления\n") ;
       if ($pv{rsi_time_frame} eq "1H" ) { $is_rsi_email_send = $is_1H_rsi_email_send ; $is_rsi_telegram_send = $is_1H_rsi_telegram_send ; }
       if ($pv{rsi_time_frame} eq "4H" ) { $is_rsi_email_send = $is_4H_rsi_email_send ; $is_rsi_telegram_send = $is_4H_rsi_telegram_send ; }
       if ($pv{rsi_time_frame} eq "1D" ) { $is_rsi_email_send = $is_1D_rsi_email_send ; $is_rsi_telegram_send = $is_1D_rsi_telegram_send ; }
       create_graphs_add_event_to_db('RSI_'.$pv{rsi_time_frame}.'_SIGNAL', $sz_rsi_change_vector, $ds_end_datetime_list[$count_rows_post-1], $pv{currency}, $pv{curr_reference}, 'RSI', 'CROSS', $pv{time_frame}, $pv{rsi_time_frame}, $pv{count_prds}, "LOW_OFF $sz_values", $is_rsi_email_send, $is_rsi_telegram_send) ;
       }
   }

#-debug-print "\n-debug - END checked RSI $main_currency / $ref_currency / $time_frame, count_rows $count_rows / $count_post_rows /n" ;
close(LOG) ;

