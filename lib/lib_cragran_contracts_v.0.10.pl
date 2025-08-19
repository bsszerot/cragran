
# open source soft - (C) 2023 CrAgrAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement


%tf_list ;
$tf_list{nothing} = "не определено" ;
$tf_list{qw/4W/} = "4W" ; $tf_list{qw/1W/} = "1W" ; $tf_list{qw/4D/} = "4D" ; $tf_list{qw/3D/} = "3D" ; $tf_list{qw/2D/} = "2D" ; $tf_list{qw/1D/} = "1D" ; $tf_list{qw/12H/} = "12H" ; $tf_list{qw/8H/} = "8H" ;
$tf_list{qw/4H/} = "4H" ; $tf_list{qw/3H/} = "3H" ; $tf_list{qw/2H/} = "2H" ; $tf_list{qw/1H/} = "1H" ; $tf_list{qw/30M/} = "30M" ; $tf_list{qw/15M/} = "15M" ; $tf_list{qw/10M/} = "10M" ; $tf_list{qw/5M/} = "5M" ;
$tf_list{qw/3M/} = "3M" ; $tf_list{qw/1M/} = "1M" ;
@tf_list = ("nothing", "4W", "1W", "4D", "3D", "2D", "1D", "12H", "8H", "4H", "3H", "2H", "1H", "30M", "15M", "10M", "5M", "3M", "1M") ;

%states_ema ;
$states_ema{nothing} = "не определено" ;
$states_ema{grow} = "Локально растёт" ;
$states_ema{fall} = "Локально падает" ;
$states_ema{flat} = "Флэт" ;
@states_ema = ("nothing", "grow", "fall", "flat") ;

%states_price ;
$states_price{nothing} = "не определено" ;
$states_price{PRICE_GROW_FORM_PRICE_AREA} = "Повыш. трэнд, растёт от ЗЦ" ;
$states_price{PRICE_GROW_TO_PRICE_AREA} = "Повыш. трэнд, возвращается к ЗЦ" ;
$states_price{PRICE_GROW_IN_PRICE_AREA} = "Повыш. трэнд, вошла в ЗЦ" ;
$states_price{PRICE_GROW_TO_CURR_EMA} = "Повыш. трэнд, подошла к EMA" ;
$states_price{PRICE_GROW_CROSS_CURR_EMA} = "Повыш. трэнд, зашла за EMA" ;
$states_price{PRICE_FAL_FROM_PRICE_AREA} = "Пониж. трэнд, падает от ЗЦ" ;
$states_price{PRICE_FAL_TO_PRICE_AREA} = "Пониж. трэнд, возвращается к ЗЦ" ;
$states_price{PRICE_FAL_IN_PRICE_AREA} = "Пониж. трэнд, вошла в ЗЦ" ;
$states_price{PRICE_FAL_TO_CURR_EMA} = "Пониж. трэнд, подошла к EMA" ;
$states_price{PRICE_FAL_CROSS_CURR_EMA} = "Пониж. трэнд, зашла за EMA" ;
$states_price{PRICE_FLAT_GROW_IN_DISC} = "Флэт, растёт в дисконт маркете" ;
$states_price{PRICE_FLAT_FAL_IN_DISC} = "Флэт, падает в дисконт маркете" ;
$states_price{PRICE_FLAT_GROW_IN_PERM} = "Флэт, растёт в премиум маркете" ;
$states_price{PRICE_FLA_FAL_IN_PERM} = "Флэт, падает в премиум маркете" ;
$states_price{other} = "иное" ;
 @states_price = ("nothing","PRICE_GROW_FORM_PRICE_AREA","PRICE_GROW_TO_PRICE_AREA","PRICE_GROW_IN_PRICE_AREA","PRICE_GROW_TO_CURR_EMA","PRICE_GROW_CROSS_CURR_EMA","PRICE_FAL_FROM_PRICE_AREA","PRICE_FAL_TO_PRICE_AREA","PRICE_FAL_IN_PRICE_AREA","PRICE_FAL_TO_CURR_EMA","PRICE_FAL_CROSS_CURR_EMA","PRICE_FLAT_GROW_IN_DISC","PRICE_FLAT_FAL_IN_DISC","PRICE_FLAT_GROW_IN_PERM","PRICE_FLA_FAL_IN_PERM","other") ;

%states_macd_line ;
$states_macd_line{nothing} = "не определено" ;
$states_macd_line{SMALL_TO_UP_MACD_LINE_VECTOR} = "Недавно вверх повернула линия MACD" ;
$states_macd_line{SMALL_TO_DOWN_MACD_LINE_VECTOR} = "Недавно вниз повернула линия MACD" ;
$states_macd_line{SMALL_TO_UP_MACD_LINE_CROSS} = "Недавно вверх пересеклись линии MACD" ;
$states_macd_line{SMALL_TO_DOWN_MACD_LINE_CROSS} = "Недавно вниз пересеклись линии MACD" ;
$states_macd_line{OLD_TO_UP_MACD_LINE_VECTOR} = "Давно вверх повернула линия MACD" ;
$states_macd_line{OLD_TO_DOWN_MACD_LINE_VECTOR} = "Давно вниз повернула линия MACD" ;
$states_macd_line{OLD_TO_UP_MACD_LINE_CROSS} = "Давно вверх пересеклись линии MACD" ;
$states_macd_line{OLD_TO_DOWN_MACD_LINE_CROSS} = "Давно вниз пересеклись линии MACD" ;
$states_macd_line{other} = "Иное" ;
@states_macd_line = ("nothing", "SMALL_TO_UP_MACD_LINE_VECTOR","SMALL_TO_DOWN_MACD_LINE_VECTOR","SMALL_TO_UP_MACD_LINE_CROSS","SMALL_TO_DOWN_MACD_LINE_CROSS","OLD_TO_UP_MACD_LINE_VECTOR","OLD_TO_DOWN_MACD_LINE_VECTOR","OLD_TO_UP_MACD_LINE_CROSS","OLD_TO_DOWN_MACD_LINE_CROSS","other") ;

%states_macd_gist ;
$states_macd_gist{nothing} = "не определено" ;
$states_macd_gist{LOWER_TO_UP_MACD_GIST_VECTOR} = "Снизу вверх повернула гистограмма MACD" ;
$states_macd_gist{LOWER_TO_DOWN_MACD_GIST_VECTOR} = "Снизу вниз повернула гистограмма MACD" ;
$states_macd_gist{HIGH_TO_UP_MACD_GIST_VECTOR} = "Сверху вверх повернула гистограмма MACD" ;
$states_macd_gist{HIGH_TO_DOWN_MACD_GIST_VECTOR} = "Сверху вниз повернула гистограмма MACD" ;
$states_macd_gist{other} = "Иное" ;
@states_macd_gist = ("nothing","LOWER_TO_UP_MACD_GIST_VECTOR","LOWER_TO_DOWN_MACD_GIST_VECTOR","HIGH_TO_UP_MACD_GIST_VECTOR","HIGH_TO_DOWN_MACD_GIST_VECTOR","other") ;

%states_rsi ;
$states_rsi{nothing} = "не определено" ;
$states_rsi{RSI_GROW_PATTERN_HIGH} = "Повыш.птрн., вверху, перекупленность, возможно падение, или продолжение роста" ;
$states_rsi{RSI_GROW_PATTERN_LOW} = "Повыш.птрн., внизу, перепроданность, вероятный рост" ;
$states_rsi{RSI_FAL_PATTERN_LOW} = "Пониж.птрн., внизу, перепроданность, возможен рост, или продолжение падения" ;
$states_rsi{RSI_FAL_PATTERN_HIGH} = "Пониж.птрн., вверху, перекупленность, вероятное падение" ;
$states_rsi{RSI_FLAT_PATTERN_HIGH} = "Флэт, пересечение сверху, перекупленность" ;
$states_rsi{RSI_FLAT_PATTERN_LOW} = "Флэт, пересечение снизу, перепроданность" ;
$states_rsi{other} = "Иное" ;
@states_rsi = ("nothing", "RSI_GROW_PATTERN_HIGH","RSI_GROW_PATTERN_LOW","RSI_FAL_PATTERN_LOW","RSI_FAL_PATTERN_HIGH","RSI_FLAT_PATTERN_HIGH","RSI_FLAT_PATTERN_LOW","other") ;

%states_base_inout ;
$states_base_inout{nothing} = "не определено" ;
$states_base_inout{NEXT_AVERAGING} = "Усреднение к уже существующей сделке" ;
$states_base_inout{TRAND_TO_CURR_PR_AREA} = "Трэнд, озврат к ЗЦ текущего цикла" ;
$states_base_inout{TRAND_TO_OWN_PR_AREA} = "Трэнд, возврат к ЗЦ старшего цикла" ;
$states_base_inout{RSI_LIMIT_CROSS} = "Флэт, сигнал RSI" ;
$states_base_inout{MACD_4H_LINE_CROSS} = "Событие MACD_4H_LINE_CROSS" ;
$states_base_inout{MACD_4H_LINE_VECTOR} = "Событие MACD_4H_LINE_VECTOR" ;
$states_base_inout{MACD_4H_GIST_VECTOR} = "Событие MACD_4H_GIST_VECTOR" ;
$states_base_inout{MACD_1H_LINE_CROSS} = "Событие MACD_1H_LINE_CROSS" ;
$states_base_inout{MACD_1H_LINE_VECTOR} = "Событие MACD_1H_LINE_VECTOR" ;
$states_base_inout{MACD_1H_GIST_VECTOR} = "Событие MACD_1H_GIST_VECTOR" ;
$states_base_inout{INVEST_DISC_MARKET} = "Инвест: монета внизу границы риска" ;
$states_base_inout{INVEST_MENTHOR} = "Инвест: рекомендация клуба М." ;
$states_base_inout{CLOSE_STOP_LOSS} = "Выбило по Stop Loss" ;
$states_base_inout{CLOSE_TAKE_PROFIT} = "Достигло Take Profit" ;
$states_base_inout{HANDS_RAISE_RISK} = "Закрыто руками по смене трэнда" ;
$states_base_inout{HANDS_PRETTY_PROFIT} = "Закрыто руками по достаточности результата" ;
$states_base_inout{other} = "Иное" ;
@states_base_inout = ("nothing","NEXT_AVERAGING","TRAND_TO_CURR_PR_AREA","TRAND_TO_OWN_PR_AREA","RSI_LIMIT_CROSS","MACD_4H_LINE_CROSS","MACD_4H_LINE_VECTOR","MACD_4H_GIST_VECTOR","MACD_1H_LINE_CROSS","MACD_1H_LINE_VECTOR","MACD_1H_GIST_VECTOR","INVEST_DISC_MARKET","INVEST_MENTHOR","CLOSE_STOP_LOSS","CLOSE_TAKE_PROFIT","HANDS_RAISE_RISK","HANDS_PRETTY_PROFIT","other") ;

