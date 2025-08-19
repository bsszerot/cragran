#!/usr/bin/perl

# open source soft - (C) 2023 CrAgrAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

use DBI ;
use Chart::Lines ;
require "/var/www/crypta/cgi/common_parameter.cragregator" ;
require "$cragran_dir_lib/lib_common_func.pl" ;
require "$cragran_dir_lib/lib_cragran_common.pl" ;
require "$cragran_dir_lib/lib_cragran_trading.pl" ;
require "$cragran_dir_lib/lib_cragran_contracts.pl" ;

# <IMG CLASS=\"ohlc_ema_graph_gd_$id_suffix\" STYLE=\"padding: 0pt $offset_ohlc_gd;\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_OHLCV_EMA_ENV_BL_gd.cgi?currency=$currency&curr_reference=$curr_reference&
#time_frame=$ema_tf&count_prds=$count_prds&offset_prds=$offset_prds&env_prct=$env_prct&output_type=graph&brush_size=4&x_size=$size_x_block&y_size=$size_y_block&is_ema_periods=default&is_ema05=shadow\"></A>" ;

#<IMG CLASS=\"ohlc_ema_graph_$id_suffix\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_OHLCV_EMA_ENV_BL.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$ema_tf&count_prds=$count_prds
#&offset_prds=$pv{offset_prds}&env_prct=$env_prct&output_type=graph&brush_size=4&x_size=1440&y_size=720&is_ema_periods=default&is_ema05=shadow\"></A>" ;

$CURR_YEAR = `date +%Y` ; $CURR_YEAR =~ s/[\r\n]+//g ;
my $count_rows = 0 ;
my $count_rows_post = 0 ;

# блок списков для первоначальной обработки данных
my @ds_datetime_list = () ;
my @ds_days_list = () ;
my @ds_hours_list = () ;
my @ds_minutes_list = () ;
my @ds_price_open = () ;
my @ds_price_min = () ;
my @ds_price_max = () ;
my @ds_price_close = () ;
my @ds_volume_from = () ;
my @ds_volume_to = () ;
my @ds_ema01 = () ;
my @ds_ema02 = () ;
my @ds_ema03 = () ;
my @ds_ema04 = () ;
my @ds_ema05 = () ;
my @ds_ema06 = () ;
my @ds_ema07 = () ;
my @ds_ema08 = () ;
my @ds_env_top = () ;
my @ds_env_dwn = () ;
# блок списков после вычитания префиксных дней
my @ds_end_datetime_list = () ;
my @ds_end_days_list = () ;
my @ds_end_hours_list = () ;
my @ds_end_minutes_list = () ;
my @ds_end_price_open = () ;
my @ds_end_price_min = () ;
my @ds_end_price_max = () ;
my @ds_end_price_close = () ;
my @ds_end_volume_from = () ;
my @ds_end_volume_to = () ;
my @ds_end_ema01 = () ;
my @ds_end_ema02 = () ;
my @ds_end_ema03 = () ;
my @ds_end_ema04 = () ;
my @ds_end_ema05 = () ;
my @ds_end_ema06 = () ;
my @ds_end_ema07 = () ;
my @ds_end_ema08 = () ;
my @ds_end_env_top = () ;
my @ds_end_env_dwn = () ;

# параметры по умолчанию
# для 2х часового графика значения ЕМА - 20 (текущая), 241 (дневная), 1570 - недельная
$pv{env_prct} = 5 ;
$pv{ema01_cnt_prds} = 20 ;
#$pv{ema02_cnt_prds} = 241 ;
#$pv{ema03_cnt_prds} = 1570 ;
$pv{ema02_cnt_prds} = 0 ;
$pv{ema03_cnt_prds} = 0 ;
$pv{ema04_cnt_prds} = 0 ;
$pv{ema05_cnt_prds} = 0 ;
$pv{ema06_cnt_prds} = 0 ;
$pv{ema07_cnt_prds} = 0 ;
$pv{ema08_cnt_prds} = 0 ;
$pv{is_envelope_view} = "yes" ;
# -- временно --
#$pv{count_prds} = 12 * 120 ;
#$pv{time_frame} = "2H" ;

# - вытащить из URL запроса значения уточняющих полей
&get_forms_param() ;
#-debug-$pv{currency} = 'BTC' ; $pv{curr_reference} = 'USDT' ; $pv{time_frame} = '10M' ; $pv{count_prds} = '120' ; $pv{output_type} = 'graph' ; $pv{brush_size} = '4' ; $pv{x_size} = '1400' ; $pv{y_size} = '640' ;
#-debug- $pv{output_type} = 'table' ; #$pv{output_type} = 'query' ;

