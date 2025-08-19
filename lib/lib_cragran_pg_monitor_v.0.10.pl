
# open source soft - (C) 2023 CrAgrAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

sub print_tools_pg_main_navigation($) { $active_tab{1} = "" ; $active_tab{2} = "" ; $active_tab{3} = "" ; $active_tab{4} = "" ; $active_tab{5} = "" ; ;
    $num_active_tab = $_[0] ; $active_tab{$num_active_tab} = " solid none solid" ;
    if ($pv{time_frame_ext} eq "") { $pv{time_frame_ext} = "10Mh" ; }
    print "<TABLE CELLSPACING=\"0\" CELLPADDING=\"0\" STYLE=\"border: 0pt none; width: 100%;\">
           <TR><TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{1}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor.cgi&action=clear\">Состояние&nbsp;прикладных<BR>таблиц&nbsp;агрегатора</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{2}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor.cgi?action=contracts_list\">Конфигурация<BR>Объекты</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{3}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_SAH.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&sess_state_filter=$pv{sess_state_filter}&is_user_backends=$pv{is_user_backends}&is_backgrounds=$pv{is_backgrounds}&is_extensions=$pv{is_extensions}&tab_detail=1\">Монитор<BR>активности</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{4}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_WS.cgi?action=aa\">Мониторинговая<BR>аналитика</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{5}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor.cgi?action=contracts_list\">---</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
<!--
           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{6}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor.cgi?action=aa\">Запросы</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{7}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor.cgi?action=contracts_list\">Список&nbsp;сделок</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{8}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor.cgi?action=aa\">Отчёты&nbsp;по&nbsp;сд
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
-->
           </TR></TABLE>" ;
    }

sub print_tools_pg_monitor_navigation($) { $active_tab{1} = "" ; $active_tab{2} = "" ; $active_tab{3} = "" ; $active_tab{4} = "" ; $active_tab{5} = "" ; ;
    $num_active_tab = $_[0] ; $active_tab{$num_active_tab} = " solid none solid" ;
    if ($pv{time_frame_ext} eq "") { $pv{time_frame_ext} = "10Mh" ; }
    print "<BR><TABLE CELLSPACING=\"0\" CELLPADDING=\"0\" STYLE=\"border: 0pt none; width: 100%;\">
           <TR><TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{1}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_SAH.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&sess_state_filter=$pv{sess_state_filter}&is_user_backends=$pv{is_user_backends}&is_backgrounds=$pv{is_backgrounds}&is_extensions=$pv{is_extensions}&tab_detail=1\"
                  TITLE=\"Распределение из stats activity [1 секунда] - долгоживущие запросы\">TOP&nbsp;Activity&nbsp;(SA)</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{2}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_WS.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$pv{query_id}&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&tab_detail=1\"
                  TITLE=\"Распределение из wait sampling [10 миллисекунд] - короткоживущие запросы\">TOP&nbsp;Activity&nbsp;(WS)</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{3}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/\" TITLE=\"текущие запросы из pg_stat_statements\">Сессии</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{4}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/\" TITLE=\"текущие сессии из pg_stat_activity\">Блокировки</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{4}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/\" TITLE=\"текущие сессии из pg_wait_sampling\">Запросы</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
           </TR></TABLE>" ;
    }

sub print_tools_pg_monitor_top_activity_SA_detail($) { $active_tab{1} = "" ; $active_tab{2} = "" ; $active_tab{3} = "" ; $active_tab{4} = "" ; $active_tab{5} = "" ; ;
    $num_active_tab = $_[0] ; $active_tab{$num_active_tab} = " solid none solid" ;
    if ($pv{time_frame_ext} eq "") { $pv{time_frame_ext} = "10Mh" ; }
    print "<TABLE CELLSPACING=\"0\" CELLPADDING=\"0\" STYLE=\"border: 0pt none; width: 100%;\">
           <TR><TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{1}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_SAH.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&sess_state_filter=$pv{sess_state_filter}&is_user_backends=$pv{is_user_backends}&is_backgrounds=$pv{is_backgrounds}&is_extensions=$pv{is_extensions}&tab_detail=1\"
                  TITLE=\"\">Запросы&nbsp;SA<BR>&nbsp;Сессии&nbsp;SA</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{2}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_SAH.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&sess_state_filter=$pv{sess_state_filter}&is_user_backends=$pv{is_user_backends}&is_backgrounds=$pv{is_backgrounds}&is_extensions=$pv{is_extensions}&tab_detail=2\"
                  TITLE=\"\">Запросы&nbsp;SA<BR>полные</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{3}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_SAH.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&sess_state_filter=$pv{sess_state_filter}&is_user_backends=$pv{is_user_backends}&is_backgrounds=$pv{is_backgrounds}&is_extensions=$pv{is_extensions}&tab_detail=3\"
                  TITLE=\"\">Сессии&nbsp;SA<BR>полные</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{4}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_SAH.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&sess_state_filter=$pv{sess_state_filter}&is_user_backends=$pv{is_user_backends}&is_backgrounds=$pv{is_backgrounds}&is_extensions=$pv{is_extensions}&tab_detail=4\"
                  TITLE=\"\">Запросы&nbsp;SA<BR>Запросы&nbsp;WS</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{5}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_SAH.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&sess_state_filter=$pv{sess_state_filter}&is_user_backends=$pv{is_user_backends}&is_backgrounds=$pv{is_backgrounds}&is_extensions=$pv{is_extensions}&tab_detail=5\"
                  TITLE=\"\">Сессии&nbsp;SA<BR>Сессии&nbsp;WS</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{6}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_SAH.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&sess_state_filter=$pv{sess_state_filter}&is_user_backends=$pv{is_user_backends}&is_backgrounds=$pv{is_backgrounds}&is_extensions=$pv{is_extensions}&tab_detail=6\"
                  TITLE=\"\">События&nbsp;ожидания<BR>SA&nbsp;WS</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
           </TR></TABLE>" ;
    }

sub print_tools_pg_monitor_top_activity_WS_detail($) { $active_tab{1} = "" ; $active_tab{2} = "" ; $active_tab{3} = "" ; $active_tab{4} = "" ; $active_tab{5} = "" ; ;
    $num_active_tab = $_[0] ; $active_tab{$num_active_tab} = " solid none solid" ;
    if ($pv{time_frame_ext} eq "") { $pv{time_frame_ext} = "10Mh" ; }
    print "<TABLE CELLSPACING=\"0\" CELLPADDING=\"0\" STYLE=\"border: 0pt none; width: 100%;\">
           <TR><TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{1}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_WS.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&tab_detail=1\"
                  TITLE=\"\">Запросы&nbsp;WS<BR>&nbsp;Сессии&nbsp;WS</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{2}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_WS.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&tab_detail=2\"
                  TITLE=\"\">Запросы&nbsp;WS<BR>полные</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{3}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_WS.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&tab_detail=3\"
                  TITLE=\"\">Сессии&nbsp;WS<BR>полные</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{4}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_WS.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&tab_detail=4\"
                  TITLE=\"\">Запросы&nbsp;SA<BR>Запросы&nbsp;WS</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{5}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_WS.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&tab_detail=5\"
                  TITLE=\"\">Сессии&nbsp;SA<BR>Сессии&nbsp;WS</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{6}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_WS.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&tab_detail=6\"
                  TITLE=\"\">События&nbsp;ожидания<BR>SA&nbsp;WS</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
           </TR></TABLE>" ;
    }

sub print_tools_pg_monitor_query_detail($) { $active_tab{1} = "" ; $active_tab{2} = "" ; $active_tab{3} = "" ; $active_tab{4} = "" ; $active_tab{5} = "" ; ;
    $num_active_tab = $_[0] ; $active_tab{$num_active_tab} = " solid none solid" ;
    if ($pv{time_frame_ext} eq "") { $pv{time_frame_ext} = "10Mh" ; }
    print "<TABLE CELLSPACING=\"0\" CELLPADDING=\"0\" STYLE=\"border: 0pt none; width: 100%;\">
           <TR><TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{1}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_query.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$pv{query_id}&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&tab_detail=1\">Распределение<BR>по&nbsp;сессиям&nbsp;SA</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{2}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_query.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$pv{query_id}&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&tab_detail=2\"
                  TITLE=\"т.к. иногда текст запроса в pg_stat_activity есть, а query_id нет - если нельзя достать текст по пустому query_id из pg_stat_statements, то делается попытка достать его из pg_stat_activity, т.к. в bestat_sa_history текст запроса не сохраняется для облегчения агрегатора\">Текст<BR>запроса</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{3}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_query.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$pv{query_id}&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&tab_detail=3\"
                  TITLE=\"в настоящее время реализовано по текущим данным pg_stat_statements без сохранения и учёта периодов\">Статистики<BR>запроса</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{4}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_query.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$pv{query_id}&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&tab_detail=4\"
                  TITLE=\"в настоящее время реализовано по текущим данным pg_stat_statements без сохранения и учёта периодов\">Планы<BR>выполнения</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{5}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_query.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$pv{query_id}&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&tab_detail=5\">События<BR>ожидания&nbsp;SA/WS</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{6}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_query.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$pv{query_id}&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&tab_detail=6\">График<BR>pg_wait_sampling</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
           </TR></TABLE>" ;
    }


sub print_js_block_pg_monitor() {
    print "<SCRIPT LANGUAGE=\"JavaScript\">
function renew_db_status_page(v_period_from,v_period_to,v_query_id,v_plan_hash,v_pid,v_serial,v_sesttfltr,v_isusrback,v_isbgr,v_isext,v_tab_detail) {
         var v_ds_type_value ;
         var v_url ;
         var id_radio_type = document.getElementsByName('ds_type') ;
         for (i=0; i < id_radio_type.length; i++) { if (id_radio_type[i].checked) { v_ds_type_value = id_radio_type[i].value ; } }
//         alert(v_ds_type_value) ;
//         window.location.href = \"http://zrt.ourorbits.ru/crypta/cgi/get_db_status.cgi?period_from=\"+v_period_from+\"&period_to=\"+v_period_to+\"&ds_type=\"+v_ds_type_value ;
//alert(window.location.href) ;
//         v_url = \"https://zrt.ourorbits.ru\"+window.location.pathname+\"?period_from=\"+v_period_from+\"&period_to=\"+v_period_to+\"&query_id=\"+v_query_id+\"&plan_hash=\"+v_plan_hash+\"&pid=\"+v_pid+\"&serial=\"+v_serial+\"&ds_type=\"+v_ds_type_value+\"&sess_state_filter=\"+v_sesttfilt+\"&is_user_backends=\"+v_isusrback+\"&is_backgrounds=\"+v_isbgr+\"&is_extensions=\"+v_isext+\"&tab_detail=\"+v_tab_detail ;
         v_url = \"https://zrt.ourorbits.ru\"+window.location.pathname+\"?period_from=\"+v_period_from+\"&period_to=\"+v_period_to+\"&query_id=\"+v_query_id+\"&plan_hash=\"+v_plan_hash+\"&pid=\"+v_pid+\"&serial=\"+v_serial+\"&ds_type=\"+v_ds_type_value+\"&sess_state_filter=\"+v_sesttfltr+\"&is_user_backends=\"+v_isusrback+\"&is_backgrounds=\"+v_isbgr+\"&is_extensions=\"+v_isext+\"&tab_detail=\"+v_tab_detail ;
//         alert(v_url) ;
         window.location.href = v_url ;
         }

function renew_wait_sampling_db_status_page(v_period_from,v_period_to,v_query_id,v_plan_hash,v_pid,v_serial,v_page_part) {
         var v_ds_type_value ;
         var v_url ;
         var id_radio_type = document.getElementsByName('ds_type') ;
         for (i=0; i < id_radio_type.length; i++) { if (id_radio_type[i].checked) { v_ds_type_value = id_radio_type[i].value ; } }
//         alert(v_ds_type_value) ;
//         window.location.href = \"http://zrt.ourorbits.ru/crypta/cgi/get_db_status.cgi?period_from=\"+v_period_from+\"&period_to=\"+v_period_to+\"&ds_type=\"+v_ds_type_value ;
//alert(window.location.href) ;
         v_url = \"https://zrt.ourorbits.ru\"+window.location.pathname+\"?period_from=\"+v_period_from+\"&period_to=\"+v_period_to+\"&query_id=\"+v_query_id+\"&plan_hash=\"+v_plan_hash+\"&pid=\"+v_pid+\"&serial=\"+v_serial+\"&ds_type=\"+v_ds_type_value+\"&page_part=\"+v_page_part ;
//         alert(v_url) ;
         window.location.href = v_url ;
         }

</SCRIPT>\n" ;
    }

