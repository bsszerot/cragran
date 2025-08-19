#!/usr/bin/perl

# open source soft - (C) 2023 CrAgaAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

$main_currency = $ARGV[1] ;
$ref_currency = $ARGV[2] ;

# если запись числа приехала в научном Е-формате, нужно преобразовать
sub ret_numassz ($) {
    local $value = @_[0] ;
#return sprintf("%.21f",$value) ;
# самое простое сделать так, но хвост размажется на 21 символ после запятой
#    return sprintf("%f",$value) ;
    if ( $value =~ m/([0-9\.]+)e-([0-9]{1,2})/ ) { return sprintf("%.21f",$value) ; }
    else { return $value ; }
    }

# пример записи E 5.969859025973405e-06
#print ret_numassz(5.969859025973405e-06) ;
#print ret_numassz(5.969859025973405e-06) ;
#exit 0 ;

while (<STDIN>) { my $curr_string = $_ ;
      my $sec = "" ; my $min = "" ; my $hour = "" ; my $mday  = "" ; my $mon = "" ; my $year = "" ; my $wday  = "" ; my $yday  = "" ; $isdst = "" ; my $day_timestamp = "" ;
      my $price_open = 0 ; my $price_high = 0 ; my $price_low = 0 ; my $price_close = 0 ; my $cnt_e_range = 15 ;
# для OHLC есть только один вид данных, выявлять и обрабатывать вид данных не нужно

# фильтруем только подходящие строки
      if ( $curr_string =~ /\[([0-9]{10})[0-9]{3},([^,]+),([^,]+),([^,]+),([^,]+)\].*/ ) {
         $day_timestamp = $1 ; $price_open = $2 ; $price_high = $3 ; $price_low = $4 ; $price_close = $5 ;
#-debug-         print "-- $day_timestamp -- $price_open -- $price_high -- $price_low -- $price_close -- \n" ;
         ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($day_timestamp) ;
         $year += 1900 ; $mon += 1 ; if ( $mon < 10 ) { $mon = '0'.$mon ; } if ( $mday < 10 ) { $mday = '0'.$mday ; }
#         if ($hour = '0') { $hour = '00' ; }
#-debug-         print "$sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst\n" ;
#-debug-         print "-- $year - $mon - $mday $hour : $min : $sec $yday / $wday / $isdst -- $price_open -- $price_high -- $price_low -- $price_close -- \n" ;
#print "-- $main_currency - $ref_currency - $year-$mon-$mday $hour:$min:$sec $yday/$wday/$isdst -- ".ret_numassz($price_open)." -- ".ret_numassz($price_high)." -- ".ret_numassz($price_low)." -- ".ret_numassz($price_close)." -- \n" ;
#print "select fn_fill_gecko_minutes_ohlc(CAST('$main_currency' AS VARCHAR), CAST('$ref_currency' AS VARCHAR), CAST($day_timestamp AS timestamp without time zone), $price_open, $price_high, $price_low, $price_close) ;\n" ;
print "select fn_fill_gecko_minutes_ohlc(CAST('$main_currency' AS VARCHAR), CAST('$ref_currency' AS VARCHAR), CAST(TO_TIMESTAMP('$year-$mon-$mday $hour:$min:$sec','YYYY-MM-DD HH24:MI:SS') AS timestamp without time zone), $price_open, $price_high, $price_low, $price_close) ;\n" ;
         }
    }