# в этом модуле убрано явное присвоение периодов ЕМА для таймфрэймов, и введена 8 ЕМА, и их выключение нулевым периодом
# но со второй версии модуля явное присвоение возвращено как один из двух режимов
if ($pv{is_ema_periods} eq "default") {
# для отображения именно текущей, дневной и недельной ЕМА в этом модуле используются перерасчитанные параметры по умолчанию
# для 2х часового графика значения ЕМА - 20 (текущая), 241 (дневная), 1570 - недельная
# соответствует пятилетний цикл, родительский и дедов - подавлены цветом и приоритетом линий графика
   if ( $pv{time_frame} eq "4W" ) { $pv{ema01_cnt_prds} = 20 ;  $pv{ema02_cnt_prds} = 10 ; $pv{ema03_cnt_prds} = 5 ;     $pv{ema04_cnt_prds} = $pv{ema03_cnt_prds} / 2 ;     $pv{ema05_cnt_prds} = 20 ; }
# соответствует годовой  цикл, родительский - пятилетний (EMA 4W), дедов - подавлен цветом и приоритетом линий графика
   if ( $pv{time_frame} eq "1W" ) { $pv{ema01_cnt_prds} = 20 ;  $pv{ema02_cnt_prds} = 10 ; $pv{ema03_cnt_prds} = 20 ;     $pv{ema04_cnt_prds} = $pv{ema03_cnt_prds} / 2 ;     $pv{ema05_cnt_prds} = 81 ; }
# соответствует месячный цикл, родительский - годовой (EMA 1W), дедов - пятилетний (EMA 4W)
   if ( $pv{time_frame} eq "4D" ) { $pv{ema01_cnt_prds} = 20 ;  $pv{ema02_cnt_prds} = 10 ; $pv{ema03_cnt_prds} = 35 ;     $pv{ema04_cnt_prds} = $pv{ema03_cnt_prds} / 2 ;     $pv{ema05_cnt_prds} = 142 ; }
   if ( $pv{time_frame} eq "2D" ) { $pv{ema01_cnt_prds} = 20 ;  $pv{ema02_cnt_prds} = 10 ; $pv{ema03_cnt_prds} = 70 ;     $pv{ema04_cnt_prds} = $pv{ema03_cnt_prds} / 2 ;     $pv{ema05_cnt_prds} = 285 ; }
#-- рассчитано с этго момнета, верхние - нет
   if ( $pv{time_frame} eq "1D" ) { $pv{ema01_cnt_prds} = 20 ;  $pv{ema02_cnt_prds} = 10 ; $pv{ema03_cnt_prds} = 140 ;     $pv{ema04_cnt_prds} = $pv{ema03_cnt_prds} / 2 ;     $pv{ema05_cnt_prds} = 570 ; }
# - уточнено 20231228 - (1) текущие быстрая и медленная ЕМА не приводятся, таймфрэймы соответствует несколькодневному (внутринедельному) циклу,
# - уточнено 20231228 - (2) родительские ЕМА, быстрая и медленная, приведены к родительской ЕМА для текущего ТФ2H, соответствуют нескольконедельный (внутримесячный) (1D)
# дедов - несколькомесячный (внутригодовой) (1W)
   if ( $pv{time_frame} eq "12H" ) { $pv{ema01_cnt_prds} = 20 ; $pv{ema02_cnt_prds} = 10 ; $pv{ema03_cnt_prds} = 40 ;      $pv{ema04_cnt_prds} = $pv{ema03_cnt_prds} / 2 ;     $pv{ema05_cnt_prds} = 261 ; }
   if ( $pv{time_frame} eq "8H" ) { $pv{ema01_cnt_prds} = 20 ;  $pv{ema02_cnt_prds} = 10 ; $pv{ema03_cnt_prds} = 60 ;      $pv{ema04_cnt_prds} = $pv{ema03_cnt_prds} / 2 ;     $pv{ema05_cnt_prds} = 392 ; }
   if ( $pv{time_frame} eq "4H" ) { $pv{ema01_cnt_prds} = 20 ;  $pv{ema02_cnt_prds} = 10 ; $pv{ema03_cnt_prds} = 120 ;     $pv{ema04_cnt_prds} = $pv{ema03_cnt_prds} / 2 ;     $pv{ema05_cnt_prds} = 785 ; }
   if ( $pv{time_frame} eq "3H" ) { $pv{ema01_cnt_prds} = 20 ;  $pv{ema02_cnt_prds} = 10 ; $pv{ema03_cnt_prds} = 160 ;     $pv{ema04_cnt_prds} = $pv{ema03_cnt_prds} / 2 ;     $pv{ema05_cnt_prds} = 1047 ; }
   if ( $pv{time_frame} eq "2H" ) { $pv{ema01_cnt_prds} = 20 ;  $pv{ema02_cnt_prds} = 10 ; $pv{ema03_cnt_prds} = 241 ;     $pv{ema04_cnt_prds} = $pv{ema03_cnt_prds} / 2 ;     $pv{ema05_cnt_prds} = 1570 ; }
   if ( $pv{time_frame} eq "1H" ) { $pv{ema01_cnt_prds} = 20 ;  $pv{ema02_cnt_prds} = 10 ; $pv{ema03_cnt_prds} = 482 ;     $pv{ema04_cnt_prds} = $pv{ema03_cnt_prds} / 2 ;     $pv{ema05_cnt_prds} = 3140 ; }
# - уточнено 20231228 - (1) текущие быстрая и медленная ЕМА не приводятся, таймфрэймы соответствует несколькочасовому (внутридневному) циклу,
# - уточнено 20231228 - (2) родительские ЕМА, быстрая и медленная, приведены к родительской ЕМА для текущего ТФ1H, соответствуют несколькодневному (внутринедельному) циклу
# - дедов цикл - не вспомню, выверялся ли - тут нескольконедельный (внутримесячный) ТФ1W, но он обычно не показывается в текущей версии модуля для экономии пространства экрана на графике
   if ( $pv{time_frame} eq "30M" ) { $pv{ema01_cnt_prds} = 20 ; $pv{ema02_cnt_prds} = 10 ; $pv{ema03_cnt_prds} = 20 * 2 ;  $pv{ema04_cnt_prds} = $pv{ema03_cnt_prds} / 2 + 5 ; $pv{ema05_cnt_prds} = 20 * 2 * 24 ; }
   if ( $pv{time_frame} eq "15M" ) { $pv{ema01_cnt_prds} = 20 ; $pv{ema02_cnt_prds} = 10 ; $pv{ema03_cnt_prds} = 20 * 4 ;  $pv{ema04_cnt_prds} = $pv{ema03_cnt_prds} / 2 ;     $pv{ema05_cnt_prds} = 20 * 4 * 24 ; }
   if ( $pv{time_frame} eq "10M" ) { $pv{ema01_cnt_prds} = 20 ; $pv{ema02_cnt_prds} = 10 ; $pv{ema03_cnt_prds} = 20 * 6 ;  $pv{ema04_cnt_prds} = $pv{ema03_cnt_prds} / 2 ;     $pv{ema05_cnt_prds} = 20 * 6 * 24 ; }
# соответствует несколькоминутному (внутричасовому) циклу, родительский несколькочасовой (внутридневной) цикл (EMA 15M), дедов несколькодневной (внутринедельный) (EMA 1H)
   if ( $pv{time_frame} eq "5M" ) { $pv{ema01_cnt_prds} = 20 ;  $pv{ema02_cnt_prds} = 10 ; $pv{ema03_cnt_prds} = 20 * 3 ;  $pv{ema04_cnt_prds} = $pv{ema03_cnt_prds} / 2 ;     $pv{ema05_cnt_prds} = 20 * 3 * 4 ; }
   if ( $pv{time_frame} eq "3M" ) { $pv{ema01_cnt_prds} = 20 ;  $pv{ema02_cnt_prds} = 10 ; $pv{ema03_cnt_prds} = 20 * 5 ;  $pv{ema04_cnt_prds} = $pv{ema03_cnt_prds} / 2 ;     $pv{ema05_cnt_prds} = 20 * 5 * 4 ; }
   if ( $pv{time_frame} eq "1M" ) { $pv{ema01_cnt_prds} = 20 ;  $pv{ema02_cnt_prds} = 10 ; $pv{ema03_cnt_prds} = 20 * 15 ; $pv{ema04_cnt_prds} = $pv{ema03_cnt_prds} / 2 ;     $pv{ema05_cnt_prds} = 20 * 15 * 4 ; }
   }
