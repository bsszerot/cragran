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

# параметры - монета, референсная, начальная цена, начальная точка времени, конечная или текущая точка времени

#@tmp1 = keys %pv ; for ($i=0;$i<=$#tmp1;$i++) { print "$tmp1[$i] = $pv{$tmp1[$i]} \n"; } print "$connector_definition{$pv{connector}} \n" ; print "$connector_credentials{$pv{connector}} \n" ; exit 0 ;
#$pv{currency} = 'ETH' ;
#$pv{curr_reference} = 'USDT' ;
#$pv{start_date} = "2024-01-01 01:01:01" ;
#$pv{end_date} = "2024-01-20 01:01:01" ;
#$pv{start_date} = "20240101010101" ;
#$pv{stop_date} = "20240120010101" ;
#$pv{output_type} = "table" ;

#print "Content-Type: image/png\n\n";
#print "\n --- start db" ;
$CURR_YEAR = `date +%Y` ; $CURR_YEAR =~ s/[\r\n]+//g ;
$count_rows = 0 ;
$request = " " ;


$v_sql_start_date = "TO_TIMESTAMP('$pv{start_date}', 'YYYYMMDDHH24MISS')" ; $v_sql_start_date_contract = $pv{start_date} ; 

if ($pv{stop_date} eq "last") { $v_sql_stop_date = "now() + INTERVAL '100 year'" ; $v_sql_stop_date_contract = $pv{start_date} ; }
else { $v_sql_stop_date = "TO_TIMESTAMP('$pv{stop_date}', 'YYYYMMDDHH24MISS')" ; $v_sql_stop_date_contract = $pv{stop_date} ; }

if ( $pv{src} eq "1M" ) { $pv{src} = "crcomp_pair_ohlc_1m_history" ; 
   $v_sql_start_date_contract =~ s/(\d{12})(\d{2})/$1/g ; $v_sql_stop_date_contract =~ s/(\d{12})(\d{2})/$1/g ;
   $request = "SELECT TO_CHAR((timestamp_point + INTERVAL '3 hour'), 'YYYY-MM-DD HH24:MI:SS'),
                      round((price_low - $pv{start_price}) / ($pv{start_price} / 100) * $pv{profit_mult},2),
                      round((price_close - $pv{start_price}) / ($pv{start_price} / 100) * $pv{profit_mult},2),
                      round((price_high - $pv{start_price}) / ($pv{start_price} / 100) * $pv{profit_mult},2),
                      CASE WHEN TO_CHAR((timestamp_point + INTERVAL '3 hour'), 'YYYYMMDDHH24MI') = '$v_sql_start_date_contract' THEN 20 ELSE 0 END,
                      CASE WHEN TO_CHAR((timestamp_point + INTERVAL '3 hour'), 'YYYYMMDDHH24MI') = '$v_sql_stop_date_contract' THEN 20 ELSE 0 END
                      from $pv{src}
                      where currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                            AND timestamp_point + INTERVAL '3 hour' + INTERVAL '1 hour' > $v_sql_start_date
                            AND timestamp_point + INTERVAL '3 hour' - INTERVAL '1 hour' < $v_sql_stop_date " ;
   }

if ( $pv{src} eq "1H" or $pv{src} eq "" ) { $pv{src} = "crcomp_pair_ohlc_1h_history" ;
   $v_sql_start_date_contract =~ s/(\d{10})(\d{4})/$1/g ; $v_sql_stop_date_contract =~ s/(\d{10})(\d{4})/$1/g ;
   $request = "SELECT TO_CHAR((timestamp_point + INTERVAL '3 hour'), 'YYYY-MM-DD HH24:MI:SS'),
                      round((price_low - $pv{start_price}) / ($pv{start_price} / 100) * $pv{profit_mult},2),
                      round((price_close - $pv{start_price}) / ($pv{start_price} / 100) * $pv{profit_mult},2),
                      round((price_high - $pv{start_price}) / ($pv{start_price} / 100) * $pv{profit_mult},2),
                      CASE WHEN TO_CHAR((timestamp_point + INTERVAL '3 hour'), 'YYYYMMDDHH24') = '$v_sql_start_date_contract' THEN 20 ELSE 0 END,
                      CASE WHEN TO_CHAR((timestamp_point + INTERVAL '3 hour'), 'YYYYMMDDHH24') = '$v_sql_stop_date_contract' THEN 20 ELSE 0 END
                      from $pv{src}
                      where currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                            AND timestamp_point + INTERVAL '3 hour' + INTERVAL '24 hour' > $v_sql_start_date
                            AND timestamp_point + INTERVAL '3 hour' - INTERVAL '24 hour' < $v_sql_stop_date " ;
   }

