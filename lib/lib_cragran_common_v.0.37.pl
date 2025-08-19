
# open source soft - (C) 2023 CrAgrAn BESST (Crypto Argegator Analyzer from Belonin Sergey Stanislav)
# author Belonin Sergey Stanislav
# license of product - public license GPL v.3
# do not use if not agree license agreement

sub print_select_tf_options($) {
    my $selected_option = $_[0] ;
    my @tf_options = ("4W","1W","4D", "2D","1D","12H","8H","4H","3H","2H","1H","30M","15M","10M","5M","3M","1M") ;
    for($i=0;$i<=$#tf_options;$i++) { if ( $tf_options[$i] eq $selected_option ) { $is_selected = "SELECTED" ; } else { $is_selected = "" ; } print "<OPTION VALUE=\"$tf_options[$i]\" $is_selected>$tf_options[$i]</OPTION>\n" ; }
    }

sub print_foother1() {
    print "<BR><HR><P STYLE=\"text-align: center;\">CrAgrAn BeSSt v.1.3, (C) Belonin S.S., 2024</P>
           </BODY>
           </HTML>" ;
    }

# фуникция возвращает адекватное входящему количество периодов, сравнивая начальный и конечный таймфрэймы
sub recode_tf_periods($$$) {
    my $start_TF = $_[0] ;
    my $enf_TF   = $_[1] ;
    my $bgn_prd  = $_[2] ;
    my $end_prd  = $bgn_prd ;
    my $lcl_mult = 1 ;

    if ( $start_TF eq "1M" ) { $lcl_mult = 1 ; }
    if ( $start_TF eq "3M" ) { $lcl_mult = 3 ; }
    if ( $start_TF eq "5M" ) { $lcl_mult = 5 ; }
    if ( $start_TF eq "10M" ) { $lcl_mult = 10 ; }
    if ( $start_TF eq "15M" ) { $lcl_mult = 15 ; }
    if ( $start_TF eq "30M" ) { $lcl_mult = 30 ; }
    if ( $start_TF eq "1H" ) { $lcl_mult = 60 ; }
    if ( $start_TF eq "2H" ) { $lcl_mult = 120 ; }
    if ( $start_TF eq "3H" ) { $lcl_mult = 180 ; }
    if ( $start_TF eq "4H" ) { $lcl_mult = 240 ; }
    if ( $start_TF eq "8H" ) { $lcl_mult = 480 ; }
    if ( $start_TF eq "12H" ) { $lcl_mult = 720 ; }
    if ( $start_TF eq "1D" ) { $lcl_mult = 1440 ; }
    if ( $start_TF eq "2D" ) { $lcl_mult = 2880 ; }
    if ( $start_TF eq "4D" ) { $lcl_mult = 1440 * 4 ; }
    if ( $start_TF eq "1W" ) { $lcl_mult = 1440 * 7 ; }
    if ( $start_TF eq "4W" ) { $lcl_mult = 1440 * 30 ; }

    if ( $enf_TF eq "1M" ) { $end_prd = $bgn_prd * $lcl_mult ; }
    if ( $enf_TF eq "3M" ) { $end_prd = $bgn_prd / 3 * $lcl_mult ; }
    if ( $enf_TF eq "5M" ) { $end_prd = $bgn_prd / 5 * $lcl_mult ; }
    if ( $enf_TF eq "10M" ) { $end_prd = $bgn_prd / 10 * $lcl_mult ; }
    if ( $enf_TF eq "15M" ) { $end_prd = $bgn_prd / 15 * $lcl_mult ; }
    if ( $enf_TF eq "30M" ) { $end_prd = $bgn_prd / 30 * $lcl_mult ; }
    if ( $enf_TF eq "1H" ) { $end_prd = $bgn_prd / 60 * $lcl_mult ; }
    if ( $enf_TF eq "2H" ) { $end_prd = $bgn_prd / 120 * $lcl_mult ; }
    if ( $enf_TF eq "3H" ) { $end_prd = $bgn_prd / 180 * $lcl_mult ; }
    if ( $enf_TF eq "4H" ) { $end_prd = $bgn_prd / 240 * $lcl_mult ; }
    if ( $enf_TF eq "8H" ) { $end_prd = $bgn_prd / 480 * $lcl_mult ; }
    if ( $enf_TF eq "12H" ) { $end_prd = $bgn_prd / 720 * $lcl_mult ; }
    if ( $enf_TF eq "1D" ) { $end_prd = $bgn_prd / 1440 * $lcl_mult ; }
    if ( $enf_TF eq "2D" ) { $end_prd = $bgn_prd / 2880 * $lcl_mult ; }
    if ( $enf_TF eq "4D" ) { $end_prd = $bgn_prd / (1440 * 4) * $lcl_mult ; }
    if ( $enf_TF eq "1W" ) { $end_prd = $bgn_prd / (1440 * 7) * $lcl_mult ; }
    if ( $enf_TF eq "4W" ) { $end_prd = $bgn_prd / (1440 * 30) * $lcl_mult ; }

    return $end_prd ;
    }

sub get_ohlcv_from_crcomp_table($$$$$$$$$$$$$) {
# здесь присваиваем переменным скалярам ссылки на массивы
    my $l_count_prds = $_[0] ;
    my $l_max_extension_periods = $_[1] ;
    my $l_date_size = $_[2] ;
    $arr_ref_datetime_list = $_[3] ;
    $arr_ref_days_list = $_[4] ;
    $arr_ref_hours_list = $_[5] ;
    $arr_ref_minutes_list = $_[6] ;
    $arr_ref_price_open = $_[7] ;
    $arr_ref_price_min = $_[8] ;
    $arr_ref_price_max = $_[9] ;
    $arr_ref_price_close = $_[10] ;
    $arr_ref_volume_from = $_[11] ;
    $arr_ref_volume_to = $_[12] ;

    my $count_rows = 0 ;
#open(DEBG,">>/tmp/print_get_ohlcv_from_crcomp_table.out") ; print DEBG "debug -- count = $l_count_prds - max_ext = $l_max_extension_periods - offset = $l_offset_prds - date_fmt = $l_date_size -- $_[0] $_[1] $_[2] $_[3] --\n" ; close(DEBG) ;
#print "debug -- $arr_ref_datetime_list - $arr_ref_days_list - $arr_ref_hours_list - $arr_ref_minutes_list - $arr_ref_price_open - $arr_ref_price_min - $arr_ref_price_max - $arr_ref_price_close\n" ;
#print "debug -- $pv{count_prds} + $l_max_extension_periods\n" ;

    $request = " " ;
    if ( $pv{time_frame} eq "4W" ) { $ext_period_real_point = ($l_count_prds + $l_max_extension_periods + 1) * 28 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 27) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 27 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 27 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 27 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 27 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 27 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1D_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point DAYS' order by timestamp_point ASC" ;
       }

    if ( $pv{time_frame} eq "1W" ) { $ext_period_real_point = ($l_count_prds + $l_max_extension_periods + 1) * 7 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 6) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1D_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point DAYS' order by timestamp_point ASC" ;
       }

    if ( $pv{time_frame} eq "4D" ) { $ext_period_real_point = ($l_count_prds + $l_max_extension_periods + 1) * 4 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 3) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1D_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point DAYS' order by timestamp_point ASC" ;
       }

    if ( $pv{time_frame} eq "2D" ) { $ext_period_real_point = ($l_count_prds + $l_max_extension_periods + 1) * 2 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 1) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1D_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point DAYS' order by timestamp_point ASC" ;
       }

    if ( $pv{time_frame} eq "1D" ) { $ext_period_real_point = $l_count_prds + $l_max_extension_periods + 1 ;
    $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       price_open as PRICE_OPEN, price_low as PRICE_MIN, price_high as PRICE_MAX, price_close PRICE_CLOSE,
                       extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours, extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       volume_from as VOLUME_FROM, volume_to as VOLUME_TO
                       FROM crcomp_pair_OHLC_1D_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point DAYS' order by timestamp_point ASC" ;
       }

    if ( $pv{time_frame} eq "12H" ) { $ext_period_real_point = ($l_count_prds + $l_max_extension_periods + 1) * 12 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 11) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1H_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point hours' order by timestamp_point ASC" ;
       }

    if ( $pv{time_frame} eq "8H" ) { $ext_period_real_point = ($l_count_prds + $l_max_extension_periods + 1) * 8 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 7) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 7 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 7 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 7 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 7 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 7 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1H_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point hours' order by timestamp_point ASC" ;
       }

    if ( $pv{time_frame} eq "4H" ) { $ext_period_real_point = ($l_count_prds + $l_max_extension_periods + 1) * 4 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 3) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1H_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point hours' order by timestamp_point ASC" ;
       }

    if ( $pv{time_frame} eq "3H" ) { $ext_period_real_point = ($l_count_prds + $l_max_extension_periods + 1) * 3 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 2) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1H_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point hours' order by timestamp_point ASC" ;
       }

    if ( $pv{time_frame} eq "2H" ) { $ext_period_real_point = ($l_count_prds + $l_max_extension_periods + 1) * 2 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 1) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1H_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point hours' order by timestamp_point ASC" ;
       }

    if ( $pv{time_frame} eq "1H" ) { $ext_period_real_point = $l_count_prds + $l_max_extension_periods + 1 ;
    $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       price_open as PRICE_OPEN, price_low as PRICE_MIN, price_high as PRICE_MAX, price_close PRICE_CLOSE,
                       extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours, extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       volume_from as VOLUME_FROM, volume_to as VOLUME_TO
                       FROM crcomp_pair_OHLC_1H_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point hours' order by timestamp_point ASC" ;
       }

    if ( $pv{time_frame} eq "30M" ) { $ext_period_real_point = ($l_count_prds + $l_max_extension_periods + 1) * 30 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 29) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1M_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point minutes' order by timestamp_point ASC" ;
       }

    if ( $pv{time_frame} eq "15M" ) { $ext_period_real_point = ($l_count_prds + $l_max_extension_periods + 1) * 15 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 14) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 14 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 14 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 14 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 14 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 14 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1M_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point minutes' order by timestamp_point ASC" ;
       }

    if ( $pv{time_frame} eq "10M" ) { $ext_period_real_point = ($l_count_prds + $l_max_extension_periods + 1) * 10 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 9) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1M_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point minutes' order by timestamp_point ASC" ;
       }

    if ( $pv{time_frame} eq "5M" ) { $ext_period_real_point = ($l_count_prds + $l_max_extension_periods + 1) * 5 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 4) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days,
                       extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours, extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1M_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point minutes' order by timestamp_point ASC" ;
       }

    if ( $pv{time_frame} eq "3M" ) { $ext_period_real_point = ($l_count_prds + $l_max_extension_periods + 1) * 3 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 2) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1M_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point minutes' order by timestamp_point ASC" ;
       }

    if ( $pv{time_frame} eq "1M" ) { $ext_period_real_point = $l_count_prds + $l_max_extension_periods + 1 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       price_open as PRICE_OPEN, price_low as PRICE_MIN, price_high PRICE_MAX, price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days,
                       extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours, extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       volume_from as VOLUME_FROM, volume_to as VOLUME_TO
                       FROM crcomp_pair_OHLC_1M_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '$ext_period_real_point minutes' order by timestamp_point ASC" ;
       }

#print "- debug - \$ext_period_real_point \$l_count_prds \$l_max_extension_periods + 1 = $ext_period_real_point $l_count_prds $l_max_extension_periods + 1 \n" ;
       my $dbh_h = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'cryptapwd') ;
       my $sth_h = $dbh_h->prepare($request) ; $sth_h->execute(); $count_rows = 0 ;