if ($pv{is_ema05} eq "shadow" ) { $pv{ema05_cnt_prds} = 0 ; }

# рассчитать расширение дней от начального периода, чтобы успешно посчитать все ЕМА на начало периода (тут берётся из часовых записей, т.е. *2)
my $ext_period = 0 ;
my $count_prds_prefix = 0 ;
my $max_ema_periods = $pv{ema01_cnt_prds} ;
if ( $max_ema_periods < $pv{ema02_cnt_prds} ) { $max_ema_periods = $pv{ema02_cnt_prds} } ;
if ( $max_ema_periods < $pv{ema03_cnt_prds} ) { $max_ema_periods = $pv{ema03_cnt_prds} } ;
if ( $max_ema_periods < $pv{ema04_cnt_prds} ) { $max_ema_periods = $pv{ema04_cnt_prds} } ;
if ( $max_ema_periods < $pv{ema05_cnt_prds} ) { $max_ema_periods = $pv{ema05_cnt_prds} } ;
if ( $max_ema_periods < $pv{ema06_cnt_prds} ) { $max_ema_periods = $pv{ema06_cnt_prds} } ;
if ( $max_ema_periods < $pv{ema07_cnt_prds} ) { $max_ema_periods = $pv{ema07_cnt_prds} } ;
if ( $max_ema_periods < $pv{ema08_cnt_prds} ) { $max_ema_periods = $pv{ema08_cnt_prds} } ;

# 20230729 в этом модуле мы не перестраховываемся двойным запасом, а берём запас точно для расчёта EMА с первой записи запрошенного периода
#$ext_period = $pv{count_prds} + $max_ema_periods + 1 ;
#-debug-print "Дополниьельный период == $ext_period == $pv{count_prds} == $count_prds_prefix ;" ;

my $ema01_mult = (2 / ($pv{ema01_cnt_prds} + 1)) ;
my $ema02_mult = (2 / ($pv{ema02_cnt_prds} + 1)) ;
my $ema03_mult = (2 / ($pv{ema03_cnt_prds} + 1)) ;
my $ema04_mult = (2 / ($pv{ema04_cnt_prds} + 1)) ;
my $ema05_mult = (2 / ($pv{ema05_cnt_prds} + 1)) ;
my $ema06_mult = (2 / ($pv{ema06_cnt_prds} + 1)) ;
my $ema07_mult = (2 / ($pv{ema07_cnt_prds} + 1)) ;
my $ema08_mult = (2 / ($pv{ema08_cnt_prds} + 1)) ;

