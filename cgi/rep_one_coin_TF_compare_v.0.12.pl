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

# параметры по умолчанию

$pv{currency} = "yes" ;
$pv{curr_reference} = "yes" ;

# - вытащить из URL запроса значения уточняющих полей
&get_forms_param() ;

$CURR_YEAR = `date +%Y` ; $CURR_YEAR =~ s/[\r\n]+//g ;
$count_rows = 0 ;
$window_days = 0 ; $window_days = $pv{window_days} - 1 ;
$request = " " ;

if ( $curr_ref_coin eq "USDT") { $curr_ref_coin_gecko = "USD" ; }
my $half_min_week_volatility = 5 ;

print "Content-Type: text/html\n\n" ;


system("cat $COMM_PAR_BASE_WEB_PATH/includes/header1_1_cgi.shtml") ;
print "REP ZRT КрАгрАн БЕССТ" ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/header1_2_cgi.shtml") ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/main_menu.shtml") ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/header2_1_cgi.shtml") ;

print_js_block_common() ;
print_js_block_trading() ;

print_main_page_title("Отчёты и аналитика", "Применимость графиков и индикаторов разных ТФ пары $pv{currency}/$pv{curr_reference} к разным циклам волатильности") ;
print_tools_coin_navigation(7) ;
print "<!-- таблица первого уровня вкладок -->
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD><BR>" ;

print_reports_coin_navigation(2,"rep_one_coin_TF_compare.cgi","Применимость графиков и индикаторов<BR> разных ТФ к разным циклам волатильности") ;
print "<!-- таблица второго уровня вкладок -->
<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\"><TR><TD>&nbsp;<BR>" ;

$col01_count_prds = 5 ;
$col02_count_prds = 15 ;
$col03_count_prds = 70 ;
$col04_count_prds = 350 ;
print_coin_links_map("rep_one_coin_TF_compare.cgi") ;

print "<BR><TABLE BORDER=\"1\" STYLE=\"width: 100%;\">" ;

print "<TR><TD COLSPAN=\"8\">
<P STYLE=\"font-size: 8pt;\">Краткое описание отчёта:
<BR>Аналитическая форма предназначена для визуальной оценки графиков разных таймфрэймов (ТФ) для информативного отображения данных того или иного
<BR>цикла волатильности монеты. Четыре колонки отчёта отражают четыре промежутка времени, подходящих для визуального анализа каждого и з циклов
<BR>Это внутридневной цикл ($col01_count_prds дней), дневной цикл ($col02_count_prds дней), недельный цикл ($col03_count_prds дней), месячный цикл ($col04_count_prds дней). Уже известно и проверено нами, что разные
<BR>графики отдают наиболее информативные сигналы на разных ТФ в качестве первичной информации, однако для разных монет эти значения  могут отличаться.
<BR>Для визуального анализа применимости графиков разных ТФ по конкретной монеты и сделан настоящий отчёт
<BR>&nbsp;</P></TD></TR>" ;

print "<TR>
<TD CLASS=\"td_head\" COLSPAN=\"2\">Дней: $col01_count_prds, целевой цикл: несколькочасовой</TD>
<TD CLASS=\"td_head\" COLSPAN=\"2\">Дней: $col02_count_prds, целевой цикл: несколькодневный</TD>
<TD CLASS=\"td_head\" COLSPAN=\"2\">Дней: $col03_count_prds, целевой цикл: нескольконедельный</TD>
<TD CLASS=\"td_head\" COLSPAN=\"2\">Дней: $col04_count_prds, целевой цикл: несколькомесячный</TD></TR>" ;