# заполнить промежуточный массив с префиксным расширением периодов - только для граничных записей периода
# и рассчитать ЕМА
       my $currency = "" ; my $reference_currency ="" ; my $datetime_point = "" ; my $price_open = 0 ; my $price_min = 0 ; my $price_max = 0 ; my $price_close = 0 ; my $days = 0 ; my $hours = 0 ; my $minutes = 0 ; my $volume_from = 0 ; my $volume_to = 0 ;
       my @data_cartrige = () ;
       while ( @data_cartrige = $sth_h->fetchrow_array() ) {
             $currency = $data_cartrige[0] ; $reference_currency = $data_cartrige[1] ; $datetime_point = $data_cartrige[2] ; $price_open = $data_cartrige[3]; $price_min = $data_cartrige[4] ; $price_max = $data_cartrige[5] ;
             $price_close = $data_cartrige[6] ; $days = $data_cartrige[7] ; $hours = $data_cartrige[8] ; $minutes = $data_cartrige[9] ; $volume_from = $data_cartrige[10] ; $volume_to = $data_cartrige[11] ;
# здесь выбираем только подходящие под NA данные без хвостов
             if ( ( $pv{time_frame} eq "4W" && $days == 1 ) ||
                  ( $pv{time_frame} eq "1W" && ( $days == 1 || $days == 8 || $days == 15 || $days == 22 || $days == 29 ) ) ||
                  ( $pv{time_frame} eq "4D" && ( $days == 1 || $days == 5 || $days == 9 || $days == 13 || $days == 17 || $days == 21 || $days == 25 || $days == 29 ) ) ||
                  ( $pv{time_frame} eq "2D" && (int($days / 2) - ($days / 2)) != 0 ) ||
                  ( $pv{time_frame} eq "12H" && ( $hours == 1 || $hours == 13 ) && $minutes == 0 ) ||
                  ( $pv{time_frame} eq "8H" && ( $hours == 1 || $hours == 9 || $hours == 17 ) && $minutes == 0 ) ||
                  ( $pv{time_frame} eq "4H" && ( $hours == 1 || $hours == 5 || $hours == 9 || $hours == 13 || $hours == 17 || $hours == 21 ) && $minutes == 0 ) ||
                  ( $pv{time_frame} eq "3H" && ( $hours == 1 || $hours == 4 || $hours == 7 || $hours == 10 || $hours == 13 || $hours == 16 || $hours == 19 || $hours == 22 ) && $minutes == 0 ) ||
                  ( $pv{time_frame} eq "2H" && ( (int($hours / 2) - ($hours / 2)) != 0 && $minutes == 0 )) ||
                  ( $pv{time_frame} eq "1H" && ( $minutes == 0 )) ||
                  ( $pv{time_frame} eq "30M" && ( $minutes == 0 || $minutes == 30 )) ||
                  ( $pv{time_frame} eq "15M" && ( $minutes == 0 || $minutes == 15 || $minutes == 30 || $minutes == 45 )) ||
                  ( $pv{time_frame} eq "10M" && ( $minutes == 0 || $minutes == 10 || $minutes == 20 || $minutes == 30 || $minutes == 40 || $minutes == 50 )) ||
                  ( $pv{time_frame} eq "5M" && ( $minutes == 0 || $minutes == 5 || $minutes == 10 || $minutes == 15 || $minutes == 20 || $minutes == 25 ||
                                                 $minutes == 30 || $minutes == 35 || $minutes == 40 || $minutes == 45 || $minutes == 50 || $minutes == 55)) ||
                  ( $pv{time_frame} eq "3M" && ( $minutes == 0 || $minutes == 3 || $minutes == 6 || $minutes == 9 || $minutes == 12 || $minutes == 15 || $minutes == 18 || $minutes == 21 ||
                                                 $minutes == 24 || $minutes == 27 || $minutes == 30 || $minutes == 33 || $minutes == 36 || $minutes == 39 || $minutes == 42 || $minutes == 45 ||
                                                 $minutes == 48 || $minutes == 51 || $minutes == 54 || $minutes == 57)) ||
                  ( $pv{time_frame} eq "1M" ) || ( $pv{time_frame} eq "1D" ) ) {
                if ($l_date_size eq "middle") { $datetime_point =~ s/(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)/$3 $4:$5/g ; }
                $arr_ref_datetime_list->[$count_rows] = $datetime_point ;
                $arr_ref_days_list->[$count_rows] = $days ;
                $arr_ref_hours_list->[$count_rows] = $hours ;
                $arr_ref_minutes_list->[$count_rows] = $minutes ;
# для начальных записей при использовании оконных функций значения могут быть пустые, а т.к. набор данных может не иметь расширенного диапазона дней, он войдут в конечный массив
# нужно подать правильные значения - пустые графической библиотекой не допускаются
                if ( $price_open eq "" ) { $price_open = $price_close ; }
                $arr_ref_price_open->[$count_rows] = $price_open ;
                $arr_ref_price_min->[$count_rows] = $price_min ;
                $arr_ref_price_max->[$count_rows] = $price_max ;
                $arr_ref_price_close->[$count_rows] = $price_close ;
                $arr_ref_volume_from->[$count_rows] = $volume_from ;
                $arr_ref_volume_to->[$count_rows] = $volume_to ;
#      $datetime_point =~ s/\d\d\d\d-(\d\d)-(\d\d)/$1$2/g ;
#-debug-print("\n--- debug --- $pv{time_frame} - count_rows $count_rows - price_close $price_close -  \$arr_ref_price_close[$count_rows] $arr_ref_price_close->[$count_rows]\n") ;
                $count_rows += 1 ;
#-debug-system("echo \"faza1 $datetime_point - $hours - $minutes\" >> /tmp/test_xxx.$pv{currency}") ;

                }
             }
       $sth_h->finish() ;
       $dbh_h->disconnect() ;

# заполнить хвост - последнее значение, не дожидаясь закрытия периода
#-debug-open(DEB_FILE,">>/tmp/test_xxx.$pv{currency}") ;
#-debug-printf DEB_FILE "faza2 - $datetime_point - $hours - $minutes \n" ;
#-debug-close(DEB_FILE) ;
#-debug-#system("echo \"- $hours - $minutes\" > /tmp/test_xxx.$pv{currency}") ;
#-debug-#print("\n--- debug --- хвост - \n") ;
#       $is_fill_tail = "no_fill" ;
       if ( $is_fill_tail eq "fill" ) {
          if ( ( $pv{time_frame} eq "4W" && $days != 1 ) ||
               ( $pv{time_frame} eq "1W" && ( $days != 1 && $days != 8 && $days != 15 && $days != 22 && $days != 29 )) ||
               ( $pv{time_frame} eq "4D" && ( $days != 1 && $days != 5 && $days != 9 && $days != 13 && $days != 17 && $days != 21 && $days != 25 && $days != 29 )) ||
               ( $pv{time_frame} eq "2D" && ( int($days / 2) - ($days / 2)) == 0 ) ||
               ( $pv{time_frame} eq "12H" && (( $hours != 1 && $hours != 13 ) || $minutes != 0 )) ||
               ( $pv{time_frame} eq "8H" && (( $hours != 1 && $hours != 9 && $hours != 17 ) || $minutes != 0 )) ||
               ( $pv{time_frame} eq "4H" && (( $hours != 1 && $hours != 5 && $hours != 9 && $hours != 13 && $hours != 17 && $hours != 21 ) || $minutes != 0 )) ||
               ( $pv{time_frame} eq "3H" && (( $hours != 1 && $hours != 4 && $hours != 7 && $hours != 10 && $hours != 13 && $hours != 16 && $hours != 19 && $hours != 22 ) || $minutes != 0 )) ||
               ( $pv{time_frame} eq "2H" && ( (int($hours / 2) - ($hours / 2)) == 0 || $minutes != 0 )) ||
               ( $pv{time_frame} eq "1H" && ( $minutes != 0 )) ||
               ( $pv{time_frame} eq "30M" && ( $minutes != 0 && $minutes != 30 )) ||
               ( $pv{time_frame} eq "15M" && ( $minutes != 0 && $minutes != 15 && $minutes != 30 && $minutes != 45 )) ||
               ( $pv{time_frame} eq "10M" && ( $minutes != 0 && $minutes != 10 && $minutes != 20 && $minutes != 30 && $minutes != 40 && $minutes != 50 )) ||
               ( $pv{time_frame} eq "5M" && ( $minutes != 0  && $minutes != 5  && $minutes != 10 && $minutes != 15 && $minutes != 20 && $minutes != 25 && $minutes != 30 &&$minutes != 35 &&
                                              $minutes != 40 && $minutes != 45 && $minutes != 50 && $minutes != 55)) ||
               ( $pv{time_frame} eq "3M" && ( $minutes != 0  && $minutes != 3  && $minutes != 6  && $minutes != 9  && $minutes != 12 && $minutes != 15 && $minutes != 18 && $minutes != 21 &&
                                              $minutes != 24 && $minutes != 27 && $minutes != 30 && $minutes != 33 && $minutes != 36 && $minutes != 39 && $minutes != 42 && $minutes != 45 &&
                                              $minutes != 48 && $minutes != 51 && $minutes != 54 && $minutes != 57)) ) {

#-debug-$aa = (int($hours / 2) - ($hours / 2)) ;
             if ($l_date_size eq "middle") { $datetime_point =~ s/(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)/$3 $4:$5/g ; }
             $arr_ref_datetime_list->[$count_rows] = $datetime_point ;
             $arr_ref_days_list->[$count_rows] = $days ;
             $arr_ref_hours_list->[$count_rows] = $hours ;
             $arr_ref_minutes_list->[$count_rows] = $minutes ;
# для начальных записей при использовании оконных функций значения могут быть пустые, а т.к. набор данных может не иметь расширенного диапазона дней, он войдут в конечный массив
# нужно подать правильные значения - пустые графической библиотекой не допускаются
             if ( $price_open eq "" ) { $price_open = $price_close ; }
             $arr_ref_price_open->[$count_rows] = $price_open ;
             $arr_ref_price_min->[$count_rows] = $price_min ;
             $arr_ref_price_max->[$count_rows] = $price_max ;
             $arr_ref_price_close->[$count_rows] = $price_close ;
             $arr_ref_volume_from->[$count_rows] = $volume_from ;
             $arr_ref_volume_to->[$count_rows] = $volume_to ;
#      $datetime_point =~ s/\d\d\d\d-(\d\d)-(\d\d)/$1$2/g ;
#-debug-system("echo \"faza3 include - $aa - $hours - $minutes --- $arr_ref_datetime_list[$count_rows] - $arr_ref_hours_list[$count_rows] - $arr_ref_minutes_list[$count_rows] - $arr_ref_price_open[$count_rows] - $arr_ref_price_min[$count_rows] - $arr_ref_price_max[$count_rows] - $arr_ref_price_close[$count_rows] - ema $arr_ref_ema01[$count_rows] - day $arr_ref_ema02[$count_rows] - week $arr_ref_ema03[$count_rows]\" >> /tmp/test_xxx.$pv{currency}") ;
             $count_rows += 1 ;
#-debug-print("\n--- debug --- хвост --- $pv{time_frame} - count_rows $count_rows - price_close $price_close -  \$arr_ref_price_close[$count_rows] $arr_ref_price_close->[$count_rows]\n") ;
             }
       }
    return $count_rows ;
    }