# здесь в функцию передаются ссылки на массивы, которые внутри функции разименовываются
$count_rows = get_ohlcv_from_crcomp_table_offset($pv{count_prds}, $max_ema_periods, $pv{offset_prds}, "full", \@ds_datetime_list, \@ds_days_list, \@ds_hours_list, \@ds_minutes_list, \@ds_price_open, \@ds_price_min, \@ds_price_max, \@ds_price_close, \@ds_end_volume_from, \@ds_end_volume_to) ;
#-debug-#print "--- debug inEMA после отработки функции заполнения --- ds_datetime_list $#ds_datetime_list - ds_days_list $#ds_days_list - ds_hours_list $#ds_hours_list - ds_minutes_list $#ds_minutes_list - ds_price_open $#ds_price_open - ds_price_min $#ds_price_min - ds_price_max $#ds_price_max - ds_price_close $#ds_price_close --- $count_rows\n" ;

for ($i=0; $i < $count_rows ; $i = $i+1) {
# рассчиталь EMA для текущей строки и заполнить ячейку массива
    if ( $pv{ema01_cnt_prds} > 0 ) { if ( $i == 0 ) { $ds_ema01[$i] = $ds_price_close[$i] ; } else { $ds_ema01[$i] = ( $ds_price_close[$i] * $ema01_mult) + ($ds_ema01[$i - 1] * (1 - $ema01_mult)) ; } }
    if ( $pv{ema02_cnt_prds} > 0 ) { if ( $i == 0 ) { $ds_ema02[$i] = $ds_price_close[$i] ; } else { $ds_ema02[$i] = ( $ds_price_close[$i] * $ema02_mult) + ($ds_ema02[$i - 1] * (1 - $ema02_mult)) ; } }
    if ( $pv{ema03_cnt_prds} > 0 ) { if ( $i == 0 ) { $ds_ema03[$i] = $ds_price_close[$i] ; } else { $ds_ema03[$i] = ( $ds_price_close[$i] * $ema03_mult) + ($ds_ema03[$i - 1] * (1 - $ema03_mult)) ; } }
    if ( $pv{ema04_cnt_prds} > 0 ) { if ( $i == 0 ) { $ds_ema04[$i] = $ds_price_close[$i] ; } else { $ds_ema04[$i] = ( $ds_price_close[$i] * $ema04_mult) + ($ds_ema04[$i - 1] * (1 - $ema04_mult)) ; } }
    if ( $pv{ema05_cnt_prds} > 0 ) { if ( $i == 0 ) { $ds_ema05[$i] = $ds_price_close[$i] ; } else { $ds_ema05[$i] = ( $ds_price_close[$i] * $ema05_mult) + ($ds_ema05[$i - 1] * (1 - $ema05_mult)) ; } }
    if ( $pv{ema06_cnt_prds} > 0 ) { if ( $i == 0 ) { $ds_ema06[$i] = $ds_price_close[$i] ; } else { $ds_ema06[$i] = ( $ds_price_close[$i] * $ema06_mult) + ($ds_ema06[$i - 1] * (1 - $ema06_mult)) ; } }
    if ( $pv{ema07_cnt_prds} > 0 ) { if ( $i == 0 ) { $ds_ema07[$i] = $ds_price_close[$i] ; } else { $ds_ema07[$i] = ( $ds_price_close[$i] * $ema07_mult) + ($ds_ema07[$i - 1] * (1 - $ema07_mult)) ; } }
    if ( $pv{ema08_cnt_prds} > 0 ) { if ( $i == 0 ) { $ds_ema08[$i] = $ds_price_close[$i] ; } else { $ds_ema08[$i] = ( $ds_price_close[$i] * $ema08_mult) + ($ds_ema08[$i - 1] * (1 - $ema08_mult)) ; } }
#-debug-#print "--- debug inEMA внутри расчёта ЕМА --- $ds_datetime_list[$i] --- $ds_price_close[$i] --- $ds_ema01[$i] --- \n" ;

# заполнить массивы конверта
    if ( $pv{ema01_cnt_prds} > 0 && $pv{is_envelope_view} == "yes" ) {
       $ds_env_top[$i] = $ds_ema01[$i] + ($ds_ema01[$i] / 100 * $pv{env_prct}) ;
       $ds_env_dwn[$i] = $ds_ema01[$i] - ($ds_ema01[$i] / 100 * $pv{env_prct}) ;
       }
}

if ( $pv{output_type} eq "query" ) { print "Content-Type: text/html\n\n$request\n\n" ; exit ; }

# берём количество результирующих строк без добавленного префикса дней меньше, чем изначально запрошено - в источнике данных было меньше строк
# если записей в БД не хватило на расширенный период - дельта как раз охватит разницу, если совсем не хватило и вышло отрицательное - дельта = 0, т.ею не применяется
my $delta_if_less = $count_rows - $pv{count_prds} ;
if ( $delta_if_less < 0) { $delta_if_less = 0 ; }

