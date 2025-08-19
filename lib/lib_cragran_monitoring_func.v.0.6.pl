#!/usr/bin/perl

# open source soft - (C) 2023 CrAgrAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

require "/var/www/crypta/cgi/common_parameter.cragregator" ;
require "$cragran_dir_lib/lib_common_func.pl" ;
require "$cragran_dir_lib/lib_cragran_common.pl" ;
require "$cragran_dir_lib/lib_cragran_trading.pl" ;
require "$cragran_dir_lib/lib_cragran_contracts.pl" ;
require "$cragran_dir_lib/lib_cragran_monitoring_func.pl" ;

# ----------------------------------------------------------------
# - функция формирует имена файлов графиков с монетами и датой в имени, формирует сами файлы графиков на текущий момент, и записывает ссылки на них в БД
# ----------------------------------------------------------------
sub create_graphs_add_event_to_db($$$$$$$$$$$$$) {
    my $v_event_name     = $_[0] ;
    my $v_sub_event_name = $_[1] ;
    my $v_datetime       = $_[2] ; $v_datetime =~ s/\s/_/g ; $v_datetime =~ s/://g ; $v_datetime =~ s/-//g ;
    my $v_main_currency  = $_[3] ;
    my $v_ref_currency   = $_[4] ;
    my $v_indicator      = $_[5] ;
    my $v_sub_indicator  = $_[6] ;
    my $v_time_frame     = $_[7] ;
    my $v_macd_tf        = $_[8] ;
    my $v_count_prds     = $_[9] ;
    my $v_message_string = $_[10] ;
    my $v_is_send_email  = $_[11] ;
    my $v_is_send_tlgrm  = $_[12] ;

    my $v_rand_id = rand() ; $v_rand_id =~ s/\.//g ;
    my $v_macd_count_prds = recode_tf_periods($v_time_frame,$v_macd_tf,$v_count_prds) ;

    $GRAPH_FILE_ONLY_NAME_EMA  = "event_".$v_rand_id."_graph_OHLCV_EMA_ENV_BL_".$v_time_frame."_".$v_main_currency."_".$v_ref_currency."_".$v_datetime.".png" ; $GRAPH_NAME_EMA  ="$cragran_dir_img_events/$GRAPH_FILE_ONLY_NAME_EMA" ;
    $GRAPH_FILE_ONLY_NAME_MACD = "event_".$v_rand_id."_graph_MACD_TV_".$v_macd_tf."_".$v_main_currency."_".$v_ref_currency."_".$v_datetime.".png" ;             $GRAPH_NAME_MACD ="$cragran_dir_img_events/$GRAPH_FILE_ONLY_NAME_MACD" ;
    $GRAPH_FILE_ONLY_NAME_RSI  = "event_".$v_rand_id."_graph_RSI_TV_".$v_time_frame."_".$v_main_currency."_".$v_ref_currency."_".$v_datetime.".png" ;           $GRAPH_NAME_RSI  ="$cragran_dir_img_events/$GRAPH_FILE_ONLY_NAME_RSI" ;
    $GRAPH_FILE_ONLY_NAME_VLT  = "event_".$v_rand_id."_graph_VLT_WNDW_".$v_time_frame."_".$v_main_currency."_".$v_ref_currency."_".$v_datetime.".png" ;         $GRAPH_NAME_VLT  ="$cragran_dir_img_events/$GRAPH_FILE_ONLY_NAME_VLT" ;

    $SQL_FILE_ONLY_NAME = "event_".$v_rand_id."_add_to_db_".$v_main_currency."_".$v_ref_currency."_".$v_indicator."_".$v_sub_indicator."_".$v_time_frame."_".$v_datetime.".sql" ;  $SQL_FILE_NAME="$cragran_dir_tmp/$SQL_FILE_ONLY_NAME" ;

# подразумевается, что файл журналирования LOG открыт для записи
    print LOG "$log_prefix - create_graphs_add_event_to_db START\n" ;
    print LOG "$log_prefix - create_graphs_add_event_to_db переменные:
$log_prefix --- v_event_name = $v_event_name
$log_prefix --- v_sub_event_name = $v_sub_event_name
$log_prefix --- v_datetime = $v_datetime
$log_prefix --- v_main_currency = $v_main_currency
$log_prefix --- v_ref_currency = $v_ref_currency
$log_prefix --- v_indicator = $v_indicator
$log_prefix --- v_sub_indicator = $v_sub_indicator
$log_prefix --- v_time_frame = $v_time_frame
$log_prefix --- v_macd_tf = $v_macd_tf
$log_prefix --- v_count_prds = $v_count_prds
$log_prefix --- v_message_string = $v_message_string
$log_prefix --- v_is_send_email = $v_is_send_email
$log_prefix --- v_is_send_tlgrm = $v_is_send_tlgrm
$log_prefix --- v_rand_id = $v_rand_id
$log_prefix --- v_macd_count_prds = $v_macd_count_prds
$log_prefix --- $GRAPH_FILE_ONLY_NAME_EMA $GRAPH_NAME_EMA
$log_prefix --- $GRAPH_FILE_ONLY_NAME_MACD $GRAPH_NAME_MACD
$log_prefix --- $GRAPH_FILE_ONLY_NAME_RSI $GRAPH_NAME_RSI
$log_prefix --- $GRAPH_FILE_ONLY_NAME_VLT $GRAPH_NAME_VLT
$log_prefix --- $SQL_FILE_ONLY_NAME\n" ;

    print LOG "$log_prefix --- старт блока формирования графиков события и рассылки уведомлений - формируются файлы\n" ;
    $TMP_BASH_FILE = "$cragran_dir_tmp/get_tmp_macd_graph".$v_rand_id.".bash" ;
    $QUERY_STRING  = "currency=$v_main_currency&curr_reference=$v_ref_currency&time_frame=$v_macd_tf&count_prds=$v_macd_count_prds&output_type=file&brush_size=4&x_size=1440&y_size=720&is_ema_periods=default&is_ema05=shadow&file_name=$GRAPH_NAME_MACD" ;
    `echo -e "export REQUEST_METHOD=\"GET\" ;\n export QUERY_STRING='$QUERY_STRING' ;\n /var/www/crypta/cgi/_graph_MACD_TV.cgi" > $TMP_BASH_FILE ; bash $TMP_BASH_FILE ;` ;

    $TMP_BASH_FILE = "$cragran_dir_tmp/get_tmp_ema_graph".$v_rand_id.".bash" ;
    $QUERY_STRING  = "currency=$v_main_currency&curr_reference=$v_ref_currency&time_frame=$v_time_frame&count_prds=$v_count_prds&env_prct=$env_prct&output_type=file&brush_size=4&x_size=1440&y_size=720&is_ema_periods=default&is_ema05=shadow&file_name=$GRAPH_NAME_EMA" ;
    `echo -e "export REQUEST_METHOD=\"GET\" ;\n export QUERY_STRING='$QUERY_STRING' ;\n /var/www/crypta/cgi/_graph_OHLCV_EMA_ENV_BL.cgi" > $TMP_BASH_FILE ; bash $TMP_BASH_FILE ;` ;

    $TMP_BASH_FILE = "$cragran_dir_tmp/get_tmp_rsi_graph".$v_rand_id.".bash" ;
    $QUERY_STRING  = "currency=$v_main_currency&curr_reference=$v_ref_currency&time_frame=$v_time_frame&count_prds=$v_count_prds&output_type=file&brush_size=4&x_size=1440&y_size=720&is_ema_periods=default&is_ema05=shadow&file_name=$GRAPH_NAME_RSI" ;
    `echo -e "export REQUEST_METHOD=\"GET\" ;\n export QUERY_STRING='$QUERY_STRING' ;\n /var/www/crypta/cgi/_graph_RSI_TV.cgi" > $TMP_BASH_FILE ; bash $TMP_BASH_FILE ;` ;

    $TMP_BASH_FILE = "$cragran_dir_tmp/get_tmp_vlt_graph".$v_rand_id.".bash" ;
    $QUERY_STRING  = "currency=$v_main_currency&curr_reference=$v_ref_currency&time_frame=$v_time_frame&count_prds=$v_count_prds&output_type=file&brush_size=4&x_size=1440&y_size=720&is_ema_periods=default&is_ema05=shadow&file_name=$GRAPH_NAME_VLT" ;
    `echo -e "export REQUEST_METHOD=\"GET\" ;\n export QUERY_STRING='$QUERY_STRING' ;\n /var/www/crypta/cgi/_graph_VLT_WNDW.cgi" > $TMP_BASH_FILE ; bash $TMP_BASH_FILE ;` ;

    print LOG "$log_prefix --- create_graphs_add_event_to_db - формируется и отрабатывает запрос в БД\n" ;
    my $sz_add_event_query = "insert into mon_events (event_rand_id, change_ts, currency, reference_currency, timestamp_point, event_name, event_vector, event_tf, event_indicator, event_sub_indicator)
       values ('$v_rand_id', now(), '$v_main_currency', '$v_ref_currency', now(), '$v_event_name', '$v_sub_event_name', '$v_time_frame', '$v_indicator', '$v_sub_indicator') ;\n
insert into mon_events_images (event_rand_id, change_ts, file_name, full_file_name, timestamp_point, ev_img_tf, ev_img_indicator, ev_img_sub_indicator)
       values('$v_rand_id', now(), '$GRAPH_FILE_ONLY_NAME_EMA','$GRAPH_NAME_EMA', now(), '$v_time_frame', '$v_indicator', '$v_sub_indicator') ;\n
insert into mon_events_images (event_rand_id, change_ts, file_name, full_file_name, timestamp_point, ev_img_tf, ev_img_indicator, ev_img_sub_indicator)
       values('$v_rand_id', now(), '$GRAPH_FILE_ONLY_NAME_MACD','$GRAPH_NAME_MACD', now(), '$v_time_frame', '$v_indicator', '$v_sub_indicator') ;\n
insert into mon_events_images (event_rand_id, change_ts, file_name, full_file_name, timestamp_point, ev_img_tf, ev_img_indicator, ev_img_sub_indicator)
       values('$v_rand_id', now(), '$GRAPH_FILE_ONLY_NAME_RSI','$GRAPH_NAME_RSI', now(), '$v_time_frame', '$v_indicator', '$v_sub_indicator') ;\n
insert into mon_events_images (event_rand_id, change_ts, file_name, full_file_name, timestamp_point, ev_img_tf, ev_img_indicator, ev_img_sub_indicator)
       values('$v_rand_id', now(), '$GRAPH_FILE_ONLY_NAME_VLT','$GRAPH_NAME_VLT', now(), '$v_time_frame', '$v_indicator', '$v_sub_indicator') ;\n
       " ;

    `echo "$sz_add_event_query" > $SQL_FILE_NAME ; export PGPASSWORD="cryptapwd" ; cat $SQL_FILE_NAME | psql -U crypta -h 127.0.0.1 -d crypta ; gzip $SQL_FILE_NAME` ;

    print LOG "$log_prefix --- create_graphs_add_event_to_db - проводится рассылка email, \$v_is_send_email = $v_is_send_email \n" ;
    if ( $v_is_send_email eq "yes_send" ) {
       $sz_message_email = $v_message_string ; $sz_message_email =~ s/<BR>/\n/g ;
       system("echo \"Уведомление $sz_message_email\" | mutt -s \"Уведомление $sz_message_email\" -a $GRAPH_NAME_MACD $GRAPH_NAME_EMA $GRAPH_NAME_RSI $GRAPH_NAME_VLT -- $mail_recipient_list") ;
       }

    print LOG "$log_prefix --- create_graphs_add_event_to_db - проводится рассылка telegram, \$v_is_send_tlgrm = $v_is_send_tlgrm\n" ;
    if ( $v_is_send_tlgrm eq "yes_send" ) {
       $sz_message_telegram = $v_message_string ;  $sz_message_telegram =~ s/<BR>/%0A/mg ; $sz_message_telegram =~ s/\s/%20/mg ;
#       @telegram_recipients = ('311883056', '452841999') ;
       foreach (@telegram_recipient_list) { my $curr_recipient = $_ ;
               system("curl -s -X POST \"https://api.telegram.org/botXXXXXXXXXX:key_key_key/sendMessage?chat_id=$curr_recipient&text=$sz_message_telegram\"") ;
               if ( $is_send_macd_graph eq "send" ) { `curl -s -X POST \"https://api.telegram.org/botXXXXXXXXXX:key_key_key/sendPhoto\" -F chat_id=\"$curr_recipient\" -F photo=\"\@$GRAPH_NAME_MACD\"` ; }
               if ( $is_send_ema_graph eq "send" ) { `curl -s -X POST \"https://api.telegram.org/botXXXXXXXXXX:key_key_key/sendPhoto\" -F chat_id=\"$curr_recipient\" -F photo=\"\@$GRAPH_NAME_EMA\"` ; }
               if ( $is_send_rsi_graph eq "send" ) { `curl -s -X POST \"https://api.telegram.org/botXXXXXXXXXX:key_key_key/sendPhoto\" -F chat_id=\"$curr_recipient\" -F photo=\"\@$GRAPH_NAME_RSI\"` ; }
               if ( $is_send_vlt_graph eq "send" ) { `curl -s -X POST \"https://api.telegram.org/botXXXXXXXXXX:key_key_key/sendPhoto\" -F chat_id=\"$curr_recipient\" -F photo=\"\@$GRAPH_NAME_VLT\"` ; }
               }
       }

    print LOG "$log_prefix - create_graphs_add_event_to_db STOP\n" ;
    }