sub print_activity_graph($$$$$$$$) { my $filter_period_from = $_[0] ; my $filter_period_to = $_[1] ; my $filter_query_id = $_[2] ; my $filter_sql_plan_hash_value = $_[3] ; my $filter_pid = $_[4] ; my $filter_session_serial = $_[5] ; my $percent = $_[6] ; $source_table_name = $_[7] ;
# !!! - вписать переменные фильтров и их обработку - state бэкэнд бэкграунд расширения
#print "&nbsp;" ; exit 0 ;
#}
#sub print_activity_graph_2($$$$$$$$) {

#-debug-$pv{period_from} = "2024-05-02 00:00:00" ; $pv{period_to} = "2025-06-03 00:00:00" ; $pv{ds_type} = "MEM" ; $pv{width} = 1500 ; $pv{height} = 700 ;

    $request_chart_per_class = " " ;
#####my $source_table_name = "pg_wait_sampling_history" ; if  ($pv{ds_type} eq "DB") { $source_table_name = "besst_stat_ash_history" ; }
    my $where_timepoint = "" ;
    my $where_ext = "" ;
    if ( $pv{period_from} eq "" ||  $pv{period_to} eq "" ) { die ; }
    $where_timepoint .= " sampling_time >= TO_TIMESTAMP('$pv{period_from}','YYYY-MM-DD HH24:MI:SS') " ;
    $where_timepoint .= " AND sampling_time <= TO_TIMESTAMP('$pv{period_to}','YYYY-MM-DD HH24:MI:SS')" ;

    if ( $filter_query_id ne "" ) { $where_ext .= " AND query_id = $filter_query_id" ; }
#    if ( $filter_sql_plan_hash_value ne "" ) { $where_ext .= " AND SQL_PLAN_HASH_VALUE = '$filter_sql_plan_hash_value'" ; }
    if ( $filter_pid ne "" ) { $where_ext .= " AND pid = $filter_pid" ; }
#    if ( $filter_session_serial ne "" ) { $where_ext .= " AND SESSION_SERIAL# = '$filter_session_serial'" ; }

   $request_chart_per_class = "
select sum(src2.wc_CPU_Active) wc_CPU_Active, sum(src2.wc_Activity) wc_Activity, sum(src2.wc_BufferPin) wc_BufferPin, sum(src2.wc_Client) wc_Client,
       sum(src2.wc_Extension) wc_Extension, sum(src2.wc_IO) wc_IO, sum(src2.wc_IPC) wc_IPC, sum(src2.wc_Lock) wc_Lock, sum(src2.wc_LWLock) wc_LWLock,
       sum(src2.wc_Timeout) wc_Timeout, sum(src2.wc_Other) wc_Other
       from (select src1.sampling_time,
            CASE WHEN src1.wait_event_type = 'CPU Active' THEN src1.value ELSE 0 END wc_CPU_Active,
            CASE WHEN src1.wait_event_type = 'Activity' THEN src1.value ELSE 0 END wc_Activity,
            CASE WHEN src1.wait_event_type = 'BufferPin' THEN src1.value ELSE 0 END wc_BufferPin,
            CASE WHEN src1.wait_event_type = 'Client' THEN src1.value ELSE 0 END wc_Client,
            CASE WHEN src1.wait_event_type = 'Extension' THEN src1.value ELSE 0 END wc_Extension,
            CASE WHEN src1.wait_event_type = 'IO' THEN src1.value ELSE 0 END wc_IO,
            CASE WHEN src1.wait_event_type = 'IPC' THEN src1.value ELSE 0 END wc_IPC,
            CASE WHEN src1.wait_event_type = 'Lock' THEN src1.value ELSE 0 END wc_Lock,
            CASE WHEN src1.wait_event_type = 'LWLock' THEN src1.value ELSE 0 END wc_LWLock,
            CASE WHEN src1.wait_event_type = 'Timeout' THEN src1.value ELSE 0 END wc_Timeout,
            CASE WHEN src1.wait_event_type NOT IN ('CPU Active','Activity','BufferPin','Client','Extension','IO','IPC','Lock','LWLock','Timeout')
                                      THEN src1.value ELSE 0 END wc_Other
            from (select ash.sampling_time sampling_time,
                         CASE WHEN ash.wait_event_type IS NULL THEN 'CPU Active' ELSE ash.wait_event_type END wait_event_type, round(sum(ash.value)/60,4) value
                         from (select date_trunc('minute', sampling_time) sampling_time, wait_event_type, count(*) value
                                      from $source_table_name
                                      where $where_timepoint $where_ext
                                      group by date_trunc('minute', sampling_time), wait_event_type) ash
                         group by ash.sampling_time, ash.wait_event_type) src1 ) src2 " ;

#debug-print "<BR>$request_chart_per_class<BR>" ;

    my $white_spaces = 100 - $percent ;
    my $count_class = 0 ;
#-debug-print "<BR>!!! pre sql ws = $white_spaces, prc = $percent<BR>" ;
    my $dbh_chart_per_class = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'cryptapwd' ) ;
    my $sth_chart_per_class = $dbh_chart_per_class->prepare($request_chart_per_class) ; $sth_chart_per_class->execute() ; $count_rows = 0 ;

#-debug-print "<BR>!!! execute sql<BR>" ;
    while (my ($wc_CPU_Active, $wc_Activity, $wc_BufferPin, $wc_Client, $wc_Extension, $wc_IO, $wc_IPC, $wc_Lock, $wc_LWLock, $wc_Timeout, $wc_Other) = $sth_chart_per_class->fetchrow_array() ) {
          $count_class++ ;
          my $tmp_sum =  $wc_CPU_Active + $wc_Activity + $wc_BufferPin + $wc_Client + $wc_Extension + $wc_IO + $wc_IPC + $wc_Lock + $wc_LWLock + $wc_Timeout + $wc_Other ;
#-debug-print "<BR>--$white_spaces -- $tmp_sum --" ;
#-debug-print "<BR>\n - class - tmp_sum $tmp_sum, query_id $query_id, time $begin_time, actSess $wc_ActiveSession, concurr $wc_Concurrency, userIO $wc_UserIO, systemIO $wc_SystemIO, other $wc_Other, config $wc_Configuration, sched $wc_Scheduler, cpu $wc_CPU, app $wc_nameApplication, commit $wc_Commit, net $wc_Network, admin $wc_Administrative, clust $wc_Cluster\n" ;
          $wc_CPU_Active = sprintf("%.1f", $wc_CPU_Active * $percent / $tmp_sum) ;
          $wc_Activity = sprintf("%.1f", $wc_Activity * $percent / $tmp_sum) ;
          $wc_BufferPin = sprintf("%.1f", $wc_BufferPin * $percent / $tmp_sum) ;
          $wc_Client = sprintf("%.1f", $wc_Client * $percent / $tmp_sum) ;
          $wc_Extension = sprintf("%.1f", $wc_Extension  * $percent / $tmp_sum) ;
          $wc_IO = sprintf("%.1f", $wc_IO * $percent / $tmp_sum) ;
          $wc_IPC = sprintf("%.1f", $wc_IPC * $percent / $tmp_sum) ;
          $wc_Lock = sprintf("%.1f", $wc_Lock * $percent / $tmp_sum) ;
          $wc_LWLock = sprintf("%.1f", $wc_LWLock * $percent / $tmp_sum) ;
          $wc_Timeout = sprintf("%d", $wc_Timeout * $percent / $tmp_sum) ;
          $wc_Other = sprintf("%d", $wc_Other * $percent / $tmp_sum) ;
#-debug-print "<BR>\n - class - tmp_sum $tmp_sum, query_id $query_id, time $begin_time, actSess $wc_ActiveSession, concurr $wc_Concurrency, userIO $wc_UserIO, systemIO $wc_SystemIO, other $wc_Other, config $wc_Configuration, sched $wc_Scheduler, cpu $wc_CPU, app $wc_Application, commit $wc_Commit, net $wc_Network, admin $wc_Administrative, clust $wc_Cluster\n" ;
          print "<TABLE WIDTH=\"200pt;\" HEIGHT=\"8pt;\" CELLPADDING=\"0\" CELLSPACING=\"0\"><TR>" ;
          if ( $wc_CPU_Active > 0 ) { print "<TD TITLE=\"CPU Active $wc_CPU_Active\%\" STYLE=\"width: $wc_CPU_Active\%; height: 15pt; background-color: darkgreen;\">&nbsp;</TD>" ; }
          if ( $wc_Activity > 0 ) { print "<TD TITLE=\"Activity $wc_Activity\%\" STYLE=\"width: $wc_Activity\%; height: 15pt; background-color: lime;\">&nbsp;</TD>" ; }
          if ( $wc_BufferPin > 0 ) { print "<TD TITLE=\"BufferPin $wc_BufferPin\%\" STYLE=\"width: $wc_BufferPin\%; height: 15pt; background-color: pink;\">&nbsp;</TD>" ; }
          if ( $wc_Client > 0 ) { print "<TD TITLE=\"Client $wc_Client\%\" STYLE=\"width: $wc_Client\%; height: 15pt; background-color: cyan;\">&nbsp;</TD>" ; }
          if ( $wc_Extension > 0 ) { print "<TD TITLE=\"Extension $wc_Extension\%\" STYLE=\"width: $wc_Extension\%; height: 15pt; background-color: slateblue;\">&nbsp;</TD>" ; }
          if ( $wc_IO > 0 ) { print "<TD TITLE=\"IO $wc_IO\%\" STYLE=\"width: $wc_IO\%; height: 15pt; background-color: navy;\">&nbsp;</TD>" ; }
          if ( $wc_IPC > 0 ) { print "<TD TITLE=\"IPC $wc_IPC\%\" STYLE=\"width: $wc_IPC\%; height: 15pt; background-color: orange;\">&nbsp;</TD>" ; }
          if ( $wc_Lock > 0 ) { print "<TD TITLE=\"Lock $wc_Lock\%\" STYLE=\"width: $wc_Lock\%; height: 15pt; background-color: darkred;\">&nbsp;</TD>" ; }
          if ( $wc_LWLock > 0 ) { print "<TD TITLE=\"LWLock $wc_LWLock\%\" STYLE=\"width: $wc_LWLock\%; height: 15pt; background-color: red;\">&nbsp;</TD>" ; }
          if ( $wc_Timeout > 0 ) { print "<TD TITLE=\"Timeout $wc_Timeout\%\" STYLE=\"width: $wc_Timeout\%; height: 15pt; background-color: lightgray;\">&nbsp;</TD>" ; }
          if ( $wc_Other > 0 ) { print "<TD TITLE=\"Other $wc_Other\%\" STYLE=\"width: $wc_Other\%; height: 15pt; background-color: black;\">&nbsp;</TD>" ; }
          print "<TD STYLE=\"width: $white_spaces\%; height: 15pt; background-color: white;\">&nbsp;</TD>" ;
          print "</TR></TABLE>" ; }
    $sth_chart_per_class->finish() ;
    $dbh_chart_per_class->disconnect() ;
