#!/usr/bin/perl

# open source soft - (C) 2023 CrAgaAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

$main_currency = $ARGV[1] ;
$ref_currency = $ARGV[2] ;

while (<>) { $szCurr = "" ; $szCurr = $_ ; $sec = "" ; 
      $min = "" ; $hour = "" ; $mday  = "" ; $mon = "" ; $year = "" ; $wday  = "" ; $yday  = "" ; $isdst = "" ; $price_open = 0 ; $price_high = 0 ; $price_low = 0 ; $price_close = 0 ; $volfrom = 0 ; $volto = 0 ;
      if ( $szCurr =~ /{"id":"([\S]+)","symbol":"([\S]+)","name":"([\S]+)"},/ ) {
         $id_currency = $1 ; $symbol_currency = $2; $name_currency = $3;
#        print ("--- $id_currency, $symbol_currency, $name_currency \n") ; }
         print "
DO \$\$DECLARE
cntEditString INTEGER ;
cntEditString_nochanged INTEGER ;
BEGIN
        cntEditString := 0 ;
        SELECT count(*) INTO cntEditString
               FROM gecko_coin_list
               WHERE id_gecko_curr = '$id_currency' AND symb_gecko_curr = '$symbol_currency' and name_gecko_curr = '$name_currency' ;
        IF cntEditString > 0 THEN
           cntEditString_nochanged := 0 ;
           SELECT count(*) INTO cntEditString_nochanged
                  FROM gecko_coin_list
                  WHERE id_gecko_curr = '$id_currency' AND symb_gecko_curr = '$symbol_currency' and name_gecko_curr = '$name_currency' ;
                        IF cntEditString_nochanged = 0 THEN
                           UPDATE gecko_coin_list SET id_gecko_curr = '$id_currency' AND symb_gecko_curr = '$symbol_currency' and name_gecko_curr = '$name_currency'
                                  WHERE id_gecko_curr = '$id_currency' AND symb_gecko_curr = '$symbol_currency' and name_gecko_curr = '$name_currency' ;
                        END IF ;
        ELSE
           insert into gecko_coin_list (id_gecko_curr, symb_gecko_curr, name_gecko_curr)
                  values ('$id_currency', '$symbol_currency', '$name_currency') ;
        END IF ;
END\$\$;
" ;
         }
      }
