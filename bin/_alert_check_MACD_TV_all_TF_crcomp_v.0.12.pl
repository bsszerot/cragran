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

$main_currency = $ARGV[1] ;
$ref_currency = $ARGV[2] ;
$base_dir = $ARGV[3] ;
$time_frame = $ARGV[4] ;

#-debug-
$pv{currency} = $main_currency ;
$pv{curr_reference} = $ref_currency ;
$pv{count_prds} = '240' ;
$pv{time_frame} = $time_frame ;

#-debug-
$pv{output_type} = 'check_treshold' ;
$alerts_spool_dir = "$base_dir/alerts_spool" ;
$alerts_history_spool_dir = "$alerts_spool_dir/history_alerts" ;
$old_alerts_spool_dir = "$alerts_spool_dir/old_alerts" ;

open(LOG, ">>$cragran_main_log_file") || die "!!! не открывается файл журнала\n" ;
my $v_log_rand = rand() ; $v_log_rand =~ s/\.//g;
my $current_module_name = "alert_check_MACD_TV_all_TF_crcomp.pl" ;
$CURR_LOG_DATE = `date +"%Y-%m-%d %H:%M:%S"` ; $CURR_LOG_DATE =~ s/[\r\n]+//g ;
$log_prefix = "cragran $v_log_rand $CURR_LOG_DATE $current_module_name MACD $time_frame $main_currency $ref_currency " ;

$CURR_YEAR = `date +%Y` ; $CURR_YEAR =~ s/[\r\n]+//g ;
$request = " " ;
my $count_rows = 0 ;
my $count_rows_post = 0 ;

# рассчитать расширение дней от начального периода, чтобы успешно посчитать все ЕМА на начало периода (тут берётся из часовых записей, т.е. *2)
# здесь период дополнительного расчёта задан жёстко, т.к. по формуле считаем ЕМА 12 и 26 периодов
my $max_ema_periods = 26 ;

my @ds_datetime_list = () ;
my @ds_days_list = () ;
my @ds_hours_list = () ;
my @ds_minutes_list = () ;
my @ds_price_open = () ;
my @ds_price_min = () ;
my @ds_price_max = () ;
my @ds_price_close = () ;

my @ds_ema12 = () ;
my @ds_ema26 = () ;
my @ds_diff_ema1226 = () ;
my @ds_ema9_diff = () ;
my @ds_null_line = () ;
my @ds_gist_up_from_up = () ;
my @ds_gist_up_from_down = () ;
my @ds_gist_down_from_up = () ;
my @ds_gist_down_from_down = () ;

# окончательные массивы после вычета периода префиксного рассчёта
@ds_end_datetime_list = () ;
@ds_end_price_close = () ;
@ds_end_ema12 = () ;
@ds_end_ema26 = () ;
@ds_end_diff_ema1226 = () ;
@ds_end_ema9_diff = () ;
@ds_end_null_line = () ;
@ds_end_gist_up_from_up = () ;
@ds_end_gist_up_from_down = () ;
@ds_end_gist_down_from_up = () ;
@ds_end_gist_down_from_down = () ;

$ema12_multi = (2 / (12 + 1)) ;
$ema26_multi = (2 / (26 + 1)) ;
$ema9_multi = (2 / (9 + 1)) ;

#-debug-print "\n-debug - END checked MACD $main_currency / $ref_currency / $time_frame, count_rows $count_rows / $count_post_rows /n" ;

# здесь в функцию передаются ссылки на массивы (операнд \@), которые внутри функции разименовываются (операнд my $loc_ref_arr = $_[0] ; $loc_ref_arr->[номер_элемента])
#$count_rows = get_ohlcv_from_crcomp_table(\@ds_datetime_list, \@ds_days_list, \@ds_hours_list, \@ds_minutes_list, \@ds_price_open, \@ds_price_min, \@ds_price_max, \@ds_price_close, $max_ema_periods, "middle") ;
$count_rows = get_ohlcv_from_crcomp_table($pv{count_prds}, $max_ema_periods, "full", \@ds_datetime_list, \@ds_days_list, \@ds_hours_list, \@ds_minutes_list, \@ds_price_open, \@ds_price_min, \@ds_price_max, \@ds_price_close) ;
#-debug-#print "--- debug inEMA после отработки функции заполнения --- ds_datetime_list $#ds_datetime_list - ds_days_list $#ds_days_list - ds_hours_list $#ds_hours_list - ds_minutes_list $#ds_minutes_list - ds_p

