
--DROP TABLE crcomp_pair_ohlc_1d_history_X1_btc_desc ;
CREATE TABLE IF NOT EXISTS public.crcomp_pair_ohlc_1d_history_X1_btc_desc
(
    currency character varying(100),
    reference_currency character varying(100),
    timestamp_point timestamp without time zone,
    price_open numeric(42,21),
    price_high numeric(42,21),
        price_low numeric(42,21),
    price_close numeric(42,21),
    volume_from numeric(42,21),
    volume_to numeric(42,21),
    change_ts timestamp without time zone,
        PRIMARY KEY (timestamp_point, currency, reference_currency)
) ;

insert into crcomp_pair_ohlc_1d_history_X1_btc_desc (
select currency, reference_currency, timestamp_point, price_open, price_high, price_low, price_close, volume_from,
       volume_to, change_ts
           from ( select ROW_NUMBER() OVER (partition by currency, reference_currency, timestamp_point
                                                                                ORDER BY change_ts DESC) sz_ranc, *
                         from crcomp_pair_ohlc_1d_history_20240807_1820_multi WHERE currency = 'BTC' and reference_currency = 'USDT') a2
           where sz_ranc = 1
       order by currency, reference_currency, timestamp_point ASC) ;
    
--DROP TABLE public.crcomp_pair_ohlc_1d_history_X1_btc_asc
CREATE TABLE IF NOT EXISTS public.crcomp_pair_ohlc_1d_history_X1_btc_asc
(
    currency character varying(100),
    reference_currency character varying(100),
    timestamp_point timestamp without time zone,
    price_open numeric(42,21),
    price_high numeric(42,21),
        price_low numeric(42,21),
    price_close numeric(42,21),
    volume_from numeric(42,21),
    volume_to numeric(42,21),
    change_ts timestamp without time zone,
        PRIMARY KEY (timestamp_point, currency, reference_currency)
) ;

insert into crcomp_pair_ohlc_1d_history_X1_btc_asc (
select currency, reference_currency, timestamp_point, price_open, price_high, price_low, price_close, volume_from,
       volume_to, change_ts
           from ( select ROW_NUMBER() OVER (partition by currency, reference_currency, timestamp_point
                                                                                ORDER BY change_ts ASC) sz_ranc, *
                         from crcomp_pair_ohlc_1d_history_20240807_1820_multi WHERE currency = 'BTC' and reference_currency = 'USDT') a2
           where sz_ranc = 1
       order by currency, reference_currency, timestamp_point ASC) ;

select count(*) from crcomp_pair_ohlc_1d_history_X1_btc_desc ; --2651
select count(*) from crcomp_pair_ohlc_1d_history_X1_btc_asc ; --2651

-- показать изменённые данные как разницу между первой и последней версией данных в мультитаблице
(select * from (select * from crcomp_pair_ohlc_1d_history_X1_btc_desc
except
select * from crcomp_pair_ohlc_1d_history_X1_btc_asc) aa order by timestamp_point)
-- и попробовать посмотреть разницу с существующими данными
except
(select * from crcomp_pair_ohlc_1d_history 
WHERE timestamp_point >= TO_TIMESTAMP('2023-06-08 00:00:00','YYYY-MMM-DD HH24:MI:SS')
and timestamp_point <= TO_TIMESTAMP('2024-04-14 00:00:00','YYYY-MMM-DD HH24:MI:SS')
AND currency = 'BTC' and reference_currency = 'USDT') ;

-- удалить предыдущие данные, иначе на уникальном ключе не зальётся
--delete from crcomp_pair_ohlc_1d_history 
WHERE timestamp_point >= TO_TIMESTAMP('2023-06-08 00:00:00','YYYY-MMM-DD HH24:MI:SS')
and timestamp_point <= TO_TIMESTAMP('2024-04-14 00:00:00','YYYY-MMM-DD HH24:MI:SS')
AND currency = 'BTC' and reference_currency = 'USDT'

-- залить корректные данные
--insert into crcomp_pair_ohlc_1d_history select * from (select * from crcomp_pair_ohlc_1d_history_X1_btc_asc
except
select * from crcomp_pair_ohlc_1d_history_X1_btc_desc) aa order by timestamp_point ;

-- разница для 1D BTC/USDT составила 311 записей

-- ###############################################################################################################################################
-- то же самое по всем монетам таблицы 1D
-- ###############################################################################################################################################

--DROP TABLE crcomp_pair_ohlc_1d_history_X1_desc ;
CREATE TABLE IF NOT EXISTS public.crcomp_pair_ohlc_1d_history_X1_desc
(
    currency character varying(100),
    reference_currency character varying(100),
    timestamp_point timestamp without time zone,
    price_open numeric(42,21),
    price_high numeric(42,21),
        price_low numeric(42,21),
    price_close numeric(42,21),
    volume_from numeric(42,21),
    volume_to numeric(42,21),
    change_ts timestamp without time zone,
        PRIMARY KEY (timestamp_point, currency, reference_currency)
) ;