#-debug- for ($i=0;$i<=$count_rows;$i++) { print "$avg_data_source[0][$i] $avg_data_source[1][$i] $avg_data_source[2][$i] $avg_data_source[3][$i] $avg_data_source[4][$i] $avg_data_source[5][$i]\n" ; } exit 0 ;
#-debug-print "<BR>\n$request_chart_per_class" ;
    }

sub print_head_ash_graph() {
    $sz_current_date_short = `date "+%Y-%m-%d 00:00:00"` ;
    $sz_current_date = `date "+%Y-%m-%d 23:59:59"` ;
    $pv{period_from} = ( $pv{period_from} eq "" ) ? $sz_current_date_short : $pv{period_from} ;
    $pv{period_to} = ( $pv{period_to} eq "" ) ? $sz_current_date : $pv{period_to} ;
    if ($pv{ds_type} eq "") { $pv{ds_type} = "DB" ; } my $is_ds_type_db = "" ; my $is_ds_type_mem = " CHECKED" ; if ($pv{ds_type} eq "DB") { $is_ds_type_db = " CHECKED" ; $is_ds_type_mem = "" ; }
    $pv{serial} = "" ; $pv{plan_hash} = "NO in PG vanilla" ;

    $pv{sess_state_filter} = ( $pv{sess_state_filter} eq "" ) ? "all_states" : $pv{sess_state_filter} ;
# лишнее, ибо выключенный - как раз пустой. Правильно инициализировать в начале
#    $#pv{is_user_backends} = ( $pv{is_user_backends} eq "" ) ? "on" : $pv{is_user_backends} ;
#    $#pv{is_backgrounds} = ( $pv{is_backgrounds} eq "" ) ? "on" : $pv{is_backgrounds} ;
#    $#pv{is_extensions} = ( $pv{is_extensions} eq "" ) ? "on" : $pv{is_extensions} ;

    print "<TABLE STYLE=\"width: 100%\">
           <TR><TD COLSPAN=\"3\" STYLE=\"text-align: left; font-size: 8pt;\">Режимы&nbsp;отображения&nbsp;SA:&nbsp;state \n
               <SELECT NAME=\"sess_state_filter\" ID=\"id_sess_state_filter\" STYLE=\"text-align: left; font-size: 8pt;\">\n" ;
               $is_slctd_sess_stt_fltr = "" ; if ( $pv{sess_state_filter} eq "all_states" ) { $is_slctd_sess_stt_fltr = "SELECTED" ; } print "<OPTION VALUE=\"all_states\">Все [all states]</OPTION>\n" ;
               $is_slctd_sess_stt_fltr = "" ; if ( $pv{sess_state_filter} eq "active" ) { $is_slctd_sess_stt_fltr = "SELECTED" ; } print "<OPTION VALUE=\"active\" $is_slctd_sess_stt_fltr>Активные [active]</OPTION>\n" ;
               $is_slctd_sess_stt_fltr = "" ; if ( $pv{sess_state_filter} eq "all_idle" ) { $is_slctd_sess_stt_fltr = "SELECTED" ; } print "<OPTION VALUE=\"idle\" $is_slctd_sess_stt_fltr>Не активные [all idle]</OPTION>\n" ;
               $is_slctd_sess_stt_fltr = "" ; if ( $pv{sess_state_filter} eq "idle_trns" ) { $is_slctd_sess_stt_fltr = "SELECTED" ; } print "<OPTION VALUE=\"idle_trns\" $is_slctd_sess_stt_fltr>idle transaction</OPTION>\n" ;
               $is_slctd_sess_stt_fltr = "" ; if ( $pv{sess_state_filter} eq "idle_tabrt" ) { $is_slctd_sess_stt_fltr = "SELECTED" ; } print "<OPTION VALUE=\"idle_tabrt\" $is_slctd_sess_stt_fltr>idle transaction break</OPTION>\n" ;
               $is_slctd_sess_stt_fltr = "" ; if ( $pv{sess_state_filter} eq "disabled" ) { $is_slctd_sess_stt_fltr = "SELECTED" ; } print "<OPTION VALUE=\"disabled\" $is_slctd_sess_stt_fltr>Выключено [disabled]</OPTION>\n" ;
        $is_checked_user_backends = "" ; if ( $pv{is_user_backends} eq "true" ) { $is_checked_user_backends = "CHECKED" ; }
        $is_checked_backgrounds = "" ; if ( $pv{is_backgrounds} eq "true" ) { $is_checked_backgrounds = "CHECKED" ; }
        $is_checked_extensions = "" ; if ( $pv{is_extensions} eq "true" ) { $is_checked_extensions = "CHECKED" ; }
#&sess_state_filter=$pv{sess_state_filter}&is_user_backends=$pv{is_user_backends}&is_backgrounds=$pv{is_backgrounds}&is_extensions=$pv{is_extensions}
#,sess_state_filter.value,is_user_backends.value,is_backgrounds.value,is_extensions.value

        print "</SELECT>
        &nbsp;
        <INPUT $is_checked_user_backends VALUE =\"$pv{is_user_backends}\" TYPE=\"checkbox\" NAME=\"is_user_backends\" ID=\"id_is_user_backends\">user backends</INPUT>
        <INPUT $is_checked_backgrounds TYPE=\"checkbox\" NAME=\"is_backgrounds\" ID=\"id_is_backgrounds\">backgrounds</INPUT>
        <INPUT $is_checked_extensions TYPE=\"checkbox\" NAME=\"is_extensions\" ID=\"id_is_extensions\">extensions</INPUT>
    </TD></TR>
    <TR><TD STYLE=\"text-align: left; font-size: 8pt;\">Период&nbsp;с&nbsp;
            <INPUT VALUE=\"$pv{period_from}\" ID=\"id_period_date_start\" STYLE=\"width: 101pt; font-size: 8pt;\"
                   onsubmit=\"renew_db_status_page(id_period_date_start.value,id_period_date_stop.value,id_query_id.value,id_plan_hash.value,id_pid.value,id_serial.value,id_sess_state_filter.value,id_is_user_backends.checked,id_is_backgrounds.checked,id_is_extensions.checked,$pv{tab_detail})\"></TD>
        <TD STYLE=\"text-align: center; font-size: 8pt;\">
            PID&nbsp;<INPUT VALUE=\"$pv{pid}\" ID=\"id_pid\" STYLE=\"width: 48pt; font-size: 8pt;\">&nbsp;
            P_START&nbsp;<INPUT VALUE=\"$pv{serial}\" ID=\"id_serial\" STYLE=\"width: 78pt; font-size: 8pt;\">&nbsp;&nbsp;
            QUERY_ID&nbsp;<INPUT VALUE=\"$pv{query_id}\" ID=\"id_query_id\" STYLE=\"width: 101pt; font-size: 8pt;\">&nbsp;
            PLAN&nbsp;<INPUT VALUE=\"$pv{plan_hash}\" ID=\"id_plan_hash\" STYLE=\"width: 78pt; font-size: 8pt;\" DISABLED>&nbsp;
        </TD>
        <TD STYLE=\"text-align: right; font-size: 8pt;\">Период&nbsp;по&nbsp;
            <INPUT VALUE=\"$pv{period_to}\" ID=\"id_period_date_stop\" STYLE=\"width: 101pt; font-size: 8pt;\"
                   onsubmit=\"renew_db_status_page(id_period_date_start.value,id_period_date_stop.value,id_query_id.value,id_plan_hash.value,id_pid.value,id_serial.value,id_sess_state_filter.value,id_is_user_backends.checked,id_is_backgrounds.checked,id_is_extensions.checked,$pv{tab_detail})\">
            &nbsp;<INPUT TITLE=\"SA - таблица агрегации, WS - таблица агрегации\" TYPE=\"radio\" NAME=\"ds_type\" ID=\"id_ds_type\" VALUE=\"DB\" $is_ds_type_db>DB</INPUT>
            &nbsp;<INPUT TITLE=\"SA - таблица агрегации, WS - сырые данные без агрегации, в зависимости от настроек периодичности срезов возможно резкое замедление\" TYPE=\"radio\" NAME=\"ds_type\" ID=\"id_ds_type\" VALUE=\"MEM\" $is_ds_type_mem>Mem</INPUT>
            &nbsp; <SPAN STYLE=\"font-size: 10pt; color: navy; pointer: arrow;\"
                   onclick=\"renew_db_status_page(id_period_date_start.value,id_period_date_stop.value,id_query_id.value,id_plan_hash.value,id_pid.value,id_serial.value,id_sess_state_filter.value,id_is_user_backends.checked,id_is_backgrounds.checked,id_is_extensions.checked,$pv{tab_detail})\">&nbsp;&nbsp;обновить</SPAN>
        </TD></TR>
    <TR><TD COLSPAN=\"3\">
    <A TARGET=\"_blank\" HREF=\"$base_url/cgi/_graph_pg_SAH_top_activity.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$pv{query_id}&plan_hash=$pv{plan_hash}&pid=$pv{pid}&serial=$pv{serial}&ds_type=$pv{ds_type}&width=1450&height=500\">
           <IMG style=\"width:100%; height: 240pt;\" SRC=\"$base_url/cgi/_graph_pg_SAH_top_activity.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$pv{query_id}&plan_hash=$pv{plan_hash}&pid=$pv{pid}&serial=$pv{serial}&ds_type=$pv{ds_type}&width=2800&height=600\"></A>
    </TD></TR>
    </TABLE>" ;

    print "<STYLE>
          TD { font-size: 10pt; }
          </STYLE>" ;
    }