# блок расчёта данных индикатора из первичных данных
for ($i=0; $i < $count_rows ; $i = $i+1) {
# рассчитываем обе две EMA и разницу
    if ($i == 0) {
       $ds_ema12[$i] = $ds_price_close[$i] ;
       $ds_ema26[$i] = $ds_price_close[$i] ;
       }
    else {
       $ds_ema12[$i] = ($ds_price_close[$i] * $ema12_multi) + ($ds_ema12[$i - 1] * (1 - $ema12_multi)) ;
       $ds_ema26[$i] = ($ds_price_close[$i] * $ema26_multi) + ($ds_ema26[$i - 1] * (1 - $ema26_multi)) ;
       }
    $ds_diff_ema1226[$i] = $ds_ema12[$i] - $ds_ema26[$i] ;

# у TV через задницу - тут SMA вместо EMA, переделываем. Она традиционно из 9 периодов
#      else { $ds_ema9_diff[$i] = ($ds_diff_ema1226[$i] * $ema9_multi) + ($ds_ema9_diff[$i - 1] * (1 - $ema9_multi)) ; }
#      if ($i < 9) { my $tmp $ds_ema9_diff[$i] = 0 ; }
    if ($i == 0) { $ds_ema9_diff[$i] = $ds_diff_ema1226[$i] ; }
    if ($i == 1) { $ds_ema9_diff[$i] = ($ds_diff_ema1226[$i] + $ds_diff_ema1226[$i - 1]) / 2 ; }
    if ($i == 2) { $ds_ema9_diff[$i] = ($ds_diff_ema1226[$i] + $ds_diff_ema1226[$i - 1] + $ds_diff_ema1226[$i - 2]) / 3 ; }
    if ($i == 3) { $ds_ema9_diff[$i] = ($ds_diff_ema1226[$i] + $ds_diff_ema1226[$i - 1] + $ds_diff_ema1226[$i - 2] + $ds_diff_ema1226[$i - 3]) / 4 ; }
    if ($i == 4) { $ds_ema9_diff[$i] = ($ds_diff_ema1226[$i] + $ds_diff_ema1226[$i - 1] + $ds_diff_ema1226[$i - 2] + $ds_diff_ema1226[$i - 3] + $ds_diff_ema1226[$i - 4]) / 5 ; }
    if ($i == 5) { $ds_ema9_diff[$i] = ($ds_diff_ema1226[$i] + $ds_diff_ema1226[$i - 1] + $ds_diff_ema1226[$i - 2] + $ds_diff_ema1226[$i - 3] + $ds_diff_ema1226[$i - 4] + $ds_diff_ema1226[$i - 5]) / 6 ; }
    if ($i == 6) { $ds_ema9_diff[$i] = ($ds_diff_ema1226[$i] + $ds_diff_ema1226[$i - 1] + $ds_diff_ema1226[$i - 2] + $ds_diff_ema1226[$i - 3] + $ds_diff_ema1226[$i - 4] + $ds_diff_ema1226[$i - 5] + $ds_diff_ema1226[$i - 6]) / 7 ; }
    if ($i == 7) { $ds_ema9_diff[$i] = ($ds_diff_ema1226[$i] + $ds_diff_ema1226[$i - 1] + $ds_diff_ema1226[$i - 2] + $ds_diff_ema1226[$i - 3] + $ds_diff_ema1226[$i - 4] + $ds_diff_ema1226[$i - 5] + $ds_diff_ema1226[$i - 6] + $ds_diff_ema1226[$i - 7]) / 8 ; }
    if ($i > 7) { $ds_ema9_diff[$i] = ($ds_diff_ema1226[$i] + $ds_diff_ema1226[$i - 1] + $ds_diff_ema1226[$i - 2] + $ds_diff_ema1226[$i - 3] + $ds_diff_ema1226[$i - 4] + $ds_diff_ema1226[$i - 5] + $ds_diff_ema1226[$i - 6] + $ds_diff_ema1226[$i - 7] + $ds_diff_ema1226[$i - 8]) / 9 ; }

# гистограмма MACD
# проинициализировать значения нулём, далее рассчитать, начиная со второй строки
    $ds_gist_up_from_up[$i] = 0 ; $ds_gist_up_from_down[$i] = 0; $ds_gist_down_from_up[$i] = 0 ; $ds_gist_down_from_down[$i] = 0 ;
    if ($i > 1) {
# если линия MACD _больше_ сигнальной, и разница _больше/дальше_ предыдущей разницы, то гистограмма _растёт выше нулевой оси_
       if ( ($ds_diff_ema1226[$i] - $ds_ema9_diff[$i]) > 0 && ($ds_diff_ema1226[$i] - $ds_ema9_diff[$i]) > ($ds_diff_ema1226[$i-1] - $ds_ema9_diff[$i-1]) ) { $ds_gist_up_from_up[$i] = $ds_diff_ema1226[$i] - $ds_ema9_diff[$i] ; } else { $ds_gist_up_from_up[$i] = 0 ; }
# если линия MACD _больше_ сигнальной, и разница _меньше/ближе_ предыдущей разницы, то гистограмма _падает выше нулевой оси_
       if ( ($ds_diff_ema1226[$i] - $ds_ema9_diff[$i]) > 0 && ($ds_diff_ema1226[$i] - $ds_ema9_diff[$i]) < ($ds_diff_ema1226[$i-1] - $ds_ema9_diff[$i-1]) ) { $ds_gist_up_from_down[$i] = $ds_diff_ema1226[$i] - $ds_ema9_diff[$i] ; } else { $ds_gist_up_from_down[$i] = 0 ; }
# если линия MACD _меньше_ сигнальной, и разница _больше/дальше_ предыдущей разницы, то гистограмма _падает ниже нулевой оси_
       if ( ($ds_diff_ema1226[$i] - $ds_ema9_diff[$i]) < 0 && ($ds_diff_ema1226[$i] - $ds_ema9_diff[$i]) < ($ds_diff_ema1226[$i-1] - $ds_ema9_diff[$i-1]) ) { $ds_gist_down_from_down[$i] = $ds_diff_ema1226[$i] - $ds_ema9_diff[$i] ; } else { $ds_gist_down_from_down[$i] = 0 ; }
# если линия MACD _меньше_ сигнальной, и разница _меньше/ближе_ предыдущей разницы, то гистограмма _растёт ниже нулевой оси_
       if ( ($ds_diff_ema1226[$i] - $ds_ema9_diff[$i]) < 0 && ($ds_diff_ema1226[$i] - $ds_ema9_diff[$i]) > ($ds_diff_ema1226[$i-1] - $ds_ema9_diff[$i-1]) ) { $ds_gist_down_from_up[$i] = $ds_diff_ema1226[$i] - $ds_ema9_diff[$i] ; } else { $ds_gist_down_from_up[$i] = 0 ; }
       }
    $ds_null_line[$i] = 0 ;
    }