sub get_ohlcv_from_crcomp_table_offset($$$$$$$$$$$$$$) {
# здесь присваиваем переменным скалярам ссылки на массивы
    my $l_count_prds = $_[0] ;
    my $l_max_extension_periods = $_[1] ;
    my $l_offset_prds = $_[2] ;
    my $l_date_size = $_[3] ;
    $arr_ref_datetime_list = $_[4] ;
    $arr_ref_days_list = $_[5] ;
    $arr_ref_hours_list = $_[6] ;
    $arr_ref_minutes_list = $_[7] ;
    $arr_ref_price_open = $_[8] ;
    $arr_ref_price_min = $_[9] ;
    $arr_ref_price_max = $_[10] ;
    $arr_ref_price_close = $_[11] ;
    $arr_ref_volume_from = $_[12] ;
    $arr_ref_volume_to = $_[13] ;

    my $count_rows = 0 ;
#open(DEBG,">>/tmp/print_get_ohlcv_from_crcomp_table.out") ; print DEBG "debug -- count = $l_count_prds\n - max_ext = $l_max_extension_periods\n - offset = $l_offset_prds\n - date_fmt = $l_date_size\n -- $_[0] $_[1] $_[2] $_[3] --\n" ; close(DEBG) ;
#print "debug -- $arr_ref_datetime_list - $arr_ref_days_list - $arr_ref_hours_list - $arr_ref_minutes_list - $arr_ref_price_open - $arr_ref_price_min - $arr_ref_price_max - $arr_ref_price_close\n" ;
#print "debug -- $pv{count_prds} + $l_max_extension_periods\n" ;

    $request = " " ;
    if ( $pv{time_frame} eq "4W" ) { $ext_period_real_point = ($l_count_prds + $l_offset_prds + $l_max_extension_periods + 1) * 28 ; $limit_prds = ($l_count_prds + $l_max_extension_periods + 1) * 28 ; 
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 27) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 27 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 27 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 27 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 27 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 27 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1D_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CAST(date_trunc('second', current_timestamp) as timestamp without time zone) - INTERVAL '$ext_period_real_point DAYS'
                       order by timestamp_point ASC LIMIT $limit_prds" ;
       }

    if ( $pv{time_frame} eq "1W" ) { $ext_period_real_point = ($l_count_prds + $l_offset_prds + $l_max_extension_periods + 1) * 7 ; $limit_prds = ($l_count_prds + $l_max_extension_periods + 1) * 7 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 6) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1D_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CAST(date_trunc('second', current_timestamp) as timestamp without time zone) - INTERVAL '$ext_period_real_point DAYS'
                       order by timestamp_point ASC LIMIT $limit_prds" ;
       }

    if ( $pv{time_frame} eq "4D" ) { $ext_period_real_point = ($l_count_prds + $l_offset_prds + $l_max_extension_periods + 1) * 4 ; $limit_prds = ($l_count_prds + $l_max_extension_periods + 1) * 4 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 3) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1D_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CAST(date_trunc('second', current_timestamp) as timestamp without time zone) - INTERVAL '$ext_period_real_point DAYS'
                       order by timestamp_point ASC LIMIT $limit_prds" ;
       }

    if ( $pv{time_frame} eq "2D" ) { $ext_period_real_point = ($l_count_prds + $l_offset_prds + $l_max_extension_periods + 1) * 2 ; $limit_prds = ($l_count_prds + $l_max_extension_periods + 1) * 2 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 1) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1D_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CAST(date_trunc('second', current_timestamp) as timestamp without time zone) - INTERVAL '$ext_period_real_point DAYS'
                       order by timestamp_point ASC LIMIT $limit_prds" ;
       }

    if ( $pv{time_frame} eq "1D" ) { $ext_period_real_point = $l_count_prds + $l_offset_prds + $l_max_extension_periods + 1 ; $limit_prds = $l_count_prds + $l_max_extension_periods + 1 ;
    $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       price_open as PRICE_OPEN, price_low as PRICE_MIN, price_high as PRICE_MAX, price_close PRICE_CLOSE,
                       extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours, extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       volume_from as VOLUME_FROM, volume_to as VOLUME_TO
                       FROM crcomp_pair_OHLC_1D_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CAST(date_trunc('second', current_timestamp) as timestamp without time zone) - INTERVAL '$ext_period_real_point DAYS'
                       order by timestamp_point ASC LIMIT $limit_prds" ;
       }

    if ( $pv{time_frame} eq "12H" ) { $ext_period_real_point = ($l_count_prds + $l_offset_prds + $l_max_extension_periods + 1) * 12 ; $limit_prds = ($l_count_prds + $l_max_extension_periods + 1) * 12 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 11) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1H_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CAST(date_trunc('second', current_timestamp) as timestamp without time zone) - INTERVAL '$ext_period_real_point hours'
                       order by timestamp_point ASC LIMIT $limit_prds" ;
       }

    if ( $pv{time_frame} eq "8H" ) { $ext_period_real_point = ($l_count_prds + $l_offset_prds + $l_max_extension_periods + 1) * 8 ; $limit_prds = ($l_count_prds + $l_max_extension_periods + 1) * 8 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 7) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 7 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 7 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 7 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 7 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 7 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1H_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CAST(date_trunc('second', current_timestamp) as timestamp without time zone) - INTERVAL '$ext_period_real_point hours'
                       order by timestamp_point ASC LIMIT $limit_prds" ;
       }

    if ( $pv{time_frame} eq "4H" ) { $ext_period_real_point = ($l_count_prds + $l_offset_prds + $l_max_extension_periods + 1) * 4 ; $limit_prds = ($l_count_prds + $l_max_extension_periods + 1) * 4 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 3) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1H_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CAST(date_trunc('second', current_timestamp) as timestamp without time zone) - INTERVAL '$ext_period_real_point hours'
                       order by timestamp_point ASC LIMIT $limit_prds" ;
       }


    if ( $pv{time_frame} eq "3H" ) { $ext_period_real_point = ($l_count_prds + $l_offset_prds + $l_max_extension_periods + 1) * 3 ; $limit_prds = ($l_count_prds + $l_max_extension_periods + 1) * 3 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 2) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1H_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CAST(date_trunc('second', current_timestamp) as timestamp without time zone) - INTERVAL '$ext_period_real_point hours' 
                       order by timestamp_point ASC LIMIT $limit_prds" ;
       }

    if ( $pv{time_frame} eq "2H" ) { $ext_period_real_point = ($l_count_prds + $l_offset_prds + $l_max_extension_periods + 1) * 2 ; $limit_prds = ($l_count_prds + $l_max_extension_periods + 1) * 2 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 1) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1H_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CAST(date_trunc('second', current_timestamp) as timestamp without time zone) - INTERVAL '$ext_period_real_point hours'
                       order by timestamp_point ASC LIMIT $limit_prds" ;
       }

    if ( $pv{time_frame} eq "1H" ) { $ext_period_real_point = $l_count_prds + $l_offset_prds + $l_max_extension_periods + 1 ; $limit_prds = $l_count_prds + $l_max_extension_periods + 1 ;
    $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       price_open as PRICE_OPEN, price_low as PRICE_MIN, price_high as PRICE_MAX, price_close PRICE_CLOSE,
                       extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours, extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       volume_from as VOLUME_FROM, volume_to as VOLUME_TO
                       FROM crcomp_pair_OHLC_1H_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CAST(date_trunc('second', current_timestamp) as timestamp without time zone) - INTERVAL '$ext_period_real_point hours'
                       order by timestamp_point ASC LIMIT $limit_prds" ;
       }

    if ( $pv{time_frame} eq "30M" ) { $ext_period_real_point = ($l_count_prds + $l_offset_prds + $l_max_extension_periods + 1) * 30 ; $limit_prds = ($l_count_prds + $l_max_extension_periods + 1) * 30 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 29) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1M_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CAST(date_trunc('second', current_timestamp) as timestamp without time zone) - INTERVAL '$ext_period_real_point minutes'
                       order by timestamp_point ASC LIMIT $limit_prds" ;
       }

    if ( $pv{time_frame} eq "15M" ) { $ext_period_real_point = ($l_count_prds + $l_offset_prds + $l_max_extension_periods + 1) * 15 ; $limit_prds = ($l_count_prds + $l_max_extension_periods + 1) * 15 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 14) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 14 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 14 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 14 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 14 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 14 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1M_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CAST(date_trunc('second', current_timestamp) as timestamp without time zone) - INTERVAL '$ext_period_real_point minutes'
                       order by timestamp_point ASC LIMIT $limit_prds" ;
       }

    if ( $pv{time_frame} eq "10M" ) { $ext_period_real_point = ($l_count_prds + $l_offset_prds + $l_max_extension_periods + 1) * 10 ; $limit_prds = ($l_count_prds + $l_max_extension_periods + 1) * 10 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 9) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1M_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CAST(date_trunc('second', current_timestamp) as timestamp without time zone) - INTERVAL '$ext_period_real_point minutes'
                       order by timestamp_point ASC LIMIT $limit_prds" ;
       }

    if ( $pv{time_frame} eq "5M" ) { $ext_period_real_point = ($l_count_prds + $l_offset_prds + $l_max_extension_periods + 1) * 5 ; $limit_prds = ($l_count_prds + $l_max_extension_periods + 1) * 5 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 4) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days,
                       extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours, extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1M_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CAST(date_trunc('second', current_timestamp) as timestamp without time zone) - INTERVAL '$ext_period_real_point minutes'
                       order by timestamp_point ASC LIMIT $limit_prds" ;
       }

    if ( $pv{time_frame} eq "3M" ) { $ext_period_real_point = ($l_count_prds + $l_offset_prds + $l_max_extension_periods + 1) * 3 ; $limit_prds = ($l_count_prds + $l_max_extension_periods + 1) * 3 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       LAG(price_open, 2) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                       min(price_low) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as PRICE_MIN,
                       max(price_high) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as PRICE_MAX,
                       price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours,
                       extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                       SUM(volume_to) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL '3 HOURS') ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as VOLUME_TO
                       FROM crcomp_pair_OHLC_1M_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CAST(date_trunc('second', current_timestamp) as timestamp without time zone) - INTERVAL '$ext_period_real_point minutes'
                       order by timestamp_point ASC LIMIT $limit_prds" ;
       }

    if ( $pv{time_frame} eq "1M" ) { $ext_period_real_point = $l_count_prds + $l_offset_prds + $l_max_extension_periods + 1 ; $limit_prds = $l_count_prds + $l_max_extension_periods + 1 ;
       $request = "SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       price_open as PRICE_OPEN, price_low as PRICE_MIN, price_high PRICE_MAX, price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL '3 HOURS')) days,
                       extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours, extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       volume_from as VOLUME_FROM, volume_to as VOLUME_TO
                       FROM crcomp_pair_OHLC_1M_history
                       WHERE currency = '$pv{currency}' AND reference_currency = '$pv{curr_reference}'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CAST(date_trunc('second', current_timestamp) as timestamp without time zone) - INTERVAL '$ext_period_real_point minutes'
                       order by timestamp_point ASC LIMIT $limit_prds" ;
       }

#print "- debug - \$ext_period_real_point \$l_count_prds \$l_max_extension_periods + 1 = $ext_period_real_point $l_count_prds $l_max_extension_periods + 1 \n" ;
#-debug-open(DEBG,">>/tmp/print_get_ohlcv_from_crcomp_table.out") ; print DEBG "- debug - $request\n \$ext_period_real_point \$l_count_prds \$l_max_extension_periods + 1 = $ext_period_real_point $l_count_prds $l_max_extension_periods + 1 \n" ; close(DEBG) ;
       my $dbh_h = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'cryptapwd') ;
       my $sth_h = $dbh_h->prepare($request) ; $sth_h->execute(); $count_rows = 0 ;