sub print_sql_table_activity($$$$$$$$$) { my $filter_period_from = $_[0] ; my $filter_period_to = $_[1] ; my $filter_query_id = $_[2] ; my $filter_sql_plan_hash_value = $_[3] ; my $filter_session_id = $_[4] ; my $filter_session_serial = $_[5] ; $source_table_name = $_[6] ; $output_format = $_[7] ; $record_limit = $_[8] ;
    my $where_timepoint = "" ;
    my $where_ext = "" ;
    if ( $filter_period_from eq "" ||  $filter_period_to eq "" ) { die ; }
    $where_timepoint .= " sampling_time >= TO_TIMESTAMP('$filter_period_from','YYYY-MM-DD HH24:MI:SS') " ;
    $where_timepoint .= " AND sampling_time <= TO_TIMESTAMP('$filter_period_to','YYYY-MM-DD HH24:MI:SS')" ;
    if ( $filter_query_id ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } if ( $filter_query_id ne "NULL" ) { $where_ext .= " QUERY_ID = '$filter_query_id'" ; } else { $where_ext .= " QUERY_ID IS NULL" ; } }
    if ( $filter_sql_plan_hash_value ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SQL_PLAN_HASH_VALUE = '$filter_sql_plan_hash_value'" ; }
    if ( $filter_session_id ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SESSION_ID = '$filter_session_id'" ; }
    if ( $filter_session_serial ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SESSION_SERIAL# = '$filter_session_serial'" ; }
    if ( $where_ext ne "" ) { $where_ext = " AND $where_ext" ; }
    print "<TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid; font-size: 10pt;\">";
    my $query_text_substr_size = 30 ;
    if ( $output_format eq "" or $output_format eq "short" ) {
       print "<TR><TD STYLE=\"text-align: center;\">SA Activity Query</TD><TD STYLE=\"text-align: center;\">%</TD><TD STYLE=\"text-align: center;\">Query ID [plan count]</TD><TD STYLE=\"text-align: center;\">Query</TD></TR>\n" ; }
    if ( $output_format eq "long" ) { $query_text_substr_size = 90 ;

print "<TR><TD CLASS=\"td_query_stats_head\" ROWSPAN=\"2\">#</TD><TD CLASS=\"td_query_stats_head\" ROWSPAN=\"2\">SA Activity Query</TD><TD CLASS=\"td_query_stats_head\" ROWSPAN=\"2\">%</TD>
           <TD CLASS=\"td_query_stats_head\" ROWSPAN=\"2\">userid</TD><TD CLASS=\"td_query_stats_head\" ROWSPAN=\"2\">dbid</TD><TD CLASS=\"td_query_stats_head\" ROWSPAN=\"2\">toplevel</TD>
           <TD CLASS=\"td_query_stats_head\" COLSPAN=\"3\">plans</TD><TD CLASS=\"td_query_stats_head\" ROWSPAN=\"2\">calls</TD><TD CLASS=\"td_query_stats_head\" COLSPAN=\"2\">exec</TD>
           <TD CLASS=\"td_query_stats_head\" ROWSPAN=\"2\">rows</TD><TD CLASS=\"td_query_stats_head\" COLSPAN=\"4\">shared_blks</TD><TD CLASS=\"td_query_stats_head\" COLSPAN=\"4\">local_blks</TD>
           <TD CLASS=\"td_query_stats_head\" COLSPAN=\"2\">temp_blks</TD><TD CLASS=\"td_query_stats_head\" COLSPAN=\"2\">blk_time</TD><TD CLASS=\"td_query_stats_head\" COLSPAN=\"2\">temp_blk_time</TD>
           <TD CLASS=\"td_query_stats_head\" COLSPAN=\"3\">WALcalls</TD><TD CLASS=\"td_query_stats_head\" ROWSPAN=\"2\">query</TD></TR>\n

       <TR><TD CLASS=\"td_query_stats_head\">count</TD><TD CLASS=\"td_query_stats_head\">total</TD><TD CLASS=\"td_query_stats_head\">mean</TD>
           <TD CLASS=\"td_query_stats_head\">total ex</TD><TD CLASS=\"td_query_stats_head\">mean ex</TD>
           <TD CLASS=\"td_query_stats_head\">shrd hit</TD><TD CLASS=\"td_query_stats_head\">read</TD><TD CLASS=\"td_query_stats_head\">dirtied</TD><TD CLASS=\"td_query_stats_head\">written</TD>
           <TD CLASS=\"td_query_stats_head\">lcl hit</TD><TD CLASS=\"td_query_stats_head\">read</TD><TD CLASS=\"td_query_stats_head\">dirtied</TD><TD CLASS=\"td_query_stats_head\">written</TD>
           <TD CLASS=\"td_query_stats_head\">read</TD><TD CLASS=\"td_query_stats_head\">written</TD>
           <TD CLASS=\"td_query_stats_head\">read</TD><TD CLASS=\"td_query_stats_head\">written</TD><TD CLASS=\"td_query_stats_head\">read</TD><TD CLASS=\"td_query_stats_head\">written</TD>
           <TD CLASS=\"td_query_stats_head\">records</TD><TD CLASS=\"td_query_stats_head\">fpi</TD><TD CLASS=\"td_query_stats_head\">bytes</TD></TR>\n" ;

#print "<TR><TD STYLE=\"text-align: center;\">SA Activity Query</TD><TD STYLE=\"text-align: center;\">%</TD><TD STYLE=\"text-align: center;\">Query ID [plan count]</TD>
#                  <TD STYLE=\"text-align: center;\">Exec</TD><TD STYLE=\"text-align: center;\">AVG Time<BR>per exec</TD><TD STYLE=\"text-align: center;\">Plans count</TD><TD STYLE=\"text-align: center;\">Query</TD></TR>\n" ;
    }

    my $source_table_name = "bestat_sa_history" ; if ($pv{ds_type} eq "DB") { $source_table_name = "bestat_sa_history" ; }
    $request_top_sql = "select ds_1.percent, ds_1.query_id
                               from ( select round(a1.count_point * 100 / a2.sum_count_point::numeric, 4) percent, a1.query_id
                                             from (select 'ok' ok1, count(*) count_point, query_id
                                                  from $source_table_name
                                                  where $where_timepoint $where_ext
                                                  group by query_id) a1,
                                    (select 'ok' ok1, count(*) sum_count_point
                                            from $source_table_name
                                            where $where_timepoint $where_ext) a2
                                    where a1.ok1 = a2.ok1
                               order by 1 desc) ds_1 LIMIT $record_limit" ;
# AND NOT query_id = 0
#open(DEBG,">/tmp/print_sql_table_activity.out") ; print DEBG $request_top_sql ;
#-debug-print "<PRE>$request_top_sql</PRE>" ;
    my $dbh_top_sql = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'cryptapwd');
    my $sth_top_sql  = $dbh_top_sql->prepare($request_top_sql ) ; $sth_top_sql->execute() ;
    my $rows_count = 0 ;
    while (my ( $percent, $query_id, $count_point ) = $sth_top_sql->fetchrow_array() ) { $rows_count++ ;
#-debug-print "<BR># = $rows_count<BR>" ;
# вытащить текст запроса
          my $curr_query_text_substr = "" ; my $curr_count_query_text_substr = 0 ;
          if ( $query_id eq "" ) { $curr_query_text_substr = "не определяется" ;
             }
          else {
             my $request_curr_query_text_substr = "select substr(query,1,$query_text_substr_size) from pg_stat_statements where queryid = $query_id" ;
             my $dbh_curr_query_text_substr = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'cryptapwd');
             my $sth_curr_query_text_substr  = $dbh_curr_query_text_substr->prepare($request_curr_query_text_substr ) ; $sth_curr_query_text_substr->execute() ;
             while (my ($res_curr_query_text_substr) = $sth_curr_query_text_substr->fetchrow_array()) { $curr_count_query_text_substr++ ; $curr_query_text_substr = $res_curr_query_text_substr ; }
             if ( $curr_query_text_substr eq "" || $curr_count_query_text_substr == 0 ) {
                $sth_curr_query_text_substr->finish() ;
                $request_curr_query_text_substr = "select substr(query,1,$query_text_substr_size) from pg_stat_activity where query_id = $query_id" ;
                $sth_curr_query_text_substr  = $dbh_curr_query_text_substr->prepare($request_curr_query_text_substr ) ; $sth_curr_query_text_substr->execute() ; 
                while (($res_curr_query_text_substr) = $sth_curr_query_text_substr->fetchrow_array()) { $curr_query_text_substr = $res_curr_query_text_substr ; }
                }
             $sth_curr_query_text_substr->finish() ; $dbh_curr_query_text_substr->disconnect() ;
             $curr_query_text_substr =~ s/\n/&nbsp;/g ;
             }
# напечатать строку таблицы для короткого формата
          if ( $output_format eq "" or $output_format eq "short" ) {
             print "\n<TR>\n<TD TITLE=\"#: $rows_count\">" ;
             print_activity_graph($pv{period_from}, $pv{period_to}, $query_id, '', '', '', $percent, $source_table_name) ;
             print "</TD>\n" ;
             print "<TD STYLE=\"text-align: right; font-size: 10pt;\">$percent</TD>\n" ;
             print "<TD><A HREF=\"http://zrt.ourorbits.ru/crypta/cgi/tools_pg_monitor_TA_query.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$query_id&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&page_part=1&srcptr=&child_number=\">$query_id</A></TD>
                    <TD>$curr_query_text_substr ...</TD>\n" ; }
# напечатать строку таблицы для длинного формата
         if ( $output_format eq "long" ) {
            $request_query_id_stats = "
select userid,dbid,toplevel,sum(plans),round(sum(total_plan_time)::numeric,2),round(avg(mean_plan_time)::numeric,2),sum(calls),round(sum(total_exec_time)::numeric,2),round(avg(mean_exec_time)::numeric,2),
       sum(rows),round((sum(shared_blks_hit*calls)/sum(calls))::numeric,2),round(sum(shared_blks_read)::numeric,2),round(sum(shared_blks_dirtied)::numeric,2),round(sum(shared_blks_written)::numeric,2),
       round((sum(local_blks_hit*calls)/sum(calls))::numeric,2),round(sum(local_blks_read)::numeric,2),round(sum(local_blks_dirtied)::numeric,2),round(sum(local_blks_written)::numeric,2),
       round(sum(temp_blks_read)::numeric,2),round(sum(temp_blks_written)::numeric,2),round(sum(blk_read_time)::numeric,2),round(sum(blk_write_time)::numeric,2),round(sum(temp_blk_read_time)::numeric,2),
       round(sum(temp_blk_write_time)::numeric,2),round(sum(wal_records)::numeric,2),round(sum(wal_fpi)::numeric,2),round(sum(wal_bytes)::numeric,2)
       from pg_stat_statements where queryid = $query_id group by userid,dbid,toplevel " ;
#-debug-print "<PRE>$request_query_id_stats</PRE>" ;
            my $dbh_query_id_stats = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'cryptapwd');
            my $sth_query_id_stats  = $dbh_query_id_stats->prepare($request_query_id_stats) ; $sth_query_id_stats->execute() ;
#-debug-print "<BR>qi = $query_id<BR>" ;
            my $query_stats_count_rows = 0 ;
            while (my($userid,$dbid,$toplevel,$plans,$total_plan_time,$mean_plan_time,$calls,$total_exec_time,$mean_exec_time,$rows,$shared_blks_hit,$shared_blks_read,$shared_blks_dirtied,$shared_blks_written,$local_blks_hit,$local_blks_read,$local_blks_dirtied,$local_blks_written,$temp_blks_read,$temp_blks_written,$blk_read_time,$blk_write_time,$temp_blk_read_time,$temp_blk_write_time,$wal_records,$wal_fpi,$wal_bytes) = $sth_query_id_stats->fetchrow_array()) {
                  $query_stats_count_rows++ ;
                  print "\n<TR>\n<TD>$rows_count</TD><TD>" ;
                  print_activity_graph($pv{period_from}, $pv{period_to}, $query_id, '', '', '', $percent, $source_table_name) ;
                  print "</TD>\n" ;
                  print "<TD STYLE=\"text-align: right; font-size: 10pt;\">$percent</TD>\n" ;
                  print "<TD>$userid</TD><TD>$dbid</TD><TD>$toplevel</TD><TD>$plans</TD><TD>$total_plan_time</TD><TD>$mean_plan_time</TD><TD>$calls</TD><TD>$total_exec_time</TD><TD>$mean_exec_time</TD><TD>$rows</TD><TD>$shared_blks_hit</TD>
                         <TD>$shared_blks_read</TD><TD>$shared_blks_dirtied</TD><TD>$shared_blks_written</TD><TD>$local_blks_hit</TD><TD>$local_blks_read</TD><TD>$local_blks_dirtied</TD><TD>$local_blks_written</TD><TD>$temp_blks_read</TD>
                         <TD>$temp_blks_written</TD><TD>$blk_read_time</TD><TD>$blk_write_time</TD><TD>$temp_blk_read_time</TD><TD>$temp_blk_write_time</TD><TD>$wal_records</TD><TD>$wal_fpi</TD><TD>$wal_bytes</TD>\n" ;
                  print "<TD STYLE=\"width: 400pt;\"><A HREF=\"http://zrt.ourorbits.ru/crypta/cgi/tools_pg_monitor_TA_query.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$query_id&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}\">$curr_query_text_substr ...</A></TD>\n" ; }
            $sth_query_id_stats->finish() ;
            $dbh_query_id_stats->disconnect() ;
            if ($query_stats_count_rows == 0) {
               print "\n<TR>\n<TD>$rows_count</TD><TD>" ;
               print_activity_graph($pv{period_from}, $pv{period_to}, $query_id, '', '', '', $percent, $source_table_name) ;
               print "</TD>\n" ;
               print "<TD STYLE=\"text-align: right; font-size: 10pt;\">$percent</TD>\n" ;
               print "<TD COLSPAN=\"27\">статистики для запроса не найдены ...</TD>\n" ;
               print "<TD STYLE=\"width: 400pt;\"><A HREF=\"http://zrt.ourorbits.ru/crypta/cgi/tools_pg_monitor_TA_query.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$query_id&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}\">$curr_query_text_substr ...</A></TD>\n" ;
               }
            }
         print "</TR>\n" ;
         }
    $sth_top_sql->finish() ;
    $dbh_top_sql->disconnect() ;
    print "</TABLE>" ;
    }

