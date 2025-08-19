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

# - вытащить из URL запроса значения уточняющих полей
&get_forms_param() ;

print "Content-Type: text/html\n\n" ;

system("cat $COMM_PAR_BASE_WEB_PATH/includes/header1_1_cgi.shtml") ;
print "REP ZRT КрАгрАн БЕССТ" ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/header1_2_cgi.shtml") ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/main_menu.shtml") ;
system("cat $COMM_PAR_BASE_WEB_PATH/includes/header2_1_cgi.shtml") ;

print_js_block_trading() ;
print_main_page_title("Отчёты и аналитика: ", "Состояние рынка") ;

#print "<H1 STYLE=\"text-align: left;\">Отчёты и аналитика: <SPAN STYLE=\"font-size: 14pt; color: green;\">Состояние рынка</SPAN></H1>" ;

#print_coin_links_map("rep_market_status.cgi") ;
#print_reports_coin_navigation(2,"rep_market_status.cgi","Состояние<BR>рынка") ;
print_tools_coin_navigation(5) ;


# это внешняя оформительская таблица
print "<TABLE BORDER=\"0\" STYLE=\"width: 100%; border: 2pt navy; border-style: none solid solid solid;\">" ;
#print "<TR><TD STYLE=\"vertical-align: top;\">" ;

# это вёрсточная таблица
#print "<TABLE BORDER=\"0\" STYLE=\"width: 100%;\">" ;
#print "<TR><TD COLSPAN=\"3\" STYLE=\"vertical-align: top; height: 154pt; overflow: hidden;\">" ;

# height: 153pt; overflow-y: clip;">
#DIV.aa_tradingview-widget-container { width: 120pt; height: 100pt; }
# display: flex; justify-content: center; align-items: center;

print "
<STYLE>
TD.head { font-size: 12pt; background: navy; color: white; }
TD.tv_ind {vertical-align: middle; text-align: center; height: 153pt; overflow: hidden; }
DIV.tradingview-widget-container { width: 109pt; height: 153pt; overflow: hidden; }
</STYLE>" ;

# это первая строка индикаторов
print "<TR><TD>" ;
# во второй строке - организационная таблица
print "<TABLE STYLE=\"width: 100%;\">
<TR><TD CLASS=\"head\">Актуальность агрегируемых данных</TD>
    <TD CLASS=\"head\">Доминация BTC<BR>\% капитализации BTC<BR>от всей крипты</TD>
    <TD CLASS=\"head\">Капитализация крипты<BR>всей (TOTAL1)</TD>
    <TD CLASS=\"head\">Индекс альтсезона<BR>(\% капитализации крипты<BR>без BTC и stablecoins)</TD>
    <TD CLASS=\"head\">Капитализация стэйблов<BR>(\% капитализации известных<BR>стэйблов от всей крипты)</TD>
    </TR>
    <TR><TD>" ;

$request = "select 'crcomp_1m', count(*) as count_records, to_char(min(timestamp_point + INTERVAL '3 hour'), 'YYYY-MM-DD HH24:MI') as min_date,
       to_char(max(timestamp_point + INTERVAL '3 hour'), 'YYYY-MM-DD HH24:MI') as max_date
       from crcomp_pair_ohlc_1m_history
union all
select 'crcomp_1h', count(*) as count_records, to_char(min(timestamp_point + INTERVAL '3 hour'), 'YYYY-MM-DD HH24:MI') as min_date, to_char(max(timestamp_point + INTERVAL '3 hour'), 'YYYY-MM-DD HH24:MI') as max_date
       from crcomp_pair_ohlc_1h_history
union all
select 'crcomp_1d', count(*) as count_records, to_char(min(timestamp_point + INTERVAL '3 hour'), 'YYYY-MM-DD HH24:MI') as min_date, to_char(max(timestamp_point + INTERVAL '3 hour'), 'YYYY-MM-DD HH24:MI') as max_date
       from crcomp_pair_ohlc_1d_history
union all
select 'gecko_coins_hist', count(*) as count_records, to_char(min(timestamp_point + INTERVAL '3 hour'), 'YYYY-MM-DD HH24:MI') as min_date, to_char(max(timestamp_point + INTERVAL '3 hour'), 'YYYY-MM-DD HH24:MI') as max_date
       from gecko_coins_history_data
union all
select 'gecko_ohlc_1m', count(*) as count_records, to_char(min(datetime_point + INTERVAL '3 hour'), 'YYYY-MM-DD HH24:MI') as min_date, to_char(max(datetime_point + INTERVAL '3 hour'), 'YYYY-MM-DD HH24:MI') as max_date
       from gecko_minutes_ohlc_history" ;
my $dbh_h = DBI->connect("dbi:Pg:dbname=$COMM_PAR_PGSQL_DB_NAME;host=$COMM_PAR_PGSQL_HOST", 'crypta', 'pg_password_value' ) ;
my $sth_h = $dbh_h->prepare($request) ; $sth_h->execute(); $count_rows = 0 ;

