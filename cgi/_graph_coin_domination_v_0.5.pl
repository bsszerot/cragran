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
#$pv{currency} = 'ETH' ;
#$pv{curr_reference} = 'USD' ;
#$pv{count_prds} = 120 ;
#$pv{output_type} = "graph" ;

#print "Content-Type: image/png\n\n";
#print "\n --- start db" ;
$CURR_YEAR = `date +%Y` ; $CURR_YEAR =~ s/[\r\n]+//g ;
$count_rows = 0 ;
$request = " " ;

if ($pv{graph_type} eq "BTC_DOM") { $pv{currency} = "BTC" ; $pv{curr_reference} = "USD" ; }

$request = "select TO_CHAR(gchd.timestamp_point,'YY-MM-DD'), gchd.market_caps, all_market_cap.all_market_day_caps, ROUND(gchd.market_caps/(all_market_cap.all_market_day_caps/100),2) coin_domination
       from gecko_coins_history_data gchd,
            gecko_coin_list gcl,
            (select timestamp_point, reference_currency, sum(market_caps) all_market_day_caps
                    from gecko_coins_history_data
                    group by timestamp_point, reference_currency) all_market_cap
       where all_market_cap.timestamp_point = gchd.timestamp_point AND all_market_cap.reference_currency = gchd.reference_currency
             AND gchd.currency = gcl.id_gecko_curr AND UPPER(gcl.symb_gecko_curr) = '$pv{currency}'
             AND UPPER(gchd.reference_currency) = '$pv{curr_reference}'
             AND gchd.timestamp_point > now() - INTERVAL '$pv{count_prds} days'
       order by gchd.timestamp_point" ;