if ( $pv{src} eq "1D" ) { $pv{src} = "crcomp_pair_ohlc_1d_history" ;
   $v_sql_start_date_contract =~ s/(\d{8})(\d{6})/$1/g ; $v_sql_stop_date_contract =~ s/(\d{8})(\d{6})/$1/g ;
   $request = "SELECT TO_CHAR((timestamp_point + INTERVAL '3 hour'), 'YYYY-MM-DD HH24:MI:SS'),
                      round((price_low - $pv{start_price}) / ($pv{start_price} / 100) * $pv{profit_mult},2),
                      round((price_close - $pv{start_price}) / ($pv{start_price} / 100) * $pv{profit_mult},2),
                      round((price_high - $pv{start_price}) / ($pv{start_price} / 100) * $pv{profit_mult},2),
                      CASE WHEN TO_CHAR((timestamp_point + INTERVAL '3 hour'), 'YYYYMMDD') = '$v_sql_start_date_contract' THEN 20 ELSE 0 END,
                      CASE WHEN TO_CHAR((timestamp_point + INTERVAL '3 hour'), 'YYYYMMDD') = '$v_sql_stop_date_contract' THEN 20 ELSE 0 END
                      from $pv{src}
                      where currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                            AND timestamp_point + INTERVAL '3 hour' + INTERVAL '2 day' > $v_sql_start_date
                            AND timestamp_point + INTERVAL '3 hour' - INTERVAL '2 day' < $v_sql_stop_date " ;
   }
#if ( $pv{src} eq "" ) { $pv{src} = "crcomp_pair_ohlc_1h_history" ; }
#$request = "SELECT TO_CHAR((timestamp_point + INTERVAL '3 hour'), 'YYYY-MM-DD HH24:MI:SS'),
#                   round((price_low - $pv{start_price}) / ($pv{start_price} / 100) * $pv{profit_mult},2),
#                   round((price_close - $pv{start_price}) / ($pv{start_price} / 100) * $pv{profit_mult},2),
#                   round((price_high - $pv{start_price}) / ($pv{start_price} / 100) * $pv{profit_mult},2),
#                   CASE WHEN TO_CHAR((timestamp_point + INTERVAL '3 hour'), 'YYYYMMDDHH24MI') = '$v_sql_start_date_contract' THEN 10 ELSE 0 END,
#                   CASE WHEN TO_CHAR((timestamp_point + INTERVAL '3 hour'), 'YYYYMMDDHH24MI') = '$v_sql_stop_date_contract' THEN 10 ELSE 0 END
#                   from $pv{src}
#                   where currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
#                   AND timestamp_point + INTERVAL '3 hour' + INTERVAL '36 hour' > $v_sql_start_date
#                   AND timestamp_point + INTERVAL '3 hour' - INTERVAL '72 hour' < $v_sql_stop_date " ;
#open(DEBG, ">/tmp/_graph_profit.out") ; print DEBG $request ;

my @date_list = () ;
my @data_source_timestamp_point = () ;
my @data_source_profit_percent_low = () ;
my @data_source_profit_percent_high = () ;
my @data_source_profit_percent_close = () ;
my @data_source_null_line = () ;
my @data_source_line_p1 = () ; my @data_source_line_p2 = () ; my @data_source_line_p3 = () ; my @data_source_line_p4 = () ; my @data_source_line_p5 = () ;
my @data_source_line_m1 = () ; my @data_source_line_m2 = () ; my @data_source_line_m3 = () ; my @data_source_line_m4 = () ; my @data_source_line_m5 = () ;

my @data_source_is_start_contract_border = () ;
my @data_source_is_stop_contract_border = () ;

