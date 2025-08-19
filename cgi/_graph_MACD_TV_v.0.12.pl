#!/usr/bin/perl

# open source soft - (C) 2023 CrAgrAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

use DBI ;
use Chart::Lines ;
use Chart::StackedBars ;
use Chart::Composite ;
require "/var/www/crypta/cgi/common_parameter.cragregator" ;
require "$cragran_dir_lib/lib_common_func.pl" ;
require "$cragran_dir_lib/lib_cragran_common.pl" ;
require "$cragran_dir_lib/lib_cragran_trading.pl" ;
require "$cragran_dir_lib/lib_cragran_contracts.pl" ;

# - вытащить из URL запроса значения уточняющих полей
&get_forms_param() ;

#-debug-$pv{currency} = 'LINK' ; $pv{curr_reference} = 'USDT' ; $pv{count_prds} = '90' ; $pv{rsi_periods} = '14' ; $pv{low_level} = '30' ; $pv{up_level} = '70' ; $pv{output_type} = 'graph' ; $pv{brush_size} = '4' ; $pv{x_size} = '1400' ; $pv{y_size} = '640' ;
#-debug-$pv{currency} = 'ICX' ; $pv{curr_reference} = 'USDT' ; $pv{time_frame} = '3H' ; $pv{count_prds} = '320' ; $pv{output_type} = 'graph' ; $pv{brush_size} = '4' ; $pv{x_size} = '1400' ; $pv{y_size} = '640' ;
#-debug-$pv{output_type} = 'table' ;

$CURR_YEAR = `date +%Y` ; $CURR_YEAR =~ s/[\r\n]+//g ;
$request = " " ;
my $count_rows = 0 ;
my $count_rows_post = 0 ;

# рассчитать расширение дней от начального периода, чтобы успешно посчитать все ЕМА на начало периода (тут берётся из часовых записей, т.е. *2)
# здесь период дополнительного расчёта задан жёстко, т.к. по формуле считаем ЕМА 12 и 26 периодов
my $max_ema_periods = 26 ;

# массивы для заполненения функцией заполнения OHLCV
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
my @ds_end_datetime_list = () ;
my @ds_end_price_close = () ;
my @ds_end_ema12 = () ;
my @ds_end_ema26 = () ;
my @ds_end_diff_ema1226 = () ;
my @ds_end_ema9_diff = () ;
my @ds_end_null_line = () ;

my @ds_end_gist_up_from_up = () ;
my @ds_end_gist_up_from_down = () ;
my @ds_end_gist_down_from_up = () ;
my @ds_end_gist_down_from_down = () ;

my $ema12_multi = (2 / (12 + 1)) ;
my $ema26_multi = (2 / (26 + 1)) ;
my $ema9_multi = (2 / (9 + 1)) ;

# здесь в функцию передаются ссылки на массивы (операнд \@), которые внутри функции разименовываются (операнд my $loc_ref_arr = $_[0] ; $loc_ref_arr->[номер_элемента])
#$count_rows = get_ohlcv_from_crcomp_table(\@ds_datetime_list, \@ds_days_list, \@ds_hours_list, \@ds_minutes_list, \@ds_price_open, \@ds_price_min, \@ds_price_max, \@ds_price_close, $max_ema_periods, "middle") ;
$count_rows = get_ohlcv_from_crcomp_table_offset($pv{count_prds}, $max_ema_periods, $pv{offset_prds}, "middle", \@ds_datetime_list, \@ds_days_list, \@ds_hours_list, \@ds_minutes_list, \@ds_price_open, \@ds_price_min, \@ds_price_max, \@ds_price_close, \@ds_volume_from, \@ds_volume_to) ;
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
# $ds_end_datetime_list[$count_rows_post] =~ s///g ;
       $ds_end_price_close[$count_rows_post] = $ds_price_close[$i - 1] ;
       $ds_end_ema12[$count_rows_post] = $ds_ema12[$i - 1] ;
       $ds_end_ema26[$count_rows_post] = $ds_ema26[$i - 1] ;
       $ds_end_diff_ema1226[$count_rows_post] = $ds_diff_ema1226[$i - 1] ;
       $ds_end_ema9_diff[$count_rows_post] = $ds_ema9_diff[$i - 1] ;
       $ds_end_null_line[$count_rows_post] = $ds_null_line[$i - 1] ;
#-debug-$tmp1 = $i - $delta_if_less - 1 ;
#-debug-$tmp2 = $i - 1 ;
#-debug-print "string - $tmp1 - $tmp2 - $ds_end_datetime_list[$i - $delta_if_less - 1] - $ds_end_price_open[$i - $delta_if_less - 1] - $ds_end_price_min[$i - $delta_if_less - 1] - $ds_end_price_max[$i - $delta_if_less - 1] - $ds_end_price_cl
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

<H1>Данные осциллятора MACD $pv{currency} / $pv{curr_reference}</H1>
<H2>период $pv{count_prds} дн. от текущей даты
<BR>нижний уровень = $pv{low_level}, верхний уровень = $pv{up_level}
</H2>