sub print_contract_form_main_block($$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$) {
    $v_user_name = $_[0] ; $v_user_id = $_[1] ; $v_action = $_[2] ;  $v_id_elem = $_[3] ; $v_id = $_[4] ; $v_rand_id = $_[5] ; $v_status = $_[6] ; $v_leverage = $_[7] ; $v_cycle = $_[8] ; $v_currency = $_[9] ;
    $v_reference_currency = $_[10] ; $v_vector = $_[11] ; $v_rmm_sl_prct = $_[12] ; $v_rmm_sl = $_[13] ; $v_rmm_tp_prct = $_[14] ; $v_rmm_tp = $_[15] ; $v_rmm_tgt_prct = $_[16] ; $v_rmm_tgt = $_[17] ;
    $v_rmm_risk = $_[18] ; $v_rmm_revard = $_[19] ; $v_input_base = $_[20] ; $v_input_event_rand_id = $_[21] ; $v_input_time_point = $_[22] ; $v_input_price = $_[23] ; $v_input_volume = $_[24] ; $v_input_summ = $_[25] ;
    $v_ind_curr_ema_tf = $_[26] ; $v_ind_curr_ema = $_[27] ; $v_ind_own_ema_tf = $_[28] ; $v_ind_own_ema = $_[29] ; $v_ind_curr_price_tf = $_[30] ; $v_ind_curr_price = $_[31] ; $v_ind_own_price_tf = $_[32] ;
    $v_ind_own_price = $_[33] ; $v_ind_curr_macd_line_tf = $_[34] ; $v_ind_curr_macd_line = $_[35] ; $v_ind_own_macd_line_tf = $_[36] ; $v_ind_own_macd_line = $_[37] ; $v_ind_curr_macd_gist_tf = $_[38] ;
    $v_ind_curr_macd_gist = $_[39] ; $v_ind_own_macd_gist_tf = $_[40] ; $v_ind_own_macd_gist = $_[41] ; $v_ind_curr_rsi_tf = $_[42] ; $v_ind_curr_rsi = $_[43] ; $v_ind_own_rsi_tf = $_[44] ; $v_ind_own_rsi = $_[45] ;
    $v_output_base = $_[46] ; $v_output_event_rand_id = $_[47] ; $v_output_time_point = $_[48] ; $v_output_price = $_[49] ; $v_output_volume = $_[50] ; $v_output_summ = $_[51] ; $v_result_percent = $_[52] ;
    $v_result_price = $_[53] ; $v_result_volume = $_[54] ; $v_result_summ = $_[55] ; $v_contract_comments = $_[56] ;

    my $v_result_color = "gray" ; my $v_last_timestamp_point = "" ; my $v_last_price_close = "" ;  my $v_last_time_point ; my $v_last_price ; my $v_prognoze_result_color = "gray" ;

#$v_contract_comments_2 = $v_contract_comments ; $v_contract_comments_2 =~ s/\n/<BR>/g ; $v_contract_comments_2 =~ s/\r/<BR>/g ; 
#-debug-print "https://zrt.ourorbits.ru/cgi/_ajax_contract_redraw.cgi<BR> \nlib action = $v_action <BR> \nlib id_element = $v_id_elem <BR> \nlib id = $v_id <BR> \nlib rand_id = $v_rand_id <BR> \nlib status = $v_status <BR> \nlib cycle = $v_cycle <BR> \nlib currency = $v_currency <BR> \nlib reference_currency = $v_reference_currency <BR> \nlib vector = $v_vector <BR> \n<BR> \nlib rmm_sl = $v_rmm_sl <BR> \nlib rmm_sl_prct = $v_rmm_sl_prct <BR> \nlib rmm_tp = $v_rmm_tp <BR> \nlib rmm_tp_prct = $v_rmm_tp_prct <BR> \nlib rmm_tgt = $v_rmm_tgt <BR> \nlib rmm_tgt_prct = $v_rmm_tgt_prct <BR> \nlib rmm_risk = $v_rmm_risk <BR> \nlib rmm_revard = $v_rmm_revard <BR> \n<BR> \nlib input_base = $v_input_base <BR> \nlib input_event_rand_id = $v_input_event_rand_id <BR> \nlib input_time_point = $v_input_time_point <BR> \nlib input_price = $v_input_price <BR> \n<BR> \nlib input_volume = $v_input_volume <BR> \nlib input_summ = $v_input_summ <BR> \n<BR> \nlib ind_curr_ema = $v_ind_curr_ema, ind_curr_ema_tf = $v_ind_curr_ema_tf <BR> \nlib ind_curr_price = $v_ind_curr_price, ind_curr_price_tf = $v_ind_curr_price_tf <BR> \nlib ind_curr_macd_line = $v_ind_curr_macd_line, ind_curr_macd_line_tf = $v_ind_curr_macd_line_tf <BR> \nlib ind_curr_macd_gist = $v_ind_curr_macd_gist, ind_curr_macd_gist_tf = $v_ind_curr_macd_gist_tf <BR> \nlib ind_curr_rsi = $v_ind_curr_rsi, ind_curr_rsi_tf = $v_ind_curr_rsi_tf <BR> \n<BR> \nlib ind_own_ema = $v_ind_own_ema, ind_own_ema_tf = $v_ind_own_ema_tf <BR> \nlib ind_own_price = $v_ind_own_price, ind_own_price_tf = $v_ind_own_price_tf <BR> \nlib ind_own_macd_line = $v_ind_own_macd_line, ind_own_macd_line_tf = $v_ind_own_macd_line_tf <BR> \nlib ind_own_macd_gist = $v_ind_own_macd_gist, ind_own_macd_gist_tf = $v_ind_own_macd_gist_tf <BR> \nlib ind_own_rsi = $v_ind_own_rsi, ind_own_rsi_tf = $v_ind_own_rsi_tf <BR> \n<BR> \nlib output_base = $v_output_base <BR> \nlib output_event_rand_id = $v_output_event_rand_id <BR> \nlib output_time_point = $v_output_time_point <BR> \nlib output_price = $v_output_price <BR> \nlib output_volume = $v_output_volume <BR> \nlib output_summ = $v_output_summ <BR> \n<BR> \nlib result_percent = $v_result_percent <BR> \nlib result_price = $v_result_price <BR> \nlib result_volume = $v_result_volume <BR> \nlib result_summ = $v_result_summ <BR> \nlib <PRE>contract_comments = $v_contract_comments</PRE> <BR> \n" ;

# блок отработки режимов - их больше, чем сброс, актуализация, запись. Ещё добавим чтение выбранной записи и м.б. что то ещё
# для режима очистки - сбросить данные для заполнения новой записи
    if  ($v_action eq "clean") {
        $v_user_name = $pv{user_name} ; $v_user_id = "" ; $v_id_elem = "" ; $v_id = "" ; $v_rand_id = "" ; $v_status = "open_contract" ; $v_leverage = "1" ; $v_cycle = "weeks"; $v_currency = "nothing" ; $v_reference_currency = "USDT" ;
        $v_vector = "long" ; $v_rmm_sl_prct = "" ; $v_rmm_sl = "" ; $v_rmm_tp_prct = "" ; $v_rmm_tp = "" ; $v_rmm_tgt_prct = "" ; $v_rmm_tgt = "" ; $v_rmm_risk = "" ; $v_rmm_revard = "" ; $v_input_base = "nothing" ;
        $v_input_event_rand_id = "" ; $v_input_time_point = "" ; $v_input_price = "" ; $v_input_volume = "" ; $v_input_summ = "" ; $v_ind_curr_ema_tf = "nothing" ; $v_ind_curr_ema = "nothing" ; $v_ind_own_ema_tf = "nothing" ;
        $v_ind_own_ema = "nothing" ; $v_ind_curr_price_tf = "nothing" ; $v_ind_curr_price = "nothing" ; $v_ind_own_price_tf = "nothing" ; $v_ind_own_price = "nothing" ; $v_ind_curr_macd_line_tf = "nothing" ; $v_ind_curr_macd_line = "nothing" ;
        $v_ind_own_macd_line_tf = "nothing" ; $v_ind_own_macd_line = "nothing" ; $v_ind_curr_macd_gist_tf = "nothing" ; $v_ind_curr_macd_gist = "nothing" ; $v_ind_own_macd_gist_tf = "nothing" ; $v_ind_own_macd_gist = "nothing" ;
        $v_ind_curr_rsi_tf = "nothing" ; $v_ind_curr_rsi = "nothing" ; $v_ind_own_rsi_tf = "nothing" ; $v_ind_own_rsi = "nothing" ; $v_output_base = "nothing" ; $v_output_event_rand_id = "" ; $v_output_time_point = "" ;
        $v_output_price = "" ; $v_output_volume = "" ; $v_output_summ = "" ; $v_result_percent = "" ; $v_result_price = "" ; $v_result_volume = "" ; $v_result_summ = "" ; $v_contract_comments = "" ;
        }

    my $sz_date = `date "+%Y-%m-%d %H:%M:%S"` ;
# $v_input_time_point = ($v_input_time_point eq "") ? $sz_date : $v_input_time_point ; $v_output_time_point = ($v_output_time_point eq "") ? $sz_date : $v_output_time_point ;

# - добавление новой или изменение существующей записи с проверкой, что обязательные поля заполнены
    if  ($v_action eq "write" &&
         ( (($v_status eq "nothing" || $v_status eq "clear_no_contract" || $v_status eq "writed_no_contract" || $v_status eq "open_contract") && $v_input_price > 0 && $v_input_volume > 0) ||
           (($v_status ne "nothing" || $v_status ne "clear_no_contract" && $v_status ne "writed_no_contract" && $v_status ne "open_contract") && $v_input_price > 0 && $v_input_volume > 0 && $v_output_price > 0 && $v_output_volume > 0))
         ) { $request = "" ;

        $v_user_name = ($v_user_name eq "") ? "NULL" : $v_user_name ;
        $v_user_id = ($v_user_id eq "") ? "NULL" : $v_user_id ;
        $v_input_time_point = ($v_input_time_point eq "") ? "NULL" : "CAST(TO_TIMESTAMP('$v_input_time_point','YYYY-MM-DD HH24:MI:SS') AS timestamp without time zone)" ;
        $v_output_time_point = ($v_output_time_point eq "") ? "NULL" : "CAST(TO_TIMESTAMP('$v_output_time_point','YYYY-MM-DD HH24:MI:SS') AS timestamp without time zone)" ;
        $v_leverage = ($v_leverage eq "") ? "NULL" : $v_leverage ;
        $v_rmm_sl_prct = ($v_rmm_sl_prct eq "") ? "NULL" : $v_rmm_sl_prct ;
        $v_rmm_sl = ($v_rmm_sl eq "") ? "NULL" : $v_rmm_sl ;
        $v_rmm_tp_prct = ($v_rmm_tp_prct eq "") ? "NULL" : $v_rmm_tp_prct ;
        $v_rmm_tp = ($v_rmm_tp eq "") ? "NULL" : $v_rmm_tp ;
        $v_rmm_tgt_prct = ($v_rmm_tgt_prct eq "") ? "NULL" : $v_rmm_tgt_prct ;
        $v_rmm_tgt = ($v_rmm_tgt eq "") ? "NULL" : $v_rmm_tgt ;
        $v_rmm_risk = ($v_rmm_risk eq "") ? "NULL" : $v_rmm_risk ;
        $v_rmm_revard = ($v_rmm_revard eq "") ? "NULL" : $v_rmm_revard ;
        $v_input_event_rand_id = ($v_input_event_rand_id eq "") ? "" : $v_input_event_rand_id ;
        $v_input_time_point = ($v_input_time_point eq "") ? "NULL" : $v_input_time_point ;
        $v_input_price = ($v_input_price eq "") ? "NULL" : $v_input_price ;
        $v_input_volume = ($v_input_volume eq "") ? "NULL" : $v_input_volume ;
        $v_input_summ = ($v_input_summ eq "") ? "NULL" : $v_input_summ ;
        $v_output_event_rand_id = ($v_output_event_rand_id eq "") ? "" : $v_output_event_rand_id ;
        $v_output_time_point = ($v_output_time_point eq "") ? "NULL" : $v_output_time_point ;
        $v_output_price = ($v_output_price eq "") ? "NULL" : $v_output_price  ;
        $v_output_volume = ($v_output_volume eq "") ? "NULL" : $v_output_volume ;
        $v_output_summ = ($v_output_summ eq "") ? "NULL" : $v_output_summ ;
        $v_result_percent = ($v_result_percent eq "") ? "NULL" : $v_result_percent ;
        $v_result_price = ($v_result_price eq "") ? "NULL" : $v_result_price ;
        $v_result_volume = ($v_result_volume eq "") ? "NULL" : $v_result_volume ;
        $v_result_summ = ($v_result_summ eq "") ? "NULL" : $v_result_summ ;
#        $v_contract_comments =~ s/\n/<BR>/g ; $v_contract_comments =~ s/\r/<BR>/g ;
#        $v_contract_comments = ($v_contract_comments eq "") ? "NULL" : $v_contract_comments ;

       if ( $v_input_price > 0 && $v_input_volume > 0) { $v_input_summ = $v_input_price * $v_input_volume ; }
# - здесь код добавления новой записи
        if ( $v_rand_id eq "" ) {  $v_id = 0 ; $v_rand_id = rand() ; $v_rand_id =~ s/\.//g ;
           $request = "INSERT INTO contracts_history ( user_name, user_id, contract_rand_id, contract_status, contract_leverage, cycle, currency, reference_currency, contract_vector, rmm_sl_prct, rmm_sl, rmm_tp_prct, rmm_tp,
 rmm_tgt_prct, rmm_tgt, rmm_risk, rmm_revard, input_base, input_event_rand_id, input_time_point, input_price, input_volume, input_summ, ind_curr_ema_tf, ind_curr_ema, ind_own_ema_tf, ind_own_ema, ind_curr_price_tf, ind_curr_price,
 ind_own_price_tf, ind_own_price, ind_curr_macd_line_tf, ind_curr_macd_line, ind_own_macd_line_tf, ind_own_macd_line, ind_curr_macd_gist_tf, ind_curr_macd_gist, ind_own_macd_gist_tf, ind_own_macd_gist, ind_curr_rsi_tf, ind_curr_rsi,
 ind_own_rsi_tf, ind_own_rsi,output_base, output_event_rand_id, output_time_point, output_price, output_volume, output_summ, result_price, result_volume, result_summ, result_percent, comments)
 VALUES ( CAST('$v_user_name' AS VARCHAR), $v_user_id, CAST('$v_rand_id' AS VARCHAR), CAST('$v_status' AS VARCHAR), $v_leverage, CAST('$v_cycle' AS VARCHAR), CAST('$v_currency' AS VARCHAR), CAST('$v_reference_currency' AS VARCHAR),
  CAST('$v_vector' AS VARCHAR),  $v_rmm_sl_prct, $v_rmm_sl, $v_rmm_tp_prct, $v_rmm_tp, $v_rmm_tgt_prct, $v_rmm_tgt, $v_rmm_risk, $v_rmm_revard, CAST('$v_input_base' AS VARCHAR), CAST('$v_input_event_rand_id' AS VARCHAR),
  $v_input_time_point, $v_input_price, $v_input_volume, $v_input_summ, CAST('$v_ind_curr_ema_tf' AS VARCHAR), CAST('$v_ind_curr_ema' AS VARCHAR), CAST('$v_ind_own_ema_tf' AS VARCHAR), CAST('$v_ind_own_ema' AS VARCHAR),
  CAST('$v_ind_curr_price_tf' AS VARCHAR), CAST('$v_ind_curr_price' AS VARCHAR), CAST('$v_ind_own_price_tf' AS VARCHAR), CAST('$v_ind_own_price' AS VARCHAR), CAST('$v_ind_curr_macd_line_tf' AS VARCHAR),
  CAST('$v_ind_curr_macd_line' AS VARCHAR), CAST('$v_ind_own_macd_line_tf' AS VARCHAR), CAST('$v_ind_own_macd_line' AS VARCHAR), CAST('$v_ind_curr_macd_gist_tf' AS VARCHAR), CAST('$v_ind_curr_macd_gist' AS VARCHAR),
  CAST('$v_ind_own_macd_gist_tf' AS VARCHAR), CAST('$v_ind_own_macd_gist' AS VARCHAR), CAST('$v_ind_curr_rsi_tf' AS VARCHAR), CAST('$v_ind_curr_rsi' AS VARCHAR), CAST('$v_ind_own_rsi_tf' AS VARCHAR), CAST('$v_ind_own_rsi' AS VARCHAR),
  CAST('$v_output_base' AS VARCHAR),  CAST('$v_output_event_rand_id' AS VARCHAR), $v_output_time_point, $v_output_price, $v_output_volume, $v_output_summ, $v_result_price, $v_result_volume, $v_result_summ, $v_result_percent,
  CAST('$v_contract_comments' AS VARCHAR))" ;
#-debug-print "INSERT request - $request<BR>\n" ;
           my $dbh_h = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'cryptapwd') ; my $sth_h = $dbh_h->prepare($request) ; $sth_h->execute(); $sth_h->finish() ; $dbh_h->disconnect() ;
           }
