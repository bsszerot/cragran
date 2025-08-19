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
#-debug-print "OK" ; print("id_img_EMA_$pv{currency}"."_$pv{curr_reference}"."---"."$pv{currency}"."---"."$pv{curr_reference}"."---"."$pv{time_frame}"."---"."$pv{count_prds}"."---"."$pv{macd_mult}") ;

print "<!-- <https://zrt.ourorbits.ru/cgi/_ajax_contract_redraw.cgi <BR> \n
cgi user_name = $pv{user_name} <BR> \n
cgi user_id = $pv{user_id} <BR> \n
cgi action = $pv{action} <BR> \n
cgi id_element = $pv{id_elem} <BR> \n
cgi id = $pv{id} <BR> \n
cgi rand_id = $pv{rand_id} <BR> \n
cgi status = $pv{status} <BR> \n
cgi leverage = $pv{leverage} <BR> \n
cgi cycle = $pv{cycle} <BR> \n
cgi currency = $pv{currency} <BR> \n
cgi reference_currency = $pv{reference_currency} <BR> \n
cgi vector = $pv{vector} <BR> \n
 <BR> \n
cgi rmm_sl = $pv{rmm_sl} <BR> \n
cgi rmm_sl_prct = $pv{rmm_sl_prct} <BR> \n
cgi rmm_tp = $pv{rmm_tp} <BR> \n
cgi rmm_tp_prct = $pv{rmm_tp_prct} <BR> \n
cgi rmm_tgt = $pv{rmm_tgt} <BR> \n
cgi rmm_tgt_prct = $pv{rmm_tgt_prct} <BR> \n
cgi rmm_risk = $pv{rmm_risk} <BR> \n
cgi rmm_revard = $pv{rmm_revard} <BR> \n
 <BR> \n
cgi input_base = $pv{input_base} <BR> \n
cgi input_event_rand_id = $pv{input_event_rand_id} <BR> \n
cgi input_time_point = $pv{input_time_point} <BR> \n
cgi input_price = $pv{input_price} <BR> \n
cgi input_volume_prct = $pv{input_volume_prct} <BR> \n
cgi input_volume = $pv{input_volume} <BR> \n
cgi input_summ = $pv{input_summ} <BR> \n
 <BR> \n
cgi ind_curr_ema = $pv{ind_curr_ema}, ind_curr_ema_tf = $pv{ind_curr_ema_tf} <BR> \n
cgi ind_curr_price = $pv{ind_curr_price}, ind_curr_price_tf = $pv{ind_curr_price_tf} <BR> \n
cgi ind_curr_macd_line = $pv{ind_curr_macd_line}, ind_curr_macd_line_tf = $pv{ind_curr_macd_line_tf} <BR> \n
cgi ind_curr_macd_gist = $pv{ind_curr_macd_gist}, ind_curr_macd_gist_tf = $pv{ind_curr_macd_gist_tf} <BR> \n
cgi ind_curr_rsi = $pv{ind_curr_rsi}, ind_curr_rsi_tf = $pv{ind_curr_rsi_tf} <BR> \n
 <BR> \n
cgi ind_own_ema = $pv{ind_own_ema}, ind_own_ema_tf = $pv{ind_own_ema_tf} <BR> \n
cgi ind_own_price = $pv{ind_own_price}, ind_own_price_tf = $pv{ind_own_price_tf} <BR> \n
cgi ind_own_macd_line = $pv{ind_own_macd_line}, ind_own_macd_line_tf = $pv{ind_own_macd_line_tf} <BR> \n
cgi ind_own_macd_gist = $pv{ind_own_macd_gist}, ind_own_macd_gist_tf = $pv{ind_own_macd_gist_tf} <BR> \n
cgi ind_own_rsi = $pv{ind_own_rsi}, ind_own_rsi_tf = $pv{ind_own_rsi_tf} <BR> \n
 <BR> \n
cgi output_base = $pv{output_base} <BR> \n
cgi output_event_rand_id = $pv{output_event_rand_id} <BR> \n
cgi output_time_point = $pv{output_time_point} <BR> \n
cgi output_price = $pv{output_price} <BR> \n
cgi output_volume_prct = $pv{output_volume_prct} <BR> \n
cgi output_volume = $pv{output_volume} <BR> \n
cgi output_summ = $pv{output_summ} <BR> \n
 <BR> \n
cgi result_percent = $pv{result_percent} <BR> \n
cgi result_price = $pv{result_price} <BR> \n
cgi result_volume = $pv{result_volume} <BR> \n
cgi result_summ = $pv{result_summ} <BR> \n
cgi <PRE>contract_comments = $pv{contract_comments}</PRE> <BR> \n-->" ;

#$pv{contract_comments} =~ s/\n/<BR>/g ; $pv{contract_comments} =~ s/\r/<BR>/g ;

print_contract_form_main_block($pv{user_name},$pv{user_id}, $pv{action}, $pv{id_elem}, $pv{id}, $pv{rand_id}, $pv{status}, $pv{leverage}, $pv{cycle}, $pv{currency}, $pv{reference_currency}, $pv{vector},
 $pv{rmm_sl_prct}, $pv{rmm_sl}, $pv{rmm_tp_prct}, $pv{rmm_tp},  $pv{rmm_tgt_prct}, $pv{rmm_tgt}, $pv{rmm_risk}, $pv{rmm_revard}, $pv{input_base}, $pv{input_event_rand_id}, $pv{input_time_point}, $pv{input_price},
 $pv{input_volume}, $pv{input_summ}, $pv{ind_curr_ema_tf}, $pv{ind_curr_ema}, $pv{ind_own_ema_tf}, $pv{ind_own_ema}, $pv{ind_curr_price_tf}, $pv{ind_curr_price}, $pv{ind_own_price_tf}, $pv{ind_own_price},
 $pv{ind_curr_macd_line_tf}, $pv{ind_curr_macd_line}, $pv{ind_own_macd_line_tf}, $pv{ind_own_macd_line}, $pv{ind_curr_macd_gist_tf}, $pv{ind_curr_macd_gist},  $pv{ind_own_macd_gist_tf}, $pv{ind_own_macd_gist},
 $pv{ind_curr_rsi_tf}, $pv{ind_curr_rsi}, $pv{ind_own_rsi_tf}, $pv{ind_own_rsi}, $pv{output_base}, $pv{output_event_rand_id}, $pv{output_time_point}, $pv{output_price}, $pv{output_volume}, $pv{output_summ},
 $pv{result_percent}, $pv{result_price}, $pv{result_volume}, $pv{result_summ}, $pv{contract_comments}) ;

