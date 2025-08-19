
# open source soft - (C) 2023 CrAgrAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

# прямые и обратные преобразования дат
#date -d "2024-10-30 10:10:10" "+%s"
#date -d "@1730272212" "+%Y-%m-%d %H:%M:%S" 

# начало - функция отрисовки мультициклового трэйдингового блока монеты
sub print_coin_multicycles_graphs_block($$$$$$$$$$$$$$$$$$) {
    my $id_element = $_[0] ;
    my $currency = $_[1] ;
    my $curr_reference = $_[2] ;
    my $ema_tf = $_[3] ;
    my $count_prds = $_[4] ;
    my $env_prct = $_[5] ;
    my $ema_mode = $_[6] ;    if ($ema_mode eq "") { $ema_mode = "1" ; }
    my $macd_mode = $_[7] ;   if ($macd_mode eq "") { $macd_mode = "1" ; }
    my $macd_tf = $_[8] ;     if ($macd_tf eq "") { $macd_tf = $ema_tf ; }
    my $macd_mult = $_[9] ;   if ($macd_mult eq "") { $macd_mult = "x1" ; }
    my $rsi_mode = $_[10] ;   if ($rsi_mode eq "") { $rsi_mode = "1" ; }
    my $rsi_tf = $_[11] ;     if ($rsi_tf eq "") { $rsi_tf = $ema_tf ; }
    my $vlt_mode = $_[12] ;   if ($vlt_mode eq "") { $vlt_mode = "1" ; }
    my $vlt_tf = $_[13] ;     if ($vlt_tf eq "") { $vlt_tf = $ema_tf ; }
    my $vol_mode = $_[14] ;   if ($vol_mode eq "") { $vol_mode = "1" ; }
    my $vol_tf = $_[15] ;     if ($vol_tf eq "") { $vol_tf = $ema_tf ; }
    my $block_size = $_[16] ;
    my $nvgt_mode = $_[17] ;

# концепция
# - мы отражаем четыре цикла для своих целей - дневной, недельний, месячный, полугодовой
# - используя для этого соответствующие таймфрэймы, соответствующие циклам и индикаторам,
# - в нескольких вариантах, а именно - (1) все ТФ одинаковые с ценой, (2) младший ТФ для RSI, старший для MACD, младший для цены и EMA, (3) выборочный, если посчитаем нуцжным реализовывать

# основной цикл для нас здесь выбрали - недельный
#$pv{weeks_count_prds} = 5600 - изначально по умолчанию выставили такой период 5600 / 24 = 233 дня, но потом решили сделать изменяемым
$pv{weeks_time_frame} = "1H" ;  $pv{weeks_count_prds} = $count_prds ; $pv{weeks_env_prct} = 5 ;
$pv{weeks_price_mode} = 1 ;     $pv{weeks_price_tf} = "1H" ;  $pv{weeks_price_prds} = recode_tf_periods("$pv{weeks_time_frame}", "$pv{weeks_price_tf}", $pv{weeks_count_prds}) ;
$pv{weeks_ema_mode} = 1 ;       $pv{weeks_ema_tf} = "1H" ;    $pv{weeks_ema_prds}   = recode_tf_periods("$pv{weeks_time_frame}", "$pv{weeks_ema_tf}",   $pv{weeks_count_prds}) ;
$pv{weeks_macd_mode} = 1 ;      $pv{weeks_macd_tf} = "4H" ;   $pv{weeks_macd_prds}  = recode_tf_periods("$pv{weeks_time_frame}", "$pv{weeks_macd_tf}",  $pv{weeks_count_prds}) ;
$pv{weeks_rsi_mode} = 1 ;       $pv{weeks_rsi_tf} = "1H" ;    $pv{weeks_rsi_prds}   = recode_tf_periods("$pv{weeks_time_frame}", "$pv{weeks_rsi_tf}",   $pv{weeks_count_prds}) ;
$pv{weeks_vlt_mode} = 1 ;       $pv{weeks_vlt_tf} = "1H" ;    $pv{weeks_vlt_prds}   = recode_tf_periods("$pv{weeks_time_frame}", "$pv{weeks_vlt_tf}",   $pv{weeks_count_prds}) ;
$pv{weeks_vol_mode} = 1 ;       $pv{weeks_vol_tf} = "1H" ;    $pv{weeks_vol_prds}   = recode_tf_periods("$pv{weeks_time_frame}", "$pv{weeks_vol_tf}",   $pv{weeks_count_prds}) ;

$pv{days_time_frame} = "10M" ;  $pv{days_count_prds} = recode_tf_periods("$pv{weeks_time_frame}", "$pv{days_time_frame}", $pv{weeks_count_prds}) ; $pv{days_env_prct} = 2 ;
$pv{days_ema_mode} = 1 ;        $pv{days_ema_tf} = "10M" ;    $pv{days_ema_prds}  = recode_tf_periods("$pv{days_time_frame}", "$pv{days_ema_tf}",  $pv{days_count_prds}) ;
$pv{days_macd_mode} = 1 ;       $pv{days_macd_tf} = "30M" ;   $pv{days_macd_prds} = recode_tf_periods("$pv{days_time_frame}", "$pv{days_macd_tf}", $pv{days_count_prds}) ;
$pv{days_rsi_mode} = 1 ;        $pv{days_rsi_tf} = "10M" ;    $pv{days_rsi_prds}  = recode_tf_periods("$pv{days_time_frame}", "$pv{days_rsi_tf}",  $pv{days_count_prds}) ;
$pv{days_vlt_mode} = 1 ;        $pv{days_vlt_tf} = "10M" ;    $pv{days_vlt_prds}  = recode_tf_periods("$pv{days_time_frame}", "$pv{days_vlt_tf}",  $pv{days_count_prds}) ;
$pv{days_vol_mode} = 1 ;        $pv{days_vol_tf} = "10M" ;    $pv{days_vol_prds}  = recode_tf_periods("$pv{days_time_frame}", "$pv{days_vol_tf}",  $pv{days_count_prds}) ;

$pv{months_time_frame} = "1D" ; $pv{months_count_prds} = recode_tf_periods("$pv{weeks_time_frame}", "$pv{months_time_frame}", $pv{weeks_count_prds}) ; $pv{months_env_prct} = 15 ;
$pv{months_ema_mode} = 1 ;      $pv{months_ema_tf} = "1D" ;  $pv{months_ema_prds}  = recode_tf_periods("$pv{months_time_frame}", "$pv{months_ema_tf}",  $pv{months_count_prds}) ;
$pv{months_macd_mode} = 1 ;     $pv{months_macd_tf} = "4D" ; $pv{months_macd_prds} = recode_tf_periods("$pv{months_time_frame}", "$pv{months_macd_tf}", $pv{months_count_prds}) ;
$pv{months_rsi_mode} = 1 ;      $pv{months_rsi_tf} = "1D" ;  $pv{months_rsi_prds}  = recode_tf_periods("$pv{months_time_frame}", "$pv{months_rsi_tf}",  $pv{months_count_prds}) ;
$pv{months_vlt_mode} = 1 ;      $pv{months_vlt_tf} = "1D" ;  $pv{months_vlt_prds}  = recode_tf_periods("$pv{months_time_frame}", "$pv{months_vlt_tf}",  $pv{months_count_prds}) ;
$pv{months_vol_mode} = 1 ;      $pv{months_vol_tf} = "1D" ;  $pv{months_vol_prds}  = recode_tf_periods("$pv{months_time_frame}", "$pv{months_vol_tf}",  $pv{months_count_prds}) ;

$pv{yhalf_time_frame} = "1W" ;  $pv{yhalf_count_prds} = recode_tf_periods("$pv{weeks_time_frame}", "$pv{yhalf_time_frame}", $pv{weeks_count_prds}) ; $pv{yhalf_env_prct} = 30 ;
$pv{yhalf_ema_mode} = 1 ;       $pv{yhalf_ema_tf} = "1W" ;   $pv{yhalf_ema_prds}  = recode_tf_periods("$pv{yhalf_time_frame}", "$pv{yhalf_ema_tf}",  $pv{yhalf_count_prds}) ;
$pv{yhalf_macd_mode} = 1 ;      $pv{yhalf_macd_tf} = "4W" ;  $pv{yhalf_macd_prds} = recode_tf_periods("$pv{yhalf_time_frame}", "$pv{yhalf_macd_tf}", $pv{yhalf_count_prds}) ;
$pv{yhalf_rsi_mode} = 1 ;       $pv{yhalf_rsi_tf} = "1W" ;   $pv{yhalf_rsi_prds}  = recode_tf_periods("$pv{yhalf_time_frame}", "$pv{yhalf_rsi_tf}",  $pv{yhalf_count_prds}) ;
$pv{yhalf_vlt_mode} = 1 ;       $pv{yhalf_vlt_tf} = "1W" ;   $pv{yhalf_vlt_prds}  = recode_tf_periods("$pv{yhalf_time_frame}", "$pv{yhalf_vlt_tf}",  $pv{yhalf_count_prds}) ;
$pv{yhalf_vol_mode} = 1 ;       $pv{yhalf_vol_tf} = "1W" ;   $pv{yhalf_vol_prds}  = recode_tf_periods("$pv{yhalf_time_frame}", "$pv{yhalf_vol_tf}",  $pv{yhalf_count_prds}) ;


$common_graphs_x_size = 2440 ; 

# выделить суффикс
#    my $id_suffix = "$currency"."_$curr_reference"."_$v_rand" ;
    my $id_suffix = $id_element ; $id_suffix =~ s/id_trading_block_//g ;

#-debug-print("<BR>debug in print_coin_graphs_block function === id_trading_block_$currency"."_$curr_reference"."\n<BR>---"."$currency"."\n<BR>---"."$curr_reference"."\n<BR>---"."$ema_tf"."\n<BR>---"."$count_prds"."\n<BR>---"."$env_prct"."\n<BR>---"."$macd_mode"."\n<BR>---"."$macd_tf"."\n<BR>---"."$rsi_mode"."\n<BR>---"."$rsi_tf"."\n<BR>---vlt_mode="."$vlt_mode"."\n<BR>--- vlt_tf="."$vlt_tf"."\n<BR>--- vol_mode="."$vol_mode"."\n<BR>--- vol_tf="."$vol_tf"."\n<BR>--- block_size="."$block_size"."\n<BR>--- nvgt_mode=".$nvgt_mode."\n<BR>---"."<BR>") ;
    $count_prds_minus = $count_prds / 2 ;
    $count_prds_plus = $count_prds * 2 ;

# v.0.9 добавляем явные стили графиков для реализации нахождения нескольких экземпляров трэйдингового блока монеты разного размероа на странице
    $img_style{$id_element} = "---!!!-unknown-!!!---" ;
#    $img_style{$id_element} = "           IMG.ohlc_ema_graph_$id_suffix { width: 1100pt; height: 320pt; }
#           IMG.ohlc_ema_graph_gd_$id_suffix { width: 1100pt; height: 320pt; }
#           IMG.macd_graph_$id_suffix { width: 1100pt; height: 87pt; }
#           IMG.rsi_graph_$id_suffix { width: 1100pt; height: 87pt; }
#           IMG.vlt_graph_$id_suffix { width: 100pt; height: 87pt; }" ;
    if ( $block_size eq "full" ) { $img_style{$id_element} = "           IMG.ohlc_ema_graph_$id_suffix { width: 1100pt; height: 270pt; }
           IMG.ohlc_ema_graph_gd_$id_suffix { width: 1100pt; height: 270pt; }
           IMG.macd_graph_$id_suffix { width: 1100pt; height: 57pt; }
           IMG.rsi_graph_$id_suffix { width: 1100pt; height: 57pt; }
           IMG.vlt_graph_$id_suffix { width: 1100pt; height: 57pt; }" ;
           }

    if ( $block_size eq "half" ) { $img_style{$id_element} = "           IMG.ohlc_ema_graph_$id_suffix { width: 340pt; height: 180pt; }
           IMG.ohlc_ema_graph_gd_$id_suffix { width: 310pt; height: 180pt; }
           IMG.macd_graph_$id_suffix { width: 340pt; height: 70pt; }
           IMG.rsi_graph_$id_suffix { width: 340pt; height: 70pt; }
           IMG.vlt_graph_$id_suffix { width: 340pt; height: 70pt; }" ;
           }

    if ( $block_size eq "middle" ) { $img_style{$id_element} = "           IMG.ohlc_ema_graph_$id_suffix { width: 510pt; height: 270pt; }
           IMG.ohlc_ema_graph_gd_$id_suffix { width: 450pt; height: 270pt; }
           IMG.macd_graph_$id_suffix { width: 510pt; height: 107pt; }
           IMG.rsi_graph_$id_suffix { width: 510pt; height: 107pt; }
           IMG.vlt_graph_$id_suffix { width: 510pt; height: 107pt; }" ;
           }

    print "\n<STYLE>
           A.complex_navigation:link { font-size: 7pt; }
           A.complex_navigation:active { font-size: 7pt; }
           A.complex_navigation:visited { font-size: 7pt; }
           A.complex_navigation:hover { font-size: 7pt; }

           SELECT.complex_navigation { font-size: 7pt; }
           DIV.complex_navigation { font-size: 7pt; }
           SPAN.complex_navigation { cursor: pointer; font-size: 7pt; }
           INPUT.complex_navigation { width: 20pt; cursor: pointer; font-size: 7pt; }

           $img_style{$id_element}
           </STYLE>" ;

    print "<!-- " ;
    my $zs_nvgt_mode_visibility = "" ; if ( $nvgt_mode eq "no_show" ) { $zs_nvgt_mode_visibility = " STYLE=\"visibility: hidden;\"" ; }
    print "\n<DIV CLASS=\"complex_navigation\" $zs_nvgt_mode_visibility><TABLE><TR><TD>$currency/$curr_reference&nbsp;
           <INPUT TYPE=\"hidden\" name=\"block_size$_id_suffix\" id=\"id_block_size_$id_suffix\" VALUE=\"$block_size\"></INPUT>
           </TD>" ;

# - в версии 22 была допущена ошибка полного не вывода параметров - а без их значений не работают функции. Сейчас - будем просто скрывать
    my $sz_ema_nvgt_visibility = "" ; if ( $ema_mode == 0 && $nvgt_mode eq "no_disabled") { $sz_ema_nvgt_visibility = " STYLE=\"display: none;\"" ; }
    $is_ema_tf_4w_selected = ($ema_tf eq "4w") ? "selected" : "" ; $is_ema_tf_1w_selected = ($ema_tf eq "1W") ? "selected" : "" ; $is_ema_tf_4d_selected = ($ema_tf eq "4D") ? "selected" : "" ;
    $is_ema_tf_2d_selected = ($ema_tf eq "2D") ? "selected" : "" ; $is_ema_tf_1d_selected = ($ema_tf eq "1D") ? "selected" : "" ; $is_ema_tf_12h_selected = ($ema_tf eq "12H") ? "selected" : "" ;
    $is_ema_tf_8h_selected = ($ema_tf eq "8H") ? "selected" : "" ; $is_ema_tf_4h_selected = ($ema_tf eq "4H") ? "selected" : "" ; $is_ema_tf_3h_selected = ($ema_tf eq "3H") ? "selected" : "" ;
    $is_ema_tf_2h_selected = ($ema_tf eq "2H") ? "selected" : "" ; $is_ema_tf_1h_selected = ($ema_tf eq "1H") ? "selected" : "" ; $is_ema_tf_30m_selected = ($ema_tf eq "30M") ? "selected" : "" ;
    $is_ema_tf_15m_selected = ($ema_tf eq "15M") ? "selected" : "" ; $is_ema_tf_10m_selected = ($ema_tf eq "10M") ? "selected" : "" ; $is_ema_tf_5m_selected = ($ema_tf eq "5M") ? "selected" : "" ;
    $is_ema_tf_3m_selected = ($ema_tf eq "3M") ? "selected" : "" ; $is_ema_tf_1m_selected = ($ema_tf eq "1M") ? "selected" : "" ;
    my $next_ema_mode = $ema_mode ; if ( $ema_mode == 0 ) { $next_ema_mode = 1 ; } if ( $ema_mode == 1 ) { $next_ema_mode = 2 ; } if ( $ema_mode == 2 ) { $next_ema_mode = 3 ; } if ( $ema_mode == 3 ) { $next_ema_mode = 0 ; }
    print "<TD><SPAN $sz_ema_nvgt_visibility>\nEMA&nbsp;" ;
    if ( $block_size ne "half" ) {
       print "\n[<A CLASS=\"complex_navigation\" TITLE=\"[0] не показать график EMA, [1] показать основной график ЕМА, [2] показать дополнительный график ЕМА свечи, [3] показывать линейный и свечной графики EMA\"
                     onclick=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference',id_ema_time_frame_$id_suffix.value,id_count_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$next_ema_mode','$next_macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ema_time_frame_$id_suffix.value,'$block_size','$nvgt_mode')\">$ema_mode</A>" ;
       print "<A CLASS=\"complex_navigation\" TITLE=\"данные графика в табличной форме\" HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_OHLCV_EMA_ENV_BL.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$ema_tf&count_prds=$count_prds&env_prct=$env_prct&output_type=table&brush_size=4&x_size=2440&y_size=1240&is_ema_periods=default&is_ema05=shadow\" TARGET=\"_blank\">T</A>" ;
       print "<A CLASS=\"complex_navigation\" TITLE=\"текст запроса к базе данных\" HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_OHLCV_EMA_ENV_BL.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$ema_tf&count_prds=$count_prds&env_prct=$env_prct&output_type=query&brush_size=4&x_size=2440&y_size=1240&is_ema_periods=default&is_ema05=shadow\" TARGET=\"_blank\">Q</A>]&nbsp;" ;
       }
    print "\n<SELECT CLASS=\"complex_navigation\" name=\"ema_time_frame$_id_suffix\" id=\"id_ema_time_frame_$id_suffix\" TITLE=\"основной ТФ, меняет выбор EMA всех индикаторов, текущих периодов $count_prds\" $sz_ema_nvgt_visibility
                   onchange=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference',id_ema_time_frame_$id_suffix.value,id_count_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$macd_mode',id_ema_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_ema_time_frame_$id_suffix.value,'$vlt_mode',id_ema_time_frame_$id_suffix.value,'$vol_mode',id_ema_time_frame_$id_suffix.value,id_block_size_$id_suffix.value,'$nvgt_mode')\">
                   <OPTION VALUE=\"4W\" $is_ema_tf_4w_selected>4W</OPTION>
                   <OPTION VALUE=\"1W\" $is_ema_tf_1w_selected>1W</OPTION>
                   <OPTION VALUE=\"4D\" $is_ema_tf_4d_selected>4D</OPTION>
                   <OPTION VALUE=\"2D\" $is_ema_tf_2d_selected>2D</OPTION>
                   <OPTION VALUE=\"1D\" $is_ema_tf_1d_selected>1D</OPTION>
                   <OPTION VALUE=\"12H\" $is_ema_tf_12h_selected>12H</OPTION>
                   <OPTION VALUE=\"8H\" $is_ema_tf_8h_selected>8H</OPTION>
                   <OPTION VALUE=\"4H\" $is_ema_tf_4h_selected>4H</OPTION>
                   <OPTION VALUE=\"3H\" $is_ema_tf_3h_selected>3H</OPTION>
                   <OPTION VALUE=\"2H\" $is_ema_tf_2h_selected>2H</OPTION>
                   <OPTION VALUE=\"1H\" $is_ema_tf_1h_selected>1H</OPTION>
                   <OPTION VALUE=\"30M\" $is_ema_tf_30m_selected>30M</OPTION>
                   <OPTION VALUE=\"15M\" $is_ema_tf_15m_selected>15M</OPTION>
                   <OPTION VALUE=\"10M\" $is_ema_tf_10m_selected>10M</OPTION>
                   <OPTION VALUE=\"5M\" $is_ema_tf_5m_selected>5M</OPTION>
                   <OPTION VALUE=\"3M\" $is_ema_tf_3m_selected>3M</OPTION>
                   <OPTION VALUE=\"1M\" $is_ema_tf_1m_selected>1M</OPTION>
                   </SELECT>
           &nbsp;
           &nbsp;<SPAN CLASS=\"complex_navigation\" TITLE=\"-50% отображаемого периода\" $sz_ema_nvgt_visibility
                       onwheel=\"two_onwheel(event,'id_trading_block_$id_suffix','$currency','$curr_reference',id_ema_time_frame_$id_suffix.value,id_count_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ema_time_frame_$id_suffix.value,'$block_size','$nvgt_mode')\"
                       onclick=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ema_tf','$count_prds_minus',id_env_prct_$id_suffix.value,'$ema_mode','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ema_time_frame_$id_suffix.value,'$block_size','$nvgt_mode')\">[-]</SPAN>
           &nbsp;<SPAN CLASS=\"complex_navigation\" TITLE=\"текущий период\" $sz_ema_nvgt_visibility
                       onwheel=\"two_onwheel(event,'id_trading_block_$id_suffix','$currency','$curr_reference',id_ema_time_frame_$id_suffix.value,id_count_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ema_time_frame_$id_suffix.value,'$block_size','$nvgt_mode')\"
                       onchange=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference',id_ema_time_frame_$id_suffix.value,id_count_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ema_time_frame_$id_suffix.value,'$block_size','$nvgt_mode')\"><INPUT CLASS=\"complex_navigation\" name=\"count_prds_$id_suffix\" id=\"id_count_prds_$id_suffix\" value=\"$count_prds\"></INPUT>&nbsp;</SPAN>
           &nbsp;<SPAN CLASS=\"complex_navigation\" TITLE=\"+50% отображаемого периода\" $sz_ema_nvgt_visibility
                       onwheel=\"two_onwheel(event,'id_trading_block_$id_suffix','$currency','$curr_reference',id_ema_time_frame_$id_suffix.value,id_count_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ema_time_frame_$id_suffix.value,'$block_size','$nvgt_mode')\"
                       onclick=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ema_tf','$count_prds_plus',id_env_prct_$id_suffix.value,'$ema_mode','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ema_time_frame_$id_suffix.value,'$block_size','$nvgt_mode')\">[+]</SPAN>
           &nbsp;</SPAN></TD>";