# - здесь код обновления записи
        else {
           $request = "UPDATE contracts_history set user_name =  CAST('$v_user_name' AS VARCHAR), user_id = $v_user_id, contract_status = CAST('$v_status' AS VARCHAR), contract_leverage = $v_leverage,
 cycle = CAST('$v_cycle' AS VARCHAR), currency = CAST('$v_currency' AS VARCHAR), reference_currency = CAST('$v_reference_currency' AS VARCHAR), contract_vector = CAST('$v_vector' AS VARCHAR), rmm_sl_prct = $v_rmm_sl_prct,
 rmm_sl = $v_rmm_sl, rmm_tp_prct = $v_rmm_tp_prct, rmm_tp = $v_rmm_tp, rmm_tgt_prct = $v_rmm_tgt_prct, rmm_tgt = $v_rmm_tgt, rmm_risk = $v_rmm_risk, rmm_revard = $v_rmm_revard, input_base = CAST('$v_input_base' AS VARCHAR),
 input_event_rand_id = CAST('$v_input_event_rand_id' AS VARCHAR), input_time_point = $v_input_time_point, input_price = $v_input_price, input_volume = $v_input_volume, input_summ = $v_input_summ,
 ind_curr_ema_tf = CAST('$v_ind_curr_ema_tf' AS VARCHAR), ind_curr_ema = CAST('$v_ind_curr_ema' AS VARCHAR), ind_own_ema_tf = CAST('$v_ind_own_ema_tf' AS VARCHAR), ind_own_ema = CAST('$v_ind_own_ema' AS VARCHAR),
 ind_curr_price_tf = CAST('$v_ind_curr_price_tf' AS VARCHAR), ind_curr_price = CAST('$v_ind_curr_price' AS VARCHAR), ind_own_price_tf = CAST('$v_ind_own_price_tf' AS VARCHAR), ind_own_price = CAST('$v_ind_own_price' AS VARCHAR),
 ind_curr_macd_line_tf = CAST('$v_ind_curr_macd_line_tf' AS VARCHAR), ind_curr_macd_line = CAST('$v_ind_curr_macd_line' AS VARCHAR), ind_own_macd_line_tf = CAST('$v_ind_own_macd_line_tf' AS VARCHAR),
 ind_own_macd_line = CAST('$v_ind_own_macd_line' AS VARCHAR), ind_curr_macd_gist_tf = CAST('$v_ind_curr_macd_gist_tf' AS VARCHAR), ind_curr_macd_gist = CAST('$v_ind_curr_macd_gist' AS VARCHAR),
 ind_own_macd_gist_tf = CAST('$v_ind_own_macd_gist_tf' AS VARCHAR), ind_own_macd_gist = CAST('$v_ind_own_macd_gist' AS VARCHAR), ind_curr_rsi_tf = CAST('$v_ind_curr_rsi_tf' AS VARCHAR), ind_curr_rsi = CAST('$v_ind_curr_rsi' AS VARCHAR),
 ind_own_rsi_tf = CAST('$v_ind_own_rsi_tf' AS VARCHAR), ind_own_rsi = CAST('$v_ind_own_rsi' AS VARCHAR), output_base = CAST('$v_output_base' AS VARCHAR), output_event_rand_id = CAST('$v_output_event_rand_id' AS VARCHAR),
 output_time_point = $v_output_time_point, output_price = $v_output_price, output_volume = $v_output_volume, output_summ = $v_output_summ, result_price = $v_result_price, result_volume = $v_result_volume, result_summ = $v_result_summ,
 result_percent = $v_result_percent, comments = CAST('$v_contract_comments' AS VARCHAR)
 WHERE contract_id = $v_id AND contract_rand_id = '$v_rand_id'" ;
#-debug-print "UPDATE request - $request<BR>\n" ;
           my $dbh_h = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'cryptapwd') ; my $sth_h = $dbh_h->prepare($request) ; $sth_h->execute(); $sth_h->finish() ; $dbh_h->disconnect() ;
           }
        }
     else { if ($v_action eq "write") {
        print "<SPAN STYLE=\"color: red;\">Ошибка !!! Поля цен и объёмов не заполнены корректно, записи/обновления не производится. Сброс вызова. Заполните и повторите попытку\n<BR></SPAN>" ;
        return ; }
        }

# если запись добавлена, обновлена или явная команда на перечитывание - перечитать данные записи из БД и отрисовывать уже жанные из БД
    if ($v_action eq "write" || $v_action eq "read") { $request = "" ;
       $request = "SELECT user_name, user_id, contract_id, contract_rand_id, contract_status, contract_leverage, cycle, currency, reference_currency, contract_vector, rmm_sl_prct, rmm_sl, rmm_tp_prct, rmm_tp, rmm_tgt_prct, rmm_tgt,
 rmm_risk, rmm_revard, input_base, input_event_rand_id, TO_CHAR(input_time_point, 'YYYY-MM-DD HH24:MI:SS'), input_price, input_volume, input_summ, ind_curr_ema_tf, ind_curr_ema, ind_own_ema_tf, ind_own_ema,
 ind_curr_price_tf, ind_curr_price, ind_own_price_tf, ind_own_price, ind_curr_macd_line_tf, ind_curr_macd_line, ind_own_macd_line_tf, ind_own_macd_line, ind_curr_macd_gist_tf, ind_curr_macd_gist,
 ind_own_macd_gist_tf, ind_own_macd_gist, ind_curr_rsi_tf, ind_curr_rsi, ind_own_rsi_tf, ind_own_rsi,output_base, output_event_rand_id, TO_CHAR(output_time_point, 'YYYY-MM-DD HH24:MI:SS'), output_price,
 output_volume, output_summ, result_price, result_volume, result_summ, result_percent, comments
 from contracts_history where contract_rand_id = '$v_rand_id'" ;
#-debug-print "$request<BR>\n" ;
       my $dbh_h = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'cryptapwd') ; my $sth_h = $dbh_h->prepare($request) ; $sth_h->execute();
       ($v_user_name, $v_user_id, $v_id, $v_rand_id, $v_status, $v_leverage, $v_cycle, $v_currency, $v_reference_currency, $v_vector, $v_rmm_sl_prct, $v_rmm_sl, $v_rmm_tp_prct, $v_rmm_tp, $v_rmm_tgt_prct, $v_rmm_tgt, $v_rmm_risk, $v_rmm_revard, $v_input_base, $v_input_event_rand_id, $v_input_time_point, $v_input_price, $v_input_volume, $v_input_summ, $v_ind_curr_ema_tf, $v_ind_curr_ema, $v_ind_own_ema_tf, $v_ind_own_ema, $v_ind_curr_price_tf, $v_ind_curr_price, $v_ind_own_price_tf, $v_ind_own_price, $v_ind_curr_macd_line_tf, $v_ind_curr_macd_line, $v_ind_own_macd_line_tf, $v_ind_own_macd_line, $v_ind_curr_macd_gist_tf, $v_ind_curr_macd_gist, $v_ind_own_macd_gist_tf, $v_ind_own_macd_gist, $v_ind_curr_rsi_tf, $v_ind_curr_rsi, $v_ind_own_rsi_tf, $v_ind_own_rsi, $v_output_base, $v_output_event_rand_id, $v_output_time_point, $v_output_price, $v_output_volume, $v_output_summ, $v_result_price, $v_result_volume, $v_result_summ, $v_result_percent, $v_contract_comments) = $sth_h->fetchrow_array() ;
       $sth_h->finish() ; $dbh_h->disconnect() ;

       $v_rmm_sl =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_rmm_sl =~ s/(\d+)\.$/$1/g ;
       $v_rmm_tp =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_rmm_tp =~ s/(\d+)\.$/$1/g ;
       $v_rmm_tgt =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_rmm_tgt =~ s/(\d+)\.$/$1/g ;
       $v_input_price =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_input_price =~ s/(\d+)\.$/$1/g ;
       $v_input_volume =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_input_volume =~ s/(\d+)\.$/$1/g ;
       $v_input_summ =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_input_summ =~ s/(\d+)\.$/$1/g ;
       $v_output_price =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_output_price =~ s/(\d+)\.$/$1/g ;
       $v_output_volume =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_output_volume =~ s/(\d+)\.$/$1/g ;
       $v_output_summ =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_output_summ =~ s/(\d+)\.$/$1/g ;
       $v_result_price =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_result_price =~ s/(\d+)\.$/$1/g ;
       $v_result_volume =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_result_volume =~ s/(\d+)\.$/$1/g ;
       $v_result_summ =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_result_summ =~ s/(\d+)\.$/$1/g ;