if ($pv{graph_type} eq "ALT_DOM") {
   $request = "select all_sm.timestamp_point, tgt.tgt_market_caps, all_sm.all_market_caps, tgt.tgt_market_caps / ( all_sm.all_market_caps / 100 ) prct
        from (select TO_CHAR(gchd.timestamp_point,'YYYY-MM-DD') timestamp_point, round(SUM(gchd.market_caps),2) all_market_caps
                     from gecko_coins_history_data gchd
                     where gchd.reference_currency = 'usd'
                           AND gchd.timestamp_point > now() - INTERVAL '$pv{count_prds} days'
                     group by TO_CHAR(gchd.timestamp_point,'YYYY-MM-DD')) as all_sm
             LEFT OUTER JOIN
             (select TO_CHAR(gchd.timestamp_point,'YYYY-MM-DD') timestamp_point, round(SUM(gchd.market_caps),2) tgt_market_caps
                     from gecko_coins_history_data gchd
                     where NOT gchd.currency in ('dai','wbtc','usdc','bitcoin','tether')
                           AND gchd.reference_currency = 'usd'
                           AND gchd.timestamp_point > now() - INTERVAL '$pv{count_prds} days'
                     group by TO_CHAR(gchd.timestamp_point,'YYYY-MM-DD')) as tgt
             ON tgt.timestamp_point = all_sm.timestamp_point ORDER by 1" ; }

if ($pv{graph_type} eq "STABLE_DOM") {
   $request = "select all_sm.timestamp_point, tgt.tgt_market_caps, all_sm.all_market_caps, tgt.tgt_market_caps / ( all_sm.all_market_caps / 100 ) prct
        from (select TO_CHAR(gchd.timestamp_point,'YYYY-MM-DD') timestamp_point, round(SUM(gchd.market_caps),2) all_market_caps
                     from gecko_coins_history_data gchd
                     where gchd.reference_currency = 'usd'
                           AND gchd.timestamp_point > now() - INTERVAL '$pv{count_prds} days'
                     group by TO_CHAR(gchd.timestamp_point,'YYYY-MM-DD')) as all_sm
             LEFT OUTER JOIN
             (select TO_CHAR(gchd.timestamp_point,'YYYY-MM-DD') timestamp_point, 
                     CASE WHEN (round(SUM(gchd.market_caps),2) > 0) THEN round(SUM(gchd.market_caps),2) ELSE 0 END tgt_market_caps
                     from gecko_coins_history_data gchd
                     where gchd.currency in ('dai','wbtc','usdc','tether')
                           AND gchd.reference_currency = 'usd'
                           AND gchd.timestamp_point > now() - INTERVAL '$pv{count_prds} days'
                     group by TO_CHAR(gchd.timestamp_point,'YYYY-MM-DD')) as tgt
             ON tgt.timestamp_point = all_sm.timestamp_point ORDER by 1" ; }

if ($pv{graph_type} eq "ALL_CAP") {
   $request = "select TO_CHAR(timestamp_point,'YYYY-MM-DD') timestamp_point, round(SUM(market_caps),2), round(SUM(market_caps),2), round(SUM(market_caps),2)
                      from gecko_coins_history_data
                      where reference_currency = 'usd'
                            AND timestamp_point > now() - INTERVAL '$pv{count_prds} days'
                      group by TO_CHAR(timestamp_point,'YYYY-MM-DD')
                      ORDER by 1" ; }

#print $request ;

my @ds_timestamp_point_list = () ;
my @ds_coin_market_cap_list = () ;
my @ds_all_market_cap_list = () ;
my @ds_coin_domination_list = () ;

my $dbh_h = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'pg_password_value' );
my $sth_h = $dbh_h->prepare($request) ; $sth_h->execute(); $count_rows = 0 ;
while (my ($timestamp_point, $coin_market_cap, $all_market_cap, $coin_domination) = $sth_h->fetchrow_array() ) {
      $ds_timestamp_point_list[$count_rows] = $timestamp_point ;
      $ds_coin_market_cap_list[$count_rows] = $coin_market_cap ;
      $ds_all_market_cap_list[$count_rows] = $all_market_cap ;
      $ds_coin_domination_list[$count_rows] = $coin_domination ;
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

<H1>График доминации монеты $pv{currency} / $pv{curr_reference} за $pv{count_prds} периодов (дней)</H1>

<TABLE BORDER=\"1\"><TR><TD STYLE=\"text-align: center;\">Дата</TD><TD STYLE=\"text-align: center;\">Капитализация монеты</TD>
<TD STYLE=\"text-align: center;\">Капитализация рынка</TD><TD STYLE=\"text-align: center;\">Индекс доминации монеты, %</TD></TR>/n" ;
   for ($curr_row = 0; $curr_row < $count_rows; $curr_row += 1) {
       print "<TR><TD>$ds_timestamp_point_list[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_coin_market_cap_list[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_all_market_cap_list[$curr_row]</TD>
                  <TD STYLE=\"text-align: right;\">$ds_coin_domination_list[$curr_row]</TD></TR>\n" ;
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
   $graphic->add_dataset( @ds_coin_domination_list ) ;

  $min_y = $max_y = $ds_coin_domination_list[0] ;
   foreach (@ds_coin_domination_list) {
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
   $graphic->set( 'y_grid_lines'    => 'true' ) ;
   $graphic->set( 'x_grid_lines'    => 'true' ) ;
   $graphic->set( 'colors' => { 'y_grid_lines' => [ 127, 127, 0 ], 'x_grid_lines' => [ 127, 127, 0 ], 'dataset0' => 'brown' } ) ;
   if ($pv{graph_type} eq "BTC_DOM") { $graphic->set( 'colors' => { 'y_grid_lines' => [ 127, 127, 0 ], 'x_grid_lines' => [ 127, 127, 0 ], 'dataset0' => 'navy' } ) ; }
   if ($pv{graph_type} eq "STABLE_DOM") { $graphic->set( 'colors' => { 'y_grid_lines' => [ 127, 127, 0 ], 'x_grid_lines' => [ 127, 127, 0 ], 'dataset0' => 'green' } ) ; }
   if ($pv{graph_type} eq "ALT_DOM") { $graphic->set( 'colors' => { 'y_grid_lines' => [ 127, 127, 0 ], 'x_grid_lines' => [ 127, 127, 0 ], 'dataset0' => 'purple' } ) ; }
#   if ($pv{graph_type} eq "BTC_DOM") { $graphic->set( 'colors' => { 'y_grid_lines' => [ 127, 127, 0 ], 'x_grid_lines' => [ 127, 127, 0 ], 'dataset0' => 'brown' } ) ; }
   $graphic->set( 'legend'  => 'none' ) ;
   $graphic->set( 'y_label' => "DMNT, %, $pv{currency}/$pv{curr_reference} $pv{count_prds} pr." );
   $graphic->set( 'label_font' => GD::Font->Giant ) ;

   $graphic->cgi_png();
   }
