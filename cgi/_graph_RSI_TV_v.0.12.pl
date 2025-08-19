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

$pv{rsi_periods} = 14 ;
# - вытащить из URL запроса значения уточняющих полей
&get_forms_param() ;

#-debug-$pv{currency} = 'LINK' ; $pv{curr_reference} = 'USD' ; $pv{count_prds} = '90' ; $pv{rsi_periods} = '14' ; $pv{low_level} = '30' ; $pv{up_level} = '70' ; $pv{output_type} = 'graph' ; $pv{brush_size} = '4' ; $pv{x_size} = '1400' ; $pv{y_size} = '640' ;
#-debug-$pv{output_type} = 'table' ;
#-debug-$pv{output_type} = 'check_treshold' ;

$CURR_YEAR = `date +%Y` ; $CURR_YEAR =~ s/[\r\n]+//g ;
$request = " " ;
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
my @ds_end_volume_from = () ;
my @ds_end_volume_to = () ;

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

# здесь в функцию передаются ссылки на массивы (операнд \@), которые внутри функции разименовываются (операнд my $loc_ref_arr = $_[0] ; $loc_ref_arr->[номер_элемента])
#$count_rows = get_ohlcv_from_crcomp_table(\@ds_datetime_list, \@ds_days_list, \@ds_hours_list, \@ds_minutes_list, \@ds_price_open, \@ds_price_min, \@ds_price_max, \@ds_price_close, $max_ema_periods, "middle") ;
$count_rows = get_ohlcv_from_crcomp_table_offset($pv{count_prds}, $ext_period, $pv{offset_prds}, "middle", \@ds_datetime_list, \@ds_days_list, \@ds_hours_list, \@ds_minutes_list, \@ds_price_open, \@ds_price_min, \@ds_price_max, \@ds_price_close, \@ds_end_volume_from, \@ds_end_volume_to) ;
#-debug-#print "--- debug inEMA после отработки функции заполнения --- ds_datetime_list $#ds_datetime_list - ds_days_list $#ds_days_list - ds_hours_list $#ds_hours_list - ds_minutes_list $#ds_minutes_list - ds_p

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

#-debug-print "$count_rows $count_rows_post $#ds_end_datetime_list\n" ;
#-debug-print "$#ds_end_datetime_list $#ds_end_price_close $ds_end_RSI $#ds_end_low_level $#ds_end_low_level\n" ;
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

<H1>Данные осциллятора RSI $pv{currency} / $pv{curr_reference}</H1>
<H2>период $pv{count_prds} дн. от текущей даты
<BR>расчётное окно = $pv{rsi_periods} периодов
<BR>нижний уровень = $pv{low_level}, верхний уровень = $pv{up_level}
</H2>

<TABLE BORDER=\"1\"><TR><TD STYLE=\"text-align: center;\">№</TD>
       <TD STYLE=\"text-align: center;\">Дата</TD>
       <TD STYLE=\"text-align: center;\">Цена закрытия</TD>
       <TD STYLE=\"text-align: center;\">Дельта вверх</TD>
       <TD STYLE=\"text-align: center;\">Дельта вверх, RMA</TD>
       <TD STYLE=\"text-align: center;\">Дельта вниз</TD>
       <TD STYLE=\"text-align: center;\">Дельта вниз, RMA</TD>
       <TD STYLE=\"text-align: center;\">RS</TD>
       <TD STYLE=\"text-align: center;\">RSI, %</TD>
       <TD STYLE=\"text-align: center;\">LOW, $pv{low_level}</TD>
       <TD STYLE=\"text-align: center;\">UP, $pv{up_level}</TD>
       </TR>" ;
   for ($curr_row = 0; $curr_row <= $#ds_end_datetime_list; $curr_row += 1) {
       print "<TR><TD STYLE=\"text-align: right;\">$curr_row</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_datetime_list[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_price_close[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_change_up[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_change_up_rma[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_change_down[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_change_down_rma[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_RS[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_RSI[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_low_level[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_top_level[$curr_row]</TD></TR>\n" ;
       }
   print "</TABLE>" ;
   }

if ( $pv{output_type} eq "graph" || $pv{output_type} eq "file" ) {
   my $graphic ;
   my $min_y ;
   my $max_y ;

   $graphic = Chart::Lines->new( $pv{x_size}, $pv{y_size} ) ;

   $graphic->add_dataset(@ds_end_datetime_list) ;
   $graphic->add_dataset(@ds_end_low_level) ;
   $graphic->add_dataset(@ds_end_top_level) ;
   $graphic->add_dataset(@ds_end_RSI) ;

# расчёт для выставления точности - количества нулей
   $min_y = $max_y = @ds_end_price_close[0] ;
   foreach (@ds_end_price_close) {
           if ( $_ < $min_y ) { $min_y = $_; }
           if ( $_ > $max_y ) { $max_y = $_; }
           }
#   $graphic->set( 'min_val' => $min_y ) ;
#   $graphic->set( 'max_val' => $max_y ) ;
   $graphic->set( 'min_val' => 0 ) ;
   $graphic->set( 'max_val' => 100 ) ;

  my $precision = 4 ;
   if ( $max_y < 1 ) { $precision = 4 ; }
   if ( $max_y < 0.1 ) { $precision = 4 ; }
   if ( $max_y < 0.01 ) { $precision = 5 ; }
   if ( $max_y < 0.001 ) { $precision = 6 ; }
   if ( $max_y < 0.0001 ) { $precision = 7 ; }
   if ( $max_y < 0.00001 ) { $precision = 8 ; }
   if ( $max_y < 0.000001 ) { $precision = 9 ; }
   if ( $max_y < 0.0000001 ) { $precision = 10 ; }
   if ( $max_y < 0.00000001 ) { $precision = 11 ; }
   if ( $max_y < 0.000000001 ) { $precision = 12 ; }
   if ( $max_y < 0.0000000001 ) { $precision = 13 ; }
   if ( $max_y < 0.00000000001 ) { $precision = 14 ; }
   if ( $max_y < 0.000000000001 ) { $precision = 15 ; }
   if ( $max_y < 0.0000000000001 ) { $precision = 16 ; }
   if ( $max_y < 0.00000000000001 ) { $precision = 17 ; }
   $precision -= 1 ;

# - похоже, влияет только на линии сетки и подписи, на основаниир сверки скриншотов. Без этого параметра плохо читаемо
   my $skip_x_ticks = $count_rows / 80 ;

   $graphic->set( 'skip_x_ticks'    => $skip_x_ticks,
                  'x_ticks'         => 'vertical',
                  'grey_background' => 'false',
                  'graph_border'    => 1,
                  'y_grid_lines'    => 'true',
                  'x_grid_lines'    => 'true',
                  'legend'          => 'none',
                  'y_label'         => "RSI_TV $pv{time_frame} $pv{currency}/$pv{curr_reference}",
                  'label_font'      => GD::Font->Giant,
                  'y_axes'          => 'both',
                  'precision'       => $precision,
                  'max_y_ticks'     => 12,
                  'min_y_ticks'     => 4,
                  'transparent'     => 'false',
                  'brush_size'      => $pv{brush_size} ) ;

   $graphic->set( 'colors' => {
                          'y_grid_lines' => [ 127, 127, 0 ],
                          'x_grid_lines' => [ 127, 127, 0 ],
                          'dataset0'     => brown,
                          'dataset1'     => brown,
                          'dataset2'     => purple
                          } ) ;
   if ( $pv{output_type} eq "graph" ) { $graphic->cgi_png() ; }
   if ( $pv{output_type} eq "file" ) { $graphic->png($pv{file_name}) ; }
   }