#print "$count_rows $#\n" ;
#exit 0 ;

# берём количество результирующих строк без добавленного префикса дней меньше, чем изначально запрошено - в источнике данных было меньше строк
my $delta_if_less = $count_rows - $pv{count_prds} ;
if ( $delta_if_less < 0) { $delta_if_less = 0 ; }

#-debug-print "== delta_if_less == $delta_if_less\n" ;
for ($i=1; $i <= $count_rows; $i = $i+1) {
    if (($i - $delta_if_less) > 0) {
       $ds_end_datetime_list[$count_rows_post] = $ds_datetime_list[$i - 1] ; $ds_end_datetime_list[$count_rows_post] =~ s///g ;
       $ds_end_price_close[$count_rows_post] = $ds_price_close[$i - 1] ;
       $ds_end_ema12[$count_rows_post] = $ds_ema12[$i - 1] ;
       $ds_end_ema26[$count_rows_post] = $ds_ema26[$i - 1] ;
       $ds_end_diff_ema1226[$count_rows_post] = $ds_diff_ema1226[$i - 1] ;
       $ds_end_ema9_diff[$count_rows_post] = $ds_ema9_diff[$i - 1] ;
       $ds_end_null_line[$count_rows_post] = $ds_null_line[$i - 1] ;
       $ds_end_gist_up_from_up[$count_rows_post] = $ds_gist_up_from_up[$i - 1] ;
       $ds_end_gist_up_from_down[$count_rows_post] = $ds_gist_up_from_down[$i - 1] ;
       $ds_end_gist_down_from_up[$count_rows_post] = $ds_gist_down_from_up[$i - 1] ;
       $ds_end_gist_down_from_down[$count_rows_post] = $ds_gist_down_from_down[$i - 1] ;
       $count_rows_post += 1 ;
       }
    }