sub print_session_table_activity($$$$$$$$) { my $filter_period_from = $_[0] ; my $filter_period_to = $_[1] ; my $filter_query_id = $_[2] ; my $filter_sql_plan_hash_value = $_[3] ; my $filter_session_id = $_[4] ; my $filter_session_serial = $_[5] ; $source_table_name = $_[6] ; $output_format = $_[7] ; $record_limit = $_[8] ;
    my $where_timepoint = "" ;
    my $where_ext = "" ;
    if ( $filter_period_from eq "" ||  $filter_period_to eq "" ) { die ; }
    if ( $record_limit eq "" ) { $record_limit = 20 ; }
    $where_timepoint .= " sampling_time >= TO_TIMESTAMP('$filter_period_from','YYYY-MM-DD HH24:MI:SS') " ;
    $where_timepoint .= " AND sampling_time <= TO_TIMESTAMP('$filter_period_to','YYYY-MM-DD HH24:MI:SS')" ;
    if ( $filter_query_id ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } if ( $filter_query_id ne "NULL" ) { $where_ext .= " QUERY_ID = '$filter_query_id'" ; } else { $where_ext .= " QUERY_ID IS NULL" ; } }
    if ( $filter_sql_plan_hash_value ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SQL_PLAN_HASH_VALUE = '$filter_sql_plan_hash_value'" ; }
    if ( $filter_session_id ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SESSION_ID = '$filter_session_id'" ; }
    if ( $filter_session_serial ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SESSION_SERIAL# = '$filter_session_serial'" ; }
    if ( $where_ext ne "" ) { $where_ext = " AND $where_ext" ; }
    print "<TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">
            <TR><TD STYLE=\"text-align: center;\">SA Activity Session</TD><TD STYLE=\"text-align: center;\">%</TD><TD STYLE=\"text-align: center;\">Process ID</TD>" ;
    if ( $output_format eq "" or $output_format eq "short" ) {
       print "<TD STYLE=\"text-align: center;\">Username</TD><TD STYLE=\"text-align: center;\">Application</TD></TR>"; }
    if ( $output_format eq "long" ) {
       print "<TD STYLE=\"text-align: center;\">backend_start</TD><TD STYLE=\"text-align: center;\">client_hostname</TD><TD STYLE=\"text-align: center;\">client_addr</TD><TD STYLE=\"text-align: center;\">client_port</TD><TD STYLE=\"text-align: center;\">usesysid</TD>
              <TD STYLE=\"text-align: center;\">Username</TD><TD STYLE=\"text-align: center;\">Application</TD><TD STYLE=\"text-align: center;\">Backend type</TD></TR>"; }
    $request_top_sess = "select ds_1.percent, ds_1.pid, ds_1.backend_start, ds_1.datname, ds_1.usesysid, ds_1.usename, ds_1.application_name, ds_1.client_addr, ds_1.client_hostname, ds_1.client_port, ds_1.backend_type
                                from ( select round(a1.count_point * 100 / a2.sum_count_point::numeric, 4) percent, a1.pid, a1.backend_start, a1.datname, a1.usesysid, a1.usename,
                                              a1.application_name, a1.client_addr, a1.client_hostname, a1.client_port, a1.backend_type
                                              from (select 'ok' ok1, count(*) count_point, pid, backend_start, datname, usesysid, usename, application_name, client_addr, client_hostname, client_port, backend_type
                                                           from $source_table_name
                                                           where $where_timepoint $where_ext
                                                           group by pid, backend_start, datname, usesysid, usename, application_name, client_addr, client_hostname, client_port, backend_type) a1,
                                                   (select 'ok' ok1, count(*) sum_count_point
                                                           from $source_table_name
                                                           where $where_timepoint $where_ext) a2
                                              where a1.ok1 = a2.ok1
                                              order by 1 desc) ds_1 LIMIT $record_limit" ;
#open(DEBG,">/tmp/print_pid_table_activity.out") ; print DEBG $request_top_sess ;
    my $dbh_top_sess = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'cryptapwd');
    my $sth_top_sess  = $dbh_top_sess ->prepare($request_top_sess ) ; $sth_top_sess->execute() ;
    while (my ( $percent, $pid, $backend_start, $datname, $usesysid, $username, $application_name, $client_addr, $client_hostname, $client_port, $backend_type ) = $sth_top_sess->fetchrow_array() ) {
          print "<TR><TD>" ;
          print_activity_graph($pv{period_from}, $pv{period_to}, '', '', $pid, $backend_start, $percent, $source_table_name) ;
          print "</TD><TD>$percent</TD>" ;
          if ( $output_format eq "" or $output_format eq "short" ) {
             print "<TD><A HREF=\"http://zrt.ourorbits.ru/crypta/cgi/get_session_info.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=$pid&serial=$serial&ds_type=$pv{ds_type}&page_part=1\" TITLE=\"backend started: $backend_start, from host [$client_hostname], IP [$client_addr], port [$client_port]\">$pid</A></TD>
                    <TD TITLE=\"User ID: $usesysid\">$username</TD><TD TITLE=\"$backend_type\">$application_name</TD></TR>" ; }
          if ( $output_format eq "long" ) {
             print "<TD><A HREF=\"http://zrt.ourorbits.ru/crypta/cgi/get_session_info.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=$pid&serial=$serial&ds_type=$pv{ds_type}&page_part=1\">$pid</A></TD>
<TD>$backend_start</TD><TD>$client_hostname</TD><TD>$client_addr</TD><TD>$client_port</TD><TD>$usesysid</TD><TD>$username</TD><TD>$application_name</TD><TD>$backend_type</TD></TR>" ; }
          }
    $sth_top_sess->finish() ;
    $dbh_top_sess->disconnect() ;
    print "</TABLE>" ;
    }

sub print_wait_sampling_activity_graph($$$$$$$$) { my $filter_period_from = $_[0] ; my $filter_period_to = $_[1] ; my $filter_query_id = $_[2] ; my $filter_sql_plan_hash_value = $_[3] ; my $filter_pid = $_[4] ; my $filter_session_serial = $_[5] ; my $percent = $_[6] ; $source_table_name = $_[7] ;
#-debug-$pv{period_from} = "2024-05-02 00:00:00" ; $pv{period_to} = "2025-06-03 00:00:00" ; $pv{ds_type} = "MEM" ; $pv{width} = 1500 ; $pv{height} = 700 ;
    $request_chart_per_class = " " ;
#####
my $source_table_name = "pg_wait_sampling_history" ; if ($pv{ds_type} eq "DB") { $source_table_name = "bestat_ws_history" ; }
    my $where_timepoint = "" ;
    my $where_ext = "" ;
    if ( $pv{period_from} eq "" ||  $pv{period_to} eq "" ) { die ; }
    $where_timepoint .= " ts >= TO_TIMESTAMP('$pv{period_from}','YYYY-MM-DD HH24:MI:SS') " ;
    $where_timepoint .= " AND ts <= TO_TIMESTAMP('$pv{period_to}','YYYY-MM-DD HH24:MI:SS')" ;

    if ( $filter_query_id ne "" ) { $where_ext .= " AND queryid = $filter_query_id" ; }
#    if ( $filter_sql_plan_hash_value ne "" ) { $where_ext .= " AND SQL_PLAN_HASH_VALUE = '$filter_sql_plan_hash_value'" ; }
    if ( $filter_pid ne "" ) { $where_ext .= " AND pid = $filter_pid" ; }
#    if ( $filter_session_serial ne "" ) { $where_ext .= " AND SESSION_SERIAL# = '$filter_session_serial'" ; }

if ($pv{ds_type} eq "MEM") {
   $request_chart_per_class = "
select sum(src2.wc_Activity) wc_Activity, sum(src2.wc_BufferPin) wc_BufferPin,
       sum(src2.wc_Client) wc_Client, sum(src2.wc_Extension) wc_Extension, sum(src2.wc_IO) wc_IO,
       sum(src2.wc_IPC) wc_IPC, sum(src2.wc_Lock) wc_Lock, sum(src2.wc_LWLock) wc_LWLock,
       sum(src2.wc_Timeout) wc_Timeout, sum(src2.wc_Other) wc_Other
       from (select src1.ts,
            CASE WHEN src1.event_type = 'Activity' THEN src1.value ELSE 0 END wc_Activity,
            CASE WHEN src1.event_type = 'BufferPin' THEN src1.value ELSE 0 END wc_BufferPin,
            CASE WHEN src1.event_type = 'Client' THEN src1.value ELSE 0 END wc_Client,
            CASE WHEN src1.event_type = 'Extension' THEN src1.value ELSE 0 END wc_Extension,
            CASE WHEN src1.event_type = 'IO' THEN src1.value ELSE 0 END wc_IO,
            CASE WHEN src1.event_type = 'IPC' THEN src1.value ELSE 0 END wc_IPC,
            CASE WHEN src1.event_type = 'Lock' THEN src1.value ELSE 0 END wc_Lock,
            CASE WHEN src1.event_type = 'LWLock' THEN src1.value ELSE 0 END wc_LWLock,
            CASE WHEN src1.event_type = 'Timeout' THEN src1.value ELSE 0 END wc_Timeout,
            CASE WHEN src1.event_type NOT IN ('Activity','BufferPin','Client','Extension','IO','IPC','Lock','LWLock','Timeout')
                                      THEN src1.value ELSE 0 END wc_Other
            from (select ash.ts ts, ash.event_type event_type, round(sum(ash.value)/6000,4) value
                         from (select date_trunc('minute', ts) ts, event_type, count(*) value
                                      from $source_table_name
                                      where $where_timepoint $where_ext
                                      group by date_trunc('minute', ts), event_type) ash
                         group by ash.ts, ash.event_type) src1 ) src2 " ;
#                         where ash.EVENT_TYPE IS NOT NULL
   }
if ($pv{ds_type} eq "DB") {
   $request_chart_per_class = "
select sum(src2.wc_Activity) wc_Activity, sum(src2.wc_BufferPin) wc_BufferPin,
       sum(src2.wc_Client) wc_Client, sum(src2.wc_Extension) wc_Extension, sum(src2.wc_IO) wc_IO,
       sum(src2.wc_IPC) wc_IPC, sum(src2.wc_Lock) wc_Lock, sum(src2.wc_LWLock) wc_LWLock,
       sum(src2.wc_Timeout) wc_Timeout, sum(src2.wc_Other) wc_Other
       from (select src1.ts,
            CASE WHEN src1.event_type = 'Activity' THEN src1.value ELSE 0 END wc_Activity,
            CASE WHEN src1.event_type = 'BufferPin' THEN src1.value ELSE 0 END wc_BufferPin,
            CASE WHEN src1.event_type = 'Client' THEN src1.value ELSE 0 END wc_Client,
            CASE WHEN src1.event_type = 'Extension' THEN src1.value ELSE 0 END wc_Extension,
            CASE WHEN src1.event_type = 'IO' THEN src1.value ELSE 0 END wc_IO,
            CASE WHEN src1.event_type = 'IPC' THEN src1.value ELSE 0 END wc_IPC,
            CASE WHEN src1.event_type = 'Lock' THEN src1.value ELSE 0 END wc_Lock,
            CASE WHEN src1.event_type = 'LWLock' THEN src1.value ELSE 0 END wc_LWLock,
            CASE WHEN src1.event_type = 'Timeout' THEN src1.value ELSE 0 END wc_Timeout,
            CASE WHEN src1.event_type NOT IN ('Activity','BufferPin','Client','Extension','IO','IPC','Lock','LWLock','Timeout')
                                      THEN src1.value ELSE 0 END wc_Other
            from (select ash.ts ts, ash.event_type event_type, round(sum(ash.value)/6000,4) value
                         from (select date_trunc('minute', ts) ts, event_type, sum(events_count) value
                                      from $source_table_name
                                      where $where_timepoint $where_ext
                                      group by date_trunc('minute', ts), event_type) ash
                         group by ash.ts, ash.event_type) src1 ) src2 " ;
     }
#-debug-print "<BR>$request_chart_per_class<BR>" ;

    my $white_spaces = 100 - $percent ;
    my $count_class = 0 ;
#-debug-print "<BR>!!! pre sql ws = $white_spaces, prc = $percent<BR>" ;
    my $dbh_chart_per_class = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'cryptapwd' ) ;
    my $sth_chart_per_class = $dbh_chart_per_class->prepare($request_chart_per_class) ; $sth_chart_per_class->execute() ; $count_rows = 0 ;

#-debug-print "<BR>!!! execute sql<BR>" ;
    while (my ($wc_Activity, $wc_BufferPin, $wc_Client, $wc_Extension, $wc_IO, $wc_IPC, $wc_Lock, $wc_LWLock, $wc_Timeout, $wc_Other) = $sth_chart_per_class->fetchrow_array() ) {
          $count_class++ ;
          my $tmp_sum =  $wc_Activity + $wc_BufferPin + $wc_Client + $wc_Extension + $wc_IO + $wc_IPC + $wc_Lock + $wc_LWLock + $wc_Timeout + $wc_Other ;
#-debug-print "<BR>--$white_spaces -- $tmp_sum --" ;
#-debug-print "<BR>\n - class - tmp_sum $tmp_sum, queryid $query_id, time $begin_time, actSess $wc_ActiveSession, concurr $wc_Concurrency, userIO $wc_UserIO, systemIO $wc_SystemIO, other $wc_Other, config $wc_Configuration, sched $wc_Scheduler, cpu $wc_CPU, app $wc_Application, commit $wc_Commit, net $wc_Network, admin $wc_Administrative, clust $wc_Cluster\n" ;
          $wc_Activity = sprintf("%.1f", $wc_Activity * $percent / $tmp_sum) ;
          $wc_BufferPin = sprintf("%.1f", $wc_BufferPin * $percent / $tmp_sum) ;
          $wc_Client = sprintf("%.1f", $wc_Client * $percent / $tmp_sum) ;
          $wc_Extension = sprintf("%.1f", $wc_Extension  * $percent / $tmp_sum) ;
          $wc_IO = sprintf("%.1f", $wc_IO * $percent / $tmp_sum) ;
          $wc_IPC = sprintf("%.1f", $wc_IPC * $percent / $tmp_sum) ;
          $wc_Lock = sprintf("%.1f", $wc_Lock * $percent / $tmp_sum) ;
          $wc_LWLock = sprintf("%.1f", $wc_LWLock * $percent / $tmp_sum) ;
          $wc_Timeout = sprintf("%d", $wc_Timeout * $percent / $tmp_sum) ;
          $wc_Other = sprintf("%d", $wc_Other * $percent / $tmp_sum) ;
#-debug-print "<BR>\n - class - tmp_sum $tmp_sum, queryid $query_id, time $begin_time, actSess $wc_ActiveSession, concurr $wc_Concurrency, userIO $wc_UserIO, systemIO $wc_SystemIO, other $wc_Other, config $wc_Configuration, sched $wc_Scheduler, cpu $wc_CPU, app $wc_Application, commit $wc_Commit, net $wc_Network, admin $wc_Administrative, clust $wc_Cluster\n" ;
          print "<TABLE WIDTH=\"200pt;\" HEIGHT=\"15pt;\" CELLPADDING=\"0\" CELLSPACING=\"0\"><TR>" ;
          if ( $wc_Activity > 0 ) { print "<TD TITLE=\"Activity $wc_Activity\%\" STYLE=\"width: $wc_Activity\%; height: 15pt; background-color: lime;\">&nbsp;</TD>" ; }
          if ( $wc_BufferPin > 0 ) { print "<TD TITLE=\"BufferPin $wc_BufferPin\%\" STYLE=\"width: $wc_BufferPin\%; height: 15pt; background-color: pink;\">&nbsp;</TD>" ; }
          if ( $wc_Client > 0 ) { print "<TD TITLE=\"Client $wc_Client\%\" STYLE=\"width: $wc_Client\%; height: 15pt; background-color: cyan;\">&nbsp;</TD>" ; }
          if ( $wc_Extension > 0 ) { print "<TD TITLE=\"Extension $wc_Extension\%\" STYLE=\"width: $wc_Extension\%; height: 15pt; background-color: slateblue;\">&nbsp;</TD>" ; }
          if ( $wc_IO > 0 ) { print "<TD TITLE=\"IO $wc_IO\%\" STYLE=\"width: $wc_IO\%; height: 15pt; background-color: navy;\">&nbsp;</TD>" ; }
          if ( $wc_IPC > 0 ) { print "<TD TITLE=\"IPC $wc_IPC\%\" STYLE=\"width: $wc_IPC\%; height: 15pt; background-color: orange;\">&nbsp;</TD>" ; }
          if ( $wc_Lock > 0 ) { print "<TD TITLE=\"Lock $wc_Lock\%\" STYLE=\"width: $wc_Lock\%; height: 15pt; background-color: darkred;\">&nbsp;</TD>" ; }
          if ( $wc_LWLock > 0 ) { print "<TD TITLE=\"LWLock $wc_LWLock\%\" STYLE=\"width: $wc_LWLock\%; height: 15pt; background-color: red;\">&nbsp;</TD>" ; }
          if ( $wc_Timeout > 0 ) { print "<TD TITLE=\"Timeout $wc_Timeout\%\" STYLE=\"width: $wc_Timeout\%; height: 15pt; background-color: lightgray;\">&nbsp;</TD>" ; }
          if ( $wc_Other > 0 ) { print "<TD TITLE=\"Other $wc_Other\%\" STYLE=\"width: $wc_Other\%; height: 15pt; background-color: black;\">&nbsp;</TD>" ; }
          print "<TD STYLE=\"width: $white_spaces\%; height: 15pt; background-color: white;\">&nbsp;</TD>" ;
          print "</TR></TABLE>" ; }
    $sth_chart_per_class->finish() ;
    $dbh_chart_per_class->disconnect() ;
#-debug- for ($i=0;$i<=$count_rows;$i++) { print "$avg_data_source[0][$i] $avg_data_source[1][$i] $avg_data_source[2][$i] $avg_data_source[3][$i] $avg_data_source[4][$i] $avg_data_source[5][$i]\n" ; } exit 0 ;
#-debug-print "<BR>\n$request_chart_per_class" ;
    }

sub print_wait_sampling_head_ash_graph() {
    $sz_current_date_short = `date "+%Y-%m-%d 00:00:00"` ;
    $sz_current_date = `date "+%Y-%m-%d 23:59:59"` ;
    $pv{period_from} = ( $pv{period_from} eq "" ) ? $sz_current_date_short : $pv{period_from} ;
    $pv{period_to} = ( $pv{period_to} eq "" ) ? $sz_current_date : $pv{period_to} ;
    if ($pv{ds_type} eq "") { $pv{ds_type} = "DB" ; } my $is_ds_type_db = "" ; my $is_ds_type_mem = " CHECKED" ; if ($pv{ds_type} eq "DB") { $is_ds_type_db = " CHECKED" ; $is_ds_type_mem = "" ; }
    $pv{serial} = "" ; $pv{plan_hash} = "NO in PG vanilla" ;
    print "<TABLE STYLE=\"width: 100%\">
    <TR><TD STYLE=\"text-align: left;\">График&nbsp;с&nbsp;<INPUT VALUE=\"$pv{period_from}\" ID=\"id_period_date_start\" STYLE=\"width: 101pt;\"></TD>
        <TD STYLE=\"text-align: center;\">
            PID&nbsp;<INPUT VALUE=\"$pv{pid}\" ID=\"id_pid\" STYLE=\"width: 49pt;\">&nbsp;
            P_START&nbsp;<INPUT VALUE=\"$pv{serial}\" ID=\"id_serial\" STYLE=\"width: 79pt;\">&nbsp;&nbsp;
            QUERY_ID&nbsp;<INPUT VALUE=\"$pv{query_id}\" ID=\"id_query_id\" STYLE=\"width: 101pt;\">&nbsp;
            PLAN&nbsp;<INPUT VALUE=\"$pv{plan_hash}\" ID=\"id_plan_hash\" STYLE=\"width: 79pt;\" DISABLED>&nbsp;
        </TD>
        <TD STYLE=\"text-align: right;\">График&nbsp;по&nbsp;<INPUT VALUE=\"$pv{period_to}\" ID=\"id_period_date_stop\" STYLE=\"width: 101pt;\">
           &nbsp;<INPUT TITLE=\"Смотреть данные в таблице агрегации\" TYPE=\"radio\" NAME=\"ds_type\" ID=\"id_ds_type\" VALUE=\"DB\" $is_ds_type_db>DB</INPUT>
           &nbsp;<INPUT TITLE=\"Смотреть данные в структурах памяти\" TYPE=\"radio\" NAME=\"ds_type\" ID=\"id_ds_type\" VALUE=\"MEM\" $is_ds_type_mem>Mem</INPUT>
           &nbsp; <SPAN STYLE=\"font-size: 11pt; color: navy; pointer: arrow;\"
                  onclick=\"renew_wait_sampling_db_status_page(id_period_date_start.value,id_period_date_stop.value,id_query_id.value,id_plan_hash.value,id_pid.value,id_serial.value,$pv{page_part})\">&nbsp;&nbsp;обновить</SPAN>
        </TD></TR>
    <TR><TD COLSPAN=\"3\">
    <A TARGET=\"_blank\" HREF=\"$base_url/cgi/_graph_pg_WS_top_activity.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$pv{query_id}&plan_hash=$pv{plan_hash}&pid=$pv{pid}&serial=$pv{serial}&ds_type=$pv{ds_type}&width=1450&height=500\">
           <IMG style=\"width:100%; height: 240pt;\" SRC=\"$base_url/cgi/_graph_pg_WS_top_activity.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$pv{query_id}&plan_hash=$pv{plan_hash}&pid=$pv{pid}&serial=$pv{serial}&ds_type=$pv{ds_type}&width=2800&height=600\"></A>
    </TD></TR>
    </TABLE>" ;
    }

sub print_wait_sampling_sql_table_activity($$$$$$$) { my $filter_period_from = $_[0] ; my $filter_period_to = $_[1] ; my $filter_query_id = $_[2] ; my $filter_sql_plan_hash_value = $_[3] ; my $filter_session_id = $_[4] ; my $filter_session_serial = $_[5] ; $source_table_name = $_[6] ;
    my $source_table_name = "pg_wait_sampling_history" ; if ($pv{ds_type} eq "DB") { $source_table_name = "bestat_ws_history" ; }
    my $where_timepoint = "" ;
    my $where_ext = "" ;
    if ( $filter_period_from eq "" ||  $filter_period_to eq "" ) { die ; }
    $where_timepoint .= " ts >= TO_TIMESTAMP('$filter_period_from','YYYY-MM-DD HH24:MI:SS') " ;
    $where_timepoint .= " AND ts <= TO_TIMESTAMP('$filter_period_to','YYYY-MM-DD HH24:MI:SS')" ;
    if ( $filter_query_id ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " QUERYID = '$filter_query_id'" ; }
    if ( $filter_sql_plan_hash_value ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SQL_PLAN_HASH_VALUE = '$filter_sql_plan_hash_value'" ; }
    if ( $filter_session_id ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SESSION_ID = '$filter_session_id'" ; }
    if ( $filter_session_serial ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SESSION_SERIAL# = '$filter_session_serial'" ; }
    if ( $where_ext ne "" ) { $where_ext = " AND $where_ext" ; }
    print "<TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">
        <TR><TD>WS Activity Query</TD><TD>%</TD><TD>Query ID [plan count]</TD><TD>Query</TD></TR>" ;
    if ($pv{ds_type} eq "MEM") {
       $request_top_sql = "select * from ( select round(a1.count_point * 100 / a2.sum_count_point::numeric, 4) percent, a1.queryid
              from (select 'ok' ok1, count(*) count_point, queryid
                           from $source_table_name
                           where $where_timepoint $where_ext
                           group by queryid) a1,
                   (select 'ok' ok1, count(*) sum_count_point
                           from $source_table_name
                           where $where_timepoint $where_ext) a2
               where a1.ok1 = a2.ok1
               order by 1 desc) ds_1 LIMIT 30" ;
       }
    if ($pv{ds_type} eq "DB") {
       $request_top_sql = "select * from ( select round(a1.count_point * 100 / a2.sum_count_point::numeric, 4) percent, a1.queryid
              from (select 'ok' ok1, sum(events_count) count_point, queryid
                           from $source_table_name
                           where $where_timepoint $where_ext
                           group by queryid) a1,
                   (select 'ok' ok1, sum(events_count) sum_count_point
                           from $source_table_name
                           where $where_timepoint $where_ext) a2
               where a1.ok1 = a2.ok1
               order by 1 desc) ds_1 LIMIT 30" ;
       }
#open(DEBG,">/tmp/print_sess_table_activity.out") ; print DEBG $request_top_sql ;
#-debug-print "<BR>ds_type = $pv{ds_type} == $request_top_sql<BR>" ;
    my $dbh_top_sql = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'cryptapwd');
    my $sth_top_sql  = $dbh_top_sql->prepare($request_top_sql ) ; $sth_top_sql->execute() ;
    while (my ( $percent, $query_id, $count_point ) = $sth_top_sql->fetchrow_array() ) {
          print "<TR><TD>" ;
          print_wait_sampling_activity_graph($pv{period_from}, $pv{period_to}, $query_id, '', '', '', $percent, $source_table_name) ;

          if ( $query_id eq "" ) { $query_id = "NULL" ; }
          my $curr_query_text_substr = "" ; my $curr_count_query_text_substr = 0 ;
          my $request_curr_query_text_substr = "select substr(query,1,30) from pg_stat_statements where queryid = $query_id" ;
          my $dbh_curr_query_text_substr = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'cryptapwd');
          my $sth_curr_query_text_substr  = $dbh_curr_query_text_substr->prepare($request_curr_query_text_substr ) ; $sth_curr_query_text_substr->execute() ;
          while (my ($res_curr_query_text_substr) = $sth_curr_query_text_substr->fetchrow_array()) { $curr_count_query_text_substr++ ; $curr_query_text_substr = $res_curr_query_text_substr ; }
          if ( $curr_query_text_substr eq "" || $curr_count_query_text_substr == 0 ) {
             $sth_curr_query_text_substr->finish() ;
             $request_curr_query_text_substr = "select substr(query,1,30) from pg_stat_activity where query_id = $query_id" ;
             $sth_curr_query_text_substr  = $dbh_curr_query_text_substr->prepare($request_curr_query_text_substr ) ; $sth_curr_query_text_substr->execute() ; ($curr_query_text_substr) = $sth_curr_query_text_substr->fetchrow_array() ;
             }
          $sth_curr_query_text_substr->finish() ; $dbh_curr_query_text_substr->disconnect() ;


          print "</TD><TD STYLE=\"text-align: right; font-size: 10pt;\">$percent</TD>
                 <TD><A HREF=\"http://zrt.ourorbits.ru/crypta/cgi/tools_pg_monitor_TA_query.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$query_id&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&page_part=1&srcptr=&child_number=\">$query_id</A></TD><TD>$curr_query_text_substr ...</TD></TR>" ;
#                 <TD><A HREF=\"http://zrt.ourorbits.ru/crypta/cgi/       get_sql_info_by_id.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=$query_id&plan_hash=&pid=&serial=&ds_type=$pv{ds_type}&page_part=1&srcptr=&child_number=\">$query_id</A></TD><TD></TD><TD>&nbsp;</TD></TR>" ;
          }
    $sth_top_sql->finish() ;
    $dbh_top_sql->disconnect() ;
    print "</TABLE>" ;
    }