# заполнить промежуточный массив с префиксным расширением периодов - только для граничных записей периода
# и рассчитать ЕМА
       my $currency = "" ; my $reference_currency ="" ; my $datetime_point = "" ; my $price_open = 0 ; my $price_min = 0 ; my $price_max = 0 ; my $price_close = 0 ; my $days = 0 ; my $hours = 0 ; my $minutes = 0 ; my $volume_from = 0 ; my $volume_to = 0 ;
       my @data_cartrige = () ;
       while ( @data_cartrige = $sth_h->fetchrow_array() ) {
             $currency = $data_cartrige[0] ; $reference_currency = $data_cartrige[1] ; $datetime_point = $data_cartrige[2] ; $price_open = $data_cartrige[3]; $price_min = $data_cartrige[4] ; $price_max = $data_cartrige[5] ;
             $price_close = $data_cartrige[6] ; $days = $data_cartrige[7] ; $hours = $data_cartrige[8] ; $minutes = $data_cartrige[9] ; $volume_from = $data_cartrige[10] ; $volume_to = $data_cartrige[11] ;
# здесь выбираем только подходящие под NA данные без хвостов
             if ( ( $pv{time_frame} eq "4W" && $days == 1 ) ||
                  ( $pv{time_frame} eq "1W" && ( $days == 1 || $days == 8 || $days == 15 || $days == 22 || $days == 29 ) ) ||
                  ( $pv{time_frame} eq "4D" && ( $days == 1 || $days == 5 || $days == 9 || $days == 13 || $days == 17 || $days == 21 || $days == 25 || $days == 29 ) ) ||
                  ( $pv{time_frame} eq "2D" && (int($days / 2) - ($days / 2)) != 0 ) ||
                  ( $pv{time_frame} eq "12H" && ( $hours == 1 || $hours == 13 ) && $minutes == 0 ) ||
                  ( $pv{time_frame} eq "8H" && ( $hours == 1 || $hours == 9 || $hours == 17 ) && $minutes == 0 ) ||
                  ( $pv{time_frame} eq "4H" && ( $hours == 1 || $hours == 5 || $hours == 9 || $hours == 13 || $hours == 17 || $hours == 21 ) && $minutes == 0 ) ||
                  ( $pv{time_frame} eq "3H" && ( $hours == 1 || $hours == 4 || $hours == 7 || $hours == 10 || $hours == 13 || $hours == 16 || $hours == 19 || $hours == 22 ) && $minutes == 0 ) ||
                  ( $pv{time_frame} eq "2H" && ( (int($hours / 2) - ($hours / 2)) != 0 && $minutes == 0 )) ||
                  ( $pv{time_frame} eq "1H" && ( $minutes == 0 )) ||
                  ( $pv{time_frame} eq "30M" && ( $minutes == 0 || $minutes == 30 )) ||
                  ( $pv{time_frame} eq "15M" && ( $minutes == 0 || $minutes == 15 || $minutes == 30 || $minutes == 45 )) ||
                  ( $pv{time_frame} eq "10M" && ( $minutes == 0 || $minutes == 10 || $minutes == 20 || $minutes == 30 || $minutes == 40 || $minutes == 50 )) ||
                  ( $pv{time_frame} eq "5M" && ( $minutes == 0 || $minutes == 5 || $minutes == 10 || $minutes == 15 || $minutes == 20 || $minutes == 25 ||
                                                 $minutes == 30 || $minutes == 35 || $minutes == 40 || $minutes == 45 || $minutes == 50 || $minutes == 55)) ||
                  ( $pv{time_frame} eq "3M" && ( $minutes == 0 || $minutes == 3 || $minutes == 6 || $minutes == 9 || $minutes == 12 || $minutes == 15 || $minutes == 18 || $minutes == 21 ||
                                                 $minutes == 24 || $minutes == 27 || $minutes == 30 || $minutes == 33 || $minutes == 36 || $minutes == 39 || $minutes == 42 || $minutes == 45 ||
                                                 $minutes == 48 || $minutes == 51 || $minutes == 54 || $minutes == 57)) ||
                  ( $pv{time_frame} eq "1M" ) || ( $pv{time_frame} eq "1D" ) ) {
                if ($l_date_size eq "middle") { $datetime_point =~ s/(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)/$3 $4:$5/g ; }
                $arr_ref_datetime_list->[$count_rows] = $datetime_point ;
                $arr_ref_days_list->[$count_rows] = $days ;
                $arr_ref_hours_list->[$count_rows] = $hours ;
                $arr_ref_minutes_list->[$count_rows] = $minutes ;
# для начальных записей при использовании оконных функций значения могут быть пустые, а т.к. набор данных может не иметь расширенного диапазона дней, он войдут в конечный массив
# нужно подать правильные значения - пустые графической библиотекой не допускаются
                if ( $price_open eq "" ) { $price_open = $price_close ; }
                $arr_ref_price_open->[$count_rows] = $price_open ;
                $arr_ref_price_min->[$count_rows] = $price_min ;
                $arr_ref_price_max->[$count_rows] = $price_max ;
                $arr_ref_price_close->[$count_rows] = $price_close ;
                $arr_ref_volume_from->[$count_rows] = $volume_from ;
                $arr_ref_volume_to->[$count_rows] = $volume_to ;
#      $datetime_point =~ s/\d\d\d\d-(\d\d)-(\d\d)/$1$2/g ;
#-debug-print("\n--- debug --- $pv{time_frame} - count_rows $count_rows - price_close $price_close -  \$arr_ref_price_close[$count_rows] $arr_ref_price_close->[$count_rows]\n") ;
                $count_rows += 1 ;
#-debug-system("echo \"faza1 $datetime_point - $hours - $minutes\" >> /tmp/test_xxx.$pv{currency}") ;

                }
             }
       $sth_h->finish() ;
       $dbh_h->disconnect() ;

# заполнить хвост - последнее значение, не дожидаясь закрытия периода
#-debug-open(DEB_FILE,">>/tmp/test_xxx.$pv{currency}") ;
#-debug-printf DEB_FILE "faza2 - $datetime_point - $hours - $minutes \n" ;
#-debug-close(DEB_FILE) ;
#-debug-#system("echo \"- $hours - $minutes\" > /tmp/test_xxx.$pv{currency}") ;
#-debug-#print("\n--- debug --- хвост - \n") ;
#       $is_fill_tail = "no_fill" ;
       if ( $is_fill_tail eq "fill" ) {
          if ( ( $pv{time_frame} eq "4W" && $days != 1 ) ||
               ( $pv{time_frame} eq "1W" && ( $days != 1 && $days != 8 && $days != 15 && $days != 22 && $days != 29 )) ||
               ( $pv{time_frame} eq "4D" && ( $days != 1 && $days != 5 && $days != 9 && $days != 13 && $days != 17 && $days != 21 && $days != 25 && $days != 29 )) ||
               ( $pv{time_frame} eq "2D" && ( int($days / 2) - ($days / 2)) == 0 ) ||
               ( $pv{time_frame} eq "12H" && (( $hours != 1 && $hours != 13 ) || $minutes != 0 )) ||
               ( $pv{time_frame} eq "8H" && (( $hours != 1 && $hours != 9 && $hours != 17 ) || $minutes != 0 )) ||
               ( $pv{time_frame} eq "4H" && (( $hours != 1 && $hours != 5 && $hours != 9 && $hours != 13 && $hours != 17 && $hours != 21 ) || $minutes != 0 )) ||
               ( $pv{time_frame} eq "3H" && (( $hours != 1 && $hours != 4 && $hours != 7 && $hours != 10 && $hours != 13 && $hours != 16 && $hours != 19 && $hours != 22 ) || $minutes != 0 )) ||
               ( $pv{time_frame} eq "2H" && ( (int($hours / 2) - ($hours / 2)) == 0 || $minutes != 0 )) ||
               ( $pv{time_frame} eq "1H" && ( $minutes != 0 )) ||
               ( $pv{time_frame} eq "30M" && ( $minutes != 0 && $minutes != 30 )) ||
               ( $pv{time_frame} eq "15M" && ( $minutes != 0 && $minutes != 15 && $minutes != 30 && $minutes != 45 )) ||
               ( $pv{time_frame} eq "10M" && ( $minutes != 0 && $minutes != 10 && $minutes != 20 && $minutes != 30 && $minutes != 40 && $minutes != 50 )) ||
               ( $pv{time_frame} eq "5M" && ( $minutes != 0  && $minutes != 5  && $minutes != 10 && $minutes != 15 && $minutes != 20 && $minutes != 25 && $minutes != 30 &&$minutes != 35 &&
                                              $minutes != 40 && $minutes != 45 && $minutes != 50 && $minutes != 55)) ||
               ( $pv{time_frame} eq "3M" && ( $minutes != 0  && $minutes != 3  && $minutes != 6  && $minutes != 9  && $minutes != 12 && $minutes != 15 && $minutes != 18 && $minutes != 21 &&
                                              $minutes != 24 && $minutes != 27 && $minutes != 30 && $minutes != 33 && $minutes != 36 && $minutes != 39 && $minutes != 42 && $minutes != 45 &&
                                              $minutes != 48 && $minutes != 51 && $minutes != 54 && $minutes != 57)) ) {

#-debug-$aa = (int($hours / 2) - ($hours / 2)) ;
             if ($l_date_size eq "middle") { $datetime_point =~ s/(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)/$3 $4:$5/g ; }
             $arr_ref_datetime_list->[$count_rows] = $datetime_point ;
             $arr_ref_days_list->[$count_rows] = $days ;
             $arr_ref_hours_list->[$count_rows] = $hours ;
             $arr_ref_minutes_list->[$count_rows] = $minutes ;
# для начальных записей при использовании оконных функций значения могут быть пустые, а т.к. набор данных может не иметь расширенного диапазона дней, он войдут в конечный массив
# нужно подать правильные значения - пустые графической библиотекой не допускаются
             if ( $price_open eq "" ) { $price_open = $price_close ; }
             $arr_ref_price_open->[$count_rows] = $price_open ;
             $arr_ref_price_min->[$count_rows] = $price_min ;
             $arr_ref_price_max->[$count_rows] = $price_max ;
             $arr_ref_price_close->[$count_rows] = $price_close ;
             $arr_ref_volume_from->[$count_rows] = $volume_from ;
             $arr_ref_volume_to->[$count_rows] = $volume_to ;
#      $datetime_point =~ s/\d\d\d\d-(\d\d)-(\d\d)/$1$2/g ;
#-debug-system("echo \"faza3 include - $aa - $hours - $minutes --- $arr_ref_datetime_list[$count_rows] - $arr_ref_hours_list[$count_rows] - $arr_ref_minutes_list[$count_rows] - $arr_ref_price_open[$count_rows] - $arr_ref_price_min[$count_rows] - $arr_ref_price_max[$count_rows] - $arr_ref_price_close[$count_rows] - ema $arr_ref_ema01[$count_rows] - day $arr_ref_ema02[$count_rows] - week $arr_ref_ema03[$count_rows]\" >> /tmp/test_xxx.$pv{currency}") ;
             $count_rows += 1 ;
#-debug-print("\n--- debug --- хвост --- $pv{time_frame} - count_rows $count_rows - price_close $price_close -  \$arr_ref_price_close[$count_rows] $arr_ref_price_close->[$count_rows]\n") ;
             }
       }
    return $count_rows ;
    }



sub print_tools_coin_navigation($) { $active_tab{1} = "" ; $active_tab{2} = "" ; $active_tab{3} = "" ; $active_tab{4} = "" ; $active_tab{5} = "" ; ;
    $num_active_tab = $_[0] ; $active_tab{$num_active_tab} = " solid none solid" ;
    if ($pv{time_frame_ext} eq "") { $pv{time_frame_ext} = "10Mh" ; }
    print "<TABLE CELLSPACING=\"0\" CELLPADDING=\"0\" STYLE=\"border: 0pt none; width: 100%;\">
           <TR><TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{5}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_market_status.cgi\">Состояние<BR>рынка</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{6}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_common_info.cgi\">Портрет<BR>монеты</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{1}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_contracts.cgi?currency=ALL&curr_reference=$pv{curr_reference}&cnt_rand_id=$pv{cnt_rand_id}&action=open_contracts_list&user_name=$pv{user_name}&cntrct_status=$pv{cntrct_status}&cntrct_cycles=$pv{cntrct_cycles}\">Ведение<BR>сделок</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{2}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_trading.cgi?currency=BTC&curr_reference=$pv{curr_reference}&rand_id=$pv{rand_id}&time_frame=SWING_DAY&window_days=7&period_days=120&sort_column=AVG_VOL&sort_type=DESC&time_frame_ext=$pv{time_frame_ext}\">Трэйдинговая<BR>аналитика</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{3}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_invest.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}&rand_id=$pv{rand_id}\">Инвестиционная<BR>аналитика</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{4}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_monitoring.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}&rand_id=$pv{rand_id}&time_frame=1D&count_prds=$pv{count_1d_prds}&macd_mult=$pv{macd_mult}&env_prct=30\">События<BR>мониторинга</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{7}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_report_list.cgi?sort_column=AVG_VOL&sort_type=DESC\">Отчёты<BR>аналитика</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{8}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_pg_monitor_TA_SAH.cgi?query_id=&plan_hash=&pid=&serial=&ds_type=DB&sess_state_filter=all_states&is_user_backends=true&is_backgrounds=true&is_extensions=true&tab_detail=1\">Postgree&nbsp;SQL<BR>monitor</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           </TR></TABLE>" ;
    }

sub print_tools_invest_navigation($) { $active_tab{1} = "" ; $active_tab{2} = "" ; $active_tab{3} = "" ; $active_tab{4} = "" ; $active_tab{5} = "" ; ;
    $num_active_tab = $_[0] ; $active_tab{$num_active_tab} = " solid none solid" ;
    if ($pv{time_frame_ext} eq "") { $pv{time_frame_ext} = "10Mh" ; }
    print "<TABLE CELLSPACING=\"0\" CELLPADDING=\"0\" STYLE=\"border: 0pt none; width: 100%;\">
           <TR><TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{2}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_invest.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}&cnt_rand_id=$pv{cnt_rand_id}\">Лента:&nbsp;Инвестиционные&nbsp;пары</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{1}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/tools_coin_invest.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}&cnt_rand_id=$pv{cnt_rand_id}\">Карточка:&nbsp;Инвестиционная&nbsp;пара</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
           </TR></TABLE>" ;
    }