#-debug-print "https://zrt.ourorbits.ru/cgi/_ajax_contract_redraw.cgi<BR> \nread user_name = $v_user_name<BR> \nread user_id = $v_user_id <BR> \nread action = $v_action <BR> \nread id_element = $v_id_elem <BR> \nread id = $v_id <BR> \nread rand_id = $v_rand_id <BR> \nread status = $v_status <BR> \nread cycle = $v_cycle <BR> \nread currency = $v_currency <BR> \nread reference_currency = $v_reference_currency <BR> \nread vector = $v_vector <BR> \n<BR> \nread rmm_sl = $v_rmm_sl <BR> \nread rmm_sl_prct = $v_rmm_sl_prct <BR> \nread rmm_tp = $v_rmm_tp <BR> \nread rmm_tp_prct = $v_rmm_tp_prct <BR> \nread rmm_tgt = $v_rmm_tgt <BR> \nread rmm_tgt_prct = $v_rmm_tgt_prct <BR> \nread rmm_risk = $v_rmm_risk <BR> \nread rmm_revard = $v_rmm_revard <BR> \n<BR> \nread input_base = $v_input_base <BR> \nread input_event_rand_id = $v_input_event_rand_id <BR> \nread input_time_point = $v_input_time_point <BR> \nread input_price = $v_input_price <BR> \n<BR> \nread input_volume = $v_input_volume <BR> \nread input_summ = $v_input_summ <BR> \n<BR> \nread ind_curr_ema = $v_ind_curr_ema, ind_curr_ema_tf = $v_ind_curr_ema_tf <BR> \nread ind_curr_price = $v_ind_curr_price, ind_curr_price_tf = $v_ind_curr_price_tf <BR> \nread ind_curr_macd_line = $v_ind_curr_macd_line, ind_curr_macd_line_tf = $v_ind_curr_macd_line_tf <BR> \nread ind_curr_macd_gist = $v_ind_curr_macd_gist, ind_curr_macd_gist_tf = $v_ind_curr_macd_gist_tf <BR> \nread ind_curr_rsi = $v_ind_curr_rsi, ind_curr_rsi_tf = $v_ind_curr_rsi_tf <BR> \n<BR> \nread ind_own_ema = $v_ind_own_ema, ind_own_ema_tf = $v_ind_own_ema_tf <BR> \nread ind_own_price = $v_ind_own_price, ind_own_price_tf = $v_ind_own_price_tf <BR> \nread ind_own_macd_line = $v_ind_own_macd_line, ind_own_macd_line_tf = $v_ind_own_macd_line_tf <BR> \nread ind_own_macd_gist = $v_ind_own_macd_gist, ind_own_macd_gist_tf = $v_ind_own_macd_gist_tf <BR> \nread ind_own_rsi = $v_ind_own_rsi, ind_own_rsi_tf = $v_ind_own_rsi_tf <BR> \n<BR> \nread output_base = $v_output_base <BR> \nread output_event_rand_id = $v_output_event_rand_id <BR> \nread output_time_point = $v_output_time_point <BR> \nread output_price = $v_output_price <BR> \nread output_volume = $v_output_volume <BR> \nread output_summ = $v_output_summ <BR> \n<BR> \nread result_percent = $v_result_percent <BR> \nread result_price = $v_result_price <BR> \nread result_volume = $v_result_volume <BR> \nread result_summ = $v_result_summ <BR> \nread <PRE>contract_comments = $v_contract_comments</PRE> <BR> \n" ;
#       $v_contract_comments =~ s/<BR>/\n/g ;

#-debug-print "<BR>====$v_id, $v_rand_id, $v_status, $v_cycle, $v_currency, $v_reference_currency, $v_vector, $v_leverage, $v_rmm_sl_prct, $v_rmm_sl, $v_rmm_tp_prct, $v_rmm_tp, $v_rmm_tgt_prct, $v_rmm_tgt,
# $v_rmm_risk, $v_rmm_revard, $v_input_base, $v_input_event_rand_id, $v_input_time_point, $v_input_price, $v_input_volume, $v_input_summ, $v_ind_curr_ema_tf, $v_ind_curr_ema, $v_ind_own_ema_tf, $v_ind_own_ema,
# $v_ind_curr_price_tf, $v_ind_curr_price, $v_ind_own_price_tf, $v_ind_own_price, $v_ind_curr_macd_line_tf, $v_ind_curr_macd_line, $v_ind_own_macd_line_tf, $v_ind_own_macd_line, $v_ind_curr_macd_gist_tf, $v_ind_curr_macd_gist,
# $v_ind_own_macd_gist_tf, $v_ind_own_macd_gist, $v_ind_curr_rsi_tf, $v_ind_curr_rsi, $v_ind_own_rsi_tf, $v_ind_own_rsi, $v_output_base, $v_output_event_rand_id, $v_output_time_point, $v_output_price, $v_output_volume,
# $v_output_summ, $v_result_price, $v_result_volume, $v_result_summ, $v_result_percent, $v_contract_comments<BR>" ;

       }

       $v_contract_comments =~ s/<BR>/\n/g ;
# инициализировать переменные для заполнения кросс - ссылок
#       $pv{currency} = $v_currency ; $pv{curr_reference} = $v_reference_currency ; $pv{cnt_rand_id} = $v_rand_id ;

# - при выборе режима актуализхации подтягиваются данные последней даты и цены
# для статусов до open_contract они актуализируют поля входа, для начиная с open_contract - поля выхода, и всегда - прогнозные
    if ($v_action eq "actualize" && $v_currency ne "" && $v_reference_currency ne "") { $request = "" ;
       $request = "SELECT TO_CHAR(timestamp_point + INTERVAL '3 hour', 'YYYY-MM-DD HH24:MI:SS'), price_close from crcomp_pair_ohlc_1m_history where currency = '$v_currency' AND reference_currency = '$v_reference_currency'
                          AND timestamp_point = (SELECT MAX(timestamp_point) from crcomp_pair_ohlc_1m_history where currency = '$v_currency' AND reference_currency = '$v_reference_currency')" ;
#-debug-print "$request<BR>\n" ;
       my $dbh_h = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'cryptapwd') ; my $sth_h = $dbh_h->prepare($request) ; $sth_h->execute();
       ($v_last_timestamp_point, $v_last_price_close) = $sth_h->fetchrow_array() ;
#-debug-print "=== $v_last_timestamp_point, $v_last_price_close<BR>\n" ;
       $sth_h->finish() ; $dbh_h->disconnect() ;
       $v_last_price_close =~ s/([\.\d]+[\.123456789])0+$/$1/g ; $v_last_price_close =~ s/(\d+)\.$/$1/g ;
       if ($v_last_timestamp_point ne "" && $v_last_price_close ne "") {
          if ($v_status eq "clear_no_contract" || $v_status eq "writed_no_contract" || $v_status eq "nothing") {
             $v_input_time_point = $v_last_timestamp_point ; $v_input_price = $v_last_price_close ; if ($v_input_volume > 0) { $v_input_summ = $v_input_price * $v_input_volume ; }
             }
          if ($v_status eq "open_contract" && $v_output_time_point eq "" && $v_output_price eq "") {
             $v_output_time_point = $v_last_timestamp_point ; $v_output_price = $v_last_price_close ; if ($v_output_volume > 0) { $v_output_summ = $v_output_price * $v_output_volume ; }
             }
          $v_last_time_point = $v_last_timestamp_point ;
          $v_last_price = $v_last_price_close ;
          }
       }

# рассчитать значения прогноза и результата
    if ( $v_input_price > 0 && $v_input_volume >  0 && $v_output_price > 0 && ( $v_vector eq "long" || $v_vector eq "short" ) ) {
       my $v_mult = 1 ; my $v_mult_2 = 1 ; $v_result_color = "green" ; 
#       if ( $v_leverage ne "" && $v_leverage > 0 ) { $v_mult = $v_leverage ; } 
       if ( $v_vector eq "short") { $v_mult *= -1 ; $v_mult_2 = -1 ; $v_result_color = "red" ; }
       if ( $v_input_price > 0 && $v_input_volume >  0 ) { $v_input_summ = $v_input_price * $v_input_volume ; $v_output_volume = $v_input_volume ; }
       if ( $v_output_price > 0 ) { $v_output_summ = $v_output_price * $v_output_volume ; }
       $v_result_summ = ($v_output_summ - $v_input_summ) * $v_mult ;
       $v_result_price = $v_output_price - $v_input_price ;
       $v_result_volume = $v_input_volume  * $v_mult ;
       $v_result_summ = ($v_output_summ - $v_input_summ) * $v_mult ;
       $v_result_percent = sprintf("%0.2f", $v_result_summ / ($v_input_summ / 100)) ;
       }

    if ( $v_input_price > 0 && $v_input_volume >  0 && $v_last_price > 0 && ( $v_vector eq "long" || $v_vector eq "short" ) ) {
       my $v_mult = 1 ; my $v_mult_2 = 1 ; $v_prognoze_result_color = "green" ;
#       if ( $v_leverage ne "" && $v_leverage > 0 ) { $v_mult = $v_leverage ; }
       if ( $v_vector eq "short") { $v_mult *= -1 ; $v_mult_2 = -1 ; $v_prognoze_result_color = "red" ; }
       $v_last_volume = $v_input_volume ; $v_prognoze_volume = $v_input_volume ;
       if ( $v_last_price > 0 ) { $v_last_summ = $v_last_price * $v_last_volume ; }

       $v_prognoze_price = $v_last_price - $v_input_price ;
       $v_prognoze_volume = $v_input_volume ;
       $v_prognoze_summ = ($v_last_summ - $v_input_summ) * $v_mult ;
       $v_prognoze_percent = sprintf("%0.2f", $v_prognoze_summ / ($v_input_summ / 100)) ;
       }

#    $v_contract_comments .= "\n--- ".$sz_date ;
    my $sz_curr_key = "" ;
    my $is_selected = "" ;

    print "<FORM>
<!-- начало версточной таблицы одной сделки -->
<TABLE>