print "<TABLE BORDER=\"1\"><TR><TD STYLE=\"font-size: 8pt; text-align: center;\">Таблица</TD><TD STYLE=\"font-size: 8pt; text-align: center;\">Кол-во<BR>записей</TD><TD STYLE=\"font-size: 8pt; text-align: center;\">Первая</TD><TD STYLE=\"font-size: 8pt; text-align: center;\">Последняя</TD></TR>" ;
while (my ($table_name, $count_record, $min_date, $max_date) = $sth_h->fetchrow_array() ) {
      $min_date =~ s/\s/&nbsp;/g ; $max_date =~ s/\s/&nbsp;/g ; $count_record = show_razryads($count_record) ;
      print "<TR><TD STYLE=\"font-size: 8pt;\">$table_name</TD>
                 <TD STYLE=\"font-size: 8pt; text-align: right;\">$count_record</TD>
                 <TD STYLE=\"font-size: 8pt;\">$min_date</TD>
                 <TD STYLE=\"font-size: 8pt;\">$max_date</TD></TR>" ; }
print "</TABLE>" ;

print "</TD><TD>
<A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_coin_domination.cgi?currency=BTC&curr_reference=USD&count_prds=720&graph_type=BTC_DOM&output_type=graph&brush_size=4&x_size=1400&y_size=640\" TARGET=\"_blank\">
                <IMG STYLE=\"width: 210pt; height: 97pt;\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_coin_domination.cgi?currency=BTC&curr_reference=USD&count_prds=720&graph_type=BTC_DOM&output_type=graph&brush_size=4&x_size=570&y_size=320\"></A>
       </TD><TD>
<A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_coin_domination.cgi?currency=ALL&curr_reference=USD&count_prds=720&graph_type=ALL_CAP&output_type=graph&brush_size=4&x_size=1400&y_size=640\" TARGET=\"_blank\">
                <IMG STYLE=\"width: 210pt; height: 97pt;\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_coin_domination.cgi?currency=ALL&curr_reference=USD&count_prds=720&graph_type=ALL_CAP&output_type=graph&brush_size=4&x_size=570&y_size=320\"></A>
       </TD><TD>
<A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_coin_domination.cgi?currency=ALT_USDT&curr_reference=USD&count_prds=720&graph_type=ALT_DOM&output_type=graph&brush_size=4&x_size=1400&y_size=640\" TARGET=\"_blank\">
                <IMG STYLE=\"width: 210pt; height: 97pt;\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_coin_domination.cgi?currency=ALT_USDT&curr_reference=USD&count_prds=720&graph_type=ALT_DOM&output_type=graph&brush_size=4&x_size=570&y_size=320\"></A>
       </TD><TD>
<A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_coin_domination.cgi?currency=BTC&curr_reference=USD&count_prds=720&graph_type=STABLE_DOM&output_type=graph&brush_size=4&x_size=1400&y_size=640\" TARGET=\"_blank\">
                <IMG STYLE=\"width: 210pt; height: 97pt;\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_coin_domination.cgi?currency=BTC&curr_reference=USD&count_prds=720&graph_type=STABLE_DOM&output_type=graph&brush_size=4&x_size=570&y_size=320\"></A>
</TD></TR></TABLE></TD></TR>" ;

# это вторая строка индикаторов
print "<TR><TD><TABLE STYLE=\"width: 100%;\"><TR>
       <TD STYLE=\"width: 50%;\" CLASS=\"head\" STYLE=\"vertical-align: top;\">Общая динамика цен главмонеты биткоина</TD>
       <TD STYLE=\"width: 50%;\" CLASS=\"head\" STYLE=\"vertical-align: top;\">Динамика референсных: Эфир и т.д.</TD>
       </TR>" ;

# это третья строка индикаторов
print "<TR><TD STYLE=\"vertical-align: top; width: 50%;\">" ;
$pv{currency} = "BTC" ;
$pv{curr_reference} = "USDT" ;
$pv{time_frame} = "1H" ;
$pv{count_prds} = 960 ;
$pv{env_prct} = 2 ;
$pv{macd_mult} = "x1" ;
$pv{macd_mode} = "0" ;
$pv{rsi_mode} = "0" ;
$pv{vlt_mode} = "0" ;
#$pv{isvw_big_price_EMA} = "yes" ;
#$pv{isvw_MACD} = "yes" ;
#$pv{isvw_RSI} = "yes" ;

print "<DIV ID=\"id_trading_block_$pv{currency}"."_$pv{curr_reference}\">" ;
print_coin_graphs_block("id_trading_block_$pv{currency}"."_$pv{curr_reference}","$pv{currency}","$pv{curr_reference}","1","$pv{time_frame}","$pv{count_prds}","$pv{offset_prds}","$pv{env_prct}","$pv{ema_mode}","$pv{time_frame}","$pv{macd_mode}","$pv{macd_tf}","$pv{macd_mult}","$pv{rsi_mode}","$pv{rsi_tf}","$pv{vlt_mode}","$pv{vlt_tf}",1,"$pv{time_frame}","middle","no_disabled","per_count","","") ;
print "</DIV>" ;