# эта навигационная панель всегда выводит две вкладки - список и текущий отчёт
sub print_reports_coin_navigation($$$) { $active_tab{1} = "" ; $active_tab{2} = "" ; $active_tab{3} = "" ; $active_tab{4} = "" ; $active_tab{5} = "" ; ;
    $num_active_tab = $_[0] ; $module_name = $_[1] ; $tab2_label = $_[2] ; $active_tab{$num_active_tab} = " solid none solid" ;
    print "<TABLE CELLSPACING=\"0\" CELLPADDING=\"0\" STYLE=\"border: 0pt none; width: 100%;\">
           <TR><TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{1}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_report_list.cgi?sort_column=AVG_VOL&sort_type=DESC\">Список<BR>отчётов</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{2}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_one_coin_TF_compare.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}\">Сравнение<BR>ТФ&nbsp;для&nbsp;монеты</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{3}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_mon_analyze_symmetric_macd.cgi?$pv{currency}&curr_reference=$pv{curr_reference}&rep_mode=group&event_name=MACD_4H_LINE_CROSS&event_tf=4H\">Realtime<BR>MACD</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{4}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_rtrsp_strategy_RSI_MACD.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}&tf_rsi=1H&tf_macd=1H&is_lncrs_1h1h=false&is_lnvct_1h1h=false&is_gsvct_1h1h=false&is_lncrs_1h4h=true&is_lnvct_1h4h=false&is_gsvct_1h4h=false&report_type=coins_groupped\">Ретроспектива<BR>RSI + MACD</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{5}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_rtrsp_strategy_RSI_MACD_EMA.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}&tf_rsi=1H&tf_macd=1H&is_lncrs_1h1h=false&is_lnvct_1h1h=false&is_gsvct_1h1h=false&is_lncrs_1h4h=true&is_lnvct_1h4h=false&is_gsvct_1h4h=false&report_type=coins_groupped\">Ретроспектива<BR>RSI + MACD + EMA</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>


           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{6}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/rep_rtrsp_strategy_RSI_MACD.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}&is_lncrs_1h1h=false&is_lnvct_1h1h=false&is_gsvct_1h1h=false&is_lncrs_1h4h=true&is_lnvct_1h4h=false&is_gsvct_1h4h=false&report_type=coins_groupped\">Ретроспектива<BR>Конструктор_01</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           <TD STYLE=\"border: 2pt navy; border-style: solid $active_tab{7}; text-align: center;\">
               <A HREF=\"$COMM_PAR_BASE_HREF/cgi/$module_name?currency=$pv{currency}&curr_reference=$pv{curr_reference}&cnt_rand_id=$pv{cnt_rand_id}&time_frame=1D&count_prds=$pv{count_1d_prds}&macd_mult=$pv{macd_mult}&env_prct=30\">Ретроспектива<BR>стEMA + ЗЦ Элдера</A></TD>
           <TD STYLE=\"border: 2pt navy; border-style: none none solid none;\">&nbsp;&nbsp;&nbsp;&nbsp;</TD>

           </TR></TABLE>" ;
    }

       
sub print_main_page_title($$) { $title_part_01 = $_[0] ; $title_part_02 = $_[1] ;
print "<TABLE BORDER=\"1\" STYLE=\"width: 100%; border-width: solid; border-color: navy;\">
<TR><TD>
    <P STYLE=\"text-align: right; font-family: sans-serif; color: navy; font-size: 14pt; font-weight: bold;\">$title_part_01 <SPAN STYLE=\"font-size: 14pt; color: green;\">$title_part_02</SPAN></P>
</TD></TR>
</TABLE><BR>" ;
    }  