#-debug-print "== delta_if_less == $delta_if_less\n" ;
my $count_rows_post = 0 ;
for ($i=1; $i <= $count_rows ; $i = $i+1) {
# учесть дельту
    if (($i - $delta_if_less) > 0) {
#-debug-$aa = int($ds_hours_list[$i - 1] / 2) ; $bb = $ds_hours_list[$i - 1] / 2) ; print "--- $aa \n\n\n" ;
#       if ( (int($ds_hours_list[$i - 1] / 2) - ($ds_hours_list[$i - 1] / 2)) == 0 && $ds_minutes_list[$i - 1] == 0) {
#-20231229-чуть улучшает использование пространства экрана-          $ds_datetime_list[$i - 1] =~ s/(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)/$1$2$3 $4:$5/g ;
          $ds_end_datetime_list[$count_rows_post] = $ds_datetime_list[$i - 1] ;
          $ds_end_hours_list[$count_rows_post] = $ds_hours_list[$i - 1] ;
          $ds_end_minutes_list[$count_rows_post] = $ds_minutes_list[$i - 1] ;
          $ds_end_price_open[$count_rows_post] = $ds_price_open[$i - 1] ;
          $ds_end_price_min[$count_rows_post] = $ds_price_min[$i - 1] ;
          $ds_end_price_max[$count_rows_post] = $ds_price_max[$i - 1] ;
          $ds_end_price_close[$count_rows_post] = $ds_price_close[$i - 1] ;
          if ( $pv{ema01_cnt_prds} > 0 ) { $ds_end_ema01[$count_rows_post] = $ds_ema01[$i - 1] ; }
          if ( $pv{ema02_cnt_prds} > 0 ) { $ds_end_ema02[$count_rows_post] = $ds_ema02[$i - 1] ; }
          if ( $pv{ema03_cnt_prds} > 0 ) { $ds_end_ema03[$count_rows_post] = $ds_ema03[$i - 1] ; }
          if ( $pv{ema04_cnt_prds} > 0 ) { $ds_end_ema04[$count_rows_post] = $ds_ema04[$i - 1] ; }
          if ( $pv{ema05_cnt_prds} > 0 ) { $ds_end_ema05[$count_rows_post] = $ds_ema05[$i - 1] ; }
          if ( $pv{ema06_cnt_prds} > 0 ) { $ds_end_ema06[$count_rows_post] = $ds_ema06[$i - 1] ; }
          if ( $pv{ema07_cnt_prds} > 0 ) { $ds_end_ema07[$count_rows_post] = $ds_ema07[$i - 1] ; }
          if ( $pv{ema08_cnt_prds} > 0 ) { $ds_end_ema08[$count_rows_post] = $ds_ema08[$i - 1] ; }
          if ( $pv{ema01_cnt_prds} > 0 && $pv{is_envelope_view} == "yes" ) {
             $ds_end_env_top[$count_rows_post] = $ds_env_top[$i - 1] ;
             $ds_end_env_dwn[$count_rows_post] = $ds_env_dwn[$i - 1] ;
             }
#-debug-#system("echo \"faza4 include - $aa - $hours - $minutes --- $ds_end_datetime_list[$count_rows] - $ds_hours_list[$count_rows] - $ds_minutes_list[$count_rows] - $ds_price_open[$count_rows] - $ds_price_min[$count_rows] - $ds_price_max[$count_rows] - $ds_price_close[$count_rows] - ema $ds_ema01[$count_rows] - day $ds_ema02[$count_rows] - week $ds_ema03[$count_rows]\" >> /tmp/test_xxx.$pv{currency}") ;
          $count_rows_post += 1 ;
#          }
#-debug-$tmp1 = $i - $delta_if_less - 1 ;
#-debug-$tmp2 = $i - 1 ;
#-debug-print "string - $tmp1 - $tmp2 - $ds_end_date_list[$i - $delta_if_less - 1] - $ds_end_price_open[$i - $delta_if_less - 1] - $ds_end_price_min[$i - $delta_if_less - 1] - $ds_end_price_max[$i - $delta_if_less - 1] - $ds_end_price_close[$i - $delta_if_less - 1] - $ds_end_ema01[$i - $delta_if_less - 1] - $ds_end_ema03[$i - $delta_if_less - 1] - $ds_end_env_top[$i - $delta_if_less - 1] - $ds_end_env_dwn[$i - $delta_if_less - 1]\n" ;
       }
    }

#-debug-exit ;