# для наборов данных гистограммы MACD выделить максимальные значения, рассчитать множитель и привести значения к диапазону -100 - 100
if (1 == 2) {
my $max_gist = 0 ;
foreach (@ds_end_gist_up_from_up) { if ( $_ > $max_gist ) { $max_gist = $_; } }
foreach (@ds_end_gist_up_from_down) { if ( $_ > $max_gist ) { $max_gist = $_; } }
foreach (@ds_end_gist_down_from_down) { if ( (-1 * $_) > $max_gist ) { $max_gist = (-1 * $_) ; } }
foreach (@ds_end_gist_down_from_up) { if ( (-1 * $_) > $max_gist ) { $max_gist = (-1 * $_) ; } }
if ( $max_gist > 0) {
   for ($i=0; $i <= $#ds_end_gist_up_from_up; $i = $i+1) { $ds_end_gist_up_from_up[$i] = $ds_end_gist_up_from_up[$i] / ( $max_gist / 100) ; }
   for ($i=0; $i <= $#ds_end_gist_up_from_down; $i = $i+1) { $ds_end_gist_up_from_down[$i] = $ds_end_gist_up_from_down[$i] / ( $max_gist / 100) ; }
   for ($i=0; $i <= $#ds_end_gist_down_from_up; $i = $i+1) { $ds_end_gist_down_from_up[$i] = $ds_end_gist_down_from_up[$i] / ( $max_gist / 100) ; }
   for ($i=0; $i <= $#ds_end_gist_down_from_down; $i = $i+1) { $ds_end_gist_down_from_down[$i] = $ds_end_gist_down_from_down[$i] / ( $max_gist / 100) ; }
   }
}

#-debug-exit ;

###########################################################################################################################
# блок мониторинговых расчётов
###########################################################################################################################

if ( $count_rows_post >= 1 ) {
#   $mail_recipient_list = "belonin\@yandex.ru, semnava\@yandex.ru" ;
   my $mail_recipient_list = "belonin\@zerot.local" ;
# пока прямо вшиты данные для недельного цикла
#   $pv{time_frame} = "1H" ;
#   $pv{count_prds} = 720 ;
#   $pv{macd_time_frame} = "4H" ;
   $pv{count_prds} = 720 ;

# для несколькоминутного цикла выставляем количество периодов 8 часов для эргономики
   if ( $pv{time_frame} eq "1M" || $pv{time_frame} eq "3M" || $pv{time_frame} eq "5M") { $pv{count_prds} = recode_tf_periods("1H", "$pv{time_frame}", 8) ; }
# для несколькочасового цикла выставляем количество периодов 10 дней для эргономики
   if ( $pv{time_frame} eq "10M" || $pv{time_frame} eq "15M" || $pv{time_frame} eq "30M") { $pv{count_prds} = recode_tf_periods("1H", "$pv{time_frame}", 240) ; }
# для несколькодневного цикла выставляем количество периодов 30 дней для эргономики
   if ( $pv{time_frame} eq "1H" || $pv{time_frame} eq "2H" || $pv{time_frame} eq "3H" || $pv{time_frame} eq "4H" || $pv{time_frame} eq "8H" || $pv{time_frame} eq "12H") { $pv{count_prds} = recode_tf_periods("1H", "$pv{time_frame}", 720) ; }
# для нескольконедельного цикла выставляем количество периодов 90 дней для эргономики
   if ( $pv{time_frame} eq "1D" || $pv{time_frame} eq "2D" || $pv{time_frame} eq "3D" || $pv{time_frame} eq "4D") { $pv{count_prds} = recode_tf_periods("1D", "$pv{time_frame}", 90) ; }
# для несколькомесячного цикла выставляем количество периодов 360 дней для эргономики
   if ( $pv{time_frame} eq "1W" || $pv{time_frame} eq "2W" || $pv{time_frame} eq "3W" || $pv{time_frame} eq "4W") { $pv{count_prds} = recode_tf_periods("1D", "$pv{time_frame}", 360) ; }
   $pv{macd_time_frame} = $pv{time_frame} ;
   $env_prct = 5 ;

# выявить изменение направления линии MACD
   check_macd_lines_vector_change() ;
# выявить пересечение линий MACD
   check_macd_lines_cross_change() ;
# выявить изменение направления гистограммы MACD
   check_macd_gist_vector_change() ;

# начала уменьшаться сверху
#$ds_gist_up_from_up[$i-1] > 0 && $ds_gist_up_from_down[$i] > 0
# начала уменьшаться снизу
#$ds_gist_down_from_up[$i-1] < 0 && $ds_gist_down_from_down[$i] < 0
# начала увеличиваться сверху
#$ds_gist_up_from_down[$i-1] > 0 && $ds_gist_up_from_up[$i] > 0
# начала увеличиваться снизу
#$ds_gist_down_from_down[$i-1] < 0 && $ds_gist_down_from_up[$i] < 0

# падение гистограммы
#($ds_gist_up_from_up[$i-1] > 0 && $ds_gist_up_from_down[$i] > 0) || ($ds_gist_down_from_up[$i-1] < 0 && $ds_gist_down_from_down[$i] < 0)
# рост гистограммы
#($ds_gist_up_from_down[$i-1] > 0 && $ds_gist_up_from_up[$i] > 0) || ($ds_gist_down_from_down[$i-1] < 0 && $ds_gist_down_from_up[$i] < 0)

   }

#-debug-print "\n-debug - END checked MACD $main_currency / $ref_currency / $time_frame, count_rows $count_rows / $count_post_rows /n" ;
close(LOG) ;