if ("$pv{isvw_VLT}" eq "yes") { print "<BR><A HREF=\"$COMM_PAR_BASE_HREF/cgi/_graph_VLT_WNDW.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}&time_frame=$pv{time_frame}&count_prds=$pv{count_prds}&vlt_wnd_01=42&output_type=graph&brush_size=4&x_size=1400&y_size=640\" TARGET=\"_blank\">
                                              <IMG CLASS=\"rsi_graph\" SRC=\"$COMM_PAR_BASE_HREF/cgi/_graph_VLT_WNDW.cgi?currency=$pv{currency}&curr_reference=$pv{curr_reference}&time_frame=$pv{time_frame}&count_prds=$pv{count_prds}&vlt_wnd_01=42&output_type=graph&brush_size=4&x_size=1440&y_size=240\"></A>" ; }
else { print "&nbsp;" ; }

print "</TD><TD STYLE=\"vertical-align: top; width: 50%;\">" ;

$pv{currency} = "ETH" ;
$pv{curr_reference} = "USDT" ;

print "<DIV ID=\"id_trading_block_$pv{currency}"."_$pv{curr_reference}\">" ;
print_coin_graphs_block("id_trading_block_$pv{currency}"."_$pv{curr_reference}","$pv{currency}","$pv{curr_reference}","1","$pv{time_frame}","$pv{count_prds}","$pv{offset_prds}","$pv{env_prct}","$pv{ema_mode}","$pv{time_frame}","$pv{macd_mode}","$pv{macd_tf}","$pv{macd_mult}","$pv{rsi_mode}","$pv{rsi_tf}","$pv{vlt_mode}","$pv{vlt_tf}",1,"$pv{time_frame}","middle","no_disabled","per_count","","") ;
print "</DIV></TD></TR></TABLE></TD></TR>" ;

# это четвёртая строка индикаторов

print '<TR><TD><TABLE STYLE="width: 100%;"><TR><TD CLASS="head">Индекс BTC</TD><TD CLASS="head">Индекс USDT</TD><TD CLASS="head">Индекс страха и жадности</TD><TD CLASS="head">Индекс доллара</TD><TD CLASS="head">Индекс S&P500</TD></TR>

<TR><TD></TD><TD></TD><TD>похоже TV врёт
<BR><A HREF="https://bitstat.top/fear_greed.php" TARGET="_blank">Детально на bitstat.top</A>
<BR><A HREF="https://www.coinglass.com/ru/pro/i/FearGreedIndex" TARGET="_blank">Детально на coinglass.com</A>
</TD><TD></TD><TD></TD></TR>

<TR><TD CLASS="tv_ind">
    <div class="tradingview-widget-container">
         <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-technical-analysis.js" async>
                 { "interval": "1D", "width": "100%", "height": "100%", "isTransparent": true, "symbol": "CRYPTO:BTCUSD", "showIntervalTabs": false, "displayMode": "single", "locale": "ru", "colorTheme": "light" }
         </script>
    </div>
    </TD><TD CLASS="tv_ind">

    <div class="tradingview-widget-container">
         <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-technical-analysis.js" async>
                 { "interval": "1D", "width": "100%", "height": "100%", "isTransparent": true, "symbol": "CRYPTO:USDTUSD", "showIntervalTabs": false, "displayMode": "single", "locale": "ru", "colorTheme": "light" }
         </script>
    </div>
    </TD><TD CLASS="tv_ind">

    <div class="tradingview-widget-container">
         <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-technical-analysis.js" async>
                 { "interval": "1D", "width": "100%", "height": "100%", "isTransparent": true, "symbol": "KUCOIN:FEARUSDT", "showIntervalTabs": false, "displayMode": "single", "locale": "ru", "colorTheme": "light" }
         </script>
    </div>
    </TD><TD CLASS="tv_ind">

    <div class="tradingview-widget-container">
         <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-technical-analysis.js" async>
                 { "interval": "1D", "width": "100%", "height": "100%", "isTransparent": true, "symbol": "TVC:DXY", "showIntervalTabs": false, "displayMode": "single", "locale": "ru", "colorTheme": "light" }
         </script>
    </div>
    </TD><TD CLASS="tv_ind">

    <div class="tradingview-widget-container">
         <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-technical-analysis.js" async>
                 { "interval": "1D", "width": "100%", "height": "100%", "isTransparent": true, "symbol": "SP:SPX", "showIntervalTabs": false, "displayMode": "single", "locale": "ru", "colorTheme": "light" }
         </script>
    </div>
    </TD></TR></TABLE>
</TD></TR>' ;
# конец четвёртой строки индикаторов

# это пятая строка индикаторов
print "<TR><TD><BR>
<BR><A TARGET=\"_blank\" HREF=\"https://www.cftc.gov/dea/futures/deacmesf.htm\">Распределение ставок крупного и мелких игроков на чикагской бирже</A>
<BR><A TARGET=\"_blank\" HREF=\"https://www.coinglass.com/FundingRate\">Фандинговые (финансирования) ставки Coinglass</A>
<BR><A TARGET=\"_blank\" HREF=\"https://www.coinglass.com/LiquidationData\">Ликвидации Coinglass</A></TD></TR>" ;
print "</TD></TR>" ;

print "</TABLE>" ;

print_foother1() ;