#$dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=$host;port=$port;options=$options", $username, $password, {AutoCommit => 0, RaiseError => 1, PrintError => 0} );
my $dbh_h = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'pg_password_value' );
my $sth_h = $dbh_h->prepare($request) ; $sth_h->execute(); $count_rows = 0 ;
while (my ($timestamp_point, $profit_percent_low, $profit_percent_close, $profit_percent_high, $is_start_point, $is_stop_point ) = $sth_h->fetchrow_array() ) {
#      print "$day_date, $volat\n" ;.
#      $day_date =~ s/-//g ;
      $date_list[$count_rows] = $timestamp_point ;
#      $day_date =~ s/\d\d\d\d-(\d\d)-(\d\d)/$1$2/g ;
      $data_source_timestamp_point[$count_rows] = $timestamp_point ;
      $data_source_profit_percent_low[$count_rows] = $profit_percent_low ;
      $data_source_profit_percent_close[$count_rows] = $profit_percent_close ;
      $data_source_profit_percent_high[$count_rows] = $profit_percent_high ;
      $data_source_null_line[$count_rows] = 0 ;
      $data_source_line_p1[$count_rows] = 1 ; $data_source_line_p2[$count_rows] = 2 ; $data_source_line_p3[$count_rows] = 3 ; $data_source_line_p4[$count_rows] = 4 ; $data_source_line_p5[$count_rows] = 5 ;
      $data_source_line_m1[$count_rows] = -1 ; $data_source_line_m2[$count_rows] = -2 ; $data_source_line_m3[$count_rows] = -3 ; $data_source_line_m4[$count_rows] = -4 ; $data_source_line_m5[$count_rows] = -5 ;
      $data_source_is_start_contract_border[$count_rows] = $is_start_point ;
#      if ( $data_source_is_start_contract_border[$count_rows] == 10 ) {
#         $data_source_is_start_contract_border[$count_rows-1] = 10 ; $data_source_is_start_contract_border[$count_rows-3] = 10 ; $data_source_is_start_contract_border[$count_rows-5] = 10 ; $data_source_is_start_contract_border[$count_rows-7] = 10 ; $data_source_is_start_contract_border[$count_rows-9] = 10 ; $data_source_is_start_contract_border[$count_rows-11] = 10 ;
#         $data_source_is_start_contract_border[$count_rows-2] = -10 ; $data_source_is_start_contract_border[$count_rows-4] = -10 ; $data_source_is_start_contract_border[$count_rows-6] = -10 ; $data_source_is_start_contract_border[$count_rows-8] = -10 ; $data_source_is_start_contract_border[$count_rows-10] = -10 ; $data_source_is_start_contract_border[$count_rows-12] = -10 ; }
      $data_source_is_stop_contract_border[$count_rows] = $is_stop_point ;
#      if ( $data_source_is_stop_contract_border[$count_rows] == 10 ) {
#         $data_source_is_stop_contract_border[$count_rows-1] = 10 ; $data_source_is_stop_contract_border[$count_rows-3] = 10 ; $data_source_is_stop_contract_border[$count_rows-5] = 10 ; $data_source_is_stop_contract_border[$count_rows-7] = 10 ; $data_source_is_stop_contract_border[$count_rows-9] = 10 ; $data_source_is_stop_contract_border[$count_rows-11] = 10 ;
#         $data_source_is_stop_contract_border[$count_rows-2] = -10 ; $data_source_is_stop_contract_border[$count_rows-4] = -10 ; $data_source_is_stop_contract_border[$count_rows-6] = -10 ; $data_source_is_stop_contract_border[$count_rows-8] = -10 ; $data_source_is_stop_contract_border[$count_rows-10] = -10 ; $data_source_is_stop_contract_border[$count_rows-14] = -10 ; }
      $count_rows += 1 ; }

$sth_h->finish() ;
$dbh_h->disconnect() ;

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
<H1>Данные графика дневных объёмов $pv{currency} / $pv{curr_reference}</H1>
<H2>период $pv{period_days} дн. от текущей даты
<BR>расчётное окно = 1 день</H2>

<TABLE BORDER=\"1\"><TR><TD STYLE=\"text-align: center;\">Дата</TD>
                        <TD STYLE=\"text-align: center;\">Дата открытия</TD>
                        <TD STYLE=\"text-align: center;\">Дата закрытия</TD>
                        <TD STYLE=\"text-align: center;\">for Low, %</TD>
                        <TD STYLE=\"text-align: center;\">for Close, %</TD>
                        <TD STYLE=\"text-align: center;\">for High, %</TD>
                        <TD STYLE=\"text-align: center;\">is Start</TD>
                        <TD STYLE=\"text-align: center;\">is Stop</TD>
                    </TR>" ;
   for ($curr_row = 0; $curr_row < $count_rows; $curr_row += 1) {
       print "<TR><TD>$data_source_timestamp_point[$curr_row]</TD>
                  <TD>$pv{start_date} $v_sql_start_date_contract</TD>
                  <TD>$pv{stop_date} $v_sql_stop_date_contract</TD>
                  <TD STYLE=\"text-align: right;\">$data_source_profit_percent_low[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$data_source_profit_percent_close[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$data_source_profit_percent_high[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$data_source_is_start_contract_border[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$data_source_is_stop_contract_border[$curr_row]</TD>
              </TR>" ;
       }
   print "</TABLE>" ;
   }

