#!/usr/bin/perl

# open source soft - (C) 2023 CrAgrAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

use DBI ;
use Chart::Lines ;
require "/var/www/crypta/cgi/common_func.body" ;
require "/var/www/crypta/cgi/common_parameter.cragregator" ;

# - вытащить из URL запроса значения уточняющих полей
&get_forms_param() ;

#@tmp1 = keys %pv ; for ($i=0;$i<=$#tmp1;$i++) { print "$tmp1[$i] = $pv{$tmp1[$i]} \n"; } print "$connector_definition{$pv{connector}} \n" ; print "$connector_credentials{$pv{connector}} \n" ; exit 0 ;
#$pv{currency} = 'XRP' ;
#$pv{curr_reference} = 'BTC' ;
#$pv{from_date} = '2023-01-01' ;

#print "Content-Type: image/png\n\n";
#print "\n --- start db" ;
$CURR_YEAR = `date +%Y` ; $CURR_YEAR =~ s/[\r\n]+//g ;
$count_rows = 0 ;
#$period_day =
$window_days = 0 ; $window_days = $pv{window_days} - 1 ;
$request = " " ;
# day_date > TO_DATE('$pv{from_date}', 'YYYY-MM-DD')

if ( $pv{volume_type} eq "vlmfrom" ) {
   $request = "SELECT day_date, round(volume_from,2) FROM curr_pair_history WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}' AND day_date > CURRENT_DATE - INTERVAL '$pv{period_days} day' ORDER BY day_date " ;
#exit ;
   }

if ( $pv{volume_type} eq "vlmto" ) {
   $request = "SELECT day_date, round(volume_to,2) FROM curr_pair_history WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}' AND day_date > CURRENT_DATE - INTERVAL '$pv{period_days} day' ORDER BY day_date " ;
#exit ;
   }

#print $request ;
my @date_list = () ;
my @data_source_field_1 = () ;
my @data_source_field_2 = () ;

#$dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=$host;port=$port;options=$options", $username, $password, {AutoCommit => 0, RaiseError => 1, PrintError => 0} );
my $dbh_h = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'pg_password_value' );
my $sth_h = $dbh_h->prepare($request) ; $sth_h->execute(); $count_rows = 0 ;  
while (my ($day_date, $volat) = $sth_h->fetchrow_array() ) {
#      print "$day_date, $volat\n" ;.
#      $day_date =~ s/-//g ;
      $date_list[$count_rows] = $day_date ;
      $day_date =~ s/\d\d\d\d-(\d\d)-(\d\d)/$1$2/g ;
      $data_source_field_1[$count_rows] = $day_date ;
      $data_source_field_2[$count_rows] = $volat ;
#      $avg_data_source[0][$count_rows] = $wc_CPU ;
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

<H1>Данные графика дневного объёма</H1>
<H2>период $pv{period_days} дн. от текущей даты
<BR>расчётное окно = $pv{window_days} дн.
<BR>вид объёма = $pv{volume_type}</H2>

<TABLE BORDER=\"1\"><TR><TD STYLE=\"text-align: center;\">Дата</TD><TD STYLE=\"text-align: center;\">Объём $pv{volume_type}, $pv{curr_reference}</TD></TR>" ;
   for ($curr_row = 0; $curr_row < $count_rows; $curr_row += 1) {
       print "<TR><TD>$date_list[$curr_row]</TD><TD STYLE=\"text-align: right;\">$data_source_field_2[$curr_row]</TD></TR>" ;
       }
   print "</TABLE>" ;
   }

if ( $pv{output_type} eq "graph" ) {
   my $graphic ;
   my $min_y ;
   my $max_y ;

   $graphic = Chart::Lines->new( $pv{x_size}, $pv{y_size} ) ;
   $graphic->set( 'brush_size' => $pv{brush_size} ) ;
   $graphic->add_dataset( @data_source_field_1 ) ;
   $graphic->add_dataset( @data_source_field_2 ) ;

   $min_y = $max_y = $data_source_field_2[0] ;
   foreach (@data_source_field_2) {
           if ( $_ < $min_y ) { $min_y = $_; }
           if ( $_ > $max_y ) { $max_y = $_; }
           }
   $graphic->set( 'min_val' => $min_y ) ;
   $graphic->set( 'max_val' => $max_y ) ;


   $graphic->set( 'max_y_ticks' => 12 ) ;
   $graphic->set( 'min_y_ticks' => 2 ) ;
   $graphic->set( 'transparent' => 'false' ) ;
#$graphic->set( 'precision' => 12 );

# - похоже, влияет только на линии сетки и подписи, на основаниир сверки скриншотов. Без этого параметра плохо читаемо
   my $skip_x_ticks = $count_rows / 15 ;
   $graphic->set( 'skip_x_ticks' => $skip_x_ticks ) ;
   $graphic->set( 'x_ticks'      => 'vertical' ) ;
   $graphic->set( 'grey_background' => 'false' ) ;
   $graphic->set( 'graph_border'    => 1 ) ;
#$graphic->set( 'title'           => "Volat., % $pv{period_day} day $pv{shadow}" );
#$graphic->set( 'sub_title'       => "Volat., % $pv{period_day} day " );
   $graphic->set( 'y_grid_lines'    => 'true' ) ;
   $graphic->set( 'x_grid_lines'    => 'true' ) ;
   $graphic->set( 'colors' => { 'y_grid_lines' => [ 127, 127, 0 ], 'x_grid_lines' => [ 127, 127, 0 ], 'dataset0' => [ 0, 0, 200 ] } ) ;
   $graphic->set( 'legend'  => 'none' ) ;
#$graphic->set( 'x_label' => 'Time (UTC)' );
   $graphic->set( 'y_label' => "Volume ($pv{volume_type}), $pv{curr_reference}" );
   $graphic->set( 'label_font' => GD::Font->Giant ) ;

   $graphic->cgi_png();
   }