sub print_wait_sampling_session_table_activity($$$$$$$) { my $filter_period_from = $_[0] ; my $filter_period_to = $_[1] ; my $filter_query_id = $_[2] ; my $filter_sql_plan_hash_value = $_[3] ; my $filter_session_id = $_[4] ; my $filter_session_serial = $_[5] ; $source_table_name = $_[6] ;
    my $source_table_name = "pg_wait_sampling_history" ; if ($pv{ds_type} eq "DB") { $source_table_name = "bestat_ws_history" ; }
    my $where_timepoint = "" ;
    my $where_ext = "" ;
    if ( $filter_period_from eq "" ||  $filter_period_to eq "" ) { die ; }
    $where_timepoint .= " ts >= TO_TIMESTAMP('$filter_period_from','YYYY-MM-DD HH24:MI:SS') " ;
    $where_timepoint .= " AND ts <= TO_TIMESTAMP('$filter_period_to','YYYY-MM-DD HH24:MI:SS')" ;
    if ( $filter_query_id ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " QUERYID = '$filter_query_id'" ; }
    if ( $filter_sql_plan_hash_value ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SQL_PLAN_HASH_VALUE = '$filter_sql_plan_hash_value'" ; }
    if ( $filter_session_id ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SESSION_ID = '$filter_session_id'" ; }
    if ( $filter_session_serial ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SESSION_SERIAL# = '$filter_session_serial'" ; }
    if ( $where_ext ne "" ) { $where_ext = " AND $where_ext" ; }
    print "<TABLE BORDER=\"1\" STYLE=\"width: 100%; border: 1pt navy; border-style: solid;\">
            <TR><TD>WS Activity Session</TD><TD>%</TD><TD>Process ID</TD><TD>---</TD><TD>---</TD></TR>";
    if ($pv{ds_type} eq "MEM") {
       $request_top_sess = "select * from ( select round(a1.count_point * 100 / a2.sum_count_point::numeric, 4) percent, a1.pid
              from (select 'ok' ok1, count(*) count_point, pid pid
                           from $source_table_name
                           where $where_timepoint $where_ext
                           group by pid) a1,
                   (select 'ok' ok1, count(*) sum_count_point
                           from $source_table_name
                           where $where_timepoint $where_ext) a2
               where a1.ok1 = a2.ok1
               order by 1 desc) ds_1 LIMIT 30" ;
       }
    if ($pv{ds_type} eq "DB") {
       $request_top_sess = "select * from ( select round(a1.count_point * 100 / a2.sum_count_point::numeric, 4) percent, a1.pid
              from (select 'ok' ok1, sum(events_count) count_point, pid pid
                           from $source_table_name
                           where $where_timepoint $where_ext
                           group by pid) a1,
                   (select 'ok' ok1, sum(events_count) sum_count_point
                           from $source_table_name
                           where $where_timepoint $where_ext) a2
               where a1.ok1 = a2.ok1
               order by 1 desc) ds_1 LIMIT 30" ;
       }
#-debug-print "<BR>$request_top_sess <BR>" ;
#open(DEBG,">/tmp/print_pid_table_activity.out") ; print DEBG $request_top_sess ;
    my $dbh_top_sess = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'cryptapwd');
    my $sth_top_sess  = $dbh_top_sess ->prepare($request_top_sess ) ; $sth_top_sess->execute() ;
    while (my ( $percent, $pid, $serial, $user_id, $user_name ) = $sth_top_sess->fetchrow_array() ) {
          print "<TR><TD>" ;
          print_wait_sampling_activity_graph($pv{period_from}, $pv{period_to}, '', '', $pid, $serial, $percent, $source_table_name) ;
          print "</TD><TD>$percent</TD>
                     <TD><A HREF=\"http://zrt.ourorbits.ru/crypta/cgi/get_session_info.cgi?period_from=$pv{period_from}&period_to=$pv{period_to}&query_id=&plan_hash=&pid=$pid&serial=$serial&ds_type=$pv{ds_type}&page_part=1\">$pid</A></TD>
                     <TD TITLE=\"User ID: $user_id\">$user_name</TD><TD>&nbsp;</TD></TR>" ;
          }
    $sth_top_sess->finish() ;
    $dbh_top_sess->disconnect() ;
    print "</TABLE>" ;
    }

