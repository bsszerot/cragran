#!/usr/bin/perl

# open source soft - (C) 2023 CrAgaAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

$main_currency = $ARGV[1] ;
$ref_currency = $ARGV[2] ;

while (<STDIN>) { $szCurr = "" ; $szCurr = $_ ; $sec = "" ; 
      $min = "" ; $hour = "" ; $mday  = "" ; $mon = "" ; $year = "" ; $wday  = "" ; $yday  = "" ; $isdst = "" ; $price_open = 0 ; $price_high = 0 ; $price_low = 0 ; $price_close = 0 ; $volfrom = 0 ; $volto = 0 ;
      if ( $szCurr =~ /{"time":([0-9\.]+),"high":([0-9\.]+),"low":([0-9\.]+),"open":([0-9\.]+),"volumefrom":([0-9\.]+),"volumeto":([0-9\.]+),"close":([0-9\.]+),"conversionType":"direct","conversionSymbol":""}.*/ ) {
         $timestamp_point = $1 ; $price_high = $2; $price_low = $3; $price_open = $4; $volfrom = $5; $volto = $6; $price_close = $7 ;
         ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($timestamp_point) ;
         $year += 1900 ; $mon += 1 ; if ( $mon < 10 ) { $mon = '0'.$mon ; } if ( $mday < 10 ) { $mday = '0'.$mday ; }
         if ( $price_high != 0 or $price_low != 0 or $price_open != 0 or $price_close != 0 ) {
            print "select fn_fill_crcomp_1H_ohlc(CAST('$main_currency' AS VARCHAR), CAST('$ref_currency' AS VARCHAR), CAST(TO_TIMESTAMP('$year-$mon-$mday $hour:$min:$sec','YYYY-MM-DD HH24:MI:SS') AS timestamp without time zone), $price_open, $price_high, $price_low, $price_close, $volfrom, $volto) ;\n" ;
            }
         }
      }