# ----------------------------------------------------------------
# функция выявляет смену направления линии MACD по заполненным массивам
# ----------------------------------------------------------------
sub check_macd_lines_vector_change() {
    my $alert_file_vector_up_name = "macd_$pv{time_frame}_$pv{currency}_$pv{curr_reference}_vector_up.alert" ;
    my $alert_file_vector_up = "$alerts_spool_dir/$alert_file_vector_up_name" ;
    my $alert_history_file_vector_up = "$alerts_history_spool_dir/$alert_file_vector_up_name" ;
    my $is_exsist_alert_vector_up = `[ -f $alert_file_vector_up ] && echo "file_exist"` ; chomp($is_exsist_alert_vector_up) ; if ( $is_exsist_alert_vector_up ne "file_exist" ) {  $is_exsist_alert_vector_up = "no_file" ; }

    my $alert_file_vector_down_name = "macd_$pv{time_frame}_$pv{currency}_$pv{curr_reference}_vector_down.alert" ;
    my $alert_file_vector_down = "$alerts_spool_dir/$alert_file_vector_down_name" ;
    my $alert_history_file_vector_down = "$alerts_history_spool_dir/$alert_file_vector_down_name" ;
    my $is_exsist_alert_vector_down = `[ -f $alert_file_vector_down ] && echo "file_exist"` ; chomp($is_exsist_alert_vector_down) ; if ( $is_exsist_alert_vector_down ne "file_exist" ) { $is_exsist_alert_vector_down = "no_file" ; }

# флаг отправки взводится если файла уведомления ещё нет
    my $is_macd_vector_send = "no_send" ;
    my $sz_vector_values = "" ;
    my $sz_vector_change_value = "" ;
    my $sz_vector_find_change_value = "" ;

    $CURR_LOG_DATE = `date +"%Y-%m-%d %H:%M:%S"` ; $CURR_LOG_DATE =~ s/[\r\n]+//g ;
    if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) {
       printf(LOG "$log_prefix - check_macd_line_vector_change START\n") ;
       printf(LOG "$log_prefix - check_macd_lines_vector_change - основные переменные:
$log_prefix --- time_frame = $pv{time_frame}
$log_prefix --- currency = $pv{currency}
$log_prefix --- curr_reference = $pv{curr_reference}
$log_prefix --- alert_file_vector_up_name = $alert_file_vector_up_name
$log_prefix --- alert_file_vector_up = $alert_file_vector_up
$log_prefix --- alert_history_file_vector_up = $alert_history_file_vector_up
$log_prefix --- is_exsist_alert_vector_up = $is_exsist_alert_vector_up
$log_prefix --- alert_file_vector_down_name = $alert_file_vector_down_name
$log_prefix --- alert_file_vector_down = $alert_file_vector_down
$log_prefix --- alert_history_file_vector_down = $alert_history_file_vector_down
$log_prefix --- is_exsist_alert_vector_down = $is_exsist_alert_vector_down
$log_prefix --- is_macd_vector_send = $is_macd_vector_send
$log_prefix --- sz_vector_values = $sz_vector_values
$log_prefix --- sz_vector_change_value = $sz_vector_change_value
$log_prefix --- sz_vector_find_change_value = $sz_vector_find_change_value
$log_prefix --- предыдущий период = %f
$log_prefix --- текущий период = %f\n", $ds_end_diff_ema1226[$count_rows_post-3] - $ds_end_diff_ema1226[$count_rows_post-2],  $ds_end_diff_ema1226[$count_rows_post-2] - $ds_end_diff_ema1226[$count_rows_post-1]) ; }

# изменение вниз
# если предпоследняя дельта периодов была MACD меньше нуля, а последняя дельта периодов была больше нуля - произошла смена направления вниз
    $sz_vector_change_value = "DOWN" ;
    if (($ds_end_diff_ema1226[$count_rows_post-3] - $ds_end_diff_ema1226[$count_rows_post-2]) < 0 and ($ds_end_diff_ema1226[$count_rows_post-2] - $ds_end_diff_ema1226[$count_rows_post-1]) > 0) {
       $sz_vector_find_change_value = $sz_vector_change_value ;
       if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - блок выявления смены направления линий MACD - успешно выявлено изменение $sz_vector_change_value\n") ; }
# - если файла события нет - взвести флаг уведомления и добавления в БД
       if ( $is_exsist_alert_vector_down ne "file_exist" ) {
          $is_macd_vector_send = "yes_send" ;
          $sz_vector_values = sprintf("MACD_%s смена направления вниз %s/%s (%s)<BR>- https://www.coinglass.com/tv/Bybit_%s%s<BR>- https://zrt.ourorbits.ru/crypta/cgi/tools_coin_trading.cgi?currency=%s",
                                     $pv{time_frame}, $pv{currency}, $pv{curr_reference}, $ds_end_datetime_list[$count_rows_post-1], $pv{currency}, $pv{curr_reference}, $pv{currency}) ;
          if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - блок выявления смены направления линий MACD - файл события не найден, взведён флаг уведомления, сформирована строка уведомления\n$log_prefix --- is_macd_vector_send = $is_macd_vector_send\n$log_prefix --- sz_vector_values = $sz_vector_values\n") ; }
          }
       else { if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - блок выявления смены направления линий MACD - файл события найден, не отрабатываем добавление в БД и уведомление\n$log_prefix --- is_macd_vector_send = $is_macd_vector_send\n$log_prefix --- sz_vector_values = $sz_vector_values\n") ; } }
# - если файла нет, или даже если файл есть - записать в него новое выявленное событие
       system("echo \"MACD_$pv{time_frame} смена направления $sz_vector_change_value - $ds_end_datetime_list[$count_rows_post-1]\" >> $alert_file_vector_down") ;
# и при наличии - перенести файл события противоположного пересечения в старые. Мы обязаны удалить файл противоположного события - тогда только пойдёт уведомление при новом выявлении события
       if ( $is_exsist_alert_vector_up eq "file_exist" ) {
          if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - блок выявления смены направления линий MACD - есть файл противоположного события, переносим в архив\n") ; }
          system("echo \"MACD_$pv{time_frame} конец сигнала вверх - $ds_end_datetime_list[$count_rows_post-1]\" >> $alert_file_vector_up") ;
          system("cat $alert_file_vector_up >> $alert_history_file_vector_up.history ; mv -f $alert_file_vector_up $old_alerts_spool_dir") ;
          }
       }
    else { if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - блок выявления смены направления линий MACD - не выявлено изменение направления $sz_vector_change_value\n") ; } }

# изменение вверх
# если предпоследняя дельта периодов была MACD больше нуля, а последняя дельта периодов была меньше нуля - произошла смена направления вверх
    $sz_vector_change_value = "UP" ;
    if (($ds_end_diff_ema1226[$count_rows_post-3] - $ds_end_diff_ema1226[$count_rows_post-2]) > 0 and ($ds_end_diff_ema1226[$count_rows_post-2] - $ds_end_diff_ema1226[$count_rows_post-1]) < 0) {
       $sz_vector_find_change_value = $sz_vector_change_value ;
       if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - блок выявления смены направления линий MACD - успешно выявлено изменение $sz_vector_change_value\n") ; }
# - если файла события нет - взвести флаг уведомления и добавления в БД
       if ( $is_exsist_alert_vector_up ne "file_exist" ) {
          $is_macd_vector_send = "yes_send" ;
          $sz_vector_values = sprintf("MACD_%s смена направления вверх %s/%s (%s)<BR>- https://www.coinglass.com/tv/Bybit_%s%s<BR>- https://zrt.ourorbits.ru/crypta/cgi/tools_coin_trading.cgi?currency=%s",
                                     $pv{time_frame}, $pv{currency}, $pv{curr_reference}, $ds_end_datetime_list[$count_rows_post-1], $pv{currency}, $pv{curr_reference}, $pv{currency}) ;
          if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - блок выявления смены направления линий MACD - файл события не найден, взведён флаг уведомления, сформирована строка уведомления\n$log_prefix --- is_macd_vector_send = $is_macd_vector_send\n$log_prefix --- sz_vector_values = $sz_vector_values\n") ; }
          }
       else { if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - блок выявления смены направления линий MACD - файл события найден, не отрабатываем добавление в БД и уведомление\n$log_prefix --- is_macd_vector_send = $is_macd_vector_send\n$log_prefix --- sz_vector_values = $sz_vector_values\n") ; } }
# - если файла нет, или даже если файл есть - записать в него новое выявленное событие
       system("echo \"MACD_$pv{time_frame} смена направления вверх - $ds_end_datetime_list[$count_rows_post-1]\" >> $alert_file_vector_up") ;
# и при наличии - перенести файл события противоположного пересечения в старые. Мы обязаны удалить файл противоположного события - тогда только пойдёт уведомление при новом выявлении события
       if ( $is_exsist_alert_vector_down eq "file_exist" ) {
          if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) {
             printf(LOG "$log_prefix - блок выявления смены направления линий MACD - есть файл противоположного события, переносим в архив\n") ; }
          system("echo \"MACD_$pv{time_frame} конец сигнала вниз - $ds_end_datetime_list[$count_rows_post-1]\" >> $alert_file_vector_down") ;
          system("cat $alert_file_vector_down >> $alert_history_file_vector_down.history ; mv -f $alert_file_vector_down $old_alerts_spool_dir") ;
          }
       }
    else { if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - блок выявления смены направления линий MACD - не выявлено изменение направления $sz_vector_change_value\n") ; } }

# при необходимости разослать уведомления
    if ( $is_macd_vector_send eq "yes_send" ) {
       printf(LOG "$log_prefix - check_macd_lines_vector_change данные \$pv{macd_time_frame} = $pv{macd_time_frame} для определения переменных уведомления\n") ;
       if ($pv{macd_time_frame} eq "1H" ) { $is_macd_line_vector_email_send = $is_1H_macd_line_vector_email_send ; $is_macd_line_vector_telegram_send = $is_1H_macd_line_vector_telegram_send ; }
       if ($pv{macd_time_frame} eq "4H" ) { $is_macd_line_vector_email_send = $is_4H_macd_line_vector_email_send ; $is_macd_line_vector_telegram_send = $is_4H_macd_line_vector_telegram_send ; }
       if ($pv{macd_time_frame} eq "1D" ) { $is_macd_line_vector_email_send = $is_1D_macd_line_vector_email_send ; $is_macd_line_vector_telegram_send = $is_1D_macd_line_vector_telegram_send ; }
       create_graphs_add_event_to_db('MACD_'.$pv{macd_time_frame}.'_LINE_VECTOR', $sz_vector_find_change_value, $ds_end_datetime_list[$count_rows_post-1], $pv{currency}, $pv{curr_reference}, 'MACD', 'lines', $pv{time_frame}, $pv{macd_time_frame}, $pv{count_prds}, $sz_vector_values, $is_macd_line_vector_email_send, $is_macd_line_vector_telegram_send) ;
       }
    printf(LOG "$log_prefix - check_macd_line_vector_change STOP\n") ;
    }


# ----------------------------------------------------------------
# функция выявляет пересечение линий MACD по заполненным массивам
# ----------------------------------------------------------------
sub check_macd_lines_cross_change() {
    my $alert_file_cross_up_name = "macd_$pv{time_frame}_$pv{currency}_$pv{curr_reference}_cross_up.alert" ;
    my $alert_file_cross_up = "$alerts_spool_dir/$alert_file_cross_up_name" ;
    my $alert_history_file_cross_up = "$alerts_history_spool_dir/$alert_file_cross_up_name" ;
    my $is_exsist_alert_cross_up = `[ -f $alert_file_cross_up ] && echo "file_exist"` ; chomp($is_exsist_alert_cross_up) ; if ( $is_exsist_alert_cross_up ne "file_exist" ) { $is_exsist_alert_cross_up = "no_file" ; }

    my $alert_file_cross_down_name = "macd_$pv{time_frame}_$pv{currency}_$pv{curr_reference}_cross_down.alert" ;
    my $alert_file_cross_down = "$alerts_spool_dir/$alert_file_cross_down_name" ;
    my $alert_history_file_cross_down = "$alerts_history_spool_dir/$alert_file_cross_down_name" ;
    my $is_exsist_alert_cross_down = `[ -f $alert_file_cross_down ] && echo "file_exist"` ; chomp($is_exsist_alert_cross_down) ; if ( $is_exsist_alert_cross_down ne "file_exist" ) {  $is_exsist_alert_cross_down = "no_file" ; }
# флаг отправки взводится если файла уведомления ещё нет
    my $is_macd_cross_send = "no_send" ;
    my $sz_cross_values = "" ;
    my $sz_cross_vector_value = "" ;
    my $sz_cross_find_change_value = "" ;

    $CURR_LOG_DATE = `date +"%Y-%m-%d %H:%M:%S"` ; $CURR_LOG_DATE =~ s/[\r\n]+//g ;
    if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) {
       printf(LOG "$log_prefix - check_macd_line_cross_change START\n") ;
       printf(LOG "$log_prefix - check_macd_lines_cross_change - основные переменные:
$log_prefix --- time_frame = $pv{time_frame}
$log_prefix --- currency = $pv{currency}
$log_prefix --- curr_reference = $pv{curr_reference}
$log_prefix --- alert_file_cross_up_name = $alert_file_cross_up_name
$log_prefix --- alert_file_cross_up = $alert_file_cross_up
$log_prefix --- alert_history_file_cross_up = $alert_history_file_cross_up
$log_prefix --- is_exsist_alert_cross_up = $is_exsist_alert_cross_up 
$log_prefix --- alert_file_cross_down_name = $alert_file_cross_down_name
$log_prefix --- alert_file_cross_down = $alert_file_cross_down
$log_prefix --- alert_history_file_cross_down = $alert_history_file_cross_down
$log_prefix --- is_exsist_alert_cross_down = $is_exsist_alert_cross_down
$log_prefix --- is_macd_cross_send = $is_macd_cross_send
$log_prefix --- sz_cross_values = $sz_cross_values
$log_prefix --- sz_cross_change_value = $sz_cross_change_value
$log_prefix --- sz_cross_find_change_value = $sz_cross_find_change_value
$log_prefix --- предыдущий период = %f
$log_prefix --- текущий период = %f\n", $ds_end_diff_ema1226[$count_rows_post-2] - $ds_end_ema9_diff[$count_rows_post-2], $ds_end_diff_ema1226[$count_rows_post-1] - $ds_end_ema9_diff[$count_rows_post-1]) ; }

# если предпоследний период был MACD выше сигналки, а последний ниже сигналки - произошло пересечение вниз
    $sz_cross_vector_value = "DOWN" ;
    if (($ds_end_diff_ema1226[$count_rows_post-2] - $ds_end_ema9_diff[$count_rows_post-2]) > 0 and ($ds_end_diff_ema1226[$count_rows_post-1] - $ds_end_ema9_diff[$count_rows_post-1]) < 0) {
       $sz_cross_find_change_value = $sz_cross_vector_value ;
       if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - блок выявления пересечений линий MACD - успешно выявлено пересечение $sz_cross_find_change_value\n") ; }
# - если файла события нет - взвести флаг уведомления
#-debug-print "\n debug $is_exsist_alert_cross_down $is_exsist_alert_cross_down" ;
       if ( $is_exsist_alert_cross_down ne "file_exist" ) {
          $is_macd_cross_send = "yes_send" ;
          $sz_cross_values = sprintf("MACD_%s есть пересечение вниз  %s/%s (%s)<BR>- https://www.coinglass.com/tv/Bybit_%s%s<BR>- https://zrt.ourorbits.ru/crypta/cgi/tools_coin_trading.cgi?currency=%s",
                                    $pv{time_frame}, $pv{currency}, $pv{curr_reference}, $ds_end_datetime_list[$count_rows_post-1], $pv{currency}, $pv{curr_reference}, $pv{currency}) ;
          if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - блок выявления пересечений линий MACD - файл события не найден, взведён флаг уведомления, сформирована строка уведомления\n$log_prefix --- is_macd_cross_send = $is_macd_cross_send\n$log_prefix --- sz_cross_values = $sz_cross_values\n") ; }
          }
       else { if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - блок выявления пересечений линий MACD - файл события найден, не отрабатываем добавление в БД и уведомление\n$log_prefix --- is_macd_cross_send = $is_macd_cross_send\n$log_prefix --- sz_cross_values = $sz_cross_values\n") ; } }
       system("echo \"MACD_$pv{time_frame} есть пересечение вниз - $ds_end_datetime_list[$count_rows_post-1]\" >> $alert_file_cross_down") ;
# и при наличии - перенести файл события противоположного пересечения в старые. Мы обязаны удалить файл противоположного события - тогда только пойдёт уведомление при новом выявлении события
       if ( $is_exsist_alert_cross_up eq "file_exist" ) {
          if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - блок выявления пересечений линий MACD - есть файл противоположного события, переносим в архив\n") ; }
          system("echo \"MACD_$pv{time_frame} конец пересечения вверх - $ds_end_datetime_list[$count_rows_post-1]\" >> $alert_file_cross_up") ;
          system("cat $alert_file_cross_up >> $alert_history_file_cross_up.history ; mv -f $alert_file_cross_up $old_alerts_spool_dir") ;
          }
       }
    else { if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - блок выявления пересечений линий MACD - не выявлено пересечений $sz_cross_vector_value\n") ; } }

# если предпоследний период был MACD ниже сигналки, а последний выше сигналки - произошло пересечение вверх
    $sz_cross_vector_value = "UP" ;
    if (($ds_end_diff_ema1226[$count_rows_post-2] - $ds_end_ema9_diff[$count_rows_post-2]) < 0 and ($ds_end_diff_ema1226[$count_rows_post-1] - $ds_end_ema9_diff[$count_rows_post-1]) > 0) {
       $sz_cross_find_change_value = $sz_cross_vector_value ;
       if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - блок выявления пересечений линий MACD - успешно выявлено пересечение $sz_cross_find_change_value\n") ; }
# - если файла события нет - взвести флаг уведомления
       if ( $is_exsist_alert_cross_up ne "file_exist" ) {
          $is_macd_cross_send = "yes_send" ;
          $sz_cross_values = sprintf("MACD_%s есть пересечение вверх %s/%s (%s)<BR>- https://www.coinglass.com/tv/Bybit_%s%s<BR>- https://zrt.ourorbits.ru/crypta/cgi/tools_coin_trading.cgi?currency=%s",
                                    $pv{time_frame}, $pv{currency}, $pv{curr_reference}, $ds_end_datetime_list[$count_rows_post-1], $pv{currency}, $pv{curr_reference}, $pv{currency}) ;
          if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - блок выявления пересечений линий MACD - файл события не найден, взведён флаг уведомления, сформирована строка уведомления\n$log_prefix --- is_macd_cross_send = $is_macd_cross_send\n$log_prefix --- sz_cross_values = $sz_cross_values\n") ; }
          }
       else { if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - блок выявления пересечений линий MACD - файл события найден, не отрабатываем добавление в БД и уведомление\n$log_prefix --- is_macd_cross_send = $is_macd_cross_send\n$log_prefix --- sz_cross_values = $sz_cross_values\n") ; } }
       system("echo \"MACD_$pv{time_frame} есть пересечение вверх - $ds_end_datetime_list[$count_rows_post-1]\" >> $alert_file_cross_up") ;
# и при наличии - перенести файл события противоположного пересечения в старые. Мы обязаны удалить файл противоположного события - тогда только пойдёт уведомление при новом выявлении события
       if ( $is_exsist_alert_cross_down eq "file_exist" ) {
          if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - блок выявления пересечений  линий MACD - есть файл противоположного события, переносим в архив\n") ; }
          system("echo \"MACD_$pv{time_frame} конец пересечения вниз - $ds_end_datetime_list[$count_rows_post-1]\" >> $alert_file_cross_down") ;
          system("cat $alert_file_cross_down >> $alert_history_file_cross_down.history ; mv -f $alert_file_cross_down $old_alerts_spool_dir") ;
          }
       }
    else { if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - блок выявления пересечений линий MACD - не выявлено пересечений $sz_cross_vector_value\n") ; } }

# при необходимости разослать уведомления
    if ( $is_macd_cross_send eq "yes_send" ) {
       printf(LOG "$log_prefix - данные check_macd_lines_cross_change \$pv{macd_time_frame} = $pv{macd_time_frame} для определения переменных уведомления\n") ;
       if ($pv{macd_time_frame} eq "1H" ) { $is_macd_line_cross_email_send = $is_1H_macd_line_cross_email_send ; $is_macd_line_cross_telegram_send = $is_1H_macd_line_cross_telegram_send ; }
       if ($pv{macd_time_frame} eq "4H" ) { $is_macd_line_cross_email_send = $is_4H_macd_line_cross_email_send ; $is_macd_line_cross_telegram_send = $is_4H_macd_line_cross_telegram_send ; }
       if ($pv{macd_time_frame} eq "1D" ) { $is_macd_line_cross_email_send = $is_1D_macd_line_cross_email_send ; $is_macd_line_cross_telegram_send = $is_1D_macd_line_cross_telegram_send ; }
       create_graphs_add_event_to_db('MACD_'.$pv{macd_time_frame}.'_LINE_CROSS', $sz_cross_find_change_value, $ds_end_datetime_list[$count_rows_post-1], $pv{currency}, $pv{curr_reference}, 'MACD', 'lines', $pv{time_frame}, $pv{macd_time_frame}, $pv{count_prds}, $sz_cross_values, $is_macd_line_cross_email_send, $is_macd_line_cross_telegram_send) ;
       }
    printf(LOG "$log_prefix - check_macd_line_cross_change STOP\n") ;
    }


# ----------------------------------------------------------------
# функция выявляет смену направления гистограммы MACD по заполненным массивам
# ----------------------------------------------------------------
sub check_macd_gist_vector_change() {
    my $alert_file_macd_gist_vector_up_name = "macd_$pv{time_frame}_$pv{currency}_$pv{curr_reference}_gist_vector_up.alert" ;
    my $alert_file_macd_gist_vector_up = "$alerts_spool_dir/$alert_file_macd_gist_vector_up_name" ;
    my $alert_history_file_macd_gist_vector_up = "$alerts_history_spool_dir/$alert_file_macd_gist_vector_up_name" ;
    my $is_exsist_alert_macd_gist_vector_up = `[ -f $alert_file_macd_gist_vector_up ] && echo "file_exist"` ; chomp($is_exsist_alert_macd_gist_vector_up) ; if ( $is_exsist_alert_macd_gist_vector_up ne "file_exist" ) {  $is_exsist_alert_macd_gist_vector_up = "no_file" ; }

    my $alert_file_macd_gist_vector_down_name = "macd_$pv{time_frame}_$pv{currency}_$pv{curr_reference}_gist_vector_down.alert" ;
    my $alert_file_macd_gist_vector_down = "$alerts_spool_dir/$alert_file_macd_gist_vector_down_name" ;
    my $alert_history_file_macd_gist_vector_down = "$alerts_history_spool_dir/$alert_file_macd_gist_vector_down_name" ;
    my $is_exsist_alert_macd_gist_vector_down = `[ -f $alert_file_macd_gist_vector_down ] && echo "file_exist"` ; chomp($is_exsist_alert_macd_gist_vector_down) ; if ( $is_exsist_alert_macd_gist_vector_down ne "file_exist" ) { $is_exsist_alert_macd_gist_vector_down = "no_file" ; }

# флаг отправки взводится если файла уведомления ещё нет
    my $is_macd_gist_vector_send = "no_send" ;
    my $sz_macd_gist_vector_values = "" ;
    my $sz_macd_gist_vector_change_value = "" ;
    my $sz_macd_gist_vector_find_change_value = "" ;

    $CURR_LOG_DATE = `date +"%Y-%m-%d %H:%M:%S"` ; $CURR_LOG_DATE =~ s/[\r\n]+//g ;
    if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) {
       printf(LOG "$log_prefix - check_macd_gist_vector_change START\n") ;
       printf(LOG "$log_prefix - check_macd_gist_vector_change - основные переменные:
$log_prefix --- time_frame = $pv{time_frame}
$log_prefix --- currency = $pv{currency}
$log_prefix --- curr_reference = $pv{curr_reference}
$log_prefix --- alert_file_macd_gist_vector_up_name = $alert_file_macd_gist_vector_up_name
$log_prefix --- alert_file_macd_gist_vector_up = $alert_file_macd_gist_vector_up
$log_prefix --- alert_history_file_macd_gist_vector_up = $alert_history_file_macd_gist_vector_up
$log_prefix --- is_exsist_alert_macd_gist_vector_up = $is_exsist_alert_macd_gist_vector_up
$log_prefix --- alert_file_macd_gist_vector_down_name = $alert_file_macd_gist_vector_down_name
$log_prefix --- alert_file_macd_gist_vector_down = $alert_file_macd_gist_vector_down
$log_prefix --- alert_history_file_macd_gist_vector_down = $alert_history_file_macd_gist_vector_down
$log_prefix --- is_exsist_alert_macd_gist_vector_down = $is_exsist_alert_macd_gist_vector_down
$log_prefix --- is_macd_macd_gist_vector_send = $is_macd_macd_gist_vector_send
$log_prefix --- sz_macd_gist_vector_values = $sz_macd_gist_vector_values
$log_prefix --- sz_macd_gist_vector_change_value = $sz_macd_gist_vector_change_value
$log_prefix --- sz_macd_gist_vector_find_change_value = $sz_macd_gist_vector_find_change_value
$log_prefix --- предыдущий период = pos up %f, pos down %f, neg up %f, neg_down %f
$log_prefix --- текущий период = pos up %f, pos down %f, neg up %f, neg_down %f\n",
 $ds_end_gist_up_from_up[$count_rows_post-2], $ds_end_gist_up_from_down[$count_rows_post-2], $ds_end_gist_down_from_up[$count_rows_post-2], $ds_end_gist_down_from_down[$count_rows_post-2],
 $ds_end_gist_up_from_up[$count_rows_post-1], $ds_end_gist_up_from_down[$count_rows_post-1], $ds_end_gist_down_from_up[$count_rows_post-1], $ds_end_gist_down_from_down[$count_rows_post-1]) ; }

# падение гистограммы
    $sz_macd_gist_vector_change_value = "DOWN" ;
    if ( ($ds_end_gist_up_from_up[$count_rows_post-2] > 0 && $ds_end_gist_up_from_down[$count_rows_post-1] > 0) || ($ds_end_gist_down_from_up[$count_rows_post-2] < 0 && $ds_end_gist_down_from_down[$count_rows_post-1] < 0) ) {
       $sz_macd_gist_vector_find_change_value = $sz_macd_gist_vector_change_value ;
       if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - check_macd_gist_vector_change - успешно выявлено изменение $sz_macd_gist_vector_change_value\n") ; }
# - если файла события нет - взвести флаг уведомления и добавления в БД
       if ( $is_exsist_alert_macd_gist_vector_down ne "file_exist" ) {
          $is_macd_gist_vector_send = "yes_send" ;
          $sz_macd_gist_vector_values = sprintf("MACD_%s смена направления GIST вниз %s/%s (%s)<BR>- https://www.coinglass.com/tv/Bybit_%s%s<BR>- https://zrt.ourorbits.ru/crypta/cgi/tools_coin_trading.cgi?currency=%s",
                                     $pv{time_frame}, $pv{currency}, $pv{curr_reference}, $ds_end_datetime_list[$count_rows_post-1], $pv{currency}, $pv{curr_reference}, $pv{currency}) ;
          if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - check_macd_gist_vector_change - файл события не найден, взведён флаг уведомления, сформирована строка уведомления\n$log_prefix --- is_macd_gist_vector_send = $is_macd_gist_vector_send\n$log_prefix --- sz_macd_gist_vector_values = $sz_macd_gist_vector_values\n") ; }
          }
       else { if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - check_macd_gist_vector_change - файл события найден, не отрабатываем добавление в БД и уведомление\n$log_prefix --- is_macd_gist_vector_send = $is_macd_gist_vector_send\n$log_prefix --- sz_macd_gist_vector_values = $sz_macd_gist_vector_values\n") ; } }
# - если файла нет, или даже если файл есть - записать в него новое выявленное событие
       system("echo \"MACD_$pv{time_frame} смена направления GIST $sz_macd_gist_vector_change_value - $ds_end_datetime_list[$count_rows_post-1]\" >> $alert_file_macd_gist_vector_down") ;
# и при наличии - перенести файл события противоположного пересечения в старые. Мы обязаны удалить файл противоположного события - тогда только пойдёт уведомление при новом выявлении события
       if ( $is_exsist_alert_macd_gist_vector_up eq "file_exist" ) {
          if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - check_macd_gist_vector_change - есть файл противоположного события, переносим в архив\n") ; }
          system("echo \"MACD_$pv{time_frame} конец сигнала вверх - $ds_end_datetime_list[$count_rows_post-1]\" >> $alert_file_macd_gist_vector_up") ;
          system("cat $alert_file_macd_gist_vector_up >> $alert_history_file_macd_gist_vector_up.history ; mv -f $alert_file_macd_gist_vector_up $old_alerts_spool_dir") ;
          }
       }
    else { if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - check_macd_gist_vector_change - не выявлено изменение направления $sz_macd_gist_vector_change_value\n") ; } }

# рост гистограммы
    $sz_macd_gist_vector_change_value = "UP" ;
    if ( ($ds_end_gist_up_from_down[$count_rows_post-2] > 0 && $ds_end_gist_up_from_up[$count_rows_post-1] > 0) || ($ds_end_gist_down_from_down[$count_rows_post-2] < 0 && $ds_end_gist_down_from_up[$count_rows_post-1] < 0) ) {
       $sz_macd_gist_vector_find_change_value = $sz_macd_gist_vector_change_value ;
       if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - check_macd_gist_vector_change - успешно выявлено изменение $sz_macd_gist_vector_change_value\n") ; }
# - если файла события нет - взвести флаг уведомления и добавления в БД
       if ( $is_exsist_alert_macd_gist_vector_up ne "file_exist" ) {
          $is_macd_gist_vector_send = "yes_send" ;
          $sz_macd_gist_vector_values = sprintf("MACD_%s смена направления GIST вверх %s/%s (%s)<BR>- https://www.coinglass.com/tv/Bybit_%s%s<BR>- https://zrt.ourorbits.ru/crypta/cgi/tools_coin_trading.cgi?currency=%s",
                                     $pv{time_frame}, $pv{currency}, $pv{curr_reference}, $ds_end_datetime_list[$count_rows_post-1], $pv{currency}, $pv{curr_reference}, $pv{currency}) ;
          if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - check_macd_gist_vector_change - файл события не найден, взведён флаг уведомления, сформирована строка уведомления\n$log_prefix --- is_macd_gist_vector_send = $is_macd_gist_vector_send\n$log_prefix --- sz_macd_gist_vector_values = $sz_macd_gist_vector_values\n") ; }
          }
       else { if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - check_macd_gist_vector_change - файл события найден, не отрабатываем добавление в БД и уведомление\n$log_prefix --- is_macd_gist_vector_send = $is_macd_gist_vector_send\n$log_prefix --- sz_macd_gist_vector_values = $sz_macd_gist_vector_values\n") ; } }
# - если файла нет, или даже если файл есть - записать в него новое выявленное событие
       system("echo \"MACD_$pv{time_frame} смена направления GIST вверх - $ds_end_datetime_list[$count_rows_post-1]\" >> $alert_file_macd_gist_vector_up") ;
# и при наличии - перенести файл события противоположного пересечения в старые. Мы обязаны удалить файл противоположного события - тогда только пойдёт уведомление при новом выявлении события
       if ( $is_exsist_alert_macd_gist_vector_down eq "file_exist" ) {
          if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) {
             printf(LOG "$log_prefix --- check_macd_gist_vector_change - есть файл противоположного события, переносим в архив\n") ; }
          system("echo \"MACD_$pv{time_frame} конец сигнала вниз - $ds_end_datetime_list[$count_rows_post-1]\" >> $alert_file_macd_gist_vector_down") ;
          system("cat $alert_file_macd_gist_vector_down >> $alert_history_file_macd_gist_vector_down.history ; mv -f $alert_file_macd_gist_vector_down $old_alerts_spool_dir") ;
          }
       }
    else { if ( $is_logging_alert_check_MACD_TV_all_TF_crcomp eq "enabled" ) { printf(LOG "$log_prefix - check_macd_gist_vector_change - не выявлено изменение направления $sz_macd_gist_vector_change_value\n") ; } }

# при необходимости разослать уведомления
    if ( $is_macd_gist_vector_send eq "yes_send" ) {
       printf(LOG "$log_prefix --- check_macd_gist_vector_change - данные \$pv{macd_time_frame} = $pv{macd_time_frame} для определения переменных уведомления\n") ;
       if ($pv{macd_time_frame} eq "1H" ) { $is_macd_gist_vector_email_send = $is_1H_macd_gist_vector_email_send ; $is_macd_gist_vector_telegram_send = $is_1H_macd_gist_vector_telegram_send ; }
       if ($pv{macd_time_frame} eq "4H" ) { $is_macd_gist_vector_email_send = $is_4H_macd_gist_vector_email_send ; $is_macd_gist_vector_telegram_send = $is_4H_macd_gist_vector_telegram_send ; }
       if ($pv{macd_time_frame} eq "1D" ) { $is_macd_gist_vector_email_send = $is_1D_macd_gist_vector_email_send ; $is_macd_gist_vector_telegram_send = $is_1D_macd_gist_vector_telegram_send ; }
       create_graphs_add_event_to_db('MACD_'.$pv{macd_time_frame}.'_GIST_VECTOR', $sz_macd_gist_vector_find_change_value, $ds_end_datetime_list[$count_rows_post-1], $pv{currency}, $pv{curr_reference}, 'MACD', 'gist', $pv{time_frame}, $pv{macd_time_frame}, $pv{count_prds}, $sz_macd_gist_vector_values, $is_macd_gist_vector_email_send, $is_macd_gist_vector_telegram_send) ;
       }
    printf(LOG "$log_prefix - check_macd_gist_vector_change STOP\n") ;
    }

sub print_tools_monitoring_navigation($) { $active_tab{1} = "" ; $active_tab{2} = "" ; $active_tab{3} = "" ; $active_tab{4} = "" ; $active_tab{5} = "" ; ;
    $num_active_tab = $_[0] ; $active_tab{$num_active_tab} = " solid none solid" ;
    if ($pv{time_frame_ext} eq "") { $pv{time_frame_ext} = "10Mh" ; }

#time_frame=1D&count_prds=$pv{count_1d_prds}&macd_mult=$pv{macd_mult}&env_prct=30\">Лента&nbsp;событий&nbsp;мониторинга</A></TD>
    print "<TABLE CELLSPACING=\"0\" CELLPADDING=\"0\" STYLE=\"border: 0pt none; width: 100%;\">
           <TR><TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{2}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_monitoring.cgi?currency=ALL&curr_reference=$pv{curr_reference}&cnt_rand_id=$pv{cnt_rand_id}&mon_areal=$pv{mon_areal}&mon_tf=$pv{mon_tf}&mon_events=$pv{mon_events}\">Лента&nbsp;событий&nbsp;мониторинга&nbsp;(RLT)</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{1}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_monitoring.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}&cnt_rand_id=$pv{cnt_rand_id}&mon_areal=$pv{mon_areal}&mon_tf=$pv{mon_tf}&mon_events=$pv{mon_events}\">События&nbsp;мониторинга&nbsp;торговой&nbsp;пары&nbsp;(RLT)</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
           </TR></TABLE>" ;
    }

-1