insert into crcomp_pair_ohlc_1d_history_X1_desc (
select currency, reference_currency, timestamp_point, price_open, price_high, price_low, price_close, volume_from,
       volume_to, change_ts
           from ( select ROW_NUMBER() OVER (partition by currency, reference_currency, timestamp_point
                                                                                ORDER BY change_ts DESC) sz_ranc, *
                         from crcomp_pair_ohlc_1d_history_20240807_1820_multi) a2
           where sz_ranc = 1
       order by currency, reference_currency, timestamp_point ASC) ;
    
--DROP TABLE public.crcomp_pair_ohlc_1d_history_X1_asc
CREATE TABLE IF NOT EXISTS public.crcomp_pair_ohlc_1d_history_X1_asc
(
    currency character varying(100),
    reference_currency character varying(100),
    timestamp_point timestamp without time zone,
    price_open numeric(42,21),
    price_high numeric(42,21),
        price_low numeric(42,21),
    price_close numeric(42,21),
    volume_from numeric(42,21),
    volume_to numeric(42,21),
    change_ts timestamp without time zone,
        PRIMARY KEY (timestamp_point, currency, reference_currency)
) ;

insert into crcomp_pair_ohlc_1d_history_X1_asc (
select currency, reference_currency, timestamp_point, price_open, price_high, price_low, price_close, volume_from,
       volume_to, change_ts
           from ( select ROW_NUMBER() OVER (partition by currency, reference_currency, timestamp_point
                                                                                ORDER BY change_ts ASC) sz_ranc, *
                         from crcomp_pair_ohlc_1d_history_20240807_1820_multi) a2
           where sz_ranc = 1
       order by currency, reference_currency, timestamp_point ASC) ;

select count(*) from crcomp_pair_ohlc_1d_history_X1_desc ; --334253
select count(*) from crcomp_pair_ohlc_1d_history_X1_asc ; --334253

-- показать изменённые данные как разницу между первой и последней версией данных в мультитаблице
(select * from (select * from crcomp_pair_ohlc_1d_history_X1_desc
except
select * from crcomp_pair_ohlc_1d_history_X1_asc) aa order by timestamp_point)

--  !!! для 1D при сверке первых и последних версий записей по всем монетам мы получаем те же 311 записей, так что 1D обработан корректно

-- ###############################################################################################################################################
-- то же самое по всем монетам таблицы 1H
-- ###############################################################################################################################################

--DROP TABLE crcomp_pair_ohlc_1h_history_X1_desc ;
CREATE TABLE IF NOT EXISTS public.crcomp_pair_ohlc_1h_history_X1_desc
(
    currency character varying(100),
    reference_currency character varying(100),
    timestamp_point timestamp without time zone,
    price_open numeric(42,21),
    price_high numeric(42,21),
        price_low numeric(42,21),
    price_close numeric(42,21),
    volume_from numeric(42,21),
    volume_to numeric(42,21),
    change_ts timestamp without time zone,
        PRIMARY KEY (timestamp_point, currency, reference_currency)
) ;


insert into crcomp_pair_ohlc_1h_history_X1_desc (
select currency, reference_currency, timestamp_point, price_open, price_high, price_low, price_close, volume_from,
       volume_to, change_ts
           from ( select ROW_NUMBER() OVER (partition by currency, reference_currency, timestamp_point
                                                                                ORDER BY change_ts DESC) sz_ranc, *
                         from crcomp_pair_ohlc_1h_history_20240807_1820_multi) a2
           where sz_ranc = 1
       order by currency, reference_currency, timestamp_point ASC) ;

--DROP TABLE public.crcomp_pair_ohlc_1h_history_X1_asc
CREATE TABLE IF NOT EXISTS public.crcomp_pair_ohlc_1h_history_X1_asc
(
    currency character varying(100),
    reference_currency character varying(100),
    timestamp_point timestamp without time zone,
    price_open numeric(42,21),
    price_high numeric(42,21),
        price_low numeric(42,21),
    price_close numeric(42,21),
    volume_from numeric(42,21),
    volume_to numeric(42,21),
    change_ts timestamp without time zone,
        PRIMARY KEY (timestamp_point, currency, reference_currency)
) ;

insert into crcomp_pair_ohlc_1h_history_X1_asc (
select currency, reference_currency, timestamp_point, price_open, price_high, price_low, price_close, volume_from,
       volume_to, change_ts
           from ( select ROW_NUMBER() OVER (partition by currency, reference_currency, timestamp_point
                                                                                ORDER BY change_ts ASC) sz_ranc, *
                         from crcomp_pair_ohlc_1h_history_20240807_1820_multi) a2
           where sz_ranc = 1
       order by currency, reference_currency, timestamp_point ASC) ;