print "</TR><TR>" ; print_TD_graph_blck("1D", "1M", $col01_count_prds) ; print_TD_graph_blck("1D", "1M", $col02_count_prds) ; print_TD_graph_blck("1D", "1M", $col03_count_prds) ; print_TD_graph_blck("1D", "1M", $col04_count_prds) ;
print "</TR><TR>" ; print_TD_graph_blck("1D", "3M", $col01_count_prds) ; print_TD_graph_blck("1D", "3M", $col02_count_prds) ; print_TD_graph_blck("1D", "3M", $col03_count_prds) ; print_TD_graph_blck("1D", "3M", $col04_count_prds) ;
print "</TR><TR>" ; print_TD_graph_blck("1D","5M", $col01_count_prds) ; print_TD_graph_blck("1D","5M", $col02_count_prds) ; print_TD_graph_blck("1D","5M", $col03_count_prds) ; print_TD_graph_blck("1D","5M", $col04_count_prds) ;
print "</TR><TR>" ; print_TD_graph_blck("1D","10M", $col01_count_prds) ; print_TD_graph_blck("1D","10M", $col02_count_prds) ; print_TD_graph_blck("1D","10M", $col03_count_prds) ; print_TD_graph_blck("1D","10M", $col04_count_prds) ;
print "</TR><TR>" ; print_TD_graph_blck("1D","15M", $col01_count_prds) ; print_TD_graph_blck("1D","15M", $col02_count_prds) ; print_TD_graph_blck("1D","15M", $col03_count_prds) ; print_TD_graph_blck("1D","15M", $col04_count_prds) ;
print "</TR><TR>" ; print_TD_graph_blck("1D","30M", $col01_count_prds) ; print_TD_graph_blck("1D","30M", $col02_count_prds) ; print_TD_graph_blck("1D","30M", $col03_count_prds) ; print_TD_graph_blck("1D","30M", $col04_count_prds) ;
print "</TR><TR>" ; print_TD_graph_blck("1D","1H", $col01_count_prds) ; print_TD_graph_blck("1D","1H", $col02_count_prds) ; print_TD_graph_blck("1D","1H", $col03_count_prds) ; print_TD_graph_blck("1D","1H", $col04_count_prds) ;
print "</TR><TR>" ; print_TD_graph_blck("1D","2H", $col01_count_prds) ; print_TD_graph_blck("1D","2H", $col02_count_prds) ; print_TD_graph_blck("1D","2H", $col03_count_prds) ; print_TD_graph_blck("1D","2H", $col04_count_prds) ;
print "</TR><TR>" ; print_TD_graph_blck("1D","3H", $col01_count_prds) ; print_TD_graph_blck("1D","3H", $col02_count_prds) ; print_TD_graph_blck("1D","3H", $col03_count_prds) ; print_TD_graph_blck("1D","3H", $col04_count_prds) ;
print "</TR><TR>" ; print_TD_graph_blck("1D","4H", $col01_count_prds) ; print_TD_graph_blck("1D","4H", $col02_count_prds) ; print_TD_graph_blck("1D","4H", $col03_count_prds) ; print_TD_graph_blck("1D","4H", $col04_count_prds) ;
print "</TR><TR>" ; print_TD_graph_blck("1D","8H", $col01_count_prds) ; print_TD_graph_blck("1D","8H", $col02_count_prds) ; print_TD_graph_blck("1D","8H", $col03_count_prds) ; print_TD_graph_blck("1D","8H", $col04_count_prds) ;
print "</TR><TR>" ; print_TD_graph_blck("1D","12H", $col01_count_prds) ; print_TD_graph_blck("1D","12H", $col02_count_prds) ; print_TD_graph_blck("1D","12H", $col03_count_prds) ; print_TD_graph_blck("1D","12H", $col04_count_prds) ;
print "</TR><TR>" ; print_TD_graph_blck("1D","1D", $col01_count_prds) ; print_TD_graph_blck("1D","1D", $col02_count_prds) ; print_TD_graph_blck("1D","1D", $col03_count_prds) ; print_TD_graph_blck("1D","1D", $col04_count_prds) ;
print "</TR><TR>" ; print_TD_graph_blck("1D","2D", $col01_count_prds) ; print_TD_graph_blck("1D","2D", $col02_count_prds) ; print_TD_graph_blck("1D","2D", $col03_count_prds) ; print_TD_graph_blck("1D","2D", $col04_count_prds) ;
print "</TR><TR>" ; print_TD_graph_blck("1D","4D", $col01_count_prds) ; print_TD_graph_blck("1D","4D", $col02_count_prds) ; print_TD_graph_blck("1D","4D", $col03_count_prds) ; print_TD_graph_blck("1D","4D", $col04_count_prds) ;
print "</TR><TR>" ; print_TD_graph_blck("1D","1W", $col01_count_prds) ; print_TD_graph_blck("1D","1W", $col02_count_prds) ; print_TD_graph_blck("1D","1W", $col03_count_prds) ; print_TD_graph_blck("1D","1W", $col04_count_prds) ;
print "</TR><TR>" ; print_TD_graph_blck("1D","4W", $col01_count_prds) ; print_TD_graph_blck("1D","4W", $col02_count_prds) ; print_TD_graph_blck("1D","4W", $col03_count_prds) ; print_TD_graph_blck("1D","4W", $col04_count_prds) ;

print "</TR>" ;
print "</TABLE>" ;
print "<!-- конец таблицы второго уровня вкладок --></TD></TR></TABLE>\n" ;
print "<!-- конец таблицы первого уровня вкладок --></TD></TR></TABLE>\n" ;
print_foother1() ;

sub print_TD_graph_blck($$$) {
    $col_tf = $_[0] ;
    $curr_tf = $_[1] ;
    $col_prds = $_[2] ;

#    $pv{ema_mode} = 1 ;
#    $pv{macd_mode} = 1 ;
#    $pv{rsi_mode} = 1 ;
    $pv{vlt_mode} = 0 ;

    $pv{count_prds} = recode_tf_periods($col_tf, $curr_tf, $col_prds) ;
#$pv{macd_mode} = 1 ;
#$pv{rsi_mode} = 1 ;
    $pv{time_frame} = $curr_tf ; $pv{env_prct} = 5 ; $pv{ema_mode} = 1 ; $pv{macd_tf} =  $pv{time_frame} ; $pv{macd_mult} = "x1" ; $pv{rsi_tf} =  $pv{time_frame} ;
    print "\n<TD COLSPAN=\"2\" STYLE=\"vertical-align: top;\"><HR>$pv{currency}/$pv{curr_reference} <SPAN STYLE=\"font-size: 12pt; color: green;\">ТФ$curr_tf</SPAN> глубина $pv{count_prds} периодов<BR><HR>" ;
    my $v_rand = rand() ; $v_rand =~ s/\.//g;
    print "<DIV ID=\"id_trading_block_$pv{currency}"."_$pv{curr_reference}"."_$v_rand\">" ;
    print_coin_graphs_block("id_trading_block_$pv{currency}"."_$pv{curr_reference}"."_$v_rand","$pv{currency}","$pv{curr_reference}","1","$pv{time_frame}","$pv{count_prds}","$pv{offset_prds}","$pv{env_prct}","$pv{ema_mode}","$pv{time_frame}","$pv{macd_mode}","$pv{macd_tf}","$pv{macd_mult}","$pv{rsi_mode}","$pv{rsi_tf}","$pv{vlt_mode}","$pv{vlt_tf}","0","$pv{time_frame}","half","no_disabled","per_count","","") ;

    print "</DIV>" ;
    print "</TD>" ;
    }

