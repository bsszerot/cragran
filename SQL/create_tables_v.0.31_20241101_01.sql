
-- --- содержимое текущей версии --- ---
-- 1.01 -- curr_pair_history
-- 1.02 -- gecko_coin_list
-- 1.03 -- таблица агрегации данных не-OHLC от GECKO (цена, капитализация, общий объём)  обвязка -- gecko_coins_history_data ;
-- 1.04 -- таблица агрегации данных OHLC от GECKO  обвязка -- gecko_minutes_ohlc_history ;
-- 1.05 -- таблица агрегации данных OHLC от crypto compare и обвязка -- crcomp_pair_OHLC_1H_history
-- 1.06 -- таблица агрегации данных OHLC от crypto compare и обвязка -- crcomp_pair_OHLC_1M_history
-- 1.07 -- таблица оптимизации агрегации данных OHLC от crypto compare и обвязка -- crcomp_pair_OHLC_1M_raw_collector
-- 1.08 -- таблица оптимизации агрегации данных OHLC от crypto compare и обвязка -- crcomp_pair_OHLC_1D_history
-- 1.09 -- таблица событий мониторинга
-- 1.10 -- таблица графиков событий мониторинга
-- 1.11 -- таблица контрактов
-- 1.12 -- таблицы ретроспективных цен и функции заполнения
-- 1.13 -- блок сбора ASH статистик
-- 1.14 -- таблицы и функции заполнения ретроспективного RSI
-- 1.15 -- таблицы и функции заполнения ретроспективного MACD
-- 1.16 -- таблицы и функции заполнения ретроспективного EMA
-- 1.17 -- таблицы и функции заполнения ретроспективных событий
-- 1.18 -- таблицы и функции заполнения ретроспективной стратегии RSI1H_MACD4H
-- 1.19 -- таблицы и функции заполнения ретроспективной стратегии RSI+MACD+EMA+EMAst

-- 2.1 разное

insert into curr_pair_history (currency, reference_currency, day_date, price_open, price_max, price_min, price_close, volume_from, volume_to)
       values () ;

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.01 начало -- таблица агрегации данных OHLC от GECKO  обвязка -- curr_pair_history ;
-- ---------------------------------------------------------------------------------------------------------------------------
--drop table curr_pair_history ;
create table curr_pair_history (
       currency           varchar(100),
       reference_currency varchar(100),
       day_date           date,
       price_open         numeric(42,21),
       price_max          numeric(42,21),
       price_min          numeric(42,21),
       price_close        numeric(42,21),
       volume_from        numeric(42,21),
       volume_to          numeric(42,21)) ;

--drop table curr_pair_history2 ;
create table curr_pair_history2 (
       currency           varchar(100),
       reference_currency varchar(100),
       day_date           date,
       price_open         numeric(42,21),
       price_max          numeric(42,21),
       price_min          numeric(42,21),
       price_close        numeric(42,21),
       volume_from        numeric(42,21),
       volume_to          numeric(42,21)) ;

CREATE INDEX crcomp_idx_pair_ohlc_1d_hist_metadata_01 ON curr_pair_history (
       currency, reference_currency, day_date) ;

CREATE INDEX crcomp_idx_pair_ohlc_1d_hist_base_metadata_01 ON curr_pair_history (
       reference_currency, day_date) ;

CREATE INDEX crcomp_idx_pair_ohlc_1d_hist_data_01 ON curr_pair_history (
       currency, reference_currency, day_date, price_open, price_max, price_min, price_close) ;

insert into curr_pair_history2 (select * from curr_pair_history) ;
commit ;
-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.01 конец -- таблица агрегации данных OHLC от GECKO  обвязка -- curr_pair_history ;
-- ---------------------------------------------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.02 начало таблица агрегации данных OHLC от GECKO  обвязка -- gecko_coin_list
-- ---------------------------------------------------------------------------------------------------------------------------
--drop table gecko_coin_list ;
--create table gecko_coin_list (
--       id_gecko_curr      varchar(100),
--       symb_gecko_curr    varchar(100),
--       name_gecko_curr    varchar(100)) ;

CREATE TABLE gecko_coin_list (
       id_gecko_curr        varchar(100),
       symb_gecko_curr      varchar(100),
       name_gecko_curr      varchar(100),
       hands_comment        varchar(254)) ;

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.02 конец таблица агрегации данных OHLC от GECKO  обвязка -- gecko_coin_list
-- ---------------------------------------------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.03 начало -- таблица агрегации данных OHLC от GECKO  обвязка -- gecko_coins_history_data ;
-- ---------------------------------------------------------------------------------------------------------------------------

-- v.2 от 20231124 - поле времени заменены на типовой, создана функция заполнения
--drop table gecko_coins_history_data ;
create table gecko_coins_history_data (
       change_ts          timestamp,
       currency           varchar(100),
       reference_currency varchar(100),
       timestamp_point    timestamp,
       price              numeric(42,21),
       market_caps        numeric(42,21),
       total_volume       numeric(42,21)) ;

select count(*) from gecko_coins_history_data ; 
select * from gecko_coins_history_data ; 
delete from gecko_coins_history_data ; 

--DROP INDEX gecko_coins_idx_history_data ;
CREATE INDEX gecko_coins_idx_history_data ON gecko_coins_history_data (currency, reference_currency, timestamp_point) ; 

-- резервная копия данных делется вручную
--drop table gecko_coins_history_data2 ;
create table gecko_coins_history_data2 (
       change_ts          timestamp,
       currency           varchar(100),
       reference_currency varchar(100),
       timestamp_point    timestamp,
       price              numeric(42,21),
       market_caps        numeric(42,21),
       total_volume       numeric(42,21)) ;

delete from gecko_coins_history_data2 ; 
select count(*) from gecko_coins_history_data2 ; 
insert into gecko_coins_history_data2 (select * from gecko_coins_history_data) ;

-- DROP FUNCTION fn_fill_gecko_historical_data(v_currency varchar, v_reference_currency varchar, v_timestamp_point timestamp without time zone, v_price numeric, v_market_caps numeric, v_total_volume numeric) ;
CREATE OR REPLACE FUNCTION fn_fill_gecko_historical_data(v_currency varchar, v_reference_currency varchar, v_timestamp_point timestamp without time zone, v_price numeric, v_market_caps numeric, v_total_volume numeric)
       RETURNS VOID AS $$
DECLARE
cntEditString INTEGER ;
cntEditString_nochanged INTEGER ;
BEGIN
        cntEditString := 0 ;
-- проверить существование строки за период вообще
        SELECT count(*) INTO cntEditString
               FROM gecko_coins_history_data
               WHERE currency = v_currency AND reference_currency = v_reference_currency AND TO_CHAR(timestamp_point, 'YYYY-MM-DD') = TO_CHAR(v_timestamp_point, 'YYYY-MM-DD') ;
        IF cntEditString > 0 THEN
           cntEditString_nochanged := 0 ;
-- проверить существующую строку за период с уже корректными данными, если данные отличаются - изменить, если нет -  перезаписывать
           SELECT count(*) INTO cntEditString_nochanged
                  FROM gecko_coins_history_data
                  WHERE currency = v_currency AND reference_currency = v_reference_currency AND TO_CHAR(timestamp_point, 'YYYY-MM-DD') = TO_CHAR(v_timestamp_point, 'YYYY-MM-DD')
                        AND price = v_price AND market_caps = v_market_caps AND total_volume = v_total_volume ;
                        IF cntEditString_nochanged = 0 THEN
                           UPDATE gecko_coins_history_data SET price = v_price, market_caps = v_market_caps, total_volume = v_total_volume
                           WHERE currency = v_currency AND reference_currency = v_reference_currency AND TO_CHAR(timestamp_point, 'YYYY-MM-DD') = TO_CHAR(v_timestamp_point, 'YYYY-MM-DD') ;
                        END IF ;
-- если строки нет - вставить новую
        ELSE
           INSERT INTO gecko_coins_history_data (change_ts, currency, reference_currency, timestamp_point, price, market_caps, total_volume)
                  VALUES (now(),v_currency, v_reference_currency, v_timestamp_point, v_price, v_market_caps, v_total_volume) ;
        END IF ;
END ;
$$ LANGUAGE plpgsql ;

--- --- --- --- --- --- старый вариант до 20231124 --- --- --- --- --- ---
--drop table gecko_coins_history_data ;
create table gecko_coins_history_data (
       currency           varchar(100),
       reference_currency varchar(100),
       day_date           date,
       prices             numeric(42,21),
       market_caps        numeric(42,21),
       total_volumes      numeric(42,21)) ;

-- резервная копия данных делется вручную
--drop table gecko_coins_history_data2 ;
create table gecko_coins_history_data2 (
       currency           varchar(100),
       reference_currency varchar(100),
       day_date           date,
       prices             numeric(42,21),
       market_caps        numeric(42,21),
       total_volumes      numeric(42,21)) ;

CREATE INDEX gecko_coins_idx_history_data ON gecko_coins_history_data (currency, reference_currency, day_date) ;

insert into gecko_coins_history_data2 (select * from gecko_coins_history_data) ;

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.03 конец -- таблица агрегации данных OHLC от GECKO  обвязка -- gecko_coins_history_data ;
-- ---------------------------------------------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.04 начало -- таблица агрегации данных OHLC от GECKO  обвязка -- gecko_minutes_ohlc_history ;
-- ---------------------------------------------------------------------------------------------------------------------------
-- drop table gecko_minutes_ohlc_history ;
create table gecko_minutes_ohlc_history (
       change_ts          timestamp,
       currency           varchar(100),
       reference_currency varchar(100),
       datetime_point     timestamp,
       price_open         numeric(42,21),
       price_max          numeric(42,21),
       price_min          numeric(42,21),
       price_close        numeric(42,21)) ;

-- резервная копия данных делется вручную
-- drop table gecko_minutes_ohlc_history2 ;
create table gecko_minutes_ohlc_history2 (
       change_ts          timestamp,
       currency           varchar(100),
       reference_currency varchar(100),
       datetime_point     timestamp,
       price_open         numeric(42,21),
       price_max          numeric(42,21),
       price_min          numeric(42,21),
       price_close        numeric(42,21)) ;

CREATE INDEX gecko_idx_minutes_ohlc_hist_metadata_01 ON  gecko_minutes_ohlc_history (
       change_ts, currency, reference_currency, datetime_point) ;

CREATE INDEX gecko_idx_minutes_ohlc_hist_base_metadata_01 ON  gecko_minutes_ohlc_history (
       currency, reference_currency, datetime_point) ;

CREATE INDEX gecko_idx_minutes_ohlc_hist_data_01 ON  gecko_minutes_ohlc_history (
       change_ts, currency, reference_currency, datetime_point, price_open, price_max, price_min, price_close) ;

insert into gecko_minutes_ohlc_history2 (select * from gecko_minutes_ohlc_history) ;
select count(*) from gecko_minutes_ohlc_history2 ;

-- функция  заливки данных, добавлена также проверка существования полностью идентичной строки, в этом случае UPDATE не запускается
-- DROP FUNCTION fn_fill_gecko_minutes_ohlc(v_currency varchar, v_reference_currency varchar, v_datetime_point timestamp, v_price_open numeric, v_price_max numeric, v_price_min numeric, v_price_close numeric) 
CREATE OR REPLACE FUNCTION fn_fill_gecko_minutes_ohlc(v_currency varchar, v_reference_currency varchar, v_datetime_point timestamp without time zone, v_price_open numeric, v_price_max numeric, v_price_min numeric, v_price_close numeric) 
       RETURNS VOID AS $$
DECLARE
cntEditString INT = 0 ;
cntEqualEditString INT = 0 ;
BEGIN
        SELECT count(*) INTO cntEditString
               FROM gecko_minutes_ohlc_history
               WHERE currency = v_currency AND reference_currency = v_reference_currency AND datetime_point = v_datetime_point ;
        IF cntEditString > 0 THEN
           SELECT count(*) INTO cntEqualEditString
               FROM gecko_minutes_ohlc_history
               WHERE currency = v_currency AND reference_currency = v_reference_currency AND datetime_point = v_datetime_point 
                     AND price_open = v_price_open AND price_max = v_price_max AND price_min = v_price_min AND price_close = v_price_close ;
               IF cntEqualEditString > 0 THEN
                  return ; 
               END IF ;   
           UPDATE gecko_minutes_ohlc_history SET change_ts = now(), price_open = v_price_open , price_max = v_price_max, price_min = v_price_min, price_close = v_price_close
                  WHERE currency = v_currency AND reference_currency = v_reference_currency AND datetime_point = v_datetime_point ;
        ELSE
           INSERT INTO gecko_minutes_ohlc_history (change_ts, currency, reference_currency, datetime_point, price_open, price_max, price_min, price_close)
                  VALUES (now(), v_currency, v_reference_currency, v_datetime_point, v_price_open, v_price_max, v_price_min, v_price_close) ;
        END IF ;
END ;
$$ LANGUAGE plpgsql ;

-- !!! проверить, что данные по второму кругу не заходят, хотя и перезаписываются !!!
select fn_fill_gecko_minutes_ohlc("aaa","bbb",now(),5.969859025973405e-06,5.969859025973405e-06,5.969859025973405e-06,5.969859025973405e-06) ;
select fn_fill_gecko_minutes_ohlc(CAST('aaa dd' AS VARCHAR), CAST('bb ddd' AS VARCHAR) , CAST(now() AS timestamp without time zone),5.969859025973405e-06,5,5,5) ;
-- проверочный болк для дополнения функции - не перезаписывать ту же самую строку с неизменными значениями
select fn_fill_gecko_minutes_ohlc(CAST('aaa dd' AS VARCHAR), CAST('bb ddd' AS VARCHAR) , CAST(TO_TIMESTAMP('2020-05-01 01:01:01','YYYY-MM-DD HH24:MI:SS') AS timestamp without time zone),205.969859025973405e-06,5,5,5) ;
select * from gecko_minutes_ohlc_history where currency = 'aaa dd' AND reference_currency = 'bb ddd' AND datetime_point = TO_TIMESTAMP('2020-05-01 01:01:01','YYYY-MM-DD HH24:MI:SS') order by 1 desc ;

select count(*) from gecko_minutes_ohlc_history ;
select * from gecko_minutes_ohlc_history order by 1 desc ;
select * from gecko_minutes_ohlc_history order by currency,reference_currency desc ;
select * from gecko_minutes_ohlc_history where currency = 'tron' and reference_currency = 'usd' order by currency, reference_currency, datetime_point desc ;
delete from gecko_minutes_ohlc_history ;

-- получить из получасового формата данных двухчасовой
-- планируется, что Perl модуль обработки будет получать все данные, и отбирать только двухчасовые, А ТАКЖЕ последние не-двухчасовые, если период не закончился
SELECT currency, reference_currency, datetime_point, price_close PRICE_CLOSE,
       min(price_min) OVER (PARTITION BY currency, reference_currency ORDER BY datetime_point ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as PRICE_MIN,
       max(price_max) OVER (PARTITION BY currency, reference_currency ORDER BY datetime_point ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as PRICE_MAX,
       LAG(price_open,3) OVER (PARTITION BY currency, reference_currency ORDER BY datetime_point ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as PRICE_OPEN
--       , price_open, price_max, price_min
       FROM gecko_minutes_ohlc_history 
       WHERE currency = 'bitcoin' AND reference_currency = 'usd'
       ORDER BY datetime_point ;
-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.04 конец -- таблица агрегации данных OHLC от GECKO и обвязка -- gecko_minutes_ohlc_history ;
-- ---------------------------------------------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.05 начало -- таблица агрегации данных OHLC от crypto compare и обвязка -- crcomp_pair_OHLC_1H_history
-- ---------------------------------------------------------------------------------------------------------------------------

-- 20240809_01 исправлена ошибка мультизаписи,
-- после выявления проблемы мультизаписи в таблице создан PRIMARY и уникальный индекс для защиты от дублирования записей - можно только удалить или обновить
-- служебное поле датывремени изменения вынесено в конец таблицы

--DROP TABLE public.crcomp_pair_ohlc_1h_history ;
CREATE TABLE IF NOT EXISTS public.crcomp_pair_ohlc_1h_history
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

-- DROP INDEX IF EXISTS public.crcomp_idx_pair_ohlc_1h_hist_metadata_01
CREATE UNIQUE INDEX crcomp_idx_pair_ohlc_1h_hist_metadata_01.
       ON crcomp_pair_ohlc_1h_history (currency, reference_currency, timestamp_point);

-- DROP INDEX IF EXISTS crcomp_idx_pair_ohlc_1h_hist_metadata_chtm_01;
CREATE INDEX IF NOT EXISTS crcomp_idx_pair_ohlc_1h_hist_metadata_chtm_01
    ON crcomp_pair_ohlc_1h_history.
       (change_ts, currency, reference_currency, timestamp_point ASC NULLS LAST) ;

CREATE OR REPLACE FUNCTION public.fn_fill_crcomp_1h_ohlc(
        v_currency character varying,
        v_reference_currency character varying,
        v_timestamp_point timestamp without time zone,
        v_price_open numeric,
        v_price_high numeric,
        v_price_low numeric,
        v_price_close numeric,
        v_volume_from numeric,
        v_volume_to numeric)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
cntEditString INTEGER ;
cntEditString_nochanged INTEGER ;
BEGIN
        cntEditString := 0 ;
        SELECT count(*) INTO cntEditString
               FROM crcomp_pair_OHLC_1H_history
               WHERE currency = v_currency AND reference_currency = v_reference_currency AND timestamp_point = v_timestamp_point ;
        IF cntEditString > 0 THEN
           cntEditString_nochanged := 0 ;
           SELECT count(*) INTO cntEditString_nochanged
                  FROM crcomp_pair_OHLC_1H_history
                  WHERE currency = v_currency AND reference_currency = v_reference_currency AND timestamp_point = v_timestamp_point
                        AND price_open = v_price_open AND price_high = v_price_high AND price_low = v_price_low AND price_close = v_price_close AND volume_from = v_volume_from AND volume_to = v_volume_to ;
                        IF cntEditString_nochanged = 0 THEN
                           UPDATE crcomp_pair_OHLC_1H_history SET price_open = v_price_open, price_high = v_price_high, price_low = v_price_low, price_close = v_price_close, volume_from = v_volume_from, volume_to = v_volume_to, change_ts = now()
                                  WHERE currency = v_currency AND reference_currency = v_reference_currency AND timestamp_point = v_timestamp_point ;
--                           COMMIT ;
                        END IF ;
        ELSE
           insert into crcomp_pair_OHLC_1H_history (currency, reference_currency, timestamp_point, price_open, price_high, price_low, price_close, volume_from, volume_to, change_ts)
                  values (v_currency, v_reference_currency, v_timestamp_point, v_price_open, v_price_high, v_price_low, v_price_close, v_volume_from, v_volume_to, now()) ;
--           COMMIT ;
        END IF ;
END ;
$BODY$;

-- ---------------------------------------------------------------------------------------------------------------------------
-- старое, до выявления мультизаписи, устарело
-- ---------------------------------------------------------------------------------------------------------------------------

-- drop table crcomp_pair_OHLC_1H_history
create table crcomp_pair_OHLC_1H_history (
       change_ts          timestamp,
       currency           varchar(100),
       reference_currency varchar(100),
       timestamp_point    timestamp,
       price_open         numeric(42,21),
       price_low          numeric(42,21),
       price_high         numeric(42,21),
       price_close        numeric(42,21),
       volume_from        numeric(42,21),
       volume_to          numeric(42,21)) ;

-- drop table crcomp_pair_OHLC_1H_history_2
create table crcomp_pair_OHLC_1H_history_2 (
       change_ts          timestamp,
       currency           varchar(100),
       reference_currency varchar(100),
       timestamp_point    timestamp,
       price_open         numeric(42,21),
       price_high         numeric(42,21),
       price_low          numeric(42,21),
       price_close        numeric(42,21),
       volume_from        numeric(42,21),
       volume_to          numeric(42,21)) ;

CREATE INDEX crcomp_idx_pair_ohlc_1h_hist_metadata_01 ON crcomp_pair_ohlc_1h_history (
       change_ts, currency, reference_currency, timestamp_point) ;

CREATE INDEX crcomp_idx_pair_ohlc_1h_hist_base_metadata_01 ON crcomp_pair_ohlc_1h_history (
       currency, reference_currency, timestamp_point) ;

CREATE INDEX crcomp_idx_pair_ohlc_1h_hist_data_01 ON crcomp_pair_ohlc_1h_history (
       change_ts, currency, reference_currency, timestamp_point, price_open, price_low, price_high, price_close) ;

insert into crcomp_pair_OHLC_1H_history_2 (select * from crcomp_pair_OHLC_1H_history_2) ;
select count(*) from crcomp_pair_OHLC_1H_history_2 ;

-- функция  заливки данных, добавлена также проверка существования полностью идентичной строки, в этом случае UPDATE не запускается
-- DROP FUNCTION fn_fill_crcomp_1H_ohlc(v_currency varchar, v_reference_currency varchar, v_timestamp_point timestamp without time zone, v_price_open numeric, v_price_high numeric, v_price_low numeric, v_price_close numeric, v_volume_from numeric, v_volume_to numeric) 
CREATE OR REPLACE FUNCTION fn_fill_crcomp_1H_ohlc(v_currency varchar, v_reference_currency varchar, v_timestamp_point timestamp without time zone, v_price_open numeric, v_price_high numeric, v_price_low numeric, v_price_close numeric, v_volume_from numeric, v_volume_to numeric) 
       RETURNS VOID AS $$
DECLARE
cntEditString INTEGER ;
cntEditString_nochanged INTEGER ;
BEGIN
        cntEditString := 0 ;
        SELECT count(*) INTO cntEditString
               FROM crcomp_pair_OHLC_1H_history
               WHERE currency = v_currency AND reference_currency = v_reference_currency AND timestamp_point = v_timestamp_point ;
        IF cntEditString > 0 THEN
           cntEditString_nochanged := 0 ;
           SELECT count(*) INTO cntEditString_nochanged
                  FROM crcomp_pair_OHLC_1H_history
                  WHERE currency = v_currency AND reference_currency = v_reference_currency AND timestamp_point = v_timestamp_point
                        AND price_open = v_price_open AND price_high = v_price_high AND price_low = v_price_low AND price_close = v_price_close AND volume_from = v_volume_from AND volume_to = v_volume_to ;
                        IF cntEditString_nochanged = 0 THEN
                           UPDATE crcomp_pair_OHLC_1H_history SET change_ts = now(), price_open = v_price_open, price_high = v_price_high, price_low = v_price_low, price_close = v_price_close, volume_from = v_volume_from, volume_to = v_volume_to 
                                  WHERE currency = v_currency AND reference_currency = v_reference_currency AND timestamp_point = v_timestamp_point ;
                        END IF ;
        ELSE
           insert into crcomp_pair_OHLC_1H_history (change_ts, currency, reference_currency, timestamp_point, price_open, price_high, price_low, price_close, volume_from, volume_to)
                  values (now(), v_currency, v_reference_currency, v_timestamp_point, v_price_open, v_price_high, v_price_low, v_price_close, v_volume_from, v_volume_to) ;
        END IF ;
END ;
$$ LANGUAGE plpgsql ;

select fn_fill_crcomp_1H_ohlc(CAST('aaa dd' AS VARCHAR), CAST('bb ddd' AS VARCHAR) , CAST(TO_TIMESTAMP('2020-05-01 01:01:01','YYYY-MM-DD HH24:MI:SS') AS timestamp without time zone),
       22.969859025973405e-06,5,5,5,4,7) ;

select count(*) FROM crcomp_pair_OHLC_1H_history ;
select * FROM crcomp_pair_OHLC_1H_history ;

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.05 конец -- таблица агрегации данных OHLC от crypto compare и обвязка -- crcomp_pair_OHLC_1H_history
-- ---------------------------------------------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.06 начало -- таблица агрегации данных OHLC от crypto compare и обвязка -- crcomp_pair_OHLC_1M_history
-- ---------------------------------------------------------------------------------------------------------------------------

-- после выявления проблемы мультизаписи в таблице создан PRIMARY и уникальный индекс для защиты от дублирования записей - можно только удалить или обновить
-- служебное поле датывремени изменения вынесено в конец таблицы

--DROP TABLE public.crcomp_pair_ohlc_1m_history ;
CREATE TABLE IF NOT EXISTS public.crcomp_pair_ohlc_1m_history
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

-- DROP INDEX IF EXISTS public.crcomp_idx_pair_ohlc_1m_hist_metadata_01
CREATE UNIQUE INDEX crcomp_idx_pair_ohlc_1m_hist_metadata_01
       ON crcomp_pair_ohlc_1m_history (currency, reference_currency, timestamp_point);

-- DROP INDEX IF EXISTS crcomp_idx_pair_ohlc_1m_hist_metadata_chtm_01;
CREATE INDEX IF NOT EXISTS crcomp_idx_pair_ohlc_1m_hist_metadata_chtm_01
    ON crcomp_pair_ohlc_1m_history
       (change_ts, currency, reference_currency, timestamp_point ASC NULLS LAST) ;

-- 20240806_01 после каждой записи добавлен COMMIT, но функция падала, и отключен
-- также в таблице создан PRIMARY и уникальный индекс для защиты от дублирования записей - можно только удалить или обновить
-- служебное поле датывремени изменения вынесено в конец таблицы
CREATE OR REPLACE FUNCTION public.fn_fill_crcomp_1m_ohlc(
        v_currency character varying,
        v_reference_currency character varying,
        v_timestamp_point timestamp without time zone,
        v_price_open numeric,
        v_price_high numeric,
        v_price_low numeric,
        v_price_close numeric,
        v_volume_from numeric,
        v_volume_to numeric)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
cntEditString INTEGER ;
cntEditString_nochanged INTEGER ;
BEGIN
        cntEditString := 0 ;
        SELECT count(*) INTO cntEditString
               FROM crcomp_pair_OHLC_1M_history
               WHERE currency = v_currency AND reference_currency = v_reference_currency AND timestamp_point = v_timestamp_point ;
        IF cntEditString > 0 THEN
           cntEditString_nochanged := 0 ;
           SELECT count(*) INTO cntEditString_nochanged
                  FROM crcomp_pair_OHLC_1M_history
                  WHERE currency = v_currency AND reference_currency = v_reference_currency AND timestamp_point = v_timestamp_point
                        AND price_open = v_price_open AND price_high = v_price_high AND price_low = v_price_low AND price_close = v_price_close AND volume_from = v_volume_from AND volume_to = v_volume_to ;
                        IF cntEditString_nochanged = 0 THEN
                           UPDATE crcomp_pair_OHLC_1M_history SET price_open = v_price_open, price_high = v_price_high, price_low = v_price_low, price_close = v_price_close, volume_from = v_volume_from, volume_to = v_volume_to, change_ts = now()
                                  WHERE currency = v_currency AND reference_currency = v_reference_currency AND timestamp_point = v_timestamp_point ;
--                           COMMIT ;
                        END IF ;
        ELSE
           insert into crcomp_pair_OHLC_1M_history (currency, reference_currency, timestamp_point, price_open, price_high, price_low, price_close, volume_from, volume_to, change_ts)
                  values (v_currency, v_reference_currency, v_timestamp_point, v_price_open, v_price_high, v_price_low, v_price_close, v_volume_from, v_volume_to, now()) ;
--           COMMIT ;
        END IF ;
END ;
$BODY$;

select fn_fill_crcomp_1M_ohlc(CAST('BTC' AS VARCHAR), CAST('USDT' AS VARCHAR), CAST(TO_TIMESTAMP('2024-08-08 8:20:0','YYYY-MM-DD HH24:MI:SS') AS timestamp without time zone), 57269.36, 57303.28, 57262.65, 57297.74, 36.68, 2101594.72) ;

-- ---------------------------------------------------------------------------------------------------------------------------
-- старое, до выявления мультизаписи, устарело
-- ---------------------------------------------------------------------------------------------------------------------------

-- drop table crcomp_pair_OHLC_1M_history
create table crcomp_pair_OHLC_1M_history (
       change_ts          timestamp,
       currency           varchar(100),
       reference_currency varchar(100),
       timestamp_point    timestamp,
       price_open         numeric(42,21),
       price_low          numeric(42,21),
       price_high         numeric(42,21),
       price_close        numeric(42,21),
       volume_from        numeric(42,21),
       volume_to          numeric(42,21)) ;

-- drop table crcomp_pair_OHLC_1M_history_2
create table crcomp_pair_OHLC_1M_history_2 (
       change_ts          timestamp,
       currency           varchar(100),
       reference_currency varchar(100),
       timestamp_point    timestamp,
       price_open         numeric(42,21),
       price_high         numeric(42,21),
       price_low          numeric(42,21),
       price_close        numeric(42,21),
       volume_from        numeric(42,21),
       volume_to          numeric(42,21)) ;

CREATE INDEX crcomp_idx_pair_ohlc_1m_hist_metadata_01 ON crcomp_pair_ohlc_1m_history (
       change_ts, currency, reference_currency, timestamp_point) ;

CREATE INDEX crcomp_idx_pair_ohlc_1m_hist_base_metadata_01 ON crcomp_pair_ohlc_1m_history (
       currency, reference_currency, timestamp_point) ;

CREATE INDEX crcomp_idx_pair_ohlc_1m_hist_data_01 ON crcomp_pair_ohlc_1m_history (
       change_ts, currency, reference_currency, timestamp_point, price_open, price_low, price_high, price_close) ;

insert into crcomp_pair_OHLC_1M_history_2 (select * from crcomp_pair_OHLC_1M_history_2) ;
select count(*) from crypta.crcomp_pair_OHLC_1M_history_2 ;

-- функция  заливки данных, добавлена также проверка существования полностью идентичной строки, в этом случае UPDATE не запускается
-- DROP FUNCTION fn_fill_crcomp_1M_ohlc(v_currency varchar, v_reference_currency varchar, v_timestamp_point timestamp without time zone, v_price_open numeric, v_price_high numeric, v_price_low numeric, v_price_close numeric, v_volume_from numeric, v_volume_to numeric) 
CREATE OR REPLACE FUNCTION fn_fill_crcomp_1M_ohlc(v_currency varchar, v_reference_currency varchar, v_timestamp_point timestamp without time zone, v_price_open numeric, v_price_high numeric, v_price_low numeric, v_price_close numeric, v_volume_from numeric, v_volume_to numeric) 
       RETURNS VOID AS $$
DECLARE
cntEditString INTEGER ;
cntEditString_nochanged INTEGER ;
BEGIN
        cntEditString := 0 ;
        SELECT count(*) INTO cntEditString
               FROM crcomp_pair_OHLC_1M_history
               WHERE currency = v_currency AND reference_currency = v_reference_currency AND timestamp_point = v_timestamp_point ;
        IF cntEditString > 0 THEN
           cntEditString_nochanged := 0 ;
           SELECT count(*) INTO cntEditString_nochanged
                  FROM crcomp_pair_OHLC_1M_history
                  WHERE currency = v_currency AND reference_currency = v_reference_currency AND timestamp_point = v_timestamp_point
                        AND price_open = v_price_open AND price_high = v_price_high AND price_low = v_price_low AND price_close = v_price_close AND volume_from = v_volume_from AND volume_to = v_volume_to ;
                        IF cntEditString_nochanged = 0 THEN
                           UPDATE crcomp_pair_OHLC_1M_history SET change_ts = now(), price_open = v_price_open, price_high = v_price_high, price_low = v_price_low, price_close = v_price_close, volume_from = v_volume_from, volume_to = v_volume_to 
                                  WHERE currency = v_currency AND reference_currency = v_reference_currency AND timestamp_point = v_timestamp_point ;
                        END IF ;
        ELSE
           insert into crcomp_pair_OHLC_1M_history (change_ts, currency, reference_currency, timestamp_point, price_open, price_high, price_low, price_close, volume_from, volume_to)
                  values (now(), v_currency, v_reference_currency, v_timestamp_point, v_price_open, v_price_high, v_price_low, v_price_close, v_volume_from, v_volume_to) ;
        END IF ;
END ;
$$ LANGUAGE plpgsql ;

select fn_fill_crcomp_1M_ohlc(CAST('aaa dd' AS VARCHAR), CAST('bb ddd' AS VARCHAR) , CAST(TO_TIMESTAMP('2020-05-01 01:01:01','YYYY-MM-DD HH24:MI:SS') AS timestamp without time zone),
       22.969859025973405e-06,5,5,5,4,7) ;

select count(*) FROM crcomp_pair_OHLC_1M_history ;
select * FROM crcomp_pair_OHLC_1M_history ;

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.06 конец -- таблица агрегации данных OHLC от crypto compare и обвязка -- crcomp_pair_OHLC_1M_history
-- ---------------------------------------------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.07 начало -- таблица агрегации данных OHLC от crypto compare и обвязка -- crcomp_pair_OHLC_1M_raw_collector
-- ---------------------------------------------------------------------------------------------------------------------------

-- drop table crcomp_pair_OHLC_1M_raw_collector
create table crcomp_pair_OHLC_1M_raw_collector (
       change_ts          timestamp,
       currency           varchar(100),
       reference_currency varchar(100),
       timestamp_point    timestamp,
       price_open         numeric(42,21),
       price_low          numeric(42,21),
       price_high         numeric(42,21),
       price_close        numeric(42,21),
       volume_from        numeric(42,21),
       volume_to          numeric(42,21)) ;

-- drop table crcomp_pair_OHLC_1M_raw_collector_2
create table crcomp_pair_OHLC_1M_raw_collector_2 (
       change_ts          timestamp,
       currency           varchar(100),
       reference_currency varchar(100),
       timestamp_point    timestamp,
       price_open         numeric(42,21),
       price_high         numeric(42,21),
       price_low          numeric(42,21),
       price_close        numeric(42,21),
       volume_from        numeric(42,21),
       volume_to          numeric(42,21)) ;

CREATE INDEX crcomp_idx_pair_ohlc_1m_rawcoll_metadata_01 ON crcomp_pair_ohlc_1m_raw_collector (
       change_ts, currency, reference_currency, timestamp_point) ;

CREATE INDEX crcomp_idx_pair_ohlc_1m_rawcoll_base_metadata_01 ON crcomp_pair_ohlc_1m_raw_collector (
       currency, reference_currency, timestamp_point) ;

CREATE INDEX crcomp_idx_pair_ohlc_1m_hist_data_01 ON crcomp_pair_ohlc_1m_raw_collector (
       change_ts, currency, reference_currency, timestamp_point, price_open, price_low, price_high, price_close) ;

insert into crcomp_pair_OHLC_1M_raw_collector_2 (select * from crcomp_pair_OHLC_1M_raw_collector) ;
select count(*) from crcomp_pair_OHLC_1M_raw_collector ;

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.07 конец -- таблица агрегации данных OHLC от crypto compare и обвязка -- crcomp_pair_OHLC_1M_collector
-- ---------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.08 начало -- таблица агрегации данных OHLC от crypto compare и обвязка -- crcomp_pair_OHLC_1D_history
-- ---------------------------------------------------------------------------------------------------------------------------

-- 20240809_01 исправлена ошибка мультизаписи,
-- после выявления проблемы мультизаписи в таблице создан PRIMARY и уникальный индекс для защиты от дублирования записей - можно только удалить или обновить
-- служебное поле датывремени изменения вынесено в конец таблицы

--DROP TABLE public.crcomp_pair_ohlc_1d_history ;
CREATE TABLE IF NOT EXISTS public.crcomp_pair_ohlc_1d_history
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

-- DROP INDEX IF EXISTS public.crcomp_idx_pair_ohlc_1d_hist_metadata_01
CREATE UNIQUE INDEX crcomp_idx_pair_ohlc_1d_hist_metadata_01
       ON crcomp_pair_ohlc_1d_history (currency, reference_currency, timestamp_point);

-- DROP INDEX IF EXISTS crcomp_idx_pair_ohlc_1d_hist_metadata_chtm_01;
CREATE INDEX IF NOT EXISTS crcomp_idx_pair_ohlc_1d_hist_metadata_chtm_01
    ON crcomp_pair_ohlc_1d_history
       (change_ts, currency, reference_currency, timestamp_point ASC NULLS LAST) ;

CREATE OR REPLACE FUNCTION public.fn_fill_crcomp_1d_ohlc(
        v_currency character varying,
        v_reference_currency character varying,
        v_timestamp_point timestamp without time zone,
        v_price_open numeric,
        v_price_high numeric,
        v_price_low numeric,
        v_price_close numeric,
        v_volume_from numeric,
        v_volume_to numeric)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
cntEditString INTEGER ;
cntEditString_nochanged INTEGER ;
BEGIN
        cntEditString := 0 ;
        SELECT count(*) INTO cntEditString
               FROM crcomp_pair_OHLC_1D_history
               WHERE currency = v_currency AND reference_currency = v_reference_currency AND timestamp_point = v_timestamp_point ;
        IF cntEditString > 0 THEN
           cntEditString_nochanged := 0 ;
           SELECT count(*) INTO cntEditString_nochanged
                  FROM crcomp_pair_OHLC_1D_history
                  WHERE currency = v_currency AND reference_currency = v_reference_currency AND timestamp_point = v_timestamp_point
                        AND price_open = v_price_open AND price_high = v_price_high AND price_low = v_price_low AND price_close = v_price_close AND volume_from = v_volume_from AND volume_to = v_volume_to ;
                        IF cntEditString_nochanged = 0 THEN
                           UPDATE crcomp_pair_OHLC_1D_history SET price_open = v_price_open, price_high = v_price_high, price_low = v_price_low, price_close = v_price_close, volume_from = v_volume_from, volume_to = v_volume_to, change_ts = now()
                                  WHERE currency = v_currency AND reference_currency = v_reference_currency AND timestamp_point = v_timestamp_point ;
--                           COMMIT ;
                        END IF ;
        ELSE
           insert into crcomp_pair_OHLC_1D_history (currency, reference_currency, timestamp_point, price_open, price_high, price_low, price_close, volume_from, volume_to, change_ts)
                  values (v_currency, v_reference_currency, v_timestamp_point, v_price_open, v_price_high, v_price_low, v_price_close, v_volume_from, v_volume_to, now()) ;
--           COMMIT ;
        END IF ;
END ;
$BODY$;

-- ---------------------------------------------------------------------------------------------------------------------------
-- старое, до выявления мультизаписи, устарело
-- ---------------------------------------------------------------------------------------------------------------------------

select * from crcomp_pair_ohlc_1d_history ;

-- DROP TABLE crcomp_pair_ohlc_1d_history ;
CREATE TABLE crcomp_pair_ohlc_1d_history
(
  change_ts timestamp without time zone,
  currency character varying(100),
  reference_currency character varying(100),
  timestamp_point timestamp without time zone,
  price_open numeric(42,21),
  price_low numeric(42,21),
  price_high numeric(42,21),
  price_close numeric(42,21),
  volume_from numeric(42,21),
  volume_to numeric(42,21)
);

ALTER TABLE crcomp_pair_ohlc_1d_history
  OWNER TO crypta;

-- Index: crcomp_idx_pair_ohlc_1h_hist_base_metadata_01

-- DROP INDEX crcomp_idx_pair_ohlc_1h_hist_base_metadata_01;

CREATE INDEX crcomp_idx01_pair_ohlc_1d_hist_base_metadata_01
  ON crcomp_pair_ohlc_1d_history
  USING btree
  (currency COLLATE pg_catalog."default", reference_currency COLLATE pg_catalog."default", timestamp_point);

-- Index: crcomp_idx_pair_ohlc_1h_hist_data_01

-- DROP INDEX crcomp_idx_pair_ohlc_1h_hist_data_01;

CREATE INDEX crcomp_idx01_pair_ohlc_1d_hist_data_01
  ON crcomp_pair_ohlc_1d_history
  USING btree
  (change_ts, currency COLLATE pg_catalog."default", reference_currency COLLATE pg_catalog."default", timestamp_point, price_open, price_low, price_high, price_close);

-- Index: crcomp_idx_pair_ohlc_1h_hist_metadata_01

-- DROP INDEX crcomp_idx_pair_ohlc_1h_hist_metadata_01;

CREATE INDEX crcomp_idx01_pair_ohlc_1d_hist_metadata_01
  ON crcomp_pair_ohlc_1d_history
  USING btree
  (change_ts, currency COLLATE pg_catalog."default", reference_currency COLLATE pg_catalog."default", timestamp_point);

CREATE TABLE crcomp_pair_ohlc_1d_history_2
(
  change_ts timestamp without time zone,
  currency character varying(100),
  reference_currency character varying(100),
  timestamp_point timestamp without time zone,
  price_open numeric(42,21),
  price_low numeric(42,21),
  price_high numeric(42,21),
  price_close numeric(42,21),
  volume_from numeric(42,21),
  volume_to numeric(42,21)
);

-- Function: fn_fill_crcomp_1d_ohlc(character varying, character varying, timestamp without time zone, numeric, numeric, numeric, numeric, numeric, numeric)
-- DROP FUNCTION fn_fill_crcomp_1d_ohlc(character varying, character varying, timestamp without time zone, numeric, numeric, numeric, numeric, numeric, numeric);
CREATE OR REPLACE FUNCTION fn_fill_crcomp_1d_ohlc(
    v_currency character varying,
    v_reference_currency character varying,
    v_timestamp_point timestamp without time zone,
    v_price_open numeric,
    v_price_high numeric,
    v_price_low numeric,
    v_price_close numeric,
    v_volume_from numeric,
    v_volume_to numeric)
  RETURNS void AS
$BODY$
DECLARE
cntEditString INTEGER ;
cntEditString_nochanged INTEGER ;
BEGIN
        cntEditString := 0 ;
        SELECT count(*) INTO cntEditString
               FROM crcomp_pair_OHLC_1D_history
               WHERE currency = v_currency AND reference_currency = v_reference_currency AND timestamp_point = v_timestamp_point ;
        IF cntEditString > 0 THEN
           cntEditString_nochanged := 0 ;
           SELECT count(*) INTO cntEditString_nochanged
                  FROM crcomp_pair_OHLC_1D_history
                  WHERE currency = v_currency AND reference_currency = v_reference_currency AND timestamp_point = v_timestamp_point
                        AND price_open = v_price_open AND price_high = v_price_high AND price_low = v_price_low AND price_close = v_price_close AND volume_from = v_volume_from AND volume_to = v_volume_to ;
                        IF cntEditString_nochanged = 0 THEN
                           UPDATE crcomp_pair_OHLC_1D_history SET change_ts = now(), price_open = v_price_open, price_high = v_price_high, price_low = v_price_low, price_close = v_price_close, volume_from = v_volume_from, volume_to = v_volume_to 
                                  WHERE currency = v_currency AND reference_currency = v_reference_currency AND timestamp_point = v_timestamp_point ;
                        END IF ;
        ELSE
           insert into crcomp_pair_OHLC_1D_history (change_ts, currency, reference_currency, timestamp_point, price_open, price_high, price_low, price_close, volume_from, volume_to)
                  values (now(), v_currency, v_reference_currency, v_timestamp_point, v_price_open, v_price_high, v_price_low, v_price_close, v_volume_from, v_volume_to) ;
        END IF ;
END ;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION fn_fill_crcomp_1d_ohlc(character varying, character varying, timestamp without time zone, numeric, numeric, numeric, numeric, numeric, numeric)
  OWNER TO crypta;

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.08 конец -- таблица агрегации данных OHLC от crypto compare и обвязка -- crcomp_pair_OHLC_1D_history
-- ---------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.09 начало -- таблица событий мониторинге
-- ---------------------------------------------------------------------------------------------------------------------------

-- ID события (sequence?)
-- время фиксации
-- событие
-- индикатор
-- ТФ
-- направление события
--DROP TABLE mon_events ;
CREATE TABLE mon_events (
  event_id            bigserial,
  event_rand_id       character varying(100),
  change_ts           timestamp without time zone,
  currency            character varying(100),
  reference_currency  character varying(100),
  timestamp_point     timestamp without time zone,
  event_name          character varying(100),
  event_vector        character varying(30),
  event_tf            character varying(10),
  event_indicator     character varying(100),
  event_sub_indicator character varying(100)
  ) ;

insert into mon_events (event_rand_id,change_ts, currency, reference_currency, timestamp_point, event_name, event_vector, event_tf, event_indicator, event_sub_indicator)
       values ('oooeeerrrtttyyy',now(),'BTCss','USDTss', now(), 'test_ev_name', 'test_ev_vector', '25D', 'PSAR', 'no') ;
select event_id, event_rand_id, change_ts, currency, reference_currency, timestamp_point, event_name, event_vector, event_tf, event_indicator, event_sub_indicator
       from mon_events 
       oreder by timestamp_point DESC ;
select * from mon_events ;

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.09 конец -- таблица событий мониторинге
-- ---------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.10 начало -- таблица графиков событий мониторинге
-- ---------------------------------------------------------------------------------------------------------------------------

-- ID события
-- ID графика
-- время фиксации
-- индикатор
-- имя файла графика
--DROP TABLE mon_events_images ;
CREATE TABLE mon_events_images (
  event_id             bigint,
  event_rand_id        character varying(100),
  event_img_id         bigserial,  
  change_ts            timestamp without time zone,
  file_name            character varying(1024),
  full_file_name       character varying(2048),
  timestamp_point      timestamp without time zone,
  ev_img_tf            character varying(10),
  ev_img_indicator     character varying(100),
  ev_img_sub_indicator character varying(100)
  ) ;

CREATE INDEX mon_events_idx_metadata_01 ON mon_events (
       change_ts, currency, reference_currency, timestamp_point) ;

CREATE INDEX mon_events_idx_base_metadata_01 ON mon_events (
       currency, reference_currency, timestamp_point) ;

CREATE INDEX mon_events_idx_data_01 ON mon_events (
       change_ts, currency, reference_currency, timestamp_point, event_name, event_vector, event_tf) ;

insert into mon_events_images (event_id, event_rand_id, change_ts, file_name, full_file_name, timestamp_point, ev_img_tf, ev_img_indicator, ev_img_sub_indicator)
       values(1, 'wwwqqqwwwrerrr', now(),'ssss.img','/a/s/d/f/ssss.img',now(),'25D','PSAR','no') ;
select event_id, event_rand_id, event_img_id, change_ts, file_name, full_file_name, timestamp_point, ev_img_tf, ev_img_indicator, ev_img_sub_indicator
       from mon_events_images
       oreder by timestamp_point DESC ;
select * from mon_events_images ;

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.10 конец -- таблица графиков событий мониторинге
-- ---------------------------------------------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.11 начало -- таблица контрактов
-- ---------------------------------------------------------------------------------------------------------------------------

-- таблица изменена - все поля процентов переведены с целочисленных NUMBER на плавающую точку REAL
create table taaa1 as select * from contracts_history ;
delete from taaa1 where contract_id IS  NULL ;
-- recreate table
insert into contracts_history select * from taaa1 ;
select contract_id,input_time_point,* from contracts_history order by 1 desc,2;
alter sequence contracts_history_contract_id_seq restart with 76 ;

-- DROP TABLE contracts_history;
CREATE TABLE contracts_history
(
  user_id bigint,
  user_name character varying(100),
  contract_id bigserial NOT NULL,
  contract_rand_id character varying(100),
  contract_status character varying(100),
  contract_leverage real,
  cycle character varying(100),
  currency character varying(100),
  reference_currency character varying(100),
  contract_vector character varying(100),
  rmm_sl numeric(42,21),
  rmm_sl_prct real,
  rmm_tp numeric(42,21),
  rmm_tp_prct real,
  rmm_tgt numeric(42,21),
  rmm_tgt_prct real,
  rmm_risk real,
  rmm_revard real,
  input_base character varying(100),
  input_event_rand_id character varying(100),
  input_time_point timestamp without time zone,
  input_price numeric(42,21),
  input_volume numeric(42,21),
  input_summ numeric(42,21),
  ind_curr_ema_tf character varying(10),
  ind_curr_ema character varying(100),
  ind_own_ema_tf character varying(10),
  ind_own_ema character varying(100),
  ind_curr_price_tf character varying(10),
  ind_curr_price character varying(100),
  ind_own_price_tf character varying(10),
  ind_own_price character varying(100),
  ind_curr_macd_line_tf character varying(10),
  ind_curr_macd_line character varying(100),
  ind_own_macd_line_tf character varying(10),
  ind_own_macd_line character varying(100),
  ind_curr_macd_gist_tf character varying(10),
  ind_curr_macd_gist character varying(100),
  ind_own_macd_gist_tf character varying(10),
  ind_own_macd_gist character varying(100),
  ind_curr_rsi_tf character varying(10),
  ind_curr_rsi character varying(100),
  ind_own_rsi_tf character varying(10),
  ind_own_rsi character varying(100),
  output_base character varying(100),
  output_event_rand_id character varying(100),
  output_time_point timestamp without time zone,
  output_price numeric(42,21),
  output_volume numeric(42,21),
  output_summ numeric(42,21),
  result_price numeric(42,21),
  result_volume numeric(42,21),
  result_summ numeric(42,21),
  result_percent real,
  comments character varying
)
WITH (
  OIDS=FALSE
);

ALTER TABLE contracts_history
  OWNER TO crypta;


-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.11 конец -- таблица контрактов
-- ---------------------------------------------------------------------------------------------------------------------------




-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.12 начало -- таблицы ретроспективных цен и функции заполнения
-- ---------------------------------------------------------------------------------------------------------------------------

-- DROP TABLE IF EXISTS public.cragran_logs;
CREATE TABLE cragran_logs (
       timestamp_point timestamp without time zone,
       tpk_part character varying(100),
       module character varying(100),
       log_text character varying(1000) )
       TABLESPACE pg_default ;
ALTER TABLE cragran_logs OWNER to crypta;

drop table  rtrsp_ohlc_1m_history ;
drop table  rtrsp_ohlc_3m_history ;
drop table  rtrsp_ohlc_5m_history ;
drop table  rtrsp_ohlc_10m_history ;
drop table  rtrsp_ohlc_15m_history ; 
drop table  rtrsp_ohlc_30m_history ;
drop table  rtrsp_ohlc_1h_history ;
drop table  rtrsp_ohlc_2h_history ;
drop table  rtrsp_ohlc_3h_history ;
drop table  rtrsp_ohlc_4h_history ;
drop table  rtrsp_ohlc_8h_history ;
drop table  rtrsp_ohlc_12h_history ;
drop table  rtrsp_ohlc_1d_history ;
drop table  rtrsp_ohlc_2d_history ;
drop table  rtrsp_ohlc_4d_history ;
drop table  rtrsp_ohlc_1w_history ;
drop table  rtrsp_ohlc_4w_history ;

delete from  rtrsp_ohlc_1m_history ; 
delete from  rtrsp_ohlc_3m_history ; 
delete from  rtrsp_ohlc_5m_history ; 
delete from  rtrsp_ohlc_10m_history ; 
delete from  rtrsp_ohlc_15m_history ; 
delete from  rtrsp_ohlc_30m_history ; 
delete from  rtrsp_ohlc_1h_history ; 
delete from  rtrsp_ohlc_2h_history ; 
delete from  rtrsp_ohlc_3h_history ;
delete from  rtrsp_ohlc_4h_history ; 
delete from  rtrsp_ohlc_8h_history ; 
delete from  rtrsp_ohlc_12h_history ; 
delete from  rtrsp_ohlc_1d_history ; 
delete from  rtrsp_ohlc_2d_history ; 
delete from  rtrsp_ohlc_4d_history ; 
delete from  rtrsp_ohlc_1w_history ; 
delete from  rtrsp_ohlc_4w_history ; 
delete from cragran_logs ;
select * from cragran_logs order by 1;

create table rtrsp_ohlc_1m_history as select * from crcomp_pair_ohlc_1m_history limit 0 ;
alter table rtrsp_ohlc_1m_history add is_tail boolean ;
alter table rtrsp_ohlc_1m_history add constraint pk_rtrsp_ohlc_1m_history PRIMARY KEY (currency, reference_currency, timestamp_point) ;

create table rtrsp_ohlc_3m_history as select * from crcomp_pair_ohlc_1m_history limit 0 ;
alter table rtrsp_ohlc_3m_history add is_tail boolean ;
alter table rtrsp_ohlc_3m_history add constraint pk_rtrsp_ohlc_3m_history PRIMARY KEY (currency, reference_currency, timestamp_point) ;

create table rtrsp_ohlc_5m_history as select * from crcomp_pair_ohlc_1m_history limit 0 ;
alter table rtrsp_ohlc_5m_history add is_tail boolean ;
alter table rtrsp_ohlc_5m_history add constraint pk_rtrsp_ohlc_5m_history PRIMARY KEY (currency, reference_currency, timestamp_point) ;

create table rtrsp_ohlc_10m_history as select * from crcomp_pair_ohlc_1m_history limit 0 ;
alter table rtrsp_ohlc_10m_history add is_tail boolean ;
alter table rtrsp_ohlc_10m_history add constraint pk_rtrsp_ohlc_10m_history PRIMARY KEY (currency, reference_currency, timestamp_point) ;

create table rtrsp_ohlc_15m_history as select * from crcomp_pair_ohlc_1m_history limit 0 ;
alter table rtrsp_ohlc_15m_history add is_tail boolean ;
alter table rtrsp_ohlc_15m_history add constraint pk_rtrsp_ohlc_15m_history PRIMARY KEY (currency, reference_currency, timestamp_point) ;

create table rtrsp_ohlc_30m_history as select * from crcomp_pair_ohlc_1d_history limit 0 ;
alter table rtrsp_ohlc_30m_history add is_tail boolean ;
alter table rtrsp_ohlc_30m_history add constraint pk_rtrsp_ohlc_30m_history PRIMARY KEY (currency, reference_currency, timestamp_point) ;

create table rtrsp_ohlc_1h_history as select * from crcomp_pair_ohlc_1h_history limit 0 ;
alter table rtrsp_ohlc_1h_history add is_tail boolean ;
alter table rtrsp_ohlc_1h_history add constraint pk_rtrsp_ohlc_1h_history PRIMARY KEY (currency, reference_currency, timestamp_point) ;

create table rtrsp_ohlc_2h_history as select * from crcomp_pair_ohlc_1h_history limit 0 ;
alter table rtrsp_ohlc_2h_history add is_tail boolean ;
alter table rtrsp_ohlc_2h_history add constraint pk_rtrsp_ohlc_2h_history PRIMARY KEY (currency, reference_currency, timestamp_point) ;

create table rtrsp_ohlc_3h_history as select * from crcomp_pair_ohlc_1h_history limit 0 ;
alter table rtrsp_ohlc_3h_history add is_tail boolean ;
alter table rtrsp_ohlc_3h_history add constraint pk_rtrsp_ohlc_3h_history PRIMARY KEY (currency, reference_currency, timestamp_point) ;

create table rtrsp_ohlc_4h_history as select * from crcomp_pair_ohlc_1h_history limit 0 ;
alter table rtrsp_ohlc_4h_history add is_tail boolean ;
alter table rtrsp_ohlc_4h_history add constraint pk_rtrsp_ohlc_4h_history PRIMARY KEY (currency, reference_currency, timestamp_point) ;

create table rtrsp_ohlc_8h_history as select * from crcomp_pair_ohlc_1h_history limit 0 ;
alter table rtrsp_ohlc_8h_history add is_tail boolean ;
alter table rtrsp_ohlc_8h_history add constraint pk_rtrsp_ohlc_8h_history PRIMARY KEY (currency, reference_currency, timestamp_point) ;

create table rtrsp_ohlc_12h_history as select * from crcomp_pair_ohlc_1h_history limit 0 ;
alter table rtrsp_ohlc_12h_history add is_tail boolean ;
alter table rtrsp_ohlc_12h_history add constraint pk_rtrsp_ohlc_12h_history PRIMARY KEY (currency, reference_currency, timestamp_point) ;

create table rtrsp_ohlc_1d_history as select * from crcomp_pair_ohlc_1d_history limit 0 ;
alter table rtrsp_ohlc_1d_history add is_tail boolean ;
alter table rtrsp_ohlc_1d_history add constraint pk_rtrsp_ohlc_1d_history PRIMARY KEY (currency, reference_currency, timestamp_point) ;

create table rtrsp_ohlc_2d_history as select * from crcomp_pair_ohlc_1d_history limit 0 ;
alter table rtrsp_ohlc_2d_history add is_tail boolean ;
alter table rtrsp_ohlc_2d_history add constraint pk_rtrsp_ohlc_2d_history PRIMARY KEY (currency, reference_currency, timestamp_point) ;

create table rtrsp_ohlc_4d_history as select * from crcomp_pair_ohlc_1d_history limit 0 ;
alter table rtrsp_ohlc_4d_history add is_tail boolean ;
alter table rtrsp_ohlc_4d_history add constraint pk_rtrsp_ohlc_4d_history PRIMARY KEY (currency, reference_currency, timestamp_point) ;

create table rtrsp_ohlc_1w_history as select * from crcomp_pair_ohlc_1d_history limit 0 ;
alter table rtrsp_ohlc_1w_history add is_tail boolean ;
alter table rtrsp_ohlc_1w_history add constraint pk_rtrsp_ohlc_1w_history PRIMARY KEY (currency, reference_currency, timestamp_point) ;

create table rtrsp_ohlc_4w_history as select * from crcomp_pair_ohlc_1d_history limit 0 ;
alter table rtrsp_ohlc_4w_history add is_tail boolean ;
alter table rtrsp_ohlc_4w_history add constraint pk_rtrsp_ohlc_4w_history PRIMARY KEY (currency, reference_currency, timestamp_point) ;

create table cragran_logs (
       timestamp_point timestamp without time zone,
       tpk_part character varying(100),
       module   character varying(100),
       log_text character varying(1000)) ;

-- ======================================================================================================================================
-- основная функция заполнения таблиц ретроспективных OHLC
-- ======================================================================================================================================

-- DROP FUNCTION IF EXISTS public.fn_fill_retrospective_ohlcv_tables(character varying, character varying, character varying, timestamp without time zone, timestamp without time zone, boolean);
CREATE OR REPLACE FUNCTION public.fn_fill_retrospective_ohlcv_tables(
    v_currency character varying,
    v_reference_currency character varying,
    v_time_frame character varying,
    v_time_start timestamp without time zone,
    v_time_stop timestamp without time zone,
    v_tail_calculate boolean)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
       DECLARE
       rec_source_ohlcv             RECORD ;
       cntPoolCommit                INTEGER ;
       cntEditString                INTEGER ;
       cntEditString_nochanged      INTEGER ;
       cnt_dataset                  INTEGER ;
       cnt_dataset_filtered         INTEGER ;
       sz_base_cursor_request       VARCHAR ;
       sz_request_lag_period        VARCHAR ;
       sz_request_table_name        VARCHAR ;
       sz_target_table_name         VARCHAR ;
       sz_query_is_record_exist     VARCHAR ;
       sz_query_is_record_nochanged VARCHAR ;
       sz_query_modify_record       VARCHAR ;
       sz_query_insert_record       VARCHAR ;
       BEGIN
       cntPoolCommit := 0 ;
       cnt_dataset := 0 ;
       cnt_dataset_filtered := 0 ;
-- установить параметры запросов для разных ТФ

       IF (v_time_frame = '4W')  THEN sz_request_lag_period := 27 ; sz_request_table_name := 'crcomp_pair_OHLC_1D_history' ; sz_target_table_name := 'rtrsp_ohlc_4w_history' ;  END IF ;
       IF (v_time_frame = '1W')  THEN sz_request_lag_period := 6 ;  sz_request_table_name := 'crcomp_pair_OHLC_1D_history' ; sz_target_table_name := 'rtrsp_ohlc_1w_history' ;  END IF ;
       IF (v_time_frame = '4D')  THEN sz_request_lag_period := 3 ;  sz_request_table_name := 'crcomp_pair_OHLC_1D_history' ; sz_target_table_name := 'rtrsp_ohlc_4d_history' ;  END IF ;
       IF (v_time_frame = '2D')  THEN sz_request_lag_period := 1 ;  sz_request_table_name := 'crcomp_pair_OHLC_1D_history' ; sz_target_table_name := 'rtrsp_ohlc_2d_history' ;  END IF ;
       IF (v_time_frame = '1D')  THEN                               sz_request_table_name := 'crcomp_pair_OHLC_1D_history' ; sz_target_table_name := 'rtrsp_ohlc_1d_history' ;  END IF ;
       IF (v_time_frame = '12H') THEN sz_request_lag_period := 11 ; sz_request_table_name := 'crcomp_pair_OHLC_1H_history' ; sz_target_table_name := 'rtrsp_ohlc_12h_history' ; END IF ;
       IF (v_time_frame = '8H')  THEN sz_request_lag_period := 7 ;  sz_request_table_name := 'crcomp_pair_OHLC_1H_history' ; sz_target_table_name := 'rtrsp_ohlc_8h_history' ;  END IF ;
       IF (v_time_frame = '4H')  THEN sz_request_lag_period := 3 ;  sz_request_table_name := 'crcomp_pair_OHLC_1H_history' ; sz_target_table_name := 'rtrsp_ohlc_4h_history' ;  END IF ;
       IF (v_time_frame = '3H')  THEN sz_request_lag_period := 2 ;  sz_request_table_name := 'crcomp_pair_OHLC_1H_history' ; sz_target_table_name := 'rtrsp_ohlc_3h_history' ;  END IF ;
       IF (v_time_frame = '2H')  THEN sz_request_lag_period := 1 ;  sz_request_table_name := 'crcomp_pair_OHLC_1H_history' ; sz_target_table_name := 'rtrsp_ohlc_2h_history' ;  END IF ;
       IF (v_time_frame = '1H')  THEN                               sz_request_table_name := 'crcomp_pair_OHLC_1H_history' ; sz_target_table_name := 'rtrsp_ohlc_1h_history' ;  END IF ;
       IF (v_time_frame = '30M') THEN sz_request_lag_period := 29 ; sz_request_table_name := 'crcomp_pair_OHLC_1M_history' ; sz_target_table_name := 'rtrsp_ohlc_30m_history' ; END IF ;
       IF (v_time_frame = '15M') THEN sz_request_lag_period := 14 ; sz_request_table_name := 'crcomp_pair_OHLC_1M_history' ; sz_target_table_name := 'rtrsp_ohlc_15m_history' ; END IF ;
       IF (v_time_frame = '10M') THEN sz_request_lag_period := 9 ;  sz_request_table_name := 'crcomp_pair_OHLC_1M_history' ; sz_target_table_name := 'rtrsp_ohlc_10m_history' ; END IF ;
       IF (v_time_frame = '5M')  THEN sz_request_lag_period := 4 ;  sz_request_table_name := 'crcomp_pair_OHLC_1M_history' ; sz_target_table_name := 'rtrsp_ohlc_5m_history' ;  END IF ;
       IF (v_time_frame = '3M')  THEN sz_request_lag_period := 2 ;  sz_request_table_name := 'crcomp_pair_OHLC_1M_history' ; sz_target_table_name := 'rtrsp_ohlc_3m_history' ;  END IF ;
       IF (v_time_frame = '1M')  THEN                               sz_request_table_name := 'crcomp_pair_OHLC_1M_history' ; sz_target_table_name := 'rtrsp_ohlc_1m_history' ; END IF ;

-- для ТФ, требующих агрегации и оконных функций - сформировать типовой запрос
       IF ( v_time_frame = '3M' OR v_time_frame = '5M' OR v_time_frame = '10M' OR v_time_frame = '15M' OR v_time_frame = '30M' OR
            v_time_frame = '2H' OR v_time_frame = '3H' OR v_time_frame = '4H' OR v_time_frame = '8H' OR v_time_frame = '12H' OR
            v_time_frame = '2D' OR v_time_frame = '4D' OR v_time_frame = '1W' OR v_time_frame = '4W' ) THEN
          sz_base_cursor_request := 'SELECT currency, reference_currency, (timestamp_point + INTERVAL ''3 HOURS'') timestamp_point,
                                            LAG(price_open,'||sz_request_lag_period||') OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL ''3 HOURS'') ASC
                                                                                             ROWS BETWEEN '||sz_request_lag_period||' PRECEDING AND CURRENT ROW) as PRICE_OPEN,
                                            min(price_low)   OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL ''3 HOURS'') ASC
                                                                  ROWS BETWEEN '||sz_request_lag_period||' PRECEDING AND CURRENT ROW) as PRICE_LOW,
                                            max(price_high)  OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL ''3 HOURS'') ASC
                                                                  ROWS BETWEEN '||sz_request_lag_period||' PRECEDING AND CURRENT ROW) as PRICE_HIGH,
                                            price_close PRICE_CLOSE, extract(day from (timestamp_point + INTERVAL ''3 HOURS'')) days,
                                            extract(hour from (timestamp_point + INTERVAL ''3 HOURS'')) hours,
                                            extract(minute from (timestamp_point + INTERVAL ''3 HOURS'')) minutes,
                                            SUM(volume_from) OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL ''3 HOURS'') ASC
                                                                  ROWS BETWEEN '||sz_request_lag_period||' PRECEDING AND CURRENT ROW) as VOLUME_FROM,
                                            SUM(volume_to)   OVER (PARTITION BY currency, reference_currency ORDER BY (timestamp_point + INTERVAL ''3 HOURS'') ASC
                                                                  ROWS BETWEEN '||sz_request_lag_period||' PRECEDING AND CURRENT ROW) as VOLUME_TO
                                            FROM '||sz_request_table_name||' WHERE currency = $1 AND reference_currency = $2 
                                                 AND (timestamp_point + INTERVAL ''3 HOURS'') >= $3 AND (timestamp_point + INTERVAL ''3 HOURS'') <= $4
                                            order by timestamp_point ASC ' ;
       END IF ;
-- для ТФ, НЕ требующих агрегации и оконных функций - сформировать типовой запрос
       IF ( v_time_frame = '1M' OR v_time_frame = '1H' OR v_time_frame = '1D' ) THEN
          sz_base_cursor_request := 'SELECT currency, reference_currency, (timestamp_point + INTERVAL ''3 HOURS'') timestamp_point,
                                            price_open, price_low, price_high, price_close, extract(day from (timestamp_point + INTERVAL ''3 HOURS'')) days,
                                            extract(hour from (timestamp_point + INTERVAL ''3 HOURS'')) hours, extract(minute from (timestamp_point + INTERVAL ''3 HOURS'')) minutes,
                                            volume_from as VOLUME_FROM, volume_to as VOLUME_TO
                                            FROM '||sz_request_table_name||' WHERE currency = $1 AND reference_currency = $2 
                                                  AND (timestamp_point + INTERVAL ''3 HOURS'') >= $3 AND (timestamp_point + INTERVAL ''3 HOURS'') <= $4
                                            order by timestamp_point ASC' ;
       END IF ;

-- -----------------------------------
-- инициализируем основной массив данных
-- -----------------------------------
       insert into cragran_logs values(clock_timestamp(),'rtsp_analyze','fn_fill_retrospective_ohlcv_tables','- [start] '||v_currency||'/'||v_reference_currency||' ТФ'||v_time_frame||' заполнение ретроспективных данных OHLC, основной массив, записи в диапазоне '||v_time_start||' - '||v_time_stop) ;
       FOR rec_source_ohlcv IN EXECUTE sz_base_cursor_request USING v_currency, v_reference_currency, v_time_start, v_time_stop LOOP
           cnt_dataset := cnt_dataset + 1 ;
-- для каждой выбранной строки проверить соответсвие фильтру попадания в агрегационную выборку, и только для таких стро провести обработку, перед "хвостом"
           IF ( ( v_time_frame = '4W'  AND rec_source_ohlcv.days = 1 ) OR
                ( v_time_frame = '1W'  AND rec_source_ohlcv.days IN (1,8,15,22,29) ) OR
                ( v_time_frame = '4D'  AND rec_source_ohlcv.days IN (1,5,9,13,17,21,25,29) ) OR
                ( v_time_frame = '2D'  AND rec_source_ohlcv.days IN (1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31) ) OR
                ( v_time_frame = '12H' AND rec_source_ohlcv.days IN (1,13) AND rec_source_ohlcv.minutes = 0 ) OR
                ( v_time_frame = '8H'  AND rec_source_ohlcv.days IN (1,9,17) AND rec_source_ohlcv.minutes = 0 ) OR
                ( v_time_frame = '4H'  AND rec_source_ohlcv.days IN (1,5,9,13,17,21) AND rec_source_ohlcv.minutes = 0 ) OR
                ( v_time_frame = '3H'  AND rec_source_ohlcv.days IN (1,3,7,10,13,16,19,22) AND rec_source_ohlcv.minutes = 0 ) OR
                ( v_time_frame = '2H'  AND rec_source_ohlcv.days IN (1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47,49,51,53,55,57,59) AND rec_source_ohlcv.minutes = 0 ) OR
                ( v_time_frame = '1H'  AND rec_source_ohlcv.minutes = 0 ) OR
                ( v_time_frame = '30M' AND rec_source_ohlcv.minutes IN (0,30) ) OR
                ( v_time_frame = '15M' AND rec_source_ohlcv.minutes IN (0,15,30,45) ) OR
                ( v_time_frame = '10M' AND rec_source_ohlcv.minutes IN (0,10,20,30,40,50) ) OR
                ( v_time_frame = '5M'  AND rec_source_ohlcv.minutes IN (0,5,10,15,20,25,30,35,40,45,50,55) ) OR
                ( v_time_frame = '3M'  AND rec_source_ohlcv.minutes IN (0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51,54,57) ) OR
                ( v_time_frame = '1M'  OR  v_time_frame = '1D'  ) ) THEN
--           IF ( rec_source_ohlcv.minutes = 0 OR rec_source_ohlcv.minutes = 30 ) THEN
-- для каждой выбранной строки проверить ее наличие в таблице - приёмнике
              cnt_dataset_filtered := cnt_dataset_filtered + 1 ;
              cntEditString := 0 ;
              sz_query_is_record_exist := 'SELECT count(*) FROM '||sz_target_table_name||' WHERE currency = $1 AND reference_currency = $2 AND timestamp_point = $3' ;
              EXECUTE sz_query_is_record_exist INTO STRICT cntEditString USING rec_source_ohlcv.currency, rec_source_ohlcv.reference_currency, rec_source_ohlcv.timestamp_point ;
-- если строка есть - проверяем ее значения
              IF cntEditString > 0 THEN
                 cntEditString_nochanged := 0 ;
                 sz_query_is_record_nochanged := 'SELECT count(*) FROM '||sz_target_table_name||' WHERE currency = $1 AND reference_currency = $2 AND timestamp_point = $3
                              AND price_open = $4 AND price_high = $5 AND price_low = $6 AND price_close = $7 AND volume_from = $8 AND volume_to = $9' ;
                 EXECUTE sz_query_is_record_nochanged INTO STRICT cntEditString_nochanged USING rec_source_ohlcv.currency, rec_source_ohlcv.reference_currency, rec_source_ohlcv.timestamp_point,
                         rec_source_ohlcv.price_open, rec_source_ohlcv.price_high, rec_source_ohlcv.price_low, rec_source_ohlcv.price_close, rec_source_ohlcv.volume_from, rec_source_ohlcv.volume_to ;
-- если строка есть, значения проверили и они те же - ничего не делаем
-- если строка есть, значения проверили и они отличаются - обновляем строку
                 IF cntEditString_nochanged = 0 THEN
                    sz_query_modify_record := 'UPDATE '||sz_target_table_name||' SET change_ts = now(), price_open = $1, price_high = $2, price_low = $3, price_close = $4, volume_from = $5, volume_to = $6
                                     WHERE currency = $7 AND reference_currency = $8 AND timestamp_point = $9' ;
                    EXECUTE sz_query_modify_record USING rec_source_ohlcv.price_open, rec_source_ohlcv.price_high, rec_source_ohlcv.price_low, rec_source_ohlcv.price_close,
                            rec_source_ohlcv.volume_from, rec_source_ohlcv.volume_to, rec_source_ohlcv.currency, rec_source_ohlcv.reference_currency, rec_source_ohlcv.timestamp_point ;
                 END IF ; -- конец если строка не изменялась
-- если строки нет - просто ее добавляем
              ELSE -- если строка с такими метаданными НЕ существует - вставить
                 sz_query_insert_record := 'insert into '||sz_target_table_name||' (change_ts, currency, reference_currency, timestamp_point, price_open, price_high, price_low, price_close, volume_from, volume_to)
                          values (now(), $1, $2, $3, $4, $5, $6, $7, $8, $9)' ;
                 EXECUTE sz_query_insert_record USING rec_source_ohlcv.currency, rec_source_ohlcv.reference_currency, rec_source_ohlcv.timestamp_point, rec_source_ohlcv.price_open,
                         rec_source_ohlcv.price_high, rec_source_ohlcv.price_low, rec_source_ohlcv.price_close, rec_source_ohlcv.volume_from, rec_source_ohlcv.volume_to ;
             END IF ; -- конец если строка с такими метаданными уже существует
          END IF ; -- конец если записи попадают в целевые и обрабатываются
       END LOOP ; -- конец перебора записей в цикле
-- -----------------------------------
-- инициализируем "хвост"
-- -----------------------------------
-- для последней записи в выборке строки проверить соответсвие фильтру попадания в "хвост" агрегационной выборки
       IF ( v_tail_calculate = true and
            (( v_time_frame = '4W'  AND NOT rec_source_ohlcv.days = 1 ) OR
             ( v_time_frame = '1W'  AND NOT rec_source_ohlcv.days IN (1,8,15,22,29) ) OR
             ( v_time_frame = '4D'  AND NOT rec_source_ohlcv.days IN (1,5,9,13,17,21,25,29) ) OR
             ( v_time_frame = '2D'  AND NOT rec_source_ohlcv.days IN (1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31) ) OR
             ( v_time_frame = '12H' AND (NOT rec_source_ohlcv.days IN (1,13) OR NOT rec_source_ohlcv.minutes = 0) ) OR
             ( v_time_frame = '8H'  AND (NOT rec_source_ohlcv.days IN (1,9,17) OR NOT rec_source_ohlcv.minutes = 0) ) OR
             ( v_time_frame = '4H'  AND (NOT rec_source_ohlcv.days IN (1,5,9,13,17,21) OR NOT rec_source_ohlcv.minutes = 0) ) OR
             ( v_time_frame = '3H'  AND (NOT rec_source_ohlcv.days IN (1,3,7,10,13,16,19,22) OR NOT rec_source_ohlcv.minutes = 0) ) OR
             ( v_time_frame = '2H'  AND (NOT rec_source_ohlcv.days IN (1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47,49,51,53,55,57,59) OR NOT rec_source_ohlcv.minutes = 0) ) OR
             ( v_time_frame = '1H'  AND NOT rec_source_ohlcv.minutes = 0 ) OR
             ( v_time_frame = '30M' AND NOT rec_source_ohlcv.minutes IN (0,30) ) OR
             ( v_time_frame = '15M' AND NOT rec_source_ohlcv.minutes IN (0,15,30,45) ) OR
             ( v_time_frame = '10M' AND NOT rec_source_ohlcv.minutes IN (0,10,20,30,40,50) ) OR
             ( v_time_frame = '5M'  AND NOT rec_source_ohlcv.minutes IN (0,5,10,15,20,25,30,35,40,45,50,55) ) OR
             ( v_time_frame = '3M'  AND NOT rec_source_ohlcv.minutes IN (0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51,54,57) ) ) ) THEN
          insert into cragran_logs values(clock_timestamp(),'rtsp_analyze','fn_fill_retrospective_ohlcv_tables','- [start] '||v_currency||'/'||v_reference_currency||' ТФ'||v_time_frame||' заполнение ретроспективных данных OHLC, хвост учитываем, записи в диапазоне '||v_time_start||' - '||v_time_stop) ;
          cnt_dataset_filtered := cnt_dataset_filtered + 1 ;
-- !!! удалить записи с флагом хвоста для данной пары 
          cntEditString := 0 ;
          sz_query_is_record_exist := 'SELECT count(*) FROM '||sz_target_table_name||' WHERE currency = $1 AND reference_currency = $2 AND timestamp_point = $3' ;
          EXECUTE sz_query_is_record_exist INTO STRICT cntEditString USING rec_source_ohlcv.currency, rec_source_ohlcv.reference_currency, rec_source_ohlcv.timestamp_point ;
-- если строка есть - проверяем ее значения
          IF cntEditString > 0 THEN
             cntEditString_nochanged := 0 ;
             sz_query_is_record_nochanged := 'SELECT count(*) FROM '||sz_target_table_name||' WHERE currency = $1 AND reference_currency = $2 AND timestamp_point = $3
                          AND price_open = $4 AND price_high = $5 AND price_low = $6 AND price_close = $7 AND volume_from = $8 AND volume_to = $9' ;
             EXECUTE sz_query_is_record_nochanged INTO STRICT cntEditString_nochanged USING rec_source_ohlcv.currency, rec_source_ohlcv.reference_currency, rec_source_ohlcv.timestamp_point,
                     rec_source_ohlcv.price_open, rec_source_ohlcv.price_high, rec_source_ohlcv.price_low, rec_source_ohlcv.price_close, rec_source_ohlcv.volume_from, rec_source_ohlcv.volume_to ;
-- если строка есть, значения проверили и они те же - ничего не делаем
-- если строка есть, значения проверили и они отличаются - обновляем строку
            IF cntEditString_nochanged = 0 THEN
                sz_query_modify_record := 'UPDATE '||sz_target_table_name||' SET change_ts = now(), price_open = $1, price_high = $2, price_low = $3, price_close = $4, volume_from = $5, volume_to = $6
                                 WHERE currency = $7 AND reference_currency = $8 AND timestamp_point = $9' ;
                EXECUTE sz_query_modify_record USING rec_source_ohlcv.price_open, rec_source_ohlcv.price_high, rec_source_ohlcv.price_low, rec_source_ohlcv.price_close,
                        rec_source_ohlcv.volume_from, rec_source_ohlcv.volume_to, rec_source_ohlcv.currency, rec_source_ohlcv.reference_currency, rec_source_ohlcv.timestamp_point ;
             END IF ; -- конец если строка не изменялась
-- если строки нет - просто ее добавляем
          ELSE -- если строка с такими метаданными НЕ существует - вставить
             sz_query_insert_record := 'insert into '||sz_target_table_name||' (change_ts, currency, reference_currency, timestamp_point, price_open, price_high, price_low, price_close, volume_from, volume_to)
                      values (now(), $1, $2, $3, $4, $5, $6, $7, $8, $9)' ;
             EXECUTE sz_query_insert_record USING rec_source_ohlcv.currency, rec_source_ohlcv.reference_currency, rec_source_ohlcv.timestamp_point, rec_source_ohlcv.price_open,
                     rec_source_ohlcv.price_high, rec_source_ohlcv.price_low, rec_source_ohlcv.price_close, rec_source_ohlcv.volume_from, rec_source_ohlcv.volume_to ;
          END IF ; -- конец если строка с такими метаданными уже существует
       ELSE
          insert into cragran_logs values(clock_timestamp(),'rtsp_analyze','fn_fill_retrospective_ohlcv_tables','- [start] '||v_currency||'/'||v_reference_currency||' ТФ'||v_time_frame||' заполнение ретроспективных данных OHLC, хвост не учитываем, записи в диапазоне '||v_time_start||' - '||v_time_stop) ;
       END IF ; -- конец условия попадания записи в "хвост"
       insert into cragran_logs values(clock_timestamp(),'rtsp_analyze','fn_fill_retrospective_ohlcv_tables','- [stop] '||v_currency||'/'||v_reference_currency||' ТФ'||v_time_frame||' заполнение ретроспективных данных OHLC, записей получено '||cnt_dataset||', записей отфильтровано '||cnt_dataset_filtered||', записи в диапазоне '||v_time_start||' - '||v_time_stop) ;
END ;
$BODY$;

ALTER FUNCTION public.fn_fill_retrospective_ohlcv_tables(character varying, character varying, character varying, timestamp without time zone, timestamp without time zone, boolean)
    OWNER TO crypta;

-- ======================================================================================================================================
-- процедура - драйвер для послойного заполнения таблиц ретроспективных OHLC - через основную функцию
-- ======================================================================================================================================

-- DROP PROCEDURE IF EXISTS public.fn_driver_fill_retrospective_ohlcv_tables(character varying);
CREATE OR REPLACE PROCEDURE public.fn_driver_fill_retrospective_ohlcv_tables(
    IN v_period_mode character varying)
LANGUAGE 'plpgsql'
AS $BODY$
       DECLARE
       rec_source_ohlcv   RECORD ;
       sz_time_period     VARCHAR ;
       sz_time_frame_list VARCHAR[16] := '{"1M","3M","5M","10M","15M","30M","1H","2H","3H","4H","8H","12H","1D","2D","4D","1W","4W"}' ;
--       sz_time_frame_list VARCHAR[16] := '{"30M","15M"}' ;
       sz_time_frame      VARCHAR ;
-- v_time_after timestamp without time zone) ;
       v_minutes_reduce_interval timestamp without time zone ;
       v_minutes_grow_interval timestamp without time zone ;
       v_hours_reduce_interval timestamp without time zone ;
       v_hours_grow_interval timestamp without time zone ;
       v_days_reduce_interval timestamp without time zone ;
       v_days_grow_interval timestamp without time zone ;
       BEGIN
-- выставляем переменные периодов в зависимости от выбранного режима работы        
       v_minutes_reduce_interval = clock_timestamp() - INTERVAL '2 days' ; v_minutes_grow_interval = clock_timestamp() + INTERVAL '32 days' ;
       v_hours_reduce_interval = clock_timestamp() - INTERVAL '2 days' ; v_hours_grow_interval = clock_timestamp() + INTERVAL '32 days' ;
       v_days_reduce_interval = clock_timestamp() - INTERVAL '2 days' ; v_days_grow_interval = clock_timestamp() + INTERVAL '32 days' ;
       if (v_period_mode = 'operative') then
          v_minutes_reduce_interval = clock_timestamp() - INTERVAL '30 minutes' ; v_minutes_grow_interval = clock_timestamp() + INTERVAL '20 minutes' ;
          v_hours_reduce_interval = clock_timestamp() - INTERVAL '15 hours' ; v_hours_grow_interval = clock_timestamp() + INTERVAL '15 hours' ;
          v_days_reduce_interval = clock_timestamp() - INTERVAL '5 days' ; v_days_grow_interval = clock_timestamp() + INTERVAL '5 days' ;
          end if ;
       if (v_period_mode = 'gap_2_days') then
          v_minutes_reduce_interval = clock_timestamp() - INTERVAL '50 hours' ; v_minutes_grow_interval =  clock_timestamp() + INTERVAL '3 hours' ;
          v_hours_reduce_interval = clock_timestamp() - INTERVAL '50 hours' ; v_hours_grow_interval =  clock_timestamp() + INTERVAL '3 hours' ;
          v_days_reduce_interval = clock_timestamp() - INTERVAL '50 hours' ; v_days_grow_interval =  clock_timestamp() + INTERVAL '3 hours' ;
          end if ;
       if (v_period_mode = 'gap_2_months') then
          v_minutes_reduce_interval = clock_timestamp() - INTERVAL '62 days' ; v_minutes_grow_interval =  clock_timestamp() + INTERVAL '2 days' ;
          v_hours_reduce_interval = clock_timestamp() - INTERVAL '62 days' ; v_hours_grow_interval =  clock_timestamp() + INTERVAL '2 days' ;
          v_days_reduce_interval = clock_timestamp() - INTERVAL '62 days' ; v_days_grow_interval =  clock_timestamp() + INTERVAL '2 days' ;
          end if ;
-- обрабатываем записи из таблицы источника в 1 минуту
       if (v_period_mode = 'all') then
          for sz_time_period in select src.tsp from (select date_trunc('month',timestamp_point) tsp from crcomp_pair_OHLC_1M_history) src group by src.tsp order by 1 asc LOOP
              for rec_source_ohlcv in select currency, reference_currency from crcomp_pair_OHLC_1M_history group by currency, reference_currency order by 1,2 LOOP
                  for sz_time_frame IN 1..6 LOOP
                  --for sz_time_frame IN 1..2 LOOP 
                      insert into cragran_logs values(clock_timestamp(),'rtsp_analyze','fn_driver_fill_retrospective_ohlcv_tables','[start driver] '||rec_source_ohlcv.currency||'/'||rec_source_ohlcv.reference_currency||' ТФ'||sz_time_frame_list[sz_time_frame]||' заполнение ретроспективных данных OHLC, точка привязки диапазона дат '||sz_time_period) ;
                      perform fn_fill_retrospective_ohlcv_tables(rec_source_ohlcv.currency,rec_source_ohlcv.reference_currency,sz_time_frame_list[sz_time_frame], CAST(TO_TIMESTAMP(sz_time_period,'YYYY-MM-DD HH24:MI:SS') AS timestamp without time zone) - INTERVAL '2 days', CAST(TO_TIMESTAMP(sz_time_period,'YYYY-MM-DD HH24:MI:SS') AS timestamp without time zone) + INTERVAL '32 days', false ) ;
                      commit ;
                   END LOOP ;
--           return next sz_time_period||rec_source_ohlcv.currency||rec_source_ohlcv.reference_currency ;
              END loop ;
              commit ;
          END loop ;
          end if ;
       if (v_period_mode = 'operative' OR v_period_mode = 'gap_2_days' OR v_period_mode = 'gap_2_months') then
          for rec_source_ohlcv in select currency, reference_currency from crcomp_pair_OHLC_1M_history group by currency, reference_currency order by 1,2 LOOP
              for sz_time_frame IN 1..6 LOOP
                  insert into cragran_logs values(clock_timestamp(),'rtsp_analyze','fn_driver_fill_retrospective_ohlcv_tables','[start driver] '||rec_source_ohlcv.currency||'/'||rec_source_ohlcv.reference_currency||' ТФ'||sz_time_frame_list[sz_time_frame]||' заполнение ретроспективных данных OHLC, точка привязки диапазона дат '||sz_time_period) ;
                  perform fn_fill_retrospective_ohlcv_tables(rec_source_ohlcv.currency,rec_source_ohlcv.reference_currency,sz_time_frame_list[sz_time_frame], v_minutes_reduce_interval, v_minutes_grow_interval, false ) ;
                  commit ;
              END LOOP ;
--           return next sz_time_period||rec_source_ohlcv.currency||rec_source_ohlcv.reference_currency ;
           commit ;
           END loop ;
           end if ;
-- обрабатываем записи из таблицы источника в 1 час
       if (v_period_mode = 'all') then
          for sz_time_period in select src.tsp from (select date_trunc('month',timestamp_point) tsp from crcomp_pair_OHLC_1H_history) src group by src.tsp order by 1 asc LOOP
              for rec_source_ohlcv in select currency, reference_currency from crcomp_pair_OHLC_1H_history group by currency, reference_currency order by 1,2 LOOP
                  for sz_time_frame IN 7..12 LOOP
                      insert into cragran_logs values(clock_timestamp(),'rtsp_analyze','fn_driver_fill_retrospective_ohlcv_tables','[start driver] '||rec_source_ohlcv.currency||'/'||rec_source_ohlcv.reference_currency||' ТФ'||sz_time_frame_list[sz_time_frame]||' заполнение ретроспективных данных OHLC, точка привязки диапазона дат '||sz_time_period) ;
                      perform fn_fill_retrospective_ohlcv_tables(rec_source_ohlcv.currency,rec_source_ohlcv.reference_currency,sz_time_frame_list[sz_time_frame], CAST(TO_TIMESTAMP(sz_time_period,'YYYY-MM-DD HH24:MI:SS') AS timestamp without time zone) - INTERVAL '2 days', CAST(TO_TIMESTAMP(sz_time_period,'YYYY-MM-DD HH24:MI:SS') AS timestamp without time zone) + INTERVAL '32 days', false ) ;
                      commit ;
                  END LOOP ;
              END loop ;
              commit ;
          END loop ;
          end if ;
       if (v_period_mode = 'operative' OR v_period_mode = 'gap_2_days' OR v_period_mode = 'gap_2_months') then
          for rec_source_ohlcv in select currency, reference_currency from crcomp_pair_OHLC_1H_history group by currency, reference_currency order by 1,2 LOOP
              for sz_time_frame IN 7..12 LOOP
                  insert into cragran_logs values(clock_timestamp(),'rtsp_analyze','fn_driver_fill_retrospective_ohlcv_tables','[start driver] '||rec_source_ohlcv.currency||'/'||rec_source_ohlcv.reference_currency||' ТФ'||sz_time_frame_list[sz_time_frame]||' заполнение ретроспективных данных OHLC, точка привязки диапазона дат '||sz_time_period) ;
                  perform fn_fill_retrospective_ohlcv_tables(rec_source_ohlcv.currency,rec_source_ohlcv.reference_currency,sz_time_frame_list[sz_time_frame], v_hours_reduce_interval, v_hours_grow_interval, false ) ;
                  commit ;
              END LOOP ;
              commit ;
          END loop ;
          end if ;
-- обрабатываем записи из таблицы источника в 1 день
       if (v_period_mode = 'all') then
          for sz_time_period in select src.tsp from (select date_trunc('month',timestamp_point) tsp from crcomp_pair_OHLC_1D_history) src group by src.tsp order by 1 asc LOOP
              for rec_source_ohlcv in select currency, reference_currency from crcomp_pair_OHLC_1D_history group by currency, reference_currency order by 1,2 LOOP
                  for sz_time_frame IN 13..17 LOOP
                      insert into cragran_logs values(clock_timestamp(),'rtsp_analyze','fn_driver_fill_retrospective_ohlcv_tables','[start driver] '||rec_source_ohlcv.currency||'/'||rec_source_ohlcv.reference_currency||' ТФ'||sz_time_frame_list[sz_time_frame]||' заполнение ретроспективных данных OHLC, точка привязки диапазона дат '||sz_time_period) ;
                      perform fn_fill_retrospective_ohlcv_tables(rec_source_ohlcv.currency,rec_source_ohlcv.reference_currency,sz_time_frame_list[sz_time_frame], CAST(TO_TIMESTAMP(sz_time_period,'YYYY-MM-DD HH24:MI:SS') AS timestamp without time zone) - INTERVAL '2 days', CAST(TO_TIMESTAMP(sz_time_period,'YYYY-MM-DD HH24:MI:SS') AS timestamp without time zone) + INTERVAL '32 days', false ) ;
                      commit ;
                  END LOOP ;
              END loop ;
              commit ;
          END loop ;
          end if ;
       if (v_period_mode = 'operative' OR v_period_mode = 'gap_2_days' OR v_period_mode = 'gap_2_months') then
       for rec_source_ohlcv in select currency, reference_currency from crcomp_pair_OHLC_1D_history group by currency, reference_currency order by 1,2 LOOP
           for sz_time_frame IN 13..17 LOOP
               insert into cragran_logs values(clock_timestamp(),'rtsp_analyze','fn_driver_fill_retrospective_ohlcv_tables','[start driver] '||rec_source_ohlcv.currency||'/'||rec_source_ohlcv.reference_currency||' ТФ'||sz_time_frame_list[sz_time_frame]||' заполнение ретроспективных данных OHLC, точка привязки диапазона дат '||sz_time_period) ;
               perform fn_fill_retrospective_ohlcv_tables(rec_source_ohlcv.currency,rec_source_ohlcv.reference_currency,sz_time_frame_list[sz_time_frame], v_days_reduce_interval, v_days_grow_interval, false ) ;
               commit ;
               END LOOP ;
           commit ;
           END loop ;
           end if ;
END ;
$BODY$;
ALTER PROCEDURE public.fn_driver_fill_retrospective_ohlcv_tables(character varying)
    OWNER TO crypta;

select 1, '1m', count(*) from rtrsp_ohlc_1m_history 
union all select 2, '3m', count(*) from rtrsp_ohlc_3m_history
union all select 3, '5m', count(*) from  rtrsp_ohlc_5m_history
union all select 4, '10m', count(*)  from  rtrsp_ohlc_10m_history
union all select 5, '15m', count(*)  from  rtrsp_ohlc_15m_history
union all select 6, '30m', count(*)  from  rtrsp_ohlc_30m_history
union all select 7, '1h', count(*)  from  rtrsp_ohlc_1h_history
union all select 8, '2h', count(*) from  rtrsp_ohlc_2h_history
union all select 9, '3h', count(*)  from  rtrsp_ohlc_3h_history
union all select 10, '4h', count(*)  from  rtrsp_ohlc_4h_history
union all select 11, '8h', count(*)  from  rtrsp_ohlc_8h_history
union all select 12, '12h', count(*)  from  rtrsp_ohlc_12h_history
union all select 13, '1d', count(*)  from  rtrsp_ohlc_1d_history
union all select 14, '2d', count(*)  from  rtrsp_ohlc_2d_history
union all select 15, '4d', count(*)  from  rtrsp_ohlc_4d_history
union all select 16, '1w', count(*)  from  rtrsp_ohlc_1w_history
union all select 17, '4w', count(*)  from  rtrsp_ohlc_4w_history order by 1 ;


select '1M','3M','5M','10M','15M','30M','1H','2H','3H','4H','8H','12H','1D','2D','4D','1W','4W' ;
select src.tsp from (select date_trunc('month',timestamp_point) tsp from crcomp_pair_OHLC_1M_history) src group by src.tsp order by 1 desc
select date_trunc('month',timestamp_point) from crcomp_pair_OHLC_1M_history order by 1 desc ;

-- похоже в 9 версии нет -- begin 
CALL fn_driver_fill_retrospective_ohlcv_tables('all_убрать_суффикс') ;


-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.12 конец -- таблицы ретроспективных цен и функции заполнения
-- ---------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.13 начало -- таблицы ASH статистик и функции заполнения
-- ---------------------------------------------------------------------------------------------------------------------------

-- таблица для сохранения посекундной агрегации из wait sampling взамен устаревшей besst_stat_ash_history
CREATE TABLE IF NOT EXISTS public.bestat_ws_history (
       ts           timestamp with time zone,
       pid          integer,
       event_type   text,
       event        text,
       queryid      bigint,
       events_count bigint ) ;

CREATE INDEX IF NOT EXISTS bestat_ws_history_idx_on_ts_01 ON public.bestat_ws_history (ts) ;
CREATE INDEX IF NOT EXISTS bestat_ws_history_idx_on_ts_eventtype_01 ON public.bestat_ws_history (ts, event_type) ;

CREATE OR REPLACE PROCEDURE public.bestat_fill_ws_history()
       LANGUAGE 'plpgsql'
       AS $BODY$
begin
MERGE INTO public.bestat_ws_history bswsh
      USING (select date_trunc('second',ts) ts, pid, event_type, event, queryid, count(*) events_count
                    from public.pg_wait_sampling_history
                    group by date_trunc('second',ts), pid, event_type, event, queryid
                    order by date_trunc('second',ts), pid, event_type, event, queryid) pwsh
      ON bswsh.pid = pwsh.pid AND bswsh.ts = pwsh.ts AND bswsh.event_type = pwsh.event_type
         AND bswsh.event = pwsh.event AND bswsh.queryid = pwsh.queryid
      WHEN NOT MATCHED THEN
           INSERT (ts, pid, event_type, event, queryid, events_count)
                  VALUES (pwsh.ts, pwsh.pid, pwsh.event_type, pwsh.event, pwsh.queryid, pwsh.events_count) ;
end ;
$BODY$;

CALL bestat_fill_ws_history() ;
select * from bestat_ws_history ;
delete from bestat_ws_history ;
commit ;

-- DROP TABLE IF EXISTS public.bestat_sa_history;
CREATE TABLE IF NOT EXISTS public.bestat_sa_history(
       sampling_time timestamp with time zone,
       datid oid,
       datname name,
       pid integer,
       leader_pid integer,
       usesysid oid,
       usename name,
       application_name text,
       client_addr inet,
       client_hostname text,
       client_port integer,
       backend_start timestamp with time zone,
       xact_start timestamp with time zone,
       query_start timestamp with time zone,
       state_change timestamp with time zone,
       wait_event_type text,
       wait_event text,
       state text,
       backend_xid xid,
       backend_xmin xid,
       query_id bigint,
       backend_type text) TABLESPACE pg_default ;

-- DROP INDEX IF EXISTS public.bestat_sa_history_idx_on_st_01;
CREATE INDEX IF NOT EXISTS bestat_sa_history_idx_on_st_01 ON public.bestat_sa_history USING btree (sampling_time ASC NULLS LAST) TABLESPACE pg_default ;

-- DROP INDEX IF EXISTS public.bestat_sa_history_idx_on_st_wet_01;
CREATE INDEX IF NOT EXISTS bestat_sa_history_idx_on_st_wet_01 ON public.bestat_sa_history USING btree (sampling_time ASC NULLS LAST, wait_event_type COLLATE pg_catalog."default" ASC NULLS LAST) TABLESPACE pg_default ;

-- DROP TABLE IF EXISTS public.bestat_sa_history_parameters;
CREATE TABLE IF NOT EXISTS public.bestat_sa_history_parameters(
       sz_parameter character varying,
       sz_value character varying
       ) TABLESPACE pg_default ;

-- DROP PROCEDURE IF EXISTS public.bestat_fill_sa_history(integer);
CREATE OR REPLACE PROCEDURE public.bestat_fill_sa_history(
    IN v_iteration integer)
LANGUAGE 'plpgsql'
AS $BODY$
declare
v_Count INTEGER ;
sz_is_collect VARCHAR ;
v_insert_timestamp TIMESTAMP ;
begin
v_Count := 0 ;
while (v_Count < v_Iteration) LOOP
      if (v_Count = (v_Iteration - 1)) then
         commit ;
         select sz_value into sz_is_collect from bestat_sa_history_parameters where sz_parameter = 'is_collect' ;
         if sz_is_collect = 'yes' then v_Count := 0 ;
            else v_count := v_Iteration + 10 ;
            end if ;
         end if ;
      v_insert_timestamp := clock_timestamp() ;
      insert into bestat_sa_history
             (SELECT v_insert_timestamp, datid, datname, pid, leader_pid, usesysid, usename,
                     application_name, client_addr, client_hostname, client_port, backend_start, xact_start,
                     query_start, state_change, wait_event_type, wait_event, state, backend_xid, backend_xmin,
                     query_id, backend_type
                     from pg_stat_activity) ;
      v_Count = v_Count + 1 ;
      perform pg_sleep(1) ;
      end LOOP ;
end ;
$BODY$;
ALTER PROCEDURE public.bestat_fill_sa_history(integer)
    OWNER TO crypta;

-----------------
-- устаревшие ---
-----------------


-- таблицы моего SAH-агрегатора (stats activity history)
-- DROP TABLE IF EXISTS public.bestat_sah;
CREATE TABLE IF NOT EXISTS public.bestat_sah (
    sampling_time timestamp with time zone,
    datid oid,
    datname name COLLATE pg_catalog."C",
    pid integer,
    leader_pid integer,
    usesysid oid,
    usename name COLLATE pg_catalog."C",
    application_name text COLLATE pg_catalog."default",
    client_addr inet,
    client_hostname text COLLATE pg_catalog."default",
    client_port integer,
    backend_start timestamp with time zone,
    xact_start timestamp with time zone,
    query_start timestamp with time zone,
    state_change timestamp with time zone,
    wait_event_type text COLLATE pg_catalog."default",
    wait_event text COLLATE pg_catalog."default",
    state text COLLATE pg_catalog."default",
    backend_xid xid,
    backend_xmin xid,
    query_id bigint,
    backend_type text COLLATE pg_catalog."default"
    ) ;

-- DROP INDEX IF EXISTS public.bestat_sah_idx_on_st_01;
CREATE INDEX IF NOT EXISTS bestat_sah_idx_on_st_01 ON public.bestat_sah (sampling_time) ;
-- DROP INDEX IF EXISTS public.bestat_sah_idx_on_st_wet_01;
CREATE INDEX IF NOT EXISTS bestat_sah_idx_on_st_wet_01 ON public.bestat_sah (sampling_time, wait_event_type) ;

-- DROP PROCEDURE IF EXISTS public.bestat_fill_sah(integer);

CREATE OR REPLACE PROCEDURE public.bestat_fill_sah(IN v_iteration integer)
       LANGUAGE 'plpgsql'
AS $BODY$
declare
v_Count            INTEGER ;
sz_is_collect      VARCHAR ;
v_insert_timestamp TIMESTAMP ;
begin
v_Count := 0 ;
while (v_Count < v_Iteration) LOOP
      if (v_Count = (v_Iteration - 1)) then
         commit ;
         select sz_value into sz_is_collect from bestat_SAH_parameters where sz_parameter = 'is_collect' ;
         if sz_is_collect = 'yes' then v_Count := 0 ;
            else v_count := v_Iteration + 10 ; 
            end if ;
         end if ;
      v_insert_timestamp := clock_timestamp() ;
      insert into bestat_SAH
             (SELECT v_insert_timestamp, datid, datname, pid, leader_pid, usesysid, usename,
                     application_name, client_addr, client_hostname, client_port, backend_start, xact_start,
                     query_start, state_change, wait_event_type, wait_event, state, backend_xid, backend_xmin,
                     query_id, backend_type
                     from pg_stat_activity) ;
      v_Count = v_Count + 1 ;
      perform pg_sleep(1) ;
      end LOOP ;
end ;
$BODY$;

-- DROP TABLE IF EXISTS public.besst_stat_ash_history;
CREATE TABLE IF NOT EXISTS public.besst_stat_ash_history (
    pid integer,
    ts timestamp with time zone,
    event_type text COLLATE pg_catalog."default",
    event text COLLATE pg_catalog."default",
    queryid bigint ) TABLESPACE pg_default ;

ALTER TABLE IF EXISTS public.besst_stat_ash_history OWNER to crypta ;

-- DROP PROCEDURE IF EXISTS public.besst_stat_fill_ash_table();
CREATE OR REPLACE PROCEDURE public.besst_stat_fill_ash_table()
LANGUAGE 'plpgsql'
AS $BODY$
begin
MERGE INTO public.besst_stat_ash_history bsah
      USING public.pg_wait_sampling_history pwsh
      ON bsah.pid = pwsh.pid AND bsah.ts = pwsh.ts
      WHEN NOT MATCHED THEN
           INSERT (pid, ts, event_type, event, queryid)
                  VALUES (pwsh.pid, pwsh.ts, pwsh.event_type, pwsh.event, pwsh.queryid) ;
end ;
$BODY$ ;
ALTER PROCEDURE public.besst_stat_fill_ash_table() OWNER TO crypta;

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.13 конец -- таблицы ASH статистик и функции заполнения
-- ---------------------------------------------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.14 начало -- таблицы и функции заполнения ретроспективного RSI
-- ---------------------------------------------------------------------------------------------------------------------------

-- таблица переделана с указанием разрядности полей numeric(42,21) - без этого таблица росла безумно

-- #######################################################################################################################################
-- Итерация 3. начало блока заполнения через merge, но с округлением значений ROUND(xxx,21)
-- #######################################################################################################################################
-- DROP TABLE IF EXISTS rtrsp_rsi_history CASCADE ;
CREATE TABLE IF NOT EXISTS rtrsp_rsi_history (
       currency character varying(100),
       reference_currency character varying(100),
       timestamp_point timestamp without time zone,
       time_frame character varying(10),
       indicator_periods integer,
       price_close numeric(42,21),
       price_close_pre numeric(42,21),
       change_up_val numeric(42,21),
       change_down_val numeric(42,21),
       up_rma numeric(42,21),
       down_rma numeric(42,21),
       rs numeric(42,21),
       rsi numeric(7,3),
       change_ts timestamp without time zone,
       PRIMARY KEY (currency, reference_currency, timestamp_point, time_frame, indicator_periods) ) ;

-- DROP FUNCTION IF EXISTS public.fn_rtrsp_calck_rsi_as_table(numeric, character varying, character varying, character varying, timestamp without time zone, timestamp without time zone);
CREATE OR REPLACE FUNCTION public.fn_rtrsp_calck_rsi_as_table(
    v_indicator_periods integer,
    v_currency character varying,
    v_reference_currency character varying,
    v_time_frame character varying,
    v_time_start timestamp without time zone,
    v_time_stop timestamp without time zone)
    RETURNS SETOF rtrsp_rsi_history
    LANGUAGE 'plpgsql'
AS $BODY$
    DECLARE
       result_record           rtrsp_RSI_history%ROWTYPE ;
       sz_base_cursor_request  VARCHAR ;
       sz_request_table_name   VARCHAR ;
       ds_price_changes        RECORD ;
       v_ds_up_rma             NUMERIC ;
       v_ds_up_rma_old         NUMERIC ;
       v_ds_down_rma           NUMERIC ;
       v_ds_down_rma_old       NUMERIC ;
       v_ds_RS                 NUMERIC ;
       v_ds_RSI                NUMERIC ;
       BEGIN
       v_ds_up_rma := 0.0 ; v_ds_up_rma_old := 0.0 ; v_ds_down_rma := 0.0 ; v_ds_down_rma_old := 0.0 ; v_ds_RS := 0.0 ; v_ds_RSI := 0.0 ;
       --sz_request_table_name := 'rtrsp_ohlc_30m_history' ;
       IF (v_time_frame = '4W')  THEN sz_request_table_name := 'rtrsp_ohlc_4w_history' ;  END IF ;
       IF (v_time_frame = '1W')  THEN sz_request_table_name := 'rtrsp_ohlc_1w_history' ;  END IF ;
       IF (v_time_frame = '4D')  THEN sz_request_table_name := 'rtrsp_ohlc_4d_history' ;  END IF ;
       IF (v_time_frame = '2D')  THEN sz_request_table_name := 'rtrsp_ohlc_2d_history' ;  END IF ;
       IF (v_time_frame = '1D')  THEN sz_request_table_name := 'rtrsp_ohlc_1d_history' ;  END IF ;
       IF (v_time_frame = '12H') THEN sz_request_table_name := 'rtrsp_ohlc_12h_history' ; END IF ;
       IF (v_time_frame = '8H')  THEN sz_request_table_name := 'rtrsp_ohlc_8h_history' ;  END IF ;
       IF (v_time_frame = '4H')  THEN sz_request_table_name := 'rtrsp_ohlc_4h_history' ;  END IF ;
       IF (v_time_frame = '3H')  THEN sz_request_table_name := 'rtrsp_ohlc_3h_history' ;  END IF ;
       IF (v_time_frame = '2H')  THEN sz_request_table_name := 'rtrsp_ohlc_2h_history' ;  END IF ;
       IF (v_time_frame = '1H')  THEN sz_request_table_name := 'rtrsp_ohlc_1h_history' ;  END IF ;
       IF (v_time_frame = '30M') THEN sz_request_table_name := 'rtrsp_ohlc_30m_history' ; END IF ;
       IF (v_time_frame = '15M') THEN sz_request_table_name := 'rtrsp_ohlc_15m_history' ; END IF ;
       IF (v_time_frame = '10M') THEN sz_request_table_name := 'rtrsp_ohlc_10m_history' ; END IF ;
       IF (v_time_frame = '5M')  THEN sz_request_table_name := 'rtrsp_ohlc_5m_history' ;  END IF ;
       IF (v_time_frame = '3M')  THEN sz_request_table_name := 'rtrsp_ohlc_3m_history' ;  END IF ;
       IF (v_time_frame = '1M')  THEN sz_request_table_name := 'rtrsp_ohlc_1m_history' ;  END IF ;

       sz_base_cursor_request := 'select rownum, currency, reference_currency, timestamp_point, price_close, price_close_pre,
                     CASE WHEN (ROWNUM = 0 OR (price_close - price_close_pre) <= 0) THEN 0
                          ELSE price_close - price_close_pre END change_up_val,
                     CASE WHEN (ROWNUM = 0 OR (price_close_pre - price_close) <= 0) THEN 0
                          ELSE price_close_pre - price_close END change_down_val
                     from (select row_number() over () rownum, currency, reference_currency, timestamp_point, price_close,
                                  LAG(price_close, 1) OVER (PARTITION BY currency, reference_currency
                                                           ORDER BY timestamp_point asc) price_close_pre
                                  from '||sz_request_table_name||' where currency = $1 AND reference_currency = $2 and 
                                        timestamp_point >= $3 AND timestamp_point <= $4
                                  ORDER BY currency, reference_currency, timestamp_point asc ) src1' ;
       FOR ds_price_changes IN EXECUTE sz_base_cursor_request USING v_currency, v_reference_currency, v_time_start, v_time_stop LOOP
-- расчёт по строкам dataset
           v_ds_up_rma := 0 ; v_ds_down_rma := 0 ; v_ds_RS := 0 ; v_ds_RSI := 0 ;
           IF (ds_price_changes.rownum = 2) THEN v_ds_up_rma := ds_price_changes.change_up_val ; v_ds_down_rma := ds_price_changes.change_down_val ; END IF ;
           IF (ds_price_changes.rownum > 2)
              THEN v_ds_up_rma   := (ds_price_changes.change_up_val   * (1 / v_indicator_periods::NUMERIC )) + (v_ds_up_rma_old::NUMERIC   * (1 - (1 / v_indicator_periods::NUMERIC)) ) ;
                   v_ds_down_rma := (ds_price_changes.change_down_val * (1 / v_indicator_periods::NUMERIC )) + (v_ds_down_rma_old::NUMERIC * (1 - (1 / v_indicator_periods::NUMERIC)) ) ;
                   END IF ;
           IF v_ds_down_rma = 0 THEN v_ds_RS := 1 ; ELSE v_ds_RS := v_ds_up_rma / v_ds_down_rma::NUMERIC ; END IF ;
           v_ds_RSI := 100 - (100 / (1 + v_ds_RS::NUMERIC)) ;
           result_record.currency           := ds_price_changes.currency ;
           result_record.reference_currency := ds_price_changes.reference_currency ;
           result_record.timestamp_point    := ds_price_changes.timestamp_point ;
           result_record.time_frame         := v_time_frame ;
           result_record.indicator_periods  := v_indicator_periods ;
           result_record.price_close        := ROUND(ds_price_changes.price_close, 21) ;
           result_record.price_close_pre    := ROUND(ds_price_changes.price_close_pre, 21) ;
           result_record.change_up_val      := ROUND(ds_price_changes.change_up_val, 21) ;
           result_record.change_down_val    := ROUND(ds_price_changes.change_down_val, 21) ;
           result_record.up_rma             := ROUND(v_ds_up_rma, 21) ;
           result_record.down_rma           := ROUND(v_ds_down_rma, 21) ;
           result_record.RS                 := ROUND(v_ds_RS, 21) ;
           result_record.RSI                := ROUND(v_ds_RSI, 3) ;
           result_record.change_ts          := now() ;
           return next result_record ;
           v_ds_up_rma_old := v_ds_up_rma ; v_ds_down_rma_old := v_ds_down_rma ;
           END LOOP ;
       RETURN ;
       END ;
$BODY$ ;

select * from rtrsp_rsi_history ;

-- примеры работы функции заполнения RSI

select * from fn_rtrsp_calck_rsi_as_table(14::INTEGER, '1INCH'::VARCHAR, 'USDT'::VARCHAR, '10M'::VARCHAR,
			  CAST(now() - INTERVAL '1 months' AS timestamp without time zone),CAST(now() AS timestamp without time zone)) ;

CREATE OR REPLACE PROCEDURE fn_rtsp_driver_fill_rsi_tables(
	   v_indicator_periods INTEGER,
	   v_period_mode character varying)
LANGUAGE 'plpgsql'
AS $BODY$
       DECLARE
       sz_msg                    VARCHAR ;
       sz_request_table_name     VARCHAR ;
       ds_months_list            RECORD ;
       sz_months_list_request    VARCHAR ;
       sz_currency_pairs_request VARCHAR ;  
       rec_currency_pairs_list   RECORD ;
       sz_time_period            VARCHAR ;
       sz_time_frame_list        VARCHAR[16] := '{"1M","3M","5M","10M","15M","30M","1H","2H","3H","4H","8H","12H","1D","2D","4D","1W","4W"}' ;
--       sz_time_frame_list VARCHAR[16] := '{"30M","15M"}' ;
       sz_time_frame             VARCHAR ;
       v_time_reduce_interval    timestamp without time zone ;
       v_time_grow_interval      timestamp without time zone ;
       BEGIN
-- выставляем переменные периодов в зависимости от выбранного режима работы        
       v_time_reduce_interval = clock_timestamp() - INTERVAL '2 days' ; v_time_grow_interval = clock_timestamp() + INTERVAL '32 days' ;
       if (v_period_mode = 'operative') then
          v_time_reduce_interval = clock_timestamp() - INTERVAL '30 minutes' ; 
		  v_time_grow_interval = clock_timestamp() + INTERVAL '20 minutes' ;
          end if ;
       if (v_period_mode = 'gap_2_days') then
          v_time_reduce_interval = clock_timestamp() - INTERVAL '50 hours' ; 
		  v_time_grow_interval =  clock_timestamp() + INTERVAL '3 hours' ;
          end if ;
       if (v_period_mode = 'gap_2_months') then
          v_time_reduce_interval = clock_timestamp() - INTERVAL '62 days' ; 
		  v_time_grow_interval =  clock_timestamp() + INTERVAL '2 days' ;
          end if ;
-- обрабатываем записи
       for v_time_frame IN 1..17 LOOP
           IF (sz_time_frame_list[v_time_frame] = '4W')  THEN sz_request_table_name := 'rtrsp_ohlc_4w_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '1W')  THEN sz_request_table_name := 'rtrsp_ohlc_1w_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '4D')  THEN sz_request_table_name := 'rtrsp_ohlc_4d_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '2D')  THEN sz_request_table_name := 'rtrsp_ohlc_2d_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '1D')  THEN sz_request_table_name := 'rtrsp_ohlc_1d_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '12H') THEN sz_request_table_name := 'rtrsp_ohlc_12h_history' ; END IF ;
           IF (sz_time_frame_list[v_time_frame] = '8H')  THEN sz_request_table_name := 'rtrsp_ohlc_8h_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '4H')  THEN sz_request_table_name := 'rtrsp_ohlc_4h_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '3H')  THEN sz_request_table_name := 'rtrsp_ohlc_3h_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '2H')  THEN sz_request_table_name := 'rtrsp_ohlc_2h_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '1H')  THEN sz_request_table_name := 'rtrsp_ohlc_1h_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '30M') THEN sz_request_table_name := 'rtrsp_ohlc_30m_history' ; END IF ;
           IF (sz_time_frame_list[v_time_frame] = '15M') THEN sz_request_table_name := 'rtrsp_ohlc_15m_history' ; END IF ;
           IF (sz_time_frame_list[v_time_frame] = '10M') THEN sz_request_table_name := 'rtrsp_ohlc_10m_history' ; END IF ;
           IF (sz_time_frame_list[v_time_frame] = '5M')  THEN sz_request_table_name := 'rtrsp_ohlc_5m_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '3M')  THEN sz_request_table_name := 'rtrsp_ohlc_3m_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '1M')  THEN sz_request_table_name := 'rtrsp_ohlc_1m_history' ;  END IF ;

           if (v_period_mode = 'all') then
--              sz_currency_pairs_request = 'select currency, reference_currency from '||sz_request_table_name||' where currency not in (''BONK'',''BNB'',''BLZ'',''BIT'',''BGB'',''BEAM'',''BCH'',''AXS'',''AXL'',''AVAX'',''AUDIO'',''ATOM'',''ARB'',''AR'',''APT'',''APEX'',''APE'',''ALGO'',''AKT'',''AGIX'',''ADA'',''ACH'',''ACA'',''AAVE'',''aaa'',''1INCH'') group by currency, reference_currency order by 1,2' ;
              sz_currency_pairs_request = 'select currency, reference_currency from '||sz_request_table_name||' group by currency, reference_currency order by 1,2' ;              FOR rec_currency_pairs_list IN EXECUTE sz_currency_pairs_request LOOP
                  sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||' старт заполнения ретро данных RSI' ;
--				    RAISE NOTICE '[start driver] %/% ТФ% старт заполнения ретроспективных данных RSI, от % до %', rec_currency_pairs_list.currency, rec_currency_pairs_list.reference_currency,sz_time_frame_list[v_time_frame],v_time_reduce_interval, v_time_grow_interval ;
--                  RAISE NOTICE '%', sz_msg ;
			 	  insert into cragran_logs values(clock_timestamp(),'rtsp_cacl_indicator_RSI','fn_rtsp_driver_fill_rsi_tables',sz_msg) ;
				  COMMIT ;
				  BEGIN
				  MERGE INTO rtrsp_rsi_history dst
                        USING (SELECT * FROM fn_rtrsp_calck_RSI_as_table(v_indicator_periods,rec_currency_pairs_list.currency,rec_currency_pairs_list.reference_currency, sz_time_frame_list[v_time_frame], CAST(now() - INTERVAL '20 years' AS timestamp without time zone), CAST(now() + INTERVAL '32 years' AS timestamp without time zone))) src
	                    ON src.currency = dst.currency AND src.reference_currency = dst.reference_currency AND
                           src.timestamp_point = dst.timestamp_point AND src.time_frame = dst.time_frame AND src.indicator_periods = dst.indicator_periods
                        WHEN MATCHED AND NOT (src.price_close = dst.price_close AND src.price_close_pre = dst.price_close_pre AND src.change_up_val = dst.change_up_val AND 
				              		          src.change_down_val = dst.change_down_val AND src.up_rma = dst.up_rma AND src.down_rma = dst.down_rma AND src.RS = dst.RS AND
						 			          src.RSI = dst.RSI) THEN 
                             UPDATE SET price_close = src.price_close, price_close_pre = src.price_close_pre, change_up_val = src.change_up_val,
	                                    change_down_val = src.change_down_val, up_rma = src.up_rma, down_rma = src.down_rma, RS = src.RS, 
			                            RSI = src.RSI, change_ts = src.change_ts
                        WHEN NOT MATCHED THEN
                             INSERT (currency, reference_currency, timestamp_point, time_frame, indicator_periods, price_close, price_close_pre,
	  	                            change_up_val, change_down_val, up_rma, down_rma, RS, RSI, change_ts)
                                    VALUES (src.currency, src.reference_currency, src.timestamp_point, src.time_frame, src.indicator_periods,
							               src.price_close, src.price_close_pre, src.change_up_val, src.change_down_val, src.up_rma,
							 		       src.down_rma, src.RS, src.RSI, src.change_ts) ;
                  sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||' стоп заполнения ретро данных RSI' ;
				  insert into cragran_logs values(clock_timestamp(),'rtsp_cacl_indicator_RSI','fn_rtsp_driver_fill_rsi_tables',sz_msg) ;	
--                  COMMIT ;
                  EXCEPTION WHEN OTHERS THEN
	                        insert into cragran_logs values(clock_timestamp(),'rtsp_cacl_indicator_RSI','fn_fill_rsi_history','Error INSERT '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ='||sz_time_frame_list[v_time_frame]) ;
		          END ;
				  COMMIT ;
                  END LOOP ;
              END IF ;

           IF (v_period_mode = 'all_per_month') THEN
              sz_months_list_request = 'select src.tsp from (select date_trunc(''month'',timestamp_point) tsp from '||sz_request_table_name||') src group by src.tsp order by 1 asc' ;
              FOR ds_months_list IN EXECUTE sz_months_list_request LOOP
			      sz_currency_pairs_request = 'select currency, reference_currency from '||sz_request_table_name||' group by currency, reference_currency order by 1,2' ;
                  FOR rec_currency_pairs_list IN EXECUTE sz_currency_pairs_request LOOP
                      sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||' старт заполнения ретро данных RSI, от '||ds_months_list.tsp - INTERVAL '2 days' ||' до '||ds_months_list.tsp + INTERVAL '32 days' ;
--                       RAISE NOTICE '[start driver] %/% ТФ% заполнение ретроспективных данных RSI, от % до %', rec_currency_pairs_list.currency, rec_currency_pairs_list.reference_currency,sz_time_frame_list[v_time_frame],v_time_reduce_interval, v_time_grow_interval ;
--                       RAISE NOTICE '%', sz_msg ;
					  insert into cragran_logs values(clock_timestamp(),'rtsp_cacl_indicator_RSI','fn_rtsp_driver_fill_rsi_tables',sz_msg) ;
					  COMMIT ;
				      BEGIN
					  MERGE INTO rtrsp_rsi_history dst
                            USING (SELECT * FROM fn_rtrsp_calck_RSI_as_table(v_indicator_periods,rec_currency_pairs_list.currency,rec_currency_pairs_list.reference_currency, sz_time_frame_list[v_time_frame], ds_months_list.tsp - INTERVAL '2 days', ds_months_list.tsp + INTERVAL '32 days')) src
	                        ON src.currency = dst.currency AND src.reference_currency = dst.reference_currency AND
                               src.timestamp_point = dst.timestamp_point AND src.time_frame = dst.time_frame AND src.indicator_periods = dst.indicator_periods
                            WHEN MATCHED AND NOT (src.price_close = dst.price_close AND src.price_close_pre = dst.price_close_pre AND src.change_up_val = dst.change_up_val AND 
							                      src.change_down_val = dst.change_down_val AND src.up_rma = dst.up_rma AND src.down_rma = dst.down_rma AND src.RS = dst.RS AND
									              src.RSI = dst.RSI) THEN 
                                 UPDATE SET price_close = src.price_close, price_close_pre = src.price_close_pre, change_up_val = src.change_up_val,
		                                    change_down_val = src.change_down_val, up_rma = src.up_rma, down_rma = src.down_rma, RS = src.RS, 
					                        RSI = src.RSI, change_ts = src.change_ts
                            WHEN NOT MATCHED THEN
                                 INSERT (currency, reference_currency, timestamp_point, time_frame, indicator_periods, price_close, price_close_pre,
	  	                                change_up_val, change_down_val, up_rma, down_rma, RS, RSI, change_ts)
                                        VALUES (src.currency, src.reference_currency, src.timestamp_point, src.time_frame, src.indicator_periods,
							                   src.price_close, src.price_close_pre, src.change_up_val, src.change_down_val, src.up_rma,
									           src.down_rma, src.RS, src.RSI, src.change_ts) ;
                      sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||' стоп заполнения ретро данных RSI' ;
				      insert into cragran_logs values(clock_timestamp(),'rtsp_cacl_indicator_RSI','fn_rtsp_driver_fill_rsi_tables',sz_msg) ;	
                      COMMIT ;
                      EXCEPTION WHEN OTHERS THEN
	                            insert into cragran_logs values(clock_timestamp(),'rtsp_cacl_indicator_RSI','fn_fill_rsi_history','Error INSERT '||v_currency||'/'||v_reference_currency||' tp='||v_timestamp_point) ;
		              END ;
					  COMMIT ;
                      END LOOP ;
                  END LOOP ;
              END IF ;

           IF (v_period_mode = 'operative' OR v_period_mode = 'gap_2_days' OR v_period_mode = 'gap_2_months') then
              sz_currency_pairs_request = 'select currency, reference_currency from '||sz_request_table_name||' group by currency, reference_currency order by 1,2' ;
              FOR rec_currency_pairs_list IN EXECUTE sz_currency_pairs_request LOOP
                  sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||' старт заполнения ретро данных RSI, от '||v_time_reduce_interval||' до '||v_time_grow_interval ;
--				     RAISE NOTICE '[start driver] %/% ТФ% заполнение ретро данных RSI, от % до %', rec_currency_pairs_list.currency, rec_currency_pairs_list.reference_currency,sz_time_frame_list[v_time_frame],v_time_reduce_interval, v_time_grow_interval ;
--                   RAISE NOTICE '%', sz_msg ;
                  insert into cragran_logs values(clock_timestamp(),'rtsp_cacl_indicator_RSI','fn_rtsp_driver_fill_rsi_tables',sz_msg) ;
				  COMMIT ;
                  BEGIN
                  MERGE INTO rtrsp_rsi_history dst
                        USING (SELECT * FROM fn_rtrsp_calck_RSI_As_table(v_indicator_periods,rec_currency_pairs_list.currency,rec_currency_pairs_list.reference_currency, sz_time_frame_list[v_time_frame], v_time_reduce_interval, v_time_grow_interval)) src
	                    ON src.currency = dst.currency AND src.reference_currency = dst.reference_currency AND
                           src.timestamp_point = dst.timestamp_point AND src.time_frame = dst.time_frame AND src.indicator_periods = dst.indicator_periods
                        WHEN MATCHED AND NOT (src.price_close = dst.price_close AND src.price_close_pre = dst.price_close_pre AND src.change_up_val = dst.change_up_val AND 
						                     src.change_down_val = dst.change_down_val AND src.up_rma = dst.up_rma AND src.down_rma = dst.down_rma AND src.RS = dst.RS AND
									         src.RSI = dst.RSI) THEN 
                             UPDATE SET price_close = src.price_close, price_close_pre = src.price_close_pre, change_up_val = src.change_up_val,
		                                change_down_val = src.change_down_val, up_rma = src.up_rma, down_rma = src.down_rma, RS = src.RS, 
					                    RSI = src.RSI, change_ts = src.change_ts
                       WHEN NOT MATCHED THEN
                            INSERT (currency, reference_currency, timestamp_point, time_frame, indicator_periods, price_close, price_close_pre,
	  	                           change_up_val, change_down_val, up_rma, down_rma, RS, RSI, change_ts)
                                   VALUES (src.currency, src.reference_currency, src.timestamp_point, src.time_frame, src.indicator_periods,
							              src.price_close, src.price_close_pre, src.change_up_val, src.change_down_val, src.up_rma,
									      src.down_rma, src.RS, src.RSI, src.change_ts) ;

                  sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||' стоп заполнения ретро данных RSI' ;
				  insert into cragran_logs values(clock_timestamp(),'rtsp_cacl_indicator_RSI','fn_rtsp_driver_fill_rsi_tables',sz_msg) ;	
--                  COMMIT ;
                  EXCEPTION WHEN OTHERS THEN
	                        insert into cragran_logs values(clock_timestamp(),'rtsp_cacl_indicator_RSI','fn_fill_rsi_history','Error INSERT '||v_currency||'/'||v_reference_currency||' tp='||v_timestamp_point) ;
		          END ;
				  COMMIT ;
                  END LOOP ;
              END IF ;	   
       END LOOP ; -- конец перебора таймфрэймов
END ;
$BODY$;	

--CALL fn_rtsp_driver_fill_rsi_tables(14,'all_per_month') ;
--CALL fn_rtsp_driver_fill_rsi_tables(14,'all') ;

--delete from cragran_logs where module = 'fn_rtsp_driver_fill_rsi_tables' ;
--delete from rtrsp_rsi_history ;

-- тест для формирования исключения уже посчитанных
select currency, reference_currency
       from rtrsp_ohlc_1m_history
	   where currency not in ('BEAM','BCH','AXS','AXL','AVAX','AUDIO','ATOM','ARB','AR','APT','APEX','APE','ALGO','AKT','AGIX','ADA','ACH','ACA','AAVE','aaa','1INCH')
	   group by currency, reference_currency
	   order by 1,2

select * from cragran_logs order by 1 desc limit 1000 ;
select count(*) from rtrsp_rsi_history ;
select * from pg_class where relname = 'rtrsp_rsi_history' ;

-- #######################################################################################################################################
-- Итерация 3. конец блока 
-- #######################################################################################################################################

'BEAM','BCH','AXS','AXL','AVAX','AUDIO','ATOM','ARB','AR','APT','APEX','APE','ALGO','AKT','AGIX','ADA','ACH','ACA','AAVE','aaa','1INCH'


-- #######################################################################################################################################
-- Итерация 2. начало блока заполнения с отдельной функцией - заполнителем. это вторая попытка, работает медленнее merge, и уже дважды висла
-- #######################################################################################################################################
CREATE OR REPLACE FUNCTION public.fn_fill_rsi_history(
       v_currency character varying,
       v_reference_currency character varying,
       v_timestamp_point timestamp without time zone,
       v_time_frame character varying,
       v_indicator_periods numeric,
       v_price_close numeric,
       v_price_close_pre numeric,
       v_change_up_val numeric,
       v_change_down_val numeric,
       v_up_rma numeric,
       v_down_rma numeric,
       v_rs numeric,
       v_rsi numeric)
    RETURNS void
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
cntEditString INTEGER ;
cntEditString_nochanged INTEGER ;
BEGIN
--v_currency, v_reference_currency, v_timestamp_point, v_time_frame, v_indicator_periods,
--v_price_close, v_price_close_pre, v_change_up_val, v_change_down_val, v_up_rma, v_down_rma, v_rs, v_rsi, v_change_ts
        cntEditString := 0 ;
        SELECT count(*) INTO cntEditString
               FROM rtrsp_rsi_history
               WHERE currency = v_currency AND reference_currency = v_reference_currency AND timestamp_point = v_timestamp_point 
			         AND time_frame = v_time_frame AND indicator_periods = v_indicator_periods;
        IF cntEditString > 0 THEN
           cntEditString_nochanged := 0 ;
           SELECT count(*) INTO cntEditString_nochanged
                  FROM rtrsp_rsi_history
                  WHERE currency = v_currency AND reference_currency = v_reference_currency AND timestamp_point = v_timestamp_point
				        AND time_frame = v_time_frame AND indicator_periods = v_indicator_periods
                        AND price_close = v_price_close AND price_close_pre = v_price_close_pre AND change_up_val = v_change_up_val
						AND change_down_val = v_change_down_val AND up_rma = v_up_rma AND down_rma = v_down_rma AND rs = v_rs AND rsi = v_rsi ;
                        IF cntEditString_nochanged = 0 THEN
                           BEGIN
                           UPDATE rtrsp_rsi_history SET price_close = v_price_close, price_close_pre = v_price_close_pre, change_up_val = v_change_up_val,
						          change_down_val = v_change_down_val, up_rma = v_up_rma, down_rma = v_down_rma, rs = v_rs, rsi = v_rsi, change_ts = now()  
                                  WHERE currency = v_currency AND reference_currency = v_reference_currency AND timestamp_point = v_timestamp_point
								        AND time_frame = v_time_frame AND indicator_periods = v_indicator_periods ;
                           EXCEPTION WHEN OTHERS THEN
					       insert into cragran_logs values(clock_timestamp(),'rtsp_cacl_indicator_RSI','fn_fill_rsi_history','Error UPDATE '||v_currency||'/'||v_reference_currency||' tp='||v_timestamp_point) ;
                           END ;
                        END IF ;
        ELSE
           BEGIN
           insert into rtrsp_rsi_history (currency, reference_currency, timestamp_point, time_frame, indicator_periods, price_close, price_close_pre,
	   						              change_up_val, change_down_val, up_rma, down_rma, rs, rsi, change_ts)
                        values (v_currency, v_reference_currency, v_timestamp_point, v_time_frame, v_indicator_periods, v_price_close, v_price_close_pre,
		   			           v_change_up_val, v_change_down_val, v_up_rma, v_down_rma, v_rs, v_rsi, now()) ;
           EXCEPTION WHEN OTHERS THEN
	       insert into cragran_logs values(clock_timestamp(),'rtsp_cacl_indicator_RSI','fn_fill_rsi_history','Error INSERT '||v_currency||'/'||v_reference_currency||' tp='||v_timestamp_point) ;
		   END ;
        END IF ;
END ;
$BODY$;


CREATE OR REPLACE FUNCTION public.fn_rtrsp_calck_rsi(
    v_indicator_periods numeric,
    v_currency character varying,
    v_reference_currency character varying,
    v_time_frame character varying,
    v_time_start timestamp without time zone,
    v_time_stop timestamp without time zone)
    RETURNS SETOF rtrsp_rsi_history
    LANGUAGE 'plpgsql'
AS $BODY$
    DECLARE
       result_record           rtrsp_RSI_history%ROWTYPE ;
       sz_base_cursor_request  VARCHAR ;
       sz_request_table_name   VARCHAR ;
       ds_price_changes        RECORD ;
       v_ds_up_rma             NUMERIC ;
       v_ds_up_rma_old         NUMERIC ;
       v_ds_down_rma           NUMERIC ;
       v_ds_down_rma_old       NUMERIC ;
       v_ds_RS                 NUMERIC ;
       v_ds_RSI                NUMERIC ;
       BEGIN
       v_ds_up_rma := 0.0 ; v_ds_up_rma_old := 0.0 ; v_ds_down_rma := 0.0 ; v_ds_down_rma_old := 0.0 ; v_ds_RS := 0.0 ; v_ds_RSI := 0.0 ;
       --sz_request_table_name := 'rtrsp_ohlc_30m_history' ;
       IF (v_time_frame = '4W')  THEN sz_request_table_name := 'rtrsp_ohlc_4w_history' ;  END IF ;
       IF (v_time_frame = '1W')  THEN sz_request_table_name := 'rtrsp_ohlc_1w_history' ;  END IF ;
       IF (v_time_frame = '4D')  THEN sz_request_table_name := 'rtrsp_ohlc_4d_history' ;  END IF ;
       IF (v_time_frame = '2D')  THEN sz_request_table_name := 'rtrsp_ohlc_2d_history' ;  END IF ;
       IF (v_time_frame = '1D')  THEN sz_request_table_name := 'rtrsp_ohlc_1d_history' ;  END IF ;
       IF (v_time_frame = '12H') THEN sz_request_table_name := 'rtrsp_ohlc_12h_history' ; END IF ;
       IF (v_time_frame = '8H')  THEN sz_request_table_name := 'rtrsp_ohlc_8h_history' ;  END IF ;
       IF (v_time_frame = '4H')  THEN sz_request_table_name := 'rtrsp_ohlc_4h_history' ;  END IF ;
       IF (v_time_frame = '3H')  THEN sz_request_table_name := 'rtrsp_ohlc_3h_history' ;  END IF ;
       IF (v_time_frame = '2H')  THEN sz_request_table_name := 'rtrsp_ohlc_2h_history' ;  END IF ;
       IF (v_time_frame = '1H')  THEN sz_request_table_name := 'rtrsp_ohlc_1h_history' ;  END IF ;
       IF (v_time_frame = '30M') THEN sz_request_table_name := 'rtrsp_ohlc_30m_history' ; END IF ;
       IF (v_time_frame = '15M') THEN sz_request_table_name := 'rtrsp_ohlc_15m_history' ; END IF ;
       IF (v_time_frame = '10M') THEN sz_request_table_name := 'rtrsp_ohlc_10m_history' ; END IF ;
       IF (v_time_frame = '5M')  THEN sz_request_table_name := 'rtrsp_ohlc_5m_history' ;  END IF ;
       IF (v_time_frame = '3M')  THEN sz_request_table_name := 'rtrsp_ohlc_3m_history' ;  END IF ;
       IF (v_time_frame = '1M')  THEN sz_request_table_name := 'rtrsp_ohlc_1m_history' ;  END IF ;

       sz_base_cursor_request := 'select rownum, currency, reference_currency, timestamp_point, price_close, price_close_pre,
                     CASE WHEN (ROWNUM = 0 OR (price_close - price_close_pre) <= 0) THEN 0
                          ELSE price_close - price_close_pre END change_up_val,
                     CASE WHEN (ROWNUM = 0 OR (price_close_pre - price_close) <= 0) THEN 0
                          ELSE price_close_pre - price_close END change_down_val
                     from (select row_number() over () rownum, currency, reference_currency, timestamp_point, price_close,
                                  LAG(price_close, 1) OVER (PARTITION BY currency, reference_currency
                                                           ORDER BY timestamp_point asc) price_close_pre
                                  from '||sz_request_table_name||' where currency = $1 AND reference_currency = $2 and 
                                        timestamp_point >= $3 AND timestamp_point <= $4
                                  ORDER BY currency, reference_currency, timestamp_point asc ) src1' ;
       FOR ds_price_changes IN EXECUTE sz_base_cursor_request USING v_currency, v_reference_currency, v_time_start, v_time_stop LOOP
-- расчёт по строкам dataset
           v_ds_up_rma := 0 ; v_ds_down_rma := 0 ; v_ds_RS := 0 ; v_ds_RSI := 0 ;
           IF (ds_price_changes.rownum = 2) THEN v_ds_up_rma := ds_price_changes.change_up_val ; v_ds_down_rma := ds_price_changes.change_down_val ; END IF ;
           IF (ds_price_changes.rownum > 2)
              THEN v_ds_up_rma   := (ds_price_changes.change_up_val   * (1 / v_indicator_periods::NUMERIC )) + (v_ds_up_rma_old::NUMERIC   * (1 - (1 / v_indicator_periods::NUMERIC)) ) ;
                   v_ds_down_rma := (ds_price_changes.change_down_val * (1 / v_indicator_periods::NUMERIC )) + (v_ds_down_rma_old::NUMERIC * (1 - (1 / v_indicator_periods::NUMERIC)) ) ;
                   END IF ;
           IF v_ds_down_rma = 0 THEN v_ds_RS := 1 ; ELSE v_ds_RS := v_ds_up_rma / v_ds_down_rma::NUMERIC ; END IF ;
           v_ds_RSI := 100 - (100 / (1 + v_ds_RS::NUMERIC)) ;
		   PERFORM fn_fill_rsi_history(ds_price_changes.currency,ds_price_changes.reference_currency,ds_price_changes.timestamp_point,v_time_frame,v_indicator_periods,ds_price_changes.price_close, ds_price_changes.price_close_pre, ds_price_changes.change_up_val, ds_price_changes.change_down_val,v_ds_up_rma, v_ds_down_rma, v_ds_RS, v_ds_RSI) ;
--select fn_fill_crcomp_1H_ohlc(CAST('BTC' AS VARCHAR), CAST('USDT' AS VARCHAR), CAST(TO_TIMESTAMP('2024-09-05 10:0:0','YYYY-MM-DD HH24:MI:SS') AS timestamp without time zone), 56797.95 ...
		   v_ds_up_rma_old := v_ds_up_rma ; v_ds_down_rma_old := v_ds_down_rma ;
           END LOOP ;
       RETURN ;
       END ;
$BODY$ ;

CREATE OR REPLACE PROCEDURE fn_rtsp_driver_fill_rsi_tables(
	v_indicator_periods numeric,
	v_period_mode character varying)
LANGUAGE 'plpgsql'
AS $BODY$
       DECLARE
       sz_msg                    VARCHAR ;
       sz_request_table_name     VARCHAR ;
       ds_months_list            RECORD ;
       sz_months_list_request    VARCHAR ;
       sz_currency_pairs_request VARCHAR ;  
       rec_currency_pairs_list   RECORD ;
       sz_time_period            VARCHAR ;
       sz_time_frame_list        VARCHAR[16] := '{"1M","3M","5M","10M","15M","30M","1H","2H","3H","4H","8H","12H","1D","2D","4D","1W","4W"}' ;
--       sz_time_frame_list VARCHAR[16] := '{"30M","15M"}' ;
       sz_time_frame             VARCHAR ;
       v_time_reduce_interval    timestamp without time zone ;
       v_time_grow_interval      timestamp without time zone ;
       BEGIN
-- выставляем переменные периодов в зависимости от выбранного режима работы        
       v_time_reduce_interval = clock_timestamp() - INTERVAL '2 days' ; v_time_grow_interval = clock_timestamp() + INTERVAL '32 days' ;
       if (v_period_mode = 'operative') then
          v_time_reduce_interval = clock_timestamp() - INTERVAL '30 minutes' ; 
		  v_time_grow_interval = clock_timestamp() + INTERVAL '20 minutes' ;
          end if ;
       if (v_period_mode = 'gap_2_days') then
          v_time_reduce_interval = clock_timestamp() - INTERVAL '50 hours' ; 
		  v_time_grow_interval =  clock_timestamp() + INTERVAL '3 hours' ;
          end if ;
       if (v_period_mode = 'gap_2_months') then
          v_time_reduce_interval = clock_timestamp() - INTERVAL '62 days' ; 
		  v_time_grow_interval =  clock_timestamp() + INTERVAL '2 days' ;
          end if ;
-- обрабатываем записи из таблицы источника в 1 минуту
       if (v_period_mode = 'all') then
          for v_time_frame IN 1..17 LOOP
              IF (sz_time_frame_list[v_time_frame] = '4W')  THEN sz_request_table_name := 'rtrsp_ohlc_4w_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '1W')  THEN sz_request_table_name := 'rtrsp_ohlc_1w_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '4D')  THEN sz_request_table_name := 'rtrsp_ohlc_4d_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '2D')  THEN sz_request_table_name := 'rtrsp_ohlc_2d_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '1D')  THEN sz_request_table_name := 'rtrsp_ohlc_1d_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '12H') THEN sz_request_table_name := 'rtrsp_ohlc_12h_history' ; END IF ;
              IF (sz_time_frame_list[v_time_frame] = '8H')  THEN sz_request_table_name := 'rtrsp_ohlc_8h_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '4H')  THEN sz_request_table_name := 'rtrsp_ohlc_4h_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '3H')  THEN sz_request_table_name := 'rtrsp_ohlc_3h_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '2H')  THEN sz_request_table_name := 'rtrsp_ohlc_2h_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '1H')  THEN sz_request_table_name := 'rtrsp_ohlc_1h_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '30M') THEN sz_request_table_name := 'rtrsp_ohlc_30m_history' ; END IF ;
              IF (sz_time_frame_list[v_time_frame] = '15M') THEN sz_request_table_name := 'rtrsp_ohlc_15m_history' ; END IF ;
              IF (sz_time_frame_list[v_time_frame] = '10M') THEN sz_request_table_name := 'rtrsp_ohlc_10m_history' ; END IF ;
              IF (sz_time_frame_list[v_time_frame] = '5M')  THEN sz_request_table_name := 'rtrsp_ohlc_5m_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '3M')  THEN sz_request_table_name := 'rtrsp_ohlc_3m_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '1M')  THEN sz_request_table_name := 'rtrsp_ohlc_1m_history' ;  END IF ;

              sz_months_list_request = 'select src.tsp from (select date_trunc(''month'',timestamp_point) tsp from '||sz_request_table_name||') src group by src.tsp order by 1 asc' ;
              FOR ds_months_list IN EXECUTE sz_months_list_request LOOP
			      sz_currency_pairs_request = 'select currency, reference_currency from '||sz_request_table_name||' group by currency, reference_currency order by 1,2' ;
                  FOR rec_currency_pairs_list IN EXECUTE sz_currency_pairs_request LOOP
                  sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||' заполнение ретро данных RSI, от '||ds_months_list.tsp - INTERVAL '2 days' ||' до '||ds_months_list.tsp + INTERVAL '32 days' ;
--				  RAISE NOTICE '[start driver] %/% ТФ% заполнение ретроспективных данных RSI, от % до %', rec_currency_pairs_list.currency, rec_currency_pairs_list.reference_currency,sz_time_frame_list[v_time_frame],v_time_reduce_interval, v_time_grow_interval ;
--                  RAISE NOTICE '%', sz_msg ;
					  insert into cragran_logs values(clock_timestamp(),'rtsp_cacl_indicator_RSI','fn_rtsp_driver_fill_rsi_tables',sz_msg) ;
                      PERFORM fn_rtrsp_calck_RSI(v_indicator_periods,rec_currency_pairs_list.currency,rec_currency_pairs_list.reference_currency, sz_time_frame_list[v_time_frame], ds_months_list.tsp - INTERVAL '2 days', ds_months_list.tsp + INTERVAL '32 days') ;
                      commit ;
                  END LOOP ;
              END loop ;
              commit ;
          END loop ;
          end if ;

       if (v_period_mode = 'operative' OR v_period_mode = 'gap_2_days' OR v_period_mode = 'gap_2_months') then
          for v_time_frame IN 1..17 LOOP
              IF (sz_time_frame_list[v_time_frame] = '4W')  THEN sz_request_table_name := 'rtrsp_ohlc_4w_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '1W')  THEN sz_request_table_name := 'rtrsp_ohlc_1w_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '4D')  THEN sz_request_table_name := 'rtrsp_ohlc_4d_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '2D')  THEN sz_request_table_name := 'rtrsp_ohlc_2d_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '1D')  THEN sz_request_table_name := 'rtrsp_ohlc_1d_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '12H') THEN sz_request_table_name := 'rtrsp_ohlc_12h_history' ; END IF ;
              IF (sz_time_frame_list[v_time_frame] = '8H')  THEN sz_request_table_name := 'rtrsp_ohlc_8h_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '4H')  THEN sz_request_table_name := 'rtrsp_ohlc_4h_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '3H')  THEN sz_request_table_name := 'rtrsp_ohlc_3h_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '2H')  THEN sz_request_table_name := 'rtrsp_ohlc_2h_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '1H')  THEN sz_request_table_name := 'rtrsp_ohlc_1h_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '30M') THEN sz_request_table_name := 'rtrsp_ohlc_30m_history' ; END IF ;
              IF (sz_time_frame_list[v_time_frame] = '15M') THEN sz_request_table_name := 'rtrsp_ohlc_15m_history' ; END IF ;
              IF (sz_time_frame_list[v_time_frame] = '10M') THEN sz_request_table_name := 'rtrsp_ohlc_10m_history' ; END IF ;
              IF (sz_time_frame_list[v_time_frame] = '5M')  THEN sz_request_table_name := 'rtrsp_ohlc_5m_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '3M')  THEN sz_request_table_name := 'rtrsp_ohlc_3m_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '1M')  THEN sz_request_table_name := 'rtrsp_ohlc_1m_history' ;  END IF ;

              sz_currency_pairs_request = 'select currency, reference_currency from '||sz_request_table_name||' group by currency, reference_currency order by 1,2' ;
              FOR rec_currency_pairs_list IN EXECUTE sz_currency_pairs_request LOOP
                  sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||' заполнение ретро данных RSI, от '||v_time_reduce_interval||' до '||v_time_grow_interval ;
--				  RAISE NOTICE '[start driver] %/% ТФ% заполнение ретро данных RSI, от % до %', rec_currency_pairs_list.currency, rec_currency_pairs_list.reference_currency,sz_time_frame_list[v_time_frame],v_time_reduce_interval, v_time_grow_interval ;
--                  RAISE NOTICE '%', sz_msg ;
                  insert into cragran_logs values(clock_timestamp(),'rtsp_cacl_indicator_RSI','fn_rtsp_driver_fill_rsi_tables',sz_msg) ;
				  PERFORM fn_rtrsp_calck_RSI(v_indicator_periods,rec_currency_pairs_list.currency,rec_currency_pairs_list.reference_currency, sz_time_frame_list[v_time_frame], v_time_reduce_interval, v_time_grow_interval) ;
                  commit ;
              END loop ;
              commit ;
          END loop ;
          end if ;	   

END ;
$BODY$;	

--delete from cragran_logs where module = 'fn_rtsp_driver_fill_rsi_tables' ;
--delete from rtrsp_rsi_history ;
CALL fn_rtsp_driver_fill_rsi_tables(14,'all') ;

select * from cragran_logs order by 1 desc limit 1000 ;
select count(*) from rtrsp_rsi_history ; -- 378707 - 
-- #######################################################################################################################################
-- Итерация 2. конец блока заполнения с отдельной функцией - заполнителем. это вторая попытка, работает медленнее merge, и уже дважды висла
-- #######################################################################################################################################

-- #######################################################################################################################################
-- Итерация 1. начало блока заполнения через merge, без указания numeric(42,21) создавала TOAST и плодила обьём
-- #######################################################################################################################################
CREATE TABLE IF NOT EXISTS rtrsp_rsi_history (
       currency character varying(100),
       reference_currency character varying(100),
       timestamp_point timestamp without time zone,
       time_frame character varying(10),
       indicator_periods numeric,
       price_close numeric,
       price_close_pre numeric,
       change_up_val numeric,
       change_down_val numeric,
       up_rma numeric,
       down_rma numeric,
       rs numeric,
       rsi numeric,
       change_ts timestamp without time zone,
       PRIMARY KEY (currency, reference_currency, timestamp_point, time_frame, indicator_periods) ) ;

-- DROP FUNCTION IF EXISTS public.fn_rtrsp_calck_rsi_as_table(numeric, character varying, character varying, character varying, timestamp without time zone, timestamp without time zone);
CREATE OR REPLACE FUNCTION public.fn_rtrsp_calck_rsi_as_table(
    v_indicator_periods numeric,
    v_currency character varying,
    v_reference_currency character varying,
    v_time_frame character varying,
    v_time_start timestamp without time zone,
    v_time_stop timestamp without time zone)
    RETURNS SETOF rtrsp_rsi_history
    LANGUAGE 'plpgsql'
AS $BODY$
    DECLARE
       result_record           rtrsp_RSI_history%ROWTYPE ;
       sz_base_cursor_request  VARCHAR ;
       sz_request_table_name   VARCHAR ;
       ds_price_changes        RECORD ;
       v_ds_up_rma             NUMERIC ;
       v_ds_up_rma_old         NUMERIC ;
       v_ds_down_rma           NUMERIC ;
       v_ds_down_rma_old       NUMERIC ;
       v_ds_RS                 NUMERIC ;
       v_ds_RSI                NUMERIC ;
       BEGIN
       v_ds_up_rma := 0.0 ; v_ds_up_rma_old := 0.0 ; v_ds_down_rma := 0.0 ; v_ds_down_rma_old := 0.0 ; v_ds_RS := 0.0 ; v_ds_RSI := 0.0 ;
       --sz_request_table_name := 'rtrsp_ohlc_30m_history' ;
       IF (v_time_frame = '4W')  THEN sz_request_table_name := 'rtrsp_ohlc_4w_history' ;  END IF ;
       IF (v_time_frame = '1W')  THEN sz_request_table_name := 'rtrsp_ohlc_1w_history' ;  END IF ;
       IF (v_time_frame = '4D')  THEN sz_request_table_name := 'rtrsp_ohlc_4d_history' ;  END IF ;
       IF (v_time_frame = '2D')  THEN sz_request_table_name := 'rtrsp_ohlc_2d_history' ;  END IF ;
       IF (v_time_frame = '1D')  THEN sz_request_table_name := 'rtrsp_ohlc_1d_history' ;  END IF ;
       IF (v_time_frame = '12H') THEN sz_request_table_name := 'rtrsp_ohlc_12h_history' ; END IF ;
       IF (v_time_frame = '8H')  THEN sz_request_table_name := 'rtrsp_ohlc_8h_history' ;  END IF ;
       IF (v_time_frame = '4H')  THEN sz_request_table_name := 'rtrsp_ohlc_4h_history' ;  END IF ;
       IF (v_time_frame = '3H')  THEN sz_request_table_name := 'rtrsp_ohlc_3h_history' ;  END IF ;
       IF (v_time_frame = '2H')  THEN sz_request_table_name := 'rtrsp_ohlc_2h_history' ;  END IF ;
       IF (v_time_frame = '1H')  THEN sz_request_table_name := 'rtrsp_ohlc_1h_history' ;  END IF ;
       IF (v_time_frame = '30M') THEN sz_request_table_name := 'rtrsp_ohlc_30m_history' ; END IF ;
       IF (v_time_frame = '15M') THEN sz_request_table_name := 'rtrsp_ohlc_15m_history' ; END IF ;
       IF (v_time_frame = '10M') THEN sz_request_table_name := 'rtrsp_ohlc_10m_history' ; END IF ;
       IF (v_time_frame = '5M')  THEN sz_request_table_name := 'rtrsp_ohlc_5m_history' ;  END IF ;
       IF (v_time_frame = '3M')  THEN sz_request_table_name := 'rtrsp_ohlc_3m_history' ;  END IF ;
       IF (v_time_frame = '1M')  THEN sz_request_table_name := 'rtrsp_ohlc_1m_history' ;  END IF ;

       sz_base_cursor_request := 'select rownum, currency, reference_currency, timestamp_point, price_close, price_close_pre,
                     CASE WHEN (ROWNUM = 0 OR (price_close - price_close_pre) <= 0) THEN 0
                          ELSE price_close - price_close_pre END change_up_val,
                     CASE WHEN (ROWNUM = 0 OR (price_close_pre - price_close) <= 0) THEN 0
                          ELSE price_close_pre - price_close END change_down_val
                     from (select row_number() over () rownum, currency, reference_currency, timestamp_point, price_close,
                                  LAG(price_close, 1) OVER (PARTITION BY currency, reference_currency
                                                           ORDER BY timestamp_point asc) price_close_pre
                                  from '||sz_request_table_name||' where currency = $1 AND reference_currency = $2 and 
                                        timestamp_point >= $3 AND timestamp_point <= $4
                                  ORDER BY currency, reference_currency, timestamp_point asc ) src1' ;
       FOR ds_price_changes IN EXECUTE sz_base_cursor_request USING v_currency, v_reference_currency, v_time_start, v_time_stop LOOP
-- расчёт по строкам dataset
           v_ds_up_rma := 0 ; v_ds_down_rma := 0 ; v_ds_RS := 0 ; v_ds_RSI := 0 ;
           IF (ds_price_changes.rownum = 2) THEN v_ds_up_rma := ds_price_changes.change_up_val ; v_ds_down_rma := ds_price_changes.change_down_val ; END IF ;
           IF (ds_price_changes.rownum > 2)
              THEN v_ds_up_rma   := (ds_price_changes.change_up_val   * (1 / v_indicator_periods::NUMERIC )) + (v_ds_up_rma_old::NUMERIC   * (1 - (1 / v_indicator_periods::NUMERIC)) ) ;
                   v_ds_down_rma := (ds_price_changes.change_down_val * (1 / v_indicator_periods::NUMERIC )) + (v_ds_down_rma_old::NUMERIC * (1 - (1 / v_indicator_periods::NUMERIC)) ) ;
                   END IF ;
           IF v_ds_down_rma = 0 THEN v_ds_RS := 1 ; ELSE v_ds_RS := v_ds_up_rma / v_ds_down_rma::NUMERIC ; END IF ;
           v_ds_RSI := 100 - (100 / (1 + v_ds_RS::NUMERIC)) ;
           result_record.currency           := ds_price_changes.currency ;
           result_record.reference_currency := ds_price_changes.reference_currency ;
           result_record.timestamp_point    := ds_price_changes.timestamp_point ;
           result_record.time_frame         := v_time_frame ;
           result_record.indicator_periods  := v_indicator_periods ;
           result_record.price_close        := ds_price_changes.price_close ;
           result_record.price_close_pre    := ds_price_changes.price_close_pre ;
           result_record.change_up_val      := ds_price_changes.change_up_val ;
           result_record.change_down_val    := ds_price_changes.change_down_val ;
           result_record.up_rma             := v_ds_up_rma ;
           result_record.down_rma           := v_ds_down_rma ;
           result_record.RS                 := v_ds_RS ;
           result_record.RSI                := v_ds_RSI ;
           result_record.change_ts          := now() ;
           return next result_record ;
           v_ds_up_rma_old := v_ds_up_rma ; v_ds_down_rma_old := v_ds_down_rma ;
           END LOOP ;
       RETURN ;
       END ;
$BODY$ ;

select * from rtrsp_rsi_history ;

-- примеры работы функции заполнения RSI
select * from fn_rtrsp_calck_RSI(14,'a','a','10M',CAST(now() AS timestamp without time zone),CAST(now() AS timestamp without time zone)) ;
select timestamp_point, ROUND(RSI,2) from fn_rtrsp_calck_RSI(14,'1INCH','USDT','10M',
	   CAST(now() - INTERVAL '3 months' AS timestamp without time zone),CAST(now() AS timestamp without time zone)) ;
select timestamp_point from fn_rtrsp_calck_RSI(14,'1INCH','USDT','10M',
	   cast(now() - INTERVAL '3 months' as timestamp without time zone), cast(now() as timestamp without time zone)) ;

CREATE OR REPLACE PROCEDURE fn_rtsp_driver_fill_rsi_tables(
	v_indicator_periods numeric,
	v_period_mode character varying)
LANGUAGE 'plpgsql'
AS $BODY$
       DECLARE
       sz_msg                    VARCHAR ;
       sz_request_table_name     VARCHAR ;
       ds_months_list            RECORD ;
       sz_months_list_request    VARCHAR ;
       sz_currency_pairs_request VARCHAR ;  
       rec_currency_pairs_list   RECORD ;
       sz_time_period            VARCHAR ;
       sz_time_frame_list        VARCHAR[16] := '{"1M","3M","5M","10M","15M","30M","1H","2H","3H","4H","8H","12H","1D","2D","4D","1W","4W"}' ;
--       sz_time_frame_list VARCHAR[16] := '{"30M","15M"}' ;
       sz_time_frame             VARCHAR ;
       v_time_reduce_interval    timestamp without time zone ;
       v_time_grow_interval      timestamp without time zone ;
       BEGIN
-- выставляем переменные периодов в зависимости от выбранного режима работы        
       v_time_reduce_interval = clock_timestamp() - INTERVAL '2 days' ; v_time_grow_interval = clock_timestamp() + INTERVAL '32 days' ;
       if (v_period_mode = 'operative') then
          v_time_reduce_interval = clock_timestamp() - INTERVAL '30 minutes' ; 
		  v_time_grow_interval = clock_timestamp() + INTERVAL '20 minutes' ;
          end if ;
       if (v_period_mode = 'gap_2_days') then
          v_time_reduce_interval = clock_timestamp() - INTERVAL '50 hours' ; 
		  v_time_grow_interval =  clock_timestamp() + INTERVAL '3 hours' ;
          end if ;
       if (v_period_mode = 'gap_2_months') then
          v_time_reduce_interval = clock_timestamp() - INTERVAL '62 days' ; 
		  v_time_grow_interval =  clock_timestamp() + INTERVAL '2 days' ;
          end if ;
-- обрабатываем записи из таблицы источника в 1 минуту
       if (v_period_mode = 'all') then
          for v_time_frame IN 1..17 LOOP
              IF (sz_time_frame_list[v_time_frame] = '4W')  THEN sz_request_table_name := 'rtrsp_ohlc_4w_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '1W')  THEN sz_request_table_name := 'rtrsp_ohlc_1w_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '4D')  THEN sz_request_table_name := 'rtrsp_ohlc_4d_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '2D')  THEN sz_request_table_name := 'rtrsp_ohlc_2d_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '1D')  THEN sz_request_table_name := 'rtrsp_ohlc_1d_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '12H') THEN sz_request_table_name := 'rtrsp_ohlc_12h_history' ; END IF ;
              IF (sz_time_frame_list[v_time_frame] = '8H')  THEN sz_request_table_name := 'rtrsp_ohlc_8h_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '4H')  THEN sz_request_table_name := 'rtrsp_ohlc_4h_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '3H')  THEN sz_request_table_name := 'rtrsp_ohlc_3h_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '2H')  THEN sz_request_table_name := 'rtrsp_ohlc_2h_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '1H')  THEN sz_request_table_name := 'rtrsp_ohlc_1h_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '30M') THEN sz_request_table_name := 'rtrsp_ohlc_30m_history' ; END IF ;
              IF (sz_time_frame_list[v_time_frame] = '15M') THEN sz_request_table_name := 'rtrsp_ohlc_15m_history' ; END IF ;
              IF (sz_time_frame_list[v_time_frame] = '10M') THEN sz_request_table_name := 'rtrsp_ohlc_10m_history' ; END IF ;
              IF (sz_time_frame_list[v_time_frame] = '5M')  THEN sz_request_table_name := 'rtrsp_ohlc_5m_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '3M')  THEN sz_request_table_name := 'rtrsp_ohlc_3m_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '1M')  THEN sz_request_table_name := 'rtrsp_ohlc_1m_history' ;  END IF ;

              sz_months_list_request = 'select src.tsp from (select date_trunc(''month'',timestamp_point) tsp from '||sz_request_table_name||') src group by src.tsp order by 1 asc' ;
              FOR ds_months_list IN EXECUTE sz_months_list_request LOOP
			      sz_currency_pairs_request = 'select currency, reference_currency from '||sz_request_table_name||' group by currency, reference_currency order by 1,2' ;
                  FOR rec_currency_pairs_list IN EXECUTE sz_currency_pairs_request LOOP
                  sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||' заполнение ретро данных RSI, от '||ds_months_list.tsp - INTERVAL '2 days' ||' до '||ds_months_list.tsp + INTERVAL '32 days' ;
--				  RAISE NOTICE '[start driver] %/% ТФ% заполнение ретроспективных данных RSI, от % до %', rec_currency_pairs_list.currency, rec_currency_pairs_list.reference_currency,sz_time_frame_list[v_time_frame],v_time_reduce_interval, v_time_grow_interval ;
--                  RAISE NOTICE '%', sz_msg ;
					  insert into cragran_logs values(clock_timestamp(),'rtsp_cacl_indicator_RSI','fn_rtsp_driver_fill_rsi_tables',sz_msg) ;
				  MERGE INTO rtrsp_rsi_history dst
                        USING (SELECT * FROM fn_rtrsp_calck_RSI(v_indicator_periods,rec_currency_pairs_list.currency,rec_currency_pairs_list.reference_currency, sz_time_frame_list[v_time_frame], ds_months_list.tsp - INTERVAL '2 days', ds_months_list.tsp + INTERVAL '32 days')) src
	                    ON src.currency = dst.currency AND src.reference_currency = dst.reference_currency AND
                           src.timestamp_point = dst.timestamp_point AND src.time_frame = dst.time_frame AND src.indicator_periods = dst.indicator_periods
                  WHEN MATCHED THEN
                       UPDATE SET price_close = src.price_close, price_close_pre = src.price_close_pre, change_up_val = src.change_up_val,
		                          change_down_val = src.change_down_val, up_rma = src.up_rma, down_rma = src.down_rma, RS = src.RS, 
					              RSI = src.RSI, change_ts = src.change_ts
                  WHEN NOT MATCHED THEN
                       INSERT (currency, reference_currency, timestamp_point, time_frame, indicator_periods, price_close, price_close_pre,
	  	                      change_up_val, change_down_val, up_rma, down_rma, RS, RSI, change_ts)
                              VALUES (src.currency, src.reference_currency, src.timestamp_point, src.time_frame, src.indicator_periods,
							         src.price_close, src.price_close_pre, src.change_up_val, src.change_down_val, src.up_rma,
									 src.down_rma, src.RS, src.RSI, src.change_ts) ;
--                      perform fn_rtrsp_calck_RSI(v_indicator_periods,rec_currency_pairs_list.currency,rec_currency_pairs_list.reference_currency, sz_time_frame_list[v_time_frame], v_time_reduce_interval, v_time_grow_interval) ;
                      commit ;
                  END LOOP ;
              END loop ;
              commit ;
          END loop ;
          end if ;

       if (v_period_mode = 'operative' OR v_period_mode = 'gap_2_days' OR v_period_mode = 'gap_2_months') then
          for v_time_frame IN 1..17 LOOP
              IF (sz_time_frame_list[v_time_frame] = '4W')  THEN sz_request_table_name := 'rtrsp_ohlc_4w_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '1W')  THEN sz_request_table_name := 'rtrsp_ohlc_1w_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '4D')  THEN sz_request_table_name := 'rtrsp_ohlc_4d_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '2D')  THEN sz_request_table_name := 'rtrsp_ohlc_2d_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '1D')  THEN sz_request_table_name := 'rtrsp_ohlc_1d_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '12H') THEN sz_request_table_name := 'rtrsp_ohlc_12h_history' ; END IF ;
              IF (sz_time_frame_list[v_time_frame] = '8H')  THEN sz_request_table_name := 'rtrsp_ohlc_8h_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '4H')  THEN sz_request_table_name := 'rtrsp_ohlc_4h_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '3H')  THEN sz_request_table_name := 'rtrsp_ohlc_3h_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '2H')  THEN sz_request_table_name := 'rtrsp_ohlc_2h_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '1H')  THEN sz_request_table_name := 'rtrsp_ohlc_1h_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '30M') THEN sz_request_table_name := 'rtrsp_ohlc_30m_history' ; END IF ;
              IF (sz_time_frame_list[v_time_frame] = '15M') THEN sz_request_table_name := 'rtrsp_ohlc_15m_history' ; END IF ;
              IF (sz_time_frame_list[v_time_frame] = '10M') THEN sz_request_table_name := 'rtrsp_ohlc_10m_history' ; END IF ;
              IF (sz_time_frame_list[v_time_frame] = '5M')  THEN sz_request_table_name := 'rtrsp_ohlc_5m_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '3M')  THEN sz_request_table_name := 'rtrsp_ohlc_3m_history' ;  END IF ;
              IF (sz_time_frame_list[v_time_frame] = '1M')  THEN sz_request_table_name := 'rtrsp_ohlc_1m_history' ;  END IF ;

              sz_currency_pairs_request = 'select currency, reference_currency from '||sz_request_table_name||' group by currency, reference_currency order by 1,2' ;
              FOR rec_currency_pairs_list IN EXECUTE sz_currency_pairs_request LOOP
                  sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||' заполнение ретро данных RSI, от '||v_time_reduce_interval||' до '||v_time_grow_interval ;
--				  RAISE NOTICE '[start driver] %/% ТФ% заполнение ретро данных RSI, от % до %', rec_currency_pairs_list.currency, rec_currency_pairs_list.reference_currency,sz_time_frame_list[v_time_frame],v_time_reduce_interval, v_time_grow_interval ;
--                  RAISE NOTICE '%', sz_msg ;

                  insert into cragran_logs values(clock_timestamp(),'rtsp_cacl_indicator_RSI','fn_rtsp_driver_fill_rsi_tables',sz_msg) ;
				  MERGE INTO rtrsp_rsi_history dst
                        USING (SELECT * FROM fn_rtrsp_calck_RSI(v_indicator_periods,rec_currency_pairs_list.currency,rec_currency_pairs_list.reference_currency, sz_time_frame_list[v_time_frame], v_time_reduce_interval, v_time_grow_interval)) src
	                    ON src.currency = dst.currency AND src.reference_currency = dst.reference_currency AND
                           src.timestamp_point = dst.timestamp_point AND src.time_frame = dst.time_frame AND src.indicator_periods = dst.indicator_periods
                  WHEN MATCHED THEN
                       UPDATE SET price_close = src.price_close, price_close_pre = src.price_close_pre, change_up_val = src.change_up_val,
		                          change_down_val = src.change_down_val, up_rma = src.up_rma, down_rma = src.down_rma, RS = src.RS, 
					              RSI = src.RSI, change_ts = src.change_ts
                  WHEN NOT MATCHED THEN
                       INSERT (currency, reference_currency, timestamp_point, time_frame, indicator_periods, price_close, price_close_pre,
	  	                      change_up_val, change_down_val, up_rma, down_rma, RS, RSI, change_ts)
                              VALUES (src.currency, src.reference_currency, src.timestamp_point, src.time_frame, src.indicator_periods,
							         src.price_close, src.price_close_pre, src.change_up_val, src.change_down_val, src.up_rma,
									 src.down_rma, src.RS, src.RSI, src.change_ts) ;
--                  perform fn_rtrsp_calck_RSI(v_indicator_periods,rec_currency_pairs_list.currency,rec_currency_pairs_list.reference_currency, sz_time_frame_list[v_time_frame], v_time_reduce_interval, v_time_grow_interval) ;
                  commit ;
              END loop ;
              commit ;
          END loop ;
          end if ;	   

END ;
$BODY$;	

CALL fn_rtsp_driver_fill_rsi_tables(14,'all') ;

--delete from cragran_logs where module = 'fn_rtsp_driver_fill_rsi_tables' ;
--delete from rtrsp_rsi_history ;

select * from cragran_logs order by 1 desc limit 1000 ;
select count(*) from rtrsp_rsi_history ;

-- #######################################################################################################################################
-- Итерация 1. конец блока заполнения через merge, без указания numeric(42,21) создавала TOAST и плодила обьём
-- #######################################################################################################################################

       
-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.14 конец -- таблицы и функции заполнения ретроспективного RSI
-- ---------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.15 начало -- таблицы и функции заполнения ретроспективного MACD
-- ---------------------------------------------------------------------------------------------------------------------------

-- DROP TABLE IF EXISTS public.rtrsp_macd_history CASCADE ;
-- truncate TABLE public.rtrsp_macd_history ;
CREATE TABLE IF NOT EXISTS public.rtrsp_macd_history(
       currency character varying(100) NOT NULL,
       reference_currency character varying(100) NOT NULL,
       timestamp_point timestamp without time zone NOT NULL,
       time_frame character varying(10) NOT NULL,
   	   long_ema_periods integer NOT NULL,
	   short_ema_periods integer NOT NULL,
       sma_periods integer NOT NULL,
	   price_close numeric(42,21),
       long_ema numeric(42,21),
	   long_ema_pre numeric(42,21),
       short_ema numeric(42,21),
	   short_ema_pre numeric(42,21),
       diff_ema numeric(42,21),
       sma_diff_ema numeric(42,21),
	   gist_value numeric(42,21),
	   gist_positive_rise numeric(42,21),
	   gist_positive_fall numeric(42,21),
	   gist_negative_rise numeric(42,21),
	   gist_negative_fall numeric(42,21),
       change_ts timestamp without time zone,
       CONSTRAINT rtrsp_macd_history_pkey 
	              PRIMARY KEY (currency, reference_currency, timestamp_point, time_frame,
		                      long_ema_periods, short_ema_periods, sma_periods)
       ) ;

-- DROP FUNCTION IF EXISTS public.fn_rtrsp_calck_macd_as_table ;
CREATE OR REPLACE FUNCTION public.fn_rtrsp_calck_macd_as_table(
	   v_long_ema_periods integer,
	   v_short_ema_periods integer,
   	   v_sma_periods integer,	
	   v_currency character varying,
	   v_reference_currency character varying,
	   v_time_frame character varying,
	   v_time_start timestamp without time zone,
	   v_time_stop timestamp without time zone)
       RETURNS SETOF rtrsp_macd_history 
       LANGUAGE 'plpgsql'
       AS $BODY$
       DECLARE
       result_record           rtrsp_macd_history%ROWTYPE ;
       sz_base_cursor_request  VARCHAR ;
       sz_request_table_name   VARCHAR ;
       ds_price_close_result   RECORD ;
	   cnt_ds_price_close      BIGINT ;
       v_long_ema_mult         NUMERIC ;
       v_long_ema              NUMERIC ;
	   v_long_ema_pre          NUMERIC ;
       v_short_ema_mult        NUMERIC ;
       v_short_ema             NUMERIC ;
	   v_short_ema_pre         NUMERIC ;
       v_diff_ema              NUMERIC ;
	   v_diff_ema_pre          NUMERIC ;
	   v_diff_ema_pre_02       NUMERIC ;
	   v_diff_ema_pre_03       NUMERIC ;
	   v_diff_ema_pre_04       NUMERIC ;
	   v_diff_ema_pre_05       NUMERIC ;
	   v_diff_ema_pre_06       NUMERIC ;
	   v_diff_ema_pre_07       NUMERIC ;
	   v_diff_ema_pre_08       NUMERIC ;
	   v_diff_ema_pre_09       NUMERIC ;
-- т.к. отсчитать SMA по изменяемой глубине - задача более сложная и менее обоснованная, плюс лишние итерации и время
-- будем фиксировать значение на типовом = 9, и под него строить запрос
-- даже при формировании EMA из младших ТФ в попытке быстрее получить сигнал - обсчёт SMA=9 не меняется
       v_sma_diff_ema          NUMERIC ;
       v_sma_diff_ema_pre      NUMERIC ;
	   v_gist_value            NUMERIC ;
	   v_gist_value_pre        NUMERIC ;
       v_gist_positive_rise    NUMERIC ;
	   v_gist_positive_fall    NUMERIC ;
	   v_gist_negative_rise    NUMERIC ;
	   v_gist_negative_fall    NUMERIC ;
       BEGIN
       v_long_ema := 0.0 ; v_long_ema_pre := 0.0 ; v_short_ema := 0.0 ; v_short_ema_pre := 0.0 ; v_diff_ema := 0.0 ; v_diff_ema_pre := 0.0 ; v_diff_ema_pre_02 := 0.0 ;
	   v_diff_ema_pre_03 := 0.0 ; v_diff_ema_pre_04 := 0.0 ; v_diff_ema_pre_05 := 0.0 ; v_diff_ema_pre_06 := 0.0 ; v_diff_ema_pre_07 := 0.0 ; v_diff_ema_pre_08 := 0.0 ;
	   v_diff_ema_pre_09 := 0.0 ; v_sma_diff_ema := 0.0 ; v_sma_diff_ema_pre := 0.0 ; v_gist_value := 0.0 ; v_gist_value_pre := 0.0 ; v_gist_positive_rise := 0.0 ;
	   v_gist_positive_fall := 0.0 ; v_gist_negative_rise := 0.0 ; v_gist_negative_fall := 0.0 ; cnt_ds_price_close := 0 ;
	   
       v_long_ema_mult = 2 / (v_long_ema_periods::float + 1) ; v_short_ema_mult = 2 / (v_short_ema_periods::float + 1) ; 
	   
       --sz_request_table_name := 'rtrsp_ohlc_30m_history' ;
       IF (v_time_frame = '4W')  THEN sz_request_table_name := 'rtrsp_ohlc_4w_history' ;  END IF ;
       IF (v_time_frame = '1W')  THEN sz_request_table_name := 'rtrsp_ohlc_1w_history' ;  END IF ;
       IF (v_time_frame = '4D')  THEN sz_request_table_name := 'rtrsp_ohlc_4d_history' ;  END IF ;
       IF (v_time_frame = '2D')  THEN sz_request_table_name := 'rtrsp_ohlc_2d_history' ;  END IF ;
       IF (v_time_frame = '1D')  THEN sz_request_table_name := 'rtrsp_ohlc_1d_history' ;  END IF ;
       IF (v_time_frame = '12H') THEN sz_request_table_name := 'rtrsp_ohlc_12h_history' ; END IF ;
       IF (v_time_frame = '8H')  THEN sz_request_table_name := 'rtrsp_ohlc_8h_history' ;  END IF ;
       IF (v_time_frame = '4H')  THEN sz_request_table_name := 'rtrsp_ohlc_4h_history' ;  END IF ;
       IF (v_time_frame = '3H')  THEN sz_request_table_name := 'rtrsp_ohlc_3h_history' ;  END IF ;
       IF (v_time_frame = '2H')  THEN sz_request_table_name := 'rtrsp_ohlc_2h_history' ;  END IF ;
       IF (v_time_frame = '1H')  THEN sz_request_table_name := 'rtrsp_ohlc_1h_history' ;  END IF ;
       IF (v_time_frame = '30M') THEN sz_request_table_name := 'rtrsp_ohlc_30m_history' ; END IF ;
       IF (v_time_frame = '15M') THEN sz_request_table_name := 'rtrsp_ohlc_15m_history' ; END IF ;
       IF (v_time_frame = '10M') THEN sz_request_table_name := 'rtrsp_ohlc_10m_history' ; END IF ;
       IF (v_time_frame = '5M')  THEN sz_request_table_name := 'rtrsp_ohlc_5m_history' ;  END IF ;
       IF (v_time_frame = '3M')  THEN sz_request_table_name := 'rtrsp_ohlc_3m_history' ;  END IF ;
       IF (v_time_frame = '1M')  THEN sz_request_table_name := 'rtrsp_ohlc_1m_history' ;  END IF ;

       sz_base_cursor_request := 'select currency, reference_currency, timestamp_point, price_close
                                         from '||sz_request_table_name||' where currency = $1 AND reference_currency = $2 and 
                                              timestamp_point >= $3 AND timestamp_point <= $4
                                         ORDER BY currency, reference_currency, timestamp_point asc' ;
       FOR ds_price_close_result IN EXECUTE sz_base_cursor_request USING v_currency, v_reference_currency, v_time_start, v_time_stop LOOP
-- расчёт по строкам dataset
           result_record.currency           := ds_price_close_result.currency ;
           result_record.reference_currency := ds_price_close_result.reference_currency ;
           result_record.timestamp_point    := ds_price_close_result.timestamp_point ;
           result_record.time_frame         := v_time_frame ;
   	       result_record.long_ema_periods   := v_long_ema_periods ;
	       result_record.short_ema_periods  := v_short_ema_periods ;
           result_record.sma_periods        := v_sma_periods ;
		   result_record.price_close        := ds_price_close_result.price_close ;
           IF ( cnt_ds_price_close = 0 ) THEN 
-- для первой записи дополнять нечем - пржнего значения нет, и тут берётся сама цена закрытия
              result_record.long_ema        := ROUND(ds_price_close_result.price_close, 21) ;
              result_record.short_ema       := ROUND(ds_price_close_result.price_close, 21) ;
		   ELSE 
              result_record.long_ema        := ROUND(((ds_price_close_result.price_close * v_long_ema_mult) + (v_long_ema_pre * (1 - v_long_ema_mult))), 21) ;
              result_record.short_ema       := ROUND(((ds_price_close_result.price_close * v_short_ema_mult) + (v_short_ema_pre * (1 - v_short_ema_mult))), 21) ;
		   END IF ;
		   result_record.long_ema_pre       := v_long_ema_pre ;
		   result_record.short_ema_pre      := v_short_ema_pre ;
           result_record.diff_ema           := ROUND(result_record.long_ema - result_record.short_ema, 21) ;
           result_record.sma_diff_ema       := ROUND((v_diff_ema_pre + v_diff_ema_pre_02 + v_diff_ema_pre_03 + v_diff_ema_pre_04 + v_diff_ema_pre_05 + v_diff_ema_pre_06 + v_diff_ema_pre_07 + v_diff_ema_pre_08 + v_diff_ema_pre_09) / 9, 21) ;
	       v_gist_value                     := result_record.diff_ema - result_record.sma_diff_ema ;
		   result_record.gist_value         := ROUND(v_gist_value, 21) ;
-- заполнить поля раздельных столбцов для отрисовки stacked bars диаграммы
           result_record.gist_positive_rise := 0 ;
	       result_record.gist_positive_fall := 0 ;			  
	       result_record.gist_negative_rise := 0 ;
		   result_record.gist_negative_fall := 0 ;
-- если гистограмма положительна - заполнить поле роста или падения, сравнив с предыдущим значением
           IF ( v_gist_value > 0 ) THEN
		      IF ( v_gist_value - v_gist_value_pre > 0 ) THEN result_record.gist_positive_rise := result_record.gist_value ; END IF ;
		      IF ( v_gist_value - v_gist_value_pre < 0 ) THEN result_record.gist_positive_fall := result_record.gist_value ; END IF ;
           END IF ;
-- если гистограмма отрицательна - заполнить поле роста или падения, сравнив с предыдущим значением		   
           IF ( v_gist_value < 0 ) THEN
		      IF ( v_gist_value - v_gist_value_pre < 0 ) THEN result_record.gist_negative_rise := result_record.gist_value ; END IF ;
		      IF ( v_gist_value - v_gist_value_pre > 0 ) THEN result_record.gist_negative_fall := result_record.gist_value ; END IF ;
           END IF ;
           result_record.change_ts          := now() ;
-- сохраняем прежние значения EMA для расчёта текущих
           v_long_ema_pre := result_record.long_ema ; v_short_ema_pre := result_record.short_ema ;
-- сдвигаем переменные для расчёта SMA9
           v_diff_ema_pre_09 := v_diff_ema_pre_08 ; v_diff_ema_pre_08 := v_diff_ema_pre_07 ; v_diff_ema_pre_07 := v_diff_ema_pre_06 ;
		   v_diff_ema_pre_06 := v_diff_ema_pre_05 ; v_diff_ema_pre_05 := v_diff_ema_pre_04 ; v_diff_ema_pre_04 := v_diff_ema_pre_03 ;
		   v_diff_ema_pre_03 := v_diff_ema_pre_02 ; v_diff_ema_pre_02 := v_diff_ema_pre ;
-- сохраняем прежние значения для учёта в расширенных столбцах гистограммы
           v_diff_ema_pre := result_record.diff_ema ; v_sma_diff_ema_pre := result_record.sma_diff_ema ; v_gist_value_pre := result_record.gist_value ;
           cnt_ds_price_close := cnt_ds_price_close + 1 ;
           return next result_record ;
           END LOOP ;
       RETURN ;
       END ;
$BODY$;

select * from fn_rtrsp_calck_macd_as_table(26::integer, 12::integer, 9::integer, 'BTC'::varchar, 'USDT'::varchar,'1M'::varchar,
			  CAST((now() - INTERVAL '200 days') AS timestamp without time zone),
			  CAST((now() - INTERVAL '100 day') AS timestamp without time zone )) ;

DROP PROCEDURE public.fn_rtsp_driver_fill_macd_tables ;
CREATE OR REPLACE PROCEDURE public.fn_rtsp_driver_fill_macd_tables(
    IN v_long_ema_periods integer,
    IN v_short_ema_periods integer,
    IN v_sma_periods integer,
    IN v_period_mode character varying)
LANGUAGE 'plpgsql'
AS $BODY$
       DECLARE
       sz_msg                    VARCHAR ;
       sz_request_table_name     VARCHAR ;
       ds_months_list            RECORD ;
       sz_months_list_request    VARCHAR ;
       sz_currency_pairs_request VARCHAR ;  
       rec_currency_pairs_list   RECORD ;
       sz_time_period            VARCHAR ;
       sz_time_frame_list        VARCHAR[16] := '{"1M","3M","5M","10M","15M","30M","1H","2H","3H","4H","8H","12H","1D","2D","4D","1W","4W"}' ;
--       sz_time_frame_list VARCHAR[16] := '{"30M","15M"}' ;
       sz_time_frame             VARCHAR ;
       v_time_reduce_interval    timestamp without time zone ;
       v_time_grow_interval      timestamp without time zone ;
       BEGIN
-- выставляем переменные периодов в зависимости от выбранного режима работы        
       v_time_reduce_interval = clock_timestamp() - INTERVAL '2 days' ; v_time_grow_interval = clock_timestamp() + INTERVAL '32 days' ;
       if (v_period_mode = 'operative') then
          v_time_reduce_interval = clock_timestamp() - INTERVAL '30 minutes' ; 
	  v_time_grow_interval = clock_timestamp() + INTERVAL '20 minutes' ;
          end if ;
       if (v_period_mode = 'gap_2_days') then
          v_time_reduce_interval = clock_timestamp() - INTERVAL '50 hours' ; 
	  v_time_grow_interval =  clock_timestamp() + INTERVAL '3 hours' ;
          end if ;
       if (v_period_mode = 'gap_2_months') then
          v_time_reduce_interval = clock_timestamp() - INTERVAL '92 days' ; 
	  v_time_grow_interval =  clock_timestamp() + INTERVAL '2 days' ;
          end if ;
       if (v_period_mode = 'all') then
          v_time_reduce_interval = clock_timestamp() - INTERVAL '92 years' ; 
	  v_time_grow_interval =  clock_timestamp() + INTERVAL '2 years' ;
          end if ;		  
-- обрабатываем записи
       for v_time_frame IN 1..17 LOOP
           IF (sz_time_frame_list[v_time_frame] = '4W')  THEN sz_request_table_name := 'rtrsp_ohlc_4w_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '1W')  THEN sz_request_table_name := 'rtrsp_ohlc_1w_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '4D')  THEN sz_request_table_name := 'rtrsp_ohlc_4d_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '2D')  THEN sz_request_table_name := 'rtrsp_ohlc_2d_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '1D')  THEN sz_request_table_name := 'rtrsp_ohlc_1d_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '12H') THEN sz_request_table_name := 'rtrsp_ohlc_12h_history' ; END IF ;
           IF (sz_time_frame_list[v_time_frame] = '8H')  THEN sz_request_table_name := 'rtrsp_ohlc_8h_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '4H')  THEN sz_request_table_name := 'rtrsp_ohlc_4h_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '3H')  THEN sz_request_table_name := 'rtrsp_ohlc_3h_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '2H')  THEN sz_request_table_name := 'rtrsp_ohlc_2h_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '1H')  THEN sz_request_table_name := 'rtrsp_ohlc_1h_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '30M') THEN sz_request_table_name := 'rtrsp_ohlc_30m_history' ; END IF ;
           IF (sz_time_frame_list[v_time_frame] = '15M') THEN sz_request_table_name := 'rtrsp_ohlc_15m_history' ; END IF ;
           IF (sz_time_frame_list[v_time_frame] = '10M') THEN sz_request_table_name := 'rtrsp_ohlc_10m_history' ; END IF ;
           IF (sz_time_frame_list[v_time_frame] = '5M')  THEN sz_request_table_name := 'rtrsp_ohlc_5m_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '3M')  THEN sz_request_table_name := 'rtrsp_ohlc_3m_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '1M')  THEN sz_request_table_name := 'rtrsp_ohlc_1m_history' ;  END IF ;

           if (v_period_mode = 'all' OR v_period_mode = 'operative' OR v_period_mode = 'gap_2_days' OR v_period_mode = 'gap_2_months') then
              sz_currency_pairs_request = 'select currency, reference_currency from '||sz_request_table_name||' group by currency, reference_currency order by 1,2' ;
--              sz_currency_pairs_request = 'select currency, reference_currency from '||sz_request_table_name||' where currency not in (''BONK'',''BNB'',''BLZ'',''BIT'',''BGB'',''BEAM'',''BCH'',''AXS'',''AXL'',''AVAX'',''AUDIO'',''ATOM'',''ARB'',''AR'',''APT'',''APEX'',''APE'',''ALGO'',''AKT'',''AGIX'',''ADA'',''ACH'',''ACA'',''AAVE'',''aaa'',''1INCH'') group by currency, reference_currency order by 1,2' ;
              FOR rec_currency_pairs_list IN EXECUTE sz_currency_pairs_request LOOP
	          sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||', lng_ema_prds '||v_long_ema_periods||', shr_ema_prds '||v_short_ema_periods||', sma_prds '||v_sma_periods||', старт заполнения ретро данных MACD c '||TO_CHAR(v_time_reduce_interval,'YYYY-MM-DD HH24:MI:SS')||' по '||TO_CHAR(v_time_grow_interval,'YYYY-MM-DD HH24:MI:SS') ;
--debug
RAISE NOTICE '%', sz_msg ;
	          insert into cragran_logs values(clock_timestamp(),'rtsp_cacl_indicator_MACD','fn_rtsp_driver_fill_macd_tables',sz_msg) ;
		  COMMIT ;
		  BEGIN
		  MERGE INTO rtrsp_macd_history dst
                        USING (SELECT * FROM fn_rtrsp_calck_MACD_as_table(v_long_ema_periods, v_short_ema_periods, v_sma_periods, rec_currency_pairs_list.currency, rec_currency_pairs_list.reference_currency, sz_time_frame_list[v_time_frame], v_time_reduce_interval, v_time_grow_interval)) src
                        ON src.currency = dst.currency AND src.reference_currency = dst.reference_currency AND src.timestamp_point = dst.timestamp_point AND
			   src.time_frame = dst.time_frame AND src.long_ema_periods = dst.long_ema_periods AND src.short_ema_periods = dst.short_ema_periods AND
			   src.sma_periods = dst.sma_periods
                        WHEN MATCHED AND NOT (src.price_close = dst.price_close AND src.long_ema = dst.long_ema AND src.long_ema_pre = dst.long_ema_pre AND
					      src.short_ema = dst.short_ema AND src.short_ema_pre = dst.short_ema_pre AND src.diff_ema = dst.diff_ema AND
					      src.sma_diff_ema = dst.sma_diff_ema AND src.gist_value = dst.gist_value AND src.gist_positive_rise = dst.gist_positive_rise AND
					      src.gist_positive_fall = dst.gist_positive_fall AND src.gist_negative_rise = dst.gist_negative_rise AND 
					      src.gist_negative_fall = dst.gist_negative_fall) THEN 
                             UPDATE SET price_close = src.price_close, long_ema = src.long_ema, long_ema_pre = src.long_ema_pre, short_ema = src.short_ema,
			                short_ema_pre = src.short_ema_pre, diff_ema = src.diff_ema, sma_diff_ema = src.sma_diff_ema, gist_value = dst.gist_value,
					gist_positive_rise = src.gist_positive_rise, gist_positive_fall = src.gist_positive_fall, gist_negative_rise = src.gist_negative_rise,
					gist_negative_fall = src.gist_negative_fall, change_ts = src.change_ts
                        WHEN NOT MATCHED THEN
                             INSERT (currency, reference_currency, timestamp_point, time_frame, long_ema_periods, short_ema_periods, sma_periods, price_close, long_ema,
				     long_ema_pre, short_ema, short_ema_pre, diff_ema, sma_diff_ema, gist_value, gist_positive_rise, gist_positive_fall, gist_negative_rise,
				     gist_negative_fall, change_ts)
                                    VALUES (src.currency, src.reference_currency, src.timestamp_point, src.time_frame, src.long_ema_periods, src.short_ema_periods,
					    src.sma_periods, src.price_close, src.long_ema, src.long_ema_pre, src.short_ema, src.short_ema_pre, src.diff_ema,
					    src.sma_diff_ema, src.gist_value, src.gist_positive_rise, src.gist_positive_fall, src.gist_negative_rise, src.gist_negative_fall,
					    src.change_ts) ;
                  sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||', lng_ema_prds '||v_long_ema_periods||', shr_ema_prds '||v_short_ema_periods||', sma_prds '||v_sma_periods||', стоп заполнения ретро данных MACD' ;
		  insert into cragran_logs values(clock_timestamp(),'rtsp_cacl_indicator_MACD','fn_rtsp_driver_fill_macd_tables',sz_msg) ;	
--                  COMMIT ;
                  EXCEPTION WHEN OTHERS THEN
--GET STACKED DIAGNOSTICS text_var1 = MESSAGE_TEXT,
--                          text_var2 = PG_EXCEPTION_DETAIL,
--                          text_var3 = PG_EXCEPTION_HINT;
                            sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||', lng_ema_prds: '||v_long_ema_periods||', shr_ema_prds: '||v_short_ema_periods||', sma_prds: '||v_sma_periods||', стоп заполнения ретро данных MACD, SQLERRM: '||SQLERRM ;
		            insert into cragran_logs values(clock_timestamp(),'rtsp_cacl_indicator_MACD','fn_fill_macd_history','Error INSERT '||sz_msg) ;
	          END ; -- конец блока EXCEPTION
		  COMMIT ;
                  END LOOP ;
              END IF ;

           IF (v_period_mode = 'all_per_month') THEN
              sz_months_list_request = 'select src.tsp from (select date_trunc(''month'',timestamp_point) tsp from '||sz_request_table_name||') src group by src.tsp order by 1 asc' ;
              FOR ds_months_list IN EXECUTE sz_months_list_request LOOP
	          sz_currency_pairs_request = 'select currency, reference_currency from '||sz_request_table_name||' group by currency, reference_currency order by 1,2' ;
                  FOR rec_currency_pairs_list IN EXECUTE sz_currency_pairs_request LOOP
                      sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||', lng_ema_prds '||v_long_ema_periods||', shr_ema_prds '||v_short_ema_periods||', sma_prds '||v_sma_periods||', старт заполнения ретро данных MACD' ;
--				    RAISE NOTICE '[start driver] %/% ТФ% старт заполнения ретроспективных данных RSI, от % до %', rec_currency_pairs_list.currency, rec_currency_pairs_list.reference_currency,sz_time_frame_list[v_time_frame],v_time_reduce_interval, v_time_grow_interval ;
--                  RAISE NOTICE '%', sz_msg ;
	              insert into cragran_logs values(clock_timestamp(),'rtsp_cacl_indicator_MACD','fn_rtsp_driver_fill_macd_tables',sz_msg) ;
		      COMMIT ;
		      BEGIN
		      MERGE INTO rtrsp_macd_history dst
                            USING (SELECT * FROM fn_rtrsp_calck_MACD_as_table(v_long_ema_periods, v_short_ema_periods, v_sma_periods, rec_currency_pairs_list.currency, rec_currency_pairs_list.reference_currency, sz_time_frame_list[v_time_frame], v_time_reduce_interval, v_time_grow_interval)) src
                            ON src.currency = dst.currency AND src.reference_currency = dst.reference_currency AND src.timestamp_point = dst.timestamp_point AND
			       src.time_frame = dst.time_frame AND src.long_ema_periods = dst.long_ema_periods AND src.short_ema_periods = dst.short_ema_periods AND
			       src.sma_periods = dst.sma_periods
                            WHEN MATCHED AND NOT (src.price_close = dst.price_close AND src.long_ema = dst.long_ema AND src.long_ema_pre = dst.long_ema_pre AND
					          src.short_ema = dst.short_ema AND src.short_ema_pre = dst.short_ema_pre AND src.diff_ema = dst.diff_ema AND
					          src.sma_diff_ema = dst.sma_diff_ema AND src.gist_value = dst.gist_value AND src.gist_positive_rise = dst.gist_positive_rise AND
					          src.gist_positive_fall = dst.gist_positive_fall AND src.gist_negative_rise = dst.gist_negative_rise AND 
					          src.gist_negative_fall = dst.gist_negative_fall) THEN 
                                 UPDATE SET price_close = src.price_close, long_ema = src.long_ema, long_ema_pre = src.long_ema_pre, short_ema = src.short_ema,
			                    short_ema_pre = src.short_ema_pre, diff_ema = src.diff_ema, sma_diff_ema = src.sma_diff_ema, gist_value = dst.gist_value,
					    gist_positive_rise = src.gist_positive_rise, gist_positive_fall = src.gist_positive_fall, gist_negative_rise = src.gist_negative_rise,
					    gist_negative_fall = src.gist_negative_fall, change_ts = src.change_ts
                            WHEN NOT MATCHED THEN
--   	   long_ema_periods, short_ema_periods, sma_periods, long_ema, short_ema, diff_ema, sma_diff_ema, gist_value, gist_positive_rise, gist_positive_fall, gist_negative_rise, gist_negative_fall, change_ts
                                 INSERT (currency, reference_currency, timestamp_point, time_frame, long_ema_periods, short_ema_periods, sma_periods, price_close, long_ema,
				         long_ema_pre, short_ema, short_ema_pre, diff_ema, sma_diff_ema, gist_value, gist_positive_rise, gist_positive_fall, gist_negative_rise,
				         gist_negative_fall, change_ts)
                                        VALUES (src.currency, src.reference_currency, src.timestamp_point, src.time_frame, src.long_ema_periods, src.short_ema_periods,
					        src.sma_periods, src.price_close, src.long_ema, src.long_ema_pre, src.short_ema, src.short_ema_pre, src.diff_ema,
					        src.sma_diff_ema, src.gist_value, src.gist_positive_rise, src.gist_positive_fall, src.gist_negative_rise, src.gist_negative_fall,
					        src.change_ts) ;
                      sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||', lng_ema_prds '||v_long_ema_periods||', shr_ema_prds '||v_short_ema_periods||', sma_prds '||v_sma_periods||', стоп заполнения ретро данных MACD' ;
		      insert into cragran_logs values(clock_timestamp(),'rtsp_cacl_indicator_MACD','fn_rtsp_driver_fill_macd_tables',sz_msg) ;	
--                  COMMIT ;
                      EXCEPTION WHEN OTHERS THEN
                                sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||', lng_ema_prds '||v_long_ema_periods||', shr_ema_prds '||v_short_ema_periods||', sma_prds '||v_sma_periods||', стоп заполнения ретро данных MACD' ;
		                insert into cragran_logs values(clock_timestamp(),'rtsp_cacl_indicator_MACD','fn_fill_macd_history','Error INSERT '||sz_msg) ;
	              END ;
		      COMMIT ;
                      END LOOP ;
                  END LOOP ;
              END IF ;

       END LOOP ; -- конец перебора таймфрэймов
END ;
$BODY$;

-- статистика -- ТФ1М обсчитан за 42 минуты 45 секунд ---
-- статистика -- после исправления формулы ТФ1М обсчитан за 48 минут 30 секунд ---

--CALL fn_rtsp_driver_fill_macd_tables(26,12,9,'all_per_month') ;
--
CALL fn_rtsp_driver_fill_macd_tables(26,12,9,'all') ;

--delete from cragran_logs where module = 'fn_rtsp_driver_fill_MACD_tables' OR module = 'fn_fill_macd_history' ;
--delete from rtrsp_macd_history ;

-- тест для формирования исключения уже посчитанных
select currency, reference_currency
       from rtrsp_ohlc_1m_history
           where currency not in ('BEAM','BCH','AXS','AXL','AVAX','AUDIO','ATOM','ARB','AR','APT','APEX','APE','ALGO','AKT','AGIX','ADA','ACH','ACA','AAVE','aaa','1INCH')
           group by currency, reference_currency
           order by 1,2

select * from cragran_logs order by 1 desc limit 1000 ;
select count(*) from rtrsp_macd_history ;
select * from pg_class where relname = 'rtrsp_macd_history' ;

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.15 конец -- таблицы и функции заполнения ретроспективного MACD
-- ---------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.16 начало -- таблицы и функции заполнения ретроспективного EMA
-- ---------------------------------------------------------------------------------------------------------------------------

-- DROP TABLE IF EXISTS public.rtrsp_ema_history CASCADE ;
-- truncate TABLE public.rtrsp_ema_history ;
-- dataset_class должен однозначно идентифицировать набор значений EMA и их периодов
CREATE TABLE IF NOT EXISTS public.rtrsp_ema_history(
       currency character varying(100) NOT NULL,
       reference_currency character varying(100) NOT NULL,
       timestamp_point timestamp without time zone NOT NULL,
       time_frame character varying(10) NOT NULL,
	   dataset_class character varying(100) NOT NULL,
	   price_close numeric(42,21),
	   ema_01_periods integer, ema_01 numeric(42,21), ema_01_pre numeric(42,21),
	   ema_02_periods integer, ema_02 numeric(42,21), ema_02_pre numeric(42,21),
	   ema_03_periods integer, ema_03 numeric(42,21), ema_03_pre numeric(42,21),
	   ema_04_periods integer, ema_04 numeric(42,21), ema_04_pre numeric(42,21),
	   ema_05_periods integer, ema_05 numeric(42,21), ema_05_pre numeric(42,21),
	   ema_06_periods integer, ema_06 numeric(42,21), ema_06_pre numeric(42,21),
	   ema_07_periods integer, ema_07 numeric(42,21), ema_07_pre numeric(42,21),
	   ema_08_periods integer, ema_08 numeric(42,21), ema_08_pre numeric(42,21),
       change_ts timestamp without time zone,
       CONSTRAINT rtrsp_ema_history_pkey 
                  PRIMARY KEY (currency, reference_currency, timestamp_point, time_frame, dataset_class)
       ) ;

-- DROP FUNCTION IF EXISTS public.fn_rtrsp_calck_ema_as_table() ;
CREATE OR REPLACE FUNCTION public.fn_rtrsp_calck_ema_as_table(
	       v_dataset_class character varying,
	       v_ema_01_periods integer, v_ema_02_periods integer, v_ema_03_periods integer, v_ema_04_periods integer,
           v_ema_05_periods integer, v_ema_06_periods integer, v_ema_07_periods integer, v_ema_08_periods integer,
           v_currency character varying,
           v_reference_currency character varying,
           v_time_frame character varying,
           v_time_start timestamp without time zone,
           v_time_stop timestamp without time zone)
       RETURNS SETOF rtrsp_ema_history
       LANGUAGE 'plpgsql'
       AS $BODY$
       DECLARE
       result_record           rtrsp_ema_history%ROWTYPE ;
       sz_base_cursor_request  VARCHAR ;
       sz_request_table_name   VARCHAR ;
       ds_price_close_result   RECORD ;
       cnt_ds_price_close      BIGINT ;
	   v_ema_01_mult NUMERIC ; v_ema_01_pre NUMERIC ;
	   v_ema_02_mult NUMERIC ; v_ema_02_pre NUMERIC ;
	   v_ema_03_mult NUMERIC ; v_ema_03_pre NUMERIC ;
	   v_ema_04_mult NUMERIC ; v_ema_04_pre NUMERIC ;
	   v_ema_05_mult NUMERIC ; v_ema_05_pre NUMERIC ;
	   v_ema_06_mult NUMERIC ; v_ema_06_pre NUMERIC ;
	   v_ema_07_mult NUMERIC ; v_ema_07_pre NUMERIC ;
	   v_ema_08_mult NUMERIC ; v_ema_08_pre NUMERIC ;

       BEGIN
	   cnt_ds_price_close := 0 ;
       v_ema_01_mult = 2 / (v_ema_01_periods::float + 1) ; v_ema_02_mult = 2 / (v_ema_02_periods::float + 1) ; v_ema_03_mult = 2 / (v_ema_03_periods::float + 1) ;
	   v_ema_04_mult = 2 / (v_ema_04_periods::float + 1) ; v_ema_05_mult = 2 / (v_ema_05_periods::float + 1) ; v_ema_06_mult = 2 / (v_ema_06_periods::float + 1) ;
	   v_ema_07_mult = 2 / (v_ema_07_periods::float + 1) ; v_ema_08_mult = 2 / (v_ema_08_periods::float + 1) ;
       v_ema_01_pre := 0.0 ; v_ema_02_pre := 0.0 ; v_ema_03_pre := 0.0 ; v_ema_04_pre := 0.0 ; v_ema_05_pre := 0.0 ; v_ema_06_pre := 0.0 ; v_ema_07_pre := 0.0 ; v_ema_08_pre := 0.0 ; 

       IF (v_time_frame = '4W')  THEN sz_request_table_name := 'rtrsp_ohlc_4w_history' ;  END IF ;
       IF (v_time_frame = '1W')  THEN sz_request_table_name := 'rtrsp_ohlc_1w_history' ;  END IF ;
       IF (v_time_frame = '4D')  THEN sz_request_table_name := 'rtrsp_ohlc_4d_history' ;  END IF ;
       IF (v_time_frame = '2D')  THEN sz_request_table_name := 'rtrsp_ohlc_2d_history' ;  END IF ;
       IF (v_time_frame = '1D')  THEN sz_request_table_name := 'rtrsp_ohlc_1d_history' ;  END IF ;
       IF (v_time_frame = '12H') THEN sz_request_table_name := 'rtrsp_ohlc_12h_history' ; END IF ;
       IF (v_time_frame = '8H')  THEN sz_request_table_name := 'rtrsp_ohlc_8h_history' ;  END IF ;
       IF (v_time_frame = '4H')  THEN sz_request_table_name := 'rtrsp_ohlc_4h_history' ;  END IF ;
       IF (v_time_frame = '3H')  THEN sz_request_table_name := 'rtrsp_ohlc_3h_history' ;  END IF ;
       IF (v_time_frame = '2H')  THEN sz_request_table_name := 'rtrsp_ohlc_2h_history' ;  END IF ;
       IF (v_time_frame = '1H')  THEN sz_request_table_name := 'rtrsp_ohlc_1h_history' ;  END IF ;
       IF (v_time_frame = '30M') THEN sz_request_table_name := 'rtrsp_ohlc_30m_history' ; END IF ;
       IF (v_time_frame = '15M') THEN sz_request_table_name := 'rtrsp_ohlc_15m_history' ; END IF ;
       IF (v_time_frame = '10M') THEN sz_request_table_name := 'rtrsp_ohlc_10m_history' ; END IF ;
       IF (v_time_frame = '5M')  THEN sz_request_table_name := 'rtrsp_ohlc_5m_history' ;  END IF ;
       IF (v_time_frame = '3M')  THEN sz_request_table_name := 'rtrsp_ohlc_3m_history' ;  END IF ;
       IF (v_time_frame = '1M')  THEN sz_request_table_name := 'rtrsp_ohlc_1m_history' ;  END IF ;

       sz_base_cursor_request := 'select currency, reference_currency, timestamp_point, price_close
                                         from '||sz_request_table_name||' where currency = $1 AND reference_currency = $2 and 
                                              timestamp_point >= $3 AND timestamp_point <= $4
                                         ORDER BY currency, reference_currency, timestamp_point asc' ;
       FOR ds_price_close_result IN EXECUTE sz_base_cursor_request USING v_currency, v_reference_currency, v_time_start, v_time_stop LOOP
-- расчёт по строкам dataset
           result_record.currency           := ds_price_close_result.currency ;
           result_record.reference_currency := ds_price_close_result.reference_currency ;
           result_record.timestamp_point    := ds_price_close_result.timestamp_point ;
           result_record.time_frame         := v_time_frame ;
           result_record.dataset_class      := v_dataset_class ;
           result_record.price_close        := ds_price_close_result.price_close ;

           result_record.ema_01_periods := v_ema_01_periods ; result_record.ema_01_pre := v_ema_01_pre ; 
           IF ( cnt_ds_price_close = 0 ) THEN
		      result_record.ema_01 := ROUND(ds_price_close_result.price_close, 21) ;
		   ELSE
		      result_record.ema_01 := ROUND(((ds_price_close_result.price_close * v_ema_01_mult) + (v_ema_01_pre * (1 - v_ema_01_mult))), 21) ;
		   END IF ;
           result_record.ema_02_periods := v_ema_02_periods ; result_record.ema_02_pre := v_ema_02_pre ; 
		   IF ( cnt_ds_price_close = 0 ) THEN 
		      result_record.ema_02 := ROUND(ds_price_close_result.price_close, 21) ;
		   ELSE
		      result_record.ema_02 := ROUND(((ds_price_close_result.price_close * v_ema_02_mult) + (v_ema_02_pre * (1 - v_ema_02_mult))), 21) ;
		   END IF ;
           result_record.ema_03_periods := v_ema_03_periods ; result_record.ema_03_pre := v_ema_03_pre ; 
		   IF ( cnt_ds_price_close = 0 ) THEN
		      result_record.ema_03 := ROUND(ds_price_close_result.price_close, 21) ;
		   ELSE
		      result_record.ema_03 := ROUND(((ds_price_close_result.price_close * v_ema_03_mult) + (v_ema_03_pre * (1 - v_ema_03_mult))), 21) ;
		   END IF ;
           result_record.ema_04_periods := v_ema_04_periods ; result_record.ema_04_pre := v_ema_04_pre ; 
		   IF ( cnt_ds_price_close = 0 ) THEN
		      result_record.ema_04 := ROUND(ds_price_close_result.price_close, 21) ;
		   ELSE
		      result_record.ema_04 := ROUND(((ds_price_close_result.price_close * v_ema_04_mult) + (v_ema_04_pre * (1 - v_ema_04_mult))), 21) ;
		   END IF ;
           result_record.ema_05_periods := v_ema_05_periods ; result_record.ema_05_pre := v_ema_05_pre ; 
		   IF ( cnt_ds_price_close = 0 ) THEN
		      result_record.ema_05 := ROUND(ds_price_close_result.price_close, 21) ;
		   ELSE
		      result_record.ema_05 := ROUND(((ds_price_close_result.price_close * v_ema_05_mult) + (v_ema_05_pre * (1 - v_ema_05_mult))), 21) ;
		   END IF ;
           result_record.ema_06_periods := v_ema_06_periods ; result_record.ema_06_pre := v_ema_06_pre ; 
		   IF ( cnt_ds_price_close = 0 ) THEN
		      result_record.ema_06 := ROUND(ds_price_close_result.price_close, 21) ;
		   ELSE
		      result_record.ema_06 := ROUND(((ds_price_close_result.price_close * v_ema_06_mult) + (v_ema_06_pre * (1 - v_ema_06_mult))), 21) ;
		   END IF ;
           result_record.ema_07_periods := v_ema_07_periods ; result_record.ema_07_pre := v_ema_07_pre ; 
		   IF ( cnt_ds_price_close = 0 ) THEN
		      result_record.ema_07 := ROUND(ds_price_close_result.price_close, 21) ;
		   ELSE
		      result_record.ema_07 := ROUND(((ds_price_close_result.price_close * v_ema_07_mult) + (v_ema_07_pre * (1 - v_ema_07_mult))), 21) ;
		   END IF ;
           result_record.ema_08_periods := v_ema_08_periods ; result_record.ema_08_pre := v_ema_08_pre ; 
		   IF ( cnt_ds_price_close = 0 ) THEN
		      result_record.ema_08 := ROUND(ds_price_close_result.price_close, 21) ;
		   ELSE
		      result_record.ema_08 := ROUND(((ds_price_close_result.price_close * v_ema_08_mult) + (v_ema_08_pre * (1 - v_ema_08_mult))), 21) ;
		   END IF ;

           result_record.change_ts          := now() ;
-- сохраняем прежние значения EMA для расчёта текущих и заполнения прежних
           v_ema_01_pre = result_record.ema_01 ; v_ema_02_pre = result_record.ema_02 ; v_ema_03_pre = result_record.ema_03 ; v_ema_04_pre = result_record.ema_04 ;
           v_ema_05_pre = result_record.ema_05 ; v_ema_06_pre = result_record.ema_06 ; v_ema_07_pre = result_record.ema_07 ; v_ema_08_pre = result_record.ema_08 ;		   
           cnt_ds_price_close := cnt_ds_price_close + 1 ;
           return next result_record ;
           END LOOP ;
       RETURN ;
       END ;
$BODY$;

select * from fn_rtrsp_calck_ema_as_table('typical0'::varchar, 20, 10, 240, 120, 1537, 770, 0, 0, 'BTC'::varchar, 'USDT'::varchar,'1M'::varchar,
                          CAST((now() - INTERVAL '200 days') AS timestamp without time zone),
                          CAST((now() - INTERVAL '100 day') AS timestamp without time zone )) ;

--DROP PROCEDURE public.fn_rtsp_driver_fill_ema_tables ;
CREATE OR REPLACE PROCEDURE public.fn_rtsp_driver_fill_ema_tables(
          v_dataset_class character varying,
	      v_ema_01_periods integer, v_ema_02_periods integer, v_ema_03_periods integer, v_ema_04_periods integer,
          v_ema_05_periods integer, v_ema_06_periods integer, v_ema_07_periods integer, v_ema_08_periods integer,
          v_period_mode character varying)
LANGUAGE 'plpgsql'
AS $BODY$
       DECLARE
       sz_msg                    VARCHAR ;
       sz_request_table_name     VARCHAR ;
       ds_months_list            RECORD ;
       sz_months_list_request    VARCHAR ;
       sz_currency_pairs_request VARCHAR ;
       rec_currency_pairs_list   RECORD ;
       sz_time_period            VARCHAR ;
       sz_time_frame_list        VARCHAR[16] := '{"1M","3M","5M","10M","15M","30M","1H","2H","3H","4H","8H","12H","1D","2D","4D","1W","4W"}' ;
--       sz_time_frame_list VARCHAR[16] := '{"30M","15M"}' ;
       sz_time_frame             VARCHAR ;
       v_time_reduce_interval    timestamp without time zone ;
       v_time_grow_interval      timestamp without time zone ;
	   err_text_var1                 text ;
	   err_text_var2                 text ;
	   err_text_var3                 text ;
       BEGIN
-- выставляем переменные периодов в зависимости от выбранного режима работы        
       v_time_reduce_interval = clock_timestamp() - INTERVAL '2 days' ; v_time_grow_interval = clock_timestamp() + INTERVAL '32 days' ;
       if (v_period_mode = 'all') then
          v_time_reduce_interval = clock_timestamp() - INTERVAL '200 years' ;
          v_time_grow_interval = clock_timestamp() + INTERVAL '20 years' ;
          end if ;
       if (v_period_mode = 'operative') then
          v_time_reduce_interval = clock_timestamp() - INTERVAL '30 minutes' ;
          v_time_grow_interval = clock_timestamp() + INTERVAL '20 minutes' ;
          end if ;
       if (v_period_mode = 'gap_2_days') then
          v_time_reduce_interval = clock_timestamp() - INTERVAL '50 hours' ;
          v_time_grow_interval = clock_timestamp() + INTERVAL '3 hours' ;
          end if ;
       if (v_period_mode = 'gap_2_months') then
          v_time_reduce_interval = clock_timestamp() - INTERVAL '62 days' ;
          v_time_grow_interval = clock_timestamp() + INTERVAL '2 days' ;
          end if ;
-- обрабатываем записи
       for v_time_frame IN 1..17 LOOP
           IF (sz_time_frame_list[v_time_frame] = '4W')  THEN sz_request_table_name := 'rtrsp_ohlc_4w_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '1W')  THEN sz_request_table_name := 'rtrsp_ohlc_1w_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '4D')  THEN sz_request_table_name := 'rtrsp_ohlc_4d_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '2D')  THEN sz_request_table_name := 'rtrsp_ohlc_2d_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '1D')  THEN sz_request_table_name := 'rtrsp_ohlc_1d_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '12H') THEN sz_request_table_name := 'rtrsp_ohlc_12h_history' ; END IF ;
           IF (sz_time_frame_list[v_time_frame] = '8H')  THEN sz_request_table_name := 'rtrsp_ohlc_8h_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '4H')  THEN sz_request_table_name := 'rtrsp_ohlc_4h_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '3H')  THEN sz_request_table_name := 'rtrsp_ohlc_3h_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '2H')  THEN sz_request_table_name := 'rtrsp_ohlc_2h_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '1H')  THEN sz_request_table_name := 'rtrsp_ohlc_1h_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '30M') THEN sz_request_table_name := 'rtrsp_ohlc_30m_history' ; END IF ;
           IF (sz_time_frame_list[v_time_frame] = '15M') THEN sz_request_table_name := 'rtrsp_ohlc_15m_history' ; END IF ;
           IF (sz_time_frame_list[v_time_frame] = '10M') THEN sz_request_table_name := 'rtrsp_ohlc_10m_history' ; END IF ;
           IF (sz_time_frame_list[v_time_frame] = '5M')  THEN sz_request_table_name := 'rtrsp_ohlc_5m_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '3M')  THEN sz_request_table_name := 'rtrsp_ohlc_3m_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '1M')  THEN sz_request_table_name := 'rtrsp_ohlc_1m_history' ;  END IF ;
           
           if (v_period_mode = 'all' OR v_period_mode = 'operative' OR v_period_mode = 'gap_2_days' OR v_period_mode = 'gap_2_months') then
		      RAISE NOTICE '=== 1 Зашли в обработчик в режиме % для ТФ % ===', v_period_mode, sz_time_frame_list[v_time_frame] ;
              sz_currency_pairs_request = 'select currency, reference_currency from '||sz_request_table_name||' group by currency, reference_currency order by 1,2' ;
              FOR rec_currency_pairs_list IN EXECUTE sz_currency_pairs_request LOOP
                  sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||', dataset_class '||v_dataset_class||', старт заполнения ретро данных EMA от '||v_time_reduce_interval||' до '||v_time_grow_interval ;
--                  RAISE NOTICE '[start driver] %/% ТФ% старт заполнения ретроспективных данных EMA, от % до %', rec_currency_pairs_list.currency, rec_currency_pairs_list.reference_currency,sz_time_frame_list[v_time_frame],v_time_reduce_interval, v_time_grow_interval ;
--                  RAISE NOTICE '%', sz_msg ;
                  insert into cragran_logs values(clock_timestamp(),'rtsp_calc_indicator_EMA','fn_rtsp_driver_fill_ema_tables',sz_msg) ;
                  COMMIT ;
     		      RAISE NOTICE '--- 1 Зашли в обработчик монеты % / % ---', rec_currency_pairs_list.currency, rec_currency_pairs_list.reference_currency ;
                  BEGIN
                  MERGE INTO rtrsp_ema_history dst
                        USING (SELECT * FROM fn_rtrsp_calck_EMA_as_table(v_dataset_class, v_ema_01_periods, v_ema_02_periods, v_ema_03_periods, v_ema_04_periods, v_ema_05_periods, v_ema_06_periods, v_ema_07_periods, v_ema_08_periods, rec_currency_pairs_list.currency, rec_currency_pairs_list.reference_currency, sz_time_frame_list[v_time_frame], CAST(v_time_reduce_interval AS timestamp without time zone), CAST(v_time_grow_interval AS timestamp without time zone))) src
                        ON src.currency = dst.currency AND src.reference_currency = dst.reference_currency AND src.timestamp_point = dst.timestamp_point AND
                           src.time_frame = dst.time_frame AND src.dataset_class = dst.dataset_class
                        WHEN MATCHED AND NOT (src.price_close = dst.price_close AND 
											  src.ema_01_periods = dst.ema_01_periods AND src.ema_01 = dst.ema_01 AND src.ema_01_pre = dst.ema_01_pre AND
											  src.ema_02_periods = dst.ema_02_periods AND src.ema_02 = dst.ema_02 AND src.ema_02_pre = dst.ema_02_pre AND
											  src.ema_03_periods = dst.ema_03_periods AND src.ema_03 = dst.ema_03 AND src.ema_03_pre = dst.ema_03_pre AND
											  src.ema_04_periods = dst.ema_04_periods AND src.ema_04 = dst.ema_04 AND src.ema_04_pre = dst.ema_04_pre AND
											  src.ema_05_periods = dst.ema_05_periods AND src.ema_05 = dst.ema_05 AND src.ema_05_pre = dst.ema_05_pre AND
											  src.ema_06_periods = dst.ema_06_periods AND src.ema_06 = dst.ema_06 AND src.ema_06_pre = dst.ema_06_pre AND
											  src.ema_07_periods = dst.ema_07_periods AND src.ema_07 = dst.ema_07 AND src.ema_07_pre = dst.ema_07_pre AND
											  src.ema_08_periods = dst.ema_08_periods AND src.ema_08 = dst.ema_08 AND src.ema_08_pre = dst.ema_08_pre) THEN
                             UPDATE SET price_close = src.price_close, ema_01_periods = src.ema_01_periods, ema_01 = src.ema_01, ema_01_pre = src.ema_01_pre,
										ema_02_periods = src.ema_02_periods, ema_02 = src.ema_02, ema_02_pre = src.ema_02_pre,
										ema_03_periods = src.ema_03_periods, ema_03 = src.ema_03, ema_03_pre = src.ema_03_pre,
										ema_04_periods = src.ema_04_periods, ema_04 = src.ema_04, ema_04_pre = src.ema_04_pre,
										ema_05_periods = src.ema_05_periods, ema_05 = src.ema_05, ema_05_pre = src.ema_05_pre,
										ema_06_periods = src.ema_06_periods, ema_06 = src.ema_06, ema_06_pre = src.ema_06_pre,
										ema_07_periods = src.ema_07_periods, ema_07 = src.ema_07, ema_07_pre = src.ema_07_pre,
										ema_08_periods = src.ema_08_periods, ema_08 = src.ema_08, ema_08_pre = src.ema_08_pre, change_ts = src.change_ts
                        WHEN NOT MATCHED THEN
                             INSERT (currency, reference_currency, timestamp_point, time_frame, dataset_class, price_close, ema_01_periods, ema_01, ema_01_pre,
									 ema_02_periods, ema_02, ema_02_pre, ema_03_periods, ema_03, ema_03_pre, ema_04_periods, ema_04, ema_04_pre,
									 ema_05_periods, ema_05, ema_05_pre, ema_06_periods, ema_06, ema_06_pre, ema_07_periods, ema_07, ema_07_pre,
									 ema_08_periods, ema_08, ema_08_pre, change_ts)
                                    VALUES (src.currency, src.reference_currency, src.timestamp_point, src.time_frame, src.dataset_class, src.price_close,
											src.ema_01_periods, src.ema_01, src.ema_01_pre, src.ema_02_periods, src.ema_02, src.ema_02_pre,
										    src.ema_03_periods, src.ema_03, src.ema_03_pre, src.ema_04_periods, src.ema_04, src.ema_04_pre,
										    src.ema_05_periods, src.ema_05, src.ema_05_pre, src.ema_06_periods, src.ema_06, src.ema_06_pre,
										    src.ema_07_periods, src.ema_07, src.ema_07_pre, src.ema_08_periods, src.ema_08, src.ema_08_pre, src.change_ts) ;
                  sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||', dataset_class '||v_dataset_class||', старт заполнения ретро данных EMA от '||v_time_reduce_interval||' до '||v_time_grow_interval ;
                  insert into cragran_logs values(clock_timestamp(),'rtsp_calc_indicator_EMA','fn_rtsp_driver_fill_ema_tables',sz_msg) ;
--                  COMMIT ;
                  EXCEPTION WHEN OTHERS THEN
                            GET STACKED DIAGNOSTICS err_text_var1 = MESSAGE_TEXT, err_text_var2 = PG_EXCEPTION_DETAIL, err_text_var3 = PG_EXCEPTION_HINT ;
--                            sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||', dataset_class '||v_dataset_class||', старт заполнения ретро данных EMA' ;
                            sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||', dataset_class '||v_dataset_class||', старт заполнения ретро данных EMA'||err_text_var1||err_text_var2||err_text_var3 ;
                            insert into cragran_logs values(clock_timestamp(),'rtsp_calc_indicator_EMA','fn_fill_ema_history','Error INSERT '||sz_msg) ;
                  END ;
                  COMMIT ; -- для каждой монеты зафиксировать результат обработки
                  END LOOP ; -- конец помонетного цикла
              END IF ; -- конец обработчика v_period_mode != 'all_per_month'

           IF (v_period_mode = 'all_per_month') THEN
		   	  RAISE NOTICE '=== 2 Зашли в обработчик в режиме % для ТФ % ===', v_period_mode, sz_time_frame_list[v_time_frame] ;
              sz_months_list_request = 'select src.tsp from (select date_trunc(''month'',timestamp_point) tsp from '||sz_request_table_name||') src group by src.tsp order by 1 asc' ;
              FOR ds_months_list IN EXECUTE sz_months_list_request LOOP
                              sz_currency_pairs_request = 'select currency, reference_currency from '||sz_request_table_name||' group by currency, reference_currency order by 1,2' ;
                  FOR rec_currency_pairs_list IN EXECUTE sz_currency_pairs_request LOOP
                      sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||', dataset_class '||v_dataset_class||', старт заполнения ретро данных EMA' ;
--                                  RAISE NOTICE '[start driver] %/% ТФ% старт заполнения ретроспективных данных RSI, от % до %', rec_currency_pairs_list.currency, rec_currency_pairs_list.reference_currency,sz_time_frame_list[v_time_frame],v_time_reduce_interval, v_time_grow_interval ;
--                  RAISE NOTICE '%', sz_msg ;
                      insert into cragran_logs values(clock_timestamp(),'rtsp_calc_indicator_EMA','fn_rtsp_driver_fill_ema_tables',sz_msg) ;
                      COMMIT ;
                      BEGIN
                      MERGE INTO rtrsp_ema_history dst
                            USING (SELECT * FROM fn_rtrsp_calck_EMA_as_table(v_dataset_class, v_ema_01_periods, v_ema_02_periods, v_ema_03_periods, v_ema_04_periods, v_ema_05_periods, v_ema_06_periods, v_ema_07_periods, v_ema_08_periods, rec_currency_pairs_list.currency, rec_currency_pairs_list.reference_currency, sz_time_frame_list[v_time_frame], CAST(v_time_reduce_interval AS timestamp without time zone), CAST(v_time_grow_interval AS timestamp without time zone))) src
                            ON src.currency = dst.currency AND src.reference_currency = dst.reference_currency AND src.timestamp_point = dst.timestamp_point AND
                               src.time_frame = dst.time_frame AND src.dataset_class = dst.dataset_class
                            WHEN MATCHED AND NOT (src.price_close = dst.price_close AND 
							    				  src.ema_01_periods = dst.ema_01_periods AND src.ema_01 = dst.ema_01 AND src.ema_01_pre = dst.ema_01_pre AND
								    			  src.ema_02_periods = dst.ema_02_periods AND src.ema_02 = dst.ema_02 AND src.ema_02_pre = dst.ema_02_pre AND
									    		  src.ema_03_periods = dst.ema_03_periods AND src.ema_03 = dst.ema_03 AND src.ema_03_pre = dst.ema_03_pre AND
										    	  src.ema_04_periods = dst.ema_04_periods AND src.ema_04 = dst.ema_04 AND src.ema_04_pre = dst.ema_04_pre AND
											      src.ema_05_periods = dst.ema_05_periods AND src.ema_05 = dst.ema_05 AND src.ema_05_pre = dst.ema_05_pre AND
											      src.ema_06_periods = dst.ema_06_periods AND src.ema_06 = dst.ema_06 AND src.ema_06_pre = dst.ema_06_pre AND
											      src.ema_07_periods = dst.ema_07_periods AND src.ema_07 = dst.ema_07 AND src.ema_07_pre = dst.ema_07_pre AND
											      src.ema_08_periods = dst.ema_08_periods AND src.ema_08 = dst.ema_08 AND src.ema_08_pre = dst.ema_08_pre) THEN
                                 UPDATE SET price_close = src.price_close, ema_01_periods = src.ema_01_periods, ema_01 = src.ema_01, ema_01_pre = src.ema_01_pre,
								    		ema_02_periods = src.ema_02_periods, ema_02 = src.ema_02, ema_02_pre = src.ema_02_pre,
									    	ema_03_periods = src.ema_03_periods, ema_03 = src.ema_03, ema_03_pre = src.ema_03_pre,
										    ema_04_periods = src.ema_04_periods, ema_04 = src.ema_04, ema_04_pre = src.ema_04_pre,
										    ema_05_periods = src.ema_05_periods, ema_05 = src.ema_05, ema_05_pre = src.ema_05_pre,
										    ema_06_periods = src.ema_06_periods, ema_06 = src.ema_06, ema_06_pre = src.ema_06_pre,
										    ema_07_periods = src.ema_07_periods, ema_07 = src.ema_07, ema_07_pre = src.ema_07_pre,
										    ema_08_periods = src.ema_08_periods, ema_08 = src.ema_08, ema_08_pre = src.ema_08_pre, change_ts = src.change_ts
                            WHEN NOT MATCHED THEN
--         long_ema_periods, short_ema_periods, sma_periods, long_ema, short_ema, diff_ema, sma_diff_ema, gist_value, gist_positive_rise, gist_positive_fall, gist_negative_rise, gist_negative_fall, change_ts
                                 INSERT (currency, reference_currency, timestamp_point, time_frame, dataset_class, price_close, ema_01_periods, ema_01, ema_01_pre,
								    	 ema_02_periods, ema_02, ema_02_pre, ema_03_periods, ema_03, ema_03_pre, ema_04_periods, ema_04, ema_04_pre,
									     ema_05_periods, ema_05, ema_05_pre, ema_06_periods, ema_06, ema_06_pre, ema_07_periods, ema_07, ema_07_pre,
									     ema_08_periods, ema_08, ema_08_pre, change_ts)
                                        VALUES (src.currency, src.reference_currency, src.timestamp_point, src.time_frame, src.dataset_class, src.price_close,
										    	src.ema_01_periods, src.ema_01, src.ema_01_pre, src.ema_02_periods, src.ema_02, src.ema_02_pre,
    										    src.ema_03_periods, src.ema_03, src.ema_03_pre, src.ema_04_periods, src.ema_04, src.ema_04_pre,
	    									    src.ema_05_periods, src.ema_05, src.ema_05_pre, src.ema_06_periods, src.ema_06, src.ema_06_pre,
		    								    src.ema_07_periods, src.ema_07, src.ema_07_pre, src.ema_08_periods, src.ema_08, src.ema_08_pre, src.change_ts) ;
                      sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||', dataset_class '||v_dataset_class||', старт заполнения ретро данных EMA' ;
                      insert into cragran_logs values(clock_timestamp(),'rtsp_calc_indicator_EMA','fn_rtsp_driver_fill_ema_tables',sz_msg) ;
--                  COMMIT ;
                      EXCEPTION WHEN OTHERS THEN
--GET STACKED DIAGNOSTICS text_var1 = MESSAGE_TEXT,
--                          text_var2 = PG_EXCEPTION_DETAIL,
--                          text_var3 = PG_EXCEPTION_HINT;
                                sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||', dataset_class '||v_dataset_class||', старт заполнения ретро данных EMA' ;
                                insert into cragran_logs values(clock_timestamp(),'rtsp_calc_indicator_EMA','fn_fill_ema_history','Error INSERT '||sz_msg) ;
                      END ;
                      COMMIT ;  -- для каждой монеты зафиксировать результат обработки
                      END LOOP ; -- конец помонетного цикла
                  END LOOP ; -- конец помесячного цикла
              END IF ; -- конец обработчика v_period_mode = 'all_per_month'
       END LOOP ; -- конец перебора таймфрэймов
END ;
$BODY$;

-- статистика -- ТФ1М EMA обсчитан за 1 час 3 минуты 10 секунд ---

--CALL fn_rtsp_driver_fill_macd_tables(26,12,9,'all_per_month') ;
--
CALL fn_rtsp_driver_fill_ema_tables('typical0',20,10,240,120,1537,770,0,0,'all') ;

--delete from cragran_logs where module = 'fn_rtsp_driver_fill_EMA_tables' OR module = 'fn_fill_ema_history' ;
--delete from cragran_logs where tpk_part = 'rtsp_calc_indicator_EMA' ;
--delete from rtrsp_ema_history ;
           
select * from cragran_logs order by 1 desc limit 1000 ;
select count(*) from rtrsp_ema_history ;
select * from pg_class where relname = 'rtrsp_ema_history' ;

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.16 конец -- таблицы и функции заполнения ретроспективного EMA
-- ---------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.17 начало -- таблицы и функции заполнения ретроспективных событий
-- ---------------------------------------------------------------------------------------------------------------------------

--DROP TABLE rtrsp_events_of_indicators CASCADE ;
CREATE TABLE rtrsp_events_of_indicators(
       currency            character varying(100),
       reference_currency  character varying(100),
       timestamp_point     timestamp without time zone,
       time_frame          character varying(10),
       RSI_state           character varying(100) DEFAULT NULL,
       RSI_event_id        bigint DEFAULT NULL,
       RSI_event_rand_id   character varying(100) DEFAULT NULL,
       RSI_event_name      character varying(100) DEFAULT NULL,
       RSI_event_vector    character varying(30) DEFAULT NULL,
       MACD_modifier       character varying(100) DEFAULT NULL,
       MACDL_state         character varying(100) DEFAULT NULL,
       MACDL_event_id      bigint DEFAULT NULL,
       MACDL_event_rand_id character varying(100) DEFAULT NULL,
       MACDL_event_name    character varying(100) DEFAULT NULL,
       MACDL_event_vector  character varying(30) DEFAULT NULL,
       MACDG_state         character varying(100) DEFAULT NULL,
       MACDG_event_id      bigint DEFAULT NULL,
       MACDG_event_rand_id character varying(100) DEFAULT NULL,
       MACDG_event_name    character varying(100) DEFAULT NULL,
       MACDG_event_vector  character varying(30) DEFAULT NULL,
       EMA_dataset_class   character varying(100) DEFAULT NULL,
       EMA01_state         character varying(100) DEFAULT NULL,
       EMA01_event_id      bigint DEFAULT NULL,
       EMA01_event_rand_id character varying(100) DEFAULT NULL,
       EMA01_event_name    character varying(100) DEFAULT NULL,
       EMA01_event_vector  character varying(30) DEFAULT NULL,
       EMA02_state         character varying(100) DEFAULT NULL,
       EMA02_event_id      bigint DEFAULT NULL,
       EMA02_event_rand_id character varying(100) DEFAULT NULL,
       EMA02_event_name    character varying(100) DEFAULT NULL,
       EMA02_event_vector  character varying(30) DEFAULT NULL,
       EMA03_state         character varying(100) DEFAULT NULL,
       EMA03_event_id      bigint DEFAULT NULL,
       EMA03_event_rand_id character varying(100) DEFAULT NULL,
       EMA03_event_name    character varying(100) DEFAULT NULL,
       EMA03_event_vector  character varying(30) DEFAULT NULL,
       EMA04_state         character varying(100) DEFAULT NULL,
       EMA04_event_id      bigint DEFAULT NULL,
       EMA04_event_rand_id character varying(100) DEFAULT NULL,
       EMA04_event_name    character varying(100) DEFAULT NULL,
       EMA04_event_vector  character varying(30) DEFAULT NULL,
       EMA05_state         character varying(100) DEFAULT NULL,
       EMA05_event_id      bigint DEFAULT NULL,
       EMA05_event_rand_id character varying(100) DEFAULT NULL,
       EMA05_event_name    character varying(100) DEFAULT NULL,
       EMA05_event_vector  character varying(30) DEFAULT NULL,
       EMA06_state         character varying(100) DEFAULT NULL,
       EMA06_event_id      bigint DEFAULT NULL,
       EMA06_event_rand_id character varying(100) DEFAULT NULL,
       EMA06_event_name    character varying(100) DEFAULT NULL,
       EMA06_event_vector  character varying(30) DEFAULT NULL,
       EMA07_state         character varying(100) DEFAULT NULL,
       EMA07_event_id      bigint DEFAULT NULL,
       EMA07_event_rand_id character varying(100) DEFAULT NULL,
       EMA07_event_name    character varying(100) DEFAULT NULL,
       EMA07_event_vector  character varying(30) DEFAULT NULL,
       EMA08_state         character varying(100) DEFAULT NULL,
       EMA08_event_id      bigint DEFAULT NULL,
       EMA08_event_rand_id character varying(100) DEFAULT NULL,
       EMA08_event_name    character varying(100) DEFAULT NULL,
       EMA08_event_vector  character varying(30) DEFAULT NULL,
       change_ts           timestamp without time zone,
       CONSTRAINT rtrsp_ind_events_pkey
                  PRIMARY KEY (currency, reference_currency, timestamp_point, time_frame)
       ) ;


-- запросы к таблицам отдельных индикаторов
select macd.currency, macd.reference_currency, macd.timestamp_point, macd.diff_ema, macd.sma_diff_ema, macd.gist_value
       from rtrsp_macd_history macd
       where currency = 'BTC' AND reference_currency = 'USDT' and time_frame = '1M' AND
             timestamp_point >= (now() - INTERVAL '100 days') AND timestamp_point <= now()
       ORDER BY currency, reference_currency, timestamp_point asc

select currency, reference_currency, timestamp_point, time_frame, dataset_class, ema_01, ema_02, ema_03, ema_04, ema_05, ema_06, ema_07, ema_08
       from rtrsp_ema_history
       where currency = 'BTC' AND reference_currency = 'USDT' and time_frame = '1M' AND
             timestamp_point >= (now() - INTERVAL '100 days') AND timestamp_point <= now()
       ORDER BY currency, reference_currency, timestamp_point asc

select currency, reference_currency, timestamp_point, time_frame, rsi
       from rtrsp_rsi_history
       where currency = 'BTC' AND reference_currency = 'USDT' and time_frame = '1M' AND
             timestamp_point >= (now() - INTERVAL '100 days') AND timestamp_point <= now()
       ORDER BY currency, reference_currency, timestamp_point asc

--LAG(ds_macd.diff_ema,1) OVER (PARTITION BY currency, reference_currency ORDER BY timestamp_point ASC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as PRICE_OPEN

-- общий запрос к таблицам отдельных индикаторов
select ds_macd.currency, ds_macd.reference_currency, ds_macd.timestamp_point,
       ds_macd.diff_ema,
       LAG(ds_macd.diff_ema, 1) OVER (PARTITION BY ds_macd.currency, ds_macd.reference_currency ORDER BY ds_macd.timestamp_point ASC) as diff_ema_pre_01,
       LAG(ds_macd.diff_ema, 2) OVER (PARTITION BY ds_macd.currency, ds_macd.reference_currency ORDER BY ds_macd.timestamp_point ASC) as diff_ema_pre_02,
       ds_macd.sma_diff_ema,
       LAG(ds_macd.sma_diff_ema, 1) OVER (PARTITION BY ds_macd.currency, ds_macd.reference_currency ORDER BY ds_macd.timestamp_point ASC) as sma_diff_ema_pre_01,
       LAG(ds_macd.sma_diff_ema, 2) OVER (PARTITION BY ds_macd.currency, ds_macd.reference_currency ORDER BY ds_macd.timestamp_point ASC) as sma_diff_ema_pre_02,
       ds_macd.gist_value,
       LAG(ds_macd.gist_value, 1) OVER (PARTITION BY ds_macd.currency, ds_macd.reference_currency ORDER BY ds_macd.timestamp_point ASC) as diff_ema_pre_01,
       LAG(ds_macd.gist_value, 2) OVER (PARTITION BY ds_macd.currency, ds_macd.reference_currency ORDER BY ds_macd.timestamp_point ASC) as diff_ema_pre_02,
       ds_ema.ema_01,
       LAG(ds_ema.ema_01, 1) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_01_pre_01,
       LAG(ds_ema.ema_01, 2) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_01_pre_02,
       ds_ema.ema_02,
       LAG(ds_ema.ema_02, 1) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_02_pre_01,
       LAG(ds_ema.ema_02, 2) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_02_pre_02,
       ds_ema.ema_03,
       LAG(ds_ema.ema_03, 1) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_03_pre_01,
       LAG(ds_ema.ema_03, 2) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_03_pre_02,
       ds_ema.ema_04,
       LAG(ds_ema.ema_04, 1) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_04_pre_01,
       LAG(ds_ema.ema_04, 2) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_04_pre_02,
       ds_ema.ema_05,
       LAG(ds_ema.ema_05, 1) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_05_pre_01,
       LAG(ds_ema.ema_05, 2) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_05_pre_02,
       ds_ema.ema_06,
       LAG(ds_ema.ema_06, 1) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_06_pre_01,
       LAG(ds_ema.ema_06, 2) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_06_pre_02,
       ds_ema.ema_07,
       LAG(ds_ema.ema_07, 1) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_07_pre_01,
       LAG(ds_ema.ema_07, 2) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_07_pre_02,
       ds_ema.ema_08,
       LAG(ds_ema.ema_08, 1) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_08_pre_01,
       LAG(ds_ema.ema_08, 2) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_08_pre_02,
       ds_rsi.rsi,
       LAG(ds_rsi.rsi, 1) OVER (PARTITION BY ds_rsi.currency, ds_rsi.reference_currency ORDER BY ds_rsi.timestamp_point ASC) as rsi_pre_01,
       LAG(ds_rsi.rsi, 2) OVER (PARTITION BY ds_rsi.currency, ds_rsi.reference_currency ORDER BY ds_rsi.timestamp_point ASC) as rsi_pre_02
       from rtrsp_macd_history ds_macd
            join rtrsp_ema_history ds_ema
                 on ds_macd.currency = ds_ema.currency and ds_macd.reference_currency = ds_ema.reference_currency and 
                    ds_macd.timestamp_point = ds_ema.timestamp_point and ds_macd.time_frame = ds_ema.time_frame
                join rtrsp_rsi_history ds_rsi
                     on ds_macd.currency = ds_rsi.currency and ds_macd.reference_currency = ds_rsi.reference_currency and 
                        ds_macd.timestamp_point = ds_rsi.timestamp_point and ds_macd.time_frame = ds_rsi.time_frame
       where ds_macd.currency = 'BTC' AND ds_macd.reference_currency = 'USDT' and ds_macd.time_frame = '1M' AND
             ds_macd.timestamp_point >= (now() - INTERVAL '100 years') AND ds_macd.timestamp_point <= now()
       ORDER BY ds_macd.currency, ds_macd.reference_currency, ds_macd.timestamp_point asc

--ds_macd.currency, ds_macd.reference_currency, 

-- функция выявления и заполнения событий по заданной монете и ТФ
-- DROP FUNCTION IF EXISTS public.fn_rtrsp_calck_events_as_table ;
CREATE OR REPLACE FUNCTION public.fn_rtrsp_calck_events_as_table(
           v_currency character varying,
           v_reference_currency character varying,
           v_time_frame character varying,
           v_time_start timestamp without time zone,
           v_time_stop timestamp without time zone)
       RETURNS SETOF rtrsp_events_of_indicators
       LANGUAGE 'plpgsql'
       AS $BODY$
       DECLARE
       result_record              rtrsp_events_of_indicators%ROWTYPE ;
       sz_indicators_request      VARCHAR ;
       ds_indicators_result       RECORD ;
       cnt_ds_result              BIGINT ;
-- создаём переменные флаги, что событие уже выявлено или нет
       v_is_RSI_CROSS_UP          INT ;
       v_is_RSI_CLEAR_CROSS_UP    INT ;
       v_is_RSI_CROSS_DOWN        INT ;
       v_is_RSI_CLEAR_CROSS_DOWN  INT ;
       v_is_MACD_LINE_CROSS_UP    INT ;
       v_is_MACD_LINE_CROSS_DOWN  INT ;
       v_is_MACD_LINE_VECTOR_UP   INT ;
       v_is_MACD_LINE_VECTOR_DOWN INT ;
       v_is_MACD_GIST_VECTOR_UP   INT ;
       v_is_MACD_GIST_VECTOR_DOWN INT ;
       v_is_EMA_01_VECTOR_UP      INT ;
       v_is_EMA_01_VECTOR_DOWN    INT ;
       v_is_EMA_02_VECTOR_UP      INT ;
       v_is_EMA_02_VECTOR_DOWN    INT ;
       v_is_EMA_03_VECTOR_UP      INT ;
       v_is_EMA_03_VECTOR_DOWN    INT ;
       v_is_EMA_04_VECTOR_UP      INT ;
       v_is_EMA_04_VECTOR_DOWN    INT ;
       v_is_EMA_05_VECTOR_UP      INT ;
       v_is_EMA_05_VECTOR_DOWN    INT ;
       v_is_EMA_06_VECTOR_UP      INT ;
       v_is_EMA_06_VECTOR_DOWN    INT ;
       v_is_EMA_07_VECTOR_UP      INT ;
       v_is_EMA_07_VECTOR_DOWN    INT ;
       v_is_EMA_08_VECTOR_UP      INT ;
       v_is_EMA_08_VECTOR_DOWN    INT ;
       BEGIN
       v_is_RSI_CROSS_UP = 0 ; v_is_RSI_CROSS_DOWN = 0 ; v_is_MACD_LINE_CROSS_UP = 0 ; v_is_MACD_LINE_CROSS_DOWN = 0 ;
       v_is_MACD_LINE_VECTOR_UP = 0 ; v_is_MACD_LINE_VECTOR_DOWN = 0 ; v_is_MACD_GIST_VECTOR_UP = 0 ; v_is_MACD_GIST_VECTOR_DOWN = 0 ;
       v_is_EMA_01_VECTOR_UP = 0 ; v_is_EMA_01_VECTOR_DOWN = 0 ; v_is_EMA_02_VECTOR_UP = 0 ; v_is_EMA_02_VECTOR_DOWN = 0 ;
       v_is_EMA_03_VECTOR_UP = 0 ; v_is_EMA_03_VECTOR_DOWN = 0 ; v_is_EMA_04_VECTOR_UP = 0 ; v_is_EMA_04_VECTOR_DOWN = 0 ;
       v_is_EMA_05_VECTOR_UP = 0 ; v_is_EMA_05_VECTOR_DOWN = 0 ; v_is_EMA_06_VECTOR_UP = 0 ; v_is_EMA_06_VECTOR_DOWN = 0 ;
       v_is_EMA_07_VECTOR_UP = 0 ; v_is_EMA_07_VECTOR_DOWN = 0 ; v_is_EMA_08_VECTOR_UP = 0 ; v_is_EMA_08_VECTOR_DOWN = 0 ;
       sz_indicators_request := 'select ds_macd.currency, ds_macd.reference_currency, ds_macd.timestamp_point, 
       ds_macd.diff_ema,
       LAG(ds_macd.diff_ema, 1) OVER (PARTITION BY ds_macd.currency, ds_macd.reference_currency ORDER BY ds_macd.timestamp_point ASC) as diff_ema_pre_01,
       LAG(ds_macd.diff_ema, 2) OVER (PARTITION BY ds_macd.currency, ds_macd.reference_currency ORDER BY ds_macd.timestamp_point ASC) as diff_ema_pre_02,
       ds_macd.sma_diff_ema,
       LAG(ds_macd.sma_diff_ema, 1) OVER (PARTITION BY ds_macd.currency, ds_macd.reference_currency ORDER BY ds_macd.timestamp_point ASC) as sma_diff_ema_pre_01,
       LAG(ds_macd.sma_diff_ema, 2) OVER (PARTITION BY ds_macd.currency, ds_macd.reference_currency ORDER BY ds_macd.timestamp_point ASC) as sma_diff_ema_pre_02,
       ds_macd.gist_value,
       LAG(ds_macd.gist_value, 1) OVER (PARTITION BY ds_macd.currency, ds_macd.reference_currency ORDER BY ds_macd.timestamp_point ASC) as gist_value_pre_01,
       LAG(ds_macd.gist_value, 2) OVER (PARTITION BY ds_macd.currency, ds_macd.reference_currency ORDER BY ds_macd.timestamp_point ASC) as gist_value_pre_02,
       ds_ema.ema_01,
       ds_ema.dataset_class,
       LAG(ds_ema.ema_01, 1) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_01_pre_01,
       LAG(ds_ema.ema_01, 2) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_01_pre_02,
       ds_ema.ema_02,
       LAG(ds_ema.ema_02, 1) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_02_pre_01,
       LAG(ds_ema.ema_02, 2) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_02_pre_02,
       ds_ema.ema_03,
       LAG(ds_ema.ema_03, 1) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_03_pre_01,
       LAG(ds_ema.ema_03, 2) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_03_pre_02,
       ds_ema.ema_04,
       LAG(ds_ema.ema_04, 1) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_04_pre_01,
       LAG(ds_ema.ema_04, 2) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_04_pre_02,
       ds_ema.ema_05,
       LAG(ds_ema.ema_05, 1) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_05_pre_01,
       LAG(ds_ema.ema_05, 2) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_05_pre_02,
       ds_ema.ema_06,
       LAG(ds_ema.ema_06, 1) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_06_pre_01,
       LAG(ds_ema.ema_06, 2) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_06_pre_02,
       ds_ema.ema_07,
       LAG(ds_ema.ema_07, 1) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_07_pre_01,
       LAG(ds_ema.ema_07, 2) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_07_pre_02,
       ds_ema.ema_08,
       LAG(ds_ema.ema_08, 1) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_08_pre_01,
       LAG(ds_ema.ema_08, 2) OVER (PARTITION BY ds_ema.currency, ds_ema.reference_currency ORDER BY ds_ema.timestamp_point ASC) as ema_08_pre_02,
       ds_rsi.rsi,
       LAG(ds_rsi.rsi, 1) OVER (PARTITION BY ds_rsi.currency, ds_rsi.reference_currency ORDER BY ds_rsi.timestamp_point ASC) as rsi_pre_01,
       LAG(ds_rsi.rsi, 2) OVER (PARTITION BY ds_rsi.currency, ds_rsi.reference_currency ORDER BY ds_rsi.timestamp_point ASC) as rsi_pre_02
       from rtrsp_macd_history ds_macd
            join rtrsp_ema_history ds_ema
                 on ds_macd.currency = ds_ema.currency and ds_macd.reference_currency = ds_ema.reference_currency and 
                    ds_macd.timestamp_point = ds_ema.timestamp_point and ds_macd.time_frame = ds_ema.time_frame
                 join rtrsp_rsi_history ds_rsi
                      on ds_macd.currency = ds_rsi.currency and ds_macd.reference_currency = ds_rsi.reference_currency and 
                         ds_macd.timestamp_point = ds_rsi.timestamp_point and ds_macd.time_frame = ds_rsi.time_frame
       where ds_macd.currency = $1 AND ds_macd.reference_currency = $2 and ds_macd.time_frame = $3 AND
             ds_macd.timestamp_point >= $4 AND ds_macd.timestamp_point <= $5
       ORDER BY ds_macd.currency, ds_macd.reference_currency, ds_macd.timestamp_point asc' ;
       FOR ds_indicators_result IN EXECUTE sz_indicators_request USING v_currency, v_reference_currency, v_time_frame, v_time_start, v_time_stop LOOP
-- расчёт по строкам dataset
           result_record.currency           := ds_indicators_result.currency ;
           result_record.reference_currency := ds_indicators_result.reference_currency ;
           result_record.timestamp_point    := ds_indicators_result.timestamp_point ;
           result_record.time_frame         := v_time_frame ;
-- --------------------------------------------
-- расчитываем события и состояния RSI		   
-- --------------------------------------------
		   result_record.RSI_state := NULL ; result_record.RSI_event_name := NULL ; result_record.RSI_event_vector := NULL ;
		   if (ds_indicators_result.rsi > ds_indicators_result.rsi_pre_01) then result_record.RSI_state := 'UP' ; end if ;
		   if (ds_indicators_result.rsi < ds_indicators_result.rsi_pre_01) then result_record.RSI_state := 'DOWN' ; end if ;
		   if (ds_indicators_result.rsi = ds_indicators_result.rsi_pre_01) then result_record.RSI_state := 'FLAT' ; end if ;
-- debug		   result_record.rsi_event_rand_id := ds_indicators_result.rsi||', '||ds_indicators_result.rsi_pre_01 ;
-- если текущее значение больше верхней границы, а предыдущее - меньше или равно, и флаг не взведён
-- то идентифицировать событие и взвести флаг
		   if (ds_indicators_result.rsi > 70 and ds_indicators_result.rsi_pre_01 <= 70 AND v_is_RSI_CROSS_UP != 1) then
		      v_is_RSI_CROSS_UP                := 1 ;
	          result_record.RSI_event_name     := 'RSI_'||v_time_frame||'_UP_CROSS_70' ;
		      result_record.RSI_event_vector   := 'UP' ;
			  end if ;
-- если текущее значение меньше верхней границы, а предыдущее больше
-- идентифицировать событие сброса пересечения верхней границы
		   if (ds_indicators_result.rsi <= 70 and ds_indicators_result.rsi_pre_01 > 70) then
	          result_record.RSI_event_name     := 'RSI_'||v_time_frame||'_CLEAR_UP_CROSS_70' ;
		      result_record.RSI_event_vector   := 'UP' ;
			  end if ;
-- если текущее значение меньше верхней границы - сбросить флаг
           if (ds_indicators_result.rsi <= 70 AND v_is_RSI_CROSS_UP = 1 ) then v_is_RSI_CROSS_UP := 0 ; end if ;

-- если текущее значение меньше нижней границы, а предыдущее больше и флаг не взведён
-- идентифицировать событие пересечения нижней границы и взвести флаг
           if (ds_indicators_result.rsi < 30 and ds_indicators_result.rsi_pre_01 >= 30 AND v_is_RSI_CROSS_DOWN != 1) then
		      v_is_RSI_CROSS_DOWN              := 1 ;
	          result_record.RSI_event_name     := 'RSI_'||v_time_frame||'_DOWN_CROSS_30' ;
		      result_record.RSI_event_vector   := 'DOWN' ;
			  end if ;
-- если текущее значение больше нижней границы, а предыдущее меньше
-- идентифицировать событие сброса пересечения нижней границы
           if (ds_indicators_result.rsi >= 30 and ds_indicators_result.rsi_pre_01 < 30) then
	          result_record.RSI_event_name     := 'RSI_'||v_time_frame||'_CLEAR_DOWN_CROSS_30' ;
		      result_record.RSI_event_vector   := 'DOWN' ;
			  end if ;
-- если текущее значение больше верхней границы и флаг взведён - сбросить флаг			  
           if (ds_indicators_result.rsi > 30 AND v_is_RSI_CROSS_DOWN = 1) then v_is_RSI_CROSS_DOWN := 0 ; end if ;
		   
-- --------------------------------------------
-- расчитываем события и состояния MACD (ухватываем и случаи равенства до пересечения)
-- --------------------------------------------
           result_record.MACDL_state := NULL ;
		   result_record.MACDL_event_name := NULL ; result_record.MACDL_event_vector := NULL ;
		   result_record.MACDG_event_name := NULL ; result_record.MACDG_event_vector := NULL ;
--           result_record.MACD_modifier         := ds_indicators_result.MACD_modifier ;
		   if (ds_indicators_result.diff_ema > ds_indicators_result.diff_ema_pre_01) then result_record.MACDL_state := 'UP' ; end if ;
		   if (ds_indicators_result.diff_ema < ds_indicators_result.diff_ema_pre_01) then result_record.MACDL_state := 'DOWN' ; end if ;
		   if (ds_indicators_result.diff_ema = ds_indicators_result.diff_ema_pre_01) then result_record.MACDL_state := 'FLAT' ; end if ;
-- распознаём события пересечения MACD line
		   if ((ds_indicators_result.diff_ema < ds_indicators_result.sma_diff_ema) and (ds_indicators_result.diff_ema_pre_01 >= ds_indicators_result.sma_diff_ema_pre_01)) then
              result_record.MACDL_event_name   := 'MACD_'||v_time_frame||'_LINE_CROSS'  ;
              result_record.MACDL_event_vector := 'UP' ;
			  end if ;
		   if ((ds_indicators_result.diff_ema > ds_indicators_result.sma_diff_ema) and (ds_indicators_result.diff_ema_pre_01 <= ds_indicators_result.sma_diff_ema_pre_01)) then
              result_record.MACDL_event_name   := 'MACD_'||v_time_frame||'_LINE_CROSS'  ;
              result_record.MACDL_event_vector := 'DOWN' ;
			  end if ;
-- распознаём события разворота MACD line
           if ((ds_indicators_result.diff_ema < ds_indicators_result.diff_ema_pre_01) and (ds_indicators_result.diff_ema_pre_01 >= ds_indicators_result.diff_ema_pre_02)) then
              result_record.MACDL_event_name   := 'MACD_'||v_time_frame||'_LINE_VECTOR'  ;
              result_record.MACDL_event_vector := 'DOWN' ;
			  end if ;
           if ((ds_indicators_result.diff_ema > ds_indicators_result.diff_ema_pre_01) and (ds_indicators_result.diff_ema_pre_01 <= ds_indicators_result.diff_ema_pre_02)) then
              result_record.MACDL_event_name   := 'MACD_'||v_time_frame||'_LINE_VECTOR'  ;
              result_record.MACDL_event_vector := 'UP' ;
			  end if ;
-- распознаём состояния MACD gist
		   if (ds_indicators_result.gist_value > ds_indicators_result.gist_value_pre_01) then result_record.MACDG_state := 'UP' ; end if ;
		   if (ds_indicators_result.gist_value < ds_indicators_result.gist_value_pre_01) then result_record.MACDG_state := 'DOWN' ; end if ;
		   if (ds_indicators_result.gist_value = ds_indicators_result.gist_value_pre_01) then result_record.MACDG_state := 'FLAT' ; end if ;
-- распознаём события разворота MACD gist
           if ((ds_indicators_result.gist_value < ds_indicators_result.gist_value_pre_01) and (ds_indicators_result.gist_value_pre_01 >= ds_indicators_result.gist_value_pre_02)) then
              result_record.MACDG_event_name   := 'MACD_'||v_time_frame||'_GIST_VECTOR'  ;
              result_record.MACDG_event_vector := 'DOWN' ;
			  end if ;
           if ((ds_indicators_result.gist_value > ds_indicators_result.gist_value_pre_01) and (ds_indicators_result.gist_value_pre_01 <= ds_indicators_result.gist_value_pre_02)) then
              result_record.MACDG_event_name   := 'MACD_'||v_time_frame||'_GIST_VECTOR'  ;
              result_record.MACDG_event_vector := 'UP' ;
			  end if ;
-- --------------------------------------------
-- расчитываем события и состояния EMA
-- --------------------------------------------
           result_record.EMA_dataset_class     := ds_indicators_result.dataset_class ;
-- расчитываем события и состояния EMA01
           result_record.EMA01_state := NULL ; result_record.EMA01_event_name := NULL ; result_record.EMA01_event_vector := NULL ;
		   if (ds_indicators_result.ema_01 > ds_indicators_result.ema_01_pre_01) then result_record.EMA01_state := 'UP' ; end if ;
		   if (ds_indicators_result.ema_01 < ds_indicators_result.ema_01_pre_01) then result_record.EMA01_state := 'DOWN' ; end if ;
		   if (ds_indicators_result.ema_01 = ds_indicators_result.ema_01_pre_01) then result_record.EMA01_state := 'FLAT' ; end if ;
           if ((ds_indicators_result.ema_01 < ds_indicators_result.ema_01_pre_01) and (ds_indicators_result.ema_01_pre_01 >= ds_indicators_result.ema_01_pre_02)) then
              result_record.EMA01_event_name   := 'EMA01_'||v_time_frame||'_LINE_VECTOR'  ;
              result_record.EMA01_event_vector := 'DOWN' ;
			  end if ;
           if ((ds_indicators_result.ema_01 > ds_indicators_result.ema_01_pre_01) and (ds_indicators_result.ema_01_pre_01 <= ds_indicators_result.ema_01_pre_02)) then
              result_record.EMA01_event_name   := 'EMA01_'||v_time_frame||'_LINE_VECTOR'  ;
              result_record.EMA01_event_vector := 'UP' ;
			  end if ;
-- расчитываем события и состояния EMA02
           result_record.EMA02_state := NULL ; result_record.EMA02_event_name := NULL ; result_record.EMA02_event_vector := NULL ;
		   if (ds_indicators_result.ema_02 > ds_indicators_result.ema_02_pre_01) then result_record.EMA02_state := 'UP' ; end if ;
		   if (ds_indicators_result.ema_02 < ds_indicators_result.ema_02_pre_01) then result_record.EMA02_state := 'DOWN' ; end if ;
		   if (ds_indicators_result.ema_02 = ds_indicators_result.ema_02_pre_01) then result_record.EMA02_state := 'FLAT' ; end if ;
           if ((ds_indicators_result.ema_02 < ds_indicators_result.ema_02_pre_01) and (ds_indicators_result.ema_02_pre_01 >= ds_indicators_result.ema_02_pre_02)) then
              result_record.EMA02_event_name   := 'EMA02_'||v_time_frame||'_LINE_VECTOR'  ;
              result_record.EMA02_event_vector := 'DOWN' ;
			  end if ;
           if ((ds_indicators_result.ema_02 > ds_indicators_result.ema_02_pre_01) and (ds_indicators_result.ema_02_pre_01 <= ds_indicators_result.ema_02_pre_02)) then
              result_record.EMA02_event_name   := 'EMA02_'||v_time_frame||'_LINE_VECTOR'  ;
              result_record.EMA02_event_vector := 'UP' ;
			  end if ;
-- расчитываем события и состояния EMA03
           result_record.EMA03_state := NULL ; result_record.EMA03_event_name := NULL ; result_record.EMA03_event_vector := NULL ;
		   if (ds_indicators_result.ema_03 > ds_indicators_result.ema_03_pre_01) then result_record.EMA03_state := 'UP' ; end if ;
		   if (ds_indicators_result.ema_03 < ds_indicators_result.ema_03_pre_01) then result_record.EMA03_state := 'DOWN' ; end if ;
		   if (ds_indicators_result.ema_03 = ds_indicators_result.ema_03_pre_01) then result_record.EMA03_state := 'FLAT' ; end if ;
           if ((ds_indicators_result.ema_03 < ds_indicators_result.ema_03_pre_01) and (ds_indicators_result.ema_03_pre_01 >= ds_indicators_result.ema_03_pre_02)) then
              result_record.EMA03_event_name   := 'EMA03_'||v_time_frame||'_LINE_VECTOR'  ;
              result_record.EMA03_event_vector := 'DOWN' ;
			  end if ;
           if ((ds_indicators_result.ema_03 > ds_indicators_result.ema_03_pre_01) and (ds_indicators_result.ema_03_pre_01 <= ds_indicators_result.ema_03_pre_02)) then
              result_record.EMA03_event_name   := 'EMA03_'||v_time_frame||'_LINE_VECTOR'  ;
              result_record.EMA03_event_vector := 'UP' ;
			  end if ;
-- расчитываем события и состояния EMA04
           result_record.EMA04_state := NULL ; result_record.EMA04_event_name := NULL ; result_record.EMA04_event_vector := NULL ;
		   if (ds_indicators_result.ema_04 > ds_indicators_result.ema_04_pre_01) then result_record.EMA04_state := 'UP' ; end if ;
		   if (ds_indicators_result.ema_04 < ds_indicators_result.ema_04_pre_01) then result_record.EMA04_state := 'DOWN' ; end if ;
		   if (ds_indicators_result.ema_04 = ds_indicators_result.ema_04_pre_01) then result_record.EMA04_state := 'FLAT' ; end if ;
           if ((ds_indicators_result.ema_04 < ds_indicators_result.ema_04_pre_01) and (ds_indicators_result.ema_04_pre_01 >= ds_indicators_result.ema_04_pre_02)) then
              result_record.EMA04_event_name   := 'EMA04_'||v_time_frame||'_LINE_VECTOR'  ;
              result_record.EMA04_event_vector := 'DOWN' ;
			  end if ;
           if ((ds_indicators_result.ema_04 > ds_indicators_result.ema_04_pre_01) and (ds_indicators_result.ema_04_pre_01 <= ds_indicators_result.ema_04_pre_02)) then
              result_record.EMA04_event_name   := 'EMA04_'||v_time_frame||'_LINE_VECTOR'  ;
              result_record.EMA04_event_vector := 'UP' ;
			  end if ;
-- расчитываем события и состояния EMA05
           result_record.EMA05_state := NULL ; result_record.EMA05_event_name := NULL ; result_record.EMA05_event_vector := NULL ;
		   if (ds_indicators_result.ema_05 > ds_indicators_result.ema_05_pre_01) then result_record.EMA05_state := 'UP' ; end if ;
		   if (ds_indicators_result.ema_05 < ds_indicators_result.ema_05_pre_01) then result_record.EMA05_state := 'DOWN' ; end if ;
		   if (ds_indicators_result.ema_05 = ds_indicators_result.ema_05_pre_01) then result_record.EMA05_state := 'FLAT' ; end if ;
           if ((ds_indicators_result.ema_05 < ds_indicators_result.ema_05_pre_01) and (ds_indicators_result.ema_05_pre_01 >= ds_indicators_result.ema_05_pre_02)) then
              result_record.EMA05_event_name   := 'EMA05_'||v_time_frame||'_LINE_VECTOR'  ;
              result_record.EMA05_event_vector := 'DOWN' ;
			  end if ;
           if ((ds_indicators_result.ema_05 > ds_indicators_result.ema_05_pre_01) and (ds_indicators_result.ema_05_pre_01 <= ds_indicators_result.ema_05_pre_02)) then
              result_record.EMA05_event_name   := 'EMA05_'||v_time_frame||'_LINE_VECTOR'  ;
              result_record.EMA05_event_vector := 'UP' ;
			  end if ;
-- расчитываем события и состояния EMA06
           result_record.EMA06_state := NULL ; result_record.EMA06_event_name := NULL ; result_record.EMA06_event_vector := NULL ;
		   if (ds_indicators_result.ema_06 > ds_indicators_result.ema_06_pre_01) then result_record.EMA06_state := 'UP' ; end if ;
		   if (ds_indicators_result.ema_06 < ds_indicators_result.ema_06_pre_01) then result_record.EMA06_state := 'DOWN' ; end if ;
		   if (ds_indicators_result.ema_06 = ds_indicators_result.ema_06_pre_01) then result_record.EMA06_state := 'FLAT' ; end if ;
           if ((ds_indicators_result.ema_06 < ds_indicators_result.ema_06_pre_01) and (ds_indicators_result.ema_06_pre_01 >= ds_indicators_result.ema_06_pre_02)) then
              result_record.EMA06_event_name   := 'EMA06_'||v_time_frame||'_LINE_VECTOR'  ;
              result_record.EMA06_event_vector := 'DOWN' ;
			  end if ;
           if ((ds_indicators_result.ema_06 > ds_indicators_result.ema_06_pre_01) and (ds_indicators_result.ema_06_pre_01 <= ds_indicators_result.ema_06_pre_02)) then
              result_record.EMA06_event_name   := 'EMA06_'||v_time_frame||'_LINE_VECTOR'  ;
              result_record.EMA06_event_vector := 'UP' ;
			  end if ;
-- расчитываем события и состояния EMA07
           result_record.EMA07_state := NULL ; result_record.EMA07_event_name := NULL ; result_record.EMA07_event_vector := NULL ;
		   if (ds_indicators_result.ema_07 > ds_indicators_result.ema_07_pre_01) then result_record.EMA07_state := 'UP' ; end if ;
		   if (ds_indicators_result.ema_07 < ds_indicators_result.ema_07_pre_01) then result_record.EMA07_state := 'DOWN' ; end if ;
		   if (ds_indicators_result.ema_07 = ds_indicators_result.ema_07_pre_01) then result_record.EMA07_state := 'FLAT' ; end if ;
           if ((ds_indicators_result.ema_07 < ds_indicators_result.ema_07_pre_01) and (ds_indicators_result.ema_07_pre_01 >= ds_indicators_result.ema_07_pre_02)) then
              result_record.EMA07_event_name   := 'EMA07_'||v_time_frame||'_LINE_VECTOR'  ;
              result_record.EMA07_event_vector := 'DOWN' ;
			  end if ;
           if ((ds_indicators_result.ema_07 > ds_indicators_result.ema_07_pre_01) and (ds_indicators_result.ema_07_pre_01 <= ds_indicators_result.ema_07_pre_02)) then
              result_record.EMA07_event_name   := 'EMA07_'||v_time_frame||'_LINE_VECTOR'  ;
              result_record.EMA07_event_vector := 'UP' ;
			  end if ;
-- расчитываем события и состояния EMA08
           result_record.EMA08_state := NULL ; result_record.EMA08_event_name := NULL ; result_record.EMA08_event_vector := NULL ;
		   if (ds_indicators_result.ema_08 > ds_indicators_result.ema_08_pre_01) then result_record.EMA08_state := 'UP' ; end if ;
		   if (ds_indicators_result.ema_08 < ds_indicators_result.ema_08_pre_01) then result_record.EMA08_state := 'DOWN' ; end if ;
		   if (ds_indicators_result.ema_08 = ds_indicators_result.ema_08_pre_01) then result_record.EMA08_state := 'FLAT' ; end if ;
           if ((ds_indicators_result.ema_08 < ds_indicators_result.ema_08_pre_01) and (ds_indicators_result.ema_08_pre_01 >= ds_indicators_result.ema_08_pre_02)) then
              result_record.EMA08_event_name   := 'EMA08_'||v_time_frame||'_LINE_VECTOR'  ;
              result_record.EMA08_event_vector := 'DOWN' ;
			  end if ;
           if ((ds_indicators_result.ema_08 > ds_indicators_result.ema_08_pre_01) and (ds_indicators_result.ema_08_pre_01 <= ds_indicators_result.ema_08_pre_02)) then
              result_record.EMA08_event_name   := 'EMA08_'||v_time_frame||'_LINE_VECTOR'  ;
              result_record.EMA08_event_vector := 'UP' ;
			  end if ;
		   
           result_record.change_ts          := now() ;
           cnt_ds_result := cnt_ds_result + 1 ;
           return next result_record ;
           END LOOP ;
       RETURN ;
       END ;
$BODY$;

ALTER FUNCTION public.fn_rtrsp_calck_events_as_table(character varying, character varying, character varying, timestamp without time zone, timestamp without time zone)
    OWNER TO crypta;
-- конец второй версии с другим выявлением RSI

select * from fn_rtrsp_calck_events_as_table('BTC','USDT','1M',
       CAST(now() - INTERVAL '500 days' as timestamp without time zone),
       CAST(now() as timestamp without time zone)) ;

CREATE OR REPLACE PROCEDURE public.fn_rtsp_driver_fill_events_tables(
       IN v_period_mode character varying)
LANGUAGE 'plpgsql'
AS $BODY$
       DECLARE
       sz_msg                    VARCHAR ;
       sz_request_table_name     VARCHAR ;
       ds_months_list            RECORD ;
       sz_months_list_request    VARCHAR ;
       sz_currency_pairs_request VARCHAR ;
       rec_currency_pairs_list   RECORD ;
       sz_time_period            VARCHAR ;
       sz_time_frame_list        VARCHAR[16] := '{"10M","30M","1H","4H","1D","4D","1W","4W"}' ;
--       sz_time_frame_list        VARCHAR[16] := '{"1M","3M","5M","10M","15M","30M","1H","2H","3H","4H","8H","12H","1D","2D","4D","1W","4W"}' ;	   
--       sz_time_frame_list VARCHAR[16] := '{"30M","15M"}' ;
       sz_time_frame             VARCHAR ;
       v_time_reduce_interval    timestamp without time zone ;
       v_time_grow_interval      timestamp without time zone ;
	   err_text_var1                 text ;
	   err_text_var2                 text ;
	   err_text_var3                 text ;
       BEGIN
-- выставляем переменные периодов в зависимости от выбранного режима работы        
       v_time_reduce_interval = clock_timestamp() - INTERVAL '32 days' ; v_time_grow_interval = clock_timestamp() + INTERVAL '2 days' ;
       if (v_period_mode = 'all') then
          v_time_reduce_interval = clock_timestamp() - INTERVAL '200 years' ;
          v_time_grow_interval = clock_timestamp() + INTERVAL '20 years' ;
          end if ;
       if (v_period_mode = 'operative') then
          v_time_reduce_interval = clock_timestamp() - INTERVAL '30 minutes' ;
          v_time_grow_interval = clock_timestamp() + INTERVAL '20 minutes' ;
          end if ;
       if (v_period_mode = 'gap_2_days') then
          v_time_reduce_interval = clock_timestamp() - INTERVAL '50 hours' ;
          v_time_grow_interval = clock_timestamp() + INTERVAL '3 hours' ;
          end if ;
       if (v_period_mode = 'gap_2_months') then
          v_time_reduce_interval = clock_timestamp() - INTERVAL '92 days' ;
          v_time_grow_interval = clock_timestamp() + INTERVAL '2 days' ;
          end if ;
-- обрабатываем записи
--       for v_time_frame IN 1..17 LOOP
       for v_time_frame IN 1..8 LOOP
           IF (sz_time_frame_list[v_time_frame] = '4W')  THEN sz_request_table_name := 'rtrsp_ohlc_4w_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '1W')  THEN sz_request_table_name := 'rtrsp_ohlc_1w_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '4D')  THEN sz_request_table_name := 'rtrsp_ohlc_4d_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '2D')  THEN sz_request_table_name := 'rtrsp_ohlc_2d_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '1D')  THEN sz_request_table_name := 'rtrsp_ohlc_1d_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '12H') THEN sz_request_table_name := 'rtrsp_ohlc_12h_history' ; END IF ;
           IF (sz_time_frame_list[v_time_frame] = '8H')  THEN sz_request_table_name := 'rtrsp_ohlc_8h_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '4H')  THEN sz_request_table_name := 'rtrsp_ohlc_4h_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '3H')  THEN sz_request_table_name := 'rtrsp_ohlc_3h_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '2H')  THEN sz_request_table_name := 'rtrsp_ohlc_2h_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '1H')  THEN sz_request_table_name := 'rtrsp_ohlc_1h_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '30M') THEN sz_request_table_name := 'rtrsp_ohlc_30m_history' ; END IF ;
           IF (sz_time_frame_list[v_time_frame] = '15M') THEN sz_request_table_name := 'rtrsp_ohlc_15m_history' ; END IF ;
           IF (sz_time_frame_list[v_time_frame] = '10M') THEN sz_request_table_name := 'rtrsp_ohlc_10m_history' ; END IF ;
           IF (sz_time_frame_list[v_time_frame] = '5M')  THEN sz_request_table_name := 'rtrsp_ohlc_5m_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '3M')  THEN sz_request_table_name := 'rtrsp_ohlc_3m_history' ;  END IF ;
           IF (sz_time_frame_list[v_time_frame] = '1M')  THEN sz_request_table_name := 'rtrsp_ohlc_1m_history' ;  END IF ;

           if (v_period_mode = 'all' OR v_period_mode = 'operative' OR v_period_mode = 'gap_2_days' OR v_period_mode = 'gap_2_months') then
              RAISE NOTICE '=== 1 Зашли в обработчик в режиме % для ТФ % ===', v_period_mode, sz_time_frame_list[v_time_frame] ;
--              sz_currency_pairs_request = 'select currency, reference_currency from '||sz_request_table_name||' group by currency, reference_currency order by 1,2' ;
-- 2024-10-11 обнаружили только 107 монет, получается остальных нет в таблицах истории ...
              sz_currency_pairs_request = 'select currency, reference_currency from rtrsp_ohlc_1m_history group by currency, reference_currency order by 1,2' ;
              FOR rec_currency_pairs_list IN EXECUTE sz_currency_pairs_request LOOP
                  sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||', старт заполнения ретро событий от '||v_time_reduce_interval||' до '||v_time_grow_interval ;
--                  RAISE NOTICE '[start driver] %/% ТФ% старт заполнения ретроспективных событий, от % до %', rec_currency_pairs_list.currency, rec_currency_pairs_list.reference_currency,sz_time_frame_list[v_time_frame],v_time_reduce_interval, v_time_grow_interval ;
--                  RAISE NOTICE '%', sz_msg ;
                  insert into cragran_logs values(clock_timestamp(),'rtsp_calc_indicator_EVENTS','fn_rtsp_driver_fill_events_tables',sz_msg) ;
                  COMMIT ;
                  RAISE NOTICE '--- 1 Зашли в обработчик монеты % / % ---', rec_currency_pairs_list.currency, rec_currency_pairs_list.reference_currency ;
                  BEGIN
                  MERGE INTO rtrsp_events_of_indicators dst
                        USING (SELECT * FROM fn_rtrsp_calck_events_as_table(rec_currency_pairs_list.currency, rec_currency_pairs_list.reference_currency, sz_time_frame_list[v_time_frame], CAST(v_time_reduce_interval AS timestamp without time zone), CAST(v_time_grow_interval AS timestamp without time zone))) src
                        ON src.currency = dst.currency AND src.reference_currency = dst.reference_currency AND src.timestamp_point = dst.timestamp_point AND
                           src.time_frame = dst.time_frame
                        WHEN MATCHED AND NOT (src.RSI_state = dst.RSI_state AND src.RSI_event_id = dst.RSI_event_id AND src.RSI_event_rand_id = dst.RSI_event_rand_id AND src.RSI_event_name = dst.RSI_event_name AND src.RSI_event_vector = dst.RSI_event_name AND 
src.MACD_modifier = dst.MACD_modifier AND
src.MACDL_state = dst.MACDL_state AND src.MACDL_event_id = dst.MACDL_event_id AND src.MACDL_event_rand_id = dst.MACDL_event_rand_id AND src.MACDL_event_name = dst.MACDL_event_name AND src.MACDL_event_vector = dst.MACDL_event_vector AND
src.MACDG_state = dst.MACDG_state AND src.MACDG_event_id = dst.MACDG_event_id AND src.MACDG_event_rand_id = dst.MACDG_event_rand_id AND src.MACDG_event_name = dst.MACDG_event_name AND src.MACDG_event_vector = dst.MACDG_event_vector AND
src.EMA_dataset_class = dst.EMA_dataset_class AND
src.EMA01_state = dst.EMA01_state AND src.EMA01_event_id = dst.EMA01_event_id AND src.EMA01_event_rand_id = dst.EMA01_event_rand_id AND src.EMA01_event_name = dst.EMA01_event_name AND src.EMA01_event_vector = dst.EMA01_event_vector AND
src.EMA02_state = dst.EMA02_state AND src.EMA02_event_id = dst.EMA02_event_id AND src.EMA02_event_rand_id = dst.EMA02_event_rand_id AND src.EMA02_event_name = dst.EMA02_event_name AND src.EMA02_event_vector = dst.EMA02_event_vector AND
src.EMA03_state = dst.EMA03_state AND src.EMA03_event_id = dst.EMA03_event_id AND src.EMA03_event_rand_id = dst.EMA03_event_rand_id AND src.EMA03_event_name = dst.EMA03_event_name AND src.EMA03_event_vector = dst.EMA03_event_vector AND
src.EMA04_state = dst.EMA04_state AND src.EMA04_event_id = dst.EMA04_event_id AND src.EMA04_event_rand_id = dst.EMA04_event_rand_id AND src.EMA04_event_name = dst.EMA04_event_name AND src.EMA04_event_vector = dst.EMA04_event_vector AND
src.EMA05_state = dst.EMA05_state AND src.EMA05_event_id = dst.EMA05_event_id AND src.EMA05_event_rand_id = dst.EMA05_event_rand_id AND src.EMA05_event_name = dst.EMA05_event_name AND src.EMA05_event_vector = dst.EMA05_event_vector AND
src.EMA06_state = dst.EMA06_state AND src.EMA06_event_id = dst.EMA06_event_id AND src.EMA06_event_rand_id = dst.EMA06_event_rand_id AND src.EMA06_event_name = dst.EMA06_event_name AND src.EMA06_event_vector = dst.EMA06_event_vector AND
src.EMA07_state = dst.EMA07_state AND src.EMA07_event_id = dst.EMA07_event_id AND src.EMA07_event_rand_id = dst.EMA07_event_rand_id AND src.EMA07_event_name = dst.EMA07_event_name AND src.EMA07_event_vector = dst.EMA07_event_vector AND
src.EMA07_state = dst.EMA08_state AND src.EMA08_event_id = dst.EMA08_event_id AND src.EMA08_event_rand_id = dst.EMA08_event_rand_id AND src.EMA08_event_name = dst.EMA08_event_name AND src.EMA08_event_vector = dst.EMA08_event_vector) THEN
                             UPDATE SET RSI_state = src.RSI_state, RSI_event_id = src.RSI_event_id, RSI_event_rand_id = src.RSI_event_rand_id, RSI_event_name = src.RSI_event_name, RSI_event_vector = src.RSI_event_name,
MACD_modifier = src.MACD_modifier, MACDL_state = src.MACDL_state, MACDL_event_id = src.MACDL_event_id, MACDL_event_rand_id = src.MACDL_event_rand_id, MACDL_event_name = src.MACDL_event_name, MACDL_event_vector = src.MACDL_event_vector,
MACDG_state = src.MACDG_state, MACDG_event_id = src.MACDG_event_id, MACDG_event_rand_id = src.MACDG_event_rand_id, MACDG_event_name = src.MACDG_event_name, MACDG_event_vector = src.MACDG_event_vector, EMA_dataset_class = src.EMA_dataset_class,
EMA01_state = src.EMA01_state, EMA01_event_id = src.EMA01_event_id, EMA01_event_rand_id = src.EMA01_event_rand_id, EMA01_event_name = src.EMA01_event_name, EMA01_event_vector = src.EMA01_event_vector,
EMA02_state = src.EMA02_state, EMA02_event_id = src.EMA02_event_id, EMA02_event_rand_id = src.EMA02_event_rand_id, EMA02_event_name = src.EMA02_event_name, EMA02_event_vector = src.EMA02_event_vector,
EMA03_state = src.EMA03_state, EMA03_event_id = src.EMA03_event_id, EMA03_event_rand_id = src.EMA03_event_rand_id, EMA03_event_name = src.EMA03_event_name, EMA03_event_vector = src.EMA03_event_vector,
EMA04_state = src.EMA04_state, EMA04_event_id = src.EMA04_event_id, EMA04_event_rand_id = src.EMA04_event_rand_id, EMA04_event_name = src.EMA04_event_name, EMA04_event_vector = src.EMA04_event_vector,
EMA05_state = src.EMA05_state, EMA05_event_id = src.EMA05_event_id, EMA05_event_rand_id = src.EMA05_event_rand_id, EMA05_event_name = src.EMA05_event_name, EMA05_event_vector = src.EMA05_event_vector,
EMA06_state = src.EMA06_state, EMA06_event_id = src.EMA06_event_id, EMA06_event_rand_id = src.EMA06_event_rand_id, EMA06_event_name = src.EMA06_event_name, EMA06_event_vector = src.EMA06_event_vector,
EMA07_state = src.EMA07_state, EMA07_event_id = src.EMA07_event_id, EMA07_event_rand_id = src.EMA07_event_rand_id, EMA07_event_name = src.EMA07_event_name, EMA07_event_vector = src.EMA07_event_vector,
EMA08_state = src.EMA08_state, EMA08_event_id = src.EMA08_event_id, EMA08_event_rand_id = src.EMA08_event_rand_id, EMA08_event_name = src.EMA08_event_name, EMA08_event_vector = src.EMA08_event_vector,
change_ts = src.change_ts
                        WHEN NOT MATCHED THEN
                             INSERT (currency, reference_currency, timestamp_point, time_frame, 
RSI_state, RSI_event_id, RSI_event_rand_id, RSI_event_name, RSI_event_vector, 
MACD_modifier, MACDL_state, MACDL_event_id, MACDL_event_rand_id, MACDL_event_name, MACDL_event_vector,
MACDG_state, MACDG_event_id, MACDG_event_rand_id, MACDG_event_name, MACDG_event_vector, EMA_dataset_class,
EMA01_state, EMA01_event_id, EMA01_event_rand_id, EMA01_event_name, EMA01_event_vector, EMA02_state, EMA02_event_id, EMA02_event_rand_id, EMA02_event_name, EMA02_event_vector,
EMA03_state, EMA03_event_id, EMA03_event_rand_id, EMA03_event_name, EMA03_event_vector, EMA04_state, EMA04_event_id, EMA04_event_rand_id, EMA04_event_name, EMA04_event_vector,
EMA05_state, EMA05_event_id, EMA05_event_rand_id, EMA05_event_name, EMA05_event_vector, EMA06_state, EMA06_event_id, EMA06_event_rand_id, EMA06_event_name, EMA06_event_vector,
EMA07_state, EMA07_event_id, EMA07_event_rand_id, EMA07_event_name, EMA07_event_vector, EMA08_state, EMA08_event_id, EMA08_event_rand_id, EMA08_event_name, EMA08_event_vector, change_ts)
                                    VALUES (src.currency, src.reference_currency, src.timestamp_point, src.time_frame, 
src.RSI_state, src.RSI_event_id, src.RSI_event_rand_id, src.RSI_event_name, src.RSI_event_name,
src.MACD_modifier, src.MACDL_state, src.MACDL_event_id, src.MACDL_event_rand_id, src.MACDL_event_name, src.MACDL_event_vector,
src.MACDG_state, src.MACDG_event_id, src.MACDG_event_rand_id, src.MACDG_event_name, src.MACDG_event_vector, src.EMA_dataset_class,
src.EMA01_state, src.EMA01_event_id, src.EMA01_event_rand_id, src.EMA01_event_name, src.EMA01_event_vector,
src.EMA02_state, src.EMA02_event_id, src.EMA02_event_rand_id, src.EMA02_event_name, src.EMA02_event_vector,
src.EMA03_state, src.EMA03_event_id, src.EMA03_event_rand_id, src.EMA03_event_name, src.EMA03_event_vector,
src.EMA04_state, src.EMA04_event_id, src.EMA04_event_rand_id, src.EMA04_event_name, src.EMA04_event_vector,
src.EMA05_state, src.EMA05_event_id, src.EMA05_event_rand_id, src.EMA05_event_name, src.EMA05_event_vector,
src.EMA06_state, src.EMA06_event_id, src.EMA06_event_rand_id, src.EMA06_event_name, src.EMA06_event_vector,
src.EMA07_state, src.EMA07_event_id, src.EMA07_event_rand_id, src.EMA07_event_name, src.EMA07_event_vector,
src.EMA08_state, src.EMA08_event_id, src.EMA08_event_rand_id, src.EMA08_event_name, src.EMA08_event_vector,
src.change_ts) ;
                  sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||', старт заполнения ретро данных EMA от '||v_time_reduce_interval||' до '||v_time_grow_interval ;
                  insert into cragran_logs values(clock_timestamp(),'rtsp_calc_indicator_EVENTS','fn_rtsp_driver_fill_events_tables',sz_msg) ;
--                  COMMIT ;
                  EXCEPTION WHEN OTHERS THEN
                            GET STACKED DIAGNOSTICS err_text_var1 = MESSAGE_TEXT, err_text_var2 = PG_EXCEPTION_DETAIL, err_text_var3 = PG_EXCEPTION_HINT ;
--                            sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||', старт заполнения ретро событий' ;
                            sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||', старт заполнения ретро событий'||err_text_var1||err_text_var2||err_text_var3 ;
                            insert into cragran_logs values(clock_timestamp(),'rtsp_calc_indicator_EVENTS','fn_fill_events_history','Error INSERT '||sz_msg) ;
                  END ;
                  COMMIT ; -- для каждой монеты зафиксировать результат обработки
                  END LOOP ; -- конец помонетного цикла
              END IF ; -- конец обработчика v_period_mode != 'all_per_month'

           IF (v_period_mode = 'all_per_month') THEN
              RAISE NOTICE '=== 2 Зашли в обработчик в режиме % для ТФ % ===', v_period_mode, sz_time_frame_list[v_time_frame] ;
              sz_months_list_request = 'select src.tsp from (select date_trunc(''month'',timestamp_point) tsp from '||sz_request_table_name||') src group by src.tsp order by 1 asc' ;
              FOR ds_months_list IN EXECUTE sz_months_list_request LOOP
                              sz_currency_pairs_request = 'select currency, reference_currency from '||sz_request_table_name||' group by currency, reference_currency order by 1,2' ;
                  FOR rec_currency_pairs_list IN EXECUTE sz_currency_pairs_request LOOP
                      sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||', старт заполнения ретро сбытий послойно' ;
--                                  RAISE NOTICE '[start driver] %/% ТФ% старт заполнения ретроспективных событий послойно, от % до %', rec_currency_pairs_list.currency, rec_currency_pairs_list.reference_currency,sz_time_frame_list[v_time_frame],v_time_reduce_interval, v_time_grow_interval ;
--                  RAISE NOTICE '%', sz_msg ;
                      insert into cragran_logs values(clock_timestamp(),'rtsp_calc_indicator_EVENTS','fn_rtsp_driver_fill_events_tables',sz_msg) ;
                      COMMIT ;
                      BEGIN
                  MERGE INTO rtrsp_events_of_indicators dst
                        USING (SELECT * FROM fn_rtrsp_calck_events_as_table(rec_currency_pairs_list.currency, rec_currency_pairs_list.reference_currency, sz_time_frame_list[v_time_frame], CAST(v_time_reduce_interval AS timestamp without time zone), CAST(v_time_grow_interval AS timestamp without time zone))) src
                        ON src.currency = dst.currency AND src.reference_currency = dst.reference_currency AND src.timestamp_point = dst.timestamp_point AND
                           src.time_frame = dst.time_frame
                        WHEN MATCHED AND NOT (src.RSI_state = dst.RSI_state AND src.RSI_event_id = dst.RSI_event_id AND src.RSI_event_rand_id = dst.RSI_event_rand_id AND src.RSI_event_name = dst.RSI_event_name AND src.RSI_event_vector = dst.RSI_event_name AND 
src.MACD_modifier = dst.MACD_modifier AND
src.MACDL_state = dst.MACDL_state AND src.MACDL_event_id = dst.MACDL_event_id AND src.MACDL_event_rand_id = dst.MACDL_event_rand_id AND src.MACDL_event_name = dst.MACDL_event_name AND src.MACDL_event_vector = dst.MACDL_event_vector AND
src.MACDG_state = dst.MACDG_state AND src.MACDG_event_id = dst.MACDG_event_id AND src.MACDG_event_rand_id = dst.MACDG_event_rand_id AND src.MACDG_event_name = dst.MACDG_event_name AND src.MACDG_event_vector = dst.MACDG_event_vector AND
src.EMA_dataset_class = dst.EMA_dataset_class AND
src.EMA01_state = dst.EMA01_state AND src.EMA01_event_id = dst.EMA01_event_id AND src.EMA01_event_rand_id = dst.EMA01_event_rand_id AND src.EMA01_event_name = dst.EMA01_event_name AND src.EMA01_event_vector = dst.EMA01_event_vector AND
src.EMA02_state = dst.EMA02_state AND src.EMA02_event_id = dst.EMA02_event_id AND src.EMA02_event_rand_id = dst.EMA02_event_rand_id AND src.EMA02_event_name = dst.EMA02_event_name AND src.EMA02_event_vector = dst.EMA02_event_vector AND
src.EMA03_state = dst.EMA03_state AND src.EMA03_event_id = dst.EMA03_event_id AND src.EMA03_event_rand_id = dst.EMA03_event_rand_id AND src.EMA03_event_name = dst.EMA03_event_name AND src.EMA03_event_vector = dst.EMA03_event_vector AND
src.EMA04_state = dst.EMA04_state AND src.EMA04_event_id = dst.EMA04_event_id AND src.EMA04_event_rand_id = dst.EMA04_event_rand_id AND src.EMA04_event_name = dst.EMA04_event_name AND src.EMA04_event_vector = dst.EMA04_event_vector AND
src.EMA05_state = dst.EMA05_state AND src.EMA05_event_id = dst.EMA05_event_id AND src.EMA05_event_rand_id = dst.EMA05_event_rand_id AND src.EMA05_event_name = dst.EMA05_event_name AND src.EMA05_event_vector = dst.EMA05_event_vector AND
src.EMA06_state = dst.EMA06_state AND src.EMA06_event_id = dst.EMA06_event_id AND src.EMA06_event_rand_id = dst.EMA06_event_rand_id AND src.EMA06_event_name = dst.EMA06_event_name AND src.EMA06_event_vector = dst.EMA06_event_vector AND
src.EMA07_state = dst.EMA07_state AND src.EMA07_event_id = dst.EMA07_event_id AND src.EMA07_event_rand_id = dst.EMA07_event_rand_id AND src.EMA07_event_name = dst.EMA07_event_name AND src.EMA07_event_vector = dst.EMA07_event_vector AND
src.EMA07_state = dst.EMA08_state AND src.EMA08_event_id = dst.EMA08_event_id AND src.EMA08_event_rand_id = dst.EMA08_event_rand_id AND src.EMA08_event_name = dst.EMA08_event_name AND src.EMA08_event_vector = dst.EMA08_event_vector) THEN
                             UPDATE SET RSI_state = src.RSI_state, RSI_event_id = src.RSI_event_id, RSI_event_rand_id = src.RSI_event_rand_id, RSI_event_name = src.RSI_event_name, RSI_event_vector = src.RSI_event_name,
MACD_modifier = src.MACD_modifier, MACDL_state = src.MACDL_state, MACDL_event_id = src.MACDL_event_id, MACDL_event_rand_id = src.MACDL_event_rand_id, MACDL_event_name = src.MACDL_event_name, MACDL_event_vector = src.MACDL_event_vector,
MACDG_state = src.MACDG_state, MACDG_event_id = src.MACDG_event_id, MACDG_event_rand_id = src.MACDG_event_rand_id, MACDG_event_name = src.MACDG_event_name, MACDG_event_vector = src.MACDG_event_vector, EMA_dataset_class = src.EMA_dataset_class,
EMA01_state = src.EMA01_state, EMA01_event_id = src.EMA01_event_id, EMA01_event_rand_id = src.EMA01_event_rand_id, EMA01_event_name = src.EMA01_event_name, EMA01_event_vector = src.EMA01_event_vector,
EMA02_state = src.EMA02_state, EMA02_event_id = src.EMA02_event_id, EMA02_event_rand_id = src.EMA02_event_rand_id, EMA02_event_name = src.EMA02_event_name, EMA02_event_vector = src.EMA02_event_vector,
EMA03_state = src.EMA03_state, EMA03_event_id = src.EMA03_event_id, EMA03_event_rand_id = src.EMA03_event_rand_id, EMA03_event_name = src.EMA03_event_name, EMA03_event_vector = src.EMA03_event_vector,
EMA04_state = src.EMA04_state, EMA04_event_id = src.EMA04_event_id, EMA04_event_rand_id = src.EMA04_event_rand_id, EMA04_event_name = src.EMA04_event_name, EMA04_event_vector = src.EMA04_event_vector,
EMA05_state = src.EMA05_state, EMA05_event_id = src.EMA05_event_id, EMA05_event_rand_id = src.EMA05_event_rand_id, EMA05_event_name = src.EMA05_event_name, EMA05_event_vector = src.EMA05_event_vector,
EMA06_state = src.EMA06_state, EMA06_event_id = src.EMA06_event_id, EMA06_event_rand_id = src.EMA06_event_rand_id, EMA06_event_name = src.EMA06_event_name, EMA06_event_vector = src.EMA06_event_vector,
EMA07_state = src.EMA07_state, EMA07_event_id = src.EMA07_event_id, EMA07_event_rand_id = src.EMA07_event_rand_id, EMA07_event_name = src.EMA07_event_name, EMA07_event_vector = src.EMA07_event_vector,
EMA08_state = src.EMA08_state, EMA08_event_id = src.EMA08_event_id, EMA08_event_rand_id = src.EMA08_event_rand_id, EMA08_event_name = src.EMA08_event_name, EMA08_event_vector = src.EMA08_event_vector,
change_ts = src.change_ts
                        WHEN NOT MATCHED THEN
                             INSERT (currency, reference_currency, timestamp_point, time_frame, 
RSI_state, RSI_event_id, RSI_event_rand_id, RSI_event_name, RSI_event_vector, 
MACD_modifier, MACDL_state, MACDL_event_id, MACDL_event_rand_id, MACDL_event_name, MACDL_event_vector,
MACDG_state, MACDG_event_id, MACDG_event_rand_id, MACDG_event_name, MACDG_event_vector, EMA_dataset_class,
EMA01_state, EMA01_event_id, EMA01_event_rand_id, EMA01_event_name, EMA01_event_vector, EMA02_state, EMA02_event_id, EMA02_event_rand_id, EMA02_event_name, EMA02_event_vector,
EMA03_state, EMA03_event_id, EMA03_event_rand_id, EMA03_event_name, EMA03_event_vector, EMA04_state, EMA04_event_id, EMA04_event_rand_id, EMA04_event_name, EMA04_event_vector,
EMA05_state, EMA05_event_id, EMA05_event_rand_id, EMA05_event_name, EMA05_event_vector, EMA06_state, EMA06_event_id, EMA06_event_rand_id, EMA06_event_name, EMA06_event_vector,
EMA07_state, EMA07_event_id, EMA07_event_rand_id, EMA07_event_name, EMA07_event_vector, EMA08_state, EMA08_event_id, EMA08_event_rand_id, EMA08_event_name, EMA08_event_vector, change_ts)
                                    VALUES (src.currency, src.reference_currency, src.timestamp_point, src.time_frame, 
src.RSI_state, src.RSI_event_id, src.RSI_event_rand_id, src.RSI_event_name, src.RSI_event_name,
src.MACD_modifier, src.MACDL_state, src.MACDL_event_id, src.MACDL_event_rand_id, src.MACDL_event_name, src.MACDL_event_vector,
src.MACDG_state, src.MACDG_event_id, src.MACDG_event_rand_id, src.MACDG_event_name, src.MACDG_event_vector, src.EMA_dataset_class,
src.EMA01_state, src.EMA01_event_id, src.EMA01_event_rand_id, src.EMA01_event_name, src.EMA01_event_vector,
src.EMA02_state, src.EMA02_event_id, src.EMA02_event_rand_id, src.EMA02_event_name, src.EMA02_event_vector,
src.EMA03_state, src.EMA03_event_id, src.EMA03_event_rand_id, src.EMA03_event_name, src.EMA03_event_vector,
src.EMA04_state, src.EMA04_event_id, src.EMA04_event_rand_id, src.EMA04_event_name, src.EMA04_event_vector,
src.EMA05_state, src.EMA05_event_id, src.EMA05_event_rand_id, src.EMA05_event_name, src.EMA05_event_vector,
src.EMA06_state, src.EMA06_event_id, src.EMA06_event_rand_id, src.EMA06_event_name, src.EMA06_event_vector,
src.EMA07_state, src.EMA07_event_id, src.EMA07_event_rand_id, src.EMA07_event_name, src.EMA07_event_vector,
src.EMA08_state, src.EMA08_event_id, src.EMA08_event_rand_id, src.EMA08_event_name, src.EMA08_event_vector,
src.change_ts) ;
                      sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||', старт заполнения ретро событий послойно' ;
                      insert into cragran_logs values(clock_timestamp(),'rtsp_calc_indicator_EVENTS','fn_rtsp_driver_fill_events_tables',sz_msg) ;
--                  COMMIT ;
                      EXCEPTION WHEN OTHERS THEN
--GET STACKED DIAGNOSTICS text_var1 = MESSAGE_TEXT,
--                          text_var2 = PG_EXCEPTION_DETAIL,
--                          text_var3 = PG_EXCEPTION_HINT;
                                sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||' ТФ'||sz_time_frame_list[v_time_frame]||', старт заполнения ретро событий послойно' ;
                                insert into cragran_logs values(clock_timestamp(),'rtsp_calc_indicator_EVENTS','fn_fill_events_history','Error INSERT '||sz_msg) ;
                      END ;
                      COMMIT ;  -- для каждой монеты зафиксировать результат обработки
                      END LOOP ; -- конец помонетного цикла
                  END LOOP ; -- конец помесячного цикла
              END IF ; -- конец обработчика v_period_mode = 'all_per_month'
       END LOOP ; -- конец перебора таймфрэймов
END ;
$BODY$;

fn_rtsp_driver_fill_events_tables
CALL fn_rtsp_driver_fill_events_tables('all') ;

--delete from cragran_logs where module = 'fn_rtsp_driver_fill_EVENTS_tables' OR module = 'fn_fill_events_history' ;
--delete from rtrsp_events_of_indicators ;

select * from cragran_logs order by 1 desc limit 1000 ;
select count(*) from rtrsp_events_of_indicators ;
select count(*) from rtrsp_events_of_indicators limit 1000 ;

select currency, reference_currency, count(*) from rtrsp_events_of_indicators group by currency, reference_currency order by 1 ;
select currency, count(*) from rtrsp_events_of_indicators group by currency order by 1 ;
select * from pg_class where relname = 'rtrsp_events_of_indicators' ;

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.17 конец -- таблицы и функции заполнения ретроспективных событий
-- ---------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.18 начало -- таблицы и функции заполнения ретроспективной стратегии RSI1H_MACD4H
-- ---------------------------------------------------------------------------------------------------------------------------
select * from cragran_logs order by timestamp_point desc limit 1000 ;

-- чтобы каждый раз не выбирать уникальные пары из больших выборок, это делается заранее
-- изменения потребуются только при появлении новых пар или выводе старых
CREATE TABLE rtrsp_processed_coin_pairs(
       currency           character varying(100) NOT NULL,
       reference_currency character varying(100) NOT NULL,
       CONSTRAINT rtrsp_processed_coin_pairs_pkey
                  PRIMARY KEY (currency, reference_currency)
       ) ;

insert into rtrsp_processed_coin_pairs 
       select currency, reference_currency
              from (select currency, reference_currency from crcomp_pair_ohlc_1m_history group by currency, reference_currency
                   union all
                   select currency, reference_currency from crcomp_pair_ohlc_1h_history group by currency, reference_currency
                   union all
                   select currency, reference_currency from crcomp_pair_ohlc_1d_history group by currency, reference_currency) src
                   group by currency, reference_currency order by 1, 2 ;


DROP TABLE rtrsp_analyze_strategy CASCADE ;
CREATE TABLE rtrsp_analyze_strategy(
       strategy_name      character varying(100) NOT NULL,
       strategy_sub_name  character varying(100) NOT NULL,
       currency           character varying(100) NOT NULL,
       reference_currency character varying(100) NOT NULL,
       vector             character varying(10),
       profit             REAL,
	   protected_profit   REAL,
       cn_period          INTERVAL,
       min_prct           REAL,
	   prtct_min_prct     REAL,
       max_prct           REAL,
       contract_in_tp     timestamp without time zone,
       contract_in_price  NUMERIC(42,21),
       contract_out_tp    timestamp without time zone,
       contract_out_price NUMERIC(42,21),
       change_ts timestamp without time zone,
       CONSTRAINT rtrsp_analyze_strategy_pkey
                  PRIMARY KEY (strategy_name, strategy_sub_name, currency, reference_currency)
       ) ;

DROP TABLE rtrsp_analyze_strategy_argegate CASCADE ;
CREATE TABLE rtrsp_analyze_strategy_argegate(
       strategy_name      character varying(100),
       strategy_sub_name  character varying(100),
       currency           character varying(100),
       reference_currency character varying(100),
       vector_type        character varying(10),
       profit             REAL,
	   protected_profit   REAL,
       count_all          INT,
       prct_count_pos     REAL,
       prct_count_neg     REAL,
       min_min_prct       REAL,
       avg_min_prct       REAL,
       max_max_prct       REAL,
       avg_max_prct       REAL,
	   prtct_min_min_prct REAL,
       prtct_avg_min_prct REAL,
       start_period       timestamp without time zone,
       stop_period        timestamp without time zone,
       change_ts timestamp without time zone
       ) ;

-- стратегия RSI1H+MACD4H - вход и выход
select timestamp_point, RSI_state IND_STATE, RSI_event_name EVENT_NAME, RSI_event_vector EVENT_VECTOR 
       from rtrsp_events_of_indicators
       where currency = 'BTC' and reference_currency = 'USDT' and time_frame = '1H' and RSI_event_name IS NOT NULL and RSI_event_vector IS NOT NULL
             AND NOT RSI_event_name LIKE 'RSI_1H_CLEAR%'
union all
select timestamp_point, MACDL_state, MACDL_event_name, MACDL_event_vector 
       from rtrsp_events_of_indicators 
       where currency = 'BTC' and reference_currency = 'USDT' and time_frame = '4H' and MACDL_event_name IS NOT NULL and MACDL_event_vector IS NOT NULL
             AND MACDL_event_name like '%CROSS%'
order by 1 asc ;

select timestamp_point, RSI_state IND_STATE, RSI_event_name EVENT_NAME, RSI_event_vector EVENT_VECTOR 
       from rtrsp_events_of_indicators
       where currency = '1INCH' and reference_currency = 'USDT' and time_frame = '10M' and RSI_event_name IS NOT NULL and RSI_event_vector IS NOT NULL
             AND NOT RSI_event_name LIKE 'RSI_1H_CLEAR%'
union all
select timestamp_point, MACDL_state, MACDL_event_name, MACDL_event_vector 
       from rtrsp_events_of_indicators 
       where currency = '1INCH' and reference_currency = 'USDT' and time_frame = '30M' and MACDL_event_name IS NOT NULL and MACDL_event_vector IS NOT NULL
             AND MACDL_event_name like '%CROSS%'
order by 1 asc ;

-- количество записей цены помесячно
select TO_CHAR(timestamp_point, 'YYYY-MM'), count(*) from rtrsp_ohlc_1H_history where currency = '1INCH' group by TO_CHAR(timestamp_point, 'YYYY-MM') order by 1 ;
-- количество записей RSI помесячно
select TO_CHAR(timestamp_point, 'YYYY-MM'), count(*) from rtrsp_rsi_history where currency = '1INCH' and time_frame = '1H'  group by TO_CHAR(timestamp_point, 'YYYY-MM') order by 1 ;

select TO_CHAR(timestamp_point, 'YYYY-MM'), count(*) from rtrsp_EVENTS_OF_INDICATORS where currency = '1INCH' and time_frame = '1H' 
       AND rsi_event_name is not null
           group by TO_CHAR(timestamp_point, 'YYYY-MM') order by 1 ;

select * from rtrsp_rsi_history where currency = '1INCH' and timestamp_point > TO_TIMESTAMP('2024-05-01', 'YYYY_MM-DD') order by timestamp_point ;
select currency, reference_currency from rtrsp_ohlc_1m_history group by currency, reference_currency order by 1,2
select currency from rtrsp_ohlc_1m_history group by currency order by 1

-- обработчик первой стратегии
DROP FUNCTION check_strategy_RSI_MACD_long_as_table ;
CREATE OR REPLACE FUNCTION public.check_strategy_rsi_macd_long_as_table(
    v_currency character varying,
    v_reference_currency character varying,
    v_rsi_time_frame character varying,
    v_macd_time_frame character varying,
    v_macd_ind_type character varying,
    v_macd_ind_sub_type character varying,
    v_protected_profit real,
    v_is_include_rsi boolean,
    v_start_date character varying,
    v_stop_date character varying)
    RETURNS SETOF rtrsp_analyze_strategy 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
       DECLARE
       result_record                       rtrsp_analyze_strategy%ROWTYPE ;
       ds_request                          VARCHAR ;
       ds_data                             RECORD ;
       sz_msg                              VARCHAR(1000) ;
       in_timestamp_point                  timestamp without time zone ;
       in_price                            NUMERIC ; 
       out_timestamp_point                 timestamp without time zone ;
       out_price                           NUMERIC ; 
-- переменные шаблона входа
       tmpl_01_RSI_UP_is_detected          boolean ;
       tmpl_01_RSI_DOWN_is_detected        boolean ;
       tmpl_01_RSI_timestamp_point         timestamp without time zone ;
       tmpl_01_RSI_event_name              character varying(100) ;
       tmpl_02_MACD_UP_is_detected         boolean ;
       tmpl_02_MACD_DOWN_is_detected       boolean ;
       tmpl_02_MACD_timestamp_point        timestamp without time zone ;
       tmpl_02_MACD_event_name             character varying(100) ;
       tmpl_02_MACD_event_vector           character varying(30) ;
       sum_percent_clear                   real ;
       sum_percent_protected               real ;
       SL_value                            real ;
       cnt_contracts                       int ;
       max_price                           NUMERIC ; 
       min_price                           NUMERIC ; 
       BEGIN
       in_timestamp_point := NULL ; out_timestamp_point := NULL ; in_price := NULL ; out_price := NULL ;
       tmpl_01_RSI_UP_is_detected := false ; tmpl_01_RSI_DOWN_is_detected := false ;
       tmpl_01_RSI_timestamp_point := NULL ; tmpl_01_RSI_event_name := NULL ;
       tmpl_02_MACD_UP_is_detected := false ; tmpl_02_MACD_DOWN_is_detected:= false ;
       tmpl_02_MACD_timestamp_point := NULL ; tmpl_02_MACD_event_name := NULL ; tmpl_02_MACD_event_vector := NULL ;
       sum_percent_clear := 0 ; sum_percent_protected := 0 ; SL_value = -2 ; cnt_contracts := 0 ;
       if (v_MACD_ind_type = 'LINE') then -- используется и тут, и в формировании имени события при проверках ниже
          ds_request := 'select timestamp_point, RSI_state IND_STATE, RSI_event_name EVENT_NAME, RSI_event_vector EVENT_VECTOR
                                from rtrsp_events_of_indicators
                                where currency = $1 and reference_currency = $2 and time_frame = $3 and RSI_event_name IS NOT NULL
				      AND RSI_event_vector IS NOT NULL AND NOT RSI_event_name LIKE ''RSI_1H_CLEAR%''
                                      AND timestamp_point >= TO_TIMESTAMP('''||v_start_date||''',''YYYY-MM-DD HH24:MI:SS'')
                                      AND timestamp_point <= TO_TIMESTAMP('''||v_stop_date||''',''YYYY-MM-DD HH24:MI:SS'')
                          union all
                          select timestamp_point, MACDL_state, MACDL_event_name, MACDL_event_vector
                                 from rtrsp_events_of_indicators
                                 where currency = $1 and reference_currency = $2 and time_frame = $4 and MACDL_event_name IS NOT NULL 
				       AND MACDL_event_vector IS NOT NULL AND MACDL_event_name like ''%'||v_MACD_ind_sub_type||'%''
                                       AND timestamp_point >= TO_TIMESTAMP('''||v_start_date||''',''YYYY-MM-DD HH24:MI:SS'')
                                       AND timestamp_point <= TO_TIMESTAMP('''||v_stop_date||''',''YYYY-MM-DD HH24:MI:SS'')
                          order by 1 asc' ;
       end if ;
       if (v_MACD_ind_type = 'GIST') then -- используется и тут, и в формировании имени события при проверках ниже
          ds_request := 'select timestamp_point, RSI_state IND_STATE, RSI_event_name EVENT_NAME, RSI_event_vector EVENT_VECTOR 
                                from rtrsp_events_of_indicators
                                where currency = $1 and reference_currency = $2 and time_frame = $3 and RSI_event_name IS NOT NULL 
				      AND RSI_event_vector IS NOT NULL AND NOT RSI_event_name LIKE ''RSI_1H_CLEAR%''
                                      AND timestamp_point >= TO_TIMESTAMP('''||v_start_date||''',''YYYY-MM-DD HH24:MI:SS'')
                                      AND timestamp_point <= TO_TIMESTAMP('''||v_stop_date||''',''YYYY-MM-DD HH24:MI:SS'')
                         union all
                         select timestamp_point, MACDG_state, MACDG_event_name, MACDG_event_vector 
                                from rtrsp_events_of_indicators 
                                where currency = $1 and reference_currency = $2 and time_frame = $4 and MACDG_event_name IS NOT NULL 
				      AND MACDG_event_vector IS NOT NULL AND MACDG_event_name like ''%'||v_MACD_ind_sub_type||'%''
                                      AND timestamp_point >= TO_TIMESTAMP('''||v_start_date||''',''YYYY-MM-DD HH24:MI:SS'')
                                      AND timestamp_point <= TO_TIMESTAMP('''||v_stop_date||''',''YYYY-MM-DD HH24:MI:SS'')
                         order by 1 asc' ;
       end if ;
-- debug RAISE NOTICE 'request %', ds_request ;
-- идём по упорядоченному списку событий
-- ищем вхождения шаблонных событий, тут они на вход и выход одинаковые
-- после выявления первого ловим второе
-- как поймали второе - внутри его обработчика проверяем, это события входа или выхода. Потом сбрасываем переменные шаблона
-- но при этом выход не инициализируем, если не было входа
       FOR ds_data IN EXECUTE ds_request USING v_currency, v_reference_currency, v_RSI_time_frame, v_MACD_time_frame LOOP
           IF ( ds_data.EVENT_NAME = 'RSI_'||v_RSI_time_frame||'_UP_CROSS_70' and tmpl_01_RSI_UP_is_detected = false ) THEN
	      tmpl_01_RSI_UP_is_detected   := true ;
	      tmpl_01_RSI_DOWN_is_detected := false ;
              tmpl_01_RSI_timestamp_point  := ds_data.TIMESTAMP_POINT ;
              tmpl_01_RSI_event_name       := ds_data.EVENT_NAME ;
              END IF ;
           IF ( ds_data.EVENT_NAME = 'RSI_'||v_RSI_time_frame||'_DOWN_CROSS_30' and tmpl_01_RSI_DOWN_is_detected = false ) THEN
	      tmpl_01_RSI_DOWN_is_detected := true ;
	      tmpl_01_RSI_UP_is_detected   := false ;
              tmpl_01_RSI_timestamp_point  := ds_data.TIMESTAMP_POINT ;
              tmpl_01_RSI_event_name       := ds_data.EVENT_NAME ;
              END IF ;
           IF ( ds_data.EVENT_NAME = 'MACD_'||v_MACD_time_frame||'_'||v_MACD_ind_type||'_'||v_MACD_ind_sub_type ) THEN
-- при выявлении второго события шаблона проверить - заполнен ли шаблон
-- для точки входа
-- во второй версии стратегии проверяем, что это первое событие из возможных нескольких, как и в RSI
              IF ( tmpl_01_RSI_event_name = 'RSI_'||v_RSI_time_frame||'_DOWN_CROSS_30' 
		   and ds_data.EVENT_NAME = 'MACD_'||v_MACD_time_frame||'_'||v_MACD_ind_type||'_'||v_MACD_ind_sub_type 
		   and ds_data.EVENT_VECTOR = 'UP' 
		   and tmpl_02_MACD_UP_is_detected = false ) THEN
		 tmpl_02_MACD_UP_is_detected   := true ;
		 tmpl_02_MACD_DOWN_is_detected := false ;
		 tmpl_02_MACD_timestamp_point  := ds_data.TIMESTAMP_POINT ;
                 tmpl_02_MACD_event_name       := ds_data.EVENT_NAME ;
                 tmpl_02_MACD_event_vector     := ds_data.EVENT_VECTOR ;
                 sz_msg := 'long точка входа - '||TO_CHAR(tmpl_01_RSI_timestamp_point,'YYYY-MM-DD HH24:MI:SS')||' - '||tmpl_01_RSI_event_name||' --- '||TO_CHAR(tmpl_02_MACD_timestamp_point,'YYYY-MM-DD HH24:MI:SS')||' - '||tmpl_02_MACD_event_name||' - '||tmpl_02_MACD_event_vector ;
-- debug                RAISE NOTICE 'идентифицировано заполнение шаблона % ', sz_msg ;
                 in_timestamp_point := tmpl_02_MACD_timestamp_point ;
                 END IF ;
-- для точки вЫхода
-- во второй версии стратегии проверяем, что это первое событие из возможных нескольких, как и в RSI				 
-- для точки выхода - проверяем ещё, что взведена точка входа, тогда записываем выход, сбрасываем переменные шаблона, печатаем выход, сбрасываем даты точки
              IF ( tmpl_01_RSI_event_name = 'RSI_'||v_RSI_time_frame||'_UP_CROSS_70' 
		   and ds_data.EVENT_NAME = 'MACD_'||v_MACD_time_frame||'_'||v_MACD_ind_type||'_'||v_MACD_ind_sub_type 
		   and ds_data.EVENT_VECTOR = 'DOWN' 
		   and tmpl_02_MACD_DOWN_is_detected = false
		   and in_timestamp_point IS NOT NULL ) THEN
		 tmpl_02_MACD_DOWN_is_detected   := true ;
		 tmpl_02_MACD_UP_is_detected     := false ;
		 tmpl_02_MACD_timestamp_point    := ds_data.TIMESTAMP_POINT ;
                 tmpl_02_MACD_event_name         := ds_data.EVENT_NAME ;
                 tmpl_02_MACD_event_vector       := ds_data.EVENT_VECTOR ;
                 sz_msg := 'long точка вЫхода - '||TO_CHAR(tmpl_01_RSI_timestamp_point,'YYYY-MM-DD HH24:MI:SS')||' - '||tmpl_01_RSI_event_name||' --- '||TO_CHAR(tmpl_02_MACD_timestamp_point,'YYYY-MM-DD HH24:MI:SS')||' - '||tmpl_02_MACD_event_name||' - '||tmpl_02_MACD_event_vector ;	  
-- debug RAISE NOTICE 'идентифицировано заполнение шаблона % ', sz_msg ;
                 out_timestamp_point := tmpl_02_MACD_timestamp_point ;
                 if (v_rsi_time_frame in ('1M','3M','5M','10M','15M','30M') or v_macd_time_frame in ('1M','3M','5M','10M','15M','30M')) then 
		    SELECT price_close INTO in_price from crcomp_pair_ohlc_1m_history
                           where timestamp_point = in_timestamp_point and currency = v_currency and reference_currency = v_reference_currency ;
                    SELECT price_close INTO out_price from crcomp_pair_ohlc_1m_history
                           where timestamp_point = out_timestamp_point and currency = v_currency and reference_currency = v_reference_currency ;
                    SELECT min(price_low) INTO min_price from crcomp_pair_ohlc_1m_history
                           where timestamp_point >= in_timestamp_point and timestamp_point < out_timestamp_point and 
                                 currency = v_currency and reference_currency = v_reference_currency ;
                    SELECT max(price_high) INTO max_price from crcomp_pair_ohlc_1m_history
                           where timestamp_point >= in_timestamp_point and timestamp_point < out_timestamp_point and 
                                 currency = v_currency and reference_currency = v_reference_currency ;
		 else
		    SELECT price_close INTO in_price from crcomp_pair_ohlc_1h_history
                           where timestamp_point = in_timestamp_point and currency = v_currency and reference_currency = v_reference_currency ;
                    SELECT price_close INTO out_price from crcomp_pair_ohlc_1h_history
                           where timestamp_point = out_timestamp_point and currency = v_currency and reference_currency = v_reference_currency ;
                    SELECT min(price_low) INTO min_price from crcomp_pair_ohlc_1h_history
                           where timestamp_point >= in_timestamp_point and timestamp_point < out_timestamp_point and 
                                 currency = v_currency and reference_currency = v_reference_currency ;
                    SELECT max(price_high) INTO max_price from crcomp_pair_ohlc_1h_history
                           where timestamp_point >= in_timestamp_point and timestamp_point < out_timestamp_point and 
                                 currency = v_currency and reference_currency = v_reference_currency ;
                 end if ;				 
                 result_record.strategy_name      := 'RSI'||v_RSI_time_frame||'MACD'||v_MACD_time_frame ;
                 result_record.strategy_sub_name  := 'normal' ;
                 result_record.currency           := v_currency ;
                 result_record.reference_currency := v_reference_currency ;
                 result_record.vector             := 'long' ;
                 result_record.profit             := ROUND((( out_price - in_price) / (in_price / 100)),2) ;
-- если в процессе сделки есть просадка меньше лимита StopLoss - поле защищённой прибыли равно SL
                 if ( (( min_price - in_price) * 100 / in_price) < v_protected_profit ) then
		    result_record.protected_profit := v_protected_profit ;
		    else
		    result_record.protected_profit := ROUND((( out_price - in_price) * 100 / in_price),2) ;
		    end if ;
                 result_record.cn_period          := out_timestamp_point - in_timestamp_point ;
		 result_record.min_prct           := ROUND((( min_price - in_price) / (in_price / 100)),2) ;
		 if ( (( min_price - in_price) * 100 / in_price) < v_protected_profit ) then
		    result_record.prtct_min_prct     := v_protected_profit ;
		    else
		    result_record.prtct_min_prct     := ROUND((( min_price - in_price) * 100 / in_price),2) ;
		    end if ;
                 result_record.max_prct           := ROUND((( max_price - in_price) / (in_price / 100)),2) ;
                 result_record.contract_in_tp     := in_timestamp_point ;
                 result_record.contract_in_price  := in_price ;
                 result_record.contract_out_tp    := out_timestamp_point ;
                 result_record.contract_out_price := out_price ;
                 result_record.change_ts          := now() ;
                 return next result_record ;

-- debug RAISE NOTICE 'идентифицирована лонговая пара прибыль %, период %, MIN %, MAX % --- вход % (price %), выход % (price %)', 
--           ROUND((( out_price - in_price) / (in_price / 100)),2),
--   TO_CHAR((out_timestamp_point - in_timestamp_point),'MM-DD HH24:MI:SS'),
--   ROUND((( min_price - in_price) / (in_price / 100)),2),
--   ROUND((( max_price - in_price) / (in_price / 100)),2),
--   TO_CHAR(in_timestamp_point,'YYYY-MM-DD HH24:MI:SS'), in_price,
--   TO_CHAR(out_timestamp_point,'YYYY-MM-DD HH24:MI:SS'), out_price ;
                 sum_percent_clear := ROUND((( out_price - in_price) / (in_price / 100)),2) + sum_percent_clear ;
                 if (ROUND((( out_price - in_price) / (in_price / 100)),2) < SL_value) then
                    sum_percent_protected := SL_value + sum_percent_protected ;
                 else
                    sum_percent_protected := ROUND((( out_price - in_price) / (in_price / 100)),2) + sum_percent_protected ;
                    end if ;
                 cnt_contracts := cnt_contracts + 1 ;
-- сбросить все переменные для следующего поиска сделки				 
                 in_price := NULL ; out_price := NULL ; in_timestamp_point := NULL ; out_timestamp_point := NULL ;
                 tmpl_01_RSI_UP_is_detected := false ; tmpl_01_RSI_DOWN_is_detected := false ;
                 tmpl_01_RSI_timestamp_point := NULL ; tmpl_01_RSI_event_name := NULL ;
                 tmpl_02_MACD_UP_is_detected := false ; tmpl_02_MACD_DOWN_is_detected:= false ;
                 tmpl_02_MACD_timestamp_point := NULL ; tmpl_02_MACD_event_name := NULL ; tmpl_02_MACD_event_vector := NULL ;
-- debug         RAISE NOTICE 'обнулили шаблонные переменные, проверили множественность RAISE' ;
                 END IF ; -- конец обработчика выявления точки выхода
           END IF ; -- конец обработчика выявления второй переменной шаблона
       END LOOP ;
-- debug   RAISE NOTICE 'Контрактов ЛОНГ %, суммарный рост за период простой %, защищённый %, SL = %', cnt_contracts, sum_percent_clear, sum_percent_protected, SL_value ;
       RETURN ;
       END ;
$BODY$;

select * from check_strategy_RSI_MACD_long_as_table('APT', 'USDT','1H','1H','LINE','CROSS',-5) ;

select contract_in_tp, contract_out_tp, cn_period, profit, min_prct, max_prct from check_strategy_RSI_MACD_long_as_table('APT', 'USDT','1H','1H','LINE','CROSS',-5) ;
select contract_in_tp, contract_out_tp, cn_period, profit, min_prct, max_prct from check_strategy_RSI_MACD_long_as_table('APT', 'USDT','1H','1H','LINE','VECTOR') ;
select contract_in_tp, contract_out_tp, cn_period, profit, min_prct, max_prct from check_strategy_RSI_MACD_long_as_table('APT', 'USDT','1H','1H','GIST','VECTOR') ;

select contract_in_tp, contract_out_tp, cn_period, profit, min_prct, max_prct from check_strategy_RSI_MACD_long_as_table('APT', 'USDT','1H','4H','LINE','CROSS') ;
select contract_in_tp, contract_out_tp, cn_period, profit, min_prct, max_prct from check_strategy_RSI_MACD_long_as_table('APT', 'USDT','1H','4H','LINE','VECTOR') ;
select contract_in_tp, contract_out_tp, cn_period, profit, min_prct, max_prct from check_strategy_RSI_MACD_long_as_table('APT', 'USDT','1H','4H','GIST','VECTOR') ;


-- нашли ошибку в вычислении гистограмм - они не указывают направление
select timestamp_point, MACDG_state, MACDG_event_name, MACDG_event_vector
       from rtrsp_events_of_indicators 
       where currency = '1INCH' and reference_currency = 'USDT' and time_frame = '4H' and MACDG_event_name IS NOT NULL and MACDG_event_vector IS NOT NULL
--       	            AND MACDG_event_name like ''%'||v_MACD_ind_sub_type||'%''
          order by 1 asc

select * from rtrsp_events_of_indicators
         where currency = '1INCH' and reference_currency = 'USDT' and time_frame = '4H' and MACDG_event_name IS NOT NULL and MACDG_event_vector IS NOT NULL
--            AND MACDG_event_name like ''%'||v_MACD_ind_sub_type||'%''
         order by 1 asc


DROP FUNCTION check_strategy_RSI_MACD_short_as_table ;
CREATE OR REPLACE FUNCTION public.check_strategy_rsi_macd_short_as_table(
       v_currency           character varying,
       v_reference_currency character varying,
       v_rsi_time_frame     character varying,
       v_macd_time_frame    character varying,
       v_macd_ind_type      character varying,
       v_macd_ind_sub_type  character varying,
       v_protected_profit   real,
       v_is_include_RSI     boolean,
       v_start_date         character varying,
       v_stop_date          character varying)
       RETURNS SETOF rtrsp_analyze_strategy
       LANGUAGE 'plpgsql'
       AS $BODY$
       DECLARE
       result_record                       rtrsp_analyze_strategy%ROWTYPE ;
       ds_request                          VARCHAR ;
       ds_data                             RECORD ;
       sz_msg                              VARCHAR(1000) ;
       in_timestamp_point                  timestamp without time zone ;
       in_price                            NUMERIC ;
       out_timestamp_point                 timestamp without time zone ;
       out_price                           NUMERIC ;
-- переменные шаблона входа
       tmpl_01_RSI_UP_is_detected          boolean ;
       tmpl_01_RSI_DOWN_is_detected        boolean ;
       tmpl_01_RSI_timestamp_point         timestamp without time zone ;
       tmpl_01_RSI_event_name              character varying(100) ;
       tmpl_02_MACD_UP_is_detected         boolean ;
       tmpl_02_MACD_DOWN_is_detected       boolean ;
       tmpl_02_MACD_timestamp_point        timestamp without time zone ;
       tmpl_02_MACD_event_name             character varying(100) ;
       tmpl_02_MACD_event_vector           character varying(30) ;
       sum_percent_clear                   real ;
       sum_percent_protected               real ;
       SL_value                            real ;
       cnt_contracts                       int ;
       max_price                           NUMERIC ;
       min_price                           NUMERIC ;
       BEGIN
       in_timestamp_point := NULL ; out_timestamp_point := NULL ;
       tmpl_01_RSI_UP_is_detected := false ; tmpl_01_RSI_DOWN_is_detected := false ;
       tmpl_01_RSI_timestamp_point := NULL ; tmpl_01_RSI_event_name := NULL ;
       tmpl_02_MACD_UP_is_detected := false ; tmpl_02_MACD_DOWN_is_detected:= false ;
       tmpl_02_MACD_timestamp_point := NULL ; tmpl_02_MACD_event_name := NULL ; tmpl_02_MACD_event_vector := NULL ;
       sum_percent_clear := 0 ; sum_percent_protected := 0 ; SL_value = -2 ; cnt_contracts := 0 ;
       if (v_MACD_ind_type = 'LINE') then -- используется и тут, и в формировании имени события при проверках ниже
          ds_request := 'select timestamp_point, RSI_state IND_STATE, RSI_event_name EVENT_NAME, RSI_event_vector EVENT_VECTOR 
                                from rtrsp_events_of_indicators
                                where currency = $1 and reference_currency = $2 and time_frame = $3 and RSI_event_name IS NOT NULL 
				      AND RSI_event_vector IS NOT NULL AND NOT RSI_event_name LIKE ''RSI_1H_CLEAR%''
                                      AND timestamp_point >= TO_TIMESTAMP('''||v_start_date||''',''YYYY-MM-DD HH24:MI:SS'')
				      AND timestamp_point <= TO_TIMESTAMP('''||v_stop_date||''',''YYYY-MM-DD HH24:MI:SS'')
                          union all
                          select timestamp_point, MACDL_state, MACDL_event_name, MACDL_event_vector 
                                 from rtrsp_events_of_indicators 
                                 where currency = $1 and reference_currency = $2 and time_frame = $4 and MACDL_event_name IS NOT NULL 
				       AND MACDL_event_vector IS NOT NULL AND MACDL_event_name like ''%'||v_MACD_ind_sub_type||'%''
                                       AND timestamp_point >= TO_TIMESTAMP('''||v_start_date||''',''YYYY-MM-DD HH24:MI:SS'')
                                       AND timestamp_point <= TO_TIMESTAMP('''||v_stop_date||''',''YYYY-MM-DD HH24:MI:SS'')
                          order by 1 asc' ;
       end if ;
       if (v_MACD_ind_type = 'GIST') then -- используется и тут, и в формировании имени события при проверках ниже
          ds_request := 'select timestamp_point, RSI_state IND_STATE, RSI_event_name EVENT_NAME, RSI_event_vector EVENT_VECTOR 
                                from rtrsp_events_of_indicators
                                where currency = $1 and reference_currency = $2 and time_frame = $3 and RSI_event_name IS NOT NULL 
				      AND RSI_event_vector IS NOT NULL AND NOT RSI_event_name LIKE ''RSI_1H_CLEAR%''
                                      AND timestamp_point >= TO_TIMESTAMP('''||v_start_date||''',''YYYY-MM-DD HH24:MI:SS'')
				      AND timestamp_point <= TO_TIMESTAMP('''||v_stop_date||''',''YYYY-MM-DD HH24:MI:SS'')
                                union all
                                select timestamp_point, MACDG_state, MACDG_event_name, MACDG_event_vector 
                                       from rtrsp_events_of_indicators 
                                       where currency = $1 and reference_currency = $2 and time_frame = $4 and MACDG_event_name IS NOT NULL 
				             AND MACDG_event_vector IS NOT NULL AND MACDG_event_name like ''%'||v_MACD_ind_sub_type||'%''
                                      AND timestamp_point >= TO_TIMESTAMP('''||v_start_date||''',''YYYY-MM-DD HH24:MI:SS'')
				      AND timestamp_point <= TO_TIMESTAMP('''||v_stop_date||''',''YYYY-MM-DD HH24:MI:SS'')
                                order by 1 asc' ;
       end if ;
-- debug RAISE NOTICE 'request %', ds_request ;
-- идём по упорядоченному списку событий
-- ищем вхождения шаблонных событий, тут они на вход и выход одинаковые
-- после выявления первого ловим второе
-- как поймали второе - внутри его обработчика проверяем, это события входа или выхода. Потом сбрасываем переменные шаблона
-- но при этом выход не инициализируем, если не было входа
       FOR ds_data IN EXECUTE ds_request USING v_currency, v_reference_currency, v_RSI_time_frame, v_MACD_time_frame LOOP
           IF ( ds_data.EVENT_NAME = 'RSI_'||v_RSI_time_frame||'_UP_CROSS_70' and tmpl_01_RSI_UP_is_detected = false ) THEN
              tmpl_01_RSI_UP_is_detected   := true ;
              tmpl_01_RSI_DOWN_is_detected := false ;
              tmpl_01_RSI_timestamp_point  := ds_data.TIMESTAMP_POINT ;
              tmpl_01_RSI_event_name       := ds_data.EVENT_NAME ;
              END IF ;
           IF ( ds_data.EVENT_NAME = 'RSI_'||v_RSI_time_frame||'_DOWN_CROSS_30' and tmpl_01_RSI_DOWN_is_detected = false ) THEN
              tmpl_01_RSI_DOWN_is_detected := true ;
              tmpl_01_RSI_UP_is_detected   := false ;
              tmpl_01_RSI_timestamp_point  := ds_data.TIMESTAMP_POINT ;
              tmpl_01_RSI_event_name       := ds_data.EVENT_NAME ;
             END IF ;
              
           IF ( ds_data.EVENT_NAME = 'MACD_'||v_MACD_time_frame||'_'||v_MACD_ind_type||'_'||v_MACD_ind_sub_type ) THEN
-- при выявлении второго события шаблона проверить - заполнен ли шаблон
              IF ( tmpl_01_RSI_event_name = 'RSI_'||v_RSI_time_frame||'_UP_CROSS_70'
                   and ds_data.EVENT_NAME = 'MACD_'||v_MACD_time_frame||'_'||v_MACD_ind_type||'_'||v_MACD_ind_sub_type
                   and ds_data.EVENT_VECTOR = 'DOWN'
                   and tmpl_02_MACD_DOWN_is_detected = false
                 ) THEN
                 tmpl_02_MACD_DOWN_is_detected := true ;
                 tmpl_02_MACD_UP_is_detected   := false ;
                 tmpl_02_MACD_timestamp_point  := ds_data.TIMESTAMP_POINT ;
                 tmpl_02_MACD_event_name       := ds_data.EVENT_NAME ;
                 tmpl_02_MACD_event_vector     := ds_data.EVENT_VECTOR ;
                 sz_msg := 'short точка входа - '||TO_CHAR(tmpl_01_RSI_timestamp_point,'YYYY-MM-DD HH24:MI:SS')||' - '||tmpl_01_RSI_event_name||' --- '||TO_CHAR(tmpl_02_MACD_timestamp_point,'YYYY-MM-DD HH24:MI:SS')||' - '||tmpl_02_MACD_event_name||' - '||tmpl_02_MACD_event_vector ;
-- debug RAISE NOTICE 'идентифицировано заполнение шаблона % ', sz_msg ;
                 in_timestamp_point := tmpl_02_MACD_timestamp_point ;
                 END IF ;
-- для точки вЫхода - проверяем ещё, что взведена точка входа, тогда записываем выход, сбрасываем переменные шаблона, печатаем выход, сбрасываем даты точки
              IF ( tmpl_01_RSI_event_name = 'RSI_'||v_RSI_time_frame||'_DOWN_CROSS_30'
                   and ds_data.EVENT_NAME = 'MACD_'||v_MACD_time_frame||'_'||v_MACD_ind_type||'_'||v_MACD_ind_sub_type
                   and ds_data.EVENT_VECTOR = 'UP'
                   and tmpl_02_MACD_UP_is_detected = false
                   and in_timestamp_point IS NOT NULL ) THEN
                 tmpl_02_MACD_UP_is_detected   := true ;
                 tmpl_02_MACD_DOWN_is_detected := false ;
                 tmpl_02_MACD_timestamp_point  := ds_data.TIMESTAMP_POINT ;
                 tmpl_02_MACD_event_name       := ds_data.EVENT_NAME ;
                 tmpl_02_MACD_event_vector     := ds_data.EVENT_VECTOR ;
                 sz_msg := 'short точка выхода - '||TO_CHAR(tmpl_01_RSI_timestamp_point,'YYYY-MM-DD HH24:MI:SS')||' - '||tmpl_01_RSI_event_name||' --- '||TO_CHAR(tmpl_02_MACD_timestamp_point,'YYYY-MM-DD HH24:MI:SS')||' - '||tmpl_02_MACD_event_name||' - '||tmpl_02_MACD_event_vector ;
-- debug RAISE NOTICE 'идентифицировано заполнение шаблона % ', sz_msg ;
                 out_timestamp_point := tmpl_02_MACD_timestamp_point ;
                 if (v_rsi_time_frame in ('1M','3M','5M','10M','15M','30M') or v_macd_time_frame in ('1M','3M','5M','10M','15M','30M')) then
                    SELECT price_close INTO in_price from crcomp_pair_ohlc_1m_history
                           where timestamp_point = in_timestamp_point and currency = v_currency and reference_currency = v_reference_currency ;
                    SELECT price_close INTO out_price from crcomp_pair_ohlc_1m_history
                           where timestamp_point = out_timestamp_point and currency = v_currency and reference_currency = v_reference_currency ;
-- здесь максимальная цена на падении высчитывается из минимума, а минимальная из максимума                                             
                    SELECT min(price_low) INTO max_price from crcomp_pair_ohlc_1m_history
                           where timestamp_point >= in_timestamp_point and timestamp_point < out_timestamp_point and
                                 currency = v_currency and reference_currency = v_reference_currency ;
                    SELECT max(price_high) INTO min_price from crcomp_pair_ohlc_1m_history
                           where timestamp_point >= in_timestamp_point and timestamp_point < out_timestamp_point and
                                 currency = v_currency and reference_currency = v_reference_currency ;
                 else
                    SELECT price_close INTO in_price from crcomp_pair_ohlc_1h_history
                           where timestamp_point = in_timestamp_point and currency = v_currency and reference_currency = v_reference_currency ;
                    SELECT price_close INTO out_price from crcomp_pair_ohlc_1h_history
                           where timestamp_point = out_timestamp_point and currency = v_currency and reference_currency = v_reference_currency ;
-- здесь максимальная цена на падении высчитывается из минимума, а минимальная из максимума                                             
                    SELECT min(price_low) INTO max_price from crcomp_pair_ohlc_1h_history
                           where timestamp_point >= in_timestamp_point and timestamp_point < out_timestamp_point and
                                 currency = v_currency and reference_currency = v_reference_currency ;
                    SELECT max(price_high) INTO min_price from crcomp_pair_ohlc_1h_history
                           where timestamp_point >= in_timestamp_point and timestamp_point < out_timestamp_point and
                                 currency = v_currency and reference_currency = v_reference_currency ;
                 end if ;
                 result_record.strategy_name      := 'RSI'||v_RSI_time_frame||'MACD'||v_MACD_time_frame ;
                 result_record.strategy_sub_name  := 'normal' ;
                 result_record.currency           := v_currency ;
                 result_record.reference_currency := v_reference_currency ;
                 result_record.vector             := 'short' ;
                 result_record.profit             := ROUND((( out_price - in_price) * -1 / (in_price / 100)),2) ;
-- если в процессе сделки есть просадка меньше лимита StopLoss - поле защищённой прибыли равно SL                                
                 if ( ( ( min_price - in_price) * -100 / in_price) < v_protected_profit ) then
                    result_record.protected_profit := v_protected_profit ;
                    else
                    result_record.protected_profit := ROUND((( out_price - in_price) * -100 / in_price),2) ;
                    end if ;
                 result_record.cn_period          := out_timestamp_point - in_timestamp_point ;
                 result_record.min_prct           := ROUND((( in_price - min_price) / (in_price / 100)),2) ;
                 if ( (( min_price - in_price) * -100 / in_price ) < v_protected_profit ) then
                    result_record.prtct_min_prct     := v_protected_profit ;
                    else
                    result_record.prtct_min_prct     := ROUND( ((min_price - in_price) * -100 / in_price),2) ;
                    end if ;
                 result_record.max_prct           := ROUND((( in_price - max_price) / (in_price / 100)),2) ;
                 result_record.contract_in_tp     := in_timestamp_point ;
                 result_record.contract_in_price  := in_price ;
                 result_record.contract_out_tp    := out_timestamp_point ;
                 result_record.contract_out_price := out_price ;
                 result_record.change_ts          := now() ;
                 return next result_record ;
                 
-- debug              RAISE NOTICE 'идентифицирована шортовая пара, прибыль %, период %, MIN %, MAX %  --- вход % (price %), выход % (price %)', 
--           ROUND((( out_price - in_price) * -1 / (in_price / 100)),2),
--   TO_CHAR((out_timestamp_point - in_timestamp_point),'MM-DD HH24:MI:SS'),
--   ROUND((( in_price - min_price) / (in_price / 100)),2),
--   ROUND((( in_price - max_price) / (in_price / 100)),2),
--   TO_CHAR(in_timestamp_point,'YYYY-MM-DD HH24:MI:SS'), in_price,
--   TO_CHAR(out_timestamp_point,'YYYY-MM-DD HH24:MI:SS'), out_price ;
                 sum_percent_clear := ROUND((( out_price - in_price) * -1 / (in_price / 100)),2) + sum_percent_clear ;
                 if (ROUND((( out_price - in_price) * -1 / (in_price / 100)),2) < SL_value) then
                    sum_percent_protected := SL_value + sum_percent_protected ;
                    else
                    sum_percent_protected := ROUND((( out_price - in_price) * -1 / (in_price / 100)),2) + sum_percent_protected ;
                    end if ;
                 cnt_contracts := cnt_contracts + 1 ;
                 in_price := NULL ; out_price := NULL ; in_timestamp_point := NULL ; out_timestamp_point := NULL ;
                 tmpl_01_RSI_UP_is_detected := false ; tmpl_01_RSI_DOWN_is_detected := false ;
                 tmpl_01_RSI_timestamp_point := NULL ; tmpl_01_RSI_event_name := NULL ;
                 tmpl_02_MACD_UP_is_detected := false ; tmpl_02_MACD_DOWN_is_detected:= false ;
                 tmpl_02_MACD_timestamp_point := NULL ; tmpl_02_MACD_event_name := NULL ; tmpl_02_MACD_event_vector := NULL ;
-- debug         RAISE NOTICE 'обнулили шаблонные переменные, проверили множественность RAISE' ;
                     END IF ; -- конец обработчика выявления точки выхода
                  END IF ; -- конец обработчика выявления второй переменной шаблона
       END LOOP ;
-- debug   RAISE NOTICE 'Контрактов ШОРТ %, суммарный рост за период простой %, защищённый %, SL = %', cnt_contracts, sum_percent_clear, sum_percent_protected, SL_value ;
       RETURN ;
       END ;
$BODY$;

select * from check_strategy_RSI_MACD_short_as_table('1INCH', 'USDT','1H','1H','LINE','VECTOR',-5,true,'2023-07-01 00:00:00'.'2033-07-01 00:00:00') ;

select profit, cn_period, min_prct, max_prct from check_strategy_RSI_MACD_short_as_table('1INCH', 'USDT','1D','1D','LINE','VECTOR') ;

select profit, cn_period, min_prct, max_prct from check_strategy_RSI_MACD_short_as_table('1INCH', 'USDT','1H','1H','LINE','CROSS') ;
select profit, cn_period, min_prct, max_prct from check_strategy_RSI_MACD_short_as_table('1INCH', 'USDT','1H','4H','LINE','VECTOR') ;
select profit, cn_period, min_prct, max_prct from check_strategy_RSI_MACD_short_as_table('1INCH', 'USDT','1H','4H','GIST','VECTOR') ;

select * from check_strategy_RSI_MACD_short_as_table('1INCH', 'USDT','1H','4H','LINE','CROSS') ;

-- -----------------------------------------
-- первая проба запросов до драйвера
-- выбираем все сделки, и лонг и шорт
-- -----------------------------------------
-- для пересечения линий MACD
select src1.* from (select contract_in_tp, vector, profit, cn_period, min_prct, max_prct from check_strategy_RSI1H_MACD4H_long_as_table('1INCH', 'USDT','1H','1H','LINE','CROSS')
union all
select contract_in_tp, vector, profit, cn_period, min_prct, max_prct from check_strategy_RSI1H_MACD4H_short_as_table('1INCH', 'USDT','1H','1H','LINE','CROSS')) src1
where min_prct > -50
order by src1.contract_in_tp asc ;
-- для смены направлений линий MACD
select src1.* from (select contract_in_tp, vector, profit, cn_period, min_prct, max_prct from check_strategy_RSI1H_MACD4H_long_as_table('1INCH', 'USDT','1H','1H','LINE','CROSS')
union all
select contract_in_tp, vector, profit, cn_period, min_prct, max_prct from check_strategy_RSI1H_MACD4H_short_as_table('1INCH', 'USDT','1H','1H','LINE','CROSS')) src1
where min_prct > -50
order by src1.contract_in_tp asc ;
-- для гистограммы
select src1.* from (select contract_in_tp, vector, profit, cn_period, min_prct, max_prct from check_strategy_RSI1H_MACD4H_long_as_table('1INCH', 'USDT','1H','1H','GIST','VECTOR')
union all
select contract_in_tp, vector, profit, cn_period, min_prct, max_prct from check_strategy_RSI1H_MACD4H_short_as_table('1INCH', 'USDT','1H','1H','GIST','VECTOR')) src1
where min_prct > -50
order by src1.contract_in_tp asc ;


-- а теперь - суммируем результат, и отбрасываем выбранный нами процент просадки
-- для пересечения линий
select count(*), sum(src1.profit) from (select contract_in_tp, vector, profit, cn_period, min_prct, max_prct from check_strategy_RSI1H_MACD4H_long_as_table('1INCH', 'USDT','1H','4H','LINE','CROSS')
union all
select contract_in_tp, vector, profit, cn_period, min_prct, max_prct from check_strategy_RSI1H_MACD4H_short_as_table('1INCH', 'USDT','1H','4H','LINE','CROSS')) src1
where min_prct > -10 ;
-- для изменения направления линий
select count(*), sum(src1.profit) from (select contract_in_tp, vector, profit, cn_period, min_prct, max_prct from check_strategy_RSI1H_MACD4H_long_as_table('1INCH', 'USDT','1H','4H','LINE','VECTOR')
union all
select contract_in_tp, vector, profit, cn_period, min_prct, max_prct from check_strategy_RSI1H_MACD4H_short_as_table('1INCH', 'USDT','1H','4H','LINE','VECTOR')) src1
where min_prct > -10 ;
-- для изменения направления гистограммы
select count(*), sum(src1.profit) from (select contract_in_tp, vector, profit, cn_period, min_prct, max_prct from check_strategy_RSI1H_MACD4H_long_as_table('1INCH', 'USDT','1H','4H','GIST','VECTOR')
union all
select contract_in_tp, vector, profit, cn_period, min_prct, max_prct from check_strategy_RSI1H_MACD4H_short_as_table('1INCH', 'USDT','1H','4H','GIST','VECTOR')) src1
where min_prct > -10 ;

select count(*) from (
select contract_in_tp, vector, profit, cn_period, min_prct, max_prct from check_strategy_RSI_MACD_long_as_table('1INCH', 'USDT','1H','1H','LINE','CROSS')
union all
select contract_in_tp, vector, profit, cn_period, min_prct, max_prct from check_strategy_RSI1H_MACD4H_short_as_table('1INCH', 'USDT','1H','1H','LINE','CROSS')) src1
where not min_prct > -10 ;

-- -----------------------------------------
-- запрос и драйвер
-- -----------------------------------------

select count(*), sum(src1.profit)
       from (select contract_in_tp, vector, profit, cn_period, min_prct, max_prct
                    from check_strategy_RSI_MACD_long_as_table('1INCH', 'USDT','1H','4H','LINE','CROSS')
            union all
            select contract_in_tp, vector, profit, cn_period, min_prct, max_prct 
                   from check_strategy_RSI_MACD_short_as_table('1INCH', 'USDT','1H','4H','LINE','CROSS')) src1
where min_prct > -10 ;

DROP FUNCTION public.fn_rtsp_driver_strategy_RSI_MACD
CREATE OR REPLACE FUNCTION public.fn_rtsp_driver_strategy_rsi_macd(
       v_currency           character varying,
       v_reference_currency character varying,
       v_rsi_time_frame     character varying,
       v_macd_time_frame    character varying,
       v_macd_ind_type      character varying,
       v_macd_ind_sub_type  character varying,
       v_vector_type        character varying,
       v_protected_profit   real,
       v_is_include_RSI     boolean,
       v_start_date         character varying,
       v_stop_date          character varying)
       RETURNS SETOF rtrsp_analyze_strategy_argegate 
       LANGUAGE 'plpgsql'
       AS $BODY$
       DECLARE
       result_record             rtrsp_analyze_strategy_argegate%ROWTYPE ;
       sz_msg                    VARCHAR ;
       rec_result_stat           RECORD ;
       sz_request_stat           VARCHAR ;
       sz_currency_pairs_request VARCHAR ;
       rec_currency_pairs_list   RECORD ;
       err_text_var1             text ;
       err_text_var2             text ;
       err_text_var3             text ;
       BEGIN
       if (v_currency = 'ALL' or v_currency = '') then
          if (v_reference_currency = 'ALL' or v_reference_currency = '') then
             sz_currency_pairs_request = 'select currency, reference_currency from rtrsp_processed_coin_pairs group by currency, reference_currency order by 1, 2' ;
             else
             sz_currency_pairs_request = 'select currency, reference_currency from rtrsp_processed_coin_pairs where reference_currency = '''||v_reference_currency||''' group by currency, reference_currency order by 1, 2' ;
             end if ;
          else
          if (v_reference_currency = 'ALL' or v_reference_currency = '') then
             sz_currency_pairs_request = 'select currency, reference_currency from rtrsp_processed_coin_pairs where currency = '''||v_currency||''' group by currency, reference_currency order by 1, 2' ;
             else
             sz_currency_pairs_request = 'select currency, reference_currency from rtrsp_processed_coin_pairs where currency = '''||v_currency||''' AND reference_currency = '''||v_reference_currency||''' group by currency, reference_currency order by 1, 2' ;
             end if ;
          end if ;
       FOR rec_currency_pairs_list IN EXECUTE sz_currency_pairs_request LOOP
           sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||', RSI ТФ'||v_RSI_time_frame||', MACD ТФ '||v_MACD_time_frame||', старт расчёта статистик стратегии' ;
-- debug RAISE NOTICE '%', sz_msg ;
           if (v_vector_type = 'all') then
              sz_request_stat := 'select sum(cnt_all) cnt_all, sum(cnt_pos) cnt_pos, sum(cnt_neg) cnt_neg, sum(src1.profit) profit,
	                                 sum(src1.protected_profit) protected_profit,
                                         min(min_prct) min_min_prct, avg(min_prct) avg_min_prct, max(max_prct) max_max_prct, avg(max_prct) avg_max_prct,
					 min(prtct_min_prct) prtct_min_min_prct, avg(prtct_min_prct) prtct_avg_min_prct,
                                         min(contract_in_tp) start_period, max(contract_out_tp) stop_period
                                         from (select contract_in_tp, contract_out_tp, vector, profit, protected_profit, cn_period, min_prct, prtct_min_prct, max_prct, 1 cnt_all, 
                                                      CASE WHEN profit > 0 THEN 1 ELSE 0 END cnt_pos, CASE WHEN profit <= 0 THEN 1 ELSE 0 END cnt_neg
                                                      from check_strategy_RSI_MACD_long_as_table($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
                                               union all
                                               select contract_in_tp, contract_out_tp, vector, profit, protected_profit, cn_period, min_prct, prtct_min_prct, max_prct, 1 cnt_all,
                                                      CASE WHEN profit > 0 THEN 1 ELSE 0 END cnt_pos, CASE WHEN profit <= 0 THEN 1 ELSE 0 END cnt_neg
                                                      from check_strategy_RSI_MACD_short_as_table($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)) src1' ;
              end if  ;

           if (v_vector_type = 'long') then
              sz_request_stat := 'select sum(cnt_all) cnt_all, sum(cnt_pos) cnt_pos, sum(cnt_neg) cnt_neg, sum(src1.profit) profit,
	                                 sum(src1.protected_profit) protected_profit,
                                         min(min_prct) min_min_prct, avg(min_prct) avg_min_prct, max(max_prct) max_max_prct, avg(max_prct) avg_max_prct,
					 min(prtct_min_prct) prtct_min_min_prct, avg(prtct_min_prct) prtct_avg_min_prct,
                                         min(contract_in_tp) start_period, max(contract_out_tp) stop_period
                                         from (select contract_in_tp, contract_out_tp, vector, profit, protected_profit, cn_period, min_prct, prtct_min_prct, max_prct, 1 cnt_all,
                                                      CASE WHEN profit > 0 THEN 1 ELSE 0 END cnt_pos, CASE WHEN profit <= 0 THEN 1 ELSE 0 END cnt_neg
                                                      from check_strategy_RSI_MACD_long_as_table($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)) src1' ;
              end if ;

           if (v_vector_type = 'short') then
              sz_request_stat := 'select sum(cnt_all) cnt_all, sum(cnt_pos) cnt_pos, sum(cnt_neg) cnt_neg, sum(src1.profit) profit,
	                                 sum(src1.protected_profit) protected_profit,
                                         min(min_prct) min_min_prct, avg(min_prct) avg_min_prct, max(max_prct) max_max_prct, avg(max_prct) avg_max_prct,
					 min(prtct_min_prct) prtct_min_min_prct, avg(prtct_min_prct) prtct_avg_min_prct, 
					 min(contract_in_tp) start_period, max(contract_out_tp) stop_period
                                         from (select contract_in_tp, contract_out_tp, vector, profit, protected_profit, cn_period, min_prct, prtct_min_prct, max_prct, 1 cnt_all,
                                                      CASE WHEN profit > 0 THEN 1 ELSE 0 END cnt_pos, CASE WHEN profit <= 0 THEN 1 ELSE 0 END cnt_neg
                                                      from check_strategy_RSI_MACD_short_as_table($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)) src1' ;
              end if ;

-- RAISE NOTICE '%', sz_request_stat ;
           FOR rec_result_stat IN EXECUTE sz_request_stat USING 
	   rec_currency_pairs_list.currency, rec_currency_pairs_list.reference_currency, v_RSI_time_frame, v_MACD_time_frame, v_MACD_ind_type, v_MACD_ind_sub_type, v_protected_profit, v_is_include_RSI, v_start_date, v_stop_date LOOP
               result_record.strategy_name      := 'RSI_'||v_RSI_time_frame||'_MACD_'||v_MACD_time_frame||'_'||v_MACD_ind_type||'_'||v_MACD_ind_sub_type ;
               result_record.strategy_sub_name  := 'normal' ;
               result_record.currency           := rec_currency_pairs_list.currency ;
               result_record.reference_currency := rec_currency_pairs_list.reference_currency ;
               result_record.vector_type        := v_vector_type ;
               result_record.profit             := round(rec_result_stat.profit::numeric, 2) ;
	       result_record.protected_profit   := round(rec_result_stat.protected_profit::numeric, 2) ;
               result_record.count_all          := rec_result_stat.cnt_all ;
               result_record.prct_count_pos     := round(rec_result_stat.cnt_pos * 100 / rec_result_stat.cnt_all, 2 ) ;
               result_record.prct_count_neg     := round(rec_result_stat.cnt_neg * 100 / rec_result_stat.cnt_all, 2 ) ;
               result_record.min_min_prct       := round(rec_result_stat.min_min_prct::numeric, 2) ;
               result_record.avg_min_prct       := round(rec_result_stat.avg_min_prct::numeric, 2) ;
               result_record.max_max_prct       := round(rec_result_stat.max_max_prct::numeric, 2) ;
               result_record.avg_max_prct       := round(rec_result_stat.avg_max_prct::numeric, 2) ;
	       result_record.prtct_min_min_prct := round(rec_result_stat.prtct_min_min_prct::numeric, 2) ;
               result_record.prtct_avg_min_prct := round(rec_result_stat.prtct_avg_min_prct::numeric, 2) ;
               result_record.start_period       := rec_result_stat.start_period ;
               result_record.stop_period        := rec_result_stat.stop_period ;
               result_record.change_ts          := now() ;

-- debug RAISE NOTICE 'currency %, ref_curr %, count %, profit %, prct_pos_cntr %, prct_neg_cntr %, min_min %, avg_min %, max_max %, avg_max %', 
--         rec_currency_pairs_list.currency, v_reference_currency, rec_result_stat.cnt_all, rec_result_stat.profit,
--         round(rec_result_stat.cnt_pos * 100 / rec_result_stat.cnt_all, 2 ), round(rec_result_stat.cnt_neg * 100 / rec_result_stat.cnt_all, 2 ),
--         round(rec_result_stat.min_min_prct::numeric, 2), round(rec_result_stat.avg_min_prct::numeric, 2),
--         round(rec_result_stat.max_max_prct::numeric, 2), round(rec_result_stat.avg_max_prct::numeric, 2) ;
               RETURN NEXT result_record ;
               END LOOP ;
           END LOOP ;
       RETURN ;
       END ;
$BODY$;

-- вытаскиваем разные индикаторы рядом
select * from  fn_rtsp_driver_strategy_RSI_MACD('', '', '1H', '4H', 'LINE', 'CROSS', 'all')
UNION ALL
select * from  fn_rtsp_driver_strategy_RSI_MACD('', 'USDT', '1H', '4H', 'LINE', 'VECTOR', 'all')
UNION ALL
select * from  fn_rtsp_driver_strategy_RSI_MACD('', 'USDT', '1H', '4H', 'GIST', 'VECTOR', 'all')
UNION ALL
select * from  fn_rtsp_driver_strategy_RSI_MACD('', 'USDT', '1H', '1H', 'LINE', 'CROSS', 'all')
UNION ALL
select * from  fn_rtsp_driver_strategy_RSI_MACD('', 'USDT', '1H', '1H', 'LINE', 'VECTOR', 'all')
UNION ALL
select * from  fn_rtsp_driver_strategy_RSI_MACD('', 'USDT', '1H', '1H', 'GIST', 'VECTOR', 'all')
order by profit desc, currency, strategy_name ;

select * from  fn_rtsp_driver_strategy_RSI_MACD('', 'USDT', '1H', '4H', 'GIST', 'VECTOR', 'all')
UNION ALL
select * from  fn_rtsp_driver_strategy_RSI_MACD('', 'USDT', '1H', '1H', 'GIST', 'VECTOR', 'all')
order by profit desc, currency, strategy_name ;

select *, extract(day from stop_period - start_period) int_period, 
round((profit / extract(day from stop_period - start_period)*30)::numeric,2) profit_per_month 

from fn_rtsp_driver_strategy_RSI_MACD('PEPE','USDT','1H', '1H', 'LINE', 'CROSS', 'all', -5) UNION ALL 


select *, extract(day from stop_period - start_period) int_period, 
round((profit / extract(day from stop_period - start_period)*30)::numeric,2) profit_per_month from fn_rtsp_driver_strategy_RSI_MACD('PEPE','USDT','1H', '1H', 'LINE', 'CROSS', 'all', -5) UNION ALL select *, extract(day from stop_period - start_period) int_period, round((profit / extract(day from stop_period - start_period)*30)::numeric,2) profit_per_month, round((protected_profit / extract(day from stop_period - start_period)*30)::numeric,2) prtct_profit_per_month from fn_rtsp_driver_strategy_RSI_MACD('PEPE','USDT','1H', '1H', 'LINE', 'VECTOR', 'all', -5) UNION ALL select *, extract(day from stop_period - start_period) int_period, round((profit / extract(day from stop_period - start_period)*30)::numeric,2) profit_per_month, round((protected_profit / extract(day from stop_period - start_period)*30)::numeric,2) prtct_profit_per_month from fn_rtsp_driver_strategy_RSI_MACD('PEPE','USDT','1H', '1H', 'GIST', 'VECTOR', 'all', -5) order by profit_per_month desc, profit desc, currency, strategy_name ; 

-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.18 конец -- таблицы и функции заполнения ретроспективной стратегии RSI1H_MACD4H
-- ---------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.19 начало -- таблицы и функции заполнения ретроспективной стратегии RSI+MACD+EMA+EMAst
-- ---------------------------------------------------------------------------------------------------------------------------
-- версия v.0.31 от 20241030_01 - добавлено отключение RSI
-- версия v.0.31 от 20241031_01 - добавлены функции стратегии RSI+MACD+EMA+EMAst
select * from cragran_logs order by timestamp_point desc limit 1000 ;

-- чтобы каждый раз не выбирать уникальные пары из больших выборок, это делается заранее
-- изменения потребуются только при появлении новых пар или выводе старых
CREATE TABLE rtrsp_processed_coin_pairs(
       currency           character varying(100) NOT NULL,
       reference_currency character varying(100) NOT NULL,
       CONSTRAINT rtrsp_processed_coin_pairs_pkey
                  PRIMARY KEY (currency, reference_currency)
       ) ;

insert into rtrsp_processed_coin_pairs 
       select currency, reference_currency
              from (select currency, reference_currency from crcomp_pair_ohlc_1m_history group by currency, reference_currency
                   union all
                   select currency, reference_currency from crcomp_pair_ohlc_1h_history group by currency, reference_currency
                   union all
                   select currency, reference_currency from crcomp_pair_ohlc_1d_history group by currency, reference_currency) src
                   group by currency, reference_currency order by 1, 2 ;


DROP TABLE rtrsp_analyze_strategy CASCADE ;
CREATE TABLE rtrsp_analyze_strategy(
       strategy_name      character varying(100) NOT NULL,
       strategy_sub_name  character varying(100) NOT NULL,
       currency           character varying(100) NOT NULL,
       reference_currency character varying(100) NOT NULL,
       vector             character varying(10),
       profit             REAL,
       protected_profit   REAL,
       cn_period          INTERVAL,
       min_prct           REAL,
       prtct_min_prct     REAL,
       max_prct           REAL,
       contract_in_tp     timestamp without time zone,
       contract_in_price  NUMERIC(42,21),
       contract_out_tp    timestamp without time zone,
       contract_out_price NUMERIC(42,21),
       change_ts timestamp without time zone,
       CONSTRAINT rtrsp_analyze_strategy_pkey
                  PRIMARY KEY (strategy_name, strategy_sub_name, currency, reference_currency)
       ) ;

DROP TABLE rtrsp_analyze_strategy_argegate CASCADE ;
CREATE TABLE rtrsp_analyze_strategy_argegate(
       strategy_name      character varying(100),
       strategy_sub_name  character varying(100),
       currency           character varying(100),
       reference_currency character varying(100),
       vector_type        character varying(10),
       profit             REAL,
	   protected_profit   REAL,
       count_all          INT,
       prct_count_pos     REAL,
       prct_count_neg     REAL,
       min_min_prct       REAL,
       avg_min_prct       REAL,
       max_max_prct       REAL,
       avg_max_prct       REAL,
       prtct_min_min_prct REAL,
       prtct_avg_min_prct REAL,
       start_period       timestamp without time zone,
       stop_period        timestamp without time zone,
       change_ts timestamp without time zone
       ) ;

-- обработчик второй стратегии RSI_MACD_EMAs
DROP FUNCTION check_strategy_RSI_MACD_EMA_long_as_table ;
CREATE OR REPLACE FUNCTION public.check_strategy_rsi_macd_ema_long_as_table(
       v_currency               character varying,
       v_reference_currency     character varying,
       v_rsi_time_frame         character varying,
       v_macd_time_frame        character varying,
       v_macd_ind_type          character varying,
       v_macd_ind_sub_type      character varying,
       v_protected_profit       real,
       v_is_include_rsi         boolean,
       v_start_date             character varying,
       v_stop_date              character varying,
       v_is_include_current_ema boolean,
       v_is_include_parent_ema  boolean)
       RETURNS SETOF rtrsp_analyze_strategy
       LANGUAGE 'plpgsql'
AS $BODY$
       DECLARE
       result_record            rtrsp_analyze_strategy%ROWTYPE ;
       ds_request               VARCHAR ;
       ds_data                  RECORD ;
       sz_msg                   VARCHAR(1000) ;
       in_timestamp_point timestamp without time zone ; in_price NUMERIC ; 
       out_timestamp_point timestamp without time zone ; out_price NUMERIC ; 
-- переменные шаблона входа
       tmpl_in_EMA01_is_detected boolean ; tmpl_in_EMA01_timestamp_point timestamp without time zone ; tmpl_in_EMA01_event_name character varying(100) ; tmpl_in_EMA01_event_vector character varying(30) ;
       tmpl_in_EMA03_is_detected boolean ; tmpl_in_EMA03_timestamp_point timestamp without time zone ; tmpl_in_EMA03_event_name character varying(100) ; tmpl_in_EMA03_event_vector character varying(30) ;
       tmpl_in_RSI_DOWN_is_detected boolean ; tmpl_in_RSI_DOWN_timestamp_point timestamp without time zone ; tmpl_in_RSI_DOWN_event_name character varying(100) ; tmpl_in_RSI_DOWN_event_vector character varying(30) ;
       tmpl_in_MACD_UP_is_detected boolean ; tmpl_in_MACD_UP_timestamp_point timestamp without time zone ; tmpl_in_MACD_UP_event_name character varying(100) ; tmpl_in_MACD_UP_event_vector character varying(30) ;
       tmpl_out_EMA01_is_detected boolean ; tmpl_out_EMA01_timestamp_point timestamp without time zone ; tmpl_out_EMA01_event_name character varying(100) ; tmpl_out_EMA01_event_vector character varying(30) ;
       tmpl_out_EMA03_is_detected boolean ; tmpl_out_EMA03_timestamp_point timestamp without time zone ; tmpl_out_EMA03_event_name character varying(100) ; tmpl_out_EMA03_event_vector character varying(30) ;
       tmpl_out_RSI_UP_is_detected boolean ; tmpl_out_RSI_UP_timestamp_point timestamp without time zone ; tmpl_out_RSI_UP_event_name character varying(100) ; tmpl_out_RSI_UP_event_vector character varying(30) ;
       tmpl_out_MACD_DOWN_is_detected boolean ; tmpl_out_MACD_DOWN_timestamp_point timestamp without time zone ; tmpl_out_MACD_DOWN_event_name character varying(100) ; tmpl_out_MACD_DOWN_event_vector character varying(30) ;
       sum_percent_clear real ; sum_percent_protected real ; cnt_contracts int ; max_price NUMERIC ; min_price NUMERIC ; 
       BEGIN
       in_timestamp_point := NULL ; out_timestamp_point := NULL ; in_price := NULL ; out_price := NULL ;
       tmpl_in_EMA01_is_detected := false ; tmpl_in_EMA01_timestamp_point := NULL ; tmpl_in_EMA01_event_name := NULL ; tmpl_in_EMA01_event_vector := NULL ;
       tmpl_in_EMA03_is_detected := false ; tmpl_in_EMA03_timestamp_point := NULL ; tmpl_in_EMA03_event_name := NULL ; tmpl_in_EMA03_event_vector := NULL ;
       tmpl_in_RSI_DOWN_is_detected := false ; tmpl_in_RSI_DOWN_timestamp_point := NULL ; tmpl_in_RSI_DOWN_event_name := NULL ; tmpl_in_RSI_DOWN_event_vector := NULL ;
       tmpl_in_MACD_UP_is_detected := false ; tmpl_in_MACD_UP_timestamp_point := NULL ; tmpl_in_MACD_UP_event_name := NULL ; tmpl_in_MACD_UP_event_vector := NULL ;
       tmpl_out_EMA01_is_detected := false ; tmpl_out_EMA01_timestamp_point := NULL ; tmpl_out_EMA01_event_name := NULL ; tmpl_out_EMA01_event_vector := NULL ;
       tmpl_out_EMA03_is_detected := false ; tmpl_out_EMA03_timestamp_point := NULL ; tmpl_out_EMA03_event_name := NULL ; tmpl_out_EMA03_event_vector := NULL ;
       tmpl_out_RSI_UP_is_detected := false ; tmpl_out_RSI_UP_timestamp_point := NULL ; tmpl_out_RSI_UP_event_name := NULL ; tmpl_out_RSI_UP_event_vector := NULL ;
       tmpl_out_MACD_DOWN_is_detected := false ; tmpl_out_MACD_DOWN_timestamp_point := NULL ; tmpl_out_MACD_DOWN_event_name := NULL ; tmpl_out_MACD_DOWN_event_vector := NULL ;
       sum_percent_clear := 0 ; sum_percent_protected := 0 ; cnt_contracts := 0 ;

-- это позволяет набрать в кубышку разные ТФ
       if (v_MACD_ind_type = 'LINE') then -- используется и тут, и в формировании имени события при проверках ниже
          ds_request := 'select 1, ''EMA03'', timestamp_point, EMA03_state IND_STATE, EMA03_event_name EVENT_NAME, EMA03_event_vector EVENT_VECTOR
                                from rtrsp_events_of_indicators
                                where currency = $1 and reference_currency = $2 and time_frame = $3 and EMA03_event_name IS NOT NULL
                                      AND EMA03_event_vector IS NOT NULL 
                                      AND timestamp_point >= TO_TIMESTAMP('''||v_start_date||''',''YYYY-MM-DD HH24:MI:SS'')
                                      AND timestamp_point <= TO_TIMESTAMP('''||v_stop_date||''',''YYYY-MM-DD HH24:MI:SS'')
                         union all
                         select 2, ''EMA01'', timestamp_point, EMA01_state, EMA01_event_name, EMA01_event_vector
                                from rtrsp_events_of_indicators
                                where currency = $1 and reference_currency = $2 and time_frame = $3 and EMA01_event_name IS NOT NULL
                                      AND EMA01_event_vector IS NOT NULL  
                                      AND timestamp_point >= TO_TIMESTAMP('''||v_start_date||''',''YYYY-MM-DD HH24:MI:SS'')
                                      AND timestamp_point <= TO_TIMESTAMP('''||v_stop_date||''',''YYYY-MM-DD HH24:MI:SS'')
                         union all
                         select 3, ''RSI'', timestamp_point, RSI_state, RSI_event_name, RSI_event_vector 
                                from rtrsp_events_of_indicators
                                where currency = $1 and reference_currency = $2 and time_frame = $3 and RSI_event_name IS NOT NULL
                                      AND RSI_event_vector IS NOT NULL AND NOT RSI_event_name LIKE ''RSI_1H_CLEAR%''
                                      AND timestamp_point >= TO_TIMESTAMP('''||v_start_date||''',''YYYY-MM-DD HH24:MI:SS'')
                                      AND timestamp_point <= TO_TIMESTAMP('''||v_stop_date||''',''YYYY-MM-DD HH24:MI:SS'')
                         union all
                         select 4, ''MACD'', timestamp_point, MACDL_state, MACDL_event_name, MACDL_event_vector 
                                from rtrsp_events_of_indicators 
                                where currency = $1 and reference_currency = $2 and time_frame = $4 and MACDL_event_name IS NOT NULL
                                      AND MACDL_event_vector IS NOT NULL AND MACDL_event_name like ''%'||v_MACD_ind_sub_type||'%''
                                      AND timestamp_point >= TO_TIMESTAMP('''||v_start_date||''',''YYYY-MM-DD HH24:MI:SS'')
                                      AND timestamp_point <= TO_TIMESTAMP('''||v_stop_date||''',''YYYY-MM-DD HH24:MI:SS'')
                         order by 3 asc, 1' ;
       end if ;
       if (v_MACD_ind_type = 'GIST') then -- используется и тут, и в формировании имени события при проверках ниже
          ds_request := 'select 1, ''EMA03'', timestamp_point, EMA03_state IND_STATE, EMA03_event_name EVENT_NAME, EMA03_event_vector EVENT_VECTOR
                                from rtrsp_events_of_indicators
                                where currency = $1 and reference_currency = $2 and time_frame = $3 
                                      AND timestamp_point >= TO_TIMESTAMP('''||v_start_date||''',''YYYY-MM-DD HH24:MI:SS'')
                                      AND timestamp_point <= TO_TIMESTAMP('''||v_stop_date||''',''YYYY-MM-DD HH24:MI:SS'')
                         union all
                         select 2, ''EMA01'', timestamp_point, EMA01_state, EMA01_event_name, EMA01_event_vector
                                from rtrsp_events_of_indicators
                                where currency = $1 and reference_currency = $2 and time_frame = $3 
                                      AND timestamp_point >= TO_TIMESTAMP('''||v_start_date||''',''YYYY-MM-DD HH24:MI:SS'')
                                      AND timestamp_point <= TO_TIMESTAMP('''||v_stop_date||''',''YYYY-MM-DD HH24:MI:SS'')
                         union all
                         select 3, ''RSI'', timestamp_point, RSI_state, RSI_event_name, RSI_event_vector 
                                from rtrsp_events_of_indicators
                                where currency = $1 and reference_currency = $2 and time_frame = $3 and RSI_event_name IS NOT NULL 
                                      AND RSI_event_vector IS NOT NULL AND NOT RSI_event_name LIKE ''RSI_1H_CLEAR%''
                                      AND timestamp_point >= TO_TIMESTAMP('''||v_start_date||''',''YYYY-MM-DD HH24:MI:SS'')
                                      AND timestamp_point <= TO_TIMESTAMP('''||v_stop_date||''',''YYYY-MM-DD HH24:MI:SS'')
                         union all
                         select 4, ''MACD'', timestamp_point, MACDG_state, MACDG_event_name, MACDG_event_vector 
                                from rtrsp_events_of_indicators 
                                where currency = $1 and reference_currency = $2 and time_frame = $4 and MACDG_event_name IS NOT NULL 
                                      AND MACDG_event_vector IS NOT NULL AND MACDG_event_name like ''%'||v_MACD_ind_sub_type||'%''
                                      AND timestamp_point >= TO_TIMESTAMP('''||v_start_date||''',''YYYY-MM-DD HH24:MI:SS'')
                                      AND timestamp_point <= TO_TIMESTAMP('''||v_stop_date||''',''YYYY-MM-DD HH24:MI:SS'')
                         order by 3 asc, 1' ;
          end if ;
-- debug RAISE NOTICE 'request %', ds_request ;
-- идём по упорядоченному списку событий
-- ищем вхождения шаблонных событий, тут они на вход и выход одинаковые
-- но при этом выход не инициализируем, если не было входа
       FOR ds_data IN EXECUTE ds_request USING v_currency, v_reference_currency, v_RSI_time_frame, v_MACD_time_frame LOOP
-- ----------------------------------
-- собираем статусы для точки входа
-- ----------------------------------
           IF ( out_timestamp_point IS NULL ) THEN
--debug RAISE NOTICE 'вход обрабатываем строку % % %', ds_data.timestamp_point, ds_data.EVENT_NAME, ds_data.event_vector ;
-- если включено и взлетело - выставить, если выключено или упало - сбросить
              IF ( v_is_include_parent_ema = true and ds_data.EVENT_NAME = 'EMA03_'||v_RSI_time_frame||'_LINE_VECTOR'
                   and ds_data.EVENT_VECTOR = 'UP' and tmpl_in_EMA03_is_detected = false ) THEN
                 tmpl_in_EMA03_is_detected := true ; tmpl_in_EMA03_timestamp_point := ds_data.timestamp_point ; tmpl_in_EMA03_event_name := ds_data.event_name ; tmpl_in_EMA03_event_vector := ds_data.event_vector ;
-- debug - RAISE NOTICE '- ищем вход. пошла вверх EMA03 % % %', ds_data.timestamp_point, ds_data.EVENT_NAME, ds_data.event_vector ;
                 END IF ;
              IF (v_is_include_parent_ema = true and ds_data.EVENT_NAME = 'EMA03_'||v_RSI_time_frame||'_LINE_VECTOR' and ds_data.EVENT_VECTOR = 'DOWN') THEN
                 tmpl_in_EMA03_is_detected := false ; tmpl_in_EMA03_timestamp_point := NULL ; tmpl_in_EMA03_event_name := NULL ; tmpl_in_EMA03_event_vector := NULL ;
-- debug - RAISE NOTICE '- ищем вход. пошла вниз EMA03 % % %', ds_data.timestamp_point, ds_data.EVENT_NAME, ds_data.event_vector ;
                 END IF ;
-- если включено и взлетело - выставить, если выключено или упало - сбросить
              IF (v_is_include_current_ema = true and ds_data.EVENT_NAME = 'EMA01_'||v_RSI_time_frame||'_LINE_VECTOR'
                  and ds_data.EVENT_VECTOR = 'UP' and tmpl_in_EMA01_is_detected = false ) THEN
                 tmpl_in_EMA01_is_detected := true ; tmpl_in_EMA01_timestamp_point := ds_data.timestamp_point ; tmpl_in_EMA01_event_name := ds_data.event_name ; tmpl_in_EMA01_event_vector := ds_data.event_vector ;
-- debug - RAISE NOTICE '- ищем вход. пошла вверх EMA01 % % %', ds_data.timestamp_point, ds_data.EVENT_NAME, ds_data.event_vector ;
                 END IF ;
              IF (v_is_include_current_ema = true and ds_data.EVENT_NAME = 'EMA01_'||v_RSI_time_frame||'_LINE_VECTOR' and ds_data.EVENT_VECTOR = 'DOWN') THEN
                 tmpl_in_EMA01_is_detected := false ; tmpl_in_EMA01_timestamp_point := NULL ; tmpl_in_EMA01_event_name := NULL ; tmpl_in_EMA01_event_vector := NULL ;
-- debug - RAISE NOTICE '- ищем вход. пошла вниз EMA01 % % %', ds_data.timestamp_point, ds_data.EVENT_NAME, ds_data.event_vector ;
                 END IF ;
-- проверить статус RSI на вход, с учетом корректных старшей EMA, корректное - взвести, некорректное - сбросить
-- если включено и взлетело - выставить, если выключено или упало, или EMA сброшены - сбросить
              IF ( (ds_data.EVENT_NAME = 'RSI_'||v_RSI_time_frame||'_DOWN_CROSS_30' and v_is_include_rsi = true)
                   and tmpl_in_RSI_DOWN_is_detected = false ) THEN
                 tmpl_in_RSI_DOWN_is_detected := true ; tmpl_in_RSI_DOWN_timestamp_point := ds_data.timestamp_point ; tmpl_in_RSI_DOWN_event_name := ds_data.event_name ; tmpl_in_RSI_DOWN_event_vector := ds_data.event_vector ;
-- debug - RAISE NOTICE '- ищем вход. выставили RSI на вход %, EMA1 % used= %, EMA3 % used= %, % %', ds_data.timestamp_point, tmpl_in_EMA01_is_detected, v_is_include_current_ema, tmpl_in_EMA03_is_detected, v_is_include_parent_ema, ds_data.EVENT_NAME, ds_data.event_vector ; 
                 END IF ;
              IF (ds_data.EVENT_NAME = 'RSI_'||v_RSI_time_frame||'_UP_CROSS_70' or v_is_include_rsi = false) THEN
                 tmpl_in_RSI_DOWN_is_detected := false ; tmpl_in_RSI_DOWN_timestamp_point := NULL ; tmpl_in_RSI_DOWN_event_name := NULL ; tmpl_in_RSI_DOWN_event_vector := NULL ;
-- debug - RAISE NOTICE '- ищем вход. сбросили RSI на вход %, EMA1 % used= %, EMA3 % used= %, % %', ds_data.timestamp_point, tmpl_in_EMA01_is_detected, v_is_include_current_ema, tmpl_in_EMA03_is_detected, v_is_include_parent_ema, ds_data.EVENT_NAME, ds_data.event_vector ; 
                 END IF ;
-- при выявлении события MACD шаблона проверить - заполнен ли шаблон RSI для точки входа, если RSI включён
              IF ( ((tmpl_in_RSI_DOWN_is_detected = true or v_is_include_rsi = false)
                   and ds_data.EVENT_NAME = 'MACD_'||v_MACD_time_frame||'_'||v_MACD_ind_type||'_'||v_MACD_ind_sub_type
                   and ds_data.EVENT_VECTOR = 'UP' and tmpl_in_MACD_UP_is_detected = false)) THEN
                 tmpl_in_MACD_UP_is_detected := true ; tmpl_in_MACD_UP_timestamp_point := ds_data.timestamp_point ; tmpl_in_MACD_UP_event_name := ds_data.event_name ; tmpl_in_MACD_UP_event_vector := ds_data.event_vector ;
-- debug - RAISE NOTICE '- ищем вход. выставили MACD на вход %, EMA1 % used= %, EMA3 % used= %, % %', ds_data.timestamp_point, tmpl_in_EMA01_is_detected, v_is_include_current_ema, tmpl_in_EMA03_is_detected, v_is_include_parent_ema, ds_data.EVENT_NAME, ds_data.event_vector ; 
                 END IF ; -- конец проверки MACD для точки входа
              IF ( ds_data.EVENT_NAME = 'MACD_'||v_MACD_time_frame||'_'||v_MACD_ind_type||'_'||v_MACD_ind_sub_type and ds_data.EVENT_VECTOR = 'DOWN') THEN
                 tmpl_in_MACD_UP_is_detected := false ; tmpl_in_MACD_UP_timestamp_point := NULL ; tmpl_in_MACD_UP_event_name := NULL ; tmpl_in_MACD_UP_event_vector := NULL ;
-- debug - RAISE NOTICE '- ищем вход. сбросили MACD на вход %, EMA1 % used= %, EMA3 % used= %, % %', ds_data.timestamp_point, tmpl_in_EMA01_is_detected, v_is_include_current_ema, tmpl_in_EMA03_is_detected, v_is_include_parent_ema, ds_data.EVENT_NAME, ds_data.event_vector ; 
--              sz_msg := 'long точка входа - '||TO_CHAR(tmpl_01_RSI_timestamp_point,'YYYY-MM-DD HH24:MI:SS')||' - '||tmpl_01_RSI_event_name||' --- '||TO_CHAR(tmpl_02_MACD_timestamp_point,'YYYY-MM-DD HH24:MI:SS')||' - '||ds_data.EVENT_NAME||' - '||ds_data.EVENT_VECTOR ;
-- debug                RAISE NOTICE 'идентифицировано заполнение шаблона % ', sz_msg ;
                 END IF ; -- конец проверки MACD для точки входа

-- -------------------------------------------------
-- проверяем созревание статусов для точки входа
-- -------------------------------------------------
-- вот здесь точку входа мы выбираем не последовательно, а в момент появления всех событий
              IF ( in_timestamp_point IS NULL and tmpl_in_MACD_UP_is_detected = true
                   and (v_is_include_current_ema = false or tmpl_in_EMA01_is_detected = true) 
                   and (v_is_include_parent_ema = false or tmpl_in_EMA03_is_detected = true)) THEN
                 in_timestamp_point := ds_data.TIMESTAMP_POINT ;
                 RAISE NOTICE '!!! таки точка входа %, RSI = % ts % ev % vc %, MACD = % ts % ev % vc %, EMA1 = % ts % ev % vc %, EMA3 = % ts % ev % vc %',
                       ds_data.timestamp_point, 
                       tmpl_in_RSI_DOWN_is_detected, tmpl_in_RSI_DOWN_timestamp_point, tmpl_in_RSI_DOWN_event_name, tmpl_in_RSI_DOWN_event_vector,
                       tmpl_in_MACD_UP_is_detected, tmpl_in_MACD_UP_timestamp_point, tmpl_in_MACD_UP_event_name, tmpl_in_MACD_UP_event_vector,
                       tmpl_in_EMA01_is_detected, tmpl_in_EMA01_timestamp_point, tmpl_in_EMA01_event_name, tmpl_in_EMA01_event_vector,
                       tmpl_in_EMA03_is_detected, tmpl_in_EMA03_timestamp_point, tmpl_in_EMA03_event_name, tmpl_in_EMA03_event_vector ;
                 END IF ;
           END IF ; -- конец блока обработичика входа (когда точка выхода пуста)

-- ----------------------------------
-- собираем для точки вЫхода, когда точка входа найдена
-- ----------------------------------
           IF ( in_timestamp_point IS NOT NULL ) THEN
--debug - RAISE NOTICE 'вЫход обрабатываем строку % % %', ds_data.timestamp_point, ds_data.EVENT_NAME, ds_data.event_vector ;
-- если включено и взлетело - выставить, если выключено или упало - сбросить
              IF ( ds_data.EVENT_NAME = 'EMA03_'||v_RSI_time_frame||'_LINE_VECTOR' and ds_data.EVENT_VECTOR = 'DOWN'
                   and v_is_include_parent_ema = true and tmpl_out_EMA03_is_detected = false ) THEN
                 tmpl_out_EMA03_is_detected := true ; tmpl_out_EMA03_timestamp_point := ds_data.timestamp_point ; tmpl_out_EMA03_event_name := ds_data.event_name ; tmpl_out_EMA03_event_vector := ds_data.event_vector ;
-- debug - RAISE NOTICE '- ищем выход. пошла вниз EMA03 % % %', ds_data.timestamp_point, ds_data.EVENT_NAME, ds_data.event_vector ;
                 END IF ;
              IF ( ds_data.EVENT_NAME = 'EMA03_'||v_RSI_time_frame||'_LINE_VECTOR' and ds_data.EVENT_VECTOR = 'UP' and v_is_include_parent_ema = true) THEN
                 tmpl_out_EMA03_is_detected := false ; tmpl_out_EMA03_timestamp_point := NULL ; tmpl_out_EMA03_event_name := NULL ; tmpl_out_EMA03_event_vector := NULL ;
-- debug -                  RAISE NOTICE '- ищем выход. пошла вверх EMA03 % % %', ds_data.timestamp_point, ds_data.EVENT_NAME, ds_data.event_vector ;
                 END IF ;
-- если включено и взлетело - выставить, если выключено или упало - сбросить
              IF ( ds_data.EVENT_NAME = 'EMA01_'||v_RSI_time_frame||'_LINE_VECTOR' and ds_data.EVENT_VECTOR = 'DOWN'
                   and v_is_include_current_ema = true and tmpl_out_EMA01_is_detected = false ) THEN
                 tmpl_out_EMA01_is_detected := true ; tmpl_out_EMA01_timestamp_point := ds_data.timestamp_point ; tmpl_out_EMA01_event_name := ds_data.event_name ; tmpl_out_EMA01_event_vector := ds_data.event_vector ;
-- debug - RAISE NOTICE '- ищем выход. пошла вниз EMA01 % % %', ds_data.timestamp_point, ds_data.EVENT_NAME, ds_data.event_vector ;
                 END IF ;
              IF ( ds_data.EVENT_NAME = 'EMA01_'||v_RSI_time_frame||'_LINE_VECTOR' and ds_data.EVENT_VECTOR = 'UP' and v_is_include_current_ema = true) THEN
                 tmpl_out_EMA01_is_detected := false ; tmpl_out_EMA01_timestamp_point := NULL ; tmpl_out_EMA01_event_name := NULL ; tmpl_out_EMA01_event_vector := NULL ;
-- debug - RAISE NOTICE '- ищем выход. пошла вверх EMA01 % % %', ds_data.timestamp_point, ds_data.EVENT_NAME, ds_data.event_vector ;
                 END IF ;
-- проверить статус RSI на вЫход, с учетом корректной старшей EMA
              IF (ds_data.EVENT_NAME = 'RSI_'||v_RSI_time_frame||'_UP_CROSS_70' and v_is_include_rsi = true and tmpl_out_RSI_UP_is_detected = false) THEN
                 tmpl_out_RSI_UP_is_detected := true ; tmpl_out_RSI_UP_timestamp_point := ds_data.timestamp_point ; tmpl_out_RSI_UP_event_name := ds_data.event_name ; tmpl_out_RSI_UP_event_vector := ds_data.event_vector ;
-- debug - RAISE NOTICE '- ищем выход.  выставили RSI на вЫход %, EMA1 %, EMA3 % % %', ds_data.timestamp_point, tmpl_in_EMA01_is_detected , tmpl_in_EMA03_is_detected, ds_data.EVENT_NAME, ds_data.event_vector ;
                 END IF ;
              IF ( ds_data.EVENT_NAME = 'RSI_'||v_RSI_time_frame||'_DOWN_CROSS_30' or v_is_include_rsi = false ) THEN
                 tmpl_out_RSI_UP_is_detected := false ; tmpl_out_RSI_UP_timestamp_point := NULL ; tmpl_out_RSI_UP_event_name := NULL ; tmpl_out_RSI_UP_event_vector := NULL ;
-- debug - RAISE NOTICE '- ищем выход. сбросили RSI на вЫход %, EMA1 %, EMA3 % % %', ds_data.timestamp_point, tmpl_in_EMA01_is_detected , tmpl_in_EMA03_is_detected, ds_data.EVENT_NAME, ds_data.event_vector ;
                 END IF ;
-- во второй версии стратегии проверяем, что это первое событие из возможных нескольких, как и в RSI
-- MACD зависит от RSI, если он включен
              IF ( ( (tmpl_out_RSI_UP_is_detected = true or v_is_include_rsi = false)
                   and ds_data.EVENT_NAME = 'MACD_'||v_MACD_time_frame||'_'||v_MACD_ind_type||'_'||v_MACD_ind_sub_type
                   and ds_data.EVENT_VECTOR = 'DOWN' 
                   and tmpl_out_MACD_DOWN_is_detected = false)) THEN
                 tmpl_out_MACD_DOWN_is_detected := true ; tmpl_out_MACD_DOWN_timestamp_point := ds_data.timestamp_point ; tmpl_out_MACD_DOWN_event_name := ds_data.event_name ; tmpl_out_MACD_DOWN_event_vector := ds_data.event_vector ;
-- debug - RAISE NOTICE '- ищем выход. выставили MACD на вЫход %, EMA1 %, EMA3 % % %', ds_data.timestamp_point, tmpl_in_EMA01_is_detected , tmpl_in_EMA03_is_detected, ds_data.EVENT_NAME, ds_data.event_vector ;
                 END IF ;
              IF ( ds_data.EVENT_NAME = 'MACD_'||v_MACD_time_frame||'_'||v_MACD_ind_type||'_'||v_MACD_ind_sub_type
                   and ds_data.EVENT_VECTOR = 'UP') THEN
                 tmpl_out_MACD_DOWN_is_detected := false ; tmpl_out_MACD_DOWN_timestamp_point := NULL ; tmpl_out_MACD_DOWN_event_name := NULL ; tmpl_out_MACD_DOWN_event_vector := NULL ;
-- debug - RAISE NOTICE '- ищем выход. сбросили MACD на вЫход %, EMA1 %, EMA3 % % %', ds_data.timestamp_point, tmpl_in_EMA01_is_detected , tmpl_in_EMA03_is_detected, ds_data.EVENT_NAME, ds_data.event_vector ;
                 END IF ;

-- -------------------------------------------------
-- проверяем созревание статусов для точки вЫхода
-- -------------------------------------------------
-- здесь мы тоже не собираем события последовательно, а ждём точки их совпадения, но в отличие от входа выходим по любому событию
              IF (out_timestamp_point IS NULL AND (tmpl_out_MACD_DOWN_is_detected = true
                  or (false and tmpl_out_EMA01_is_detected = true and v_is_include_current_ema = true)
                  or (false and tmpl_out_EMA03_is_detected = true and v_is_include_parent_ema = true))) THEN
--              sz_msg := 'long точка вЫхода - '||TO_CHAR(tmpl_01_RSI_timestamp_point,'YYYY-MM-DD HH24:MI:SS')||' - '||tmpl_01_RSI_event_name||' --- '||TO_CHAR(tmpl_02_MACD_timestamp_point,'YYYY-MM-DD HH24:MI:SS')||' - '||tmpl_02_MACD_event_name||' - '||tmpl_02_MACD_event_vector ;	  
-- debug RAISE NOTICE 'идентифицировано заполнение шаблона % ', sz_msg ;
                 out_timestamp_point := ds_data.TIMESTAMP_POINT ;
                 RAISE NOTICE '!!! таки точка вЫхода %, RSI = % ts % ev % vc %, MACD = % ts % ev % vc %, EMA1 = % ts % ev % vc %, EMA3 = % ts % ev % vc %',
                       ds_data.timestamp_point,
                       tmpl_out_RSI_UP_is_detected, tmpl_out_RSI_UP_timestamp_point, tmpl_out_RSI_UP_event_name, tmpl_out_RSI_UP_event_vector,
                       tmpl_out_MACD_DOWN_is_detected, tmpl_out_MACD_DOWN_timestamp_point, tmpl_out_MACD_DOWN_event_name, tmpl_out_MACD_DOWN_event_vector,
                       tmpl_out_EMA01_is_detected, tmpl_out_EMA01_timestamp_point, tmpl_out_EMA01_event_name, tmpl_out_EMA01_event_vector,
                       tmpl_out_EMA03_is_detected, tmpl_out_EMA03_timestamp_point, tmpl_out_EMA03_event_name, tmpl_out_EMA03_event_vector ;
                 if (tmpl_out_EMA01_is_detected = true and v_is_include_current_ema = true) then RAISE NOTICE '--- выход по EMA01' ; end if ;
                 if (tmpl_out_EMA03_is_detected = true and v_is_include_parent_ema = true) then RAISE NOTICE '--- выход по EMA03' ; end if ;
                 if (tmpl_out_MACD_DOWN_is_detected = true) then RAISE NOTICE '--- выход по MACD' ; end if ;
				 if (v_rsi_time_frame in ('1D','2D','4D','1W','4W') or v_macd_time_frame in ('1D','2D','4D','1W','4W')) then 
                    SELECT price_close INTO in_price from crcomp_pair_ohlc_1d_history
                           where timestamp_point + INTERVAL '3 HOURS' = in_timestamp_point and currency = v_currency and reference_currency = v_reference_currency ;
                    SELECT price_close INTO out_price from crcomp_pair_ohlc_1d_history
                           where timestamp_point + INTERVAL '3 HOURS' = out_timestamp_point and currency = v_currency and reference_currency = v_reference_currency ;
                    SELECT min(price_low) INTO min_price from crcomp_pair_ohlc_1d_history
                           where timestamp_point + INTERVAL '3 HOURS' >= in_timestamp_point and timestamp_point + INTERVAL '3 HOURS' <= out_timestamp_point and 
                                 currency = v_currency and reference_currency = v_reference_currency ;
                    SELECT max(price_high) INTO max_price from crcomp_pair_ohlc_1d_history
                           where timestamp_point + INTERVAL '3 HOURS' >= in_timestamp_point and timestamp_point + INTERVAL '3 HOURS' <= out_timestamp_point and 
                                 currency = v_currency and reference_currency = v_reference_currency ;
                 end if ;
				 if (v_rsi_time_frame in ('1H','2H','3H','4H','8H','12H') or v_macd_time_frame in ('1H','2H','3H','4H','8H','12H')) then 
                    SELECT price_close INTO in_price from crcomp_pair_ohlc_1h_history
                           where timestamp_point + INTERVAL '3 HOURS' = in_timestamp_point and currency = v_currency and reference_currency = v_reference_currency ;
                    SELECT price_close INTO out_price from crcomp_pair_ohlc_1h_history
                           where timestamp_point + INTERVAL '3 HOURS' = out_timestamp_point and currency = v_currency and reference_currency = v_reference_currency ;
                    SELECT min(price_low) INTO min_price from crcomp_pair_ohlc_1h_history
                           where timestamp_point + INTERVAL '3 HOURS' >= in_timestamp_point and timestamp_point + INTERVAL '3 HOURS' <= out_timestamp_point and 
                                 currency = v_currency and reference_currency = v_reference_currency ;
                    SELECT max(price_high) INTO max_price from crcomp_pair_ohlc_1h_history
                           where timestamp_point + INTERVAL '3 HOURS' >= in_timestamp_point and timestamp_point + INTERVAL '3 HOURS' <= out_timestamp_point and 
                                 currency = v_currency and reference_currency = v_reference_currency ;
                 end if ;
				 if (v_rsi_time_frame in ('1M','3M','5M','10M','15M','30M') or v_macd_time_frame in ('1M','3M','5M','10M','15M','30M')) then 
                    SELECT price_close INTO in_price from crcomp_pair_ohlc_1m_history
                           where timestamp_point + INTERVAL '3 HOURS' = in_timestamp_point and currency = v_currency and reference_currency = v_reference_currency ;
                    SELECT price_close INTO out_price from crcomp_pair_ohlc_1m_history
                           where timestamp_point + INTERVAL '3 HOURS' = out_timestamp_point and currency = v_currency and reference_currency = v_reference_currency ;
                    SELECT min(price_low) INTO min_price from crcomp_pair_ohlc_1m_history
                           where timestamp_point + INTERVAL '3 HOURS' >= in_timestamp_point and timestamp_point + INTERVAL '3 HOURS' <= out_timestamp_point and 
                                 currency = v_currency and reference_currency = v_reference_currency ;
                    SELECT max(price_high) INTO max_price from crcomp_pair_ohlc_1m_history
                           where timestamp_point + INTERVAL '3 HOURS' >= in_timestamp_point and timestamp_point + INTERVAL '3 HOURS' <= out_timestamp_point and 
                                 currency = v_currency and reference_currency = v_reference_currency ;
				 end if ;
                 result_record.strategy_name      := 'RSI'||v_RSI_time_frame||'MACD'||v_MACD_time_frame ;
                 result_record.strategy_sub_name  := 'normal' ;
                 result_record.currency           := v_currency ;
                 result_record.reference_currency := v_reference_currency ;
                 result_record.vector             := 'long' ;
                 result_record.profit             := ROUND((( out_price - in_price) / (in_price / 100)),2) ;
-- если в процессе сделки есть просадка меньше лимита StopLoss - поле защищённой прибыли равно SL
                 if ( (( min_price - in_price) * 100 / in_price) < v_protected_profit ) then
                    result_record.protected_profit := v_protected_profit ;
                 else
                    result_record.protected_profit := ROUND((( out_price - in_price) * 100 / in_price),2) ;
                 end if ;
                 result_record.cn_period           := out_timestamp_point - in_timestamp_point ;
                 result_record.min_prct            := ROUND((( min_price - in_price) / (in_price / 100)),2) ;
                 if ( (( min_price - in_price) * 100 / in_price) < v_protected_profit ) then
                    result_record.prtct_min_prct   := v_protected_profit ;
                 else
                   result_record.prtct_min_prct    := ROUND((( min_price - in_price) * 100 / in_price),2) ;
                 end if ;
                 result_record.max_prct            := ROUND((( max_price - in_price) / (in_price / 100)),2) ;
                 result_record.contract_in_tp      := in_timestamp_point ;
                 result_record.contract_in_price   := in_price ;
                 result_record.contract_out_tp     := out_timestamp_point ;
                 result_record.contract_out_price  := out_price ;
                 result_record.change_ts           := now() ;
                 return next result_record ;

-- debug RAISE NOTICE 'идентифицирована лонговая пара прибыль %, период %, MIN %, MAX % --- вход % (price %), выход % (price %)', 
--           ROUND((( out_price - in_price) / (in_price / 100)),2),
--   TO_CHAR((out_timestamp_point - in_timestamp_point),'MM-DD HH24:MI:SS'),
--   ROUND((( min_price - in_price) / (in_price / 100)),2),
--   ROUND((( max_price - in_price) / (in_price / 100)),2),
--   TO_CHAR(in_timestamp_point,'YYYY-MM-DD HH24:MI:SS'), in_price,
--   TO_CHAR(out_timestamp_point,'YYYY-MM-DD HH24:MI:SS'), out_price ;
                 sum_percent_clear := ROUND((( out_price - in_price) / (in_price / 100)),2) + sum_percent_clear ;
                 if (ROUND((( out_price - in_price) / (in_price / 100)),2) < v_protected_profit) then
                    sum_percent_protected := v_protected_profit + sum_percent_protected ;
                 else
                    sum_percent_protected := ROUND((( out_price - in_price) / (in_price / 100)),2) + sum_percent_protected ;
                 end if ;
                 cnt_contracts := cnt_contracts + 1 ;
-- сбросить все переменные для следующего поиска сделки
                 in_timestamp_point := NULL ; out_timestamp_point := NULL ; in_price := NULL ; out_price := NULL ;
                 tmpl_in_EMA01_is_detected := false ; tmpl_in_EMA01_timestamp_point := NULL ; tmpl_in_EMA01_event_name := NULL ; tmpl_in_EMA01_event_vector := NULL ;
                 tmpl_in_EMA03_is_detected := false ; tmpl_in_EMA03_timestamp_point := NULL ; tmpl_in_EMA03_event_name := NULL ; tmpl_in_EMA03_event_vector := NULL ;
                 tmpl_in_RSI_DOWN_is_detected := false ; tmpl_in_RSI_DOWN_timestamp_point := NULL ; tmpl_in_RSI_DOWN_event_name := NULL ; tmpl_in_RSI_DOWN_event_vector := NULL ;
                 tmpl_in_MACD_UP_is_detected := false ; tmpl_in_MACD_UP_timestamp_point := NULL ; tmpl_in_MACD_UP_event_name := NULL ; tmpl_in_MACD_UP_event_vector := NULL ;
                 tmpl_out_EMA01_is_detected := false ; tmpl_out_EMA01_timestamp_point := NULL ; tmpl_out_EMA01_event_name := NULL ; tmpl_out_EMA01_event_vector := NULL ;
                 tmpl_out_EMA03_is_detected := false ; tmpl_out_EMA03_timestamp_point := NULL ; tmpl_out_EMA03_event_name := NULL ; tmpl_out_EMA03_event_vector := NULL ;
                 tmpl_out_RSI_UP_is_detected := false ; tmpl_out_RSI_UP_timestamp_point := NULL ; tmpl_out_RSI_UP_event_name := NULL ; tmpl_out_RSI_UP_event_vector := NULL ;
                 tmpl_out_MACD_DOWN_is_detected := false ; tmpl_out_MACD_DOWN_timestamp_point := NULL ; tmpl_out_MACD_DOWN_event_name := NULL ; tmpl_out_MACD_DOWN_event_vector := NULL ;
-- debug         RAISE NOTICE 'обнулили шаблонные переменные, проверили множественность RAISE' ;
                 END IF ; -- конец обработчика именно MACD
          END IF ; -- конец условного блока обработки точки выхода - когде не =пуста точка входа
       END LOOP ;
-- debug   RAISE NOTICE 'Контрактов ЛОНГ %, суммарный рост за период простой %, защищённый %, SL = %', cnt_contracts, sum_percent_clear, sum_percent_protected, SL_value ;
       RETURN ;
       END ;
$BODY$;

-- вот три индикатора показывают минус на фоне старшей EMA - RSI + MACD
select * from check_strategy_rsi_macd_ema_long_as_table('APT', 'USDT', '10M', '10M', 'LINE', 'CROSS', -3, true, 
													TO_CHAR(now() - interval '25 month','YYYY-MM-DD HH24:MI:SS'),
												    TO_CHAR(now(),'YYYY-MM-DD HH24:MI:SS'), false, true ) ;

select count(*), sum(a.profit), sum(a.protected_profit) from (
select * from check_strategy_rsi_macd_ema_long_as_table('APT', 'USDT', '1H', '4H', 'LINE', 'CROSS', -7, true, 
													TO_CHAR(now() - interval '1200 month','YYYY-MM-DD HH24:MI:SS'),
												    TO_CHAR(now(),'YYYY-MM-DD HH24:MI:SS'), true, true )) a;


-- а вот проверяем, куда шла старшая
-- получается, что собирать события последовательно нельзя
-- вечер 30 октября - скорее их нужно собиратьь группами, и в точках пероесечения искать точки входа и выхода
select ema03_state from 
rtrsp_events_of_indicators st,
check_strategy_rsi_macd_ema_long_as_table('APT', 'USDT', '10M', '30M', 'LINE', 'VECTOR', -1, true, 
													TO_CHAR(now() - interval '15 month','YYYY-MM-DD HH24:MI:SS'),
												    TO_CHAR(now(),'YYYY-MM-DD HH24:MI:SS'), false, true ) dt 
where st.timestamp_point > dt.contract_in_tp and st.timestamp_point < dt.contract_out_tp
 and st.currency = 'APT' and st.reference_currency = 'USDT' and st.time_frame = '10M'  order by st.timestamp_point;


-- обработчик второй стратегии RSI_MACD_EMAs
DROP FUNCTION check_strategy_RSI_MACD_EMA_short_as_table ;
CREATE OR REPLACE FUNCTION public.check_strategy_rsi_macd_ema_short_as_table(
       v_currency               character varying,
       v_reference_currency     character varying,
       v_rsi_time_frame         character varying,
       v_macd_time_frame        character varying,
       v_macd_ind_type          character varying,
       v_macd_ind_sub_type      character varying,
       v_protected_profit       real,
       v_is_include_rsi         boolean,
       v_start_date             character varying,
       v_stop_date              character varying,
       v_is_include_current_ema boolean,
       v_is_include_parent_ema  boolean)
       RETURNS SETOF rtrsp_analyze_strategy 
       LANGUAGE 'plpgsql'
AS $BODY$
       DECLARE
       result_record                       rtrsp_analyze_strategy%ROWTYPE ;
       ds_request                          VARCHAR ;
       ds_data                             RECORD ;
       sz_msg                              VARCHAR(1000) ;
       in_timestamp_point timestamp without time zone ; in_price NUMERIC ; 
       out_timestamp_point timestamp without time zone ; out_price NUMERIC ; 
-- переменные шаблона входа
       tmpl_in_EMA01_is_detected boolean ; tmpl_in_EMA01_timestamp_point timestamp without time zone ; tmpl_in_EMA01_event_name character varying(100) ; tmpl_in_EMA01_event_vector character varying(30) ;
       tmpl_in_EMA03_is_detected boolean ; tmpl_in_EMA03_timestamp_point timestamp without time zone ; tmpl_in_EMA03_event_name character varying(100) ; tmpl_in_EMA03_event_vector character varying(30) ;
       tmpl_in_RSI_UP_is_detected boolean ; tmpl_in_RSI_UP_timestamp_point timestamp without time zone ; tmpl_in_RSI_UP_event_name character varying(100) ; tmpl_in_RSI_UP_event_vector character varying(30) ;
       tmpl_in_MACD_DOWN_is_detected boolean ; tmpl_in_MACD_DOWN_timestamp_point timestamp without time zone ; tmpl_in_MACD_DOWN_event_name character varying(100) ; tmpl_in_MACD_DOWN_event_vector character varying(30) ;
       tmpl_out_EMA01_is_detected boolean ; tmpl_out_EMA01_timestamp_point timestamp without time zone ; tmpl_out_EMA01_event_name character varying(100) ; tmpl_out_EMA01_event_vector character varying(30) ;
       tmpl_out_EMA03_is_detected boolean ; tmpl_out_EMA03_timestamp_point timestamp without time zone ; tmpl_out_EMA03_event_name character varying(100) ; tmpl_out_EMA03_event_vector character varying(30) ;
       tmpl_out_RSI_DOWN_is_detected boolean ; tmpl_out_RSI_DOWN_timestamp_point timestamp without time zone ; tmpl_out_RSI_DOWN_event_name character varying(100) ; tmpl_out_RSI_DOWN_event_vector character varying(30) ;
       tmpl_out_MACD_UP_is_detected boolean ; tmpl_out_MACD_UP_timestamp_point timestamp without time zone ; tmpl_out_MACD_UP_event_name character varying(100) ; tmpl_out_MACD_UP_event_vector character varying(30) ;
       sum_percent_clear real ; sum_percent_protected real ; cnt_contracts int ; max_price NUMERIC ; min_price NUMERIC ; 
       BEGIN
       in_timestamp_point := NULL ; out_timestamp_point := NULL ; in_price := NULL ; out_price := NULL ;
       tmpl_in_EMA01_is_detected := false ; tmpl_in_EMA01_timestamp_point := NULL ; tmpl_in_EMA01_event_name := NULL ; tmpl_in_EMA01_event_vector := NULL ;
       tmpl_in_EMA03_is_detected := false ; tmpl_in_EMA03_timestamp_point := NULL ; tmpl_in_EMA03_event_name := NULL ; tmpl_in_EMA03_event_vector := NULL ;
       tmpl_in_RSI_UP_is_detected := false ; tmpl_in_RSI_UP_timestamp_point := NULL ; tmpl_in_RSI_UP_event_name := NULL ; tmpl_in_RSI_UP_event_vector := NULL ;
       tmpl_in_MACD_DOWN_is_detected := false ; tmpl_in_MACD_DOWN_timestamp_point := NULL ; tmpl_in_MACD_DOWN_event_name := NULL ; tmpl_in_MACD_DOWN_event_vector := NULL ;
       tmpl_out_EMA01_is_detected := false ; tmpl_out_EMA01_timestamp_point := NULL ; tmpl_out_EMA01_event_name := NULL ; tmpl_out_EMA01_event_vector := NULL ;
       tmpl_out_EMA03_is_detected := false ; tmpl_out_EMA03_timestamp_point := NULL ; tmpl_out_EMA03_event_name := NULL ; tmpl_out_EMA03_event_vector := NULL ;
       tmpl_out_RSI_DOWN_is_detected := false ; tmpl_out_RSI_DOWN_timestamp_point := NULL ; tmpl_out_RSI_DOWN_event_name := NULL ; tmpl_out_RSI_DOWN_event_vector := NULL ;
       tmpl_out_MACD_UP_is_detected := false ; tmpl_out_MACD_UP_timestamp_point := NULL ; tmpl_out_MACD_UP_event_name := NULL ; tmpl_out_MACD_UP_event_vector := NULL ;
       sum_percent_clear := 0 ; sum_percent_protected := 0 ; cnt_contracts := 0 ;

-- это позволяет набрать в кубышку разные ТФ
       if (v_MACD_ind_type = 'LINE') then -- используется и тут, и в формировании имени события при проверках ниже
          ds_request := 'select 1, ''EMA03'', timestamp_point, EMA03_state IND_STATE, EMA03_event_name EVENT_NAME, EMA03_event_vector EVENT_VECTOR 
                                from rtrsp_events_of_indicators
                                where currency = $1 and reference_currency = $2 and time_frame = $3 and EMA03_event_name IS NOT NULL 
                                      AND EMA03_event_vector IS NOT NULL 
                                      AND timestamp_point >= TO_TIMESTAMP('''||v_start_date||''',''YYYY-MM-DD HH24:MI:SS'')
                                      AND timestamp_point <= TO_TIMESTAMP('''||v_stop_date||''',''YYYY-MM-DD HH24:MI:SS'')
                          union all
                          select 2, ''EMA01'', timestamp_point, EMA01_state, EMA01_event_name, EMA01_event_vector
                                from rtrsp_events_of_indicators
                                where currency = $1 and reference_currency = $2 and time_frame = $3 and EMA01_event_name IS NOT NULL 
                                      AND EMA01_event_vector IS NOT NULL
                                      AND timestamp_point >= TO_TIMESTAMP('''||v_start_date||''',''YYYY-MM-DD HH24:MI:SS'')
                                      AND timestamp_point <= TO_TIMESTAMP('''||v_stop_date||''',''YYYY-MM-DD HH24:MI:SS'')
                          union all
                          select 3, ''RSI'', timestamp_point, RSI_state, RSI_event_name, RSI_event_vector 
                                from rtrsp_events_of_indicators
                                where currency = $1 and reference_currency = $2 and time_frame = $3 and RSI_event_name IS NOT NULL 
                                      AND RSI_event_vector IS NOT NULL AND NOT RSI_event_name LIKE ''RSI_1H_CLEAR%''
                                      AND timestamp_point >= TO_TIMESTAMP('''||v_start_date||''',''YYYY-MM-DD HH24:MI:SS'')
                                      AND timestamp_point <= TO_TIMESTAMP('''||v_stop_date||''',''YYYY-MM-DD HH24:MI:SS'')
                          union all
                          select 4, ''MACD'', timestamp_point, MACDL_state, MACDL_event_name, MACDL_event_vector 
                                 from rtrsp_events_of_indicators 
                                 where currency = $1 and reference_currency = $2 and time_frame = $4 and MACDL_event_name IS NOT NULL 
                                       AND MACDL_event_vector IS NOT NULL AND MACDL_event_name like ''%'||v_MACD_ind_sub_type||'%''
                                       AND timestamp_point >= TO_TIMESTAMP('''||v_start_date||''',''YYYY-MM-DD HH24:MI:SS'')
                                       AND timestamp_point <= TO_TIMESTAMP('''||v_stop_date||''',''YYYY-MM-DD HH24:MI:SS'')
                          order by 3 asc, 1' ;
       end if ;
       if (v_MACD_ind_type = 'GIST') then -- используется и тут, и в формировании имени события при проверках ниже
          ds_request := 'select 1, ''EMA03'', timestamp_point, EMA03_state IND_STATE, EMA03_event_name EVENT_NAME, EMA03_event_vector EVENT_VECTOR 
                                from rtrsp_events_of_indicators
                                where currency = $1 and reference_currency = $2 and time_frame = $3 
                                      AND timestamp_point >= TO_TIMESTAMP('''||v_start_date||''',''YYYY-MM-DD HH24:MI:SS'')
                                      AND timestamp_point <= TO_TIMESTAMP('''||v_stop_date||''',''YYYY-MM-DD HH24:MI:SS'')
                          union all
                          select 2, ''EMA01'', timestamp_point, EMA01_state, EMA01_event_name, EMA01_event_vector
                                from rtrsp_events_of_indicators
                                where currency = $1 and reference_currency = $2 and time_frame = $3 
                                      AND timestamp_point >= TO_TIMESTAMP('''||v_start_date||''',''YYYY-MM-DD HH24:MI:SS'')
                                      AND timestamp_point <= TO_TIMESTAMP('''||v_stop_date||''',''YYYY-MM-DD HH24:MI:SS'')
                          union all
                          select 3, ''RSI'', timestamp_point, RSI_state, RSI_event_name, RSI_event_vector 
                                from rtrsp_events_of_indicators
                                where currency = $1 and reference_currency = $2 and time_frame = $3 and RSI_event_name IS NOT NULL 
                                      AND RSI_event_vector IS NOT NULL AND NOT RSI_event_name LIKE ''RSI_1H_CLEAR%''
                                      AND timestamp_point >= TO_TIMESTAMP('''||v_start_date||''',''YYYY-MM-DD HH24:MI:SS'')
                                      AND timestamp_point <= TO_TIMESTAMP('''||v_stop_date||''',''YYYY-MM-DD HH24:MI:SS'')
                          union all
                          select 4, ''MACD'', timestamp_point, MACDG_state, MACDG_event_name, MACDG_event_vector 
                                 from rtrsp_events_of_indicators 
                                 where currency = $1 and reference_currency = $2 and time_frame = $4 and MACDG_event_name IS NOT NULL 
                                       AND MACDG_event_vector IS NOT NULL AND MACDG_event_name like ''%'||v_MACD_ind_sub_type||'%''
                                       AND timestamp_point >= TO_TIMESTAMP('''||v_start_date||''',''YYYY-MM-DD HH24:MI:SS'')
                                       AND timestamp_point <= TO_TIMESTAMP('''||v_stop_date||''',''YYYY-MM-DD HH24:MI:SS'')
                          order by 3 asc, 1' ;
          end if ;
-- debug RAISE NOTICE 'request %', ds_request ;
-- идём по упорядоченному списку событий
-- ищем вхождения шаблонных событий, тут они на вход и выход одинаковые
-- но при этом выход не инициализируем, если не было входа
       FOR ds_data IN EXECUTE ds_request USING v_currency, v_reference_currency, v_RSI_time_frame, v_MACD_time_frame LOOP
-- ----------------------------------
-- собираем статусы для точки входа
-- ----------------------------------
           IF ( out_timestamp_point IS NULL ) THEN
--debug RAISE NOTICE 'вход обрабатываем строку % % %', ds_data.timestamp_point, ds_data.EVENT_NAME, ds_data.event_vector ;
-- если включено и взлетело - выставить, если выключено или упало - сбросить
              IF ( v_is_include_parent_ema = true and ds_data.EVENT_NAME = 'EMA03_'||v_RSI_time_frame||'_LINE_VECTOR'
                   and ds_data.EVENT_VECTOR = 'DOWN' and tmpl_in_EMA03_is_detected = false ) THEN
                 tmpl_in_EMA03_is_detected := true ; tmpl_in_EMA03_timestamp_point := ds_data.timestamp_point ; tmpl_in_EMA03_event_name := ds_data.event_name ; tmpl_in_EMA03_event_vector := ds_data.event_vector ;
-- debug - RAISE NOTICE '- ищем вход. пошла вверх EMA03 % % %', ds_data.timestamp_point, ds_data.EVENT_NAME, ds_data.event_vector ;
                 END IF ;
              IF (v_is_include_parent_ema = true and ds_data.EVENT_NAME = 'EMA03_'||v_RSI_time_frame||'_LINE_VECTOR' and ds_data.EVENT_VECTOR = 'UP') THEN
                 tmpl_in_EMA03_is_detected := false ; tmpl_in_EMA03_timestamp_point := NULL ; tmpl_in_EMA03_event_name := NULL ; tmpl_in_EMA03_event_vector := NULL ;
-- debug - RAISE NOTICE '- ищем вход. пошла вниз EMA03 % % %', ds_data.timestamp_point, ds_data.EVENT_NAME, ds_data.event_vector ;
                 END IF ;
-- если включено и взлетело - выставить, если выключено или упало - сбросить
              IF (v_is_include_current_ema = true and ds_data.EVENT_NAME = 'EMA01_'||v_RSI_time_frame||'_LINE_VECTOR'
                  and ds_data.EVENT_VECTOR = 'DOWN' and tmpl_in_EMA01_is_detected = false ) THEN
                 tmpl_in_EMA01_is_detected := true ; tmpl_in_EMA01_timestamp_point := ds_data.timestamp_point ; tmpl_in_EMA01_event_name := ds_data.event_name ; tmpl_in_EMA01_event_vector := ds_data.event_vector ;
-- debug - RAISE NOTICE '- ищем вход. пошла вверх EMA01 % % %', ds_data.timestamp_point, ds_data.EVENT_NAME, ds_data.event_vector ;
                 END IF ;
              IF (v_is_include_current_ema = true and ds_data.EVENT_NAME = 'EMA01_'||v_RSI_time_frame||'_LINE_VECTOR' and ds_data.EVENT_VECTOR = 'UP') THEN
                 tmpl_in_EMA01_is_detected := false ; tmpl_in_EMA01_timestamp_point := NULL ; tmpl_in_EMA01_event_name := NULL ; tmpl_in_EMA01_event_vector := NULL ;
-- debug - RAISE NOTICE '- ищем вход. пошла вниз EMA01 % % %', ds_data.timestamp_point, ds_data.EVENT_NAME, ds_data.event_vector ;
                 END IF ;
-- проверить статус RSI на вход, с учетом корректных старшей EMA, корректное - взвести, некорректное - сбросить
-- если включено и взлетело - выставить, если выключено или упало, или EMA сброшены - сбросить
              IF ( (ds_data.EVENT_NAME = 'RSI_'||v_RSI_time_frame||'_UP_CROSS_70' and v_is_include_rsi = true)
                    and tmpl_in_RSI_UP_is_detected = false ) THEN
                 tmpl_in_RSI_UP_is_detected := true ; tmpl_in_RSI_UP_timestamp_point := ds_data.timestamp_point ; tmpl_in_RSI_UP_event_name := ds_data.event_name ; tmpl_in_RSI_UP_event_vector := ds_data.event_vector ;
-- debug - RAISE NOTICE '- ищем вход. выставили RSI на вход %, EMA1 % used= %, EMA3 % used= %, % %', ds_data.timestamp_point, tmpl_in_EMA01_is_detected, v_is_include_current_ema, tmpl_in_EMA03_is_detected, v_is_include_parent_ema, ds_data.EVENT_NAME, ds_data.event_vector ; 
                 END IF ;
              IF (ds_data.EVENT_NAME = 'RSI_'||v_RSI_time_frame||'_DOWN_CROSS_30' or v_is_include_rsi = false) THEN
                 tmpl_in_RSI_UP_is_detected := false ; tmpl_in_RSI_UP_timestamp_point := NULL ; tmpl_in_RSI_UP_event_name := NULL ; tmpl_in_RSI_UP_event_vector := NULL ;
-- debug - RAISE NOTICE '- ищем вход. сбросили RSI на вход %, EMA1 % used= %, EMA3 % used= %, % %', ds_data.timestamp_point, tmpl_in_EMA01_is_detected, v_is_include_current_ema, tmpl_in_EMA03_is_detected, v_is_include_parent_ema, ds_data.EVENT_NAME, ds_data.event_vector ; 
                 END IF ;
-- при выявлении события MACD шаблона проверить - заполнен ли шаблон RSI для точки входа, если RSI включён
              IF ( ((tmpl_in_RSI_UP_is_detected = true or v_is_include_rsi = false)
                    and ds_data.EVENT_NAME = 'MACD_'||v_MACD_time_frame||'_'||v_MACD_ind_type||'_'||v_MACD_ind_sub_type
                    and ds_data.EVENT_VECTOR = 'DOWN' and tmpl_in_MACD_DOWN_is_detected = false)) THEN
                 tmpl_in_MACD_DOWN_is_detected := true ; tmpl_in_MACD_DOWN_timestamp_point := ds_data.timestamp_point ; tmpl_in_MACD_DOWN_event_name := ds_data.event_name ; tmpl_in_MACD_DOWN_event_vector := ds_data.event_vector ;
-- debug - RAISE NOTICE '- ищем вход. выставили MACD на вход %, EMA1 % used= %, EMA3 % used= %, % %', ds_data.timestamp_point, tmpl_in_EMA01_is_detected, v_is_include_current_ema, tmpl_in_EMA03_is_detected, v_is_include_parent_ema, ds_data.EVENT_NAME, ds_data.event_vector ; 
                 END IF ; -- конец проверки MACD для точки входа
              IF ( ds_data.EVENT_NAME = 'MACD_'||v_MACD_time_frame||'_'||v_MACD_ind_type||'_'||v_MACD_ind_sub_type and ds_data.EVENT_VECTOR = 'UP') THEN
                 tmpl_in_MACD_DOWN_is_detected := false ; tmpl_in_MACD_DOWN_timestamp_point := NULL ; tmpl_in_MACD_DOWN_event_name := NULL ; tmpl_in_MACD_DOWN_event_vector := NULL ;
-- debug - RAISE NOTICE '- ищем вход. сбросили MACD на вход %, EMA1 % used= %, EMA3 % used= %, % %', ds_data.timestamp_point, tmpl_in_EMA01_is_detected, v_is_include_current_ema, tmpl_in_EMA03_is_detected, v_is_include_parent_ema, ds_data.EVENT_NAME, ds_data.event_vector ; 
--              sz_msg := 'long точка входа - '||TO_CHAR(tmpl_01_RSI_timestamp_point,'YYYY-MM-DD HH24:MI:SS')||' - '||tmpl_01_RSI_event_name||' --- '||TO_CHAR(tmpl_02_MACD_timestamp_point,'YYYY-MM-DD HH24:MI:SS')||' - '||ds_data.EVENT_NAME||' - '||ds_data.EVENT_VECTOR ;
-- debug - RAISE NOTICE 'идентифицировано заполнение шаблона % ', sz_msg ;
                 END IF ; -- конец проверки MACD для точки входа
 
-- -------------------------------------------------
-- проверяем созревание статусов для точки входа
-- -------------------------------------------------
-- вот здесь точку входа мы выбираем не последовательно, а в момент появления всех событий
              IF ( in_timestamp_point IS NULL and tmpl_in_MACD_DOWN_is_detected = true
                   and (v_is_include_current_ema = false or tmpl_in_EMA01_is_detected = true)
                   and (v_is_include_parent_ema = false or tmpl_in_EMA03_is_detected = true)) THEN
                 in_timestamp_point := ds_data.TIMESTAMP_POINT ;
                 RAISE NOTICE '!!! таки точка входа %, RSI = % ts % ev % vc %, MACD = % ts % ev % vc %, EMA1 = % ts % ev % vc %, EMA3 = % ts % ev % vc %', 
                       ds_data.timestamp_point, 
                       tmpl_in_RSI_UP_is_detected, tmpl_in_RSI_UP_timestamp_point, tmpl_in_RSI_UP_event_name, tmpl_in_RSI_UP_event_vector,
                       tmpl_in_MACD_DOWN_is_detected, tmpl_in_MACD_DOWN_timestamp_point, tmpl_in_MACD_DOWN_event_name, tmpl_in_MACD_DOWN_event_vector,
                       tmpl_in_EMA01_is_detected, tmpl_in_EMA01_timestamp_point, tmpl_in_EMA01_event_name, tmpl_in_EMA01_event_vector,
                       tmpl_in_EMA03_is_detected, tmpl_in_EMA03_timestamp_point, tmpl_in_EMA03_event_name, tmpl_in_EMA03_event_vector ;
                 END IF ;
           END IF ; -- конец блока обработичика входа (когда точка выхода пуста)

-- ----------------------------------
-- собираем для точки вЫхода, когда точка входа найдена
-- ----------------------------------
           IF ( in_timestamp_point IS NOT NULL ) THEN
--debug - RAISE NOTICE 'вЫход обрабатываем строку % % %', ds_data.timestamp_point, ds_data.EVENT_NAME, ds_data.event_vector ;
-- если включено и взлетело - выставить, если выключено или упало - сбросить
              IF ( ds_data.EVENT_NAME = 'EMA03_'||v_RSI_time_frame||'_LINE_VECTOR' and ds_data.EVENT_VECTOR = 'UP'
                   and v_is_include_parent_ema = true and tmpl_out_EMA03_is_detected = false ) THEN
                 tmpl_out_EMA03_is_detected := true ; tmpl_out_EMA03_timestamp_point := ds_data.timestamp_point ; tmpl_out_EMA03_event_name := ds_data.event_name ; tmpl_out_EMA03_event_vector := ds_data.event_vector ;
-- debug - RAISE NOTICE '- ищем выход. пошла вниз EMA03 % % %', ds_data.timestamp_point, ds_data.EVENT_NAME, ds_data.event_vector ;
                 END IF ;
              IF ( ds_data.EVENT_NAME = 'EMA03_'||v_RSI_time_frame||'_LINE_VECTOR' and ds_data.EVENT_VECTOR = 'DOWN' and v_is_include_parent_ema = true) THEN
                 tmpl_out_EMA03_is_detected := false ; tmpl_out_EMA03_timestamp_point := NULL ; tmpl_out_EMA03_event_name := NULL ; tmpl_out_EMA03_event_vector := NULL ;
-- debug - RAISE NOTICE '- ищем выход. пошла вверх EMA03 % % %', ds_data.timestamp_point, ds_data.EVENT_NAME, ds_data.event_vector ;
                 END IF ;
-- если включено и взлетело - выставить, если выключено или упало - сбросить
              IF ( ds_data.EVENT_NAME = 'EMA01_'||v_RSI_time_frame||'_LINE_VECTOR' and ds_data.EVENT_VECTOR = 'UP'
				   and v_is_include_current_ema = true and tmpl_out_EMA01_is_detected = false ) THEN
                 tmpl_out_EMA01_is_detected := true ; tmpl_out_EMA01_timestamp_point := ds_data.timestamp_point ; tmpl_out_EMA01_event_name := ds_data.event_name ; tmpl_out_EMA01_event_vector := ds_data.event_vector ;
-- debug - 			     RAISE NOTICE '- ищем выход. пошла вниз EMA01 % % %', ds_data.timestamp_point, ds_data.EVENT_NAME, ds_data.event_vector ;
                 END IF ;
              IF ( ds_data.EVENT_NAME = 'EMA01_'||v_RSI_time_frame||'_LINE_VECTOR' and ds_data.EVENT_VECTOR = 'DOWN' and v_is_include_current_ema = true) THEN
                 tmpl_out_EMA01_is_detected := false ; tmpl_out_EMA01_timestamp_point := NULL ; tmpl_out_EMA01_event_name := NULL ; tmpl_out_EMA01_event_vector := NULL ;
-- debug - RAISE NOTICE '- ищем выход. пошла вверх EMA01 % % %', ds_data.timestamp_point, ds_data.EVENT_NAME, ds_data.event_vector ;
                 END IF ;
-- проверить статус RSI на вЫход, с учетом корректной старшей EMA
              IF (ds_data.EVENT_NAME = 'RSI_'||v_RSI_time_frame||'_DOWN_CROSS_30' and v_is_include_rsi = true and tmpl_out_RSI_DOWN_is_detected = false) THEN
                 tmpl_out_RSI_DOWN_is_detected := true ; tmpl_out_RSI_DOWN_timestamp_point := ds_data.timestamp_point ; tmpl_out_RSI_DOWN_event_name := ds_data.event_name ; tmpl_out_RSI_DOWN_event_vector := ds_data.event_vector ;
-- debug - RAISE NOTICE '- ищем выход.  выставили RSI на вЫход %, EMA1 %, EMA3 % % %', ds_data.timestamp_point, tmpl_in_EMA01_is_detected , tmpl_in_EMA03_is_detected, ds_data.EVENT_NAME, ds_data.event_vector ;
                 END IF ;
              IF ( ds_data.EVENT_NAME = 'RSI_'||v_RSI_time_frame||'_UP_CROSS_70' or v_is_include_rsi = false ) THEN
                 tmpl_out_RSI_DOWN_is_detected := false ; tmpl_out_RSI_DOWN_timestamp_point := NULL ; tmpl_out_RSI_DOWN_event_name := NULL ; tmpl_out_RSI_DOWN_event_vector := NULL ;
-- debug - RAISE NOTICE '- ищем выход. сбросили RSI на вЫход %, EMA1 %, EMA3 % % %', ds_data.timestamp_point, tmpl_in_EMA01_is_detected , tmpl_in_EMA03_is_detected, ds_data.EVENT_NAME, ds_data.event_vector ;
                 END IF ;
-- во второй версии стратегии проверяем, что это первое событие из возможных нескольких, как и в RSI
-- MACD зависит от RSI, если он включен
              IF ( ( (tmpl_out_RSI_DOWN_is_detected = true or v_is_include_rsi = false)
                   and ds_data.EVENT_NAME = 'MACD_'||v_MACD_time_frame||'_'||v_MACD_ind_type||'_'||v_MACD_ind_sub_type 
                   and ds_data.EVENT_VECTOR = 'UP'
                   and tmpl_out_MACD_UP_is_detected = false)) THEN
                 tmpl_out_MACD_UP_is_detected := true ; tmpl_out_MACD_UP_timestamp_point := ds_data.timestamp_point ; tmpl_out_MACD_UP_event_name := ds_data.event_name ; tmpl_out_MACD_UP_event_vector := ds_data.event_vector ;
-- debug - RAISE NOTICE '- ищем выход. выставили MACD на вЫход %, EMA1 %, EMA3 % % %', ds_data.timestamp_point, tmpl_in_EMA01_is_detected , tmpl_in_EMA03_is_detected, ds_data.EVENT_NAME, ds_data.event_vector ;
                 END IF ;
              IF ( ds_data.EVENT_NAME = 'MACD_'||v_MACD_time_frame||'_'||v_MACD_ind_type||'_'||v_MACD_ind_sub_type
                   and ds_data.EVENT_VECTOR = 'DOWN') THEN
                 tmpl_out_MACD_UP_is_detected := false ; tmpl_out_MACD_UP_timestamp_point := NULL ; tmpl_out_MACD_UP_event_name := NULL ; tmpl_out_MACD_UP_event_vector := NULL ;
-- debug - RAISE NOTICE '- ищем выход. сбросили MACD на вЫход %, EMA1 %, EMA3 % % %', ds_data.timestamp_point, tmpl_in_EMA01_is_detected , tmpl_in_EMA03_is_detected, ds_data.EVENT_NAME, ds_data.event_vector ;
                 END IF ;

-- -------------------------------------------------
-- проверяем созревание статусов для точки вЫхода
-- -------------------------------------------------
-- здесь мы тоже не собираем события последовательно, а ждём точки их совпадения, но в отличие от входа выходим по любому событию
               IF (out_timestamp_point IS NULL AND (tmpl_out_MACD_UP_is_detected = true
                  or (false and tmpl_out_EMA01_is_detected = true and v_is_include_current_ema = true)
                  or (false and tmpl_out_EMA03_is_detected = true and v_is_include_parent_ema = true))) THEN
--              sz_msg := 'long точка вЫхода - '||TO_CHAR(tmpl_01_RSI_timestamp_point,'YYYY-MM-DD HH24:MI:SS')||' - '||tmpl_01_RSI_event_name||' --- '||TO_CHAR(tmpl_02_MACD_timestamp_point,'YYYY-MM-DD HH24:MI:SS')||' - '||tmpl_02_MACD_event_name||' - '||tmpl_02_MACD_event_vector ;	  
-- debug RAISE NOTICE 'идентифицировано заполнение шаблона % ', sz_msg ;
                  out_timestamp_point := ds_data.TIMESTAMP_POINT ;
                  RAISE NOTICE '!!! таки точка вЫхода %, RSI = % ts % ev % vc %, MACD = % ts % ev % vc %, EMA1 = % ts % ev % vc %, EMA3 = % ts % ev % vc %',
                        ds_data.timestamp_point, 
                        tmpl_out_RSI_DOWN_is_detected, tmpl_out_RSI_DOWN_timestamp_point, tmpl_out_RSI_DOWN_event_name, tmpl_out_RSI_DOWN_event_vector,
                        tmpl_out_MACD_UP_is_detected, tmpl_out_MACD_UP_timestamp_point, tmpl_out_MACD_UP_event_name, tmpl_out_MACD_UP_event_vector,
                        tmpl_out_EMA01_is_detected, tmpl_out_EMA01_timestamp_point, tmpl_out_EMA01_event_name, tmpl_out_EMA01_event_vector,
                        tmpl_out_EMA03_is_detected, tmpl_out_EMA03_timestamp_point, tmpl_out_EMA03_event_name, tmpl_out_EMA03_event_vector ;
                 if (tmpl_out_EMA01_is_detected = true and v_is_include_current_ema = true) then RAISE NOTICE '--- выход по EMA01' ; end if ;
                 if (tmpl_out_EMA03_is_detected = true and v_is_include_parent_ema = true) then RAISE NOTICE '--- выход по EMA03' ; end if ;
                 if (tmpl_out_MACD_UP_is_detected = true) then RAISE NOTICE '--- выход по MACD' ; end if ;
                 if (v_rsi_time_frame in ('1D','2D','4D','1W','4W') or v_macd_time_frame in ('1D','2D','4D','1W','4W')) then
                    SELECT price_close INTO in_price from crcomp_pair_ohlc_1d_history
                           where timestamp_point  + INTERVAL '3 HOURS' = in_timestamp_point and currency = v_currency and reference_currency = v_reference_currency ;
                    SELECT price_close INTO out_price from crcomp_pair_ohlc_1d_history
                           where timestamp_point + INTERVAL '3 HOURS' = out_timestamp_point and currency = v_currency and reference_currency = v_reference_currency ;
-- здесь максимальная цена на падении высчитывается из минимума, а минимальная из максимума
                    SELECT min(price_low) INTO max_price from crcomp_pair_ohlc_1d_history
                           where timestamp_point + INTERVAL '3 HOURS' >= in_timestamp_point and timestamp_point + INTERVAL '3 HOURS' <= out_timestamp_point and 
                                 currency = v_currency and reference_currency = v_reference_currency ;
                    SELECT max(price_high) INTO min_price from crcomp_pair_ohlc_1d_history
                           where timestamp_point + INTERVAL '3 HOURS' >= in_timestamp_point and timestamp_point + INTERVAL '3 HOURS' <= out_timestamp_point and 
                                 currency = v_currency and reference_currency = v_reference_currency ;
				 end if ;
                 if (v_rsi_time_frame in ('1H','2H','3H','4H','8H','12H') or v_macd_time_frame in ('1H','2H','3H','4H','8H','12H')) then
                    SELECT price_close INTO in_price from crcomp_pair_ohlc_1h_history
                           where timestamp_point + INTERVAL '3 HOURS' = in_timestamp_point and currency = v_currency and reference_currency = v_reference_currency ;
                    SELECT price_close INTO out_price from crcomp_pair_ohlc_1h_history
                           where timestamp_point + INTERVAL '3 HOURS' = out_timestamp_point and currency = v_currency and reference_currency = v_reference_currency ;
-- здесь максимальная цена на падении высчитывается из минимума, а минимальная из максимума
                    SELECT min(price_low) INTO max_price from crcomp_pair_ohlc_1h_history
                           where timestamp_point + INTERVAL '3 HOURS' >= in_timestamp_point and timestamp_point + INTERVAL '3 HOURS' <= out_timestamp_point and
                                 currency = v_currency and reference_currency = v_reference_currency ;
                    SELECT max(price_high) INTO min_price from crcomp_pair_ohlc_1h_history
                           where timestamp_point + INTERVAL '3 HOURS' >= in_timestamp_point and timestamp_point + INTERVAL '3 HOURS' <= out_timestamp_point and
                                 currency = v_currency and reference_currency = v_reference_currency ;
                 end if ; -- конец условного блока выбора таблицы для просадок
                 if (v_rsi_time_frame in ('1M','3M','5M','10M','15M','30M') or v_macd_time_frame in ('1M','3M','5M','10M','15M','30M')) then				 
                    SELECT price_close INTO in_price from crcomp_pair_ohlc_1m_history
                           where timestamp_point + INTERVAL '3 HOURS' = in_timestamp_point and currency = v_currency and reference_currency = v_reference_currency ;
                    SELECT price_close INTO out_price from crcomp_pair_ohlc_1m_history
                           where timestamp_point + INTERVAL '3 HOURS' = out_timestamp_point and currency = v_currency and reference_currency = v_reference_currency ;
-- здесь максимальная цена на падении высчитывается из минимума, а минимальная из максимума
                    SELECT min(price_low) INTO max_price from crcomp_pair_ohlc_1m_history
                           where timestamp_point + INTERVAL '3 HOURS' >= in_timestamp_point and timestamp_point + INTERVAL '3 HOURS' <= out_timestamp_point and
                                 currency = v_currency and reference_currency = v_reference_currency ;
                    SELECT max(price_high) INTO min_price from crcomp_pair_ohlc_1m_history
                           where timestamp_point + INTERVAL '3 HOURS' >= in_timestamp_point and timestamp_point + INTERVAL '3 HOURS' <= out_timestamp_point and
                                 currency = v_currency and reference_currency = v_reference_currency ;
                 end if ;
                 result_record.strategy_name      := 'RSI'||v_RSI_time_frame||'MACD'||v_MACD_time_frame ;
                 result_record.strategy_sub_name  := 'normal' ;
                 result_record.currency           := v_currency ;
                 result_record.reference_currency := v_reference_currency ;
                 result_record.vector             := 'long' ;
                 result_record.profit             := ROUND((( out_price - in_price) * -1 / (in_price / 100)),2) ;
-- если в процессе сделки есть просадка меньше лимита StopLoss - поле защищённой прибыли равно SL
                 if ( (( min_price - in_price) * -100 / in_price) < v_protected_profit ) then
                    result_record.protected_profit := v_protected_profit ;
                 else
                    result_record.protected_profit := ROUND((( out_price - in_price) * -100 / in_price),2) ;
                 end if ;
                 result_record.cn_period           := out_timestamp_point - in_timestamp_point ;
                 result_record.min_prct            := ROUND((( in_price - min_price) / (in_price / 100)),2) ;
                 if ( (( min_price - in_price) * -100 / in_price) < v_protected_profit ) then
                    result_record.prtct_min_prct   := v_protected_profit ;
                 else
                    result_record.prtct_min_prct   := ROUND((( min_price - in_price) * -100 / in_price),2) ;
                 end if ;
                 result_record.max_prct            := ROUND((( in_price - max_price) / (in_price / 100)),2) ;
                 result_record.contract_in_tp      := in_timestamp_point ;
                 result_record.contract_in_price   := in_price ;
                 result_record.contract_out_tp     := out_timestamp_point ;
                 result_record.contract_out_price  := out_price ;
                 result_record.change_ts           := now() ;
                 return next result_record ;

-- debug RAISE NOTICE 'идентифицирована лонговая пара прибыль %, период %, MIN %, MAX % --- вход % (price %), выход % (price %)', 
--           ROUND((( out_price - in_price) / (in_price / 100)),2),
--   TO_CHAR((out_timestamp_point - in_timestamp_point),'MM-DD HH24:MI:SS'),
--   ROUND((( min_price - in_price) / (in_price / 100)),2),
--   ROUND((( max_price - in_price) / (in_price / 100)),2),
--   TO_CHAR(in_timestamp_point,'YYYY-MM-DD HH24:MI:SS'), in_price,
--   TO_CHAR(out_timestamp_point,'YYYY-MM-DD HH24:MI:SS'), out_price ;
                 sum_percent_clear := ROUND((( out_price - in_price) * -1 / (in_price / 100)),2) + sum_percent_clear ;
                 if (ROUND((( out_price - in_price) * -1 / (in_price / 100)),2) < v_protected_profit) then
                    sum_percent_protected := v_protected_profit + sum_percent_protected ;
                 else
                    sum_percent_protected := ROUND((( out_price - in_price) * -1 / (in_price / 100)),2) + sum_percent_protected ;
                 end if ;
                 cnt_contracts := cnt_contracts + 1 ;
-- сбросить все переменные для следующего поиска сделки				 
                 in_timestamp_point := NULL ; out_timestamp_point := NULL ; in_price := NULL ; out_price := NULL ;
                 tmpl_in_EMA01_is_detected := false ; tmpl_in_EMA01_timestamp_point := NULL ; tmpl_in_EMA01_event_name := NULL ; tmpl_in_EMA01_event_vector := NULL ;
                 tmpl_in_EMA03_is_detected := false ; tmpl_in_EMA03_timestamp_point := NULL ; tmpl_in_EMA03_event_name := NULL ; tmpl_in_EMA03_event_vector := NULL ;
                 tmpl_in_RSI_UP_is_detected := false ; tmpl_in_RSI_UP_timestamp_point := NULL ; tmpl_in_RSI_UP_event_name := NULL ; tmpl_in_RSI_UP_event_vector := NULL ;
                 tmpl_in_MACD_DOWN_is_detected := false ; tmpl_in_MACD_DOWN_timestamp_point := NULL ; tmpl_in_MACD_DOWN_event_name := NULL ; tmpl_in_MACD_DOWN_event_vector := NULL ;
                 tmpl_out_EMA01_is_detected := false ; tmpl_out_EMA01_timestamp_point := NULL ; tmpl_out_EMA01_event_name := NULL ; tmpl_out_EMA01_event_vector := NULL ;
                 tmpl_out_EMA03_is_detected := false ; tmpl_out_EMA03_timestamp_point := NULL ; tmpl_out_EMA03_event_name := NULL ; tmpl_out_EMA03_event_vector := NULL ;
                 tmpl_out_RSI_DOWN_is_detected := false ; tmpl_out_RSI_DOWN_timestamp_point := NULL ; tmpl_out_RSI_DOWN_event_name := NULL ; tmpl_out_RSI_DOWN_event_vector := NULL ;
                 tmpl_out_MACD_UP_is_detected := false ; tmpl_out_MACD_UP_timestamp_point := NULL ; tmpl_out_MACD_UP_event_name := NULL ; tmpl_out_MACD_UP_event_vector := NULL ;
-- debug         RAISE NOTICE 'обнулили шаблонные переменные, проверили множественность RAISE' ;
                 END IF ; -- конец обработчика именно MACD
          END IF ; -- конец условного блока обработки точки выхода - когда не пуста точка входа
       END LOOP ;
-- debug   RAISE NOTICE 'Контрактов ЛОНГ %, суммарный рост за период простой %, защищённый %, SL = %', cnt_contracts, sum_percent_clear, sum_percent_protected, SL_value ;
       RETURN ;
       END ;
$BODY$;

-- вот три индикатора показывают минус на фоне старшей EMA - RSI + MACD
select * from check_strategy_rsi_macd_ema_short_as_table('APT', 'USDT', '1H', '4H', 'LINE', 'CROSS', -7, true,
         TO_CHAR(now() - interval '25 month','YYYY-MM-DD HH24:MI:SS'),
         TO_CHAR(now(),'YYYY-MM-DD HH24:MI:SS'), true, true ) ;

select count(*), sum(a.profit), sum(a.protected_profit) from (
select * from check_strategy_rsi_macd_ema_short_as_table('APT', 'USDT', '1H', '4H', 'LINE', 'CROSS', -5, true, 
         TO_CHAR(now() - interval '1200 month','YYYY-MM-DD HH24:MI:SS'),
         TO_CHAR(now(),'YYYY-MM-DD HH24:MI:SS'), true, true )) a;

-- а вот проверяем, куда шла старшая
-- получается, что собирать события последовательно нельзя
-- вечер 30 октября - скорее их нужно собиратьь группами, и в точках пероесечения искать точки входа и выхода
select ema03_state from
rtrsp_events_of_indicators st,
check_strategy_rsi_macd_ema_long_as_table('APT', 'USDT', '10M', '30M', 'LINE', 'VECTOR', -1, true, 
               TO_CHAR(now() - interval '15 month','YYYY-MM-DD HH24:MI:SS'),
               TO_CHAR(now(),'YYYY-MM-DD HH24:MI:SS'), false, true ) dt 
where st.timestamp_point > dt.contract_in_tp and st.timestamp_point < dt.contract_out_tp
 and st.currency = 'APT' and st.reference_currency = 'USDT' and st.time_frame = '10M'  order by st.timestamp_point ;

-- -----------------------------------------
-- запрос и драйвер
-- -----------------------------------------

select count(*), sum(src1.profit)
       from (select contract_in_tp, vector, profit, cn_period, min_prct, max_prct
                    from check_strategy_RSI_MACD_long_as_table('1INCH', 'USDT','1H','4H','LINE','CROSS')
            union all
            select contract_in_tp, vector, profit, cn_period, min_prct, max_prct 
                   from check_strategy_RSI_MACD_short_as_table('1INCH', 'USDT','1H','4H','LINE','CROSS')) src1
where min_prct > -10 ;

DROP FUNCTION public.fn_rtsp_driver_strategy_RSI_MACD_EMA
CREATE OR REPLACE FUNCTION public.fn_rtsp_driver_strategy_rsi_macd_ema(
       v_currency              character varying,
       v_reference_currency    character varying,
       v_rsi_time_frame        character varying,
       v_macd_time_frame       character varying,
       v_macd_ind_type         character varying,
       v_macd_ind_sub_type     character varying,
       v_vector_type           character varying,
       v_protected_profit      real,
       v_is_include_RSI        boolean,
       v_start_date            character varying,
       v_stop_date             character varying,
       v_is_include_ema        boolean,
	   v_is_include_parent_ema boolean)
       RETURNS SETOF rtrsp_analyze_strategy_argegate 
       LANGUAGE 'plpgsql'
AS $BODY$
       DECLARE
       result_record             rtrsp_analyze_strategy_argegate%ROWTYPE ;
       sz_msg                    VARCHAR ;
       rec_result_stat           RECORD ;
       sz_request_stat           VARCHAR ;
       sz_currency_pairs_request VARCHAR ;
       rec_currency_pairs_list   RECORD ;
       err_text_var1             text ;
       err_text_var2             text ;
       err_text_var3             text ;
       BEGIN
       if (v_currency = 'ALL' or v_currency = '') then
          if (v_reference_currency = 'ALL' or v_reference_currency = '') then
             sz_currency_pairs_request = 'select currency, reference_currency from rtrsp_processed_coin_pairs group by currency, reference_currency order by 1, 2' ;
             else
             sz_currency_pairs_request = 'select currency, reference_currency from rtrsp_processed_coin_pairs where reference_currency = '''||v_reference_currency||''' group by currency, reference_currency order by 1, 2' ;
             end if ;
          else
          if (v_reference_currency = 'ALL' or v_reference_currency = '') then
             sz_currency_pairs_request = 'select currency, reference_currency from rtrsp_processed_coin_pairs where currency = '''||v_currency||''' group by currency, reference_currency order by 1, 2' ;
             else
             sz_currency_pairs_request = 'select currency, reference_currency from rtrsp_processed_coin_pairs where currency = '''||v_currency||''' AND reference_currency = '''||v_reference_currency||''' group by currency, reference_currency order by 1, 2' ;
             end if ;
          end if ;
       FOR rec_currency_pairs_list IN EXECUTE sz_currency_pairs_request LOOP
           sz_msg = '[start driver] '||rec_currency_pairs_list.currency||'/'||rec_currency_pairs_list.reference_currency||', RSI ТФ'||v_RSI_time_frame||', MACD ТФ '||v_MACD_time_frame||', старт расчёта статистик стратегии' ;
-- debug RAISE NOTICE '%', sz_msg ;
           if (v_vector_type = 'all') then
              sz_request_stat := 'select sum(cnt_all) cnt_all, sum(cnt_pos) cnt_pos, sum(cnt_neg) cnt_neg, sum(src1.profit) profit,
	                                 sum(src1.protected_profit) protected_profit,
                                         min(min_prct) min_min_prct, avg(min_prct) avg_min_prct, max(max_prct) max_max_prct, avg(max_prct) avg_max_prct,
					                     min(prtct_min_prct) prtct_min_min_prct, avg(prtct_min_prct) prtct_avg_min_prct,
                                         min(contract_in_tp) start_period, max(contract_out_tp) stop_period
                                         from (select contract_in_tp, contract_out_tp, vector, profit, protected_profit, cn_period, min_prct, prtct_min_prct, max_prct, 1 cnt_all, 
                                                      CASE WHEN profit > 0 THEN 1 ELSE 0 END cnt_pos, CASE WHEN profit <= 0 THEN 1 ELSE 0 END cnt_neg
                                                      from check_strategy_RSI_MACD_EMA_long_as_table($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
                                               union all
                                               select contract_in_tp, contract_out_tp, vector, profit, protected_profit, cn_period, min_prct, prtct_min_prct, max_prct, 1 cnt_all,
                                                      CASE WHEN profit > 0 THEN 1 ELSE 0 END cnt_pos, CASE WHEN profit <= 0 THEN 1 ELSE 0 END cnt_neg
                                                      from check_strategy_RSI_MACD_EMA_short_as_table($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)) src1' ;
              end if  ;

           if (v_vector_type = 'long') then
              sz_request_stat := 'select sum(cnt_all) cnt_all, sum(cnt_pos) cnt_pos, sum(cnt_neg) cnt_neg, sum(src1.profit) profit,
	                                 sum(src1.protected_profit) protected_profit,
                                         min(min_prct) min_min_prct, avg(min_prct) avg_min_prct, max(max_prct) max_max_prct, avg(max_prct) avg_max_prct,
					 min(prtct_min_prct) prtct_min_min_prct, avg(prtct_min_prct) prtct_avg_min_prct,
                                         min(contract_in_tp) start_period, max(contract_out_tp) stop_period
                                         from (select contract_in_tp, contract_out_tp, vector, profit, protected_profit, cn_period, min_prct, prtct_min_prct, max_prct, 1 cnt_all,
                                                      CASE WHEN profit > 0 THEN 1 ELSE 0 END cnt_pos, CASE WHEN profit <= 0 THEN 1 ELSE 0 END cnt_neg
                                                      from check_strategy_RSI_MACD_EMA_long_as_table($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)) src1' ;
              end if ;

           if (v_vector_type = 'short') then
              sz_request_stat := 'select sum(cnt_all) cnt_all, sum(cnt_pos) cnt_pos, sum(cnt_neg) cnt_neg, sum(src1.profit) profit,
	                                 sum(src1.protected_profit) protected_profit,
                                         min(min_prct) min_min_prct, avg(min_prct) avg_min_prct, max(max_prct) max_max_prct, avg(max_prct) avg_max_prct,
					 min(prtct_min_prct) prtct_min_min_prct, avg(prtct_min_prct) prtct_avg_min_prct, 
					 min(contract_in_tp) start_period, max(contract_out_tp) stop_period
                                         from (select contract_in_tp, contract_out_tp, vector, profit, protected_profit, cn_period, min_prct, prtct_min_prct, max_prct, 1 cnt_all,
                                                      CASE WHEN profit > 0 THEN 1 ELSE 0 END cnt_pos, CASE WHEN profit <= 0 THEN 1 ELSE 0 END cnt_neg
                                                      from check_strategy_RSI_MACD_EMA_short_as_table($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)) src1' ;
              end if ;

-- RAISE NOTICE '%', sz_request_stat ;
           FOR rec_result_stat IN EXECUTE sz_request_stat USING 
	           rec_currency_pairs_list.currency, rec_currency_pairs_list.reference_currency, v_RSI_time_frame, v_MACD_time_frame, v_MACD_ind_type, v_MACD_ind_sub_type, v_protected_profit, v_is_include_RSI, v_start_date, v_stop_date, v_is_include_ema, v_is_include_parent_ema LOOP
               result_record.strategy_name      := 'RSI_'||v_RSI_time_frame||'_MACD_'||v_MACD_time_frame||'_'||v_MACD_ind_type||'_'||v_MACD_ind_sub_type ;
               result_record.strategy_sub_name  := 'normal' ;
               result_record.currency           := rec_currency_pairs_list.currency ;
               result_record.reference_currency := rec_currency_pairs_list.reference_currency ;
               result_record.vector_type        := v_vector_type ;
               result_record.profit             := round(rec_result_stat.profit::numeric, 2) ;
	       result_record.protected_profit   := round(rec_result_stat.protected_profit::numeric, 2) ;
               result_record.count_all          := rec_result_stat.cnt_all ;
               result_record.prct_count_pos     := round(rec_result_stat.cnt_pos * 100 / rec_result_stat.cnt_all, 2 ) ;
               result_record.prct_count_neg     := round(rec_result_stat.cnt_neg * 100 / rec_result_stat.cnt_all, 2 ) ;
               result_record.min_min_prct       := round(rec_result_stat.min_min_prct::numeric, 2) ;
               result_record.avg_min_prct       := round(rec_result_stat.avg_min_prct::numeric, 2) ;
               result_record.max_max_prct       := round(rec_result_stat.max_max_prct::numeric, 2) ;
               result_record.avg_max_prct       := round(rec_result_stat.avg_max_prct::numeric, 2) ;
	           result_record.prtct_min_min_prct := round(rec_result_stat.prtct_min_min_prct::numeric, 2) ;
               result_record.prtct_avg_min_prct := round(rec_result_stat.prtct_avg_min_prct::numeric, 2) ;
               result_record.start_period       := rec_result_stat.start_period ;
               result_record.stop_period        := rec_result_stat.stop_period ;
               result_record.change_ts          := now() ;

-- debug RAISE NOTICE 'currency %, ref_curr %, count %, profit %, prct_pos_cntr %, prct_neg_cntr %, min_min %, avg_min %, max_max %, avg_max %', 
--         rec_currency_pairs_list.currency, v_reference_currency, rec_result_stat.cnt_all, rec_result_stat.profit,
--         round(rec_result_stat.cnt_pos * 100 / rec_result_stat.cnt_all, 2 ), round(rec_result_stat.cnt_neg * 100 / rec_result_stat.cnt_all, 2 ),
--         round(rec_result_stat.min_min_prct::numeric, 2), round(rec_result_stat.avg_min_prct::numeric, 2),
--         round(rec_result_stat.max_max_prct::numeric, 2), round(rec_result_stat.avg_max_prct::numeric, 2) ;
               RETURN NEXT result_record ;
               END LOOP ;
           END LOOP ;
       RETURN ;
       END ;
$BODY$;


select src4.*, round((profit / int_period * 30)::numeric,2) profit_per_month, round((protected_profit / int_period * 30)::numeric,2) prtct_profit_per_month 
       from ( select *, CASE WHEN extract(day from stop_period - start_period) > 0 THEN extract(day from stop_period - start_period) ELSE 1 END int_period 
			         from fn_rtsp_driver_strategy_RSI_MACD_EMA('APT','USDT','1H','4H', 'LINE', 'CROSS', 'all', -5, true, '2022-07-01 00:00:00', '2033-07-01 00:00:00', 'true', 'true')) src4 order by prtct_profit_per_month desc ; 

-- вытаскиваем разные индикаторы рядом
select * from  fn_rtsp_driver_strategy_RSI_MACD('', '', '1H', '4H', 'LINE', 'CROSS', 'all')
UNION ALL
select * from  fn_rtsp_driver_strategy_RSI_MACD('', 'USDT', '1H', '4H', 'LINE', 'VECTOR', 'all')
UNION ALL
select * from  fn_rtsp_driver_strategy_RSI_MACD('', 'USDT', '1H', '4H', 'GIST', 'VECTOR', 'all')
UNION ALL
select * from  fn_rtsp_driver_strategy_RSI_MACD('', 'USDT', '1H', '1H', 'LINE', 'CROSS', 'all')
UNION ALL
select * from  fn_rtsp_driver_strategy_RSI_MACD('', 'USDT', '1H', '1H', 'LINE', 'VECTOR', 'all')
UNION ALL
select * from  fn_rtsp_driver_strategy_RSI_MACD('', 'USDT', '1H', '1H', 'GIST', 'VECTOR', 'all')
order by profit desc, currency, strategy_name ;

select * from  fn_rtsp_driver_strategy_RSI_MACD('', 'USDT', '1H', '4H', 'GIST', 'VECTOR', 'all')
UNION ALL
select * from  fn_rtsp_driver_strategy_RSI_MACD('', 'USDT', '1H', '1H', 'GIST', 'VECTOR', 'all')
order by profit desc, currency, strategy_name ;

select *, extract(day from stop_period - start_period) int_period, 
round((profit / extract(day from stop_period - start_period)*30)::numeric,2) profit_per_month 

from fn_rtsp_driver_strategy_RSI_MACD('PEPE','USDT','1H', '1H', 'LINE', 'CROSS', 'all', -5) UNION ALL 


select *, extract(day from stop_period - start_period) int_period, 
round((profit / extract(day from stop_period - start_period)*30)::numeric,2) profit_per_month from fn_rtsp_driver_strategy_RSI_MACD('PEPE','USDT','1H', '1H', 'LINE', 'CROSS', 'all', -5) UNION ALL select *, extract(day from stop_period - start_period) int_period, round((profit / extract(day from stop_period - start_period)*30)::numeric,2) profit_per_month, round((protected_profit / extract(day from stop_period - start_period)*30)::numeric,2) prtct_profit_per_month from fn_rtsp_driver_strategy_RSI_MACD('PEPE','USDT','1H', '1H', 'LINE', 'VECTOR', 'all', -5) UNION ALL select *, extract(day from stop_period - start_period) int_period, round((profit / extract(day from stop_period - start_period)*30)::numeric,2) profit_per_month, round((protected_profit / extract(day from stop_period - start_period)*30)::numeric,2) prtct_profit_per_month from fn_rtsp_driver_strategy_RSI_MACD('PEPE','USDT','1H', '1H', 'GIST', 'VECTOR', 'all', -5) order by profit_per_month desc, profit desc, currency, strategy_name ; 


select src.*,
       round((profit / int_period * 30)::numeric,2) profit_per_month, 
	   round((protected_profit / int_period * 30)::numeric,2) prtct_profit_per_month 
	   from (
select *, CASE WHEN extract(day from stop_period - start_period) > 0 THEN extract(day from stop_period - start_period) ELSE 1 END int_period
	   from fn_rtsp_driver_strategy_RSI_MACD('ALL', 'USDT', '1H', '1H', 'LINE', 'CROSS', 'all', -70, false, 


-- ---------------------------------------------------------------------------------------------------------------------------
-- 1.19 конец -- таблицы и функции заполнения ретроспективной стратегии RSI+MACD+EMA+EMAst
-- ---------------------------------------------------------------------------------------------------------------------------



-- ---------------------------------------------------------------------------------------------------------------------------
-- 2.1 разное
-- ---------------------------------------------------------------------------------------------------------------------------

--select fn_fill_gecko_minutes_ohlc(CAST('1inch' AS VARCHAR), CAST('usd' AS VARCHAR), CAST(1683846000 AS timestamp without time zone), 0.40926, 0.40926, 0.408871, 0.408871) ;

-- 2023-04-28 недельная волатильность (окно расчёта 7 дней)
-- drop view vw_volatility_weekly ;
create view vw_volatility_weekly as (
       select ds_win1.currency, ds_win1.reference_currency, ds_win1.day_date, ds_win1.price_close, round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WEEK_VOL
              from (select currency, reference_currency, day_date, price_close,
                           min(price_min) OVER (PARTITION BY currency, reference_currency ORDER BY day_date ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as MIN_PRICE,
                           max(price_max) OVER (PARTITION BY currency, reference_currency ORDER BY day_date ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as MAX_PRICE
                           from  curr_pair_history
                           order by currency, reference_currency, day_date ) ds_win1
              order by ds_win1.currency, ds_win1.reference_currency, ds_win1.day_date DESC) ;

-- вариант без не нужных сортировок
create view vw_volatility_weekly as (
       select ds_win1.currency, ds_win1.reference_currency, ds_win1.day_date, ds_win1.price_close, round(((ds_win1.MAX_PRICE - ds_win1.MIN_PRICE)/(ds_win1.MIN_PRICE/100)),2) as WEEK_VOL
              from (select currency, reference_currency, day_date, price_close,
                           min(price_min) OVER (PARTITION BY currency, reference_currency ORDER BY day_date ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as MIN_PRICE,
                           max(price_max) OVER (PARTITION BY currency, reference_currency ORDER BY day_date ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as MAX_PRICE
                           from  curr_pair_history) ds_win1 ) ;

select * from vw_volatility_weekly where currency = 'ETH' and reference_currency  ='USD' order by day_date asc ;


DECLARE
cntEditString = 0 ;
BEGIN
        SELECT count(1) INTO cntEditString
               FROM curr_pair_history
               WHERE currency = '' AND reference_currency = '' AND day_date = '' ;
        IF cntEditString > 0 THEN
           UPDATE curr_pair_history SET price_open = '' , price_max = '', price_min = '', price_close = '', volume_from = '', volume_to = ''
                  WHERE currency, reference_currency, day_date ;
        ELSE
           INSERT INTO curr_pair_history (currency, reference_currency, day_date, price_open, price_max, price_min, price_close, volume_from, volume_to)
                  VALUES () ;
        END ;
END;

insert into curr_pair_history (currency, reference_currency, day_date, price_open, price_max, price_min, price_close, volume_from, volume_to).
values ('TRX', 'USD', '2020-03-27', 0.01188, 0.01209, 0.01106, 0.01118, 6278981.51, 72806.19) ;

DO $$DECLARE
cntEditString integer ;
BEGIN
        cntEditString := 0 ;
END$$;



DO $$DECLARE
cntEditString INTEGER ;
cntEditString_nochanged INTEGER ;
BEGIN
        cntEditString := 0 ;
        SELECT count(*) INTO cntEditString
               FROM curr_pair_history
               WHERE currency = 'TRX' AND reference_currency = 'USD' AND day_date = '2020-03-27' ;
        IF cntEditString > 0 THEN
           cntEditString_nochanged := 0 ;
           SELECT count(*) INTO cntEditString_nochanged
                  FROM curr_pair_history
                  WHERE currency = 'TRX' AND reference_currency = 'USD' AND day_date = '2020-03-27'
                        AND price_open = 0.01188 AND price_max = 0.01209 AND price_min = 0.01106 AND price_close = 0.01118 AND volume_from = 6278981.51 AND volume_to = 72806.19 ;
                        IF cntEditString_nochanged = 0 THEN
                           UPDATE curr_pair_history SET price_open = 0.01188 , price_max = 0.01209, price_min = 0.01106, price_close = 0.01118, volume_from = 6278981.51, volume_to = 72806.19
                                  WHERE currency = 'TRX' AND reference_currency = 'USD' AND day_date = '2020-03-27' ;
                        END IF ;
        ELSE
           INSERT INTO curr_pair_history (currency, reference_currency, day_date, price_open, price_max, price_min, price_close, volume_from, volume_to)
                  VALUES ('TRX', 'USD', '2020-03-27', 0.01188, 0.01209, 0.01106, 0.01118, 6278981.51, 72806.19) ;
        END IF ;
END$$;

-- №№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№


select count(*) from rtrsp_ohlc_1m_history ; 
delete from  rtrsp_ohlc_1m_history ; 

-- блок восстановления после неудачного добавления данных  в основную таблицу ТФ1D
create table crcomp_pair_ohlc_1d_history_2 as select * from crcomp_pair_ohlc_1d_history ; 
select count(*) from crcomp_pair_ohlc_1d_history ;
select * from crcomp_pair_OHLC_1D_history where currency = 'BTC' AND timestamp_point > TO_TIMESTAMP('2023-03-11 12:00:00','YYYY-MM-DD HH24:MI:SS') limit 10000;
select currency,count(*) from crcomp_pair_OHLC_1D_history 
         where currency = 'BTC' AND timestamp_point > TO_TIMESTAMP('2023-03-11 12:00:00','YYYY-MM-DD HH24:MI:SS') 
               AND TO_CHAR(timestamp_point,'HH24:MI:SS') <> '00:00:00'
         group  by currency ;
select currency,count(*) from crcomp_pair_OHLC_1D_history 
         where currency = 'BTC' AND TO_CHAR(timestamp_point,'HH24:MI:SS') <> '00:00:00'
         group  by currency ;
select count(*) from crcomp_pair_OHLC_1D_history ;

delete from crcomp_pair_OHLC_1D_history  where currency = 'BTC' AND TO_CHAR(timestamp_point,'HH24:MI:SS') <> '00:00:00' ;
-- конец блок восстановления после неудачного добавления данных  в основную таблицу ТФ1D


select TO_TIMESTAMP('2023-03-11 12:00:00','YYYY-MM-DD HH24:MI:SS') ;

-- тест работает ли ИН со списком цифр
drop function test_01 (n_test INTEGER) ;
create or replace function test_01 (n_test INTEGER) RETURNS varchar AS
$BODY$
BEGIN
if (n_test IN (2,3,6,7,8)) then return 'ok = '||n_test ; 
else return 'NO = '||n_test ; 
end if ;
END ;
$BODY$
LANGUAGE plpgsql VOLATILE ;

select test_01(6) ;
       






































											 '2022-07-01 00:00:00', '2033-07-01 00:00:00')) src order by prtct_profit_per_month desc ;