if ( $pv{output_type} eq "graph" ) {
   my $graphic ; my $min_y ; $min_ext_y ; my $max_y ; $max_ext_y ;

   $graphic = Chart::Composite->new( $pv{x_size}, $pv{y_size} ) ;
   $graphic->set( 'brush_size' => $pv{brush_size} ) ;
   $graphic->add_dataset( @data_source_timestamp_point ) ;
   $graphic->add_dataset( @data_source_null_line ) ;
   $graphic->add_dataset( @data_source_line_p1 ) ; $graphic->add_dataset( @data_source_line_p2 ) ; $graphic->add_dataset( @data_source_line_p3 ) ; $graphic->add_dataset( @data_source_line_p4 ) ; $graphic->add_dataset( @data_source_line_p5 ) ;
   $graphic->add_dataset( @data_source_line_m1 ) ; $graphic->add_dataset( @data_source_line_m2 ) ; $graphic->add_dataset( @data_source_line_m3 ) ; $graphic->add_dataset( @data_source_line_m4 ) ; $graphic->add_dataset( @data_source_line_m5 ) ;
   $graphic->add_dataset( @data_source_profit_percent_low ) ;
   $graphic->add_dataset( @data_source_profit_percent_close ) ;
   $graphic->add_dataset( @data_source_profit_percent_high ) ;
   $graphic->add_dataset( @data_source_is_start_contract_border ) ;
   $graphic->add_dataset( @data_source_is_stop_contract_border ) ;
   $graphic->set( 'composite_info' => [[ 'StackedBars', [ 15, 16 ] ], [ 'Lines', [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14] ] ] );

   $min_y = $max_y = $data_source_profit_percent_low[0] ; foreach (@data_source_profit_percent_low) { if ( $_ < $min_y ) { $min_y = $_; } if ( $_ > $max_y ) { $max_y = $_; } }
   foreach (@data_source_profit_percent_close) { if ( $_ < $min_y ) { $min_y = $_; } if ( $_ > $max_y ) { $max_y = $_; } }
   foreach (@data_source_profit_percent_high) { if ( $_ < $min_y ) { $min_y = $_; } if ( $_ > $max_y ) { $max_y = $_; } }
   foreach (@data_source_null_line) { if ( $_ < $min_ext_y ) { $min_ext_y = $_; } if ( $_ > $max_ext_y ) { $max_ext_y = $_; } }

#   $min_y = ( $min_y > $min_ext_y ) ? $min_ext_y : $min_y ; $max_y = ( $max_y < $max_ext_y ) ? $max_ext_y : $max_y ;

   $graphic->set( 'min_val' => $min_y ) ;
   $graphic->set( 'max_val' => $max_y ) ;

   $graphic->set( 'max_y_ticks' => 12 ) ;
   $graphic->set( 'min_y_ticks' => 2 ) ;
   $graphic->set( 'transparent' => 'false' ) ;
#$graphic->set( 'precision' => 12 );

   my $skip_x_ticks = $count_rows / 15 ;
   $graphic->set( 'skip_x_ticks' => $skip_x_ticks,
                  'x_ticks'      => 'vertical',
                  'grey_background' => 'false',
                  'graph_border'    => 1,
                  'y_grid_lines'    => 'true',
                  'x_grid_lines'    => 'true',
                  'legend'  => 'none',
                  'y_label' => "Profit, $pv{currency}/$pv{curr_reference}",
#                  'label_font' => GD::Font->Giant,
                  'include_zero' => 'yes',
#                  'brush_size1' => 1,
#                  'brush_size2' => 4,
                  'brush_size' => $pv{brush_size},
                  'transparent' => 'false'
                  ) ;

   $graphic->set( 'colors' => { 'y_grid_lines' => [ 127, 127, 0 ], 'x_grid_lines' => [ 127, 127, 0 ],
                  'dataset0' => red,
                  'dataset1' => red,
                  'dataset2' => brown,
                  'dataset3' => lightgreen, 'dataset4' => lightgreen, 'dataset5' => lightgreen, 'dataset6' => lightgreen, 'dataset7' => lightgreen,
                  'dataset8' => lightgreen, 'dataset9' => lightgreen, 'dataset10' => lightgreen, 'dataset11' => lightgreen, 'dataset12' => lightgreen,
                  'dataset13' => red,
                  'dataset14' => green,
                  'dataset15' => purple } ) ;

   $graphic->cgi_png();
   }
