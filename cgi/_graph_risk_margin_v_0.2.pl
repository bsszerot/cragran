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

# - вытащить из URL запроса значения уточняющих полей
&get_forms_param() ;

#@tmp1 = keys %pv ; for ($i=0;$i<=$#tmp1;$i++) { print "$tmp1[$i] = $pv{$tmp1[$i]} \n"; } print "$connector_definition{$pv{connector}} \n" ; print "$connector_credentials{$pv{connector}} \n" ; exit 0 ;
#$pv{currency} = 'LDO' ;
#$pv{curr_reference} = 'USDT' ;
#$pv{count_prds} = 120 ;
#$pv{output_type} = "table" ;

#print "Content-Type: image/png\n\n";
#print "\n --- start db" ;
$CURR_YEAR = `date +%Y` ; $CURR_YEAR =~ s/[\r\n]+//g ;
$count_rows = 0 ;
$request = " " ;

$request = "select TO_CHAR(t1.timestamp_point, 'YY-MM-DD') TIME_POINT, t2.max_price, t2.min_price, t1.price_close, t1.price_close/(t2.max_price/100) risk_margin
         from crcomp_pair_ohlc_1d_history t1,
              (select max(price_close) max_price, min(price_close) min_price
                      from crcomp_pair_ohlc_1d_history
                      where timestamp_point > now() - INTERVAL '$pv{count_prds} days'
                            AND currency = '$pv{currency}'
                            AND reference_currency = '$pv{curr_reference}') t2
         where t1.timestamp_point > now() - INTERVAL '$pv{count_prds} days'
               AND t1.currency = '$pv{currency}'
               AND t1.reference_currency = '$pv{curr_reference}'
         order by t1.timestamp_point" ;

#print $request ;

my @ds_timestamp_point_list = () ;
my @ds_max_price_list = () ;
my @ds_min_price_list = () ;
my @ds_price_close = () ;
my @ds_risk_margin_list = () ;

my $dbh_h = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'pg_password_value' );
my $sth_h = $dbh_h->prepare($request) ; $sth_h->execute(); $count_rows = 0 ;
while (my ($timestamp_point, $max_price, $min_price, $price_close, $risk_margin) = $sth_h->fetchrow_array() ) {
      $ds_timestamp_point_list[$count_rows] = $timestamp_point ;
      $ds_max_price_list[$count_rows] = $max_price ;
      $ds_min_price_list[$count_rows] = $min_price ;
      $ds_price_close[$count_rows] = $price_close ;
      $ds_risk_margin_list[$count_rows] = $risk_margin ;
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

<H1>График границы риска $pv{currency} / $pv{curr_reference} за $pv{count_prds} периодов (дней)</H1>

<TABLE BORDER=\"1\"><TR><TD STYLE=\"text-align: center;\">Дата</TD><TD STYLE=\"text-align: center;\">$pv{currency} / $pv{curr_reference}</TD><TD STYLE=\"text-align: center;\">Максимальная цена</TD>
<TD STYLE=\"text-align: center;\">Минимальная цена</TD><TD STYLE=\"text-align: center;\">Текущая граница риска</TD></TR>/n" ;
   for ($curr_row = 0; $curr_row < $count_rows; $curr_row += 1) {
       print "<TR><TD>$ds_timestamp_point_list[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_max_price_list[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_min_price_list[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_price_close[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_risk_margin_list[$curr_row]</TD></TR>\n" ;
       }
   print "</TABLE>" ;
   }

if ( $pv{output_type} eq "graph" ) {
   my $graphic ;
   my $min_y ;
   my $max_y ;

   $graphic = Chart::Lines->new( $pv{x_size}, $pv{y_size} ) ;
   $graphic->set( 'brush_size' => $pv{brush_size} ) ;

   $graphic->add_dataset( @ds_timestamp_point_list ) ;
#   $graphic->add_dataset( @ds_max_price_list ) ;
#  $graphic->add_dataset( @ds_min_price_list ) ;
   $graphic->add_dataset( @ds_risk_margin_list ) ;

#   $min_y = $max_y = $data_source_field_2[0] ;
#   foreach (@data_source_field_2) {
#           if ( $_ < $min_y ) { $min_y = $_; }
#           if ( $_ > $max_y ) { $max_y = $_; }
#           }

   $graphic->set( 'min_val' => 0 ) ;
   $graphic->set( 'max_val' => 100 ) ;

   $graphic->set( 'max_y_ticks' => 12 ) ;
   $graphic->set( 'min_y_ticks' => 7 ) ;
   $graphic->set( 'transparent' => 'false' ) ;
#$graphic->set( 'precision' => 12 );

# - похоже, влияет только на линии сетки и подписи, на основаниир сверки скриншотов. Без этого параметра плохо читаемо
   my $skip_x_ticks = $count_rows / 15 ;
   $graphic->set( 'skip_x_ticks' => $skip_x_ticks ) ;
   $graphic->set( 'x_ticks'      => 'vertical' ) ;
#   $graphic->set( 'x_ticks'      => 'normal' ) ;
#   $graphic->set( 'x_ticks'      => 'staggered' ) ;
   $graphic->set( 'grey_background' => 'false' ) ;
   $graphic->set( 'graph_border'    => 1 ) ;
#$graphic->set( 'title'           => $title_name );
#$graphic->set( 'sub_title'       => "over Time" );
   $graphic->set( 'y_grid_lines'    => 'true' ) ;
   $graphic->set( 'x_grid_lines'    => 'true' ) ;
   $graphic->set( 'colors' => { 'y_grid_lines' => [ 127, 127, 0 ], 'x_grid_lines' => [ 127, 127, 0 ], 'dataset0' => [ 0, 0, 200 ] } ) ;
   $graphic->set( 'legend'  => 'none' ) ;
#$graphic->set( 'x_label' => 'Time (UTC)' );
   $graphic->set( 'y_label' => "RiskMarg., %, $pv{currency}/$pv{curr_reference} $pv{count_prds} pr." );
   $graphic->set( 'label_font' => GD::Font->Giant ) ;

   $graphic->cgi_png();
   }