# onclick=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference',id_ema_time_frame_$id_suffix.value,id_count_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value, '$vlt_mode',id_vlt_time_frame_$id_suffix.value)\"
    my $sz_macd_nvgt_visibility = "" ; if ( $macd_mode == 0 && $nvgt_mode eq "no_disabled" ) { $sz_macd_nvgt_visibility = " STYLE=\"display: none;\"" ; }
    $is_macd_tf_4w_selected = ($macd_tf eq "4w") ? "selected" : "" ; $is_macd_tf_1w_selected = ($macd_tf eq "1W") ? "selected" : "" ; $is_macd_tf_4d_selected = ($macd_tf eq "4D") ? "selected" : "" ;
    $is_macd_tf_2d_selected = ($macd_tf eq "2D") ? "selected" : "" ; $is_macd_tf_1d_selected = ($macd_tf eq "1D") ? "selected" : "" ; $is_macd_tf_12h_selected = ($macd_tf eq "12H") ? "selected" : "" ;
    $is_macd_tf_8h_selected = ($macd_tf eq "8H") ? "selected" : "" ; $is_macd_tf_4h_selected = ($macd_tf eq "4H") ? "selected" : "" ; $is_macd_tf_3h_selected = ($macd_tf eq "3H") ? "selected" : "" ;
    $is_macd_tf_2h_selected = ($macd_tf eq "2H") ? "selected" : "" ; $is_macd_tf_1h_selected = ($macd_tf eq "1H") ? "selected" : "" ; $is_macd_tf_30m_selected = ($macd_tf eq "30M") ? "selected" : "" ;
    $is_macd_tf_15m_selected = ($macd_tf eq "15M") ? "selected" : "" ; $is_macd_tf_10m_selected = ($macd_tf eq "10M") ? "selected" : "" ; $is_macd_tf_5m_selected = ($macd_tf eq "5M") ? "selected" : "" ;
    $is_macd_tf_3m_selected = ($macd_tf eq "3M") ? "selected" : "" ; $is_macd_tf_1m_selected = ($macd_tf eq "1M") ? "selected" : "" ;
    my $next_macd_mode = $macd_mode ; if ( $macd_mode == 0 ) { $next_macd_mode = 1 ; } if ( $macd_mode == 1 ) { $next_macd_mode = 2 ; } if ( $macd_mode == 2 ) { $next_macd_mode = 0 ; }
    print "\n<TD><SPAN $sz_macd_nvgt_visibility>MACD&nbsp;" ;
    if ( $block_size ne "half" ) {
       print "\n[<A CLASS=\"complex_navigation\" TITLE=\"[0] не показывать, [1] показать график выбранного ТФ, [2] плюс график текущего ТФ EMA, в т.ч. с мультипликатором\"
                    onclick=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference',id_ema_time_frame_$id_suffix.value,id_count_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$next_macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ema_time_frame_$id_suffix.value,'$block_size','$nvgt_mode')\">$macd_mode</A>" ;
       print "<A CLASS=\"complex_navigation\" TITLE=\"данные графика в табличной форме\" HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_MACD_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$macd_tf&count_prds=$macd_count_prds&output_type=table&brush_size=4&x_size=1440&y_size=240\" TARGET=\"_blank\">T</A>" ;
       print "<A CLASS=\"complex_navigation\" TITLE=\"текст запроса к базе данных\" HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_MACD_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$macd_tf&count_prds=$macd_count_prds&output_type=query&brush_size=4&x_size=1440&y_size=240\" TARGET=\"_blank\">Q</A>]&nbsp;" ;
       }
    print "\n<SELECT CLASS=\"complex_navigation\" name=\"macd_time_frame$_id_suffix\" id=\"id_macd_time_frame_$id_suffix\" TITLE=\"отдельный ТФ индикатора MACD, текущих периодов $macd_count_prds\" $sz_macd_nvgt_visibility
                   onchange=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference',id_ema_time_frame_$id_suffix.value,id_count_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ema_time_frame_$id_suffix.value,'$block_size','$nvgt_mode')\">
                   <OPTION VALUE=\"4W\" $is_macd_tf_4w_selected>4W</OPTION>
                   <OPTION VALUE=\"1W\" $is_macd_tf_1w_selected>1W</OPTION>
                   <OPTION VALUE=\"4D\" $is_macd_tf_4d_selected>4D</OPTION>
                   <OPTION VALUE=\"2D\" $is_macd_tf_2d_selected>2D</OPTION>
                   <OPTION VALUE=\"1D\" $is_macd_tf_1d_selected>1D</OPTION>
                   <OPTION VALUE=\"12H\" $is_macd_tf_12h_selected>12H</OPTION>
                   <OPTION VALUE=\"8H\" $is_macd_tf_8h_selected>8H</OPTION>
                   <OPTION VALUE=\"4H\" $is_macd_tf_4h_selected>4H</OPTION>
                   <OPTION VALUE=\"3H\" $is_macd_tf_3h_selected>3H</OPTION>
                   <OPTION VALUE=\"2H\" $is_macd_tf_2h_selected>2H</OPTION>
                   <OPTION VALUE=\"1H\" $is_macd_tf_1h_selected>1H</OPTION>
                   <OPTION VALUE=\"30M\" $is_macd_tf_30m_selected>30M</OPTION>
                   <OPTION VALUE=\"15M\" $is_macd_tf_15m_selected>15M</OPTION>
                   <OPTION VALUE=\"10M\" $is_macd_tf_10m_selected>10M</OPTION>
                   <OPTION VALUE=\"5M\" $is_macd_tf_5m_selected>5M</OPTION>
                   <OPTION VALUE=\"3M\" $is_macd_tf_3m_selected>3M</OPTION>
                   <OPTION VALUE=\"1M\" $is_macd_tf_1m_selected>1M</OPTION>
                   </SELECT>
           &nbsp;</SPAN></TD>" ;
    if ( $block_size ne "half" ) {
# - разрешаем локально изменить ТФ MACD
       if ( $macd_mult eq "x1" ) { print "&nbsp;<SPAN $sz_macd_nvgt_visibility CLASS=\"complex_navigation\" TITLE=\"при щелчке - показать график MACD следующего ТФ, игнорировать явно выставленный ТФ\"
          onclick=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference',id_ema_time_frame_$id_suffix.value,id_count_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$macd_mode',id_macd_time_frame_$id_suffix.value,'x2','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ema_time_frame_$id_suffix.value,'$block_size','$nvgt_mode')\">[x1]</SPAN>" ; }
       else { print "&nbsp;<SPAN $sz_macd_nvgt_visibility CLASS=\"complex_navigation\" TITLE=\"при щелчке - показать график MACD текущего ТФ, или выставленный явно отдельный ТФ\"
            onclick=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference',id_ema_time_frame_$id_suffix.value,id_count_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$macd_mode',id_macd_time_frame_$id_suffix.value,'x1','$rsi_mode',id_rsi_time_frame_$id_suffix.value, '$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ema_time_frame_$id_suffix.value,'$block_size','$nvgt_mode')\">[x2]</SPAN>" ; }
       }

    my $sz_rsi_nvgt_visibility = "" ; if ( $rsi_mode == 0 && $nvgt_mode eq "no_disabled" ) { $sz_rsi_nvgt_visibility = " STYLE=\"display: none;\"" ; }
    $is_rsi_tf_4w_selected = ($rsi_tf eq "4w") ? "selected" : "" ; $is_rsi_tf_1w_selected = ($rsi_tf eq "1W") ? "selected" : "" ; $is_rsi_tf_4d_selected = ($rsi_tf eq "4D") ? "selected" : "" ;
    $is_rsi_tf_2d_selected = ($rsi_tf eq "2D") ? "selected" : "" ; $is_rsi_tf_1d_selected = ($rsi_tf eq "1D") ? "selected" : "" ; $is_rsi_tf_12h_selected = ($rsi_tf eq "12H") ? "selected" : "" ;
    $is_rsi_tf_8h_selected = ($rsi_tf eq "8H") ? "selected" : "" ; $is_rsi_tf_4h_selected = ($rsi_tf eq "4H") ? "selected" : "" ; $is_rsi_tf_3h_selected = ($rsi_tf eq "3H") ? "selected" : "" ;
    $is_rsi_tf_2h_selected = ($rsi_tf eq "2H") ? "selected" : "" ; $is_rsi_tf_1h_selected = ($rsi_tf eq "1H") ? "selected" : "" ; $is_rsi_tf_30m_selected = ($rsi_tf eq "30M") ? "selected" : "" ;
    $is_rsi_tf_15m_selected = ($rsi_tf eq "15M") ? "selected" : "" ; $is_rsi_tf_10m_selected = ($rsi_tf eq "10M") ? "selected" : "" ; $is_rsi_tf_5m_selected = ($rsi_tf eq "5M") ? "selected" : "" ;
    $is_rsi_tf_3m_selected = ($rsi_tf eq "3M") ? "selected" : "" ; $is_rsi_tf_1m_selected = ($rsi_tf eq "1M") ? "selected" : "" ;
    my $next_rsi_mode = $rsi_mode ; if ( $rsi_mode == 0 ) { $next_rsi_mode = 1 ; } if ( $rsi_mode == 1 ) { $next_rsi_mode = 2 ; } if ( $rsi_mode == 2 ) { $next_rsi_mode = 0 ; }
    print "\n<TD><SPAN $sz_rsi_nvgt_visibility>&nbsp;RSI&nbsp;" ;
    if ( $block_size ne "half" ) {
       print "\n[<A CLASS=\"complex_navigation\" TITLE=\"[0] не показывать, [1] показать график выбранного ТФ, [2] плюс график текущего ТФ EMA\" onclick=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference',id_ema_time_frame_$id_suffix.value,id_count_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$next_rsi_mode',id_rsi_time_frame_$id_suffix.value, '$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$block_size')\">$rsi_mode</A>" ;
       print "<A CLASS=\"complex_navigation\" TITLE=\"данные графика в табличной форме\" HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_RSI_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$rsi_tf&count_prds=$count_prds&output_type=table&brush_size=4&x_size=1440&y_size=240\" TARGET=\"_blank\">T</A>" ;
       print "<A CLASS=\"complex_navigation\" TITLE=\"текст запроса к базе данных\" HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_RSI_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$rsi_tf&count_prds=$count_prds&output_type=query&brush_size=4&x_size=1440&y_size=240\" TARGET=\"_blank\">Q</A>]&nbsp;" ;
       }
    print "\n<SELECT CLASS=\"complex_navigation\" name=\"rsi_time_frame$_id_suffix\" id=\"id_rsi_time_frame_$id_suffix\" TITLE=\"отдельный ТФ индикатора RSI, текущих периодов $rsi_count_prds\"
                   onchange=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference',id_ema_time_frame_$id_suffix.value,id_count_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ema_time_frame_$id_suffix.value,'$block_size','$nvgt_mode')\">
                   <OPTION VALUE=\"4W\" $is_rsi_tf_4w_selected>4W</OPTION>
                   <OPTION VALUE=\"1W\" $is_rsi_tf_1w_selected>1W</OPTION>
                   <OPTION VALUE=\"4D\" $is_rsi_tf_4d_selected>4D</OPTION>
                   <OPTION VALUE=\"2D\" $is_rsi_tf_2d_selected>2D</OPTION>
                   <OPTION VALUE=\"1D\" $is_rsi_tf_1d_selected>1D</OPTION>
                   <OPTION VALUE=\"12H\" $is_rsi_tf_12h_selected>12H</OPTION>
                   <OPTION VALUE=\"8H\" $is_rsi_tf_8h_selected>8H</OPTION>
                   <OPTION VALUE=\"4H\" $is_rsi_tf_4h_selected>4H</OPTION>
                   <OPTION VALUE=\"3H\" $is_rsi_tf_3h_selected>3H</OPTION>
                   <OPTION VALUE=\"2H\" $is_rsi_tf_2h_selected>2H</OPTION>
                   <OPTION VALUE=\"1H\" $is_rsi_tf_1h_selected>1H</OPTION>
                   <OPTION VALUE=\"30M\" $is_rsi_tf_30m_selected>30M</OPTION>
                   <OPTION VALUE=\"15M\" $is_rsi_tf_15m_selected>15M</OPTION>
                   <OPTION VALUE=\"10M\" $is_rsi_tf_10m_selected>10M</OPTION>
                   <OPTION VALUE=\"5M\" $is_rsi_tf_5m_selected>5M</OPTION>
                   <OPTION VALUE=\"3M\" $is_rsi_tf_3m_selected>3M</OPTION>
                   <OPTION VALUE=\"1M\" $is_rsi_tf_1m_selected>1M</OPTION>
                   </SELECT>
           &nbsp;</SPAN></TD>" ;

    my $sz_vlt_nvgt_visibility = "" ; if ( $vlt_mode == 0 && $nvgt_mode eq "no_disabled" ) { $sz_vlt_nvgt_visibility = " STYLE=\"display: none;\"" ; }
    $is_vlt_tf_4w_selected = ($vlt_tf eq "4w") ? "selected" : "" ; $is_vlt_tf_1w_selected = ($vlt_tf eq "1W") ? "selected" : "" ; $is_vlt_tf_4d_selected = ($vlt_tf eq "4D") ? "selected" : "" ;
    $is_vlt_tf_2d_selected = ($vlt_tf eq "2D") ? "selected" : "" ; $is_vlt_tf_1d_selected = ($vlt_tf eq "1D") ? "selected" : "" ; $is_vlt_tf_12h_selected = ($vlt_tf eq "12H") ? "selected" : "" ;
    $is_vlt_tf_8h_selected = ($vlt_tf eq "8H") ? "selected" : "" ; $is_vlt_tf_4h_selected = ($vlt_tf eq "4H") ? "selected" : "" ; $is_vlt_tf_3h_selected = ($vlt_tf eq "3H") ? "selected" : "" ;
    $is_vlt_tf_2h_selected = ($vlt_tf eq "2H") ? "selected" : "" ; $is_vlt_tf_1h_selected = ($vlt_tf eq "1H") ? "selected" : "" ; $is_vlt_tf_30m_selected = ($vlt_tf eq "30M") ? "selected" : "" ;
    $is_vlt_tf_15m_selected = ($vlt_tf eq "15M") ? "selected" : "" ; $is_vlt_tf_10m_selected = ($vlt_tf eq "10M") ? "selected" : "" ; $is_vlt_tf_5m_selected = ($vlt_tf eq "5M") ? "selected" : "" ;
    $is_vlt_tf_3m_selected = ($vlt_tf eq "3M") ? "selected" : "" ; $is_vlt_tf_1m_selected = ($vlt_tf eq "1M") ? "selected" : "" ;
    my $next_vlt_mode = $vlt_mode ; if ( $vlt_mode == 0 ) { $next_vlt_mode = 1 ; } if ( $vlt_mode == 1 ) { $next_vlt_mode = 2 ; } if ( $vlt_mode == 2 ) { $next_vlt_mode = 0 ; }
    if ( $block_size ne "half") {
       print "\n<TD><SPAN $sz_vlt_nvgt_visibility>VLT&nbsp;" ;
       print "\n[<A CLASS=\"complex_navigation\" TITLE=\"[0] не показывать, [1] показать график выбранного ТФ, [2] плюс график текущего ТФ EMA\"
               onclick=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference',id_ema_time_frame_$id_suffix.value,id_count_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$next_vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ema_time_frame_$id_suffix.value,'$block_size','$nvgt_mode')\">$vlt_mode</A><A CLASS=\"complex_navigation\" TITLE=\"данные графика в табличной форме\">T</A><A CLASS=\"complex_navigation\" TITLE=\"текст запроса к базе данных\">Q</A>]
               &nbsp;" ;
       print "\n<SELECT CLASS=\"complex_navigation\" name=\"vlt_time_frame$_id_suffix\" id=\"id_vlt_time_frame_$id_suffix\" TITLE=\"отдельный ТФ индикатора волатильности, текущих периодов $vlt_count_prds\"
                      onchange=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference',id_ema_time_frame_$id_suffix.value,id_count_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ema_time_frame_$id_suffix.value,'$block_size','$nvgt_mode')\">
                      <OPTION VALUE=\"4W\" $is_vlt_tf_4w_selected>4W</OPTION>
                      <OPTION VALUE=\"1W\" $is_vlt_tf_1w_selected>1W</OPTION>
                      <OPTION VALUE=\"4D\" $is_vlt_tf_4d_selected>4D</OPTION>
                      <OPTION VALUE=\"2D\" $is_vlt_tf_2d_selected>2D</OPTION>
                      <OPTION VALUE=\"1D\" $is_vlt_tf_1d_selected>1D</OPTION>
                      <OPTION VALUE=\"12H\" $is_vlt_tf_12h_selected>12H</OPTION>
                      <OPTION VALUE=\"8H\" $is_vlt_tf_8h_selected>8H</OPTION>
                      <OPTION VALUE=\"4H\" $is_vlt_tf_4h_selected>4H</OPTION>
                      <OPTION VALUE=\"3H\" $is_vlt_tf_3h_selected>3H</OPTION>
                      <OPTION VALUE=\"2H\" $is_vlt_tf_2h_selected>2H</OPTION>
                      <OPTION VALUE=\"1H\" $is_vlt_tf_1h_selected>1H</OPTION>
                      <OPTION VALUE=\"30M\" $is_vlt_tf_30m_selected>30M</OPTION>
                      <OPTION VALUE=\"15M\" $is_vlt_tf_15m_selected>15M</OPTION>
                      <OPTION VALUE=\"10M\" $is_vlt_tf_10m_selected>10M</OPTION>
                      <OPTION VALUE=\"5M\" $is_vlt_tf_5m_selected>5M</OPTION>
                      <OPTION VALUE=\"3M\" $is_vlt_tf_3m_selected>3M</OPTION>
                      <OPTION VALUE=\"1M\" $is_vlt_tf_1m_selected>1M</OPTION>
                      </SELECT>
              &nbsp;</SPAN>" ;
       }
    else { print "<INPUT TYPE=\"hidden\" VALUE=\"$vlt_tf\" name=\"vlt_time_frame$_id_suffix\" id=\"id_vlt_time_frame_$id_suffix\"></TD>" ; }

    my $sz_env_nvgt_visibility = "" ; if ( $env_mode == 0 && $nvgt_mode eq "no_disabled" ) { $sz_env_nvgt_visibility = " STYLE=\"display: none;\"" ; }
    print "\n<TD><SPAN $sz_env_nvgt_visibility>ENV&nbsp;
             <INPUT CLASS=\"complex_navigation\" name=\"env_prct_$id_suffix\" id=\"id_env_prct_$id_suffix\" value=\"$env_prct\"
                    onchange=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference',id_ema_time_frame_$id_suffix.value,id_count_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value, '$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ema_time_frame_$id_suffix.value,'$block_size','$nvgt_mode')\"></INPUT>
             </SPAN></TD>" ;

    if ( $block_size ne "half" ) {
       print "\n&nbsp;&nbsp;<A CLASS=\"complex_navigation\" TITLE=\"Портрет монеты\" HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_common_info.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=1D&count_prds=$count_prds&macd_mult=$pv{macd_mult}&env_prct=$half_min_week_volatility&output_type=graph&brush_size=4&x_size=2440&y_size=1240\">COIN</A>" ;
       }
    print "&nbsp;<A CLASS=\"complex_navigation\" TITLE=\"SWING недельный цикл\" HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_trading.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=SWING_WEEK\">W</A>
           &nbsp;<A CLASS=\"complex_navigation\" TITLE=\"INTRADAY дневной цикл\" HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_trading.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=SWING_DAY\">D</A>" ;
    if ( $block_size ne "half" ) {
       print "&nbsp;<A CLASS=\"complex_navigation\" TITLE=\"Сравнение таймфрэймов для монеты\" HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_one_coin_TF_compare.cgi?currency=$currency&curr_reference=$curr_reference\">CMP</A>
              &nbsp;&nbsp;&nbsp;
              &nbsp;<A CLASS=\"complex_navigation\" TARGET=\"_blank\" TITLE=\"ByBit USDT (нужно войти)\" HREF=\"https://www.bybit.com/trade/usdt/$currency$curr_reference\">ByB</A>
              &nbsp;<A CLASS=\"complex_navigation\" TARGET=\"_blank\" TITLE=\"Coin Glass (нужно войти)\" HREF=\"https://www.coinglass.com/tv/Bybit_$currency$curr_reference\">CGls</A>
              &nbsp;<A CLASS=\"complex_navigation\" TARGET=\"_blank\" TITLE=\"Coin Trader (может не совпасть название монет, тогда руками)\" HREF=\"https://charts.cointrader.pro/charts.html?coin=$currency%3A$curr_reference\">CTrd</A>" ;
       }
    print "</TD><TR></TABLE></DIV>" ;
    print " -->" ;


#    if ( $vol_mode > 0 ) {
    print "\n<A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_VOLUME.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$pv{weeks_vol_tf}&count_prds=$pv{weeks_vol_prds}&output_type=graph&brush_size=4&x_size=2110&y_size=340\" TARGET=\"_blank\">
                <IMG CLASS=\"macd_graph_$id_suffix\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_VOLUME.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$pv{weeks_vol_tf}&count_prds=$pv{weeks_vol_prds}&output_type=graph&brush_size=4&x_size=$common_graphs_x_size&y_size=340\"></A>" ;
#                <IMG CLASS=\"macd_graph_$id_suffix\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_VOLUME.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$vol_tf&count_prds=$vol_count_prds&output_type=graph&brush_size=4&x_size=1602&y_size=240\"></A>" ;
#          }

#    if ($ema_mode > 0) {
#       if ($ema_mode == 1 || $ema_mode == 3) {
          print "\n<BR>
                   <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_OHLCV_EMA_ENV_BL.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$pv{weeks_price_tf}&count_prds=$pv{weeks_price_prds}&env_prct=$pv{weeks_env_prct}&output_type=graph&brush_size=4&x_size=2440&y_size=1240&is_ema_periods=default\" TARGET=\"_blank\">
                      <IMG CLASS=\"ohlc_ema_graph_$id_suffix\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_OHLCV_EMA_ENV_BL.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$pv{weeks_price_tf}&count_prds=$pv{weeks_price_prds}&env_prct=$pv{weeks_env_prct}&output_type=graph&brush_size=4&x_size=$common_graphs_x_size&y_size=1240&is_ema_periods=default\"></A>" ; 
#          print "\n<A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_OHLCV_EMA_ENV_BL.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$ema_tf&count_prds=$count_prds&env_prct=$env_prct&output_type=graph&brush_size=4&x_size=2440&y_size=1240&is_ema_periods=default&is_ema05=shadow\" TARGET=\"_blank\">
#                      <IMG CLASS=\"ohlc_ema_graph_$id_suffix\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_OHLCV_EMA_ENV_BL.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$ema_tf&count_prds=$count_prds&env_prct=$env_prct&output_type=graph&brush_size=4&x_size=2440&y_size=710&is_ema_periods=default&is_ema05=shadow\"></A>" ; 

#          }
#       }

#    if ($macd_mode > 0) {
#print "\n<BR>=== debug EMA / MACD / MACD2 === TF $ema_tf / $macd_tf / $macd_2_tf === PRDS $count_prds / $macd_count_prds / $macd_2_prds ===<BR>" ;
       print "\n<BR>
              <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_MACD_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$pv{days_macd_tf}&count_prds=$pv{days_macd_prds}&output_type=graph&brush_size=4&x_size=2440&y_size=640\" TARGET=\"_blank\">
                 <IMG CLASS=\"macd_graph_$id_suffix\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_MACD_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$pv{days_macd_tf}&count_prds=$pv{days_macd_prds}&output_type=graph&brush_size=4&x_size=$common_graphs_x_size&y_size=240\"></A>" ;

       print "\n<BR>
              <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_MACD_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$pv{weeks_macd_tf}&count_prds=$pv{weeks_macd_prds}&output_type=graph&brush_size=4&x_size=2440&y_size=640\" TARGET=\"_blank\">
                 <IMG CLASS=\"macd_graph_$id_suffix\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_MACD_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$pv{weeks_macd_tf}&count_prds=$pv{weeks_macd_prds}&output_type=graph&brush_size=4&x_size=$common_graphs_x_size&y_size=240\"></A>" ;

       print "\n<BR>
              <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_MACD_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$pv{months_macd_tf}&count_prds=$pv{months_macd_prds}&output_type=graph&brush_size=4&x_size=2440&y_size=640\" TARGET=\"_blank\">
                 <IMG CLASS=\"macd_graph_$id_suffix\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_MACD_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$pv{months_macd_tf}&count_prds=$pv{months_macd_prds}&output_type=graph&brush_size=4&x_size=$common_graphs_x_size&y_size=240\"></A>" ;

       print "\n<BR>
              <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_MACD_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$pv{yhalf_macd_tf}&count_prds=$pv{yhalf_macd_prds}&output_type=graph&brush_size=4&x_size=2440&y_size=640\" TARGET=\"_blank\">
                 <IMG CLASS=\"macd_graph_$id_suffix\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_MACD_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$pv{yhalf_macd_tf}&count_prds=$pv{yhalf_macd_prds}&output_type=graph&brush_size=4&x_size=$common_graphs_x_size&y_size=240\"></A>" ;
#       }
#    else { print "&nbsp;" ; }

#    if ($rsi_mode > 0) {
#print "\n<BR>=== debug EMA / RSI === TF $ema_tf / $rsi_tf === PRDS $count_prds / $rsi_count_prds ===<BR>" ;
       print "\n<BR>
              <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_RSI_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$pv{days_rsi_tf}&count_prds=$pv{days_rsi_prds}&output_type=graph&brush_size=4&x_size=2440&y_size=640\" TARGET=\"_blank\">
                 <IMG CLASS=\"rsi_graph_$id_suffix\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_RSI_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$pv{days_rsi_tf}&count_prds=$pv{days_rsi_prds}&output_type=graph&brush_size=4&x_size=$common_graphs_x_size&y_size=240\"></A>" ;

       print "\n<BR>
              <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_RSI_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$pv{weeks_rsi_tf}&count_prds=$pv{weeks_rsi_prds}&output_type=graph&brush_size=4&x_size=2440&y_size=640\" TARGET=\"_blank\">
                 <IMG CLASS=\"rsi_graph_$id_suffix\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_RSI_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$pv{weeks_rsi_tf}&count_prds=$pv{weeks_rsi_prds}&output_type=graph&brush_size=4&x_size=$common_graphs_x_size&y_size=240\"></A>" ;

       print "\n<BR>
              <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_RSI_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$pv{months_rsi_tf}&count_prds=$pv{months_rsi_prds}&output_type=graph&brush_size=4&x_size=2440&y_size=640\" TARGET=\"_blank\">
                 <IMG CLASS=\"rsi_graph_$id_suffix\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_RSI_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$pv{months_rsi_tf}&count_prds=$pv{months_rsi_prds}&output_type=graph&brush_size=4&x_size=$common_graphs_x_size&y_size=240\"></A>" ;

       print "\n<BR>
              <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_RSI_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$pv{yhalf_rsi_tf}&count_prds=$pv{yhalf_rsi_prds}&output_type=graph&brush_size=4&x_size=2440&y_size=640\" TARGET=\"_blank\">
                 <IMG CLASS=\"rsi_graph_$id_suffix\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_RSI_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$pv{yhalf_rsi_tf}&count_prds=$pv{yhalf_rsi_prds}&output_type=graph&brush_size=4&x_size=$common_graphs_x_size&y_size=240\"></A>" ;

#       if ($rsi_mode == 2) {
#          print "\n<BR>
#                 <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_RSI_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$ema_tf&count_prds=$count_prds&output_type=graph&brush_size=4&x_size=1440&y_size=640\" TARGET=\"_blank\">
#                    <IMG CLASS=\"rsi_graph_$id_suffix\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_RSI_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$ema_tf&count_prds=$count_prds&output_type=graph&brush_size=4&x_size=1440&y_size=240\"></A>" ;
#          }
#       }
#    else { print "&nbsp;" ; }

#    if ($vlt_mode > 0) {
#print "\n<BR>=== debug EMA / VLT === TF $ema_tf / $vlt_tf === PRDS $count_prds / $vlt_count_prds ===<BR>" ;
       print "\n<BR>
              <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_VLT_WNDW.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$pv{weeks_vlt_tf}&count_prds=$pv{weeks_vlt_prds}&output_type=graph&brush_size=4&x_size=1400&y_size=640\" TARGET=\"_blank\">
                 <IMG CLASS=\"vlt_graph_$id_suffix\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_VLT_WNDW.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$pv{weeks_vlt_tf}&count_prds=$pv{weeks_vlt_prds}&output_type=graph&brush_size=4&x_size=$common_graphs_x_size&y_size=240\"></A>" ;
#       }
#    else { print "&nbsp;" ; }

    }