sub print_coin_links_map($) {
    $cgi_module_name = $_[0] ;
    $tmp_coin_list = $trade_all_vol_coin_list ; $tmp_coin_list =~ s/\',\'/ /g ; $tmp_coin_list =~ s/\'//g ;
    @tmp_coin_list1 = sort(split(/ /, $tmp_coin_list)) ;

    print "<STYLE>
           A.small_size:link { color: navy; text-decoration: none; font-weight: normal; font-size: 7pt; font-family: sans-serif; }
           A.small_size:active { color: navy; text-decoration: none; font-weight: normal; font-size: 7pt; font-family: sans-serif; }
           A.small_size:visited { color: navy; text-decoration: none; font-weight: normal; font-size: 7pt; font-family: sans-serif; }
           A.small_size:hover { color: navy; text-decoration: none; font-weight: normal; font-size: 7pt; font-family: sans-serif; }
           </STYLE>" ;

    print "<TABLE BORDER=\"0\"><TR><TD>Фильтр:&nbsp;</TD><TD><SELECT CLASS=\"\" NAME=\"filter_currency\" ID=\"id_filter_currency\">" ;
    my $is_fc_selected ;
    $is_fc_selected = "" ; if ( "$pv{currency}" eq "TOP_100" )   { $is_fc_selected = " SELECTED" ; } print "\n<OPTION VALUE=\"TOP_100\" $is_fc_selected>список - ТОП100 по капитализации</OPTION>" ;
    $is_fc_selected = "" ; if ( "$pv{currency}" eq "TOP_50" )    { $is_fc_selected = " SELECTED" ; } print "\n<OPTION VALUE=\"TOP_50\" $is_fc_selected>список - ТОП50 по капитализации</OPTION>" ;
    $is_fc_selected = "" ; if ( "$pv{currency}" eq "ALL" )       { $is_fc_selected = " SELECTED" ; } print "\n<OPTION VALUE=\"ALL\" $is_fc_selected>список - все монеты</OPTION>" ;
    $is_fc_selected = "" ; if ( "$pv{currency}" eq "IN_TRADE" )  { $is_fc_selected = " SELECTED" ; } print "\n<OPTION VALUE=\"IN_TRADE\" $is_fc_selected>список - открытые трэйдинг сделки</OPTION>" ;
    $is_fc_selected = "" ; if ( "$pv{currency}" eq "IN_INVEST" ) { $is_fc_selected = " SELECTED" ; } print "\n<OPTION VALUE=\"IN_INVEST\" $is_fc_selected>список - открытые инвест сделки</OPTION>" ;
    $is_fc_selected = "" ; if ( "$pv{currency}" eq "INVST_01" )  { $is_fc_selected = " SELECTED" ; } print "\n<OPTION VALUE=\"INVST_01\" $is_fc_selected>список - клуб. Надёжные, уверенный спот инвест</OPTION>" ;
    $is_fc_selected = "" ; if ( "$pv{currency}" eq "INVST_02" )  { $is_fc_selected = " SELECTED" ; } print "\n<OPTION VALUE=\"INVST_02\" $is_fc_selected>список - клуб. Кандидаты на инвест от 20240214</OPTION>" ;
    $is_fc_selected = "" ; if ( "$pv{currency}" eq "INVST_03" )  { $is_fc_selected = " SELECTED" ; } print "\n<OPTION VALUE=\"INVST_03\" $is_fc_selected>список - клуб. Новые</OPTION>" ;
    $is_fc_selected = "" ; if ( "$pv{currency}" eq "INVST_04" )  { $is_fc_selected = " SELECTED" ; } print "\n<OPTION VALUE=\"INVST_04\" $is_fc_selected>список - клуб. Принесут больше всего</OPTION>" ;
    foreach (@tmp_coin_list1) { $filter_currency = $_ ; $is_fc_selected = "" ; if ( $filter_currency eq "$pv{currency}" ) { $is_fc_selected = " SELECTED" ; }
            print "\n<OPTION VALUE=\"$filter_currency\" $is_fc_selected>$filter_currency</OPTION>" ; }
    print "</SELECT>&nbsp;\n" ;

    print "<SELECT CLASS=\"\" NAME=\"filter_curr_reference\" ID=\"id_filter_curr_reference\">" ;
    my $is_fcrref_selected ;
    foreach ("USDT","BTC") { $filter_curr_reference = $_ ; $is_fcrref_selected = "" ; if ( $filter_curr_reference eq "$pv{curr_reference}" ) { $is_fcrref_selected = " SELECTED" ; }
            print "\n<OPTION VALUE=\"$filter_curr_reference\" $is_fcrref_selected>$filter_curr_reference</OPTION>" ; }
    print "</SELECT>&nbsp;\n</TD>" ;

# дополнительные поля фильтра для формы ведения сделок
    if ( $cgi_module_name eq "tools_coin_contracts.cgi" ) {
       print "<TD>Пользователь:&nbsp;</TD><TD><SELECT NAME=\"filter_user_name\" ID=\"id_filter_user_name\" STYLE=\"width: 127pt;\">" ;
       $is_filter_user_name_selected = "" ; if ( $pv{user_name} eq "undefined" ) { $is_filter_user_name_selected = " SELECTED" ; } print "<OPTION VALUE=\"undefined\" $is_filter_user_name_selected>Не определено</OPTION>" ;
       $is_filter_user_name_selected = "" ; if ( $pv{user_name} eq "Serjie" ) { $is_filter_user_name_selected = " SELECTED" ; } print "<OPTION VALUE=\"Serjie\" $is_filter_user_name_selected>Serjie</OPTION>" ;
       $is_filter_user_name_selected = "" ; if ( $pv{user_name} eq "Semnava" ) { $is_filter_user_name_selected = " SELECTED" ; } print "<OPTION VALUE=\"Semnava\" $is_filter_user_name_selected>Semnava</OPTION>" ;
       print "</SELECT>&nbsp;\n</TD><TD>" ;

       print "&nbsp;Статус:&nbsp;</TD><TD><SELECT NAME=\"filter_contract_status\" ID=\"id_filter_contract_status\">" ;
       $is_filter_contract_status_selected = "" ; if ( $pv{cntrct_status} eq "" ) { $is_filter_contract_status_selected = " SELECTED" ; } print "<OPTION VALUE=\"\" $is_filter_contract_status_selected>Все</OPTION>" ;
       $is_filter_contract_status_selected = "" ; if ( $pv{cntrct_status} eq "open_contract" ) { $is_filter_contract_status_selected = " SELECTED" ; } print "<OPTION VALUE=\"open_contract\" $is_filter_contract_status_selected>Открытые</OPTION>" ;
       $is_filter_contract_status_selected = "" ; if ( $pv{cntrct_status} eq "closed_contract" ) { $is_filter_contract_status_selected = " SELECTED" ; } print "<OPTION VALUE=\"closed_contract\" $is_filter_contract_status_selected>Закрытые</OPTION>" ;
       print "</SELECT>&nbsp;\n</TD><TD ROWSPAN=\"2\">" ;

       print "<SPAN STYLE=\"cursor: pointer; font-size: 10pt; color: navy ;\"
              onclick=\"reload_filters_contracts('$cgi_module_name',id_filter_currency.value,id_filter_curr_reference.value,'$pv{rand_id}','$pv{action}',id_filter_user_name.value,id_filter_contract_status.value,id_filter_contract_cycles.value,id_filter_rep_mode.value)\">&nbsp;&nbsp;обновить</SPAN>\n" ;

       print "</TD></TR><TR><TD>Циклы:&nbsp;</TD><TD><SELECT NAME=\"filter_contract_status\" ID=\"id_filter_contract_cycles\" STYLE=\"width: 343pt;\">" ;
       $is_filter_contract_cycles_selected = "" ; if ( $pv{cntrct_cycles} eq "" ) { $is_filter_contract_cycles_selected = " SELECTED" ; } print "<OPTION VALUE=\"\" $is_filter_contract_cycles_selected>Все</OPTION>" ;
       $is_filter_contract_cycles_selected = "" ; if ( $pv{cntrct_cycles} eq "trading" ) { $is_filter_contract_cycles_selected = " SELECTED" ; } print "<OPTION VALUE=\"trading\" $is_filter_contract_cycles_selected>Трэйдинг</OPTION>" ;
       $is_filter_contract_cycles_selected = "" ; if ( $pv{cntrct_cycles} eq "invest" ) { $is_filter_contract_cycles_selected = " SELECTED" ; } print "<OPTION VALUE=\"invest\" $is_filter_contract_cycles_selected>Инвестирование</OPTION>" ;
       print "</SELECT>&nbsp;\n</TD><TD>" ;

       print "Формат&nbsp;отчёта:&nbsp;</TD><TD><SELECT NAME=\"filter_rep_mode\" ID=\"id_filter_rep_mode\" STYLE=\"width: 127pt;\">" ;
       $is_filter_rep_mode_selected = "" ; if ( $pv{rep_mode} eq "" || $pv{rep_mode} eq "full" ) { $is_filter_rep_mode_selected = " SELECTED" ; } print "<OPTION VALUE=\"full\" $is_filter_rep_mode_selected>Полный</OPTION>" ;
       $is_filter_rep_mode_selected = "" ; if ( $pv{rep_mode} eq "easy" ) { $is_filter_rep_mode_selected = " SELECTED" ; } print "<OPTION VALUE=\"easy\" $is_filter_rep_mode_selected>Упрощённый</OPTION>" ;
       print "</SELECT>&nbsp;\n</TD></TR>" ;
       }

# дополнительные поля фильтра для формы мониторинга
    if ( $cgi_module_name eq "tools_coin_monitoring.cgi" ) {
       print "<TD>&nbsp;потолки:&nbsp;</TD><TD><SELECT NAME=\"filter_areal\" ID=\"id_filter_mon_areal\">" ;
       $is_filter_mon_areal_selected = "" ; if ( $pv{mon_areal} eq "undefined" ) { $is_filter_mon_areal_selected = " SELECTED" ; } print "<OPTION VALUE=\"undefined\" $is_filter_mon_areal_selected>не определено (все ТФ)</OPTION>" ;
       $is_filter_mon_areal_selected = "" ; if ( $pv{mon_areal} eq "equal" ) { $is_filter_mon_areal_selected = " SELECTED" ; } print "<OPTION VALUE=\"equal\" $is_filter_mon_areal_selected>текущий ТФ</OPTION>" ;
       $is_filter_mon_areal_selected = "" ; if ( $pv{mon_areal} eq "eq_plus" ) { $is_filter_mon_areal_selected = " SELECTED" ; } print "<OPTION VALUE=\"eq_plus\" $is_filter_mon_areal_selected>текущий ТФ и старше</OPTION>" ;
       print "</SELECT>&nbsp;\n</TD><TD>" ;

       print "&nbsp;ТФ:&nbsp;</TD><TD><SELECT NAME=\"filter_mon_tf\" ID=\"id_filter_mon_tf\">" ;
       $is_filter_mon_tf_selected = "" ; if ( $pv{mon_tf} eq "undefined" || $pv{mon_tf} eq "" ) { $is_filter_mon_tf_selected = " SELECTED" ; } print "<OPTION VALUE=\"undefined\" $is_filter_mon_tf_selected>не определено</OPTION>" ;
       $is_filter_mon_tf_selected = "" ; if ( $pv{mon_tf} eq "4W" ) { $is_filter_mon_tf_selected = " SELECTED" ; } print "<OPTION VALUE=\"4W\" $is_filter_mon_tf_selected>4W</OPTION>" ;
       $is_filter_mon_tf_selected = "" ; if ( $pv{mon_tf} eq "1W" ) { $is_filter_mon_tf_selected = " SELECTED" ; } print "<OPTION VALUE=\"1W\" $is_filter_mon_tf_selected>1W</OPTION>" ;
       $is_filter_mon_tf_selected = "" ; if ( $pv{mon_tf} eq "4D" ) { $is_filter_mon_tf_selected = " SELECTED" ; } print "<OPTION VALUE=\"4D\" $is_filter_mon_tf_selected>4D</OPTION>" ;
       $is_filter_mon_tf_selected = "" ; if ( $pv{mon_tf} eq "2D" ) { $is_filter_mon_tf_selected = " SELECTED" ; } print "<OPTION VALUE=\"2D\" $is_filter_mon_tf_selected>2D</OPTION>" ;
       $is_filter_mon_tf_selected = "" ; if ( $pv{mon_tf} eq "1D" ) { $is_filter_mon_tf_selected = " SELECTED" ; } print "<OPTION VALUE=\"1D\" $is_filter_mon_tf_selected>1D</OPTION>" ;
       $is_filter_mon_tf_selected = "" ; if ( $pv{mon_tf} eq "12H" ) { $is_filter_mon_tf_selected = " SELECTED" ; } print "<OPTION VALUE=\"12H\" $is_filter_mon_tf_selected>12H</OPTION>" ;
       $is_filter_mon_tf_selected = "" ; if ( $pv{mon_tf} eq "8H" ) { $is_filter_mon_tf_selected = " SELECTED" ; } print "<OPTION VALUE=\"8H\" $is_filter_mon_tf_selected>8H</OPTION>" ;
       $is_filter_mon_tf_selected = "" ; if ( $pv{mon_tf} eq "4H" ) { $is_filter_mon_tf_selected = " SELECTED" ; } print "<OPTION VALUE=\"4H\" $is_filter_mon_tf_selected>4H</OPTION>" ;
       $is_filter_mon_tf_selected = "" ; if ( $pv{mon_tf} eq "3H" ) { $is_filter_mon_tf_selected = " SELECTED" ; } print "<OPTION VALUE=\"3H\" $is_filter_mon_tf_selected>3H</OPTION>" ;
       $is_filter_mon_tf_selected = "" ; if ( $pv{mon_tf} eq "2H" ) { $is_filter_mon_tf_selected = " SELECTED" ; } print "<OPTION VALUE=\"2H\" $is_filter_mon_tf_selected>2H</OPTION>" ;
       $is_filter_mon_tf_selected = "" ; if ( $pv{mon_tf} eq "1H" ) { $is_filter_mon_tf_selected = " SELECTED" ; } print "<OPTION VALUE=\"1H\" $is_filter_mon_tf_selected>1H</OPTION>" ;
       $is_filter_mon_tf_selected = "" ; if ( $pv{mon_tf} eq "30M" ) { $is_filter_mon_tf_selected = " SELECTED" ; } print "<OPTION VALUE=\"30M\" $is_filter_mon_tf_selected>30M</OPTION>" ;
       $is_filter_mon_tf_selected = "" ; if ( $pv{mon_tf} eq "15M" ) { $is_filter_mon_tf_selected = " SELECTED" ; } print "<OPTION VALUE=\"15M\" $is_filter_mon_tf_selected>15M</OPTION>" ;
       $is_filter_mon_tf_selected = "" ; if ( $pv{mon_tf} eq "10M" ) { $is_filter_mon_tf_selected = " SELECTED" ; } print "<OPTION VALUE=\"10M\" $is_filter_mon_tf_selected>10M</OPTION>" ;
       $is_filter_mon_tf_selected = "" ; if ( $pv{mon_tf} eq "5M" ) { $is_filter_mon_tf_selected = " SELECTED" ; } print "<OPTION VALUE=\"5M\" $is_filter_mon_tf_selected>5M</OPTION>" ;
       $is_filter_mon_tf_selected = "" ; if ( $pv{mon_tf} eq "3M" ) { $is_filter_mon_tf_selected = " SELECTED" ; } print "<OPTION VALUE=\"3M\" $is_filter_mon_tf_selected>3M</OPTION>" ;
       $is_filter_mon_tf_selected = "" ; if ( $pv{mon_tf} eq "1M" ) { $is_filter_mon_tf_selected = " SELECTED" ; } print "<OPTION VALUE=\"1M\" $is_filter_mon_tf_selected>1M</OPTION>" ;
       print "</SELECT>&nbsp;\n</TD><TD>" ;

       print "&nbsp;События:&nbsp;</TD><TD><SELECT NAME=\"filter_events\" ID=\"id_filter_mon_events\">" ;
       $is_filter_mon_events_selected = "" ; if ( $pv{mon_events} eq "" ) { $is_filter_mon_events_selected = " SELECTED" ; } print "<OPTION VALUE=\"all\" $is_filter_mon_events_selected>Все</OPTION>" ;
       $is_filter_mon_events_selected = "" ; if ( $pv{mon_events} eq "MACD_ALL" ) { $is_filter_mon_events_selected = " SELECTED" ; } print "<OPTION VALUE=\"MACD_ALL\" $is_filter_mon_events_selected>MACD_ALL</OPTION>" ;
       $is_filter_mon_events_selected = "" ; if ( $pv{mon_events} eq "MACD_LINE_CROSS" ) { $is_filter_mon_events_selected = " SELECTED" ; } print "<OPTION VALUE=\"MACD_LINE_CROSS\" $is_filter_mon_events_selected>MACD_LINE_CROSS</OPTION>" ;
       $is_filter_mon_events_selected = "" ; if ( $pv{mon_events} eq "MACD_LINE_VECTOR" ) { $is_filter_mon_events_selected = " SELECTED" ; } print "<OPTION VALUE=\"MACD_LINE_VECTOR\" $is_filter_mon_events_selected>MACD_LINE_VECTOR</OPTION>" ;
       $is_filter_mon_events_selected = "" ; if ( $pv{mon_events} eq "MACD_GIST_VECTOR" ) { $is_filter_mon_events_selected = " SELECTED" ; } print "<OPTION VALUE=\"MACD_GIST_VECTOR\" $is_filter_mon_events_selected>MACD_GIST_VECTOR</OPTION>" ;
       $is_filter_mon_events_selected = "" ; if ( $pv{mon_events} eq "RSI_ALL" ) { $is_filter_mon_events_selected = " SELECTED" ; } print "<OPTION VALUE=\"RSI_ALL\" $is_filter_mon_events_selected>RSI_ALL</OPTION>" ;
       print "</SELECT>&nbsp;\n</TD><TD>" ;

       print "<SPAN STYLE=\"cursor: pointer; font-size: 10pt; color: navy ;\"
              onclick=\"reload_filters_monitoring('$cgi_module_name',id_filter_currency.value,id_filter_curr_reference.value,'$pv{rand_id}','$pv{action}',id_filter_mon_areal.value,id_filter_mon_tf.value,id_filter_mon_events.value)\">&nbsp;&nbsp;обновить</SPAN>\n
              </TD></TR>" ;
       }

# дополнительные поля фильтра для формы rep_one_coin_TF_compare.cgi
    if ( $cgi_module_name eq "rep_one_coin_TF_compare.cgi" ) {
       print "<TD>&nbsp;RSI:&nbsp;</TD><TD><SELECT NAME=\"rsi_mode\" ID=\"id_rsi_mode\">" ;
       $is_filter_rsi_mode_selected = "" ; if ( $pv{rsi_mode} eq "1" ) { $is_filter_rsi_mode_selected = " SELECTED" ; } print "<OPTION VALUE=\"1\" $is_filter_rsi_mode_selected>показывать</OPTION>" ;
       $is_filter_rsi_mode_selected = "" ; if ( $pv{rsi_mode} eq "0" ) { $is_filter_rsi_mode_selected = " SELECTED" ; } print "<OPTION VALUE=\"0\" $is_filter_rsi_mode_selected>не показывать</OPTION>" ;
       print "</SELECT>&nbsp;\n</TD><TD>" ;

       print "&nbsp;MACD:&nbsp;</TD><TD><SELECT NAME=\"macd_mode\" ID=\"id_macd_mode\">" ;
       $is_filter_macd_mode_selected = "" ; if ( $pv{macd_mode} eq "1" ) { $is_filter_macd_mode_selected = " SELECTED" ; } print "<OPTION VALUE=\"1\" $is_filter_macd_mode_selected>показывать</OPTION>" ;
       $is_filter_macd_mode_selected = "" ; if ( $pv{macd_mode} eq "0" ) { $is_filter_macd_mode_selected = " SELECTED" ; } print "<OPTION VALUE=\"0\" $is_filter_macd_mode_selected>не показывать</OPTION>" ;
       print "</SELECT>&nbsp;\n</TD><TD>" ;

       print "<SPAN STYLE=\"cursor: pointer; font-size: 10pt; color: navy ;\"
              onclick=\"reload_filters_TF_compare('$cgi_module_name',id_filter_currency.value,id_filter_curr_reference.value,id_rsi_mode.value,id_macd_mode.value)\">&nbsp;&nbsp;обновить</SPAN>\n
              </TD></TR>" ;
       }

    if ( $cgi_module_name eq "rep_mon_analyze_symmetric_macd.cgi" ) {
       print "<TD>rep_mode: <INPUT VALUE =\"$pv{rep_mode}\" TYPE=\"input\" NAME=\"rep_mode\" ID=\"id_rep_mode\"></INPUT></TD>
              <TD>event_name: <INPUT VALUE =\"$pv{event_name}\" TYPE=\"input\" NAME=\"event_name\" ID=\"id_event_name\"></INPUT></TD>
              <TD>event_tf: <INPUT VALUE =\"$pv{event_tf}\" TYPE=\"input\" NAME=\"event_tf\" ID=\"id_event_tf\"></INPUT>" ;

       print "<TD><SPAN STYLE=\"cursor: pointer; font-size: 10pt; color: navy ;\"
              onclick=\"reload_filters_analyze_symmetric_macd('$cgi_module_name',id_filter_currency.value,id_filter_curr_reference.value,id_rep_mode.value,id_event_name.value,id_event_tf.value)\">&nbsp;&nbsp;обновить</SPAN>\n
              </TD></TR>" ;
       }

# дополнительные поля фильтра для формы ретроспективного анализа стратегии RSI+MACD
    if ( $cgi_module_name eq "rep_rtrsp_strategy_RSI_MACD.cgi" ) {
       $is_lncrs_1h1h = "" ; if ( $pv{is_lncrs_1h1h} eq "true" ) { $is_lncrs_1h1h = "CHECKED" ; } $is_lnvct_1h1h = "" ; if ( $pv{is_lnvct_1h1h} eq "true" ) { $is_lnvct_1h1h = "CHECKED" ; } $is_gsvct_1h1h = "" ; if ( $pv{is_gsvct_1h1h} eq "true" ) { $is_gsvct_1h1h = "CHECKED" ; }
       $is_lncrs_1h4h = "" ; if ( $pv{is_lncrs_1h4h} eq "true" ) { $is_lncrs_1h4h = "CHECKED" ; } $is_lnvct_1h4h = "" ; if ( $pv{is_lnvct_1h4h} eq "true" ) { $is_lnvct_1h4h = "CHECKED" ; } $is_gsvct_1h4h = "" ; if ( $pv{is_gsvct_1h4h} eq "true" ) { $is_gsvct_1h4h = "CHECKED" ; }
       $is_include_rsi  = "" ; if ( $pv{is_include_rsi } eq "true" ) { $is_include_rsi  = "CHECKED" ; }

       print "<TD><INPUT $is_lncrs_1h1h VALUE =\"$pv{is_lncrs_1h1h}\" TYPE=\"checkbox\" NAME=\"is_lncrs_1h1h\" ID=\"id_is_lncrs_1h1h\">RSI младший ТФ, Line Cross MACD младший ТФ</INPUT></TD>
              <TD><INPUT $is_lncrs_1h4h VALUE =\"$pv{is_lncrs_1h4h}\" TYPE=\"checkbox\" NAME=\"is_lncrs_1h4h\" ID=\"id_is_lncrs_1h4h\">RSI младший ТФ, Line Cross MACD старший ТФ</INPUT></TD>" ;

       print "<TD COLSPAN=\"2\"><SPAN STYLE=\"cursor: pointer; font-size: 10pt; color: navy ;\"
              onclick=\"reload_filters_rtrsp_RSI_MACD('$cgi_module_name','$pv{report_type}',id_filter_currency.value,id_filter_curr_reference.value,id_is_include_rsi.checked,id_start_date.value,id_stop_date.value,id_tf_rsi.value,id_tf_macd.value,'$pv{macd_ind_type}','$pv{macd_ind_sub_type}',id_is_lncrs_1h1h.checked,id_is_lnvct_1h1h.checked,id_is_gsvct_1h1h.checked,id_is_lncrs_1h4h.checked,id_is_lnvct_1h4h.checked,id_is_gsvct_1h4h.checked,'$pv{sort_field}',id_sl_value.value)\">&nbsp;&nbsp;обновить</SPAN>\n
              </TD></TR>" ;

       print "<TR><TD>&nbsp;</TD>
                  <TD><INPUT $is_include_rsi VALUE =\"$pv{is_include_rsi}\" TYPE=\"checkbox\" NAME=\"is_include_rsi\" ID=\"id_is_include_rsi\">RSI</INPUT>&nbsp;
                      <INPUT $is_include_ema VALUE =\"$pv{is_include_ema}\" TYPE=\"checkbox\" NAME=\"is_include_ema\" ID=\"id_is_include_ema\">EMA</INPUT>&nbsp;
                      <INPUT $is_include_stema VALUE =\"$pv{is_include_stema}\" TYPE=\"checkbox\" NAME=\"is_include_stema\" ID=\"id_is_include_stema\">EMA&nbsp;ст.&nbsp;цикла</INPUT>&nbsp;
                      RSI&nbsp;ТФ&nbsp;<INPUT VALUE =\"$pv{tf_rsi}\" TYPE=\"input\" NAME=\"tf_rsi\" ID=\"id_tf_rsi\" STYLE=\"width: 28pt; text-align: right;\"></INPUT>&nbsp;
                      MACD&nbsp;ТФ&nbsp;<INPUT VALUE =\"$pv{tf_macd}\" TYPE=\"input\" NAME=\"tf_macd\" ID=\"id_tf_macd\" STYLE=\"width: 28pt; text-align: right;\"></INPUT>
                  </TD>
              <TD><INPUT $is_lnvct_1h1h VALUE =\"$pv{is_lnvct_1h1h}\" TYPE=\"checkbox\" NAME=\"is_lnvct_1h1h\" ID=\"id_is_lnvct_1h1h\">RSI младший ТФ, Line Vector MACD младший ТФ</INPUT></TD>
              <TD><INPUT $is_lnvct_1h4h VALUE =\"$pv{is_lnvct_1h4h}\" TYPE=\"checkbox\" NAME=\"is_lnvct_1h4h\" ID=\"id_is_lnvct_1h4h\">RSI младший ТФ, Line Vector MACD старший ТФ</INPUT></TD></TR>" ;

       print "<TR><TD>Диапазон:</TD>
                  <TD><INPUT VALUE =\"$pv{start_date}\" TYPE=\"input\" NAME=\"start_date\" ID=\"id_start_date\" STYLE=\"width: 109pt; text-align: right;\"></INPUT>&nbsp;-&nbsp;<INPUT VALUE =\"$pv{stop_date}\" TYPE=\"input\" NAME=\"stop_date\" ID=\"id_stop_date\" STYLE=\"width: 109pt; text-align: right;\"></INPUT>&nbsp;
                      SL&nbsp;<INPUT VALUE =\"$pv{sl_value}\" TYPE=\"input\" NAME=\"sl_value\" ID=\"id_sl_value\" STYLE=\"width: 25pt; text-align: right;\"></INPUT>
                      TP&nbsp;<INPUT VALUE =\"$pv{tp_value}\" TYPE=\"input\" NAME=\"tp_value\" ID=\"id_tp_value\" STYLE=\"width: 25pt; text-align: right;\"></INPUT>
                  </TD>
              <TD><INPUT $is_gsvct_1h1h VALUE =\"$pv{is_gsvct_1h1h}\" TYPE=\"checkbox\" NAME=\"is_gsvct_1h1h\" ID=\"id_is_gsvct_1h1h\">RSI младший ТФ, Gist Vector MACD младший ТФ</INPUT></TD>
              <TD><INPUT $is_gsvct_1h4h VALUE =\"$pv{is_gsvct_1h4h}\" TYPE=\"checkbox\" NAME=\"is_gsvct_1h4h\" ID=\"id_is_gsvct_1h4h\">RSI младший ТФ, Gist Vector MACD старший ТФ</INPUT></TD></TR>" ;
       }

    if ( $cgi_module_name eq "rep_rtrsp_strategy_RSI_MACD_EMA.cgi" ) {
       $is_lncrs_1h1h = "" ; if ( $pv{is_lncrs_1h1h} eq "true" ) { $is_lncrs_1h1h = "CHECKED" ; } $is_lnvct_1h1h = "" ; if ( $pv{is_lnvct_1h1h} eq "true" ) { $is_lnvct_1h1h = "CHECKED" ; } $is_gsvct_1h1h = "" ; if ( $pv{is_gsvct_1h1h} eq "true" ) { $is_gsvct_1h1h = "CHECKED" ; }
       $is_lncrs_1h4h = "" ; if ( $pv{is_lncrs_1h4h} eq "true" ) { $is_lncrs_1h4h = "CHECKED" ; } $is_lnvct_1h4h = "" ; if ( $pv{is_lnvct_1h4h} eq "true" ) { $is_lnvct_1h4h = "CHECKED" ; } $is_gsvct_1h4h = "" ; if ( $pv{is_gsvct_1h4h} eq "true" ) { $is_gsvct_1h4h = "CHECKED" ; }
       $is_include_rsi  = "" ; if ( $pv{is_include_rsi } eq "true" ) { $is_include_rsi  = "CHECKED" ; } $is_include_ema  = "" ; if ( $pv{is_include_ema } eq "true" ) { $is_include_ema  = "CHECKED" ; } $is_include_stema  = "" ; if ( $pv{is_include_stema } eq "true" ) { $is_include_stema  = "CHECKED" ; }

       print "<TD><INPUT $is_lncrs_1h1h VALUE =\"$pv{is_lncrs_1h1h}\" TYPE=\"checkbox\" NAME=\"is_lncrs_1h1h\" ID=\"id_is_lncrs_1h1h\">RSI младший ТФ, Line Cross MACD младший ТФ</INPUT></TD>
              <TD><INPUT $is_lncrs_1h4h VALUE =\"$pv{is_lncrs_1h4h}\" TYPE=\"checkbox\" NAME=\"is_lncrs_1h4h\" ID=\"id_is_lncrs_1h4h\">RSI младший ТФ, Line Cross MACD старший ТФ</INPUT></TD>" ;

       print "<TD COLSPAN=\"2\"><SPAN STYLE=\"cursor: pointer; font-size: 10pt; color: navy ;\"
              onclick=\"reload_filters_rtrsp_RSI_MACD_EMA('$cgi_module_name','$pv{report_type}',id_filter_currency.value,id_filter_curr_reference.value,id_is_include_rsi.checked,id_start_date.value,id_stop_date.value,id_tf_rsi.value,id_tf_macd.value,'$pv{macd_ind_type}','$pv{macd_ind_sub_type}',id_is_lncrs_1h1h.checked,id_is_lnvct_1h1h.checked,id_is_gsvct_1h1h.checked,id_is_lncrs_1h4h.checked,id_is_lnvct_1h4h.checked,id_is_gsvct_1h4h.checked,'$pv{sort_field}',id_sl_value.value,id_is_include_ema.checked,id_is_include_stema.checked)\">&nbsp;&nbsp;обновить</SPAN>\n
              </TD></TR>" ;

       print "<TR><TD>&nbsp;</TD>
                  <TD><INPUT $is_include_rsi VALUE =\"$pv{is_include_rsi}\" TYPE=\"checkbox\" NAME=\"is_include_rsi\" ID=\"id_is_include_rsi\">RSI</INPUT>&nbsp;
                      <INPUT $is_include_ema VALUE =\"$pv{is_include_ema}\" TYPE=\"checkbox\" NAME=\"is_include_ema\" ID=\"id_is_include_ema\">EMA</INPUT>&nbsp;
                      <INPUT $is_include_stema VALUE =\"$pv{is_include_stema}\" TYPE=\"checkbox\" NAME=\"is_include_stema\" ID=\"id_is_include_stema\">EMA&nbsp;ст.&nbsp;цикла</INPUT>&nbsp;
                      RSI&nbsp;ТФ&nbsp;<INPUT VALUE =\"$pv{tf_rsi}\" TYPE=\"input\" NAME=\"tf_rsi\" ID=\"id_tf_rsi\" STYLE=\"width: 28pt; text-align: right;\"></INPUT>&nbsp;
                      MACD&nbsp;ТФ&nbsp;<INPUT VALUE =\"$pv{tf_macd}\" TYPE=\"input\" NAME=\"tf_macd\" ID=\"id_tf_macd\" STYLE=\"width: 28pt; text-align: right;\"></INPUT>
                  </TD>
              <TD><INPUT $is_lnvct_1h1h VALUE =\"$pv{is_lnvct_1h1h}\" TYPE=\"checkbox\" NAME=\"is_lnvct_1h1h\" ID=\"id_is_lnvct_1h1h\">RSI младший ТФ, Line Vector MACD младший ТФ</INPUT></TD>
              <TD><INPUT $is_lnvct_1h4h VALUE =\"$pv{is_lnvct_1h4h}\" TYPE=\"checkbox\" NAME=\"is_lnvct_1h4h\" ID=\"id_is_lnvct_1h4h\">RSI младший ТФ, Line Vector MACD старший ТФ</INPUT></TD></TR>" ;

       print "<TR><TD>Диапазон:</TD>
                  <TD><INPUT VALUE =\"$pv{start_date}\" TYPE=\"input\" NAME=\"start_date\" ID=\"id_start_date\" STYLE=\"width: 109pt; text-align: right;\"></INPUT>&nbsp;-&nbsp;<INPUT VALUE =\"$pv{stop_date}\" TYPE=\"input\" NAME=\"stop_date\" ID=\"id_stop_date\" STYLE=\"width: 109pt; text-align: right;\"></INPUT>&nbsp;
                      SL&nbsp;<INPUT VALUE =\"$pv{sl_value}\" TYPE=\"input\" NAME=\"sl_value\" ID=\"id_sl_value\" STYLE=\"width: 25pt; text-align: right;\"></INPUT>
                      TP&nbsp;<INPUT VALUE =\"$pv{tp_value}\" TYPE=\"input\" NAME=\"tp_value\" ID=\"id_tp_value\" STYLE=\"width: 25pt; text-align: right;\"></INPUT>
                  </TD>
              <TD><INPUT $is_gsvct_1h1h VALUE =\"$pv{is_gsvct_1h1h}\" TYPE=\"checkbox\" NAME=\"is_gsvct_1h1h\" ID=\"id_is_gsvct_1h1h\">RSI младший ТФ, Gist Vector MACD младший ТФ</INPUT></TD>
              <TD><INPUT $is_gsvct_1h4h VALUE =\"$pv{is_gsvct_1h4h}\" TYPE=\"checkbox\" NAME=\"is_gsvct_1h4h\" ID=\"id_is_gsvct_1h4h\">RSI младший ТФ, Gist Vector MACD старший ТФ</INPUT></TD></TR>" ;
       }


# отобразить ссылку на обновление для всех не кастомизированных
    if ( $cgi_module_name ne "tools_coin_contracts.cgi" && $cgi_module_name ne "tools_coin_monitoring.cgi" && $cgi_module_name ne "rep_one_coin_TF_compare.cgi" && $cgi_module_name ne "rep_rtrsp_strategy_RSI_MACD.cgi" 
         && $cgi_module_name ne "rep_mon_analyze_symmetric_macd.cgi" && $cgi_module_name ne "rep_rtrsp_strategy_RSI_MACD_EMA.cgi" ) {
       print "<TD><SPAN STYLE=\"cursor: pointer; font-size: 10pt; color: navy ;\"
              onclick=\"reload_filters_contracts('$cgi_module_name',id_filter_currency.value,id_filter_curr_reference.value,'$pv{rand_id}','$pv{action}','','','')\">&nbsp;&nbsp;обновить</SPAN>\n
              </TD></TR>" ;
       }

    print "</TABLE><BR>\n" ;
    }

