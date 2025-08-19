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

my @ds_end_datetime_list = () ;
my @ds_end_volume_up = () ;
my @ds_end_volume_down = () ;

# здесь в функцию передаются ссылки на массивы (операнд \@), которые внутри функции разименовываются (операнд my $loc_ref_arr = $_[0] ; $loc_ref_arr->[номер_элемента])
#$count_rows = get_ohlcv_from_crcomp_table(\@ds_datetime_list, \@ds_days_list, \@ds_hours_list, \@ds_minutes_list, \@ds_price_open, \@ds_price_min, \@ds_price_max, \@ds_price_close, $max_ema_periods, "middle") ;
# а вто ТФ, определяющий запрос, просто наследуется от вызывающего родителя
$count_rows = get_ohlcv_from_crcomp_table_offset($pv{count_prds}, $max_ema_periods, $pv{offset_prds}, "middle", \@ds_datetime_list, \@ds_days_list, \@ds_hours_list, \@ds_minutes_list, \@ds_price_open, \@ds_price_min, \@ds_price_max, \@ds_price_close, \@ds_volume_from, \@ds_volume_to) ;
#-debug-#print "--- debug inEMA после отработки функции заполнения --- ds_datetime_list $#ds_datetime_list - ds_days_list $#ds_days_list - ds_hours_list $#ds_hours_list - ds_minutes_list $#ds_minutes_list - ds_p

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
       if ( $i > 1 ) {
          if ( $ds_volume_from[$i - 1] >= $ds_volume_from[$i - 2] ) {
             $ds_end_volume_up[$count_rows_post] = $ds_volume_from[$i - 1] ;
             $ds_end_volume_down[$count_rows_post] = 0 ;
             }
          else {
             $ds_end_volume_up[$count_rows_post] = 0 ;
             $ds_end_volume_down[$count_rows_post] = $ds_volume_from[$i - 1] ;
             }
          }
       else {
            $ds_end_volume_up[$count_rows_post] = $ds_volume_from[$i - 1] ;
            $ds_end_volume_down[$count_rows_post] = 0 ;
            }
       $count_rows_post += 1 ;
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
       <TD STYLE=\"text-align: right;\">VOLUME UP</TD>
       <TD STYLE=\"text-align: right;\">VOLUME DOWN</TD>
       </TR>" ;
   for ($curr_row = 0; $curr_row <= $#ds_end_datetime_list; $curr_row += 1) {
       print "<TR><TD>$curr_row</TD>
                  <TD>$ds_end_datetime_list[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_volume_up[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_end_volume_down[$curr_row]</TD>
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
#   $graphic = Chart::Composite->new( $pv{x_size}, $pv{y_size} ) ;


   $graphic = Chart::StackedBars->new( $pv{x_size}, $pv{y_size} ) ;

   $graphic->add_dataset(@ds_end_datetime_list) ;
   $graphic->add_dataset(@ds_end_volume_up) ;
   $graphic->add_dataset(@ds_end_volume_down) ;

#   $graphic->set( 'brush_size' => $pv{brush_size} ) ;

#   $graphic->set( 'composite_info' => [[ 'StackedBars', [ 4, 5, 6, 7 ] ], [ 'Lines', [1, 2, 3] ] ] );

   $min_y = $max_y = @ds_end_volume_up[0] ;
   foreach (@ds_end_volume_to) {
           if ( $_ < $min_y ) { $min_y = $_; }
           if ( $_ > $max_y ) { $max_y = $_; }
           }
   foreach (@ds_end_volume_down) {
           if ( $_ < $min_y ) { $min_y = $_; }
           if ( $_ > $max_y ) { $max_y = $_; }
           }

#-before composite   $graphic->set( 'min_val' => $min_y ) ;
#   $graphic->set( 'max_val' => $max_y ) ;

   $graphic->set( 'min_val1' => $min_y ) ;
   $graphic->set( 'max_val1' => $max_y ) ;

   $graphic->set( 'min_val2' => $min_y ) ;
   $graphic->set( 'max_val2' => $max_y ) ;

#   $graphic->set( 'y_ticks2' => 0 ) ;
#   $graphic->set( 'f_y_ticks2' => '' ) ;

   my $precision = 0 ;
#   if ( $max_y < 1 ) { $precision = 4 ; }
#   if ( $max_y < 0.1 ) { $precision = 4 ; }
#   if ( $max_y < 0.01 ) { $precision = 5 ; }
#   if ( $max_y < 0.001 ) { $precision = 6 ; }
#   if ( $max_y < 0.0001 ) { $precision = 7 ; }
#   if ( $max_y < 0.00001 ) { $precision = 8 ; }
#   if ( $max_y < 0.000001 ) { $precision = 9 ; }
#   if ( $max_y < 0.0000001 ) { $precision = 10 ; }
#   if ( $max_y < 0.00000001 ) { $precision = 11 ; }
#   if ( $max_y < 0.000000001 ) { $precision = 12 ; }
#   if ( $max_y < 0.0000000001 ) { $precision = 13 ; }
#   if ( $max_y < 0.00000000001 ) { $precision = 14 ; }
#   if ( $max_y < 0.000000000001 ) { $precision = 15 ; }
#   if ( $max_y < 0.0000000000001 ) { $precision = 16 ; }
#   if ( $max_y < 0.00000000000001 ) { $precision = 17 ; }
#   $precision -= 1;
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
                  'y_label' => "VOLUME $pv{time_frame}, $pv{currency}/$pv{curr_reference}",
#                  'label_font' => GD::Font->Giant,
                  'include_zero' => 'false',
#                  'brush_size1' => 1,
#                  'brush_size2' => 4,
                  'brush_size' => $pv{brush_size},
                  'transparent' => 'false',
                  'y_axes'          => 'both'
                  ) ;

#                          'dataset0'     => darkgreen,
#                          'dataset1'     => lightgreen,
#                          'dataset2'     => red,
#                          'dataset3'     => darkred,
#                          'dataset4'     => brown,
#                          'dataset5'     => orange,


   $graphic->set( 'colors' => {
                          'y_grid_lines' => [ 127, 127, 0 ],
                          'x_grid_lines' => [ 127, 127, 0 ],
                          'dataset0'     => green,
                          'dataset1'     => red
                          } ) ;
   if ( $pv{output_type} eq "graph" ) { $graphic->cgi_png() ; }
   if ( $pv{output_type} eq "file" ) { $graphic->png($pv{file_name}) ; }
   }
