#!/usr/bin/perl

# open source soft - (C) 2023 CrAgrAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

use DBI ;
require "/var/www/crypta/cgi/common_parameter.cragregator" ;
require "$cragran_dir_lib/lib_common_func.pl" ;
require "$cragran_dir_lib/lib_cragran_common.pl" ;
require "$cragran_dir_lib/lib_cragran_trading.pl" ;
require "$cragran_dir_lib/lib_cragran_contracts.pl" ;

&get_forms_param() ;

print "Content-Type: text/html\n\n" ;

#\"&isvw_big_price_EMA=yes&isvw_MACD=yes&isvw_RSI=yes\"
#-debug-print "OK" ; print("===AJAX_FOR_TRADING=== debug\n<BR>id_elenment = $pv{id_element}"."\n<BR>--- "."currency = $pv{currency}"."\n<BR>--- "."curr_reference = $pv{curr_reference}"."\n<BR>--- ohlc_mode = "."$pv{ohlc_mode}"."\n<BR>--- ohlc_tf = "."$pv{ohlc_tf}"."\n<BR>--- "."count_prds = $pv{count_prds}"."\n<BR>--- "."offset_prds = $pv{offset_prds}"."\n<BR>--- "."env_prct = $pv{env_prct}"."\n<BR>--- "."ema_mode = $pv{ema_mode}"."ema_tf = $pv{ema_tf}"."\n<BR>--- "."macd_mode = $pv{macd_mode}"."\n<BR>--- "."macd_tf = $pv{macd_tf}"."\n<BR>--- "."macd_mult = $pv{macd_mult}"."\n<BR>--- "."rsi_mode = $pv{rsi_mode}"."\n<BR>--- "."rsi_tf = $pv{rsi_tf}"."\n<BR>--- vlt_mode = "."$pv{vlt_mode}"."\n<BR>--- "."vlt_tf = $pv{vlt_tf}"."\n<BR>--- vol_mode = "."$pv{vol_mode}"."\n<BR>--- vol_tf = "."$pv{vol_tf}"."\n<BR>--- block_size = "."$pv{block_size}"."\n<BR>--- nvgt = "."$pv{nvgt_mode}"."\n<BR>--- src_prds = "."$pv{src_prds}"."\n<BR>--- start_tsp = "."$pv{start_tsp}"."\n<BR>--- stop_tsp = "."$pv{stop_tsp}") ;

print_coin_graphs_block("$pv{id_element}","$pv{currency}","$pv{curr_reference}","$pv{ohlc_mode}","$pv{ohlc_tf}","$pv{count_prds}","$pv{offset_prds}","$pv{env_prct}","$pv{ema_mode}","$pv{ema_tf}","$pv{macd_mode}","$pv{macd_tf}","$pv{macd_mult}","$pv{rsi_mode}","$pv{rsi_tf}","$pv{vlt_mode}","$pv{vlt_tf}","$pv{vol_mode}","$pv{vol_tf}","$pv{block_size}","$pv{nvgt_mode}","$pv{src_prds}","$pv{start_tsp}","$pv{stop_tsp}") ;