sub print_js_block_common() {
    print "<SCRIPT LANGUAGE=\"JavaScript\">
function reload_filters(v_source_page,v_coin, v_curr_ref_coin, v_rand_id, v_action, v_user_name, v_cntrct_status, v_cntrct_cycles) {
         //alert(\"debug in JS function currency=\" + v_coin + \"&curr_reference=\" + v_curr_ref_coin + \"&rand_id=\" + v_rand_id + \"&action=\" + v_action + \"&user_name=\" + v_user_name + \"&cntrct_status=\" + v_cntrct_status + \"&cntrct_cycles=\" + v_cntrct_cycles) ;
         var url=\"https://zrt.ourorbits.ru/cgi/\" + v_source_page + \"?currency=\" + v_coin + \"&curr_reference=\" + v_curr_ref_coin + \"&rand_id=\" + v_rand_id + \"&action=\" + v_action + \"&user_name=\" + v_user_name + \"&cntrct_status=\" + v_cntrct_status + \"&cntrct_cycles=\" + v_cntrct_cycles ;
         //alert(url) ;
         window.location.href = url ;
         }

function reload_filters_contracts(v_source_page,v_coin, v_curr_ref_coin, v_rand_id, v_action, v_user_name, v_cntrct_status, v_cntrct_cycles, v_rep_mode) {
         //alert(\"debug in JS function currency=\" + v_coin + \"&curr_reference=\" + v_curr_ref_coin + \"&rand_id=\" + v_rand_id + \"&action=\" + v_action + \"&user_name=\" + v_user_name + \"&cntrct_status=\" + v_cntrct_status + \"&cntrct_cycles=\" + v_cntrct_cycles + \"&rep_mode=\" + v_rep_mode) ;
         var url=\"https://zrt.ourorbits.ru/cgi/\" + v_source_page + \"?currency=\" + v_coin + \"&curr_reference=\" + v_curr_ref_coin + \"&rand_id=\" + v_rand_id + \"&action=\" + v_action + \"&user_name=\" + v_user_name + \"&cntrct_status=\" + v_cntrct_status + \"&cntrct_cycles=\" + v_cntrct_cycles + \"&rep_mode=\" + v_rep_mode ;
         //alert(url) ;
         window.location.href = url ;
         }

function reload_filters_monitoring(v_source_page,v_coin, v_curr_ref_coin, v_rand_id, v_action, v_mon_areal, v_mon_tf, v_mon_events) {
         //alert(\"debug in JS function currency=\" + v_coin + \"&curr_reference=\" + v_curr_ref_coin + \"&rand_id=\" + v_rand_id + \"&action=\" + v_action + \"&mon_areal=\" + v_mon_areal + \"&mon_tf=\" + v_mon_tf + \"&mon_events=\" + v_mon_events) ;
         var url=\"https://zrt.ourorbits.ru/cgi/\" + v_source_page + \"?currency=\" + v_coin + \"&curr_reference=\" + v_curr_ref_coin + \"&rand_id=\" + v_rand_id + \"&action=\" + v_action + \"&mon_areal=\" + v_mon_areal + \"&mon_tf=\" + v_mon_tf + \"&mon_events=\" + v_mon_events ;
         //alert(url) ;
         window.location.href = url ;
         }

function reload_filters_TF_compare(v_source_page,v_coin, v_curr_ref_coin, v_rsi_mode, v_macd_mode) {
         //alert(\"debug in JS function currency=\" + v_coin + \"&curr_reference=\" + v_curr_ref_coin + \"&rsi_mode=\" + v_rsi_mode + \"&macd_mode=\" + v_macd_mode) ;
         var url=\"https://zrt.ourorbits.ru/cgi/\" + v_source_page + \"?currency=\" + v_coin + \"&curr_reference=\" + v_curr_ref_coin + \"&rsi_mode=\" + v_rsi_mode + \"&macd_mode=\" + v_macd_mode ;
         //alert(url) ;
         window.location.href = url ;
         }


function reload_filters_rtrsp_RSI_MACD(v_source_page, v_report_type, v_coin, v_curr_ref_coin, v_is_include_rsi, v_start_date, v_stop_date, v_tf_rsi, v_tf_macd, v_macd_ind_type, v_macd_ind_sub_type, v_is_lncrs_1h1h, v_is_lnvct_1h1h, v_is_gsvct_1h1h, v_is_lncrs_1h4h, v_is_lnvct_1h4h, v_is_gsvct_1h4h, v_sort_field, v_sl_value) {
         //alert(\"debug in JS function currency=\" + v_coin + \"&curr_reference=\" + v_curr_ref_coin + \"&is_lncrs_1h1h=\" + v_is_lncrs_1h1h + \"&is_lnvct_1h1h=\" + v_is_lnvct_1h1h + \"&is_gsvct_1h1h=\" + v_is_gsvct_1h1h + \"&is_lncrs_1h4h=\" + v_is_lncrs_1h4h + \"&is_lnvct_1h4h=\" + v_is_lnvct_1h4h + \"&is_gsvct_1h4h=\" + v_is_gsvct_1h4h ) ;
         //var url=\"https://zrt.ourorbits.ru/cgi/\" + v_source_page + \"?report_type=\" + v_report_type + \"&currency=\" + v_coin + \"&curr_reference=\" + v_curr_ref_coin + \"&is_lncrs_1h1h=\" + v_is_lncrs_1h1h + \"&is_lnvct_1h1h=\" + v_is_lnvct_1h1h + \"&is_gsvct_1h1h=\" + v_is_gsvct_1h1h + \"&is_lncrs_1h4h=\" + v_is_lncrs_1h4h + \"&is_lnvct_1h4h=\" + v_is_lnvct_1h4h + \"&is_gsvct_1h4h=\" + v_is_gsvct_1h4h ;
         var url=\"https://zrt.ourorbits.ru/cgi/\" + v_source_page + \"?report_type=\" + v_report_type + \"&currency=\" + v_coin + \"&curr_reference=\" + v_curr_ref_coin + \"&is_include_rsi=\" + v_is_include_rsi + \"&start_date=\" + v_start_date + \"&stop_date=\" + v_stop_date + \"&tf_rsi=\" + v_tf_rsi + \"&tf_macd=\" + v_tf_macd + \"&macd_ind_type=\" + v_macd_ind_type + \"&macd_ind_sub_type=\" + v_macd_ind_sub_type + \"&is_lncrs_1h1h=\" + v_is_lncrs_1h1h + \"&is_lnvct_1h1h=\" + v_is_lnvct_1h1h + \"&is_gsvct_1h1h=\" + v_is_gsvct_1h1h + \"&is_lncrs_1h4h=\" + v_is_lncrs_1h4h + \"&is_lnvct_1h4h=\" + v_is_lnvct_1h4h + \"&is_gsvct_1h4h=\" + v_is_gsvct_1h4h + \"&sort_field=\" + v_sort_field + \"&sl_value=\" + v_sl_value ;
         //alert(url) ;
         window.location.href = url ;
         }

function reload_filters_rtrsp_RSI_MACD_EMA(v_source_page, v_report_type, v_coin, v_curr_ref_coin, v_is_include_rsi, v_start_date, v_stop_date, v_tf_rsi, v_tf_macd, v_macd_ind_type, v_macd_ind_sub_type, v_is_lncrs_1h1h, v_is_lnvct_1h1h, v_is_gsvct_1h1h, v_is_lncrs_1h4h, v_is_lnvct_1h4h, v_is_gsvct_1h4h, v_sort_field, v_sl_value, v_is_include_ema, v_is_include_stema) {
         //alert(\"debug in JS function currency=\" + v_coin + \"&curr_reference=\" + v_curr_ref_coin + \"&is_lncrs_1h1h=\" + v_is_lncrs_1h1h + \"&is_lnvct_1h1h=\" + v_is_lnvct_1h1h + \"&is_gsvct_1h1h=\" + v_is_gsvct_1h1h + \"&is_lncrs_1h4h=\" + v_is_lncrs_1h4h + \"&is_lnvct_1h4h=\" + v_is_lnvct_1h4h + \"&is_gsvct_1h4h=\" + v_is_gsvct_1h4h ) ;
         //var url=\"https://zrt.ourorbits.ru/cgi/\" + v_source_page + \"?report_type=\" + v_report_type + \"&currency=\" + v_coin + \"&curr_reference=\" + v_curr_ref_coin + \"&is_lncrs_1h1h=\" + v_is_lncrs_1h1h + \"&is_lnvct_1h1h=\" + v_is_lnvct_1h1h + \"&is_gsvct_1h1h=\" + v_is_gsvct_1h1h + \"&is_lncrs_1h4h=\" + v_is_lncrs_1h4h + \"&is_lnvct_1h4h=\" + v_is_lnvct_1h4h + \"&is_gsvct_1h4h=\" + v_is_gsvct_1h4h ;
         var url=\"https://zrt.ourorbits.ru/cgi/\" + v_source_page + \"?report_type=\" + v_report_type + \"&currency=\" + v_coin + \"&curr_reference=\" + v_curr_ref_coin + \"&is_include_rsi=\" + v_is_include_rsi + \"&start_date=\" + v_start_date + \"&stop_date=\" + v_stop_date + \"&tf_rsi=\" + v_tf_rsi + \"&tf_macd=\" + v_tf_macd + \"&macd_ind_type=\" + v_macd_ind_type + \"&macd_ind_sub_type=\" + v_macd_ind_sub_type + \"&is_lncrs_1h1h=\" + v_is_lncrs_1h1h + \"&is_lnvct_1h1h=\" + v_is_lnvct_1h1h + \"&is_gsvct_1h1h=\" + v_is_gsvct_1h1h + \"&is_lncrs_1h4h=\" + v_is_lncrs_1h4h + \"&is_lnvct_1h4h=\" + v_is_lnvct_1h4h + \"&is_gsvct_1h4h=\" + v_is_gsvct_1h4h + \"&sort_field=\" + v_sort_field + \"&sl_value=\" + v_sl_value + \"&is_include_ema=\" + v_is_include_ema + \"&is_include_stema=\" + v_is_include_stema ;
         //alert(url) ;
         window.location.href = url ;
         }


function reload_filters_analyze_symmetric_macd(v_source_page,v_coin, v_curr_ref_coin, v_rep_mode, v_event_name, v_event_tf) {
         //alert(\"debug in JS function currency=\" + v_coin + \"&curr_reference=\" + v_curr_ref_coin + \"&rand_id=\" + v_rand_id + \"&action=\" + v_action + \"&user_name=\" + v_user_name + \"&cntrct_status=\" + v_cntrct_status + \"&cntrct_cycles=\" + v_cntrct_cycles) ;
         var url=\"https://zrt.ourorbits.ru/cgi/\" + v_source_page + \"?currency=\" + v_coin + \"&curr_reference=\" + v_curr_ref_coin + \"&rep_mode=\" + v_rep_mode + \"&event_name=\" + v_event_name + \"&event_tf=\" + v_event_tf ;
         //alert(url) ;
         window.location.href = url ;
         }


</SCRIPT>\n" ;
   }

1

