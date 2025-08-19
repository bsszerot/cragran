#!/usr/bin/perl

# open source soft - (C) 2023 CrAgaAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

$main_currency = $ARGV[1] ;
$ref_currency = $ARGV[2] ;

my $data_faza = "no" ; my $cnt_price = 0 ; my $cnt_cap = 0 ; my $cnt_vol = 0 ;

while (<STDIN>) { my $curr_string = $_ ;
      my $sec = "" ; my $min = "" ; my $hour = "" ; my $mday  = "" ; my $mon = "" ; my $year = "" ; my $wday  = "" ; my $yday  = "" ; $isdst = "" ; my $day_timestamp = "" ; my $curr_value = 0 ; my $sz_curr_value = "" ; my $cnt_e_range = 15 ;
# выставить вид предоставляемых данных
      if ( $curr_string =~ /.*prices.*/ ) { $data_faza = "prices" ; }
      if ( $curr_string =~ /.*market_caps.*/ ) { $data_faza = "market_caps" ; }
      if ( $curr_string =~ /.*total_volumes.*/ ) { $data_faza = "total_volumes" ; }
#print "faza = $data_faza" ;
# фильтруем только подходящие строки
      if ( $curr_string =~ /\[[0-9]{10}[0-9]{3},[0-9\.]+\].*/ || $curr_string =~ /\[[0-9]{10}[0-9]{3},[0-9\.]+e-[0-9]{2}\].*/ ) {
###print "В выборке\n" ;
         if ( $curr_string =~ /\[([0-9]{10})[0-9]{3},([0-9\.]+)\].*/ ) { $day_timestamp = $1 ; $curr_value = $2 ; $curr_grade = "" ; }
         if ( $curr_string =~ /\[([0-9]{10})[0-9]{3},([0-9\.]+)e-([0-9]{1,2})\].*/ ) {
            $day_timestamp = $1 ; $curr_value = $2 ; $curr_grade = $3 ; $cnt_e_range += $curr_grade ;
###print "В выборке 2 $day_timestamp == $curr_value == $curr_grade \n" ;
            if ( "$curr_grade" eq "01" || $curr_grade eq "1"  ) { $curr_value /= 10 ; }
            if ( "$curr_grade" eq "02" || $curr_grade eq "2"  ) { $curr_value /= 100 ; }
            if ( "$curr_grade" eq "03" || $curr_grade eq "3"  ) { $curr_value /= 1000 ; }
            if ( "$curr_grade" eq "04" || $curr_grade eq "4"  ) { $curr_value /= 10000 ; }
            if ( "$curr_grade" eq "05" || $curr_grade eq "5"  ) { $curr_value /= 100000 ; }
            if ( "$curr_grade" eq "06" || $curr_grade eq "6"  ) { $curr_value /= 1000000 ; }
            if ( "$curr_grade" eq "07" || $curr_grade eq "7"  ) { $curr_value /= 10000000 ; }
            if ( "$curr_grade" eq "08" || $curr_grade eq "8"  ) { $curr_value /= 100000000 ; }
            if ( "$curr_grade" eq "09" || $curr_grade eq "9"  ) { $curr_value /= 1000000000 ; }
            if ( "$curr_grade" eq "10" ) { $curr_value /= 10000000000 ; }
            if ( "$curr_grade" eq "11" ) { $curr_value /= 100000000000 ; }
            if ( "$curr_grade" eq "12" ) { $curr_value /= 1000000000000 ; }
###printf ("после %s %.21f %d",$day_timestamp, $curr_value, $curr_grade) ;
            }
         if ( $curr_string =~ /\[([0-9]{10})[0-9]{3},([0-9\.]+)e\+([0-9]{2})\].*/ ) {
            $day_timestamp = $1 ; $curr_value = $2 ; $curr_grade = $3 ;
            if ( "$curr_grade" eq "01" || $curr_grade eq "1"  ) { $curr_value = $2 * 10 ; }
            if ( "$curr_grade" eq "02" || $curr_grade eq "2"  ) { $curr_value = $2 * 100 ; }
            if ( "$curr_grade" eq "03" || $curr_grade eq "3"  ) { $curr_value = $2 * 1000 ; }
            if ( "$curr_grade" eq "04" || $curr_grade eq "4"  ) { $curr_value = $2 * 10000 ; }
            if ( "$curr_grade" eq "05" || $curr_grade eq "5"  ) { $curr_value = $2 * 100000 ; }
            if ( "$curr_grade" eq "06" || $curr_grade eq "6"  ) { $curr_value = $2 * 1000000 ; }
            if ( "$curr_grade" eq "07" || $curr_grade eq "7"  ) { $curr_value = $2 * 10000000 ; }
            if ( "$curr_grade" eq "08" || $curr_grade eq "8"  ) { $curr_value = $2 * 100000000 ; }
            if ( "$curr_grade" eq "09" || $curr_grade eq "9"  ) { $curr_value = $2 * 1000000000 ; }
            if ( "$curr_grade" eq "10" ) { $curr_value = $2 * 10000000000 ; }
            if ( "$curr_grade" eq "11" ) { $curr_value = $2 * 100000000000 ; }
            if ( "$curr_grade" eq "12" ) { $curr_value = $2 * 1000000000000 ; }
            }

# - увы, придётся переводить в строковый формат, т.к. gecko отдаёт то нормально, то через е-степень
         $sz_curr_value = sprintf("%.21f", $curr_value) ;
###print "== # == $day_timestamp, $sz_curr_value \n" ;

#         $day_timestamp = $1 ; $curr_value = $2 ; $curr_grade = $3 ;
#print "data sz checked, faza = $data_faza, $day_timestamp, $curr_value \n" ;
         ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($day_timestamp) ;
#         if ($mon == 0) { print "--- mon $mon - $day_timestamp \n" ; }
         $year += 1900 ; $mon += 1 ; if ( $mon < 10 ) { $mon = '0'.$mon ; } if ( $mday < 10 ) { $mday = '0'.$mday ; } if ( $hour < 10 ) { $hour = '0'.$hour ; } if ( $min < 10 ) { $min = '0'.$min ; } if ( $sec < 10 ) { $sec = '0'.$sec ; }
# увидел, что текущая дата повторяется дважды - на 0 часов и на дату запросе по GMT, убираем
         if ( $hour == 0 && $min == 0 && $sec == 0 ) {
#            print "data sz checked, faza = $data_faza, $day_timestamp - $year $mon $mday $hour $min $sec, $curr_value \n" ;
#--            if ( $data_faza eq "prices" ) { $price_date[$cnt_price] = "$year-$mon-$mday" ; $price_value[$cnt_price] = $curr_value ; $cnt_price += 1 ; }
#--            if ( $data_faza eq "market_caps" ) { $market_caps_date[$cnt_cap] = "$year-$mon-$mday" ; $market_caps_value[$cnt_cap] = $curr_value ; $cnt_cap += 1 ; }
#--            if ( $data_faza eq "total_volumes" ) { $total_volumes_date[$cnt_vol] = "$year-$mon-$mday" ; $total_volume_value[$cnt_vol] = $curr_value ; $cnt_vol += 1 ; }

            if ( $data_faza eq "prices" ) { $price_date[$cnt_price] = "$year-$mon-$mday $hour:$min:$sec" ; $price_value[$cnt_price] = $sz_curr_value ; $cnt_price += 1 ; }
            if ( $data_faza eq "market_caps" ) { $market_caps_date[$cnt_cap] = "$year-$mon-$mday $hour:$min:$sec" ; $market_caps_value[$cnt_cap] = $sz_curr_value ; $cnt_cap += 1 ; }
            if ( $data_faza eq "total_volumes" ) { $total_volumes_date[$cnt_vol] = "$year-$mon-$mday $hour:$min:$sec" ; $total_volume_value[$cnt_vol] = $sz_curr_value ; $cnt_vol += 1 ; }
            }
         }
      }

#print "$cnt_price - $cnt_cap - $cnt_vol $#data_price_date \n" ;
for ($i=0;$i <= $#price_date;$i++) {
#-debug-# print "--- $price_date[$i] = $price_value[$i], $market_caps_date[$i] = $market_caps_value[$i], $total_volumes_date[$i] = $total_volume_value[$i]\n" ;
#-debug-# print "INSERT INTO gecko_coins_history_data (currency, reference_currency, day_date, prices, market_caps, total_volumes) VALUES ('bitcoin', 'usd', '$price_date[$i]', $price_value[$i], $market_caps_value[$i], $total_volume_value[$i]) ;\n" ;
    print "select fn_fill_gecko_historical_data(CAST('$main_currency' AS VARCHAR), CAST('$ref_currency' AS VARCHAR), CAST(TO_TIMESTAMP('$price_date[$i]','YYYY-MM-DD HH24:MI:SS') AS timestamp without time zone), $price_value[$i], $market_caps_value[$i], $total_volume_value[$i]) ;\n" ;
    }