# конец - функция отрисовки основного трэйдингового блока монеты, опосредованно вызывается из функций Java Script, которые вызывают отдельный cgi модуль _ajax_for_trading.cgi с этой функцией

# начало - функция отрисовки основного трэйдингового блока монеты, опосредованно вызывается из функций Java Script, которые вызывают отдельный cgi модуль _ajax_for_trading.cgi с этой функцией
sub print_coin_graphs_block($$$$$$$$$$$$$$$$$$$$$$$$) {
    my $id_element = $_[0] ;
    my $currency = $_[1] ;
    my $curr_reference = $_[2] ;
    my $ohlc_mode = $_[3] ;
    my $ohlc_tf = $_[4] ;
    my $count_prds = $_[5] ;
    my $offset_prds = $_[6] ;
    my $env_prct = $_[7] ;
    my $ema_mode = $_[8] ;    if ($ema_mode eq "") { $ema_mode = "1" ; }
    my $ema_tf = $_[9] ;      if ($ema_tf eq "") { $ema_tf = $ohlc_tf ; }
    my $macd_mode = $_[10] ;  if ($macd_mode eq "") { $macd_mode = "1" ; }
    my $macd_tf = $_[11] ;    if ($macd_tf eq "") { $macd_tf = $ohlc_tf ; }
    my $macd_mult = $_[12] ;  if ($macd_mult eq "") { $macd_mult = "x1" ; }
    my $rsi_mode = $_[13] ;   if ($rsi_mode eq "") { $rsi_mode = "1" ; }
    my $rsi_tf = $_[14] ;     if ($rsi_tf eq "") { $rsi_tf = $ohlc_tf ; }
    my $vlt_mode = $_[15] ;   if ($vlt_mode eq "") { $vlt_mode = "1" ; }
    my $vlt_tf = $_[16] ;     if ($vlt_tf eq "") { $vlt_tf = $ohlc_tf ; }
    my $vol_mode = $_[17] ;   if ($vol_mode eq "") { $vol_mode = "1" ; }
    my $vol_tf = $_[18] ;     if ($vol_tf eq "") { $vol_tf = $ohlc_tf ; }
    my $block_size = $_[19] ; if ($vol_tf eq "") { $vol_tf = $ohlc_tf ; }
    my $nvgt_mode = $_[20] ; 
    my $src_prds = $_[21] ;   if ($src_prds eq "") { $src_prds = "tsp" ; }
    my $start_tsp = $_[22] ;
    my $stop_tsp = $_[23] ;
# выделить суффикс
    my $id_suffix = $id_element ; $id_suffix =~ s/id_trading_block_//g ;
#-debug-print("<BR>debug параметры при вызове функции print_coin_graphs_block function ===\n<BR>--- id = id_trading_block_$currency"."_$curr_reference"."\n<BR>--- currency = $currency"."\n<BR>--- curr_reference = $curr_reference"."\n<BR>---ohlc_mode = $ohlc_mode"."\n<BR>---ohlc_tf = $ohlc_tf"."\n<BR>---count_prds = $count_prds"."\n<BR>---offset_prds = $offset_prds"."\n<BR>--- env_prct $env_prct"."\n<BR>--- ema_mode = $ema_mode"."\n<BR>--- ema_tf = $ema_tf"."\n<BR>--- macd_mode = $macd_mode"."\n<BR>--- macd_tf = $macd_tf"."\n<BR>--- rsi_mode = $rsi_mode"."\n<BR>--- rsi_tf = $rsi_tf"."\n<BR>--- vlt_mode = $vlt_mode"."\n<BR>--- vlt_tf = $vlt_tf"."\n<BR>--- vol_mode = $vol_mode"."\n<BR>--- vol_tf = $vol_tf"."\n<BR>--- block_size = $block_size"."\n<BR>--- nvgt_mode = $nvgt_mode"."\n<BR>--- src_prds = $src_prds"."\n<BR>--- start_tsp = $start_tsp"."\n<BR>--- stop_tsp = $stop_tsp"."\n<BR>---"."<BR>") ;

    if ( $offset_prds eq "" || $offset_prds < 1 ) { $offset_prds = 0 ; }
    $count_prds_minus = int($count_prds / 2) ; $count_prds_plus = int($count_prds * 2) ;
    $offset_prds_minus = int($offset_prds + ($count_prds / 16)) ; $offset_prds_minus = $offset_prds_minus < 0 ? 0 : $offset_prds_minus ; $offset_prds_plus = int($offset_prds - ($count_prds / 16)) ; $offset_prds_plus = $offset_prds_plus < 0 ? 0 : $offset_prds_plus ;
    $offset_prds = int($offset_prds) ; $count_prds = int($count_prds) ;

# обрабатываем режимы выборки диапазона отображения
    $current_tsp = `date "+%Y-%m-%d %H:%M:%S"` ; my $uni_current_tsp =  `date -d \"$current_tsp\" \"+%s\"` ;
    if ( $src_prds eq "per_count" || $src_prds eq "" ) {
       $uni_stop_tsp = $uni_current_tsp - (recode_tf_periods("$ohlc_tf", "1M",  $offset_prds) * 60) ; $stop_tsp = `date -d \"\@$uni_stop_tsp\" "+%Y-%m-%d %H:%M:%S"` ;
       $uni_start_tsp = $uni_stop_tsp - (recode_tf_periods("$ohlc_tf", "1M",  $count_prds) * 60) ; $start_tsp = `date -d \"\@$uni_start_tsp\" "+%Y-%m-%d %H:%M:%S"` ;
       }

    if ( $src_prds eq "per_tsp" ) {
       my $uni_stop_tsp =  `date -d \"$stop_tsp\" \"+%s\"` ; $offset_prds = recode_tf_periods("1M", "$ohlc_tf", int(($uni_current_tsp - $uni_stop_tsp) / 60)) ; #$pv{offset_prds} = $offset_prds ;
       my $uni_start_tsp =  `date -d \"$start_tsp\" \"+%s\"` ; $count_prds = recode_tf_periods("1M", "$ohlc_tf", int(($uni_stop_tsp - $uni_start_tsp) / 60)) ; #$pv{count_prds} = $count_prds ;
       }

# чтобы узнать периоды индикаторов в случае выборки по датам - сначала нуждно получить количество периодов
    my $macd_count_prds = recode_tf_periods("$ohlc_tf","$macd_tf",$count_prds) ;
    my $rsi_count_prds = recode_tf_periods("$ohlc_tf","$rsi_tf",$count_prds) ;
    my $vlt_count_prds = recode_tf_periods("$ohlc_tf","$vlt_tf",$count_prds) ;
    my $vol_count_prds = recode_tf_periods("$ohlc_tf","$vol_tf",$count_prds) ;

# v.0.9 добавляем явные стили графиков для реализации нахождения нескольких экземпляров трэйдингового блока монеты разного размероа на странице
    $img_style{$id_element} = "---!!!-unknown-!!!---" ;
    if ( $block_size eq "full" ) { $img_style{$id_element} = "           IMG.ohlc_ema_graph_$id_suffix { width: 701pt; height: 320pt; }
           IMG.ohlc_ema_graph_gd_$id_suffix { width: 650pt; height: 320pt; }
           IMG.macd_graph_$id_suffix { width: 701pt; height: 110pt; }
           IMG.rsi_graph_$id_suffix { width: 701pt; height: 110pt; }
           IMG.vlt_graph_$id_suffix { width: 701pt; height: 110pt; }" ;
           }

    if ( $block_size eq "half" ) { $img_style{$id_element} = "           IMG.ohlc_ema_graph_$id_suffix { width: 379pt; height: 180pt; }
           IMG.ohlc_ema_graph_gd_$id_suffix { width: 379pt; height: 180pt; }
           IMG.macd_graph_$id_suffix { width: 379pt; height: 70pt; }
           IMG.rsi_graph_$id_suffix { width: 379pt; height: 70pt; }
           IMG.vlt_graph_$id_suffix { width: 379pt; height: 70pt; }" ;
           }

    if ( $block_size eq "middle" ) { $img_style{$id_element} = "           IMG.ohlc_ema_graph_$id_suffix { width: 510pt; height: 270pt; }
           IMG.ohlc_ema_graph_gd_$id_suffix { width: 450pt; height: 270pt; }
           IMG.macd_graph_$id_suffix { width: 510pt; height: 107pt; }
           IMG.rsi_graph_$id_suffix { width: 510pt; height: 107pt; }
           IMG.vlt_graph_$id_suffix { width: 510pt; height: 107pt; }" ;
           }

    print "\n<STYLE>
           A.complex_navigation:link { font-size: 7pt; }
           A.complex_navigation:active { font-size: 7pt; }
           A.complex_navigation:visited { font-size: 7pt; }
           A.complex_navigation:hover { font-size: 7pt; }

           SELECT.complex_navigation { font-size: 7pt; width: 30pt; }
           DIV.complex_navigation { font-size: 7pt; }
           SPAN.complex_navigation { cursor: pointer; font-size: 7pt; }
           INPUT.complex_navigation { width: 20pt; cursor: pointer; font-size: 7pt; }
           TD.complex_navigation { font-size: 7pt; text-align: center ; background-color: #CCCCCC; }

           $img_style{$id_element}
           </STYLE>" ;
##CC99FF #6699FF
    my $zs_nvgt_mode_visibility = "" ; if ( $nvgt_mode eq "no_show" ) { $zs_nvgt_mode_visibility = " STYLE=\"visibility: hidden;\"" ; }
    my $next_ohlc_mode = $ohlc_mode ; my $ohlc_color = "black" ; if ( $ohlc_mode == 0 ) { $next_ohlc_mode = 1 ; $ohlc_color = "gray" ; } if ( $ohlc_mode == 1 ) { $next_ohlc_mode = 2 ; $ohlc_color = "green" ; } if ( $ohlc_mode == 2 ) { $next_ohlc_mode = 3 ; $ohlc_color = "red" ; } if ( $ohlc_mode == 3 ) { $next_ohlc_mode = 0 ; $ohlc_color = "purple" ; }
    print "\n<DIV CLASS=\"complex_navigation\" $zs_nvgt_mode_visibility><TABLE STYLE=\"width: 100%;\"><TR><TD CLASS=\"complex_navigation\">$currency/$curr_reference<BR>" ;
    print "<A CLASS=\"complex_navigation\" TITLE=\"[0] не показать график OHLC, [1] показать основной график OHLC, [2] показать дополнительный график OHLC свечи, [3] показывать линейный и свечной графики OHLC\"
                     onclick=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$next_ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$next_ema_mode','$ema_tf','$next_macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','$src_prds',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\"><SPAN STYLE=\"color: $ohlc_color;\">OHLC</SPAN></A>&nbsp;" ;
    if ( $block_size ne "half" ) {
       print "<A CLASS=\"complex_navigation\" TITLE=\"данные графика в табличной форме\" HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_OHLCV_EMA_ENV_BL.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$ohlc_tf&count_prds=$count_prds&offset_prds=$offset_prds&env_prct=$env_prct&output_type=table&brush_size=4&x_size=2440&y_size=1240&is_ema_periods=default&is_ema05=shadow\" TARGET=\"_blank\">[T</A>" ;
       print "<A CLASS=\"complex_navigation\" TITLE=\"текст запроса к базе данных\" HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_OHLCV_EMA_ENV_BL.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$ohlc_tf&count_prds=$count_prds&offset_prds=$offset_prds&env_prct=$env_prct&output_type=query&brush_size=4&x_size=2440&y_size=1240&is_ema_periods=default&is_ema05=shadow\" TARGET=\"_blank\">Q</A>]" ;
       }

# - в версии 22 была допущена ошибка полного не вывода параметров - а без их значений не работают функции. Сейчас - будем просто скрывать
    print "<INPUT TYPE=\"hidden\" name=\"block_size$_id_suffix\" id=\"id_block_size_$id_suffix\" VALUE=\"$block_size\"></INPUT></TD>" ;

# блок ТФ, дат и периодов OHLC
# ##########################################################################################################################################################################
    my $next_ohlc_mode = $ohlc_mode ; my $ohlc_color = "black" ; if ( $ohlc_mode == 0 ) { $next_ohlc_mode = 1 ; $ohlc_color = "gray" ; } if ( $ohlc_mode == 1 ) { $next_ohlc_mode = 2 ; $ohlc_color = "green" ; } if ( $ohlc_mode == 2 ) { $next_ohlc_mode = 3 ; $ohlc_color = "red" ; } if ( $ohlc_mode == 3 ) { $next_ohlc_mode = 0 ; $ohlc_color = "purple" ; }
    print "<TD CLASS=\"complex_navigation\"><SPAN $sz_ema_nvgt_visibility>\n" ;
    print "<INPUT onchange=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$ema_tf','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','per_tsp',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\"
                  CLASS=\"complex_navigation\" name=\"start_tsp_$id_suffix\" id=\"id_start_tsp_$id_suffix\" value=\"$start_tsp\" STYLE=\"text-align: right; width: 74pt;\" TITLE=\"universal time = $uni_start_tsp\"></INPUT>
           <INPUT onchange=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$ema_tf','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','per_tsp',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\"
                  CLASS=\"complex_navigation\" name=\"stop_tsp_$id_suffix\" id=\"id_stop_tsp_$id_suffix\" value=\"$stop_tsp\" STYLE=\"text-align: right; width: 74pt;\" TITLE=\"universal time = $uni_stop_tsp\"></INPUT>
           <BR>
           <SPAN STYLE=\"white-space: nowrap;\">
                 <SPAN CLASS=\"complex_navigation\" TITLE=\"-50% отображаемого периода\" $sz_ema_nvgt_visibility
                       onwheel=\"two_onwheel(event,'id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$ema_tf','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','per_count',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\"
                       onclick=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf','$count_prds_minus','$offset_prds',id_env_prct_$id_suffix.value,'$ema_mode','$ema_tf','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','per_count',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\">[-]</SPAN>
           &nbsp;<SPAN CLASS=\"complex_navigation\" TITLE=\"количество отображаемых периодов\" $sz_ema_nvgt_visibility
                       onwheel=\"two_onwheel(event,'id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$ema_tf','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','per_count',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\"
                       onchange=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$ema_tf','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','per_count',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\"><INPUT CLASS=\"complex_navigation\" name=\"count_prds_$id_suffix\" id=\"id_count_prds_$id_suffix\" value=\"$count_prds\" STYLE=\"text-align: center;\"></INPUT></SPAN>
           &nbsp;<SPAN CLASS=\"complex_navigation\" TITLE=\"+50% отображаемого периода\" $sz_ema_nvgt_visibility
                       onwheel=\"two_onwheel(event,'id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$ema_tf','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','per_count',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\"
                       onclick=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf','$count_prds_plus','$offset_prds',id_env_prct_$id_suffix.value,'$ema_mode','$ema_tf','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','per_count',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\">[+]</SPAN>
           </SPAN>" ;

    if ( $block_size eq "half" ) { print "<BR>" ; } else { print "&nbsp;" ; } 
    print "<SELECT CLASS=\"complex_navigation\" name=\"ohlc_time_frame_$id_suffix\" id=\"id_ohlc_time_frame_$id_suffix\" TITLE=\"основной ТФ, меняет выбор EMA всех индикаторов, текущих периодов $count_prds\" $sz_ema_nvgt_visibility
                   onchange=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode',id_ohlc_time_frame_$id_suffix.value,id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$ema_tf','$macd_mode',id_ohlc_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_ohlc_time_frame_$id_suffix.value,'$vlt_mode',id_ohlc_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,id_block_size_$id_suffix.value,'$nvgt_mode','per_tsp',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\">" ;
    print_select_tf_options($ohlc_tf) ;
    print "</SELECT>" ;
    if ( $block_size eq "half" ) { print "<BR>" ; } else { print "&nbsp;" ; } 

    print "<SPAN STYLE=\"white-space: nowrap;\">
                 <SPAN CLASS=\"complex_navigation\" TITLE=\"-25% отображаемого периода\" $sz_ema_nvgt_visibility
                       onwheel=\"two_onwheel_offset(event,'id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$ema_tf','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','per_count',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\"
                       onclick=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf','$count_prds','$offset_prds_minus',id_env_prct_$id_suffix.value,'$ema_mode',id_ema_time_frame_$id_suffix.value,'$macd_mode','$ema_tf','$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','per_count',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\">[-]</SPAN>
           &nbsp;<SPAN CLASS=\"complex_navigation\" TITLE=\"смещение в прошлое\" $sz_ema_nvgt_visibility
                       onwheel=\"two_onwheel_offset(event,'id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$ema_tf','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','per_count',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\"
                       onchange=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_ohlc_time_frame_$id_suffix.value,id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$ema_tf','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','per_count',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\"><INPUT CLASS=\"complex_navigation\" name=\"offset_prds_$id_suffix\" id=\"id_offset_prds_$id_suffix\" value=\"$offset_prds\" STYLE=\"text-align: center;\"></INPUT></SPAN>
           &nbsp;<SPAN CLASS=\"complex_navigation\" TITLE=\"+25% отображаемого периода\" $sz_ema_nvgt_visibility
                       onwheel=\"two_onwheel_offset(event,'id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$ema_tf','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','per_count',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\"
                       onclick=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf','$count_prds','$offset_prds_plus',id_env_prct_$id_suffix.value,'$ema_mode','$ema_tf','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','per_count',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\">[+]</SPAN>
           </SPAN></SPAN></TD>";

# блок EMA1
# ##########################################################################################################################################################################
    my $sz_ema_nvgt_visibility = "" ; if ( $ema_mode == 0 && $nvgt_mode eq "no_disabled") { $sz_ema_nvgt_visibility = " STYLE=\"display: none;\"" ; }
    my $next_ema_mode = $ema_mode ; my $ema_color = "black" ; if ( $ema_mode == 0 ) { $next_ema_mode = 1 ; $ema_color = "gray" ; } if ( $ema_mode == 1 ) { $next_ema_mode = 2 ; $ema_color = "green" ; } if ( $ema_mode == 2 ) { $next_ema_mode = 3 ; $ema_color = "red" ; } if ( $ema_mode == 3 ) { $next_ema_mode = 0 ; $ema_color = "purple" ; }
    print "<TD CLASS=\"complex_navigation\"><SPAN $sz_ema_nvgt_visibility>\n" ;
    print "<A CLASS=\"complex_navigation\" TITLE=\"[0] не показать график EMA, [1] показать основной график ЕМА, [2] показать дополнительный график ЕМА свечи, [3] показывать линейный и свечной графики EMA\"
                     onclick=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$next_ema_mode','$ema_tf','$next_macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','$src_prds',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\"><SPAN STYLE=\"color: $ema_color;\">EMA&nbsp;01</SPAN>&nbsp;</A>" ;
    print "\n<BR>
           <SELECT CLASS=\"complex_navigation\" name=\"ema_time_frame_$id_suffix\" id=\"id_ema_time_frame_$id_suffix\" TITLE=\"основной ТФ, меняет выбор EMA всех индикаторов, текущих периодов $count_prds\" $sz_ema_nvgt_visibility
                   onchange=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode',id_ema_time_frame_$id_suffix.value,'$macd_mode',id_ohlc_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_ohlc_time_frame_$id_suffix.value,'$vlt_mode',id_ohlc_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,id_block_size_$id_suffix.value,'$nvgt_mode','per_tsp',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\">" ;
# !!!!!!!!!!!!!!!!!!!!!!!!! добавить переменную в аргументы функции
    print_select_tf_options($ema_tf) ;
    print "</SELECT></SPAN>" ;
    if ( $block_size ne "half" ) { print "</TD>" ; } else { print "<BR>\n" ; }

# блок EMA2
# ##########################################################################################################################################################################
    my $sz_ema2_nvgt_visibility = "" ; if ( $ema2_mode == 0 && $nvgt_mode eq "no_disabled") { $sz_ema2_nvgt_visibility = " STYLE=\"display: none;\"" ; }
    my $next_ema2_mode = $ema2_mode ; my $ema2_color = "black" ; if ( $ema2_mode == 0 ) { $next_ema2_mode = 1 ; $ema2_color = "gray" ; } if ( $ema2_mode == 1 ) { $next_ema2_mode = 2 ; $ema2_color = "green" ; } if ( $ema2_mode == 2 ) { $next_ema2_mode = 3 ; $ema2_color = "red" ; } if ( $ema2_mode == 3 ) { $next_ema2_mode = 0 ; $ema2_color = "purple" ; }
    if ( $block_size ne "half" ) { print "<TD CLASS=\"complex_navigation\">" ; }
    print "<SPAN $sz_ema2_nvgt_visibility>\n" ;
    print "<A CLASS=\"complex_navigation\" TITLE=\"[0] не показать график ema2, [1] показать основной график ЕМА, [2] показать дополнительный график ЕМА свечи, [3] показывать линейный и свечной графики ema2\"
                     onclick=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$next_ema2_mode','$ema2_tf','$next_macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','$src_prds',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\"><SPAN STYLE=\"color: $ema2_color;\">EMA&nbsp;02</SPAN>&nbsp;</A>" ;
    print "\n<BR>
           <SELECT CLASS=\"complex_navigation\" name=\"ema2_time_frame_$id_suffix\" id=\"id_ema2_time_frame_$id_suffix\" TITLE=\"основной ТФ, меняет выбор ema2 всех индикаторов, текущих периодов $count_prds\" $sz_ema2_nvgt_visibility
                   onchange=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema2_mode',id_ema2_time_frame_$id_suffix.value,'$macd_mode',id_ohlc_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_ohlc_time_frame_$id_suffix.value,'$vlt_mode',id_ohlc_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,id_block_size_$id_suffix.value,'$nvgt_mode','per_tsp',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\">" ;
    print_select_tf_options($ema2_tf) ;
    print "</SELECT></SPAN></TD>" ;

# блок EMA3
# ##########################################################################################################################################################################
    my $sz_ema3_nvgt_visibility = "" ; if ( $ema3_mode == 0 && $nvgt_mode eq "no_disabled") { $sz_ema3_nvgt_visibility = " STYLE=\"display: none;\"" ; }
    my $next_ema3_mode = $ema3_mode ; my $ema3_color = "black" ; if ( $ema3_mode == 0 ) { $next_ema3_mode = 1 ; $ema3_color = "gray" ; } if ( $ema3_mode == 1 ) { $next_ema3_mode = 2 ; $ema3_color = "green" ; } if ( $ema3_mode == 2 ) { $next_ema3_mode = 3 ; $ema3_color = "red" ; } if ( $ema3_mode == 3 ) { $next_ema3_mode = 0 ; $ema3_color = "purple" ; }
    print "<TD CLASS=\"complex_navigation\"><SPAN $sz_ema3_nvgt_visibility>\n" ;
    print "<A CLASS=\"complex_navigation\" TITLE=\"[0] не показать график ema3, [1] показать основной график ЕМА, [2] показать дополнительный график ЕМА свечи, [3] показывать линейный и свечной графики ema3\"
                     onclick=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$next_ema3_mode','$ema3_tf','$next_macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','$src_prds',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\"><SPAN STYLE=\"color: $ema3_color;\">EMA&nbsp;03</SPAN>&nbsp;</A>" ;
    print "\n<BR>
           <SELECT CLASS=\"complex_navigation\" name=\"ema3_time_frame_$id_suffix\" id=\"id_ema3_time_frame_$id_suffix\" TITLE=\"основной ТФ, меняет выбор ema3 всех индикаторов, текущих периодов $count_prds\" $sz_ema3_nvgt_visibility
                   onchange=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema3_mode',id_ema3_time_frame_$id_suffix.value,'$macd_mode',id_ohlc_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_ohlc_time_frame_$id_suffix.value,'$vlt_mode',id_ohlc_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,id_block_size_$id_suffix.value,'$nvgt_mode','per_tsp',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\">" ;
    print_select_tf_options($ema3_tf) ;
    print "</SELECT></SPAN>" ;
    if ( $block_size ne "half" ) { print "</TD>" ; } else { print "<BR>\n" ; }

# блок EMA4
# ##########################################################################################################################################################################
    my $sz_ema4_nvgt_visibility = "" ; if ( $ema4_mode == 0 && $nvgt_mode eq "no_disabled") { $sz_ema4_nvgt_visibility = " STYLE=\"display: none;\"" ; }
    my $next_ema4_mode = $ema4_mode ; my $ema4_color = "black" ; if ( $ema4_mode == 0 ) { $next_ema4_mode = 1 ; $ema4_color = "gray" ; } if ( $ema4_mode == 1 ) { $next_ema4_mode = 2 ; $ema4_color = "green" ; } if ( $ema4_mode == 2 ) { $next_ema4_mode = 3 ; $ema4_color = "red" ; } if ( $ema4_mode == 3 ) { $next_ema4_mode = 0 ; $ema4_color = "purple" ; }
    if ( $block_size ne "half" ) { print "<TD CLASS=\"complex_navigation\">" ; }
    print "<SPAN $sz_ema4_nvgt_visibility>\n" ;
    print "<A CLASS=\"complex_navigation\" TITLE=\"[0] не показать график ema4, [1] показать основной график ЕМА, [2] показать дополнительный график ЕМА свечи, [3] показывать линейный и свечной графики ema4\"
                     onclick=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$next_ema4_mode','$ema4_tf','$next_macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','$src_prds',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\"><SPAN STYLE=\"color: $ema4_color;\">EMA&nbsp;04</SPAN>&nbsp;</A>" ;
    print "\n<BR>
           <SELECT CLASS=\"complex_navigation\" name=\"ema4_time_frame_$id_suffix\" id=\"id_ema4_time_frame_$id_suffix\" TITLE=\"основной ТФ, меняет выбор ema4 всех индикаторов, текущих периодов $count_prds\" $sz_ema4_nvgt_visibility
                   onchange=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema4_mode',id_ema4_time_frame_$id_suffix.value,'$macd_mode',id_ohlc_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_ohlc_time_frame_$id_suffix.value,'$vlt_mode',id_ohlc_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,id_block_size_$id_suffix.value,'$nvgt_mode','per_tsp',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\">" ;
    print_select_tf_options($ema4_tf) ;
    print "</SELECT></SPAN></TD>" ;


# блок MACD
# ##########################################################################################################################################################################
    my $sz_macd_nvgt_visibility = "" ; if ( $macd_mode == 0 && $nvgt_mode eq "no_disabled" ) { $sz_macd_nvgt_visibility = " STYLE=\"display: none;\"" ; }
    my $next_macd_mode = $macd_mode ; my $macd_color = "black" ; if ( $macd_mode == 0 ) { $next_macd_mode = 1 ; $macd_color = "gray" ; $macd_mult = "x1" ; } if ( $macd_mode == 1 ) { $next_macd_mode = 2 ; $macd_color = "green" ; $macd_mult = "x1" ; } if ( $macd_mode == 2 ) { $next_macd_mode = 3 ; $macd_color = "red" ; $macd_mult = "x1" ; } if ( $macd_mode == 3 ) { $next_macd_mode = 0 ; $macd_color = "purple" ; $macd_mult = "x2" ; }
# если мы выбираем мильтипликатор - не учитывем отдельный ТФ, даже выбранный явно
# если возвращаем на x1 - доступно обновление ведомых через ведущий для второго графика, если включён
# с версии 5 график с мультипликатором обрабатывается переменными macd_2_xxx
    if ( $macd_mult eq "x2") { $macd_2_tf  = $ohlc_tf ; $macd_2_prds = $count_prds ;
       if ( $ohlc_tf eq "1D" ) { $macd_2_tf = "4D" ; $macd_2_prds = $count_prds / 4 ; }
       if ( $ohlc_tf eq "4H" ) { $macd_2_tf = "1D" ; $macd_2_prds = $count_prds / 6 ; }
       if ( $ohlc_tf eq "3H" ) { $macd_2_tf = "4H" ; $macd_2_prds = $count_prds / 4 * 3 ; }
       if ( $ohlc_tf eq "2H" ) { $macd_2_tf = "4H" ; $macd_2_prds = $count_prds / 2 ; }
       if ( $ohlc_tf eq "1H" ) { $macd_2_tf = "2H" ; $macd_2_prds = $count_prds / 2 ; }
       if ( $ohlc_tf eq "30M" || $ohlc_tf eq "30Mh" ) { $macd_2_tf = "1H" ; $macd_2_prds = $count_prds / 2 ; }
       if ( $ohlc_tf eq "15M" || $ohlc_tf eq "15Mh" ) { $macd_2_tf = "30M" ; $macd_2_prds = $count_prds / 2 ; }
       if ( $ohlc_tf eq "10M" || $ohlc_tf eq "10Mh" ) { $macd_2_tf = "30M" ; $macd_2_prds = $count_prds / 3 ; }
       if ( $ohlc_tf eq "5M" ) { $macd_2_tf = "10M" ; $macd_2_prds = $count_prds / 2 ; }
       if ( $ohlc_tf eq "3M" ) { $macd_2_tf = "15M" ; $macd_2_prds = $count_prds / 5 ; }
       if ( $ohlc_tf eq "1M" ) { $macd_2_tf = "3M" ; $macd_2_prds = $count_prds / 3 ; }
       }
    print "\n<TD CLASS=\"complex_navigation\"><SPAN $sz_macd_nvgt_visibility>
           \n<A CLASS=\"complex_navigation\" TITLE=\"[0] не показывать, [1] показать график выбранного ТФ, [2] плюс график текущего ТФ OHLC, [3] второй график в два раза большего ТФ от OHLC\"
                onclick=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$ema_tf','$next_macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','$src_prds',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\"><SPAN STYLE=\"color: $macd_color;\">MACD</SPAN>&nbsp;</A>" ;
    if ( $block_size ne "half" ) {
       print "<A CLASS=\"complex_navigation\" TITLE=\"данные графика в табличной форме\" HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_MACD_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$macd_tf&count_prds=$macd_count_prds&output_type=table&brush_size=4&x_size=1440&y_size=240\" TARGET=\"_blank\">[T</A>" ;
       print "<A CLASS=\"complex_navigation\" TITLE=\"текст запроса к базе данных\" HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_MACD_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$macd_tf&count_prds=$macd_count_prds&output_type=query&brush_size=4&x_size=1440&y_size=240\" TARGET=\"_blank\">Q</A>]" ;
       }
    print "\n<BR><SELECT CLASS=\"complex_navigation\" name=\"macd_time_frame$_id_suffix\" id=\"id_macd_time_frame_$id_suffix\" TITLE=\"отдельный ТФ индикатора MACD, текущих периодов $macd_count_prds\" $sz_macd_nvgt_visibility
                   onchange=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$ema_tf','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','$src_prds',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\">" ;
    print_select_tf_options($macd_tf) ;
    print "</SELECT>" ;

    if ( $block_size ne "half" ) {
# - разрешаем локально изменить ТФ MACD
#       if ( $macd_mult eq "x1" ) { print "&nbsp;<SPAN $sz_macd_nvgt_visibility CLASS=\"complex_navigation\" TITLE=\"при щелчке - показать график MACD следующего ТФ, игнорировать явно выставленный ТФ\"
#          onclick=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$ema_tf','$macd_mode',id_macd_time_frame_$id_suffix.value,'x2','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','$src_prds',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\">[x1]</SPAN>" ; }
#       else { print "&nbsp;<SPAN $sz_macd_nvgt_visibility CLASS=\"complex_navigation\" TITLE=\"при щелчке - показать график MACD текущего ТФ, или выставленный явно отдельный ТФ\"
#            onclick=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$ema_tf','$macd_mode',id_macd_time_frame_$id_suffix.value,'x1','$rsi_mode',id_rsi_time_frame_$id_suffix.value, '$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','$src_prds',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\">[x2]</SPAN>" ; }
       }
    print "</SPAN>" ;
    if ( $block_size ne "half" ) { print "</TD>" ; } else { print "<BR>\n" ; }

# блок RSI
# ##########################################################################################################################################################################
    my $sz_rsi_nvgt_visibility = "" ; if ( $rsi_mode == 0 && $nvgt_mode eq "no_disabled" ) { $sz_rsi_nvgt_visibility = " STYLE=\"display: none;\"" ; }
    my $next_rsi_mode = $rsi_mode ; my $rsi_color = "black" ; if ( $rsi_mode == 0 ) { $next_rsi_mode = 1 ; $rsi_color = "gray" ; } if ( $rsi_mode == 1 ) { $next_rsi_mode = 2 ; $rsi_color = "green" ; } if ( $rsi_mode == 2 ) { $next_rsi_mode = 0 ; $rsi_color = "red" ; }
    if ( $block_size ne "half" ) { print "<TD CLASS=\"complex_navigation\">" ; }
    print "\n<SPAN $sz_rsi_nvgt_visibility>" ;
    print "<A CLASS=\"complex_navigation\" TITLE=\"[0] не показывать, [1] показать график выбранного ТФ, [2] плюс график текущего ТФ EMA\"
              onclick=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$ema_tf','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$next_rsi_mode',id_rsi_time_frame_$id_suffix.value, '$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$block_size')\"><SPAN STYLE=\"color: $rsi_color;\">RSI</SPAN>&nbsp;</A>" ;
    if ( $block_size ne "half" ) {
       print "<A CLASS=\"complex_navigation\" TITLE=\"данные графика в табличной форме\" HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_RSI_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$rsi_tf&count_prds=$count_prds&output_type=table&brush_size=4&x_size=1440&y_size=240\" TARGET=\"_blank\">[T</A>" ;
       print "<A CLASS=\"complex_navigation\" TITLE=\"текст запроса к базе данных\" HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_RSI_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$rsi_tf&count_prds=$count_prds&output_type=query&brush_size=4&x_size=1440&y_size=240\" TARGET=\"_blank\">Q</A>]&nbsp;" ;
       }
    print "\n<BR><SELECT CLASS=\"complex_navigation\" name=\"rsi_time_frame$_id_suffix\" id=\"id_rsi_time_frame_$id_suffix\" TITLE=\"отдельный ТФ индикатора RSI, текущих периодов $rsi_count_prds\"
                   onchange=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$ema_tf','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','$src_prds',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\">" ;
    print_select_tf_options($rsi_tf) ;
    print "</SELECT></SPAN></TD>" ;

# блок Alligator
# ##########################################################################################################################################################################
    my $sz_alligator_nvgt_visibility = "" ; if ( $alligator_mode == 0 && $nvgt_mode eq "no_disabled") { $sz_alligator_nvgt_visibility = " STYLE=\"display: none;\"" ; }
    my $next_alligator_mode = $alligator_mode ; my $alligator_color = "black" ; if ( $alligator_mode == 0 ) { $next_alligator_mode = 1 ; $alligator_color = "gray" ; } if ( $alligator_mode == 1 ) { $next_alligator_mode = 2 ; $alligator_color = "green" ; } if ( $alligator_mode == 2 ) { $next_alligator_mode = 3 ; $alligator_color = "red" ; } if ( $alligator_mode == 3 ) { $next_alligator_mode = 0 ; $alligator_color = "purple" ; }
    print "<TD CLASS=\"complex_navigation\"><SPAN $sz_alligator_nvgt_visibility>\n" ;
    print "<A CLASS=\"complex_navigation\" TITLE=\"[0] не показать график alligator, [1] показать основной график ЕМА, [2] показать дополнительный график ЕМА свечи, [3] показывать линейный и свечной графики alligator\"
                     onclick=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$next_alligator_mode','$alligator_tf','$next_macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','$src_prds',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\"><SPAN STYLE=\"color: $alligator_color;\">Alligator</SPAN>&nbsp;</A>" ;
    print "\n<BR>
           <SELECT CLASS=\"complex_navigation\" name=\"alligator_time_frame_$id_suffix\" id=\"id_alligator_time_frame_$id_suffix\" TITLE=\"основной ТФ, меняет выбор alligator всех индикаторов, текущих периодов $count_prds\" $sz_alligator_nvgt_visibility
                   onchange=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$alligator_mode',id_alligator_time_frame_$id_suffix.value,'$macd_mode',id_ohlc_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_ohlc_time_frame_$id_suffix.value,'$vlt_mode',id_ohlc_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,id_block_size_$id_suffix.value,'$nvgt_mode','per_tsp',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\">" ;
    print_select_tf_options($alligator_tf) ;
    print "</SELECT></SPAN>" ;
    if ( $block_size ne "half" ) { print "</TD>" ; } else { print "<BR>\n" ; }

# блок KST
# ##########################################################################################################################################################################
    my $sz_kst_nvgt_visibility = "" ; if ( $kst_mode == 0 && $nvgt_mode eq "no_disabled") { $sz_kst_nvgt_visibility = " STYLE=\"display: none;\"" ; }
    my $next_kst_mode = $kst_mode ; my $kst_color = "black" ; if ( $kst_mode == 0 ) { $next_kst_mode = 1 ; $kst_color = "gray" ; } if ( $kst_mode == 1 ) { $next_kst_mode = 2 ; $kst_color = "green" ; } if ( $kst_mode == 2 ) { $next_kst_mode = 3 ; $kst_color = "red" ; } if ( $kst_mode == 3 ) { $next_kst_mode = 0 ; $kst_color = "purple" ; }
    if ( $block_size ne "half" ) { print "<TD CLASS=\"complex_navigation\">" ; }
    print "<SPAN $sz_kst_nvgt_visibility>\n" ;
    print "<A CLASS=\"complex_navigation\" TITLE=\"[0] не показать график kst, [1] показать основной график ЕМА, [2] показать дополнительный график ЕМА свечи, [3] показывать линейный и свечной графики kst\"
                     onclick=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$next_kst_mode','$kst_tf','$next_macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','$src_prds',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\"><SPAN STYLE=\"color: $kst_color;\">KST</SPAN>&nbsp;</A>" ;
    print "\n<BR>
           <SELECT CLASS=\"complex_navigation\" name=\"kst_time_frame_$id_suffix\" id=\"id_kst_time_frame_$id_suffix\" TITLE=\"основной ТФ, меняет выбор kst всех индикаторов, текущих периодов $count_prds\" $sz_kst_nvgt_visibility
                   onchange=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$kst_mode',id_kst_time_frame_$id_suffix.value,'$macd_mode',id_ohlc_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_ohlc_time_frame_$id_suffix.value,'$vlt_mode',id_ohlc_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,id_block_size_$id_suffix.value,'$nvgt_mode','per_tsp',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\">" ;
    print_select_tf_options($kst_tf) ;
    print "</SELECT></SPAN></TD>" ;

# - блок VLT
# ##########################################################################################################################################################################
    my $sz_vlt_nvgt_visibility = "" ; if ( $vlt_mode == 0 && $nvgt_mode eq "no_disabled" ) { $sz_vlt_nvgt_visibility = " STYLE=\"display: none;\"" ; }
    my $next_vlt_mode = $vlt_mode ; if ( $vlt_mode == 0 ) { $next_vlt_mode = 1 ; } if ( $vlt_mode == 1 ) { $next_vlt_mode = 2 ; } if ( $vlt_mode == 2 ) { $next_vlt_mode = 0 ; }
    if ( $block_size ne "half") {
       print "\n<TD CLASS=\"complex_navigation\"><SPAN $sz_vlt_nvgt_visibility>VLT&nbsp;" ;
       print "\n[<A CLASS=\"complex_navigation\" TITLE=\"[0] не показывать, [1] показать график выбранного ТФ, [2] плюс график текущего ТФ EMA\"
               onclick=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$ema_tf','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$next_vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','$src_prds',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\">$vlt_mode</A><A CLASS=\"complex_navigation\" TITLE=\"данные графика в табличной форме\">T</A><A CLASS=\"complex_navigation\" TITLE=\"текст запроса к базе данных\">Q</A>]
               &nbsp;" ;
       print "\n<BR><SELECT CLASS=\"complex_navigation\" name=\"vlt_time_frame$_id_suffix\" id=\"id_vlt_time_frame_$id_suffix\" TITLE=\"отдельный ТФ индикатора волатильности, текущих периодов $vlt_count_prds\"
                      onchange=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$ema_tf','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','$src_prds',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\">" ;
    print_select_tf_options($vlt_tf) ;
    print "</SELECT>&nbsp;</SPAN></TD>" ;
       }
    else { print "<INPUT TYPE=\"hidden\" VALUE=\"$vlt_tf\" name=\"vlt_time_frame$_id_suffix\" id=\"id_vlt_time_frame_$id_suffix\">" ; }

# - блок ENV
    my $sz_env_nvgt_visibility = "" ; if ( $env_mode == 0 && $nvgt_mode eq "no_disabled" ) { $sz_env_nvgt_visibility = " STYLE=\"display: none;\"" ; }
    print "\n<TD CLASS=\"complex_navigation\"><SPAN $sz_env_nvgt_visibility>ENV&nbsp;
             <BR><INPUT CLASS=\"complex_navigation\" name=\"env_prct_$id_suffix\" id=\"id_env_prct_$id_suffix\" value=\"$env_prct\" STYLE=\"text-align: right;\"
                    onchange=\"two_onclick('id_trading_block_$id_suffix','$currency','$curr_reference','$ohlc_mode','$ohlc_tf',id_count_prds_$id_suffix.value,id_offset_prds_$id_suffix.value,id_env_prct_$id_suffix.value,'$ema_mode','$ema_tf','$macd_mode',id_macd_time_frame_$id_suffix.value,'$macd_mult','$rsi_mode',id_rsi_time_frame_$id_suffix.value,'$vlt_mode',id_vlt_time_frame_$id_suffix.value,'$vol_mode',id_ohlc_time_frame_$id_suffix.value,'$block_size','$nvgt_mode','$src_prds',id_start_tsp_$id_suffix.value,id_stop_tsp_$id_suffix.value)\"></INPUT>
             </SPAN></TD>" ;

# - блок ссылок
# ##########################################################################################################################################################################
    print "<TD CLASS=\"complex_navigation\">" ;
    if ( $block_size ne "half" ) {
       print "\n&nbsp;&nbsp;<A CLASS=\"complex_navigation\" TITLE=\"Портрет монеты\" HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_common_info.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=1D&count_prds=$count_prds&macd_mult=$pv{macd_mult}&env_prct=$half_min_week_volatility&output_type=graph&brush_size=4&x_size=2440&y_size=1240\">COIN</A>" ;
       }
    print "&nbsp;<A CLASS=\"complex_navigation\" TITLE=\"SWING недельный цикл\" HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_trading.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=SWING_WEEK\">W</A>
           &nbsp;<A CLASS=\"complex_navigation\" TITLE=\"INTRADAY дневной цикл\" HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_trading.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=SWING_DAY\">D</A>" ;
    if ( $block_size ne "half" ) {
       print "&nbsp;<A CLASS=\"complex_navigation\" TITLE=\"Сравнение таймфрэймов для монеты\" HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_one_coin_TF_compare.cgi?currency=$currency&curr_reference=$curr_reference\">CMP</A><BR>
              &nbsp;<A CLASS=\"complex_navigation\" TARGET=\"_blank\" TITLE=\"ByBit USDT (нужно войти)\" HREF=\"https://www.bybit.com/trade/usdt/$currency$curr_reference\">ByB</A>
              &nbsp;<A CLASS=\"complex_navigation\" TARGET=\"_blank\" TITLE=\"Coin Glass (нужно войти)\" HREF=\"https://www.coinglass.com/tv/Bybit_$currency$curr_reference\">CGls</A>
              &nbsp;<A CLASS=\"complex_navigation\" TARGET=\"_blank\" TITLE=\"Coin Trader (может не совпасть название монет, тогда руками)\" HREF=\"https://charts.cointrader.pro/charts.html?coin=$currency%3A$curr_reference\">CTrd</A>" ;
       }
    print "</TD></TR></TABLE></DIV>" ;

# - выводим графики
# ##########################################################################################################################################################################
    if ( $vol_mode > 0 ) {
    print "\n<A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_VOLUME.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$vol_tf&count_prds=$vol_count_prds&offset_prds=$offset_prds&output_type=graph&brush_size=4&x_size=1440&y_size=640\" TARGET=\"_blank\">
                <IMG CLASS=\"macd_graph_$id_suffix\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_VOLUME.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$vol_tf&count_prds=$vol_count_prds&offset_prds=$offset_prds&output_type=graph&brush_size=4&x_size=1602&y_size=240\"></A>" ;
          }

    if ($ohlc_mode > 0) {
       if ($ohlc_mode == 1 || $ohlc_mode == 3) {
          print "\n<A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_OHLCV_EMA_ENV_BL.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$ohlc_tf&count_prds=$count_prds&offset_prds=$offset_prds&env_prct=$env_prct&output_type=graph&brush_size=4&x_size=2440&y_size=1240&is_ema_periods=default&is_ema05=shadow\" TARGET=\"_blank\">
                      <IMG CLASS=\"ohlc_ema_graph_$id_suffix\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_OHLCV_EMA_ENV_BL.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$ohlc_tf&count_prds=$count_prds&offset_prds=$offset_prds&env_prct=$env_prct&output_type=graph&brush_size=4&x_size=1440&y_size=720&is_ema_periods=default&is_ema05=shadow\"></A>" ; 
          }
#       if ($ema_mode == 2 || $param_is_show_candle_too eq "yes") {
       if ($ohlc_mode == 2 || $ohlc_mode == 3) {
          my $size_x = $count_prds * 10 ; if ( $count_prds < 30 ) { $size_x = $count_prds * 40 ; } my $size_x_block = $size_x / 2 ; my $size_y = $size_x / 2 ; my $size_y_block = $size_y / 2 ;
          my $offset_ohlc_gd = "0pt" ; if ( $block_size eq "full" ) { $offset_ohlc_gd = "25pt" ; } if ( $block_size eq "half" ) { $offset_ohlc_gd = "14pt" ; } if ( $block_size eq "middle" ) { $offset_ohlc_gd = "33pt" ; }
          print "\n<A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_OHLCV_EMA_ENV_BL_gd.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$ohlc_tf&count_prds=$count_prds&env_prct=$env_prct&output_type=graph&brush_size=4&x_size=$size_x&y_size=1240&is_ema_periods=default&is_ema05=shadow\" TARGET=\"_blank\">
                      <IMG CLASS=\"ohlc_ema_graph_gd_$id_suffix\" STYLE=\"padding: 0pt $offset_ohlc_gd;\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_OHLCV_EMA_ENV_BL_gd.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$ohlc_tf&count_prds=$count_prds&env_prct=$env_prct&output_type=graph&brush_size=4&x_size=$size_x_block&y_size=$size_y_block&is_ema_periods=default&is_ema05=shadow\"></A>" ;
          }
       else { print "&nbsp;" ; }
       }

    if ($macd_mode > 0) { $macd_offset_prds = recode_tf_periods($ohlc_tf, $macd_tf, $offset_prds) ;
#-debug-print "\n<BR>=== debug EMA / MACD / MACD2 === TF $ohlc_tf / $macd_tf / $macd_2_tf === PRDS $count_prds / $macd_count_prds / $macd_2_prds ===<BR>" ;
       print "\n<BR>
              <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_MACD_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$macd_tf&count_prds=$macd_count_prds&offset_prds=$macd_offset_prds&output_type=graph&brush_size=4&x_size=1440&y_size=640\" TARGET=\"_blank\">
                 <IMG CLASS=\"macd_graph_$id_suffix\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_MACD_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$macd_tf&count_prds=$macd_count_prds&offset_prds=$macd_offset_prds&output_type=graph&brush_size=4&x_size=1440&y_size=240\"></A>" ;
       if ($macd_mode == 2 or $macd_mode == 3) {
          if ( $macd_mult eq "x1" ) {
             print "\n<BR>
                    <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_MACD_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$ohlc_tf&count_prds=$count_prds&offset_prds=$offset_prds&output_type=graph&brush_size=4&x_size=1440&y_size=640\" TARGET=\"_blank\">
                       <IMG CLASS=\"macd_graph_$id_suffix\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_MACD_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$ohlc_tf&count_prds=$count_prds&offset_prds=$offset_prds&output_type=graph&brush_size=4&x_size=1440&y_size=240\"></A>" ;
             }
          else { $macd_2_offset_prds = recode_tf_periods($ohlc_tf, $macd_2_tf, $offset_prds) ;
               print "\n<BR>
                     <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_MACD_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$macd_2_tf&count_prds=$macd_2_prds&offset_prds=$macd_2_offset_prds&output_type=graph&brush_size=4&x_size=1440&y_size=640\" TARGET=\"_blank\">
                       <IMG CLASS=\"macd_graph_$id_suffix\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_MACD_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$macd_2_tf&count_prds=$macd_2_prds&offset_prds=$macd_2_offset_prds&output_type=graph&brush_size=4&x_size=1440&y_size=240\"></A>" ;
               }
          }
       }
    else { print "&nbsp;" ; }

    if ($rsi_mode > 0) { $rsi_offset_prds = recode_tf_periods($ohlc_tf, $rsi_tf, $offset_prds) ; ;
#print "\n<BR>=== debug EMA / RSI === TF $ohlc_tf / $rsi_tf === PRDS $count_prds / $rsi_count_prds ===<BR>" ;
       print "\n<BR>
              <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_RSI_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$rsi_tf&count_prds=$rsi_count_prds&offset_prds=$rsi_offset_prds&output_type=graph&brush_size=4&x_size=1440&y_size=640\" TARGET=\"_blank\">
                 <IMG CLASS=\"rsi_graph_$id_suffix\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_RSI_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$rsi_tf&count_prds=$rsi_count_prds&offset_prds=$rsi_offset_prds&output_type=graph&brush_size=4&x_size=1440&y_size=240\"></A>" ;
       if ($rsi_mode == 2) { $rsi_offset_prds = 0 ;
          print "\n<BR>
                 <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_RSI_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$ohlc_tf&count_prds=$count_prds&offset_prds=$offset_prds&output_type=graph&brush_size=4&x_size=1440&y_size=640\" TARGET=\"_blank\">
                    <IMG CLASS=\"rsi_graph_$id_suffix\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_RSI_TV.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$ohlc_tf&count_prds=$count_prds&offset_prds=$offset_prds&output_type=graph&brush_size=4&x_size=1440&y_size=240\"></A>" ;
          }
       }
    else { print "&nbsp;" ; }

    if ($vlt_mode > 0) {
#print "\n<BR>=== debug EMA / VLT === TF $ohlc_tf / $vlt_tf === PRDS $count_prds / $vlt_count_prds ===<BR>" ;
       print "\n<BR>
              <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_VLT_WNDW.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$vlt_tf&count_prds=$vlt_count_prds&output_type=graph&brush_size=4&x_size=1400&y_size=640\" TARGET=\"_blank\">
                 <IMG CLASS=\"vlt_graph_$id_suffix\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_VLT_WNDW.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$vlt_tf&count_prds=$vlt_count_prds&output_type=graph&brush_size=4&x_size=1440&y_size=240\"></A>" ;
       if ($vlt_mode == 2) {
          print "\n<BR>
                 <A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_VLT_WNDW.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$ohlc_tf&count_prds=$count_prds&output_type=graph&brush_size=4&x_size=1400&y_size=640\" TARGET=\"_blank\">
                    <IMG CLASS=\"vlt_graph_$id_suffix\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_VLT_WNDW.cgi?currency=$currency&curr_reference=$curr_reference&time_frame=$ohlc_tf&count_prds=$count_prds&output_type=graph&brush_size=4&x_size=1440&y_size=240\"></A>" ;
          }
       }
    else { print "&nbsp;" ; }

    }
# конец - функция отрисовки основного трэйдингового блока монеты, опосредованно вызывается из функций Java Script, которые вызывают отдельный cgi модуль _ajax_for_trading.cgi с этой функцией

sub print_tools_trading_navigation($) { $active_tab{1} = "" ; $active_tab{2} = "" ; $active_tab{3} = "" ; $active_tab{4} = "" ; $active_tab{5} = "" ; ;
    $num_active_tab = $_[0] ; $active_tab{$num_active_tab} = " solid none solid" ;
    if ($pv{time_frame_ext} eq "") { $pv{time_frame_ext} = "10Mh" ; }
    print "<TABLE CELLSPACING=\"0\" CELLPADDING=\"0\" STYLE=\"border: 0pt none; width: 100%;\">
           <TR><TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{2}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_trading.cgi?currency=BTC&curr_reference=$pv{curr_reference}&time_frame=SWING_DAY&window_days=7&period_days=120&sort_column=AVG_VOL&sort_type=DESC&time_frame_ext=$pv{time_frame_ext}\">Лента:&nbsp;Трэйдинговые&nbsp;пары</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{1}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_trading.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}&time_frame=SWING_DAY&window_days=7&period_days=120&sort_column=AVG_VOL&sort_type=DESC&time_frame_ext=$pv{time_frame_ext}\">Карточка:&nbsp;Трэйдинговая&nbsp;пара</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{3}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_trading_multicycles.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}&time_frame=SWING_DAY&window_days=7&period_days=120&sort_column=AVG_VOL&sort_type=DESC&time_frame_ext=$pv{time_frame_ext}\">Мультицикловая&nbsp;аналитика:&nbsp;трэйдинговая&nbsp;пара</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           </TR></TABLE>" ;
    }

# document.getElementById('id_ema_time_frame').value
sub print_js_block_trading() {
    print "<SCRIPT LANGUAGE=\"JavaScript\">
async function two_onclick(id_elem, v_coin, v_curr_ref_coin, v_ohlc_mode, v_ohlc_tf, v_count_prds, v_offset_prds, v_env_prct, v_ema_mode, v_ema_tf, v_macd_mode, v_macd_tf, v_macd_mult, v_rsi_mode, v_rsi_tf , v_vlt_mode, v_vlt_tf, v_vol_mode, v_vol_tf, v_block_size, v_nvgt_mode, v_src_prds, v_start_tsp, v_stop_tsp) {
      //alert(\"debug in JS function id_elem=\" + id_elem + \"currency=\" + v_coin + \"&curr_reference=\" + v_curr_ref_coin + \"&time_frame=\" + v_time_frame + \"&count_prds=\" + v_count_prds + \"&env_prct=\" +  v_env_prct + \"&macd_mult=\" + v_macd_mult + \"&isvw_big_price_EMA=yes&isvw_MACD=yes&isvw_RSI=yes\") ;
      var url=\"https://zrt.ourorbits.ru/cgi/_ajax_for_trading.cgi?id_element=\" + id_elem + \"&currency=\" + v_coin + \"&curr_reference=\" + v_curr_ref_coin + \"&ohlc_mode=\" + v_ohlc_mode + \"&ohlc_tf=\" + v_ohlc_tf + \"&count_prds=\" + v_count_prds + \"&offset_prds=\" + v_offset_prds + \"&env_prct=\" + v_env_prct + \"&ema_mode=\" + v_ema_mode + \"&ema_tf=\" + v_ema_tf + \"&macd_mode=\" + v_macd_mode + \"&macd_tf=\" + v_macd_tf + \"&macd_mult=\" + v_macd_mult + \"&rsi_mode=\" + v_rsi_mode + \"&rsi_tf=\" + v_rsi_tf + \"&vlt_mode=\" + v_vlt_mode + \"&vlt_tf=\" + v_vlt_tf + \"&vol_mode=\" + v_vol_mode + \"&vol_tf=\" + v_vol_tf + \"&block_size=\" + v_block_size + \"&nvgt_mode=\" + v_nvgt_mode + \"&src_prds=\" + v_src_prds + \"&start_tsp=\" + v_start_tsp + \"&stop_tsp=\" + v_stop_tsp ;
      //alert(url) ;
      document.all(id_elem).innerHTML=\"Loading...\"
      document.all(id_elem).innerHTML=await(await fetch(url)).text();
      }

// функция изменения отображаемого периода прокруткой колеса
async function two_onwheel(v_event, id_elem, v_coin, v_curr_ref_coin, v_ohlc_mode, v_ohlc_tf, v_count_prds, v_offset_prds, v_env_prct, v_ema_mode, v_ema_tf, v_macd_mode, v_macd_tf, v_macd_mult, v_rsi_mode, v_rsi_tf, v_vlt_mode, v_vlt_tf, v_vol_mode, v_vol_tf, v_block_size, v_nvgt_mode, v_src_prds, v_start_tsp, v_stop_tsp) {
      v_event.preventDefault() ;
      v_event = v_event || window.event;
      // wheelDelta не дает возможность узнать количество пикселей
      var v_delta = v_event.deltaY || v_event.detail || v_event.wheelDelta;
      var v_new_count_prds ;
      if ( v_delta > 0 ) { v_new_count_prds = Math.floor(v_count_prds / 1.5) ; }
      if ( v_delta < 0 ) { v_new_count_prds = Math.floor(v_count_prds * 1.5) ; }

      //alert(\"debug in JS function id_elem=\" + id_elem + \"currency=\" + v_coin + \"&curr_reference=\" + v_curr_ref_coin + \"&time_frame=\" + v_time_frame + \"&count_prds=\" + v_count_prds + \"&env_prct=\" +  v_env_prct + \"&macd_mult=\" + v_macd_mult + \"&isvw_big_price_EMA=yes&isvw_MACD=yes&isvw_RSI=yes\") ;
      var url=\"https://zrt.ourorbits.ru/cgi/_ajax_for_trading.cgi?id_element=\" + id_elem + \"&currency=\" + v_coin + \"&curr_reference=\" + v_curr_ref_coin + \"&ohlc_mode=\" + v_ohlc_mode + \"&ohlc_tf=\" + v_ohlc_tf + \"&count_prds=\" + v_new_count_prds + \"&offset_prds=\" + v_offset_prds + \"&env_prct=\" + v_env_prct + \"&ema_mode=\" + v_ema_mode + \"&ema_tf=\" + v_ema_tf + \"&macd_mode=\" + v_macd_mode + \"&macd_tf=\" + v_macd_tf + \"&macd_mult=\" + v_macd_mult + \"&rsi_mode=\" + v_rsi_mode + \"&rsi_tf=\" + v_rsi_tf + \"&vlt_mode=\" + v_vlt_mode + \"&vlt_tf=\" + v_vlt_tf + \"&vol_mode=\" + v_vol_mode + \"&vol_tf=\" + v_vol_tf + \"&block_size=\" + v_block_size + \"&nvgt_mode=\" + v_nvgt_mode + \"&src_prds=\" + v_src_prds + \"&start_tsp=\" + v_start_tsp + \"&stop_tsp=\" + v_stop_tsp ;
      //alert(url) ;
      document.all(id_elem).innerHTML=\"Loading...\"
      document.all(id_elem).innerHTML=await(await fetch(url)).text();
      }

// функция изменения смещения отображаемого периода прокруткой колеса
async function two_onwheel_offset(v_event, id_elem, v_coin, v_curr_ref_coin, v_ohlc_mode, v_ohlc_tf, v_count_prds, v_offset_prds, v_env_prct, v_ema_mode, v_ema_tf, v_macd_mode, v_macd_tf, v_macd_mult, v_rsi_mode, v_rsi_tf, v_vlt_mode, v_vlt_tf, v_vol_mode, v_vol_tf, v_block_size, v_nvgt_mode, v_src_prds, v_start_tsp, v_stop_tsp) {
      v_event.preventDefault() ;
      v_event = v_event || window.event;
      // wheelDelta не дает возможность узнать количество пикселей
      var v_delta = v_event.deltaY || v_event.detail || v_event.wheelDelta;
      var v_new_offset_prds ;
      if ( v_delta > 0 ) { v_new_offset_prds = Math.floor(v_offset_prds / 1.25) ; }
      if ( v_delta < 0 ) { v_new_offset_prds = Math.floor(v_offset_prds * 1.25) ; }

      //alert(\"debug in JS function id_elem=\" + id_elem + \"currency=\" + v_coin + \"&curr_reference=\" + v_curr_ref_coin + \"&time_frame=\" + v_time_frame + \"&count_prds=\" + v_count_prds + \"&env_prct=\" +  v_env_prct + \"&macd_mult=\" + v_macd_mult + \"&isvw_big_price_EMA=yes&isvw_MACD=yes&isvw_RSI=yes\") ;
      var url=\"https://zrt.ourorbits.ru/cgi/_ajax_for_trading.cgi?id_element=\" + id_elem + \"&currency=\" + v_coin + \"&curr_reference=\" + v_curr_ref_coin + \"&ohlc_mode=\" + v_ohlc_mode + \"&ohlc_tf=\" + v_ohlc_tf + \"&count_prds=\" + v_count_prds + \"&offset_prds=\" + v_new_offset_prds + \"&env_prct=\" + v_env_prct + \"&ema_mode=\" + v_ema_mode + \"&ema_tf=\" + v_ema_tf + \"&macd_mode=\" + v_macd_mode + \"&macd_tf=\" + v_macd_tf + \"&macd_mult=\" + v_macd_mult + \"&rsi_mode=\" + v_rsi_mode + \"&rsi_tf=\" + v_rsi_tf + \"&vlt_mode=\" + v_vlt_mode + \"&vlt_tf=\" + v_vlt_tf + \"&vol_mode=\" + v_vol_mode + \"&vol_tf=\" + v_vol_tf + \"&block_size=\" + v_block_size + \"&nvgt_mode=\" + v_nvgt_mode + \"&src_prds=\" + v_src_prds + \"&start_tsp=\" + v_start_tsp + \"&stop_tsp=\" + v_stop_tsp ;
      //alert(url) ;
      document.all(id_elem).innerHTML=\"Loading...\"
      document.all(id_elem).innerHTML=await(await fetch(url)).text();
      }

</SCRIPT>\n" ;
   }

1