sub print_sah_events($$$$$$$) { my $filter_period_from = $_[0] ; my $filter_period_to = $_[1] ; my $filter_query_id = $_[2] ; my $filter_sql_plan_hash_value = $_[3] ; my $filter_session_id = $_[4] ; my $filter_session_serial = $_[5] ; $source_table_name = $_[6] ;
#    my $source_table_name = "bestat_SAH" ; if  ($pv{ds_type} eq "DB") { $source_table_name = "bestat_SAH" ; }
    my $where_timepoint = "" ;
    my $where_ext = "" ;
    if ( $filter_period_from eq "" ||  $filter_period_to eq "" ) { die ; }
    $where_timepoint .= " sampling_time >= TO_TIMESTAMP('$filter_period_from','YYYY-MM-DD HH24:MI:SS') " ;
    $where_timepoint .= " AND sampling_time <= TO_TIMESTAMP('$filter_period_to','YYYY-MM-DD HH24:MI:SS')" ;
    if ( $filter_query_id ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } if ( $filter_query_id ne "NULL" && $filter_query_id != 0 ) { $where_ext .= " QUERY_ID = $filter_query_id" ; } else { $where_ext .= " QUERY_ID IS NULL or QUERY_ID = 0" ; } }
    if ( $filter_sql_plan_hash_value ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SQL_PLAN_HASH_VALUE = '$filter_sql_plan_hash_value'" ; }
    if ( $filter_session_id ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SESSION_ID = '$filter_session_id'" ; }
    if ( $filter_session_serial ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SESSION_SERIAL# = '$filter_session_serial'" ; }
    if ( $where_ext ne "" ) { $where_ext = " AND $where_ext" ; }

    print "<TABLE BORDER=\"1\" WIDTH=\"100%\">
                 <TR><TD CLASS=\"td_waits_head\">Activity [pg_stat_activity]</TD><TD CLASS=\"td_waits_head\">%</TD><TD CLASS=\"td_waits_head\">count</TD><TD CLASS=\"td_waits_head\">state</TD><TD CLASS=\"td_waits_head\">Wait Event Type</TD><TD CLASS=\"td_waits_head\">Wait Event</TD></TR>\n" ;
   $request_query_per_wait_stats = "select a1.state, a1.wait_event_type, a1.wait_event, a1.ev_count, round((a1.ev_count::numeric  * 100 / a2.all_count),2) event_percent
                                           from ( select state, wait_event_type, wait_event, count(*) ev_count
                                                         from bestat_sa_history
                                                         where $where_timepoint $where_ext
                                                         group by state, wait_event_type, wait_event) a1,
                                                ( select count(*) all_count
                                                         from bestat_sa_history
                                                         where $where_timepoint $where_ext) a2
                                           order by a1.ev_count desc " ;
#-debug-print "<BR>$request_query_per_wait_stats<BR>" ;
# !!! обработчики IS NULL ввести
   $count_rows_query_per_wait_stats = 0 ;
   my $dbh_query_per_wait_stats = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'cryptapwd' ) ;
   my $sth_query_per_wait_stats = $dbh_query_per_wait_stats->prepare($request_query_per_wait_stats) ; $sth_query_per_wait_stats->execute() ;
   while ( ($state,$wait_event_type,$wait_event,$wait_event_count, $event_percent) = $sth_query_per_wait_stats->fetchrow_array() ) {
         $count_rows_query_per_wait_stats++ ;
         $white_spaces = 100 - $event_percent ;
         print "<TR><TD CLASS=\"td_waits_right\" TITLE=\"#: $count_rows_query_per_wait_stats, count: $wait_event_count\">" ;
         print "<TABLE WIDTH=\"200pt;\" HEIGHT=\"8pt;\" CELLPADDING=\"0\" CELLSPACING=\"0\"><TR>" ;
         if ( $wait_event_type eq "" && $wait_event eq "" ) { print "<TD TITLE=\"CPU Active $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: darkgreen;\">&nbsp;</TD>" ; }
         if ( $wait_event_type eq "Activity" ) { print "<TD TITLE=\"Activity::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: lime;\">&nbsp;</TD>" ; }
         if ( $wait_event_type eq "BufferPin" ) { print "<TD TITLE=\"BufferPin::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: pink;\">&nbsp;</TD>" ; }
         if ( $wait_event_type eq "Client" ) { print "<TD TITLE=\"Client::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: cyan;\">&nbsp;</TD>" ; }
         if ( $wait_event_type eq "Extension" ) { print "<TD TITLE=\"Extension::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: slateblue;\">&nbsp;</TD>" ; }
         if ( $wait_event_type eq "IO" ) { print "<TD TITLE=\"IO::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: navy;\">&nbsp;</TD>" ; }
         if ( $wait_event_type eq "IPC" ) { print "<TD TITLE=\"IPC::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: orange;\">&nbsp;</TD>" ; }
         if ( $wait_event_type eq "Lock" ) { print "<TD TITLE=\"Lock::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: darkred;\">&nbsp;</TD>" ; }
         if ( $wait_event_type eq "LWLock" ) { print "<TD TITLE=\"LWLock::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: red;\">&nbsp;</TD>" ; }
         if ( $wait_event_type eq "Timeout" ) { print "<TD TITLE=\"Timeout::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: lightgray;\">&nbsp;</TD>" ; }
         if ( $wait_event_type eq "Other" ) { print "<TD TITLE=\"Other::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: black;\">&nbsp;</TD>" ; }
         print "<TD STYLE=\"width: $white_spaces\%; height: 15pt; background-color: white;\">&nbsp;</TD>" ;
         print "</TR></TABLE>" ;
         print "</TD><TD CLASS=\"td_waits_right\">$event_percent</TD><TD CLASS=\"td_waits_right\">$wait_event_count</TD><TD CLASS=\"td_waits_left\">$state</TD><TD CLASS=\"td_waits_left\">$wait_event_type</TD><TD CLASS=\"td_waits_left\">$wait_event</TD></TR>\n" ;
         }
   $sth_query_per_wait_stats->finish() ;
   $dbh_query_per_wait_stats->disconnect() ;
   print "</TABLE>" ;

    }

sub print_wait_sampling_events($$$$$$$) { my $filter_period_from = $_[0] ; my $filter_period_to = $_[1] ; my $filter_query_id = $_[2] ; my $filter_sql_plan_hash_value = $_[3] ; my $filter_session_id = $_[4] ; my $filter_session_serial = $_[5] ; $source_table_name = $_[6] ;
    my $source_table_name = "pg_wait_sampling_history" ; if ($pv{ds_type} eq "DB") { $source_table_name = "bestat_ws_history" ; }
    my $where_timepoint = "" ;
    my $where_ext = "" ;
    if ( $filter_period_from eq "" ||  $filter_period_to eq "" ) { die ; }
    $where_timepoint .= " ts >= TO_TIMESTAMP('$filter_period_from','YYYY-MM-DD HH24:MI:SS') " ;
    $where_timepoint .= " AND ts <= TO_TIMESTAMP('$filter_period_to','YYYY-MM-DD HH24:MI:SS')" ;
    if ( $filter_query_id ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } if ( $filter_query_id ne "NULL" && $filter_query_id != 0 ) { $where_ext .= " QUERYID = $filter_query_id" ; } else { $where_ext .= " QUERYID IS NULL or QUERYID = 0 " ; } }
    if ( $filter_sql_plan_hash_value ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SQL_PLAN_HASH_VALUE = '$filter_sql_plan_hash_value'" ; }
    if ( $filter_session_id ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SESSION_ID = '$filter_session_id'" ; }
    if ( $filter_session_serial ne "" ) { if ( $where_ext ne "" ) { $where_ext .= " AND " ; } $where_ext .= " SESSION_SERIAL# = '$filter_session_serial'" ; }
    if ( $where_ext ne "" ) { $where_ext = " AND $where_ext" ; }

  print "<TABLE BORDER=\"1\" WIDTH=\"100%\">
                 <TR><TD CLASS=\"td_waits_head\">Activity [pg_wait_sampling]</TD><TD CLASS=\"td_waits_head\">%</TD><TD CLASS=\"td_waits_head\">count</TD><TD CLASS=\"td_waits_head\">Wait Event Type</TD><TD CLASS=\"td_waits_head\">Wait Event</TD></TR>\n" ;
  $request_query_per_wait_stats = "" ;
  if ($source_table_name eq "pg_wait_sampling_history") {
     $request_query_per_wait_stats = "select a1.event_type, a1.event, a1.ev_count, round((a1.ev_count::numeric  * 100 / a2.all_count),2) event_percent
                                             from ( select event_type, event, count(*) ev_count
                                                           from $source_table_name
                                                           where  $where_timepoint $where_ext
                                                           group by event_type, event) a1,
                                                  ( select count(*) all_count
                                                           from $source_table_name
                                                           where $where_timepoint $where_ext) a2
                                             order by a1.ev_count desc " ;
     }
  if ($source_table_name eq "bestat_ws_history") {
     $request_query_per_wait_stats = "select a1.event_type, a1.event, a1.ev_count, round((a1.ev_count::numeric  * 100 / a2.all_count),2) event_percent
                                             from ( select event_type, event, sum(events_count) ev_count
                                                           from $source_table_name
                                                           where $where_timepoint $where_ext
                                                           group by event_type, event) a1,
                                                  ( select sum(events_count) all_count
                                                           from $source_table_name
                                                           where $where_timepoint $where_ext) a2
                                             order by a1.ev_count desc " ;
     }
#-debug-print "<PRE>$request_query_per_wait_stats</PRE>" ;
     $count_rows_query_per_wait_stats = 0 ;
     my $dbh_query_per_wait_stats = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'cryptapwd' ) ;
     my $sth_query_per_wait_stats = $dbh_query_per_wait_stats->prepare($request_query_per_wait_stats) ; $sth_query_per_wait_stats->execute() ;
     while ( ($wait_event_type,$wait_event,$wait_event_count, $event_percent) = $sth_query_per_wait_stats->fetchrow_array() ) {
           $count_rows_query_per_wait_stats++ ;
           $white_spaces = 100 - $event_percent ;
           print "<TR><TD CLASS=\"td_waits_right\" TITLE=\"#: $count_rows_query_per_wait_stats, count: $wait_event_count\">" ;
           print "<TABLE WIDTH=\"200pt;\" HEIGHT=\"8pt;\" CELLPADDING=\"0\" CELLSPACING=\"0\"><TR>" ;
           if ( $wait_event_type eq "" && $wait_event eq "" ) { print "<TD TITLE=\"CPU Active $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: darkgreen;\">&nbsp;</TD>" ; }
           if ( $wait_event_type eq "Activity" ) { print "<TD TITLE=\"Activity::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: lime;\">&nbsp;</TD>" ; }
           if ( $wait_event_type eq "BufferPin" ) { print "<TD TITLE=\"BufferPin::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: pink;\">&nbsp;</TD>" ; }
           if ( $wait_event_type eq "Client" ) { print "<TD TITLE=\"Client::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: cyan;\">&nbsp;</TD>" ; }
           if ( $wait_event_type eq "Extension" ) { print "<TD TITLE=\"Extension::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: slateblue;\">&nbsp;</TD>" ; }
           if ( $wait_event_type eq "IO" ) { print "<TD TITLE=\"IO::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: navy;\">&nbsp;</TD>" ; }
           if ( $wait_event_type eq "IPC" ) { print "<TD TITLE=\"IPC::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: orange;\">&nbsp;</TD>" ; }
           if ( $wait_event_type eq "Lock" ) { print "<TD TITLE=\"Lock::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: darkred;\">&nbsp;</TD>" ; }
           if ( $wait_event_type eq "LWLock" ) { print "<TD TITLE=\"LWLock::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: red;\">&nbsp;</TD>" ; }
           if ( $wait_event_type eq "Timeout" ) { print "<TD TITLE=\"Timeout::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: lightgray;\">&nbsp;</TD>" ; }
           if ( $wait_event_type eq "Other" ) { print "<TD TITLE=\"Other::$wait_event $event_percent\%\" STYLE=\"width: $event_percent\%; height: 15pt; background-color: black;\">&nbsp;</TD>" ; }
           print "<TD STYLE=\"width: $white_spaces\%; height: 15pt; background-color: white;\">&nbsp;</TD>" ;
           print "</TR></TABLE>" ;
           print "</TD><TD CLASS=\"td_waits_right\">$event_percent</TD><TD CLASS=\"td_waits_right\">$wait_event_count</TD><TD CLASS=\"td_waits_left\">$wait_event_type</TD><TD CLASS=\"td_waits_left\">$wait_event</TD></TR>\n" ;
           }
     $sth_query_per_wait_stats->finish() ;
     $dbh_query_per_wait_stats->disconnect() ;
     print "</TABLE>" ;
    }

1
