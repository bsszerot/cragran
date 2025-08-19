
select count(*) from crcomp_pair_ohlc_1h_history ;
select * from pg_proc where proname like 'fn_fill_crcomp%'
CREATE TABLE crcomp_pair_ohlc_1h_history_20240807_1820_multi AS select * from crcomp_pair_ohlc_1h_history a1 ;

-- наша временная таблица
--DROP TABLE public.crcomp_pair_ohlc_1h_history_X1 ;
CREATE TABLE IF NOT EXISTS public.crcomp_pair_ohlc_1h_history_X1
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

-- DROP INDEX IF EXISTS public.crcomp_idx_pair_ohlc_1h_hist_X1_metadata_01
CREATE UNIQUE INDEX crcomp_idx_pair_ohlc_1h_hist_X1_metadata_01 
       ON crcomp_pair_ohlc_1h_history_X1 (currency, reference_currency, timestamp_point);

select count(*) from crcomp_pair_ohlc_1h_history ;

-- заливаем промежуточную таблицу, ранжируем одинаковые записи по времени правки, и выбираем позднейшие
insert into crcomp_pair_ohlc_1h_history_X1 (
select currency, reference_currency, timestamp_point, price_open, price_high, price_low, price_close, volume_from,
       volume_to, change_ts
	   from ( select ROW_NUMBER() OVER (partition by currency, reference_currency, timestamp_point
										ORDER BY change_ts DESC) sz_ranc, *
                     from crcomp_pair_ohlc_1h_history) a2
	   where sz_ranc = 1 
       order by currency, reference_currency, timestamp_point ASC) ;
COMMIT ;

-- FUNCTION: public.fn_fill_crcomp_1h_ohlc(character varying, character varying, timestamp without time zone, numeric, numeric, numeric, numeric, numeric, numeric)
-- DROP FUNCTION IF EXISTS public.fn_fill_crcomp_1h_ohlc(character varying, character varying, timestamp without time zone, numeric, numeric, numeric, numeric, numeric, numeric);

-- 20240806_01 после каждой записи добавлен COMMIT, 
-- также в таблице создан PRIMARY и уникальный индекс для защиты от дублирования записей - можно только удалить или обновить
	
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
CREATE UNIQUE INDEX crcomp_idx_pair_ohlc_1h_hist_metadata_01 
       ON crcomp_pair_ohlc_1h_history (currency, reference_currency, timestamp_point);

-- DROP INDEX IF EXISTS crcomp_idx_pair_ohlc_1h_hist_metadata_chtm_01;
CREATE INDEX IF NOT EXISTS crcomp_idx_pair_ohlc_1h_hist_metadata_chtm_01
    ON crcomp_pair_ohlc_1h_history 
       (change_ts, currency, reference_currency, timestamp_point ASC NULLS LAST) ;

--insert into crcomp_pair_ohlc_1h_history (
--select currency, reference_currency, timestamp_point, price_open, price_high, price_low, price_close, volume_from,
--       volume_to, change_ts
--	   from ( select ROW_NUMBER() OVER (partition by currency, reference_currency, timestamp_point
--										ORDER BY change_ts DESC) sz_ranc, *
--                     from crcomp_pair_ohlc_1h_history_X1) a2
--	   where sz_ranc = 1 
--       order by currency, reference_currency, timestamp_point ASC) ;

-- когда уже подготовлена промежуточная таблица, скрипты ниже, удаляем, пересоздаём и заливаем основную минутную
-- INSERT INTO crcomp_pair_ohlc_1h_history 
--       SELECT * from crcomp_pair_ohlc_1h_history_X1 ORDER BY currency, reference_currency, timestamp_point ASC ;

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



-- -------------------------------------------------------
-- проверка после исправления - всё по нулям, убрано из полутора миллионов около 50 тысяч записей


-- выявлена проблема задваивания записей
select count(*), timestamp_point, currency, reference_currency
       from public.crcomp_pair_ohlc_1h_history
   group by timestamp_point, currency, reference_currency
   having count(*) > 1
   order by 1 desc
-- и их количество
select count(*) from
(select count(*), timestamp_point, currency, reference_currency
       from public.crcomp_pair_ohlc_1h_history
   group by timestamp_point, currency, reference_currency
   having count(*) > 1
   order by 1 desc) a ;
-- мультизаписей для 1М - 137435 - даже если их по 5, это около 800 тыс. на 45 млн. таблицу

-- а вот совершенно одинаковые
select count(*), timestamp_point, currency, reference_currency, price_open, price_low, price_high, price_close, volume_from, volume_to
       from public.crcomp_pair_ohlc_1h_history
   group by timestamp_point, currency, reference_currency, price_open, price_low, price_high, price_close, volume_from, volume_to
   having count(*) > 1
   order by 1 desc
-- и их количество
select count(*) from
       (select count(*), timestamp_point, currency, reference_currency, price_open, price_low, price_high, price_close, volume_from, volume_to
       from public.crcomp_pair_ohlc_1h_history
   group by timestamp_point, currency, reference_currency, price_open, price_low, price_high, price_close, volume_from, volume_to
   having count(*) > 1
   order by 1 desc) a ;
-- одинаковых мультизаписей для 1М - 136694 - почти все записи с одинаковыми данными, отличается 741 запись

	