select count(*) from crcomp_pair_ohlc_1h_history_X1_desc ; --1627515
select count(*) from crcomp_pair_ohlc_1h_history_X1_asc ; --1627515

-- показать изменённые данные как разницу между первой и последней версией данных в мультитаблице
(select * from (select * from crcomp_pair_ohlc_1h_history_X1_asc
except
select * from crcomp_pair_ohlc_1h_history_X1_desc) aa order by timestamp_point desc)
-- c 2023-06-01 01:00:00 по 2023-06-01 01:00:00 57717 записей из 1627515
select currency, reference_currency, count(*) from (select * from (select * from crcomp_pair_ohlc_1h_history_X1_asc
except
select * from crcomp_pair_ohlc_1h_history_X1_desc) aa order by timestamp_point desc) aa 
group by currency, reference_currency
order by 3 desc ;
-- по 33 монетам более 1000 измененных записей
-- тут нужно решитьь, что с этим делать - вероятно посмотреть - растёт или нет по записям объём
-- в отличие от записей 1D возможна просто ситуация, когда записывались более старые и более новые версии, и более новые актуальнее


-- ###############################################################################################################################################
-- то же самое по всем монетам таблицы 1M
-- ###############################################################################################################################################


--DROP TABLE crcomp_pair_ohlc_1m_history_X1_desc ;
CREATE TABLE IF NOT EXISTS public.crcomp_pair_ohlc_1m_history_X1_desc
(
    currency character varying(100),
    reference_currency character varying(100),
    timestamp_point timestamp without time zone,
    price_open numeric(42,21),
    price_high numeric(42,21),
        price_low numeric(42,21),
    price_close numeric(42,21),
    volume_from numeric(42,21),
    volume_to numeric(42,21),
    change_ts timestamp without time zone,
        PRIMARY KEY (timestamp_point, currency, reference_currency)
) ;


insert into crcomp_pair_ohlc_1m_history_X1_desc (
select currency, reference_currency, timestamp_point, price_open, price_high, price_low, price_close, volume_from,
       volume_to, change_ts
           from ( select ROW_NUMBER() OVER (partition by currency, reference_currency, timestamp_point
                                                                                ORDER BY change_ts DESC) sz_ranc, *
                         from crcomp_pair_ohlc_1m_history_20240807_1820_multi) a2
           where sz_ranc = 1
       order by currency, reference_currency, timestamp_point ASC) ;

--DROP TABLE public.crcomp_pair_ohlc_1m_history_X1_asc
CREATE TABLE IF NOT EXISTS public.crcomp_pair_ohlc_1m_history_X1_asc
(
    currency character varying(100),
    reference_currency character varying(100),
    timestamp_point timestamp without time zone,
    price_open numeric(42,21),
    price_high numeric(42,21),
        price_low numeric(42,21),
    price_close numeric(42,21),
    volume_from numeric(42,21),
    volume_to numeric(42,21),
    change_ts timestamp without time zone,
        PRIMARY KEY (timestamp_point, currency, reference_currency)
) ;

insert into crcomp_pair_ohlc_1m_history_X1_asc (
select currency, reference_currency, timestamp_point, price_open, price_high, price_low, price_close, volume_from,
       volume_to, change_ts
           from ( select ROW_NUMBER() OVER (partition by currency, reference_currency, timestamp_point
                                                                                ORDER BY change_ts ASC) sz_ranc, *
                         from crcomp_pair_ohlc_1m_history_20240807_1820_multi) a2
           where sz_ranc = 1
       order by currency, reference_currency, timestamp_point ASC) ;

select count(*) from crcomp_pair_ohlc_1m_history_X1_desc ; --51 074 926
select count(*) from crcomp_pair_ohlc_1m_history_X1_asc ; --51 074 926

-- показать изменённые данные как разницу между первой и последней версией данных в мультитаблице
(select * from (select * from crcomp_pair_ohlc_1m_history_X1_asc
except
select * from crcomp_pair_ohlc_1m_history_X1_desc) aa order by timestamp_point desc)
-- 137337 записей отличается из 51 074 926., т.е. примерно 0.28%
-- с большой вероятностью тут корректны именно послдие версии, захватывающие данные полной минуты, по сравнению с первой версией - данными не полной минуты

select currency, reference_currency, count(*) 
from (select * from (select * from crcomp_pair_ohlc_1m_history_X1_asc
except
select * from crcomp_pair_ohlc_1m_history_X1_desc) aa order by timestamp_point desc) aa 
group by currency, reference_currency
order by 3 desc ;
-- разные монеты от 2900 записей и ниже