<TR><TD COLSPAN=\"3\" CLASS=\"contract_delim\">Основные</TD><TD COLSPAN=\"10\"><HR CLASS=\"contract_delim\"></TD></TR>
<TR><TD CLASS=\"contract_norm\"  STYLE=\"text-align: right;\" COLSPAN=\"13\">
    <SPAN CLASS=\"contract_action\" onclick=\"contracts_form_redraw(id_user_name.value, id_user_id.value, 'clean', 'id_one_contract', id_id.value, id_rand_id.value, id_status.value, id_leverage.value, id_cycle_type.value, id_currency.value,
          id_curr_reference.value, id_vector.value, id_rmm_sl_price_prct.value, id_rmm_sl_price.value, id_rmm_tp_price_prct.value, id_rmm_tp_price.value, id_rmm_target_price_prct.value, id_rmm_target_price.value, id_rmm_risk.value,
          id_rmm_reward.value, id_input_base.value, id_input_event_id.value, id_input_date.value, id_input_price.value, id_input_volume.value, id_input_summ.value, id_ind_curr_ema_tf.value, id_ind_curr_ema.value,
          id_ind_own_ema_tf.value, id_ind_own_ema.value, id_ind_curr_price_tf.value, id_ind_curr_price.value, id_ind_own_price_tf.value, id_ind_own_price.value, id_ind_curr_macd_line_tf.value, id_ind_curr_macd_line.value,
          id_ind_own_macd_line_tf.value, id_ind_own_macd_line.value, id_ind_curr_macd_gist_tf.value, id_ind_curr_macd_gist.value, id_ind_own_macd_gist_tf.value, id_ind_own_macd_gist.value, id_ind_curr_rsi_tf.value,
          id_ind_curr_rsi.value, id_ind_own_rsi_tf.value, id_ind_own_rsi.value, id_output_base.value, id_output_event_id.value, id_output_date.value, id_output_price.value, id_output_volume.value, id_output_summ.value,
          id_result_percent.value, id_result_price.value, id_result_volume.value, id_result_summ.value, id_contract_comments.value)\" TITLE=\"сбросить значения для заполнения новой записи\">новая</SPAN>&nbsp;

    <SPAN CLASS=\"contract_action\" onclick=\"contracts_form_redraw(id_user_name.value, id_user_id.value, 'actualize', 'id_one_contract', id_id.value, id_rand_id.value, id_status.value, id_leverage.value, id_cycle_type.value, id_currency.value,
          id_curr_reference.value, id_vector.value, id_rmm_sl_price_prct.value, id_rmm_sl_price.value, id_rmm_tp_price_prct.value, id_rmm_tp_price.value, id_rmm_target_price_prct.value, id_rmm_target_price.value, id_rmm_risk.value,
          id_rmm_reward.value,
          id_input_base.value, id_input_event_id.value, id_input_date.value, id_input_price.value, id_input_volume.value, id_input_summ.value, id_ind_curr_ema_tf.value, id_ind_curr_ema.value, id_ind_own_ema_tf.value,
          id_ind_own_ema.value, id_ind_curr_price_tf.value, id_ind_curr_price.value, id_ind_own_price_tf.value, id_ind_own_price.value, id_ind_curr_macd_line_tf.value, id_ind_curr_macd_line.value, id_ind_own_macd_line_tf.value,
          id_ind_own_macd_line.value, id_ind_curr_macd_gist_tf.value, id_ind_curr_macd_gist.value, id_ind_own_macd_gist_tf.value, id_ind_own_macd_gist.value, id_ind_curr_rsi_tf.value, id_ind_curr_rsi.value,
          id_ind_own_rsi_tf.value, id_ind_own_rsi.value, id_output_base.value, id_output_event_id.value, id_output_date.value, id_output_price.value, id_output_volume.value, id_output_summ.value, id_result_percent.value,
          id_result_price.value, id_result_volume.value, id_result_summ.value, id_contract_comments.value)\" TITLE=\"актуализировать: [1] для подготовки - дату, цены, опц. значения индикаторов, [2] в сделке - текущие цены и результаты\">актуализировать</SPAN>&nbsp;

    <SPAN CLASS=\"contract_action\" onclick=\"contracts_form_redraw(id_user_name.value, id_user_id.value, 'write', 'id_one_contract', id_id.value, id_rand_id.value, id_status.value, id_leverage.value, id_cycle_type.value, id_currency.value,
          id_curr_reference.value,
          id_vector.value, id_rmm_sl_price_prct.value, id_rmm_sl_price.value, id_rmm_tp_price_prct.value, id_rmm_tp_price.value, id_rmm_target_price_prct.value, id_rmm_target_price.value, id_rmm_risk.value, id_rmm_reward.value,
          id_input_base.value, id_input_event_id.value, id_input_date.value, id_input_price.value, id_input_volume.value, id_input_summ.value, id_ind_curr_ema_tf.value, id_ind_curr_ema.value, id_ind_own_ema_tf.value,
          id_ind_own_ema.value, id_ind_curr_price_tf.value, id_ind_curr_price.value, id_ind_own_price_tf.value, id_ind_own_price.value, id_ind_curr_macd_line_tf.value, id_ind_curr_macd_line.value, id_ind_own_macd_line_tf.value,
          id_ind_own_macd_line.value, id_ind_curr_macd_gist_tf.value, id_ind_curr_macd_gist.value, id_ind_own_macd_gist_tf.value, id_ind_own_macd_gist.value, id_ind_curr_rsi_tf.value, id_ind_curr_rsi.value,
          id_ind_own_rsi_tf.value, id_ind_own_rsi.value, id_output_base.value, id_output_event_id.value, id_output_date.value, id_output_price.value, id_output_volume.value, id_output_summ.value, id_result_percent.value,
          id_result_price.value, id_result_volume.value, id_result_summ.value, id_contract_comments.value)\" TITLE=\"запись в БД новую - с пустым ID или изменить текущую с установленным ID\">записать</SPAN>

    <A HREF=\"cgi/tools_coin_contracts.cgi?action=read&cnt_rand_id=$v_rand_id\" TITLEW=\"обновить всю страницу\">обновить</A>
</TD></TR>

<TR><TD CLASS=\"contract_norm\" CLASS=\"contract_norm\">пользователь</TD>

    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD COLSPAN=\"2\">