<TABLE BORDER=\"1\"><TR><TD STYLE=\"text-align: center;\">№</TD>
       <TD STYLE=\"text-align: center;\">Дата</TD>
       <TD STYLE=\"text-align: right;\">EMA9 DIFF</TD>
       <TD STYLE=\"text-align: right;\">EMA_1226_DIFF</TD>
       <TD STYLE=\"text-align: right;\">GIST_UP_from_UP</TD>
       <TD STYLE=\"text-align: right;\">GIST_UP_from_DOWN</TD>
       <TD STYLE=\"text-align: right;\">GIST_DOWN_from_UP</TD>
       <TD STYLE=\"text-align: right;\">GIST_DOWN_from_DOWN</TD>
       </TR>" ;
   for ($curr_row = 0; $curr_row <= $#ds_end_datetime_list; $curr_row += 1) {
       print "<TR><TD>$curr_row</TD>
                  <TD>$ds_end_datetime_list[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_ema9_diff[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_diff_ema1226[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_gist_up_from_up[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_gist_up_from_down[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_gist_down_from_up[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_gist_down_from_down[$curr_row]</TD>
                  </TR>\n" ;
       }
   print "</TABLE>" ;
   }

if ( $pv{output_type} eq "graph" || $pv{output_type} eq "file" ) {
   my $graphic ;
   my $min_y ;
   my $max_y ;
   my $min_supp_y ;
   my $max_supp_y ;

#   $graphic = Chart::Lines->new( $pv{x_size}, $pv{y_size} ) ;
   $graphic = Chart::Composite->new( $pv{x_size}, $pv{y_size} ) ;

   $graphic->add_dataset(@ds_end_datetime_list) ;
   $graphic->add_dataset(@ds_end_null_line) ;
   $graphic->add_dataset(@ds_end_ema9_diff) ;
   $graphic->add_dataset(@ds_end_diff_ema1226) ;

   $graphic->add_dataset(@ds_end_gist_up_from_up) ;
   $graphic->add_dataset(@ds_end_gist_up_from_down) ;
   $graphic->add_dataset(@ds_end_gist_down_from_up) ;
   $graphic->add_dataset(@ds_end_gist_down_from_down) ;

   $graphic->set( 'composite_info' => [[ 'StackedBars', [ 4, 5, 6, 7 ] ], [ 'Lines', [1, 2, 3] ] ] );

   $min_y = $max_y = @ds_end_diff_ema1226[0] ;
   foreach (@ds_end_diff_ema1226) {
           if ( $_ < $min_y ) { $min_y = $_; }
           if ( $_ > $max_y ) { $max_y = $_; }
           }
   $min_supp_y = $max_supp_y = @ds_end_ema9_diff[0] ;
   foreach (@ds_end_ema9_diff) {
           if ( $_ < $min_supp_y ) { $min_supp_y = $_; }
           if ( $_ > $max_supp_y ) { $max_supp_y = $_; }
           }
   if ( $min_supp_y < $min_y ) { $min_y = $min_supp_y ; }
   if ( $max_supp_y > $max_y ) { $max_y = $max_supp_y ; }

foreach (@ds_end_gist_up_from_up) { if ( $_ < $min_y ) { $min_y = $_; } if ( $_ > $max_y ) { $max_y = $_; } }
foreach (@ds_end_gist_up_from_down) { if ( $_ < $min_y ) { $min_y = $_; } if ( $_ > $max_y ) { $max_y = $_; } }
foreach (@ds_end_gist_down_from_down) { if ( $_ < $min_y ) { $min_y = $_; } if ( $_ > $max_y ) { $max_y = $_; } }
foreach (@ds_end_gist_down_from_up) { if ( $_ < $min_y ) { $min_y = $_; } if ( $_ > $max_y ) { $max_y = $_; } }

#-before composite   $graphic->set( 'min_val' => $min_y ) ;
#   $graphic->set( 'max_val' => $max_y ) ;

   $graphic->set( 'min_val1' => $min_y ) ;
   $graphic->set( 'max_val1' => $max_y ) ;

   $graphic->set( 'min_val2' => $min_y ) ;
   $graphic->set( 'max_val2' => $max_y ) ;

#   $graphic->set( 'y_ticks2' => 0 ) ;
#   $graphic->set( 'f_y_ticks2' => '' ) ;

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
   $precision -= 1;
   $graphic->set( 'precision' => $precision );

   $graphic->set( 'max_y_ticks' => 12 ) ;
   $graphic->set( 'min_y_ticks' => 2 ) ;

# - похоже, влияет только на линии сетки и подписи, на основаниир сверки скриншотов. Без этого параметра плохо читаемо
   my $skip_x_ticks = $count_rows / 80 ;
#   my $skip_x_ticks = $count_rows / 160 ;

   $graphic->set( 'skip_x_ticks' => $skip_x_ticks,
                  'x_ticks'      => 'vertical',
                  'grey_background' => 'false',
                  'graph_border'    => 1,
                  'y_grid_lines'    => 'true',
                  'x_grid_lines'    => 'true',
                  'legend'  => 'none',
                  'y_label' => "MACD_TV $pv{time_frame}, $pv{currency}/$pv{curr_reference}",
#                  'label_font' => GD::Font->Giant,
                  'include_zero' => 'false',
                  'brush_size1' => 1,
                  'brush_size2' => 4,
                  'brush_size' => $pv{brush_size},
                  'transparent' => 'false'
                  ) ;

   $graphic->set( 'colors' => {
                          'y_grid_lines' => [ 127, 127, 0 ],
                          'x_grid_lines' => [ 127, 127, 0 ],
                          'dataset0'     => darkgreen,
                          'dataset1'     => lightgreen,
                          'dataset2'     => red,
                          'dataset3'     => darkred,
                          'dataset4'     => brown,
                          'dataset5'     => orange,
                          'dataset6'     => navy
                          } ) ;
   if ( $pv{output_type} eq "graph" ) { $graphic->cgi_png() ; }
   if ( $pv{output_type} eq "file" ) { $graphic->png($pv{file_name}) ; }
   }