if ( $pv{output_type} eq "table" ) {
   print "Content-Type: text/html\n\n" ;
   print "<HTML>
<HEAD>
<BASE HREF=\"$COMM_PAR_BASE_HREF/\">
<LINK REL=STYLESHEET HREF=\"$COMM_PAR_BASE_HREF\/css\/common.css\">
<META HTTP-EQUIV=\"Cache-Control\" content=\"no-cache, no-store, max-age=0, must-revalidate\">
<META HTTP-EQUIV=\"Pragma\" content=\"no-cache\">
<META HTTP-EQUIV=\"Expires\" content=\"Fri, 01 Jan 1990 00:00:00 GMT\">
<META HTTP_EQUIV=\"CONTENT-TYPE\" CONTENT=\"text/html; charset=utf-8\">
</HEAD>
<BODY>
<STYLE>
BODY { font-family: sans-serif; font-size: 10pt; }
TD { font-family: sans-serif; font-size: 10pt; }
TD.coinlines { background-color: navy; color: white; }
H1 { text-align: right; color: navy ; }
H2 { text-align: right; color: navy ; }
</STYLE>

<H1>Данные графика цен и EMA $pv{currency} / $pv{curr_reference}</H1>
<H2>таймфрэйм: $pv{tima_frame}, глубина $pv{count_prds} периодов
<BR>глубина EMA: curr $pv{ema01_cnt_prds} / day $pv{ema02_cnt_prds} / week $pv{ema03_cnt_prds}
<BR>глубина конверта: 
</H2>" ;

print "<PRE>currency=$pv{currency}
curr_reference=$pv{curr_reference}
time_frame=$pv{time_frame}
count_prds=$pv{count_prds}
offset_prds=$pv{offset_prds}
env_prct=$pv{env_prct}
output_type=$pv{output_type}
brush_size=$pv{brush_size}
x_size=$pv{x_size}
y_size=$pv{y_size}
is_ema_periods=$pv{is_ema_periods}
is_ema05=$pv{is_ema05}</PRE>" ;

print "<TABLE BORDER=\"1\"><TR><TD STYLE=\"text-align: center;\">№</TD>
       <TD STYLE=\"text-align: center;\">Дата</TD>
       <TD STYLE=\"text-align: center;\">Открытие</TD>
       <TD STYLE=\"text-align: center;\">Минимальная</TD>
       <TD STYLE=\"text-align: center;\">Максимальная</TD>
       <TD STYLE=\"text-align: center;\">Закрытия</TD>
       <TD STYLE=\"text-align: center;\">EMA01 [$pv{ema01_cnt_prds}]</TD>
       <TD STYLE=\"text-align: center;\">EMA02 [$pv{ema02_cnt_prds}]</TD>
       <TD STYLE=\"text-align: center;\">EMA03 [$pv{ema03_cnt_prds}]</TD>
       <TD STYLE=\"text-align: center;\">EMA04 [$pv{ema04_cnt_prds}]</TD>
       <TD STYLE=\"text-align: center;\">EMA05 [$pv{ema05_cnt_prds}]</TD>
       <TD STYLE=\"text-align: center;\">EMA06 [$pv{ema06_cnt_prds}]</TD>
       <TD STYLE=\"text-align: center;\">EMA07 [$pv{ema07_cnt_prds}]</TD>
       <TD STYLE=\"text-align: center;\">EMA08 [$pv{ema08_cnt_prds}]</TD>
       <TD STYLE=\"text-align: center;\">Часы</TD>
       <TD STYLE=\"text-align: center;\">Минуты</TD>
       </TR>" ;
   for ($curr_row = 0; $curr_row <= $#ds_end_datetime_list ; $curr_row += 1) {
       print "<TR><TD>$curr_row</TD>
                  <TD>$ds_end_datetime_list[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_price_open[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_price_min[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_price_max[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_price_close[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_ema01[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_ema02[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_ema03[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_ema04[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_ema05[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_ema06[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_ema07[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_ema08[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_hours_list[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_minutes_list[$curr_row]</TD>
               </TR>\n" ;
       }
   print "</TABLE>" ;
   }

if ( $pv{output_type} eq "graph" || $pv{output_type} eq "file" ) {
   my $graphic ;
   my $min_y ;
   my $max_y ;

   $graphic = Chart::Lines->new( $pv{x_size}, $pv{y_size} ) ;
   $graphic->set( 'brush_size' => $pv{brush_size} ) ;

   $graphic->add_dataset(@ds_end_datetime_list) ;
   if ( $pv{is_envelope_view} == "yes" ) {
      $graphic->add_dataset(@ds_end_env_top) ;
      $graphic->add_dataset(@ds_end_env_dwn) ;
      }
   $graphic->add_dataset(@ds_end_price_open) ;
   $graphic->add_dataset(@ds_end_price_min) ;
   $graphic->add_dataset(@ds_end_price_max) ;
   $graphic->add_dataset(@ds_end_price_close) ;
   if ( $pv{ema01_cnt_prds} > 0 ) { $graphic->add_dataset(@ds_end_ema01) ; }
   if ( $pv{ema02_cnt_prds} > 0 ) { $graphic->add_dataset(@ds_end_ema02) ; }
   if ( $pv{ema03_cnt_prds} > 0 ) { $graphic->add_dataset(@ds_end_ema03) ; }
   if ( $pv{ema04_cnt_prds} > 0 ) { $graphic->add_dataset(@ds_end_ema04) ; }
   if ( $pv{ema05_cnt_prds} > 0 ) { $graphic->add_dataset(@ds_end_ema05) ; }
   if ( $pv{ema06_cnt_prds} > 0 ) { $graphic->add_dataset(@ds_end_ema06) ; }
   if ( $pv{ema07_cnt_prds} > 0 ) { $graphic->add_dataset(@ds_end_ema07) ; }
   if ( $pv{ema08_cnt_prds} > 0 ) { $graphic->add_dataset(@ds_end_ema08) ; }

# выставляем начальные границы отображения
   my $min_y ; my $ema01_min_y ; my $ema02_min_y ; my $ema03_min_y ; my $ema04_min_y ; my $ema05_min_y ; my $ema06_min_y ; my $ema07_min_y ; my $ema08_min_y ; my $env_min_y ;
   my $max_y ; my $ema01_max_y ; my $ema02_max_y ; my $ema03_max_y ; my $ema04_max_y ; my $ema05_max_y ; my $ema06_max_y ; my $ema07_max_y ; my $ema08_max_y ; my $env_max_y ;

   $min_y = $ds_end_price_min[0] ; foreach (@ds_end_price_min) { if ( $_ < $min_y ) { $min_y = $_; } }
   $max_y = $ds_end_price_max[0] ; foreach (@ds_end_price_max) { if ( $_ > $max_y ) { $max_y = $_; } }

# добавляем учёт ЕМА и конвертов для границ отображения
   if ( $pv{ema01_cnt_prds} > 0 ) { $ema01_min_y = $ds_end_ema01[0] ; foreach (@ds_end_ema01) { if ( $_ < $ema01_min_y ) { $ema01_min_y = $_; } } if ($min_y > $ema01_min_y) { $min_y = $ema01_min_y ; } $ema01_max_y = $ds_end_ema01[0] ; foreach (@ds_end_ema01) { if ( $_ > $ema01_max_y ) { $ema01_max_y = $_; } } if ($max_y < $ema01_min_y) { $max_y = $ema01_max_y ; } }
   if ( $pv{ema02_cnt_prds} > 0 ) { $ema02_min_y = $ds_end_ema02[0] ; foreach (@ds_end_ema02) { if ( $_ < $ema02_min_y ) { $ema02_min_y = $_; } } if ($min_y > $ema02_min_y) { $min_y = $ema02_min_y ; } $ema02_max_y = $ds_end_ema02[0] ; foreach (@ds_end_ema02) { if ( $_ > $ema02_max_y ) { $ema02_max_y = $_; } } if ($max_y < $ema02_min_y) { $max_y = $ema02_max_y ; } }
   if ( $pv{ema03_cnt_prds} > 0 ) { $ema03_min_y = $ds_end_ema03[0] ; foreach (@ds_end_ema03) { if ( $_ < $ema03_min_y ) { $ema03_min_y = $_; } } if ($min_y > $ema03_min_y) { $min_y = $ema03_min_y ; } $ema03_max_y = $ds_end_ema03[0] ; foreach (@ds_end_ema03) { if ( $_ > $ema03_max_y ) { $ema03_max_y = $_; } } if ($max_y < $ema03_min_y) { $max_y = $ema03_max_y ; } }
   if ( $pv{ema04_cnt_prds} > 0 ) { $ema04_min_y = $ds_end_ema04[0] ; foreach (@ds_end_ema04) { if ( $_ < $ema04_min_y ) { $ema04_min_y = $_; } } if ($min_y > $ema04_min_y) { $min_y = $ema04_min_y ; } $ema04_max_y = $ds_end_ema04[0] ; foreach (@ds_end_ema04) { if ( $_ > $ema04_max_y ) { $ema04_max_y = $_; } } if ($max_y < $ema04_min_y) { $max_y = $ema04_max_y ; } }
   if ( $pv{ema05_cnt_prds} > 0 ) { $ema05_min_y = $ds_end_ema05[0] ; foreach (@ds_end_ema05) { if ( $_ < $ema05_min_y ) { $ema05_min_y = $_; } } if ($min_y > $ema05_min_y) { $min_y = $ema05_min_y ; } $ema05_max_y = $ds_end_ema05[0] ; foreach (@ds_end_ema05) { if ( $_ > $ema05_max_y ) { $ema05_max_y = $_; } } if ($max_y < $ema05_min_y) { $max_y = $ema05_max_y ; } }
   if ( $pv{ema06_cnt_prds} > 0 ) { $ema06_min_y = $ds_end_ema06[0] ; foreach (@ds_end_ema06) { if ( $_ < $ema06_min_y ) { $ema06_min_y = $_; } } if ($min_y > $ema06_min_y) { $min_y = $ema06_min_y ; } $ema06_max_y = $ds_end_ema06[0] ; foreach (@ds_end_ema06) { if ( $_ > $ema06_max_y ) { $ema06_max_y = $_; } } if ($max_y < $ema06_min_y) { $max_y = $ema06_max_y ; } }
   if ( $pv{ema07_cnt_prds} > 0 ) { $ema07_min_y = $ds_end_ema07[0] ; foreach (@ds_end_ema07) { if ( $_ < $ema07_min_y ) { $ema07_min_y = $_; } } if ($min_y > $ema07_min_y) { $min_y = $ema07_min_y ; } $ema07_max_y = $ds_end_ema07[0] ; foreach (@ds_end_ema07) { if ( $_ > $ema07_max_y ) { $ema07_max_y = $_; } } if ($max_y < $ema07_min_y) { $max_y = $ema07_max_y ; } }
   if ( $pv{ema08_cnt_prds} > 0 ) { $ema08_min_y = $ds_end_ema08[0] ; foreach (@ds_end_ema08) { if ( $_ < $ema08_min_y ) { $ema08_min_y = $_; } } if ($min_y > $ema08_min_y) { $min_y = $ema08_min_y ; } $ema08_max_y = $ds_end_ema08[0] ; foreach (@ds_end_ema08) { if ( $_ > $ema08_max_y ) { $ema08_max_y = $_; } } if ($max_y < $ema08_min_y) { $max_y = $ema08_max_y ; } }
# добавляем учёт конверта
   if ( $pv{ema01_cnt_prds} > 0 && $pv{is_envelope_view} == "yes" ) {
      $env_min_y = $ds_end_env_dwn[0] ; foreach (@ds_end_env_dwn) { if ( $_ < $env_min_y ) { $env_min_y = $_; } }
      $env_max_y = $ds_end_env_top[0] ; foreach (@ds_end_env_top) { if ( $_ > $env_max_y ) { $env_max_y = $_; } }
      if ($min_y > $env_min_y) { $min_y = $env_min_y ; }
      if ($max_y < $env_max_y) { $max_y = $env_max_y ; }
      }
   $graphic->set( 'min_val' => $min_y ) ;
   $graphic->set( 'max_val' => $max_y ) ;

   my $precision = 4 ;
   if ( $max_y < 1 ) { $precision = 5 ; }
   if ( $max_y < 0.1 ) { $precision = 6 ; }
   if ( $max_y < 0.01 ) { $precision = 7 ; }
   if ( $max_y < 0.001 ) { $precision = 8 ; }
   if ( $max_y < 0.0001 ) { $precision = 9 ; }
   if ( $max_y < 0.00001 ) { $precision = 10 ; }
   if ( $max_y < 0.000001 ) { $precision = 11 ; }
   if ( $max_y < 0.0000001 ) { $precision = 12 ; }
   if ( $max_y < 0.00000001 ) { $precision = 13 ; }
   if ( $max_y < 0.000000001 ) { $precision = 14 ; }
   if ( $max_y < 0.0000000001 ) { $precision = 15 ; }
   if ( $max_y < 0.00000000001 ) { $precision = 16 ; }
   if ( $max_y < 0.000000000001 ) { $precision = 17 ; }
   if ( $max_y < 0.0000000000001 ) { $precision = 18 ; }
   if ( $max_y < 0.00000000000001 ) { $precision = 19 ; }
   $graphic->set( 'precision' => $precision );

   $graphic->set( 'max_y_ticks' => 12 ) ;
   $graphic->set( 'min_y_ticks' => 2 ) ;
   $graphic->set( 'transparent' => 'false' ) ;

# - похоже, влияет только на линии сетки и подписи, на основаниир сверки скриншотов. Без этого параметра плохо читаемо
   my $skip_x_ticks = ($count_rows - $delta_if_less) / 80 ;
#   my $skip_x_ticks = 2 ;
   $graphic->set( 'skip_x_ticks' => $skip_x_ticks ) ;
   $graphic->set( 'x_ticks'      => 'vertical' ) ;
#   $graphic->set( 'x_ticks'      => 'normal' ) ;
#   $graphic->set( 'x_ticks'      => 'staggered' ) ;
   $graphic->set( 'grey_background' => 'false' ) ;
   $graphic->set( 'graph_border'    => 1 ) ;
#$graphic->set( 'title'           => $title_name );
#$graphic->set( 'sub_title'       => "over Time" );
#$graphic->set( 'sub_title'       => "(C) 2000-2016, Sergey S. Belonin" );
   $graphic->set( 'y_grid_lines'    => 'true' ) ;
   $graphic->set( 'x_grid_lines'    => 'true' ) ;
   $graphic->set( 'colors' => { 'y_grid_lines' => [ 127, 127, 0 ], 'x_grid_lines' => [ 127, 127, 0 ], 'dataset0' => [ 0, 0, 200 ] } ) ;
   $graphic->set( 'legend'  => 'none' ) ;
#$graphic->set( 'x_label' => 'Time (UTC)' );
   $graphic->set( 'y_label' => "OHLC $pv{time_frame}, EMAs $pv{ema01_cnt_prds}/$pv{ema02_cnt_prds}/$pv{ema03_cnt_prds}/$pv{ema04_cnt_prds} $pv{currency}/$pv{curr_reference}" );
   $graphic->set( 'label_font' => GD::Font->Giant ) ;

   $graphic->set( 'y_axes'  => 'both' ) ;

   $graphic->set( 'colors' => {
                          'y_grid_lines' => [ 127, 127, 0 ],
                          'x_grid_lines' => [ 127, 127, 0 ],
                          'dataset0'   => gray,
                          'dataset1'   => gray,
                          'dataset2'   => blue,
                          'dataset3'   => green,
                          'dataset4'   => green,
                          'dataset5'   => red,
                          'dataset6'   => purple,
                          'dataset7'   => brown,
                          'dataset8'   => orange,
                          'dataset9'   => yellow,
                          'dataset10'  => cyan,
                          'dataset11'   => red,
                          'dataset12'   => red,
                          'dataset13'   => red
                          } ) ;

   if ( $pv{output_type} eq "graph" ) { $graphic->cgi_png() ; }
   if ( $pv{output_type} eq "file" ) { $graphic->png($pv{file_name}) ; }
   }