<SELECT CLASS=\"contract_norm_user_name\" NAME=\"user_name\" ID=\"id_user_name\">" ;
$is_selected = "" ; if ( $v_user_name eq "undefined" ) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"undefined\" $is_selected>не определено</OPTION>" ;
$is_selected = "" ; if ( $v_user_name eq "Serjie") { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"Serjie\" $is_selected>Serjie</OPTION>" ;
$is_selected = "" ; if ( $v_user_name eq "Semnava") { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"Semnava\" $is_selected>Semnava</OPTION>" ;
print "</SELECT>
<INPUT TYPE=\"hidden\" NAME=\"user_id\" ID=\"id_user_id\" VALUE=\"$v_user_id\" DIASBLED>&nbsp;
ID <INPUT CLASS=\"contract_norm_id\" NAME=\"id\" ID=\"id_id\" VALUE=\"$v_id\" TITLE=\"contract rand_id = $v_rand_id\" DISABLED><INPUT TYPE=\"hidden\" NAME=\"rand_id\" ID=\"id_rand_id\" VALUE=\"$v_rand_id\" DISABLED></TD>

    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm\" COLSPAN=\"6\">Статус
        <SELECT CLASS=\"contract_norm_status\" name=\"status\" ID=\"id_status\">" ;
$is_selected = "" ; if ( $v_status eq "clear_no_contract") { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"clear_no_contract\" $is_selected>не записана (подготовка)</OPTION>" ;
$is_selected = "" ; if ( $v_status eq "writed_no_contract") { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"writed_no_contract\" $is_selected>записана, не в сделке</OPTION>" ;
$is_selected = "" ; if ( $v_status eq "open_contract") { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"open_contract\" $is_selected>открытая сделка</OPTION>" ;
$is_selected = "" ; if ( $v_status eq "part_closed_contract") { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"part_closed_contract\" DISABLED $is_selected>частично закрытая сделка</OPTION>" ;
$is_selected = "" ; if ( $v_status eq "closed_contract") { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"closed_contract\" $is_selected TITLE=\"можно модифицировать\">закрытая сделка</OPTION>" ;
$is_selected = "" ; if ( $v_status eq "archived_contract") { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"archived_contract\" $is_selected TITLE=\"защищено от модификаций, кроме изменения статуса\">в архиве</OPTION>" ;
print " </SELECT>
    </TD>
    <TD CLASS=\"contract_norm\">Плечо</TD>
    <TD><INPUT CLASS=\"contract_norm_lever\" NAME=\"leverage\" ID=\"id_leverage\" VALUE=\"$v_leverage\"></TD>
    </TR>

<TR><TD CLASS=\"contract_norm\">цикл</TD>

    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD COLSPAN=\"2\">" ;

$vector_slyle_color = "" ;
if ( $v_vector eq "short" ) { $vector_slyle_color = "red" ; } if ( $v_vector eq "long" ) { $vector_slyle_color = "green" ; } if ( $v_vector eq "nothing" ) { $vector_slyle_color = "navy" ; }
print " <SELECT CLASS=\"contract_big_cycle\" STYLE=\"color: $vector_slyle_color;\" name=\"cycle_type\" ID=\"id_cycle_type\" onchange=\"set_contract_cycle()\">" ;
$is_selected = "" ; if ( $v_cycle eq "nothing") { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"nothing\" $is_selected>не определено</OPTION>" ;
$is_selected = "" ; if ( $v_cycle eq "minutes") { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"minutes\" $is_selected>минуты</OPTION>" ;
$is_selected = "" ; if ( $v_cycle eq "hours") { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"hours\" $is_selected>часы</OPTION>" ;
$is_selected = "" ; if ( $v_cycle eq "days") { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"days\" $is_selected>дни</OPTION>" ;
$is_selected = "" ; if ( $v_cycle eq "weeks") { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"weeks\" $is_selected>недели</OPTION>" ;
$is_selected = "" ; if ( $v_cycle eq "months") { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"months\" $is_selected>месяцы</OPTION>" ;
$is_selected = "" ; if ( $v_cycle eq "invest") { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"invest\" $is_selected>инвестирование</OPTION>" ;
print "</SELECT></TD>

    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_big\" COLSPAN=\"2\">
        <SELECT CLASS=\"contract_big_coin\" STYLE=\"color: $vector_slyle_color;\" name=\"currency\" ID=\"id_currency\">" ;

$is_selected = "" ; if ( $v_currency eq "nothing") { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"nothing\" $is_selected>не определено</OPTION>" ;
$request = "select distinct currency from crcomp_pair_OHLC_1D_history order by 1 asc" ;
my $dbh_h = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'cryptapwd') ;
my $sth_h = $dbh_h->prepare($request) ; $sth_h->execute();
while ( my ($curr_currency) = $sth_h->fetchrow_array() ) {
      $is_selected = "" ; if ( $v_currency eq $curr_currency) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$curr_currency\" $is_selected>$curr_currency</OPTION>" ;
      }
$sth_h->finish() ;
$dbh_h->disconnect() ;

print " </SELECT></TD>

    <TD CLASS=\"contract_big\" ID=\"id_coin_big_td\">&nbsp;/&nbsp;</TD>
    <TD CLASS=\"contract_big\" COLSPAN=\"2\">
        <SELECT CLASS=\"contract_big_ref_coin\" STYLE=\"color: $vector_slyle_color;\" name=\"curr_reference\" ID=\"id_curr_reference\">" ;

$is_selected = "" ; if ( $v_curr_reference eq "nothing") { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"nothing\" $is_selected>не определено</OPTION>" ;
$request = "select distinct reference_currency from crcomp_pair_OHLC_1D_history order by 1 asc" ;
my $dbh_h = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'cryptapwd') ;
my $sth_h = $dbh_h->prepare($request) ; $sth_h->execute();
while ( my ($reference_currency) = $sth_h->fetchrow_array() ) {
      $is_selected = "" ; if ( $v_reference_currency eq $reference_currency) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$reference_currency\" $is_selected>$reference_currency</OPTION>" ;
      }
$sth_h->finish() ;
$dbh_h->disconnect() ;

print " </SELECT></TD>

    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_big\" COLSPAN=\"2\">
        <SELECT CLASS=\"contract_big_type\" STYLE=\"color: $vector_slyle_color;\" name=\"vector\" ID=\"id_vector\" onchange=\"set_contract_vector()\">" ;
$is_selected = "" ; if ( $v_vector eq "nothing") { $is_selected = "SELECTED" ; } print " <OPTION VALUE=\"nothing\" $is_selected>не определено</OPTION>" ;
$is_selected = "" ; if ( $v_vector eq "long") { $is_selected = "SELECTED" ; } print " <OPTION VALUE=\"long\" $is_selected>Long</OPTION>" ;
$is_selected = "" ; if ( $v_vector eq "short") { $is_selected = "SELECTED" ; } print " <OPTION VALUE=\"short\" $is_selected>Short</OPTION>" ;
print " </SELECT></TD>

    <TD>&nbsp;&nbsp;&nbsp;</TD>
    </TR>

<TR><TD CLASS=\"contract_norm\" TITLE=\"управление рисками и капиталом\">РММ</TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm\">SL</TD>
    <TD><INPUT CLASS=\"contract_norm_prct\" NAME=\"rmm_sl_price_prct\" ID=\"id_rmm_sl_price_prct\" VALUE=\"$v_rmm_sl_prct\" onchange=\"calc_price_from_percent()\">%
        <INPUT CLASS=\"contract_norm_value\" NAME=\"rmm_sl_price\" ID=\"id_rmm_sl_price\" VALUE=\"$v_rmm_sl\" onchange=\"calc_percent_from_price()\"></TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm\">TP</TD>
    <TD><INPUT CLASS=\"contract_norm_prct\" NAME=\"rmm_tp_price_prct\" ID=\"id_rmm_tp_price_prct\" VALUE=\"$v_rmm_tp_prct\" onchange=\"calc_price_from_percent()\">%
        <INPUT CLASS=\"contract_norm_value\" NAME=\"rmm_tp_price\" ID=\"id_rmm_tp_price\" VALUE=\"$v_rmm_tp\" onchange=\"calc_percent_from_price()\"></TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm\">цель</TD>
    <TD><INPUT CLASS=\"contract_norm_prct\" NAME=\"rmm_target_price_prct\" ID=\"id_rmm_target_price_prct\" VALUE=\"$v_rmm_tgt_prct\" onchange=\"calc_price_from_percent()\">%
        <INPUT CLASS=\"contract_norm_value\" NAME=\"rmm_target_price\" ID=\"id_rmm_target_price\" VALUE=\"$v_rmm_tgt\" onchange=\"calc_percent_from_price()\"></TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm\">R/R</TD>
    <TD><INPUT CLASS=\"contract_norm_rr\" NAME=\"rmm_risk\" ID=\"id_rmm_risk\" VALUE=\"$v_rmm_risk\">&nbsp;/&nbsp;
        <INPUT CLASS=\"contract_norm_rr\" NAME=\"rmm_reward\" ID=\"id_rmm_reward\" VALUE=\"$v_rmm_revard\"></TD>
    </TR>

<TR><TD COLSPAN=\"3\" CLASS=\"contract_delim\">Вход в сделку</TD><TD COLSPAN=\"10\"><HR CLASS=\"contract_delim\"></TD></TR>
<TR><TD CLASS=\"contract_norm\">основание</TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD COLSPAN=\"8\">
        <SELECT CLASS=\"contract_in_out_base\" name=\"input_base\" ID=\"id_input_base\">" ;
$sz_curr_key = "" ; foreach (@states_base_inout) { $sz_curr_key = $_ ; $is_selected = "" ; if ( $v_input_base eq $sz_curr_key ) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$sz_curr_key\" $is_selected>$states_base_inout{$sz_curr_key}</OPTION>" ; }
print "</SELECT>
    </TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm\">event ID</TD><TD><INPUT CLASS=\"contract_norm\" NAME=\"input_event_id\" ID=\"id_input_event_id\" VALUE=\"$v_input_event_rand_id\"></TD>
    </TR>

<TR><TD CLASS=\"contract_norm\">детализация</TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm\">дата</TD><TD><INPUT CLASS=\"contract_norm_date\" NAME=\"input_date\" ID=\"id_input_date\" VALUE=\"$v_input_time_point\"></TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm\">цена</TD><TD><INPUT CLASS=\"contract_norm\" NAME=\"input_price\" ID=\"id_input_price\" VALUE=\"$v_input_price\"></TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm\">объём</TD>
    <TD><INPUT CLASS=\"contract_norm_volume\" NAME=\"input_volume\" ID=\"id_input_volume\" VALUE=\"$v_input_volume\"></TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm\">сумма</TD><TD><INPUT CLASS=\"contract_norm\" NAME=\"input_summ\" ID=\"id_input_summ\" VALUE=\"$v_input_summ\"></TD>
    </TR>" ;

print "<TR><TD COLSPAN=\"3\" CLASS=\"contract_delim\">Индикаторы входа</TD><TD COLSPAN=\"10\"><HR CLASS=\"contract_delim\"></TD></TR>
<TR><TD CLASS=\"contract_ind_top\">тек./стрш.</TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_ind_top\">EMA</TD>
    <TD COLSPAN=\"5\">
        <SELECT CLASS=\"contract_ind_tf\" name=\"ind_curr_ema_tf\" ID=\"id_ind_curr_ema_tf\">" ;
$sz_curr_key = "" ; foreach (@tf_list) { $sz_curr_key = $_ ; $is_selected = "" ; if ( $v_ind_curr_ema_tf eq $sz_curr_key ) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$sz_curr_key\" $is_selected>$tf_list{$sz_curr_key}</OPTION>" ; }
print "</SELECT>&nbsp;<SELECT CLASS=\"contract_ind_value\" name=\"ind_curr_ema\" ID=\"id_ind_curr_ema\">" ;
$sz_curr_key = "" ; foreach (@states_ema) { $sz_curr_key = $_ ; $is_selected = "" ; if ( $v_ind_curr_ema eq $sz_curr_key ) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$sz_curr_key\" $is_selected>$states_ema{$sz_curr_key}</OPTION>" ; }
print " </SELECT>&nbsp;
        </TD>
    <TD CLASS=\"contract_ind_top\">EMA</TD>
    <TD COLSPAN=\"5\">
        <SELECT CLASS=\"contract_ind_tf\" name=\"ind_own_ema_tf\" ID=\"id_ind_own_ema_tf\">" ;
$sz_curr_key = "" ; foreach (@tf_list) { $sz_curr_key = $_ ; $is_selected = "" ; if ( $v_ind_own_ema_tf eq $sz_curr_key ) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$sz_curr_key\" $is_selected>$tf_list{$sz_curr_key}</OPTION>" ; }
print " </SELECT>&nbsp;<SELECT CLASS=\"contract_ind_value\" name=\"ind_own_ema\" ID=\"id_ind_own_ema\">" ;
$sz_curr_key = "" ; foreach (@states_ema) { $sz_curr_key = $_ ; $is_selected = "" ; if ( $v_ind_own_ema eq $sz_curr_key ) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$sz_curr_key\" $is_selected>$states_ema{$sz_curr_key}</OPTION>" ; }
print " </SELECT>&nbsp;
        </TD></TR>

<TR><TD CLASS=\"contract_ind_top\">тек./стрш.</TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_ind_top\">Цена</TD>
    <TD COLSPAN=\"5\">
        <SELECT CLASS=\"contract_ind_tf\" name=\"ind_curr_price_tf\" ID=\"id_ind_curr_price_tf\">" ;
$sz_curr_key = "" ; foreach (@tf_list) { $sz_curr_key = $_ ; $is_selected = "" ; if ( $v_ind_curr_price_tf eq $sz_curr_key ) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$sz_curr_key\" $is_selected>$tf_list{$sz_curr_key}</OPTION>" ; }
print " </SELECT>&nbsp;<SELECT CLASS=\"contract_ind_value\" name=\"ind_curr_price\" ID=\"id_ind_curr_price\">" ;
$sz_curr_key = "" ; foreach (@states_price) { $sz_curr_key = $_ ; $is_selected = "" ; if ( $v_ind_curr_price eq $sz_curr_key ) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$sz_curr_key\" $is_selected>$states_price{$sz_curr_key}</OPTION>" ; }
print " </SELECT>&nbsp;
        </TD>
    <TD CLASS=\"contract_ind_top\">Цена</TD>
    <TD COLSPAN=\"5\">
        <SELECT CLASS=\"contract_ind_tf\" name=\"ind_own_price_tf\" ID=\"id_ind_own_price_tf\">" ;
$sz_curr_key = "" ; foreach (@tf_list) { $sz_curr_key = $_ ; $is_selected = "" ; if ( $v_ind_own_price_tf eq $sz_curr_key ) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$sz_curr_key\" $is_selected>$tf_list{$sz_curr_key}</OPTION>" ; }
print " </SELECT>&nbsp;<SELECT CLASS=\"contract_ind_value\" name=\"ind_own_price\" ID=\"id_ind_own_price\">" ;
$sz_curr_key = "" ; foreach (@states_price) { $sz_curr_key = $_ ; $is_selected = "" ; if ( $v_ind_own_price eq $sz_curr_key ) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$sz_curr_key\" $is_selected>$states_price{$sz_curr_key}</OPTION>" ; }
print " </SELECT>&nbsp;
        </TD></TR>

<TR><TD CLASS=\"contract_ind_top\">тек./стрш.</TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_ind_top\">MACDln</TD>
    <TD COLSPAN=\"5\">
        <SELECT CLASS=\"contract_ind_tf\" name=\"ind_curr_macd_line_tf\" ID=\"id_ind_curr_macd_line_tf\">" ;
$sz_curr_key = "" ; foreach (@tf_list) { $sz_curr_key = $_ ; $is_selected = "" ; if ( $v_ind_curr_macd_line_tf eq $sz_curr_key ) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$sz_curr_key\" $is_selected>$tf_list{$sz_curr_key}</OPTION>" ; }
print " </SELECT>&nbsp;<SELECT CLASS=\"contract_ind_value\" name=\"ind_curr_macd_line\" ID=\"id_ind_curr_macd_line\">" ;
$sz_curr_key = "" ; foreach (@states_macd_line) { $sz_curr_key = $_ ; $is_selected = "" ; if ( $v_ind_curr_macd_line eq $sz_curr_key ) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$sz_curr_key\" $is_selected>$states_macd_line{$sz_curr_key}</OPTION>" ; }
print " </SELECT>&nbsp;
        </TD>
    <TD CLASS=\"contract_ind_top\">MACDln</TD>
    <TD COLSPAN=\"5\">
        <SELECT CLASS=\"contract_ind_tf\" name=\"ind_own_macd_line_tf\" ID=\"id_ind_own_macd_line_tf\">" ;
$sz_curr_key = "" ; foreach (@tf_list) { $sz_curr_key = $_ ; $is_selected = "" ; if ( $v_ind_own_macd_line_tf eq $sz_curr_key ) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$sz_curr_key\" $is_selected>$tf_list{$sz_curr_key}</OPTION>" ; }
print " </SELECT>&nbsp;<SELECT CLASS=\"contract_ind_value\" name=\"ind_own_macd_line\" ID=\"id_ind_own_macd_line\">" ;
$sz_curr_key = "" ; foreach (@states_macd_line) { $sz_curr_key = $_ ; $is_selected = "" ; if ( $v_ind_own_macd_line eq $sz_curr_key ) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$sz_curr_key\" $is_selected>$states_macd_line{$sz_curr_key}</OPTION>" ; }
print " </SELECT>&nbsp;
        </TD></TR>

<TR><TD CLASS=\"contract_ind_top\">тек./стрш.</TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_ind_top\">MACDgs</TD>
    <TD COLSPAN=\"5\">
        <SELECT CLASS=\"contract_ind_tf\" name=\"ind_curr_macd_gist_tf\" ID=\"id_ind_curr_macd_gist_tf\">" ;
$sz_curr_key = "" ; foreach (@tf_list) { $sz_curr_key = $_ ; $is_selected = "" ; if ( $v_ind_curr_macd_gist_tf eq $sz_curr_key ) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$sz_curr_key\" $is_selected>$tf_list{$sz_curr_key}</OPTION>" ; }
print " </SELECT>&nbsp;<SELECT CLASS=\"contract_ind_value\" name=\"ind_curr_macd_gist\" ID=\"id_ind_curr_macd_gist\">" ;
$sz_curr_key = "" ; foreach (@states_macd_gist) { $sz_curr_key = $_ ; $is_selected = "" ; if ( $v_ind_curr_macd_gist eq $sz_curr_key ) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$sz_curr_key\" $is_selected>$states_macd_gist{$sz_curr_key}</OPTION>" ; }
print " </SELECT>&nbsp;
        </TD>
    <TD CLASS=\"contract_ind_top\">MACDgs</TD>

    <TD COLSPAN=\"5\">
        <SELECT CLASS=\"contract_ind_tf\" name=\"ind_own_macd_gist_tf\" ID=\"id_ind_own_macd_gist_tf\">" ;
$sz_curr_key = "" ; foreach (@tf_list) { $sz_curr_key = $_ ; $is_selected = "" ; if ( $v_ind_own_macd_gist_tf eq $sz_curr_key ) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$sz_curr_key\" $is_selected>$tf_list{$sz_curr_key}</OPTION>" ; }
print " </SELECT>&nbsp;<SELECT CLASS=\"contract_ind_value\" name=\"ind_own_macd_gist\" ID=\"id_ind_own_macd_gist\">" ;
$sz_curr_key = "" ; foreach (@states_macd_gist) { $sz_curr_key = $_ ; $is_selected = "" ; if ( $v_ind_own_macd_gist eq $sz_curr_key ) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$sz_curr_key\" $is_selected>$states_macd_gist{$sz_curr_key}</OPTION>" ; }
print " </SELECT>&nbsp;

        </TD></TR>

<TR><TD CLASS=\"contract_ind_top\">тек./стрш.</TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_ind_top\">RSI</TD>
    <TD COLSPAN=\"5\">
        <SELECT CLASS=\"contract_ind_tf\" name=\"ind_curr_rsi_tf\" ID=\"id_ind_curr_rsi_tf\">" ;
$sz_curr_key = "" ; foreach (@tf_list) { $sz_curr_key = $_ ; $is_selected = "" ; if ( $v_ind_curr_rsi_tf eq $sz_curr_key ) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$sz_curr_key\" $is_selected>$tf_list{$sz_curr_key}</OPTION>" ; }
print " </SELECT>&nbsp;<SELECT CLASS=\"contract_ind_value\" name=\"ind_curr_rsi\" ID=\"id_ind_curr_rsi\">" ;
$sz_curr_key = "" ; foreach (@states_rsi) { $sz_curr_key = $_ ; $is_selected = "" ; if ( $v_ind_curr_rsi eq $sz_curr_key ) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$sz_curr_key\" $is_selected>$states_rsi{$sz_curr_key}</OPTION>" ; }
print " </SELECT>&nbsp;
        </TD>
    <TD CLASS=\"contract_ind_top\">RSI</TD>
    <TD COLSPAN=\"5\">
        <SELECT CLASS=\"contract_ind_tf\" name=\"ind_own_rsi_tf\" ID=\"id_ind_own_rsi_tf\">" ;
$sz_curr_key = "" ; foreach (@tf_list) { $sz_curr_key = $_ ; $is_selected = "" ; if ( $v_ind_own_rsi_tf eq $sz_curr_key ) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$sz_curr_key\" $is_selected>$tf_list{$sz_curr_key}</OPTION>" ; }
print " </SELECT>&nbsp;<SELECT CLASS=\"contract_ind_value\" name=\"ind_own_rsi\" ID=\"id_ind_own_rsi\">" ;
$sz_curr_key = "" ; foreach (@states_rsi) { $sz_curr_key = $_ ; $is_selected = "" ; if ( $v_ind_own_rsi eq $sz_curr_key ) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$sz_curr_key\" $is_selected>$states_rsi{$sz_curr_key}</OPTION>" ; }
print " </SELECT>&nbsp;
        </TD></TR>


<TR><TD COLSPAN=\"3\" CLASS=\"contract_delim\">Выход из сделки</TD><TD COLSPAN=\"10\"><HR CLASS=\"contract_delim\"></TD></TR>
<TR><TD CLASS=\"contract_norm\">основание</TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD COLSPAN=\"8\">
        <SELECT CLASS=\"contract_in_out_base\" name=\"output_base\" ID=\"id_output_base\">" ;
$sz_curr_key = "" ; foreach (@states_base_inout) { $sz_curr_key = $_ ; $is_selected = "" ; if ( "_$v_output_base" eq "_$sz_curr_key" ) { $is_selected = "SELECTED" ; } print "<OPTION VALUE=\"$sz_curr_key\" $is_selected>$states_base_inout{$sz_curr_key}</OPTION>" ; }
print " </SELECT>
    </TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm\">event ID</TD><TD><INPUT CLASS=\"contract_norm\" NAME=\"output_event_id\" ID=\"id_output_event_id\" VALUE=\"$v_output_event_rand_id\"></TD>
    </TR>

<TR><TD CLASS=\"contract_norm\">детализация</TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm\">дата</TD><TD><INPUT CLASS=\"contract_norm_date\" NAME=\"output_date\" ID=\"id_output_date\" VALUE=\"$v_output_time_point\"></TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm\">цена</TD><TD><INPUT CLASS=\"contract_norm\" NAME=\"output_price\" ID=\"id_output_price\" VALUE=\"$v_output_price\"></TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm\">объём</TD>
    <TD><INPUT CLASS=\"contract_norm_volume\" NAME=\"output_volume\" ID=\"id_output_volume\" VALUE=\"$v_output_volume\"></TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm\">сумма</TD><TD><INPUT CLASS=\"contract_norm\" NAME=\"output_summ\" ID=\"id_output_summ\" VALUE=\"$v_output_summ\"></TD>
    </TR>

<TR><TD COLSPAN=\"3\" CLASS=\"contract_delim\">Результат</TD><TD COLSPAN=\"10\"><HR CLASS=\"contract_delim\"></TD></TR>
<TR><TD CLASS=\"contract_norm_purple\">последняя</TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm_purple\">дата</TD><TD CLASS=\"contract_norm_purple\"><INPUT CLASS=\"contract_norm_date_purple\" NAME=\"last_date\" ID=\"id_last_date\" VALUE=\"$v_last_time_point\" DISABLED></TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm_purple\">цена</TD><TD CLASS=\"contract_norm_purple\"><INPUT CLASS=\"contract_norm_purple\" NAME=\"last_price\" ID=\"id_last_price\" VALUE=\"$v_last_price\" DISABLED></TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm_purple\">объём</TD>
    <TD CLASS=\"contract_norm_purple\"><INPUT CLASS=\"contract_norm_purple_volume\" NAME=\"last_volume\" ID=\"id_last_volume\" VALUE=\"$v_last_volume\" DISABLED></TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm_purple\">сумма</TD><TD CLASS=\"contract_norm_purple\"><INPUT CLASS=\"contract_norm_purple\" NAME=\"last_summ\" ID=\"id_last_summ\" VALUE=\"$v_last_summ\" DISABLED></TD>
    </TR>

<TR><TD CLASS=\"contract_norm_purple\">текущ. рез.</TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm_purple\">%</TD><TD CLASS=\"contract_norm_purple\"><INPUT CLASS=\"contract_norm_date_purple\" NAME=\"prognoze_percent\" ID=\"id_prognoze_date\" VALUE=\"$v_prognoze_percent\" STYLE=\"color: $v_prognoze_result_color;\" DISABLED></TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm_purple\">цена</TD><TD CLASS=\"contract_norm_purple\"><INPUT CLASS=\"contract_norm_purple\" NAME=\"prognoze_price\" ID=\"id_prognoze_price\" VALUE=\"$v_last_price\" STYLE=\"color: $v_prognoze_result_color;\" DISABLED></TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm_purple\">объём</TD>
    <TD CLASS=\"contract_norm_purple\"><INPUT CLASS=\"contract_norm_purple_volume\" NAME=\"prognoze_volume\" ID=\"id_prognoze_volume\" VALUE=\"$v_prognoze_volume\" STYLE=\"color: $v_prognoze_result_color;\" DISABLED></TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm_purple\">сумма</TD><TD CLASS=\"contract_norm_purple\"><INPUT CLASS=\"contract_norm_purple\" NAME=\"prognoze_summ\" ID=\"id_prognoze_summ\" VALUE=\"$v_prognoze_summ\" STYLE=\"color: $v_prognoze_result_color;\" DISABLED></TD>
    </TR>

<TR><TD CLASS=\"contract_norm\">результат</TD>
    <TD CLASS=\"contract_norm\">&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm\">%</TD><TD><INPUT CLASS=\"contract_norm\" NAME=\"result_percent\" ID=\"id_result_percent\" VALUE=\"$v_result_percent\" STYLE=\"color: $v_result_color;\" DISABLED></TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm\">цена</TD><TD><INPUT CLASS=\"contract_norm\" NAME=\"result_price\" ID=\"id_result_price\" VALUE=\"$v_result_price\" STYLE=\"color: $v_result_color;\" DISABLED></TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm\">объём</TD><TD><INPUT CLASS=\"contract_norm_volume\" NAME=\"result_volume\" ID=\"id_result_volume\" VALUE=\"$v_result_volume\" STYLE=\"color: $v_result_color;\" DISABLED></TD>
    <TD>&nbsp;&nbsp;&nbsp;</TD>
    <TD CLASS=\"contract_norm\">сумма</TD><TD><INPUT CLASS=\"contract_norm\" NAME=\"result_summ\" ID=\"id_result_summ\" VALUE=\"$v_result_summ\" STYLE=\"color: $v_result_color;\" DISABLED></TD>
    </TR>


<TR><TD COLSPAN=\"3\" CLASS=\"contract_delim\">Дополнения</TD><TD COLSPAN=\"10\"><HR CLASS=\"contract_delim\"></TD></TR>
<TR><TD COLSPAN=\"13\" CLASS=\"contract_norm_top\">заметки/комментарии<BR>
        <TEXTAREA CLASS=\"contract_norm_textarea\" NAME=\"contract_comments\" ID=\"id_contract_comments\" WRAP=\"soft\" STYLE=\"white-space: pre-wrap;\" VALUE=\"$v_contract_comments\">$v_contract_comments</TEXTAREA></TD>
    </TR>


<TR><TD COLSPAN=\"4\" CLASS=\"contract_delim\">Графики входа и выхода</TD><TD COLSPAN=\"9\"><HR CLASS=\"contract_delim\"></TD></TR>
<TR><TD COLSPAN=\"13\" CLASS=\"contract_norm_top\">
<TABLE STYLE=\"width: 100%;\">
<TR><TD CLASS=\"td_head\">Вход текущий ТФ</TD><TD CLASS=\"td_head\">Вход старший ТФ</TD><TD CLASS=\"td_head\">Выход текущий ТФ</TD><TD CLASS=\"td_head\">Выход старший ТФ</TD></TR>

</TABLE>
</TD></TR>


</TABLE>
<!-- конец версточной таблицы одной сделки -->
</FORM>" ;
    }

sub print_js_block_contracts() {
    print "<SCRIPT LANGUAGE=\"JavaScript\">

async function contracts_form_redraw(v_user_name, v_user_id, v_action, v_id_elem, v_id, v_rand_id, v_status, v_leverage, v_cycle, v_currency, v_reference_currency, v_vector, v_rmm_sl_prct, v_rmm_sl, v_rmm_tp_prct,
 v_rmm_tp, v_rmm_tgt_prct, v_rmm_tgt, v_rmm_risk, v_rmm_revard, v_input_base, v_input_event_rand_id, v_input_time_point, v_input_price, v_input_volume, v_input_summ,
 v_ind_curr_ema_tf, v_ind_curr_ema, v_ind_own_ema_tf, v_ind_own_ema, v_ind_curr_price_tf, v_ind_curr_price, v_ind_own_price_tf, v_ind_own_price,
 v_ind_curr_macd_line_tf, v_ind_curr_macd_line, v_ind_own_macd_line_tf, v_ind_own_macd_line, v_ind_curr_macd_gist_tf, v_ind_curr_macd_gist, v_ind_own_macd_gist_tf, v_ind_own_macd_gist,
 v_ind_curr_rsi_tf, v_ind_curr_rsi, v_ind_own_rsi_tf, v_ind_own_rsi, v_output_base, v_output_event_rand_id, v_output_time_point, v_output_price, v_output_volume, v_output_summ,
 v_result_percent, v_result_price, v_result_volume, v_result_summ, v_contract_comments) {

v_contract_comments = v_contract_comments.replaceAll(\"\\n\",\"<BR>\") ;

      var url=\"https://zrt.ourorbits.ru/cgi/_ajax_for_contract_redraw.cgi?user_name=\" + v_user_name + \"&user_id=\" + v_user_id + \"&action=\" + v_action + \"&id_element=\" + v_id_elem + \"&id=\" + v_id + \"&rand_id=\" + v_rand_id +
 \"&status=\" + v_status + \"&leverage=\" + v_leverage + \"&cycle=\" + v_cycle + \"&currency=\" + v_currency + \"&reference_currency=\" + v_reference_currency + \"&vector=\" + v_vector +
 \"&rmm_sl=\" + v_rmm_sl + \"&rmm_sl_prct=\" + v_rmm_sl_prct + \"&rmm_tp=\" + v_rmm_tp + \"&rmm_tp_prct=\" + v_rmm_tp_prct + \"&rmm_tgt=\" + v_rmm_tgt + \"&rmm_tgt_prct=\" + v_rmm_tgt_prct +
 \"&rmm_risk=\" + v_rmm_risk + \"&rmm_revard=\" + v_rmm_revard +
 \"&input_time_point=\" + v_input_time_point + \"&input_price=\" + v_input_price + \"&input_volume=\" + v_input_volume + \"&input_summ=\" + v_input_summ + \"&input_base=\" + v_input_base +
 \"&input_event_rand_id=\" + v_input_event_rand_id + \"&ind_curr_ema=\" + v_ind_curr_ema + \"&ind_curr_ema_tf=\" + v_ind_curr_ema_tf + \"&ind_curr_price=\" + v_ind_curr_price + \"&ind_curr_price_tf=\" + v_ind_curr_price_tf +
 \"&ind_curr_macd_line=\" + v_ind_curr_macd_line + \"&ind_curr_macd_line_tf=\" + v_ind_curr_macd_line_tf + \"&ind_curr_macd_gist=\" + v_ind_curr_macd_gist + \"&ind_curr_macd_gist_tf=\" + v_ind_curr_macd_gist_tf +
 \"&ind_curr_rsi=\" + v_ind_curr_rsi + \"&ind_curr_rsi_tf=\" + v_ind_curr_rsi_tf + \"&ind_own_ema_tf=\" + v_ind_own_ema_tf + \"&ind_own_ema=\" + v_ind_own_ema + \"&ind_own_price_tf=\" + v_ind_own_price_tf +
 \"&ind_own_price=\" + v_ind_own_price + \"&ind_own_macd_line_tf=\" + v_ind_own_macd_line_tf + \"&ind_own_macd_line=\" + v_ind_own_macd_line + \"&ind_own_macd_gist_tf=\" + v_ind_own_macd_gist_tf +
 \"&ind_own_macd_gist=\" + v_ind_own_macd_gist + \"&ind_own_rsi_tf=\" + v_ind_own_rsi_tf + \"&ind_own_rsi=\" + v_ind_own_rsi + \"&output_base=\" + v_output_base + \"&output_event_rand_id=\" + v_output_event_rand_id +
 \"&output_time_point=\" + v_output_time_point + \"&output_price=\" + v_output_price + \"&output_volume=\" + v_output_volume + \"&output_summ=\" + v_output_summ +
 \"&result_percent=\" + v_result_percent + \"&result_price=\" + v_result_price + \"&result_volume=\" + v_result_volume + \"&result_summ=\" + v_result_summ + \"&contract_comments=\" + v_contract_comments ;

      //alert(url) ;
      document.all(v_id_elem).innerHTML=\"Loading...\"
      document.all(v_id_elem).innerHTML=await(await fetch(url)).text();
      }

// функция выставляет переменные таймфрэймов индикаторов при смене цикла
// в будущем намереваем также автоматически заполнять здесь последние значения индикаторов для выбранных таймфрэймов - методом старта перерисовки всего блока
function set_contract_cycle() {
         //alert(document.all('id_cycle_type').value);
         //alert(id_cycle_type.value);
         if ( id_cycle_type.value == 'days' ) {
            id_ind_curr_ema_tf.value = '1H' ;
            id_ind_own_ema_tf.value = '1D' ;
            id_ind_curr_price_tf.value = '1H' ;
            id_ind_own_price_tf.value = '1D' ;
            id_ind_curr_macd_line_tf.value = '4H' ;
            id_ind_own_macd_line_tf.value = '4D' ;
            id_ind_curr_macd_gist_tf.value = '4H' ;
            id_ind_own_macd_gist_tf.value = '4D' ;
            id_ind_curr_rsi_tf.value = '10M' ;
            id_ind_own_rsi_tf.value = '1H' ;
            }
         if ( id_cycle_type.value == 'hours' ) {
            id_ind_curr_ema_tf.value = '10M' ;
            id_ind_own_ema_tf.value = '1H' ;
            id_ind_curr_price_tf.value = '10M' ;
            id_ind_own_price_tf.value = '1H' ;
            id_ind_curr_macd_line_tf.value = '30M' ;
            id_ind_own_macd_line_tf.value = '4H' ;
            id_ind_curr_macd_gist_tf.value = '30M' ;
            id_ind_own_macd_gist_tf.value = '4H' ;
            id_ind_curr_rsi_tf.value = '5M' ;
            id_ind_own_rsi_tf.value = '10M' ;
            }
         }

// функция меняет цвет монет, цикла и направления, но для работы при обновлении формы нужен функционал и там
function set_contract_vector() {
         //alert(document.all('id_cycle_type').value);
         //alert(id_cycle_type.value);
         if ( id_vector.value == 'long' ) {
            id_cycle_type.style.color = 'green' ;
            id_currency.style.color = 'green' ;
            id_curr_reference.style.color = 'green' ;
            id_vector.style.color = 'green' ;
            id_coin_big_td.style.color = 'green' ;
            }
         if ( id_vector.value == 'short' ) {
            id_cycle_type.style.color = 'red' ;
            id_currency.style.color = 'red' ;
            id_curr_reference.style.color = 'red' ;
            id_vector.style.color = 'red' ;
            id_coin_big_td.style.color = 'red' ;
            }
         }

// калькуляторы - цена по процентам
function calc_price_from_percent() {
         if ( id_input_price.value > 0) {
            if (id_vector.value == 'long') {
               if ( id_rmm_sl_price_prct.value > 0 ) { id_rmm_sl_price.value = (id_input_price.value * (1 - (id_rmm_sl_price_prct.value / 100))) ; id_rmm_risk.value = id_rmm_sl_price_prct.value ; }
               if ( id_rmm_tp_price_prct.value > 0 ) { id_rmm_tp_price.value = (id_input_price.value * (1 + (id_rmm_tp_price_prct.value / 100))) ; id_rmm_reward.value = id_rmm_tp_price_prct.value ; }
               if ( id_rmm_target_price_prct.value > 0 ) { id_rmm_target_price.value = (id_input_price.value * (1 + (id_rmm_target_price_prct.value / 100))) ; }
               }
            if (id_vector.value == 'short') {
               if ( id_rmm_sl_price_prct.value > 0 ) { id_rmm_sl_price.value = (id_input_price.value * (1 + (id_rmm_sl_price_prct.value / 100))) ; id_rmm_risk.value = id_rmm_sl_price_prct.value ; }
               if ( id_rmm_tp_price_prct.value > 0 ) { id_rmm_tp_price.value = (id_input_price.value * (1 - (id_rmm_tp_price_prct.value / 100))) ; id_rmm_reward.value = id_rmm_tp_price_prct.value ; }
               if ( id_rmm_target_price_prct.value > 0 ) { id_rmm_target_price.value = (id_input_price.value * (1 - (id_rmm_target_price_prct.value / 100))) ; }
               }
            }
         }

// калькуляторы - проценты по цене
function calc_percent_from_price() {
         if ( id_input_price.value > 0) {
            if (id_vector.value == 'long') {
               if ( id_rmm_sl_price.value > 0 ) { id_rmm_sl_price_prct.value = ((id_input_price.value - id_rmm_sl_price.value) / (id_input_price.value / 100)) ; id_rmm_sl_price_prct.value = id_rmm_sl_price_prct.value.toFixed(2) ; id_rmm_risk.value = id_rmm_sl_price_prct.value ; }
               if ( id_rmm_tp_price.value > 0 ) { id_rmm_tp_price_prct.value = ((id_rmm_tp_price.value - id_input_price.value) / (id_input_price.value / 100)) ; id_rmm_tp_price_prct.value = id_rmm_tp_price_prct.value.toFixed(2) ; id_rmm_reward.value = id_rmm_tp_price_prct.value ; }
               if ( id_rmm_target_price.value > 0 ) { id_rmm_target_price_prct.value = ((id_rmm_target_price.value - id_input_price.value) / (id_input_price.value / 100)) ; }
               }
            if (id_vector.value == 'short') {
               if ( id_rmm_sl_price.value > 0 ) { id_rmm_sl_price_prct.value = ((id_rmm_sl_price.value - id_input_price.value) / (id_input_price.value / 100)) ; id_rmm_sl_price_prct.value = id_rmm_sl_price_prct.value.toFixed(2) ; id_rmm_risk.value = id_rmm_sl_price_prct.value ; }
               if ( id_rmm_tp_price.value > 0 ) { id_rmm_tp_price_prct.value = ((id_input_price.value - id_rmm_tp_price.value) / (id_input_price.value / 100)) ; id_rmm_tp_price_prct.value = id_rmm_tp_price_prct.value.toFixed(2) ; id_rmm_reward.value = id_rmm_tp_price_prct.value ; }
               if ( id_rmm_target_price.value > 0 ) { id_rmm_target_price_prct.value = ((id_input_price.value - id_rmm_target_price.value) / (id_input_price.value / 100)) ; }
               }
            }
         }

</SCRIPT>\n" ;
    }

sub print_tools_contracts_navigation($) { $active_tab{1} = "" ; $active_tab{2} = "" ; $active_tab{3} = "" ; $active_tab{4} = "" ; $active_tab{5} = "" ; ;
    $num_active_tab = $_[0] ; $active_tab{$num_active_tab} = " solid none solid" ;
    if ($pv{time_frame_ext} eq "") { $pv{time_frame_ext} = "10Mh" ; }
    print "<TABLE CELLSPACING=\"0\" CELLPADDING=\"0\" STYLE=\"border: 0pt none; width: 100%;\">
           <TR><TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{1}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_contracts.cgi?currency=ALL&curr_reference=$pv{curr_reference}&cnt_rand_id=$pv{cnt_rand_id}&action=open_contracts_list&user_name=$pv{user_name}&cntrct_status=$pv{cntrct_status}&cntrct_cycles=$pv{cntrct_cycles}\">Лента:&nbsp;Открытые&nbsp;сделки</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{2}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_contracts.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}&cnt_rand_id=$pv{cnt_rand_id}&action=clear&user_name=$pv{user_name}&cntrct_status=$pv{cntrct_status}&cntrct_cycles=$pv{cntrct_cycles}\">Карточка:&nbsp;Отдельная&nbsp;сделка</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
    
           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{3}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_contracts.cgi?currency=ALL&curr_reference=$pv{curr_reference}&cnt_rand_id=$pv{cnt_rand_id}&action=contracts_list&user_name=$pv{user_name}&cntrct_status=$pv{cntrct_status}&cntrct_cycles=$pv{cntrct_cycles}\">Лента:&nbsp;Все&nbsp;сделки</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
<!--
           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{4}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_contracts.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}&time_frame=1D&count_prds=$pv{count_1d_prds}&macd_mult=$pv{macd_mult}&env_prct=30\">Отчёты&nbsp;по&nbsp;сд
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
-->
           </TR></TABLE>" ;
    }


1
